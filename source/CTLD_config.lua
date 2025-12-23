-- CTLDConfig Singleton Class
CTLDConfig = {}
CTLDConfig._instance = nil

-- Get the unique instance of the config
function CTLDConfig.get()
    if CTLDConfig._instance == nil then
        CTLDConfig._instance = setmetatable({}, { __index = CTLDConfig })
        CTLDConfig._instance.settings = {}
        CTLDConfig._instance.isLoaded = false
    end
    return CTLDConfig._instance
end

-- Load settings from the text file
function CTLDConfig:load()
    if self.isLoaded then
        return true, "CTLDConfig: Configuration already loaded."
    end
    self.isLoaded                                         = true

    -- ****************************************************************
    -- ******************** DEFAULT CONFIGURATION AREA ****************
    -- ****************************************************************
    self.settings["staticBugWorkaround"]                  = false --    DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE
    self.settings["disableAllSmoke"]                      = false -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below
    self.settings["addPlayerAircraftByType"]              = true  -- Allow units to CTLD by aircraft type and not by pilot name - this is done everytime a player enters a new units
    self.settings["hoverPickup"]                          = true  --    if set to false you can load crates with the F10 menu instead of hovering... Only if not using real crates!
    self.settings["loadCrateFromMenu"]                    = true  -- if set to true, you can load crates with the F10 menu OR hovering, in case of using choppers and planes for example.
    self.settings["enableCrates"]                         = true  -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
    self.settings["enableAllCrates"]                      = true  -- if false, the "all crates" menu items will not be displayed
    self.settings["slingLoad"]                            = false -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
    -- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
    -- to use the other method.
    -- Set staticBugFix    to FALSE if use set ctld.slingLoad to TRUE
    self.settings["enableSmokeDrop"]                      = true                                          -- if false, helis and c-130 will not be able to drop smoke
    self.settings["maxExtractDistance"]                   = 125                                           -- max distance from vehicle to troops to allow a group extraction
    self.settings["maximumDistanceLogistic"]              = 200                                           -- max distance from vehicle to logistics to allow a loading or spawning operation
    self.settings["enableRepackingVehicles"]              = true                                          -- if true, vehicles can be repacked into crates
    self.settings["maximumDistanceRepackableUnitsSearch"] = 200                                           -- max distance from transportUnit to search force repackable units in meters
    self.settings["maximumSearchDistance"]                = 4000                                          -- max distance for troops to search for enemy
    self.settings["maximumMoveDistance"]                  = 2000                                          -- max distance for troops to move from drop point if no enemy is nearby
    self.settings["minimumDeployDistance"]                = 1000                                          -- minimum distance from a friendly pickup zone where you can deploy a crate
    self.settings["numberOfTroops"]                       = 10                                            -- default number of troops to load on a transport heli or C-130
    -- also works as maximum size of group that'll fit into a helicopter unless overridden
    self.settings["enableFastRopeInsertion"]              = true                                          -- allows you to drop troops by fast rope
    self.settings["fastRopeMaximumHeight"]                = 18.28                                         -- in meters which is 60 ft max fast rope (not rappell) safe height
    self.settings["vehiclesForTransportRED"]              = { "BRDM-2", "BTR_D" }                         -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
    self.settings["vehiclesForTransportBLUE"]             = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}
    self.settings["vehiclesWeight"]                       = {
        ["BRDM-2"] = 7000,
        ["BTR_D"] = 8000,
        ["M1045 HMMWV TOW"] = 3220,
        ["M1043 HMMWV Armament"] = 2500
    }


    self.settings["spawnRPGWithCoalition"]     = true  --spawns a friendly RPG unit with Coalition forces
    self.settings["spawnStinger"]              = false -- spawns a stinger / igla soldier with a group of 6 or more soldiers!
    self.settings["enabledFOBBuilding"]        = true  -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
    -- In future i'd like it to be a FARP but so far that seems impossible...
    -- You can also enable troop Pickup at FOBS
    self.settings["cratesRequiredForFOB"]      = 3 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
    -- The large crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled
    -- Small FOB crates can be moved by helicopter. The FOB will require ctld.cratesRequiredForFOB larges crates and small crates are 1/3 of a large fob crate
    -- To build the FOB entirely out of small crates you will need ctld.cratesRequiredForFOB * 3

    self.settings["troopPickupAtFOB"]          = true     -- if true, troops can also be picked up at a created FOB
    self.settings["buildTimeFOB"]              = 120      --time in seconds for the FOB to be built
    self.settings["crateWaitTime"]             = 40       -- time in seconds to wait before you can spawn another crate
    self.settings["forceCrateToBeMoved"]       = true     -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam
    self.settings["radioSound"]                =
    "beacon.ogg"                                          -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
    self.settings["radioSoundFC3"]             =
    "beaconsilent.ogg"                                    -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)
    self.settings["deployedBeaconBattery"]     = 30       -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed
    self.settings["enabledRadioBeaconDrop"]    = true     -- if its set to false then beacons cannot be dropped by units
    self.settings["allowRandomAiTeamPickups"]  = false    -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones
    -- Limit the dropping of infantry teams -- this limit control is inactive if ctld.nbLimitSpawnedTroops = {0, 0} ----
    self.settings["nbLimitSpawnedTroops"]      = { 0, 0 } -- {redLimitInfantryCount, blueLimitInfantryCount} when this cumulative number of troops is reached, no more troops can be loaded onboard
    self.settings["InfantryInGameCount"]       = { 0, 0 } -- {redCoaInfantryCount, blueCoaInfantryCount}

    -- Simulated Sling load configuration
    self.settings["minimumHoverHeight"]        = 7.5  -- Lowest allowable height for crate hover
    self.settings["maximumHoverHeight"]        = 12.0 -- Highest allowable height for crate hover
    self.settings["maxDistanceFromCrate"]      = 5.5  -- Maximum distance from from crate for hover
    self.settings["hoverTime"]                 = 10   -- Time to hold hover above a crate for loading in seconds

    -- end of Simulated Sling load configuration

    -- ***************** AA SYSTEM CONFIG *****************
    self.settings["aaLaunchers"]               = 3 -- controls how many launchers to add to the AA systems when its spawned if no amount is specified in the template.
    -- Sets a limit on the number of active AA systems that can be built for RED.
    -- A system is counted as Active if its fully functional and has all parts
    -- If a system is partially destroyed, it no longer counts towards the total
    -- When this limit is hit, a player will still be able to get crates for an AA system, just unable
    -- to unpack them

    self.settings["AASystemLimitRED"]          = 20 -- Red side limit
    self.settings["AASystemLimitBLUE"]         = 20 -- Blue side limit

    -- Allows players to create systems using as many crates as they like
    -- Example : an amount X of patriot launcher crates allows for Y launchers to be deployed, if a player brings 2*X+Z crates (Z being lower then X), then deploys the patriot site, 2*Y launchers will be in the group and Z launcher crate will be left over

    self.settings["AASystemCrateStacking"]     = false
    --END AA SYSTEM CONFIG ------------------------------------

    -- ***************** JTAC CONFIGURATION *****************
    self.settings["JTAC_LIMIT_RED"]            = 10    -- max number of JTAC Crates for the RED Side
    self.settings["JTAC_LIMIT_BLUE"]           = 10    -- max number of JTAC Crates for the BLUE Side
    self.settings["JTAC_dropEnabled"]          = true  -- allow JTAC Crate spawn from F10 menu
    self.settings["JTAC_maxDistance"]          = 10000 -- How far a JTAC can "see" in meters (with Line of Sight)
    self.settings["JTAC_smokeOn_RED"]          = false -- enables marking of target with smoke for RED forces
    self.settings["JTAC_smokeOn_BLUE"]         = false -- enables marking of target with smoke for BLUE forces
    self.settings["JTAC_smokeColour_RED"]      = 4     -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
    self.settings["JTAC_smokeColour_BLUE"]     = 1     -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
    self.settings["JTAC_smokeMarginOfError"]   = 50    -- error that the JTAC is allowed to make when popping a smoke (in meters)
    self.settings["JTAC_smokeOffset_x"]        = 0.0   -- distance in the X direction from target to smoke (meters)
    self.settings["JTAC_smokeOffset_y"]        = 2.0   -- distance in the Y direction from target to smoke (meters)
    self.settings["JTAC_smokeOffset_z"]        = 0.0   -- distance in the z direction from target to smoke (meters)
    self.settings["JTAC_jtacStatusF10"]        = true  -- enables F10 JTAC Status menu
    self.settings["JTAC_location"]             = true  -- shows location of target in JTAC message
    self.settings["location_DMS"]              = false -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes
    self.settings["JTAC_lock"]                 =
    "all"                                              -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units
    self.settings["JTAC_allowStandbyMode"]     = true  -- if true, allow players to toggle lasing on/off
    self.settings["JTAC_laseSpotCorrections"]  = true  -- if true, each JTAC will have a special option (toggle on/off) available in it's menu to attempt to lead the target, taking into account current wind conditions and the speed of the target (particularily useful against moving heavy armor)
    self.settings["JTAC_allowSmokeRequest"]    = true  -- if true, allow players to request a smoke on target (temporary)
    self.settings["JTAC_allow9Line"]           = true  -- if true, allow players to ask for a 9Line (individual) for a specific JTAC's target

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
    self.settings["pickupZones"]               = {
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
    self.settings["dropOffZones"]              = {
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
    self.settings["wpZones"]                   = {
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
    self.settings["aircraftTypeTable"]         = {
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
        "C-130J-30",

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
    self.settings["transportPilotNames"]       = {
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
    self.settings["extractableGroups"]         = {
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
    self.settings["dynamicLogisticUnitsIndex"] = 0 -- This is the unit that will be spawned first and then subsequent units will be from the next in the list
    self.settings["logisticUnits"]             = {
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
    self.settings["vehicleTransportEnabled"]   = {
        "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
        "Hercules",
        "C-130J-30",
        --"CH-47Fbl1",
    }

    -- ************** Units able to use DCS dynamic cargo system ******************
    -- DCS (version) added the ability to load and unload cargo from aircraft.
    -- Units listed here will spawn a cargo static that can be loaded with the standard DCS cargo system
    -- We will also use this to make modifications to the menu and other checks and messages
    self.settings["dynamicCargoUnits"]         = {
        "CH-47Fbl1",
        "UH-1H",
        "Mi-8MT",
        "Mi-24P",
        "C-130J-30"
    }

    -- ************** Maximum Units SETUP for UNITS ******************
    -- Put the name of the Unit you want to limit group sizes too
    -- i.e
    -- ["UH-1H"] = 10,
    --
    -- Will limit UH1 to only transport groups with a size 10 or less
    -- Make sure the unit name is exactly right or it wont work

    self.settings["unitLoadLimits"]            = {
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
        ["C-130J-30"] = 80

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
    self.settings["internalCargoLimits"]       = {

        -- Remove the -- below to turn on options
        ["Mi-8MT"] = 2,
        ["CH-47Fbl1"] = 8,
        ["C-130J-30"] = 20
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

    self.settings["unitActions"] = {

        -- Remove the -- below to turn on options
        -- ["SA342Mistral"] = {crates=true, troops=true},
        -- ["SA342L"] = {crates=false, troops=true},
        -- ["SA342M"] = {crates=false, troops=true},

        --%%%%% MODS %%%%%
        --["Bronco-OV-10A"] = {crates=true, troops=true},
        ["Hercules"] = { crates = true, troops = true },
        ["SK-60"] = { crates = true, troops = true },
        ["UH-60L"] = { crates = true, troops = true },
        ["C-130J-30"] = { crates = true, troops = true },
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

    self.settings["SOLDIER_WEIGHT"] = 80 -- kg, will be randomized between 90% and 120%
    self.settings["KIT_WEIGHT"] = 20     -- kg
    self.settings["RIFLE_WEIGHT"] = 5    -- kg
    self.settings["MANPAD_WEIGHT"] = 18  -- kg
    self.settings["RPG_WEIGHT"] = 7.6    -- kg
    self.settings["MG_WEIGHT"] = 10      -- kg
    self.settings["MORTAR_WEIGHT"] = 26  -- kg
    self.settings["JTAC_WEIGHT"] = 15    -- kg

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
    self.settings["loadableGroups"] = {
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
    self.settings["spawnableCrates"] = {
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
    }

    self.settings["spawnableCratesModels"] = {
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
    self.settings["jtacUnitTypes"]     = {
        "SKP", "Hummer",                      -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
        "MQ", "RQ"                            --"MQ-9 Repear", "RQ-1A Predator"}
    }
    self.settings["jtacDroneRadius"]   = 1000 -- JTAC offset radius in meters for orbiting drones
    self.settings["jtacDroneAltitude"] = 7000 -- JTAC altitude in meters for orbiting drones

    -- ******************************************************************
    -- ****************** END OF CONFIGURATION AREA *********************
    -- ******************************************************************

    -- overwrite defaults settings from CTLD_userConfig.lua --------------------------------------------
    if ctld.yamlConfigDatas then
        local userConfigTable = CTLDConfig.parseYAML(ctld.yamlConfigDatas) -- get user config coming from CTLD_userConfig.lua execution in ME

        local report = "REPORT - CTLD user config loaded :"
        for k, v in pairs(userConfigTable) do
            local tableName, fieldName = k:match("([^%.]+)%.(.+)") -- extract key after "ctld."
            if tableName == "ctld" then                            -- load generals settings
                --ctld[fieldName] = v
                self.settings["fieldName"] = v
                report = report .. "\nctld." .. fieldName .. " = " .. tostring(ctld[fieldName])
            end
        end
        return true, report
    else
        env.info("CTLDConfig: No YAML config data found in ctld.yamlConfigDatas")
    end

    -- Temporary: Loading old ctld settings variables for backward compatibility
    if ctld ~= nil then
        for k, v in pairs(CTLDConfig.getAllSettings()) do
            if self.settings[k] ~= nil then
                ctld[k] = v -- set old ctld variables
            end
        end
    end
end

-- Retrieve a specific setting
function CTLDConfig:getSetting(key)
    return self.settings[key]
end

-- Retrieve a specific setting
function CTLDConfig.getAllSettings()
    return CTLDConfig._instance.settings
end

------------------------------------------------------------------
-- yaml parsing utilities
------------------------------------------------------------------
-- Utility: Trims whitespace from both ends of a string
-- @param s: The raw string to trim
function CTLDConfig.trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Utility: Converts string values to their appropriate Lua types
-- @param v: The string value to convert
function CTLDConfig.to_type(v)
    if v == "true" then return true end
    if v == "false" then return false end
    if tonumber(v) then return tonumber(v) end
    return v:gsub("^['\"]", ""):gsub("['\"]$", "")
end

-- Main Parser: Converts a YAML-formatted string into a Lua Table
function CTLDConfig.parseYAML(data)
    local result = {}
    local stack = { result }
    local indentStack = { -1 }

    local literalMode = false
    local literalKey, literalIndent = "", 0
    local literalLines = {}

    for line in data:gmatch("[^\r\n]+") do
        local indent = line:match("^%s*"):len()
        local content = CTLDConfig.trim(line)

        -- 1. EXIT MULTILINE MODE
        if literalMode and #content > 0 and indent <= literalIndent then
            stack[#stack][literalKey] = table.concat(literalLines, "\n")
            literalMode = false
            literalLines = {}
        end

        -- 2. PROCESSING
        if literalMode then
            literalLines[#literalLines + 1] = line:sub(literalIndent + 3) or ""
        elseif content ~= "" and not content:match("^#") then
            -- STACK REALIGNMENT
            while #indentStack > 1 and indent <= indentStack[#indentStack] do
                table.remove(stack)
                table.remove(indentStack)
            end

            -- Check for list item with key attached (- polar:)
            local listDashKey, listDashValue = content:match("^%- ([^:]+):%s*(.*)")
            local key, value

            if listDashKey then
                -- NEW LIST ITEM OBJECT
                local newEntry = {}
                local parent = stack[#stack]
                parent[#parent + 1] = newEntry

                -- We push the entry into the stack
                table.insert(stack, newEntry)
                table.insert(indentStack, indent)

                key, value = listDashKey, listDashValue
                -- Important: update indent to match the key position after the dash
                indent = line:find(listDashKey) - 1
            else
                -- Standard key:value
                key, value = content:match("([^:]+):%s*(.*)")
            end

            if key then
                key, value = CTLDConfig.trim(key), CTLDConfig.trim(value)
                if value == "|" then
                    literalMode, literalKey, literalIndent = true, key, indent
                    literalLines = {}
                elseif value == "" then
                    -- Nested object
                    local newSubTable = {}
                    stack[#stack][key] = newSubTable
                    -- Move into the sub-table
                    table.insert(stack, newSubTable)
                    table.insert(indentStack, indent)
                else
                    -- Simple assignment
                    stack[#stack][key] = CTLDConfig.to_type(value)
                end
            elseif content:match("^%-") then
                -- Simple list item (- SAM-6)
                local item = CTLDConfig.trim(content:sub(2))
                local parent = stack[#stack]
                if type(parent) == "table" then
                    parent[#parent + 1] = CTLDConfig.to_type(item)
                end
            end
        end
    end

    if literalMode then stack[#stack][literalKey] = table.concat(literalLines, "\n") end
    return result
end

--[[
------------------------------------------------------------------
-- Example: At start of CTLD initialization : Load ctld user config from CTLD_userConfig.lua
-- and set the ctld settings accordingly
-- ctld.yamlConfigDatas must be loaded beforehand by executing CTLD_userConfig.lua in the mission editor
-- with a trigger at START MISSION in "DO SCRIPT FILE" action
------------------------------------------------------------------

local myConfig = CTLDConfig.get()   -- Get the singleton instance
local success, report = myConfig:load()   -- Load the data from your specific path
if success then
    trigger.action.outText(report, 10)    -- Display the result if loading was successful
end

--At this stage, the ctld configuration settings are loaded with the user's values.


------------------------------------------------------------------
--- How to use the CTLDConfig singleton class in your scripts
--- to get ex "ctld.maximumDistanceLogistic = 200" value
------------------------------------------------------------------
local config = CTLDConfig.get()                                        -- get the singleton instance
local maximumDistanceLogistic = config:getSetting("maximumDistanceLogistic")  -- retrieve specific setting
-- Now you can use maximumDistanceLogistic in your script

-- You can also modify settings:
config:setSetting("maximumDistanceLogistic", 250)

-- To completely reset the singleton (useful for testing):
CTLDConfig.reset()  -- ALEX - Avec "." car méthode de classe
]] --
