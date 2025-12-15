 
-- ==================================================================================================== 
-- Start : mist.lua 
--[[--
MIST Mission Scripting Tools.
## Description:
MIssion Scripting Tools (MIST) is a collection of Lua functions
and databases that is intended to be a supplement to the standard
Lua functions included in the simulator scripting engine.

MIST functions and databases provide ready-made solutions to many common
scripting tasks and challenges, enabling easier scripting and saving
mission scripters time. The table mist.flagFuncs contains a set of
Lua functions (that are similar to Slmod functions) that do not
require detailed Lua knowledge to use.

However, the majority of MIST does require knowledge of the Lua language,
and, if you are going to utilize these components of MIST, it is necessary
that you read the Simulator Scripting Engine guide on the official ED wiki.

## Links:

ED Forum Thread: <http://forums.eagle.ru/showthread.php?t=98616>

##Github:

Development <https://github.com/mrSkortch/MissionScriptingTools>

Official Releases <https://github.com/mrSkortch/MissionScriptingTools/tree/master>

@script MIST
@author Speed
@author Grimes
@author lukrop
]]
mist = {}

-- don't change these
mist.majorVersion = 4
mist.minorVersion = 5
mist.build = "128-DYNSLOTS-02"

-- forward declaration of log shorthand
local log
local dbLog

local mistSettings = {
	errorPopup = false, -- errors printed by mist logger will create popup warning you
	warnPopup = false,
	infoPopup = false,
	logLevel = 'warn',
	dbLog = 'warn',
}

do -- the main scope
	local coroutines = {}

	local tempSpawnedUnits = {} -- birth events added here
	local tempSpawnedGroups = {}
	local tempSpawnGroupsCounter = 0

	local mistAddedObjects = {} -- mist.dynAdd unit data added here
	local mistAddedGroups = {} -- mist.dynAdd groupdata added here
	local writeGroups = {}
	local lastUpdateTime = 0

	local updateAliveUnitsCounter = 0
	local updateTenthSecond = 0

	local mistGpId = 70000
	local mistUnitId = 70000
	local mistDynAddIndex = { [' air '] = 0, [' hel '] = 0, [' gnd '] = 0, [' bld '] = 0, [' static '] = 0, [' shp '] = 0 }

	local scheduledTasks = {}
	local taskId = 0
	local idNum = 0

	mist.nextGroupId = 1
	mist.nextUnitId = 1



	local function initDBs() -- mist.DBs scope
		mist.DBs = {}
		mist.DBs.markList = {}
		mist.DBs.missionData = {}
		if env.mission then
			mist.DBs.missionData.startTime = env.mission.start_time
			mist.DBs.missionData.theatre = env.mission.theatre
			mist.DBs.missionData.version = env.mission.version
			mist.DBs.missionData.files = {}
			if type(env.mission.resourceCounter) == 'table' then
				for fIndex, fData in pairs(env.mission.resourceCounter) do
					mist.DBs.missionData.files[#mist.DBs.missionData.files + 1] = mist.utils.deepCopy(fIndex)
				end
			end
			-- if we add more coalition specific data then bullseye should be categorized by coaliton. For now its just the bullseye table
			mist.DBs.missionData.bullseye = {}
			mist.DBs.missionData.countries = {}
		end


		mist.DBs.drawingByName = {}
		mist.DBs.drawingIndexed = {}

		if env.mission.drawings and env.mission.drawings.layers then
			for i = 1, #env.mission.drawings.layers do
				local l = env.mission.drawings.layers[i]

				for j = 1, #l.objects do
					local copy = mist.utils.deepCopy(l.objects[j])
					--log:warn(copy)
					local doOffset = false
					copy.layer = l.name

					local theta = copy.angle or 0
					theta = math.rad(theta)
					if copy.primitiveType == "Polygon" then
						if copy.polygonMode == 'rect' then
							local h, w = copy.height, copy.width
							copy.points = {}
							copy.points[1] = { x = h / 2, y = w / 2 }
							copy.points[2] = { x = -h / 2, y = w / 2 }
							copy.points[3] = { x = -h / 2, y = -w / 2 }
							copy.points[4] = { x = h / 2, y = -w / 2 }
							doOffset = true
						elseif copy.polygonMode == "circle" then
							copy.points = { x = copy.mapX, y = copy.mapY }
						elseif copy.polygonMode == 'oval' then
							copy.points = {}
							local numPoints = 24
							local angleStep = (math.pi * 2) / numPoints
							doOffset = true
							for v = 1, numPoints do
								local pointAngle = v * angleStep
								local x = copy.r1 * math.cos(pointAngle)
								local y = copy.r2 * math.sin(pointAngle)

								table.insert(copy.points, { x = x, y = y })
							end
						elseif copy.polygonMode == "arrow" then
							doOffset = true
						end


						if theta ~= 0 and copy.points and doOffset == true then
							--log:warn('offsetting Values')
							for p = 1, #copy.points do
								local offset = mist.vec.rotateVec2(copy.points[p], theta)
								copy.points[p] = offset
							end
							--log:warn(copy.points[1])
						end
					elseif copy.primitiveType == "Line" and copy.closed == true then
						table.insert(copy.points, mist.utils.deepCopy(copy.points[1]))
					end
					if copy.points and #copy.points > 1 then
						for u = 1, #copy.points do
							copy.points[u].x = mist.utils.round(copy.points[u].x + copy.mapX, 2)
							copy.points[u].y = mist.utils.round(copy.points[u].y + copy.mapY, 2)
						end
					end
					if mist.DBs.drawingByName[copy.name] then
						log:warn(
							"Drawing by the name of [ $1 ] already exists in DB. Failed to add to mist.DBs.drawingByName.",
							copy.name)
					else
						mist.DBs.drawingByName[copy.name] = copy
					end
					table.insert(mist.DBs.drawingIndexed, copy)
				end
			end
		end

		local abRef = { units = {}, airbase = {} }
		for ind, val in pairs(world.getAirbases()) do
			local cat = "airbase"
			if Airbase.getDesc(val).category > 0 then
				cat = "units"
			end
			abRef[cat][tonumber(val:getID())] = { name = val:getName() }
		end


		mist.DBs.navPoints = {}
		mist.DBs.units = {}
		--Build mist.db.units and mist.DBs.navPoints
		for coa_name_miz, coa_data in pairs(env.mission.coalition) do
			local coa_name = coa_name_miz
			if string.lower(coa_name_miz) == 'neutrals' then
				coa_name = 'neutral'
			end
			local coaEnum = coalition.side[string.upper(coa_name)]
			if type(coa_data) == 'table' then
				mist.DBs.units[coa_name] = {}

				if coa_data.bullseye then
					mist.DBs.missionData.bullseye[coa_name] = {}
					mist.DBs.missionData.bullseye[coa_name].x = coa_data.bullseye.x
					mist.DBs.missionData.bullseye[coa_name].y = coa_data.bullseye.y
				end
				-- build nav points DB
				mist.DBs.navPoints[coa_name] = {}
				if coa_data.nav_points then --navpoints
					--mist.debug.writeData (mist.utils.serialize,{'NavPoints',coa_data.nav_points}, 'NavPoints.txt')
					for nav_ind, nav_data in pairs(coa_data.nav_points) do
						if type(nav_data) == 'table' then
							mist.DBs.navPoints[coa_name][nav_ind] = mist.utils.deepCopy(nav_data)

							mist.DBs.navPoints[coa_name][nav_ind].name = nav_data
								.callsignStr            -- name is a little bit more self-explanatory.
							mist.DBs.navPoints[coa_name][nav_ind].point = {} -- point is used by SSE, support it.
							mist.DBs.navPoints[coa_name][nav_ind].point.x = nav_data.x
							mist.DBs.navPoints[coa_name][nav_ind].point.y = 0
							mist.DBs.navPoints[coa_name][nav_ind].point.z = nav_data.y
						end
					end
				end
				if coa_data.country then --there is a country table
					for cntry_id, cntry_data in pairs(coa_data.country) do
						local countryName = string.lower(cntry_data.name)
						if cntry_data.id and country.names[cntry_data.id] then
							countryName = string.lower(country.names[cntry_data.id])
						end
						mist.DBs.missionData.countries[countryName] = coa_name
						mist.DBs.units[coa_name][countryName] = {}
						mist.DBs.units[coa_name][countryName].countryId = cntry_data.id

						if type(cntry_data) == 'table' then                                                                                                --just making sure
							for obj_cat_name, obj_cat_data in pairs(cntry_data) do
								if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then --should be an unncessary check
									local category = obj_cat_name

									if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
										mist.DBs.units[coa_name][countryName][category] = {}

										for group_num, group_data in pairs(obj_cat_data.group) do
											local helipadId
											local airdromeId

											if group_data.route and group_data.route.points and group_data.route.points[1] then
												if group_data.route.points[1].airdromeId then
													airdromeId = group_data.route.points[1].airdromeId
													--table.insert(abRef.airbase[group_data.route.points[1].airdromeId], group_data.groupId)
												elseif group_data.route.points[1].helipadId then
													helipadId = group_data.route.points[1].helipadId
													--table.insert(abRef.units[group_data.route.points[1].helipadId], group_data.groupId)
												end
											end
											if group_data and group_data.units and type(group_data.units) == 'table' then --making sure again- this is a valid group
												mist.DBs.units[coa_name][countryName][category][group_num] = {}
												local groupName = group_data.name
												if env.mission.version > 7 and env.mission.version < 19 then
													groupName = env.getValueDictByKey(groupName)
												end
												mist.DBs.units[coa_name][countryName][category][group_num].groupName =
													groupName
												mist.DBs.units[coa_name][countryName][category][group_num].groupId =
													group_data.groupId
												mist.DBs.units[coa_name][countryName][category][group_num].category =
													category
												mist.DBs.units[coa_name][countryName][category][group_num].coalition =
													coa_name
												mist.DBs.units[coa_name][countryName][category][group_num].coalitionId =
													coaEnum
												mist.DBs.units[coa_name][countryName][category][group_num].country =
													countryName
												mist.DBs.units[coa_name][countryName][category][group_num].countryId =
													cntry_data.id
												mist.DBs.units[coa_name][countryName][category][group_num].startTime =
													group_data.start_time
												mist.DBs.units[coa_name][countryName][category][group_num].task =
													group_data.task
												mist.DBs.units[coa_name][countryName][category][group_num].hidden =
													group_data.hidden

												mist.DBs.units[coa_name][countryName][category][group_num].units = {}

												mist.DBs.units[coa_name][countryName][category][group_num].radioSet =
													group_data.radioSet
												mist.DBs.units[coa_name][countryName][category][group_num].uncontrolled =
													group_data.uncontrolled
												mist.DBs.units[coa_name][countryName][category][group_num].frequency =
													group_data.frequency
												mist.DBs.units[coa_name][countryName][category][group_num].modulation =
													group_data.modulation

												for unit_num, unit_data in pairs(group_data.units) do
													local units_tbl = mist.DBs.units[coa_name][countryName][category]
														[group_num]
														.units --pointer to the units table for this group

													units_tbl[unit_num] = {}
													if env.mission.version > 7 and env.mission.version < 19 then
														units_tbl[unit_num].unitName = env.getValueDictByKey(unit_data
															.name)
													else
														units_tbl[unit_num].unitName = unit_data.name
													end
													units_tbl[unit_num].type = unit_data.type
													units_tbl[unit_num].skill = unit_data
														.skill --will be nil for statics
													units_tbl[unit_num].unitId = unit_data.unitId
													units_tbl[unit_num].category = category
													units_tbl[unit_num].coalition = coa_name
													units_tbl[unit_num].coalitionId = coaEnum

													units_tbl[unit_num].country = countryName
													units_tbl[unit_num].countryId = cntry_data.id
													units_tbl[unit_num].heading = unit_data.heading
													units_tbl[unit_num].playerCanDrive = unit_data.playerCanDrive
													units_tbl[unit_num].alt = unit_data.alt
													units_tbl[unit_num].alt_type = unit_data.alt_type
													units_tbl[unit_num].speed = unit_data.speed
													units_tbl[unit_num].livery_id = unit_data.livery_id
													if unit_data.point then --ME currently does not work like this, but it might one day
														units_tbl[unit_num].point = unit_data.point
													else
														units_tbl[unit_num].point = {}
														units_tbl[unit_num].point.x = unit_data.x
														units_tbl[unit_num].point.y = unit_data.y
													end
													units_tbl[unit_num].x = unit_data.x
													units_tbl[unit_num].y = unit_data.y

													units_tbl[unit_num].callsign = unit_data.callsign
													units_tbl[unit_num].onboard_num = unit_data.onboard_num
													units_tbl[unit_num].hardpoint_racks = unit_data.hardpoint_racks
													units_tbl[unit_num].psi = unit_data.psi

													if helipadId then
														units_tbl[unit_num].helipadId = mist.utils.deepCopy(helipadId)
													end
													if airdromeId then
														units_tbl[unit_num].airdromeId = mist.utils.deepCopy(airdromeId)
													end

													units_tbl[unit_num].groupName = groupName
													units_tbl[unit_num].groupId = group_data.groupId
													units_tbl[unit_num].linkUnit = unit_data.linkUnit
													if unit_data.AddPropAircraft then
														units_tbl[unit_num].AddPropAircraft = unit_data.AddPropAircraft
													end

													if category == 'static' then
														units_tbl[unit_num].categoryStatic = unit_data.category
														units_tbl[unit_num].shape_name = unit_data.shape_name
														if group_data.linkOffset then
															if group_data.route and group_data.route.points and group_data.route.points[1] and group_data.route.points[1].linkUnit then
																units_tbl[unit_num].linkUnit = group_data.route.points
																	[1].linkUnit
															end
															units_tbl[unit_num].offset = unit_data.offsets
														end

														if unit_data.mass then
															units_tbl[unit_num].mass = unit_data.mass
														end

														if unit_data.canCargo then
															units_tbl[unit_num].canCargo = unit_data.canCargo
														end

														if unit_data.category == "Heliports" then
															if not abRef.units[unit_data.unitId] then
																abRef.units[unit_data.unitId] = { name = unit_data.name }
															end
														end
													end
												end --for unit_num, unit_data in pairs(group_data.units) do
											end --if group_data and group_data.units then
										end --for group_num, group_data in pairs(obj_cat_data.group) do
									end --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
								end --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
							end --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
						end --if type(cntry_data) == 'table' then
					end --for cntry_id, cntry_data in pairs(coa_data.country) do
				end --if coa_data.country then --there is a country table
			end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
		end     --for coa_name, coa_data in pairs(mission.coalition) do

		mist.DBs.unitsByName = {}
		mist.DBs.unitsById = {}
		mist.DBs.unitsByCat = {}

		mist.DBs.unitsByCat.helicopter = {} -- adding default categories
		mist.DBs.unitsByCat.plane = {}
		mist.DBs.unitsByCat.ship = {}
		mist.DBs.unitsByCat.static = {}
		mist.DBs.unitsByCat.vehicle = {}

		mist.DBs.unitsByNum = {}

		mist.DBs.groupsByName = {}
		mist.DBs.groupsById = {}
		mist.DBs.humansByName = {}
		mist.DBs.humansById = {}

		mist.DBs.dynGroupsAdded = {} -- will be filled by mist.dbUpdate from dynamically spawned groups
		mist.DBs.activeHumans = {}

		mist.DBs.aliveUnits = {}  -- will be filled in by the "updateAliveUnits" coroutine in mist.main.

		mist.DBs.removedAliveUnits = {} -- will be filled in by the "updateAliveUnits" coroutine in mist.main.

		mist.DBs.const = {}

		mist.DBs.const.nato = {
			a = "alpha",
			b = "bravo",
			c = "charlie",
			d = "delta",
			e = "echo",
			f = "foxtrot",
			g = "golf",
			h = "hotel",
			i = "india",
			j = "juliett",
			k = "kilo",
			l = "lima",
			m = "mike",
			n = "november",
			o = "oscar",
			p = "papa",
			q = "quebec",
			r = "romeo",
			s = "sierra",
			t = "tango",
			u = "uniform",
			v = "victor",
			w = "whiskey",
			x = "xray",
			y = "yankee",
			z = "zulu",

		}

		-- not accessible by SSE, must use static list :-/
		mist.DBs.const.callsigns = {
			['NATO'] = {
				['rules'] = {
					['groupLimit'] = 9,
				},
				['AWACS'] = {
					['Overlord'] = 1,
					['Magic'] = 2,
					['Wizard'] = 3,
					['Focus'] = 4,
					['Darkstar'] = 5,
				},
				['TANKER'] = {
					['Texaco'] = 1,
					['Arco'] = 2,
					['Shell'] = 3,
				},
				['TRANSPORT'] = {
					['Heavy'] = 9,
					['Trash'] = 10,
					['Cargo'] = 11,
					['Ascot'] = 12,
					['JTAC'] = {
						['Axeman'] = 1,
						['Darknight'] = 2,
						['Warrior'] = 3,
						['Pointer'] = 4,
						['Eyeball'] = 5,
						['Moonbeam'] = 6,
						['Whiplash'] = 7,
						['Finger'] = 8,
						['Pinpoint'] = 9,
						['Ferret'] = 10,
						['Shaba'] = 11,
						['Playboy'] = 12,
						['Hammer'] = 13,
						['Jaguar'] = 14,
						['Deathstar'] = 15,
						['Anvil'] = 16,
						['Firefly'] = 17,
						['Mantis'] = 18,
						['Badger'] = 19,
					},
					['aircraft'] = {
						['Enfield'] = 1,
						['Springfield'] = 2,
						['Uzi'] = 3,
						['Colt'] = 4,
						['Dodge'] = 5,
						['Ford'] = 6,
						['Chevy'] = 7,
						['Pontiac'] = 8,
					},

					['unique'] = {
						['A10'] = {
							['Hawg'] = 9,
							['Boar'] = 10,
							['Pig'] = 11,
							['Tusk'] = 12,
							['rules'] = {
								['canUseAircraft'] = true,
								['appliesTo'] = {
									'A-10C_2',
									'A-10C',
									'A-10A',
								},
							},
						},
						['f16'] = {
							Viper = 9,
							Venom = 10,
							Lobo = 11,
							Cowboy = 12,
							Python = 13,
							Rattler = 14,
							Panther = 15,
							Wolf = 16,
							Weasel = 17,
							Wild = 18,
							Ninja = 19,
							Jedi = 20,
							rules = {
								['canUseAircraft'] = true,
								['appliesTo'] = {
									'F-16C_50',
									'F-16C bl.52d',
									'F-16C bl.50',
									'F-16A MLU',
									'F-16A',
								},
							},

						},
						['f18'] = {
							['Hornet'] = 9,
							['Squid'] = 10,
							['Ragin'] = 11,
							['Roman'] = 12,
							Sting = 13,
							Jury = 14,
							Jokey = 15,
							Ram = 16,
							Hawk = 17,
							Devil = 18,
							Check = 19,
							Snake = 20,
							['rules'] = {
								['canUseAircraft'] = true,
								['appliesTo'] = {

									"FA-18C_hornet",
									'F/A-18C',
								},
							},
						},
						['b1'] = {
							['Bone'] = 9,
							['Dark'] = 10,
							['Vader'] = 11,
							['rules'] = {
								['canUseAircraft'] = true,
								['appliesTo'] = {
									'B-1B',
								},
							},
						},
						['b52'] = {
							['Buff'] = 9,
							['Dump'] = 10,
							['Kenworth'] = 11,
							['rules'] = {
								['canUseAircraft'] = true,
								['appliesTo'] = {
									'B-52H',
								},
							},
						},
						['f15e'] = {
							['Dude'] = 9,
							['Thud'] = 10,
							['Gunny'] = 11,
							['Trek'] = 12,
							Sniper = 13,
							Sled = 14,
							Best = 15,
							Jazz = 16,
							Rage = 17,
							Tahoe = 18,
							['rules'] = {
								['canUseAircraft'] = true,
								['appliesTo'] = {
									'F-15E',
									--'F-15ERAZBAM',
								},
							},
						},

					},
				},
			},
		}
		mist.DBs.const.shapeNames = {
			["Landmine"] = "landmine",
			["FARP CP Blindage"] = "kp_ug",
			["Subsidiary structure C"] = "saray-c",
			["Barracks 2"] = "kazarma2",
			["Small house 2C"] = "dom2c",
			["Military staff"] = "aviashtab",
			["Tech hangar A"] = "ceh_ang_a",
			["Oil derrick"] = "neftevyshka",
			["Tech combine"] = "kombinat",
			["Garage B"] = "garage_b",
			["Airshow_Crowd"] = "Crowd1",
			["Hangar A"] = "angar_a",
			["Repair workshop"] = "tech",
			["Subsidiary structure D"] = "saray-d",
			["FARP Ammo Dump Coating"] = "SetkaKP",
			["Small house 1C area"] = "dom2c-all",
			["Tank 2"] = "airbase_tbilisi_tank_01",
			["Boiler-house A"] = "kotelnaya_a",
			["Workshop A"] = "tec_a",
			["Small werehouse 1"] = "s1",
			["Garage small B"] = "garagh-small-b",
			["Small werehouse 4"] = "s4",
			["Shop"] = "magazin",
			["Subsidiary structure B"] = "saray-b",
			["FARP Fuel Depot"] = "GSM Rus",
			["Coach cargo"] = "wagon-gruz",
			["Electric power box"] = "tr_budka",
			["Tank 3"] = "airbase_tbilisi_tank_02",
			["Red_Flag"] = "H-flag_R",
			["Container red 3"] = "konteiner_red3",
			["Garage A"] = "garage_a",
			["Hangar B"] = "angar_b",
			["Black_Tyre"] = "H-tyre_B",
			["Cafe"] = "stolovaya",
			["Restaurant 1"] = "restoran1",
			["Subsidiary structure A"] = "saray-a",
			["Container white"] = "konteiner_white",
			["Warehouse"] = "sklad",
			["Tank"] = "bak",
			["Railway crossing B"] = "pereezd_small",
			["Subsidiary structure F"] = "saray-f",
			["Farm A"] = "ferma_a",
			["Small werehouse 3"] = "s3",
			["Water tower A"] = "wodokachka_a",
			["Railway station"] = "r_vok_sd",
			["Coach a tank blue"] = "wagon-cisterna_blue",
			["Supermarket A"] = "uniwersam_a",
			["Coach a platform"] = "wagon-platforma",
			["Garage small A"] = "garagh-small-a",
			["TV tower"] = "tele_bash",
			["Comms tower M"] = "tele_bash_m",
			["Small house 1A"] = "domik1a",
			["Farm B"] = "ferma_b",
			["GeneratorF"] = "GeneratorF",
			["Cargo1"] = "ab-212_cargo",
			["Container red 2"] = "konteiner_red2",
			["Subsidiary structure E"] = "saray-e",
			["Coach a passenger"] = "wagon-pass",
			["Black_Tyre_WF"] = "H-tyre_B_WF",
			["Electric locomotive"] = "elektrowoz",
			["Shelter"] = "ukrytie",
			["Coach a tank yellow"] = "wagon-cisterna_yellow",
			["Railway crossing A"] = "pereezd_big",
			[".Ammunition depot"] = "SkladC",
			["Small werehouse 2"] = "s2",
			["Windsock"] = "H-Windsock_RW",
			["Shelter B"] = "ukrytie_b",
			["Fuel tank"] = "toplivo-bak",
			["Locomotive"] = "teplowoz",
			[".Command Center"] = "ComCenter",
			["Pump station"] = "nasos",
			["Black_Tyre_RF"] = "H-tyre_B_RF",
			["Coach cargo open"] = "wagon-gruz-otkr",
			["Subsidiary structure 3"] = "hozdomik3",
			["FARP Tent"] = "PalatkaB",
			["White_Tyre"] = "H-tyre_W",
			["Subsidiary structure G"] = "saray-g",
			["Container red 1"] = "konteiner_red1",
			["Small house 1B area"] = "domik1b-all",
			["Subsidiary structure 1"] = "hozdomik1",
			["Container brown"] = "konteiner_brown",
			["Small house 1B"] = "domik1b",
			["Subsidiary structure 2"] = "hozdomik2",
			["Chemical tank A"] = "him_bak_a",
			["WC"] = "WC",
			["Small house 1A area"] = "domik1a-all",
			["White_Flag"] = "H-Flag_W",
			["Airshow_Cone"] = "Comp_cone",
			["Bulk Cargo Ship Ivanov"] = "barge-1",
			["Bulk Cargo Ship Yakushev"] = "barge-2",
			["Outpost"] = "block",
			["Road outpost"] = "block-onroad",
			["Container camo"] = "bw_container_cargo",
			["Tech Hangar A"] = "ceh_ang_a",
			["Bunker 1"] = "dot",
			["Bunker 2"] = "dot2",
			["Tanker Elnya 160"] = "elnya",
			["F-shape barrier"] = "f_bar_cargo",
			["Helipad Single"] = "farp",
			["FARP"] = "farps",
			["Fueltank"] = "fueltank_cargo",
			["Gate"] = "gate",
			["Armed house"] = "home1_a",
			["FARP Command Post"] = "kp-ug",
			["Watch Tower Armed"] = "ohr-vyshka",
			["Oiltank"] = "oiltank_cargo",
			["Pipes small"] = "pipes_small_cargo",
			["Pipes big"] = "pipes_big_cargo",
			["Oil platform"] = "plavbaza",
			["Tetrapod"] = "tetrapod_cargo",
			["Trunks long"] = "trunks_long_cargo",
			["Trunks small"] = "trunks_small_cargo",
			["Passenger liner"] = "yastrebow",
			["Passenger boat"] = "zwezdny",
			["Oil rig"] = "oil_platform",
			["Gas platform"] = "gas_platform",
			["Container 20ft"] = "container_20ft",
			["Container 40ft"] = "container_40ft",
			["Downed pilot"] = "cadaver",
			["Parachute"] = "parash",
			["Pilot F15 Parachute"] = "pilot_f15_parachute",
			["Pilot standing"] = "pilot_parashut",
		}


		-- create mist.DBs.oldAliveUnits
		-- do
		-- local intermediate_alive_units = {}	-- between 0 and 0.5 secs old
		-- local function make_old_alive_units() -- called every 0.5 secs, makes the old_alive_units DB which is just a copy of alive_units that is 0.5 to 1 sec old
		-- if intermediate_alive_units then
		-- mist.DBs.oldAliveUnits = mist.utils.deepCopy(intermediate_alive_units)
		-- end
		-- intermediate_alive_units = mist.utils.deepCopy(mist.DBs.aliveUnits)
		-- timer.scheduleFunction(make_old_alive_units, nil, timer.getTime() + 0.5)
		-- end

		-- make_old_alive_units()
		-- end

		--Build DBs

		--dbLog:echo(abRef)
		mist.DBs.spawnsByBase = {}

		for coa_name, coa_data in pairs(mist.DBs.units) do
			for cntry_name, cntry_data in pairs(coa_data) do
				for category_name, category_data in pairs(cntry_data) do
					if type(category_data) == 'table' then
						for group_ind, group_data in pairs(category_data) do
							if type(group_data) == 'table' and group_data.units and type(group_data.units) == 'table' and #group_data.units > 0 then -- OCD paradigm programming
								mist.DBs.groupsByName[group_data.groupName] = mist.utils.deepCopy(group_data)
								mist.DBs.groupsById[group_data.groupId] = mist.utils.deepCopy(group_data)
								for unit_ind, unit_data in pairs(group_data.units) do
									local copy = mist.utils.deepCopy(unit_data)
									local num = #mist.DBs.unitsByNum + 1
									copy.dbNum = num

									mist.DBs.unitsByName[unit_data.unitName] = mist.utils.deepCopy(copy)
									mist.DBs.unitsById[unit_data.unitId] = mist.utils.deepCopy(copy)

									mist.DBs.unitsByCat[unit_data.category] = mist.DBs.unitsByCat[unit_data.category] or
										{} -- future-proofing against new categories...
									table.insert(mist.DBs.unitsByCat[unit_data.category], mist.utils.deepCopy(copy))
									--dbLog:info('inserting $1', unit_data.unitName)
									table.insert(mist.DBs.unitsByNum, mist.utils.deepCopy(copy))

									if unit_data.skill and (unit_data.skill == "Client" or unit_data.skill == "Player") then
										mist.DBs.humansByName[unit_data.unitName] = mist.utils.deepCopy(copy)
										mist.DBs.humansById[unit_data.unitId] = mist.utils.deepCopy(copy)
										--if Unit.getByName(unit_data.unitName) then
										--	mist.DBs.activeHumans[unit_data.unitName] = mist.utils.deepCopy(unit_data)
										--	mist.DBs.activeHumans[unit_data.unitName].playerName = Unit.getByName(unit_data.unitName):getPlayerName()
										--end
									end
									if unit_data.airdromeId then
										--log:echo(unit_data.airdromeId)
										--log:echo(abRef.airbase[unit_data.airdromeId])
										if not mist.DBs.spawnsByBase[abRef.airbase[unit_data.airdromeId].name] then
											mist.DBs.spawnsByBase[abRef.airbase[unit_data.airdromeId].name] = {}
										end
										table.insert(mist.DBs.spawnsByBase[abRef.airbase[unit_data.airdromeId].name],
											unit_data.unitName)
									end
									if unit_data.helipadId and abRef.units[unit_data.helipadId] and abRef.units[unit_data.helipadId].name then
										if not mist.DBs.spawnsByBase[abRef.units[unit_data.helipadId].name] then
											mist.DBs.spawnsByBase[abRef.units[unit_data.helipadId].name] = {}
										end
										table.insert(mist.DBs.spawnsByBase[abRef.units[unit_data.helipadId].name],
											unit_data.unitName)
									end
								end
							end
						end
					end
				end
			end
		end

		mist.DBs.zonesByName = {}
		mist.DBs.zonesByNum = {}

		if env.mission.triggers and env.mission.triggers.zones then
			for zone_ind, zone_data in pairs(env.mission.triggers.zones) do
				if type(zone_data) == 'table' then
					local zone = mist.utils.deepCopy(zone_data)
					--log:warn(zone)
					zone.point = {} -- point is used by SSE
					zone.point.x = zone_data.x
					zone.point.y = land.getHeight({ x = zone_data.x, y = zone_data.y })
					zone.point.z = zone_data.y
					zone.properties = {}
					if zone_data.properties then
						for propInd, prop in pairs(zone_data.properties) do
							if prop.value and tostring(prop.value) ~= "" then
								zone.properties[prop.key] = prop.value
							end
						end
					end
					if zone.verticies then -- trust but verify
						local r = 0
						for i = 1, #zone.verticies do
							local dist = mist.utils.get2DDist(zone.point, zone.verticies[i])
							if dist > r then
								r = mist.utils.deepCopy(dist)
							end
						end
						zone.radius = r
					end
					if zone.linkUnit then
						local uRef = mist.DBs.unitsByName[zone.linkUnit]
						if uRef then
							if zone.verticies then
								local offset = {}
								for i = 1, #zone.verticies do
									table.insert(offset,
										{
											dist = mist.utils.get2DDist(uRef.point, zone.verticies[i]),
											heading = mist
												.utils.getHeadingPoints(uRef.point, zone.verticies[i]) + uRef.heading
										})
								end
								zone.offset = offset
							else
								zone.offset = {
									dist = mist.utils.get2DDist(uRef.point, zone.point),
									heading = mist
										.utils.getHeadingPoints(uRef.point, zone.point) + uRef.heading
								}
							end
						end
					end

					mist.DBs.zonesByName[zone_data.name] = zone
					mist.DBs.zonesByNum[#mist.DBs.zonesByNum + 1] = mist.utils.deepCopy(zone) --[[deepcopy so that the zone in zones_by_name and the zone in
																								zones_by_num se are different objects.. don't want them linked.]]
				end
			end
		end

		--DynDBs
		mist.DBs.MEunits = mist.utils.deepCopy(mist.DBs.units)
		mist.DBs.MEunitsByName = mist.utils.deepCopy(mist.DBs.unitsByName)
		mist.DBs.MEunitsById = mist.utils.deepCopy(mist.DBs.unitsById)
		mist.DBs.MEunitsByCat = mist.utils.deepCopy(mist.DBs.unitsByCat)
		mist.DBs.MEunitsByNum = mist.utils.deepCopy(mist.DBs.unitsByNum)
		mist.DBs.MEgroupsByName = mist.utils.deepCopy(mist.DBs.groupsByName)
		mist.DBs.MEgroupsById = mist.utils.deepCopy(mist.DBs.groupsById)

		mist.DBs.deadObjects = {}

		do
			local mt = {}

			function mt.__newindex(t, key, val)
				local original_key = key --only for duplicate runtime IDs.
				local key_ind = 1
				while mist.DBs.deadObjects[key] do
					--dbLog:warn('duplicate runtime id of previously dead object key: $1', key)
					key = tostring(original_key) .. ' #' .. tostring(key_ind)
					key_ind = key_ind + 1
				end

				if mist.DBs.aliveUnits and mist.DBs.aliveUnits[val.object.id_] then
					----dbLog:info('object found in alive_units')
					val.objectData = mist.utils.deepCopy(mist.DBs.aliveUnits[val.object.id_])
					local pos = Object.getPosition(val.object)
					if pos then
						val.objectPos = pos.p
					end
					val.objectType = mist.DBs.aliveUnits[val.object.id_].category
				elseif mist.DBs.removedAliveUnits and mist.DBs.removedAliveUnits[val.object.id_] then -- it didn't exist in alive_units, check old_alive_units
					----dbLog:info('object found in old_alive_units')
					val.objectData = mist.utils.deepCopy(mist.DBs.removedAliveUnits[val.object.id_])
					local pos = Object.getPosition(val.object)
					if pos then
						val.objectPos = pos.p
					end
					val.objectType = mist.DBs.removedAliveUnits[val.object.id_].category
				else --attempt to determine if static object...
					----dbLog:info('object not found in alive units or old alive units')
					local pos = Object.getPosition(val.object)
					if pos then
						local static_found = false
						for ind, static in pairs(mist.DBs.unitsByCat.static) do
							if ((pos.p.x - static.point.x) ^ 2 + (pos.p.z - static.point.y) ^ 2) ^ 0.5 < 0.1 then --really, it should be zero...
								--dbLog:info('correlated dead static object to position')
								val.objectData = static
								val.objectPos = pos.p
								val.objectType = 'static'
								static_found = true
								break
							end
						end
						if not static_found then
							val.objectPos = pos.p
							val.objectType = 'building'
							val.typeName = Object.getTypeName(val.object)
						end
					else
						val.objectType = 'unknown'
					end
				end
				rawset(t, key, val)
			end

			setmetatable(mist.DBs.deadObjects, mt)
		end

		do -- mist unitID funcs
			for id, idData in pairs(mist.DBs.unitsById) do
				if idData.unitId > mist.nextUnitId then
					mist.nextUnitId = mist.utils.deepCopy(idData.unitId)
				end
				if idData.groupId > mist.nextGroupId then
					mist.nextGroupId = mist.utils.deepCopy(idData.groupId)
				end
			end
		end
	end

	local function updateAliveUnits()      -- coroutine function
		--log:warn("updateALiveUnits")
		local lalive_units = mist.DBs.aliveUnits -- local references for faster execution
		local lunits = mist.DBs.unitsByNum
		local ldeepcopy = mist.utils.deepCopy
		local lUnit = Unit
		local lremovedAliveUnits = mist.DBs.removedAliveUnits
		local updatedUnits = {}

		if #lunits > 0 then
			local units_per_run = math.ceil(#lunits / 20)
			if units_per_run < 5 then
				units_per_run = 5
			end

			for i = 1, #lunits do
				if lunits[i].category ~= 'static' then -- can't get statics with Unit.getByName :(
					local unit = lUnit.getByName(lunits[i].unitName)
					if unit and unit:isExist() == true then
						----dbLog:info("unit named $1 alive!", lunits[i].unitName) -- spammy
						local pos = unit:getPosition()
						local newtbl = ldeepcopy(lunits[i])
						if pos then
							newtbl.pos = pos.p
						end
						newtbl.unit = unit
						--newtbl.rt_id = unit.id_
						lalive_units[unit.id_] = newtbl
						updatedUnits[unit.id_] = true
					end
				end
				if i % units_per_run == 0 then
					--log:warn("yield: $1", i)
					coroutine.yield()
				end
			end
			-- All units updated, remove any "alive" units that were not updated- they are dead!
			for unit_id, unit in pairs(lalive_units) do
				if not updatedUnits[unit_id] then
					lremovedAliveUnits[unit_id] = unit
					lalive_units[unit_id] = nil
				end
			end
		end
	end

	local function dbUpdate(event, oType, origGroupName)
		--dbLog:info('dbUpdate: $1', event)
		local newTable = {}
		local objType = oType
		newTable.startTime = 0
		if type(event) == 'string' then -- if name of an object.
			local newObject
			if Group.getByName(event) then
				newObject = Group.getByName(event)
			elseif StaticObject.getByName(event) then
				newObject = StaticObject.getByName(event)
				objType = "static"
				--	log:info('its static')
			else
				log:warn('$1 is not a Group or Static Object. This should not be possible. Sent category is: $2', event,
					objType)
				return false
			end
			local objName = newObject:getName()
			newTable.name = origGroupName or objName
			newTable.groupId = tonumber(newObject:getID())
			newTable.groupName = origGroupName or objName
			local unitOneRef
			if objType == 'static' then
				unitOneRef = newObject
				newTable.countryId = tonumber(newObject:getCountry())
				newTable.coalitionId = tonumber(newObject:getCoalition())
				newTable.category = 'static'
			else
				unitOneRef = newObject:getUnits()
				if #unitOneRef > 0 and unitOneRef[1] and type(unitOneRef[1]) == 'table' then
					newTable.countryId = tonumber(unitOneRef[1]:getCountry())
					newTable.coalitionId = tonumber(unitOneRef[1]:getCoalition())
					newTable.category = tonumber(Object.getCategory(newObject))
				else
					log:warn('getUnits failed to return on $1 ; Built Data: $2.', event, newTable)
					return false
				end
			end
			for countryData, countryId in pairs(country.id) do
				if newTable.country and string.upper(countryData) == string.upper(newTable.country) or countryId == newTable.countryId then
					newTable.countryId = countryId
					newTable.country = string.lower(countryData)
					for coaData, coaId in pairs(coalition.side) do
						if coaId == coalition.getCountryCoalition(countryId) then
							newTable.coalition = string.lower(coaData)
						end
					end
				end
			end
			for catData, catId in pairs(Unit.Category) do
				if objType == 'group' and Group.getByName(newTable.groupName):isExist() then
					if catId == Group.getByName(newTable.groupName):getCategory() then
						newTable.category = string.lower(catData)
					end
				elseif objType == 'static' and StaticObject.getByName(newTable.groupName):isExist() then
					if catId == StaticObject.getByName(newTable.groupName):getCategory() then
						newTable.category = string.lower(catData)
					end
				end
			end
			local gfound = false
			for index, data in pairs(mistAddedGroups) do
				if mist.stringMatch(data.name, newTable.groupName) == true then
					gfound = true
					newTable.task = data.task
					newTable.modulation = data.modulation
					newTable.uncontrolled = data.uncontrolled
					newTable.radioSet = data.radioSet
					newTable.hidden = data.hidden
					newTable.startTime = data.start_time
					mistAddedGroups[index] = nil
				end
			end

			if gfound == false then
				newTable.uncontrolled = false
				newTable.hidden = false
			end

			newTable.units = {}
			if objType == 'group' then
				for unitId, unitData in pairs(unitOneRef) do
					local point = unitData:getPoint()
					newTable.units[unitId] = {}
					newTable.units[unitId].unitName = unitData:getName()

					newTable.units[unitId].x = mist.utils.round(point.x)
					newTable.units[unitId].y = mist.utils.round(point.z)
					newTable.units[unitId].point = {}
					newTable.units[unitId].point.x = newTable.units[unitId].x
					newTable.units[unitId].point.y = newTable.units[unitId].y
					newTable.units[unitId].alt = mist.utils.round(point.y)
					newTable.units[unitId].speed = mist.vec.mag(unitData:getVelocity())

					newTable.units[unitId].heading = mist.getHeading(unitData, true)

					newTable.units[unitId].type = unitData:getTypeName()
					newTable.units[unitId].unitId = tonumber(unitData:getID())

					local pName = unitData:getPlayerName()
					--log:warn("pName: '$1'", pName)
					local unitName = newTable.units[unitId].unitName
					--log:warn("unitName: '$1'", unitName)
					--log:warn("mist.DBs.MEunitsByName[unitName]: '$1'", mist.DBs.MEunitsByName[unitName])
					if (pName and pName ~= "") and not mist.DBs.MEunitsByName[unitName] then
						newTable.dynamicSlot = timer.getTime()
						if not mist.DBs.humansById[unitId] then
							mist.DBs.humansById[unitId] = newTable.units[unitId]
							--log:info("added human by id: $1", unitId)
							--log:info("mist.DBs.humansById: $1", mist.DBs.humansById)
						end
						if not mist.DBs.humansByName[unitName] then
							mist.DBs.humansByName[unitName] = newTable.units[unitId]
							--log:info("added human by name: $1", unitName)
							--log:info("mist.DBs.humansByName: $1", mist.DBs.humansByName)
						end
					end

					newTable.units[unitId].groupName = newTable.groupName
					newTable.units[unitId].groupId = newTable.groupId
					newTable.units[unitId].countryId = newTable.countryId
					newTable.units[unitId].coalitionId = newTable.coalitionId
					newTable.units[unitId].coalition = newTable.coalition
					newTable.units[unitId].country = newTable.country
					local found = false
					for index, data in pairs(mistAddedObjects) do
						if mist.stringMatch(data.name, unitName) == true then
							found = true
							newTable.units[unitId].livery_id = data.livery_id
							newTable.units[unitId].skill = data.skill
							newTable.units[unitId].alt_type = data.alt_type
							newTable.units[unitId].callsign = data.callsign
							newTable.units[unitId].psi = data.psi
							mistAddedObjects[index] = nil
						end
						if found == false then
							if newTable.dynamicSlot then
								newTable.units[unitId].skill = "Client"
							else
								newTable.units[unitId].skill = "High"
							end
							newTable.units[unitId].alt_type = "BARO"
						end
						if newTable.units[unitId].alt_type == "RADIO" then -- raw postition MSL was grabbed for group, but spawn is AGL, so re-offset it
							newTable.units[unitId].alt = (newTable.units[unitId].alt - land.getHeight({ x = newTable.units[unitId].x, y = newTable.units[unitId].y }))
						end
					end
				end
			else -- its a static
				newTable.category = 'static'
				local point = newObject:getPoint()
				newTable.units[1] = {}
				newTable.units[1].unitName = newObject:getName()
				newTable.units[1].category = 'static'
				newTable.units[1].x = mist.utils.round(point.x)
				newTable.units[1].y = mist.utils.round(point.z)
				newTable.units[1].point = {}
				newTable.units[1].point.x = newTable.units[1].x
				newTable.units[1].point.y = newTable.units[1].y
				newTable.units[1].alt = mist.utils.round(point.y)
				newTable.units[1].heading = mist.getHeading(newObject, true)
				newTable.units[1].type = newObject:getTypeName()
				newTable.units[1].unitId = tonumber(newObject:getID())
				newTable.units[1].groupName = newTable.name
				newTable.units[1].groupId = newTable.groupId
				newTable.units[1].countryId = newTable.countryId
				newTable.units[1].country = newTable.country
				newTable.units[1].coalitionId = newTable.coalitionId
				newTable.units[1].coalition = newTable.coalition
				if Object.getCategory(newObject) == 6 and newObject:getCargoDisplayName() then
					local mass = newObject:getCargoDisplayName()
					mass = string.gsub(mass, ' ', '')
					mass = string.gsub(mass, 'kg', '')
					newTable.units[1].mass = tonumber(mass)
					newTable.units[1].categoryStatic = 'Cargos'
					newTable.units[1].canCargo = true
					newTable.units[1].shape_name = 'ab-212_cargo'
				end

				----- search mist added objects for extra data if applicable
				for index, data in pairs(mistAddedObjects) do
					if mist.stringMatch(data.name, newTable.units[1].unitName) == true then
						newTable.units[1].shape_name = data.shape_name -- for statics
						newTable.units[1].livery_id = data.livery_id
						newTable.units[1].airdromeId = data.airdromeId
						newTable.units[1].mass = data.mass
						newTable.units[1].canCargo = data.canCargo
						newTable.units[1].categoryStatic = data.categoryStatic
						newTable.units[1].type = data.type
						newTable.units[1].linkUnit = data.linkUnit

						mistAddedObjects[index] = nil
						break
					end
				end
			end
		end
		--dbLog:warn(newTable)
		--mist.debug.writeData(mist.utils.serialize,{'msg', newTable}, timer.getAbsTime() ..'Group.lua')
		newTable.timeAdded = timer.getAbsTime() -- only on the dynGroupsAdded table. For other reference, see start time
		--mist.debug.dumpDBs()
		--end
		--dbLog:warn(newTable)
		--dbLog:info('endDbUpdate')
		return newTable
	end

	--[[DB update code... FRACK. I need to refactor some of it.
	
	The problem is that the DBs need to account better for shared object names. Needs to write over some data and outright remove other.
	
	If groupName is used then entire group needs to be rewritten
		what to do with old groups units DB entries?. Names cant be assumed to be the same.
	
	
	-- new spawn event check.
	-- event handler filters everything into groups: tempSpawnedGroups
	-- this function then checks DBs to see if data has changed
	]]
	local function checkSpawnedEventsNew()
		if tempSpawnGroupsCounter > 0 then
			--[[local updatesPerRun = math.ceil(#tempSpawnedGroupsCounter/20)
			if updatesPerRun < 5 then
				updatesPerRun = 5
			end]]

			--dbLog:info('iterate')
			for name, gData in pairs(tempSpawnedGroups) do
				--env.info(name)
				--dbLog:warn(gData)
				local updated = false
				local stillExists = false
				local staticGroupName
				if not gData.checked then
					tempSpawnedGroups[name].checked = true -- so if there was an error it will get cleared.
					local _g = gData.gp or Group.getByName(name)
					if mist.DBs.groupsByName[name] then
						-- first check group level properties, groupId, countryId, coalition
						--dbLog:info('Found in DBs, check if updated')
						local dbTable = mist.DBs.groupsByName[name]
						--dbLog:info(dbTable)
						if gData.type ~= 'static' then
							--dbLog:info('Not static')

							if _g and _g:isExist() == true then
								stillExists = true
								local _u = _g:getUnit(1)

								if _u and (dbTable.groupId ~= tonumber(_g:getID()) or _u:getCountry() ~= dbTable.countryId or _u:getCoalition() ~= dbTable.coaltionId) then
									--dbLog:info('Group Data mismatch')
									updated = true
								else
									--  dbLog:info('No Mismatch')
								end
							else
								dbLog:warn('$1 : Group was not accessible', name)
							end
						end
					end
					--dbLog:info('Updated: $1', updated)
					if updated == false then
						if gData.type ~= 'static' then -- time to check units
							-- dbLog:info('No Group Mismatch, Check Units')
							if _g and _g:isExist() == true then
								stillExists = true
								for index, uObject in pairs(_g:getUnits()) do
									-- dbLog:info(index)
									if mist.DBs.unitsByName[uObject:getName()] then
										--dbLog:info('UnitByName table exists')
										local uTable = mist.DBs.unitsByName[uObject:getName()]
										if tonumber(uObject:getID()) ~= uTable.unitId or uObject:getTypeName() ~= uTable.type then
											--dbLog:info('Unit Data mismatch')
											updated = true
											break
										end
									end
								end
							end
						else -- it is a static object
							local ref = mist.DBs.unitsByName[name]
							if ref then
								staticGroupName = ref.groupName
							else
								stillExists = true
							end
						end
					else
						stillExists = true
					end

					if stillExists == true and (updated == true or not mist.DBs.groupsByName[name]) then
						--dbLog:info('Get Table')
						local dbData = dbUpdate(name, gData.type, staticGroupName)
						if dbData and type(dbData) == 'table' then
							if dbData.name then
								writeGroups[#writeGroups + 1] = { data = dbData, isUpdated = updated }
							else
								dbLog:warn("dbUpdate failed to populate data: $1  $2   $3", name, gData.type, gData)
							end
						end
					end
					-- Work done, so remove
				end
				tempSpawnedGroups[name] = nil
				tempSpawnGroupsCounter = tempSpawnGroupsCounter - 1
			end
		end
	end

	local updateChecker = {}


	local function writeDBTables(newEntry)
		local ldeepCopy = mist.utils.deepCopy
		local newTable = newEntry.data
		--dbLog:info(newTable)

		local state = 0
		if not newTable.name then
			dbLog:warn("Failed to add to database; sufficent data missing $1", newTable)
			return false
		end

		if updateChecker[newTable.name] then
			dbLog:warn("Failed to add to database: $1. Stopped at state: $2", newTable.name, updateChecker
				[newTable.name])
			return false
		else
			--dbLog:info('define default state')
			updateChecker[newTable.name] = 0
			--dbLog:info('define default state1')
			state = updateChecker[newTable.name]
			--dbLog:info('define default state2')
		end

		local updated = newEntry.isUpdated
		local mistCategory
		--dbLog:info('define categoryy')
		if type(newTable.category) == 'string' then
			mistCategory = string.lower(newTable.category)
		end

		if string.upper(newTable.category) == 'GROUND_UNIT' then
			mistCategory = 'vehicle'
			newTable.category = mistCategory
		elseif string.upper(newTable.category) == 'AIRPLANE' then
			mistCategory = 'plane'
			newTable.category = mistCategory
		elseif string.upper(newTable.category) == 'HELICOPTER' then
			mistCategory = 'helicopter'
			newTable.category = mistCategory
		elseif string.upper(newTable.category) == 'SHIP' then
			mistCategory = 'ship'
			newTable.category = mistCategory
		end
		--dbLog:info('Update unitsBy')
		state = 1
		for newId, newUnitData in pairs(newTable.units) do
			--dbLog:info(newId)
			newUnitData.category = mistCategory

			--dbLog:info(updated)
			if mist.DBs.unitsByName[newUnitData.unitName] and updated == true then --if unit existed before and something was updated, write over the entry for a given unit name just in case.
				state = 1.1
				--dbLog:info('Updating Unit Tables')
				local refNum = mist.DBs.unitsByName[newUnitData.unitName].dbNum
				for i = 1, #mist.DBs.unitsByCat[mistCategory] do
					if mist.DBs.unitsByCat[mistCategory][i].unitName == newUnitData.unitName then
						--dbLog:info('Entry Found, Rewriting for unitsByCat')
						mist.DBs.unitsByCat[mistCategory][i] = ldeepCopy(newUnitData)
						break
					end
				end
				state = 1.2
				--dbLog:info('updateByNum')
				if refNum then -- easy way
					--dbLog:info('refNum exists, Rewriting for unitsByCat')
					mist.DBs.unitsByNum[refNum] = ldeepCopy(newUnitData)
				else --- the hard way
					--dbLog:info('iterate unitsByNum')
					for i = 1, #mist.DBs.unitsByNum do
						if mist.DBs.unitsByNum[i].unitName == newUnitData.unitName then
							--dbLog:info('Entry Found, Rewriting for unitsByNum')
							mist.DBs.unitsByNum[i] = ldeepCopy(newUnitData)
							break
						end
					end
				end
			else
				state = 1.3
				--dbLog:info('Unitname not in use, add as normal')
				newUnitData.dbNum = #mist.DBs.unitsByNum + 1
				mist.DBs.unitsByCat[mistCategory][#mist.DBs.unitsByCat[mistCategory] + 1] = ldeepCopy(newUnitData)
				mist.DBs.unitsByNum[#mist.DBs.unitsByNum + 1] = ldeepCopy(newUnitData)
			end
			if newUnitData.unitId then
				--dbLog:info('byId')
				mist.DBs.unitsById[tonumber(newUnitData.unitId)] = ldeepCopy(newUnitData)
			end

			if newTable.dynamicSlot then
				mist.DBs.humansByName[newTable.units[1].unitName] = ldeepCopy(newUnitData)
				if newUnitData.unitId then
					mist.DBs.humansById[newTable.units[1].unitId] = ldeepCopy(newUnitData)
				end
			end
			mist.DBs.unitsByName[newUnitData.unitName] = ldeepCopy(newUnitData)
		end
		-- this is a really annoying DB to populate. Gotta create new tables in case its missing
		--dbLog:info('write mist.DBs.units')
		state = 2
		if not mist.DBs.units[newTable.coalition] then
			mist.DBs.units[newTable.coalition] = {}
		end
		state = 3
		if not mist.DBs.units[newTable.coalition][newTable.country] then
			mist.DBs.units[newTable.coalition][(newTable.country)] = {}
			mist.DBs.units[newTable.coalition][(newTable.country)].countryId = newTable.countryId
		end
		state = 4
		if not mist.DBs.units[newTable.coalition][newTable.country][mistCategory] then
			mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory] = {}
		end
		state = 5
		if updated == true then
			--dbLog:info('Updating DBsUnits')
			for i = 1, #mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory] do
				if mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory][i].groupName == newTable.groupName then
					--dbLog:info('Entry Found, Rewriting')
					mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory][i] = ldeepCopy(newTable)
					break
				end
			end
		else
			--dbLog:info('adding to DBs Units')
			mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory][#mist.DBs.units[newTable.coalition][(newTable.country)][mistCategory] + 1] =
				ldeepCopy(newTable)
		end
		state = 6

		if newTable.groupId then
			--dbLog:info('Make groupsById')
			mist.DBs.groupsById[newTable.groupId] = ldeepCopy(newTable)
		end
		--dbLog:info('make groupsByName')
		mist.DBs.groupsByName[newTable.name] = ldeepCopy(newTable)
		--dbLog:info('add to dynGroups')
		mist.DBs.dynGroupsAdded[#mist.DBs.dynGroupsAdded + 1] = ldeepCopy(newTable)
		--dbLog:info('clear entry')



		updateChecker[newTable.name] = nil
		--dbLog:info('return')
		return true
	end

	function mist.forceAddToDB(object)
		-- object is static object or group.
		-- call dbUpdate to get the table

		local tbl = dbUpdate(object)
		if tbl then
			local res = writeDBTables(tbl)
			if not res then
				log:warn("Failed to force add to DBs: $1", object)
			end
		end
		-- call writeDBTables with that table.
	end

	local function updateDBTables()
		local i = #writeGroups

		local savesPerRun = math.ceil(i / 10)
		if savesPerRun < 5 then
			savesPerRun = 5
		end
		if i > 0 then
			--dbLog:info('updateDBTables: $1', #writeGroups)

			for x = i, 1, -1 do
				--dbLog:info(x)
				local res = writeDBTables(writeGroups[x])
				if res and res == true then
					--dbLog:info('result: complete')
					writeGroups[x] = nil
				else
					writeGroups[x] = nil
				end
			end
			if x % savesPerRun == 0 then
				--dbLog:info("yield")
				coroutine.yield()
			end
			if timer.getTime() > lastUpdateTime then
				lastUpdateTime = timer.getTime()
			end

			--dbLog:info('endUpdateTables')
		end
	end

	local function groupSpawned(event)
		-- dont need to add units spawned in at the start of the mission if mist is loaded in init line
		if event.id == world.event.S_EVENT_BIRTH and timer.getTime0() < timer.getAbsTime() then
			if Object.getCategory(event.initiator) == 1 then
				--log:info('Object is a Unit')
				local g = Unit.getGroup(event.initiator)
				if g and event.initiator:getPlayerName() ~= "" and not mist.DBs.MEunitsByName[event.initiator:getName()] then
					--	log:info(Unit.getGroup(event.initiator):getName())
					local gName = g:getName()
					if not tempSpawnedGroups[gName] then
						--log:warn('addedTo tempSpawnedGroups: $1', gName)
						tempSpawnedGroups[gName] = { type = 'group', gp = g }
						tempSpawnGroupsCounter = tempSpawnGroupsCounter + 1
					end
				else
					log:error('Group not accessible by unit in event handler. This is a DCS bug')
				end
			elseif Object.getCategory(event.initiator) == 3 or Object.getCategory(event.initiator) == 6 then
				--log:info('staticSpawnEvent')
				--log:info(event)
				--log:info(event.initiator:getTypeName())
				--table.insert(tempSpawnedUnits,(event.initiator))
				-------
				-- New functionality below.
				-------
				--log:info(event.initiator:getName())
				--log:info('Object is Static')
				tempSpawnedGroups[StaticObject.getName(event.initiator)] = { type = 'static' }
				tempSpawnGroupsCounter = tempSpawnGroupsCounter + 1
			end
		end
	end

	local function doScheduledFunctions()
		local i = 1
		while i <= #scheduledTasks do
			local refTime = timer.getTime()
			if not scheduledTasks[i].rep then -- not a repeated process
				if scheduledTasks[i].t <= refTime then
					local task = scheduledTasks[i] -- local reference
					table.remove(scheduledTasks, i)
					local err, errmsg = pcall(task.f, unpack(task.vars, 1, table.maxn(task.vars)))
					if not err then
						log:error('Error in scheduled function: $1', errmsg)
					end
					--task.f(unpack(task.vars, 1, table.maxn(task.vars)))	-- do the task, do not increment i
				else
					i = i + 1
				end
			else
				if scheduledTasks[i].st and scheduledTasks[i].st <= refTime then --if a stoptime was specified, and the stop time exceeded
					table.remove(scheduledTasks, i)                  -- stop time exceeded, do not execute, do not increment i
				elseif scheduledTasks[i].t <= refTime then
					local task = scheduledTasks[i]                   -- local reference
					task.t = timer.getTime() + task.rep              --schedule next run
					local err, errmsg = pcall(task.f, unpack(task.vars, 1, table.maxn(task.vars)))
					if not err then
						log:error('Error in scheduled function: $1', errmsg)
					end
					--scheduledTasks[i].f(unpack(scheduledTasks[i].vars, 1, table.maxn(scheduledTasks[i].vars)))	-- do the task
					i = i + 1
				else
					i = i + 1
				end
			end
		end
	end

	-- Event handler to start creating the dead_objects table
	local function addDeadObject(event)
		if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_CRASH then
			if event.initiator and event.initiator.id_ and event.initiator.id_ > 0 then
				local id = event.initiator.id_ -- initial ID, could change if there is a duplicate id_ already dead.
				local val = { object = event.initiator } -- the new entry in mist.DBs.deadObjects.

				local original_id = id       --only for duplicate runtime IDs.
				local id_ind = 1
				while mist.DBs.deadObjects[id] do
					--log:info('duplicate runtime id of previously dead object id: $1', id)
					id = tostring(original_id) .. ' #' .. tostring(id_ind)
					id_ind = id_ind + 1
				end
				local valid
				if mist.DBs.aliveUnits and mist.DBs.aliveUnits[val.object.id_] then
					--log:info('object found in alive_units')
					val.objectData = mist.utils.deepCopy(mist.DBs.aliveUnits[val.object.id_])
					if Object.isExist(val.object) then
						local pos = Object.getPosition(val.object)
						if pos then
							val.objectPos = pos.p
						end
						val.objectType = mist.DBs.aliveUnits[val.object.id_].category
						--[[if mist.DBs.activeHumans[Unit.getName(val.object)] then
						--trigger.action.outText('remove via death: ' .. Unit.getName(val.object),20)
							mist.DBs.activeHumans[Unit.getName(val.object)] = nil
						end]]
						valid = true
					end
				elseif mist.DBs.removedAliveUnits and mist.DBs.removedAliveUnits[val.object.id_] then -- it didn't exist in alive_units, check old_alive_units
					--log:info('object found in old_alive_units')
					val.objectData = mist.utils.deepCopy(mist.DBs.removedAliveUnits[val.object.id_])
					if Object.isExist(val.object) then
						local pos = Object.getPosition(val.object)
						if pos then
							val.objectPos = pos.p
						end
						val.objectType = mist.DBs.removedAliveUnits[val.object.id_].category
						valid = true
					end
				else --attempt to determine if static object...
					--log:info('object not found in alive units or old alive units')
					if Object.isExist(val.object) then
						local pos = Object.getPosition(val.object)
						if pos then
							local static_found = false
							for ind, static in pairs(mist.DBs.unitsByCat.static) do
								if ((pos.p.x - static.point.x) ^ 2 + (pos.p.z - static.point.y) ^ 2) ^ 0.5 < 0.1 then --really, it should be zero...
									--log:info('correlated dead static object to position')
									val.objectData = static
									val.objectPos = pos.p
									val.objectType = 'static'
									static_found = true
									break
								end
							end
							if not static_found then
								val.objectPos = pos.p
								val.objectType = 'building'
								val.typeName = Object.getTypeName(val.object)
							end
						else
							val.objectType = 'unknown'
						end
						valid = true
					end
				end
				if valid then
					mist.DBs.deadObjects[id] = val
				end
			end
		end
	end

	--[[
		local function addClientsToActive(event)
			if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT or event.id == world.event.S_EVENT_BIRTH then
				log:info(event)
				if Unit.getPlayerName(event.initiator) then
					log:info(Unit.getPlayerName(event.initiator))
					local newU = mist.utils.deepCopy(mist.DBs.unitsByName[Unit.getName(event.initiator)])
					newU.playerName = Unit.getPlayerName(event.initiator)
					mist.DBs.activeHumans[Unit.getName(event.initiator)] = newU
					--trigger.action.outText('added: ' .. Unit.getName(event.initiator), 20)
				end
			elseif event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT and event.initiator then
				if mist.DBs.activeHumans[Unit.getName(event.initiator)] then
					mist.DBs.activeHumans[Unit.getName(event.initiator)] = nil
					-- trigger.action.outText('removed via control: ' .. Unit.getName(event.initiator), 20)
				end
			end
		end

	mist.addEventHandler(addClientsToActive)
	]]
	local function verifyDB()
		--log:warn('verfy Run')
		for coaName, coaId in pairs(coalition.side) do
			--env.info(coaName)
			local gps = coalition.getGroups(coaId)
			for i = 1, #gps do
				if gps[i] and Group.getSize(gps[i]) > 0 then
					local gName = Group.getName(gps[i])
					if not mist.DBs.groupsByName[gName] then
						--env.info(Unit.getID(gUnits[j]) .. ' Not found in DB yet')
						if not tempSpawnedGroups[gName] then
							--dbLog:info('added')
							tempSpawnedGroups[gName] = { type = 'group', gp = gps[i] }
							tempSpawnGroupsCounter = tempSpawnGroupsCounter + 1
						end
					end
				end
			end
			local st = coalition.getStaticObjects(coaId)
			for i = 1, #st do
				local s = st[i]
				if StaticObject.isExist(s) then
					local name = s:getName()
					if not mist.DBs.unitsByName[name] then
						dbLog:warn('$1 Not found in DB yet. ID: $2', name, StaticObject.getID(s))
						if string.len(name) > 0 then -- because in this mission someone sent the name was returning as an empty string. Gotta be careful.
							tempSpawnedGroups[s:getName()] = { type = 'static' }
							tempSpawnGroupsCounter = tempSpawnGroupsCounter + 1
						end
					end
				end
			end
		end
	end


	--- init function.
	-- creates logger, adds default event handler
	-- and calls main the first time.
	-- @function mist.init
	function mist.init()
		-- create logger
		mist.log = mist.Logger:new("MIST", mistSettings.logLevel)
		dbLog = mist.Logger:new('MISTDB', mistSettings.dbLog)

		log = mist.log -- log shorthand
		-- set warning log level, showing only
		-- warnings and errors
		--log:setLevel("warning")

		log:info("initializing databases")
		initDBs()

		-- add event handler for group spawns
		mist.addEventHandler(groupSpawned)
		mist.addEventHandler(addDeadObject)

		log:warn('Init time: $1', timer.getTime())

		-- call main the first time therafter it reschedules itself.
		mist.main()
		--log:msg('MIST version $1.$2.$3 loaded', mist.majorVersion, mist.minorVersion, mist.build)

		mist.scheduleFunction(verifyDB, {}, timer.getTime() + 1)
		return
	end

	--- The main function.
	-- Run 100 times per second.
	-- You shouldn't call this function.
	function mist.main()
		timer.scheduleFunction(mist.main, {}, timer.getTime() + 0.01) --reschedule first in case of Lua error

		updateTenthSecond = updateTenthSecond + 1
		if updateTenthSecond == 20 then
			updateTenthSecond = 0

			checkSpawnedEventsNew()

			if not coroutines.updateDBTables then
				coroutines.updateDBTables = coroutine.create(updateDBTables)
			end

			coroutine.resume(coroutines.updateDBTables)

			if coroutine.status(coroutines.updateDBTables) == 'dead' then
				coroutines.updateDBTables = nil
			end
		end

		--updating alive units
		updateAliveUnitsCounter = updateAliveUnitsCounter + 1
		if updateAliveUnitsCounter == 5 then
			updateAliveUnitsCounter = 0

			if not coroutines.updateAliveUnits then
				coroutines.updateAliveUnits = coroutine.create(updateAliveUnits)
			end

			coroutine.resume(coroutines.updateAliveUnits)

			if coroutine.status(coroutines.updateAliveUnits) == 'dead' then
				coroutines.updateAliveUnits = nil
			end
		end

		doScheduledFunctions()
	end -- end of mist.main

	--- Returns next unit id.
	-- @treturn number next unit id.
	function mist.getNextUnitId()
		mist.nextUnitId = mist.nextUnitId + 1
		if mist.nextUnitId > 6900 and mist.nextUnitId < 30000 then
			mist.nextUnitId = 30000
		end
		return mist.utils.deepCopy(mist.nextUnitId)
	end

	--- Returns next group id.
	-- @treturn number next group id.
	function mist.getNextGroupId()
		mist.nextGroupId = mist.nextGroupId + 1
		if mist.nextGroupId > 6900 and mist.nextGroupId < 30000 then
			mist.nextGroupId = 30000
		end
		return mist.utils.deepCopy(mist.nextGroupId)
	end

	--- Returns timestamp of last database update.
	-- @treturn timestamp of last database update
	function mist.getLastDBUpdateTime()
		return lastUpdateTime
	end

	--- Spawns a static object to the game world.
	-- @todo write good docs
	-- @tparam table staticObj table containing data needed for the object creation
	function mist.dynAddStatic(n)
		local newObj = mist.utils.deepCopy(n)
		--log:warn(newObj)
		if newObj.units and newObj.units[1] then -- if its mist format
			for entry, val in pairs(newObj.units[1]) do
				if newObj[entry] and newObj[entry] ~= val or not newObj[entry] then
					newObj[entry] = val
				end
			end
		end
		--log:info(newObj)

		local cntry = newObj.country
		if newObj.countryId then
			cntry = newObj.countryId
		end

		local newCountry = ''

		for countryId, countryName in pairs(country.name) do
			if type(cntry) == 'string' then
				cntry = cntry:gsub("%s+", "_")
				if tostring(countryName) == string.upper(cntry) then
					newCountry = countryName
				end
			elseif type(cntry) == 'number' then
				if countryId == cntry then
					newCountry = countryName
				end
			end
		end

		if newCountry == '' then
			log:error("Country not found: $1", cntry)
			return false
		end

		if newObj.clone or not newObj.groupId then
			mistGpId = mistGpId + 1
			newObj.groupId = mistGpId
		end

		if newObj.clone or not newObj.unitId then
			mistUnitId = mistUnitId + 1
			newObj.unitId = mistUnitId
		end


		newObj.name = newObj.name or newObj.unitName

		if newObj.clone or not newObj.name then
			mistDynAddIndex[' static '] = mistDynAddIndex[' static '] + 1
			newObj.name = (newCountry .. ' static ' .. mistDynAddIndex[' static '])
		end

		if not newObj.dead then
			newObj.dead = false
		end

		if not newObj.heading then
			newObj.heading = math.rad(math.random(360))
		end

		if newObj.categoryStatic then
			newObj.category = newObj.categoryStatic
		end
		if newObj.mass then
			newObj.category = 'Cargos'
		end

		if newObj.shapeName then
			newObj.shape_name = newObj.shapeName
		end

		if not newObj.shape_name then
			log:info('shape_name not present')
			if mist.DBs.const.shapeNames[newObj.type] then
				newObj.shape_name = mist.DBs.const.shapeNames[newObj.type]
			end
		end

		mistAddedObjects[#mistAddedObjects + 1] = mist.utils.deepCopy(newObj)
		if newObj.x and newObj.y and newObj.type and type(newObj.x) == 'number' and type(newObj.y) == 'number' and type(newObj.type) == 'string' then
			--log:warn(newObj)
			coalition.addStaticObject(country.id[newCountry], newObj)

			return newObj
		end
		log:error("Failed to add static object due to missing or incorrect value. X: $1, Y: $2, Type: $3", newObj.x,
			newObj.y, newObj.type)
		return false
	end

	--- Spawns a dynamic group into the game world.
	-- Same as coalition.add function in SSE. checks the passed data to see if its valid.
	-- Will generate groupId, groupName, unitId, and unitName if needed
	-- @tparam table newGroup table containting values needed for spawning a group.
	function mist.dynAdd(ng)
		local newGroup = mist.utils.deepCopy(ng)
		--log:warn(newGroup)
		--mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, 'newGroupOrig.lua')
		local cntry = newGroup.country
		if newGroup.countryId then
			cntry = newGroup.countryId
		end

		local groupType = newGroup.category
		local newCountry = ''
		-- validate data
		for countryId, countryName in pairs(country.name) do
			if type(cntry) == 'string' then
				cntry = cntry:gsub("%s+", "_")
				if tostring(countryName) == string.upper(cntry) then
					newCountry = countryName
				end
			elseif type(cntry) == 'number' then
				if countryId == cntry then
					newCountry = countryName
				end
			end
		end

		if newCountry == '' then
			log:error("Country not found: $1", cntry)
			return false
		end

		local newCat = ''
		for catName, catId in pairs(Unit.Category) do
			if type(groupType) == 'string' then
				if tostring(catName) == string.upper(groupType) then
					newCat = catName
				end
			elseif type(groupType) == 'number' then
				if catId == groupType then
					newCat = catName
				end
			end

			if catName == 'GROUND_UNIT' and (string.upper(groupType) == 'VEHICLE' or string.upper(groupType) == 'GROUND') then
				newCat = 'GROUND_UNIT'
			elseif catName == 'AIRPLANE' and string.upper(groupType) == 'PLANE' then
				newCat = 'AIRPLANE'
			end
		end
		local typeName
		if newCat == 'GROUND_UNIT' then
			typeName = ' gnd '
		elseif newCat == 'AIRPLANE' then
			typeName = ' air '
		elseif newCat == 'HELICOPTER' then
			typeName = ' hel '
		elseif newCat == 'SHIP' then
			typeName = ' shp '
		elseif newCat == 'BUILDING' then
			typeName = ' bld '
		end
		if newGroup.clone or not newGroup.groupId then
			mistDynAddIndex[typeName] = mistDynAddIndex[typeName] + 1
			mistGpId = mistGpId + 1
			newGroup.groupId = mistGpId
		end
		if newGroup.groupName or newGroup.name then
			if newGroup.groupName then
				newGroup.name = newGroup.groupName
			elseif newGroup.name then
				newGroup.name = newGroup.name
			end
		end

		if newGroup.clone and mist.DBs.groupsByName[newGroup.name] or not newGroup.name then
			--if newGroup.baseName then
			-- idea of later. So custmozed naming can be created
			-- else
			newGroup.name = tostring(newCountry .. tostring(typeName) .. mistDynAddIndex[typeName])
			--end
		end

		if not newGroup.hidden then
			newGroup.hidden = false
		end

		if not newGroup.visible then
			newGroup.visible = false
		end

		if (newGroup.start_time and type(newGroup.start_time) ~= 'number') or not newGroup.start_time then
			if newGroup.startTime then
				newGroup.start_time = mist.utils.round(newGroup.startTime)
			else
				newGroup.start_time = 0
			end
		end


		for unitIndex, unitData in pairs(newGroup.units) do
			local originalName = newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name
			if newGroup.clone or not unitData.unitId then
				mistUnitId = mistUnitId + 1
				newGroup.units[unitIndex].unitId = mistUnitId
			end
			if newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name then
				if newGroup.units[unitIndex].unitName then
					newGroup.units[unitIndex].name = newGroup.units[unitIndex].unitName
				elseif newGroup.units[unitIndex].name then
					newGroup.units[unitIndex].name = newGroup.units[unitIndex].name
				end
			end
			if newGroup.clone or not unitData.name then
				newGroup.units[unitIndex].name = tostring(newGroup.name .. ' unit' .. unitIndex)
			end

			if not unitData.skill then
				newGroup.units[unitIndex].skill = 'Random'
			end

			if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
				if newGroup.units[unitIndex].alt_type and newGroup.units[unitIndex].alt_type ~= 'BARO' or not newGroup.units[unitIndex].alt_type then
					newGroup.units[unitIndex].alt_type = 'RADIO'
				end
				if not unitData.speed then
					if newCat == 'AIRPLANE' then
						newGroup.units[unitIndex].speed = 150
					elseif newCat == 'HELICOPTER' then
						newGroup.units[unitIndex].speed = 60
					end
				end
				if not unitData.payload then
					newGroup.units[unitIndex].payload = mist.getPayload(originalName)
				end
				if not unitData.alt then
					if newCat == 'AIRPLANE' then
						newGroup.units[unitIndex].alt = 2000
						newGroup.units[unitIndex].alt_type = 'RADIO'
						newGroup.units[unitIndex].speed = 150
					elseif newCat == 'HELICOPTER' then
						newGroup.units[unitIndex].alt = 500
						newGroup.units[unitIndex].alt_type = 'RADIO'
						newGroup.units[unitIndex].speed = 60
					end
				end
			elseif newCat == 'GROUND_UNIT' then
				if nil == unitData.playerCanDrive then
					unitData.playerCanDrive = true
				end
			end
			mistAddedObjects[#mistAddedObjects + 1] = mist.utils.deepCopy(newGroup.units[unitIndex])
		end
		mistAddedGroups[#mistAddedGroups + 1] = mist.utils.deepCopy(newGroup)
		if newGroup.route then
			if newGroup.route and not newGroup.route.points then
				if newGroup.route[1] then
					local copyRoute = mist.utils.deepCopy(newGroup.route)
					newGroup.route = {}
					newGroup.route.points = copyRoute
				end
			end
		else -- if aircraft and no route assigned. make a quick and stupid route so AI doesnt RTB immediately
			--if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
			newGroup.route = {}
			newGroup.route.points = {}
			newGroup.route.points[1] = {}
			--end
		end
		newGroup.country = newCountry

		-- update and verify any self tasks
		if newGroup.route and newGroup.route.points then
			--log:warn(newGroup.route.points)
			for i, pData in pairs(newGroup.route.points) do
				if pData.task and pData.task.params and pData.task.params.tasks and #pData.task.params.tasks > 0 then
					for tIndex, tData in pairs(pData.task.params.tasks) do
						if tData.params and tData.params.action then
							if tData.params.action.id == "EPLRS" then
								tData.params.action.params.groupId = newGroup.groupId
							elseif tData.params.action.id == "ActivateBeacon" or tData.params.action.id == "ActivateICLS" then
								tData.params.action.params.unitId = newGroup.units[1].unitId
							end
						end
					end
				end
			end
		end
		--mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, newGroup.name ..'.lua')
		--log:warn(newGroup)
		-- sanitize table
		newGroup.groupName = nil
		newGroup.clone = nil
		newGroup.category = nil
		newGroup.country = nil

		newGroup.tasks = {}

		for unitIndex, unitData in pairs(newGroup.units) do
			newGroup.units[unitIndex].unitName = nil
		end

		ctld.logTrace("mist.dynAdd().nexGroup =  %s", ctld.p(newGroup))
		ctld.logTrace("mist.dynAdd().nexGroup =  %s", mist.utils.tableShow(newGroup))
		coalition.addGroup(country.id[newCountry], Unit.Category[newCat], newGroup)

		return newGroup
	end

	--- Schedules a function.
	-- Modified Slmod task scheduler, superior to timer.scheduleFunction
	-- @tparam function f function to schedule
	-- @tparam table vars array containing all parameters passed to the function
	-- @tparam number t time in seconds from mission start to schedule the function to.
	-- @tparam[opt] number rep time between repetitions of the function
	-- @tparam[opt] number st time in seconds from mission start at which the function
	-- should stop to be rescheduled.
	-- @treturn number scheduled function id.
	function mist.scheduleFunction(f, vars, t, rep, st)
		--verify correct types
		assert(type(f) == 'function', 'variable 1, expected function, got ' .. type(f))
		assert(type(vars) == 'table' or vars == nil, 'variable 2, expected table or nil, got ' .. type(f))
		assert(type(t) == 'number', 'variable 3, expected number, got ' .. type(t))
		assert(type(rep) == 'number' or rep == nil, 'variable 4, expected number or nil, got ' .. type(rep))
		assert(type(st) == 'number' or st == nil, 'variable 5, expected number or nil, got ' .. type(st))
		if not vars then
			vars = {}
		end
		taskId = taskId + 1
		table.insert(scheduledTasks, { f = f, vars = vars, t = t, rep = rep, st = st, id = taskId })
		return taskId
	end

	--- Removes a scheduled function.
	-- @tparam number id function id
	-- @treturn boolean true if function was successfully removed, false otherwise.
	function mist.removeFunction(id)
		local i = 1
		while i <= #scheduledTasks do
			if scheduledTasks[i].id == id then
				table.remove(scheduledTasks, i)
				return true
			else
				i = i + 1
			end
		end
		return false
	end

	--- Registers an event handler.
	-- @tparam function f function handling event
	-- @treturn number id of the event handler
	function mist.addEventHandler(f) --id is optional!
		local handler = {}
		idNum = idNum + 1
		handler.id = idNum
		handler.f = f
		function handler:onEvent(event)
			self.f(event)
		end

		world.addEventHandler(handler)
		return handler.id
	end

	--- Removes event handler with given id.
	-- @tparam number id event handler id
	-- @treturn boolean true on success, false otherwise
	function mist.removeEventHandler(id)
		for key, handler in pairs(world.eventHandlers) do
			if handler.id and handler.id == id then
				world.eventHandlers[key] = nil
				return true
			end
		end
		return false
	end
end

-- Begin common funcs
do
	--- Returns MGRS coordinates as string.
	-- @tparam string MGRS MGRS coordinates
	-- @tparam number acc the accuracy of each easting/northing.
	-- Can be: 0, 1, 2, 3, 4, or 5.
	function mist.tostringMGRS(MGRS, acc)
		if acc == 0 then
			return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
		else
			return MGRS.UTMZone ..
				' ' ..
				MGRS.MGRSDigraph ..
				' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Easting / (10 ^ (5 - acc)), 0))
				.. ' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Northing / (10 ^ (5 - acc)), 0))
		end
	end

	--[[acc:
	in DM: decimal point of minutes.
	In DMS: decimal point of seconds.
	position after the decimal of the least significant digit:
	So:
	42.32 - acc of 2.
	]]
	function mist.tostringLL(lat, lon, acc, DMS)
		local latHemi, lonHemi
		if lat > 0 then
			latHemi = 'N'
		else
			latHemi = 'S'
		end

		if lon > 0 then
			lonHemi = 'E'
		else
			lonHemi = 'W'
		end

		lat = math.abs(lat)
		lon = math.abs(lon)

		local latDeg = math.floor(lat)
		local latMin = (lat - latDeg) * 60

		local lonDeg = math.floor(lon)
		local lonMin = (lon - lonDeg) * 60

		if DMS then -- degrees, minutes, and seconds.
			local oldLatMin = latMin
			latMin = math.floor(latMin)
			local latSec = mist.utils.round((oldLatMin - latMin) * 60, acc)

			local oldLonMin = lonMin
			lonMin = math.floor(lonMin)
			local lonSec = mist.utils.round((oldLonMin - lonMin) * 60, acc)

			if latSec == 60 then
				latSec = 0
				latMin = latMin + 1
			end

			if lonSec == 60 then
				lonSec = 0
				lonMin = lonMin + 1
			end

			local secFrmtStr -- create the formatting string for the seconds place
			if acc <= 0 then -- no decimal place.
				secFrmtStr = '%02d'
			else
				local width = 3 + acc -- 01.310 - that's a width of 6, for example.
				secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
			end

			return string.format('%02d', latDeg) ..
				' ' ..
				string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
				..
				string.format('%02d', lonDeg) ..
				' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi
		else -- degrees, decimal minutes.
			latMin = mist.utils.round(latMin, acc)
			lonMin = mist.utils.round(lonMin, acc)

			if latMin == 60 then
				latMin = 0
				latDeg = latDeg + 1
			end

			if lonMin == 60 then
				lonMin = 0
				lonDeg = lonDeg + 1
			end

			local minFrmtStr -- create the formatting string for the minutes place
			if acc <= 0 then -- no decimal place.
				minFrmtStr = '%02d'
			else
				local width = 3 + acc -- 01.310 - that's a width of 6, for example.
				minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
			end

			return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
				.. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi
		end
	end

	--[[ required: az - radian
		required: dist - meters
		optional: alt - meters (set to false or nil if you don't want to use it).
		optional: metric - set true to get dist and alt in km and m.
		precision will always be nearest degree and NM or km.]]
	function mist.tostringBR(az, dist, alt, metric)
		az = mist.utils.round(mist.utils.toDegree(az), 0)

		if metric then
			dist = mist.utils.round(dist / 1000, 0)
		else
			dist = mist.utils.round(mist.utils.metersToNM(dist), 0)
		end

		local s = string.format('%03d', az) .. ' for ' .. dist

		if alt then
			if metric then
				s = s .. ' at ' .. mist.utils.round(alt, 0)
			else
				s = s .. ' at '
				local rounded = mist.utils.round(mist.utils.metersToFeet(alt / 1000), 0)
				s = s .. rounded
				if rounded > 0 then
					s = s .. "000"
				end
			end
		end
		return s
	end

	function mist.getNorthCorrection(gPoint) --gets the correction needed for true north
		local point = mist.utils.deepCopy(gPoint)
		if not point.z then               --Vec2; convert to Vec3
			point.z = point.y
			point.y = 0
		end
		local lat, lon = coord.LOtoLL(point)
		local north_posit = coord.LLtoLO(lat + 1, lon)
		return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
	end

	--- Returns skill of the given unit.
	-- @tparam string unitName unit name
	-- @return skill of the unit
	function mist.getUnitSkill(unitName)
		if mist.DBs.unitsByName[unitName] then
			if Unit.getByName(unitName) then
				local lunit = Unit.getByName(unitName)
				local data = mist.DBs.unitsByName[unitName]
				if data.unitName == unitName and data.type == lunit:getTypeName() and data.unitId == tonumber(lunit:getID()) and data.skill then
					return data.skill
				end
			end
		end
		log:error("Unit not found in DB: $1", unitName)
		return false
	end

	--- Returns an array containing a group's units positions.
	--	e.g.
	--		{
	--			[1] = {x = 299435.224, y = -1146632.6773},
	--			[2] = {x = 663324.6563, y = 322424.1112}
	--		}
	--	@tparam number|string groupIdent group id or name
	--	@treturn table array containing positions of each group member
	function mist.getGroupPoints(groupIdent)
		-- search by groupId and allow groupId and groupName as inputs
		local gpId = groupIdent
		if type(groupIdent) == 'string' and not tonumber(groupIdent) then
			if mist.DBs.MEgroupsByName[groupIdent] then
				gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
			else
				log:error("Group not found in mist.DBs.MEgroupsByName: $1", groupIdent)
			end
		end

		for coa_name, coa_data in pairs(env.mission.coalition) do
			if type(coa_data) == 'table' then
				if coa_data.country then --there is a country table
					for cntry_id, cntry_data in pairs(coa_data.country) do
						for obj_cat_name, obj_cat_data in pairs(cntry_data) do
							if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then -- only these types have points
								if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
									for group_num, group_data in pairs(obj_cat_data.group) do
										if group_data and group_data.groupId == gpId then                                                        -- this is the group we are looking for
											if group_data.route and group_data.route.points and #group_data.route.points > 0 then
												local points = {}
												for point_num, point in pairs(group_data.route.points) do
													if not point.point then
														points[point_num] = { x = point.x, y = point.y }
													else
														points[point_num] = point
															.point --it's possible that the ME could move to the point = Vec2 notation.
													end
												end
												return points
											end
											return
										end --if group_data and group_data.name and group_data.name == 'groupname'
									end --for group_num, group_data in pairs(obj_cat_data.group) do
								end --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
							end --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
						end --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
					end --for cntry_id, cntry_data in pairs(coa_data.country) do
				end --if coa_data.country then --there is a country table
			end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
		end   --for coa_name, coa_data in pairs(mission.coalition) do
	end

	--- getUnitAttitude(unit) return values.
	-- Yaw, AoA, ClimbAngle - relative to earth reference
	-- DOES NOT TAKE INTO ACCOUNT WIND.
	-- @table attitude
	-- @tfield number Heading in radians, range of 0 to 2*pi,
	-- relative to true north.
	-- @tfield number Pitch in radians, range of -pi/2 to pi/2
	-- @tfield number Roll in radians, range of 0 to 2*pi,
	-- right roll is positive direction.
	-- @tfield number Yaw in radians, range of -pi to pi,
	-- right yaw is positive direction.
	-- @tfield number AoA in radians, range of -pi to pi,
	-- rotation of aircraft to the right in comparison to
	-- flight direction being positive.
	-- @tfield number ClimbAngle in radians, range of -pi/2 to pi/2

	--- Returns the attitude of a given unit.
	-- Will work on any unit, even if not an aircraft.
	-- @tparam Unit unit unit whose attitude is returned.
	-- @treturn table @{attitude}
	function mist.getAttitude(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			local Heading = math.atan2(unitpos.x.z, unitpos.x.x)

			Heading = Heading + mist.getNorthCorrection(unitpos.p)

			if Heading < 0 then
				Heading = Heading + 2 * math.pi -- put heading in range of 0 to 2*pi
			end
			---- heading complete.----

			local Pitch = math.asin(unitpos.x.y)
			---- pitch complete.----

			-- now get roll:
			--maybe not the best way to do it, but it works.

			--first, make a vector that is perpendicular to y and unitpos.x with cross product
			local cp = mist.vec.cp(unitpos.x, { x = 0, y = 1, z = 0 })

			--now, get dot product of of this cross product with unitpos.z
			local dp = mist.vec.dp(cp, unitpos.z)

			--now get the magnitude of the roll (magnitude of the angle between two vectors is acos(vec1.vec2/|vec1||vec2|)
			local Roll = math.acos(dp / (mist.vec.mag(cp) * mist.vec.mag(unitpos.z)))

			--now, have to get sign of roll.
			-- by convention, making right roll positive
			-- to get sign of roll, use the y component of unitpos.z.	For right roll, y component is negative.

			if unitpos.z.y > 0 then -- left roll, flip the sign of the roll
				Roll = -Roll
			end
			---- roll complete. ----

			--now, work on yaw, AoA, climb, and abs velocity
			local Yaw
			local AoA
			local ClimbAngle

			-- get unit velocity
			local unitvel = unit:getVelocity()
			if mist.vec.mag(unitvel) ~= 0 then --must have non-zero velocity!
				local AxialVel = {}   --unit velocity transformed into aircraft axes directions

				--transform velocity components in direction of aircraft axes.
				AxialVel.x = mist.vec.dp(unitpos.x, unitvel)
				AxialVel.y = mist.vec.dp(unitpos.y, unitvel)
				AxialVel.z = mist.vec.dp(unitpos.z, unitvel)

				--Yaw is the angle between unitpos.x and the x and z velocities
				--define right yaw as positive
				Yaw = math.acos(mist.vec.dp({ x = 1, y = 0, z = 0 }, { x = AxialVel.x, y = 0, z = AxialVel.z }) /
					mist.vec.mag({ x = AxialVel.x, y = 0, z = AxialVel.z }))

				--now set correct direction:
				if AxialVel.z > 0 then
					Yaw = -Yaw
				end

				-- AoA is angle between unitpos.x and the x and y velocities
				AoA = math.acos(mist.vec.dp({ x = 1, y = 0, z = 0 }, { x = AxialVel.x, y = AxialVel.y, z = 0 }) /
					mist.vec.mag({ x = AxialVel.x, y = AxialVel.y, z = 0 }))

				--now set correct direction:
				if AxialVel.y > 0 then
					AoA = -AoA
				end

				ClimbAngle = math.asin(unitvel.y / mist.vec.mag(unitvel))
			end
			return { Heading = Heading, Pitch = Pitch, Roll = Roll, Yaw = Yaw, AoA = AoA, ClimbAngle = ClimbAngle }
		else
			log:error("Couldn't get unit's position")
		end
	end

	--- Returns heading of given unit.
	-- @tparam Unit unit unit whose heading is returned.
	-- @param rawHeading
	-- @treturn number heading of the unit, in range
	-- of 0 to 2*pi.
	function mist.getHeading(unit, rawHeading)
		local unitpos = unit:getPosition()
		if unitpos then
			local Heading = math.atan2(unitpos.x.z, unitpos.x.x)
			if not rawHeading then
				Heading = Heading + mist.getNorthCorrection(unitpos.p)
			end
			if Heading < 0 then
				Heading = Heading + 2 * math.pi -- put heading in range of 0 to 2*pi
			end
			return Heading
		end
	end

	--- Returns given unit's pitch
	-- @tparam Unit unit unit whose pitch is returned.
	-- @treturn number pitch of given unit
	function mist.getPitch(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			return math.asin(unitpos.x.y)
		end
	end

	--- Returns given unit's roll.
	-- @tparam Unit unit unit whose roll is returned.
	-- @treturn number roll of given unit
	function mist.getRoll(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			-- now get roll:
			--maybe not the best way to do it, but it works.

			--first, make a vector that is perpendicular to y and unitpos.x with cross product
			local cp = mist.vec.cp(unitpos.x, { x = 0, y = 1, z = 0 })

			--now, get dot product of of this cross product with unitpos.z
			local dp = mist.vec.dp(cp, unitpos.z)

			--now get the magnitude of the roll (magnitude of the angle between two vectors is acos(vec1.vec2/|vec1||vec2|)
			local Roll = math.acos(dp / (mist.vec.mag(cp) * mist.vec.mag(unitpos.z)))

			--now, have to get sign of roll.
			-- by convention, making right roll positive
			-- to get sign of roll, use the y component of unitpos.z.	For right roll, y component is negative.

			if unitpos.z.y > 0 then -- left roll, flip the sign of the roll
				Roll = -Roll
			end
			return Roll
		end
	end

	--- Returns given unit's yaw.
	-- @tparam Unit unit unit whose yaw is returned.
	-- @treturn number yaw of given unit.
	function mist.getYaw(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			-- get unit velocity
			local unitvel = unit:getVelocity()
			if mist.vec.mag(unitvel) ~= 0 then --must have non-zero velocity!
				local AxialVel = {}   --unit velocity transformed into aircraft axes directions

				--transform velocity components in direction of aircraft axes.
				AxialVel.x = mist.vec.dp(unitpos.x, unitvel)
				AxialVel.y = mist.vec.dp(unitpos.y, unitvel)
				AxialVel.z = mist.vec.dp(unitpos.z, unitvel)

				--Yaw is the angle between unitpos.x and the x and z velocities
				--define right yaw as positive
				local Yaw = math.acos(mist.vec.dp({ x = 1, y = 0, z = 0 }, { x = AxialVel.x, y = 0, z = AxialVel.z }) /
					mist.vec.mag({ x = AxialVel.x, y = 0, z = AxialVel.z }))

				--now set correct direction:
				if AxialVel.z > 0 then
					Yaw = -Yaw
				end
				return Yaw
			end
		end
	end

	--- Returns given unit's angle of attack.
	-- @tparam Unit unit unit to get AoA from.
	-- @treturn number angle of attack of the given unit.
	function mist.getAoA(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			local unitvel = unit:getVelocity()
			if mist.vec.mag(unitvel) ~= 0 then --must have non-zero velocity!
				local AxialVel = {}   --unit velocity transformed into aircraft axes directions

				--transform velocity components in direction of aircraft axes.
				AxialVel.x = mist.vec.dp(unitpos.x, unitvel)
				AxialVel.y = mist.vec.dp(unitpos.y, unitvel)
				AxialVel.z = mist.vec.dp(unitpos.z, unitvel)

				-- AoA is angle between unitpos.x and the x and y velocities
				local AoA = math.acos(mist.vec.dp({ x = 1, y = 0, z = 0 }, { x = AxialVel.x, y = AxialVel.y, z = 0 }) /
					mist.vec.mag({ x = AxialVel.x, y = AxialVel.y, z = 0 }))

				--now set correct direction:
				if AxialVel.y > 0 then
					AoA = -AoA
				end
				return AoA
			end
		end
	end

	--- Returns given unit's climb angle.
	-- @tparam Unit unit unit to get climb angle from.
	-- @treturn number climb angle of given unit.
	function mist.getClimbAngle(unit)
		local unitpos = unit:getPosition()
		if unitpos then
			local unitvel = unit:getVelocity()
			if mist.vec.mag(unitvel) ~= 0 then --must have non-zero velocity!
				return math.asin(unitvel.y / mist.vec.mag(unitvel))
			end
		end
	end

	--[[--
	Unit name table.
	Many Mist functions require tables of unit names, which are known
	in Mist as UnitNameTables. These follow a special set of shortcuts
	borrowed from Slmod. These shortcuts alleviate the problem of entering
	huge lists of unit names by hand, and in many cases, they remove the
	need to even know the names of the units in the first place!

	These are the unit table "short-cut" commands:

	Prefixes:
			"[-u]<unit name>" - subtract this unit if its in the table
			"[g]<group name>" - add this group to the table
			"[-g]<group name>" - subtract this group from the table
			"[c]<country name>"	- add this country's units
			"[-c]<country name>" - subtract this country's units if any are in the table

	Stand-alone identifiers
			"[all]" - add all units
			"[-all]" - subtract all units (not very useful by itself)
			"[blue]" - add all blue units
			"[-blue]" - subtract all blue units
			"[red]" - add all red coalition units
			"[-red]" - subtract all red units

	Compound Identifiers:
			"[c][helicopter]<country name>"	- add all of this country's helicopters
			"[-c][helicopter]<country name>" - subtract all of this country's helicopters
			"[c][plane]<country name>"	- add all of this country's planes
			"[-c][plane]<country name>" - subtract all of this country's planes
			"[c][ship]<country name>"	- add all of this country's ships
			"[-c][ship]<country name>" - subtract all of this country's ships
			"[c][vehicle]<country name>"	- add all of this country's vehicles
			"[-c][vehicle]<country name>" - subtract all of this country's vehicles

			"[all][helicopter]" -	add all helicopters
			"[-all][helicopter]" - subtract all helicopters
			"[all][plane]" - add all	planes
			"[-all][plane]" - subtract all planes
			"[all][ship]" - add all ships
			"[-all][ship]" - subtract all ships
			"[all][vehicle]" - add all vehicles
			"[-all][vehicle]" - subtract all vehicles

			"[blue][helicopter]" -	add all blue coalition helicopters
			"[-blue][helicopter]" - subtract all blue coalition helicopters
			"[blue][plane]" - add all blue coalition planes
			"[-blue][plane]" - subtract all blue coalition planes
			"[blue][ship]" - add all blue coalition ships
			"[-blue][ship]" - subtract all blue coalition ships
			"[blue][vehicle]" - add all blue coalition vehicles
			"[-blue][vehicle]" - subtract all blue coalition vehicles

			"[red][helicopter]" -	add all red coalition helicopters
			"[-red][helicopter]" - subtract all red coalition helicopters
			"[red][plane]" - add all red coalition planes
			"[-red][plane]" - subtract all red coalition planes
			"[red][ship]" - add all red coalition ships
			"[-red][ship]" - subtract all red coalition ships
			"[red][vehicle]" - add all red coalition vehicles
			"[-red][vehicle]" - subtract all red coalition vehicles

	Country names to be used in [c] and [-c] short-cuts:
			Turkey
			Norway
			The Netherlands
			Spain
			11
			UK
			Denmark
			USA
			Georgia
			Germany
			Belgium
			Canada
			France
			Israel
			Ukraine
			Russia
			South Ossetia
			Abkhazia
			Italy
			Australia
			Austria
			Belarus
			Bulgaria
			Czech Republic
			China
			Croatia
			Finland
			Greece
			Hungary
			India
			Iran
			Iraq
			Japan
			Kazakhstan
			North Korea
			Pakistan
			Poland
			Romania
			Saudi Arabia
			Serbia, Slovakia
			South Korea
			Sweden
			Switzerland
			Syria
			USAF Aggressors

	Do NOT use a '[u]' notation for single units. Single units are referenced
	the same way as before: Simply input their names as strings.

	These unit tables are evaluated in order, and you cannot subtract a unit
	from a table before it is added. For example:

			{'[blue]', '[-c]Georgia'}

	will evaluate to all of blue coalition except those units owned by the
	country named "Georgia"; however:

			{'[-c]Georgia', '[blue]'}

	will evaluate to all of the units in blue coalition, because the addition
	of all units owned by blue coalition occurred AFTER the subtraction of all
	units owned by Georgia (which actually subtracted nothing at all, since
	there were no units in the table when the subtraction occurred).

	More examples:

			{'[blue][plane]', '[-c]Georgia', '[-g]Hawg 1'}

	Evaluates to all blue planes, except those blue units owned by the country
	named "Georgia" and the units in the group named "Hawg1".


			{'[g]arty1', '[g]arty2', '[-u]arty1_AD', '[-u]arty2_AD', 'Shark 11' }

	Evaluates to the unit named "Shark 11", plus all the units in groups named
	"arty1" and "arty2" except those that are named "arty1\_AD" and "arty2\_AD".

	@table UnitNameTable
	]]

	--- Returns a table containing unit names.
	-- @tparam table tbl sequential strings
	-- @treturn table @{UnitNameTable}
	function mist.makeUnitTable(tbl, exclude)
		--Assumption: will be passed a table of strings, sequential
		--log:info(tbl)


		local excludeType = {}
		if exclude then
			if type(exclude) == 'table' then
				for x, y in pairs(exclude) do
					excludeType[x] = true
					excludeType[y] = true
				end
			else
				excludeType[exclude] = true
			end
		end


		local units_by_name = {}

		local l_munits = mist.DBs.units --local reference for faster execution
		for i = 1, #tbl do
			local unit = tbl[i]
			if unit:sub(1, 4) == '[-u]' then --subtract a unit
				if units_by_name[unit:sub(5)] then -- 5 to end
					units_by_name[unit:sub(5)] = nil --remove
				end
			elseif unit:sub(1, 3) == '[g]' then -- add a group
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						for unit_type, unit_type_tbl in pairs(country_table) do
							if type(unit_type_tbl) == 'table' then
								for group_ind, group_tbl in pairs(unit_type_tbl) do
									if type(group_tbl) == 'table' and group_tbl.groupName == unit:sub(4) then
										-- index 4 to end
										for unit_ind, unit in pairs(group_tbl.units) do
											units_by_name[unit.unitName] = true --add
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 4) == '[-g]' then -- subtract a group
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						for unit_type, unit_type_tbl in pairs(country_table) do
							if type(unit_type_tbl) == 'table' then
								for group_ind, group_tbl in pairs(unit_type_tbl) do
									if type(group_tbl) == 'table' and group_tbl.groupName == unit:sub(5) then
										-- index 5 to end
										for unit_ind, unit in pairs(group_tbl.units) do
											if units_by_name[unit.unitName] then
												units_by_name[unit.unitName] = nil --remove
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 3) == '[c]' then -- add a country
				local category = ''
				local country_start = 4
				if unit:sub(4, 15) == '[helicopter]' then
					category = 'helicopter'
					country_start = 16
				elseif unit:sub(4, 10) == '[plane]' then
					category = 'plane'
					country_start = 11
				elseif unit:sub(4, 9) == '[ship]' then
					category = 'ship'
					country_start = 10
				elseif unit:sub(4, 12) == '[vehicle]' then
					category = 'vehicle'
					country_start = 13
				elseif unit:sub(4, 11) == '[static]' then
					category = 'static'
					country_start = 12
				end
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						if country == string.lower(unit:sub(country_start)) then -- match
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												units_by_name[unit.unitName] = true --add
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 4) == '[-c]' then -- subtract a country
				local category = ''
				local country_start = 5
				if unit:sub(5, 16) == '[helicopter]' then
					category = 'helicopter'
					country_start = 17
				elseif unit:sub(5, 11) == '[plane]' then
					category = 'plane'
					country_start = 12
				elseif unit:sub(5, 10) == '[ship]' then
					category = 'ship'
					country_start = 11
				elseif unit:sub(5, 13) == '[vehicle]' then
					category = 'vehicle'
					country_start = 14
				elseif unit:sub(5, 12) == '[static]' then
					category = 'static'
					country_start = 13
				end
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						if country == string.lower(unit:sub(country_start)) then -- match
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												if units_by_name[unit.unitName] then
													units_by_name[unit.unitName] = nil --remove
												end
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 6) == '[blue]' then -- add blue coalition
				local category = ''
				if unit:sub(7) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(7) == '[plane]' then
					category = 'plane'
				elseif unit:sub(7) == '[ship]' then
					category = 'ship'
				elseif unit:sub(7) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(7) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					if coa == 'blue' then
						for country, country_table in pairs(coa_tbl) do
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												units_by_name[unit.unitName] = true --add
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 7) == '[-blue]' then -- subtract blue coalition
				local category = ''
				if unit:sub(8) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(8) == '[plane]' then
					category = 'plane'
				elseif unit:sub(8) == '[ship]' then
					category = 'ship'
				elseif unit:sub(8) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(8) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					if coa == 'blue' then
						for country, country_table in pairs(coa_tbl) do
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												if units_by_name[unit.unitName] then
													units_by_name[unit.unitName] = nil --remove
												end
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 5) == '[red]' then -- add red coalition
				local category = ''
				if unit:sub(6) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(6) == '[plane]' then
					category = 'plane'
				elseif unit:sub(6) == '[ship]' then
					category = 'ship'
				elseif unit:sub(6) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(6) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					if coa == 'red' then
						for country, country_table in pairs(coa_tbl) do
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												units_by_name[unit.unitName] = true --add
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 6) == '[-red]' then -- subtract red coalition
				local category = ''
				if unit:sub(7) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(7) == '[plane]' then
					category = 'plane'
				elseif unit:sub(7) == '[ship]' then
					category = 'ship'
				elseif unit:sub(7) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(7) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					if coa == 'red' then
						for country, country_table in pairs(coa_tbl) do
							for unit_type, unit_type_tbl in pairs(country_table) do
								if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
									for group_ind, group_tbl in pairs(unit_type_tbl) do
										if type(group_tbl) == 'table' then
											for unit_ind, unit in pairs(group_tbl.units) do
												if units_by_name[unit.unitName] then
													units_by_name[unit.unitName] = nil --remove
												end
											end
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 5) == '[all]' then -- add all of a certain category (or all categories)
				local category = ''
				if unit:sub(6) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(6) == '[plane]' then
					category = 'plane'
				elseif unit:sub(6) == '[ship]' then
					category = 'ship'
				elseif unit:sub(6) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(6) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						for unit_type, unit_type_tbl in pairs(country_table) do
							if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
								for group_ind, group_tbl in pairs(unit_type_tbl) do
									if type(group_tbl) == 'table' then
										for unit_ind, unit in pairs(group_tbl.units) do
											units_by_name[unit.unitName] = true --add
										end
									end
								end
							end
						end
					end
				end
			elseif unit:sub(1, 6) == '[-all]' then -- subtract all of a certain category (or all categories)
				local category = ''
				if unit:sub(7) == '[helicopter]' then
					category = 'helicopter'
				elseif unit:sub(7) == '[plane]' then
					category = 'plane'
				elseif unit:sub(7) == '[ship]' then
					category = 'ship'
				elseif unit:sub(7) == '[vehicle]' then
					category = 'vehicle'
				elseif unit:sub(7) == '[static]' then
					category = 'static'
				end
				for coa, coa_tbl in pairs(l_munits) do
					for country, country_table in pairs(coa_tbl) do
						for unit_type, unit_type_tbl in pairs(country_table) do
							if type(unit_type_tbl) == 'table' and (category == '' or unit_type == category) and not excludeType[unit_type] then
								for group_ind, group_tbl in pairs(unit_type_tbl) do
									if type(group_tbl) == 'table' then
										for unit_ind, unit in pairs(group_tbl.units) do
											if units_by_name[unit.unitName] then
												units_by_name[unit.unitName] = nil --remove
											end
										end
									end
								end
							end
						end
					end
				end
			else               -- just a regular unit
				units_by_name[unit] = true --add
			end
		end

		local units_tbl = {} -- indexed sequentially
		for unit_name, val in pairs(units_by_name) do
			if val then
				units_tbl[#units_tbl + 1] = unit_name -- add all the units to the table
			end
		end


		units_tbl.processed = timer.getTime() --add the processed flag
		return units_tbl
	end

	function mist.getUnitsByAttribute(att, rnum, id)
		local cEntry = {}
		cEntry.type = att.type or att.typeName or att.typename
		cEntry.country = att.country
		cEntry.coalition = att.coalition
		cEntry.skill = att.skill
		cEntry.category = att.category

		local num = rnum or 1

		if cEntry.skill == 'human' then
			cEntry.skill = { 'Client', 'Player' }
		end


		local checkedVal = {}
		local units = {}
		for uName, uData in pairs(mist.DBs.unitsByName) do
			local matched = 0
			for cName, cVal in pairs(cEntry) do
				if type(cVal) == 'table' then
					for sName, sVal in pairs(cVal) do
						if (uData[cName] and uData[cName] == sVal) or (uData[cName] and uData[cName] == sName) then
							matched = matched + 1
						end
					end
				else
					if uData[cName] and uData[cName] == cVal then
						matched = matched + 1
					end
				end
			end
			if matched >= num then
				if id then
					units[uData.unitId] = true
				else
					units[uName] = true
				end
			end
		end

		local rtn = {}
		for name, _ in pairs(units) do
			table.insert(rtn, name)
		end
		return rtn
	end

	function mist.getGroupsByAttribute(att, rnum, id)
		local cEntry = {}
		cEntry.type = att.type or att.typeName or att.typename
		cEntry.country = att.country
		cEntry.coalition = att.coalition
		cEntry.skill = att.skill
		cEntry.category = att.category

		local num = rnum or 1

		if cEntry.skill == 'human' then
			cEntry.skill = { 'Client', 'Player' }
		end
		local groups = {}
		for gName, gData in pairs(mist.DBs.groupsByName) do
			local matched = 0
			for cName, cVal in pairs(cEntry) do
				if type(cVal) == 'table' then
					for sName, sVal in pairs(cVal) do
						if cName == 'skill' or cName == 'type' then
							local lMatch = 0
							for uId, uData in pairs(gData.units) do
								if (uData[cName] and uData[cName] == sVal) or (gData[cName] and gData[cName] == sName) then
									lMatch = lMatch + 1
									break
								end
							end
							if lMatch > 0 then
								matched = matched + 1
							end
						end
						if (gData[cName] and gData[cName] == sVal) or (gData[cName] and gData[cName] == sName) then
							matched = matched + 1
							break
						end
					end
				else
					if cName == 'skill' or cName == 'type' then
						local lMatch = 0
						for uId, uData in pairs(gData.units) do
							if (uData[cName] and uData[cName] == sVal) then
								lMatch = lMatch + 1
								break
							end
						end
						if lMatch > 0 then
							matched = matched + 1
						end
					end
					if gData[cName] and gData[cName] == cVal then
						matched = matched + 1
					end
				end
			end
			if matched >= num then
				if id then
					groups[gData.groupid] = true
				else
					groups[gName] = true
				end
			end
		end
		local rtn = {}
		for name, _ in pairs(groups) do
			table.insert(rtn, name)
		end
		return rtn
	end

	function mist.getDeadMapObjectsFromPoint(p, radius, filters)
		local map_objs = {}
		local fCheck = filters or {}
		local filter = {}
		local r = radius or p.radius or 100
		local point = mist.utils.makeVec3(p)
		local filterSize = 0
		for fInd, fVal in pairs(fCheck) do
			filterSize = filterSize + 1
			filter[string.lower(fInd)] = true
			filter[string.lower(fVal)] = true
		end
		for obj_id, obj in pairs(mist.DBs.deadObjects) do
			log:warn(obj)
			if obj.objectType and obj.objectType == 'building' then --dead map object
				if ((point.x - obj.objectPos.x) ^ 2 + (point.z - obj.objectPos.z) ^ 2) ^ 0.5 <= r then
					if filterSize == 0 or (obj.typeName and filter[string.lower(obj.typeName)]) then
						map_objs[#map_objs + 1] = mist.utils.deepCopy(obj)
					end
				end
			end
		end
		return map_objs
	end

	function mist.getDeadMapObjsInZones(zone_names, filters)
		-- zone_names: table of zone names
		-- returns: table of dead map objects (indexed numerically)
		local map_objs = {}
		local zones = {}
		for i = 1, #zone_names do
			if mist.DBs.zonesByName[zone_names[i]] then
				zones[#zones + 1] = mist.DBs.zonesByName[zone_names[i]]
			end
		end
		for i = 1, #zones do
			local rtn = mist.getDeadMapObjectsFromPoint(zones[i], nil, filters)
			for j = 1, #rtn do
				map_objs[#map_objs + 1] = rtn[j]
			end
		end

		return map_objs
	end

	function mist.getDeadMapObjsInPolygonZone(zone, filters)
		-- zone_names: table of zone names
		-- returns: table of dead map objects (indexed numerically)
		local filter = {}
		local fCheck = filters or {}
		local filterSize = 0
		for fInd, fVal in pairs(fCheck) do
			filterSize = filterSize + 1
			filter[string.lower(fInd)] = true
			filter[string.lower(fVal)] = true
		end
		local map_objs = {}
		for obj_id, obj in pairs(mist.DBs.deadObjects) do
			if obj.objectType and obj.objectType == 'building' then --dead map object
				if mist.pointInPolygon(obj.objectPos, zone) and (filterSize == 0 or filter[string.lower(obj.objectData.type)]) then
					map_objs[#map_objs + 1] = mist.utils.deepCopy(obj)
				end
			end
		end
		return map_objs
	end

	mist.shape = {}
	function mist.shape.insideShape(shape1, shape2, full)
		if shape1.radius then -- probably a circle
			if shape2.radius then
				return mist.shape.circleInCircle(shape1, shape2, full)
			elseif shape2[1] then
				return mist.shape.circleInPoly(shape1, shape2, full)
			end
		elseif shape1[1] then -- shape1 is probably a polygon
			if shape2.radius then
				return mist.shape.polyInCircle(shape1, shape2, full)
			elseif shape2[1] then
				return mist.shape.polyInPoly(shape1, shape2, full)
			end
		end
		return false
	end

	function mist.shape.circleInCircle(c1, c2, full)
		if not full then -- quick partial check
			if mist.utils.get2DDist(c1.point, c2.point) <= c2.radius then
				return true
			end
		end
		local theta = mist.utils.getHeadingPoints(c2.point, c1.point) -- heading from
		if full then
			return mist.utils.get2DDist(mist.projectPoint(c1.point, c1.radius, theta), c2.point) <= c2.radius
		else
			return mist.utils.get2DDist(mist.projectPoint(c1.point, c1.radius, theta + math.pi), c2.point) <= c2.radius
		end
		return false
	end

	function mist.shape.circleInPoly(circle, poly, full)
		if poly and type(poly) == 'table' and circle and type(circle) == 'table' and circle.radius and circle.point then
			if not full then
				for i = 1, #poly do
					if mist.utils.get2DDist(circle.point, poly[i]) <= circle.radius then
						return true
					end
				end
			end
			-- no point is inside of the zone, now check if any part is
			local count = 0
			for i = 1, #poly do
				local theta -- heading of each set of points
				if i == #poly then
					theta = mist.utils.getHeadingPoints(poly[i], poly[1])
				else
					theta = mist.utils.getHeadingPoints(poly[i], poly[i + 1])
				end
				-- offset
				local pPoint = mist.projectPoint(circle.point, circle.radius, theta - (math.pi / 180))
				local oPoint = mist.projectPoint(circle.point, circle.radius, theta + (math.pi / 180))


				if mist.pointInPolygon(pPoint, poly) == true then
					if (full and mist.pointInPolygon(oPoint, poly) == true) or not full then
						return true
					end
				end
			end
		end
		return false
	end

	function mist.shape.polyInPoly(p1, p2, full)
		local count = 0
		for i = 1, #p1 do
			if mist.pointInPolygon(p1[i], p2) then
				count = count + 1
			end
			if (not full) and count > 0 then
				return true
			end
		end
		if count == #p1 then
			return true
		end

		return false
	end

	function mist.shape.polyInCircle(poly, circle, full)
		local count = 0
		for i = 1, #poly do
			if mist.utils.get2DDist(circle.point, poly[i]) <= circle.radius then
				if full then
					count = count + 1
				else
					return true
				end
			end
		end
		if count == #poly then
			return true
		end

		return false
	end

	function mist.shape.getPointOnSegment(point, seg, isSeg)
		local p = mist.utils.makeVec2(point)
		local s1 = mist.utils.makeVec2(seg[1])
		local s2 = mist.utils.makeVec2(seg[2])


		local cx, cy = p.x - s1.x, p.y - s1.y
		local dx, dy = s2.x - s1.x, s2.y - s1.y
		local d = (dx * dx + dy * dy)

		if d == 0 then
			return { x = s1.x, y = s1.y }
		end
		local u = (cx * dx + cy * dy) / d
		if isSeg then
			if u < 0 then
				u = 0
			elseif u > 1 then
				u = 1
			end
		end
		return { x = s1.x + u * dx, y = s1.y + u * dy }
	end

	function mist.shape.segmentIntersect(seg1, seg2)
		local segA = { mist.utils.makeVec2(seg1[1]), mist.utils.makeVec2(seg1[2]) }
		local segB = { mist.utils.makeVec2(seg2[1]), mist.utils.makeVec2(seg2[2]) }

		local dx1, dy1 = segA[2].x - segA[1].x, segA[2].y - segA[1].y
		local dx2, dy2 = segB[2].x - segB[1].x, segB[2].y - segB[1].y
		local dx3, dy3 = segA[1].x - segB[1].x, segA[1].y - segB[1].y

		local d = dx1 * dy2 - dy1 * dx2

		if d == 0 then
			return false
		end
		local t1 = (dx2 * dy3 - dy2 * dx3) / d
		if t1 < 0 or t1 > 1 then
			return false
		end
		local t2 = (dx1 * dy3 - dy1 * dx3) / d
		if t2 < 0 or t2 > 1 then
			return false
		end
		-- point of intersection
		return true, { x = segA[1].x + t1 * dx1, y = segA[1].y + t1 * dy1 }
	end

	function mist.pointInPolygon(point, poly, maxalt) --raycasting point in polygon. Code from http://softsurfer.com/Archive/algorithm_0103/algorithm_0103.htm
		--[[local type_tbl = {
		point = {'table'},
		poly = {'table'},
		maxalt = {'number', 'nil'},
		}

	local err, errmsg = mist.utils.typeCheck('mist.pointInPolygon', type_tbl, {point, poly, maxalt})
	assert(err, errmsg)
	]]
		point = mist.utils.makeVec3(point)
		local px = point.x
		local pz = point.z
		local cn = 0
		local newpoly = mist.utils.deepCopy(poly)

		if not maxalt or (point.y <= maxalt) then
			local polysize = #newpoly
			newpoly[#newpoly + 1] = newpoly[1]

			newpoly[1] = mist.utils.makeVec3(newpoly[1])

			for k = 1, polysize do
				newpoly[k + 1] = mist.utils.makeVec3(newpoly[k + 1])
				if ((newpoly[k].z <= pz) and (newpoly[k + 1].z > pz)) or ((newpoly[k].z > pz) and (newpoly[k + 1].z <= pz)) then
					local vt = (pz - newpoly[k].z) / (newpoly[k + 1].z - newpoly[k].z)
					if (px < newpoly[k].x + vt * (newpoly[k + 1].x - newpoly[k].x)) then
						cn = cn + 1
					end
				end
			end

			return cn % 2 == 1
		else
			return false
		end
	end

	function mist.mapValue(val, inMin, inMax, outMin, outMax)
		return (val - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
	end

	function mist.getUnitsInPolygon(unit_names, polyZone, max_alt)
		local units = {}

		for i = 1, #unit_names do
			units[#units + 1] = Unit.getByName(unit_names[i]) or StaticObject.getByName(unit_names[i])
		end

		local inZoneUnits = {}
		for i = 1, #units do
			local lUnit = units[i]
			local lCat = Object.getCategory(lUnit)
			if lUnit:isExist() == true and ((lCat == 1 and lUnit:isActive()) or lCat ~= 1) and mist.pointInPolygon(lUnit:getPosition().p, polyZone, max_alt) then
				inZoneUnits[#inZoneUnits + 1] = lUnit
			end
		end

		return inZoneUnits
	end

	function mist.getUnitsInZones(unit_names, zone_names, zone_type)
		zone_type = zone_type or 'cylinder'
		if zone_type == 'c' or zone_type == 'cylindrical' or zone_type == 'C' then
			zone_type = 'cylinder'
		end
		if zone_type == 's' or zone_type == 'spherical' or zone_type == 'S' then
			zone_type = 'sphere'
		end

		assert(zone_type == 'cylinder' or zone_type == 'sphere', 'invalid zone_type: ' .. tostring(zone_type))

		local units = {}
		local zones = {}

		if zone_names and type(zone_names) == 'string' then
			zone_names = { zone_names }
		end
		for k = 1, #unit_names do
			local unit = Unit.getByName(unit_names[k]) or StaticObject.getByName(unit_names[k])
			if unit and unit:isExist() == true then
				units[#units + 1] = unit
			end
		end


		for k = 1, #zone_names do
			local zone = mist.DBs.zonesByName[zone_names[k]]
			if zone then
				zones[#zones + 1] = {
					radius = zone.radius,
					x = zone.point.x,
					y = zone.point.y,
					z = zone.point.z,
					verts =
						zone.verticies
				}
			end
		end

		local in_zone_units = {}
		for units_ind = 1, #units do
			local lUnit = units[units_ind]
			local unit_pos = lUnit:getPosition().p
			local lCat = Object.getCategory(lUnit)
			for zones_ind = 1, #zones do
				if zone_type == 'sphere' then --add land height value for sphere zone type
					local alt = land.getHeight({ x = zones[zones_ind].x, y = zones[zones_ind].z })
					if alt then
						zones[zones_ind].y = alt
					end
				end

				if unit_pos and ((lCat == 1 and lUnit:isActive() == true) or lCat ~= 1) then -- it is a unit and is active or it is not a unit
					if zones[zones_ind].verts then
						if mist.pointInPolygon(unit_pos, zones[zones_ind].verts) then
							in_zone_units[#in_zone_units + 1] = lUnit
						end
					else
						if zone_type == 'cylinder' and (((unit_pos.x - zones[zones_ind].x) ^ 2 + (unit_pos.z - zones[zones_ind].z) ^ 2) ^ 0.5 <= zones[zones_ind].radius) then
							in_zone_units[#in_zone_units + 1] = lUnit
							break
						elseif zone_type == 'sphere' and (((unit_pos.x - zones[zones_ind].x) ^ 2 + (unit_pos.y - zones[zones_ind].y) ^ 2 + (unit_pos.z - zones[zones_ind].z) ^ 2) ^ 0.5 <= zones[zones_ind].radius) then
							in_zone_units[#in_zone_units + 1] = lUnit
							break
						end
					end
				end
			end
		end
		return in_zone_units
	end

	function mist.getUnitsInMovingZones(unit_names, zone_unit_names, radius, zone_type)
		zone_type = zone_type or 'cylinder'
		if zone_type == 'c' or zone_type == 'cylindrical' or zone_type == 'C' then
			zone_type = 'cylinder'
		end
		if zone_type == 's' or zone_type == 'spherical' or zone_type == 'S' then
			zone_type = 'sphere'
		end

		assert(zone_type == 'cylinder' or zone_type == 'sphere', 'invalid zone_type: ' .. tostring(zone_type))

		local units = {}
		local zone_units = {}

		for k = 1, #unit_names do
			local unit = Unit.getByName(unit_names[k]) or StaticObject.getByName(unit_names[k])
			if unit and unit:isExist() == true then
				units[#units + 1] = unit
			end
		end

		for k = 1, #zone_unit_names do
			local unit = Unit.getByName(zone_unit_names[k]) or StaticObject.getByName(zone_unit_names[k])
			if unit and unit:isExist() == true then
				zone_units[#zone_units + 1] = unit
			end
		end

		local in_zone_units = {}

		for units_ind = 1, #units do
			local lUnit = units[units_ind]
			local lCat = Object.getCategory(lUnit)
			local unit_pos = lUnit:getPosition().p
			for zone_units_ind = 1, #zone_units do
				local zone_unit_pos = zone_units[zone_units_ind]:getPosition().p
				if unit_pos and zone_unit_pos and ((lCat == 1 and lUnit:isActive()) or lCat ~= 1) then
					if zone_type == 'cylinder' and (((unit_pos.x - zone_unit_pos.x) ^ 2 + (unit_pos.z - zone_unit_pos.z) ^ 2) ^ 0.5 <= radius) then
						in_zone_units[#in_zone_units + 1] = lUnit
						break
					elseif zone_type == 'sphere' and (((unit_pos.x - zone_unit_pos.x) ^ 2 + (unit_pos.y - zone_unit_pos.y) ^ 2 + (unit_pos.z - zone_unit_pos.z) ^ 2) ^ 0.5 <= radius) then
						in_zone_units[#in_zone_units + 1] = lUnit
						break
					end
				end
			end
		end
		return in_zone_units
	end

	function mist.getUnitsLOS(unitset1, altoffset1, unitset2, altoffset2, radius)
		--log:info("$1, $2, $3, $4, $5", unitset1, altoffset1, unitset2, altoffset2, radius)
		radius = radius or math.huge
		local unit_info1 = {}
		local unit_info2 = {}

		-- get the positions all in one step, saves execution time.
		for unitset1_ind = 1, #unitset1 do
			local unit1 = Unit.getByName(unitset1[unitset1_ind])
			if unit1 then
				local lCat = Object.getCategory(unit1)
				if ((lCat == 1 and unit1:isActive()) or lCat ~= 1) and unit1:isExist() == true then
					unit_info1[#unit_info1 + 1] = {}
					unit_info1[#unit_info1].unit = unit1
					unit_info1[#unit_info1].pos = unit1:getPosition().p
				end
			end
		end

		for unitset2_ind = 1, #unitset2 do
			local unit2 = Unit.getByName(unitset2[unitset2_ind])
			if unit2 then
				local lCat = Object.getCategory(unit2)
				if ((lCat == 1 and unit2:isActive()) or lCat ~= 1) and unit2:isExist() == true then
					unit_info2[#unit_info2 + 1] = {}
					unit_info2[#unit_info2].unit = unit2
					unit_info2[#unit_info2].pos = unit2:getPosition().p
				end
			end
		end

		local LOS_data = {}
		-- now compute los
		for unit1_ind = 1, #unit_info1 do
			local unit_added = false
			for unit2_ind = 1, #unit_info2 do
				if radius == math.huge or (mist.vec.mag(mist.vec.sub(unit_info1[unit1_ind].pos, unit_info2[unit2_ind].pos)) < radius) then -- inside radius
					local point1 = {
						x = unit_info1[unit1_ind].pos.x,
						y = unit_info1[unit1_ind].pos.y + altoffset1,
						z =
							unit_info1[unit1_ind].pos.z
					}
					local point2 = {
						x = unit_info2[unit2_ind].pos.x,
						y = unit_info2[unit2_ind].pos.y + altoffset2,
						z =
							unit_info2[unit2_ind].pos.z
					}
					if land.isVisible(point1, point2) then
						if unit_added == false then
							unit_added = true
							LOS_data[#LOS_data + 1] = {}
							LOS_data[#LOS_data].unit = unit_info1[unit1_ind].unit
							LOS_data[#LOS_data].vis = {}
							LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
						else
							LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
						end
					end
				end
			end
		end

		return LOS_data
	end

	function mist.getAvgPoint(points)
		local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
		for i = 1, #points do
			--log:warn(points[i])
			local nPoint = mist.utils.makeVec3(points[i])
			if nPoint.z then
				avgX = avgX + nPoint.x
				avgY = avgY + nPoint.y
				avgZ = avgZ + nPoint.z
				totNum = totNum + 1
			end
		end
		if totNum ~= 0 then
			return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
		end
	end

	--Gets the average position of a group of units (by name)
	function mist.getAvgPos(unitNames)
		local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
		for i = 1, #unitNames do
			local unit
			if Unit.getByName(unitNames[i]) then
				unit = Unit.getByName(unitNames[i])
			elseif StaticObject.getByName(unitNames[i]) then
				unit = StaticObject.getByName(unitNames[i])
			end
			if unit and unit:isExist() == true then
				local pos = unit:getPosition().p
				if pos then -- you never know O.o
					avgX = avgX + pos.x
					avgY = avgY + pos.y
					avgZ = avgZ + pos.z
					totNum = totNum + 1
				end
			end
		end
		if totNum ~= 0 then
			return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
		end
	end

	function mist.getAvgGroupPos(groupName)
		if type(groupName) == 'string' and Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
			groupName = Group.getByName(groupName)
		end
		local units = {}
		for i = 1, groupName:getSize() do
			table.insert(units, groupName:getUnit(i):getName())
		end

		return mist.getAvgPos(units)
	end

	--[[ vars for mist.getMGRSString:
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer between 0 and 5, inclusive
]]
	function mist.getMGRSString(vars)
		local units = vars.units
		local acc = vars.acc or 5
		local avgPos = mist.getAvgPos(units)
		if avgPos then
			return mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(avgPos)), acc)
		end
	end

	--[[ vars for mist.getLLString
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer, number of numbers after decimal place
vars.DMS - if true, output in degrees, minutes, seconds.	Otherwise, output in degrees, minutes.
]]
	function mist.getLLString(vars)
		local units = vars.units
		local acc = vars.acc or 3
		local DMS = vars.DMS
		local avgPos = mist.getAvgPos(units)
		if avgPos then
			local lat, lon = coord.LOtoLL(avgPos)
			return mist.tostringLL(lat, lon, acc, DMS)
		end
	end

	--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -	vec3 ref point, maybe overload for vec2 as well?
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
]]
	function mist.getBRString(vars)
		local units = vars.units
		local ref = mist.utils.makeVec3(vars.ref, 0) -- turn it into Vec3 if it is not already.
		local alt = vars.alt
		local metric = vars.metric
		local avgPos = mist.getAvgPos(units)
		if avgPos then
			local vec = { x = avgPos.x - ref.x, y = avgPos.y - ref.y, z = avgPos.z - ref.z }
			local dir = mist.utils.getDir(vec, ref)
			local dist = mist.utils.get2DDist(avgPos, ref)
			if alt then
				alt = avgPos.y
			end
			return mist.tostringBR(dir, dist, alt, metric)
		end
	end

	-- Returns the Vec3 coordinates of the average position of the concentration of units most in the heading direction.
	--[[ vars for mist.getLeadingPos:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
]]
	function mist.getLeadingPos(vars)
		local units = vars.units
		local heading = vars.heading
		local radius = vars.radius
		if vars.headingDegrees then
			heading = mist.utils.toRadian(vars.headingDegrees)
		end

		local unitPosTbl = {}
		for i = 1, #units do
			local unit = Unit.getByName(units[i])
			if unit and unit:isExist() then
				unitPosTbl[#unitPosTbl + 1] = unit:getPosition().p
			end
		end

		if #unitPosTbl > 0 then -- one more more units found.
			-- first, find the unit most in the heading direction
			local maxPos = -math.huge
			heading = heading * -1 -- rotated value appears to be opposite of what was expected
			local maxPosInd -- maxPos - the furthest in direction defined by heading; maxPosInd =
			for i = 1, #unitPosTbl do
				local rotatedVec2 = mist.vec.rotateVec2(mist.utils.makeVec2(unitPosTbl[i]), heading)
				if (not maxPos) or maxPos < rotatedVec2.x then
					maxPos = rotatedVec2.x
					maxPosInd = i
				end
			end

			--now, get all the units around this unit...
			local avgPos
			if radius then
				local maxUnitPos = unitPosTbl[maxPosInd]
				local avgx, avgy, avgz, totNum = 0, 0, 0, 0
				for i = 1, #unitPosTbl do
					if mist.utils.get2DDist(maxUnitPos, unitPosTbl[i]) <= radius then
						avgx = avgx + unitPosTbl[i].x
						avgy = avgy + unitPosTbl[i].y
						avgz = avgz + unitPosTbl[i].z
						totNum = totNum + 1
					end
				end
				avgPos = { x = avgx / totNum, y = avgy / totNum, z = avgz / totNum }
			else
				avgPos = unitPosTbl[maxPosInd]
			end

			return avgPos
		end
	end

	--[[ vars for mist.getLeadingMGRSString:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.acc - number, 0 to 5.
]]
	function mist.getLeadingMGRSString(vars)
		local pos = mist.getLeadingPos(vars)
		if pos then
			local acc = vars.acc or 5
			return mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(pos)), acc)
		end
	end

	--[[ vars for mist.getLeadingLLString:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.acc - number of digits after decimal point (can be negative)
vars.DMS -	boolean, true if you want DMS.
]]
	function mist.getLeadingLLString(vars)
		local pos = mist.getLeadingPos(vars)
		if pos then
			local acc = vars.acc or 3
			local DMS = vars.DMS
			local lat, lon = coord.LOtoLL(pos)
			return mist.tostringLL(lat, lon, acc, DMS)
		end
	end

	--[[ vars for mist.getLeadingBRString:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.metric - boolean, if true, use km instead of NM.
vars.alt - boolean, if true, include altitude.
vars.ref - vec3/vec2 reference point.
]]
	function mist.getLeadingBRString(vars)
		local pos = mist.getLeadingPos(vars)
		if pos then
			local ref = vars.ref
			local alt = vars.alt
			local metric = vars.metric

			local vec = { x = pos.x - ref.x, y = pos.y - ref.y, z = pos.z - ref.z }
			local dir = mist.utils.getDir(vec, ref)
			local dist = mist.utils.get2DDist(pos, ref)
			if alt then
				alt = pos.y
			end
			return mist.tostringBR(dir, dist, alt, metric)
		end
	end

	--[[getPathLength from GSH
-- Returns the length between the defined set of points. Can also return the point index before the cutoff was achieved
p - table of path points, vec2 or vec3
cutoff - number distance after which to stop at
topo  - boolean for if it should get the topographical distance

]]

	function mist.getPathLength(p, cutoff, topo)
		local l = 0
		local cut = 0 or cutOff
		local path = {}

		for i = 1, #p do
			if topo then
				table.insert(path, mist.utils.makeVec3GL(p[i]))
			else
				table.insert(path, mist.utils.makeVec3(p[i]))
			end
		end

		for i = 1, #path do
			if i + 1 <= #path then
				if topo then
					l = mist.utils.get3DDist(path[i], path[i + 1]) + l
				else
					l = mist.utils.get2DDist(path[i], path[i + 1]) + l
				end
			end
			if cut ~= 0 and l > cut then
				return l, i
			end
		end
		return l
	end

	--[[
Return a series of points to simplify the input table. Best used in conjunction with findPathOnRoads to turn the massive table into a list of X points.
p - table of path points, can be vec2 or vec3
num - number of segments.
exact - boolean for whether or not it returns the exact distance or uses the first WP to that distance.


]]

	function mist.getPathInSegments(p, num, exact)
		local tot = mist.getPathLength(p)
		local checkDist = tot / num
		local typeUsed = 'vec2'

		local points = { [1] = p[1] }
		local curDist = 0
		for i = 1, #p do
			if i + 1 <= #p then
				curDist = mist.utils.get2DDist(p[i], p[i + 1]) + curDist
				if curDist > checkDist then
					curDist = 0
					if exact then
						-- get avg point between the two
						-- insert into point table
						-- need to be accurate... maybe reassign the point for the value it is checking?
						-- insert into p table?
					else
						table.insert(points, p[i])
					end
				end
			end
		end
		return points
	end

	function mist.getPointAtDistanceOnPath(p, dist, r, rtn)
		log:info('find distance: $1', dist)
		local rType = r or 'roads'
		local point = { x = 0, y = 0, z = 0 }
		local path = {}
		local ret = rtn or 'vec2'
		local l = 0
		if p[1] and #p == 2 then
			path = land.findPathOnRoads(rType, p[1].x, p[1].y, p[2].x, p[2].y)
		else
			path = p
		end
		for i = 1, #path do
			if i + 1 <= #path then
				nextPoint = path[i + 1]
				if topo then
					l = mist.utils.get3DDist(path[i], path[i + 1]) + l
				else
					l = mist.utils.get2DDist(path[i], path[i + 1]) + l
				end
			end
			if l > dist then
				local diff = dist
				if i ~= 1 then -- get difference
					diff = l - dist
				end
				local dir = mist.utils.getHeadingPoints(mist.utils.makeVec3(path[i]), mist.utils.makeVec3(path[i + 1]))
				local x, y
				if r then
					x, y = land.getClosestPointOnRoads(rType, mist.utils.round((math.cos(dir) * diff) + path[i].x, 1),
						mist.utils.round((math.sin(dir) * diff) + path[i].y, 1))
				else
					x, y = mist.utils.round((math.cos(dir) * diff) + path[i].x, 1),
						mist.utils.round((math.sin(dir) * diff) + path[i].y, 1)
				end

				if ret == 'vec2' then
					return { x = x, y = y }, dir
				elseif ret == 'vec3' then
					return { x = x, y = 0, z = y }, dir
				end

				return { x = x, y = y }, dir
			end
		end
		log:warn('Find point at distance: $1, path distance $2', dist, l)
		return false
	end

	function mist.projectPoint(point, dist, theta)
		local newPoint = {}
		if point.z then
			newPoint.z = mist.utils.round(math.sin(theta) * dist + point.z, 3)
			newPoint.y = mist.utils.deepCopy(point.y)
		else
			newPoint.y = mist.utils.round(math.sin(theta) * dist + point.y, 3)
		end
		newPoint.x = mist.utils.round(math.cos(theta) * dist + point.x, 3)

		return newPoint
	end
end




--- Group functions.
-- @section groups
do -- group functions scope
	--- Check table used for group creation.
	-- @tparam table groupData table to check.
	-- @treturn boolean true if a group can be spawned using
	-- this table, false otherwise.
	function mist.groupTableCheck(groupData)
		-- return false if country, category
		-- or units are missing
		if not groupData.country or
			not groupData.category or
			not groupData.units then
			return false
		end
		-- return false if unitData misses
		-- x, y or type
		for unitId, unitData in pairs(groupData.units) do
			if not unitData.x or
				not unitData.y or
				not unitData.type then
				return false
			end
		end
		-- everything we need is here return true
		return true
	end

	--- Returns group data table of give group.
	function mist.getCurrentGroupData(gpName)
		local dbData = mist.getGroupData(gpName) or {}

		if Group.getByName(gpName) and Group.getByName(gpName):isExist() == true then
			local newGroup = Group.getByName(gpName)
			local newData = mist.utils.deepCopy(dbData)
			newData.name = gpName
			newData.groupId = tonumber(newGroup:getID())
			newData.category = newGroup:getCategory()
			newData.groupName = gpName
			newData.hidden = dbData.hidden


			if newData.category == 2 then
				newData.category = 'vehicle'
			elseif newData.category == 3 then
				newData.category = 'ship'
			end

			newData.units = {}
			local newUnits = newGroup:getUnits()
			if #newUnits == 0 then
				log:warn('getCurrentGroupData has returned no units for: $1', gpName)
			end
			for unitNum, unitData in pairs(newGroup:getUnits()) do
				newData.units[unitNum] = {}
				local uName = unitData:getName()

				if mist.DBs.unitsByName[uName] and unitData:getTypeName() == mist.DBs.unitsByName[uName].type and mist.DBs.unitsByName[uName].unitId == tonumber(unitData:getID()) then -- If old data matches most of new data
					newData.units[unitNum] = mist.utils.deepCopy(mist.DBs.unitsByName[uName])
				else
					newData.units[unitNum].unitId = tonumber(unitData:getID())
					newData.units[unitNum].type = unitData:getTypeName()
					newData.units[unitNum].skill = mist.getUnitSkill(uName)
					newData.country = string.lower(country.name[unitData:getCountry()])
					newData.units[unitNum].callsign = unitData:getCallsign()
					newData.units[unitNum].unitName = uName
				end
				local pos = unitData:getPosition()
				newData.units[unitNum].x = pos.p.x
				newData.units[unitNum].y = pos.p.z
				newData.units[unitNum].point = { x = newData.units[unitNum].x, y = newData.units[unitNum].y }
				newData.units[unitNum].heading = math.atan2(pos.x.z, pos.x.x)
				newData.units[unitNum].alt = pos.p.y
				newData.units[unitNum].speed = mist.vec.mag(unitData:getVelocity())
			end

			return newData
		elseif StaticObject.getByName(gpName) and StaticObject.getByName(gpName):isExist() == true and dbData.units then
			local staticObj = StaticObject.getByName(gpName)
			local pos = staticObj:getPosition()
			dbData.units[1].x = pos.p.x
			dbData.units[1].y = pos.p.z
			dbData.units[1].alt = pos.p.y
			dbData.units[1].heading = math.atan2(pos.x.z, pos.x.x)

			return dbData
		end
	end

	function mist.getGroupData(gpName, route)
		local found = false
		local newData = {}
		if mist.DBs.groupsByName[gpName] then
			newData = mist.utils.deepCopy(mist.DBs.groupsByName[gpName])
			found = true
		end

		if found == false then
			for groupName, groupData in pairs(mist.DBs.groupsByName) do
				if mist.stringMatch(groupName, gpName) == true then
					newData = mist.utils.deepCopy(groupData)
					newData.groupName = groupName
					found = true
					break
				end
			end
		end

		local payloads
		if newData.category == 'plane' or newData.category == 'helicopter' then
			payloads = mist.getGroupPayload(newData.groupName)
		end
		if found == true then
			--newData.hidden = false -- maybe add this to DBs

			for unitNum, unitData in pairs(newData.units) do
				newData.units[unitNum] = {}

				newData.units[unitNum].unitId = unitData.unitId
				--newData.units[unitNum].point = unitData.point
				newData.units[unitNum].x = unitData.point.x
				newData.units[unitNum].y = unitData.point.y
				newData.units[unitNum].alt = unitData.alt
				newData.units[unitNum].alt_type = unitData.alt_type
				newData.units[unitNum].speed = unitData.speed
				newData.units[unitNum].type = unitData.type
				newData.units[unitNum].skill = unitData.skill
				newData.units[unitNum].unitName = unitData.unitName
				newData.units[unitNum].heading = unitData.heading   -- added to DBs
				newData.units[unitNum].playerCanDrive = unitData.playerCanDrive -- added to DBs
				newData.units[unitNum].livery_id = unitData.livery_id
				newData.units[unitNum].AddPropAircraft = unitData.AddPropAircraft
				newData.units[unitNum].AddPropVehicle = unitData.AddPropVehicle


				if newData.category == 'plane' or newData.category == 'helicopter' then
					newData.units[unitNum].payload = payloads[unitNum]

					newData.units[unitNum].onboard_num = unitData.onboard_num
					newData.units[unitNum].callsign = unitData.callsign
				end
				if newData.category == 'static' then
					newData.units[unitNum].categoryStatic = unitData.categoryStatic
					newData.units[unitNum].mass = unitData.mass
					newData.units[unitNum].canCargo = unitData.canCargo
					newData.units[unitNum].shape_name = unitData.shape_name
				end
			end
			--log:info(newData)
			if route then
				newData.route = mist.getGroupRoute(gpName, true)
			end

			return newData
		else
			log:error('$1 not found in MIST database', gpName)
			return
		end
	end

	function mist.getPayload(unitIdent)
		-- refactor to search by groupId and allow groupId and groupName as inputs
		local unitId = unitIdent
		if type(unitIdent) == 'string' and not tonumber(unitIdent) then
			if mist.DBs.MEunitsByName[unitIdent] then
				unitId = mist.DBs.MEunitsByName[unitIdent].unitId
			else
				log:error("Unit not found in mist.DBs.MEunitsByName: $1", unitIdent)
				return {}
			end
		elseif type(unitIdent) == "number" and not mist.DBs.MEunitsById[unitIdent] then
			log:error("Unit not found in mist.DBs.MEunitsBId: $1", unitIdent)
			return {}
		end
		local ref = mist.DBs.MEunitsById[unitId]

		if ref then
			local gpId = mist.DBs.MEunitsById[unitId].groupId

			if gpId and unitId then
				for coa_name, coa_data in pairs(env.mission.coalition) do
					if (coa_name == 'red' or coa_name == 'blue') and type(coa_data) == 'table' then
						if coa_data.country then --there is a country table
							for cntry_id, cntry_data in pairs(coa_data.country) do
								for obj_cat_name, obj_cat_data in pairs(cntry_data) do
									if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then -- only these types have points
										if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
											for group_num, group_data in pairs(obj_cat_data.group) do
												if group_data and group_data.groupId == gpId then
													for unitIndex, unitData in pairs(group_data.units) do --group index
														if unitData.unitId == unitId then
															return unitData.payload
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		else
			log:error('Need string or number. Got: $1', type(unitIdent))
			return {}
		end
		log:warn("Couldn't find payload for unit: $1", unitIdent)
		return {}
	end

	function mist.getGroupPayload(groupIdent)
		local gpId = groupIdent
		if type(groupIdent) == 'string' and not tonumber(groupIdent) then
			if mist.DBs.MEgroupsByName[groupIdent] then
				gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
			else
				log:error('$1 not found in mist.DBs.MEgroupsByName', groupIdent)
				return {}
			end
		end

		if gpId then
			for coa_name, coa_data in pairs(env.mission.coalition) do
				if type(coa_data) == 'table' then
					if coa_data.country then --there is a country table
						for cntry_id, cntry_data in pairs(coa_data.country) do
							for obj_cat_name, obj_cat_data in pairs(cntry_data) do
								if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then -- only these types have points
									if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
										for group_num, group_data in pairs(obj_cat_data.group) do
											if group_data and group_data.groupId == gpId then
												local payloads = {}
												for unitIndex, unitData in pairs(group_data.units) do --group index
													payloads[unitIndex] = unitData.payload
												end
												return payloads
											end
										end
									end
								end
							end
						end
					end
				end
			end
		else
			log:error('Need string or number. Got: $1', type(groupIdent))
			return {}
		end
		log:warn("Couldn't find payload for group: $1", groupIdent)
		return {}
	end

	function mist.getGroupTable(groupIdent)
		local gpId = groupIdent
		if type(groupIdent) == 'string' and not tonumber(groupIdent) then
			if mist.DBs.MEgroupsByName[groupIdent] then
				gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
			else
				log:error('$1 not found in mist.DBs.MEgroupsByName', groupIdent)
			end
		end

		if gpId then
			for coa_name, coa_data in pairs(env.mission.coalition) do
				if type(coa_data) == 'table' then
					if coa_data.country then --there is a country table
						for cntry_id, cntry_data in pairs(coa_data.country) do
							for obj_cat_name, obj_cat_data in pairs(cntry_data) do
								if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then -- only these types have points
									if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
										for group_num, group_data in pairs(obj_cat_data.group) do
											if group_data and group_data.groupId == gpId then
												local gp = mist.utils.deepCopy(group_data)
												gp.category = obj_cat_name
												gp.country = cntry_data.id
												return gp
											end
										end
									end
								end
							end
						end
					end
				end
			end
		else
			log:error('Need string or number. Got: $1', type(groupIdent))
			return false
		end
		log:warn("Couldn't find table for group: $1", groupIdent)
	end

	function mist.getValidRandomPoint(vars)

	end

	function mist.teleportToPoint(vars) -- main teleport function that all of teleport/respawn functions call
		--log:warn(vars)
		local point = vars.point
		local gpName
		if vars.gpName then
			gpName = vars.gpName
		elseif vars.groupName then
			gpName = vars.groupName
		else
			log:error('Missing field groupName or gpName in variable table. Table: $1', vars)
		end

		--[[New vars to add, mostly for when called via inZone functions
        anyTerrain
        offsetWP1
        offsetRoute
        initTasks

        ]]

		local action = vars.action

		local disperse = vars.disperse or false
		local maxDisp = vars.maxDisp or 200
		local radius = vars.radius or 0
		local innerRadius = vars.innerRadius

		local dbData = false



		local newGroupData
		if gpName and not vars.groupData then
			if string.lower(action) == 'teleport' or string.lower(action) == 'tele' then
				newGroupData = mist.getCurrentGroupData(gpName)
			elseif string.lower(action) == 'respawn' then
				newGroupData = mist.getGroupData(gpName)
				dbData = true
			elseif string.lower(action) == 'clone' then
				newGroupData = mist.getGroupData(gpName)
				newGroupData.clone = 'order66'
				dbData = true
			else
				action = 'tele'
				newGroupData = mist.getCurrentGroupData(gpName)
			end
		else
			action = 'tele'
			newGroupData = vars.groupData
		end

		if vars.newGroupName then
			newGroupData.groupName = vars.newGroupName
		end

		if #newGroupData.units == 0 then
			log:warn('$1 has no units in group table', gpName)
			return
		end

		--log:info('get Randomized Point')
		local diff = { x = 0, y = 0 }
		local newCoord, origCoord

		local validTerrain = { 'LAND', 'ROAD', 'SHALLOW_WATER', 'WATER', 'RUNWAY' }
		if vars.anyTerrain then
			-- do nothing
		elseif vars.validTerrain then
			validTerrain = vars.validTerrain
		else
			if string.lower(newGroupData.category) == 'ship' then
				validTerrain = { 'SHALLOW_WATER', 'WATER' }
			elseif string.lower(newGroupData.category) == 'vehicle' then
				validTerrain = { 'LAND', 'ROAD' }
			end
		end

		if point and radius >= 0 then
			local valid = false
			-- new thoughts
			--[[ Get AVG position of group and max radius distance to that avg point, otherwise use disperse data to get zone area to check
            if disperse then

            else

            end
            -- ]]






			---- old
			for i = 1, 100 do
				newCoord = mist.getRandPointInCircle(point, radius, innerRadius)
				if vars.anyTerrain or mist.isTerrainValid(newCoord, validTerrain) then
					origCoord = mist.utils.deepCopy(newCoord)
					diff = { x = (newCoord.x - newGroupData.units[1].x), y = (newCoord.y - newGroupData.units[1].y) }
					valid = true
					break
				end
			end
			if valid == false then
				log:error('Point supplied in variable table is not a valid coordinate. Valid coords: $1', validTerrain)
				return false
			end
		end
		if not newGroupData.country and mist.DBs.groupsByName[newGroupData.groupName].country then
			newGroupData.country = mist.DBs.groupsByName[newGroupData.groupName].country
		end
		if not newGroupData.category and mist.DBs.groupsByName[newGroupData.groupName].category then
			newGroupData.category = mist.DBs.groupsByName[newGroupData.groupName].category
		end
		--log:info(point)
		for unitNum, unitData in pairs(newGroupData.units) do
			--log:info(unitNum)
			if disperse then
				local unitCoord
				if maxDisp and type(maxDisp) == 'number' and unitNum ~= 1 then
					for i = 1, 100 do
						unitCoord = mist.getRandPointInCircle(origCoord, maxDisp)
						if mist.isTerrainValid(unitCoord, validTerrain) == true then
							--log:warn('Index: $1, Itered: $2. AT: $3', unitNum, i, unitCoord)
							break
						end
					end

					--else
					--newCoord = mist.getRandPointInCircle(zone.point, zone.radius)
				end
				if unitNum == 1 then
					unitCoord = mist.utils.deepCopy(newCoord)
				end
				if unitCoord then
					newGroupData.units[unitNum].x = unitCoord.x
					newGroupData.units[unitNum].y = unitCoord.y
				end
			else
				newGroupData.units[unitNum].x = unitData.x + diff.x
				newGroupData.units[unitNum].y = unitData.y + diff.y
			end
			if point then
				if (newGroupData.category == 'plane' or newGroupData.category == 'helicopter') then
					if point.z and point.y > 0 and point.y > land.getHeight({ newGroupData.units[unitNum].x, newGroupData.units[unitNum].y }) + 10 then
						newGroupData.units[unitNum].alt = point.y
						--log:info('far enough from ground')
					else
						if newGroupData.category == 'plane' then
							--log:info('setNewAlt')
							newGroupData.units[unitNum].alt = land.getHeight({ newGroupData.units[unitNum].x,
								newGroupData.units[unitNum].y }) + math.random(300, 9000)
						else
							newGroupData.units[unitNum].alt = land.getHeight({ newGroupData.units[unitNum].x,
								newGroupData.units[unitNum].y }) + math.random(200, 3000)
						end
					end
				end
			end
		end

		if newGroupData.start_time then
			newGroupData.startTime = newGroupData.start_time
		end

		if newGroupData.startTime and newGroupData.startTime ~= 0 and dbData == true then
			local timeDif = timer.getAbsTime() - timer.getTime0()
			if timeDif > newGroupData.startTime then
				newGroupData.startTime = 0
			else
				newGroupData.startTime = newGroupData.startTime - timeDif
			end
		end


		local tempRoute

		if mist.DBs.MEgroupsByName[gpName] and not vars.route then
			-- log:warn('getRoute')
			tempRoute = mist.getGroupRoute(gpName, true)
		elseif vars.route then
			--  log:warn('routeExist')
			tempRoute = mist.utils.deepCopy(vars.route)
		end
		-- log:warn(tempRoute)
		if tempRoute then
			if (vars.offsetRoute or vars.offsetWP1 or vars.initTasks) then
				for i = 1, #tempRoute do
					-- log:warn(i)
					if (vars.offsetRoute) or (i == 1 and vars.offsetWP1) or (i == 1 and vars.initTasks) then
						-- log:warn('update offset')
						tempRoute[i].x = tempRoute[i].x + diff.x
						tempRoute[i].y = tempRoute[i].y + diff.y
					elseif vars.initTasks and i > 1 then
						--log:warn('deleteWP')
						tempRoute[i] = nil
					end
				end
			end
			newGroupData.route = tempRoute
		end


		--log:warn(newGroupData)
		--mist.debug.writeData(mist.utils.serialize,{'teleportToPoint', newGroupData}, 'newGroupData.lua')
		if string.lower(newGroupData.category) == 'static' then
			--log:warn(newGroupData)

			return mist.dynAddStatic(newGroupData)
		end
		return mist.dynAdd(newGroupData)
	end

	function mist.respawnInZone(gpName, zone, disperse, maxDisp, v)
		if type(gpName) == 'table' and gpName:getName() then
			gpName = gpName:getName()
		elseif type(gpName) == 'table' and gpName[1]:getName() then
			gpName = math.random(#gpName)
		else
			gpName = tostring(gpName)
		end

		if type(zone) == 'string' then
			zone = mist.DBs.zonesByName[zone]
		elseif type(zone) == 'table' and not zone.radius then
			zone = mist.DBs.zonesByName[zone[math.random(1, #zone)]]
		end
		local vars = {}
		vars.gpName = gpName
		vars.action = 'respawn'
		vars.point = zone.point
		vars.radius = zone.radius
		vars.disperse = disperse
		vars.maxDisp = maxDisp

		if v and type(v) == 'table' then
			for index, val in pairs(v) do
				vars[index] = val
			end
		end

		return mist.teleportToPoint(vars)
	end

	function mist.cloneInZone(gpName, zone, disperse, maxDisp, v)
		--log:info('cloneInZone')
		if type(gpName) == 'table' then
			gpName = gpName:getName()
		else
			gpName = tostring(gpName)
		end

		if type(zone) == 'string' then
			zone = mist.DBs.zonesByName[zone]
		elseif type(zone) == 'table' and not zone.radius then
			zone = mist.DBs.zonesByName[zone[math.random(1, #zone)]]
		end
		local vars = {}
		vars.gpName = gpName
		vars.action = 'clone'
		vars.point = zone.point
		vars.radius = zone.radius
		vars.disperse = disperse
		vars.maxDisp = maxDisp
		--log:info('do teleport')
		if v and type(v) == 'table' then
			for index, val in pairs(v) do
				vars[index] = val
			end
		end
		return mist.teleportToPoint(vars)
	end

	function mist.teleportInZone(gpName, zone, disperse, maxDisp, v) -- groupName, zoneName or table of Zone Names, keepForm is a boolean
		if type(gpName) == 'table' and gpName:getName() then
			gpName = gpName:getName()
		else
			gpName = tostring(gpName)
		end

		if type(zone) == 'string' then
			zone = mist.DBs.zonesByName[zone]
		elseif type(zone) == 'table' and not zone.radius then
			zone = mist.DBs.zonesByName[zone[math.random(1, #zone)]]
		end

		local vars = {}
		vars.gpName = gpName
		vars.action = 'tele'
		vars.point = zone.point
		vars.radius = zone.radius
		vars.disperse = disperse
		vars.maxDisp = maxDisp
		if v and type(v) == 'table' then
			for index, val in pairs(v) do
				vars[index] = val
			end
		end
		return mist.teleportToPoint(vars)
	end

	function mist.respawnGroup(gpName, task)
		local vars = {}
		vars.gpName = gpName
		vars.action = 'respawn'
		if task and type(task) ~= 'number' then
			vars.route = mist.getGroupRoute(gpName, 'task')
		end
		local newGroup = mist.teleportToPoint(vars)
		if task and type(task) == 'number' then
			local newRoute = mist.getGroupRoute(gpName, 'task')
			mist.scheduleFunction(mist.goRoute, { newGroup, newRoute }, timer.getTime() + task)
		end
		return newGroup
	end

	function mist.cloneGroup(gpName, task)
		local vars = {}
		vars.gpName = gpName
		vars.action = 'clone'
		if task and type(task) ~= 'number' then
			vars.route = mist.getGroupRoute(gpName, 'task')
		end
		local newGroup = mist.teleportToPoint(vars)
		if task and type(task) == 'number' then
			local newRoute = mist.getGroupRoute(gpName, 'task')
			mist.scheduleFunction(mist.goRoute, { newGroup, newRoute }, timer.getTime() + task)
		end
		return newGroup
	end

	function mist.teleportGroup(gpName, task)
		local vars = {}
		vars.gpName = gpName
		vars.action = 'teleport'
		if task and type(task) ~= 'number' then
			vars.route = mist.getGroupRoute(gpName, 'task')
		end
		local newGroup = mist.teleportToPoint(vars)
		if task and type(task) == 'number' then
			local newRoute = mist.getGroupRoute(gpName, 'task')
			mist.scheduleFunction(mist.goRoute, { newGroup, newRoute }, timer.getTime() + task)
		end
		return newGroup
	end

	function mist.spawnRandomizedGroup(groupName, vars) -- need to debug
		if Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
			local gpData = mist.getGroupData(groupName)
			gpData.units = mist.randomizeGroupOrder(gpData.units, vars)
			gpData.route = mist.getGroupRoute(groupName, 'task')

			mist.dynAdd(gpData)
		end

		return true
	end

	function mist.randomizeNumTable(vars)
		local newTable = {}

		local excludeIndex = {}
		local randomTable = {}

		if vars and vars.exclude and type(vars.exclude) == 'table' then
			for index, data in pairs(vars.exclude) do
				excludeIndex[data] = true
			end
		end

		local low, hi, size

		if vars.size then
			size = vars.size
		end

		if vars and vars.lowerLimit and type(vars.lowerLimit) == 'number' then
			low = mist.utils.round(vars.lowerLimit)
		else
			low = 1
		end

		if vars and vars.upperLimit and type(vars.upperLimit) == 'number' then
			hi = mist.utils.round(vars.upperLimit)
		else
			hi = size
		end

		local choices = {}
		-- add to exclude list and create list of what to randomize
		for i = 1, size do
			if not (i >= low and i <= hi) then
				excludeIndex[i] = true
			end
			if not excludeIndex[i] then
				table.insert(choices, i)
			else
				newTable[i] = i
			end
		end

		for ind, num in pairs(choices) do
			local found = false
			local x = 0
			while found == false do
				x = mist.random(size) -- get random number from list
				local addNew = true
				for index, _ in pairs(excludeIndex) do
					if index == x then
						addNew = false
						break
					end
				end
				if addNew == true then
					excludeIndex[x] = true
					found = true
				end
				excludeIndex[x] = true
			end
			newTable[num] = x
		end
		--[[
		for i = 1, #newTable do
			log:info(newTable[i])
		end
		]]
		return newTable
	end

	function mist.randomizeGroupOrder(passedUnits, vars)
		-- figure out what to exclude, and send data to other func
		local units = passedUnits

		if passedUnits.units then
			units = passUnits.units
		end

		local exclude = {}
		local excludeNum = {}
		if vars and vars.excludeType and type(vars.excludeType) == 'table' then
			exclude = vars.excludeType
		end

		if vars and vars.excludeNum and type(vars.excludeNum) == 'table' then
			excludeNum = vars.excludeNum
		end

		local low, hi

		if vars and vars.lowerLimit and type(vars.lowerLimit) == 'number' then
			low = mist.utils.round(vars.lowerLimit)
		else
			low = 1
		end

		if vars and vars.upperLimit and type(vars.upperLimit) == 'number' then
			hi = mist.utils.round(vars.upperLimit)
		else
			hi = #units
		end


		local excludeNum = {}
		for unitIndex, unitData in pairs(units) do
			if unitIndex >= low and unitIndex <= hi then -- if within range
				local found = false
				if #exclude > 0 then
					for excludeType, index in pairs(exclude) do -- check if excluded
						if mist.stringMatch(excludeType, unitData.type) then -- if excluded
							excludeNum[unitIndex] = unitIndex
							found = true
						end
					end
				end
			else -- unitIndex is either to low, or to high: added to exclude list
				excludeNum[unitIndex] = unitId
			end
		end

		local newGroup = {}
		local newOrder = mist.randomizeNumTable({ exclude = excludeNum, size = #units })

		for unitIndex, unitData in pairs(units) do
			for i = 1, #newOrder do
				if newOrder[i] == unitIndex then
					newGroup[i] = mist.utils.deepCopy(units[i]) -- gets all of the unit data
					newGroup[i].type = mist.utils.deepCopy(unitData.type)
					newGroup[i].skill = mist.utils.deepCopy(unitData.skill)
					newGroup[i].unitName = mist.utils.deepCopy(unitData.unitName)
					newGroup[i].unitIndex = mist.utils.deepCopy(unitData.unitIndex) -- replaces the units data with a new type
				end
			end
		end
		return newGroup
	end

	function mist.random(firstNum, secondNum) -- no support for decimals
		local lowNum, highNum
		if not secondNum then
			highNum = firstNum
			lowNum = 1
		else
			lowNum = firstNum
			highNum = secondNum
		end
		local total = 1
		if highNum > 50 then
			return math.random(lowNum, highNum)
		end
		if math.abs(highNum - lowNum + 1) < 50 then       -- if total values is less than 50
			total = math.modf(50 / math.abs(highNum - lowNum + 1)) -- make x copies required to be above 50
		end
		local choices = {}
		for i = 1, total do   -- iterate required number of times
			for x = lowNum, highNum do -- iterate between the range
				choices[#choices + 1] = x -- add each entry to a table
			end
		end
		local rtnVal = math.random(#choices) -- will now do a math.random of at least 50 choices
		for i = 1, 10 do
			rtnVal = math.random(#choices) -- iterate a few times for giggles
		end
		return choices[rtnVal]
	end

	function mist.stringCondense(s)
		local exclude = { '%-', '%(', '%)', '%_', '%[', '%]', '%.', '%#', '% ', '%{', '%}', '%$', '%%', '%?', '%+', '%^' }
		for i, str in pairs(exclude) do
			s = string.gsub(s, str, '')
		end
		return s
	end

	function mist.stringMatch(s1, s2, bool)
		if type(s1) == 'string' and type(s2) == 'string' then
			s1 = mist.stringCondense(s1)
			s2 = mist.stringCondense(s2)
			if not bool then
				s1 = string.lower(s1)
				s2 = string.lower(s2)
			end
			--log:info('Comparing: $1 and $2', s1, s2)
			if s1 == s2 then
				return true
			else
				return false
			end
		else
			log:error('Either the first or second variable were not a string')
			return false
		end
	end

	mist.matchString = mist.stringMatch -- both commands work because order out type of I

	--[[ scope:
{
	units = {...},	-- unit names.
	coa = {...}, -- coa names
	countries = {...}, -- country names
	CA = {...}, -- looks just like coa.
	unitTypes = { red = {}, blue = {}, all = {}, Russia = {},}
}


scope examples:

{	units = { 'Hawg11', 'Hawg12' }, CA = {'blue'} }

{ countries = {'Georgia'}, unitTypes = {blue = {'A-10C', 'A-10A'}}}

{ coa = {'all'}}

{unitTypes = { blue = {'A-10C'}}}
]]
end

--- Utility functions.
-- E.g. conversions between units etc.
-- @section mist.utils
do -- mist.util scope
	mist.utils = {}

	--- Converts angle in radians to degrees.
	-- @param angle angle in radians
	-- @return angle in degrees
	function mist.utils.toDegree(angle)
		return angle * 180 / math.pi
	end

	--- Converts angle in degrees to radians.
	-- @param angle angle in degrees
	-- @return angle in degrees
	function mist.utils.toRadian(angle)
		return angle * math.pi / 180
	end

	--- Converts meters to nautical miles.
	-- @param meters distance in meters
	-- @return distance in nautical miles
	function mist.utils.metersToNM(meters)
		return meters / 1852
	end

	--- Converts meters to feet.
	-- @param meters distance in meters
	-- @return distance in feet
	function mist.utils.metersToFeet(meters)
		return meters / 0.3048
	end

	--- Converts nautical miles to meters.
	-- @param nm distance in nautical miles
	-- @return distance in meters
	function mist.utils.NMToMeters(nm)
		return nm * 1852
	end

	--- Converts feet to meters.
	-- @param feet distance in feet
	-- @return distance in meters
	function mist.utils.feetToMeters(feet)
		return feet * 0.3048
	end

	--- Converts meters per second to knots.
	-- @param mps speed in m/s
	-- @return speed in knots
	function mist.utils.mpsToKnots(mps)
		return mps * 3600 / 1852
	end

	--- Converts meters per second to kilometers per hour.
	-- @param mps speed in m/s
	-- @return speed in km/h
	function mist.utils.mpsToKmph(mps)
		return mps * 3.6
	end

	--- Converts knots to meters per second.
	-- @param knots speed in knots
	-- @return speed in m/s
	function mist.utils.knotsToMps(knots)
		return knots * 1852 / 3600
	end

	--- Converts kilometers per hour to meters per second.
	-- @param kmph speed in km/h
	-- @return speed in m/s
	function mist.utils.kmphToMps(kmph)
		return kmph / 3.6
	end

	function mist.utils.kelvinToCelsius(t)
		return t - 273.15
	end

	function mist.utils.FahrenheitToCelsius(f)
		return (f - 32) * (5 / 9)
	end

	function mist.utils.celsiusToFahrenheit(c)
		return c * (9 / 5) + 32
	end

	function mist.utils.hexToRGB(hex, l) -- because for some reason the draw tools use hex when everything is rgba 0 - 1
		local int = 255
		if l then
			int = 1
		end
		if hex and type(hex) == 'string' then
			local val = {}
			hex = string.gsub(hex, '0x', '')
			if string.len(hex) == 8 then
				val[1] = tonumber("0x" .. hex:sub(1, 2)) / int
				val[2] = tonumber("0x" .. hex:sub(3, 4)) / int
				val[3] = tonumber("0x" .. hex:sub(5, 6)) / int
				val[4] = tonumber("0x" .. hex:sub(7, 8)) / int

				return val
			end
		end
	end

	function mist.utils.converter(t1, t2, val)
		if type(t1) == 'string' then
			t1 = string.lower(t1)
		end
		if type(t2) == 'string' then
			t2 = string.lower(t2)
		end
		if val and type(val) ~= 'number' then
			if tonumber(val) then
				val = tonumber(val)
			else
				log:warn("Value given is not a number: $1", val)
				return 0
			end
		end

		-- speed
		if t1 == 'mps' then
			if t2 == 'kmph' then
				return val * 3.6
			elseif t2 == 'knots' or t2 == 'knot' then
				return val * 3600 / 1852
			end
		elseif t1 == 'kmph' then
			if t2 == 'mps' then
				return val / 3.6
			elseif t2 == 'knots' or t2 == 'knot' then
				return val * 0.539957
			end
		elseif t1 == 'knot' or t1 == 'knots' then
			if t2 == 'kmph' then
				return val * 1.852
			elseif t2 == 'mps' then
				return val * 0.514444
			end

			-- Distance
		elseif t1 == 'feet' or t1 == 'ft' then
			if t2 == 'nm' then
				return val / 6076.12
			elseif t2 == 'km' then
				return (val * 0.3048) / 1000
			elseif t2 == 'm' then
				return val * 0.3048
			end
		elseif t1 == 'nm' then
			if t2 == 'feet' or t2 == 'ft' then
				return val * 6076.12
			elseif t2 == 'km' then
				return val * 1.852
			elseif t2 == 'm' then
				return val * 1852
			end
		elseif t1 == 'km' then
			if t2 == 'nm' then
				return val / 1.852
			elseif t2 == 'feet' or t2 == 'ft' then
				return (val / 0.3048) * 1000
			elseif t2 == 'm' then
				return val * 1000
			end
		elseif t1 == 'm' then
			if t2 == 'nm' then
				return val / 1852
			elseif t2 == 'km' then
				return val / 1000
			elseif t2 == 'feet' or t2 == 'ft' then
				return val / 0.3048
			end

			-- Temperature
		elseif t1 == 'f' or t1 == 'fahrenheit' then
			if t2 == 'c' or t2 == 'celsius' then
				return (val - 32) * (5 / 9)
			elseif t2 == 'k' or t2 == 'kelvin' then
				return (val + 459.67) * (5 / 9)
			end
		elseif t1 == 'c' or t1 == 'celsius' then
			if t2 == 'f' or t2 == 'fahrenheit' then
				return val * (9 / 5) + 32
			elseif t2 == 'k' or t2 == 'kelvin' then
				return val + 273.15
			end
		elseif t1 == 'k' or t1 == 'kelvin' then
			if t2 == 'c' or t2 == 'celsius' then
				return val - 273.15
			elseif t2 == 'f' or t2 == 'fahrenheit' then
				return ((val * (9 / 5)) - 459.67)
			end

			-- Pressure
		elseif t1 == 'p' or t1 == 'pascal' or t1 == 'pascals' then
			if t2 == 'hpa' or t2 == 'hectopascal' then
				return val / 100
			elseif t2 == 'mmhg' then
				return val * 0.00750061561303
			elseif t2 == 'inhg' then
				return val * 0.0002953
			end
		elseif t1 == 'hpa' or t1 == 'hectopascal' then
			if t2 == 'p' or t2 == 'pascal' or t2 == 'pascals' then
				return val * 100
			elseif t2 == 'mmhg' then
				return val * 0.00750061561303
			elseif t2 == 'inhg' then
				return val * 0.02953
			end
		elseif t1 == 'mmhg' then
			if t2 == 'p' or t2 == 'pascal' or t2 == 'pascals' then
				return val / 0.00750061561303
			elseif t2 == 'hpa' or t2 == 'hectopascal' then
				return val * 1.33322
			elseif t2 == 'inhg' then
				return val / 25.4
			end
		elseif t1 == 'inhg' then
			if t2 == 'p' or t2 == 'pascal' or t2 == 'pascals' then
				return val * 3386.39
			elseif t2 == 'mmhg' then
				return val * 25.4
			elseif t2 == 'hpa' or t2 == 'hectopascal' then
				return val * 33.8639
			end
		else
			log:warn("First value doesn't match with list. Value given: $1", t1)
		end
		log:warn("Match not found. Unable to convert: $1 into $2", t1, t2)
	end

	mist.converter = mist.utils.converter

	function mist.utils.getQFE(point, inchHg)
		local t, p = 0, 0
		if atmosphere.getTemperatureAndPressure then
			t, p = atmosphere.getTemperatureAndPressure(mist.utils.makeVec3GL(point))
		end
		if p == 0 then
			local h = land.getHeight(mist.utils.makeVec2(point)) / 0.3048 -- convert to feet
			if inchHg then
				return (env.mission.weather.qnh - (h / 30)) * 0.0295299830714
			else
				return env.mission.weather.qnh - (h / 30)
			end
		else
			if inchHg then
				return mist.converter('p', 'inhg', p)
			else
				return mist.converter('p', 'hpa', p)
			end
		end
	end

	--- Converts a Vec3 to a Vec2.
	-- @tparam Vec3 vec the 3D vector
	-- @return vector converted to Vec2
	function mist.utils.makeVec2(vec)
		if vec.z then
			return { x = vec.x, y = vec.z }
		else
			return { x = vec.x, y = vec.y } -- it was actually already vec2.
		end
	end

	--- Converts a Vec2 to a Vec3.
	-- @tparam Vec2 vec the 2D vector
	-- @param y optional new y axis (altitude) value. If omitted it's 0.
	function mist.utils.makeVec3(vec, y)
		if not vec.z then
			if vec.alt and not y then
				y = vec.alt
			elseif not y then
				y = 0
			end
			return { x = vec.x, y = y, z = vec.y }
		else
			return { x = vec.x, y = vec.y, z = vec.z } -- it was already Vec3, actually.
		end
	end

	--- Converts a Vec2 to a Vec3 using ground level as altitude.
	-- The ground level at the specific point is used as altitude (y-axis)
	-- for the new vector. Optionally a offset can be specified.
	-- @tparam Vec2 vec the 2D vector
	-- @param[opt] offset offset to be applied to the ground level
	-- @return new 3D vector
	function mist.utils.makeVec3GL(vec, offset)
		local adj = offset or 0

		if not vec.z then
			return { x = vec.x, y = (land.getHeight(vec) + adj), z = vec.y }
		else
			return { x = vec.x, y = (land.getHeight({ x = vec.x, y = vec.z }) + adj), z = vec.z }
		end
	end

	--- Returns the center of a zone as Vec3.
	-- @tparam string|table zone trigger zone name or table
	-- @treturn Vec3 center of the zone
	function mist.utils.zoneToVec3(zone, gl)
		local new = {}
		if type(zone) == 'table' then
			if zone.point then
				new.x = zone.point.x
				new.y = zone.point.y
				new.z = zone.point.z
			elseif zone.x and zone.y and zone.z then
				new = mist.utils.deepCopy(zone)
			end
			return new
		elseif type(zone) == 'string' then
			zone = trigger.misc.getZone(zone)
			if zone then
				new.x = zone.point.x
				new.y = zone.point.y
				new.z = zone.point.z
			end
		end
		if new.x and gl then
			new.y = land.getHeight({ x = new.x, y = new.z })
		end
		return new
	end

	function mist.utils.getHeadingPoints(point1, point2, north) -- sick of writing this out.
		if north then
			local p1 = mist.utils.makeVec3(point1)
			return mist.utils.getDir(mist.vec.sub(mist.utils.makeVec3(point2), p1), p1)
		else
			return mist.utils.getDir(mist.vec.sub(mist.utils.makeVec3(point2), mist.utils.makeVec3(point1)))
		end
	end

	--- Returns heading-error corrected direction.
	-- True-north corrected direction from point along vector vec.
	-- @tparam Vec3 vec
	-- @tparam Vec2 point
	-- @return heading-error corrected direction from point.
	function mist.utils.getDir(vec, point)
		local dir = math.atan2(vec.z, vec.x)
		if point then
			dir = dir + mist.getNorthCorrection(point)
		end
		if dir < 0 then
			dir = dir + 2 * math.pi -- put dir in range of 0 to 2*pi
		end
		return dir
	end

	--- Returns distance in meters between two points.
	-- @tparam Vec2|Vec3 point1 first point
	-- @tparam Vec2|Vec3 point2 second point
	-- @treturn number distance between given points.
	function mist.utils.get2DDist(point1, point2)
		if not point1 then
			log:warn("mist.utils.get2DDist  1st input value is nil")
		end
		if not point2 then
			log:warn("mist.utils.get2DDist  2nd input value is nil")
		end
		point1 = mist.utils.makeVec3(point1)
		point2 = mist.utils.makeVec3(point2)
		return mist.vec.mag({ x = point1.x - point2.x, y = 0, z = point1.z - point2.z })
	end

	--- Returns distance in meters between two points in 3D space.
	-- @tparam Vec3 point1 first point
	-- @tparam Vec3 point2 second point
	-- @treturn number distancen between given points in 3D space.
	function mist.utils.get3DDist(point1, point2)
		if not point1 then
			log:warn("mist.utils.get2DDist  1st input value is nil")
		end
		if not point2 then
			log:warn("mist.utils.get2DDist  2nd input value is nil")
		end
		return mist.vec.mag({ x = point1.x - point2.x, y = point1.y - point2.y, z = point1.z - point2.z })
	end

	--- Creates a waypoint from a vector.
	-- @tparam Vec2|Vec3 vec position of the new waypoint
	-- @treturn Waypoint a new waypoint to be used inside paths.
	function mist.utils.vecToWP(vec)
		local newWP = {}
		newWP.x = vec.x
		newWP.y = vec.y
		if vec.z then
			newWP.alt = vec.y
			newWP.y = vec.z
		else
			newWP.alt = land.getHeight({ x = vec.x, y = vec.y })
		end
		return newWP
	end

	--- Creates a waypoint from a unit.
	-- This function also considers the units speed.
	-- The alt_type of this waypoint is set to "BARO".
	-- @tparam Unit pUnit Unit whose position and speed will be used.
	-- @treturn Waypoint new waypoint.
	function mist.utils.unitToWP(pUnit)
		local unit = mist.utils.deepCopy(pUnit)
		if type(unit) == 'string' then
			if Unit.getByName(unit) then
				unit = Unit.getByName(unit)
			end
		end
		if unit:isExist() == true then
			local new = mist.utils.vecToWP(unit:getPosition().p)
			new.speed = mist.vec.mag(unit:getVelocity())
			new.alt_type = "BARO"

			return new
		end
		log:error("$1 not found or doesn't exist", pUnit)
		return false
	end

	--- Creates a deep copy of a object.
	-- Usually this object is a table.
	-- See also: from http://lua-users.org/wiki/CopyTable
	-- @param object object to copy
	-- @return copy of object
	function mist.utils.deepCopy(object)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for index, value in pairs(object) do
				new_table[_copy(index)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
		end
		return _copy(object)
	end

	--- Simple rounding function.
	-- From http://lua-users.org/wiki/SimpleRound
	-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
	-- @tparam number num number to round
	-- @param idp
	function mist.utils.round(num, idp)
		local mult = 10 ^ (idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	--- Rounds all numbers inside a table.
	-- @tparam table tbl table in which to round numbers
	-- @param idp
	function mist.utils.roundTbl(tbl, idp)
		for id, val in pairs(tbl) do
			if type(val) == 'number' then
				tbl[id] = mist.utils.round(val, idp)
			end
		end
		return tbl
	end

	--- Executes the given string.
	-- borrowed from Slmod
	-- @tparam string s string containing LUA code.
	-- @treturn boolean true if successfully executed, false otherwise
	function mist.utils.dostring(s)
		local f, err = loadstring(s)
		if f then
			return true, f()
		else
			return false, err
		end
	end

	--- Checks a table's types.
	-- This function checks a tables types against a specifically forged type table.
	-- @param fname
	-- @tparam table type_tbl
	-- @tparam table var_tbl
	-- @usage -- specifically forged type table
	-- type_tbl = {
	--						 {'table', 'number'},
	--						 'string',
	--						 'number',
	--						 'number',
	--						 {'string','nil'},
	--						 {'number', 'nil'}
	--					 }
	-- -- my_tbl index 1 must be a table or a number;
	-- -- index 2, a string; index 3, a number;
	-- -- index 4, a number; index 5, either a string or nil;
	-- -- and index 6, either a number or nil.
	-- mist.utils.typeCheck(type_tbl, my_tb)
	-- @return true if table passes the check, false otherwise.
	function mist.utils.typeCheck(fname, type_tbl, var_tbl)
		-- log:info('type check')
		for type_key, type_val in pairs(type_tbl) do
			-- log:info('type_key: $1 type_val: $2', type_key, type_val)

			--type_key can be a table of accepted keys- so try to find one that is not nil
			local type_key_str = ''
			local act_key =
				type_key -- actual key within var_tbl - necessary to use for multiple possible key variables.	Initialize to type_key
			if type(type_key) == 'table' then
				for i = 1, #type_key do
					if i ~= 1 then
						type_key_str = type_key_str .. '/'
					end
					type_key_str = type_key_str .. tostring(type_key[i])
					if var_tbl[type_key[i]] ~= nil then
						act_key = type_key[i] -- found a non-nil entry, make act_key now this val.
					end
				end
			else
				type_key_str = tostring(type_key)
			end

			local err_msg = 'Error in function ' .. fname .. ', parameter "' .. type_key_str .. '", expected: '
			local passed_check = false

			if type(type_tbl[type_key]) == 'table' then
				-- log:info('err_msg, before: $1', err_msg)
				for j = 1, #type_tbl[type_key] do
					if j == 1 then
						err_msg = err_msg .. type_tbl[type_key][j]
					else
						err_msg = err_msg .. ' or ' .. type_tbl[type_key][j]
					end

					if type(var_tbl[act_key]) == type_tbl[type_key][j] then
						passed_check = true
					end
				end
				-- log:info('err_msg, after: $1', err_msg)
			else
				-- log:info('err_msg, before: $1', err_msg)
				err_msg = err_msg .. type_tbl[type_key]
				-- log:info('err_msg, after: $1', err_msg)
				if type(var_tbl[act_key]) == type_tbl[type_key] then
					passed_check = true
				end
			end

			if not passed_check then
				err_msg = err_msg .. ', got ' .. type(var_tbl[act_key])
				return false, err_msg
			end
		end
		return true
	end

	--- Serializes the give variable to a string.
	-- borrowed from slmod
	-- @param var variable to serialize
	-- @treturn string variable serialized to string
	function mist.utils.basicSerialize(var)
		if var == nil then
			return "\"\""
		else
			if ((type(var) == 'number') or
					(type(var) == 'boolean') or
					(type(var) == 'function') or
					(type(var) == 'table') or
					(type(var) == 'userdata')) then
				return tostring(var)
			elseif type(var) == 'string' then
				var = string.format('%q', var)
				return var
			end
		end
	end

	--- Serialize value
	-- borrowed from slmod (serialize_slmod)
	-- @param name
	-- @param value value to serialize
	-- @param level
	function mist.utils.serialize(name, value, level)
		--Based on ED's serialize_simple2
		local function basicSerialize(o)
			if type(o) == "number" then
				return tostring(o)
			elseif type(o) == "boolean" then
				return tostring(o)
			else -- assume it is a string
				return mist.utils.basicSerialize(o)
			end
		end

		local function serializeToTbl(name, value, level)
			local var_str_tbl = {}
			if level == nil then
				level = ""
			end
			if level ~= "" then
				level = level .. ""
			end
			table.insert(var_str_tbl, level .. name .. " = ")

			if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
				table.insert(var_str_tbl, basicSerialize(value) .. ",\n")
			elseif type(value) == "table" then
				table.insert(var_str_tbl, "\n" .. level .. "{\n")

				for k, v in pairs(value) do -- serialize its fields
					local key
					if type(k) == "number" then
						key = string.format("[%s]", k)
					else
						key = string.format("[%q]", k)
					end
					table.insert(var_str_tbl, mist.utils.serialize(key, v, level .. "	"))
				end
				if level == "" then
					table.insert(var_str_tbl, level .. "} -- end of " .. name .. "\n")
				else
					table.insert(var_str_tbl, level .. "}, -- end of " .. name .. "\n")
				end
			else
				log:error('Cannot serialize a $1', type(value))
			end
			return var_str_tbl
		end

		local t_str = serializeToTbl(name, value, level)

		return table.concat(t_str)
	end

	--- Serialize value supporting cycles.
	-- borrowed from slmod (serialize_wcycles)
	-- @param name
	-- @param value value to serialize
	-- @param saved
	function mist.utils.serializeWithCycles(name, value, saved)
		--mostly straight out of Programming in Lua
		local function basicSerialize(o)
			if type(o) == "number" then
				return tostring(o)
			elseif type(o) == "boolean" then
				return tostring(o)
			else -- assume it is a string
				return mist.utils.basicSerialize(o)
			end
		end

		local t_str = {}
		saved = saved or {} -- initial value
		if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
			table.insert(t_str, name .. " = ")
			if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
				table.insert(t_str, basicSerialize(value) .. "\n")
			else
				if saved[value] then -- value already saved?
					table.insert(t_str, saved[value] .. "\n")
				else
					saved[value] = name -- save name for next time
					table.insert(t_str, "{}\n")
					for k, v in pairs(value) do -- save its fields
						local fieldname = string.format("%s[%s]", name, basicSerialize(k))
						table.insert(t_str, mist.utils.serializeWithCycles(fieldname, v, saved))
					end
				end
			end
			return table.concat(t_str)
		else
			return ""
		end
	end

	--- Serialize a table to a single line string.
	-- serialization of a table all on a single line, no comments, made to replace old get_table_string function
	-- borrowed from slmod
	-- @tparam table tbl table to serialize.
	-- @treturn string string containing serialized table
	function mist.utils.oneLineSerialize(tbl)
		if type(tbl) == 'table' then --function only works for tables!
			local tbl_str = {}

			tbl_str[#tbl_str + 1] = '{ '

			for ind, val in pairs(tbl) do -- serialize its fields
				if type(ind) == "number" then
					tbl_str[#tbl_str + 1] = '['
					tbl_str[#tbl_str + 1] = tostring(ind)
					tbl_str[#tbl_str + 1] = '] = '
				else --must be a string
					tbl_str[#tbl_str + 1] = '['
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(ind)
					tbl_str[#tbl_str + 1] = '] = '
				end

				if ((type(val) == 'number') or (type(val) == 'boolean')) then
					tbl_str[#tbl_str + 1] = tostring(val)
					tbl_str[#tbl_str + 1] = ', '
				elseif type(val) == 'string' then
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(val)
					tbl_str[#tbl_str + 1] = ', '
				elseif type(val) == 'nil' then -- won't ever happen, right?
					tbl_str[#tbl_str + 1] = 'nil, '
				elseif type(val) == 'table' then
					tbl_str[#tbl_str + 1] = mist.utils.oneLineSerialize(val)
					tbl_str[#tbl_str + 1] = ', ' --I think this is right, I just added it
				else
					log:warn('Unable to serialize value type $1 at index $2', mist.utils.basicSerialize(type(val)),
						tostring(ind))
				end
			end
			tbl_str[#tbl_str + 1] = '}'
			return table.concat(tbl_str)
		else
			return mist.utils.basicSerialize(tbl)
		end
	end

	function mist.utils.tableShowSorted(tbls, v)
		local vars = v or {}
		local loc = vars.loc or ""
		local indent = vars.indent or ""
		local tableshow_tbls = vars.tableshow_tbls or {}
		local tbl = tbls or {}

		if type(tbl) == 'table' then --function only works for tables!
			tableshow_tbls[tbl] = loc

			local tbl_str = {}

			tbl_str[#tbl_str + 1] = indent .. '{\n'

			local sorted = {}
			local function byteCompare(str1, str2)
				local shorter = string.len(str1)
				if shorter > string.len(str2) then
					shorter = string.len(str2)
				end
				for i = 1, shorter do
					local b1 = string.byte(str1, i)
					local b2 = string.byte(str2, i)

					if b1 < b2 then
						return true
					elseif b1 > b2 then
						return false
					end
				end
				return false
			end
			for ind, val in pairs(tbl) do -- serialize its fields
				local indS = tostring(ind)
				local ins = { ind = indS, val = val }
				local index
				if #sorted > 0 then
					local found = false
					for i = 1, #sorted do
						if byteCompare(indS, tostring(sorted[i].ind)) == true then
							index = i
							break
						end
					end
				end
				if index then
					table.insert(sorted, index, ins)
				else
					table.insert(sorted, ins)
				end
			end
			--log:warn(sorted)
			for i = 1, #sorted do
				local ind = sorted[i].ind
				local val = sorted[i].val

				if type(ind) == "number" then
					tbl_str[#tbl_str + 1] = indent
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = tostring(ind)
					tbl_str[#tbl_str + 1] = '] = '
				else
					tbl_str[#tbl_str + 1] = indent
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(ind)
					tbl_str[#tbl_str + 1] = '] = '
				end

				if ((type(val) == 'number') or (type(val) == 'boolean')) then
					tbl_str[#tbl_str + 1] = tostring(val)
					tbl_str[#tbl_str + 1] = ',\n'
				elseif type(val) == 'string' then
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(val)
					tbl_str[#tbl_str + 1] = ',\n'
				elseif type(val) == 'nil' then -- won't ever happen, right?
					tbl_str[#tbl_str + 1] = 'nil,\n'
				elseif type(val) == 'table' then
					if tableshow_tbls[val] then
						tbl_str[#tbl_str + 1] = ' already defined: ' .. tableshow_tbls[val] .. ',\n'
					else
						tableshow_tbls[val] = loc .. '["' .. ind .. '"]'
						--tbl_str[#tbl_str + 1] = tostring(val) .. ' '
						tbl_str[#tbl_str + 1] = mist.utils.tableShowSorted(val,
							{
								loc = loc .. '["' .. ind .. '"]',
								indent = indent .. '    ',
								tableshow_tbls =
									tableshow_tbls
							})
						tbl_str[#tbl_str + 1] = ',\n'
					end
				elseif type(val) == 'function' then
					if debug and debug.getinfo then
						local fcnname = tostring(val)
						local info = debug.getinfo(val, "S")
						if info.what == "C" then
							tbl_str[#tbl_str + 1] = ', C function\n'
						else
							if (string.sub(info.source, 1, 2) == [[./]]) then
								tbl_str[#tbl_str + 1] = string.format('%q',
										'function, defined in (' .. '-' .. info.lastlinedefined .. ')' .. info.source) ..
									',\n'
							else
								tbl_str[#tbl_str + 1] = string.format('%q',
									'function, defined in (' .. '-' .. info.lastlinedefined .. ')') .. ',\n'
							end
						end
					else
						tbl_str[#tbl_str + 1] = 'a function,\n'
					end
				else
					tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
						mist.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
				end
			end

			tbl_str[#tbl_str + 1] = indent .. '}'
			return table.concat(tbl_str)
		end
	end

	--- Returns table in a easy readable string representation.
	-- this function is not meant for serialization because it uses
	-- newlines for better readability.
	-- @param tbl table to show
	-- @param loc
	-- @param indent
	-- @param tableshow_tbls
	-- @return human readable string representation of given table
	function mist.utils.tableShow(tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
		tableshow_tbls = tableshow_tbls or {}                    --create table of tables
		loc = loc or ""
		indent = indent or ""
		if type(tbl) == 'table' then --function only works for tables!
			tableshow_tbls[tbl] = loc

			local tbl_str = {}

			tbl_str[#tbl_str + 1] = indent .. '{\n'

			for ind, val in pairs(tbl) do
				if type(ind) == "number" then
					tbl_str[#tbl_str + 1] = indent
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = tostring(ind)
					tbl_str[#tbl_str + 1] = '] = '
				else
					tbl_str[#tbl_str + 1] = indent
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(ind)
					tbl_str[#tbl_str + 1] = '] = '
				end

				if ((type(val) == 'number') or (type(val) == 'boolean')) then
					tbl_str[#tbl_str + 1] = tostring(val)
					tbl_str[#tbl_str + 1] = ',\n'
				elseif type(val) == 'string' then
					tbl_str[#tbl_str + 1] = mist.utils.basicSerialize(val)
					tbl_str[#tbl_str + 1] = ',\n'
				elseif type(val) == 'nil' then -- won't ever happen, right?
					tbl_str[#tbl_str + 1] = 'nil,\n'
				elseif type(val) == 'table' then
					if tableshow_tbls[val] then
						tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
					else
						tableshow_tbls[val] = loc .. '[' .. mist.utils.basicSerialize(ind) .. ']'
						tbl_str[#tbl_str + 1] = tostring(val) .. ' '
						tbl_str[#tbl_str + 1] = mist.utils.tableShow(val,
							loc .. '[' .. mist.utils.basicSerialize(ind) .. ']', indent .. '    ', tableshow_tbls)
						tbl_str[#tbl_str + 1] = ',\n'
					end
				elseif type(val) == 'function' then
					if debug and debug.getinfo then
						local fcnname = tostring(val)
						local info = debug.getinfo(val, "S")
						if info.what == "C" then
							tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
						else
							if (string.sub(info.source, 1, 2) == [[./]]) then
								tbl_str[#tbl_str + 1] = string.format('%q',
									fcnname ..
									', defined in (' ..
									info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) .. ',\n'
							else
								tbl_str[#tbl_str + 1] = string.format('%q',
										fcnname ..
										', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..
									',\n'
							end
						end
					else
						tbl_str[#tbl_str + 1] = 'a function,\n'
					end
				else
					tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
						mist.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
				end
			end

			tbl_str[#tbl_str + 1] = indent .. '}'
			return table.concat(tbl_str)
		end
	end
end

--- Debug functions
-- @section mist.debug
do -- mist.debug scope
	mist.debug = {}

	function mist.debug.changeSetting(s)
		if type(s) == 'table' then
			for sName, sVal in pairs(s) do
				if type(sVal) == 'string' or type(sVal) == 'number' then
					if sName == 'log' then
						mistSettings[sName] = sVal
						mist.log:setLevel(sVal)
					elseif sName == 'dbLog' then
						mistSettings[sName] = sVal
						dblog:setLevel(sVal)
					end
				else
					mistSettings[sName] = sVal
				end
			end
		end
	end

	--- Dumps the global table _G.
	-- This dumps the global table _G to a file in
	-- the DCS\Logs directory.
	-- This function requires you to disable script sanitization
	-- in $DCS_ROOT\Scripts\MissionScripting.lua to access lfs and io
	-- libraries.
	-- @param fname
	function mist.debug.dump_G(fname, simp)
		if lfs and io then
			local fdir = lfs.writedir() .. [[Logs\]] .. fname
			local f = io.open(fdir, 'w')
			if simp then
				local g = mist.utils.deepCopy(_G)
				g.mist = nil
				g.slmod = nil
				g.env.mission = nil
				g.env.warehouses = nil
				g.country.by_idx = nil
				g.country.by_country = nil

				f:write(mist.utils.tableShowSorted(g))
			else
				f:write(mist.utils.tableShowSorted(_G))
			end
			f:close()
			log:info('Wrote debug data to $1', fdir)
			--trigger.action.outText(errmsg, 10)
		else
			log:alert(
				'insufficient libraries to run mist.debug.dump_G, you must disable the sanitization of the io and lfs libraries in ./Scripts/MissionScripting.lua')
			--trigger.action.outText(errmsg, 10)
		end
	end

	--- Write debug data to file.
	-- This function requires you to disable script sanitization
	-- in $DCS_ROOT\Scripts\MissionScripting.lua to access lfs and io
	-- libraries.
	-- @param fcn
	-- @param fcnVars
	-- @param fname
	function mist.debug.writeData(fcn, fcnVars, fname)
		if lfs and io then
			local fdir = lfs.writedir() .. [[Logs\]] .. fname
			local f = io.open(fdir, 'w')
			f:write(fcn(unpack(fcnVars, 1, table.maxn(fcnVars))))
			f:close()
			log:info('Wrote debug data to $1', fdir)
			local errmsg = 'mist.debug.writeData wrote data to ' .. fdir
			trigger.action.outText(errmsg, 10)
		else
			local errmsg =
			'Error: insufficient libraries to run mist.debug.writeData, you must disable the sanitization of the io and lfs libraries in ./Scripts/MissionScripting.lua'
			log:alert(errmsg)
			trigger.action.outText(errmsg, 10)
		end
	end

	--- Write mist databases to file.
	-- This function requires you to disable script sanitization
	-- in $DCS_ROOT\Scripts\MissionScripting.lua to access lfs and io
	-- libraries.
	function mist.debug.dumpDBs()
		for DBname, DB in pairs(mist.DBs) do
			if type(DB) == 'table' and type(DBname) == 'string' then
				mist.debug.writeData(mist.utils.serialize, { DBname, DB }, 'mist_DBs_' .. DBname .. '.lua')
			end
		end
	end

	-- write group table
	function mist.debug.writeGroup(gName, data)
		if gName and mist.DBs.groupsByName[gName] then
			local dat
			if data then
				dat = mist.getGroupData(gName)
			else
				dat = mist.getGroupTable(gName)
			end
			if dat then
				dat.route = { points = mist.getGroupRoute(gName, true) }
			end

			if io and lfs and dat then
				mist.debug.writeData(mist.utils.serialize, { gName, dat }, gName .. '_table.lua')
			else
				if dat then
					trigger.action.outText(
						'Error: insufficient libraries to run mist.debug.writeGroup, you must disable the sanitization of the io and lfs libraries in ./Scripts/MissionScripting.lua \nGroup table written to DCS.log file instead.',
						10)
					log:warn('$1 dataTable: $2', gName, dat)
				else
					trigger.action.outText(
						'Unable to write group table for: ' ..
						gName ..
						'\n Error: insufficient libraries to run mist.debug.writeGroup, you must disable the sanitization of the io and lfs libraries in ./Scripts/MissionScripting.lua',
						10)
				end
			end
		end
	end

	-- write all object types in mission.
	function mist.debug.writeTypes(fName)
		local wt = 'mistDebugWriteTypes.lua'
		if fName and type(fName) == 'string' and string.find(fName, '.lua') then
			wt = fName
		end
		local output = { units = {}, countries = {} }
		for coa_name_miz, coa_data in pairs(env.mission.coalition) do
			if type(coa_data) == 'table' then
				if coa_data.country then --there is a country table
					for cntry_id, cntry_data in pairs(coa_data.country) do
						local countryName = string.lower(cntry_data.name)
						if cntry_data.id and country.names[cntry_data.id] then
							countryName = string.lower(country.names[cntry_data.id])
						end
						output.countries[countryName] = {}
						if type(cntry_data) == 'table' then                                                                                                --just making sure
							for obj_cat_name, obj_cat_data in pairs(cntry_data) do
								if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then --should be an unncessary check
									local category = obj_cat_name
									if not output.countries[countryName][category] then
										-- log:warn('Create: $1', category)
										output.countries[countryName][category] = {}
									end
									if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
										for group_num, group_data in pairs(obj_cat_data.group) do
											if group_data and group_data.units and type(group_data.units) == 'table' then                         --making sure again- this is a valid group
												for i = 1, #group_data.units do
													if group_data.units[i] then
														local u = group_data.units[i]
														local liv = u.livery_id or 'default'
														if not output.units[u.type] then -- create unit table
															-- log:warn('Create: $1', u.type)
															output.units[u.type] = { count = 0, livery_id = {} }
														end

														if not output.countries[countryName][category][u.type] then
															-- log:warn('Create country, category, unit: $1', u.type)
															output.countries[countryName][category][u.type] = 0
														end
														-- add to count
														output.countries[countryName][category][u.type] = output
															.countries[countryName][category][u.type] + 1
														output.units[u.type].count = output.units[u.type].count + 1

														if liv and not output.units[u.type].livery_id[countryName] then
															-- log:warn('Create livery country: $1', countryName)
															output.units[u.type].livery_id[countryName] = {}
														end
														if liv and not output.units[u.type].livery_id[countryName][liv] then
															--log:warn('Create Livery: $1', liv)
															output.units[u.type].livery_id[countryName][liv] = 0
														end
														if liv then
															output.units[u.type].livery_id[countryName][liv] = output
																.units[u.type].livery_id[countryName][liv] + 1
														end
														if u.payload and u.payload.pylons then
															if not output.units[u.type].CLSID then
																output.units[u.type].CLSID = {}
																output.units[u.type].pylons = {}
															end

															for pyIndex, pData in pairs(u.payload.pylons) do
																if not output.units[u.type].CLSID[pData.CLSID] then
																	output.units[u.type].CLSID[pData.CLSID] = 0
																end
																output.units[u.type].CLSID[pData.CLSID] = output.units
																	[u.type].CLSID[pData.CLSID] + 1

																if not output.units[u.type].pylons[pyIndex] then
																	output.units[u.type].pylons[pyIndex] = {}
																end
																if not output.units[u.type].pylons[pyIndex][pData.CLSID] then
																	output.units[u.type].pylons[pyIndex][pData.CLSID] = 0
																end
																output.units[u.type].pylons[pyIndex][pData.CLSID] =
																	output.units[u.type].pylons[pyIndex][pData.CLSID] + 1
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if io and lfs then
			mist.debug.writeData(mist.utils.serialize, { 'mistDebugWriteTypes', output }, wt)
		else
			trigger.action.outText(
				'Error: insufficient libraries to run mist.debug.writeTypes, you must disable the sanitization of the io and lfs libraries in ./Scripts/MissionScripting.lua \n writeTypes table written to DCS.log file instead.',
				10)
			log:warn('mist.debug.writeTypes: $1', output)
		end
		return output
	end

	function mist.debug.writeWeapons(unit)

	end

	function mist.debug.mark(msg, coord)
		mist.marker.add({ point = coord, text = msg })
		log:warn('debug.mark: $1    $2', msg, coord)
	end
end

--- 3D Vector functions
-- @section mist.vec
do -- mist.vec scope
	mist.vec = {}

	--- Vector addition.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, sum of vec1 and vec2.
	function mist.vec.add(vec1, vec2)
		return { x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z }
	end

	--- Vector substraction.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, vec2 substracted from vec1.
	function mist.vec.sub(vec1, vec2)
		return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
	end

	--- Vector scalar multiplication.
	-- @tparam Vec3 vec vector to multiply
	-- @tparam number mult scalar multiplicator
	-- @treturn Vec3 new vector multiplied with the given scalar
	function mist.vec.scalarMult(vec, mult)
		return { x = vec.x * mult, y = vec.y * mult, z = vec.z * mult }
	end

	mist.vec.scalar_mult = mist.vec.scalarMult

	--- Vector dot product.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn number dot product of given vectors
	function mist.vec.dp(vec1, vec2)
		return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
	end

	--- Vector cross product.
	-- @tparam Vec3 vec1 first vector
	-- @tparam Vec3 vec2 second vector
	-- @treturn Vec3 new vector, cross product of vec1 and vec2.
	function mist.vec.cp(vec1, vec2)
		return {
			x = vec1.y * vec2.z - vec1.z * vec2.y,
			y = vec1.z * vec2.x - vec1.x * vec2.z,
			z = vec1.x * vec2.y -
				vec1.y * vec2.x
		}
	end

	--- Vector magnitude
	-- @tparam Vec3 vec vector
	-- @treturn number magnitude of vector vec
	function mist.vec.mag(vec)
		return (vec.x ^ 2 + vec.y ^ 2 + vec.z ^ 2) ^ 0.5
	end

	--- Unit vector
	-- @tparam Vec3 vec
	-- @treturn Vec3 unit vector of vec
	function mist.vec.getUnitVec(vec)
		local mag = mist.vec.mag(vec)
		return { x = vec.x / mag, y = vec.y / mag, z = vec.z / mag }
	end

	--- Rotate vector.
	-- @tparam Vec2 vec2 to rotoate
	-- @tparam number theta
	-- @return Vec2 rotated vector.
	function mist.vec.rotateVec2(vec2, theta)
		return {
			x = vec2.x * math.cos(theta) - vec2.y * math.sin(theta),
			y = vec2.x * math.sin(theta) +
				vec2.y * math.cos(theta)
		}
	end

	function mist.vec.normalize(vec3)
		local mag = mist.vec.mag(vec3)
		if mag ~= 0 then
			return mist.vec.scalar_mult(vec3, 1.0 / mag)
		end
	end
end

--- Flag functions.
-- The mist "Flag functions" are functions that are similar to Slmod functions
-- that detect a game condition and set a flag when that game condition is met.
--
-- They are intended to be used by persons with little or no experience in Lua
-- programming, but with a good knowledge of the DCS mission editor.
-- @section mist.flagFunc
do -- mist.flagFunc scope
	mist.flagFunc = {}

	--- Sets a flag if map objects are destroyed inside a zone.
	-- Once this function is run, it will start a continuously evaluated process
	-- that will set a flag true if map objects (such as bridges, buildings in
	-- town, etc.) die (or have died) in a mission editor zone (or set of zones).
	-- This will only happen once; once the flag is set true, the process ends.
	-- @usage
	-- -- Example vars table
	-- vars = {
	--	 zones = { "zone1", "zone2" }, -- can also be a single string
	--	 flag = 3, -- number of the flag
	--	 stopflag = 4, -- optional number of the stop flag
	--	 req_num = 10, -- optional minimum amount of map objects needed to die
	-- }
	-- mist.flagFuncs.mapobjs_dead_zones(vars)
	-- @tparam table vars table containing parameters.
	function mist.flagFunc.mapobjs_dead_zones(vars)
		--[[vars needs to be:
zones = table or string,
flag = number,
stopflag = number or nil,
req_num = number or nil

AND used by function,
initial_number

]]
		-- type_tbl
		local type_tbl = {
			[{ 'zones', 'zone' }] = { 'table', 'string' },
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.mapobjs_dead_zones', type_tbl, vars)
		assert(err, errmsg)
		local zones = vars.zones or vars.zone
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local req_num = vars.req_num or vars.reqnum or 1
		local initial_number = vars.initial_number

		if type(zones) == 'string' then
			zones = { zones }
		end

		if not initial_number then
			initial_number = #mist.getDeadMapObjsInZones(zones)
		end

		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if (#mist.getDeadMapObjsInZones(zones) - initial_number) >= req_num and trigger.misc.getUserFlag(flag) == 0 then
				trigger.action.setUserFlag(flag, true)
				return
			else
				mist.scheduleFunction(mist.flagFunc.mapobjs_dead_zones,
					{ { zones = zones, flag = flag, stopflag = stopflag, req_num = req_num, initial_number = initial_number } },
					timer.getTime() + 1)
			end
		end
	end

	--- Sets a flag if map objects are destroyed inside a polygon.
	-- Once this function is run, it will start a continuously evaluated process
	-- that will set a flag true if map objects (such as bridges, buildings in
	-- town, etc.) die (or have died) in a polygon.
	-- This will only happen once; once the flag is set true, the process ends.
	-- @usage
	-- -- Example vars table
	-- vars = {
	--	 zone = {
	--		 [1] = mist.DBs.unitsByName['NE corner'].point,
	--		 [2] = mist.DBs.unitsByName['SE corner'].point,
	--		 [3] = mist.DBs.unitsByName['SW corner'].point,
	--		 [4] = mist.DBs.unitsByName['NW corner'].point
	--	 }
	--	 flag = 3, -- number of the flag
	--	 stopflag = 4, -- optional number of the stop flag
	--	 req_num = 10, -- optional minimum amount of map objects needed to die
	-- }
	-- mist.flagFuncs.mapobjs_dead_zones(vars)
	-- @tparam table vars table containing parameters.
	function mist.flagFunc.mapobjs_dead_polygon(vars)
		--[[vars needs to be:
zone = table,
flag = number,
stopflag = number or nil,
req_num = number or nil

AND used by function,
initial_number

]]
		-- type_tbl
		local type_tbl = {
			[{ 'zone', 'polyzone' }] = 'table',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.mapobjs_dead_polygon', type_tbl, vars)
		assert(err, errmsg)
		local zone = vars.zone or vars.polyzone
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local req_num = vars.req_num or vars.reqnum or 1
		local initial_number = vars.initial_number

		if not initial_number then
			initial_number = #mist.getDeadMapObjsInPolygonZone(zone)
		end

		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if (#mist.getDeadMapObjsInPolygonZone(zone) - initial_number) >= req_num and trigger.misc.getUserFlag(flag) == 0 then
				trigger.action.setUserFlag(flag, true)
				return
			else
				mist.scheduleFunction(mist.flagFunc.mapobjs_dead_polygon,
					{ { zone = zone, flag = flag, stopflag = stopflag, req_num = req_num, initial_number = initial_number } },
					timer.getTime() + 1)
			end
		end
	end

	--- Sets a flag if unit(s) is/are inside a polygon.
	-- @tparam table vars @{unitsInPolygonVars}
	-- @usage -- set flag 11 to true as soon as any blue vehicles
	-- -- are inside the polygon shape created off of the waypoints
	-- -- of the group forest1
	-- mist.flagFunc.units_in_polygon {
	--		units = {'[blue][vehicle]'},
	--		zone = mist.getGroupPoints('forest1'),
	--		flag = 11
	-- }
	function mist.flagFunc.units_in_polygon(vars)
		--[[vars needs to be:
units = table,
zone = table,
flag = number,
stopflag = number or nil,
maxalt = number or nil,
interval	= number or nil,
req_num = number or nil
toggle = boolean or nil
unitTableDef = table or nil
]]
		-- type_tbl
		local type_tbl = {
			[{ 'units', 'unit' }] = 'table',
			[{ 'zone', 'polyzone' }] = 'table',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'maxalt', 'alt' }] = { 'number', 'nil' },
			interval = { 'number', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
			unitTableDef = { 'table', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.units_in_polygon', type_tbl, vars)
		assert(err, errmsg)
		local units = vars.units or vars.unit
		local zone = vars.zone or vars.polyzone
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local maxalt = vars.maxalt or vars.alt
		local req_num = vars.req_num or vars.reqnum or 1
		local toggle = vars.toggle or nil
		local unitTableDef = vars.unitTableDef

		if not units.processed then
			unitTableDef = mist.utils.deepCopy(units)
		end

		if (units.processed and units.processed < mist.getLastDBUpdateTime()) or not units.processed then -- run unit table short cuts
			if unitTableDef then
				units = mist.makeUnitTable(unitTableDef)
			end
		end

		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == 0) then
			local num_in_zone = 0
			for i = 1, #units do
				local unit = Unit.getByName(units[i]) or StaticObject.getByName(units[i])
				if unit and unit:isExist() == true then
					local pos = unit:getPosition().p
					if mist.pointInPolygon(pos, zone, maxalt) then
						num_in_zone = num_in_zone + 1
						if num_in_zone >= req_num and trigger.misc.getUserFlag(flag) == 0 then
							trigger.action.setUserFlag(flag, true)
							break
						end
					end
				end
			end
			if toggle and (num_in_zone < req_num) and trigger.misc.getUserFlag(flag) > 0 then
				trigger.action.setUserFlag(flag, false)
			end
			-- do another check in case stopflag was set true by this function
			if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == 0) then
				mist.scheduleFunction(mist.flagFunc.units_in_polygon,
					{ { units = units, zone = zone, flag = flag, stopflag = stopflag, interval = interval, req_num = req_num, maxalt = maxalt, toggle = toggle, unitTableDef = unitTableDef } },
					timer.getTime() + interval)
			end
		end
	end

	--- Sets a flag if unit(s) is/are inside a trigger zone.
	-- @todo document
	function mist.flagFunc.units_in_zones(vars)
		--[[vars needs to be:
	units = table,
	zones = table,
	flag = number,
	stopflag = number or nil,
	zone_type = string or nil,
	req_num = number or nil,
	interval	= number or nil
	toggle = boolean or nil
	]]
		-- type_tbl
		local type_tbl = {
			units = 'table',
			zones = 'table',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'zone_type', 'zonetype' }] = { 'string', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
			unitTableDef = { 'table', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.units_in_zones', type_tbl, vars)
		assert(err, errmsg)
		local units = vars.units
		local zones = vars.zones
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local zone_type = vars.zone_type or vars.zonetype or 'cylinder'
		local req_num = vars.req_num or vars.reqnum or 1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil
		local unitTableDef = vars.unitTableDef

		if not units.processed then
			unitTableDef = mist.utils.deepCopy(units)
		end

		if (units.processed and units.processed < mist.getLastDBUpdateTime()) or not units.processed then -- run unit table short cuts
			if unitTableDef then
				units = mist.makeUnitTable(unitTableDef)
			end
		end

		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			local in_zone_units = mist.getUnitsInZones(units, zones, zone_type)

			if #in_zone_units >= req_num and trigger.misc.getUserFlag(flag) == 0 then
				trigger.action.setUserFlag(flag, true)
			elseif #in_zone_units < req_num and toggle then
				trigger.action.setUserFlag(flag, false)
			end
			-- do another check in case stopflag was set true by this function
			if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
				mist.scheduleFunction(mist.flagFunc.units_in_zones,
					{ { units = units, zones = zones, flag = flag, stopflag = stopflag, zone_type = zone_type, req_num = req_num, interval = interval, toggle = toggle, unitTableDef = unitTableDef } },
					timer.getTime() + interval)
			end
		end
	end

	--[[
    function mist.flagFunc.weapon_in_zones(vars)
        -- borrow from suchoi surprise. While running enabled event handler that checks for weapons in zone.
        -- Choice is weapon category or weapon strings.

    end
]]
	--- Sets a flag if unit(s) is/are inside a moving zone.
	-- @todo document
	function mist.flagFunc.units_in_moving_zones(vars)
		--[[vars needs to be:
	units = table,
	zone_units = table,
	radius = number,
	flag = number,
	stopflag = number or nil,
	zone_type = string or nil,
	req_num = number or nil,
	interval	= number or nil
	toggle = boolean or nil
	]]
		-- type_tbl
		local type_tbl = {
			units = 'table',
			[{ 'zone_units', 'zoneunits' }] = 'table',
			radius = 'number',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'zone_type', 'zonetype' }] = { 'string', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
			unitTableDef = { 'table', 'nil' },
			zUnitTableDef = { 'table', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.units_in_moving_zones', type_tbl, vars)
		assert(err, errmsg)
		local units = vars.units
		local zone_units = vars.zone_units or vars.zoneunits
		local radius = vars.radius
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local zone_type = vars.zone_type or vars.zonetype or 'cylinder'
		local req_num = vars.req_num or vars.reqnum or 1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil
		local unitTableDef = vars.unitTableDef
		local zUnitTableDef = vars.zUnitTableDef

		if not units.processed then
			unitTableDef = mist.utils.deepCopy(units)
		end

		if not zone_units.processed then
			zUnitTableDef = mist.utils.deepCopy(zone_units)
		end

		if (units.processed and units.processed < mist.getLastDBUpdateTime()) or not units.processed then -- run unit table short cuts
			if unitTableDef then
				units = mist.makeUnitTable(unitTableDef)
			end
		end

		if (zone_units.processed and zone_units.processed < mist.getLastDBUpdateTime()) or not zone_units.processed then -- run unit table short cuts
			if zUnitTableDef then
				zone_units = mist.makeUnitTable(zUnitTableDef)
			end
		end

		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			local in_zone_units = mist.getUnitsInMovingZones(units, zone_units, radius, zone_type)

			if #in_zone_units >= req_num and trigger.misc.getUserFlag(flag) == 0 then
				trigger.action.setUserFlag(flag, true)
			elseif #in_zone_units < req_num and toggle then
				trigger.action.setUserFlag(flag, false)
			end
			-- do another check in case stopflag was set true by this function
			if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
				mist.scheduleFunction(mist.flagFunc.units_in_moving_zones,
					{ { units = units, zone_units = zone_units, radius = radius, flag = flag, stopflag = stopflag, zone_type = zone_type, req_num = req_num, interval = interval, toggle = toggle, unitTableDef = unitTableDef, zUnitTableDef = zUnitTableDef } },
					timer.getTime() + interval)
			end
		end
	end

	--- Sets a flag if units have line of sight to each other.
	-- @todo document
	function mist.flagFunc.units_LOS(vars)
		--[[vars needs to be:
unitset1 = table,
altoffset1 = number,
unitset2 = table,
altoffset2 = number,
flag = number,
stopflag = number or nil,
radius = number or nil,
interval	= number or nil,
req_num = number or nil
toggle = boolean or nil
]]
		-- type_tbl
		local type_tbl = {
			[{ 'unitset1', 'units1' }] = 'table',
			[{ 'altoffset1', 'alt1' }] = 'number',
			[{ 'unitset2', 'units2' }] = 'table',
			[{ 'altoffset2', 'alt2' }] = 'number',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			[{ 'req_num', 'reqnum' }] = { 'number', 'nil' },
			interval = { 'number', 'nil' },
			radius = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
			unitTableDef1 = { 'table', 'nil' },
			unitTableDef2 = { 'table', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.units_LOS', type_tbl, vars)
		assert(err, errmsg)
		local unitset1 = vars.unitset1 or vars.units1
		local altoffset1 = vars.altoffset1 or vars.alt1
		local unitset2 = vars.unitset2 or vars.units2
		local altoffset2 = vars.altoffset2 or vars.alt2
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local radius = vars.radius or math.huge
		local req_num = vars.req_num or vars.reqnum or 1
		local toggle = vars.toggle or nil
		local unitTableDef1 = vars.unitTableDef1
		local unitTableDef2 = vars.unitTableDef2

		if not unitset1.processed then
			unitTableDef1 = mist.utils.deepCopy(unitset1)
		end

		if not unitset2.processed then
			unitTableDef2 = mist.utils.deepCopy(unitset2)
		end

		if (unitset1.processed and unitset1.processed < mist.getLastDBUpdateTime()) or not unitset1.processed then -- run unit table short cuts
			if unitTableDef1 then
				unitset1 = mist.makeUnitTable(unitTableDef1)
			end
		end

		if (unitset2.processed and unitset2.processed < mist.getLastDBUpdateTime()) or not unitset2.processed then -- run unit table short cuts
			if unitTableDef2 then
				unitset2 = mist.makeUnitTable(unitTableDef2)
			end
		end


		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			local unitLOSdata = mist.getUnitsLOS(unitset1, altoffset1, unitset2, altoffset2, radius)

			if #unitLOSdata >= req_num and trigger.misc.getUserFlag(flag) == 0 then
				trigger.action.setUserFlag(flag, true)
			elseif #unitLOSdata < req_num and toggle then
				trigger.action.setUserFlag(flag, false)
			end
			-- do another check in case stopflag was set true by this function
			if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
				mist.scheduleFunction(mist.flagFunc.units_LOS,
					{ { unitset1 = unitset1, altoffset1 = altoffset1, unitset2 = unitset2, altoffset2 = altoffset2, flag = flag, stopflag = stopflag, radius = radius, req_num = req_num, interval = interval, toggle = toggle, unitTableDef1 = unitTableDef1, unitTableDef2 = unitTableDef2 } },
					timer.getTime() + interval)
			end
		end
	end

	--- Sets a flag if group is alive.
	-- @todo document
	function mist.flagFunc.group_alive(vars)
		--[[vars
groupName
flag
toggle
interval
stopFlag

]]
		local type_tbl = {
			[{ 'group', 'groupname', 'gp', 'groupName' }] = 'string',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.group_alive', type_tbl, vars)
		assert(err, errmsg)

		local groupName = vars.groupName or vars.group or vars.gp or vars.Groupname
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil


		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if Group.getByName(groupName) and Group.getByName(groupName):isExist() == true and #Group.getByName(groupName):getUnits() > 0 then
				if trigger.misc.getUserFlag(flag) == 0 then
					trigger.action.setUserFlag(flag, true)
				end
			else
				if toggle then
					trigger.action.setUserFlag(flag, false)
				end
			end
		end

		if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			mist.scheduleFunction(mist.flagFunc.group_alive,
				{ { groupName = groupName, flag = flag, stopflag = stopflag, interval = interval, toggle = toggle } },
				timer.getTime() + interval)
		end
	end

	--- Sets a flag if group is dead.
	-- @todo document
	function mist.flagFunc.group_dead(vars)
		local type_tbl = {
			[{ 'group', 'groupname', 'gp', 'groupName' }] = 'string',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.group_dead', type_tbl, vars)
		assert(err, errmsg)

		local groupName = vars.groupName or vars.group or vars.gp or vars.Groupname
		local flag = vars.flag
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil


		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if (Group.getByName(groupName) and Group.getByName(groupName):isExist() == false) or (Group.getByName(groupName) and #Group.getByName(groupName):getUnits() < 1) or not Group.getByName(groupName) then
				if trigger.misc.getUserFlag(flag) == 0 then
					trigger.action.setUserFlag(flag, true)
				end
			else
				if toggle then
					trigger.action.setUserFlag(flag, false)
				end
			end
		end

		if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			mist.scheduleFunction(mist.flagFunc.group_dead,
				{ { groupName = groupName, flag = flag, stopflag = stopflag, interval = interval, toggle = toggle } },
				timer.getTime() + interval)
		end
	end

	--- Sets a flag if less than given percent of group is alive.
	-- @todo document
	function mist.flagFunc.group_alive_less_than(vars)
		local type_tbl = {
			[{ 'group', 'groupname', 'gp', 'groupName' }] = 'string',
			percent = 'number',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.group_alive_less_than', type_tbl, vars)
		assert(err, errmsg)

		local groupName = vars.groupName or vars.group or vars.gp or vars.Groupname
		local flag = vars.flag
		local percent = vars.percent
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil


		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
				if Group.getByName(groupName):getSize() / Group.getByName(groupName):getInitialSize() < percent / 100 then
					if trigger.misc.getUserFlag(flag) == 0 then
						trigger.action.setUserFlag(flag, true)
					end
				else
					if toggle then
						trigger.action.setUserFlag(flag, false)
					end
				end
			else
				if trigger.misc.getUserFlag(flag) == 0 then
					trigger.action.setUserFlag(flag, true)
				end
			end
		end

		if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			mist.scheduleFunction(mist.flagFunc.group_alive_less_than,
				{ { groupName = groupName, flag = flag, stopflag = stopflag, interval = interval, toggle = toggle, percent = percent } },
				timer.getTime() + interval)
		end
	end

	--- Sets a flag if more than given percent of group is alive.
	-- @todo document
	function mist.flagFunc.group_alive_more_than(vars)
		local type_tbl = {
			[{ 'group', 'groupname', 'gp', 'groupName' }] = 'string',
			percent = 'number',
			flag = { 'number', 'string' },
			[{ 'stopflag', 'stopFlag' }] = { 'number', 'string', 'nil' },
			interval = { 'number', 'nil' },
			toggle = { 'boolean', 'nil' },
		}

		local err, errmsg = mist.utils.typeCheck('mist.flagFunc.group_alive_more_than', type_tbl, vars)
		assert(err, errmsg)

		local groupName = vars.groupName or vars.group or vars.gp or vars.Groupname
		local flag = vars.flag
		local percent = vars.percent
		local stopflag = vars.stopflag or vars.stopFlag or -1
		local interval = vars.interval or 1
		local toggle = vars.toggle or nil


		if stopflag == -1 or (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			if Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
				if Group.getByName(groupName):getSize() / Group.getByName(groupName):getInitialSize() > percent / 100 then
					if trigger.misc.getUserFlag(flag) == 0 then
						trigger.action.setUserFlag(flag, true)
					end
				else
					if toggle and trigger.misc.getUserFlag(flag) == 1 then
						trigger.action.setUserFlag(flag, false)
					end
				end
			else --- just in case
				if toggle and trigger.misc.getUserFlag(flag) == 1 then
					trigger.action.setUserFlag(flag, false)
				end
			end
		end

		if (type(trigger.misc.getUserFlag(stopflag)) == 'number' and trigger.misc.getUserFlag(stopflag) == 0) or (type(trigger.misc.getUserFlag(stopflag)) == 'boolean' and trigger.misc.getUserFlag(stopflag) == false) then
			mist.scheduleFunction(mist.flagFunc.group_alive_more_than,
				{ { groupName = groupName, flag = flag, stopflag = stopflag, interval = interval, toggle = toggle, percent = percent } },
				timer.getTime() + interval)
		end
	end

	mist.flagFunc.mapobjsDeadPolygon = mist.flagFunc.mapobjs_dead_polygon
	mist.flagFunc.mapobjsDeadZones = mist.flagFunc.Mapobjs_dead_zones
	mist.flagFunc.unitsInZones = mist.flagFunc.units_in_zones
	mist.flagFunc.unitsInMovingZones = mist.flagFunc.units_in_moving_zones
	mist.flagFunc.unitsInPolygon = mist.flagFunc.units_in_polygon
	mist.flagFunc.unitsLOS = mist.flagFunc.units_LOS
	mist.flagFunc.groupAlive = mist.flagFunc.group_alive
	mist.flagFunc.groupDead = mist.flagFunc.group_dead
	mist.flagFunc.groupAliveMoreThan = mist.flagFunc.group_alive_more_than
	mist.flagFunc.groupAliveLessThan = mist.flagFunc.group_alive_less_than
end

--- Message functions.
-- Messaging system
-- @section mist.msg
do -- mist.msg scope
	local messageList = {}
	-- this defines the max refresh rate of the message box it honestly only needs to
	-- go faster than this for precision timing stuff (which could be its own function)
	local messageDisplayRate = 0.1
	local messageID = 0
	local displayActive = false
	local displayFuncId = 0

	local caSlots = false
	local caMSGtoGroup = false
	local anyUpdate = false
	local anySound = false
	local lastMessageTime = math.huge

	if env.mission.groundControl then -- just to be sure?
		for index, value in pairs(env.mission.groundControl) do
			if type(value) == 'table' then
				for roleName, roleVal in pairs(value) do
					for rIndex, rVal in pairs(roleVal) do
						if type(rVal) == 'number' and rVal > 0 then
							caSlots = true
							break
						end
					end
				end
			elseif type(value) == 'boolean' and value == true then
				caSlots = true
				break
			end
		end
	end

	local function mistdisplayV5()
		log:warn("mistdisplayV5: $1", timer.getTime())

		local clearView = true
		if #messageList > 0 then
			log:warn('Updates: $1', anyUpdate)
			if anyUpdate == true or anySound == true then
				local activeClients = {}

				for clientId, clientData in pairs(mist.DBs.humansById) do
					if Unit.getByName(clientData.unitName) and Unit.getByName(clientData.unitName):isExist() == true then
						activeClients[clientData.groupId] = clientData.groupName
					end
				end

				if displayActive == false then
					displayActive = true
				end
				--mist.debug.writeData(mist.utils.serialize,{'msg', messageList}, 'messageList.lua')
				local msgTableText = {}
				local msgTableSound = {}
				local curTime = timer.getTime()
				for mInd, messageData in pairs(messageList) do
					log:warn(messageData)
					if messageData.displayTill < curTime then
						log:warn('remove')
						messageData:remove() -- now using the remove/destroy function.
					else
						if messageData.displayedFor then
							messageData.displayedFor = curTime - messageData.addedAt
						end

						local soundIndex = 0
						local refSound = 100000
						if messageData.multSound and #messageData.multSound > 0 then
							anySound = true
							for index, sData in pairs(messageData.multSound) do
								if sData.time <= messageData.displayedFor and sData.played == false and sData.time < refSound then -- find index of the next sound to be played
									refSound = sData.time
									soundIndex = index
								end
							end
							if soundIndex ~= 0 then
								messageData.multSound[soundIndex].played = true
							end
						end

						for recIndex, recData in pairs(messageData.msgFor) do  -- iterate recipiants
							if recData == 'RED' or recData == 'BLUE' or activeClients[recData] then -- rec exists
								if messageData.text then                       -- text
									if not msgTableText[recData] then          -- create table entry for text
										msgTableText[recData] = {}
										msgTableText[recData].text = {}
										if recData == 'RED' or recData == 'BLUE' then
											msgTableText[recData].text[1] = '-------Combined Arms Message-------- \n'
										end
										msgTableText[recData].text[#msgTableText[recData].text + 1] = messageData.text
										msgTableText[recData].displayTime = messageData.displayTime -
											messageData.displayedFor
									else -- add to table entry and adjust display time if needed
										if recData == 'RED' or recData == 'BLUE' then
											msgTableText[recData].text[#msgTableText[recData].text + 1] =
											'\n ---------------- Combined Arms Message: \n'
										else
											msgTableText[recData].text[#msgTableText[recData].text + 1] =
											'\n ---------------- \n'
										end
										table.insert(msgTableText[recData].text, messageData.text)
										if msgTableText[recData].displayTime < messageData.displayTime - messageData.displayedFor then
											msgTableText[recData].displayTime = messageData.displayTime -
												messageData.displayedFor
										else
											--msgTableText[recData].displayTime = 10
										end
									end
								end
								if soundIndex ~= 0 then
									msgTableSound[recData] = messageData.multSound[soundIndex].file
								end
							end
						end
						messageData.update = nil
					end
				end
				------- new display
				if anyUpdate == true then
					if caSlots == true and caMSGtoGroup == false then
						if msgTableText.RED then
							trigger.action.outTextForCoalition(coalition.side.RED, table.concat(msgTableText.RED.text),
								msgTableText.RED.displayTime, clearView)
						end
						if msgTableText.BLUE then
							trigger.action.outTextForCoalition(coalition.side.BLUE, table.concat(msgTableText.BLUE.text),
								msgTableText.BLUE.displayTime, clearView)
						end
					end

					for index, msgData in pairs(msgTableText) do
						if type(index) == 'number' then -- its a groupNumber
							trigger.action.outTextForGroup(index, table.concat(msgData.text), msgData.displayTime,
								clearView)
						end
					end
				end
				--- new audio
				if msgTableSound.RED then
					trigger.action.outSoundForCoalition(coalition.side.RED, msgTableSound.RED)
				end
				if msgTableSound.BLUE then
					trigger.action.outSoundForCoalition(coalition.side.BLUE, msgTableSound.BLUE)
				end


				for index, file in pairs(msgTableSound) do
					if type(index) == 'number' then -- its a groupNumber
						trigger.action.outSoundForGroup(index, file)
					end
				end
			end

			anyUpdate = false
			anySound = false
		else
			mist.removeFunction(displayFuncId)
			displayActive = false
		end
	end

	local function mistdisplayV4()
		local activeClients = {}

		for clientId, clientData in pairs(mist.DBs.humansById) do
			if Unit.getByName(clientData.unitName) and Unit.getByName(clientData.unitName):isExist() == true then
				activeClients[clientData.groupId] = clientData.groupName
			end
		end

		--[[if caSlots == true and caMSGtoGroup == true then

		end]]


		if #messageList > 0 then
			if displayActive == false then
				displayActive = true
			end
			--mist.debug.writeData(mist.utils.serialize,{'msg', messageList}, 'messageList.lua')
			local msgTableText = {}
			local msgTableSound = {}

			for messageId, messageData in pairs(messageList) do
				if messageData.displayedFor > messageData.displayTime then
					messageData:remove() -- now using the remove/destroy function.
				else
					if messageData.displayedFor then
						messageData.displayedFor = messageData.displayedFor + messageDisplayRate
					end
					local nextSound = 1000
					local soundIndex = 0

					if messageData.multSound and #messageData.multSound > 0 then
						for index, sData in pairs(messageData.multSound) do
							if sData.time <= messageData.displayedFor and sData.played == false and sData.time < nextSound then -- find index of the next sound to be played
								nextSound = sData.time
								soundIndex = index
							end
						end
						if soundIndex ~= 0 then
							messageData.multSound[soundIndex].played = true
						end
					end

					for recIndex, recData in pairs(messageData.msgFor) do     -- iterate recipiants
						if recData == 'RED' or recData == 'BLUE' or activeClients[recData] then -- rec exists
							if messageData.text then                          -- text
								if not msgTableText[recData] then             -- create table entry for text
									msgTableText[recData] = {}
									msgTableText[recData].text = {}
									if recData == 'RED' or recData == 'BLUE' then
										msgTableText[recData].text[1] = '-------Combined Arms Message-------- \n'
									end
									msgTableText[recData].text[#msgTableText[recData].text + 1] = messageData.text
									msgTableText[recData].displayTime = messageData.displayTime -
										messageData.displayedFor
								else -- add to table entry and adjust display time if needed
									if recData == 'RED' or recData == 'BLUE' then
										msgTableText[recData].text[#msgTableText[recData].text + 1] =
										'\n ---------------- Combined Arms Message: \n'
									else
										msgTableText[recData].text[#msgTableText[recData].text + 1] =
										'\n ---------------- \n'
									end
									msgTableText[recData].text[#msgTableText[recData].text + 1] = messageData.text
									if msgTableText[recData].displayTime < messageData.displayTime - messageData.displayedFor then
										msgTableText[recData].displayTime = messageData.displayTime -
											messageData.displayedFor
									else
										msgTableText[recData].displayTime = 1
									end
								end
							end
							if soundIndex ~= 0 then
								msgTableSound[recData] = messageData.multSound[soundIndex].file
							end
						end
					end
				end
			end
			------- new display

			if caSlots == true and caMSGtoGroup == false then
				if msgTableText.RED then
					trigger.action.outTextForCoalition(coalition.side.RED, table.concat(msgTableText.RED.text),
						msgTableText.RED.displayTime, true)
				end
				if msgTableText.BLUE then
					trigger.action.outTextForCoalition(coalition.side.BLUE, table.concat(msgTableText.BLUE.text),
						msgTableText.BLUE.displayTime, true)
				end
			end

			for index, msgData in pairs(msgTableText) do
				if type(index) == 'number' then -- its a groupNumber
					trigger.action.outTextForGroup(index, table.concat(msgData.text), msgData.displayTime, true)
				end
			end
			--- new audio
			if msgTableSound.RED then
				trigger.action.outSoundForCoalition(coalition.side.RED, msgTableSound.RED)
			end
			if msgTableSound.BLUE then
				trigger.action.outSoundForCoalition(coalition.side.BLUE, msgTableSound.BLUE)
			end


			for index, file in pairs(msgTableSound) do
				if type(index) == 'number' then -- its a groupNumber
					trigger.action.outSoundForGroup(index, file)
				end
			end
		else
			mist.removeFunction(displayFuncId)
			displayActive = false
		end
	end

	local typeBase = {
		['Mi-8MT'] = { 'Mi-8MTV2', 'Mi-8MTV', 'Mi-8' },
		['MiG-21Bis'] = { 'Mig-21' },
		['MiG-15bis'] = { 'Mig-15' },
		['FW-190D9'] = { 'FW-190' },
		['Bf-109K-4'] = { 'Bf-109' },
	}

	--[[function mist.setCAGroupMSG(val)
	if type(val) == 'boolean' then
		caMSGtoGroup = val
		return true
	end
	return false
end]]

	mist.message = {

		add = function(vars)
			local function msgSpamFilter(recList, spamBlockOn)
				for id, name in pairs(recList) do
					if name == spamBlockOn then
						--	log:info('already on recList')
						return recList
					end
				end
				--log:info('add to recList')
				table.insert(recList, spamBlockOn)
				return recList
			end

			--[[
			local vars = {}
			vars.text = 'Hello World'
			vars.displayTime = 20
			vars.msgFor = {coa = {'red'}, countries = {'Ukraine', 'Georgia'}, unitTypes = {'A-10C'}}
			mist.message.add(vars)

			Displays the message for all red coalition players. Players belonging to Ukraine and Georgia, and all A-10Cs on the map

			]]


			local new = {}
			new.text = vars.text      -- The actual message
			new.displayTime = vars.displayTime -- How long will the message appear for
			new.displayedFor = 0      -- how long the message has been displayed so far
			new.displayTill = timer.getTime() + vars.displayTime
			new.name = vars
				.name -- ID to overwrite the older message (if it exists) Basically it replaces a message that is displayed with new text.
			new.addedAt = timer.getTime()
			new.clearView = vars.clearView or true
			--log:warn('New Message: $1', new.text)

			if vars.multSound and vars.multSound[1] then
				new.multSound = vars.multSound
			else
				new.multSound = {}
			end

			if vars.sound or vars.fileName then -- converts old sound file system into new multSound format
				local sound = vars.sound
				if vars.fileName then
					sound = vars.fileName
				end
				new.multSound[#new.multSound + 1] = { time = 0.1, file = sound }
			end

			if #new.multSound > 0 then
				for i, data in pairs(new.multSound) do
					data.played = false
				end
			end

			local newMsgFor = {} -- list of all groups message displays for
			for forIndex, forData in pairs(vars.msgFor) do
				for list, listData in pairs(forData) do
					for clientId, clientData in pairs(mist.DBs.humansById) do
						forIndex = string.lower(forIndex)
						if type(listData) == 'string' then
							listData = string.lower(listData)
						end
						if (forIndex == 'coa' and (listData == string.lower(clientData.coalition) or listData == 'all')) or (forIndex == 'countries' and string.lower(clientData.country) == listData) or (forIndex == 'units' and string.lower(clientData.unitName) == listData) then --
							newMsgFor = msgSpamFilter(newMsgFor, clientData.groupId)                                                                                                                                                                                 -- so units dont get the same message twice if complex rules are given
							--table.insert(newMsgFor, clientId)
						elseif forIndex == 'unittypes' then
							for typeId, typeData in pairs(listData) do
								local found = false
								for clientDataEntry, clientDataVal in pairs(clientData) do
									if type(clientDataVal) == 'string' then
										if mist.matchString(list, clientDataVal) == true or list == 'all' then
											local sString = typeData
											for rName, pTbl in pairs(typeBase) do -- just a quick check to see if the user may have meant something and got the specific type of the unit wrong
												for pIndex, pName in pairs(pTbl) do
													if mist.stringMatch(sString, pName) then
														sString = rName
													end
												end
											end
											if sString == clientData.type then
												found = true
												newMsgFor = msgSpamFilter(newMsgFor, clientData.groupId) -- sends info oto other function to see if client is already recieving the current message.
												--table.insert(newMsgFor, clientId)
											end
										end
									end
									if found == true then -- shouldn't this be elsewhere too?
										break
									end
								end
							end
						end
					end
					for coaData, coaId in pairs(coalition.side) do
						if string.lower(forIndex) == 'coa' or string.lower(forIndex) == 'ca' then
							if listData == string.lower(coaData) or listData == 'all' then
								newMsgFor = msgSpamFilter(newMsgFor, coaData)
							end
						end
					end
				end
			end

			if #newMsgFor > 0 then
				new.msgFor = newMsgFor -- I swear its not confusing
			else
				return false
			end


			if vars.name and type(vars.name) == 'string' then
				for i = 1, #messageList do
					if messageList[i].name then
						if messageList[i].name == vars.name then
							--log:info('updateMessage')
							messageList[i].displayTill = timer.getTime() + messageList[i].displayTime
							messageList[i].displayedFor = 0
							messageList[i].addedAt = timer.getTime()
							messageList[i].text = new.text
							messageList[i].msgFor = new.msgFor
							messageList[i].multSound = new.multSound
							anyUpdate = true
							--log:warn('Message updated: $1', new.messageID)
							return messageList[i].messageID
						end
					end
				end
			end
			anyUpdate = true
			messageID = messageID + 1
			new.messageID = messageID

			--mist.debug.writeData(mist.utils.serialize,{'msg', new}, 'newMsg.lua')


			messageList[#messageList + 1] = new

			local mt = { __index = mist.message }
			setmetatable(new, mt)

			if displayActive == false then
				displayActive = true
				displayFuncId = mist.scheduleFunction(mistdisplayV4, {}, timer.getTime() + messageDisplayRate,
					messageDisplayRate)
			end

			return messageID
		end,

		remove = function(self) -- Now a self variable; the former functionality taken up by mist.message.removeById.
			for i, msgData in pairs(messageList) do
				if messageList[i] == self then
					table.remove(messageList, i)
					anyUpdate = true
					return true --removal successful
				end
			end
			return false -- removal not successful this script fails at life!
		end,

		removeById = function(id) -- This function is NOT passed a self variable; it is the remove by id function.
			for i, msgData in pairs(messageList) do
				if messageList[i].messageID == id then
					table.remove(messageList, i)
					anyUpdate = true
					return true --removal successful
				end
			end
			return false -- removal not successful this script fails at life!
		end,
	}

	--[[ vars for mist.msgMGRS
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer between 0 and 5, inclusive
vars.text - text in the message
vars.displayTime - self explanatory
vars.msgFor - scope
]]
	function mist.msgMGRS(vars)
		local units = vars.units
		local acc = vars.acc
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getMGRSString { units = units, acc = acc }
		local newText
		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end
		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end

	--[[ vars for mist.msgLL
vars.units - table of unit names (NOT unitNameTable- maybe this should change) (Yes).
vars.acc - integer, number of numbers after decimal place
vars.DMS - if true, output in degrees, minutes, seconds.	Otherwise, output in degrees, minutes.
vars.text - text in the message
vars.displayTime - self explanatory
vars.msgFor - scope
]]
	function mist.msgLL(vars)
		local units = vars.units -- technically, I don't really need to do this, but it helps readability.
		local acc = vars.acc
		local DMS = vars.DMS
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getLLString { units = units, acc = acc, DMS = DMS }
		local newText
		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end

		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end

	--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -	vec3 ref point, maybe overload for vec2 as well?
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgBR(vars)
		local units = vars.units -- technically, I don't really need to do this, but it helps readability.
		local ref = vars.ref -- vec2/vec3 will be handled in mist.getBRString
		local alt = vars.alt
		local metric = vars.metric
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getBRString { units = units, ref = ref, alt = alt, metric = metric }
		local newText
		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end

		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end

	-- basically, just sub-types of mist.msgBR... saves folks the work of getting the ref point.
	--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -	string red, blue
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgBullseye(vars)
		if mist.DBs.missionData.bullseye[string.lower(vars.ref)] then
			vars.ref = mist.DBs.missionData.bullseye[string.lower(vars.ref)]
			mist.msgBR(vars)
		end
	end

	--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -	unit name of reference point
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgBRA(vars)
		if Unit.getByName(vars.ref) and Unit.getByName(vars.ref):isExist() == true then
			vars.ref = Unit.getByName(vars.ref):getPosition().p
			if not vars.alt then
				vars.alt = true
			end
			mist.msgBR(vars)
		end
	end

	--[[ vars for mist.msgLeadingMGRS:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees (optional)
vars.acc - number, 0 to 5.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgLeadingMGRS(vars)
		local units = vars.units -- technically, I don't really need to do this, but it helps readability.
		local heading = vars.heading
		local radius = vars.radius
		local headingDegrees = vars.headingDegrees
		local acc = vars.acc
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getLeadingMGRSString { units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, acc = acc }
		local newText
		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end

		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end

	--[[ vars for mist.msgLeadingLL:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees (optional)
vars.acc - number of digits after decimal point (can be negative)
vars.DMS -	boolean, true if you want DMS. (optional)
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgLeadingLL(vars)
		local units = vars.units -- technically, I don't really need to do this, but it helps readability.
		local heading = vars.heading
		local radius = vars.radius
		local headingDegrees = vars.headingDegrees
		local acc = vars.acc
		local DMS = vars.DMS
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getLeadingLLString { units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, acc = acc, DMS = DMS }
		local newText

		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end

		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end

	--[[
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees	(optional)
vars.metric - boolean, if true, use km instead of NM. (optional)
vars.alt - boolean, if true, include altitude. (optional)
vars.ref - vec3/vec2 reference point.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
	function mist.msgLeadingBR(vars)
		local units = vars.units -- technically, I don't really need to do this, but it helps readability.
		local heading = vars.heading
		local radius = vars.radius
		local headingDegrees = vars.headingDegrees
		local metric = vars.metric
		local alt = vars.alt
		local ref = vars.ref -- vec2/vec3 will be handled in mist.getBRString
		local text = vars.text
		local displayTime = vars.displayTime
		local msgFor = vars.msgFor

		local s = mist.getLeadingBRString { units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, metric = metric, alt = alt, ref = ref }
		local newText

		if text then
			if string.find(text, '%%s') then -- look for %s
				newText = string.format(text, s) -- insert the coordinates into the message
			else
				-- just append to the end.
				newText = text .. s
			end
		else
			newText = s
		end

		mist.message.add {
			text = newText,
			displayTime = displayTime,
			msgFor = msgFor
		}
	end
end

--- Demo functions.
-- @section mist.demos
do -- mist.demos scope
	mist.demos = {}

	function mist.demos.printFlightData(unit)
		if unit:isExist() then
			local function printData(unit, prevVel, prevE, prevTime)
				local angles = mist.getAttitude(unit)
				if angles then
					local Heading = angles.Heading
					local Pitch = angles.Pitch
					local Roll = angles.Roll
					local Yaw = angles.Yaw
					local AoA = angles.AoA
					local ClimbAngle = angles.ClimbAngle

					if not Heading then
						Heading = 'NA'
					else
						Heading = string.format('%12.2f', mist.utils.toDegree(Heading))
					end

					if not Pitch then
						Pitch = 'NA'
					else
						Pitch = string.format('%12.2f', mist.utils.toDegree(Pitch))
					end

					if not Roll then
						Roll = 'NA'
					else
						Roll = string.format('%12.2f', mist.utils.toDegree(Roll))
					end

					local AoAplusYaw = 'NA'
					if AoA and Yaw then
						AoAplusYaw = string.format('%12.2f', mist.utils.toDegree((AoA ^ 2 + Yaw ^ 2) ^ 0.5))
					end

					if not Yaw then
						Yaw = 'NA'
					else
						Yaw = string.format('%12.2f', mist.utils.toDegree(Yaw))
					end

					if not AoA then
						AoA = 'NA'
					else
						AoA = string.format('%12.2f', mist.utils.toDegree(AoA))
					end

					if not ClimbAngle then
						ClimbAngle = 'NA'
					else
						ClimbAngle = string.format('%12.2f', mist.utils.toDegree(ClimbAngle))
					end
					local unitPos = unit:getPosition()
					local unitVel = unit:getVelocity()
					local curTime = timer.getTime()
					local absVel = string.format('%12.2f', mist.vec.mag(unitVel))


					local unitAcc = 'NA'
					local Gs = 'NA'
					local axialGs = 'NA'
					local transGs = 'NA'
					if prevVel and prevTime then
						local xAcc = (unitVel.x - prevVel.x) / (curTime - prevTime)
						local yAcc = (unitVel.y - prevVel.y) / (curTime - prevTime)
						local zAcc = (unitVel.z - prevVel.z) / (curTime - prevTime)

						unitAcc = string.format('%12.2f', mist.vec.mag({ x = xAcc, y = yAcc, z = zAcc }))
						Gs = string.format('%12.2f', mist.vec.mag({ x = xAcc, y = yAcc + 9.81, z = zAcc }) / 9.81)
						axialGs = string.format('%12.2f',
							mist.vec.dp({ x = xAcc, y = yAcc + 9.81, z = zAcc }, unitPos.x) / 9.81)
						transGs = string.format('%12.2f',
							mist.vec.mag(mist.vec.cp({ x = xAcc, y = yAcc + 9.81, z = zAcc }, unitPos.x)) / 9.81)
					end

					local E = 0.5 * mist.vec.mag(unitVel) ^ 2 + 9.81 * unitPos.p.y

					local energy = string.format('%12.2e', E)

					local dEdt = 'NA'
					if prevE and prevTime then
						dEdt = string.format('%12.2e', (E - prevE) / (curTime - prevTime))
					end

					trigger.action.outText(
						string.format('%-25s', 'Heading: ') ..
						Heading ..
						' degrees\n' ..
						string.format('%-25s', 'Roll: ') ..
						Roll .. ' degrees\n' .. string.format('%-25s', 'Pitch: ') .. Pitch
						..
						' degrees\n' ..
						string.format('%-25s', 'Yaw: ') ..
						Yaw ..
						' degrees\n' ..
						string.format('%-25s', 'AoA: ') ..
						AoA ..
						' degrees\n' ..
						string.format('%-25s', 'AoA plus Yaw: ') ..
						AoAplusYaw .. ' degrees\n' .. string.format('%-25s', 'Climb Angle: ') ..
						ClimbAngle ..
						' degrees\n' ..
						string.format('%-25s', 'Absolute Velocity: ') ..
						absVel .. ' m/s\n' .. string.format('%-25s', 'Absolute Acceleration: ') .. unitAcc .. ' m/s^2\n'
						..
						string.format('%-25s', 'Axial G loading: ') ..
						axialGs ..
						' g\n' ..
						string.format('%-25s', 'Transverse G loading: ') ..
						transGs ..
						' g\n' ..
						string.format('%-25s', 'Absolute G loading: ') ..
						Gs ..
						' g\n' ..
						string.format('%-25s', 'Energy: ') ..
						energy .. ' J/kg\n' .. string.format('%-25s', 'dE/dt: ') .. dEdt .. ' J/(kg*s)', 1)
					return unitVel, E, curTime
				end
			end

			local function frameFinder(unit, prevVel, prevE, prevTime)
				if unit:isExist() then
					local currVel = unit:getVelocity()
					if prevVel and (prevVel.x ~= currVel.x or prevVel.y ~= currVel.y or prevVel.z ~= currVel.z) or (prevTime and (timer.getTime() - prevTime) > 0.25) then
						prevVel, prevE, prevTime = printData(unit, prevVel, prevE, prevTime)
					end
					mist.scheduleFunction(frameFinder, { unit, prevVel, prevE, prevTime }, timer.getTime() + 0.005) -- it can't go this fast, limited to the 100 times a sec check right now.
				end
			end


			local curVel = unit:getVelocity()
			local curTime = timer.getTime()
			local curE = 0.5 * mist.vec.mag(curVel) ^ 2 + 9.81 * unit:getPosition().p.y
			frameFinder(unit, curVel, curE, curTime)
		end
	end
end



do
	--[[ stuff for marker panels
		marker.add() add marker. Point of these functions is to simplify process and to store all mark panels added.
		-- generates Id if not specified or if multiple marks created.
		-- makes marks for countries by creating a mark for each client group in the country
		-- can create multiple marks if needed for groups and countries.
		-- adds marks to table for parsing and removing
		-- Uses similar structure as messages. Big differences is it doesn't only mark to groups.
			If to All, then mark is for All
			if to coa mark is to coa
			if to specific units, mark is to group
			
			
		--------
		STUFF TO Check
		--------
		If mark added to a group before a client joins slot is synced.
		Mark made for cliet A in Slot A. Client A leaves, Client B joins in slot A. What do they see?
		

		May need to automate process...


        Could release this. But things I might need to add/change before doing so.
            - removing marks and re-adding in same sequence doesn't appear to work. May need to schedule adding mark if updating an entry.
            - I really dont like the old message style code for which groups get the message. Perhaps change to unitsTable and create function for getting humanUnitsTable.
            = Event Handler, and check it, for marks added via script or user to deconflict Ids.
            - Full validation of passed values for a specific shape type.

	]]

	local usedMarks = {}

	local mDefs = {
		coa = {
			['red'] = { fillColor = { .8, 0, 0, .5 }, color = { .8, 0, 0, .5 }, lineType = 2, fontSize = 16 },
			['blue'] = { fillColor = { 0, 0, 0.8, .5 }, color = { 0, 0, 0.8, .5 }, lineType = 2, fontSize = 16 },
			['all'] = { fillColor = { .1, .1, .1, .5 }, color = { .9, .9, .9, .5 }, lineType = 2, fontSize = 16 },
			['neutral'] = { fillColor = { .1, .1, .1, .5 }, color = { .2, .2, .2, .5 }, lineType = 2, fontSize = 16 },
		},
	}

	local userDefs = { ['red'] = {}, ['blue'] = {}, ['all'] = {}, ['neutral'] = {} }

	local mId = 1000

	local tNames = { 'line', 'circle', 'rect', 'arrow', 'text', 'quad', 'freeform' }
	local tLines = {
		[0] = 'no line',
		[1] = 'solid',
		[2] = 'dashed',
		[3] = 'dotted',
		[4] = 'dot dash',
		[5] = 'long dash',
		[6] = 'two dash'
	}
	local coas = { [-1] = 'all', [0] = 'neutral', [1] = 'red', [2] = 'blue' }

	local altNames = { ['poly'] = 7, ['lines'] = 1, ['polygon'] = 7 }

	local function draw(s)
		--log:warn(s)
		if type(s) == 'table' then
			local mType = s.markType
			--log:echo(s)

			if mType == 'panel' then
				local markScope = s.markScope or "all"
				if markScope == 'coa' then
					trigger.action.markToCoalition(s.markId, s.text, s.pos, s.markFor, s.readOnly)
				elseif markScope == 'group' then
					trigger.action.markToGroup(s.markId, s.text, s.pos, s.markFor, s.readOnly)
				else
					trigger.action.markToAll(s.markId, s.text, s.pos, s.readOnly)
				end
			elseif mType == 'line' then
				trigger.action.lineToAll(s.coa, s.markId, s.pos[1], s.pos[2], s.color, s.fillColor, s.lineType,
					s.readOnly, s.message)
			elseif mType == 'circle' then
				trigger.action.circleToAll(s.coa, s.markId, s.pos[1], s.radius, s.color, s.fillColor, s.lineType,
					s.readOnly, s.message)
			elseif mType == 'rect' then
				trigger.action.rectToAll(s.coa, s.markId, s.pos[1], s.pos[2], s.color, s.fillColor, s.lineType,
					s.readOnly, s.message)
			elseif mType == 'arrow' then
				trigger.action.arrowToAll(s.coa, s.markId, s.pos[1], s.pos[2], s.color, s.fillColor, s.lineType,
					s.readOnly, s.message)
			elseif mType == 'text' then
				trigger.action.textToAll(s.coa, s.markId, s.pos[1], s.color, s.fillColor, s.fontSize, s.readOnly, s.text)
			elseif mType == 'quad' then
				trigger.action.quadToAll(s.coa, s.markId, s.pos[1], s.pos[2], s.pos[3], s.pos[4], s.color, s.fillColor,
					s.lineType, s.readOnly, s.message)
			end
			if s.name and not usedMarks[s.name] then
				usedMarks[s.name] = s.markId
			end
		elseif type(s) == 'string' then
			--log:warn(s)
			mist.utils.dostring(s)
		end
	end

	mist.marker = {}

	local function markSpamFilter(recList, spamBlockOn)
		for id, name in pairs(recList) do
			if name == spamBlockOn then
				--log:info('already on recList')
				return recList
			end
		end
		--log:info('add to recList')
		table.insert(recList, spamBlockOn)
		return recList
	end

	local function iterate()
		while mId < 10000000 do
			if usedMarks[mId] then
				mId = mId + 1
			else
				return mist.utils.deepCopy(mId)
			end
		end
		return mist.utils.deepCopy(mId)
	end

	local function validateColor(val)
		if type(val) == 'table' then
			for i = 1, 4 do
				if val[i] then
					if type(val[i]) == 'number' and val[i] > 1 then
						val[i] = val[i] / 255 -- convert RGB values from 0-255 to 0-1 equivilent.
					end
				else
					val[i] = 0.8
					log:warn("index $1 of color to mist.marker.add was missing, defaulted to 0.8", i)
				end
			end
		elseif type(val) == 'string' then
			val = mist.utils.hexToRGB(val)
		end
		return val
	end

	local function checkDefs(vName, coa)
		--log:warn('CheckDefs: $1 $2', vName, coa)
		local coaName
		if type(coa) == 'number' then
			if coas[coa] then
				coaName = coas[coa]
			end
		elseif type(coa) == 'string' then
			coaName = coa
		end

		-- log:warn(coaName)
		if userDefs[coaName] and userDefs[coaName][vName] then
			return userDefs[coaName][vName]
		elseif mDefs.coa[coaName] and mDefs.coa[coaName][vName] then
			return mDefs.coa[coaName][vName]
		end
	end

	function mist.marker.getNextId()
		return iterate()
	end

	local handle = {}
	function handle:onEvent(e)
		if world.event.S_EVENT_MARK_ADDED == e.id and e.idx then
			usedMarks[e.idx] = e.idx
			if not mist.DBs.markList[e.idx] then
				--log:info('create maker DB: $1', e.idx)
				mist.DBs.markList[e.idx] = {
					time = e.time,
					pos = e.pos,
					groupId = e.groupId,
					mType = 'panel',
					text = e
						.text,
					markId = e.idx,
					coalition = e.coalition
				}
				if e.unit then
					mist.DBs.markList[e.idx].unit = e.initiator:getName()
				end
				--log:info(mist.marker.list[e.idx])
			end
		elseif world.event.S_EVENT_MARK_CHANGE == e.id and e.idx then
			if mist.DBs.markList[e.idx] then
				mist.DBs.markList[e.idx].text = e.text
			end
		elseif world.event.S_EVENT_MARK_REMOVE == e.id and e.idx then
			if mist.DBs.markList[e.idx] then
				mist.DBs.markList[e.idx] = nil
			end
		end
	end

	local function getMarkId(id)
		if mist.DBs.markList[id] then
			return id
		else
			for mEntry, mData in pairs(mist.DBs.markList) do
				if id == mData.name or id == mData.id then
					return mData.markId
				end
			end
		end
	end


	local function removeMark(id)
		--log:info("Removing Mark: $1", id)
		local removed = false
		if type(id) == 'table' then
			for ind, val in pairs(id) do
				local r
				if type(val) == "table" and val.markId then
					r = val.markId
				else
					r = getMarkId(val)
				end
				if r then
					trigger.action.removeMark(r)
					mist.DBs.markList[r] = nil
					removed = true
				end
			end
		else
			local r = getMarkId(id)
			if r then
				trigger.action.removeMark(r)
				mist.DBs.markList[r] = nil
				removed = true
			end
		end
		return removed
	end

	world.addEventHandler(handle)
	function mist.marker.setDefault(vars)
		local anyChange = false
		if vars and type(vars) == 'table' then
			for l1, l1Data in pairs(vars) do
				if type(l1Data) == 'table' then
					if not userDefs[l1] then
						userDefs[l1] = {}
					end

					for l2, l2Data in pairs(l1Data) do
						userDefs[l1][l2] = l2Data
						anyChange = true
					end
				else
					userDefs[l1] = l1Data
					anyChange = true
				end
			end
		end
		return anyChange
	end

	function mist.marker.add(vars)
		--log:warn('markerFunc')
		--log:warn(vars)
		local pos        = vars.point or vars.points or vars.pos
		local text       = vars.text or ''
		local markFor    = vars.markFor
		local markForCoa = vars.markForCoa or
			vars
			.coa -- optional, can be used if you just want to mark to a specific coa/all
		local id         = vars.id or vars.markId or vars.markid
		local mType      = vars.mType or vars.markType or vars.type or 0
		local color      = vars.color
		local fillColor  = vars.fillColor
		local lineType   = vars.lineType or 2
		local readOnly   = vars.readOnly or true
		local message    = vars.message
		local fontSize   = vars.fontSize
		local name       = vars.name
		local radius     = vars.radius or 500

		local coa        = -1
		local usedId     = 0

		pos              = mist.utils.deepCopy(pos)

		if id then
			if type(id) ~= 'number' then
				name = id
				usedId = iterate()
			end
			--log:info('checkIfIdExist: $1', id)
			--[[
           Maybe it should treat id or name as the same thing/single value.

           If passed number it will use that as the first Id used and will delete/update any marks associated with that same value.


           ]]

			local lId = id or name
			if mist.DBs.markList[id] then ----------  NEED A BETTER WAY TO ASSOCIATE THE ID VALUE. CUrrnetly deleting from table and checking if that deleted entry exists which it wont.
				--log:warn('active mark to be removed: $1', id)
				name = mist.DBs.markList[id].name or id
				removeMark(id)
			elseif usedMarks[id] then
				--log:info('exists in usedMarks: $1', id)
				removeMark(usedMarks[id])
			elseif name and usedMarks[name] then
				--log:info('exists in usedMarks: $1', name)
				removeMark(usedMarks[name])
			end
			usedId = iterate()
			usedMarks[id] = usedId -- redefine the value used
		end
		if name then
			usedMarks[name] = usedId
		end

		if usedId == 0 then
			usedId = iterate()
		end
		if mType then
			if type(mType) == 'string' then
				for i = 1, #tNames do
					--log:warn(tNames[i])
					if mist.stringMatch(mType, tNames[i]) then
						mType = i
						break
					end
				end
			elseif type(mType) == 'number' and mType > #tNames then
				mType = 0
			end
		end
		--log:warn(mType)
		local markScope = 'all'
		local markForTable = {}

		if pos then
			if pos[1] then
				for i = 1, #pos do
					pos[i] = mist.utils.makeVec3(pos[i])
				end
			else
				pos[1] = mist.utils.makeVec3(pos)
			end
		end
		if text and type(text) ~= string then
			text = tostring(text)
		end

		if markForCoa then
			if type(markForCoa) == 'string' then
				--log:warn("coa is string")
				if tonumber(markForCoa) then
					coa = coas[tonumber(markForCoa)]
					markScope = 'coa'
				else
					for ind, cName in pairs(coas) do
						if mist.stringMatch(cName, markForCoa) then
							coa = ind
							markScope = 'coa'
							break
						end
					end
				end
			elseif type(markForCoa) == 'number' and markForCoa >= -1 and markForCoa <= #coas then
				coa = markForCoa
				--log:warn("coa is number")
				markScope = 'coa'
			end
			markFor = coa
		elseif markFor then
			if type(markFor) == 'number' then -- groupId
				if mist.DBs.groupsById[markFor] then
					markScope = 'group'
				end
			elseif type(markFor) == 'string' then -- groupName
				if mist.DBs.groupsByName[markFor] then
					markScope = 'group'
					markFor = mist.DBs.groupsByName[markFor].groupId
				end
			elseif type(markFor) == 'table' then -- multiple groupName, country, coalition, all
				markScope = 'table'
				--log:warn(markFor)
				for forIndex, forData in pairs(markFor) do -- need to rethink this part and organization. Gotta be a more logical way to send messages to coa, groups, or all.
					for list, listData in pairs(forData) do
						--log:warn(listData)
						forIndex = string.lower(forIndex)
						if type(listData) == 'string' then
							listData = string.lower(listData)
						end
						if listData == 'all' then
							markScope = 'all'
							break
						elseif (forIndex == 'coa' or forIndex == 'ca') then -- mark for coa or CA.
							local matches = 0
							for name, index in pairs(coalition.side) do
								if listData == string.lower(name) then
									markScope = 'coa'
									markFor = index
									coa = index
									matches = matches + 1
								end
							end
							if matches > 1 then
								markScope = 'all'
							end
						elseif forIndex == 'countries' then
							for clienId, clientData in pairs(mist.DBs.humansById) do
								if (string.lower(clientData.country) == listData) or (forIndex == 'units' and string.lower(clientData.unitName) == listData) then
									markForTable = markSpamFilter(markForTable, clientData.groupId)
								end
							end
						elseif forIndex == 'unittypes' then -- mark to group
							-- iterate play units
							for clientId, clientData in pairs(mist.DBs.humansById) do
								for typeId, typeData in pairs(listData) do
									--log:warn(typeData)
									local found = false
									if list == 'all' or clientData.coalition and type(clientData.coalition) == 'string' and mist.stringMatch(clientData.coalition, list) then
										if mist.matchString(typeData, clientData.type) then
											found = true
										else
											-- check other known names for aircraft
										end
									end
									if found == true then
										markForTable = markSpamFilter(markForTable, clientData.groupId) -- sends info to other function to see if client is already recieving the current message.
									end
									for clientDataEntry, clientDataVal in pairs(clientData) do
										if type(clientDataVal) == 'string' then
											if mist.matchString(list, clientDataVal) == true or list == 'all' then
												local sString = typeData
												for rName, pTbl in pairs(typeBase) do -- just a quick check to see if the user may have meant something and got the specific type of the unit wrong
													for pIndex, pName in pairs(pTbl) do
														if mist.stringMatch(sString, pName) then
															sString = rName
														end
													end
												end
												if mist.stringMatch(sString, clientData.type) then
													found = true
													markForTable = markSpamFilter(markForTable, clientData.groupId) -- sends info oto other function to see if client is already recieving the current message.
													--table.insert(newMsgFor, clientId)
												end
											end
										end
										if found == true then -- shouldn't this be elsewhere too?
											break
										end
									end
								end
							end
						end
					end
				end
			end
		else
			markScope = 'all'
		end

		if mType == 0 then
			local data = {
				markId = usedId,
				text = text,
				pos = pos[1],
				markScope = markScope,
				markFor = markFor,
				markType =
				'panel',
				name = name,
				time = timer.getTime()
			}
			if markScope ~= 'table' then
				-- create marks

				mist.DBs.markList[usedId] = data -- add to the DB
			else
				if #markForTable > 0 then
					--log:info('iterate')
					local list = {}
					if id and not name then
						name = id
					end
					for i = 1, #markForTable do
						local newId = iterate()
						local data = {
							markId = newId,
							text = text,
							pos = pos[i],
							markScope = markScope,
							markFor =
								markForTable[i],
							markType = 'panel',
							name = name,
							readOnly = readOnly,
							time = timer.getTime()
						}
						mist.DBs.markList[newId] = data
						table.insert(list, data)

						draw(data)
					end
					return list
				end
			end

			draw(data)

			return data
		elseif mType > 0 then
			local newId = iterate()
			local fCal = {}
			fCal[#fCal + 1] = mType
			fCal[#fCal + 1] = coa
			fCal[#fCal + 1] = usedId

			local likeARainCoat = false
			if mType == 7 then
				local score = 0
				for i = 1, #pos do
					if i < #pos then
						local val = ((pos[i + 1].x - pos[i].x) * (pos[i + 1].z + pos[i].z))
						--log:warn("$1 index score is: $2", i, val)
						score = score + val
					else
						score = score + ((pos[1].x - pos[i].x) * (pos[1].z + pos[i].z))
					end
				end
				--log:warn(score)
				if score > 0 then -- it is anti-clockwise. Due to DCS bug make it clockwise.
					likeARainCoat = true
					--log:warn('flip')

					for i = #pos, 1, -1 do
						fCal[#fCal + 1] = pos[i]
					end
				end
			end
			if likeARainCoat == false then
				for i = 1, #pos do
					fCal[#fCal + 1] = pos[i]
				end
			end
			if radius and mType == 2 then
				fCal[#fCal + 1] = radius
			end

			if not color then
				color = checkDefs('color', coa)
			else
				color = validateColor(color)
			end
			fCal[#fCal + 1] = color


			if not fillColor then
				fillColor = checkDefs('fillColor', coa)
			else
				fillColor = validateColor(fillColor)
			end
			fCal[#fCal + 1] = fillColor

			if mType == 5 then -- text to all
				if not fontSize then
					fontSize = checkDefs('fontSize', coa) or 16
				end
				fCal[#fCal + 1] = fontSize
			else
				if not lineType then
					lineType = checkDefs('lineType', coa) or 2
				end
			end
			fCal[#fCal + 1] = lineType
			if not readOnly then
				readOnly = true
			end
			fCal[#fCal + 1] = readOnly
			if mType == 5 then
				fCal[#fCal + 1] = text
			else
				fCal[#fCal + 1] = message
			end
			local data = {
				coa = coa,
				markId = usedId,
				pos = pos,
				markFor = markFor,
				color = color,
				readOnly = readOnly,
				message =
					message,
				fillColor = fillColor,
				lineType = lineType,
				markType = tNames[mType],
				name = name,
				radius = radius,
				text =
					text,
				fontSize = fontSize,
				time = timer.getTime()
			}
			mist.DBs.markList[usedId] = data

			if mType == 7 or mType == 1 then
				local s = "trigger.action.markupToAll("

				for i = 1, #fCal do
					--log:warn(fCal[i])
					if type(fCal[i]) == 'table' or type(fCal[i]) == 'boolean' then
						s = s .. mist.utils.oneLineSerialize(fCal[i])
					else
						s = s .. fCal[i]
					end
					if i < #fCal then
						s = s .. ','
					end
				end

				s = s .. ')'
				if name then
					usedMarks[name] = usedId
				end
				draw(s)
			else
				draw(data)
			end
			return data
		end
	end

	function mist.marker.remove(id)
		return removeMark(id)
	end

	function mist.marker.get(id)
		if mist.DBs.markList[id] then
			return mist.DBs.markList[id]
		end
		local names = {}
		for markId, data in pairs(mist.DBs.markList) do
			if data.name and data.name == id then
				table.insert(names, data)
			end
		end
		if #names >= 1 then
			return names
		end
	end

	function mist.marker.drawZone(name, v)
		if mist.DBs.zonesByName[name] then
			--log:warn(mist.DBs.zonesByName[name])
			local vars = v or {}
			local ref = mist.utils.deepCopy(mist.DBs.zonesByName[name])

			if ref.type == 2 then -- it is a quad, but use freeform cause it isnt as bugged
				vars.mType = 6
				vars.point = ref.verticies
			else
				vars.mType = 2
				vars.radius = ref.radius
				vars.point = ref.point
			end


			if not (vars.ignoreColor and vars.ignoreColor == true) and not vars.fillColor then
				vars.fillColor = ref.color
			end

			--log:warn(vars)
			return mist.marker.add(vars)
		end
	end

	function mist.marker.drawShape(name, v)
		if mist.DBs.drawingByName[name] then
			local d = v or {}
			local o = mist.utils.deepCopy(mist.DBs.drawingByName[name])
			--mist.marker.add({point = {x = o.mapX, z = o.mapY}, text = name})
			--log:warn(o)
			d.points = o.points or {}
			if o.primitiveType == "Polygon" then
				d.mType = 7

				if o.polygonMode == "rect" then
					d.mType = 6
				elseif o.polygonMode == "circle" then
					d.mType = 2
					d.points = { x = o.mapX, y = o.mapY }
					d.radius = o.radius
				end
			elseif o.primitiveType == "TextBox" then
				d.mType = 5
				d.points = { x = o.mapX, y = o.mapY }
				d.text = o.text or d.text
				d.fontSize = d.fontSize or o.fontSize
			end
			-- NOTE TO SELF. FIGURE OUT WHICH SHAPES NEED TO BE OFFSET. OVAL YES.

			if o.fillColorString and not d.fillColor then
				d.fillColor = mist.utils.hexToRGB(o.fillColorString)
			end
			if o.colorString then
				d.color = mist.utils.hexToRGB(o.colorString)
			end


			if o.thickness == 0 then
				d.lineType = 0
			elseif o.style == 'solid' then
				d.lineType = 1
			elseif o.style == 'dot' then
				d.lineType = 2
			elseif o.style == 'dash' then
				d.lineType = 3
			else
				d.lineType = 1
			end


			if o.primitiveType == "Line" and #d.points >= 2 then
				d.mType = 1
				local rtn = {}
				for i = 1, #d.points - 1 do
					local var = mist.utils.deepCopy(d)
					var.points = {}
					var.points[1] = d.points[i]
					var.points[2] = d.points[i + 1]
					table.insert(rtn, mist.marker.add(var))
				end
				return rtn
			else
				if d.mType then
					--log:warn(d)
					return mist.marker.add(d)
				end
			end
		end
	end

	--[[
    function mist.marker.circle(v)


    end
]]
end
--- Time conversion functions.
-- @section mist.time
do -- mist.time scope
	mist.time = {}
	-- returns a string for specified military time
	-- theTime is optional
	-- if present current time in mil time is returned
	-- if number or table the time is converted into mil tim
	function mist.time.convertToSec(timeTable)
		local timeInSec = 0
		if timeTable and type(timeTable) == 'number' then
			timeInSec = timeTable
		elseif timeTable and type(timeTable) == 'table' and (timeTable.d or timeTable.h or timeTable.m or timeTable.s) then
			if timeTable.d and type(timeTable.d) == 'number' then
				timeInSec = timeInSec + (timeTable.d * 86400)
			end
			if timeTable.h and type(timeTable.h) == 'number' then
				timeInSec = timeInSec + (timeTable.h * 3600)
			end
			if timeTable.m and type(timeTable.m) == 'number' then
				timeInSec = timeInSec + (timeTable.m * 60)
			end
			if timeTable.s and type(timeTable.s) == 'number' then
				timeInSec = timeInSec + timeTable.s
			end
		end
		return timeInSec
	end

	function mist.time.getDHMS(timeInSec)
		if timeInSec and type(timeInSec) == 'number' then
			local tbl = { d = 0, h = 0, m = 0, s = 0 }
			if timeInSec > 86400 then
				while timeInSec > 86400 do
					tbl.d = tbl.d + 1
					timeInSec = timeInSec - 86400
				end
			end
			if timeInSec > 3600 then
				while timeInSec > 3600 do
					tbl.h = tbl.h + 1
					timeInSec = timeInSec - 3600
				end
			end
			if timeInSec > 60 then
				while timeInSec > 60 do
					tbl.m = tbl.m + 1
					timeInSec = timeInSec - 60
				end
			end
			tbl.s = timeInSec
			return tbl
		else
			log:error("Didn't recieve number")
			return
		end
	end

	function mist.getMilString(theTime)
		local timeInSec = 0
		if theTime then
			timeInSec = mist.time.convertToSec(theTime)
		else
			timeInSec = mist.utils.round(timer.getAbsTime(), 0)
		end

		local DHMS = mist.time.getDHMS(timeInSec)

		return tostring(string.format('%02d', DHMS.h) .. string.format('%02d', DHMS.m))
	end

	function mist.getClockString(theTime, hour)
		local timeInSec = 0
		if theTime then
			timeInSec = mist.time.convertToSec(theTime)
		else
			timeInSec = mist.utils.round(timer.getAbsTime(), 0)
		end
		local DHMS = mist.time.getDHMS(timeInSec)
		if hour then
			if DHMS.h > 12 then
				DHMS.h = DHMS.h - 12
				return tostring(string.format('%02d', DHMS.h) ..
					':' .. string.format('%02d', DHMS.m) .. ':' .. string.format('%02d', DHMS.s) .. ' PM')
			else
				return tostring(string.format('%02d', DHMS.h) ..
					':' .. string.format('%02d', DHMS.m) .. ':' .. string.format('%02d', DHMS.s) .. ' AM')
			end
		else
			return tostring(string.format('%02d', DHMS.h) ..
				':' .. string.format('%02d', DHMS.m) .. ':' .. string.format('%02d', DHMS.s))
		end
	end

	-- returns the date in string format
	-- both variables optional
	-- first val returns with the month as a string
	-- 2nd val defins if it should be written the American way or the wrong way.
	function mist.time.getDate(convert)
		local cal = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 } --
		local date = {}

		if not env.mission.date then -- Not likely to happen. Resaving mission auto updates this to remove it.
			date.d = 0
			date.m = 6
			date.y = 2011
		else
			date.d = env.mission.date.Day
			date.m = env.mission.date.Month
			date.y = env.mission.date.Year
		end
		local start = 86400
		local timeInSec = mist.utils.round(timer.getAbsTime())
		if convert and type(convert) == 'number' then
			timeInSec = convert
		end
		if timeInSec > 86400 then
			while start < timeInSec do
				if date.d >= cal[date.m] then
					if date.m == 2 and date.d == 28 then -- HOLY COW we can edit years now. Gotta re-add this!
						if date.y % 4 == 0 and date.y % 100 == 0 and date.y % 400 ~= 0 or date.y % 4 > 0 then
							date.m = date.m + 1
							date.d = 0
						end
						--date.d = 29
					else
						date.m = date.m + 1
						date.d = 0
					end
				end
				if date.m == 13 then
					date.m = 1
					date.y = date.y + 1
				end
				date.d = date.d + 1
				start = start + 86400
			end
		end
		return date
	end

	function mist.time.relativeToStart(time)
		if type(time) == 'number' then
			return time - timer.getTime0()
		end
	end

	function mist.getDateString(rtnType, murica, oTime) -- returns date based on time
		local word = { 'January', 'Feburary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
			'November', 'December' }                 -- 'etc
		local curTime = 0
		if oTime then
			curTime = oTime
		else
			curTime = mist.utils.round(timer.getAbsTime())
		end
		local tbl = mist.time.getDate(curTime)

		if rtnType then
			if murica then
				return tostring(word[tbl.m] .. ' ' .. tbl.d .. ' ' .. tbl.y)
			else
				return tostring(tbl.d .. ' ' .. word[tbl.m] .. ' ' .. tbl.y)
			end
		else
			if murica then
				return tostring(tbl.m .. '.' .. tbl.d .. '.' .. tbl.y)
			else
				return tostring(tbl.d .. '.' .. tbl.m .. '.' .. tbl.y)
			end
		end
	end

	--WIP
	function mist.time.milToGame(milString, rtnType) --converts a military time. By default returns the abosolute time that event would occur. With optional value it returns how many seconds from time of call till that time.
		local curTime = mist.utils.round(timer.getAbsTime())
		local milTimeInSec = 0

		if milString and type(milString) == 'string' and string.len(milString) >= 4 then
			local hr = tonumber(string.sub(milString, 1, 2))
			local mi = tonumber(string.sub(milString, 3))
			milTimeInSec = milTimeInSec + (mi * 60) + (hr * 3600)
		elseif milString and type(milString) == 'table' and (milString.d or milString.h or milString.m or milString.s) then
			milTimeInSec = mist.time.convertToSec(milString)
		end

		local startTime = timer.getTime0()
		local daysOffset = 0
		if startTime > 86400 then
			daysOffset = mist.utils.round(startTime / 86400)
			if daysOffset > 0 then
				milTimeInSec = milTimeInSec * daysOffset
			end
		end

		if curTime > milTimeInSec then
			milTimeInSec = milTimeInSec + 86400
		end
		if rtnType then
			milTimeInSec = milTimeInSec - startTime
		end
		return milTimeInSec
	end
end

--- Group task functions.
-- @section tasks
do -- group tasks scope
	mist.ground = {}
	mist.fixedWing = {}
	mist.heli = {}
	mist.air = {}
	mist.air.fixedWing = {}
	mist.air.heli = {}
	mist.ship = {}

	--- Tasks group to follow a route.
	-- This sets the mission task for the given group.
	-- Any wrapped actions inside the path (like enroute
	-- tasks) will be executed.
	-- @tparam Group group group to task.
	-- @tparam table path containing
	-- points defining a route.
	function mist.goRoute(group, path)
		local misTask = {
			id = 'Mission',
			params = {
				route = {
					points = mist.utils.deepCopy(path),
				},
			},
		}
		if type(group) == 'string' then
			group = Group.getByName(group)
		end
		if group then
			local groupCon = group:getController()
			if groupCon then
				--log:warn(misTask)
				groupCon:setTask(misTask)
				return true
			end
		end
		return false
	end

	-- same as getGroupPoints but returns speed and formation type along with vec2 of point}
	function mist.getGroupRoute(groupIdent, task)
		-- refactor to search by groupId and allow groupId and groupName as inputs
		local gpId = groupIdent
		if mist.DBs.MEgroupsByName[groupIdent] then
			gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
		else
			log:error('$1 not found in mist.DBs.MEgroupsByName', groupIdent)
		end

		for coa_name, coa_data in pairs(env.mission.coalition) do
			if type(coa_data) == 'table' then
				if coa_data.country then --there is a country table
					for cntry_id, cntry_data in pairs(coa_data.country) do
						for obj_cat_name, obj_cat_data in pairs(cntry_data) do
							if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then -- only these types have points
								if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
									for group_num, group_data in pairs(obj_cat_data.group) do
										if group_data and group_data.groupId == gpId then                                                        -- this is the group we are looking for
											if group_data.route and group_data.route.points and #group_data.route.points > 0 then
												local points = {}

												for point_num, point in pairs(group_data.route.points) do
													local routeData = {}
													if env.mission.version > 7 and env.mission.version < 19 then
														routeData.name = env.getValueDictByKey(point.name)
													else
														routeData.name = point.name
													end
													if not point.point then
														routeData.x = point.x
														routeData.y = point.y
													else
														routeData.point = point
															.point --it's possible that the ME could move to the point = Vec2 notation.
													end
													routeData.form = point.action
													routeData.speed = point.speed
													routeData.alt = point.alt
													routeData.alt_type = point.alt_type
													routeData.airdromeId = point.airdromeId
													routeData.helipadId = point.helipadId
													routeData.type = point.type
													routeData.action = point.action
													if task then
														routeData.task = point.task
													end
													points[point_num] = routeData
												end

												return points
											end
											log:error('Group route not defined in mission editor for groupId: $1', gpId)
											return
										end --if group_data and group_data.name and group_data.name == 'groupname'
									end --for group_num, group_data in pairs(obj_cat_data.group) do
								end --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
							end --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
						end --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
					end --for cntry_id, cntry_data in pairs(coa_data.country) do
				end --if coa_data.country then --there is a country table
			end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
		end   --for coa_name, coa_data in pairs(mission.coalition) do
	end

	-- function mist.ground.buildPath() end -- ????

	function mist.ground.patrolRoute(vars)
		--log:info('patrol')
		local tempRoute = {}
		local useRoute = {}
		local gpData = vars.gpData
		if type(gpData) == 'string' then
			gpData = Group.getByName(gpData)
		end

		local useGroupRoute
		if not vars.useGroupRoute then
			useGroupRoute = vars.gpData
		else
			useGroupRoute = vars.useGroupRoute
		end
		local routeProvided = false
		if not vars.route then
			if useGroupRoute then
				tempRoute = mist.getGroupRoute(useGroupRoute)
			end
		else
			useRoute = vars.route
			local posStart = mist.getLeadPos(gpData)
			useRoute[1] = mist.ground.buildWP(posStart, useRoute[1].action, useRoute[1].speed)
			routeProvided = true
		end


		local overRideSpeed = vars.speed or 'default'
		local pType = vars.pType
		local offRoadForm = vars.offRoadForm or 'default'
		local onRoadForm = vars.onRoadForm or 'default'

		if routeProvided == false and #tempRoute > 0 then
			local posStart = mist.getLeadPos(gpData)


			useRoute[#useRoute + 1] = mist.ground.buildWP(posStart, offRoadForm, overRideSpeed)
			for i = 1, #tempRoute do
				local tempForm = tempRoute[i].action
				local tempSpeed = tempRoute[i].speed

				if offRoadForm == 'default' then
					tempForm = tempRoute[i].action
				end
				if onRoadForm == 'default' then
					onRoadForm = 'On Road'
				end
				if (string.lower(tempRoute[i].action) == 'on road' or string.lower(tempRoute[i].action) == 'onroad' or string.lower(tempRoute[i].action) == 'on_road') then
					tempForm = onRoadForm
				else
					tempForm = offRoadForm
				end

				if type(overRideSpeed) == 'number' then
					tempSpeed = overRideSpeed
				end


				useRoute[#useRoute + 1] = mist.ground.buildWP(tempRoute[i], tempForm, tempSpeed)
			end

			if pType and string.lower(pType) == 'doubleback' then
				local curRoute = mist.utils.deepCopy(useRoute)
				for i = #curRoute, 2, -1 do
					useRoute[#useRoute + 1] = mist.ground.buildWP(curRoute[i], curRoute[i].action, curRoute[i].speed)
				end
			end

			useRoute[1].action = useRoute[#useRoute].action -- make it so the first WP matches the last WP
		end

		local cTask3 = {}
		local newPatrol = {}
		newPatrol.route = useRoute
		newPatrol.gpData = gpData:getName()
		cTask3[#cTask3 + 1] = 'mist.ground.patrolRoute('
		cTask3[#cTask3 + 1] = mist.utils.oneLineSerialize(newPatrol)
		cTask3[#cTask3 + 1] = ')'
		cTask3 = table.concat(cTask3)
		local tempTask = {
			id = 'WrappedAction',
			params = {
				action = {
					id = 'Script',
					params = {
						command = cTask3,

					},
				},
			},
		}

		useRoute[#useRoute].task = tempTask
		log:info(useRoute)
		mist.goRoute(gpData, useRoute)

		return
	end

	function mist.insertTaskToWP(wp, task)
		if not wp.task then
			wp.task = { ["id"] = "ComboTask", ["params"] = { tasks = {} } }
		end
		table.insert(wp.task.params.tasks, task)
	end

	function mist.ground.patrol(gpData, pType, form, speed)
		local vars = {}

		if type(gpData) == 'table' and gpData:getName() then
			gpData = gpData:getName()
		end

		vars.useGroupRoute = gpData
		vars.gpData = gpData
		vars.pType = pType
		vars.offRoadForm = form
		vars.speed = speed

		mist.ground.patrolRoute(vars)

		return
	end

	-- No longer accepts path
	function mist.ground.buildWP(point, overRideForm, overRideSpeed)
		local wp = {}
		wp.x = point.x

		if point.z then
			wp.y = point.z
		else
			wp.y = point.y
		end
		local form, speed

		if point.speed and not overRideSpeed then
			wp.speed = point.speed
		elseif type(overRideSpeed) == 'number' then
			wp.speed = overRideSpeed
		else
			wp.speed = mist.utils.kmphToMps(20)
		end

		if point.form and not overRideForm then
			form = point.form
		else
			form = overRideForm
		end

		if not form then
			wp.action = 'Cone'
		else
			form = string.lower(form)
			if form == 'off_road' or form == 'off road' then
				wp.action = 'Off Road'
			elseif form == 'on_road' or form == 'on road' then
				wp.action = 'On Road'
			elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest' then
				wp.action = 'Rank'
			elseif form == 'cone' then
				wp.action = 'Cone'
			elseif form == 'diamond' then
				wp.action = 'Diamond'
			elseif form == 'vee' then
				wp.action = 'Vee'
			elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
				wp.action = 'EchelonL'
			elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
				wp.action = 'EchelonR'
			else
				wp.action = 'Cone' -- if nothing matched
			end
		end

		wp.type = 'Turning Point'

		return wp
	end

	function mist.fixedWing.buildWP(point, WPtype, speed, alt, altType)
		local wp = {}
		wp.x = point.x

		if point.z then
			wp.y = point.z
		else
			wp.y = point.y
		end

		if alt and type(alt) == 'number' then
			wp.alt = alt
		else
			wp.alt = 2000
		end

		if altType then
			altType = string.lower(altType)
			if altType == 'radio' or altType == 'agl' then
				wp.alt_type = 'RADIO'
			elseif altType == 'baro' or altType == 'asl' then
				wp.alt_type = 'BARO'
			end
		else
			wp.alt_type = 'RADIO'
		end

		if point.speed then
			speed = point.speed
		end

		if point.type then
			WPtype = point.type
		end

		if not speed then
			wp.speed = mist.utils.kmphToMps(500)
		else
			wp.speed = speed
		end

		if not WPtype then
			wp.action = 'Turning Point'
		else
			WPtype = string.lower(WPtype)
			if WPtype == 'flyover' or WPtype == 'fly over' or WPtype == 'fly_over' then
				wp.action = 'Fly Over Point'
			elseif WPtype == 'turningpoint' or WPtype == 'turning point' or WPtype == 'turning_point' then
				wp.action = 'Turning Point'
			else
				wp.action = 'Turning Point'
			end
		end

		wp.type = 'Turning Point'
		return wp
	end

	function mist.heli.buildWP(point, WPtype, speed, alt, altType)
		local wp = {}
		wp.x = point.x

		if point.z then
			wp.y = point.z
		else
			wp.y = point.y
		end

		if alt and type(alt) == 'number' then
			wp.alt = alt
		else
			wp.alt = 500
		end

		if altType then
			altType = string.lower(altType)
			if altType == 'radio' or altType == 'agl' then
				wp.alt_type = 'RADIO'
			elseif altType == 'baro' or altType == 'asl' then
				wp.alt_type = 'BARO'
			end
		else
			wp.alt_type = 'RADIO'
		end

		if point.speed then
			speed = point.speed
		end

		if point.type then
			WPtype = point.type
		end

		if not speed then
			wp.speed = mist.utils.kmphToMps(200)
		else
			wp.speed = speed
		end

		if not WPtype then
			wp.action = 'Turning Point'
		else
			WPtype = string.lower(WPtype)
			if WPtype == 'flyover' or WPtype == 'fly over' or WPtype == 'fly_over' then
				wp.action = 'Fly Over Point'
			elseif WPtype == 'turningpoint' or WPtype == 'turning point' or WPtype == 'turning_point' then
				wp.action = 'Turning Point'
			else
				wp.action = 'Turning Point'
			end
		end

		wp.type = 'Turning Point'
		return wp
	end

	-- need to return a Vec3 or Vec2?
	function mist.getRandPointInCircle(p, r, innerRadius, maxA, minA)
		local point = mist.utils.makeVec3(p)
		local theta = 2 * math.pi * math.random()
		local radius = r or 1000
		local minR = innerRadius or 0
		if maxA and not minA then
			theta = math.rad(math.random(0, maxA - math.random()))
		elseif maxA and minA then
			if minA < maxA then
				theta = math.rad(math.random(minA, maxA) - math.random())
			else
				theta = math.rad(math.random(maxA, minA) - math.random())
			end
		end
		local rad = math.random() + math.random()
		if rad > 1 then
			rad = 2 - rad
		end

		local radMult
		if minR and minR <= radius then
			--radMult = (radius - innerRadius)*rad + innerRadius
			radMult = radius * math.sqrt((minR ^ 2 + (radius ^ 2 - minR ^ 2) * math.random()) / radius ^ 2)
		else
			radMult = radius * rad
		end

		local rndCoord
		if radius > 0 then
			rndCoord = { x = math.cos(theta) * radMult + point.x, y = math.sin(theta) * radMult + point.z }
		else
			rndCoord = { x = point.x, y = point.z }
		end
		return rndCoord
	end

	function mist.getRandomPointInZone(zoneName, innerRadius, maxA, minA)
		if type(zoneName) == 'string' then
			local zone = mist.DBs.zonesByName[zoneName]
			if zone.type and zone.type == 2 then
				return mist.getRandomPointInPoly(zone.verticies)
			else
				return mist.getRandPointInCircle(zone.point, zone.radius, innerRadius, maxA, minA)
			end
		end
		return false
	end

	function mist.getRandomPointInPoly(zone)
		--env.info('Zone Size: '.. #zone)
		local avg = mist.getAvgPoint(zone)
		--log:warn(avg)
		local radius = 0
		local minR = math.huge
		local newCoord = {}
		for i = 1, #zone do
			if mist.utils.get2DDist(avg, zone[i]) > radius then
				radius = mist.utils.get2DDist(avg, zone[i])
			end
			if mist.utils.get2DDist(avg, zone[i]) < minR then
				minR = mist.utils.get2DDist(avg, zone[i])
			end
		end
		--log:warn('minR: $1', minR)
		--log:warn('Radius: $1', radius)
		local lSpawnPos = {}
		for j = 1, 100 do
			newCoord = mist.getRandPointInCircle(avg, radius)
			if mist.pointInPolygon(newCoord, zone) then
				break
			end
			if j == 100 then
				newCoord = mist.getRandPointInCircle(avg, radius)
				log:warn("Failed to find point in poly; Giving random point from center of the poly")
			end
		end
		return newCoord
	end

	function mist.getWindBearingAndVel(p)
		local point = mist.utils.makeVec3(p)
		local gLevel = land.getHeight({ x = point.x, y = point.z })
		if point.y <= gLevel then
			point.y = gLevel + 10
		end
		local t = atmosphere.getWind(point)
		local bearing = math.atan2(t.z, t.x)
		local vel = math.sqrt(t.x ^ 2 + t.z ^ 2)
		return bearing, vel
	end

	function mist.groupToRandomPoint(vars)
		local group = vars.group --Required
		local point = vars.point --required
		local radius = vars.radius or 0
		local innerRadius = vars.innerRadius
		local form = vars.form or 'Cone'
		local heading = vars.heading or math.random() * 2 * math.pi
		local headingDegrees = vars.headingDegrees
		local speed = vars.speed or mist.utils.kmphToMps(20)


		local useRoads
		if not vars.disableRoads then
			useRoads = true
		else
			useRoads = false
		end

		local path = {}

		if headingDegrees then
			heading = headingDegrees * math.pi / 180
		end

		if heading >= 2 * math.pi then
			heading = heading - 2 * math.pi
		end

		local rndCoord = mist.getRandPointInCircle(point, radius, innerRadius)

		local offset = {}
		local posStart = mist.getLeadPos(group)
		if posStart then
			offset.x = mist.utils.round(math.sin(heading - (math.pi / 2)) * 50 + rndCoord.x, 3)
			offset.z = mist.utils.round(math.cos(heading + (math.pi / 2)) * 50 + rndCoord.y, 3)
			path[#path + 1] = mist.ground.buildWP(posStart, form, speed)


			if useRoads == true and ((point.x - posStart.x) ^ 2 + (point.z - posStart.z) ^ 2) ^ 0.5 > radius * 1.3 then
				path[#path + 1] = mist.ground.buildWP({ x = posStart.x + 11, z = posStart.z + 11 }, 'off_road', speed)
				path[#path + 1] = mist.ground.buildWP(posStart, 'on_road', speed)
				path[#path + 1] = mist.ground.buildWP(offset, 'on_road', speed)
			else
				path[#path + 1] = mist.ground.buildWP({ x = posStart.x + 25, z = posStart.z + 25 }, form, speed)
			end
		end
		path[#path + 1] = mist.ground.buildWP(offset, form, speed)
		path[#path + 1] = mist.ground.buildWP(rndCoord, form, speed)

		mist.goRoute(group, path)

		return
	end

	function mist.groupRandomDistSelf(gpData, dist, form, heading, speed, disableRoads)
		local pos = mist.getLeadPos(gpData)
		local fakeZone = {}
		fakeZone.radius = dist or math.random(300, 1000)
		fakeZone.point = { x = pos.x, y = pos.y, z = pos.z }
		mist.groupToRandomZone(gpData, fakeZone, form, heading, speed, disableRoads)

		return
	end

	function mist.groupToRandomZone(gpData, zone, form, heading, speed, disableRoads)
		if type(gpData) == 'string' then
			gpData = Group.getByName(gpData)
		end

		if type(zone) == 'string' then
			zone = mist.DBs.zonesByName[zone]
		elseif type(zone) == 'table' and not zone.radius then
			zone = mist.DBs.zonesByName[zone[math.random(1, #zone)]]
		end

		if speed then
			speed = mist.utils.kmphToMps(speed)
		end

		local vars = {}
		vars.group = gpData
		vars.radius = zone.radius
		vars.form = form
		vars.headingDegrees = heading
		vars.speed = speed
		vars.point = mist.utils.zoneToVec3(zone)
		vars.disableRoads = disableRoads
		mist.groupToRandomPoint(vars)

		return
	end

	function mist.isTerrainValid(coord, terrainTypes) -- vec2/3 and enum or table of acceptable terrain types
		if coord.z then
			coord.y = coord.z
		end
		local typeConverted = {}

		if type(terrainTypes) == 'string' then -- if its a string it does this check
			for constId, constData in pairs(land.SurfaceType) do
				if string.lower(constId) == string.lower(terrainTypes) or string.lower(constData) == string.lower(terrainTypes) then
					table.insert(typeConverted, constId)
				end
			end
		elseif type(terrainTypes) == 'table' then -- if its a table it does this check
			for typeId, typeData in pairs(terrainTypes) do
				for constId, constData in pairs(land.SurfaceType) do
					if string.lower(constId) == string.lower(typeData) or string.lower(constData) == string.lower(typeData) then
						table.insert(typeConverted, constId)
					end
				end
			end
		end
		for validIndex, validData in pairs(typeConverted) do
			if land.getSurfaceType(coord) == land.SurfaceType[validData] then
				log:info('Surface is : $1', validData)
				return true
			end
		end
		return false
	end

	function mist.terrainHeightDiff(coord, searchSize)
		local samples = {}
		local searchRadius = 5
		if searchSize then
			searchRadius = searchSize
		end
		if type(coord) == 'string' then
			coord = mist.utils.zoneToVec3(coord)
		end

		coord = mist.utils.makeVec2(coord)

		samples[#samples + 1] = land.getHeight(coord)
		for i = 0, 360, 30 do
			samples[#samples + 1] = land.getHeight({ x = (coord.x + (math.sin(math.rad(i)) * searchRadius)), y = (coord.y + (math.cos(math.rad(i)) * searchRadius)) })
			if searchRadius >= 20 then -- if search radius is sorta large, take a sample halfway between center and outer edge
				samples[#samples + 1] = land.getHeight({ x = (coord.x + (math.sin(math.rad(i)) * (searchRadius / 2))), y = (coord.y + (math.cos(math.rad(i)) * (searchRadius / 2))) })
			end
		end
		local tMax, tMin = 0, 1000000
		for index, height in pairs(samples) do
			if height > tMax then
				tMax = height
			end
			if height < tMin then
				tMin = height
			end
		end
		return mist.utils.round(tMax - tMin, 2)
	end

	function mist.groupToPoint(gpData, point, form, heading, speed, useRoads)
		if type(point) == 'string' then
			point = mist.DBs.zonesByName[point]
		end
		if speed then
			speed = mist.utils.kmphToMps(speed)
		end

		local vars = {}
		vars.group = gpData
		vars.form = form
		vars.headingDegrees = heading
		vars.speed = speed
		vars.disableRoads = useRoads
		vars.point = mist.utils.zoneToVec3(point)
		mist.groupToRandomPoint(vars)

		return
	end

	function mist.getLeadPos(group)
		local gObj
		if type(group) == 'string' then -- group name
			gObj = Group.getByName(group)
		elseif type(group) == "table" then
			gObj = group
		end

		if gObj then
			local units = gObj:getUnits()

			local leader = units[1]
			if leader then
				if Unit.isExist(leader) then
					return leader:getPoint()
				elseif #units > 1 then
					for i = 2, #units do
						if Unit.isExist(units[i]) then
							return units[i]:getPoint()
						end
					end
				end
			end
		end
		log:error("Group passed to mist.getLeadPos might be dead: $1", group)
	end

	function mist.groupIsDead(groupName) -- copy more or less from on station
		local gp = Group.getByName(groupName)
		if gp then
			if #gp:getUnits() > 0 and gp:isExist() == true then
				return false
			end
		end
		return true
	end

	function mist.pointInZone(point, zone)
		local ref = mist.utils.deepCopy(zone)
		if type(zone) == 'string' then
			ref = mist.DBs.zonesByName[zone]
		end
		if ref.verticies then
			return mist.pointInPolygon(point, ref.verticies)
		else
			return mist.utils.get2DDist(point, ref.point) < ref.radius
		end
	end
end

--- Database tables.
-- @section mist.DBs

--- Mission data
-- @table mist.DBs.missionData
-- @field startTime mission start time
-- @field theatre mission theatre/map e.g. Caucasus
-- @field version mission version
-- @field files mission resources

--- Tables used as parameters.
-- @section varTables

--- mist.flagFunc.units_in_polygon parameter table.
-- @table unitsInPolygonVars
-- @tfield table unit name table @{UnitNameTable}.
-- @tfield table zone table defining a polygon.
-- @tfield number|string flag flag to set to true.
-- @tfield[opt] number|string stopflag if set to true the function
-- will stop evaluating.
-- @tfield[opt] number maxalt maximum altitude (MSL) for the
-- polygon.
-- @tfield[opt] number req_num minimum number of units that have
-- to be in the polygon.
-- @tfield[opt] number interval sets the interval for
-- checking if units are inside of the polygon in seconds. Default: 1.
-- @tfield[opt] boolean toggle switch the flag to false if required
-- conditions are not met. Default: false.
-- @tfield[opt] table unitTableDef
--- Logger class.
-- @type mist.Logger
do -- mist.Logger scope
	mist.Logger = {}

	--- parses text and substitutes keywords with values from given array.
	-- @param text string containing keywords to substitute with values
	-- or a variable.
	-- @param ... variables to use for substitution in string.
	-- @treturn string new string with keywords substituted or
	-- value of variable as string.
	local function formatText(text, ...)
		if type(text) ~= 'string' then
			if type(text) == 'table' then
				text = mist.utils.oneLineSerialize(text)
			else
				text = tostring(text)
			end
		else
			for index, value in ipairs(arg) do
				-- TODO: check for getmetatabel(value).__tostring
				if type(value) == 'table' then
					value = mist.utils.oneLineSerialize(value)
				else
					value = tostring(value)
				end
				text = text:gsub('$' .. index, value)
			end
		end
		local fName = nil
		local cLine = nil
		if debug then
			local dInfo = debug.getinfo(3)
			fName = dInfo.name
			cLine = dInfo.currentline
			-- local fsrc = dinfo.short_src
			--local fLine = dInfo.linedefined
		end
		if fName and cLine then
			return fName .. '|' .. cLine .. ': ' .. text
		elseif cLine then
			return cLine .. ': ' .. text
		else
			return ' ' .. text
		end
	end

	local function splitText(text)
		local tbl = {}
		while text:len() > 4000 do
			local sub = text:sub(1, 4000)
			text = text:sub(4001)
			table.insert(tbl, sub)
		end
		table.insert(tbl, text)
		return tbl
	end

	--- Creates a new logger.
	-- Each logger has it's own tag and log level.
	-- @tparam string tag tag which appears at the start of
	-- every log line produced by this logger.
	-- @tparam[opt] number|string level the log level defines which messages
	-- will be logged and which will be omitted. Log level 3 beeing the most verbose
	-- and 0 disabling all output. This can also be a string. Allowed strings are:
	-- "none" (0), "error" (1), "warning" (2) and "info" (3).
	-- @usage myLogger = mist.Logger:new("MyScript")
	-- @usage myLogger = mist.Logger:new("MyScript", 2)
	-- @usage myLogger = mist.Logger:new("MyScript", "info")
	-- @treturn mist.Logger
	function mist.Logger:new(tag, level)
		local l = { tag = tag }
		setmetatable(l, self)
		self.__index = self
		l:setLevel(level)
		return l
	end

	--- Sets the level of verbosity for this logger.
	-- @tparam[opt] number|string level the log level defines which messages
	-- will be logged and which will be omitted. Log level 3 beeing the most verbose
	-- and 0 disabling all output. This can also[ be a string. Allowed strings are:
	-- "none" (0), "error" (1), "warning" (2) and "info" (3).
	-- @usage myLogger:setLevel("info")
	-- @usage -- log everything
	--myLogger:setLevel(3)
	function mist.Logger:setLevel(level)
		self.level = 2
		if level then
			if type(level) == 'string' then
				level = string.lower(level)
				if level == 'none' or level == 'off' then
					self.level = 0
				elseif level == 'error' then
					self.level = 1
				elseif level == 'warning' or level == 'warn' then
					self.level = 2
				elseif level == 'info' then
					self.level = 3
				end
			elseif type(level) == 'number' then
				self.level = level
			end
		end
	end

	--- Logs error and shows alert window.
	-- This logs an error to the dcs.log and shows a popup window,
	-- pausing the simulation. This works always even if logging is
	-- disabled by setting a log level of "none" or 0.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @usage myLogger:alert("Shit just hit the fan! WEEEE!!!11")
	function mist.Logger:alert(text, ...)
		text = formatText(text, unpack(arg))
		if text:len() > 4000 then
			local texts = splitText(text)
			for i = 1, #texts do
				if i == 1 then
					env.error(self.tag .. '|' .. texts[i], true)
				else
					env.error(texts[i])
				end
			end
		else
			env.error(self.tag .. '|' .. text, true)
		end
	end

	--- Logs a message, disregarding the log level.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @usage myLogger:msg("Always logged!")
	function mist.Logger:msg(text, ...)
		text = formatText(text, unpack(arg))
		if text:len() > 4000 then
			local texts = splitText(text)
			for i = 1, #texts do
				if i == 1 then
					env.info(self.tag .. '|' .. texts[i])
				else
					env.info(texts[i])
				end
			end
		else
			env.info(self.tag .. '|' .. text)
		end
	end

	--- Logs an error.
	-- logs a message prefixed with this loggers tag to dcs.log as
	-- long as at least the "error" log level (1) is set.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @usage myLogger:error("Just an error!")
	-- @usage myLogger:error("Foo is $1 instead of $2", foo, "bar")
	function mist.Logger:error(text, ...)
		if self.level >= 1 then
			text = formatText(text, unpack(arg))
			if text:len() > 4000 then
				local texts = splitText(text)
				for i = 1, #texts do
					if i == 1 then
						env.error(self.tag .. '|' .. texts[i])
					else
						env.error(texts[i])
					end
				end
			else
				env.error(self.tag .. '|' .. text, mistSettings.errorPopup)
			end
		end
	end

	--- Logs a message, disregarding the log level and displays a message out text box.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @usage myLogger:msg("Always logged!")

	function mist.Logger:echo(text, ...)
		text = formatText(text, unpack(arg))
		if text:len() > 4000 then
			local texts = splitText(text)
			for i = 1, #texts do
				if i == 1 then
					env.info(self.tag .. '|' .. texts[i])
				else
					env.info(texts[i])
				end
			end
		else
			env.info(self.tag .. '|' .. text)
		end
		trigger.action.outText(text, 30)
	end

	--- Logs a warning.
	-- logs a message prefixed with this loggers tag to dcs.log as
	-- long as at least the "warning" log level (2) is set.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @usage myLogger:warn("Mother warned you! Those $1 from the interwebs are $2", {"geeks", 1337})
	function mist.Logger:warn(text, ...)
		if self.level >= 2 then
			text = formatText(text, unpack(arg))
			if text:len() > 4000 then
				local texts = splitText(text)
				for i = 1, #texts do
					if i == 1 then
						env.warning(self.tag .. '|' .. texts[i])
					else
						env.warning(texts[i])
					end
				end
			else
				env.warning(self.tag .. '|' .. text, mistSettings.warnPopup)
			end
		end
	end

	--- Logs a info.
	-- logs a message prefixed with this loggers tag to dcs.log as
	-- long as the highest log level (3) "info" is set.
	-- @tparam string text the text with keywords to substitute.
	-- @param ... variables to be used for substitution.
	-- @see warn
	function mist.Logger:info(text, ...)
		if self.level >= 3 then
			text = formatText(text, unpack(arg))
			if text:len() > 4000 then
				local texts = splitText(text)
				for i = 1, #texts do
					if i == 1 then
						env.info(self.tag .. '|' .. texts[i])
					else
						env.info(texts[i])
					end
				end
			else
				env.info(self.tag .. '|' .. text, mistSettings.infoPopup)
			end
		end
	end
end


-- initialize mist
mist.init()
env.info(('Mist version ' .. mist.majorVersion .. '.' .. mist.minorVersion .. '.' .. mist.build .. ' loaded.'))

-- vim: noet:ts=2:sw=2
-- End : mist.lua 
-- ==================================================================================================== 
-- Start : CTLD-i18n.lua 
--[[
    Combat Troop and Logistics Drop - Internationalization (I18N) - French, Spanish and Korean translations

    Dear translators: find the english version in the main CTLD.lua file (it's called `ctld.i18n["en"]`) and use it as a template to build your translation.

    Hall of fame:
    - FullGas1 (concept, FR and ES translations)
    - rising_star (KO translation)
]]
if not ctld then ctld = {} end -- DONT REMOVE!
ctld.i18n = {}

-- These are the string translations
-- If you want to change the text then do so here
-- If you want to add a new language then create a new block
-- following the same format as the current ones

--========  FRENCH - FRANCAIS =====================================================================================
ctld.i18n["fr"] = {}
ctld.i18n["fr"].translation_version =
"1.6" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "fr"; env.info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
    tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["fr"]["Standard Group"] = "Groupe standard"
ctld.i18n["fr"]["Anti Air"] = "Défense aérienne"
ctld.i18n["fr"]["Anti Tank"] = "Anti Tank"
ctld.i18n["fr"]["Mortar Squad"] = "Groupe mortier"
ctld.i18n["fr"]["JTAC Group"] = "Groupe JTAC"
ctld.i18n["fr"]["Single JTAC"] = "JTAC seul"
ctld.i18n["fr"]["2x - Standard Groups"] = "2x - Groupes standards"
ctld.i18n["fr"]["2x - Anti Air"] = "2x - Défenses aériennes"
ctld.i18n["fr"]["2x - Anti Tank"] = "2x - Anti Tank"
ctld.i18n["fr"]["2x - Standard Groups + 2x Mortar"] = "2x - Groupes standards + 2x Groupes mortiers"
ctld.i18n["fr"]["3x - Standard Groups"] = "3x - Groupes standards"
ctld.i18n["fr"]["3x - Anti Air"] = "3x - Défenses aériennes"
ctld.i18n["fr"]["3x - Anti Tank"] = "3x - Anti Tank"
ctld.i18n["fr"]["3x - Mortar Squad"] = "3x - Groupes mortiers"
ctld.i18n["fr"]["5x - Mortar Squad"] = "5x - Groupes mortiers"
ctld.i18n["fr"]["Mortar Squad Red"] = "Groupe mortier rouge"

--- crates names
ctld.i18n["fr"]["Humvee - MG"] = ""
ctld.i18n["fr"]["Humvee - TOW"] = ""
ctld.i18n["fr"]["Light Tank - MRAP"] = ""
ctld.i18n["fr"]["Med Tank - LAV-25"] = ""
ctld.i18n["fr"]["Heavy Tank - Abrams"] = ""
ctld.i18n["fr"]["BTR-D"] = ""
ctld.i18n["fr"]["BRDM-2"] = ""
ctld.i18n["fr"]["Hummer - JTAC"] = ""
ctld.i18n["fr"]["M-818 Ammo Truck"] = ""
ctld.i18n["fr"]["M-978 Tanker"] = ""
ctld.i18n["fr"]["SKP-11 - JTAC"] = ""
ctld.i18n["fr"]["Ural-375 Ammo Truck"] = ""
ctld.i18n["fr"]["KAMAZ Ammo Truck"] = ""
ctld.i18n["fr"]["EWR Radar"] = ""
ctld.i18n["fr"]["FOB Crate - Small"] = ""
ctld.i18n["fr"]["MQ-9 Repear - JTAC"] = ""
ctld.i18n["fr"]["RQ-1A Predator - JTAC"] = ""
ctld.i18n["fr"]["MLRS"] = ""
ctld.i18n["fr"]["SpGH DANA"] = ""
ctld.i18n["fr"]["T155 Firtina"] = ""
ctld.i18n["fr"]["Howitzer"] = ""
ctld.i18n["fr"]["SPH 2S19 Msta"] = ""
ctld.i18n["fr"]["M1097 Avenger"] = ""
ctld.i18n["fr"]["M48 Chaparral"] = ""
ctld.i18n["fr"]["Roland ADS"] = ""
ctld.i18n["fr"]["Gepard AAA"] = ""
ctld.i18n["fr"]["LPWS C-RAM"] = ""
ctld.i18n["fr"]["9K33 Osa"] = ""
ctld.i18n["fr"]["9P31 Strela-1"] = ""
ctld.i18n["fr"]["9K35M Strela-10"] = ""
ctld.i18n["fr"]["9K331 Tor"] = ""
ctld.i18n["fr"]["2K22 Tunguska"] = ""
ctld.i18n["fr"]["HAWK Launcher"] = ""
ctld.i18n["fr"]["HAWK Search Radar"] = ""
ctld.i18n["fr"]["HAWK Track Radar"] = ""
ctld.i18n["fr"]["HAWK PCP"] = ""
ctld.i18n["fr"]["HAWK CWAR"] = ""
ctld.i18n["fr"]["HAWK Repair"] = ""
ctld.i18n["fr"]["NASAMS Launcher 120C"] = ""
ctld.i18n["fr"]["NASAMS Search/Track Radar"] = ""
ctld.i18n["fr"]["NASAMS Command Post"] = ""
ctld.i18n["fr"]["NASAMS Repair"] = ""
ctld.i18n["fr"]["KUB Launcher"] = ""
ctld.i18n["fr"]["KUB Radar"] = ""
ctld.i18n["fr"]["KUB Repair"] = ""
ctld.i18n["fr"]["BUK Launcher"] = ""
ctld.i18n["fr"]["BUK Search Radar"] = ""
ctld.i18n["fr"]["BUK CC Radar"] = ""
ctld.i18n["fr"]["BUK Repair"] = ""
ctld.i18n["fr"]["Patriot Launcher"] = ""
ctld.i18n["fr"]["Patriot Radar"] = ""
ctld.i18n["fr"]["Patriot ECS"] = ""
ctld.i18n["fr"]["Patriot ICC"] = ""
ctld.i18n["fr"]["Patriot EPP"] = ""
ctld.i18n["fr"]["Patriot AMG (optional)"] = ""
ctld.i18n["fr"]["Patriot Repair"] = ""
ctld.i18n["fr"]["S-300 Grumble TEL C"] = ""
ctld.i18n["fr"]["S-300 Grumble Flap Lid-A TR"] = ""
ctld.i18n["fr"]["S-300 Grumble Clam Shell SR"] = ""
ctld.i18n["fr"]["S-300 Grumble Big Bird SR"] = ""
ctld.i18n["fr"]["S-300 Grumble C2"] = ""
ctld.i18n["fr"]["S-300 Repair"] = ""
ctld.i18n["fr"]["Humvee - TOW - All crates"] = "Humvee - TOW - Toutes les caisses"
ctld.i18n["fr"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Toutes les caisses"
ctld.i18n["fr"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Toutes les caisses"
ctld.i18n["fr"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Toutes les caisses"
ctld.i18n["fr"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Toutes les caisses"
ctld.i18n["fr"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["M-978 Tanker - All crates"] = "M-978 Tanker - Toutes les caisses"
ctld.i18n["fr"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["EWR Radar - All crates"] = "EWR Radar - Toutes les caisses"
ctld.i18n["fr"]["MLRS - All crates"] = "MLRS - Toutes les caisses"
ctld.i18n["fr"]["SpGH DANA - All crates"] = "SpGH DANA - Toutes les caisses"
ctld.i18n["fr"]["T155 Firtina - All crates"] = "T155 Firtina - Toutes les caisses"
ctld.i18n["fr"]["Howitzer - All crates"] = "Howitzer - Toutes les caisses"
ctld.i18n["fr"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Toutes les caisses"
ctld.i18n["fr"]["M1097 Avenger - All crates"] = "M1097 Avenger - Toutes les caisses"
ctld.i18n["fr"]["M48 Chaparral - All crates"] = "M48 Chaparral - Toutes les caisses"
ctld.i18n["fr"]["Roland ADS - All crates"] = "Roland ADS - Toutes les caisses"
ctld.i18n["fr"]["Gepard AAA - All crates"] = "Gepard AAA - Toutes les caisses"
ctld.i18n["fr"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Toutes les caisses"
ctld.i18n["fr"]["9K33 Osa - All crates"] = "9K33 Osa - Toutes les caisses"
ctld.i18n["fr"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Toutes les caisses"
ctld.i18n["fr"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Toutes les caisses"
ctld.i18n["fr"]["9K331 Tor - All crates"] = "9K331 Tor - Toutes les caisses"
ctld.i18n["fr"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Toutes les caisses"
ctld.i18n["fr"]["HAWK - All crates"] = "HAWK - Toutes les caisses"
ctld.i18n["fr"]["NASAMS - All crates"] = "NASAMS - Toutes les caisses"
ctld.i18n["fr"]["KUB - All crates"] = "KUB - Toutes les caisses"
ctld.i18n["fr"]["BUK - All crates"] = "BUK - Toutes les caisses"
ctld.i18n["fr"]["Patriot - All crates"] = "Patriot - Toutes les caisses"
ctld.i18n["fr"]["Patriot - All crates"] = "Patriot - Toutes les caisses"

--- mission design error messages
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find trigger called %1"] =
"CTLD.lua ERREUR : Impossible de trouver le déclencheur appelé %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone called %1"] =
"CTLD.lua ERREUR : Impossible de trouver la zone appelée %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone or ship called %1"] =
"CTLD.lua ERREUR : Impossible de trouver la zone ou le navire appelé %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find crate with weight %1"] =
"CTLD.lua ERREUR : Impossible de trouver une caisse avec un poids de %1"

--- runtime messages
ctld.i18n["fr"]["You are not close enough to friendly logistics to get a crate!"] =
"Vous n'êtes pas assez proche de la logistique alliée pour obtenir une caisse !"
ctld.i18n["fr"]["No more JTAC Crates Left!"] = "Plus de caisses JTAC disponibles !"
ctld.i18n["fr"]["Sorry you must wait %1 seconds before you can get another crate"] =
"Désolé, vous devez attendre %1 secondes avant de pouvoir obtenir une autre caisse"
ctld.i18n["fr"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"Une caisse %1 pesant %2 kg a été apportée et se trouve à vos %3 heure"
ctld.i18n["fr"]["%1 fast-ropped troops from %2 into combat"] = "%1 a largué rapidement des troupes de %2 au combat"
ctld.i18n["fr"]["%1 dropped troops from %2 into combat"] = "%1 a largué des troupes de %2 au combat"
ctld.i18n["fr"]["%1 fast-ropped troops from %2 into %3"] = "%1 a largué rapidement des troupes de %2 à %3"
ctld.i18n["fr"]["%1 dropped troops from %2 into %3"] = "%1 a largué des troupes de %2 à %3"
ctld.i18n["fr"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"Trop haut ou trop rapide pour larguer des troupes au combat ! Survolez en dessous de %1 pieds ou atterrissez."
ctld.i18n["fr"]["%1 dropped vehicles from %2 into combat"] = "%1 a largué des véhicules de %2 au combat"
ctld.i18n["fr"]["%1 loaded troops into %2"] = "%1 a chargé des troupes dans %2"
ctld.i18n["fr"]["%1 loaded %2 vehicles into %3"] = "%1 a chargé %2 véhicules dans %3"
ctld.i18n["fr"]["%1 delivered a FOB Crate"] = "%1 a livré une caisse FOB"
ctld.i18n["fr"]["Delivered FOB Crate 60m at 6'oclock to you"] = "Caisse FOB livrée à 60 m à 6 heures de vous"
ctld.i18n["fr"]["FOB Crate dropped back to base"] = "Caisse FOB ramenée à la base"
ctld.i18n["fr"]["FOB Crate Loaded"] = "Caisse FOB chargée"
ctld.i18n["fr"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 a chargé une caisse FOB prête à être livrée !"
ctld.i18n["fr"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"Il n'y a pas d'unités logistiques alliée à proximité pour charger une caisse FOB !"
ctld.i18n["fr"]["This area has no more reinforcements available!"] = "Cette zone n'a plus de renforts disponibles !"
ctld.i18n["fr"]["You are not in a pickup zone and no one is nearby to extract"] =
"Vous n'êtes pas dans une zone d'embarquement et personne n'est à proximité pour être extrait."
ctld.i18n["fr"]["You are not in a pickup zone"] = "Vous n'êtes pas dans une zone d'embarquement"
ctld.i18n["fr"]["No one to unload"] = "Personne à débarquer"
ctld.i18n["fr"]["Dropped troops back to base"] = "Troupes larguées à la base"
ctld.i18n["fr"]["Dropped vehicles back to base"] = "Véhicules largués à la base"
ctld.i18n["fr"]["You already have troops onboard."] = "Vous avez déjà des troupes à bord."
ctld.i18n["fr"]["Count Infantries limit in the mission reached, you can't load more troops"] =
"Nombre maximum de troupes sur mission atteint, vous ne pouvez pas charger plus de troupes"
ctld.i18n["fr"]["You already have vehicles onboard."] = "Vous avez déjà des véhicules à bord."
ctld.i18n["fr"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"Désolé - Le groupe de %1 est trop important. \n\nLa limite est de %2 pour %3"
ctld.i18n["fr"]["%1 extracted troops in %2 from combat"] = "%1 troupes extraites du combat en %2"
ctld.i18n["fr"]["No extractable troops nearby!"] = "Aucune troupe extractible à proximité !"
ctld.i18n["fr"]["%1 extracted vehicles in %2 from combat"] = "%1 véhicules extraits du combat en %2"
ctld.i18n["fr"]["No extractable vehicles nearby!"] = "Aucun véhicule extractible à proximité !"
ctld.i18n["fr"]["%1 troops onboard (%2 kg)\n"] = "%1 troupes à bord (%2 kg)\n"
ctld.i18n["fr"]["%1 vehicles onboard (%2)\n"] = "%1 véhicules à bord (%2)\n"
ctld.i18n["fr"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caisse FOB à bord (%1 kg)\n"
ctld.i18n["fr"]["%1 crate onboard (%2 kg)\n"] = "%1 caisse à bord (%2 kg)\n"
ctld.i18n["fr"]["Total weight of cargo : %1 kg\n"] = "Poids total de la cargaison : %1 kg\n"
ctld.i18n["fr"]["No cargo."] = "Aucune cargaison."
ctld.i18n["fr"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"Stationaire au-dessus de la caisse %1. \n\nMaintenez le stationaire pendant %2 secondes ! \n\nSi le compte à rebours s'arrête, vous êtes trop loin !"
ctld.i18n["fr"]["Loaded %1 crate!"] = "Caisse %1 chargée !"
ctld.i18n["fr"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Trop bas pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
ctld.i18n["fr"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Trop haut pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
ctld.i18n["fr"]["You must land before you can load a crate!"] =
"Vous devez atterrir avant de pouvoir charger une caisse !"
ctld.i18n["fr"]["No Crates within 50m to load!"] = "Aucune caisse à moins de 50 m pour charger !"
ctld.i18n["fr"]["Maximum number of crates are on board!"] = "Nombre maximal de caisses à bord !"
ctld.i18n["fr"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caisse - kg %3 - %4 m - %5 heures"
ctld.i18n["fr"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caisse FOB - %1 m - %2 heures\n"
ctld.i18n["fr"]["No Nearby Crates"] = "Aucune caisse à proximité"
ctld.i18n["fr"]["Nearby Crates:\n%1"] = "Caisses à proximité :\n%1"
ctld.i18n["fr"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Caisses FOB à proximité (non chargeables par élingue) :\n%1"
ctld.i18n["fr"]["FOB Positions:"] = "Positions FOB :"
ctld.i18n["fr"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["fr"]["Sorry, there are no active FOBs!"] = "Désolé, il n'y a pas de FOB actif !"
ctld.i18n["fr"]["You can't unpack that here! Take it to where it's needed!"] =
"Vous ne pouvez déballer ça ici ! Emmenez-le là où vous en avez besoin !"
ctld.i18n["fr"]["Sorry you must move this crate before you unpack it!"] =
"Désolé, vous devez déplacer cette caisse avant de la déballer !"
ctld.i18n["fr"]["%1 successfully deployed %2 to the field"] = "%1 a déployé avec succès %2 sur le terrain."
ctld.i18n["fr"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"Aucune caisse alliée n'est suffisamment proche pour être déballée, ou la caisse est trop proche d'un avion."
ctld.i18n["fr"]["Finished building FOB! Crates and Troops can now be picked up."] =
"Construction du FOB terminée ! Les caisses et les troupes peuvent maintenant embarqués."
ctld.i18n["fr"]["Finished building FOB! Crates can now be picked up."] =
"Construction du FOB terminée ! Les caisses peuvent maintenant être embarqués."
ctld.i18n["fr"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 a commencé à construire le FOB en utilisant %2 caisses FOB, il sera terminé dans %3 secondes.\nPosition marquée par le fumigène."
ctld.i18n["fr"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"Impossible de construire le FOB !\n\nIl nécessite %1 grandes caisses FOB (3 petites caisses FOB équivalent à 1 grande caisse FOB) et il y a l'équivalent de %2 grandes caisses FOB à proximité\n\nOu les caisses ne sont pas à moins de 750 m les unes des autres autre"
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, survolez la caisse pendant %1 secondes ou atterrissez et utilisez les commandes de caisse F10."
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour ramasser une caisse, survolez la caisse pendant %1 secondes."
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, atterrissez et utilisez les commandes de caisse F10."
ctld.i18n["fr"]["%1 crate has been safely unhooked and is at your %2 o'clock"] =
"%1 caisse a été décrochée en toute sécurité et se trouve à vos %2 heures"
ctld.i18n["fr"]["%1 crate has been safely dropped below you"] = "%1 caisse a été déposée en toute sécurité sous vous"
ctld.i18n["fr"]["You were too high! The crate has been destroyed"] = "Vous étiez trop haut! La caisse a été détruite"
ctld.i18n["fr"]["Radio Beacons:\n%1"] = "Balises radio :\n%1"
ctld.i18n["fr"]["No Active Radio Beacons"] = "Aucune balise radio active"
ctld.i18n["fr"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 a déployé une balise radio.\n\n%2"
ctld.i18n["fr"]["You need to land before you can deploy a Radio Beacon!"] =
"Vous devez atterrir avant de pouvoir déployer une balise radio !"
ctld.i18n["fr"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 a supprimé une balise radio.\n\n%2"
ctld.i18n["fr"]["No Radio Beacons within 500m."] = "Aucune balise radio à moins de 500m."
ctld.i18n["fr"]["You need to land before remove a Radio Beacon"] =
"Vous devez atterrir avant de retirer une balise radio"
ctld.i18n["fr"]["%1 successfully rearmed a full %2 in the field"] =
"%1 a réarmé avec succès un %2 complet sur le terrain"
ctld.i18n["fr"]["Missing %1\n"] = "%1 manquant\n"
ctld.i18n["fr"]["Out of parts for AA Systems. Current limit is %1\n"] =
"Plus de pièces pour les systèmes AA. La limite actuelle est de %1\n"
ctld.i18n["fr"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"Impossible de construire %1\n%2\n\nOu les caisses ne sont pas assez proches les unes des autres"
ctld.i18n["fr"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 a déployé avec succès un %2 complet sur le terrain. \n\nLa limite du système actif AA est : %3\nActif : %4"
ctld.i18n["fr"]["%1 successfully repaired a full %2 in the field."] =
"%1 a réparé avec succès un %2 complet sur le terrain."
ctld.i18n["fr"]["Cannot repair %1. No damaged %2 within 300m"] =
"Impossible de réparer %1. Aucun %2 endommagé à moins de 300 m"
ctld.i18n["fr"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 a déployé avec succès %2 sur le terrain en utilisant %3 caisses."
ctld.i18n["fr"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"Impossible de construire %1 !\n\nIl faut %2 caisses et il y en a %3 \n\nOu les caisses ne sont pas à moins de 300 m les unes des autres"
ctld.i18n["fr"]["%1 dropped %2 smoke."] = "%1 a largué un fumigène %2."

--- JTAC messages
ctld.i18n["fr"]["JTAC Group %1 KIA!"] = "Groupe JTAC %1 KIA !"
ctld.i18n["fr"]["%1, selected target reacquired, %2"] = "%1, cible sélectionnée réacquise, %2"
ctld.i18n["fr"][". CODE: %1. POSITION: %2"] = ". CODE : %1. POSITION : %2"
ctld.i18n["fr"]["new target, "] = "nouvelle cible, "
ctld.i18n["fr"]["standing by on %1"] = "en attente sur %1"
ctld.i18n["fr"]["lasing %1"] = "laser %1"
ctld.i18n["fr"][", temporarily %1"] = ", temporairement %1"
ctld.i18n["fr"]["target lost"] = "cible perdue"
ctld.i18n["fr"]["target destroyed"] = "cible détruite"
ctld.i18n["fr"][", selected %1"] = ", %1 sélectionné"
ctld.i18n["fr"]["%1 %2 target lost."] = "%1 %2 cible perdue."
ctld.i18n["fr"]["%1 %2 target destroyed."] = "%1 %2 cible détruite."
ctld.i18n["fr"]["JTAC STATUS: \n\n"] = "ÉTAT JTAC : \n\n"
ctld.i18n["fr"][", available on %1 %2,"] = ", disponible sur %1 %2,"
ctld.i18n["fr"]["UNKNOWN"] = "INCONNU"
ctld.i18n["fr"][" targeting "] = " ciblage "
ctld.i18n["fr"][" targeting selected unit "] = " ciblage de l'unité sélectionnée "
ctld.i18n["fr"][" attempting to find selected unit, temporarily targeting "] =
" tentative de recherche de l'unité sélectionnée, ciblage temporaire "
ctld.i18n["fr"]["(Laser OFF) "] = "(Laser INACTIF) "
ctld.i18n["fr"]["Visual On: "] = "Visuel activé : "
ctld.i18n["fr"][" searching for targets %1\n"] = " recherche de cibles %1\n"
ctld.i18n["fr"]["No Active JTACs"] = "Aucun JTAC actif"
ctld.i18n["fr"][", targeting selected unit, %1"] = ", ciblage de l'unité sélectionnée, %1"
ctld.i18n["fr"][". CODE: %1. POSITION: %2"] = ". CODE : %1. POSITION : %2"
ctld.i18n["fr"][", target selection reset."] = ", sélection de cible réinitialisée."
ctld.i18n["fr"]["%1, laser and smokes enabled"] = "%1, laser et fumigènes activés"
ctld.i18n["fr"]["%1, laser and smokes disabled"] = "%1, laser et fumigènes désactivés"
ctld.i18n["fr"]["%1, wind and target speed laser spot compensations enabled"] =
"%1, compensations activées de la vitesse du vent et de la cible pour le spot laser"
ctld.i18n["fr"]["%1, wind and target speed laser spot compensations disabled"] =
"%1, compensations désactivées de la vitesse du vent et de la cible pour le spot laser"
ctld.i18n["fr"]["%1, WHITE smoke deployed near target"] = "%1, fumigène BLANCHE déployée près de la cible"

--- F10 menu messages
ctld.i18n["fr"]["Actions"] = "Actions"
ctld.i18n["fr"]["Troop Transport"] = "Transport troupes"
ctld.i18n["fr"]["Unload / Extract Troops"] = "Débarqt / Embarqt Troupes"
ctld.i18n["fr"]["Next page"] = "page suiv."
ctld.i18n["fr"]["Load "] = "Charger "
ctld.i18n["fr"]["Vehicle / FOB Transport"] = "Transport Vehicule / FOB"
ctld.i18n["fr"]["Crates: Vehicle / FOB / Drone"] = "Caisses Vehicule / FOB / Drone"
ctld.i18n["fr"]["Unload Vehicles"] = "Décharger Vehicles"
ctld.i18n["fr"]["Load / Extract Vehicles"] = "Chargt / Déchargt Vehicules"
ctld.i18n["fr"]["Load / Unload FOB Crate"] = "Chargt / Déchargt Caisse FOB"
ctld.i18n["fr"]["Repack Vehicles"] = "Ré-emballer véhicules"
ctld.i18n["fr"]["CTLD Commands"] = "Commandes CTLD"
ctld.i18n["fr"]["CTLD"] = "CTLD"
ctld.i18n["fr"]["Check Cargo"] = "Vérif° chargement"
ctld.i18n["fr"]["Load Nearby Crate(s)"] = "Charger caisse(s) proche"
ctld.i18n["fr"]["Unpack Any Crate"] = "Déballer caisses"
ctld.i18n["fr"]["Drop Crate(s)"] = "Décharger caisse(s)"
ctld.i18n["fr"]["List Nearby Crates"] = "Liste caisses proches"
ctld.i18n["fr"]["List FOBs"] = "Liste FOBs"
ctld.i18n["fr"]["List Beacons"] = "Liste balises"
ctld.i18n["fr"]["List Radio Beacons"] = "Liste Radio balises"
ctld.i18n["fr"]["Smoke Markers"] = "Marques Fumées"
ctld.i18n["fr"]["Drop Red Smoke"] = "Déposer Fumi Rouge"
ctld.i18n["fr"]["Drop Blue Smoke"] = "Déposer Fumi Bleu"
ctld.i18n["fr"]["Drop Orange Smoke"] = "Déposer Fumi Orange"
ctld.i18n["fr"]["Drop Green Smoke"] = "Déposer Fumi Vert"
ctld.i18n["fr"]["Drop Beacon"] = "Déposer Fumi Vert"
ctld.i18n["fr"]["Radio Beacons"] = "Déposer Balise"
ctld.i18n["fr"]["Remove Closest Beacon"] = "Supprimer Balise +proche"
ctld.i18n["fr"]["JTAC Status"] = "Statut JTAC"
ctld.i18n["fr"]["DISABLE "] = "DESACTIVE "
ctld.i18n["fr"]["ENABLE "] = "ACTIVE "
ctld.i18n["fr"]["REQUEST "] = "DEMANDE"
ctld.i18n["fr"]["Reset TGT Selection"] = "Réinitialiser sélection TGT"
-- F10 RECON menus
ctld.i18n["fr"]["RECON"] = "RECONNAISSANCE"
ctld.i18n["fr"]["Show targets in LOS (refresh)"] = "Marquer cibles visibles sur carte F10"
ctld.i18n["fr"]["Hide targets in LOS"] = "Effacer marques sur carte F10"
ctld.i18n["fr"]["START autoRefresh targets in LOS"] = "Lancer suivi automatique des cibles"
ctld.i18n["fr"]["STOP autoRefresh targets in LOS"] = "Stopper suivi automatique des cibles"

--======  SPANISH : ESPAÑOL====================================================================================
ctld.i18n["es"] = {}
ctld.i18n["es"].translation_version =
"1.6" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "es"; env
    .info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
        tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["es"]["Standard Group"] = "Grupo estándar"
ctld.i18n["es"]["Anti Air"] = "Defensa aérea"
ctld.i18n["es"]["Anti Tank"] = "Antitanque"
ctld.i18n["es"]["Mortar Squad"] = "Grupo mortero"
ctld.i18n["es"]["JTAC Group"] = "Grupo JTAC"
ctld.i18n["es"]["Single JTAC"] = "JTAC solo"
ctld.i18n["es"]["2x - Standard Groups"] = "2x - Grupos estándares"
ctld.i18n["es"]["2x - Anti Air"] = "2x - Defensas aéreas"
ctld.i18n["es"]["2x - Anti Tank"] = "2x - Antitanque"
ctld.i18n["es"]["2x - Standard Groups + 2x Mortar"] = "2x - Grupos estándar + 2x Grupos morteros"
ctld.i18n["es"]["3x - Standard Groups"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Air"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Tank"] = "3x - Antitanque"
ctld.i18n["es"]["3x - Mortar Squad"] = "3x - Grupos de morteros"
ctld.i18n["es"]["5x - Mortar Squad"] = "5x - Grupos de morteros"
ctld.i18n["es"]["Mortar Squad Red"] = "Grupo mortero rojo"

--- crates names
ctld.i18n["es"]["Humvee - MG"] = "Humvee - Antipersonal .50 cal"
ctld.i18n["es"]["Humvee - TOW"] = "Humvee - Antitanque TOW"
ctld.i18n["es"]["Light Tank - MRAP"] = "Tanque ligero - MRAP"
ctld.i18n["es"]["Med Tank - LAV-25"] = "Tanque Med - LAV-25"
ctld.i18n["es"]["Heavy Tank - Abrams"] = "Tanque pesado - Abrams"
ctld.i18n["es"]["BTR-D"] = "BTR-D - Transporte de tropas"
ctld.i18n["es"]["BRDM-2"] = "BRDM-2 - Reconocimiento"
ctld.i18n["es"]["Hummer - JTAC"] = "JTAC Hummer"
ctld.i18n["es"]["M-818 Ammo Truck"] = "Camión M-818 de municiones"
ctld.i18n["es"]["M-978 Tanker"] = "Camión cisterna M-978"
ctld.i18n["es"]["SKP-11 - JTAC"] = "JTAC SKP-11"
ctld.i18n["es"]["Ural-375 Ammo Truck"] = "Camión Ural-375 de municiones"
ctld.i18n["es"]["KAMAZ Ammo Truck"] = "Camión KAMAZ de municiones"
ctld.i18n["es"]["EWR Radar"] = "Radar Alerta Temprana"
ctld.i18n["es"]["FOB Crate - Small"] = "Caja FOB - Pequeña"
ctld.i18n["es"]["MQ-9 Repear - JTAC"] = "JTAC MQ-9 Repear"
ctld.i18n["es"]["RQ-1A Predator - JTAC"] = "JTAC RQ-1A Predator"
ctld.i18n["es"]["MLRS"] = "MLRS - Artilleria de cohetes"
ctld.i18n["es"]["SpGH DANA"] = "Obus autopropulsado SpGH DANA"
ctld.i18n["es"]["T155 Firtina"] = "Obus autopropulsado T155 Firtina"
ctld.i18n["es"]["Howitzer"] = "Obus autopropulsado M109A6 Paladin"
ctld.i18n["es"]["SPH 2S19 Msta"] = "SPH 2S19 Msta - Obus Autopropulsado"
ctld.i18n["es"]["M1097 Avenger"] = "M1097 Avenger - SAM Corta Distancia"
ctld.i18n["es"]["M48 Chaparral"] = "M48 Chaparral - SAM Corta Distancia"
ctld.i18n["es"]["Roland ADS"] = "Roland ADS - Lanzador"
ctld.i18n["es"]["Gepard AAA"] = "Gepard AAA - AAA"
ctld.i18n["es"]["LPWS C-RAM"] = "LPWS C-RAM - AAA"
ctld.i18n["es"]["9K33 Osa"] = "9K33 Osa - SA-8 Gecko"
ctld.i18n["es"]["9P31 Strela-1"] = "9P31 Strela-1 - SA-9 Gaskin"
ctld.i18n["es"]["9K35M Strela-10"] = "9K35M Strela-10 - SA-13 Gopher"
ctld.i18n["es"]["9K331 Tor"] = "9K331 Tor - SA-15 Tor"
ctld.i18n["es"]["2K22 Tunguska"] = "2K22 Tunguska - SA-19 Tunguska"
ctld.i18n["es"]["HAWK Launcher"] = "HAWK - Lanzador"
ctld.i18n["es"]["HAWK Search Radar"] = "HAWK - Radar de Búsqueda"
ctld.i18n["es"]["HAWK Track Radar"] = "HAWK - Radar de Seguimiento"
ctld.i18n["es"]["HAWK PCP"] = "HAWK - Puesto de Comando"
ctld.i18n["es"]["HAWK CWAR"] = "HAWK - Sistema de Control de Guerra"
ctld.i18n["es"]["HAWK Repair"] = "Reparar HAWK"
ctld.i18n["es"]["NASAMS Launcher 120C"] = "NASAMS - Lanzador 120C"
ctld.i18n["es"]["NASAMS Search/Track Radar"] = "NASAMS - Radar de Búsqueda/Seguimiento"
ctld.i18n["es"]["NASAMS Command Post"] = "NASAMS - Puesto de Mando"
ctld.i18n["es"]["NASAMS Repair"] = "Reparar NASAMS"
ctld.i18n["es"]["KUB Launcher"] = "KUB - Lanzador"
ctld.i18n["es"]["KUB Radar"] = "KUB - Radar"
ctld.i18n["es"]["KUB Repair"] = "Reparar KUB"
ctld.i18n["es"]["BUK Launcher"] = "BUK - Lanzador"
ctld.i18n["es"]["BUK Search Radar"] = "BUK - Radar de Búsqueda"
ctld.i18n["es"]["BUK CC Radar"] = "BUK - Radar de Control de Combate"
ctld.i18n["es"]["BUK Repair"] = "Reparar BUK"
ctld.i18n["es"]["Patriot Launcher"] = "Patriot - Lanzador"
ctld.i18n["es"]["Patriot Radar"] = "Patriot - Radar de Búsqueda"
ctld.i18n["es"]["Patriot ECS"] = "Patriot - Puesto de Mando"
ctld.i18n["es"]["Patriot ICC"] = "Patriot - Sistema de Control de Fuego"
ctld.i18n["es"]["Patriot EPP"] = "Patriot - Generador"
ctld.i18n["es"]["Patriot AMG (optional)"] = ""
ctld.i18n["es"]["Patriot Repair"] = "Reparar Patriot"
ctld.i18n["es"]["S-300 Grumble TEL C"] = "S-300 Grumble TEL C - Lanzador"
ctld.i18n["es"]["S-300 Grumble Flap Lid-A TR"] = "S-300 Grumble Flap Lid-A TR - Radar de Seguimiento"
ctld.i18n["es"]["S-300 Grumble Clam Shell SR"] = "S-300 Grumble Clam Shell SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble Big Bird SR"] = "S-300 Grumble Big Bird SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble C2"] = "S-300 Grumble C2 - Puesto de Mando"
ctld.i18n["es"]["S-300 Repair"] = "Reparar S-300"
ctld.i18n["es"]["Humvee - TOW - All crates"] = "Humvee - TOW - Todas las cajas"
ctld.i18n["es"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Todas las cajas"
ctld.i18n["es"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Todas las cajas"
ctld.i18n["es"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Todas las cajas"
ctld.i18n["es"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Todas las cajas"
ctld.i18n["es"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["M-978 Tanker - All crates"] = "M-978 Tanker - Todas las cajas"
ctld.i18n["es"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["EWR Radar - All crates"] = "EWR Radar - Todas las cajas"
ctld.i18n["es"]["MLRS - All crates"] = "MLRS - Todas las cajas"
ctld.i18n["es"]["SpGH DANA - All crates"] = "SpGH DANA - Todas las cajas"
ctld.i18n["es"]["T155 Firtina - All crates"] = "T155 Firtina - Todas las cajas"
ctld.i18n["es"]["Howitzer - All crates"] = "Howitzer - Todas las cajas"
ctld.i18n["es"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Todas las cajas"
ctld.i18n["es"]["M1097 Avenger - All crates"] = "M1097 Avenger - Todas las cajas"
ctld.i18n["es"]["M48 Chaparral - All crates"] = "M48 Chaparral - Todas las cajas"
ctld.i18n["es"]["Roland ADS - All crates"] = "Roland ADS - Todas las cajas"
ctld.i18n["es"]["Gepard AAA - All crates"] = "Gepard AAA - Todas las cajas"
ctld.i18n["es"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Todas las cajas"
ctld.i18n["es"]["9K33 Osa - All crates"] = "9K33 Osa - Todas las cajas"
ctld.i18n["es"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Todas las cajas"
ctld.i18n["es"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Todas las cajas"
ctld.i18n["es"]["9K331 Tor - All crates"] = "9K331 Tor - Todas las cajas"
ctld.i18n["es"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Todas las cajas"
ctld.i18n["es"]["HAWK - All crates"] = "HAWK - Todas clas ajas"
ctld.i18n["es"]["NASAMS - All crates"] = "NASAMS - Todas las cajas"
ctld.i18n["es"]["KUB - All crates"] = "KUB - Todas las cajas"
ctld.i18n["es"]["BUK - All crates"] = "BUK - Todas las cajas"
ctld.i18n["es"]["Patriot - All crates"] = "Patriot - Todas las cajas"
ctld.i18n["es"]["Patriot - All crates"] = "Patriot - Todas las cajas"

--- mission design error messages
ctld.i18n["es"]["CTLD.lua ERROR: Can't find trigger called %1"] =
"CTLD.lua ERROR : Imposible encontrar el activador llamado %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua ERROR : Imposible encontrar la zona llamada %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone or ship called %1"] =
"CTLD.lua ERROR : Imposible encontrar la zona o el barco llamado %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find crate with weight %1"] =
"CTLD.lua ERROR : Imposible encontrar una caja con un peso de %1"

--- runtime messages
ctld.i18n["es"]["You are not close enough to friendly logistics to get a crate!"] =
"¡No estás lo suficientemente cerca de la logística aliada para solicitar una caja!"
ctld.i18n["es"]["No more JTAC Crates Left!"] = "¡No hay más cajas JTAC disponibles!"
ctld.i18n["es"]["Sorry you must wait %1 seconds before you can get another crate"] =
"Lo sentimos, debes esperar %1 segundos antes de poder solicitar otra caja"
ctld.i18n["es"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"Una caja %1 pesando %2 kg ha sido preparada y está a tus %3 en punto "
ctld.i18n["es"]["%1 fast-ropped troops from %2 into combat"] = "%1 descolgo tropas con cuerdas de %2 al combate"
ctld.i18n["es"]["%1 dropped troops from %2 into combat"] = "%1 descargo tropas de %2 al combate"
ctld.i18n["es"]["%1 fast-ropped troops from %2 into %3"] = "%1 descolgo tropas con cuerdas de %2 a %3"
ctld.i18n["es"]["%1 dropped troops from %2 into %3"] = "%1 arrojó tropas de %2 a %3"
ctld.i18n["es"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"¡Demasiado alto o rápido para lanzar tropas al combate! Manten estacionario por debajo de % 1 pies o aterriza."
ctld.i18n["es"]["%1 dropped vehicles from %2 into combat"] = "%1 descargo vehículos de %2 al combate"
ctld.i18n["es"]["%1 loaded troops into %2"] = "%1 cargó tropas en %2"
ctld.i18n["es"]["%1 loaded %2 vehicles into %3"] = "%1 cargó %2 vehículos en %3"
ctld.i18n["es"]["%1 delivered a FOB Crate"] = "%1 entregó una caja FOB"
ctld.i18n["es"]["Delivered FOB Crate 60m at 6 o'clock to you"] = "Se le entregó la caja FOB de 60 m a sus 6 en punto"
ctld.i18n["es"]["FOB Crate dropped back to base"] = "Caja FOB devuelta a la base"
ctld.i18n["es"]["FOB Crate Loaded"] = "Caja FOB cargada"
ctld.i18n["es"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 cargó una caja FOB lista para su entrega!"
ctld.i18n["es"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"¡No hay unidades logísticas amigas cerca para cargar una caja FOB!"
ctld.i18n["es"]["This area has no more reinforcements available!"] = "¡Esta área no tiene más refuerzos disponibles!"
ctld.i18n["es"]["You are not in a pickup zone and no one is nearby to extract"] =
"No estás en una zona de carga y/o no hay nadie cerca para extraccion"
ctld.i18n["es"]["You are not in a pickup zone"] = "No estás en una zona de carga"
ctld.i18n["es"]["No one to unload"] = "Nadie / Nada para descargar"
ctld.i18n["es"]["Dropped troops back to base"] = "Tropas descargados de vuelta a la base"
ctld.i18n["es"]["Dropped vehicles back to base"] = "Vehículos descargados de vuelta a la base"
ctld.i18n["es"]["You already have troops onboard."] = "Ya tienes tropas a bordo."
ctld.i18n["es"]["Count Infantries limit in the mission reached, you can't load more troops"] =
"Se alcanzó el límite de infantería en la misión, no puedes cargar más tropas"
ctld.i18n["es"]["You already have vehicles onboard."] = "Ya tienes vehículos a bordo."
ctld.i18n["es"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"Lo sentimos, el grupo de %1 es demasiado grande. \n \nEl límite es %2 para %3"
ctld.i18n["es"]["%1 extracted troops in %2 from combat"] = "%1 tropas extraídas del combate en %2"
ctld.i18n["es"]["No extractable troops nearby!"] = "¡No hay tropas extraíbles cerca!"
ctld.i18n["es"]["%1 extracted vehicles in %2 from combat"] = "%1 vehículos extraídos del combate en %2"
ctld.i18n["es"]["No extractable vehicles nearby!"] = "¡No hay vehículos extraíbles cerca!"
ctld.i18n["es"]["%1 troops onboard (%2 kg)\n"] = "%1 tropas a bordo (%2 kg)\n"
ctld.i18n["es"]["%1 vehicles onboard (%2)\n"] = "%1 vehículos a bordo (%2)\n"
ctld.i18n["es"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caja FOB a bordo (%1 kg)\n"
ctld.i18n["es"]["%1 crate onboard (%2 kg)\n"] = "%1 caja a bordo (%2 kg)\n"
ctld.i18n["es"]["Total weight of cargo : %1 kg\n"] = "Peso total de la carga: %1 kg\n"
ctld.i18n["es"]["No cargo."] = "Sin carga."
ctld.i18n["es"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"En estacionario sobre la caja %1 \n\n¡Mantenlo durante %2 segundos! \n\n¡Si la cuenta atras se detiene, estás demasiado lejos!"
ctld.i18n["es"]["Loaded %1 crate!"] = "Caja %1 cargada !"
ctld.i18n["es"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado bajo para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado alto para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
ctld.i18n["es"]["No Crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡El número máximo de cajas está a bordo!"
ctld.i18n["es"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caja - kg %3 - %4 m - a tus %5 en punto"
ctld.i18n["es"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caja FOB - %1 m - a las %2 en punto\n"
ctld.i18n["es"]["No Nearby Crates"] = "Ninguna caja de proximidad"
ctld.i18n["es"]["Nearby Crates:\n%1"] = "Cajas cercanas:\n%1"
ctld.i18n["es"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Cajas FOB cercanas (no se pueden cargar con eslinga):\n%1"
ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"
ctld.i18n["es"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["es"]["Sorry, there are no active FOBs!"] = "¡Lo sentimos, no hay FOB activos!"
ctld.i18n["es"]["No cargo."] = "Sin carga."
ctld.i18n["es"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"En estacionario sobre la caja %1 \n\n¡Mantenlo durante %2 segundos! \n\n¡Si la cuenta atras se detiene, estás demasiado lejos!"
ctld.i18n["es"]["Loaded %1 crate!"] = "¡Caja %1 cargada!"
ctld.i18n["es"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado bajo para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado alto para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
ctld.i18n["es"]["No Crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡Número máximo de cajas a bordo!"
ctld.i18n["es"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caja - kg %3 - %4 m - a tus %5 en punto"
ctld.i18n["es"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caja FOB - %1 m - a tus %2 en punto\n"
ctld.i18n["es"]["No Nearby Crates"] = "No hay cajas cerca"
ctld.i18n["es"]["Nearby Crates:\n%1"] = "Cajas cercanas:\n%1"
ctld.i18n["es"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Cajas FOB cercanas (no se pueden cargar con eslinga):\n%1"
ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"
ctld.i18n["es"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["es"]["Sorry, there are no active FOBs!"] = "¡Lo sentimos, no hay FOB activos!"
ctld.i18n["es"]["You can't unpack that here! Take it to where it's needed!"] =
"¡No puedes desembalar eso aquí! ¡Llévalo a donde lo necesiten!"
ctld.i18n["es"]["Sorry you must move this crate before you unpack it!"] =
"¡Lo siento, debes mover esta caja antes de desembalar!"
ctld.i18n["es"]["%1 successfully deployed %2 to the field"] = "%1 Desplego %2 con exito en el campo."
ctld.i18n["es"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"No hay cajas amigas lo suficientemente cerca por desembalar, o la caja está demasiado cerca de un avión"
ctld.i18n["es"]["Finished building FOB! Crates and Troops can now be picked up."] =
"¡Construcción FOB completada! Ahora se pueden recoger cajas y tropas"
ctld.i18n["es"]["Finished building FOB! Crates can now be picked up."] =
"¡Construcción FOB completada! Ahora se pueden recoger cajas."
ctld.i18n["es"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 comenzó a construir FOB usando %2 cajas FOB , estará terminado en %3 segundos.\nPosición marcada con bomba de humo."
ctld.i18n["es"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"¡No se puede construir el FOB!\n\nSe requiere %1 cajas FOB grandes (3 cajas FOB pequeñas equivalente a 1 caja FOB grande) y hay el equivalente a %2 cajas FOB grandes cerca\n\nO las cajas no están a menos de 750 m una de otra"
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"Actualmente no estás transportando ninguna caja.\n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos o aterrice y use los comandos de caja F10."
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos."
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, aterriza y usa los controles de la caja F10."
ctld.i18n["es"]["%1 crate has been safely unhooked and is at your %2 o'clock"] =
"%1 caja desenganchada de forma segura y está en tus %2 en punto"
ctld.i18n["es"]["%1 crate has been safely dropped below you"] = "%1 caja ha soltado de forma segura debajo de ti"
ctld.i18n["es"]["You were too high! The crate has been destroyed"] = "¡Estabas demasiado alto! La caja ha sido destruida"
ctld.i18n["es"]["Radio Beacons:\n%1"] = "Balizas de radio:\n%1"
ctld.i18n["es"]["No Active Radio Beacons"] = "No hay radiobalizas activas"
ctld.i18n["es"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 Despliega una radiobaliza.\n\n%2"
ctld.i18n["es"]["You need to land before you can deploy a Radio Beacon!"] =
"¡Debes aterrizar antes de poder desplegar una radiobaliza!"
ctld.i18n["es"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 eliminó una radiobaliza.\n\n%2"
ctld.i18n["es"]["No Radio Beacons within 500m."] = "No hay radiobalizas a menos de 500 m."
ctld.i18n["es"]["You need to land before remove a Radio Beacon"] =
"Es necesario aterrizar antes de eliminar una radiobaliza"
ctld.i18n["es"]["%1 successfully rearmed a full %2 in the field"] = "%1 rearmó con exito un %2 completo en el campo"
ctld.i18n["es"]["Missing %1\n"] = "Faltan: %1\n"
ctld.i18n["es"]["Out of parts for AA Systems. Current limit is %1\n"] =
"Sin piezas para sistemas AA. El límite actual es %1\n"
ctld.i18n["es"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"Imposible construir %1\n%2\n\nO las cajas no están lo suficientemente cerca unas de otras."
ctld.i18n["es"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 Despliegue con exito un % 2 completo en el campo \n\nEl límite AA del sistema activo es: %3\nActivo: %4"
ctld.i18n["es"]["%1 successfully repaired a full %2 in the field."] = "%1 reparó con exito un %2 completo en el campo."
ctld.i18n["es"]["Cannot repair %1. No damaged %2 within 300m"] =
"Imposible reparar %1. No hay daños en %2 en 300 m al rededor"
ctld.i18n["es"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 Despliegue con exito de %2 en el campo usando %3 cajas."
ctld.i18n["es"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"Imposible construir %1 !\n\nNecesita %2 cajas y hay %3 \n\nO las cajas están a no menos de 300 m una de otra"
ctld.i18n["es"]["%1 dropped %2 smoke."] = "%1 lanzo humo %2."

--- JTAC messages
ctld.i18n["es"]["JTAC Group %1 KIA!"] = "¡Grupo JTAC %1 KIA!"
ctld.i18n["es"]["%1, selected target reacquired, %2"] = "%1, objetivo seleccionado readquirido, %2"
ctld.i18n["es"][". CODE: %1. POSITION: %2"] = ". CÓDIGO: %1. POSICIÓN: %2"
ctld.i18n["es"]["new target, "] = "nuevo objetivo, "
ctld.i18n["es"]["standing by on %1"] = "en espera en %1"
ctld.i18n["es"]["lasing %1"] = "láser %1"
ctld.i18n["es"][", temporarily %1"] = ", temporalmente %1"
ctld.i18n["es"]["target lost"] = "objetivo perdido"
ctld.i18n["es"]["target destroyed"] = "objetivo destruido"
ctld.i18n["es"][", selected %1"] = ", %1 seleccionado"
ctld.i18n["es"]["%1 %2 target lost."] = "%1 %2 objetivo perdido."
ctld.i18n["es"]["%1 %2 target destroyed."] = "%1 %2 objetivo destruido."
ctld.i18n["es"]["JTAC STATUS: \n\n"] = "ESTADO JTAC: \n\n"
ctld.i18n["es"][", available on %1 %2,"] = ", disponible en %1 %2,"
ctld.i18n["es"]["UNKNOWN"] = "DESCONOCIDO"
ctld.i18n["es"][" targeting "] = " apuntando "
ctld.i18n["es"][" targeting selected unit "] = " apuntando a la unidad indicada"
ctld.i18n["es"][" attempting to find selected unit, temporarily targeting "] =
" intentando encontrar la unidad indicada, laser activo "
ctld.i18n["es"]["(Laser OFF) "] = "(Láser INACTIVO) "
ctld.i18n["es"]["Visual On: "] = "Visual activado: "
ctld.i18n["es"][" searching for targets %1\n"] = " buscando objetivos %1\n"
ctld.i18n["es"]["No Active JTACs"] = "Sin JTAC activos"
ctld.i18n["es"][", targeting selected unit, %1"] = ", apuntando a la unidad indicada, %1"
ctld.i18n["es"][". CODE: %1. POSITION: %2"] = ". CÓDIGO: %1. POSICIÓN: %2"
ctld.i18n["es"][", target selection reset."] = ", reinicio de selección de objetivo."
ctld.i18n["es"]["%1, laser and smokes enabled"] = "%1, láser y humo habilitados"
ctld.i18n["es"]["%1, laser and smokes disabled"] = "%1, láser y humo deshabilitados"
ctld.i18n["es"]["%1, wind and target speed laser spot compensations enabled"] =
"%1, compensaciones habilitadas del viento y de velocidad del objetivo para el punto láser"
ctld.i18n["es"]["%1, wind and target speed laser spot compensations disabled"] =
"%1, compensaciones deshabilitadas del viento y de velocidad del objetivo para el punto láser"
ctld.i18n["es"]["%1, WHITE smoke deployed near target"] = "%1, humo BLANCO desplegado cerca del objetivo"

--- F10 menu messages
ctld.i18n["es"]["Actions"] = "Acciones"
ctld.i18n["es"]["Troop Transport"] = "Transporte de tropas"
ctld.i18n["es"]["Unload / Extract Troops"] = "Descargar/Extraer tropas"
ctld.i18n["es"]["Next page"] = "Página siguiente"
ctld.i18n["es"]["Load "] = "Cargar "
ctld.i18n["es"]["Vehicle / FOB Transport"] = "Transporte de Vehículo / FOB"
ctld.i18n["es"]["Vehicle / FOB Crates / Drone"] = "Cajas de Vehículo / FOB / Dron"
ctld.i18n["es"]["Unload Vehicles"] = "Descargar vehículos"
ctld.i18n["es"]["Load / Extract Vehicles"] = "Cargar/Extraer vehículos"
ctld.i18n["es"]["Load / Unload FOB Crate"] = "Cargar/Descargar caja FOB"
ctld.i18n["es"]["Repack Vehicles"] = "Reenvolver vehículos"
ctld.i18n["es"]["CTLD Commands"] = "Comandos CTLD"
ctld.i18n["es"]["CTLD"] = "CTLD"
ctld.i18n["es"]["Check Cargo"] = "Verificar carga"
ctld.i18n["es"]["Load Nearby Crate(s)"] = "Cargar caja(s) cercana(s)"
ctld.i18n["es"]["Unpack Any Crate"] = "Desempaquetar cajas"
ctld.i18n["es"]["Drop Crate(s)"] = "Soltar caja(s)"
ctld.i18n["es"]["List Nearby Crates"] = "Enumerar cajas cercanas"
ctld.i18n["es"]["List FOBs"] = "Enumerar FOBs"
ctld.i18n["es"]["List Beacons"] = "Enumerar balizas"
ctld.i18n["es"]["List Radio Beacons"] = "Enumerar radiobalizas"
ctld.i18n["es"]["Smoke Markers"] = "Marcadores de humo"
ctld.i18n["es"]["Drop Red Smoke"] = "Lanzar humo rojo"
ctld.i18n["es"]["Drop Blue Smoke"] = "Lanzar humo azul"
ctld.i18n["es"]["Drop Orange Smoke"] = "Lanzar humo naranja"
ctld.i18n["es"]["Drop Green Smoke"] = "Lanzar humo verde"
ctld.i18n["es"]["Drop Beacon"] = "Desplegar baliza"
ctld.i18n["es"]["Radio Beacons"] = "Balizas de radio"
ctld.i18n["es"]["Remove Closest Beacon"] = "Quitar la baliza mas cercana"
ctld.i18n["es"]["JTAC Status"] = "Estado de JTAC"
ctld.i18n["es"]["DISABLE "] = "DESHABILITAR "
ctld.i18n["es"]["ENABLE "] = "HABILITAR "
ctld.i18n["es"]["REQUEST "] = "SOLICITUD "
ctld.i18n["es"]["Reset TGT Selection"] = "Restablecer selección de objetivo"
-- F10 RECON menus
ctld.i18n["es"]["RECON"] = "RECONOCIMIENTO"
ctld.i18n["es"]["Show targets in LOS (refresh)"] = "Marcar objetivos visibles en el mapa F10"
ctld.i18n["es"]["Hide targets in LOS"] = "Borrar marcas del mapa F10"
ctld.i18n["es"]["START autoRefresh targets in LOS"] = "Iniciar el seguimiento automático de objetivos"
ctld.i18n["es"]["STOP autoRefresh targets in LOS"] = "Detener el seguimiento automático de objetivos"
--========================================================================================================================

--========  Korean - 한국어 =====================================================================================
ctld.i18n["ko"] = {}
ctld.i18n["ko"].translation_version =
"1.1" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "ko"; env
    .info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
        tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["ko"]["Standard Group"] = "표준 그룹"
ctld.i18n["ko"]["Anti Air"] = "방공"
ctld.i18n["ko"]["Anti Tank"] = "대기갑"
ctld.i18n["ko"]["Mortar Squad"] = "박격포 분대"
ctld.i18n["ko"]["JTAC Group"] = "JTAC 그룹"
ctld.i18n["ko"]["Single JTAC"] = "싱글 JTAC"
ctld.i18n["ko"]["2x - Standard Groups"] = "표준 그룹 2x"
ctld.i18n["ko"]["2x - Anti Air"] = "방공 2x"
ctld.i18n["ko"]["2x - Anti Tank"] = "대기갑 2x"
ctld.i18n["ko"]["2x - Standard Groups + 2x Mortar"] = "표준 그룹 2x + 박격포 분대 2x"
ctld.i18n["ko"]["3x - Standard Groups"] = "표준 그룹 3x"
ctld.i18n["ko"]["3x - Anti Air"] = "방공 3x"
ctld.i18n["ko"]["3x - Anti Tank"] = "대기갑 3x"
ctld.i18n["ko"]["3x - Mortar Squad"] = "박격포 분대 3x"
ctld.i18n["ko"]["5x - Mortar Squad"] = "박격포 분대 5x"
ctld.i18n["ko"]["Mortar Squad Red"] = "레드 박격포 분대"

--- crates names
ctld.i18n["ko"]["Humvee - MG"] = "험비 - MG"
ctld.i18n["ko"]["Humvee - TOW"] = "험비 - TOW"
ctld.i18n["ko"]["Light Tank - MRAP"] = nil
ctld.i18n["ko"]["Med Tank - LAV-25"] = nil
ctld.i18n["ko"]["Heavy Tank - Abrams"] = "M1 에이브럼스"
ctld.i18n["ko"]["BTR-D"] = nil
ctld.i18n["ko"]["BRDM-2"] = nil
ctld.i18n["ko"]["Hummer - JTAC"] = "험머 - JTAC"
ctld.i18n["ko"]["M-818 Ammo Truck"] = "M-818 탄약 차량"
ctld.i18n["ko"]["M-978 Tanker"] = "M-978 연료 차량"
ctld.i18n["ko"]["SKP-11 - JTAC"] = nil
ctld.i18n["ko"]["Ural-375 Ammo Truck"] = "Ural-375 탄약 차량"
ctld.i18n["ko"]["KAMAZ Ammo Truck"] = "KAMAZ 탄약 차량"
ctld.i18n["ko"]["EWR Radar"] = "조기경보 레이더"
ctld.i18n["ko"]["FOB Crate - Small"] = "FOB 화물 - 小"
ctld.i18n["ko"]["MLRS"] = nil
ctld.i18n["ko"]["SpGH DANA"] = "DANA 자주곡사포"
ctld.i18n["ko"]["T155 Firtina"] = "T-155 프르트나"
ctld.i18n["ko"]["Howitzer"] = nil
ctld.i18n["ko"]["SPH 2S19 Msta"] = "2S19 므스타 자주곡사포"
ctld.i18n["ko"]["M1097 Avenger"] = "M1097 어벤저"
ctld.i18n["ko"]["M48 Chaparral"] = "M48 채퍼럴"
ctld.i18n["ko"]["Roland ADS"] = "롤랑 ADS"
ctld.i18n["ko"]["Gepard AAA"] = "게파트 자주대공포"
ctld.i18n["ko"]["LPWS C-RAM"] = nil
ctld.i18n["ko"]["9K33 Osa"] = "9K33 오사"
ctld.i18n["ko"]["9P31 Strela-1"] = "9P31 스트렐라-1"
ctld.i18n["ko"]["9K35M Strela-10"] = "9K35M 스트렐라-10"
ctld.i18n["ko"]["9K331 Tor"] = "9K331 토르"
ctld.i18n["ko"]["2K22 Tunguska"] = "2K22 퉁구스카"
ctld.i18n["ko"]["HAWK Launcher"] = "호크 포대"
ctld.i18n["ko"]["HAWK Search Radar"] = "호크 탐지 레이더"
ctld.i18n["ko"]["HAWK Track Radar"] = "호크 추적 레이더"
ctld.i18n["ko"]["HAWK PCP"] = "호크 PCP"
ctld.i18n["ko"]["HAWK CWAR"] = "호크 CWAR"
ctld.i18n["ko"]["HAWK Repair"] = "호크 수리킷"
ctld.i18n["ko"]["NASAMS Launcher 120C"] = "NASAMS 포대 120C"
ctld.i18n["ko"]["NASAMS Search/Track Radar"] = "NASAMS 레이더"
ctld.i18n["ko"]["NASAMS Command Post"] = "NASAMS 관제소"
ctld.i18n["ko"]["NASAMS Repair"] = "NASAMS 수리킷"
ctld.i18n["ko"]["KUB Launcher"] = "SA-6 포대"
ctld.i18n["ko"]["KUB Radar"] = "SA-6 레이더"
ctld.i18n["ko"]["KUB Repair"] = "SA-6 수리킷"
ctld.i18n["ko"]["BUK Launcher"] = "SA-11 포대"
ctld.i18n["ko"]["BUK Search Radar"] = "SA-11 탐지 레이더"
ctld.i18n["ko"]["BUK CC Radar"] = "SA-11 CC"
ctld.i18n["ko"]["BUK Repair"] = "SA-11 수리킷"
ctld.i18n["ko"]["Patriot Launcher"] = "패트리어트 포대"
ctld.i18n["ko"]["Patriot Radar"] = "패트리어트 탐지 레이더"
ctld.i18n["ko"]["Patriot ECS"] = "패트리어트 ECS"
ctld.i18n["ko"]["Patriot ICC"] = "패트리어트 ICC"
ctld.i18n["ko"]["Patriot EPP"] = "패트리어트 EPP"
ctld.i18n["ko"]["Patriot AMG (optional)"] = "패트리어트 AMG (선택 사항)"
ctld.i18n["ko"]["Patriot Repair"] = "패트리어트 수리킷"
ctld.i18n["ko"]["S-300 Grumble TEL C"] = "S-300 C 포대"
ctld.i18n["ko"]["S-300 Grumble Flap Lid-A TR"] = "S-300 5N63 추적 레이더"
ctld.i18n["ko"]["S-300 Grumble Clam Shell SR"] = "S-300 Clam Shell 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble Big Bird SR"] = "S-300 Big Bird 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble C2"] = "S-300 관제소"
ctld.i18n["ko"]["S-300 Repair"] = "S-300 수리킷"

--- mission design error messages
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find trigger called %1"] = "CTLD.lua 오류 : %1 트리거를 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua 오류 : %1 존을 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = "CTLD.lua 오류 : %1 존 또는 함선을 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find crate with weight %1"] = "CTLD.lua 오류 : %1 의 무게를 가진 화물을 찾을 수 없음"

--- runtime messages
ctld.i18n["ko"]["You are not close enough to friendly logistics to get a crate!"] = "아군 보급계가 화물을 싣기에 충분한 거리에 있지 않습니다!"
ctld.i18n["ko"]["No more JTAC Crates Left!"] = "JTAC 화물이 남아있지 않습니다!"
ctld.i18n["ko"]["Sorry you must wait %1 seconds before you can get another crate"] = "죄송합니다, 다른 화물을 얻기까지 %1 초 기다려야 합니다."
ctld.i18n["ko"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"%2 KG의 %1 화물이 %3 시 방향에 있습니다."
ctld.i18n["ko"]["%1 fast-ropped troops from %2 into combat"] = "%1 이(가) %2 에서 공수부대를 투입했습니다."
ctld.i18n["ko"]["%1 dropped troops from %2 into combat"] = "%1 이(가) %2 에서 병력을 투입했습니다."
ctld.i18n["ko"]["%1 fast-ropped troops from %2 into %3"] = "%1 이(가) %2 에서 %3 로 공수부대를 투입했습니다."
ctld.i18n["ko"]["%1 dropped troops from %2 into %3"] = "%1 이(가) %2에서 %3 로 병력을 투입했습니다."
ctld.i18n["ko"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"병력을 투입하기에 너무 빠르거나 너무 높습니다! %1 피트 아래로 호버링 하거나 착륙하십시오."
ctld.i18n["ko"]["%1 dropped vehicles from %2 into combat"] = "%1 이(가) %2 에서 차량(들)을 투입했습니다."
ctld.i18n["ko"]["%1 loaded troops into %2"] = "%1 이 %2 로 병력을 실었습니다."
ctld.i18n["ko"]["%1 loaded %2 vehicles into %3"] = "%1 이 %2 대의 차량을 %3 로 실었습니다."
ctld.i18n["ko"]["%1 delivered a FOB Crate"] = "%1 이 FOB 화물을 배달했습니다."
ctld.i18n["ko"]["Delivered FOB Crate 60m at 6'oclock to you"] = "FOB 화물이 6시 방향 60m 거리에 있습니다."
ctld.i18n["ko"]["FOB Crate dropped back to base"] = "FOB 화물이 기지로 돌아갔습니다."
ctld.i18n["ko"]["FOB Crate Loaded"] = "FOB 화물 적재 완료"
ctld.i18n["ko"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 이 배달 준비가 완료된 FOB 화물을 실었습니다!"
ctld.i18n["ko"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"아군 보급계가 FOB 화물을 싣기에 충분한 거리에 있지 않습니다!"
ctld.i18n["ko"]["You already have troops onboard."] = "이미 병력이 탑승중입니다."
ctld.i18n["ko"]["You already have vehicles onboard."] = "이미 차량이 적재되어 있습니다."
ctld.i18n["ko"]["This area has no more reinforcements available!"] = "이 구역은 지원이 불가합니다!"
ctld.i18n["ko"]["You are not in a pickup zone and no one is nearby to extract"] = "픽업 구역이 아니고 근처에 철수할 병력이 없습니다."
ctld.i18n["ko"]["You are not in a pickup zone"] = "픽업 구역이 아닙니다."
ctld.i18n["ko"]["No one to unload"] = "내릴 사람 없음"
ctld.i18n["ko"]["Dropped troops back to base"] = "병력을 기지로 돌려보냈습니다."
ctld.i18n["ko"]["Dropped vehicles back to base"] = "차량을 기지로 돌려보냈습니다."
ctld.i18n["ko"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"죄송합니다. %1 그룹이 너무 무겁습니다. \n\n%3 의 무게 제한은 %2 입니다."
ctld.i18n["ko"]["%1 extracted troops in %2 from combat"] = "%1 이 %2 에서 병력을 철수시켰습니다."
ctld.i18n["ko"]["No extractable troops nearby!"] = "철수시킬 병력이 근처에 없습니다!"
ctld.i18n["ko"]["%1 extracted vehicles in %2 from combat"] = "%1 이 %2 에서 차량을 철수시켰습니다."
ctld.i18n["ko"]["No extractable vehicles nearby!"] = "철수시킬 차량이 근처에 없습니다!"
ctld.i18n["ko"]["%1 troops onboard (%2 kg)\n"] = "탑승중인 병력 : %1 (%2 kg)\n"
ctld.i18n["ko"]["%1 vehicles onboard (%2)\n"] = "적재된 차량 : %1 (%2 kg)\n"
ctld.i18n["ko"]["1 FOB Crate oboard (%1 kg)\n"] = "FOB 화물 1개 적재됨 (%1 kg)\n"
ctld.i18n["ko"]["%1 crate onboard (%2 kg)\n"] = "적재된 화물 : %1 (%2 kg)\n"
ctld.i18n["ko"]["Total weight of cargo : %1 kg\n"] = "총 화물 무게 : %1 kg\n"
ctld.i18n["ko"]["No cargo."] = "화물 없음."
ctld.i18n["ko"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"%1 화물 위 호버링 중. \n\n%2 초 동안 호버링하세요! \n\n카운트다운이 멈추면 너무 멀다는 뜻입니다!"
ctld.i18n["ko"]["Loaded %1 crate!"] = "%1 화물 적재 완료!"
ctld.i18n["ko"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = "%1 화물을 싣기에 너무 낮습니다.\n\n%2 초 동안 호버링하세요."
ctld.i18n["ko"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = "%1 화물을 싣기에 너무 높습니다.\n\n%2 초 동안 호버링하세요."
ctld.i18n["ko"]["You must land before you can load a crate!"] = "화물을 싣기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["No Crates within 50m to load!"] = "50m 내에 실을 화물이 없습니다!"
ctld.i18n["ko"]["Maximum number of crates are on board!"] = "이미 화물을 최대로 실었습니다!"
ctld.i18n["ko"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 화물 - kg %3 - %4 m - %5 시 방향"
ctld.i18n["ko"]["FOB Crate - %1 m - %2 o'clock\n"] = "FOB 화물 - %1 m - %2 시 방향\n"
ctld.i18n["ko"]["No Nearby Crates"] = "근처 화물 없음."
ctld.i18n["ko"]["Nearby Crates:\n%1"] = "근처 화물:\n%1"
ctld.i18n["ko"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = "근처 FOB 화물 (슬링로드 불가):\n%1"
ctld.i18n["ko"]["FOB Positions:"] = "FOB 위치:"
ctld.i18n["ko"]["%1\nFOB @ %2"] = nil
ctld.i18n["ko"]["Sorry, there are no active FOBs!"] = "죄송합니다, 활성화된 FOB가 없습니다."
ctld.i18n["ko"]["You can't unpack that here! Take it to where it's needed!"] = "여기에 풀 수 없습니다! 필요한 곳에 가져가세요!"
ctld.i18n["ko"]["Sorry you must move this crate before you unpack it!"] = "죄송합니다, 풀기 전에 이 화물을 옮겨야 합니다!"
ctld.i18n["ko"]["%1 successfully deployed %2 to the field"] = "%1 이 %2 를 성공적으로 배치했습니다."
ctld.i18n["ko"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"풀 아군 화물이 가깝지 않거나 너무 가깝습니다."
ctld.i18n["ko"]["Finished building FOB! Crates and Troops can now be picked up."] = "FOB 건설 완료! 이제 화물과 병력을 실을 수 있습니다."
ctld.i18n["ko"]["Finished building FOB! Crates can now be picked up."] = "FOB 건설 완료! 이제 화물을 실을 수 있습니다."
ctld.i18n["ko"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 이 %2 개의 FOB 화물을 이용하여 FOB 건설을 시작했습니다. %3 초 후 완료됩니다.\n위치가 연막으로 표시됐습니다."
ctld.i18n["ko"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"FOB를 건설할 수 없습니다!\n\n%1 개의 FOB 화물 - 大 가 필요합니다! (3개의 FOB 화물 - 小 는 1개의 FOB 화물 - 大 와 동일합니다.) 근처에 %2 개의 FOB 화물 - 大 가 있습니다.\n\n또는 화물들이 서로 750m 거리보다 멀리 있습니다."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 화물 위에서 %1 초 동안 호버링하거나 착륙하여 F10 화물 명령어를 사용하세요."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 화물 위에서 %1 초 동안 호버링하세요."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 착륙하여 F10 화물 명령어를 사용하세요."
ctld.i18n["ko"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = "%1 화물이 안전하게 내려졌고 %2 시 방향에 있습니다."
ctld.i18n["ko"]["%1 crate has been safely dropped below you"] = "%1 화물이 밑에 안전하게 내려졌습니다."
ctld.i18n["ko"]["You were too high! The crate has been destroyed"] = "너무 높았습니다! 화물이 파괴되었습니다."
ctld.i18n["ko"]["Radio Beacons:\n%1"] = "라디오 비콘 :\n%1"
ctld.i18n["ko"]["No Active Radio Beacons"] = "활성화된 라디오 비콘 없음."
ctld.i18n["ko"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 이(가) 라디오 비콘을 배치했습니다.\n\n%2"
ctld.i18n["ko"]["You need to land before you can deploy a Radio Beacon!"] = "라디오 비콘을 배치하려면 착륙해야 합니다!"
ctld.i18n["ko"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 이(가) 라디오 비콘을 제거했습니다.\n\n%2"
ctld.i18n["ko"]["No Radio Beacons within 500m."] = "500m 내에 라디오 비콘 없음."
ctld.i18n["ko"]["You need to land before remove a Radio Beacon"] = "라디오 비콘을 제거하려면 착륙해야 합니다."
ctld.i18n["ko"]["%1 successfully rearmed a full %2 in the field"] = "%1 이(가) %2 을(를) 성공적으로 재무장 시켰습니다."
ctld.i18n["ko"]["Missing %1\n"] = "%1 없음\n"
ctld.i18n["ko"]["Out of parts for AA Systems. Current limit is %1\n"] = "방공 시스템 필요 부분 없음. 현재 제한 : %1\n"
ctld.i18n["ko"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"%1 건설 불가\n%2\n\n또는 화물이 서로 가까이 있지 않습니다."
ctld.i18n["ko"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 이(가) 완전한 %2 를 성공적으로 투입했습니다. \n\n방공 시스템 제한 : %3\n활성화된 방공 시스템 : %4"
ctld.i18n["ko"]["%1 successfully repaired a full %2 in the field."] = "%1 이(가) 완전한 %2 을(를) 성공적으로 수리했습니다."
ctld.i18n["ko"]["Cannot repair %1. No damaged %2 within 300m"] = "%1 수리 불가. 300m 내에 손상을 입은 %2 없음."
ctld.i18n["ko"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 이 %3 개의 화물을 이용하여 %2 을(를) 성공적으로 배치했습니다."
ctld.i18n["ko"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"%1 건설 불가!\n\n%2 개의 화물이 필요하지만 %3 개 있습니다. \n\n또는 화물들이 서로 300m 내의 거리에 있지 않습니다."
ctld.i18n["ko"]["%1 dropped %2 smoke."] = "%1 이(가) %2 연막을 투하했습니다."

--- JTAC messages
ctld.i18n["ko"]["JTAC Group %1 KIA!"] = "JTAC 그룹 %1 전사!"
ctld.i18n["ko"]["%1, selected target reacquired, %2"] = "%1, 선택된 목표물 재습득, %2"
ctld.i18n["ko"][". CODE: %1. POSITION: %2"] = ". 코드: %1. 위치: %2"
ctld.i18n["ko"]["new target, "] = "새 목표물, "
ctld.i18n["ko"]["standing by on %1"] = "%1 대기 중"
ctld.i18n["ko"]["lasing %1"] = "%1 레이저 조준 중"
ctld.i18n["ko"][", temporarily %1"] = ", 임시로 %1"
ctld.i18n["ko"]["target lost"] = "목표물 놓침"
ctld.i18n["ko"]["target destroyed"] = "목표물 파괴됨"
ctld.i18n["ko"][", selected %1"] = ", %1 선택 완료"
ctld.i18n["ko"]["%1 %2 target lost."] = "%1 %2 목표물 놓침."
ctld.i18n["ko"]["%1 %2 target destroyed."] = "%1 %2 목표물 파괴됨."
ctld.i18n["ko"]["JTAC STATUS: \n\n"] = "JTAC 상태 : \n\n"
ctld.i18n["ko"][", available on %1 %2,"] = ", %1 %2 가능,"
ctld.i18n["ko"]["UNKNOWN"] = "미상"
ctld.i18n["ko"][" targeting "] = " 조준 중 : "
ctld.i18n["ko"][" targeting selected unit "] = " 선택한 유닛 조준 중 "
ctld.i18n["ko"][" attempting to find selected unit, temporarily targeting "] = " 선택한 유닛 찾는 중, 임시로 조준 중 : "
ctld.i18n["ko"]["(Laser OFF) "] = "(레이저 끔) "
ctld.i18n["ko"]["Visual On: "] = "육안 식별 : "
ctld.i18n["ko"][" searching for targets %1\n"] = " %1 목표물 찾는 중\n"
ctld.i18n["ko"]["No Active JTACs"] = "활성화된 JTAC 없음"
ctld.i18n["ko"][", targeting selected unit, %1"] = ", 선택한 유닛 조준 중, %1"
ctld.i18n["ko"][". CODE: %1. POSITION: %2"] = ". 코드: %1. 위치: %2"
ctld.i18n["ko"][", target selection reset."] = ", 목표물 선택 초기화."
ctld.i18n["ko"]["%1, laser and smokes enabled"] = "%1, 레이저 및 연막 사용"
ctld.i18n["ko"]["%1, laser and smokes disabled"] = "%1, 레이저 및 연막 미사용"
ctld.i18n["ko"]["%1, wind and target speed laser spot compensations enabled"] = "%1, 바람, 목표물 속도 보정 사용"
ctld.i18n["ko"]["%1, wind and target speed laser spot compensations disabled"] = "%1, 바람, 목표물 속도 보정 미사용"
ctld.i18n["ko"]["%1, WHITE smoke deployed near target"] = "%1, 목표물 근처 백색 연막"

--- F10 menu messages
ctld.i18n["ko"]["Actions"] = "행동"
ctld.i18n["ko"]["Troop Transport"] = "병력 수송"
ctld.i18n["ko"]["Unload / Extract Troops"] = "병력 하차 / 철수"
ctld.i18n["ko"]["Next page"] = "다음 페이지"
ctld.i18n["ko"]["Load "] = "싣기 : "
ctld.i18n["ko"]["Vehicle / FOB Transport"] = "차량 / FOB 수송"
ctld.i18n["ko"]["Vehicle / FOB Crates"] = "차량 / FOB 화물"
ctld.i18n["ko"]["Unload Vehicles"] = "차량 하역"
ctld.i18n["ko"]["Load / Extract Vehicles"] = "차량 적재 / 철수"
ctld.i18n["ko"]["Load / Unload FOB Crate"] = "FOB 화물 적재 / 철수"
ctld.i18n["ko"]["CTLD Commands"] = "CTLD 명령"
ctld.i18n["ko"]["CTLD"] = "CTLD"
ctld.i18n["ko"]["Check Cargo"] = "화물 확인"
ctld.i18n["ko"]["Load Nearby Crate"] = "근처 화물 싣기"
ctld.i18n["ko"]["Unpack Any Crate"] = "화물 풀기"
ctld.i18n["ko"]["Drop Crate"] = "화물 투하"
ctld.i18n["ko"]["List Nearby Crates"] = "근처 화물 목록"
ctld.i18n["ko"]["List FOBs"] = "FOB 목록"
ctld.i18n["ko"]["List Beacons"] = "비콘 목록"
ctld.i18n["ko"]["List Radio Beacons"] = "라디오 비콘 목록"
ctld.i18n["ko"]["Smoke Markers"] = "연막 마커"
ctld.i18n["ko"]["Drop Red Smoke"] = "적색 연막 투하"
ctld.i18n["ko"]["Drop Blue Smoke"] = "청색 연막 투하"
ctld.i18n["ko"]["Drop Orange Smoke"] = "주황색 연막 투하"
ctld.i18n["ko"]["Drop Green Smoke"] = "녹색 연막 투하"
ctld.i18n["ko"]["Drop Beacon"] = "비콘 투하"
ctld.i18n["ko"]["Radio Beacons"] = "라디오 비콘"
ctld.i18n["ko"]["Remove Closest Beacon"] = "가까운 비콘 제거"
ctld.i18n["ko"]["JTAC Status"] = "JTAC 상태"
ctld.i18n["ko"]["DISABLE "] = "비활성화 "
ctld.i18n["ko"]["ENABLE "] = "활성화 "
ctld.i18n["ko"]["REQUEST "] = "요청 "
ctld.i18n["ko"]["Reset TGT Selection"] = "TGT 선택 초기화"
--========================================================================================================================
-- End : CTLD-i18n.lua 
-- ==================================================================================================== 
-- Start : CTLD_utils.lua 
-- Fichier: ctld_module.lua (Classes complètes et mises à jour)

-- 1. Définition du namespace global 'ctld'
ctld = ctld or {}

-- ====================================================================================================
-- CLASSE ctld.utils
-- ====================================================================================================

local utils = {}
ctld.utils = utils
if not ctld.utils.marks then ctld.utils.marks = {}; end

function ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
    local coalitionId = coalitionId or 2
    local markId = ctld.utils.getNextUniqId()

    -- Color
    local tableColor = { 0, 0, 255, 0.4 }  --blue  by default
    if coalitionId == 1 then
        tableColor = { 1, 0, 0, 0.4 }      --red  % of (r,g,b,alpha)    red
    elseif coalitionId == 2 then
        tableColor = { 0, 0, 255, 0.4 }    --blue  % of (r,g,b,alpha)   blue
    elseif coalitionId == 0 then
        tableColor = { 2, 173, 33, 0.4 }   --green  % of (r,g,b,alpha)  neutral
    elseif coalitionId == -1 then
        tableColor = { 247, 179, 30, 0.4 } --orange  % of (r,g,b,alpha) All
    end

    local tableFillColor = { 0, 0, 255, 0.4 } --tableColor
    local lineType = 1                        --solid
    local message = message or ""
    ctld.utils.marks[markId] = message

    --trigger.action.quadToAll(number coalition , number id , vec3 point1 , vec3 point2 , vec3 point3 , vec3 point4 , table color , table fillColor , number lineType , boolean readOnly, string message)
    trigger.action.quadToAll(coalitionId, markId,
        vec3Points1To4[1], vec3Points1To4[2], vec3Points1To4[3], vec3Points1To4[4],
        tableColor, tableFillColor, lineType, true, message)

    --[[-example ------------------------------------------------------------
local heliName = "h1-1"
local triggerUnitObj = Unit.getByName(heliName)
local vec3StartPoint = triggerUnitObj:getPosition().p
local vec3EndPoint = {x = vec3StartPoint.x+1000,z=vec3StartPoint.z+1000,y=vec3StartPoint.y}
ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
]] --
end

--------------------------------------------------------------------------------------------------------
-- Calculates the absolute coordinates (x, y, heading, altitude) of a target point
-- based on a reference point and a relative offset, respecting the DCS coordinate system
-- (X=North, Y=East) and magnetic declination.
---------------------------------------------------------------------------------------------
-- @param refX X coordinate (North) of the reference point.
-- @param refY Y coordinate (East) of the reference point.
-- @param refHeading True/Geographic Heading of the reference unit in degrees.
-- @param refAltitude Altitude of the reference unit.
-- @param offsetAngleInDegrees Angle of the offset relative to the reference heading (0 = directly ahead).
-- @param offsetDistance Distance of the offset.
-- @param offsetHeading True/Geographic Heading for the final point.
-- @param offsetAltitude Altitude difference to add to the reference altitude.
-- @param magneticDeclinationInDegrees Magnetic Declination (subtract from True Heading to get Magnetic Heading).
--
-- @return x Absolute X coordinate (North) of the target point.
-- @return y Absolute Y coordinate (East) of the target point.
-- @return magneticHeadingInDegrees Magnetic Heading of the target point in degrees.
-- @return altitude Absolute altitude of the target point.
---
function ctld.utils.getRelativeCoords(
    refX, refY, refHeading, refAltitude,
    offsetAngleInDegrees, offsetDistanceInMeters,
    offsetHeadingInDegrees, offsetAltitudeInMeters,
    magneticDeclinationInDegrees
)
    -------------------------------------------------------------------------
    -- 1. Convert reference heading (radians → degrees)
    --    refHeading is a DCS true heading in radians, clockwise, 0 = North.
    -------------------------------------------------------------------------
    local refHeadingDeg = math.deg(refHeading)

    -------------------------------------------------------------------------
    -- 2. Compute the world angle used to project the new position.
    --    offsetAngleInDegrees is relative to the aircraft's heading.
    -------------------------------------------------------------------------
    local worldAngleDeg = refHeadingDeg + offsetAngleInDegrees

    -- Convert to radians for math.sin/cos (DCS uses clockwise headings)
    local worldAngleRad = math.rad(worldAngleDeg)

    -------------------------------------------------------------------------
    -- 3. Compute position deltas using DCS Cartesian coordinates:
    --    X axis = South/North, positive to the North.
    --    Y axis (vec3.z) = West/East, positive to the East.
    -------------------------------------------------------------------------
    local dx = math.cos(worldAngleRad) * offsetDistanceInMeters
    local dy = math.sin(worldAngleRad) * offsetDistanceInMeters

    local newX = refX + dx
    local newY = refY + dy

    -------------------------------------------------------------------------
    -- 4. Compute the object's final magnetic heading.
    --
    --    refHeadingDeg            = reference TRUE heading
    --    + offsetHeadingInDegrees = rotation relative to the reference
    --    - magneticDeclination    = convert true → magnetic
    -------------------------------------------------------------------------
    local magneticHeadingDeg =
        refHeadingDeg +
        offsetHeadingInDegrees -
        magneticDeclinationInDegrees

    -- Normalize to 0–360°
    magneticHeadingDeg = (magneticHeadingDeg % 360 + 360) % 360

    -------------------------------------------------------------------------
    -- 5. Compute altitude
    -------------------------------------------------------------------------
    local newAltitude = refAltitude + offsetAltitudeInMeters

    return newX, newY, magneticHeadingDeg, newAltitude
end

--------------------------------------------------------------------------------------------------------
-- Return a Vec2 point relative to  a reference point (position & heading DCS)
function ctld.utils.GetRelativeVec2Coords(refVec2Point, refHeadingInRadians, distanceFromRef,
                                          angleInDegreesFromRefHeading)
    -- absolue Heading in radians
    local absoluteHeadingInRadians = refHeadingInRadians + math.rad(angleInDegreesFromRefHeading)
    -- in DCS : x = Nord (+), z = Est (+)
    local dx = math.cos(absoluteHeadingInRadians) * distanceFromRef -- displacement North/South
    local dy = math.sin(absoluteHeadingInRadians) * distanceFromRef -- displacement Est/West

    local newCoords = {
        x = refVec2Point.x + dx,
        y = refVec2Point.y + dy,
    }
    return newCoords
end

--------------------------------------------------------------------------------------------------------
--- Returns magnetic variation of given DCS point (vec2 or vec3).
-- borrowed from mist
function ctld.utils.getNorthCorrectionInRadians(caller, vec2OrVec3Point) --gets the correction needed for true north (magnetic variation)
    if vec2OrVec3Point == nil then
        if env and env.error then
            env.error("ctld.utils.getNorthCorrectionInRadians()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return 0
    end

    local point = ctld.utils.deepCopy(vec2OrVec3Point)
    if not point.z then --Vec2; convert to Vec3
        point.z = point.y
        point.y = 0
    end
    local lat, lon = coord.LOtoLL(point)
    local north_posit = coord.LLtoLO(lat + 1, lon)
    return math.atan(north_posit.z - point.z, north_posit.x - point.x)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:getHeadingInRadians
-- @-- borrowed from mist
---@param unitObject any
---@param rawHeading boolean (true=geographic/false=magnetic)
---@return integer       --- @--return "magneticHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, false)))..", geographicHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, true)))
function ctld.utils.getHeadingInRadians(caller, unitObject, rawHeading) --rawHeading: boolean (true=geographic/false=magnetic)
    if not unitObject then
        if env and env.error then
            env.error("ctld.utils.getHeadingInRadians()." .. tostring(caller) .. ": Invalid unit object provided.")
        end
        return 0
    end
    rawHeading = rawHeading or false
    local unitpos = unitObject:getPosition()
    if unitpos then
        local HeadingInRadians = math.atan(unitpos.x.z, unitpos.x.x)
        if not rawHeading then
            HeadingInRadians = HeadingInRadians +
                ctld.utils.getNorthCorrectionInRadians("ctld.utils.getHeadingInRadians()", unitpos.p)
        end
        if HeadingInRadians < 0 then
            HeadingInRadians = HeadingInRadians + 2 * math.pi -- put heading in range of 0 to 2*pi
        end
        return HeadingInRadians
    end
    return 0
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec2 to a Vec3.
-- @-- borrowed from mist
-- @tparam Vec2 vec the 2D vector
-- @param y optional new y axis (altitude) value. If omitted it's 0.
function ctld.utils.makeVec3FromVec2OrVec3(caller, vec, y)
    if not vec then
        if env and env.error then
            env.error("ctld.utils.makeVec3FromVec2OrVec3()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return { x = vec.x, y = y, z = vec.y }
    else
        return { x = vec.x, y = vec.y, z = vec.z } -- it was already Vec3, actually.
    end
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec3 to a Vec2.
-- @tparam Vec3 vec the 3D vector
-- @return vector converted to Vec2
function ctld.utils.makeVec2FromVec3OrVec2(caller, vec)
    if vec == nil then
        if env and env.error then
            env.error("ctld.utils.makeVec2FromVec3OrVec2()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if vec.z then
        return { x = vec.x, y = vec.z }
    else
        return { x = vec.x, y = vec.y } -- it was actually already vec2.
    end
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:rotateVec3
-- Calcule l'offset cartésien absolu en appliquant la rotation du cap de l'appareil.
-- (Conçu pour le format de données : relative = {x, y, z})
function ctld.utils.rotateVec3(relativeVec, headingDeg)
    local x_rel = relativeVec.x
    local z_rel = relativeVec.z
    -- y_rel n'est pas utilisé dans le calcul de rotation, mais sera dans le retour
    local y_rel = relativeVec.y or 0

    -- Vérification des données (X et Z sont obligatoires)
    if x_rel == nil or z_rel == nil then
        local msg = "CTLD.utils:rotateVec3: Missing X or Z component in relative position data."
        if env and env.error then
            env.error(msg)
            -- Lève une erreur qui sera capturée par pcall (si appelé)
            error(msg)
        else
            error(msg)
        end
    end

    local headingRad = math.rad(headingDeg)
    local cos_h = math.cos(headingRad)
    local sin_h = math.sin(headingRad)

    local x_rot = (z_rel * sin_h) + (x_rel * cos_h)
    local z_rot = (z_rel * cos_h) - (x_rel * sin_h)

    return { x = x_rot, y = y_rel, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
-- Add 2 position vectors (Vec3) of DCS.
function ctld.utils.addVec3(vec1, vec2)
    return {
        -- Use or 0 to avoid 'nil'
        x = (vec1.x or 0) + (vec2.x or 0),
        y = (vec1.y or 0) + (vec2.y or 0),
        z = (vec1.z or 0) + (vec2.z or 0),
    }
end

--------------------------------------------------------------------------------------------------------
--- Vector substraction.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn Vec3 new vector, vec2 substracted from vec1.
function ctld.utils.subVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.subVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return nil
    end
    return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
end

--------------------------------------------------------------------------------------------------------
--- Vector dot product.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn number dot product of given vectors
function ctld.utils.multVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.multVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

--------------------------------------------------------------------------------------------------------
--- Returns the center of a zone as Vec3.
-- @-- borrowed from mist
-- @tparam string|table zone trigger zone name or table
-- @treturn Vec3 center of the zone
function ctld.utils.zoneToVec3(caller, zone, gl)
    if zone == nil then
        if env and env.error then
            env.error("ctld.utils.zoneToVec3()." .. tostring(caller) .. ": Invalid zone provided.")
        end
        return nil
    end

    local new = {}
    if type(zone) == 'table' then
        if zone.point then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        elseif zone.x and zone.y and zone.z then
            new = ctld.utils.deepCopy("ctld.utils.zoneToVec3()", zone)
        end
        return new
    elseif type(zone) == 'string' then
        zone = trigger.misc.getZone(zone)
        if zone then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        end
    end
    if new.x and gl then
        new.y = land.getHeight({ x = new.x, y = new.z })
    end
    return new
end

--------------------------------------------------------------------------------------------------------
--- Vector magnitude
-- @tparam Vec3 (3D with x,y,z)vec vector
-- @treturn number magnitude of vector vec
function ctld.utils.vec3Mag(caller, vec3)
    if vec3 == nil or vec3.x == nil or vec3.y == nil or vec3.z == nil then
        if env and env.error then
            env.error("ctld.utils.vec3Mag()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return 0
    end

    return (vec3.x ^ 2 + vec3.y ^ 2 + vec3.z ^ 2) ^ 0.5
end

--------------------------------------------------------------------------------------------------------
--- Returns distance in meters between two points.
-- @-- borrowed from mist
-- @tparam Vec2|Vec3 point1 first point
-- @tparam Vec2|Vec3 point2 second point
-- @treturn number distance between given points.
function ctld.utils.get2DDist(caller, point1, point2)
    if point1 == nil or point2 == nil then
        if env and env.error then
            env.error("ctld.utils.get2DDist()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    if not point1 then
        log:warn("ctld.utils.get2DDist()  1st input value is nil")
    end
    if not point2 then
        log:warn("ctld.utils.get2DDist()  2nd input value is nil")
    end
    point1 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point1)
    point2 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point2)
    return ctld.utils.vec3Mag("ctld.utils.get2DDist()", { x = point1.x - point2.x, y = 0, z = point1.z - point2.z })
end

--------------------------------------------------------------------------------------------------------
--- Simple rounding function.
-- @-- borrowed from mist
-- From http://lua-users.org/wiki/SimpleRound
-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
-- @tparam number num number to round
-- @param idp
function ctld.utils.round(caller, num, idp)
    if num == nil or type(num) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.round()." .. tostring(caller) .. ": Invalid number provided.")
        end
        return 0
    end
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------------------------------
utils.UniqIdCounter = 0 -- Compteur statique pour les ID uniques
--- @function ctld.utils:getNextUniqId
-- Génère un ID unique incrémental, comme requis pour 'unitId' dans groupData.
function ctld.utils.getNextUniqId()
    utils.UniqIdCounter = utils.UniqIdCounter + 1
    return utils.UniqIdCounter
end

--- Converts angle in radians to degrees.
-- @param angle angle in radians
-- @return angle in degrees
function ctld.utils.radianToDegree(caller, angleInRadians)
    if angle == nil or type(angle) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.toDegree()." .. tostring(caller) .. ": Invalid angle provided.")
        end
        return 0
    end
    return math.deg(angleInRadians)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:normalizeHeading
-- Normalise a heading between 0 et 360 degrees.
function ctld.utils.normalizeHeadingInDegrees(caller, offsetHeadingInDegrees)
    if offsetHeadingInDegrees == nil then
        if env and env.error then
            env.error("CTLD.utils.normalizeHeadingInDegrees()." .. tostring(caller) .. ": Invalid heading provided.")
        end
        return 0
    end
    local result = offsetHeadingInDegrees % 360
    if result < 0 then
        result = result + 360
    end
    return result
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:polarToCartesian
-- Convertit une distance (rho), un angle (theta) et un cap de référence (headingDeg)
-- en coordonnées cartésiennes absolues (x, z) de la carte DCS.
-- @param distance number La distance au point de référence.
-- @param relativeAngle number L'angle relatif au point de référence (0 = devant, 90 = droite).
-- @param headingDeg number Le cap absolu de l'appareil (point de référence).
-- @return table L'offset cartésien absolu { x, y=0, z }.
function ctld.utils.polarToCartesian(distance, relativeAngle, headingDeg)
    local absoluteAngle = headingDeg + relativeAngle
    local angleRad = math.rad(absoluteAngle)

    -- Correction du facteur distance (20m -> 10m)
    local dist = (distance or 0) * 2

    -- X (Nord/Sud, l'axe de référence du cap 0°) : Utilise COS
    local x_rot = dist * math.cos(angleRad)

    -- Z (Est/Ouest) : Utilise SIN. La trigonométrie standard sin(angle) augmente CCW.
    -- Nous ne touchons pas au signe car la trigonométrie de DCS peut être non standard.
    local z_rot = dist * math.sin(angleRad)

    return { x = x_rot, y = 0, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
--- Converts kilometers per hour to meters per second.
-- @param kmph speed in km/h
-- @return speed in m/s
function ctld.utils.kmphToMps(caller, kmph)
    if kmph == nil or type(kmph) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.kmphToMps()." .. tostring(caller) .. ": Invalid speed provided.")
        end
        return 0
    end
    return kmph / 3.6
end

--------------------------------------------------------------------------------------------------------
--- Builds a ground waypoint from a point definition.
-- No longer accepts path
function ctld.utils.buildWP(caller, point, overRideForm, overRideSpeed)
    if point == nil then
        if env and env.error then
            env.error("ctld.utils.buildWP()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return nil
    end

    local wp = {}
    wp.x = point.x

    if point.z then
        wp.y = point.z
    else
        wp.y = point.y
    end
    local form, speed

    if point.speed and not overRideSpeed then
        wp.speed = point.speed
    elseif type(overRideSpeed) == 'number' then
        wp.speed = overRideSpeed
    else
        wp.speed = ctld.utils.kmphToMps("ctld.utils.buildWP()", 20)
    end

    if point.form and not overRideForm then
        form = point.form
    else
        form = overRideForm
    end

    if not form then
        wp.action = 'Cone'
    else
        form = string.lower(form)
        if form == 'off_road' or form == 'off road' then
            wp.action = 'Off Road'
        elseif form == 'on_road' or form == 'on road' then
            wp.action = 'On Road'
        elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest' then
            wp.action = 'Rank'
        elseif form == 'cone' then
            wp.action = 'Cone'
        elseif form == 'diamond' then
            wp.action = 'Diamond'
        elseif form == 'vee' then
            wp.action = 'Vee'
        elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
            wp.action = 'EchelonL'
        elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
            wp.action = 'EchelonR'
        else
            wp.action = 'Cone' -- if nothing matched
        end
    end

    wp.type = 'Turning Point'

    return wp
end

--------------------------------------------------------------------------------------------------------
function ctld.utils.getUnitsLOS(caller, unitset1, altoffset1, unitset2, altoffset2, radius)
    --log:info("$1, $2, $3, $4, $5", unitset1, altoffset1, unitset2, altoffset2, radius)
    if unitset1 == nil or unitset2 == nil or altoffset1 == nil or altoffset2 == nil or radius == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsLOS()." .. tostring(caller) .. ": parameters sets cannot be nil.")
        end
        return {}
    end

    radius = radius or math.huge
    local unit_info1 = {}
    local unit_info2 = {}

    -- get the positions all in one step, saves execution time.
    for unitset1_ind = 1, #unitset1 do
        local unit1 = Unit.getByName(unitset1[unitset1_ind])
        if unit1 then
            local lCat = Object.getCategory(unit1)
            if ((lCat == 1 and unit1:isActive()) or lCat ~= 1) and unit1:isExist() == true then
                unit_info1[#unit_info1 + 1] = {}
                unit_info1[#unit_info1].unit = unit1
                unit_info1[#unit_info1].pos = unit1:getPosition().p
            end
        end
    end

    for unitset2_ind = 1, #unitset2 do
        local unit2 = Unit.getByName(unitset2[unitset2_ind])
        if unit2 then
            local lCat = Object.getCategory(unit2)
            if ((lCat == 1 and unit2:isActive()) or lCat ~= 1) and unit2:isExist() == true then
                unit_info2[#unit_info2 + 1] = {}
                unit_info2[#unit_info2].unit = unit2
                unit_info2[#unit_info2].pos = unit2:getPosition().p
            end
        end
    end

    local LOS_data = {}
    -- now compute los
    for unit1_ind = 1, #unit_info1 do
        local unit_added = false
        for unit2_ind = 1, #unit_info2 do
            if radius == math.huge or (ctld.utils.vec3Mag("ctld.utils.getUnitsLOS()", ctld.utils.subVec3("ctld.utils.getUnitsLOS()", unit_info1[unit1_ind].pos, unit_info2[unit2_ind].pos)) < radius) then -- inside radius
                local point1 = {
                    x = unit_info1[unit1_ind].pos.x,
                    y = unit_info1[unit1_ind].pos.y + altoffset1,
                    z =
                        unit_info1[unit1_ind].pos.z
                }
                local point2 = {
                    x = unit_info2[unit2_ind].pos.x,
                    y = unit_info2[unit2_ind].pos.y + altoffset2,
                    z =
                        unit_info2[unit2_ind].pos.z
                }
                if land.isVisible(point1, point2) then
                    if unit_added == false then
                        unit_added = true
                        LOS_data[#LOS_data + 1] = {}
                        LOS_data[#LOS_data].unit = unit_info1[unit1_ind].unit
                        LOS_data[#LOS_data].vis = {}
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    else
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    end
                end
            end
        end
    end

    return LOS_data
end

--------------------------------------------------------------------------------------------------------
-- same as getGroupPoints but returns speed and formation type along with vec2 of point}
function ctld.utils.getGroupRoute(caller, groupIdent, task)
    if groupIdent == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupRoute()." .. tostring(caller) .. ": Invalid group identifier provided.")
        end
        return nil
    end
    -- refactor to search by groupId and allow groupId and groupName as inputs
    local gpId = groupIdent
    if mist.DBs.MEgroupsByName[groupIdent] then
        gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
    else
        log:error("ctld.utils.getGroupRoute()." .. tostring(caller) .. '$1 not found in mist.DBs.MEgroupsByName',
            groupIdent)
    end

    for coa_name, coa_data in pairs(env.mission.coalition) do
        if type(coa_data) == 'table' then
            if coa_data.country then --there is a country table
                for cntry_id, cntry_data in pairs(coa_data.country) do
                    for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                        if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then                       -- only these types have points
                            if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
                                for group_num, group_data in pairs(obj_cat_data.group) do
                                    if group_data and group_data.groupId == gpId then                                                                                -- this is the group we are looking for
                                        if group_data.route and group_data.route.points and #group_data.route.points > 0 then
                                            local points = {}

                                            for point_num, point in pairs(group_data.route.points) do
                                                local routeData = {}
                                                if env.mission.version > 7 and env.mission.version < 19 then
                                                    routeData.name = env.getValueDictByKey(point.name)
                                                else
                                                    routeData.name = point.name
                                                end
                                                if not point.point then
                                                    routeData.x = point.x
                                                    routeData.y = point.y
                                                else
                                                    routeData.point = point
                                                        .point --it's possible that the ME could move to the point = Vec2 notation.
                                                end
                                                routeData.form = point.action
                                                routeData.speed = point.speed
                                                routeData.alt = point.alt
                                                routeData.alt_type = point.alt_type
                                                routeData.airdromeId = point.airdromeId
                                                routeData.helipadId = point.helipadId
                                                routeData.type = point.type
                                                routeData.action = point.action
                                                if task then
                                                    routeData.task = point.task
                                                end
                                                points[point_num] = routeData
                                            end

                                            return points
                                        end
                                        log:error('Group route not defined in mission editor for groupId: $1', gpId)
                                        return
                                    end --if group_data and group_data.name and group_data.name == 'groupname'
                                end     --for group_num, group_data in pairs(obj_cat_data.group) do
                            end         --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
                        end             --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
                    end                 --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                end                     --for cntry_id, cntry_data in pairs(coa_data.country) do
            end                         --if coa_data.country then --there is a country table
        end                             --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
    end                                 --for coa_name, coa_data in pairs(mission.coalition) do
end

--------------------------------------------------------------------------------------------------------
--Gets the average position of a group of units (by name)
function ctld.utils.getAvgPos(caller, unitNames)
    if unitNames == nil or #unitNames == 0 then
        if env and env.error then
            env.error("ctld.utils.getAvgPos()." .. tostring(caller) .. ": Invalid unit names provided.")
        end
        return nil
    end

    local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
    for i = 1, #unitNames do
        local unit
        if Unit.getByName(unitNames[i]) then
            unit = Unit.getByName(unitNames[i])
        elseif StaticObject.getByName(unitNames[i]) then
            unit = StaticObject.getByName(unitNames[i])
        end
        if unit and unit:isExist() == true then
            local pos = unit:getPosition().p
            if pos then -- you never know O.o
                avgX = avgX + pos.x
                avgY = avgY + pos.y
                avgZ = avgZ + pos.z
                totNum = totNum + 1
            end
        end
    end
    if totNum ~= 0 then
        return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
    end
end

--------------------------------------------------------------------------------------------------------
--- Creates a deep copy of a object.
-- @-- borrowed from mist
-- Usually this object is a table.
-- See also: from http://lua-users.org/wiki/CopyTable
-- @param object object to copy
-- @return copy of object
function ctld.utils.deepCopy(caller, object)
    local lookup_table = {}
    if object == nil then
        if env and env.error then
            env.error("ctld.utils.deepCopy()." .. tostring(caller) .. ": Attempt to deep copy a nil object.")
        end
        return nil
    end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--======================================================================================================
--- Returns table in a easy readable string representation.
-- borrowed from mist
-- this function is not meant for serialization because it uses
-- newlines for better readability.
-- @param tbl table to show
-- @param loc
-- @param indent
-- @param tableshow_tbls
-- @return human readable string representation of given table
function ctld.utils.tableShow(caller, tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
    if tbl == nil then
        if env and env.error then
            env.error("ctld.utils.tableShow()." .. tostring(caller) .. ": Attempt to show a nil table.")
        end
        return "nil"
    end

    tableshow_tbls = tableshow_tbls or {} --create table of tables
    loc = loc or ""
    indent = indent or ""
    if type(tbl) == 'table' then --function only works for tables!
        tableshow_tbls[tbl] = loc

        local tbl_str = {}

        --tbl_str[#tbl_str + 1] = indent .. '{\n'
        tbl_str[#tbl_str + 1] = '{\n'

        for ind, val in pairs(tbl) do
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'nil' then -- won't ever happen, right?
                tbl_str[#tbl_str + 1] = 'nil,\n'
            elseif type(val) == 'table' then
                if tableshow_tbls[val] then
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                else
                    --tableshow_tbls[val] = loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']'
                    --tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                    --[[
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val,
                    loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']',
                    indent .. '    ',
                    tableshow_tbls) ]] --
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val, loc, indent .. '    ')
                    tbl_str[#tbl_str + 1] = ',\n'
                end
            elseif type(val) == 'function' then
                if debug and debug.getinfo then
                    local fcnname = tostring(val)
                    local info = debug.getinfo(val, "S")
                    if info.what == "C" then
                        tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                    else
                        if (string.sub(info.source, 1, 2) == [[./]]) then
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                fcnname ..
                                ', defined in (' ..
                                info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) .. ',\n'
                        else
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                    fcnname ..
                                    ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..
                                ',\n'
                        end
                    end
                else
                    tbl_str[#tbl_str + 1] = 'a function,\n'
                end
            else
                tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
                    ctld.utils.basicSerialize("ctld.utils.tableShow()", type(val)) .. ' at index ' .. tostring(ind)
            end
        end
        --string.sub("Hello, World!", -6, -1)
        if string.sub(table.concat(tbl_str), - #indent - 2, -1) == '{\n' then
            trigger.action.outText(string.sub(table.concat(tbl_str), - #indent - 2, -1), 10)
            for i = 1, #indent do
                tbl_str[#tbl_str] = nil
            end
            tbl_str[#tbl_str + 1] = '{}'
        else
            tbl_str[#tbl_str + 1] = indent .. '}'
        end
        return table.concat(tbl_str)
    end
end

--======================================================================================================
--- Serializes the give variable to a string.
-- borrowed from slmod
-- @param var variable to serialize
-- @treturn string variable serialized to string
function ctld.utils.basicSerialize(caller, var)
    if var == nil then
        if env and env.error then
            env.error("ctld.utils.basicSerialize()." .. tostring(caller) .. ": Attempt to serialize a nil variable.")
        end
        return "nil"
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata')) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end
-- End : CTLD_utils.lua 
-- ==================================================================================================== 
-- Start : CTLD.lua 
--[[ ! IMPORTANT : You must must use the version of MIST supplied in the CTLD pack to correctly manage dynamic spwans

        Combat Troop and Logistics Drop

        Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
        without requiring external mods.

        Supports all of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

        Supports deployment of Auto Lasing JTAC to the field

        See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

        Contributors:
                - Steggles - https://github.com/Bob7heBuilder
                - mvee - https://github.com/mvee
                - jmontleon - https://github.com/jmontleon
                - emilianomolina - https://github.com/emilianomolina
                - davidp57 - https://github.com/veaf
                - Queton1-1 - https://github.com/Queton1-1
                - Proxy404 - https://github.com/Proxy404
                - atcz - https://github.com/atcz
                - marcos2221- https://github.com/marcos2221
                - FullGas1 - https://github.com/FullGas1 (i18n concept, FR and SP translations)

        Add [issues](https://github.com/ciribob/DCS-CTLD/issues) to the GitHub repository if you want to report a bug or suggest a new feature.

        Contact Zip [on Discord](https://discordapp.com/users/421317390807203850) or [on Github](https://github.com/davidp57) if you need help or want to have a friendly chat.

        Send beers (or kind messages) to Ciribob [on Discord](https://discordapp.com/users/204712384747536384), he's the reason we have CTLD ^^
 ]]

if not ctld then -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    trigger.action.outText(
        "\n\n** HEY MISSION-DESIGNER! **\n\nCTLD-i18n has not been loaded!\n\nMake sure CTLD-i18n is loaded\n*before* running this script!\n\nIt contains all the translations!\n",
        10)
    ctld = {} -- DONT REMOVE!
end

--- Identifier. All output in DCS.log will start with this.
ctld.Id = "CTLD - "

--- Version.
ctld.Version = "1.6.4"

-- To add debugging messages to dcs.log, change the following log levels to `true`; `Debug` is less detailed than `Trace`
ctld.Debug = false
ctld.Trace = true

if ctld.Debug then
    env.info(ctld.Id .. "Debug logging is ENABLED")
end

ctld.dontInitialize = false -- if true, ctld.initialize() will not run; instead, you'll have to run it from your own code - it's useful when you want to override some functions/parameters before the initialization takes place

-- ***************************************************************
-- *************** Internationalization (I18N) *******************
-- ***************************************************************

-- If you want to change the language replace "en" with the language you want to use

--========    ENGLISH - the reference ===========================================================================
ctld.i18n_lang = "en"
--========    FRENCH - FRANCAIS =================================================================================
--ctld.i18n_lang = "fr"
--======    SPANISH : ESPAÑOL ====================================================================================
--ctld.i18n_lang = "es"
--======    Korean : 한국어 ====================================================================================
--ctld.i18n_lang = "ko"

if not ctld.i18n then -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    ctld.i18n = {}    -- DONT REMOVE!
end

-- This is the default language
-- If a string is not found in the current language then it will default to this language
-- Note that no translation is provided for this language (obviously) but that we'll maintain this table to help the translators.
ctld.i18n["en"] = {}
ctld.i18n["en"].translation_version =
"1.6" -- make sure that all the translations are compatible with this version of the english language texts
local lang = "en"; env.info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
    tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["en"]["Standard Group"] = ""
ctld.i18n["en"]["Anti Air"] = ""
ctld.i18n["en"]["Anti Tank"] = ""
ctld.i18n["en"]["Mortar Squad"] = ""
ctld.i18n["en"]["JTAC Group"] = ""
ctld.i18n["en"]["Single JTAC"] = ""
ctld.i18n["en"]["2x - Standard Groups"] = ""
ctld.i18n["en"]["2x - Anti Air"] = ""
ctld.i18n["en"]["2x - Anti Tank"] = ""
ctld.i18n["en"]["2x - Standard Groups + 2x Mortar"] = ""
ctld.i18n["en"]["3x - Standard Groups"] = ""
ctld.i18n["en"]["3x - Anti Air"] = ""
ctld.i18n["en"]["3x - Anti Tank"] = ""
ctld.i18n["en"]["3x - Mortar Squad"] = ""
ctld.i18n["en"]["5x - Mortar Squad"] = ""
ctld.i18n["en"]["Mortar Squad Red"] = ""

--- crates names
ctld.i18n["en"]["Humvee - MG"] = ""
ctld.i18n["en"]["Humvee - TOW"] = ""
ctld.i18n["en"]["Light Tank - MRAP"] = ""
ctld.i18n["en"]["Med Tank - LAV-25"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams"] = ""
ctld.i18n["en"]["BTR-D"] = ""
ctld.i18n["en"]["BRDM-2"] = ""
ctld.i18n["en"]["Hummer - JTAC"] = ""
ctld.i18n["en"]["M-818 Ammo Truck"] = ""
ctld.i18n["en"]["M-978 Tanker"] = ""
ctld.i18n["en"]["SKP-11 - JTAC"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck"] = ""
ctld.i18n["en"]["KAMAZ Ammo Truck"] = ""
ctld.i18n["en"]["EWR Radar"] = ""
ctld.i18n["en"]["FOB Crate - Small"] = ""
ctld.i18n["en"]["MQ-9 Repear - JTAC"] = ""
ctld.i18n["en"]["RQ-1A Predator - JTAC"] = ""
ctld.i18n["en"]["MLRS"] = ""
ctld.i18n["en"]["SpGH DANA"] = ""
ctld.i18n["en"]["T155 Firtina"] = ""
ctld.i18n["en"]["Howitzer"] = ""
ctld.i18n["en"]["SPH 2S19 Msta"] = ""
ctld.i18n["en"]["M1097 Avenger"] = ""
ctld.i18n["en"]["M48 Chaparral"] = ""
ctld.i18n["en"]["Roland ADS"] = ""
ctld.i18n["en"]["Gepard AAA"] = ""
ctld.i18n["en"]["LPWS C-RAM"] = ""
ctld.i18n["en"]["9K33 Osa"] = ""
ctld.i18n["en"]["9P31 Strela-1"] = ""
ctld.i18n["en"]["9K35M Strela-10"] = ""
ctld.i18n["en"]["9K331 Tor"] = ""
ctld.i18n["en"]["2K22 Tunguska"] = ""
ctld.i18n["en"]["HAWK Launcher"] = ""
ctld.i18n["en"]["HAWK Search Radar"] = ""
ctld.i18n["en"]["HAWK Track Radar"] = ""
ctld.i18n["en"]["HAWK PCP"] = ""
ctld.i18n["en"]["HAWK CWAR"] = ""
ctld.i18n["en"]["HAWK Repair"] = ""
ctld.i18n["en"]["NASAMS Launcher 120C"] = ""
ctld.i18n["en"]["NASAMS Search/Track Radar"] = ""
ctld.i18n["en"]["NASAMS Command Post"] = ""
ctld.i18n["en"]["NASAMS Repair"] = ""
ctld.i18n["en"]["KUB Launcher"] = ""
ctld.i18n["en"]["KUB Radar"] = ""
ctld.i18n["en"]["KUB Repair"] = ""
ctld.i18n["en"]["BUK Launcher"] = ""
ctld.i18n["en"]["BUK Search Radar"] = ""
ctld.i18n["en"]["BUK CC Radar"] = ""
ctld.i18n["en"]["BUK Repair"] = ""
ctld.i18n["en"]["Patriot Launcher"] = ""
ctld.i18n["en"]["Patriot Radar"] = ""
ctld.i18n["en"]["Patriot ECS"] = ""
ctld.i18n["en"]["Patriot ICC"] = ""
ctld.i18n["en"]["Patriot EPP"] = ""
ctld.i18n["en"]["Patriot AMG (optional)"] = ""
ctld.i18n["en"]["Patriot Repair"] = ""
ctld.i18n["en"]["S-300 Grumble TEL C"] = ""
ctld.i18n["en"]["S-300 Grumble Flap Lid-A TR"] = ""
ctld.i18n["en"]["S-300 Grumble Clam Shell SR"] = ""
ctld.i18n["en"]["S-300 Grumble Big Bird SR"] = ""
ctld.i18n["en"]["S-300 Grumble C2"] = ""
ctld.i18n["en"]["S-300 Repair"] = ""
ctld.i18n["en"]["Humvee - TOW - All crates"] = ""
ctld.i18n["en"]["Light Tank - MRAP - All crates"] = ""
ctld.i18n["en"]["Med Tank - LAV-25 - All crates"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams - All crates"] = ""
ctld.i18n["en"]["Hummer - JTAC - All crates"] = ""
ctld.i18n["en"]["M-818 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["M-978 Tanker - All crates"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["EWR Radar - All crates"] = ""
ctld.i18n["en"]["MLRS - All crates"] = ""
ctld.i18n["en"]["SpGH DANA - All crates"] = ""
ctld.i18n["en"]["T155 Firtina - All crates"] = ""
ctld.i18n["en"]["Howitzer - All crates"] = ""
ctld.i18n["en"]["SPH 2S19 Msta - All crates"] = ""
ctld.i18n["en"]["M1097 Avenger - All crates"] = ""
ctld.i18n["en"]["M48 Chaparral - All crates"] = ""
ctld.i18n["en"]["Roland ADS - All crates"] = ""
ctld.i18n["en"]["Gepard AAA - All crates"] = ""
ctld.i18n["en"]["LPWS C-RAM - All crates"] = ""
ctld.i18n["en"]["9K33 Osa - All crates"] = ""
ctld.i18n["en"]["9P31 Strela-1 - All crates"] = ""
ctld.i18n["en"]["9K35M Strela-10 - All crates"] = ""
ctld.i18n["en"]["9K331 Tor - All crates"] = ""
ctld.i18n["en"]["2K22 Tunguska - All crates"] = ""
ctld.i18n["en"]["HAWK - All crates"] = ""
ctld.i18n["en"]["NASAMS - All crates"] = ""
ctld.i18n["en"]["KUB - All crates"] = ""
ctld.i18n["en"]["BUK - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""

--- mission design error messages
ctld.i18n["en"]["CTLD.lua ERROR: Can't find trigger called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find crate with weight %1"] = ""

--- runtime messages
ctld.i18n["en"]["You are not close enough to friendly logistics to get a crate!"] = ""
ctld.i18n["en"]["No more JTAC Crates Left!"] = ""
ctld.i18n["en"]["Sorry you must wait %1 seconds before you can get another crate"] = ""
ctld.i18n["en"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into %3"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into %3"] = ""
ctld.i18n["en"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = ""
ctld.i18n["en"]["%1 dropped vehicles from %2 into combat"] = ""
ctld.i18n["en"]["%1 loaded troops into %2"] = ""
ctld.i18n["en"]["%1 loaded %2 vehicles into %3"] = ""
ctld.i18n["en"]["%1 delivered a FOB Crate"] = ""
ctld.i18n["en"]["Delivered FOB Crate 60m at 6'oclock to you"] = ""
ctld.i18n["en"]["FOB Crate dropped back to base"] = ""
ctld.i18n["en"]["FOB Crate Loaded"] = ""
ctld.i18n["en"]["%1 loaded a FOB Crate ready for delivery!"] = ""
ctld.i18n["en"]["There are no friendly logistic units nearby to load a FOB crate from!"] = ""
ctld.i18n["en"]["This area has no more reinforcements available!"] = ""
ctld.i18n["en"]["You are not in a pickup zone and no one is nearby to extract"] = ""
ctld.i18n["en"]["You are not in a pickup zone"] = ""
ctld.i18n["en"]["No one to unload"] = ""
ctld.i18n["en"]["Dropped troops back to base"] = ""
ctld.i18n["en"]["Dropped vehicles back to base"] = ""
ctld.i18n["en"]["You already have troops onboard."] = ""
ctld.i18n["en"]["Count Infantries limit in the mission reached, you can't load more troops"] = ""
ctld.i18n["en"]["You already have vehicles onboard."] = ""
ctld.i18n["en"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = ""
ctld.i18n["en"]["%1 extracted troops in %2 from combat"] = ""
ctld.i18n["en"]["No extractable troops nearby!"] = ""
ctld.i18n["en"]["%1 extracted vehicles in %2 from combat"] = ""
ctld.i18n["en"]["No extractable vehicles nearby!"] = ""
ctld.i18n["en"]["%1 troops onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["%1 vehicles onboard (%2)\n"] = ""
ctld.i18n["en"]["1 FOB Crate oboard (%1 kg)\n"] = ""
ctld.i18n["en"]["%1 crate onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["Total weight of cargo : %1 kg\n"] = ""
ctld.i18n["en"]["No cargo."] = ""
ctld.i18n["en"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
""
ctld.i18n["en"]["Loaded %1 crate!"] = ""
ctld.i18n["en"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["You must land before you can load a crate!"] = ""
ctld.i18n["en"]["No Crates within 50m to load!"] = ""
ctld.i18n["en"]["Maximum number of crates are on board!"] = ""
ctld.i18n["en"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = ""
ctld.i18n["en"]["FOB Crate - %1 m - %2 o'clock\n"] = ""
ctld.i18n["en"]["No Nearby Crates"] = ""
ctld.i18n["en"]["Nearby Crates:\n%1"] = ""
ctld.i18n["en"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = ""
ctld.i18n["en"]["FOB Positions:"] = ""
ctld.i18n["en"]["%1\nFOB @ %2"] = ""
ctld.i18n["en"]["Sorry, there are no active FOBs!"] = ""
ctld.i18n["en"]["You can't unpack that here! Take it to where it's needed!"] = ""
ctld.i18n["en"]["Sorry you must move this crate before you unpack it!"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field"] = ""
ctld.i18n["en"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = ""
ctld.i18n["en"]["Finished building FOB! Crates and Troops can now be picked up."] = ""
ctld.i18n["en"]["Finished building FOB! Crates can now be picked up."] = ""
ctld.i18n["en"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
""
ctld.i18n["en"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
""
ctld.i18n["en"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = ""
ctld.i18n["en"]["%1 crate has been safely dropped below you"] = ""
ctld.i18n["en"]["You were too high! The crate has been destroyed"] = ""
ctld.i18n["en"]["Radio Beacons:\n%1"] = ""
ctld.i18n["en"]["No Active Radio Beacons"] = ""
ctld.i18n["en"]["%1 deployed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["You need to land before you can deploy a Radio Beacon!"] = ""
ctld.i18n["en"]["%1 removed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["No Radio Beacons within 500m."] = ""
ctld.i18n["en"]["You need to land before remove a Radio Beacon"] = ""
ctld.i18n["en"]["%1 successfully rearmed a full %2 in the field"] = ""
ctld.i18n["en"]["Missing %1\n"] = ""
ctld.i18n["en"]["Out of parts for AA Systems. Current limit is %1\n"] = ""
ctld.i18n["en"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = ""
ctld.i18n["en"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = ""
ctld.i18n["en"]["%1 successfully repaired a full %2 in the field."] = ""
ctld.i18n["en"]["Cannot repair %1. No damaged %2 within 300m"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field using %3 crates."] = ""
ctld.i18n["en"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
""
ctld.i18n["en"]["%1 dropped %2 smoke."] = ""

--- JTAC messages
ctld.i18n["en"]["JTAC Group %1 KIA!"] = ""
ctld.i18n["en"]["%1, selected target reacquired, %2"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"]["new target, "] = ""
ctld.i18n["en"]["standing by on %1"] = ""
ctld.i18n["en"]["lasing %1"] = ""
ctld.i18n["en"][", temporarily %1"] = ""
ctld.i18n["en"]["target lost"] = ""
ctld.i18n["en"]["target destroyed"] = ""
ctld.i18n["en"][", selected %1"] = ""
ctld.i18n["en"]["%1 %2 target lost."] = ""
ctld.i18n["en"]["%1 %2 target destroyed."] = ""
ctld.i18n["en"]["JTAC STATUS: \n\n"] = ""
ctld.i18n["en"][", available on %1 %2,"] = ""
ctld.i18n["en"]["UNKNOWN"] = ""
ctld.i18n["en"][" targeting "] = ""
ctld.i18n["en"][" targeting selected unit "] = ""
ctld.i18n["en"][" attempting to find selected unit, temporarily targeting "] = ""
ctld.i18n["en"]["(Laser OFF) "] = ""
ctld.i18n["en"]["Visual On: "] = ""
ctld.i18n["en"][" searching for targets %1\n"] = ""
ctld.i18n["en"]["No Active JTACs"] = ""
ctld.i18n["en"][", targeting selected unit, %1"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"][", target selection reset."] = ""
ctld.i18n["en"]["%1, laser and smokes enabled"] = ""
ctld.i18n["en"]["%1, laser and smokes disabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations enabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations disabled"] = ""
ctld.i18n["en"]["%1, WHITE smoke deployed near target"] = ""

--- F10 menu messages
ctld.i18n["en"]["Actions"] = ""
ctld.i18n["en"]["Troop Transport"] = ""
ctld.i18n["en"]["Unload / Extract Troops"] = ""
ctld.i18n["en"]["Next page"] = ""
ctld.i18n["en"]["Load "] = ""
ctld.i18n["en"]["Vehicle / FOB Transport"] = ""
ctld.i18n["en"]["Crates: Vehicle / FOB / Drone"] = ""
ctld.i18n["en"]["Unload Vehicles"] = ""
ctld.i18n["en"]["Load / Extract Vehicles"] = ""
ctld.i18n["en"]["Load / Unload FOB Crate"] = ""
ctld.i18n["en"]["Repack Vehicles"] = ""
ctld.i18n["en"]["CTLD Commands"] = ""
ctld.i18n["en"]["CTLD"] = ""
ctld.i18n["en"]["Check Cargo"] = ""
ctld.i18n["en"]["Load Nearby Crate(s)"] = ""
ctld.i18n["en"]["Unpack Any Crate"] = ""
ctld.i18n["en"]["Drop Crate(s)"] = ""
ctld.i18n["en"]["List Nearby Crates"] = ""
ctld.i18n["en"]["List FOBs"] = ""
ctld.i18n["en"]["List Beacons"] = ""
ctld.i18n["en"]["List Radio Beacons"] = ""
ctld.i18n["en"]["Smoke Markers"] = ""
ctld.i18n["en"]["Drop Red Smoke"] = ""
ctld.i18n["en"]["Drop Blue Smoke"] = ""
ctld.i18n["en"]["Drop Orange Smoke"] = ""
ctld.i18n["en"]["Drop Green Smoke"] = ""
ctld.i18n["en"]["Drop Beacon"] = ""
ctld.i18n["en"]["Radio Beacons"] = ""
ctld.i18n["en"]["Remove Closest Beacon"] = ""
ctld.i18n["en"]["JTAC Status"] = ""
ctld.i18n["en"]["DISABLE "] = ""
ctld.i18n["en"]["ENABLE "] = ""
ctld.i18n["en"]["REQUEST "] = ""
ctld.i18n["en"]["Reset TGT Selection"] = ""
-- F10 RECON menus
ctld.i18n["en"]["RECON"] = ""
ctld.i18n["en"]["Show targets in LOS (refresh)"] = ""
ctld.i18n["en"]["Hide targets in LOS"] = ""
ctld.i18n["en"]["START autoRefresh targets in LOS"] = ""
ctld.i18n["en"]["STOP autoRefresh targets in LOS"] = ""

--- Translates a string (text) with parameters (parameters) to the language defined in ctld.i18n_lang
---@param text string The text to translate, with the parameters as %1, %2, etc. (all strings!!!!)
---@param ... any (list) The parameters to replace in the text, in order (all paremeters will be converted to string)
---@return string the translated and formatted text
function ctld.i18n_translate(text, ...)
    local _text

    if not ctld.i18n[ctld.i18n_lang] then
        env.info(string.format(" E - CTLD.i18n_translate: Language %s not found, defaulting to 'en'",
            tostring(ctld.i18n_lang)))
        _text = ctld.i18n["en"][text]
    else
        _text = ctld.i18n[ctld.i18n_lang][text]
    end

    -- default to english
    if _text == nil then
        _text = ctld.i18n["en"][text]
    end

    -- default to the provided text
    if _text == nil or _text == "" then
        _text = text
    end

    if arg and arg.n and arg.n > 0 then
        local _args = {}
        for i = 1, arg.n do
            _args[i] = tostring(arg[i]) or ""
        end
        for i = 1, #_args do
            _text = string.gsub(_text, "%%" .. i, _args[i])
        end
    end

    return _text
end

-- ************************************************************************
-- *********************    USER CONFIGURATION ******************************
-- ************************************************************************
ctld.staticBugWorkaround                  = false --    DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE

ctld.disableAllSmoke                      = false -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below

-- Allow units to CTLD by aircraft type and not by pilot name - this is done everytime a player enters a new unit
ctld.addPlayerAircraftByType              = true

ctld.hoverPickup                          = true  --    if set to false you can load crates with the F10 menu instead of hovering... Only if not using real crates!
ctld.loadCrateFromMenu                    = true  -- if set to true, you can load crates with the F10 menu OR hovering, in case of using choppers and planes for example.

ctld.enableCrates                         = true  -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.enableAllCrates                      = true  -- if false, the "all crates" menu items will not be displayed
ctld.slingLoad                            = false -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
-- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
-- to use the other method.
-- Set staticBugFix    to FALSE if use set ctld.slingLoad to TRUE
ctld.enableSmokeDrop                      = true                                          -- if false, helis and c-130 will not be able to drop smoke
ctld.maxExtractDistance                   = 125                                           -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic              = 200                                           -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.enableRepackingVehicles              = true                                          -- if true, vehicles can be repacked into crates
ctld.maximumDistanceRepackableUnitsSearch = 200                                           -- max distance from transportUnit to search force repackable units in meters
ctld.maximumSearchDistance                = 4000                                          -- max distance for troops to search for enemy
ctld.maximumMoveDistance                  = 2000                                          -- max distance for troops to move from drop point if no enemy is nearby
ctld.minimumDeployDistance                = 1000                                          -- minimum distance from a friendly pickup zone where you can deploy a crate
ctld.numberOfTroops                       = 10                                            -- default number of troops to load on a transport heli or C-130
-- also works as maximum size of group that'll fit into a helicopter unless overridden
ctld.enableFastRopeInsertion              = true                                          -- allows you to drop troops by fast rope
ctld.fastRopeMaximumHeight                = 18.28                                         -- in meters which is 60 ft max fast rope (not rappell) safe height
ctld.vehiclesForTransportRED              = { "BRDM-2", "BTR_D" }                         -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
ctld.vehiclesForTransportBLUE             = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}
ctld.vehiclesWeight                       = {
    ["BRDM-2"] = 7000,
    ["BTR_D"] = 8000,
    ["M1045 HMMWV TOW"] = 3220,
    ["M1043 HMMWV Armament"] = 2500
}

ctld.spawnRPGWithCoalition                = true  --spawns a friendly RPG unit with Coalition forces
ctld.spawnStinger                         = false -- spawns a stinger / igla soldier with a group of 6 or more soldiers!
ctld.enabledFOBBuilding                   = true  -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
-- In future i'd like it to be a FARP but so far that seems impossible...
-- You can also enable troop Pickup at FOBS
ctld.cratesRequiredForFOB                 = 3 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
-- The large crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled
-- Small FOB crates can be moved by helicopter. The FOB will require ctld.cratesRequiredForFOB larges crates and small crates are 1/3 of a large fob crate
-- To build the FOB entirely out of small crates you will need ctld.cratesRequiredForFOB * 3

ctld.troopPickupAtFOB                     = true     -- if true, troops can also be picked up at a created FOB
ctld.buildTimeFOB                         = 120      --time in seconds for the FOB to be built
ctld.crateWaitTime                        = 40       -- time in seconds to wait before you can spawn another crate
ctld.forceCrateToBeMoved                  = true     -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam
ctld.radioSound                           =
"beacon.ogg"                                         -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
ctld.radioSoundFC3                        =
"beaconsilent.ogg"                                   -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)
ctld.deployedBeaconBattery                = 30       -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed
ctld.enabledRadioBeaconDrop               = true     -- if its set to false then beacons cannot be dropped by units
ctld.allowRandomAiTeamPickups             = false    -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones
-- Limit the dropping of infantry teams -- this limit control is inactive if ctld.nbLimitSpawnedTroops = {0, 0} ----
ctld.nbLimitSpawnedTroops                 = { 0, 0 } -- {redLimitInfantryCount, blueLimitInfantryCount} when this cumulative number of troops is reached, no more troops can be loaded onboard
ctld.InfantryInGameCount                  = { 0, 0 } -- {redCoaInfantryCount, blueCoaInfantryCount}

-- Simulated Sling load configuration
ctld.minimumHoverHeight                   = 7.5  -- Lowest allowable height for crate hover
ctld.maximumHoverHeight                   = 12.0 -- Highest allowable height for crate hover
ctld.maxDistanceFromCrate                 = 5.5  -- Maximum distance from from crate for hover
ctld.hoverTime                            = 10   -- Time to hold hover above a crate for loading in seconds

-- end of Simulated Sling load configuration

-- ***************** AA SYSTEM CONFIG *****************
ctld.aaLaunchers                          = 3 -- controls how many launchers to add to the AA systems when its spawned if no amount is specified in the template.
-- Sets a limit on the number of active AA systems that can be built for RED.
-- A system is counted as Active if its fully functional and has all parts
-- If a system is partially destroyed, it no longer counts towards the total
-- When this limit is hit, a player will still be able to get crates for an AA system, just unable
-- to unpack them

ctld.AASystemLimitRED                     = 20 -- Red side limit
ctld.AASystemLimitBLUE                    = 20 -- Blue side limit

-- Allows players to create systems using as many crates as they like
-- Example : an amount X of patriot launcher crates allows for Y launchers to be deployed, if a player brings 2*X+Z crates (Z being lower then X), then deploys the patriot site, 2*Y launchers will be in the group and Z launcher crate will be left over

ctld.AASystemCrateStacking                = false
--END AA SYSTEM CONFIG ------------------------------------

-- ***************** JTAC CONFIGURATION *****************
ctld.JTAC_LIMIT_RED                       = 10    -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE                      = 10    -- max number of JTAC Crates for the BLUE Side
ctld.JTAC_dropEnabled                     = true  -- allow JTAC Crate spawn from F10 menu
ctld.JTAC_maxDistance                     = 10000 -- How far a JTAC can "see" in meters (with Line of Sight)
ctld.JTAC_smokeOn_RED                     = false -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE                    = false -- enables marking of target with smoke for BLUE forces
ctld.JTAC_smokeColour_RED                 = 4     -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE                = 1     -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeMarginOfError              = 50    -- error that the JTAC is allowed to make when popping a smoke (in meters)
ctld.JTAC_smokeOffset_x                   = 0.0   -- distance in the X direction from target to smoke (meters)
ctld.JTAC_smokeOffset_y                   = 2.0   -- distance in the Y direction from target to smoke (meters)
ctld.JTAC_smokeOffset_z                   = 0.0   -- distance in the z direction from target to smoke (meters)
ctld.JTAC_jtacStatusF10                   = true  -- enables F10 JTAC Status menu
ctld.JTAC_location                        = true  -- shows location of target in JTAC message
ctld.location_DMS                         = false -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes
ctld.JTAC_lock                            =
"all"                                             -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units
ctld.JTAC_allowStandbyMode                = true  -- if true, allow players to toggle lasing on/off
ctld.JTAC_laseSpotCorrections             = true  -- if true, each JTAC will have a special option (toggle on/off) available in it's menu to attempt to lead the target, taking into account current wind conditions and the speed of the target (particularily useful against moving heavy armor)
ctld.JTAC_allowSmokeRequest               = true  -- if true, allow players to request a smoke on target (temporary)
ctld.JTAC_allow9Line                      = true  -- if true, allow players to ask for a 9Line (individual) for a specific JTAC's target

-- ***************** Pickup, dropoff and waypoint zones *****************

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",
-- Use any of the predefined names or set your own ones
-- You can add number as a third option to limit the number of soldier or vehicle groups that can be loaded from a zone.
-- Dropping back a group at a limited zone will add one more to the limit
-- If a zone isn't ACTIVE then you can't pickup from that zone until the zone is activated by ctld.activatePickupZone
-- using the Mission editor
-- You can pickup from a SHIP by adding the SHIP UNIT NAME instead of a zone name
-- Side - Controls which side can load/unload troops at the zone
-- Flag Number - Optional last field. If set the current number of groups remaining can be obtained from the flag value
--pickupZones = { "Zone name or Ship Unit Name", "smoke color", "limit (-1 unlimited)", "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", flag number (optional) }
ctld.pickupZones                          = {
    { "pickzone1",   "blue", -1, "yes", 0 },
    { "pickzone2",   "red",  -1, "yes", 0 },
    { "pickzone3",   "none", -1, "yes", 0 },
    { "pickzone4",   "none", -1, "yes", 0 },
    { "pickzone5",   "none", -1, "yes", 0 },
    { "pickzone6",   "none", -1, "yes", 0 },
    { "pickzone7",   "none", -1, "yes", 0 },
    { "pickzone8",   "none", -1, "yes", 0 },
    { "pickzone9",   "none", 5,  "yes", 1 }, -- limits pickup zone 9 to 5 groups of soldiers or vehicles, only red can pick up
    { "pickzone10",  "none", 10, "yes", 2 }, -- limits pickup zone 10 to 10 groups of soldiers or vehicles, only blue can pick up

    { "pickzone11",  "blue", 20, "no",  2 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone12",  "red",  20, "no",  1 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone13",  "none", -1, "yes", 0 },
    { "pickzone14",  "none", -1, "yes", 0 },
    { "pickzone15",  "none", -1, "yes", 0 },
    { "pickzone16",  "none", -1, "yes", 0 },
    { "pickzone17",  "none", -1, "yes", 0 },
    { "pickzone18",  "none", -1, "yes", 0 },
    { "pickzone19",  "none", 5,  "yes", 0 },
    { "pickzone20",  "none", 10, "yes", 0, 1000 }, -- optional extra flag number to store the current number of groups available in

    { "USA Carrier", "blue", 10, "yes", 0, 1001 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
}

-- dropOffZones = {"name","smoke colour",0,side 1 = Red or 2 = Blue or 0 = Both sides}
ctld.dropOffZones                         = {
    { "dropzone1",  "green",  2 },
    { "dropzone2",  "blue",   2 },
    { "dropzone3",  "orange", 2 },
    { "dropzone4",  "none",   2 },
    { "dropzone5",  "none",   1 },
    { "dropzone6",  "none",   1 },
    { "dropzone7",  "none",   1 },
    { "dropzone8",  "none",   1 },
    { "dropzone9",  "none",   1 },
    { "dropzone10", "none",   1 },
}

--wpZones = { "Zone name", "smoke color",    "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", }
ctld.wpZones                              = {
    { "wpzone1",  "green",  "yes", 2 },
    { "wpzone2",  "blue",   "yes", 2 },
    { "wpzone3",  "orange", "yes", 2 },
    { "wpzone4",  "none",   "yes", 2 },
    { "wpzone5",  "none",   "yes", 2 },
    { "wpzone6",  "none",   "yes", 1 },
    { "wpzone7",  "none",   "yes", 1 },
    { "wpzone8",  "none",   "yes", 1 },
    { "wpzone9",  "none",   "yes", 1 },
    { "wpzone10", "none",   "no",  0 }, -- Both sides as its set to 0
}

-- ******************** Transports names **********************
-- If ctld.addPlayerAircraftByType = True, comment or uncomment lines to allow aircraft's type carry CTLD
ctld.aircraftTypeTable                    = {
    --%%%%% MODS %%%%%
    --"Bronco-OV-10A",
    --"Hercules",
    --"SK-60",
    --"UH-60L",
    --"T-45",

    --%%%%% CHOPPERS %%%%%
    --"Ka-50",
    --"Ka-50_3",
    "Mi-8MT",
    "Mi-24P",
    --"SA342L",
    --"SA342M",
    --"SA342Mistral",
    --"SA342Minigun",
    "UH-1H",
    "CH-47Fbl1",

    --%%%%% AIRCRAFTS %%%%%
    --"C-101EB",
    --"C-101CC",
    --"Christen Eagle II",
    --"L-39C",
    --"L-39ZA",
    --"MB-339A",
    --"MB-339APAN",
    --"Mirage-F1B",
    --"Mirage-F1BD",
    --"Mirage-F1BE",
    --"Mirage-F1BQ",
    --"Mirage-F1DDA",
    --"Su-25T",
    --"Yak-52",

    --%%%%% WARBIRDS %%%%%
    --"Bf-109K-4",
    --"Fw 190A8",
    --"FW-190D9",
    --"I-16",
    --"MosquitoFBMkVI",
    --"P-47D-30",
    --"P-47D-40",
    --"P-51D",
    --"P-51D-30-NA",
    --"SpitfireLFMkIX",
    --"SpitfireLFMkIXCW",
    --"TF-51D",
}

-- Use any of the predefined names or set your own ones
ctld.transportPilotNames                  = {
    "helicargo1",
    "helicargo2",
    "helicargo3",
    "helicargo4",
    "helicargo5",
    "helicargo6",
    "helicargo7",
    "helicargo8",
    "helicargo9",
    "helicargo10",

    "helicargo11",
    "helicargo12",
    "helicargo13",
    "helicargo14",
    "helicargo15",
    "helicargo16",
    "helicargo17",
    "helicargo18",
    "helicargo19",
    "helicargo20",

    "helicargo21",
    "helicargo22",
    "helicargo23",
    "helicargo24",
    "helicargo25",

    "MEDEVAC #1",
    "MEDEVAC #2",
    "MEDEVAC #3",
    "MEDEVAC #4",
    "MEDEVAC #5",
    "MEDEVAC #6",
    "MEDEVAC #7",
    "MEDEVAC #8",
    "MEDEVAC #9",
    "MEDEVAC #10",
    "MEDEVAC #11",
    "MEDEVAC #12",
    "MEDEVAC #13",
    "MEDEVAC #14",
    "MEDEVAC #15",
    "MEDEVAC #16",

    "MEDEVAC RED #1",
    "MEDEVAC RED #2",
    "MEDEVAC RED #3",
    "MEDEVAC RED #4",
    "MEDEVAC RED #5",
    "MEDEVAC RED #6",
    "MEDEVAC RED #7",
    "MEDEVAC RED #8",
    "MEDEVAC RED #9",
    "MEDEVAC RED #10",
    "MEDEVAC RED #11",
    "MEDEVAC RED #12",
    "MEDEVAC RED #13",
    "MEDEVAC RED #14",
    "MEDEVAC RED #15",
    "MEDEVAC RED #16",
    "MEDEVAC RED #17",
    "MEDEVAC RED #18",
    "MEDEVAC RED #19",
    "MEDEVAC RED #20",
    "MEDEVAC RED #21",

    "MEDEVAC BLUE #1",
    "MEDEVAC BLUE #2",
    "MEDEVAC BLUE #3",
    "MEDEVAC BLUE #4",
    "MEDEVAC BLUE #5",
    "MEDEVAC BLUE #6",
    "MEDEVAC BLUE #7",
    "MEDEVAC BLUE #8",
    "MEDEVAC BLUE #9",
    "MEDEVAC BLUE #10",
    "MEDEVAC BLUE #11",
    "MEDEVAC BLUE #12",
    "MEDEVAC BLUE #13",
    "MEDEVAC BLUE #14",
    "MEDEVAC BLUE #15",
    "MEDEVAC BLUE #16",
    "MEDEVAC BLUE #17",
    "MEDEVAC BLUE #18",
    "MEDEVAC BLUE #19",
    "MEDEVAC BLUE #20",
    "MEDEVAC BLUE #21",

    -- *** AI transports names (different names only to ease identification in mission) ***

    -- Use any of the predefined names or set your own ones
    "transport1",
    "transport2",
    "transport3",
    "transport4",
    "transport5",
    "transport6",
    "transport7",
    "transport8",
    "transport9",
    "transport10",

    "transport11",
    "transport12",
    "transport13",
    "transport14",
    "transport15",
    "transport16",
    "transport17",
    "transport18",
    "transport19",
    "transport20",

    "transport21",
    "transport22",
    "transport23",
    "transport24",
    "transport25",
}

-- *************** Optional Extractable GROUPS *****************

-- Use any of the predefined names or set your own ones
ctld.extractableGroups                    = {
    "extract1",
    "extract2",
    "extract3",
    "extract4",
    "extract5",
    "extract6",
    "extract7",
    "extract8",
    "extract9",
    "extract10",

    "extract11",
    "extract12",
    "extract13",
    "extract14",
    "extract15",
    "extract16",
    "extract17",
    "extract18",
    "extract19",
    "extract20",

    "extract21",
    "extract22",
    "extract23",
    "extract24",
    "extract25",
}

-- ************** Logistics UNITS FOR CRATE SPAWNING ******************

-- Use any of the predefined names or set your own ones
-- When a logistic unit is destroyed, you will no longer be able to spawn crates
ctld.dynamicLogisticUnitsIndex            = 0 -- This is the unit that will be spawned first and then subsequent units will be from the next in the list
ctld.logisticUnits                        = {
    "logistic1",
    "logistic2",
    "logistic3",
    "logistic4",
    "logistic5",
    "logistic6",
    "logistic7",
    "logistic8",
    "logistic9",
    "logistic10",
}

-- ************** UNITS ABLE TO TRANSPORT VEHICLES ******************
-- Add the model name of the unit that you want to be able to transport and deploy vehicles
-- units db has all the names or you can extract a mission.miz file by making it a zip and looking
-- in the contained mission file
ctld.vehicleTransportEnabled              = {
    "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
    "Hercules",
    --"CH-47Fbl1",
}

-- ************** Units able to use DCS dynamic cargo system ******************
-- DCS (version) added the ability to load and unload cargo from aircraft.
-- Units listed here will spawn a cargo static that can be loaded with the standard DCS cargo system
-- We will also use this to make modifications to the menu and other checks and messages
ctld.dynamicCargoUnits                    = {
    "CH-47Fbl1",
    "UH-1H",
    "Mi-8MT",
    "Mi-24P",
}

-- ************** Maximum Units SETUP for UNITS ******************
-- Put the name of the Unit you want to limit group sizes too
-- i.e
-- ["UH-1H"] = 10,
--
-- Will limit UH1 to only transport groups with a size 10 or less
-- Make sure the unit name is exactly right or it wont work

ctld.unitLoadLimits                       = {
    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = 4,
    -- ["SA342L"] = 4,
    -- ["SA342M"] = 4,

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = 4,
    ["Hercules"] = 30,
    --["SK-60"] = 1,
    ["UH-60L"] = 12,
    --["T-45"] = 1,

    --%%%%% CHOPPERS %%%%%
    ["Mi-8MT"] = 16,
    ["Mi-24P"] = 10,
    --["SA342L"] = 4,
    --["SA342M"] = 4,
    --["SA342Mistral"] = 4,
    --["SA342Minigun"] = 3,
    ["UH-1H"] = 8,
    ["CH-47Fbl1"] = 33,

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = 1,
    --["C-101CC"] = 1,
    --["Christen Eagle II"] = 1,
    --["L-39C"] = 1,
    --["L-39ZA"] = 1,
    --["MB-339A"] = 1,
    --["MB-339APAN"] = 1,
    --["Mirage-F1B"] = 1,
    --["Mirage-F1BD"] = 1,
    --["Mirage-F1BE"] = 1,
    --["Mirage-F1BQ"] = 1,
    --["Mirage-F1DDA"] = 1,
    --["Su-25T"] = 1,
    --["Yak-52"] = 1,

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = 1,
    --["Fw 190A8"] = 1,
    --["FW-190D9"] = 1,
    --["I-16"] = 1,
    --["MosquitoFBMkVI"] = 1,
    --["P-47D-30"] = 1,
    --["P-47D-40"] = 1,
    --["P-51D"] = 1,
    --["P-51D-30-NA"] = 1,
    --["SpitfireLFMkIX"] = 1,
    --["SpitfireLFMkIXCW"] = 1,
    --["TF-51D"] = 1,
}

-- Put the name of the Unit you want to enable loading multiple crates
ctld.internalCargoLimits                  = {

    -- Remove the -- below to turn on options
    ["Mi-8MT"] = 2,
    ["CH-47Fbl1"] = 8,
    --["UH-1H"] = 3, -- to remove after debug
}


-- ************** Allowable actions for UNIT TYPES ******************
-- Put the name of the Unit you want to limit actions for
-- NOTE - the unit must've been listed in the transportPilotNames list above
-- This can be used in conjunction with the options above for group sizes
-- By default you can load both crates and troops unless overriden below
-- i.e
-- ["UH-1H"] = {crates=true, troops=false},
--
-- Will limit UH1 to only transport CRATES but NOT TROOPS
--
-- ["SA342Mistral"] = {crates=fales, troops=true},
-- Will allow Mistral Gazelle to only transport crates, not troops

ctld.unitActions = {

    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = {crates=true, troops=true},
    -- ["SA342L"] = {crates=false, troops=true},
    -- ["SA342M"] = {crates=false, troops=true},

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = {crates=true, troops=true},
    ["Hercules"] = { crates = true, troops = true },
    ["SK-60"] = { crates = true, troops = true },
    ["UH-60L"] = { crates = true, troops = true },
    --["T-45"] = {crates=true, troops=true},

    --%%%%% CHOPPERS %%%%%
    --["Ka-50"] = {crates=true, troops=false},
    --["Ka-50_3"] = {crates=true, troops=false},
    ["Mi-8MT"] = { crates = true, troops = true },
    ["Mi-24P"] = { crates = true, troops = true },
    --["SA342L"] = {crates=false, troops=true},
    --["SA342M"] = {crates=false, troops=true},
    --["SA342Mistral"] = {crates=false, troops=true},
    --["SA342Minigun"] = {crates=false, troops=true},
    ["UH-1H"] = { crates = true, troops = true },
    ["CH-47Fbl1"] = { crates = true, troops = true },

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = {crates=true, troops=true},
    --["C-101CC"] = {crates=true, troops=true},
    --["Christen Eagle II"] = {crates=true, troops=true},
    --["L-39C"] = {crates=true, troops=true},
    --["L-39ZA"] = {crates=true, troops=true},
    --["MB-339A"] = {crates=true, troops=true},
    --["MB-339APAN"] = {crates=true, troops=true},
    --["Mirage-F1B"] = {crates=true, troops=true},
    --["Mirage-F1BD"] = {crates=true, troops=true},
    --["Mirage-F1BE"] = {crates=true, troops=true},
    --["Mirage-F1BQ"] = {crates=true, troops=true},
    --["Mirage-F1DDA"] = {crates=true, troops=true},
    --["Su-25T"]= {crates=true, troops=false},
    --["Yak-52"] = {crates=true, troops=true},

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = {crates=true, troops=false},
    --["Fw 190A8"] = {crates=true, troops=false},
    --["FW-190D9"] = {crates=true, troops=false},
    --["I-16"] = {crates=true, troops=false},
    --["MosquitoFBMkVI"] = {crates=true, troops=true},
    --["P-47D-30"] = {crates=true, troops=false},
    --["P-47D-40"] = {crates=true, troops=false},
    --["P-51D"] = {crates=true, troops=false},
    --["P-51D-30-NA"] = {crates=true, troops=false},
    --["SpitfireLFMkIX"] = {crates=true, troops=false},
    --["SpitfireLFMkIXCW"] = {crates=true, troops=false},
    --["TF-51D"] = {crates=true, troops=true},
}

-- ************** WEIGHT CALCULATIONS FOR INFANTRY GROUPS ******************

-- Infantry groups weight is calculated based on the soldiers' roles, and the weight of their kit
-- Every soldier weights between 90% and 120% of ctld.SOLDIER_WEIGHT, and they all carry a backpack and their helmet (ctld.KIT_WEIGHT)
-- Standard grunts have a rifle and ammo (ctld.RIFLE_WEIGHT)
-- AA soldiers have a MANPAD tube (ctld.MANPAD_WEIGHT)
-- Anti-tank soldiers have a RPG and a rocket (ctld.RPG_WEIGHT)
-- Machine gunners have the squad MG and 200 bullets (ctld.MG_WEIGHT)
-- JTAC have the laser sight, radio and binoculars (ctld.JTAC_WEIGHT)
-- Mortar servants carry their tube and a few rounds (ctld.MORTAR_WEIGHT)

ctld.SOLDIER_WEIGHT = 80 -- kg, will be randomized between 90% and 120%
ctld.KIT_WEIGHT = 20     -- kg
ctld.RIFLE_WEIGHT = 5    -- kg
ctld.MANPAD_WEIGHT = 18  -- kg
ctld.RPG_WEIGHT = 7.6    -- kg
ctld.MG_WEIGHT = 10      -- kg
ctld.MORTAR_WEIGHT = 26  -- kg
ctld.JTAC_WEIGHT = 15    -- kg

-- ************** INFANTRY GROUPS FOR PICKUP ******************
-- Unit Types
-- inf is normal infantry
-- mg is M249
-- at is RPG-16
-- aa is Stinger or Igla
-- mortar is a 2B11 mortar unit
-- jtac is a JTAC soldier, which will use JTACAutoLase
-- You must add a name to the group for it to work
-- You can also add an optional coalition side to limit the group to one side
-- for the side - 2 is BLUE and 1 is RED
ctld.loadableGroups = {
    { name = ctld.i18n_translate("Standard Group"),                   inf = 6,    mg = 2,  at = 2 }, -- will make a loadable group with 6 infantry, 2 MGs and 2 anti-tank for both coalitions
    { name = ctld.i18n_translate("Anti Air"),                         inf = 2,    aa = 3 },
    { name = ctld.i18n_translate("Anti Tank"),                        inf = 2,    at = 6 },
    { name = ctld.i18n_translate("Mortar Squad"),                     mortar = 6 },
    { name = ctld.i18n_translate("JTAC Group"),                       inf = 4,    jtac = 1 }, -- will make a loadable group with 4 infantry and a JTAC soldier for both coalitions
    { name = ctld.i18n_translate("Single JTAC"),                      jtac = 1 },             -- will make a loadable group witha single JTAC soldier for both coalitions
    { name = ctld.i18n_translate("2x - Standard Groups"),             inf = 12,   mg = 4,  at = 4 },
    { name = ctld.i18n_translate("2x - Anti Air"),                    inf = 4,    aa = 6 },
    { name = ctld.i18n_translate("2x - Anti Tank"),                   inf = 4,    at = 12 },
    { name = ctld.i18n_translate("2x - Standard Groups + 2x Mortar"), inf = 12,   mg = 4,  at = 4, mortar = 12 },
    { name = ctld.i18n_translate("3x - Standard Groups"),             inf = 18,   mg = 6,  at = 6 },
    { name = ctld.i18n_translate("3x - Anti Air"),                    inf = 6,    aa = 9 },
    { name = ctld.i18n_translate("3x - Anti Tank"),                   inf = 6,    at = 18 },
    { name = ctld.i18n_translate("3x - Mortar Squad"),                mortar = 18 },
    { name = ctld.i18n_translate("5x - Mortar Squad"),                mortar = 30 },
    -- {name = ctld.i18n_translate("Mortar Squad Red"), inf = 2, mortar = 5, side =1 }, --would make a group loadable by RED only
}

-- ************** SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
ctld.spawnableCrates = {
    -- name of the sub menu on F10 for spawning crates
    ["Combat Vehicles"] = {
        --crates you can spawn
        -- weight in KG
        -- Desc is the description on the F10 MENU
        -- unit is the model name of the unit to spawn
        -- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
        -- side is optional but 2 is BLUE and 1 is RED

        -- Some descriptions are filtered to determine if JTAC or not!

        --- BLUE
        { weight = 1000.01,                                  desc = ctld.i18n_translate("Humvee - MG"),                      unit = "M1043 HMMWV Armament", side = 2 }, --careful with the names as the script matches the desc to JTAC types
        { weight = 1000.02,                                  desc = ctld.i18n_translate("Humvee - TOW"),                     unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
        { multiple = { 1000.02, 1000.02 },                   desc = ctld.i18n_translate("Humvee - TOW - All crates"),        side = 2 },
        { weight = 1000.03,                                  desc = ctld.i18n_translate("Light Tank - MRAP"),                unit = "MaxxPro_MRAP",         side = 2, cratesRequired = 2 },
        { multiple = { 1000.03, 1000.03 },                   desc = ctld.i18n_translate("Light Tank - MRAP - All crates"),   side = 2 },
        { weight = 1000.04,                                  desc = ctld.i18n_translate("Med Tank - LAV-25"),                unit = "LAV-25",               side = 2, cratesRequired = 3 },
        { multiple = { 1000.04, 1000.04, 1000.04 },          desc = ctld.i18n_translate("Med Tank - LAV-25 - All crates"),   side = 2 },
        { weight = 1000.05,                                  desc = ctld.i18n_translate("Heavy Tank - Abrams"),              unit = "M-1 Abrams",           side = 2, cratesRequired = 4 },
        { multiple = { 1000.05, 1000.05, 1000.05, 1000.05 }, desc = ctld.i18n_translate("Heavy Tank - Abrams - All crates"), side = 2 },

        --- RED
        { weight = 1000.11,                                  desc = ctld.i18n_translate("BTR-D"),                            unit = "BTR_D",                side = 1 },
        { weight = 1000.12,                                  desc = ctld.i18n_translate("BRDM-2"),                           unit = "BRDM-2",               side = 1 },
        -- need more redfor!
    },
    ["Support"] = {
        --- BLUE
        { weight = 1001.01,                         desc = ctld.i18n_translate("Hummer - JTAC"),                    unit = "Hummer",            side = 2,          cratesRequired = 2 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { multiple = { 1001.01, 1001.01 },          desc = ctld.i18n_translate("Hummer - JTAC - All crates"),       side = 2 },
        { weight = 1001.02,                         desc = ctld.i18n_translate("M-818 Ammo Truck"),                 unit = "M 818",             side = 2,          cratesRequired = 2 },
        { multiple = { 1001.02, 1001.02 },          desc = ctld.i18n_translate("M-818 Ammo Truck - All crates"),    side = 2 },
        { weight = 1001.03,                         desc = ctld.i18n_translate("M-978 Tanker"),                     unit = "M978 HEMTT Tanker", side = 2,          cratesRequired = 2 },
        { multiple = { 1001.03, 1001.03 },          desc = ctld.i18n_translate("M-978 Tanker - All crates"),        side = 2 },

        --- RED
        { weight = 1001.11,                         desc = ctld.i18n_translate("SKP-11 - JTAC"),                    unit = "SKP-11",            side = 1 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 1001.12,                         desc = ctld.i18n_translate("Ural-375 Ammo Truck"),              unit = "Ural-375",          side = 1,          cratesRequired = 2 },
        { multiple = { 1001.12, 1001.12 },          desc = ctld.i18n_translate("Ural-375 Ammo Truck - All crates"), side = 1 },
        { weight = 1001.13,                         desc = ctld.i18n_translate("KAMAZ Ammo Truck"),                 unit = "KAMAZ Truck",       side = 1,          cratesRequired = 2 },

        --- Both
        { weight = 1001.21,                         desc = ctld.i18n_translate("EWR Radar"),                        unit = "FPS-117",           cratesRequired = 3 },
        { multiple = { 1001.21, 1001.21, 1001.21 }, desc = ctld.i18n_translate("EWR Radar - All crates") },
        { weight = 1001.22,                         desc = ctld.i18n_translate("FOB Crate - Small"),                unit = "FOB-SMALL" }, -- Builds a FOB! - requires 3 * ctld.cratesRequiredForFOB

    },
    ["Artillery"] = {
        --- BLUE
        { weight = 1002.01,                         desc = ctld.i18n_translate("MLRS"),                       unit = "MLRS",         side = 2, cratesRequired = 3 },
        { multiple = { 1002.01, 1002.01, 1002.01 }, desc = ctld.i18n_translate("MLRS - All crates"),          side = 2 },
        { weight = 1002.02,                         desc = ctld.i18n_translate("SpGH DANA"),                  unit = "SpGH_Dana",    side = 2, cratesRequired = 3 },
        { multiple = { 1002.02, 1002.02, 1002.02 }, desc = ctld.i18n_translate("SpGH DANA - All crates"),     side = 2 },
        { weight = 1002.03,                         desc = ctld.i18n_translate("T155 Firtina"),               unit = "T155_Firtina", side = 2, cratesRequired = 3 },
        { multiple = { 1002.03, 1002.03, 1002.03 }, desc = ctld.i18n_translate("T155 Firtina - All crates"),  side = 2 },
        { weight = 1002.04,                         desc = ctld.i18n_translate("Howitzer"),                   unit = "M-109",        side = 2, cratesRequired = 3 },
        { multiple = { 1002.04, 1002.04, 1002.04 }, desc = ctld.i18n_translate("Howitzer - All crates"),      side = 2 },

        --- RED
        { weight = 1002.11,                         desc = ctld.i18n_translate("SPH 2S19 Msta"),              unit = "SAU Msta",     side = 1, cratesRequired = 3 },
        { multiple = { 1002.11, 1002.11, 1002.11 }, desc = ctld.i18n_translate("SPH 2S19 Msta - All crates"), side = 1 },

    },
    ["SAM short range"] = {
        --- BLUE
        { weight = 1003.01,                         desc = ctld.i18n_translate("M1097 Avenger"),                unit = "M1097 Avenger",       side = 2, cratesRequired = 3 },
        { multiple = { 1003.01, 1003.01, 1003.01 }, desc = ctld.i18n_translate("M1097 Avenger - All crates"),   side = 2 },
        { weight = 1003.02,                         desc = ctld.i18n_translate("M48 Chaparral"),                unit = "M48 Chaparral",       side = 2, cratesRequired = 2 },
        { multiple = { 1003.02, 1003.02 },          desc = ctld.i18n_translate("M48 Chaparral - All crates"),   side = 2 },
        { weight = 1003.03,                         desc = ctld.i18n_translate("Roland ADS"),                   unit = "Roland ADS",          side = 2, cratesRequired = 3 },
        { multiple = { 1003.03, 1003.03, 1003.03 }, desc = ctld.i18n_translate("Roland ADS - All crates"),      side = 2 },
        { weight = 1003.04,                         desc = ctld.i18n_translate("Gepard AAA"),                   unit = "Gepard",              side = 2, cratesRequired = 3 },
        { multiple = { 1003.04, 1003.04, 1003.04 }, desc = ctld.i18n_translate("Gepard AAA - All crates"),      side = 2 },
        { weight = 1003.05,                         desc = ctld.i18n_translate("LPWS C-RAM"),                   unit = "HEMTT_C-RAM_Phalanx", side = 2, cratesRequired = 3 },
        { multiple = { 1003.05, 1003.05, 1003.05 }, desc = ctld.i18n_translate("LPWS C-RAM - All crates"),      side = 2 },

        --- RED
        { weight = 1003.11,                         desc = ctld.i18n_translate("9K33 Osa"),                     unit = "Osa 9A33 ln",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.11, 1003.11, 1003.11 }, desc = ctld.i18n_translate("9K33 Osa - All crates"),        side = 1 },
        { weight = 1003.12,                         desc = ctld.i18n_translate("9P31 Strela-1"),                unit = "Strela-1 9P31",       side = 1, cratesRequired = 3 },
        { multiple = { 1003.12, 1003.12, 1003.12 }, desc = ctld.i18n_translate("9P31 Strela-1 - All crates"),   side = 1 },
        { weight = 1003.13,                         desc = ctld.i18n_translate("9K35M Strela-10"),              unit = "Strela-10M3",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.13, 1003.13, 1003.13 }, desc = ctld.i18n_translate("9K35M Strela-10 - All crates"), side = 1 },
        { weight = 1003.14,                         desc = ctld.i18n_translate("9K331 Tor"),                    unit = "Tor 9A331",           side = 1, cratesRequired = 3 },
        { multiple = { 1003.14, 1003.14, 1003.14 }, desc = ctld.i18n_translate("9K331 Tor - All crates"),       side = 1 },
        { weight = 1003.15,                         desc = ctld.i18n_translate("2K22 Tunguska"),                unit = "2S6 Tunguska",        side = 1, cratesRequired = 3 },
        { multiple = { 1003.15, 1003.15, 1003.15 }, desc = ctld.i18n_translate("2K22 Tunguska - All crates"),   side = 1 },
    },
    ["SAM mid range"] = {
        --- BLUE
        -- HAWK System
        { weight = 1004.01,                         desc = ctld.i18n_translate("HAWK Launcher"),             unit = "Hawk ln",              side = 2 },
        { weight = 1004.02,                         desc = ctld.i18n_translate("HAWK Search Radar"),         unit = "Hawk sr",              side = 2 },
        { weight = 1004.03,                         desc = ctld.i18n_translate("HAWK Track Radar"),          unit = "Hawk tr",              side = 2 },
        { weight = 1004.04,                         desc = ctld.i18n_translate("HAWK PCP"),                  unit = "Hawk pcp",             side = 2 },
        { weight = 1004.05,                         desc = ctld.i18n_translate("HAWK CWAR"),                 unit = "Hawk cwar",            side = 2 },
        { weight = 1004.06,                         desc = ctld.i18n_translate("HAWK Repair"),               unit = "HAWK Repair",          side = 2 },
        { multiple = { 1004.01, 1004.02, 1004.03 }, desc = ctld.i18n_translate("HAWK - All crates"),         side = 2 },
        -- End of HAWK

        -- NASAMS Sysyem
        { weight = 1004.11,                         desc = ctld.i18n_translate("NASAMS Launcher 120C"),      unit = "NASAMS_LN_C",          side = 2 },
        { weight = 1004.12,                         desc = ctld.i18n_translate("NASAMS Search/Track Radar"), unit = "NASAMS_Radar_MPQ64F1", side = 2 },
        { weight = 1004.13,                         desc = ctld.i18n_translate("NASAMS Command Post"),       unit = "NASAMS_Command_Post",  side = 2 },
        { weight = 1004.14,                         desc = ctld.i18n_translate("NASAMS Repair"),             unit = "NASAMS Repair",        side = 2 },
        { multiple = { 1004.11, 1004.12, 1004.13 }, desc = ctld.i18n_translate("NASAMS - All crates"),       side = 2 },
        -- End of NASAMS

        --- RED
        -- KUB SYSTEM
        { weight = 1004.21,                         desc = ctld.i18n_translate("KUB Launcher"),              unit = "Kub 2P25 ln",          side = 1 },
        { weight = 1004.22,                         desc = ctld.i18n_translate("KUB Radar"),                 unit = "Kub 1S91 str",         side = 1 },
        { weight = 1004.23,                         desc = ctld.i18n_translate("KUB Repair"),                unit = "KUB Repair",           side = 1 },
        { multiple = { 1004.21, 1004.22 },          desc = ctld.i18n_translate("KUB - All crates"),          side = 1 },
        -- End of KUB

        -- BUK System
        { weight = 1004.31,                         desc = ctld.i18n_translate("BUK Launcher"),              unit = "SA-11 Buk LN 9A310M1", side = 1 },
        { weight = 1004.32,                         desc = ctld.i18n_translate("BUK Search Radar"),          unit = "SA-11 Buk SR 9S18M1",  side = 1 },
        { weight = 1004.33,                         desc = ctld.i18n_translate("BUK CC Radar"),              unit = "SA-11 Buk CC 9S470M1", side = 1 },
        { weight = 1004.34,                         desc = ctld.i18n_translate("BUK Repair"),                unit = "BUK Repair",           side = 1 },
        { multiple = { 1004.31, 1004.32, 1004.33 }, desc = ctld.i18n_translate("BUK - All crates"),          side = 1 },
        -- END of BUK
    },
    ["SAM long range"] = {
        --- BLUE
        -- Patriot System
        { weight = 1005.01,                                           desc = ctld.i18n_translate("Patriot Launcher"),            unit = "Patriot ln",        side = 2 },
        { weight = 1005.02,                                           desc = ctld.i18n_translate("Patriot Radar"),               unit = "Patriot str",       side = 2 },
        { weight = 1005.03,                                           desc = ctld.i18n_translate("Patriot ECS"),                 unit = "Patriot ECS",       side = 2 },
        -- { weight = 1005.04, desc = ctld.i18n_translate("Patriot ICC"), unit = "Patriot cp", side = 2 },
        -- { weight = 1005.05, desc = ctld.i18n_translate("Patriot EPP"), unit = "Patriot EPP", side = 2 },
        { weight = 1005.06,                                           desc = ctld.i18n_translate("Patriot AMG (optional)"),      unit = "Patriot AMG",       side = 2 },
        { weight = 1005.07,                                           desc = ctld.i18n_translate("Patriot Repair"),              unit = "Patriot Repair",    side = 2 },
        { multiple = { 1005.01, 1005.02, 1005.03 },                   desc = ctld.i18n_translate("Patriot - All crates"),        side = 2 },
        -- End of Patriot

        -- S-300 SYSTEM
        { weight = 1005.11,                                           desc = ctld.i18n_translate("S-300 Grumble TEL C"),         unit = "S-300PS 5P85C ln",  side = 1 },
        { weight = 1005.12,                                           desc = ctld.i18n_translate("S-300 Grumble Flap Lid-A TR"), unit = "S-300PS 40B6M tr",  side = 1 },
        { weight = 1005.13,                                           desc = ctld.i18n_translate("S-300 Grumble Clam Shell SR"), unit = "S-300PS 40B6MD sr", side = 1 },
        { weight = 1005.14,                                           desc = ctld.i18n_translate("S-300 Grumble Big Bird SR"),   unit = "S-300PS 64H6E sr",  side = 1 },
        { weight = 1005.15,                                           desc = ctld.i18n_translate("S-300 Grumble C2"),            unit = "S-300PS 54K6 cp",   side = 1 },
        { weight = 1005.16,                                           desc = ctld.i18n_translate("S-300 Repair"),                unit = "S-300 Repair",      side = 1 },
        { multiple = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = ctld.i18n_translate("Patriot - All crates"),        side = 1 },
        -- End of S-300
    },
    ["Drone"] = {
        --- BLUE MQ-9 Repear
        { weight = 1006.01, desc = ctld.i18n_translate("MQ-9 Repear - JTAC"),    unit = "MQ-9 Reaper",    side = 2 },
        -- End of BLUE MQ-9 Repear

        --- RED MQ-1A Predator
        { weight = 1006.11, desc = ctld.i18n_translate("MQ-1A Predator - JTAC"), unit = "RQ-1A Predator", side = 1 },
        -- End of RED MQ-1A Predator
    },
    --["FARP Alpha"] = {{ weight = 1007.01, desc = ctld.i18n_translate("FARP Alpha"), unit = "FARP Alpha", cratesRequired = 1 }, },
    --- Single Farp
    --["mineField"] = {{ weight = 1007.02, desc = ctld.i18n_translate("mineField"), unit = "mineField", cratesRequired = 1 },},
}

ctld.spawnableCratesModels = {
    ["load"] = {
        ["category"] = "Cargos", --"Fortifications"
        ["type"] = "ammo_cargo", --"uh1h_cargo"    --"Cargo04"
        ["canCargo"] = false,
    },
    ["sling"] = {
        ["category"] = "Cargos",
        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",
        ["canCargo"] = true
    },
    ["dynamic"] = {
        ["category"] = "Cargos",
        ["type"] = "ammo_cargo",
        ["canCargo"] = true
    }
}


--[[ Placeholder for different type of cargo containers. Let's say pipes and trunks, fuel for FOB building
        ["shape_name"] = "ab-212_cargo",
        ["type"] = "uh1h_cargo" --new type for the container previously used

        ["shape_name"] = "ammo_box_cargo",
        ["type"] = "ammo_cargo",

        ["shape_name"] = "barrels_cargo",
        ["type"] = "barrels_cargo",

        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",

        ["shape_name"] = "f_bar_cargo",
        ["type"] = "f_bar_cargo",

        ["shape_name"] = "fueltank_cargo",
        ["type"] = "fueltank_cargo",

        ["shape_name"] = "iso_container_cargo",
        ["type"] = "iso_container",

        ["shape_name"] = "iso_container_small_cargo",
        ["type"] = "iso_container_small",

        ["shape_name"] = "oiltank_cargo",
        ["type"] = "oiltank_cargo",

        ["shape_name"] = "pipes_big_cargo",
        ["type"] = "pipes_big_cargo",

        ["shape_name"] = "pipes_small_cargo",
        ["type"] = "pipes_small_cargo",

        ["shape_name"] = "tetrapod_cargo",
        ["type"] = "tetrapod_cargo",

        ["shape_name"] = "trunks_long_cargo",
        ["type"] = "trunks_long_cargo",

        ["shape_name"] = "trunks_small_cargo",
        ["type"] = "trunks_small_cargo",
]] --

-- if the unit is on this list, it will be made into a JTAC when deployed
ctld.jtacUnitTypes     = {
    "SKP", "Hummer",          -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
    "MQ", "RQ"                --"MQ-9 Repear", "RQ-1A Predator"}
}
ctld.jtacDroneRadius   = 1000 -- JTAC offset radius in meters for orbiting drones
ctld.jtacDroneAltitude = 7000 -- JTAC altitude in meters for orbiting drones
-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************

-----------------------------------------------------------------
-- Spawn group at a trigger and set them as extractable. Usage:
-- ctld.spawnGroupAtTrigger("groupside", number, "triggerName", radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group description
-- "triggerName" = trigger name in mission editor between commas
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtTrigger("red", 2, "spawn1", 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtTrigger("blue", {mg=1,at=2,aa=3,inf=4,mortar=5},"spawn2", 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
--
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    local _spawnTrigger = trigger.misc.getZone(_triggerName) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find trigger called %1", _triggerName), 10)
        return
    end

    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_pos3, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-----------------------------------------------------------------
-- Spawn group at a Vec3 Point and set them as extractable. Usage:
-- ctld.spawnGroupAtPoint("groupside", number,Vec3 Point, radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group Description
-- Vec3 Point = A vec3 point like {x=1,y=2,z=3}. Can be obtained from a unit like so: Unit.getName("Unit1"):getPoint()
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtPoint("red", 2, {x=1,y=2,z=3}, 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtPoint("blue", {mg=1,at=2,aa=3,inf=4,mortar=5}, {x=1,y=2,z=3}, 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
function ctld.spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)
    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_point, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-- Preloads a transport with troops or vehicles
-- replaces any troops currently on board
function ctld.preLoadTransport(_unitName, _number, _troops)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        -- will replace any units currently on board
        --                if not ctld.troopsOnboard(_unit,_troops)    then
        ctld.loadTroops(_unit, _troops, _number)
        --                end
    end
end

-- Continuously counts the number of crates in a zone and sets the value of the passed in flag
-- to the count amount
-- This means you can trigger actions based on the count and also trigger messages before the count is reached
-- Just pass in the zone name and flag number like so as a single (NOT Continuous) Trigger
-- This will now work for Mission Editor and Spawned Crates
-- e.g. ctld.cratesInZone("DropZone1", 5)
function ctld.cratesInZone(_zone, _flagNumber)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.cratesInZone()", _zone)

    --ignore side, if crate has been used its discounted from the count
    local _crateTables = { ctld.spawnedCratesRED, ctld.spawnedCratesBLUE, ctld.missionEditorCargoCrates }

    local _crateCount = 0

    for _, _crates in pairs(_crateTables) do
        for _crateName, _dontUse in pairs(_crates) do
            --get crate
            local _crate = ctld.getCrateObject(_crateName)

            --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
            if _crate ~= nil and _crate:getLife() > 0
                and (ctld.inAir(_crate) == false) then
                local _dist = ctld.getDistance(_crate:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    _crateCount = _crateCount + 1
                end
            end
        end
    end

    --set flag stuff
    trigger.action.setUserFlag(_flagNumber, _crateCount)

    -- env.info("FLAG ".._flagNumber.." crates ".._crateCount)

    --retrigger in 5 seconds
    timer.scheduleFunction(function(_args)
        ctld.cratesInZone(_args[1], _args[2])
    end, { _zone, _flagNumber }, timer.getTime() + 5)
end

-- Creates an extraction zone
-- any Soldiers (not vehicles) dropped at this zone by a helicopter will disappear
-- and be added to a running total of soldiers for a set flag number
-- The idea is you can then drop say 20 troops in a zone and trigger an action using the mission editor triggers
-- and the flag value
--
-- The ctld.createExtractZone function needs to be called once in a trigger action do script.
-- if you dont want smoke, pass -1 to the function.
--Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4, NO SMOKE = -1
--
-- e.g. ctld.createExtractZone("extractzone1", 2, -1) will create an extraction zone at trigger zone "extractzone1", store the number of troops dropped at
-- the zone in flag 2 and not have smoke
--
--
--
function ctld.createExtractZone(_zone, _flagNumber, _smoke)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    trigger.action.setUserFlag(_flagNumber, 0) --start at 0

    local _details = { point = _pos3, name = _zone, smoke = _smoke, flag = _flagNumber, radius = _triggerZone.radius }

    ctld.extractZones[_zone .. "-" .. _flagNumber] = _details

    if _smoke ~= nil and _smoke > -1 then
        local _smokeFunction

        _smokeFunction = function(_args)
            local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]
            -- check zone is still active
            if _extractDetails == nil then
                -- stop refreshing smoke, zone is done
                return
            end


            trigger.action.smoke(_args.point, _args.smoke)
            --refresh in 5 minutes
            timer.scheduleFunction(_smokeFunction, _args, timer.getTime() + 300)
        end

        --run local function
        _smokeFunction(_details)
    end
end

-- Removes an extraction zone
--
-- The smoke will take up to 5 minutes to disappear depending on the last time the smoke was activated
--
-- The ctld.removeExtractZone function needs to be called once in a trigger action do script.
--
-- e.g. ctld.removeExtractZone("extractzone1", 2) will remove an extraction zone at trigger zone "extractzone1"
-- that was setup with flag 2
--
--
--
function ctld.removeExtractZone(_zone, _flagNumber)
    local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]

    if _extractDetails ~= nil then
        --remove zone
        ctld.extractZones[_zone .. "-" .. _flagNumber] = nil
    end
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- GROUPS in a zone and store the values in two flags
-- A group is only counted as being in a zone when the leader of that group
-- is in the zone
-- Use: ctld.countDroppedGroupsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedGroupsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedGroupsInZone()", _zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }
    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedGroupsInZone()", _zone)
                local _dist = ctld.getDistance(_groupUnits[1]:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    if (_groupUnits[1]:getCoalition() == 1) then
                        _redCount = _redCount + 1;
                    else
                        _blueCount = _blueCount + 1;
                    end
                end
            end
        end
    end
    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Groups in zone ".._blueCount.." ".._redCount)
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- UNITS in a zone and store the values in two flags

-- Use: ctld.countDroppedUnitsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedUnitsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedUnitsInZone()", _zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }

    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedUnitsInZone()", _zone)
                for _, _unit in pairs(_groupUnits) do
                    local _dist = ctld.getDistance(_unit:getPoint(), _zonePos)

                    if _dist <= _triggerZone.radius then
                        if (_unit:getCoalition() == 1) then
                            _redCount = _redCount + 1;
                        else
                            _blueCount = _blueCount + 1;
                        end
                    end
                end
            end
        end
    end


    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Units in zone ".._blueCount.." ".._redCount)
end

--***************************************************************
function ctld.getNextDynamicLogisticUnitIndex()
    ctld.dynamicLogisticUnitsIndex = ctld.dynamicLogisticUnitsIndex + 1
    return ctld.dynamicLogisticUnitsIndex
end

-- Creates a radio beacon on a random UHF - VHF and HF/FM frequency for homing
-- This WILL NOT WORK if you dont add beacon.ogg and beaconsilent.ogg to the mission!!!
-- e.g. ctld.createRadioBeaconAtZone("beaconZone","red", 1440,"Waypoint 1") will create a beacon at trigger zone "beaconZone" for the Red side
-- that will last 1440 minutes (24 hours ) and named "Waypoint 1" in the list of radio beacons
--
-- e.g. ctld.createRadioBeaconAtZone("beaconZoneBlue","blue", 20) will create a beacon at trigger zone "beaconZoneBlue" for the Blue side
-- that will last 20 minutes
function ctld.createRadioBeaconAtZone(_zone, _coalition, _batteryLife, _name)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.createRadioBeaconAtZone()", _zone)

    ctld.beaconCount = ctld.beaconCount + 1

    if _name == nil or _name == "" then
        _name = "Beacon #" .. ctld.beaconCount
    end

    if _coalition == "red" then
        ctld.createRadioBeacon(_zonePos, 1, 0, _name, _batteryLife) --1440
    else
        ctld.createRadioBeacon(_zonePos, 2, 2, _name, _batteryLife) --1440
    end
end

-- Activates a pickup zone
-- Activates a pickup zone when called from a trigger
-- EG: ctld.activatePickupZone("pickzone3")
-- This is enable pickzone3 to be used as a pickup zone for the team set
function ctld.activatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone or ship called %1", _zoneName), 10)
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[4] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[4] = 1                  --activate zone

            if ctld.disableAllSmoke == true then --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a pickup zone
-- Deactivates a pickup zone when called from a trigger
-- EG: ctld.deactivatePickupZone("pickzone3")
-- This is disables pickzone3 and can no longer be used to as a pickup zone
-- These functions can be called by triggers, like if a set of buildings is used, you can trigger the zone to be 'not operational'
-- once they are destroyed
function ctld.deactivatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            -- i'd just ignore it if its already been deactivated
            _zoneDetails[4] = 0 --deactivate zone
        end
    end
end

-- Change the remaining groups currently available for pickup at a zone
-- e.g. ctld.changeRemainingGroupsForPickupZone("pickup1", 5) -- adds 5 groups
-- ctld.changeRemainingGroupsForPickupZone("pickup1", -3) -- remove 3 groups
function ctld.changeRemainingGroupsForPickupZone(_zoneName, _amount)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            ctld.updateZoneCounter(_zoneName, _amount)
        end
    end
end

-- Activates a Waypoint zone
-- Activates a Waypoint zone when called from a trigger
-- EG: ctld.activateWaypointZone("pickzone3")
-- This means that troops dropped within the radius of the zone will head to the center
-- of the zone instead of searching for troops
function ctld.activateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position


    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)

        return
    end

    for _, _zoneDetails in pairs(ctld.wpZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[3] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[3] = 1                  --activate zone

            if ctld.disableAllSmoke == true then --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a Waypoint zone
-- Deactivates a Waypoint zone when called from a trigger
-- EG: ctld.deactivateWaypointZone("wpzone3")
-- This disables wpzone3 so that troops dropped in this zone will search for troops as normal
-- These functions can be called by triggers
function ctld.deactivateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            _zoneDetails[3] = 0 --deactivate zone
        end
    end
end

-- Continuous Trigger Function
-- Causes an AI unit with the specified name to unload troops / vehicles when
-- an enemy is detected within a specified distance
-- The enemy must have Line or Sight to the unit to be detected
function ctld.unloadInProximityToEnemy(_unitName, _distance)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil and _unit:getPlayerName() == nil then
        -- no player name means AI!
        -- the findNearest visible enemy you'd want to modify as it'll find enemies quite far away
        -- limited by    ctld.JTAC_maxDistance
        local _nearestEnemy = ctld.findNearestVisibleEnemy(_unit, "all", _distance)

        if _nearestEnemy ~= nil then
            if ctld.troopsOnboard(_unit, true) then
                ctld.deployTroops(_unit, true)
                return true
            end

            if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
                ctld.deployTroops(_unit, false)
                return true
            end
        end
    end

    return false
end

-- Unit will unload any units onboard if the unit is on the ground
-- when this function is called
function ctld.unloadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        if ctld.troopsOnboard(_unit, true) then
            ctld.unloadTroops({ _unitName, true })
        end

        if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
            ctld.unloadTroops({ _unitName, false })
        end
    end
end

-- Loads Troops and Vehicles from a zone or picks up nearby troops or vehicles
function ctld.loadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        ctld.loadTroopsFromZone({ _unitName, true, "", true })

        if ctld.unitCanCarryVehicles(_unit) then
            ctld.loadTroopsFromZone({ _unitName, false, "", true })
        end
    end
end

-- adds a callback that will be called for many actions ingame
function ctld.addCallback(_callback)
    table.insert(ctld.callbacks, _callback)
end

-- Spawns a sling loadable crate at a Trigger Zone
--
-- Weights can be found in the ctld.spawnableCrates list
-- e.g. ctld.spawnCrateAtZone("red", 500,"triggerzone1") -- spawn a humvee at triggerzone 1 for red side
-- e.g. ctld.spawnCrateAtZone("blue", 505,"triggerzone1") -- spawn a tow humvee at triggerzone1 for blue side
--
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    local _spawnTrigger = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _point = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side)
end

-- Spawns a sling loadable crate at a Point
--
-- Weights can be found in the ctld.spawnableCrates list
-- Points can be made by hand or obtained from a Unit position by Unit.getByName("PilotName"):getPoint()
-- e.g. ctld.spawnCrateAtPoint("red", 500,{x=1,y=2,z=3}) -- spawn a humvee at triggerzone 1 for red side at a specified point
-- e.g. ctld.spawnCrateAtPoint("blue", 505,{x=1,y=2,z=3}) -- spawn a tow humvee at triggerzone1 for blue side at a specified point
--
--
function ctld.spawnCrateAtPoint(_side, _weight, _point, _hdg)
    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side, _hdg)
end

-- ***************************************************************
function ctld.getSecureDistanceFromUnit(_unitName) -- return a distance between the center of unitName, to be sure not touch the unitName
    local rotorDiameter = 0                        --19    -- meters  -- õk for UH & CH47
    if Unit.getByName(_unitName) then
        local unitUserBox = Unit.getByName(_unitName):getDesc().box
        local SecureDistanceFromUnit = 0
        if math.abs(unitUserBox.max.x) >= math.abs(unitUserBox.min.x) then
            SecureDistanceFromUnit = math.abs(unitUserBox.max.x) + (rotorDiameter / 2)
        else
            SecureDistanceFromUnit = math.abs(unitUserBox.min.x) + (rotorDiameter / 2)
        end
        return SecureDistanceFromUnit
    end
    return nil
end

-- ***************************************************************
--               Repack vehicules crates functions
-- ***************************************************************
ctld.repackRequestsStack = {}                 -- table to store the repack request
ctld.inAirMemorisation   = {}                 -- last helico state of InAir()
function ctld.updateRepackMenuOnlanding(p, t) -- update helo repack menu when a helo landing is detected
    if t == nil then t = timer.getTime() + 1; end
    if ctld.transportPilotNames then
        for _, _unitName in pairs(ctld.transportPilotNames) do
            if Unit.getByName(_unitName) ~= nil and Unit.getByName(_unitName):isActive() == true then
                if ctld.inAirMemorisation[_unitName] == nil then ctld.inAirMemorisation[_unitName] = false end -- init InAir() state
                local _heli = Unit.getByName(_unitName)
                if ctld.inAir(_heli) == false then
                    if ctld.inAirMemorisation[_unitName] == true then -- if transition from inAir to Landed => updateRepackMenu
                        ctld.updateRepackMenu(_unitName)
                    end
                    ctld.inAirMemorisation[_unitName] = false
                else
                    ctld.inAirMemorisation[_unitName] = true
                end
            end
        end
    end
    return t + 5 -- reschdule each 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInRepackRadius(_PlayerTransportUnitName, _radius)
    if _radius == nil then
        _radius = ctld.maximumDistanceRepackableUnitsSearch
    end

    local unit = ctld.getTransportUnit(_PlayerTransportUnitName)
    if unit == nil then
        return
    end

    local unitsNamesList  = ctld.getNearbyUnits(unit:getPoint(), _radius, unit:getCoalition())

    local repackableUnits = {}
    for i = 1, #unitsNamesList do
        local unitObject     = Unit.getByName(unitsNamesList[i])
        local repackableUnit = ctld.isRepackableUnit(unitsNamesList[i])
        if repackableUnit then
            repackableUnit["repackableUnitGroupID"] = unitObject:getGroup():getID()
            table.insert(repackableUnits, ctld.utils.deepCopy("ctld.getUnitsInRepackRadius()", repackableUnit))
        end
    end
    return repackableUnits
end

-- ***************************************************************
function ctld.getNearbyUnits(_point, _radius, _coalition)
    if _coalition == nil then
        _coalition = 4 -- all coalitions
    end
    local unitsByDistance = {}
    local cpt = 1
    local _units = {}
    for _unitName, _ in pairs(CTLD_extAPI.DBs.unitsByName) do
        local u = Unit.getByName(_unitName)
        local e = (u and u:isExist()) or false
        -- pcall is needed because getCoalition() fails if the unit is an object without coalition (like a smoke effect)
        local c = nil
        pcall(function() c = (u and e and u:getCoalition()) or nil end)
        if u and e and (_coalition == 4 or c == _coalition) then
            local _dist = ctld.utils.get2DDist("ctld.getNearbyUnits()", u:getPoint(), _point)
            if _dist <= _radius then
                unitsByDistance[cpt] = { id = cpt, dist = _dist, unit = _unitName, typeName = u:getTypeName() }
                cpt = cpt + 1
            end
        end
    end

    --table.sort(unitsByDistance, function(a,b) return a.dist < b.dist end)       -- sort the table by distance (the nearest first)
    table.sort(unitsByDistance, function(a, b) return a.typeName < b.typeName end) -- sort the table by typeNAme
    for i, v in ipairs(unitsByDistance) do
        table.insert(_units, v.unit)                                               -- insert nearby unitName
    end
    return _units
end

-- ***************************************************************
function ctld.isRepackableUnit(_unitName)
    local unitObject = Unit.getByName(_unitName)
    local unitType   = unitObject:getTypeName()
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _unitName then
                if ctld.spawnableCrates[k][i].unit == unitType then
                    local repackableUnit = ctld.utils.deepCopy("ctld.isRepackableUnit", ctld.spawnableCrates[k]
                        [i])
                    repackableUnit["repackableUnitName"] = _unitName
                    return repackableUnit
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.getCrateDesc(_crateWeight)
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _crateWeight then
                if ctld.spawnableCrates[k][i].weight == _crateWeight then
                    return ctld.spawnableCrates[k][i]
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.repackVehicleRequest(_params) -- update rrs table 'repackRequestsStack' with the request
    --ctld.logTrace("FG_    ctld.repackVehicleRequest._params = " .. ctld.p(_params))
    ctld.repackRequestsStack[#ctld.repackRequestsStack + 1] = _params
end

-- ***************************************************************
function ctld.repackVehicle(_params, t) -- scan rrs table 'repackRequestsStack' to process each request
    --ctld.logTrace("FG_ XXXXXXXXXXXXXXXXXXXXXXXXXXX ctld.repackVehicle.ctld.repackRequestsStack XXXXXXXXXXXXXXXXXXXXXXXXXXX")
    if t == nil then
        t = timer.getTime()
    end
    if #ctld.repackRequestsStack ~= 0 then
        ctld.logTrace("FG_    ctld.repackVehicle.ctld.repackRequestsStack = %s", ctld.p(ctld.repackRequestsStack))
    end
    for ii, v in ipairs(ctld.repackRequestsStack) do
        ctld.logTrace("FG_    ctld.repackVehicle.v[%s] = %s", ii, ctld.p(v))
        local repackableUnitName = v.repackableUnitName
        local repackableUnit     = Unit.getByName(repackableUnitName)
        local crateWeight        = v.weight
        local playerUnitName     = v.playerUnitName
        if repackableUnit then
            if repackableUnit:isExist() then
                local PlayerTransportUnit = Unit.getByName(playerUnitName)
                local playerCoa           = PlayerTransportUnit:getCoalition()
                local refCountry          = PlayerTransportUnit:getCountry()
                -- calculate the heading of the spawns to be carried out
                local playerHeading       = ctld.utils.getHeadingInRadians("ctld.repackVehicle()", PlayerTransportUnit)
                local playerPoint         = PlayerTransportUnit:getPoint()
                local offset              = 5
                local randomHeading       = ctld.RandomReal(playerHeading - math.pi / 4, playerHeading + math.pi / 4)
                if ctld.unitDynamicCargoCapable(PlayerTransportUnit) ~= false then
                    randomHeading = ctld.RandomReal(playerHeading + math.pi - math.pi / 4,
                        playerHeading + math.pi + math.pi / 4)
                end
                repackableUnit:destroy() -- destroy repacked unit
                for i = 1, v.cratesRequired or 1 do
                    -- see to spawn the crate at random position heading the transport unit
                    local _unitId        = ctld.getNextUnitId()
                    local _name          = string.format("%s_%i", v.desc, _unitId)
                    local secureDistance = ctld.getSecureDistanceFromUnit(playerUnitName) or 10
                    local relativePoint  = ctld.getRelativePoint(playerPoint, secureDistance + (i * offset),
                        randomHeading) -- 7 meters from the transport unit

                    if ctld.unitDynamicCargoCapable(PlayerTransportUnit) == false then
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa,
                            playerHeading, nil)
                    else
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa,
                            playerHeading, "dynamic")
                    end
                end
            end
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
        end
        ctld.repackRequestsStack[ii] = nil                                                                 -- remove the processed request from the stacking table
    end



    if ctld.enableRepackingVehicles == true then
        return t + 3 -- reschedule the function in 3 seconds
    else
        return nil   --stop scheduling
    end
end

-- ***************************************************************
function ctld.addStaticLogisticUnit(_point, _country) -- create a temporary logistic unit with a Windsock object
    local dynamicLogisticUnitName = "%dynLogisticName_" .. tostring(ctld.getNextDynamicLogisticUnitIndex())
    ctld.logisticUnits[#ctld.logisticUnits + 1] = dynamicLogisticUnitName
    local LogUnit = {
        ["category"] = "Fortifications",
        ["shape_name"] = "H-Windsock_RW",
        ["type"] = "Windsock",
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = dynamicLogisticUnitName,
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    LogUnit["country"] = _country
    CTLD_extAPI.dynAddStatic("ctld.addStaticLogisticUnit", LogUnit)
    return StaticObject.getByName(LogUnit["name"])
end

-- ***************************************************************
function ctld.updateDynamicLogisticUnitsZones() -- remove Dynamic Logistic Units if no statics units (crates) are in the zone
    local _units = {}
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if string.sub(logUnit, 1, 17) == "%dynLogisticName_" then -- check if the unit is a dynamic logistic unit
            local unitsInLogisticUnitZone = ctld.getUnitsInLogisticZone(logUnit)
            if #unitsInLogisticUnitZone == 0 then
                local _logUnit = StaticObject.getByName(logUnit)
                if _logUnit then
                    _logUnit:destroy()          -- destroy the    dynamic Logistic unit object from map
                    ctld.logisticUnits[i] = nil -- remove the dynamic Logistic unit from the list
                end
            end
        end
    end
    return 5 -- reschedule the function in 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInLogisticZone(_logisticUnitName, _coalition)
    local _unit = StaticObject.getByName(_logisticUnitName)
    if _unit then
        local _point = _unit:getPoint()
        local _unitList = ctld.getNearbyUnits(_point, ctld.maximumDistanceLogistic, _coalition)
        return _unitList
    end
    return {}
end

-- ***************************************************************
function ctld.isUnitInNamedLogisticZone(_unitName, _logisticUnitName) -- check if a unit is in the named logistic zone
    --ctld.logTrace("FG_    ctld.isUnitInNamedLogisticZone._logisticUnitName = %s", ctld.p(_logisticUnitName))
    local _unit = Unit.getByName(_unitName)
    if _unit == nil then
        return false
    end
    local unitPoint = _unit:getPoint()
    if StaticObject.getByName(_logisticUnitName) then
        local logisticUnitPoint = StaticObject.getByName(_logisticUnitName):getPoint()
        local _dist = ctld.getDistance(unitPoint, logisticUnitPoint)
        if _dist <= ctld.maximumDistanceLogistic then
            return true
        end
    end
    return false
end

-- ***************************************************************
function ctld.isUnitInALogisticZone(_unitName) -- check if a unit is in a logistic zone if true then return the logisticUnitName of the zone
    --ctld.logTrace("FG_    ctld.isUnitInALogisticZone._unitName = %s", ctld.p(_unitName))
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if ctld.isUnitInNamedLogisticZone(_unitName, logUnit) then
            return logUnit
        end
    end
    return nil
end

-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

--- Tells CTLD What multipart AA Systems there are and what parts they need
-- A New system added here also needs the launcher added
-- The number of times that each part is spawned for each system is specified by the entry "amount", NOTE : they will be spawned in a circle with the corresponding headings, NOTE 2 : launchers will use the default ctld.aaLauncher amount if nothing is specified
-- If a component does not require a crate, it can be specified via the entry "NoCrate" set to true
ctld.AASystemTemplate = {

    {
        name = "HAWK AA System",
        count = 5,
        parts = {
            { name = "Hawk ln",   desc = "HAWK Launcher",     launcher = true },
            { name = "Hawk tr",   desc = "HAWK Track Radar",  amount = 2 },
            { name = "Hawk sr",   desc = "HAWK Search Radar", amount = 2 },
            { name = "Hawk pcp",  desc = "HAWK PCP",          NoCrate = true },
            { name = "Hawk cwar", desc = "HAWK CWAR",         amount = 2,     NoCrate = true },
        },
        repair = "HAWK Repair",
    },
    {
        name = "Patriot AA System",
        count = 4,
        parts = {
            { name = "Patriot ln",  desc = "Patriot Launcher",               launcher = true, amount = 8 },
            { name = "Patriot ECS", desc = "Patriot Control Unit" },
            { name = "Patriot str", desc = "Patriot Search and Track Radar", amount = 2 },
            --{name = "Patriot cp", desc = "Patriot ICC", NoCrate = true},
            --{name = "Patriot EPP", desc = "Patriot EPP", NoCrate = true},
            { name = "Patriot AMG", desc = "Patriot AMG DL relay",           NoCrate = true },
        },
        repair = "Patriot Repair",
    },
    {
        name = "NASAMS AA System",
        count = 3,
        parts = {
            { name = "NASAMS_LN_C",          desc = "NASAMS Launcher 120C",     launcher = true },
            { name = "NASAMS_Radar_MPQ64F1", desc = "NASAMS Search/Track Radar" },
            { name = "NASAMS_Command_Post",  desc = "NASAMS Command Post" },
        },
        repair = "NASAMS Repair",
    },
    {
        name = "BUK AA System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher",    launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1",  desc = "BUK Search Radar" },
        },
        repair = "BUK Repair",
    },
    {
        name = "KUB AA System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln",  desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "KUB Repair",
    },
    {
        name = "S-300 AA System",
        count = 6,
        parts = {
            { desc = "S-300 Grumble TEL C",         name = "S-300PS 5P85C ln", launcher = true, amount = 1 },
            { desc = "S-300 Grumble TEL D",         name = "S-300PS 5P85D ln", NoCrate = true,  amount = 2 },
            { desc = "S-300 Grumble Flap Lid-A TR", name = "S-300PS 40B6M tr" },
            { desc = "S-300 Grumble Clam Shell SR", name = "S-300PS 40B6MD sr" },
            { desc = "S-300 Grumble Big Bird SR",   name = "S-300PS 64H6E sr" },
            { desc = "S-300 Grumble C2",            name = "S-300PS 54K6 cp" },
        },
        repair = "S-300 Repair",
    },
}


ctld.crateWait = {}
ctld.crateMove = {}

---------------- INTERNAL FUNCTIONS ----------------
---
---
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- print an object for a debugging log
function ctld.p(o, level)
    local MAX_LEVEL = 20
    if level == nil then level = 0 end
    if level > MAX_LEVEL then
        ctld.logError("max depth reached in ctld.p : " .. tostring(MAX_LEVEL))
        return ""
    end
    local text = ""
    if (type(o) == "table") then
        text = "\n"
        for key, value in pairs(o) do
            for i = 0, level do
                text = text .. " "
            end
            text = text .. "." .. key .. "=" .. ctld.p(value, level + 1) .. "\n"
        end
    elseif (type(o) == "function") then
        text = "[function]"
    elseif (type(o) == "boolean") then
        if o == true then
            text = "[true]"
        else
            text = "[false]"
        end
    else
        if o == nil then
            text = "[nil]"
        else
            text = tostring(o)
        end
    end
    return text
end

function ctld.formatText(text, ...)
    if not text then
        return ""
    end
    if type(text) ~= 'string' then
        text = ctld.p(text)
    else
        local args = ...
        if args and args.n and args.n > 0 then
            local pArgs = {}
            for i = 1, args.n do
                pArgs[i] = ctld.p(args[i])
            end
            text = text:format(unpack(pArgs))
        end
    end
    local fName = nil
    local cLine = nil
    if debug and debug.getinfo then
        local dInfo = debug.getinfo(3)
        fName = dInfo.name
        cLine = dInfo.currentline
    end
    if fName and cLine then
        return fName .. '|' .. cLine .. ': ' .. text
    elseif cLine then
        return cLine .. ': ' .. text
    else
        return ' ' .. text
    end
end

function ctld.logError(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" E - " .. ctld.Id .. message)
end

function ctld.logWarning(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" W - " .. ctld.Id .. message)
end

function ctld.logInfo(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" I - " .. ctld.Id .. message)
end

function ctld.logDebug(message, ...)
    if message and ctld.Debug then
        message = ctld.formatText(message, arg)
        env.info(" D - " .. ctld.Id .. message)
    end
end

function ctld.logTrace(message, ...)
    if message and ctld.Trace then
        message = ctld.formatText(message, arg)
        env.info(" T - " .. ctld.Id .. message)
    end
end

ctld.nextUnitId = 1;
ctld.getNextUnitId = function()
    ctld.nextUnitId = ctld.nextUnitId + 1

    return ctld.nextUnitId
end

ctld.nextGroupId = 1;

ctld.getNextGroupId = function()
    ctld.nextGroupId = ctld.nextGroupId + 1

    return ctld.nextGroupId
end

function ctld.getTransportUnit(_unitName)
    if _unitName == nil then
        return nil
    end

    local transportUnitObject = Unit.getByName(_unitName)

    if transportUnitObject ~= nil and transportUnitObject:isActive() and transportUnitObject:getLife() > 0 then
        return transportUnitObject
    end
    return nil
end

function ctld.spawnCrateStatic(_country, _unitId, _point, _name, _weight, _side, _hdg, _model_type)
    local _crate
    local _spawnedCrate

    local hdg = _hdg or 0

    if ctld.staticBugWorkaround and ctld.slingLoad == false then
        local _groupId = ctld.getNextGroupId()
        local _groupName = "Crate Group #" .. _groupId

        local _group = {
            ["visible"] = false,
            -- ["groupId"] = _groupId,
            ["hidden"] = false,
            ["units"] = {},
            --                ["y"] = _positions[1].z,
            --                ["x"] = _positions[1].x,
            ["name"] = _groupName,
            ["task"] = {},
        }

        _group.units[1] = ctld.createUnit(_point.x, _point.z, hdg, { type = "UAZ-469", name = _name, unitId = _unitId })

        --switch to MIST
        _group.category = Group.Category.GROUND;
        _group.country = _country;

        local _spawnedGroup = Group.getByName(CTLD_extAPI.dynAdd("ctld.spawnCrateStatic", _group).name)

        -- Turn off AI
        trigger.action.setGroupAIOff(_spawnedGroup)

        _spawnedCrate = Unit.getByName(_name)
    else
        if _model_type ~= nil then
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels[_model_type])
        elseif ctld.slingLoad then
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels["sling"])
        else
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels["load"])
        end

        _crate["y"] = _point.z
        _crate["x"] = _point.x
        _crate["mass"] = _weight
        _crate["name"] = _name
        _crate["heading"] = hdg
        _crate["country"] = _country

        CTLD_extAPI.dynAddStatic("ctld.spawnCrateStatic()", _crate)

        _spawnedCrate = StaticObject.getByName(_crate["name"])
    end


    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _side == 1 then
        ctld.spawnedCratesRED[_name] = _crateType
    else
        ctld.spawnedCratesBLUE[_name] = _crateType
    end

    return _spawnedCrate
end

function ctld.spawnFOBCrateStatic(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["shape_name"] = "konteiner_red1",
        ["type"] = "Container red 1",
        --     ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country

    CTLD_extAPI.dynAddStatic("ctld.spawnFOBCrateStatic", _crate)

    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end

function ctld.spawnFOB(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["type"] = "outpost",
        --    ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country
    CTLD_extAPI.dynAddStatic("ctld.spawnFOB", _crate)
    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    local _id = ctld.getNextUnitId()
    local _tower = {
        ["type"] = "house2arm",
        --     ["unitId"] = _id,
        ["rate"] = 100,
        ["y"] = _point.z + -36.57142857,
        ["x"] = _point.x + 14.85714286,
        ["name"] = "FOB Watchtower #" .. _id,
        ["category"] = "Fortifications",
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    --coalition.addStaticObject(_country, _tower)
    _tower["country"] = _country

    CTLD_extAPI.dynAddStatic("ctld.spawnFOB", _tower)

    return _spawnedCrate
end

function ctld.spawnCrate(_arguments, bypassCrateWaitTime)
    local _status, _err = pcall(function(_args)
        -- use the cargo weight to guess the type of unit as no way to add description :(
        local _crateType = ctld.crateLookupTable[tostring(_args[2])]
        local _heli = ctld.getTransportUnit(_args[1])
        if not _heli then
            return
        end

        -- check crate spam
        if not (bypassCrateWaitTime) and _heli:getPlayerName() ~= nil and ctld.crateWait[_heli:getPlayerName()] and ctld.crateWait[_heli:getPlayerName()] > timer.getTime() then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("Sorry you must wait %1 seconds before you can get another crate",
                    (ctld.crateWait[_heli:getPlayerName()] - timer.getTime())), 20)
            return
        end

        if _crateType and _crateType.multiple then
            for _, weight in pairs(_crateType.multiple) do
                local _aCrateType = ctld.crateLookupTable[tostring(weight)]
                if _aCrateType then
                    ctld.spawnCrate({ _args[1], _aCrateType.weight }, true)
                end
            end
            return
        end

        if _crateType ~= nil and _heli ~= nil and ctld.inAir(_heli) == false then
            if ctld.inLogisticsZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You are not close enough to friendly logistics to get a crate!"), 10)
                return
            end

            if ctld.isJTACUnitType(_crateType.unit) then
                local _limitHit = false

                if _heli:getCoalition() == 1 then
                    if ctld.JTAC_LIMIT_RED == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_RED = ctld.JTAC_LIMIT_RED - 1
                    end
                else
                    if ctld.JTAC_LIMIT_BLUE == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_BLUE = ctld.JTAC_LIMIT_BLUE - 1
                    end
                end

                if _limitHit then
                    ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No more JTAC Crates Left!"), 10)
                    return
                end
            end

            if _heli:getPlayerName() ~= nil then
                ctld.crateWait[_heli:getPlayerName()] = timer.getTime() + ctld.crateWaitTime
            end

            local _heli = ctld.getTransportUnit(_args[1])

            local _model_type = nil

            local _point = ctld.getPointAt12Oclock(_heli, 15)
            local _position = "12"

            if ctld.unitDynamicCargoCapable(_heli) then
                _model_type = "dynamic"
                _point = ctld.getPointAt6Oclock(_heli, 15)
                _position = "6"
            end

            local _unitId = ctld.getNextUnitId()

            local _side = _heli:getCoalition()

            local _name = string.format("%s #%i", _crateType.desc, _unitId)

            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crateType.weight, _side, 0, _model_type)

            -- add to move table
            ctld.crateMove[_name] = _name

            local refPoint = _heli:getPoint()
            local refLat, refLon = coord.LOtoLL(refPoint)
            local unitPos = _heli:getPosition()
            local refHeading = math.deg(math.atan2(unitPos.x.z, unitPos.x.x))

            local destLat, destLon, destAlt = coord.LOtoLL(_point)

            local relativePos, forma = ctld.tools.getRelativeBearing(refLat, refLon, refHeading, destLat, destLon,
                'clock')

            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock ",
                    _crateType.desc, _crateType.weight, relativePos), 20)
        else
            env.info("Couldn't find crate item to spawn")
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

--***************************************************************
ctld.randomCrateSpacing = 15 -- meters
function ctld.getPointAt12Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, 0)
end

function ctld.getPointAt6Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, math.pi)
end

function ctld.getPointInFrontSector(_unit, _offset)
    if _unit then
        local playerHeading = ctld.utils.getHeadingInRadians("ctld.getPointInFrontSector", _unit)
        local randomHeading = ctld.RandomReal(playerHeading - math.pi / 4, playerHeading + math.pi / 4)
        if _offset == nil then
            _offset = 20
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function ctld.getPointInRearSector(_unit, _offset)
    if _unit then
        local playerHeading = ctld.utils.getHeadingInRadians("ctld.getPointInRearSector", _unit)
        local randomHeading = ctld.RandomReal(playerHeading + math.pi - math.pi / 4, playerHeading + math.pi + math.pi /
            4)
        if _offset == nil then
            _offset = 30
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function ctld.getPointAtDirection(_unit, _offset, _directionInRadian)
    if _offset == nil then
        _offset = ctld.getSecureDistanceFromUnit(_unit:getName())
    end
    --ctld.logTrace("_offset = %s", ctld.p(_offset))
    local _randomOffsetX = math.random(0, ctld.randomCrateSpacing * 2) - ctld.randomCrateSpacing
    local _randomOffsetZ = math.random(0, ctld.randomCrateSpacing)
    --ctld.logTrace("_randomOffsetX = %s", ctld.p(_randomOffsetX))
    --ctld.logTrace("_randomOffsetZ = %s", ctld.p(_randomOffsetZ))
    local _position      = _unit:getPosition()
    local _angle         = math.atan(_position.x.z, _position.x.x) + _directionInRadian
    local _xOffset       = math.cos(_angle) * (_offset + _randomOffsetX)
    local _zOffset       = math.sin(_angle) * (_offset + _randomOffsetZ)
    local _point         = _unit:getPoint()
    return { x = _point.x + _xOffset, z = _point.z + _zOffset, y = _point.y }
end

function ctld.getRelativePoint(_refPointXZTable, _distance, _angle_radians) -- return coord point at distance and angle from _refPointXZTable
    local relativePoint = {}
    relativePoint.x = _refPointXZTable.x + _distance * math.cos(_angle_radians)
    if _refPointXZTable.z == nil then
        relativePoint.y = _refPointXZTable.y + _distance * math.sin(_angle_radians)
    else
        relativePoint.z = _refPointXZTable.z + _distance * math.sin(_angle_radians)
    end
    return relativePoint
end

function ctld.troopsOnboard(_heli, _troops)
    if ctld.inTransitTroops[_heli:getName()] ~= nil then
        local _onboard = ctld.inTransitTroops[_heli:getName()]

        if _troops then
            if _onboard.troops ~= nil and _onboard.troops.units ~= nil and #_onboard.troops.units > 0 then
                return true
            else
                return false
            end
        else
            if _onboard.vehicles ~= nil and _onboard.vehicles.units ~= nil and #_onboard.vehicles.units > 0 then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

-- if its dropped by AI then there is no player name so return the type of unit
function ctld.getPlayerNameOrType(_heli)
    if _heli:getPlayerName() == nil then
        return _heli:getTypeName()
    else
        return _heli:getPlayerName()
    end
end

function ctld.inExtractZone(_heli)
    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.extractZones) do
        --get distance to center
        local _dist = ctld.getDistance(_heliPoint, _zoneDetails.point)

        if _dist <= _zoneDetails.radius then
            return _zoneDetails
        end
    end

    return false
end

-- safe to fast rope if speed is less than 0.5 Meters per second
function ctld.safeToFastRope(_heli)
    if ctld.enableFastRopeInsertion == false then
        return false
    end

    --landed or speed is less than 8 km/h and height is less than fast rope height
    if (ctld.inAir(_heli) == false or (ctld.heightDiff(_heli) <= ctld.fastRopeMaximumHeight + 3.0 and ctld.utils.vec3Mag("ctld.safeToFastRope()", _heli:getVelocity()) < 2.2)) then
        return true
    end
end

function ctld.metersToFeet(_meters)
    local _feet = _meters * 3.2808399

    return ctld.utils.round("ctld.metersToFeet", _feet)
end

function ctld.inAir(_heli)
    if _heli:inAir() == false then
        return false
    end

    -- less than 5 cm/s a second so landed
    -- BUT AI can hold a perfect hover so ignore AI
    if ctld.utils.vec3Mag("ctld.inAir)", _heli:getVelocity()) < 0.05 and _heli:getPlayerName() ~= nil then
        return false
    end
    return true
end

function ctld.deployTroops(_heli, _troops)
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    -- deloy troops
    if _troops then
        if _onboard.troops ~= nil and #_onboard.troops.units > 0 then
            if ctld.inAir(_heli) == false or ctld.safeToFastRope(_heli) then
                -- check we're not in extract zone
                local _extractZone = ctld.inExtractZone(_heli)

                if _extractZone == false then
                    local _droppedTroops = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.troops, false)
                    if _onboard.troops.jtac or _droppedTroops:getName():lower():find("jtac") then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)
                        ctld.JTACStart(_droppedTroops:getName(), _code)
                    end

                    if _heli:getCoalition() == 1 then
                        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
                    else
                        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
                    end

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into combat",
                                ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into combat", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName()), 10)
                    end

                    ctld.processCallback({ unit = _heli, unloaded = _droppedTroops, action = "dropped_troops" })
                else
                    --extract zone!
                    local _droppedCount = trigger.misc.getUserFlag(_extractZone.flag)

                    _droppedCount = (#_onboard.troops.units) + _droppedCount

                    trigger.action.setUserFlag(_extractZone.flag, _droppedCount)

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Too high or too fast to drop troops into combat! Hover below %1 feet or land.",
                        ctld.metersToFeet(ctld.fastRopeMaximumHeight)), 10)
            end
        end
    else
        if ctld.inAir(_heli) == false then
            if _onboard.vehicles ~= nil and #_onboard.vehicles.units > 0 then
                local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.vehicles, true)

                if _heli:getCoalition() == 1 then
                    table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
                else
                    table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
                end

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
                ctld.adaptWeightToCargo(_heli:getName())

                ctld.processCallback({ unit = _heli, unloaded = _droppedVehicles, action = "dropped_vehicles" })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 dropped vehicles from %2 into combat", ctld.getPlayerNameOrType(_heli),
                        _heli:getTypeName()), 10)
            end
        end
    end
end

function ctld.insertIntoTroopsArray(_troopType, _count, _troopArray, _troopName)
    for _i = 1, _count do
        local _unitId = ctld.getNextUnitId()
        table.insert(_troopArray,
            {
                type = _troopType,
                unitId = _unitId,
                name = string.format("Dropped %s #%i", _troopName or _troopType,
                    _unitId)
            })
    end

    return _troopArray
end

function ctld.generateTroopTypes(_side, _countOrTemplate, _country)
    local _troops = {}
    local _weight = 0
    local _hasJTAC = false

    local function getSoldiersWeight(count, additionalWeight)
        local _weight = 0
        for i = 1, count do
            local _soldierWeight = math.random(90, 120) * ctld.SOLDIER_WEIGHT / 100
            _weight = _weight + _soldierWeight + ctld.KIT_WEIGHT + additionalWeight
        end
        return _weight
    end

    if type(_countOrTemplate) == "table" then
        if _countOrTemplate.aa then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier stinger", _countOrTemplate.aa, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("SA-18 Igla manpad", _countOrTemplate.aa, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.aa, ctld.MANPAD_WEIGHT)
        end

        if _countOrTemplate.inf then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.inf, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.inf, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.inf, ctld.RIFLE_WEIGHT)
        end

        if _countOrTemplate.mg then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M249", _countOrTemplate.mg, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Paratrooper AKS-74", _countOrTemplate.mg, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mg, ctld.MG_WEIGHT)
        end

        if _countOrTemplate.at then
            _troops = ctld.insertIntoTroopsArray("Paratrooper RPG-16", _countOrTemplate.at, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.at, ctld.RPG_WEIGHT)
        end

        if _countOrTemplate.mortar then
            _troops = ctld.insertIntoTroopsArray("2B11 mortar", _countOrTemplate.mortar, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mortar, ctld.MORTAR_WEIGHT)
        end

        if _countOrTemplate.jtac then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.jtac, _troops, "JTAC")
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.jtac, _troops, "JTAC")
            end
            _hasJTAC = true
            _weight = _weight + getSoldiersWeight(_countOrTemplate.jtac, ctld.JTAC_WEIGHT + ctld.RIFLE_WEIGHT)
        end
    else
        for _i = 1, _countOrTemplate do
            local _unitType = "Infantry AK"

            if _side == 2 then
                if _i <= 2 then
                    _unitType = "Soldier M249"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "Soldier stinger"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Soldier M4 GRG"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            else
                if _i <= 2 then
                    _unitType = "Paratrooper AKS-74"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "SA-18 Igla manpad"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Infantry AK"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            end

            local _unitId = ctld.getNextUnitId()

            _troops[_i] = { type = _unitType, unitId = _unitId, name = string.format("Dropped %s #%i", _unitType, _unitId) }
        end
    end

    local _groupId = ctld.getNextGroupId()
    local _groupName = "Dropped Group"
    if _hasJTAC then
        _groupName = "Dropped JTAC Group"
    end
    local _details = {
        units = _troops,
        groupId = _groupId,
        groupName = string.format("%s %i", _groupName, _groupId),
        side =
            _side,
        country = _country,
        weight = _weight,
        jtac = _hasJTAC
    }

    return _details
end

--Special F10 function for players for troops
function ctld.unloadExtractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return false
    end


    local _extract = nil
    if not ctld.inAir(_heli) then
        if _heli:getCoalition() == 1 then
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end
    end

    if _extract ~= nil and not ctld.troopsOnboard(_heli, true) then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), true })
    else
        return ctld.unloadTroops({ _heli:getName(), true, true })
    end
end

-- load troops onto vehicle
function ctld.loadTroops(_heli, _troops, _numberOrTemplate)
    -- load troops + vehicles if c130 or herc
    -- "M1045 HMMWV TOW"
    -- "M1043 HMMWV Armament"
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    --number doesnt apply to vehicles
    if _numberOrTemplate == nil or (type(_numberOrTemplate) ~= "table" and type(_numberOrTemplate) ~= "number") then
        _numberOrTemplate = ctld.getTransportLimit(_heli:getTypeName())
    end

    if _onboard == nil then
        _onboard = { troops = {}, vehicles = {} }
    end

    local _list
    if _heli:getCoalition() == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    if _troops then
        _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(), _numberOrTemplate, _heli:getCountry())
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded troops into %2", ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)

        ctld.processCallback({ unit = _heli, onboard = _onboard.troops, action = "load_troops" })
    else
        _onboard.vehicles = ctld.generateVehiclesForTransport(_heli:getCoalition(), _heli:getCountry())

        local _count = #_list

        ctld.processCallback({ unit = _heli, onboard = _onboard.vehicles, action = "load_vehicles" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded %2 vehicles into %3", ctld.getPlayerNameOrType(_heli), _count,
                _heli:getTypeName()), 10)
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())
end

function ctld.generateVehiclesForTransport(_side, _country)
    local _vehicles = {}
    local _list
    if _side == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end


    for _i, _type in ipairs(_list) do
        local _unitId = ctld.getNextUnitId()
        local _weight = ctld.vehiclesWeight[_type] or 2500
        _vehicles[_i] = {
            type = _type,
            unitId = _unitId,
            name = string.format("Dropped %s #%i", _type, _unitId),
            weight =
                _weight
        }
    end


    local _groupId = ctld.getNextGroupId()
    local _details = {
        units = _vehicles,
        groupId = _groupId,
        groupName = string.format("Dropped Group %i", _groupId),
        side =
            _side,
        country = _country
    }

    return _details
end

function ctld.loadUnloadFOBCrate(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    if ctld.inAir(_heli) == true then
        return
    end


    local _side = _heli:getCoalition()

    local _inZone = ctld.inLogisticsZone(_heli)
    local _crateOnboard = ctld.inTransitFOBCrates[_heli:getName()] ~= nil

    if _inZone == false and _crateOnboard == true then
        ctld.inTransitFOBCrates[_heli:getName()] = nil

        local _position = _heli:getPosition()

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_position.x.z, _position.x.x)
        local _xOffset = math.cos(_angle) * -60
        local _yOffset = math.sin(_angle) * -60

        local _point = _heli:getPoint()

        local _side = _heli:getCoalition()

        local _unitId = ctld.getNextUnitId()

        local _name = string.format("FOB Crate #%i", _unitId)

        local _spawnedCrate = ctld.spawnFOBCrateStatic(_heli:getCountry(), ctld.getNextUnitId(),
            { x = _point.x + _xOffset, z = _point.z + _yOffset }, _name)

        if _side == 1 then
            ctld.droppedFOBCratesRED[_name] = _name
        else
            ctld.droppedFOBCratesBLUE[_name] = _name
        end

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 delivered a FOB Crate", ctld.getPlayerNameOrType(_heli)), 10)

        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Delivered FOB Crate 60m at 6'oclock to you"), 10)
    elseif _inZone == true and _crateOnboard == true then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate dropped back to base"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = nil
    elseif _inZone == true and _crateOnboard == false then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = true

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)
    else
        -- nearest Crate
        local _crates = ctld.getCratesAndDistance(_heli)
        local _nearestCrate = ctld.getClosestCrate(_heli, _crates, "FOB")

        if _nearestCrate ~= nil and _nearestCrate.dist < 150 then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)
            ctld.inTransitFOBCrates[_heli:getName()] = true

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)

            if _side == 1 then
                ctld.droppedFOBCratesRED[_nearestCrate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
            end

            --remove
            _nearestCrate.crateUnit:destroy()
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("There are no friendly logistic units nearby to load a FOB crate from!"), 10)
        end
    end
end

function ctld.updateTroopsInGame(params, t) -- return count of troops in game by Coalition
    if t == nil then t = timer.getTime() + 1; end
    ctld.InfantryInGameCount = { 0, 0 }
    for coalitionId = 1, 2 do                                                          -- for each CoaId
        for k, v in ipairs(coalition.getGroups(coalitionId, Group.Category.GROUND)) do -- for each GROUND type group
            for index, unitObj in pairs(v:getUnits()) do                               -- for each unit in group
                if unitObj:getDesc().attributes.Infantry then
                    ctld.InfantryInGameCount[coalitionId] = ctld.InfantryInGameCount[coalitionId] + 1
                end
            end
        end
    end
    return 5 -- reschedule each 5"
end

function ctld.loadTroopsFromZone(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]
    local _groupTemplate = _args[3] or ""
    local _allowExtract = _args[4]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end
        return false
    end

    local _extract

    if _allowExtract then
        -- first check for extractable troops regardless of if we're in a zone or not
        if _troops then
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
            end
        else
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
            end
        end
    end

    if _extract ~= nil then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), _troops })
    elseif _zone.inZone == true then
        local heloCoa = _heli:getCoalition()
        ctld.logTrace("FG_ heloCoa =  %s", ctld.p(heloCoa))
        ctld.logTrace("FG_ (ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0) =  %s",
            ctld.p(ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0))
        ctld.logTrace("FG_ ctld.InfantryInGameCount[heloCoa] =  %s", ctld.p(ctld.InfantryInGameCount[heloCoa]))
        ctld.logTrace("FG_ _groupTemplate.total =  %s", ctld.p(_groupTemplate.total))
        ctld.logTrace("FG_ ctld.nbLimitSpawnedTroops[%s].total =  %s", ctld.p(heloCoa),
            ctld.p(ctld.nbLimitSpawnedTroops[heloCoa]))

        local limitReached = true
        if (ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0) and (ctld.InfantryInGameCount[heloCoa] + _groupTemplate.total > ctld.nbLimitSpawnedTroops[heloCoa]) then -- load troops only if Coa limit not reached
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("Count Infantries limit in the mission reached, you can't load more troops"), 10)
            return false
        end
        if _zone.limit - 1 >= 0 then
            -- decrease zone counter by 1
            ctld.updateZoneCounter(_zone.index, -1)
            ctld.loadTroops(_heli, _troops, _groupTemplate)
            return true
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("This area has no more reinforcements available!"), 20)
            return false
        end
    else
        if _allowExtract then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("You are not in a pickup zone and no one is nearby to extract"), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You are not in a pickup zone"), 10)
        end

        return false
    end
end

function ctld.unloadTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)
    if not ctld.troopsOnboard(_heli, _troops) then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No one to unload"), 10)

        return false
    else
        -- troops must be onboard to get here
        if _zone.inZone == true then
            if _troops then
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped troops back to base"), 20)

                ctld.processCallback({
                    unit = _heli,
                    unloaded = ctld.inTransitTroops[_heli:getName()].troops,
                    action =
                    "unload_troops_zone"
                })

                ctld.inTransitTroops[_heli:getName()].troops = nil
            else
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped vehicles back to base"), 20)

                ctld.processCallback({
                    unit = _heli,
                    unloaded = ctld.inTransitTroops[_heli:getName()].vehicles,
                    action =
                    "unload_vehicles_zone"
                })

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
            end

            ctld.adaptWeightToCargo(_heli:getName())

            -- increase zone counter by 1
            ctld.updateZoneCounter(_zone.index, 1)

            return true
        elseif ctld.troopsOnboard(_heli, _troops) then
            return ctld.deployTroops(_heli, _troops)
        end
    end
end

function ctld.extractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    if ctld.inAir(_heli) then
        return false
    end

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end

        return false
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        _onboard = { troops = nil, vehicles = nil }
    end

    local _extracted = false

    if _troops then
        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end


        if _extractTroops ~= nil then
            local _limit = ctld.getTransportLimit(_heli:getTypeName())

            local _size = #_extractTroops.group:getUnits()

            if _limit < #_extractTroops.group:getUnits() then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3", _size,
                        _limit, _heli:getTypeName()), 20)

                return
            end

            _onboard.troops = _extractTroops.details
            _onboard.troops.weight = #_extractTroops.group:getUnits() * 130 -- default to 130kg per soldier

            if _extractTroops.group:getName():lower():find("jtac") then
                _onboard.troops.jtac = true
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted troops in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            ctld.processCallback({ unit = _heli, extracted = _extractTroops, action = "extract_troops" })

            --remove
            _extractTroops.group:destroy()

            _extracted = true
        else
            _onboard.troops = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable troops nearby!"), 20)
        end
    else
        local _extractVehicles


        if _heli:getCoalition() == 1 then
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
        else
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
        end

        if _extractVehicles ~= nil then
            _onboard.vehicles = _extractVehicles.details

            if _heli:getCoalition() == 1 then
                ctld.droppedVehiclesRED[_extractVehicles.group:getName()] = nil
            else
                ctld.droppedVehiclesBLUE[_extractVehicles.group:getName()] = nil
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted vehicles in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            ctld.processCallback({ unit = _heli, extracted = _extractVehicles, action = "extract_vehicles" })
            --remove
            _extractVehicles.group:destroy()
            _extracted = true
        else
            _onboard.vehicles = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable vehicles nearby!"), 20)
        end
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())

    return _extracted
end

function ctld.checkTroopStatus(_args)
    local _unitName = _args[1]
    --list onboard troops, if c130
    local _heli = ctld.getTransportUnit(_unitName)

    if _heli == nil then
        return
    end

    local _, _message = ctld.getWeightOfCargo(_unitName)
    if _message and _message ~= "" then
        ctld.displayMessageToGroup(_heli, _message, 10)
    end
end

-- Removes troops from transport when it dies
function ctld.checkTransportStatus()
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 3)

    for _, _name in ipairs(ctld.transportPilotNames) do
        local _transUnit = ctld.getTransportUnit(_name)

        if _transUnit == nil then
            --env.info("CTLD Transport Unit Dead event")
            ctld.inTransitTroops[_name] = nil
            ctld.inTransitFOBCrates[_name] = nil
            ctld.inTransitSlingLoadCrates[_name] = nil
        end
    end
end

function ctld.adaptWeightToCargo(unitName)
    local _weight = ctld.getWeightOfCargo(unitName)
    trigger.action.setUnitInternalCargo(unitName, _weight)
end

function ctld.getWeightOfCargo(unitName)
    local FOB_CRATE_WEIGHT = 800
    local _weight = 0
    local _description = ""

    ctld.inTransitSlingLoadCrates[unitName] = ctld.inTransitSlingLoadCrates[unitName] or {}

    -- add troops weight
    if ctld.inTransitTroops[unitName] then
        local _inTransit = ctld.inTransitTroops[unitName]
        if _inTransit then
            local _troops = _inTransit.troops
            if _troops and _troops.units then
                _description = _description ..
                    ctld.i18n_translate("%1 troops onboard (%2 kg)\n", #_troops.units, _troops.weight)
                _weight = _weight + _troops.weight
            end
            local _vehicles = _inTransit.vehicles
            if _vehicles and _vehicles.units then
                for _, _unit in pairs(_vehicles.units) do
                    _weight = _weight + _unit.weight
                end
                _description = _description ..
                    ctld.i18n_translate("%1 vehicles onboard (%2)\n", #_vehicles.units, _weight)
            end
        end
    end

    -- add FOB crates weight
    if ctld.inTransitFOBCrates[unitName] then
        _weight = _weight + FOB_CRATE_WEIGHT
        _description = _description .. ctld.i18n_translate("1 FOB Crate oboard (%1 kg)\n", FOB_CRATE_WEIGHT)
    end

    -- add simulated slingload crates weight
    for i = 1, #ctld.inTransitSlingLoadCrates[unitName] do
        local _crate = ctld.inTransitSlingLoadCrates[unitName][i]
        if _crate and _crate.simulatedSlingload then
            _weight = _weight + _crate.weight
            _description = _description .. ctld.i18n_translate("%1 crate onboard (%2 kg)\n", _crate.desc, _crate.weight)
        end
    end
    if _description ~= "" then
        _description = _description .. ctld.i18n_translate("Total weight of cargo : %1 kg\n", _weight)
    else
        _description = ctld.i18n_translate("No cargo.")
    end

    return _weight, _description
end

function ctld.checkHoverStatus()
    timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1.0)

    local _status, _result = pcall(function()
        for _, _name in ipairs(ctld.transportPilotNames) do
            local _reset = true
            local _transUnit = ctld.getTransportUnit(_name)
            local _transUnitTypeName = _transUnit and _transUnit:getTypeName()
            local _cargoCapacity = ctld.internalCargoLimits[_transUnitTypeName] or 1
            ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

            --only check transports that are hovering and not planes
            if _transUnit ~= nil and #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity and ctld.inAir(_transUnit) and ctld.unitCanCarryVehicles(_transUnit) == false and not ctld.unitDynamicCargoCapable(_transUnit) then
                local _crates = ctld.getCratesAndDistance(_transUnit)

                for _, _crate in pairs(_crates) do
                    local _crateUnitName = _crate.crateUnit:getName()
                    if _crate.dist < ctld.maxDistanceFromCrate and _crate.details.unit ~= "FOB" then
                        --check height!
                        local _height = _transUnit:getPoint().y - _crate.crateUnit:getPoint().y
                        if _height > ctld.minimumHoverHeight and _height <= ctld.maximumHoverHeight then
                            local _time = ctld.hoverStatus[_name]

                            if _time == nil then
                                ctld.hoverStatus[_name] = ctld.hoverTime
                                _time = ctld.hoverTime
                            else
                                _time = ctld.hoverStatus[_name] - 1
                                ctld.hoverStatus[_name] = _time
                            end

                            if _time > 0 then
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate(
                                        "Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!",
                                        _crate.details.desc, _time), 10, true)
                            else
                                ctld.hoverStatus[_name] = nil
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc), 10, true)

                                --crates been moved once!
                                ctld.crateMove[_crateUnitName] = nil

                                if _transUnit:getCoalition() == 1 then
                                    ctld.spawnedCratesRED[_crateUnitName] = nil
                                else
                                    ctld.spawnedCratesBLUE[_crateUnitName] = nil
                                end

                                _crate.crateUnit:destroy()

                                local _copiedCrate = ctld.utils.deepCopy("ctld.checkHoverStatus()", _crate
                                    .details)
                                _copiedCrate.simulatedSlingload = true
                                table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                                ctld.adaptWeightToCargo(_name)
                            end

                            _reset = false

                            break
                        elseif _height <= ctld.minimumHoverHeight then
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too low to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        else
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too high to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        end
                    end
                end
            end

            if _reset then
                ctld.hoverStatus[_name] = nil
            end
        end
    end)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _result))
    end
end

function ctld.loadNearbyCrate(_name)
    local _transUnit = ctld.getTransportUnit(_name)

    if _transUnit ~= nil then
        local _cargoCapacity = ctld.internalCargoLimits[_transUnit:getTypeName()] or 1
        ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

        if ctld.inAir(_transUnit) then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("You must land before you can load a crate!"), 10,
                true)
            return
        end

        local _crates = ctld.getCratesAndDistance(_transUnit)
        local loaded = false
        for _, _crate in pairs(_crates) do
            if _crate.dist < 50.0 then
                if #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity then
                    ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc),
                        10)

                    if _transUnit:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                    else
                        ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                    end

                    ctld.crateMove[_crate.crateUnit:getName()] = nil

                    _crate.crateUnit:destroy()

                    local _copiedCrate = ctld.utils.deepCopy("ctld.loadNearbyCrate()", _crate.details)
                    _copiedCrate.simulatedSlingload = true
                    table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                    loaded = true
                    ctld.adaptWeightToCargo(_name)
                else
                    -- Max crates onboard
                    local outputMsg = ctld.i18n_translate("Maximum number of crates are on board!")
                    for i = 1, _cargoCapacity do
                        outputMsg = outputMsg .. "\n" .. ctld.inTransitSlingLoadCrates[_name][i].desc
                    end
                    ctld.displayMessageToGroup(_transUnit, outputMsg, 10, true)
                    return
                end
            end
        end
        if not loaded then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("No Crates within 50m to load!"), 10, true)
        end
    end
end

--check each minute if the beacons' batteries have failed, and stop them accordingly
--there's no more need to actually refresh the beacons, since we set "loop" to true.
function ctld.refreshRadioBeacons()
    timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 60)


    for _index, _beaconDetails in ipairs(ctld.deployedRadioBeacons) do
        if ctld.updateRadioBeacon(_beaconDetails) == false then
            --search used frequencies + remove, add back to unused

            for _i, _freq in ipairs(ctld.usedUHFFrequencies) do
                if _freq == _beaconDetails.uhf then
                    table.insert(ctld.freeUHFFrequencies, _freq)
                    table.remove(ctld.usedUHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedVHFFrequencies) do
                if _freq == _beaconDetails.vhf then
                    table.insert(ctld.freeVHFFrequencies, _freq)
                    table.remove(ctld.usedVHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedFMFrequencies) do
                if _freq == _beaconDetails.fm then
                    table.insert(ctld.freeFMFrequencies, _freq)
                    table.remove(ctld.usedFMFrequencies, _i)
                end
            end

            --clean up beacon table
            table.remove(ctld.deployedRadioBeacons, _index)
        end
    end
end

function ctld.getClockDirection(_heli, _crate)
    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p      -- get position of crate
    local _playerPosition = _heli:getPosition().p -- get position of helicopter
    local _relativePosition = ctld.utils.subVec3("ctld.getClockDirection()", _position, _playerPosition)

    local _playerHeading = ctld.utils.getHeadingInRadians("ctld.getClockDirection()", _heli) -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = { x = math.cos(_playerHeading), y = 0, z = math.sin(_playerHeading) }

    local _headingVectorPerpendicular = {
        x = math.cos(_playerHeading + math.pi / 2),
        y = 0,
        z = math.sin(_playerHeading +
            math.pi / 2)
    }

    local _forwardDistance = ctld.utils.multVec3("ctld.getClockDirection()", _relativePosition, _headingVector)

    local _rightDistance = ctld.utils.multVec3("ctld.getClockDirection()", _relativePosition, _headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance, _forwardDistance) * 180 / math.pi

    if _angle < 0 then
        _angle = 360 + _angle
    end
    _angle = math.floor(_angle * 12 / 360 + 0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end

function ctld.listNearbyCrates(_args)
    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    local _crates = ctld.getCratesAndDistance(_heli)

    --sort
    local _sort = function(a, b) return a.dist < b.dist end
    table.sort(_crates, _sort)

    for _, _crate in pairs(_crates) do
        if _crate.dist < 1000 and _crate.details.unit ~= "FOB" then
            _message = ctld.i18n_translate("%1\n%2 crate - kg %3 - %4 m - %5 o'clock", _message, _crate.details.desc,
                _crate.details.weight, _crate.dist, ctld.getClockDirection(_heli, _crate.crateUnit))
        end
    end


    local _fobMsg = ""
    for _, _fobCrate in pairs(_crates) do
        if _fobCrate.dist < 1000 and _fobCrate.details.unit == "FOB" then
            _fobMsg = _fobMsg ..
                ctld.i18n_translate("FOB Crate - %1 m - %2 o'clock\n", _fobCrate.dist,
                    ctld.getClockDirection(_heli, _fobCrate.crateUnit))
        end
    end

    local _txt = ctld.i18n_translate("No Nearby Crates")
    if _message ~= "" or _fobMsg ~= "" then
        _txt = ""

        if _message ~= "" then
            _txt = ctld.i18n_translate("Nearby Crates:\n%1", _message)
        end

        if _fobMsg ~= "" then
            if _txt ~= "" then
                _txt = _txt .. "\n\n"
            end

            _txt = _txt .. ctld.i18n_translate("Nearby FOB Crates (Not Slingloadable):\n%1", _fobMsg)
        end
    end
    ctld.displayMessageToGroup(_heli, _txt, 20)
end

function ctld.listFOBS(_args)
    local _msg = ctld.i18n_translate("FOB Positions:")

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    -- get fob positions
    local _fobs = ctld.getSpawnedFobs(_heli)

    if _fobs and #_fobs > 0 then
        -- now check spawned fobs
        for _, _fob in ipairs(_fobs) do
            _msg = ctld.i18n_translate("%1\nFOB @ %2", _msg, ctld.getFOBPositionString(_fob))
        end
    else
        _msg = ctld.i18n_translate("Sorry, there are no active FOBs!")
    end
    ctld.displayMessageToGroup(_heli, _msg, 20)
end

function ctld.getFOBPositionString(_fob)
    local _lat, _lon = coord.LOtoLL(_fob:getPosition().p)

    local _latLngStr = CTLD_extAPI.tostringLL("ctld.getFOBPositionString()", _lat, _lon, 3, ctld.location_DMS)

    --     local _mgrsString = CTLD_extAPI.tostringMGRS("ctld.getFOBPositionString()", coord.LLtoMGRS(coord.LOtoLL(_fob:getPosition().p)), 5)

    local _message = _latLngStr

    local _beaconInfo = ctld.fobBeacons[_fob:getName()]

    if _beaconInfo ~= nil then
        _message = string.format("%s - %.2f KHz ", _message, _beaconInfo.vhf / 1000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.uhf / 1000000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.fm / 1000000)
    end

    return _message
end

function ctld.displayMessageToGroup(_unit, _text, _time, _clear)
    local _groupId = ctld.getGroupId(_unit)
    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time, _clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

function ctld.heightDiff(_unit)
    local _point = _unit:getPoint()

    -- env.info("heightunit " .. _point.y)
    --env.info("heightland " .. land.getHeight({ x = _point.x, y = _point.z }))

    return _point.y - land.getHeight({ x = _point.x, y = _point.z })
end

--includes fob crates!
function ctld.getCratesAndDistance(_heli)
    local _crates = {}

    local _allCrates
    if _heli:getCoalition() == 1 then
        _allCrates = ctld.spawnedCratesRED
    else
        _allCrates = ctld.spawnedCratesBLUE
    end

    for _crateName, _details in pairs(_allCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0
            and (ctld.inAir(_crate) == false) then
            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = _details }

            table.insert(_crates, _crateDetails)
        end
    end

    local _fobCrates
    if _heli:getCoalition() == 1 then
        _fobCrates = ctld.droppedFOBCratesRED
    else
        _fobCrates = ctld.droppedFOBCratesBLUE
    end

    for _crateName, _details in pairs(_fobCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then
            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = { unit = "FOB" }, }

            table.insert(_crates, _crateDetails)
        end
    end

    return _crates
end

function ctld.getClosestCrate(_heli, _crates, _type)
    local _closestCrate     = nil
    local _shortestDistance = -1
    local _distance         = 0
    local _minimumDistance  = 5  -- prevents dynamic cargo crates from unpacking while in cargo hold
    local _maxDistance      = 25 -- prevents onboard dynamic cargo crates from unpacking requested by other helo
    for _, _crate in pairs(_crates) do
        if (_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) and _distance > _minimumDistance and _distance < _maxDistance then
                _shortestDistance = _distance
                _closestCrate = _crate
            end
        end
    end

    return _closestCrate
end

function ctld.findNearestAASystem(_heli, _aaSystem)
    local _closestHawkGroup = nil
    local _shortestDistance = -1
    local _distance = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() and _hawkDetails[1].system.name == _aaSystem.name then
            local _units = _hawkGroup:getUnits()

            for _, _leader in pairs(_units) do
                if _leader ~= nil and _leader:getLife() > 0 then
                    _distance = ctld.getDistance(_leader:getPoint(), _heli:getPoint())

                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestHawkGroup = _hawkGroup
                    end

                    break
                end
            end
        end
    end

    if _closestHawkGroup ~= nil then
        return { group = _closestHawkGroup, dist = _shortestDistance }
    end
    return nil
end

function ctld.getCrateObject(_name)
    local _crate

    if ctld.staticBugWorkaround then
        _crate = Unit.getByName(_name)
    else
        _crate = StaticObject.getByName(_name)
    end
    return _crate
end

function ctld.unpackCrates(_arguments)
    ctld.logTrace("FG_ ctld.unpackCrates._arguments =  %s", ctld.p(_arguments))
    local _status, _err = pcall(function(_args)
        local _heli = ctld.getTransportUnit(_args[1])
        ctld.logTrace("FG_ ctld.unpackCrates._args =  %s", ctld.p(_args))
        if _heli ~= nil and ctld.inAir(_heli) == false then
            local _crates = ctld.getCratesAndDistance(_heli)
            local _crate = ctld.getClosestCrate(_heli, _crates)
            ctld.logTrace("FG_ ctld.unpackCrates._crate =  %s", ctld.p(_crate))

            if ctld.inLogisticsZone(_heli) == true or ctld.farEnoughFromLogisticZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)
                return
            end

            if _crate ~= nil and _crate.dist < 750
                and (_crate.details.unit == "FOB" or _crate.details.unit == "FOB-SMALL") then
                ctld.unpackFOBCrates(_crates, _heli)

                return
            elseif _crate ~= nil and _crate.dist < 200 then
                if ctld.forceCrateToBeMoved and ctld.crateMove[_crate.crateUnit:getName()] and not ctld.unitDynamicCargoCapable(_heli) then
                    ctld.displayMessageToGroup(_heli,
                        ctld.i18n_translate("Sorry you must move this crate before you unpack it!"), 20)
                    return
                end


                local _aaTemplate = ctld.getAATemplate(_crate.details.unit)

                if _aaTemplate then
                    if _crate.details.unit == _aaTemplate.repair then
                        ctld.repairAASystem(_heli, _crate, _aaTemplate)
                    else
                        ctld.unpackAASystem(_heli, _crate, _crates, _aaTemplate)
                    end

                    return -- stop processing
                    -- is multi crate?
                elseif _crate.details.cratesRequired ~= nil and _crate.details.cratesRequired > 1 then
                    -- multicrate

                    ctld.unpackMultiCrate(_heli, _crate, _crates)

                    return
                else
                    ctld.logTrace("single crate =  %s", ctld.p(_arguments))
                    -- single crate
                    --local _cratePoint = _crate.crateUnit:getPoint()
                    local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                    if ctld.unitDynamicCargoCapable(_heli) == true then
                        _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                        if _crate.details.unit == "MQ-9 Reaper" or _crate.details.unit == "RQ-1A Predator" then
                            --special case to increase spawn altitude for drones
                            _point.y = _point.y + 1000 -- set spawn altitude to 1000m
                        end
                    end
                    local _crateName = _crate.crateUnit:getName()
                    local _crateHdg  = ctld.utils.getHeadingInRadians("ctld.unpackCrates()", _crate.crateUnit, true)

                    --remove crate
                    --    if ctld.slingLoad == false then
                    _crate.crateUnit:destroy()
                    -- end
                    ctld.logTrace("_crate =  %s", ctld.p(_crate))
                    ctld.logTrace("single _point =  %s", ctld.p(_point))
                    ctld.logTrace("single _crate.details.unit =  %s", ctld.p(_crate.details.unit))
                    local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _point }, { _crate.details.unit }, { _crateHdg })
                    ctld.logTrace("_spawnedGroups.name =  %s", ctld.p(_spawnedGroups:getName()))
                    ctld.logTrace("_spawnedGroups =  %s", ctld.p(_spawnedGroups))

                    if _heli:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crateName] = nil
                    else
                        ctld.spawnedCratesBLUE[_crateName] = nil
                    end

                    ctld.processCallback({ unit = _heli, crate = _crate, spawnedGroup = _spawnedGroups, action = "unpack" })

                    if _crate.details.unit == "1L13 EWR" then
                        ctld.addEWRTask(_spawnedGroups)

                        --             env.info("Added EWR")
                    end


                    trigger.action.outTextForCoalition(_heli:getCoalition(),
                        ctld.i18n_translate("%1 successfully deployed %2 to the field", ctld.getPlayerNameOrType(_heli),
                            _crate.details.desc), 10)
                    timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
                    if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        --put to the end
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)

                        ctld.JTACStart(_spawnedGroups:getName(), _code) --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("No friendly crates close enough to unpack, or crate too close to aircraft."), 20)
            end
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

-- builds a fob!
function ctld.unpackFOBCrates(_crates, _heli)
    if ctld.inLogisticsZone(_heli) == true then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)

        return
    end

    -- unpack multi crate
    local _nearbyMultiCrates = {}

    local _bigFobCrates = 0
    local _smallFobCrates = 0
    local _totalCrates = 0

    for _, _nearbyCrate in pairs(_crates) do
        if _nearbyCrate.dist < 750 then
            if _nearbyCrate.details.unit == "FOB" then
                _bigFobCrates = _bigFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            elseif _nearbyCrate.details.unit == "FOB-SMALL" then
                _smallFobCrates = _smallFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            end

            --catch divide by 0
            if _smallFobCrates > 0 then
                _totalCrates = _bigFobCrates + (_smallFobCrates / 3.0)
            else
                _totalCrates = _bigFobCrates
            end

            if _totalCrates >= ctld.cratesRequiredForFOB then
                break
            end
        end
    end

    --- check crate count
    if _totalCrates >= ctld.cratesRequiredForFOB then
        -- destroy crates

        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do
            if _heli:getCoalition() == 1 then
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())

            --destroy
            _crate.crateUnit:destroy()
        end

        local _centroid = ctld.getCentroid(_points)

        timer.scheduleFunction(function(_args)
            local _unitId = ctld.getNextUnitId()
            local _name = "Deployed FOB #" .. _unitId

            local _fob = ctld.spawnFOB(_args[2], _unitId, _args[1], _name)

            --make it able to deploy crates
            table.insert(ctld.logisticUnits, _fob:getName())

            ctld.beaconCount = ctld.beaconCount + 1

            local _radioBeaconName = "FOB Beacon #" .. ctld.beaconCount

            local _radioBeaconDetails = ctld.createRadioBeacon(_args[1], _args[3], _args[2], _radioBeaconName, nil, true)

            ctld.fobBeacons[_name] = {
                vhf = _radioBeaconDetails.vhf,
                uhf = _radioBeaconDetails.uhf,
                fm =
                    _radioBeaconDetails.fm
            }

            if ctld.troopPickupAtFOB == true then
                table.insert(ctld.builtFOBS, _fob:getName())

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates and Troops can now be picked up."), 10)
            else
                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates can now be picked up."), 10)
            end
        end, { _centroid, _heli:getCountry(), _heli:getCoalition() }, timer.getTime() + ctld.buildTimeFOB)

        ctld.processCallback({ unit = _heli, position = _centroid, action = "fob" })

        trigger.action.smoke(_centroid, trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
                "%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke.",
                ctld.getPlayerNameOrType(_heli), _totalCrates, ctld.buildTimeFOB, 10))
    else
        local _txt = ctld.i18n_translate(
            "Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other",
            ctld.cratesRequiredForFOB, _totalCrates)
        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

--unloads the sling crate when the helicopter is on the ground or between 4.5 - 10 meters
function ctld.dropSlingCrate(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    ctld.inTransitSlingLoadCrates[_unitName] = ctld.inTransitSlingLoadCrates[_unitName] or {}

    if _heli == nil then
        return -- no heli!
    end

    local _currentCrate = ctld.inTransitSlingLoadCrates[_unitName][#ctld.inTransitSlingLoadCrates[_unitName]]

    if _currentCrate == nil then
        if ctld.hoverPickup and ctld.loadCrateFromMenu then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands.",
                    ctld.hoverTime), 10)
        elseif ctld.hoverPickup then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate.",
                    ctld.hoverTime), 10)
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."),
                10)
        end
    else
        local _point = _heli:getPoint()
        local _side = _heli:getCoalition()
        local _hdg = ctld.utils.getHeadingInRadians("ctld.dropSlingCrate()", _heli, true)
        local _heightDiff = ctld.heightDiff(_heli)

        if _heightDiff > 40.0 then
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.adaptWeightToCargo(_unitName)
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You were too high! The crate has been destroyed"), 10)
            return
        end
        local _loadedCratesCopy = ctld.utils.deepCopy("ctld.dropSlingCrate()",
            ctld.inTransitSlingLoadCrates[_unitName])
        ctld.logTrace("_loadedCratesCopy = %s", ctld.p(_loadedCratesCopy))
        for _, _crate in pairs(_loadedCratesCopy) do
            ctld.logTrace("_crate = %s", ctld.p(_crate))
            ctld.logTrace("ctld.inAir(_heli) = %s", ctld.p(ctld.inAir(_heli)))
            ctld.logTrace("_heightDiff = %s", ctld.p(_heightDiff))
            local _unitId = ctld.getNextUnitId()
            local _name = string.format("%s #%i", _crate.desc, _unitId)
            local _model_type = nil
            if ctld.inAir(_heli) == false or _heightDiff <= 7.5 then
                _point = ctld.getPointAt12Oclock(_heli, 15)
                local _position = "12"
                if ctld.unitDynamicCargoCapable(_heli) then
                    _model_type = "dynamic"
                    _point = ctld.getPointAt6Oclock(_heli, 15)
                    _position = "6"
                end
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely unhooked and is at your %2 o'clock", _crate.desc,
                        _position), 10)
            elseif _heightDiff > 7.5 and _heightDiff <= 40.0 then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely dropped below you", _crate.desc), 10)
            end
            --remove crate from cargo
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crate.weight, _side, _hdg, _model_type)
        end
        ctld.adaptWeightToCargo(_unitName)
    end
end

--spawns a radio beacon made up of two units,
-- one for VHF and one for UHF
-- The units are set to to NOT engage
function ctld.createRadioBeacon(_point, _coalition, _country, _name, _batteryTime, _isFOB)
    local _freq = ctld.generateADFFrequencies()

    --create timeout
    local _battery

    if _batteryTime == nil then
        _battery = timer.getTime() + (ctld.deployedBeaconBattery * 60)
    else
        _battery = timer.getTime() + (_batteryTime * 60)
    end

    local _lat, _lon = coord.LOtoLL(_point)

    local _latLngStr = CTLD_extAPI.tostringLL("ctld.createRadioBeacon()", _lat, _lon, 3, ctld.location_DMS)

    --local _mgrsString = CTLD_extAPI.tostringMGRS("ctld.createRadioBeacon()", coord.LLtoMGRS(coord.LOtoLL(_point)), 5)

    local _freqsText = _name

    if _isFOB then
        --    _message = "FOB " .. _message
        _battery = -1 --never run out of power!
    end

    _freqsText = _freqsText .. " - " .. _latLngStr


    _freqsText = string.format("%.2f kHz - %.2f / %.2f MHz", _freq.vhf / 1000, _freq.uhf / 1000000, _freq.fm / 1000000)

    local _uhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _vhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _fmGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)

    local _beaconDetails = {
        vhf = _freq.vhf,
        vhfGroup = _vhfGroup:getName(),
        uhf = _freq.uhf,
        uhfGroup = _uhfGroup:getName(),
        fm = _freq.fm,
        fmGroup = _fmGroup:getName(),
        text = _freqsText,
        battery = _battery,
        coalition = _coalition,
    }

    ctld.updateRadioBeacon(_beaconDetails)

    table.insert(ctld.deployedRadioBeacons, _beaconDetails)

    return _beaconDetails
end

function ctld.generateADFFrequencies()
    if #ctld.freeUHFFrequencies <= 3 then
        ctld.freeUHFFrequencies = ctld.usedUHFFrequencies
        ctld.usedUHFFrequencies = {}
    end

    --remove frequency at RANDOM
    local _uhf = table.remove(ctld.freeUHFFrequencies, math.random(#ctld.freeUHFFrequencies))
    table.insert(ctld.usedUHFFrequencies, _uhf)


    if #ctld.freeVHFFrequencies <= 3 then
        ctld.freeVHFFrequencies = ctld.usedVHFFrequencies
        ctld.usedVHFFrequencies = {}
    end

    local _vhf = table.remove(ctld.freeVHFFrequencies, math.random(#ctld.freeVHFFrequencies))
    table.insert(ctld.usedVHFFrequencies, _vhf)

    if #ctld.freeFMFrequencies <= 3 then
        ctld.freeFMFrequencies = ctld.usedFMFrequencies
        ctld.usedFMFrequencies = {}
    end

    local _fm = table.remove(ctld.freeFMFrequencies, math.random(#ctld.freeFMFrequencies))
    table.insert(ctld.usedFMFrequencies, _fm)

    return { uhf = _uhf, vhf = _vhf, fm = _fm }
    --- return {uhf=_uhf,vhf=_vhf}
end

function ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _groupId = ctld.getNextGroupId()

    local _unitId = ctld.getNextUnitId()

    local _radioGroup = {
        ["visible"] = false,
        -- ["groupId"] = _groupId,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["y"] = _point.z,
                ["type"] = "TACAN_beacon",
                ["name"] = "Unit #" .. _unitId .. " - " .. _name .. " [" .. _freqsText .. "]",
                --     ["unitId"] = _unitId,
                ["heading"] = 0,
                ["playerCanDrive"] = true,
                ["skill"] = "Excellent",
                ["x"] = _point.x,
            }
        },
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = "Group #" .. _groupId .. " - " .. _name,
        ["task"] = {},
        --added two fields below for MIST
        ["category"] = Group.Category.GROUND,
        ["country"] = _country
    }

    -- return coalition.addGroup(_country, Group.Category.GROUND, _radioGroup)
    return Group.getByName(CTLD_extAPI.dynAdd("ctld.spawnRadioBeaconUnit()", _radioGroup).name)
end

function ctld.updateRadioBeacon(_beaconDetails)
    local _vhfGroup = Group.getByName(_beaconDetails.vhfGroup)

    local _uhfGroup = Group.getByName(_beaconDetails.uhfGroup)

    local _fmGroup = Group.getByName(_beaconDetails.fmGroup)

    local _radioLoop = {}

    if _vhfGroup ~= nil and _vhfGroup:getUnits() ~= nil and #_vhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _vhfGroup, freq = _beaconDetails.vhf, silent = false, mode = 0 })
    end

    if _uhfGroup ~= nil and _uhfGroup:getUnits() ~= nil and #_uhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _uhfGroup, freq = _beaconDetails.uhf, silent = true, mode = 0 })
    end

    if _fmGroup ~= nil and _fmGroup:getUnits() ~= nil and #_fmGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _fmGroup, freq = _beaconDetails.fm, silent = false, mode = 1 })
    end

    local _batLife = _beaconDetails.battery - timer.getTime()

    if (_batLife <= 0 and _beaconDetails.battery ~= -1) or #_radioLoop ~= 3 then
        -- ran out of batteries
        if _vhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_vhfGroup:getName())
            _vhfGroup:destroy()
        end
        if _uhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_uhfGroup:getName())
            _uhfGroup:destroy()
        end
        if _fmGroup ~= nil then
            trigger.action.stopRadioTransmission(_fmGroup:getName())
            _fmGroup:destroy()
        end

        return false
    end

    --fobs have unlimited battery life
    --        if _battery ~= -1 then
    --                _text = _text.." "..ctld.utils.round("ctld.updateRadioBeacon()", _batLife).." seconds of battery"
    --        end

    for _, _radio in pairs(_radioLoop) do
        local _groupController = _radio.group:getController()

        local _sound = ctld.radioSound
        if _radio.silent then
            _sound = ctld.radioSoundFC3
        end

        _sound = "l10n/DEFAULT/" .. _sound

        _groupController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)


        -- stop the transmission at each call to the ctld.updateRadioBeacon method (default each minute)
        trigger.action.stopRadioTransmission(_radio.group:getName())

        -- restart it as the battery is still up
        -- the transmission is set to loop and has the name of the transmitting DCS group (that includes the type - i.e. FM, UHF, VHF)
        trigger.action.radioTransmission(_sound, _radio.group:getUnit(1):getPoint(), _radio.mode, true, _radio.freq, 1000,
            _radio.group:getName())
    end

    return true
end

function ctld.listRadioBeacons(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil then
        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                _message = _message .. _details.text .. "\n"
            end
        end

        if _message ~= "" then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Radio Beacons:\n%1", _message), 20)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Active Radio Beacons"), 20)
        end
    end
end

function ctld.dropRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        --deploy 50 m infront
        --try to spawn at 12 oclock to us
        local _point = ctld.getPointAt12Oclock(_heli, 50)

        ctld.beaconCount = ctld.beaconCount + 1
        local _name = "Beacon #" .. ctld.beaconCount

        local _radioBeaconDetails = ctld.createRadioBeacon(_point, _heli:getCoalition(), _heli:getCountry(), _name, nil,
            false)

        -- mark with flare?

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 deployed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                _radioBeaconDetails.text, 20))
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before you can deploy a Radio Beacon!"),
            20)
    end
end

--remove closet radio beacon
function ctld.removeRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        -- mark with flare?

        local _closestBeacon = nil
        local _shortestDistance = -1
        local _distance = 0

        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                local _group = Group.getByName(_details.vhfGroup)

                if _group ~= nil and #_group:getUnits() == 1 then
                    _distance = ctld.getDistance(_heli:getPoint(), _group:getUnit(1):getPoint())
                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestBeacon = _details
                    end
                end
            end
        end

        if _closestBeacon ~= nil and _shortestDistance then
            local _vhfGroup = Group.getByName(_closestBeacon.vhfGroup)

            local _uhfGroup = Group.getByName(_closestBeacon.uhfGroup)

            local _fmGroup = Group.getByName(_closestBeacon.fmGroup)

            if _vhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_vhfGroup:getName())
                _vhfGroup:destroy()
            end
            if _uhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_uhfGroup:getName())
                _uhfGroup:destroy()
            end
            if _fmGroup ~= nil then
                trigger.action.stopRadioTransmission(_fmGroup:getName())
                _fmGroup:destroy()
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 removed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                    _closestBeacon.text, 20))
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Radio Beacons within 500m."), 20)
        end
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before remove a Radio Beacon"), 20)
    end
end

-- gets the center of a bunch of points!
-- return proper DCS point with height
function ctld.getCentroid(_points)
    local _tx, _ty = 0, 0
    for _index, _point in ipairs(_points) do
        _tx = _tx + _point.x
        _ty = _ty + _point.z
    end

    local _npoints = #_points

    local _point = { x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({ _point.x, _point.z })

    return _point
end

function ctld.getAATemplate(_unitName)
    for _, _system in pairs(ctld.AASystemTemplate) do
        if _system.repair == _unitName then
            return _system
        end

        for _, _part in pairs(_system.parts) do
            if _unitName == _part.name then
                return _system
            end
        end
    end

    return nil
end

function ctld.getLauncherUnitFromAATemplate(_aaTemplate)
    for _, _part in pairs(_aaTemplate.parts) do
        if _part.launcher then
            return _part.name
        end
    end

    return nil
end

function ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    -- are we adding to existing aa system?
    -- check to see if the crate is a launcher
    if ctld.getLauncherUnitFromAATemplate(_aaSystemTemplate) == _nearestCrate.details.unit then
        -- find nearest COMPLETE AA system
        local _nearestSystem = ctld.findNearestAASystem(_heli, _aaSystemTemplate)

        if _nearestSystem ~= nil and _nearestSystem.dist < 300 then
            local _uniqueTypes = {} -- stores each unique part of system
            local _types = {}
            local _points = {}
            local _hdgs = {}

            local _units = _nearestSystem.group:getUnits()

            if _units ~= nil and #_units > 0 then
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        --this allows us to count each type once
                        _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                        table.insert(_points, _units[x]:getPoint())
                        table.insert(_types, _units[x]:getTypeName())
                        table.insert(_hdgs, ctld.utils.getHeadingInRadians("ctld.rearmAASystem()", _units[x], true))
                    end
                end
            end

            -- do we have the correct number of unique pieces and do we have enough points for all the pieces
            if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                -- rearm aa system
                -- destroy old group
                ctld.completeAASystems[_nearestSystem.group:getName()] = nil

                _nearestSystem.group:destroy()

                local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

                ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup,
                    _aaSystemTemplate)

                ctld.processCallback({
                    unit = _heli,
                    crate = _nearestCrate,
                    spawnedGroup = _spawnedGroup,
                    action =
                    "rearm"
                })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 successfully rearmed a full %2 in the field", ctld.getPlayerNameOrType(_heli),
                        _aaSystemTemplate.name, 20))

                if _heli:getCoalition() == 1 then
                    ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
                else
                    ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
                end

                -- remove crate
                --         if ctld.slingLoad == false then
                _nearestCrate.crateUnit:destroy()
                --    end

                return true -- all done so quit
            end
        end
    end

    return false
end

function ctld.getAASystemDetails(_hawkGroup, _aaSystemTemplate)
    local _units = _hawkGroup:getUnits()

    local _hawkDetails = {}

    for _, _unit in pairs(_units) do
        table.insert(_hawkDetails,
            {
                point = _unit:getPoint(),
                unit = _unit:getTypeName(),
                name = _unit:getName(),
                system = _aaSystemTemplate,
                hdg =
                    ctld.utils.getHeadingInRadians("ctld.getAASystemDetails()", _unit, true)
            })
    end

    return _hawkDetails
end

function ctld.countTableEntries(_table)
    if _table == nil then
        return 0
    end


    local _count = 0

    for _key, _value in pairs(_table) do
        _count = _count + 1
    end

    return _count
end

function ctld.unpackAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    ctld.logTrace("_nearestCrate = %s", ctld.p(_nearestCrate))
    ctld.logTrace("_nearbyCrates = %s", ctld.p(_nearbyCrates))
    ctld.logTrace("_aaSystemTemplate = %s", ctld.p(_aaSystemTemplate))

    if ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate) then
        -- rearmed system
        return
    end

    local _systemParts = {}

    --initialise list of parts
    for _, _part in pairs(_aaSystemTemplate.parts) do
        local _systemPart = {
            name = _part.name,
            desc = _part.desc,
            launcher = _part.launcher,
            amount = _part.amount,
            NoCrate =
                _part.NoCrate,
            found = 0,
            required = 1
        }
        -- if the part is a NoCrate required, it's found by default
        if _systemPart.NoCrate ~= nil then
            _systemPart.found = 1
        end
        _systemParts[_part.name] = _systemPart
    end

    local _cratePositions = {}
    local _crateHdg = {}

    local crateDistance = 500

    -- find all crates close enough and add them to the list if they're part of the AA System
    for _, _nearbyCrate in pairs(_nearbyCrates) do
        ctld.logTrace("_nearbyCrate = %s", ctld.p(_nearbyCrate))
        if _nearbyCrate.dist < crateDistance then
            local _name = _nearbyCrate.details.unit
            ctld.logTrace("_name = %s", ctld.p(_name))

            if _systemParts[_name] ~= nil then
                local foundCount = _systemParts[_name].found
                ctld.logTrace("foundCount = %s", ctld.p(foundCount))

                if not _cratePositions[_name] then
                    _cratePositions[_name] = {}
                end
                if not _crateHdg[_name] then
                    _crateHdg[_name] = {}
                end

                -- if this is our first time encountering this part of the system
                if foundCount == 0 then
                    local _foundPart = _systemParts[_name]

                    _foundPart.found = 1

                    -- store the number of crates required to compute how many crates will have to be removed later and to see if the system can be deployed
                    local cratesRequired = _nearbyCrate.details.cratesRequired
                    ctld.logTrace("cratesRequired = %s", ctld.p(cratesRequired))
                    if cratesRequired ~= nil then
                        _foundPart.required = cratesRequired
                    end

                    _systemParts[_name] = _foundPart
                else
                    -- otherwise, we found another crate for the same part
                    _systemParts[_name].found = foundCount + 1
                end

                -- add the crate to the part info along with it's position and heading
                local crateUnit = _nearbyCrate.crateUnit
                if not _systemParts[_name].crates then
                    _systemParts[_name].crates = {}
                end
                table.insert(_systemParts[_name].crates, _nearbyCrate)
                table.insert(_cratePositions[_name], crateUnit:getPoint())
                table.insert(_crateHdg[_name], ctld.utils.getHeadingInRadians("ctld.unpackAASystem()", crateUnit, true))
            end
        end
    end

    -- Compute the centroids for each type of crates and then the centroid of all the system crates which is used to find the spawn location for each part and a position for the NoCrate parts respectively
    -- One issue, all crates are considered for the centroid and the headings but not all of them may be used if crate stacking is allowed
    local _crateCentroids = {}
    local _idxCentroids = {}
    for _partName, _partPositions in pairs(_cratePositions) do
        _crateCentroids[_partName] = ctld.getCentroid(_partPositions)
        table.insert(_idxCentroids, _crateCentroids[_partName])
    end
    local _crateCentroid = ctld.getCentroid(_idxCentroids)

    -- Compute the average heading for each type of crates to know the heading to spawn the part
    local _aveHdg = {}
    -- Headings of each group of crates
    for _partName, _crateHeadings in pairs(_crateHdg) do
        local crateCount = #_crateHeadings
        _aveHdg[_partName] = 0
        -- Heading of each crate within a group
        for _index, _crateHeading in pairs(_crateHeadings) do
            _aveHdg[_partName] = _crateHeading / crateCount + _aveHdg[_partName]
        end
    end

    local spawnDistance = 50 -- circle radius to spawn units in a circle and randomize position relative to the crate location
    local arcRad = math.pi * 2

    local _txt = ""

    local _posArray = {}
    local _hdgArray = {}
    local _typeArray = {}
    -- for each part of the system parts
    for _name, _systemPart in pairs(_systemParts) do
        -- check if enough crates were found to build the part
        if _systemPart.found < _systemPart.required then
            _txt = _txt .. ctld.i18n_translate("Missing %1\n", _systemPart.desc)
        else
            -- use the centroid of the crates for this part as a spawn location
            local _point = _crateCentroids[_name]
            -- in the case this centroid does not exist (NoCrate), use the centroid of all crates found and add some randomness
            if _point == nil then
                _point = _crateCentroid
                _point = {
                    x = _point.x + math.random(0, 3) * spawnDistance,
                    y = _point.y,
                    z = _point.z +
                        math.random(0, 3) * spawnDistance
                }
            end

            -- use the average heading to spawn the part at
            local _hdg = _aveHdg[_name]
            -- if non are found (NoCrate), random heading
            if _hdg == nil then
                _hdg = math.random(0, arcRad)
            end

            -- search for the amount of times this part needs to be spawned, by default 1 for any unit and aaLaunchers for launchers
            local partAmount = 1
            if _systemPart.amount == nil then
                if _systemPart.launcher ~= nil then
                    partAmount = ctld.aaLaunchers
                end
            else
                -- but the amount may also be specified in the template
                partAmount = _systemPart.amount
            end
            -- if crate stacking is allowed, then find the multiplication factor for the amount depending on how many crates are required and how many were found
            if ctld.AASystemCrateStacking then
                _systemPart.amountFactor = _systemPart.found - _systemPart.found % _systemPart.required
            else
                _systemPart.amountFactor = 1
            end
            partAmount = partAmount * _systemPart.amountFactor

            --handle multiple units per part by spawning them in a circle around the crate
            if partAmount > 1 then
                local angular_step = arcRad / partAmount

                for _i = 1, partAmount do
                    local _angle = (angular_step * (_i - 1) + _hdg) % arcRad
                    local _xOffset = math.cos(_angle) * spawnDistance
                    local _yOffset = math.sin(_angle) * spawnDistance

                    table.insert(_posArray, { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset })
                    table.insert(_hdgArray, _angle) -- also spawn them perpendicular to that point of the circle
                    table.insert(_typeArray, _name)
                end
            else
                table.insert(_posArray, _point)
                table.insert(_hdgArray, _hdg)
                table.insert(_typeArray, _name)
            end
        end
    end

    local _activeLaunchers = ctld.countCompleteAASystems(_heli)

    local _allowed = ctld.getAllowedAASystems(_heli)

    env.info("Active: " .. _activeLaunchers .. " Allowed: " .. _allowed)

    if _activeLaunchers + 1 > _allowed then
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("Out of parts for AA Systems. Current limit is %1\n", _allowed, 10))
        return
    end

    if _txt ~= "" then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot build %1\n%2\n\nOr the crates are not close enough together",
                _aaSystemTemplate.name, _txt), 20)
        return
    else
        -- destroy crates
        for _name, _systemPart in pairs(_systemParts) do
            -- if there is a crate to delete in the first place
            if _systemPart.NoCrate ~= true then
                -- figure out how many crates to delete since we searched for as many as possible, not all of them might have been used
                local amountToDel = _systemPart.amountFactor * _systemPart.required
                local DelCounter = 0

                -- for each crate found for this part
                for _index, _crate in pairs(_systemPart.crates) do
                    -- if we still need to delete some crates
                    if DelCounter < amountToDel then
                        if _heli:getCoalition() == 1 then
                            ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                        else
                            ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                        end

                        --destroy
                        -- if ctld.slingLoad == false then
                        _crate.crateUnit:destroy()
                        DelCounter = DelCounter +
                            1 -- count up for one more crate has been deleted
                        --end
                    else
                        break
                    end
                end
            end
        end

        -- HAWK / BUK READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray, _hdgArray)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
                "%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4",
                ctld.getPlayerNameOrType(_heli), _aaSystemTemplate.name, _allowed, (_activeLaunchers + 1)), 10)
    end
end

--count the number of captured cities, sets the amount of allowed AA Systems
function ctld.getAllowedAASystems(_heli)
    if _heli:getCoalition() == 1 then
        return ctld.AASystemLimitBLUE
    else
        return ctld.AASystemLimitRED
    end
end

function ctld.countCompleteAASystems(_heli)
    local _count = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() then
            local _units = _hawkGroup:getUnits()

            if _units ~= nil and #_units > 0 then
                --get the system template
                local _aaSystemTemplate = _hawkDetails[1].system

                local _uniqueTypes = {} -- stores each unique part of system
                local _types = {}
                local _points = {}

                if _units ~= nil and #_units > 0 then
                    for x = 1, #_units do
                        if _units[x]:getLife() > 0 then
                            --this allows us to count each type once
                            _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                            table.insert(_points, _units[x]:getPoint())
                            table.insert(_types, _units[x]:getTypeName())
                        end
                    end
                end

                -- do we have the correct number of unique pieces and do we have enough points for all the pieces
                if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                    _count = _count + 1
                end
            end
        end
    end

    return _count
end

function ctld.repairAASystem(_heli, _nearestCrate, _aaSystem)
    -- find nearest COMPLETE AA system
    local _nearestHawk = ctld.findNearestAASystem(_heli, _aaSystem)



    if _nearestHawk ~= nil and _nearestHawk.dist < 300 then
        local _oldHawk = ctld.completeAASystems[_nearestHawk.group:getName()]

        --spawn new one

        local _types = {}
        local _hdgs = {}
        local _points = {}

        for _, _part in pairs(_oldHawk) do
            table.insert(_points, _part.point)
            table.insert(_hdgs, _part.hdg)
            table.insert(_types, _part.unit)
        end

        --remove old system
        ctld.completeAASystems[_nearestHawk.group:getName()] = nil
        _nearestHawk.group:destroy()

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystem)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "repair" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 successfully repaired a full %2 in the field.", ctld.getPlayerNameOrType(_heli),
                _aaSystem.name), 10)

        if _heli:getCoalition() == 1 then
            ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
        else
            ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
        end

        -- remove crate
        -- if ctld.slingLoad == false then
        _nearestCrate.crateUnit:destroy()
        -- end
    else
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot repair %1. No damaged %2 within 300m", _aaSystem.name, _aaSystem.name), 10)
    end
end

function ctld.unpackMultiCrate(_heli, _nearestCrate, _nearbyCrates)
    --ctld.logTrace("FG_ ctld.unpackMultiCrate, _nearestCrate =  %s", ctld.p(_nearestCrate))
    -- unpack multi crate
    local _nearbyMultiCrates = {}

    for _, _nearbyCrate in pairs(_nearbyCrates) do
        if _nearbyCrate.dist < 300 then
            if _nearbyCrate.details.unit == _nearestCrate.details.unit then
                table.insert(_nearbyMultiCrates, _nearbyCrate)
                if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
                    break
                end
            end
        end
    end

    --- check crate count
    if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
        --local _point    = _nearestCrate.crateUnit:getPoint()
        --local _point    = _heli:getPoint()
        --local secureDistanceFromUnit = ctld.getSecureDistanceFromUnit(_heli:getName())
        --_point.x = _point.x + secureDistanceFromUnit
        local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        if ctld.unitDynamicCargoCapable(_heli) == true then
            _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        end

        local _crateHdg = ctld.utils.getHeadingInRadians("ctld.unpackMultiCrate()", _nearestCrate.crateUnit, true)

        -- destroy crates
        for _, _crate in pairs(_nearbyMultiCrates) do
            if _point == nil then
                _point = _crate.crateUnit:getPoint()
            end

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            --destroy
            --     if ctld.slingLoad == false then
            _crate.crateUnit:destroy()
            --     end
        end

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, { _point }, { _nearestCrate.details.unit }, { _crateHdg })
        if _spawnedGroup == nil then
            ctld.logError("ctld.unpackMultiCrate group was not spawned - skipping setGrpROE")
        else
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
            ctld.setGrpROE(_spawnedGroup)
            ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })
            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 successfully deployed %2 to the field using %3 crates.",
                    ctld.getPlayerNameOrType(_heli), _nearestCrate.details.desc, #_nearbyMultiCrates), 10)
        end
    else
        local _txt = ctld.i18n_translate(
            "Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other",
            _nearestCrate.details.desc, _nearestCrate.details.cratesRequired, #_nearbyMultiCrates)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

--[[
function ctld.spawnCrateGroup_old(_heli, _positions, _types, _hdgs)
    -- ctld.logTrace("_heli      =  %s", ctld.p(_heli))
    -- ctld.logTrace("_positions =  %s", ctld.p(_positions))
    -- ctld.logTrace("_types     =  %s", ctld.p(_types))
    -- ctld.logTrace("_hdgs      =  %s", ctld.p(_hdgs))

    local _id = ctld.getNextGroupId()
    local _groupName = _types[1] .. "    #" .. _id
    local _side = _heli:getCoalition()
    local _group = {
        ["visible"]  = false,
        -- ["groupId"] = _id,
        ["hidden"]   = false,
        ["units"]    = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"]     = _groupName,
        ["tasks"]    = {},
        ["radioSet"] = false,
        ["task"]     = "Reconnaissance",
        ["route"]    = {},
    }

    local _hdg = 120 * math.pi / 180                                     -- radians = 120 degrees
    if _types[1] ~= "MQ-9 Reaper" and _types[1] ~= "RQ-1A Predator" then -- non-drones - JTAC
        local _spreadMin = 5
        local _spreadMax = 5
        local _spreadMult = 1
        for _i, _pos in ipairs(_positions) do
            local _unitId = ctld.getNextUnitId()
            local _details = {
                type = _types[_i],
                unitId = _unitId,
                name = string.format("Unpacked %s #%i", _types[_i],
                    _unitId)
            }
            --ctld.logTrace("Group._details =  %s", ctld.p(_details))
            if _hdgs and _hdgs[_i] then
                _hdg = _hdgs[_i]
            end

            _group.units[_i] = ctld.createUnit(_pos.x + math.random(_spreadMin, _spreadMax) * _spreadMult,
                _pos.z + math.random(_spreadMin, _spreadMax) * _spreadMult,
                _hdg,
                _details)
        end
        _group.category = Group.Category.GROUND
    else -- drones - JTAC
        local _unitId = ctld.getNextUnitId()
        local _details = {
            type      = _types[1],
            unitId    = _unitId,
            name      = string.format("Unpacked %s #%i", _types[1], _unitId),
            livery_id = "'camo' scheme",
            skill     = "High",
            speed     = 80,
            payload   = { pylons = {}, fuel = 1300, flare = 0, chaff = 0, gun = 100 }
        }

        _group.units[1] = ctld.createUnit(_positions[1].x,
            _positions[1].z + ctld.jtacDroneRadius,
            _hdg,
            _details)

        _group.category = Group.Category.AIRPLANE -- for drones

        -- create drone orbiting route
        local DroneRoute = {
            ["points"] =
            {
                [1] =
                {
                    ["alt"] = 2000,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] =
                    {
                        ["addopt"] = {},
                    }, -- end of ["properties"]
                    ["speed"] = 80,
                    ["task"] =
                    {
                        ["id"] = "ComboTask",
                        ["params"] =
                        {
                            ["tasks"] =
                            {
                                [1] =
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 1,
                                    ["params"] =
                                    {
                                        ["action"] =
                                        {
                                            ["id"] = "EPLRS",
                                            ["params"] =
                                            {
                                                ["value"] = true,
                                                ["groupId"] = 0,
                                            }, -- end of ["params"]
                                        },     -- end of ["action"]
                                    },         -- end of ["params"]
                                },             -- end of [1]
                                [2] =
                                {
                                    ["number"] = 2,
                                    ["auto"] = false,
                                    ["id"] = "Orbit",
                                    ["enabled"] = true,
                                    ["params"] =
                                    {
                                        ["altitude"] = ctld.jtacDroneAltitude,
                                        ["pattern"]  = "Circle",
                                        ["speed"]    = 80,
                                    }, -- end of ["params"]
                                },     -- end of [2]
                                [3] =
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 3,
                                    ["params"] =
                                    {
                                        ["action"] =
                                        {
                                            ["id"] = "Option",
                                            ["params"] =
                                            {
                                                ["value"] = true,
                                                ["name"] = 6,
                                            }, -- end of ["params"]
                                        },     -- end of ["action"]
                                    },         -- end of ["params"]
                                },             -- end of [3]
                            },                 -- end of ["tasks"]
                        },                     -- end of ["params"]
                    },                         -- end of ["task"]
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = _positions[1].z,
                    ["x"] = _positions[1].x,
                    ["speed_locked"] = true,
                    ["formation_template"] = "",
                }, -- end of [1]
            },     -- end of ["points"]
        }          -- end of ["route"]
        ---------------------------------------------------------------------------------
        _group.route = DroneRoute
    end

    _group.country = _heli:getCountry()
    local _spawnedGroup = Group.getByName(CTLD_extAPI.dynAdd("ctld.spawnCrateGroup_old()", _group).name)
    return _spawnedGroup
end ]] --#region

function ctld.spawnCrateGroup(_heli, _positions, _types, _hdgs)
    --ctld.logTrace("_heli      =  %s", ctld.p(_heli))
    --ctld.logTrace("_positions =  %s", ctld.p(_positions))
    --ctld.logTrace("_types     =  %s", ctld.p(_types))
    --ctld.logTrace("_hdgs      =  %s", ctld.p(_hdgs))

    local _id = ctld.getNextGroupId()
    local _groupName = _types[1] .. "    #" .. _id
    local _side = _heli:getCoalition()
    local _group = {
        ["visible"]    = false,
        ["groupId"]    = _id,
        ["hidden"]     = false,
        ["units"]      = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"]       = _groupName,
        ["tasks"]      = {},
        ["radioSet"]   = false,
        ["task"]       = "Reconnaissance",
        ["route"]      = {},
        ["start_time"] = 0,
    }
    local _hdg = 120 * math.pi / 180 -- radians = 120 degrees

    --------------------------------------------------------------------------------------
    if true then -- disable scene crates for now
        --if ctld.scene.SceneModels[_types[1]] == nil then -- if DCS standard typeName
        local _spreadMin = 5
        local _spreadMax = 5
        local _spreadMult = 1
        for _i, _pos in ipairs(_positions) do
            local _unitId = ctld.getNextUnitId()
            local _details = {
                type = _types[_i],
                unitId = _unitId,
                name = string.format("Unpacked %s #%i", _types[_i], _unitId)
            }
            --ctld.logTrace("Group._details =  %s", ctld.p(_details))
            if _hdgs and _hdgs[_i] then
                _hdg = _hdgs[_i]
            end
            local _unit_x = _pos.x + math.random(_spreadMin, _spreadMax) * _spreadMult
            local _unit_y = _pos.z + math.random(_spreadMin, _spreadMax) * _spreadMult

            local _unit_speed = 0
            local _unit_alt = _pos.y
            if _types[_i] ~= "MQ-9 Reaper" and _types[_i] ~= "RQ-1A Predator" then
                _unit_alt = nil
                _unit_speed = nil
            else                 -- for drones
                _unit_alt = 4000 --meters
                _unit_speed = 54 -- kts
            end

            _group.units[_i] = ctld.createUnit(_unit_x, _unit_y, _hdg, _details, _unit_alt, _unit_speed)
            _group.units[_i].speed = 54
        end
        if _types[1] ~= "MQ-9 Reaper" and _types[1] ~= "RQ-1A Predator" then
            _group.speed = _group.units[1].speed
            _group.category = Group.Category.GROUND
        else
            _group.category = Group.Category.AIRPLANE -- for drones
            _group.communication = true
            _group.frequency = 124
            _group.route = {
                ["points"] =
                {
                    [1] =
                    {
                        ["alt"] = _group.units[1].alt,
                        ["action"] = "Turning Point",
                        ["alt_type"] = "BARO",
                        ["properties"] = { ["addopt"] = {},
                        }
                        , -- end of ["properties"]
                        ["speed"] = _group.speed,
                        ["task"] =
                        {
                            ["id"] = "ComboTask",
                            ["params"] =
                            {
                                ["tasks"] =
                                {
                                    [1] = {
                                        ["number"] = 1,
                                        ["auto"] = true,
                                        ["id"] = "WrappedAction",
                                        ["enabled"] = true,
                                        ["params"] =
                                        {
                                            ["action"] = {
                                                ["id"] = "EPLRS",
                                                ["params"] = {
                                                    ["value"] = true,
                                                    ["groupId"] = _group.groupId,
                                                },
                                            },
                                        },
                                    },
                                    [2] = {
                                        ["number"] = 2,
                                        ["auto"] = false,
                                        ["id"] = "Orbit",
                                        ["enabled"] = true,
                                        ["params"] = {
                                            ["altitude"] = _group.units[1].alt,
                                            ["pattern"] = "Circle",
                                            ["speed"] = _group.speed,
                                        },
                                    },
                                },
                            },
                        },
                        ["type"] = "Turning Point",
                        ["ETA"] = 0,
                        ["ETA_locked"] = true,
                        ["y"] = _group.units[1].y,
                        ["x"] = _group.units[1].x,
                        ["speed_locked"] = true,
                        ["formation_template"] = "",
                    },
                },
            }
        end

        _group.country = _heli:getCountry()
        local _spawnedGroup = Group.getByName(CTLD_extAPI.dynAdd("ctld.spawnCrateGroup()", _group).name)
        return _spawnedGroup
    else -- if scene crate requested
        return ctld.scene.playScene(_heli, ctld.scene.SceneModels[_types[1]])
    end
end

-- spawn normal group
function ctld.spawnDroppedGroup(_point, _details, _spawnBehind, _maxSearch)
    local _groupName = _details.groupName

    local _group = {
        ["visible"] = false,
        --    ["groupId"] = _details.groupId,
        ["hidden"] = false,
        ["units"] = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["task"] = {},
    }


    if _spawnBehind == false then
        -- spawn in circle around heli

        local _pos = _point

        for _i, _detail in ipairs(_details.units) do
            local _angle = math.pi * 2 * (_i - 1) / #_details.units
            local _xOffset = math.cos(_angle) * 30
            local _yOffset = math.sin(_angle) * 30

            _group.units[_i] = ctld.createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _detail)
        end
    else
        local _pos     = _point

        --try to spawn at 6 oclock to us
        local _angle   = math.atan(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * -30
        local _yOffset = math.sin(_angle) * -30


        for _i, _detail in ipairs(_details.units) do
            _group.units[_i] = ctld.createUnit(_pos.x + (_xOffset + 10 * _i), _pos.z + (_yOffset + 10 * _i), _angle,
                _detail)
        end
    end

    --switch to MIST
    _group.category = Group.Category.GROUND;
    _group.country = _details.country;

    local _spawnedGroup = Group.getByName(CTLD_extAPI.dynAdd("ctld.spawnDroppedGroup()", _group).name)

    --local _spawnedGroup = coalition.addGroup(_details.country, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    if _maxSearch == nil then
        _maxSearch = ctld.maximumSearchDistance
    end

    local _wpZone = ctld.inWaypointZone(_point, _spawnedGroup:getCoalition())

    if _wpZone.inZone then
        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _wpZone.point)
        env.info("Heading to waypoint - In Zone " .. _wpZone.name)
    else
        local _enemyPos = ctld.findNearestEnemy(_details.loadTroops, _point, _maxSearch)

        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _enemyPos)
    end

    return _spawnedGroup
end

function ctld.findNearestEnemy(_side, _point, _searchDistance)
    local _closestEnemy = nil

    local _groups

    local _closestEnemyDist = _searchDistance

    local _heliPoint = _point

    if _side == 2 then
        _groups = coalition.getGroups(1, Group.Category.GROUND)
    else
        _groups = coalition.getGroups(2, Group.Category.GROUND)
    end

    for _, _group in pairs(_groups) do
        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        _leader = _units[x]
                        break
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestEnemyDist then
                        _closestEnemyDist = _dist
                        _closestEnemy = _leaderPos
                    end
                end
            end
        end
    end


    -- no enemy - move to random point
    if _closestEnemy ~= nil then
        -- env.info("found enemy")
        return _closestEnemy
    else
        local _x = _heliPoint.x + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _z = _heliPoint.z + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _y = _heliPoint.y + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)

        return { x = _x, z = _z, y = _y }
    end
end

function ctld.findNearestGroup(_heli, _groups)
    local _closestGroupDetails = {}
    local _closestGroup = nil

    local _closestGroupDist = ctld.maxExtractDistance

    local _heliPoint = _heli:getPoint()

    for _, _groupName in pairs(_groups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                local _groupDetails = {
                    groupId = _group:getID(),
                    groupName = _group:getName(),
                    side = _group
                        :getCoalition(),
                    units = {}
                }

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        if _leader == nil then
                            _leader = _units[x]
                            -- set country based on leader
                            _groupDetails.country = _leader:getCountry()
                        end

                        local _unitDetails = {
                            type = _units[x]:getTypeName(),
                            unitId = _units[x]:getID(),
                            name = _units
                                [x]:getName()
                        }

                        table.insert(_groupDetails.units, _unitDetails)
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestGroupDist then
                        _closestGroupDist = _dist
                        _closestGroupDetails = _groupDetails
                        _closestGroup = _group
                    end
                end
            end
        end
    end


    if _closestGroup ~= nil then
        return { group = _closestGroup, details = _closestGroupDetails }
    else
        return nil
    end
end

function ctld.createUnit(_x, _y, _angle, _details, _altitude, _speed)
    local _alt_type = "BARO"
    local _payload = {}
    local _callsign = {
        [1] = 7,
        [2] = 1,
        ["name"] = "Chevy11",
        [3] = 1,
    }
    if _altitude == nil then
        _alt_type = nil
        _speed = nil
        _payload = nil
        _callsign = nil
    end
    local _newUnit = {
        ["alt"] = _altitude,
        ["alt_type"] = _alt_type,
        ["speed"] = _speed,
        ["payload"] = _payload,
        ["callsign"] = _callsign,
        ["y"] = _y,
        ["type"] = _details.type,
        ["name"] = _details.name,
        --    ["unitId"] = _details.unitId,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function ctld.addEWRTask(_group)
    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_ewrGroup)
        local _grp = ctld.getAliveGroup(_ewrGroup)

        if _grp ~= nil then
            local _controller = _grp:getController();
            local _EWR = {
                id = 'EWR',
                auto = true,
                params = {
                }
            }
            _controller:setTask(_EWR)
        end
    end
    , _group:getName(), timer.getTime() + 2)
end

function ctld.orderGroupToMoveToPoint(_leader, _destination)
    local _group = _leader:getGroup()

    local _path = {}
    table.insert(_path, ctld.utils.buildWP("ctld.orderGroupToMoveToPoint()", _leader:getPoint(), 'Off Road', 50))
    table.insert(_path, ctld.utils.buildWP("ctld.orderGroupToMoveToPoint()", _destination, 'Off Road', 50))

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points = _path
            },
        },
    }


    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_arg)
        local _grp = ctld.getAliveGroup(_arg[1])

        if _grp ~= nil then
            local _controller = _grp:getController();
            Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
            Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            _controller:setTask(_arg[2])
        end
    end
    , { _group:getName(), _mission }, timer.getTime() + 2)
end

-- are we in pickup zone
function ctld.inPickupZone(_heli)
    if ctld.inAir(_heli) then
        return { inZone = false, limit = -1, index = -1 }
    end

    local _heliPoint = _heli:getPoint()

    for _i, _zoneDetails in pairs(ctld.pickupZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone == nil then
            local _ship = ctld.getTransportUnit(_zoneDetails[1])

            if _ship then
                local _point = _ship:getPoint()
                _triggerZone = {}
                _triggerZone.point = _point
                _triggerZone.radius = 200 -- should be big enough for ship
            end
        end

        if _triggerZone ~= nil then
            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)
            if _dist <= _triggerZone.radius then
                local _heliCoalition = _heli:getCoalition()
                if _zoneDetails[4] == 1 and (_zoneDetails[5] == _heliCoalition or _zoneDetails[5] == 0) then
                    return { inZone = true, limit = _zoneDetails[3], index = _i }
                end
            end
        end
    end

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do
        --get distance to center

        local _dist = ctld.getDistance(_heliPoint, _fob:getPoint())

        if _dist <= 150 then
            return { inZone = true, limit = 10000, index = -1 };
        end
    end



    return { inZone = false, limit = -1, index = -1 };
end

function ctld.getSpawnedFobs(_heli)
    local _fobs = {}

    for _, _fobName in ipairs(ctld.builtFOBS) do
        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getCoalition() == _heli:getCoalition() and _fob:getLife() > 0 then
            table.insert(_fobs, _fob)
        end
    end

    return _fobs
end

-- are we in a dropoff zone
function ctld.inDropoffZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.dropOffZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil and (_zoneDetails[3] == _heli:getCoalition() or _zoneDetails[3] == 0) then
            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    return false
end

-- are we in a waypoint zone
function ctld.inWaypointZone(_point, _coalition)
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --right coalition and active?
        if _triggerZone ~= nil and (_zoneDetails[4] == _coalition or _zoneDetails[4] == 0) and _zoneDetails[3] == 1 then
            --get distance to center

            local _dist = ctld.getDistance(_point, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return { inZone = true, point = _triggerZone.point, name = _zoneDetails[1] }
            end
        end
    end

    return { inZone = false }
end

-- are we near friendly logistics zone
function ctld.inLogisticsZone(_heli)
    --ctld.logDebug("ctld.inLogisticsZone(), _heli = %s", ctld.p(_heli))

    if ctld.inAir(_heli) then
        return false
    end
    local _heliPoint = _heli:getPoint()
    ctld.logDebug("_heliPoint = %s", ctld.p(_heliPoint))
    for _, _name in pairs(ctld.logisticUnits) do
        ctld.logDebug("_name = %s", ctld.p(_name))
        local _logistic = StaticObject.getByName(_name)
        if not _logistic then
            _logistic = Unit.getByName(_name)
        end
        ctld.logDebug("_logistic = %s", ctld.p(_logistic))
        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() and _logistic:getLife() > 0 then
            --get distance
            local _dist = ctld.getDistance(_heliPoint, _logistic:getPoint())
            if _dist <= ctld.maximumDistanceLogistic then
                return true
            end
        end
    end

    return false
end

-- are far enough from a friendly logistics zone
function ctld.farEnoughFromLogisticZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    local _farEnough = true

    for _, _name in pairs(ctld.logisticUnits) do
        local _logistic = StaticObject.getByName(_name)

        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() then
            --get distance
            local _dist = ctld.getDistance(_heliPoint, _logistic:getPoint())
            -- env.info("DIST ".._dist)
            if _dist <= ctld.minimumDeployDistance then
                -- env.info("TOO CLOSE ".._dist)
                _farEnough = false
            end
        end
    end

    return _farEnough
end

function ctld.refreshSmoke()
    if ctld.disableAllSmoke == true then
        return
    end

    for _, _zoneGroup in pairs({ ctld.pickupZones, ctld.dropOffZones }) do
        for _, _zoneDetails in pairs(_zoneGroup) do
            local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

            if _triggerZone == nil then
                local _ship = ctld.getTransportUnit(_triggerZone)

                if _ship then
                    local _point = _ship:getPoint()
                    _triggerZone = {}
                    _triggerZone.point = _point
                end
            end


            --only trigger if smoke is on AND zone is active
            if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[4] == 1 then
                -- Trigger smoke markers

                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end

    --waypoint zones
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --only trigger if smoke is on AND zone is active
        if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[3] == 1 then
            -- Trigger smoke markers

            local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
            local _alt = land.getHeight(_pos2)
            local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

            trigger.action.smoke(_pos3, _zoneDetails[2])
        end
    end


    --refresh in 5 minutes
    timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 300)
end

function ctld.dropSmoke(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil then
        local _colour = ""

        if _args[2] == trigger.smokeColor.Red then
            _colour = "RED"
        elseif _args[2] == trigger.smokeColor.Blue then
            _colour = "BLUE"
        elseif _args[2] == trigger.smokeColor.Green then
            _colour = "GREEN"
        elseif _args[2] == trigger.smokeColor.Orange then
            _colour = "ORANGE"
        end

        local _point = _heli:getPoint()

        local _pos2 = { x = _point.x, y = _point.z }
        local _alt = land.getHeight(_pos2)
        local _pos3 = { x = _point.x, y = _alt, z = _point.z }

        trigger.action.smoke(_pos3, _args[2])

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 dropped %2 smoke.", ctld.getPlayerNameOrType(_heli), _colour), 10)
    end
end

function ctld.unitCanCarryVehicles(_unit)
    local _type = string.lower(_unit:getTypeName())

    for _, _name in ipairs(ctld.vehicleTransportEnabled) do
        local _nameLower = string.lower(_name)
        if string.find(_type, _nameLower, 1, true) then
            return true
        end
    end

    return false
end

function ctld.unitDynamicCargoCapable(_unit)
    local cache = {}
    local _type = string.lower(_unit:getTypeName())
    local result = cache[_type]
    if result == nil then
        result = false
        --ctld.logDebug("ctld.unitDynamicCargoCapable(_type=[%s])", ctld.p(_type))
        for _, _name in ipairs(ctld.dynamicCargoUnits) do
            local _nameLower = string.lower(_name)
            if string.find(_type, _nameLower, 1, true) then --string.match does not work with patterns containing '-' as it is a magic character
                result = true
                break
            end
        end
        cache[_type] = result
    end
    return result
end

function ctld.isJTACUnitType(_type)
    if _type then
        _type = string.lower(_type)
        for _, _name in ipairs(ctld.jtacUnitTypes) do
            local _nameLower = string.lower(_name)
            if string.match(_type, _nameLower) then
                return true
            end
        end
    end
    return false
end

function ctld.updateZoneCounter(_index, _diff)
    if ctld.pickupZones[_index] ~= nil then
        ctld.pickupZones[_index][3] = ctld.pickupZones[_index][3] + _diff

        if ctld.pickupZones[_index][3] < 0 then
            ctld.pickupZones[_index][3] = 0
        end

        if ctld.pickupZones[_index][6] ~= nil then
            trigger.action.setUserFlag(ctld.pickupZones[_index][6], ctld.pickupZones[_index][3])
        end
        --    env.info(ctld.pickupZones[_index][1].." = " ..ctld.pickupZones[_index][3])
    end
end

function ctld.processCallback(_callbackArgs)
    for _, _callback in pairs(ctld.callbacks) do
        local _status, _result = pcall(function()
            _callback(_callbackArgs)
        end)

        if (not _status) then
            env.error(string.format("CTLD Callback Error: %s", _result))
        end
    end
end

-- checks the status of all AI troop carriers and auto loads and unloads troops
-- as long as the troops are on the ground
function ctld.checkAIStatus()
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 2)


    for _, _unitName in pairs(ctld.transportPilotNames) do
        local status, error = pcall(function()
            local _unit = ctld.getTransportUnit(_unitName)

            -- no player name means AI!
            if _unit ~= nil and _unit:getPlayerName() == nil then
                local _zone = ctld.inPickupZone(_unit)
                --    env.error("Checking.. ".._unit:getName())
                if _zone.inZone == true and not ctld.troopsOnboard(_unit, true) then
                    --     env.error("in zone, loading.. ".._unit:getName())

                    if ctld.allowRandomAiTeamPickups == true then
                        -- Random troop pickup implementation
                        local _team = nil
                        if _unit:getCoalition() == 1 then
                            _team = math.floor((math.random(#ctld.redTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.redTeams[_team]], true })
                        else
                            _team = math.floor((math.random(#ctld.blueTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.blueTeams[_team]], true })
                        end
                    else
                        ctld.loadTroopsFromZone({ _unitName, true, "", true })
                    end
                elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, true) then
                    --         env.error("in dropoff zone, unloading.. ".._unit:getName())
                    ctld.unloadTroops({ _unitName, true })
                end

                if ctld.unitCanCarryVehicles(_unit) then
                    if _zone.inZone == true and not ctld.troopsOnboard(_unit, false) then
                        ctld.loadTroopsFromZone({ _unitName, false, "", true })
                    elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, false) then
                        ctld.unloadTroops({ _unitName, false })
                    end
                end
            end
        end)

        if (not status) then
            env.error(string.format("Error with ai status: %s", error), false)
        end
    end
end

function ctld.getTransportLimit(_unitType)
    if ctld.unitLoadLimits[_unitType] then
        return ctld.unitLoadLimits[_unitType]
    end

    return ctld.numberOfTroops
end

function ctld.getUnitActions(_unitType)
    if ctld.unitActions[_unitType] then
        return ctld.unitActions[_unitType]
    end

    return { crates = true, troops = true }
end

-- Adds menuitem to a human unit
function ctld.addTransportF10MenuOptions(_unitName)
    ctld.logDebug("ctld.addTransportF10MenuOptions(_unitName=[%s])", ctld.p(_unitName))
    local _unit = ctld.getTransportUnit(_unitName)
    ctld.logTrace("_unit = %s", ctld.p(_unit))

    if _unit then
        local _unitTypename = _unit:getTypeName()
        local _groupId = ctld.getGroupId(_unit)
        if _groupId then
            -- ctld.logTrace("_groupId = %s", ctld.p(_groupId))
            -- ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo[tostring(_groupId)]))
            if ctld.addedTo[tostring(_groupId)] == nil then
                ctld.logTrace("adding CTLD menu for _groupId = %s", ctld.p(_groupId))
                local _rootPath = missionCommands.addSubMenuForGroup(_groupId, ctld.i18n_translate("CTLD"))
                local _unitActions = ctld.getUnitActions(_unitTypename)
                missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Check Cargo"), _rootPath,
                    ctld.checkTroopStatus, { _unitName })
                if _unitActions.troops then
                    local _troopCommandsPath = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Troop Transport"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unload / Extract Troops"),
                        _troopCommandsPath, ctld.unloadExtractTroops, { _unitName })

                    -- local _loadPath = missionCommands.addSubMenuForGroup(_groupId, "Load From Zone", _troopCommandsPath)
                    local _transportLimit = ctld.getTransportLimit(_unitTypename)
                    local itemNb = 0
                    local menuEntries = {}
                    local menuPath = _troopCommandsPath
                    for _, _loadGroup in pairs(ctld.loadableGroups) do
                        if not _loadGroup.side or _loadGroup.side == _unit:getCoalition() then
                            -- check size & unit
                            if _transportLimit >= _loadGroup.total then
                                table.insert(menuEntries,
                                    { text = ctld.i18n_translate("Load ") .. _loadGroup.name, group = _loadGroup })
                            end
                        end
                    end
                    for _i, _menu in ipairs(menuEntries) do
                        -- add the menu item
                        itemNb = itemNb + 1
                        if itemNb == 9 and _i < #menuEntries then -- page limit reached (first item is "unload")
                            menuPath = missionCommands.addSubMenuForGroup(_groupId, ctld.i18n_translate("Next page"),
                                menuPath)
                            itemNb = 1
                        end
                        missionCommands.addCommandForGroup(_groupId, _menu.text, menuPath, ctld.loadTroopsFromZone,
                            { _unitName, true, _menu.group, false })
                    end
                    if ctld.unitCanCarryVehicles(_unit) then
                        local _vehicleCommandsPath = missionCommands.addSubMenuForGroup(_groupId,
                            ctld.i18n_translate("Vehicle / FOB Transport"), _rootPath)
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unload Vehicles"),
                            _vehicleCommandsPath, ctld.unloadTroops, { _unitName, false })
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Load / Extract Vehicles"),
                            _vehicleCommandsPath, ctld.loadTroopsFromZone, { _unitName, false, "", true })

                        if ctld.enabledFOBBuilding and ctld.staticBugWorkaround == false then
                            missionCommands.addCommandForGroup(_groupId,
                                ctld.i18n_translate("Load / Unload FOB Crate"), _vehicleCommandsPath,
                                ctld.loadUnloadFOBCrate, { _unitName, false })
                        end
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Check Cargo"),
                            _vehicleCommandsPath, ctld.checkTroopStatus, { _unitName })
                    end
                end

                if ctld.enableCrates and _unitActions.crates then
                    if ctld.unitCanCarryVehicles(_unit) == false then
                        -- sort the crate categories alphabetically
                        local crateCategories = {}
                        for category, _ in pairs(ctld.spawnableCrates) do
                            table.insert(crateCategories, category)
                        end
                        table.sort(crateCategories)
                        --ctld.logTrace("crateCategories = [%s]", ctld.p(crateCategories))

                        -- add menu for spawning crates
                        local itemNbMain = 0
                        local _cratesMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                            ctld.i18n_translate("Crates: Vehicle / FOB / Drone"), _rootPath)

                        for _i, _category in ipairs(crateCategories) do
                            local _subMenuName = _category
                            local _crates = ctld.spawnableCrates[_subMenuName]

                            -- add the submenu item
                            itemNbMain = itemNbMain + 1
                            if itemNbMain == 10 and _i < #crateCategories then -- page limit reached
                                _cratesMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                                    ctld.i18n_translate("Next page"), _cratesMenuPath)
                                itemNbMain = 1
                            end
                            local itemNbSubmenu = 0
                            local menuEntries = {}
                            local _subMenuPath = missionCommands.addSubMenuForGroup(_groupId, _subMenuName,
                                _cratesMenuPath)
                            for _, _crate in pairs(_crates) do
                                --ctld.logTrace("_crate = [%s]", ctld.p(_crate))
                                if not (_crate.multiple) or ctld.enableAllCrates then
                                    local isJTAC = ctld.isJTACUnitType(_crate.unit)
                                    --ctld.logTrace("isJTAC = [%s]", ctld.p(isJTAC))
                                    if not isJTAC or (isJTAC and ctld.JTAC_dropEnabled) then
                                        if _crate.side == nil or (_crate.side == _unit:getCoalition()) then
                                            local _crateRadioMsg = _crate.desc
                                            --add in the number of crates required to build something
                                            if _crate.cratesRequired ~= nil and _crate.cratesRequired > 1 then
                                                _crateRadioMsg = _crateRadioMsg .. " (" .. _crate.cratesRequired ..
                                                    ")"
                                            end
                                            if _crate.multiple then
                                                _crateRadioMsg = "* " .. _crateRadioMsg
                                            end
                                            local _menuEntry = { text = _crateRadioMsg, crate = _crate }
                                            --ctld.logTrace("_menuEntry = [%s]", ctld.p(_menuEntry))
                                            table.insert(menuEntries, _menuEntry)
                                        end
                                    end
                                end
                            end
                            for _i, _menu in ipairs(menuEntries) do
                                --ctld.logTrace("_menu = [%s]", ctld.p(_menu))
                                -- add the submenu item
                                itemNbSubmenu = itemNbSubmenu + 1
                                if itemNbSubmenu == 10 and _i < #menuEntries then -- page limit reached
                                    _subMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                                        ctld.i18n_translate("Next page"), _subMenuPath)
                                    itemNbSubmenu = 1
                                end
                                missionCommands.addCommandForGroup(_groupId, _menu.text, _subMenuPath,
                                    ctld.spawnCrate, { _unitName, _menu.crate.weight })
                            end
                        end
                    end
                end

                if (ctld.enabledFOBBuilding or ctld.enableCrates) and _unitActions.crates then
                    local _crateCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("CTLD Commands"), _rootPath)
                    if ctld.vehicleCommandsPath[_unitName] == nil then
                        ctld.vehicleCommandsPath[_unitName] = ctld.utils.deepCopy(
                            "ctld.addTransportF10MenuOptions()", _crateCommands)
                    end
                    if ctld.hoverPickup == false or ctld.loadCrateFromMenu == true then
                        if ctld.loadCrateFromMenu then
                            missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Load Nearby Crate(s)"),
                                _crateCommands, ctld.loadNearbyCrate, _unitName)
                        end
                    end

                    if ctld.loadCrateFromMenu or ctld.hoverPickup then
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Crate(s)"),
                            _crateCommands, ctld.dropSlingCrate, { _unitName })
                    end

                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unpack Any Crate"),
                        _crateCommands, ctld.unpackCrates, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Nearby Crates"),
                        _crateCommands, ctld.listNearbyCrates, { _unitName })

                    if ctld.enabledFOBBuilding then
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List FOBs"), _crateCommands,
                            ctld.listFOBS, { _unitName })
                    end

                    if ctld.enableRepackingVehicles == true then
                        ctld.updateRepackMenu(_unitName) -- add repack menu
                    end
                end

                if ctld.enableSmokeDrop then
                    local _smokeMenu = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Smoke Markers"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Red Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Blue Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Orange Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Green Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
                end

                if ctld.enabledRadioBeaconDrop then
                    local _radioCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Radio Beacons"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Beacons"), _radioCommands,
                        ctld.listRadioBeacons, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Beacon"), _radioCommands,
                        ctld.dropRadioBeacon, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Remove Closest Beacon"),
                        _radioCommands, ctld.removeRadioBeacon, { _unitName })
                elseif ctld.deployedRadioBeacons ~= {} then
                    local _radioCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Radio Beacons"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Beacons"), _radioCommands,
                        ctld.listRadioBeacons, { _unitName })
                end

                ctld.addedTo[tostring(_groupId)] = true
                ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo))
                ctld.logTrace("done adding CTLD menu for _groupId = %s", ctld.p(_groupId))
            end
        end
    end
end

--******************************************************************************************************
function ctld.buildPaginatedMenu(_menuEntries) --[[ params table :
                                                    { text        = command name menu
                                                    groupId       = playerUnit groupId,
                                                    subMenuPath   = complet MenuPath clicked,
                                                    menuFunction  = function name to run on clicked menu,
                                                    menuArgsTable = table with arguments for the function to run,
                                                    }]]
    local nextSubMenuPath = {}
    local itemNbSubmenu   = 0
    for i, menu in ipairs(_menuEntries) do
        if #nextSubMenuPath ~= 0 then
            menu.subMenuPath = ctld.utils.deepCopy("ctld.buildPaginatedMenu()", nextSubMenuPath)
            --menu.subMenuPath = nextSubMenuPath
        end
        -- add the submenu item
        itemNbSubmenu = itemNbSubmenu + 1
        if itemNbSubmenu == 10 and i < #_menuEntries then -- page limit reached
            nextSubMenuPath = missionCommands.addSubMenuForGroup(menu.groupId, ctld.i18n_translate("Next page"),
                menu.subMenuPath)
            itemNbSubmenu   = 1
        end
        menu.menuArgsTable.subMenuPath      = ctld.utils.deepCopy("ctld.buildPaginatedMenu()", menu.subMenuPath) -- copy the table to avoid overwriting the same table in the next loop
        menu.menuArgsTable.subMenuLineIndex = itemNbSubmenu
        --ctld.logTrace("FG_ boucle[%s].groupId = %s", i, menu.groupId)
        --ctld.logTrace("FG_ boucle[%s].menu.text = %s", i, menu.text)
        --ctld.logTrace("FG_ boucle[%s].menu.subMenuPath = %s", i, menu.subMenuPath)
        --ctld.logTrace("FG_ boucle[%s].menu.menuFunction = %s", i, menu.menuFunction)
        local r                             = missionCommands.addCommandForGroup(menu.groupId, menu.text,
            menu.subMenuPath, menu.menuFunction,
            ctld.utils.deepCopy("ctld.buildPaginatedMenu()", menu.menuArgsTable))
        --ctld.logTrace("FG_ boucle[%s].r = %s", i, r)
        --ctld.logTrace("FG_ boucle[%s].menu.menuArgsTable =  %s", i, ctld.p(menu.menuArgsTable))
    end
end

--******************************************************************************************************
-- return true if  _typeUnitDesc already exist in _MenuEntriesTable
-- ex:  ctld.isUnitInrepackableVehicles(repackableTable, "Humvee - TOW")
function ctld.isUnitInMenuEntriesTable(_MenuEntriesTable, _typeUnitDesc)
    for i = 1, #_MenuEntriesTable do
        if _MenuEntriesTable[i].menuArgsTable.desc == _typeUnitDesc then
            return true
        end
    end
    return false
end

--******************************************************************************************************
function ctld.updateRepackMenu(_playerUnitName)
    local playerUnit = ctld.getTransportUnit(_playerUnitName)
    if playerUnit then
        local _groupId = ctld.getGroupId(playerUnit)
        if _groupId == nil then
            return
        end
        if ctld.enableRepackingVehicles then
            local repackableVehicles = ctld.getUnitsInRepackRadius(_playerUnitName,
                ctld.maximumDistanceRepackableUnitsSearch)
            if repackableVehicles then
                --ctld.logTrace("FG_ ctld.vehicleCommandsPath[_playerUnitName] = %s", ctld.p(ctld.vehicleCommandsPath[_playerUnitName]))
                local RepackPreviousMenu                    = ctld.utils.deepCopy("ctld.updateRepackMenu()",
                    ctld.vehicleCommandsPath
                    [_playerUnitName])
                local RepackCommandsPath                    = ctld.utils.deepCopy("ctld.updateRepackMenu()",
                    ctld.vehicleCommandsPath
                    [_playerUnitName])
                local repackSubMenuText                     = ctld.i18n_translate("Repack Vehicles")
                RepackCommandsPath[#RepackCommandsPath + 1] =
                    repackSubMenuText                                            -- add the submenu name to get the complet repack path
                --ctld.logTrace("FG_ RepackCommandsPath = %s", ctld.p(RepackCommandsPath))
                missionCommands.removeItemForGroup(_groupId, RepackCommandsPath) -- remove existing "Repack Vehicles" menu
                --ctld.logTrace("FG_ RepackCommandsPath = %s", ctld.p(RepackCommandsPath))
                --ctld.logTrace("FG_ repackableVehicles = %s", ctld.p(repackableVehicles))
                --ctld.logTrace("FG_ repackSubMenuText  = %s", ctld.p(repackSubMenuText))
                --ctld.logTrace("FG_ RepackPreviousMenu = %s", ctld.p(RepackPreviousMenu))
                local RepackMenuPath = missionCommands.addSubMenuForGroup(_groupId, repackSubMenuText, RepackPreviousMenu)
                local menuEntries = {}
                for i, _vehicle in ipairs(repackableVehicles) do
                    if ctld.isUnitInMenuEntriesTable(menuEntries, _vehicle.desc) == false then
                        _vehicle.playerUnitName = _playerUnitName
                        table.insert(menuEntries, {
                            text          = ctld.i18n_translate("repack ") .. _vehicle.unit,
                            groupId       = _groupId,
                            subMenuPath   = RepackMenuPath,
                            menuFunction  = ctld.repackVehicleRequest,
                            menuArgsTable = ctld.utils.deepCopy("ctld.updateRepackMenu()", _vehicle)
                        })
                    end
                end
                --ctld.logTrace("FG_ menuEntries = %s", ctld.p(menuEntries))
                ctld.buildPaginatedMenu(menuEntries)
            end
        end
    end
end

--******************************************************************************************************
function ctld.autoUpdateRepackMenu(p, t) -- auto update repack menus for each transport unit
    if t == nil then t = timer.getTime() end
    if p.reschedule == nil then p.reschedule = false end
    ctld.logTrace("FG_ ctld.autoUpdateRepackMenu.p.reschedule = %s", p.reschedule)
    if ctld.enableRepackingVehicles then
        for _, _unitName in pairs(ctld.transportPilotNames) do
            if ctld.vehicleCommandsPath[_unitName] ~= nil then
                local status, error = pcall(
                    function()
                        local _unit = ctld.getTransportUnit(_unitName)
                        if _unit then
                            -- if transport unit landed => update repack menus
                            if (ctld.inAir(_unit) == false or (ctld.heightDiff(_unit) <= 0.1 + 3.0 and ctld.utils.vec3Mag("ctld.autoUpdateRepackMenu()", _unit:getVelocity()) < 0.1)) then
                                local _unitTypename = _unit:getTypeName()
                                local _groupId = ctld.getGroupId(_unit)
                                if _groupId then
                                    if ctld.addedTo[tostring(_groupId)] ~= nil then -- if groupMenu on loaded => add RepackMenus
                                        ctld.updateRepackMenu(_unitName)
                                    end
                                end
                            end
                        end
                    end)
                if (not status) then
                    env.error(string.format("Error in ctld.autoUpdateRepackMenu : %s", error), false)
                end
            end
        end
    end
    if p.reschedule == true or p.reschedule == nil then
        return t + 5 -- reschedule every 5 seconds
    end
end

--******************************************************************************************************
function ctld.addOtherF10MenuOptions()
    --ctld.logDebug("ctld.addOtherF10MenuOptions")
    -- reschedule every 10 seconds
    timer.scheduleFunction(ctld.addOtherF10MenuOptions, nil, timer.getTime() + 10)
    local status, error = pcall(function()
        -- now do any player controlled aircraft that ARENT transport units
        if ctld.enabledRadioBeaconDrop then
            ctld.addRadioListCommand(2) -- get all BLUE players
            ctld.addRadioListCommand(1) -- get all RED players
        end

        if ctld.JTAC_jtacStatusF10 then
            ctld.addJTACRadioCommand(2) -- get all BLUE players
            ctld.addJTACRadioCommand(1) -- get all RED players
        end

        if ctld.reconF10Menu then
            ctld.addReconRadioCommand(2) -- get all BLUE players
            ctld.addReconRadioCommand(1) -- get all RED players
        end
    end)

    if (not status) then
        env.error(string.format("Error adding f10 to other players: %s", error), false)
    end
end

--add to all players that arent transport
function ctld.addRadioListCommand(_side)
    local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
            local _groupId = ctld.getGroupId(_playerUnit)

            if _groupId then
                --ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo))
                if ctld.addedTo[tostring(_groupId)] == nil then
                    ctld.logTrace("adding List Radio Beacons for _groupId = %s", ctld.p(_groupId))
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Radio Beacons"), nil,
                        ctld.listRadioBeacons, { _playerUnit:getName() })
                    ctld.addedTo[tostring(_groupId)] = true
                end
            end
        end
    end
end

function ctld.addJTACRadioCommand(_side)
    local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
            local _groupId = ctld.getGroupId(_playerUnit)

            if _groupId then
                local newGroup = false
                if ctld.jtacRadioAdded[tostring(_groupId)] == nil then
                    --ctld.logDebug("ctld.addJTACRadioCommand - adding JTAC radio menu for unit [%s]", ctld.p(_playerUnit:getName()))
                    newGroup = true
                    local JTACpath = missionCommands.addSubMenuForGroup(_groupId, ctld.jtacMenuName)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("JTAC Status"), JTACpath,
                        ctld.getJTACStatus, { _playerUnit:getName() })
                    ctld.jtacRadioAdded[tostring(_groupId)] = true
                end

                --fetch the time to check for a regular refresh
                local time = timer.getTime()

                --depending on the delay, this part of the radio menu will be refreshed less often or as often as the static JTAC status command, this is for better reliability for the user when navigating through the menus. New groups will get the lists regardless and if a new JTAC is added all lists will be refreshed regardless of the delay.
                if ctld.jtacLastRadioRefresh + ctld.jtacRadioRefreshDelay <= time or ctld.refreshJTACmenu[_side] or newGroup then
                    ctld.jtacLastRadioRefresh = time

                    --build the path to the CTLD JTAC menu
                    local jtacCurrentPagePath = { [1] = ctld.jtacMenuName }
                    --build the path for the NextPage submenu on the first page of the CTLD JTAC menu
                    local NextPageText = "Next Page"
                    local MainNextPagePath = { [1] = ctld.jtacMenuName, [2] = NextPageText }
                    --remove it along with everything that's in it
                    missionCommands.removeItemForGroup(_groupId, MainNextPagePath)

                    --counter to know when to add the next page submenu to fit all of the JTAC group submenus
                    local jtacCounter = 0

                    for _jtacGroupName, jtacUnit in pairs(ctld.jtacUnits) do
                        --ctld.logTrace(string.format("JTAC - MENU - [%s] - processing menu", ctld.p(_jtacGroupName)))

                        --if the JTAC is on the same team as the group being considered
                        local jtacCoalition = ctld.jtacUnits[_jtacGroupName].side
                        if jtacCoalition and jtacCoalition == _side then
                            --only bother removing the submenus on the first page of the CTLD JTAC menu as the other pages were deleted entirely above
                            if ctld.jtacGroupSubMenuPath[_jtacGroupName] and #ctld.jtacGroupSubMenuPath[_jtacGroupName] == 2 then
                                missionCommands.removeItemForGroup(_groupId, ctld.jtacGroupSubMenuPath[_jtacGroupName])
                            end
                            --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacTargetsList = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacTargetsList[_jtacGroupName])))
                            --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacCurrentTargets = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacCurrentTargets[_jtacGroupName])))

                            local jtacActionMenu = false
                            for _, _specialOptionTable in pairs(ctld.jtacSpecialOptions) do
                                if _specialOptionTable.globalToggle then
                                    jtacActionMenu = true
                                    break
                                end
                            end

                            --if JTAC has at least one other target in sight or (if special options are available (NOTE : accessed through the JTAC's own menu also) and the JTAC has at least one target)
                            if (ctld.jtacTargetsList[_jtacGroupName] and #ctld.jtacTargetsList[_jtacGroupName] >= 1) or (ctld.jtacCurrentTargets[_jtacGroupName] and jtacActionMenu) then
                                local jtacGroupSubMenuName = string.format(_jtacGroupName .. " Selection")

                                jtacCounter = jtacCounter + 1
                                --F2 through F10 makes 9 entries possible per page, with one being the NextMenu submenu. F1 is taken by JTAC status entry.
                                if jtacCounter % 9 == 0 then
                                    --recover the path to the current page with space available for JTAC group submenus
                                    jtacCurrentPagePath = missionCommands.addSubMenuForGroup(_groupId, NextPageText,
                                        jtacCurrentPagePath)
                                end
                                --add the JTAC group submenu to the current page
                                ctld.jtacGroupSubMenuPath[_jtacGroupName] = missionCommands.addSubMenuForGroup(_groupId,
                                    jtacGroupSubMenuName, jtacCurrentPagePath)
                                --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacGroupSubMenuPath = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacGroupSubMenuPath[_jtacGroupName])))

                                --make a copy of the JTAC group submenu's path to insert the target's list on as many pages as required. The JTAC's group submenu path only leads to the first page
                                local jtacTargetPagePath = ctld.utils.deepCopy("ctld.addJTACRadioCommand()",
                                    ctld.jtacGroupSubMenuPath[_jtacGroupName])

                                --counter to know when to add the next page submenu to fit all of the targets in the JTAC's group submenu. SMay not actually start at 0 due to static items being present on the first page
                                local itemCounter = 0
                                local jtacSpecialOptPagePath = nil

                                if jtacActionMenu then
                                    --special options
                                    local SpecialOptionsCounter = 0

                                    for _, _specialOption in pairs(ctld.jtacSpecialOptions) do
                                        if _specialOption.globalToggle then
                                            if not jtacSpecialOptPagePath then
                                                itemCounter = itemCounter +
                                                    1 --one item is added to the first JTAC target page
                                                jtacSpecialOptPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                    ctld.i18n_translate("Actions"), jtacTargetPagePath)
                                            end

                                            SpecialOptionsCounter = SpecialOptionsCounter + 1

                                            if SpecialOptionsCounter % 10 == 0 then
                                                jtacSpecialOptPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                    NextPageText, jtacSpecialOptPagePath)
                                                SpecialOptionsCounter = SpecialOptionsCounter +
                                                    1 --Added Next Page item
                                            end

                                            if _specialOption.jtacs then
                                                if _specialOption.jtacs[_jtacGroupName] then
                                                    missionCommands.addCommandForGroup(_groupId,
                                                        ctld.i18n_translate("DISABLE ") .. _specialOption.message,
                                                        jtacSpecialOptPagePath, _specialOption.setter,
                                                        { jtacGroupName = _jtacGroupName, value = false })
                                                else
                                                    missionCommands.addCommandForGroup(_groupId,
                                                        ctld.i18n_translate("ENABLE ") .. _specialOption.message,
                                                        jtacSpecialOptPagePath, _specialOption.setter,
                                                        { jtacGroupName = _jtacGroupName, value = true })
                                                end
                                            else
                                                missionCommands.addCommandForGroup(_groupId,
                                                    ctld.i18n_translate("REQUEST ") .. _specialOption.message,
                                                    jtacSpecialOptPagePath, _specialOption.setter,
                                                    { jtacGroupName = _jtacGroupName, value = false }) --value is not used here
                                            end
                                        end
                                    end
                                end

                                if #ctld.jtacTargetsList[_jtacGroupName] >= 1 then
                                    --ctld.logTrace(string.format("JTAC - MENU - [%s] - adding targets menu", ctld.p(_jtacGroupName)))

                                    --add a reset targeting option to revert to automatic JTAC unit targeting
                                    missionCommands.addCommandForGroup(_groupId,
                                        ctld.i18n_translate("Reset TGT Selection"), jtacTargetPagePath,
                                        ctld.setJTACTarget, { jtacGroupName = _jtacGroupName, targetName = nil })

                                    itemCounter = itemCounter +
                                        1 --one item is added to the first JTAC target page

                                    --indicator table to know which unitType was already added to the radio submenu
                                    local typeNameList = {}
                                    for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
                                        local targetName = target.unit:getName()
                                        --check if the jtac has a current target before filtering it out if possible
                                        if (ctld.jtacCurrentTargets[_jtacGroupName] and targetName ~= ctld.jtacCurrentTargets[_jtacGroupName].name) then
                                            local targetType_name = target.unit:getTypeName()

                                            if targetType_name then
                                                if typeNameList[targetType_name] then
                                                    typeNameList[targetType_name].amount = typeNameList[targetType_name]
                                                        .amount + 1
                                                else
                                                    typeNameList[targetType_name] = {}
                                                    typeNameList[targetType_name].targetName =
                                                        targetName --store the first targetName
                                                    typeNameList[targetType_name].amount = 1
                                                end
                                            end
                                        end
                                    end

                                    for typeName, info in pairs(typeNameList) do
                                        local amount = info.amount
                                        local targetName = info.targetName
                                        itemCounter = itemCounter + 1

                                        --F1 through F10 makes 10 entries possible per page, with one being the NextMenu submenu.
                                        if itemCounter % 10 == 0 then
                                            jtacTargetPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                NextPageText, jtacTargetPagePath)
                                            itemCounter = itemCounter +
                                                1 --added the next page item
                                        end

                                        missionCommands.addCommandForGroup(_groupId,
                                            string.format(typeName .. "(" .. amount .. ")"), jtacTargetPagePath,
                                            ctld.setJTACTarget,
                                            { jtacGroupName = _jtacGroupName, targetName = targetName })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if ctld.refreshJTACmenu[_side] then
            ctld.refreshJTACmenu[_side] = false
        end
    end
end

function ctld.getGroupId(_unit)
    local _unitDB = CTLD_extAPI.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    end

    return nil
end

--get distance in meters assuming a Flat world
function ctld.getDistance(_point1, _point2)
    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

------------ JTAC -----------

ctld.jtacMenuName = "JTAC" --name of the CTLD JTAC radio menu
ctld.jtacLaserPoints = {}
ctld.jtacIRPoints = {}
ctld.jtacSmokeMarks = {}
ctld.jtacUnits = {}          -- list of JTAC units for f10 command
ctld.jtacStop = {}           -- jtacs to tell to stop lasing
ctld.jtacCurrentTargets = {}
ctld.jtacTargetsList = {}    --current available targets to each JTAC for lasing (targets from other JTACs are filtered out). Contains DCS unit objects with their methods and the distance to the JTAC {unit, dist}
ctld.jtacSelectedTarget = {} --currently user selected target if it contains a unit's name, otherwise contains 1 or nil (if not initialized)
ctld.jtacSpecialOptions = {  --list which contains the status of special options for each jtac, ordered for them to show up in the correct order in the corresponding radio menu
    standbyMode = {          --#1
        globalToggle = ctld.JTAC_allowStandbyMode,
        message = "Standby Mode",
        setter = nil, --ctld.setStdbMode, will be set after declaration of said function
        jtacs = {
            --enable flag for each JTAC
        },
    },              --disable designation by the JTAC
    smokeMarker = { --#4
        globalToggle = ctld.JTAC_allowSmokeRequest,
        message = "Smoke on TGT",
        setter = nil,       --ctld.setSmokeOnTarget
    },                      --smoke marker on target
    laseSpotCorrections = { --#2
        globalToggle = ctld.JTAC_laseSpotCorrections,
        message = "Speed Corrections",
        setter = nil, --ctld.setLaseCompensation
        jtacs = {
            --enable flag for each JTAC
        },
    },         --target speed and wind compensation for laser spot
    _9Line = { --#3
        globalToggle = ctld.JTAC_allow9Line,
        message = "9 Line",
        setter = nil,             --ctld.setJTAC9Line
    },                            --9Line message for JTAC
}
ctld.jtacRadioAdded = {}          --keeps track of who's had the radio command added
ctld.jtacGroupSubMenuPath = {}    --keeps track of which submenu contains each JTAC's target selection menu
ctld.jtacRadioRefreshDelay = 120  --determines how often in seconds the dynamic parts of the jtac radio menu (target lists) will be refreshed
ctld.jtacLastRadioRefresh = 0     -- time at which the target lists were refreshed for everyone at least
ctld.refreshJTACmenu = {}         --indicator to know when a new JTAC is added to a coalition in order to rebuild the corresponding target lists
ctld.jtacGeneratedLaserCodes = {} -- keeps track of generated codes, cycles when they run out
ctld.jtacLaserPointCodes = {}
ctld.jtacRadioData = {}

--[[
        Called when a new JTAC is spawned, it will wait one second for DCS to have time to fill the group with units, and then call ctld.JTACAutoLase.

        The goal here is to correct a bug: when a group is respawned (i.e. when any group with the name of a previously existing group is spawned),
        DCS spawns a group which exists (Group.getByName gets a valid table, and group:isExist returns true), but has no units (i.e. group:getUnits returns an empty table).
        This causes JTACAutoLase to call cleanupJTAC because it does not find the JTAC unit, and the JTAC to be put out of the JTACAutoLase loop, and never processed again.
        By waiting a bit, the group gets populated before JTACAutoLase is called, hence avoiding a trip to cleanupJTAC.
]]
function ctld.JTACStart(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    timer.scheduleFunction(ctld.JTACAutoLase,
        { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
        timer.getTime() + 1)
end

function ctld.JTACAutoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    --ctld.logDebug(string.format("ctld.JTACAutoLase(_jtacGroupName=%s, _laserCode=%s", ctld.p(_jtacGroupName), ctld.p(_laserCode)))
    local _radio = _radio
    if not _radio then
        _radio = {}
        if _laserCode then
            local _laserCode = tonumber(_laserCode)
            if _laserCode and _laserCode >= 1111 and _laserCode <= 1688 then
                local _laserB = math.floor((_laserCode - 1000) / 100)
                local _laserCD = _laserCode - 1000 - _laserB * 100
                local _frequency = tostring(30 + _laserB + _laserCD * 0.05)
                --ctld.logTrace(string.format("_laserB=%s", ctld.p(_laserB)))
                --ctld.logTrace(string.format("_laserCD=%s", ctld.p(_laserCD)))
                --ctld.logTrace(string.format("_frequency=%s", ctld.p(_frequency)))
                _radio.freq = _frequency
                _radio.mod = "fm"
            end
        end
    end

    if _radio and not _radio.name then
        _radio.name = _jtacGroupName
    end

    if ctld.jtacStop[_jtacGroupName] == true then
        ctld.jtacStop[_jtacGroupName] = nil -- allow it to be started again
        ctld.cleanupJTAC(_jtacGroupName)
        return
    end

    if _lock == nil then
        _lock = ctld.JTAC_lock
    end

    ctld.jtacLaserPointCodes[_jtacGroupName] = _laserCode
    ctld.jtacRadioData[_jtacGroupName] = _radio

    local _jtacGroup = ctld.getGroup(_jtacGroupName)
    local _jtacUnit

    if _jtacGroup == nil or #_jtacGroup == 0 then
        --check not in a heli
        if ctld.inTransitTroops then
            for _, _onboard in pairs(ctld.inTransitTroops) do
                if _onboard ~= nil then
                    if _onboard.troops ~= nil and _onboard.troops.groupName ~= nil and _onboard.troops.groupName == _jtacGroupName then
                        --jtac soldier being transported by heli
                        ctld.cleanupJTAC(_jtacGroupName)

                        ctld.logTrace(string.format(
                            "JTAC - LASE - [%s] - in transport, waiting - scheduling JTACAutoLase in %ss at %s",
                            ctld.p(_jtacGroupName), ctld.p(10), ctld.p(timer.getTime() + 10)))
                        timer.scheduleFunction(ctld.timerJTACAutoLase,
                            { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio }, timer.getTime() + 10)
                        return
                    end

                    if _onboard.vehicles ~= nil and _onboard.vehicles.groupName ~= nil and _onboard.vehicles.groupName == _jtacGroupName then
                        --jtac vehicle being transported by heli
                        ctld.cleanupJTAC(_jtacGroupName)

                        ctld.logTrace(string.format(
                            "JTAC - LASE - [%s] - in transport, waiting - scheduling JTACAutoLase in %ss at %s",
                            ctld.p(_jtacGroupName), ctld.p(10), ctld.p(timer.getTime() + 10)))
                        timer.scheduleFunction(ctld.timerJTACAutoLase,
                            { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio }, timer.getTime() + 10)
                        return
                    end
                end
            end
        end

        if ctld.jtacUnits[_jtacGroupName] ~= nil then
            ctld.notifyCoalition(ctld.i18n_translate("JTAC Group %1 KIA!", _jtacGroupName), 10,
                ctld.jtacUnits[_jtacGroupName].side, _radio)
        end

        --remove from list
        ctld.cleanupJTAC(_jtacGroupName)

        return
    else
        _jtacUnit = _jtacGroup[1]
        local _jtacCoalition = _jtacUnit:getCoalition()
        --add to list
        ctld.jtacUnits[_jtacGroupName] = { name = _jtacUnit:getName(), side = _jtacCoalition, radio = _radio }

        --Targets list, special options and Selected target initialization
        if not ctld.jtacTargetsList[_jtacGroupName] then
            --Target list
            ctld.jtacTargetsList[_jtacGroupName] = {}
            if _jtacCoalition then ctld.refreshJTACmenu[_jtacCoalition] = true end

            --Special Options
            for _, _specialOption in pairs(ctld.jtacSpecialOptions) do
                if _specialOption.jtacs then
                    _specialOption.jtacs[_jtacGroupName] = false
                end
            end
        end

        if not ctld.jtacSelectedTarget[_jtacGroupName] then
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
        end

        -- work out smoke colour
        if _colour == nil then
            if _jtacUnit:getCoalition() == 1 then
                _colour = ctld.JTAC_smokeColour_RED
            else
                _colour = ctld.JTAC_smokeColour_BLUE
            end
        end


        if _smoke == nil then
            if _jtacUnit:getCoalition() == 1 then
                _smoke = ctld.JTAC_smokeOn_RED
            else
                _smoke = ctld.JTAC_smokeOn_BLUE
            end
        end
    end


    -- search for current unit

    if _jtacUnit:isActive() == false then
        ctld.cleanupJTAC(_jtacGroupName)

        ctld.logTrace(string.format("JTAC - LASE - [%s] - not active, scheduling JTACAutoLase in 30s at %s",
            ctld.p(_jtacGroupName), ctld.p(timer.getTime() + 30)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + 30)

        return
    end

    local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)
    --update targets list and store the next potential target if the selected one was lost
    local _defaultEnemyUnit = ctld.findNearestVisibleEnemy(_jtacUnit, _lock)

    -- if the JTAC sees a unit and a target was selected by users but is not the current unit, check if the selected target is in the targets list, if it is, then it's been reacquired
    if _enemyUnit and ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 and ctld.jtacSelectedTarget[_jtacGroupName] ~= _enemyUnit:getName() then
        for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
            if target then
                local targetUnit = target.unit
                local targetName = targetUnit:getName()

                if ctld.jtacSelectedTarget[_jtacGroupName] == targetName then
                    ctld.jtacCurrentTargets[_jtacGroupName] = {
                        name = targetName,
                        unitType = targetUnit:getTypeName(),
                        unitId =
                            targetUnit:getID()
                    }
                    _enemyUnit = targetUnit

                    local message = ctld.i18n_translate("%1, selected target reacquired, %2", _jtacGroupName,
                        _enemyUnit:getTypeName())
                    local fullMessage = message ..
                        ctld.i18n_translate(". CODE: %1. POSITION: %2", _laserCode, ctld.getPositionString(_enemyUnit))
                    ctld.notifyCoalition(fullMessage, 10, _jtacUnit:getCoalition(), _radio, message)
                end
            end
        end
    end

    local targetDestroyed = false
    local targetLost = false
    local wasSelected = false

    if _enemyUnit == nil and ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then
        local _tempUnitInfo = ctld.jtacCurrentTargets[_jtacGroupName]

        --            env.info("TEMP UNIT INFO: " .. tempUnitInfo.name .. " " .. tempUnitInfo.unitType)

        local _tempUnit = Unit.getByName(_tempUnitInfo.name)

        wasSelected = (ctld.jtacCurrentTargets[_jtacGroupName].name == ctld.jtacSelectedTarget[_jtacGroupName])

        if _tempUnit ~= nil and _tempUnit:getLife() > 0 and _tempUnit:isActive() == true then
            targetLost = true
        else
            targetDestroyed = true
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
        end

        --remove from smoke list
        ctld.jtacSmokeMarks[_tempUnitInfo.name] = nil

        -- JTAC Unit: resume his route ------------
        trigger.action.groupContinueMoving(Group.getByName(_jtacGroupName))

        -- remove from target list
        ctld.jtacCurrentTargets[_jtacGroupName] = nil

        --stop lasing
        ctld.cancelLase(_jtacGroupName)
    end


    if _enemyUnit == nil then
        if _defaultEnemyUnit ~= nil then
            -- store current target for easy lookup
            ctld.jtacCurrentTargets[_jtacGroupName] = {
                name = _defaultEnemyUnit:getName(),
                unitType = _defaultEnemyUnit
                    :getTypeName(),
                unitId = _defaultEnemyUnit:getID()
            }

            --add check for lasing or not
            local action = ctld.i18n_translate("new target, ")

            if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                action = ctld.i18n_translate("standing by on %1", action)
            else
                action = ctld.i18n_translate("lasing %1", action)
            end

            if wasSelected and targetLost then
                action = ctld.i18n_translate(", temporarily %1", action)
            else
                action = ", " .. action
            end

            if targetLost then
                action = ctld.i18n_translate("target lost") .. action
            elseif targetDestroyed then
                action = ctld.i18n_translate("target destroyed") .. action
            end

            if wasSelected then
                action = ctld.i18n_translate(", selected %1", action)
            elseif targetLost or targetDestroyed then
                action = ", " .. action
            end
            wasSelected = false
            targetDestroyed = false
            targetLost = false

            local message = _jtacGroupName .. action .. _defaultEnemyUnit:getTypeName()
            local fullMessage = message ..
                '. CODE: ' .. _laserCode .. ". POSITION: " .. ctld.getPositionString(_defaultEnemyUnit)
            ctld.notifyCoalition(fullMessage, 10, _jtacUnit:getCoalition(), _radio, message)

            -- JTAC Unit stop his route -----------------
            trigger.action.groupStopMoving(Group.getByName(_jtacGroupName)) -- stop JTAC

            -- create smoke
            if _smoke == true then
                --create first smoke
                ctld.createSmokeMarker(_defaultEnemyUnit, _colour)
            end
        end
    end

    if _enemyUnit ~= nil and not ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
        local refreshDelay = 15 --delay in between JTACAutoLase scheduled calls when a target is tracked
        local targetSpeedVec = _enemyUnit:getVelocity()
        local targetSpeed = math.sqrt(targetSpeedVec.x ^ 2 + targetSpeedVec.y ^ 2 + targetSpeedVec.z ^ 2)
        local maxUpdateDist = 5 --maximum distance the unit will be allowed to travel before the lase spot is updated again
        --ctld.logTrace(string.format("targetSpeed=%s", ctld.p(targetSpeed)))

        ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

        --if the target is going sufficiently fast for it to wander off futher than the maxUpdateDist, schedule laseUnit calls to update the lase spot only (we consider that the unit lives and drives on between JTACAutoLase calls)
        if targetSpeed >= maxUpdateDist / refreshDelay then
            local updateTimeStep = maxUpdateDist /
                targetSpeed --calculate the time step so that the target is never more than maxUpdateDist from it's last lased position
            --ctld.logTrace(string.format("JTAC - LASE - [%s] - target is moving at %s m/s, schedulting lasing steps every %ss", ctld.p(_jtacGroupName), ctld.p(targetSpeed), ctld.p(updateTimeStep)))

            local i = 1
            while i * updateTimeStep <= refreshDelay - updateTimeStep do --while the scheduled time for the laseUnit call isn't greater than the time between two JTACAutoLase() calls minus one time step (because at the next time step JTACAutoLase() should have been called and this in term also calls laseUnit())
                timer.scheduleFunction(ctld.timerLaseUnit, { _enemyUnit, _jtacUnit, _jtacGroupName, _laserCode },
                    timer.getTime() + i * updateTimeStep)
                i = i + 1
            end
            --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduled %s moving target lasing steps", ctld.p(_jtacGroupName), ctld.p(i)))
        end

        --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduling JTACAutoLase in %ss at %s", ctld.p(_jtacGroupName), ctld.p(refreshDelay), ctld.p(timer.getTime() + refreshDelay)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + refreshDelay)

        if _smoke == true then
            local _nextSmokeTime = ctld.jtacSmokeMarks[_enemyUnit:getName()]

            --recreate smoke marker after 5 mins
            if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then
                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end
    else
        --ctld.logDebug(string.format("JTAC - MODE - [%s] - No Enemies Nearby / Standby mode", ctld.p(_jtacGroupName)))

        -- stop lazing the old spot
        --ctld.logDebug(string.format("JTAC - LASE - [%s] - canceling lasing of the old spot", ctld.p(_jtacGroupName)))
        ctld.cancelLase(_jtacGroupName)

        --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduling JTACAutoLase in %ss at %s", ctld.p(_jtacGroupName), ctld.p(5), ctld.p(timer.getTime() + 5)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + 5)
    end

    local action = ", "
    if wasSelected then
        action = action .. "selected "
    end

    if targetLost then
        ctld.notifyCoalition(ctld.i18n_translate("%1 %2 target lost.", _jtacGroupName, action), 10,
            _jtacUnit:getCoalition(), _radio)
    elseif targetDestroyed then
        ctld.notifyCoalition(ctld.i18n_translate("%1 %2 target destroyed.", _jtacGroupName, action), 10,
            _jtacUnit:getCoalition(), _radio)
    end
end

function ctld.JTACAutoLaseStop(_jtacGroupName)
    ctld.jtacStop[_jtacGroupName] = true
end

-- used by the timer function
function ctld.timerJTACAutoLase(_args)
    ctld.JTACAutoLase(_args[1], _args[2], _args[3], _args[4], _args[5], _args[6])
end

function ctld.cleanupJTAC(_jtacGroupName)
    -- clear laser - just in case
    ctld.cancelLase(_jtacGroupName)

    -- Cleanup
    ctld.jtacCurrentTargets[_jtacGroupName] = nil

    ctld.jtacTargetsList[_jtacGroupName] = nil

    ctld.jtacSelectedTarget[_jtacGroupName] = nil

    for _, _specialOption in pairs(ctld.jtacSpecialOptions) do --delete jtac specific settings for all special options
        if _specialOption.jtacs then
            _specialOption.jtacs[_jtacGroupName] = nil
        end
    end

    ctld.jtacRadioData[_jtacGroupName] = nil

    --remove the JTAC's group submenu and all of the target pages it potentially contained if the JTAC has or had a menu
    if ctld.jtacUnits[_jtacGroupName] and ctld.jtacUnits[_jtacGroupName].side and ctld.jtacGroupSubMenuPath[_jtacGroupName] then
        local _players = coalition.getPlayers(ctld.jtacUnits[_jtacGroupName].side)

        if _players ~= nil then
            for _, _playerUnit in pairs(_players) do
                local _groupId = ctld.getGroupId(_playerUnit)

                if _groupId then
                    missionCommands.removeItemForGroup(_groupId, ctld.jtacGroupSubMenuPath[_jtacGroupName])
                end
            end
        end
    end

    ctld.jtacUnits[_jtacGroupName] = nil

    ctld.jtacGroupSubMenuPath[_jtacGroupName] = nil
end

--- send a message to the coalition
--- if _radio is set, the message will be read out loud via SRS
function ctld.notifyCoalition(_message, _displayFor, _side, _radio, _shortMessage)
    trigger.action.outTextForCoalition(_side, _message, _displayFor)

    local _shortMessage = _shortMessage
    if _shortMessage == nil then
        _shortMessage = _message
    end

    if STTS and STTS.TextToSpeech and _radio and _radio.freq then
        local _freq = _radio.freq
        local _modulation = _radio.mod or "FM"
        local _volume = _radio.volume or "1.0"
        local _name = _radio.name or "JTAC"
        local _gender = _radio.gender or "male"
        local _culture = _radio.culture or "en-US"
        local _voice = _radio.voice
        local _googleTTS = _radio.googleTTS or false
        STTS.TextToSpeech(_shortMessage, _freq, _modulation, _volume, _name, _side, nil, 1, _gender, _culture, _voice,
            _googleTTS)
    else
        trigger.action.outSoundForCoalition(_side, "radiobeep.ogg")
    end
end

function ctld.createSmokeMarker(_enemyUnit, _colour)
    --recreate in 5 mins
    ctld.jtacSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0

    local _enemyPoint = _enemyUnit:getPoint()
    trigger.action.smoke(
        {
            x = _enemyPoint.x + math.random(-ctld.JTAC_smokeMarginOfError, ctld.JTAC_smokeMarginOfError) +
                ctld.JTAC_smokeOffset_x,
            y = _enemyPoint.y + ctld.JTAC_smokeOffset_y,
            z = _enemyPoint.z +
                math.random(-ctld.JTAC_smokeMarginOfError, ctld.JTAC_smokeMarginOfError) + ctld.JTAC_smokeOffset_z
        }, _colour)
end

function ctld.cancelLase(_jtacGroupName)
    --local index = "JTAC_"..jtacUnit:getID()

    local _tempLase = ctld.jtacLaserPoints[_jtacGroupName]

    if _tempLase ~= nil then
        Spot.destroy(_tempLase)
        ctld.jtacLaserPoints[_jtacGroupName] = nil

        --            env.info('Destroy laze    '..index)

        _tempLase = nil
    end

    local _tempIR = ctld.jtacIRPoints[_jtacGroupName]

    if _tempIR ~= nil then
        Spot.destroy(_tempIR)
        ctld.jtacIRPoints[_jtacGroupName] = nil

        --    env.info('Destroy laze    '..index)

        _tempIR = nil
    end
end

-- used by the timer function
function ctld.timerLaseUnit(_args)
    ctld.laseUnit(_args[1], _args[2], _args[3], _args[4])
end

function ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)
    --cancelLase(jtacGroupName)
    --ctld.logTrace("ctld.laseUnit()")

    local _spots = {}

    if _enemyUnit:isExist() then
        local _enemyVector = _enemyUnit:getPoint()
        local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

        if ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] then
            local _enemySpeedVector = _enemyUnit:getVelocity()
            ctld.logTrace(string.format("_enemySpeedVector=%s", ctld.p(_enemySpeedVector)))

            local _WindSpeedVector = atmosphere.getWind(_enemyVectorUpdated)
            ctld.logTrace(string.format("_WindSpeedVector=%s", ctld.p(_WindSpeedVector)))

            --if target speed is greater than 0, calculated using absolute value norm
            if math.abs(_enemySpeedVector.x) + math.abs(_enemySpeedVector.y) + math.abs(_enemySpeedVector.z) > 0 then
                local CorrectionFactor = 1 --correction factor in seconds applied to the target speed components to determine the lasing spot for a direct hit on a moving vehicle

                --correct in the direction of the movement
                _enemyVectorUpdated.x = _enemyVectorUpdated.x + _enemySpeedVector.x * CorrectionFactor
                _enemyVectorUpdated.y = _enemyVectorUpdated.y + _enemySpeedVector.y * CorrectionFactor
                _enemyVectorUpdated.z = _enemyVectorUpdated.z + _enemySpeedVector.z * CorrectionFactor
            end

            --if wind speed is greater than 0, calculated using absolute value norm
            if math.abs(_WindSpeedVector.x) + math.abs(_WindSpeedVector.y) + math.abs(_WindSpeedVector.z) > 0 then
                local CorrectionFactor = 1.05 --correction factor in seconds applied to the wind speed components to determine the lasing spot for a direct hit in adverse conditions

                --correct to the opposite of the wind direction
                _enemyVectorUpdated.x = _enemyVectorUpdated.x - _WindSpeedVector.x * CorrectionFactor
                _enemyVectorUpdated.y = _enemyVectorUpdated.y -
                    _WindSpeedVector.y *
                    CorrectionFactor --not sure about correcting altitude but that component is always 0 in testing
                _enemyVectorUpdated.z = _enemyVectorUpdated.z - _WindSpeedVector.z * CorrectionFactor
            end
            --combination of both should result in near perfect accuracy if the bomb doesn't stall itself following fast vehicles or correcting for heavy winds, correction factors can be adjusted but should work up to 40kn of wind for vehicles moving at 90kph (beware to drop the bomb in a way to not stall it, facing which ever is larger, target speed or wind)
        end

        local _oldLase = ctld.jtacLaserPoints[_jtacGroupName]
        local _oldIR = ctld.jtacIRPoints[_jtacGroupName]

        if _oldLase == nil or _oldIR == nil then
            -- create lase

            local _status, _result = pcall(function()
                _spots['irPoint'] = Spot.createInfraRed(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
                _spots['laserPoint'] = Spot.createLaser(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated,
                    _laserCode)
                return _spots
            end)

            if not _status then
                env.error('ERROR: ' .. _result, false)
            else
                if _result.irPoint then
                    --        env.info(jtacUnit:getName() .. ' placed IR Pointer on '..enemyUnit:getName())

                    ctld.jtacIRPoints[_jtacGroupName] = _result
                        .irPoint --store so we can remove after
                end
                if _result.laserPoint then
                    --    env.info(jtacUnit:getName() .. ' is Lasing '..enemyUnit:getName()..'. CODE:'..laserCode)

                    ctld.jtacLaserPoints[_jtacGroupName] = _result.laserPoint
                end
            end
        else
            -- update lase

            if _oldLase ~= nil then
                _oldLase:setPoint(_enemyVectorUpdated)
            end

            if _oldIR ~= nil then
                _oldIR:setPoint(_enemyVectorUpdated)
            end
        end
    end
end

-- get currently selected unit and check they're still in range
function ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)
    local _unit = nil

    if ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then
        _unit = Unit.getByName(ctld.jtacCurrentTargets[_jtacGroupName].name)
    end

    local _tempPoint = nil
    local _tempDist = nil
    local _tempPosition = nil
    local _jtacPosition = _jtacUnit:getPosition()
    local _jtacPoint = _jtacUnit:getPoint()

    if _unit ~= nil and _unit:getLife() > 0 and _unit:isActive() == true then
        -- calc distance
        _tempPoint = _unit:getPoint()
        --     tempPosition = unit:getPosition()

        _tempDist = ctld.getDistance(_unit:getPoint(), _jtacUnit:getPoint())
        if _tempDist < ctld.JTAC_maxDistance then
            -- calc visible

            -- check slightly above the target as rounding errors can cause issues, plus the unit has some height anyways
            local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
            local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

            if land.isVisible(_offsetEnemyPos, _offsetJTACPos) then
                return _unit
            end
        end
    end
    return nil
end

-- Find nearest enemy to JTAC that isn't blocked by terrain
function ctld.findNearestVisibleEnemy(_jtacUnit, _targetType, _distance)
    --local startTime = os.clock()
    local _maxDistance = _distance or ctld.JTAC_maxDistance
    local _nearestDistance = _maxDistance
    local _jtacGroupName = _jtacUnit:getGroup():getName()
    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()
    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }

    local _unitList = {}

    local _search = function(_unit, _coa)
        pcall(function()
            if _unit ~= nil
                and _unit:getLife() > 0
                and _unit:isActive()
                and _unit:getCoalition() ~= _coa
                and not _unit:inAir()
                and not ctld.alreadyTarget(_jtacUnit, _unit) then
                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then
                    local _dist = ctld.getDistance(_offsetJTACPos, _offsetEnemyPos)

                    if _dist < _maxDistance then
                        table.insert(_unitList, { unit = _unit, dist = _dist })
                    end
                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    --log.info(string.format("JTAC Search elapsed time: %.4f\n", os.clock() - startTime))

    -- generate list order by distance & visible

    -- first check
    -- hpriority
    -- priority
    -- vehicle
    -- unit


    ctld.jtacTargetsList[_jtacGroupName] = _unitList
    --from the units in range, build the targets list, unsorted as to keep consistency between radio menu refreshes

    local _sort = function(a, b) return a.dist < b.dist end
    table.sort(_unitList, _sort)
    -- sort list

    -- check for hpriority
    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "hpriority") then
            return _enemyUnit.unit
        end
    end

    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "priority") then
            return _enemyUnit.unit
        end
    end

    local result = nil
    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()
        --log.info(string.format("CTLD - checking _enemyName=%s", _enemyName))

        -- check for air defenses
        --log.info(string.format("CTLD - _enemyUnit.unit:getDesc()[attributes]=%s", ctld.p(_enemyUnit.unit:getDesc()["attributes"])))
        local airdefense = (_enemyUnit.unit:getDesc()["attributes"]["Air Defence"] ~= nil)
        --log.info(string.format("CTLD - airdefense=%s", tostring(airdefense)))

        if (_targetType == "vehicle" and ctld.isVehicle(_enemyUnit.unit)) or _targetType == "all" then
            if airdefense then
                return _enemyUnit.unit
            else
                result = _enemyUnit.unit
            end
        elseif (_targetType == "troop" and ctld.isInfantry(_enemyUnit.unit)) or _targetType == "all" then
            if airdefense then
                return _enemyUnit.unit
            else
                result = _enemyUnit.unit
            end
        end
    end

    return result
end

function ctld.listNearbyEnemies(_jtacUnit)
    local _maxDistance = ctld.JTAC_maxDistance

    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()

    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }
    local _enemies = nil

    local _search = function(_unit, _coa)
        pcall(function()
            if _unit ~= nil
                and _unit:getLife() > 0
                and _unit:isActive()
                and _unit:getCoalition() ~= _coa
                and not _unit:inAir() then
                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then
                    if not _enemies then
                        _enemies = {}
                    end

                    _enemies[_unit:getTypeName()] = _unit:getTypeName()
                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    return _enemies
end

-- tests whether the unit is targeted by another JTAC
function ctld.alreadyTarget(_jtacUnit, _enemyUnit)
    for _, _jtacTarget in pairs(ctld.jtacCurrentTargets) do
        if _jtacTarget.unitId == _enemyUnit:getID() then
            -- env.info("ALREADY TARGET")
            return true
        end
    end

    return false
end

-- Returns only alive units from group but the group / unit may not be active

function ctld.getGroup(groupName)
    local _group = Group.getByName(groupName)

    local _filteredUnits = {} --contains alive units
    local _x = 1

    if _group ~= nil then
        --ctld.logTrace(string.format("ctld.getGroup - %s - group ~= nil", ctld.p(groupName)))
        if _group:isExist() then
            --ctld.logTrace(string.format("ctld.getGroup - %s - group:isExist()", ctld.p(groupName)))
            local _groupUnits = _group:getUnits()

            if _groupUnits ~= nil and #_groupUnits > 0 then
                --ctld.logTrace(string.format("ctld.getGroup - %s - group has %s units", ctld.p(groupName), ctld.p(#_groupUnits)))
                for _x = 1, #_groupUnits do
                    if _groupUnits[_x]:getLife() > 0 then -- removed and _groupUnits[_x]:isExist() as isExist doesnt work on single units!
                        table.insert(_filteredUnits, _groupUnits[_x])
                    else
                        --ctld.logTrace(string.format("ctld.getGroup - %s - dead unit %s", ctld.p(groupName), ctld.p(_groupUnits[_x]:getName())))
                    end
                end
            end
        end
    end

    return _filteredUnits
end

function ctld.getAliveGroup(_groupName)
    local _group = Group.getByName(_groupName)

    if _group and _group:isExist() == true and #_group:getUnits() > 0 then
        return _group
    end

    return nil
end

-- gets the JTAC status and displays to coalition units
function ctld.getJTACStatus(_args)
    --returns the status of all JTAC units unless the status of a single JTAC is asked for (by inserting it's groupName in _args[2])

    local _playerUnit = ctld.getTransportUnit(_args[1])
    local _singleJtacGroupName = _args[2]

    if _playerUnit == nil and _singleJtacGroupName == nil then
        return
    end

    local _side = nil

    if _playerUnit == nil then
        _side = ctld.jtacUnits[_singleJtacGroupName].side
    else
        _side = _playerUnit:getCoalition()
    end

    local _jtacUnit = nil
    local hasJTAC = false
    local _message = ctld.i18n_translate("JTAC STATUS: \n\n")

    for _jtacGroupName, _jtacDetails in pairs(ctld.jtacUnits) do
        --look up units
        if _singleJtacGroupName == nil or (_singleJtacGroupName and _singleJtacGroupName == _jtacGroupName) then --if the status of a single JTAC or if the status of a single JTAC was asked and this is the correct JTAC we're going over in the loop
            _jtacUnit = Unit.getByName(_jtacDetails.name)

            if _jtacUnit ~= nil and _jtacUnit:getLife() > 0 and _jtacUnit:isActive() == true and _jtacUnit:getCoalition() == _side then
                hasJTAC = true

                local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

                local _laserCode = ctld.jtacLaserPointCodes[_jtacGroupName]

                local _start = "->" .. _jtacGroupName
                if (_jtacDetails.radio) then
                    _start = _start ..
                        ctld.i18n_translate(", available on %1 %2,", _jtacDetails.radio.freq, _jtacDetails.radio.mod)
                end

                if _laserCode == nil then
                    _laserCode = ctld.i18n_translate("UNKNOWN")
                end

                if _enemyUnit ~= nil and _enemyUnit:getLife() > 0 and _enemyUnit:isActive() == true then
                    local action = ctld.i18n_translate(" targeting ")

                    if ctld.jtacSelectedTarget[_jtacGroupName] == _enemyUnit:getName() then
                        action = ctld.i18n_translate(" targeting selected unit ")
                    else
                        if ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 then
                            action = ctld.i18n_translate(" attempting to find selected unit, temporarily targeting ")
                        end
                    end

                    if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                        action = action .. ctld.i18n_translate("(Laser OFF) ")
                    end

                    _message = _message ..
                        "" ..
                        _start ..
                        action ..
                        _enemyUnit:getTypeName() .. " CODE: " .. _laserCode .. ctld.getPositionString(_enemyUnit) .. "\n"

                    local _list = ctld.listNearbyEnemies(_jtacUnit)

                    if _list then
                        _message = _message .. ctld.i18n_translate("Visual On: ")

                        for _, _type in pairs(_list) do
                            _message = _message .. _type .. ", "
                        end
                        _message = _message .. "\n"
                    end
                else
                    _message = _message ..
                        "" ..
                        _start .. ctld.i18n_translate(" searching for targets %1\n", ctld.getPositionString(_jtacUnit))
                end
            end
        end
    end

    if not hasJTAC then
        ctld.notifyCoalition(ctld.i18n_translate("No Active JTACs"), 10, _side)
    else
        ctld.notifyCoalition(_message, 10, _side)
    end
end

function ctld.setJTACTarget(_args)
    if _args then
        local _jtacGroupName = _args.jtacGroupName
        local targetName = _args.targetName

        if _jtacGroupName and targetName and ctld.jtacSelectedTarget[_jtacGroupName] and ctld.jtacTargetsList[_jtacGroupName] then
            --look for the unit's (target) name in the Targets List, create the required data structure for jtacCurrentTargets and then assign it to the JTAC called _jtacGroupName
            for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
                if target then
                    local listedTargetUnit = target.unit
                    local ListedTargetName = listedTargetUnit:getName()

                    if ListedTargetName == targetName then
                        ctld.jtacSelectedTarget[_jtacGroupName] = targetName
                        ctld.jtacCurrentTargets[_jtacGroupName] = {
                            name = targetName,
                            unitType = listedTargetUnit
                                :getTypeName(),
                            unitId = listedTargetUnit:getID()
                        }

                        local message = _jtacGroupName ..
                            ctld.i18n_translate(", targeting selected unit, %1", listedTargetUnit:getTypeName())
                        local fullMessage = message ..
                            ctld.i18n_translate(". CODE: %1. POSITION: %2", ctld.jtacLaserPointCodes[_jtacGroupName],
                                ctld.getPositionString(listedTargetUnit))
                        ctld.notifyCoalition(fullMessage, 10, ctld.jtacUnits[_jtacGroupName].side,
                            ctld.jtacRadioData[_jtacGroupName], message)
                    end
                end
            end
        elseif not targetName and ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 then
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
            ctld.jtacCurrentTargets[_jtacGroupName] = nil

            local message = _jtacGroupName .. ctld.i18n_translate(", target selection reset.")
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])

            if ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] then
                ctld.setLaseCompensation({ jtacGroupName = _jtacGroupName, value = false }) --disable laser spot corrections
            end

            if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                ctld.setStdbMode({ jtacGroupName = _jtacGroupName, value = false }) --make the JTAC exit standby mode after either target selection or targeting selection reset
            end
        end

        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

--special option setters (make sure to affect the function pointer to the corresponding .setter in the special options table after declaration of said function)
function ctld.setSpecialOptionArgsCheck(_args)
    if _args then
        local _jtacGroupName = _args.jtacGroupName
        local _value = _args.value        --expected boolean
        local _notOutput = _args.noOutput --expected boolean

        if _jtacGroupName then
            return { jtacGroupName = _jtacGroupName, value = _value, noOutput = _notOutput }
        end
    end

    return nil
end

function ctld.setStdbMode(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _value = parsedArgs.value
        local _noOutput = parsedArgs.noOutput

        local message = ctld.i18n_translate("%1, laser and smokes enabled", _jtacGroupName)
        if _value then
            message = ctld.i18n_translate("%1, laser and smokes disabled", _jtacGroupName)
        end
        if not _noOutput then
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
        end

        ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] = _value
        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

ctld.jtacSpecialOptions.standbyMode.setter = ctld.setStdbMode

function ctld.setLaseCompensation(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _value = parsedArgs.value
        local _noOutput = parsedArgs.noOutput

        local message = ctld.i18n_translate("%1, wind and target speed laser spot compensations enabled", _jtacGroupName)
        if _value then
            message = ctld.i18n_translate("%1, wind and target speed laser spot compensations disabled", _jtacGroupName)
        end
        if not _noOutput then
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
        end

        ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] = _value
        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

ctld.jtacSpecialOptions.laseSpotCorrections.setter = ctld.setLaseCompensation

function ctld.setSmokeOnTarget(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _noOutput = parsedArgs.noOutput
        local _enemyUnit = Unit.getByName(ctld.jtacCurrentTargets[_jtacGroupName].name)

        if _enemyUnit then
            if not _noOutput then
                ctld.notifyCoalition(ctld.i18n_translate("%1, WHITE smoke deployed near target", _jtacGroupName), 10,
                    ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
            end

            local _enemyPoint = _enemyUnit:getPoint()
            local randomCircleDiam = 30;
            trigger.action.smoke(
                {
                    x = _enemyPoint.x + math.random(randomCircleDiam, -randomCircleDiam),
                    y = _enemyPoint.y + 2.0,
                    z =
                        _enemyPoint.z + math.random(randomCircleDiam, -randomCircleDiam)
                }, 2)
        end
    end
end

ctld.jtacSpecialOptions.smokeMarker.setter = ctld.setSmokeOnTarget

function ctld.setJTAC9Line(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName

        ctld.getJTACStatus({ nil, _jtacGroupName })
    end
end

ctld.jtacSpecialOptions._9Line.setter = ctld.setJTAC9Line

function ctld.setGrpROE(_grp, _ROE)
    if _grp == nil then
        ctld.logError("ctld.setGrpROE called with a nil group")
        return
    end

    if _ROE == nil then
        _ROE = AI.Option.Ground.val.ROE.OPEN_FIRE
    end

    if _grp and _grp:isExist() == true and #_grp:getUnits() > 0 then -- check if the group truly exists
        local _controller = _grp:getController();
        Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
        Controller.setOption(_controller, AI.Option.Ground.id.ROE, _ROE)
        --_controller:setTask(_grp)             -- FG 250510 this line seems to be a bug
    end
end

function ctld.isInfantry(_unit)
    local _typeName = _unit:getTypeName()

    --type coerce tostring
    _typeName = string.lower(_typeName .. "")

    local _soldierType = { "infantry", "paratrooper", "stinger", "manpad", "mortar" }

    for _key, _value in pairs(_soldierType) do
        if string.match(_typeName, _value) then
            return true
        end
    end

    return false
end

-- assume anything that isnt soldier is vehicle
function ctld.isVehicle(_unit)
    if ctld.isInfantry(_unit) then
        return false
    end

    return true
end

-- The entered value can range from 1111 - 1788,
-- -- but the first digit of the series must be a 1 or 2
-- -- and the last three digits must be between 1 and 8.
--    The range used to be bugged so its not 1 - 8 but 0 - 7.
-- function below will use the range 1-7 just incase
function ctld.generateLaserCode()
    ctld.jtacGeneratedLaserCodes = {}

    -- generate list of laser codes
    local _code = 1511

    local _count = 1

    while _code < 1777 and _count < 30 do
        while true do
            _code = _code + 1

            if not ctld.containsDigit(_code, 8)
                and not ctld.containsDigit(_code, 9)
                and not ctld.containsDigit(_code, 0) then
                table.insert(ctld.jtacGeneratedLaserCodes, _code)

                --env.info(_code.." Code")
                break
            end
        end
        _count = _count + 1
    end
end

function ctld.containsDigit(_number, _numberToFind)
    local _thisNumber = _number
    local _thisDigit = 0

    while _thisNumber ~= 0 do
        _thisDigit = _thisNumber % 10
        _thisNumber = math.floor(_thisNumber / 10)

        if _thisDigit == _numberToFind then
            return true
        end
    end

    return false
end

-- 200 - 400 in 10KHz
-- 400 - 850 in 10 KHz
-- 850 - 1250 in 50 KHz
function ctld.generateVHFrequencies()
    --ignore list
    --list of all frequencies in KHZ that could conflict with
    -- 191 - 1290 KHz, beacon range
    local _skipFrequencies = {
        745, --Astrahan
        381,
        384,
        300.50,
        312.5,
        1175,
        342,
        735,
        300.50,
        353.00,
        440,
        795,
        525,
        520,
        690,
        625,
        291.5,
        300.50,
        435,
        309.50,
        920,
        1065,
        274,
        312.50,
        580,
        602,
        297.50,
        750,
        485,
        950,
        214,
        1025, 730, 995, 455, 307, 670, 329, 395, 770,
        380, 705, 300.5, 507, 740, 1030, 515,
        330, 309.5,
        348, 462, 905, 352, 1210, 942, 435,
        324,
        320, 420, 311, 389, 396, 862, 680, 297.5,
        920, 662,
        866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528,
        337, 312.5, 830, 740, 309.5, 641, 312, 722, 682, 1050,
        1116, 935, 1000, 430, 577,
        326 -- Nevada
    }

    ctld.freeVHFFrequencies = {}
    local _start = 200000

    -- first range
    while _start < 400000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end


        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 400000
    -- second range
    while _start < 850000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end


        _start = _start + 10000
    end

    _start = 850000
    -- third range
    while _start <= 1250000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 50000
    end
end

-- 220 - 399 MHZ, increments of 0.5MHZ
function ctld.generateUHFrequencies()
    ctld.freeUHFFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do
        table.insert(ctld.freeUHFFrequencies, _start)
        _start = _start + 500000
    end
end

-- 220 - 399 MHZ, increments of 0.5MHZ
--        -- first digit 3-7MHz
--        -- second digit 0-5KHz
--        -- third digit 0-9
--        -- fourth digit 0 or 5
--        -- times by 10000
--
function ctld.generateFMFrequencies()
    ctld.freeFMFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do
        _start = _start + 500000
    end

    for _first = 3, 7 do
        for _second = 0, 5 do
            for _third = 0, 9 do
                local _frequency = ((100 * _first) + (10 * _second) + _third) *
                    100000 --extra 0 because we didnt bother with 4th digit
                table.insert(ctld.freeFMFrequencies, _frequency)
            end
        end
    end
end

function ctld.getPositionString(_unit)
    if ctld.JTAC_location == false then
        return ""
    end

    local _lat, _lon  = coord.LOtoLL(_unit:getPosition().p)
    local _latLngStr  = CTLD_extAPI.tostringLL("ctld.getPositionString()", _lat, _lon, 3, ctld.location_DMS)
    local _mgrsString = CTLD_extAPI.tostringMGRS("ctld.getPositionString()",
        coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)
    local _TargetAlti = land.getHeight(ctld.utils.makeVec2FromVec3OrVec2("ctld.getPositionString()", _unit:getPoint()))
    return " @ " ..
        _latLngStr ..
        " - MGRS " ..
        _mgrsString ..
        " - ALTI: " ..
        ctld.utils.round("ctld.getPositionString()", _TargetAlti, 0) ..
        " m / " .. ctld.utils.round("ctld.getPositionString()", _TargetAlti / 0.3048, 0) .. " ft"
end

--**********************************************************************
--  Automaticaly put in orbit over his target a flying JTAC
--
--  Objective   :   This script put in orbit each flying JTAC over his detected target
--                  Associated with CTLD/JTAC function, you can assign a fly route to the JTAC (a drone for example),
--                  this one follow it, and start orbiting when he detects a target.
--                  As soon as it don't detect a target, it restart following its initial route at the nearest waypoint
--  Use : In mission editor:
--                  0> Set ctld.enableAutoOrbitingFlyingJtacOnTarget = true
--      			1> Load MIST + CTLD
--                  2> Create a TRIGGER (once) at Time sup à 6, and a ACTION.EXECUTE SCRIPT :
--							ctld.JTACAutoLase("gdrone1", 1688,false)  -- défine group "gdrone1" as a JTAC
------------------------------------------------------------------------------------
ctld.JTACInRoute = {}                            -- for each JTAC in route, indicates the time of the run
ctld.OrbitInUse = {}                             -- for each Orbit group in use, indicates the time of the run
ctld.enableAutoOrbitingFlyingJtacOnTarget = true -- if true activate the AutoOrbitingFlyinfJtacOnTarget function for all flying JTACS
------------------------------------------------------------------------------------
-- Automatic JTAC orbit on target detect
function ctld.TreatOrbitJTAC(params, t)
    if t == nil then t = timer.getTime() end

    for k, v in pairs(ctld.jtacUnits) do                                     -- vérify state of each active JTAC
        if ctld.isFlyingJtac(k) then
            if ctld.JTACInRoute[k] == nil and ctld.OrbitInUse[k] == nil then -- if JTAC is in route
                ctld.JTACInRoute[k] = timer.getTime()                        -- update time of the last run
            end

            if ctld.jtacCurrentTargets[k] ~= nil then                                            -- if target lased by JTAC
                local droneAlti = Unit.getByName(k):getPoint().y
                if ctld.OrbitInUse[k] == nil then                                                -- if JTAC is not in orbit => start orbiting and update start time
                    ctld.StartOrbitGroup(k, ctld.jtacCurrentTargets[k].name, droneAlti, 100)     -- do orbit JTAC
                    ctld.OrbitInUse[k]  = timer.getTime()                                        -- update time of the last orbit run
                    ctld.JTACInRoute[k] = nil                                                    -- JTAC is in orbit => reset the route time
                else                                                                             -- JTAC already orbiting => update coord for following the target mouvements each 60"
                    if timer.getTime() > (ctld.OrbitInUse[k] + 60) then                          -- each 60" update orbit coord
                        ctld.StartOrbitGroup(k, ctld.jtacCurrentTargets[k].name, droneAlti, 100) -- do orbit JTAC
                        ctld.OrbitInUse[k] = timer.getTime()                                     -- update time of the last orbit run
                    end
                end
            else                                          -- if JTAC have no target
                if ctld.InOrbitList(k) == true then       -- JTAC orbiting, without target => stop orbit
                    --Unit.getByName(k):getController():popTask()	   -- stop orbiting JTAC Task => return to route
                    ctld.backToRoute(k)                   -- return to route from the nearest WP
                    ctld.OrbitInUse[k]  = nil             -- Reset orbit
                    ctld.JTACInRoute[k] = timer.getTime() -- update time of the last start inroute
                end
            end
        end
    end
    return t + 3 --reschedule in 3"
end

------------------------------------------------------------------------------------
-- Make orbit the _jtacUnitName group, on target "_unitTargetName".  _alti in meters, speed in km/h
function ctld.StartOrbitGroup(_jtacUnitName, _unitTargetName, _alti, _speed)
    if (Unit.getByName(_unitTargetName) ~= nil) and (Unit.getByName(_jtacUnitName) ~= nil) then -- si target unit and JTAC group exist
        local orbit = {
            id     = 'Orbit',
            params = {
                pattern = 'Circle',
                --point = ctld.utils.makeVec2FromVec3OrVec2("ctld.StartOrbitGroup()",
                --    ctld.utils.getAvgPos("ctld.StartOrbitGroup()",
                --        CTLD_extAPI.makeUnitTable("ctld.StartOrbitGroup()", { _unitTargetName }))),
                point = ctld.utils.makeVec2FromVec3OrVec2("ctld.StartOrbitGroup()",
                    Unit.getByName(_unitTargetName):getPoint()),
                speed = _speed,
                altitude = _alti
            }
        }
        local jtacGroupName = Unit.getByName(_jtacUnitName):getGroup():getName()
        Unit.getByName(_jtacUnitName):getController():popTask() -- stop current Task
        Group.getByName(jtacGroupName):getController():pushTask(orbit)
    end
end

-------------------------------------------------------------------------------------------
-- test if one unitName already is targeted by a JTAC
function ctld.InOrbitList(_grpName)
    for k, v in pairs(ctld.OrbitInUse) do -- for each orbit in use
        if k == _grpName then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------------
-- return the WayPoint number (on the JTAC route) the most near from the target
function ctld.getNearestWP(_referenceUnitName)
    local WP = 0
    local memoDist = nil                                                                  -- Lower distance checked
    local refGroupName = Unit.getByName(_referenceUnitName):getGroup():getName()
    local JTACRoute = ctld.utils.getGroupRoute("ctld.getNearestWP()", refGroupName, true) -- get the initial editor route of the current group
    if Unit.getByName(_referenceUnitName) ~= nil then                                     --JTAC et unit must exist
        for i = 1, #JTACRoute do
            local ptWP  = { x = JTACRoute[i].x, y = JTACRoute[i].y }
            local ptRef = ctld.utils.makeVec2FromVec3OrVec2("ctld.getNearestWP()",
                Unit.getByName(_referenceUnitName):getPoint())
            local dist  = ctld.utils.get2DDist("ctld.getNearestWP()", ptRef, ptWP) -- distance between 2 points
            if memoDist == nil then
                memoDist = dist
                WP = i
            elseif dist < memoDist then
                memoDist = dist
                WP = i
            end
        end
    end
    return WP
end

----------------------------------------------------------------------------
-- Modify the route deleting all the WP before "firstWP" param, for aligne the orbit on the nearest WP of the target
function ctld.backToRoute(_jtacUnitName)
    local jtacGroupName = Unit.getByName(_jtacUnitName):getGroup():getName()
    --local JTACRoute     = ctld.utils.getGroupRoute("ctld.backToRoute()", jtacGroupName, true)   -- get the initial editor route of the current group
    local JTACRoute     = ctld.utils.deepCopy("ctld.backToRoute()",
        ctld.utils.getGroupRoute("ctld.backToRoute()", jtacGroupName, true)) -- get the initial editor route of the current group
    local newJTACRoute  = ctld.adjustRoute(JTACRoute, ctld.getNearestWP(_jtacUnitName))

    local Mission       = {}
    Mission             = { id = 'Mission', params = { route = { points = newJTACRoute } } }

    -- unactive orbit mode if it's on
    if ctld.InOrbitList(_jtacUnitName) == true then -- if JTAC orbiting => stop it
        ctld.OrbitInUse[_jtacUnitName] = nil
    end
    Unit.getByName(_jtacUnitName):getController():setTask(Mission) -- submit the new route
    return Mission
end

----------------------------------------------------------------------------
function ctld.adjustRoute(_initialRouteTable, _firstWpOfNewRoute) -- create a route based on inital one, starting at _firstWpOfNewRoute WP
    if _firstWpOfNewRoute >= 1 then
        -- if the last WP switch to the first this cycle is recreated
        local adjustedRoute = {}
        local mappingWP = {}
        local idx = 1
        for i = _firstWpOfNewRoute, #_initialRouteTable do -- load each WP route starting from _firstWpOfNewRoute to end
            adjustedRoute[idx] = _initialRouteTable[i]
            mappingWP[i] = idx
            ctld.logDebug("ctld.adjustRoute - mappingWP[%s]=[%s]", ctld.p(i), ctld.p(idx))
            idx = idx + 1
        end
        for i = 1, _firstWpOfNewRoute - 1 do -- load each WP route starting from 1 to _firstWpOfNewRoute-1
            adjustedRoute[idx] = _initialRouteTable[i]
            mappingWP[i] = idx
            ctld.logDebug("ctld.adjustRoute - mappingWP[%s]=[%s]", ctld.p(i), ctld.p(idx))
            idx = idx + 1
        end

        -- apply offset (_firstWpOfNewRoute) to SwitchWaypoint tasks
        local lastWpAsAlreadySwitchWaypoint = false
        for idx2 = 1, #adjustedRoute do
            if #adjustedRoute[idx2] and
                #adjustedRoute[idx2].task and
                #adjustedRoute[idx2].task.params and
                #adjustedRoute[idx2].task.params.tasks then
                for j = 1, #adjustedRoute[idx2].task.params.tasks do
                    if adjustedRoute[idx2].task.params.tasks[j].id and
                        adjustedRoute[idx2].task.params.tasks[j].id ~= "ControlledTask" then
                        if adjustedRoute[idx2].task.params.tasks[j].params and
                            adjustedRoute[idx2].task.params.tasks[j].params.action and
                            adjustedRoute[idx2].task.params.tasks[j].params.action.id and
                            adjustedRoute[idx2].task.params.tasks[j].params.action.id == "SwitchWaypoint" then
                            if adjustedRoute[idx2].task.params.tasks[j].params.action.params then
                                local goToWaypointIndex = adjustedRoute[idx2].task.params.tasks[j].params.action.params
                                    .goToWaypointIndex
                                adjustedRoute[idx2].task.params.tasks[j].params.action.params.fromWaypointIndex = idx2
                                adjustedRoute[idx2].task.params.tasks[j].params.action.params.goToWaypointIndex =
                                    mappingWP[goToWaypointIndex]
                                if idx2 == #adjustedRoute then
                                    lastWpAsAlreadySwitchWaypoint = true
                                end
                            end
                        end
                    else -- for "ControlledTask"
                        if adjustedRoute[idx2].task.params.tasks[j].params and
                            adjustedRoute[idx2].task.params.tasks[j].params.task and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.id and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.id == "SwitchWaypoint" then
                            if adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params then
                                local goToWaypointIndex = adjustedRoute[idx2].task.params.tasks[j].params.task.params
                                    .action.params.goToWaypointIndex
                                adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params.fromWaypointIndex =
                                    idx2
                                adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params.goToWaypointIndex =
                                    mappingWP[goToWaypointIndex]
                                if idx2 == #adjustedRoute then
                                    lastWpAsAlreadySwitchWaypoint = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if lastWpAsAlreadySwitchWaypoint == false then
            local newTaskIdx                                                                 = #adjustedRoute
                [#adjustedRoute].task.params.tasks + 1
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx]                      = {
                number  = newTaskIdx,
                auto    = false,
                enabled = true,
                id      = "WrappedAction",
                params  = { action = {} }
            }
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx].params.action.id     = "SwitchWaypoint"
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx].params.action.params = {
                fromWaypointIndex = #_initialRouteTable,
                goToWaypointIndex = 1
            }
        end
        --ctld.logDebug("ctld.adjustRoute - adjustedRoute = [%s]", ctld.p(adjustedRoute))
        return adjustedRoute
    end
    return nil
end

----------------------------------------------------------------------------
function ctld.isFlyingJtac(_jtacUnitName)
    if Unit.getByName(_jtacUnitName) then
        if Unit.getByName(_jtacUnitName):getCategoryEx() == 0 then -- it's an airplane JTAC
            return true
        end
    end
    return false
end

--**********************************************************************
--                                     RECOGNITION SUPPORT FUNCTIONS
-- Shows/remove/refresh marks in F10 map on targets in LOS of a unit passed in params
---------------------------------------------------------------------
-- examples ---------------------------------------------------------
--ctld.reconRefreshTargetsInLosOnF10Map(Unit.getByName("uh2-1"), 2000, 200)
--ctld.reconRemoveTargetsInLosOnF10Map(Unit.getByName("uh2-1"))
--ctld.reconShowTargetsInLosOnF10Map(Unit.getByName("uh2-1"), 2000, 200)
----------------------------------------------------------------------
--if ctld == nil then    ctld = {} end
if ctld.lastMarkId == nil then
    ctld.lastMarkId = 0
end

-- ***************** RECON CONFIGURATION *****************
ctld.reconF10Menu                   = true                         -- enables F10 RECON menu
ctld.reconMenuName                  = ctld.i18n_translate("RECON") --name of the CTLD JTAC radio menu
ctld.reconRadioAdded                = {}                           --stores the groups that have had the radio menu added
ctld.reconLosSearchRadius           = 2000                         -- search radius in meters
ctld.reconLosMarkRadius             = 100                          -- mark radius dimension in meters
ctld.reconAutoRefreshLosTargetMarks = false                        -- if true recon LOS marks are automaticaly refreshed on F10 map
ctld.reconLastScheduleIdAutoRefresh = 0

---- F10 RECON Menus ------------------------------------------------------------------
function ctld.addReconRadioCommand(_side) -- _side = 1 or 2 (red    or blue)
    if ctld.reconF10Menu then
        if _side == 1 or _side == 2 then
            local _players = coalition.getPlayers(_side)
            if _players ~= nil then
                for _, _playerUnit in pairs(_players) do
                    local _groupId = ctld.getGroupId(_playerUnit)
                    if _groupId then
                        if ctld.reconRadioAdded[tostring(_groupId)] == nil then
                            --ctld.logDebug("ctld.addReconRadioCommand - adding RECON radio menu for unit [%s]", ctld.p(_playerUnit:getName()))
                            local RECONpath = missionCommands.addSubMenuForGroup(_groupId, ctld.reconMenuName)
                            missionCommands.addCommandForGroup(_groupId,
                                ctld.i18n_translate("Show targets in LOS (refresh)"), RECONpath,
                                ctld.reconRefreshTargetsInLosOnF10Map, {
                                    _groupId      = _groupId,
                                    _playerUnit   = _playerUnit,
                                    _searchRadius = ctld.reconLosSearchRadius,
                                    _markRadius   = ctld.reconLosMarkRadius,
                                    _boolRemove   = true
                                })
                            missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Hide targets in LOS"),
                                RECONpath, ctld.reconRemoveTargetsInLosOnF10Map, _playerUnit)
                            if ctld.reconAutoRefreshLosTargetMarks then
                                missionCommands.addCommandForGroup(_groupId,
                                    ctld.i18n_translate("STOP autoRefresh targets in LOS"), RECONpath,
                                    ctld.reconStopAutorefreshTargetsInLosOnF10Map,
                                    _groupId,
                                    _playerUnit,
                                    ctld.reconLosSearchRadius,
                                    ctld.reconLosMarkRadius,
                                    true)
                            else
                                missionCommands.addCommandForGroup(_groupId,
                                    ctld.i18n_translate("START autoRefresh targets in LOS"), RECONpath,
                                    ctld.reconStartAutorefreshTargetsInLosOnF10Map,
                                    _groupId,
                                    _playerUnit,
                                    ctld.reconLosSearchRadius,
                                    ctld.reconLosMarkRadius,
                                    true
                                )
                            end
                            ctld.reconRadioAdded[tostring(_groupId)] = timer.getTime() --fetch the time to check for a regular refresh
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------
function ctld.reconStopAutorefreshTargetsInLosOnF10Map(_groupId, _playerUnit, _searchRadius, _markRadius, _boolRemove)
    ctld.reconAutoRefreshLosTargetMarks = false

    if ctld.reconLastScheduleIdAutoRefresh ~= 0 then
        timer.removeFunction(ctld.reconLastScheduleIdAutoRefresh) -- reset last schedule
    end

    ctld.reconRemoveTargetsInLosOnF10Map(_playerUnit)
    missionCommands.removeItemForGroup(_groupId,
        { ctld.reconMenuName, ctld.i18n_translate("STOP autoRefresh targets in LOS") })
    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("START autoRefresh targets in LOS"),
        { ctld.reconMenuName },
        ctld.reconStartAutorefreshTargetsInLosOnF10Map,
        _groupId,
        _playerUnit,
        _searchRadius,
        _markRadius,
        _boolRemove)
end

--------------------------------------------------------------------
function ctld.reconStartAutorefreshTargetsInLosOnF10Map(_groupId, _playerUnit, _searchRadius, _markRadius, _boolRemove)
    ctld.reconAutoRefreshLosTargetMarks = true
    ctld.reconRefreshTargetsInLosOnF10Map({
            _groupId      = _groupId,
            _playerUnit   = _playerUnit,
            _searchRadius = _searchRadius or ctld.reconLosSearchRadius,
            _markRadius   = _markRadius or ctld.reconLosMarkRadius,
            _boolRemove   = _boolRemove or true
        },
        timer.getTime())
    missionCommands.removeItemForGroup(_groupId,
        { ctld.reconMenuName, ctld.i18n_translate("START autoRefresh targets in LOS") })
    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("STOP autoRefresh targets in LOS"),
        { ctld.reconMenuName },
        ctld.reconStopAutorefreshTargetsInLosOnF10Map,
        _groupId,
        _playerUnit,
        _searchRadius,
        _markRadius,
        _boolRemove)
end

--------------------------------------------------------------------
function ctld.reconShowTargetsInLosOnF10Map(_playerUnit, _searchRadius, _markRadius) -- _groupId targeting
    -- _searchRadius and _markRadius in meters
    if _playerUnit then
        local TargetsInLOS = {}

        local enemyColor = "red"
        local color = { 1, 0, 0, 0.2 } -- red

        if _playerUnit:getCoalition() == 1 then
            enemyColor = "blue"
            color = { 51 / 255, 51 / 255, 1, 0.2 } -- blue
        end

        local enemyUnitsListNames = {}
        for i, v in ipairs(coalition.getGroups(coalition.side[string.upper(enemyColor)], Group.Category.GROUND)) do
            enemyUnitsListNames[#enemyUnitsListNames + 1] = v:getName()
        end

        --local t = ctld.utils.getUnitsLOS("ctld.reconShowTargetsInLosOnF10Map()", { _playerUnit:getName() }, 180,
        --    CTLD_extAPI.makeUnitTable("ctld.reconShowTargetsInLosOnF10Map()", { '[' .. enemyColor .. '][vehicle]' }),
        --    180, _searchRadius)

        local t = ctld.utils.getUnitsLOS("ctld.reconShowTargetsInLosOnF10Map()",
            { _playerUnit:getName() },
            180,
            enemyUnitsListNames,
            180, _searchRadius)

        local MarkIds = {}
        if t then
            for i = 1, #t do                                   -- for each unit having los on enemies
                for j = 1, #t[i].vis do                        -- for each enemy unit in los
                    local targetPoint = t[i].vis[j]:getPoint() -- point of each target on LOS
                    ctld.lastMarkId = ctld.lastMarkId + 1
                    trigger.action.circleToAll(_playerUnit:getCoalition(), ctld.lastMarkId, targetPoint, _markRadius,
                        color, color, 1, false, nil)
                    MarkIds[#MarkIds + 1] = ctld.lastMarkId
                    TargetsInLOS[#TargetsInLOS + 1] = {
                        targetObject   = t[i].vis[j]:getName(),
                        targetTypeName = t[i].vis[j]:getTypeName(),
                        targetPoint    = targetPoint
                    }
                end
            end
        end
        CTLD_extAPI.DBs.humansByName[_playerUnit:getName()].losMarkIds =
            MarkIds -- store list of marksIds generated and showed on F10 map
        return TargetsInLOS
    else
        return nil
    end
end

---------------------------------------------------------
function ctld.reconRemoveTargetsInLosOnF10Map(_playerUnit)
    local unitName = _playerUnit:getName()
    if CTLD_extAPI.DBs.humansByName[unitName].losMarkIds then
        for i = 1, #CTLD_extAPI.DBs.humansByName[unitName].losMarkIds do -- for each unit having los on enemies
            trigger.action.removeMark(CTLD_extAPI.DBs.humansByName[unitName].losMarkIds[i])
        end
        CTLD_extAPI.DBs.humansByName[unitName].losMarkIds = nil
    end
end

---------------------------------------------------------
function ctld.reconRefreshTargetsInLosOnF10Map(_params, _t) -- _params._playerUnit targeting
    -- _params._searchRadius and _params._markRadius in meters
    -- _params._boolRemove = true to remove previous marksIds
    if _t == nil then _t = timer.getTime() end

    if ctld.reconAutoRefreshLosTargetMarks then -- to follow mobile enemy targets
        ctld.reconLastScheduleIdAutoRefresh = timer.scheduleFunction(ctld.reconRefreshTargetsInLosOnF10Map,
            {
                _groupId      = _params._groupId,
                _playerUnit   = _params._playerUnit,
                _searchRadius = _params._searchRadius,
                _markRadius   = _params._markRadius,
                _boolRemove   = _params._boolRemove
            },
            timer.getTime() + 10)
    end

    if _params._boolRemove == true then
        ctld.reconRemoveTargetsInLosOnF10Map(_params._playerUnit)
    end

    return ctld.reconShowTargetsInLosOnF10Map(_params._playerUnit, _params._searchRadius, _params._markRadius) -- returns TargetsInLOS table
end

--- test ------------------------------------------------------
--local unitName = "uh2-1"                    --"uh1-1"    --"uh2-1"
--ctld.reconShowTargetsInLosOnF10Map(Unit.getByName(unitName),2000,200)


--**********************************************************************

-- ***************** SETUP SCRIPT ****************
function ctld.initialize()
    ctld.logInfo(string.format("Initializing version %s", ctld.Version))

    assert(mist ~= nil,
        "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

    ctld.addedTo = {}
    ctld.spawnedCratesRED = {}    -- use to store crates that have been spawned
    ctld.spawnedCratesBLUE = {}   -- use to store crates that have been spawned

    ctld.droppedTroopsRED = {}    -- stores dropped troop groups
    ctld.droppedTroopsBLUE = {}   -- stores dropped troop groups

    ctld.droppedVehiclesRED = {}  -- stores vehicle groups for c-130 / hercules
    ctld.droppedVehiclesBLUE = {} -- stores vehicle groups for c-130 / hercules

    ctld.inTransitTroops = {}

    ctld.inTransitFOBCrates = {}

    ctld.inTransitSlingLoadCrates = {} -- stores crates that are being transported by helicopters for alternative to real slingload

    ctld.droppedFOBCratesRED = {}
    ctld.droppedFOBCratesBLUE = {}

    ctld.builtFOBS = {}            -- stores fully built fobs

    ctld.completeAASystems = {}    -- stores complete spawned groups from multiple crates

    ctld.fobBeacons = {}           -- stores FOB radio beacon details, refreshed every 60 seconds

    ctld.deployedRadioBeacons = {} -- stores details of deployed radio beacons

    ctld.beaconCount = 1

    ctld.usedUHFFrequencies = {}
    ctld.usedVHFFrequencies = {}
    ctld.usedFMFrequencies = {}

    ctld.freeUHFFrequencies = {}
    ctld.freeVHFFrequencies = {}
    ctld.freeFMFrequencies = {}

    --used to lookup what the crate will contain
    ctld.crateLookupTable = {}

    ctld.extractZones = {}             -- stored extract zones

    ctld.missionEditorCargoCrates = {} -- crates added by mission editor for triggering cratesinzone
    ctld.hoverStatus = {}              -- tracks status of a helis hover above a crate

    ctld.callbacks = {}                -- function callback
    ctld.vehicleCommandsPath = {}      -- memory of F10 c=CTLD menu path bay unitNames

    -- Remove intransit troops when heli / cargo plane dies
    --ctld.eventHandler = {}
    --function ctld.eventHandler:onEvent(_event)
    --
    --        if _event == nil or _event.initiator == nil then
    --                env.info("CTLD null event")
    --        elseif _event.id == 9 then
    --                -- Pilot dead
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --        elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
    --                -- env.info("Event unit - Pilot Ejected or Unit Dead")
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --                -- env.info(_event.initiator:getName())
    --        end
    --
    --end

    -- create crate lookup table
    for _subMenuName, _crates in pairs(ctld.spawnableCrates) do
        for _, _crate in pairs(_crates) do
            -- convert number to string otherwise we'll have a pointless giant
            -- table. String means 'hashmap' so it will only contain the right number of elements
            if _crate.multiple then
                local _totalWeight = 0
                for _, _weight in pairs(_crate.multiple) do
                    _totalWeight = _totalWeight + _weight
                end
                _crate.weight = _totalWeight
            end
            ctld.crateLookupTable[tostring(_crate.weight)] = _crate
        end
    end


    --sort out pickup zones
    for _, _zone in pairs(ctld.pickupZones) do
        local _zoneName = _zone[1]
        local _zoneColor = _zone[2]
        local _zoneActive = _zone[4]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        -- add in counter for troops or units
        if _zone[3] == -1 then
            _zone[3] = 10000;
        end

        -- change active to 1 / 0
        if _zoneActive == "yes" then
            _zone[4] = 1
        else
            _zone[4] = 0
        end
    end

    --sort out dropoff zones
    for _, _zone in pairs(ctld.dropOffZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        _zone[4] = 1
    end

    --sort out waypoint zones
    for _, _zone in pairs(ctld.wpZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        -- change active to 1 / 0
        if _zone[3] == "yes" then
            _zone[3] = 1
        else
            _zone[3] = 0
        end
    end

    -- Sort out extractable groups
    for _, _groupName in pairs(ctld.extractableGroups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            if _group:getCoalition() == 1 then
                table.insert(ctld.droppedTroopsRED, _group:getName())
            else
                table.insert(ctld.droppedTroopsBLUE, _group:getName())
            end
        end
    end


    -- Seperate troop teams into red and blue for random AI pickups
    if ctld.allowRandomAiTeamPickups == true then
        ctld.redTeams = {}
        ctld.blueTeams = {}
        for _, _loadGroup in pairs(ctld.loadableGroups) do
            if not _loadGroup.side then
                table.insert(ctld.redTeams, _)
                table.insert(ctld.blueTeams, _)
            elseif _loadGroup.side == 1 then
                table.insert(ctld.redTeams, _)
            elseif _loadGroup.side == 2 then
                table.insert(ctld.blueTeams, _)
            end
        end
    end

    -- add total count

    for _, _loadGroup in pairs(ctld.loadableGroups) do
        _loadGroup.total = 0
        if _loadGroup.aa then
            _loadGroup.total = _loadGroup.aa + _loadGroup.total
        end

        if _loadGroup.inf then
            _loadGroup.total = _loadGroup.inf + _loadGroup.total
        end


        if _loadGroup.mg then
            _loadGroup.total = _loadGroup.mg + _loadGroup.total
        end

        if _loadGroup.at then
            _loadGroup.total = _loadGroup.at + _loadGroup.total
        end

        if _loadGroup.mortar then
            _loadGroup.total = _loadGroup.mortar + _loadGroup.total
        end
    end

    --*************************************************************************************************
    -- Scheduled functions (run cyclically) -- but hold execution for a second so we can override parts
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 1)
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 5)

    timer.scheduleFunction(function()
        timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.addOtherF10MenuOptions, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.updateDynamicLogisticUnitsZones, nil, timer.getTime() + 5)
        if ctld.enableCrates == true and ctld.hoverPickup == true then
            timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1)
        end
        if ctld.enableRepackingVehicles == true then
            timer.scheduleFunction(ctld.updateRepackMenuOnlanding, nil, timer.getTime() + 1) -- update helo repack menu when a helo landing is detected
            timer.scheduleFunction(ctld.repackVehicle, nil, timer.getTime() + 1)
        end
        if ctld.enableAutoOrbitingFlyingJtacOnTarget then
            timer.scheduleFunction(ctld.TreatOrbitJTAC, {}, timer.getTime() + 3)
        end
        if ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0 then
            timer.scheduleFunction(ctld.updateTroopsInGame, {}, timer.getTime() + 1)
        end
    end, nil, timer.getTime() + 1)

    --event handler for deaths
    --world.addEventHandler(ctld.eventHandler)

    --env.info("CTLD event handler added")

    env.info("Generating Laser Codes")
    ctld.generateLaserCode()
    env.info("Generated Laser Codes")



    env.info("Generating UHF Frequencies")
    ctld.generateUHFrequencies()
    env.info("Generated    UHF Frequencies")

    env.info("Generating VHF Frequencies")
    ctld.generateVHFrequencies()
    env.info("Generated VHF Frequencies")


    env.info("Generating FM Frequencies")
    ctld.generateFMFrequencies()
    env.info("Generated FM Frequencies")

    -- Search for crates
    -- Crates are NOT returned by coalition.getStaticObjects() for some reason
    -- Search for crates in the mission editor instead
    env.info("Searching for Crates")
    for _coalitionName, _coalitionData in pairs(env.mission.coalition) do
        if (_coalitionName == 'red' or _coalitionName == 'blue')
            and type(_coalitionData) == 'table' then
            if _coalitionData.country then --there is a country table
                for _, _countryData in pairs(_coalitionData.country) do
                    if type(_countryData) == 'table' then
                        for _objectTypeName, _objectTypeData in pairs(_countryData) do
                            if _objectTypeName == "static" then
                                if ((type(_objectTypeData) == 'table')
                                        and _objectTypeData.group
                                        and (type(_objectTypeData.group) == 'table')
                                        and (#_objectTypeData.group > 0)) then
                                    for _groupId, _group in pairs(_objectTypeData.group) do
                                        if _group and _group.units and type(_group.units) == 'table' then
                                            for _unitNum, _unit in pairs(_group.units) do
                                                if _unit.canCargo == true then
                                                    local _cargoName = env.getValueDictByKey(_unit.name)
                                                    ctld.missionEditorCargoCrates[_cargoName] = _cargoName
                                                    env.info("Crate Found: " .. _unit.name .. " - Unit: " .. _cargoName)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    env.info("END search for crates")

    -- register event handler
    ctld.logInfo("registering event handler")
    world.addEventHandler(ctld.eventHandler)
    env.info("CTLD READY")
end

--- Handle world events.
ctld.eventHandler = {}
function ctld.eventHandler:onEvent(event)
    --ctld.logTrace("ctld.eventHandler:onEvent()")
    if event == nil then
        ctld.logError("Event handler was called with a nil event!")
        return
    end

    local eventName = "unknown"
    -- check that we know the event
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        eventName = "S_EVENT_PLAYER_ENTER_UNIT"
    elseif event.id == world.event.S_EVENT_BIRTH then
        eventName = "S_EVENT_BIRTH"
    else
        --ctld.logTrace("Ignoring event %s", ctld.p(event))
        return
    end
    ctld.logDebug("caught event %s: %s", ctld.p(eventName), ctld.p(event))

    -- find the originator unit
    local unitName = nil
    if event.initiator ~= nil and event.initiator.getName then
        unitName = event.initiator:getName()
        ctld.logDebug("unitName = [%s]", ctld.p(unitName))
    end
    if not unitName then
        ctld.logInfo("no unitname found in event %s", ctld.p(event))
        return
    end

    local function processHumanPlayer()
        ctld.logTrace("in the 'processHumanPlayer' function processHumanPlayer()- unitName = %s", ctld.p(unitName))
        --ctld.logTrace("in the 'processHumanPlayer' function processHumanPlayer()- CTLD_extAPI.DBs.humansByName[unitName] = %s", ctld.p(CTLD_extAPI.DBs.humansByName[unitName]))
        if CTLD_extAPI.DBs.humansByName[unitName] then -- it's a human unit
            ctld.logDebug("caught event %s for human unit [%s]", ctld.p(eventName), ctld.p(unitName))
            local _unit = Unit.getByName(unitName)
            if _unit ~= nil then
                local _groupId = _unit:getGroup():getID()
                -- assign transport pilot
                ctld.logTrace("_unit = %s", ctld.p(_unit))

                local playerTypeName = _unit:getTypeName()
                ctld.logTrace("playerTypeName = %s", ctld.p(playerTypeName))

                -- Allow units to CTLD by aircraft type and not by pilot name
                if ctld.addPlayerAircraftByType then
                    for _, aircraftType in pairs(ctld.aircraftTypeTable) do
                        if aircraftType == playerTypeName then
                            ctld.logTrace("adding by aircraft type, unitName = %s", ctld.p(unitName))
                            if ctld.tools.isValueInIpairTable(ctld.transportPilotNames, unitName) == false then
                                table.insert(ctld.transportPilotNames, unitName) -- add transport unit to the list
                            end
                            if ctld.addedTo[tostring(_groupId)] == nil then      -- only if menu not already set up
                                ctld.addTransportF10MenuOptions(unitName)        -- add transport radio menu
                                break
                            end
                        end
                    end
                else
                    for _, _unitName in pairs(ctld.transportPilotNames) do
                        if _unitName == unitName then
                            ctld.logTrace("adding by transportPilotNames, unitName = %s", ctld.p(unitName))
                            ctld.addTransportF10MenuOptions(unitName) -- add transport radio menu
                            break
                        end
                    end
                end
            end
        end
    end

    if not CTLD_extAPI.DBs.humansByName[unitName] then
        -- give a few milliseconds for MiST to handle the BIRTH event too
        ctld.logTrace("give MiST some time to handle the BIRTH event too")
        timer.scheduleFunction(function()
            ctld.logTrace("calling the 'processHumanPlayer' function in a timer")
            processHumanPlayer()
        end, nil, timer.getTime() + 2) --1.5
    else
        ctld.logTrace("calling the 'processHumanPlayer' function immediately")
        processHumanPlayer()
    end
end

function ctld.i18n_check(language, verbose)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        ctld.logError(string.format("CTLD.i18n_check: Language %s not found", language))
        return false
    end
    local englishVersion = english.translation_version
    local tocheckVersion = tocheck.translation_version
    if englishVersion ~= tocheckVersion then
        ctld.logError(string.format("CTLD.i18n_check: Language version mismatch: EN has version %s, %s has version %s",
            englishVersion, language, tocheckVersion))
    end
    --ctld.logTrace(string.format("english = %s", ctld.p(english)))
    for textRef, textEnglish in pairs(english) do
        if textRef ~= "translation_version" then
            local textTocheck = tocheck[textRef]
            if not textTocheck then
                ctld.logError(string.format("CTLD.i18n_check: NOT FOUND: checking %s text [%s]", language, textRef))
            elseif textTocheck == textEnglish then
                ctld.logWarning(string.format("CTLD.i18n_check:         SAME: checking %s text [%s] as in EN", language,
                    textRef))
            elseif verbose then
                ctld.logInfo(string.format("CTLD.i18n_check:             OK: checking %s text [%s]", language, textRef))
            end
        end
    end
end

-- example of usage:
--ctld.i18n_check("fr")


-- initialize the random number generator to make it almost random
math.random(); math.random(); math.random()

function ctld.RandomReal(mini, maxi)
    local rand = math.random()                 --random value between 0 and 1
    local result = mini + rand * (maxi - mini) --	scale the random value between [mini, maxi]
    return result
end

-- Tools
ctld.tools = {}
function ctld.tools.isValueInIpairTable(tab, value)
    for i, v in ipairs(tab) do
        if v == value then
            return true -- La valeur existe
        end
    end
    return false -- La valeur n'existe pas
end

------------------------------------------------------------------------------------
--- Calculates the orientation of an end point relative to a reference point.
--- The calculation takes into account the current orientation of the reference point.
---
--- @param refLat number Latitude of the reference point in degrees.
--- @param refLon number Longitude of the reference point in degrees.
--- @param refHeading number Current orientation of the reference point in degrees (0 = North, 90 = East).
--- @param destLat number Latitude of the arrival point in degrees.
--- @param destLon number Longitude of the arrival point in degrees.
--- @param resultFormat string The desired output format: "radian", "degree" or "clock".
--- @return number The relative orientation in the specified resultFormat.
function ctld.tools.getRelativeBearing(refLat, refLon, refHeading, destLat, destLon, resultFormat)
    -- Converting degrees to radians for geometric calculations
    local radrefLat = math.rad(refLat)
    local raddestLat = math.rad(destLat)
    local radrefLon = math.rad(refLon)
    local raddestLon = math.rad(destLon)
    local radrefHeading = math.rad(refHeading)

    -- Calculating the longitude difference between the two points
    local deltaLon = raddestLon - radrefLon

    -- Using the great circle formula for azimuth (bearing)
    -- This formula is based on spherical trigonometry and uses atan2
    -- to correctly handle all quadrants.
    local y = math.sin(deltaLon) * math.cos(raddestLat)
    local x = math.cos(radrefLat) * math.sin(raddestLat) -
        math.sin(radrefLat) * math.cos(raddestLat) * math.cos(deltaLon)
    local absoluteBearingRad = math.atan2(y, x)

    -- Calculate relative orientation by subtracting the reference refHeading
    local relativeBearingRad = absoluteBearingRad - radrefHeading

    -- Normalizes the angle to be in the range [-pi, pi]
    -- This ensures a consistent angle, whether positive or negative.
    local normalizedRad = (relativeBearingRad + math.pi) % (2 * math.pi) - math.pi

    -- Returns the value in the requested resultFormat
    if resultFormat == "radian" then
        return normalizedRad, resultFormat
    elseif resultFormat == "clock" then
        -- Convert to clock position (12h = front, 3h = right, 6h = back, etc..)
        local bearingDeg = math.deg(normalizedRad)
        local clockPosition = ((bearingDeg + 360) % 360) / 30
        clockPosition = clockPosition >= 0 and math.floor(clockPosition + 0.5) or math.ceil(clockPosition - 0.5),
            resultFormat -- rounded clockPosition
        if clockPosition == 0 then clockPosition = 12 end
        return clockPosition, resultFormat
    else -- By default, the resultFormat is "degree"
        resultFormat = "degree"
        local bearingDeg = math.deg(normalizedRad)
        return (bearingDeg + 360) % 360, resultFormat
    end
end

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

-- initialize CTLD
-- if you need to have a chance to modify the configuration before initialization in your other scripts, please set ctld.dontInitialize to true and call ctld.initialize() manually
if ctld.dontInitialize then
    ctld.logInfo(string.format("Skipping initializion of version %s because ctld.dontInitialize is true", ctld.Version))
else
    ctld.initialize()
end
-- End : CTLD.lua 
-- ==================================================================================================== 
-- Start : CTLD_extAPI.lua 
-- ================================================================
-- CTLD_extAPI.lua
-- Explicit indirections to MIST / MOOSE (no wrapper system)
-- ================================================================

if trigger == nil then
    trigger = { action = { outText = function(msg, time) print('[DCS outText] ' .. msg) end } }
end

CTLD_extAPI = CTLD_extAPI or {}

local framework = nil
local frameworkName = nil

if mist ~= nil then
    framework = mist
    frameworkName = 'MIST'
elseif Moose ~= nil then
    framework = Moose
    frameworkName = 'MOOSE'
else
    local msg = '[CTLD_extAPI ERROR] No framework detected (mist == nil and Moose == nil)'
    if trigger and trigger.action and trigger.action.outText then
        trigger.action.outText(msg, 20)
    else
        print(msg)
    end
    if env and env.info then env.info(msg) end
end

local function logError(msg)
    if trigger and trigger.action and trigger.action.outText then
        trigger.action.outText(msg, 15)
    else
        print(msg)
    end
    if env and env.info then env.info(msg) end
end

-- ================================================================
-- DBs
-- ================================================================

CTLD_extAPI.DBs              = CTLD_extAPI.DBs or {}

CTLD_extAPI.DBs.humansByName = framework and framework.DBs and framework.DBs.humansByName or nil
CTLD_extAPI.DBs.unitsById    = framework and framework.DBs and framework.DBs.unitsById or nil
CTLD_extAPI.DBs.unitsByName  = framework and framework.DBs and framework.DBs.unitsByName or nil

-- ================================================================
-- Top-level functions
-- ================================================================

CTLD_extAPI.dynAdd           = function(caller, ...)
    if not (framework and framework.dynAdd) then
        logError('[CTLD_extAPI ERROR] dynAdd unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.dynAdd(...)
end

CTLD_extAPI.dynAddStatic     = function(caller, ...)
    if not (framework and framework.dynAddStatic) then
        logError('[CTLD_extAPI ERROR] dynAddStatic unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.dynAddStatic(...)
end

CTLD_extAPI.tostringLL       = function(caller, ...)
    if not (framework and framework.tostringLL) then
        logError('[CTLD_extAPI ERROR] tostringLL unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.tostringLL(...)
end

CTLD_extAPI.tostringMGRS     = function(caller, ...)
    if not (framework and framework.tostringMGRS) then
        logError('[CTLD_extAPI ERROR] tostringMGRS unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.tostringMGRS(...)
end

-- ================================================================
-- End of CTLD_extAPI.lua
-- ================================================================
-- End : CTLD_extAPI.lua 
