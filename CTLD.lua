--[[
    Combat Troop and Logistics Drop

    Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
    without requiring external mods.

    Supports some of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

    Supports deployment of Auto Lasing JTAC to the field

    See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

    Version: 1.06 - 29/05/2015 - Event Bug Fix from Latest DCS Patch

 ]]

ctld = {} -- DONT REMOVE!

-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************
ctld.disableAllSmoke = false -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below

ctld.enableCrates = true -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS

ctld.enableSmokeDrop = true -- if false, helis and c-130 will not be able to drop smoke

ctld.maxExtractDistance = 125 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic = 200 -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.maximumSearchDistance = 4000 -- max distance for troops to search for enemy
ctld.maximumMoveDistance = 1000 -- max distance for troops to move from drop point if no enemy is nearby

ctld.numberOfTroops = 10 -- default number of troops to load on a transport heli or C-130

ctld.vehiclesForTransportRED = { "BRDM-2", "BTR_D" } -- vehicles to load onto Il-76
ctld.vehiclesForTransportBLUE = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130

ctld.spawnRPGWithCoalition = true --spawns a friendly RPG unit with Coalition forces

ctld.enabledFOBBuilding = true -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
-- In future i'd like it to be a FARP but so far that seems impossible...
-- You can also enable troop Pickup at FOBS

ctld.cratesRequiredForFOB = 3 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
-- The crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled

ctld.troopPickupAtFOB = true -- if true, troops can also be picked up at a created FOB

ctld.buildTimeFOB = 120 --time in seconds for the FOB to be built

ctld.radioSound = "beacon.ogg" -- the name of the sound file to use for the FOB radio beacons

-- ***************** JTAC CONFIGURATION *****************

ctld.JTAC_LIMIT_RED = 5 -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE = 5 -- max number of JTAC Crates for the BLUE Side

ctld.JTAC_dropEnabled = true -- allow JTAC Crate spawn from F10 menu

ctld.JTAC_maxDistance = 5000 -- How far a JTAC can "see" in meters (with Line of Sight)

ctld.JTAC_smokeOn_RED = true -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE = true -- enables marking of target with smoke for BLUE forces

ctld.JTAC_smokeColour_RED = 4 -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE = 1 -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4

ctld.JTAC_jtacStatusF10 = true -- enables F10 JTAC Status menu

ctld.JTAC_location = true -- shows location of target in JTAC message

ctld.JTAC_lock =  "all" -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units

-- ***************** Pickup and dropoff zones *****************

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",

-- Use any of the predefined names or set your own ones

ctld.pickupZones = {
    { "pickzone1", "blue" },
    { "pickzone2", "blue" },
    { "pickzone3", "none" },
    { "pickzone4", "none" },
    { "pickzone5", "none" },
    { "pickzone6", "none" },
    { "pickzone7", "none" },
    { "pickzone8", "none" },
    { "pickzone9", "none" },
    { "pickzone10", "none" },
}

ctld.dropOffZones = {
    { "dropzone1", "red" },
    { "dropzone2", "blue" },
    { "dropzone3", "none" },
    { "dropzone4", "none" },
    { "dropzone5", "none" },
    { "dropzone6", "none" },
    { "dropzone7", "none" },
    { "dropzone8", "none" },
    { "dropzone9", "none" },
    { "dropzone10", "none" },
}

-- ******************** Transports names **********************

-- Use any of the predefined names or set your own ones

ctld.transportPilotNames = {
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

ctld.extractableGroups = {
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

ctld.logisticUnits = {
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
ctld.vehicleTransportEnabled = {
    "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
    "C-130",
}


-- ************** SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
ctld.spawnableCrates = {

    -- name of the sub menu on F10 for spawning crates
    ["Ground Forces"] = {

        --crates you can spawn
        -- weight in KG
        -- Desc is the description on the F10 MENU
        -- unit is the model name of the unit to spawn
        -- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
        -- side is optional but 2 is BLUE and 1 is RED
        -- dont use that option with the HAWK Crates
        { weight = 1400, desc = "HMMWV - TOW", unit = "M1045 HMMWV TOW" , side = 2 },
        { weight = 1200, desc = "HMMWV - MG", unit = "M1043 HMMWV Armament", side = 2 },

        { weight = 1700, desc = "BTR-D", unit =  "BTR_D", side = 1 },
        { weight = 1900, desc = "BRDM-2", unit =  "BRDM-2", side = 1 },

        { weight = 1100, desc = "HMMWV - JTAC", unit = "Hummer", side = 2,  }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 1500, desc = "SKP-11 - JTAC", unit = "SKP-11", side = 1,  }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled

        { weight = 200, desc = "2B11 Mortar", unit = "2B11 mortar" },
        -- { weight = 500, desc = "M-109", unit = "M-109", cratesRequired = 3 },
    },

    ["AA Crates"] = {

        { weight = 210, desc = "Stinger", unit = "Stinger manpad", side = 2 },
        { weight = 215, desc = "Igla", unit = "SA-18 Igla manpad", side = 1 },

        { weight = 1000, desc = "HAWK Launcher", unit = "Hawk ln" },
        { weight = 1010, desc = "HAWK Search Radar", unit = "Hawk sr" },
        { weight = 1020, desc = "HAWK Track Radar", unit = "Hawk tr" },
        --   { weight = 505, desc =  "M6 Linebacker", unit = "M6 Linebacker", cratesRequired = 3 },
    },

}

-- if the unit is on this list, it will be made into a JTAC
ctld.jtacUnitTypes = {
    "SKP","Hummer" -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
}

-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************


-----------------------------------------------------------------
-- Spawn group at a trigger and set them as extractable. Usage:
-- 			ctld.spawnGroupAtTrigger("groupside", number, "triggerName", radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn
-- "triggerName" = trigger name in mission editor between commas
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtTrigger("red", 2, "spawn1", 1000)
--
-- This example will spawn 2 groups of russians at trigger "spawn1"
-- and they will search for enemy or move randomly withing 1000m
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    local _spawnTrigger = trigger.misc.getZone(_triggerName) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find trigger called " .. _triggerName, 10)
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

    if _number < 1 then
        _number = 1
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _groupDetails = ctld.generateTroopTypes(_groupSide,_number,_country)

    local _droppedTroops = ctld.spawnDroppedGroup(_pos3, _groupDetails, false,_searchRadius);

    if _groupSide == 1 then

        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else

        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end

end


-- Preloads a transport with troops or vehicles
-- replaces any troops currently on board
function ctld.preLoadTransport(_unitName, _number,_troops)

    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then

        -- will replace any units currently on board
        --        if not ctld.troopsOnboard(_unit,_troops)  then
        ctld.loadTroops(_unit,_troops,_number)
        --        end
    end

end



-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

---------------- INTERNAL FUNCTIONS ----------------

function ctld.getTransportUnit(_unitName)

    if _unitName == nil then
        return nil
    end

    local _heli = Unit.getByName(_unitName)

    if _heli ~= nil and _heli:isActive() and _heli:getLife() > 0 then

        return _heli
    end

    return nil
end

function ctld.spawnCrateStatic(_country,_unitId,_point,_name,_weight)

    local _crate = {
        ["category"] = "Cargo",
        ["shape_name"] = "ab-212_cargo",
        ["type"] = "Cargo1",
        ["unitId"] = _unitId,
        ["y"] = _point.z ,
        ["x"] = _point.x ,
        ["mass"] = _weight,
        ["name"] = _name,
        ["canCargo"] = true,
        ["heading"] = 0,
        --            ["displayName"] = "name 2", -- getCargoDisplayName function exists but no way to set the variable
        --            ["DisplayName"] = "name 2",
        --            ["cargoDisplayName"] = "cargo123",
        --            ["CargoDisplayName"] = "cargo123",
    }

    local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end

function ctld.spawnFOBCrateStatic(_country,_unitId,_point,_name)

    local _crate = {
        ["category"] = "Fortifications",
        ["shape_name"] = "konteiner_red1",
        ["type"] = "Container red 1",
        ["unitId"] = _unitId,
        ["y"] = _point.z ,
        ["x"] = _point.x ,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    local  _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end


function ctld.spawnFOB(_country,_unitId,_point,_name)

    local _crate = {
        ["category"] = "Fortifications",
        ["type"] = "outpost",
        ["unitId"] = _unitId,
        ["y"] = _point.z ,
        ["x"] = _point.x ,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    local _id = mist.getNextUnitId()
    local _tower = {
        ["type"] = "house2arm",
        ["unitId"] = _id,
        ["rate"] = 100,
        ["y"] = _point.z + -36.57142857,
        ["x"] = _point.x + 14.85714286,
        ["name"] = "FOB Watchtower #".._id,
        ["category"] = "Fortifications",
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    coalition.addStaticObject(_country, _tower)

    return _spawnedCrate
end

--function ctld.spawnFARP(_country,_point)
--
--    local _crate = {
--        ["type"] = "FARP",
--        ["unitId"] = _unitId,
--        ["heliport_modulation"] = 0,
--        ["y"] = _point.z+1,
--        ["x"] = _point.x+1,
--        ["name"] = _name,
--        ["category"] = "Heliports",
--        ["canCargo"] = false,
--        ["heliport_frequency"] = 127.5,
--        ["heliport_callsign_id"] = 1,
--        ["heading"] = 3.1415926535898,
--
--    }
--
--
--    local _farpPiece =   {
--        ["shape_name"] = "PalatkaB",
--        ["type"] = "FARP Tent",
--
--        ["y"] = _point.z+1.5,
--        ["x"] = _point.x+1.5,
--        ["name"] = "Unit #"..mist.getNextUnitId(),
--        ["unitId"] = mist.getNextUnitId(),
--        ["category"] = "Fortifications",
--        ["heading"] = 3.1415926535898,
--    }
--
--    coalition.addStaticObject(_country, _farpPiece)
--    local _farpPiece =      {
--        ["shape_name"] = "SetkaKP",
--        ["type"] = "FARP Ammo Dump Coating",
--
--        ["y"] = _point.z+2,
--        ["x"] = _point.x+2,
--        ["name"] = "Unit #"..mist.getNextUnitId(),
--        ["unitId"] = mist.getNextUnitId(),
--        ["category"] = "Fortifications",
--        ["heading"] = 3.1415926535898,
--    }
--    coalition.addStaticObject(_country, _farpPiece)
--    local _farpPiece =     {
--        ["shape_name"] = "GSM Rus",
--        ["type"] = "FARP Fuel Depot",
--
--        ["y"] = _point.z+2.5,
--        ["x"] = _point.x+2.5,
--        ["name"] = "Unit #"..mist.getNextUnitId(),
--        ["unitId"] = mist.getNextUnitId(),
--        ["category"] = "Fortifications",
--        ["heading"] = 3.1415926535898,
--    }
--    coalition.addStaticObject(_country, _farpPiece)
--
--
--
--    local _farpUnits = {
--        {
--
--            ["type"] = "M978 HEMTT Tanker",
--            ["name"] = "Unit #"..mist.getNextUnitId(),
--            ["unitId"] = mist.getNextUnitId(),
--            ["heading"] = 4.7822021504645,
--            ["playerCanDrive"] = true,
--            ["skill"] = "Average",
--            ["x"] = _point.x,
--            ["y"] = _point.z,
--        },
--        {
--
--            ["type"] = "M 818",
--            ["name"] = "Unit #"..mist.getNextUnitId(),
--            ["unitId"] = mist.getNextUnitId(),
--            ["heading"] = 4.7822021504645,
--            ["playerCanDrive"] = true,
--            ["skill"] = "Average",
--            ["x"] = _point.x,
--            ["y"] = _point.z,
--
--        },
--        {
--
--            ["type"] = "M-113",
--            ["name"] = "Unit #"..mist.getNextUnitId(),
--            ["unitId"] = mist.getNextUnitId(),
--            ["heading"] = 4.7822021504645,
--            ["playerCanDrive"] = true,
--            ["skill"] = "Average",
--            ["x"] = _point.x,
--            ["y"] = _point.z,
--
--        },
--    }
--
--    mist.dynAdd({units = _farpUnits,country=_country,category=Group.Category.GROUND})
--
--end

function ctld.spawnCrate(_args)

    -- use the cargo weight to guess the type of unit as no way to add description :(

    local _crateType = ctld.crateLookupTable[tostring(_args[2])]
    local _heli = ctld.getTransportUnit(_args[1])

    if _crateType ~= nil and _heli ~= nil and _heli:inAir() == false then

        if ctld.inLogisticsZone(_heli) == false then

            ctld.displayMessageToGroup(_heli, "You are not close enough to friendly logistics to get a crate!", 10)

            return
        end

        if ctld.isJTACUnitType(_crateType.unit)  then

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
                ctld.displayMessageToGroup(_heli, "No more JTAC Crates Left!",10)
                return
            end

        end

        local _position = _heli:getPosition()

        --try to spawn at 12 oclock to us
        local _angle = math.atan2(_position.x.z, _position.x.x)
        local _xOffset = math.cos(_angle) * 30
        local _yOffset = math.sin(_angle) * 30

        --   trigger.action.outText("Spawn Crate".._args[1].." ".._args[2],10)

        local _heli = ctld.getTransportUnit(_args[1])

        local _point = _heli:getPoint()

        local _unitId = mist.getNextUnitId()

        local _side = _heli:getCoalition()

        local _name = string.format("%s #%i", _crateType.desc, _unitId)

        local _spawnedCrate =  ctld.spawnCrateStatic(_heli:getCountry(),_unitId,{x=_point.x+_xOffset,z=_point.z + _yOffset},_name,_crateType.weight)

        if _side == 1 then
            --   _spawnedCrate = coalition.addStaticObject(_side, _spawnedCrate)
            ctld.spawnedCratesRED[_name] = _crateType
        else
            --   _spawnedCrate = coalition.addStaticObject(_side, _spawnedCrate)
            ctld.spawnedCratesBLUE[_name] = _crateType
        end

        ctld.displayMessageToGroup(_heli, string.format("A %s crate weighing %s kg has been brought out and is at your 12 o'clock ", _crateType.desc, _crateType.weight), 20)

    else
        env.info("Couldn't find crate item to spawn")
    end
end

function ctld.troopsOnboard(_heli,_troops)

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


function ctld.deployTroops(_heli,_troops)

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    -- deloy troops
    if _troops then

        if _onboard.troops ~= nil and #_onboard.troops.units > 0 then

            local _droppedTroops = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.troops, false)

            if _heli:getCoalition() == 1 then

                table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
            else

                table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
            end

            ctld.inTransitTroops[_heli:getName()].troops = nil
            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " dropped troops from " .. _heli:getTypeName() .. " into combat", 10)

        end
    else
        if _onboard.vehicles ~= nil and #_onboard.vehicles.units > 0 then

            local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.vehicles, true)

            if _heli:getCoalition() == 1 then

                table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
            else

                table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
            end

            ctld.inTransitTroops[_heli:getName()].vehicles = nil

            trigger.action.outTextForCoalition(_heli:getCoalition(),ctld.getPlayerNameOrType(_heli) .. " dropped vehicles from " .. _heli:getTypeName() .. " into combat", 10)

        end
    end

end



function ctld.generateTroopTypes(_side,_count, _country)

    local _troops = {}

    for _i = 1,_count do

        local _unitType = "Soldier AK"

        if _side == 2 then
            _unitType = "Soldier M4"
            if _i <= 4 and ctld.spawnRPGWithCoalition then
                _unitType = "Paratrooper RPG-16"
            end
            if _i <= 2 then
                _unitType = "Soldier M249"
            end
        else
            _unitType = "Infantry AK"
            if _i <= 4 then
                _unitType = "Paratrooper RPG-16"
            end
            if _i <= 2 then
                _unitType = "Paratrooper AKS-74"
            end
        end

        local _unitId = mist.getNextUnitId()

        _troops[_i] =  {type = _unitType, unitId = _unitId, name = string.format("Dropped %s #%i",_unitType,_unitId)}

    end

    local _groupId = mist.getNextGroupId()
    local _details = {units = _troops, groupId = _groupId, groupName = string.format("Dropped Group %i",_groupId), side=_side, country=_country}

    return _details
end

-- load troops onto vehicle
function ctld.loadTroops(_heli,_troops, _number)

    -- load troops + vehicles if c130 or herc
    -- "M1045 HMMWV TOW"
    -- "M1043 HMMWV Armament"
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    --number doesnt apply to vehicles
    if _number == nil then
        _number = ctld.numberOfTroops
    end

    if _onboard == nil then
        _onboard =  { troops = {}, vehicles = {} }
    end

    local _list
    if _heli:getCoalition() == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    if _troops then

        _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(),_number,_heli:getCountry())

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded ".._number.." troops into " .. _heli:getTypeName(), 10)

    else

        _onboard.vehicles = ctld.generateVehiclesForTransport(_heli:getCoalition(), _heli:getCountry())

        local _count = #_list

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded ".._count.." vehicles into " .. _heli:getTypeName(), 10)

    end

    ctld.inTransitTroops[_heli:getName()] = _onboard

end

function ctld.generateVehiclesForTransport(_side,_country)

    local _vehicles = {}
    local _list
    if _side == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end


    for _i, _type in ipairs(_list) do

        local _unitId= mist.getNextUnitId()

        _vehicles[_i] =  {type = _type, unitId = _unitId, name = string.format("Dropped %s #%i",_type,_unitId)}

    end


    local _groupId = mist.getNextGroupId()
    local _details = {units = _vehicles, groupId = _groupId, groupName = string.format("Dropped Group %i",_groupId), side=_side, country=_country }

    return _details

end

function ctld.loadUnloadFOBCrate(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    if _heli:inAir() == true then
        return
    end


    local _side = _heli:getCoalition()

    local _inZone = ctld.inLogisticsZone(_heli)
    local _crateOnboard =  ctld.inTransitFOBCrates[_heli:getName()] ~= nil

    if _inZone == false and _crateOnboard == true then

        ctld.inTransitFOBCrates[_heli:getName()] = nil

        local _position = _heli:getPosition()

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_position.x.z, _position.x.x)
        local _xOffset = math.cos(_angle) * -60
        local _yOffset = math.sin(_angle) * -60

        local _point = _heli:getPoint()

        local _side = _heli:getCoalition()

        local _unitId = mist.getNextUnitId()

        local _name = string.format("FOB Crate #%i", _unitId)

        local _spawnedCrate =  ctld.spawnFOBCrateStatic(_heli:getCountry(),mist.getNextUnitId(),{x=_point.x+_xOffset,z=_point.z + _yOffset},_name)

        if _side == 1 then
            ctld.droppedFOBCratesRED[_name] = _name
        else
            ctld.droppedFOBCratesBLUE[_name] = _name
        end

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " delivered a FOB Crate", 10)

        ctld.displayMessageToGroup(_heli, "Delivered FOB Crate 60m at 6'oclock to you", 10)

    elseif _inZone == true and _crateOnboard == true then

        ctld.displayMessageToGroup(_heli, "FOB Crate dropped back to base", 10)

        ctld.inTransitFOBCrates[_heli:getName()] = nil

    elseif _inZone == true and _crateOnboard == false then
        ctld.displayMessageToGroup(_heli, "FOB Crate Loaded", 10)

        ctld.inTransitFOBCrates[_heli:getName()] = true

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded a FOB Crate ready for delivery!", 10)

    else

        -- nearest Crate
        local _crates = ctld.getCratesAndDistance(_heli)
        local _nearestCrate = ctld.getClosestCrate(_heli, _crates, "FOB")

        if _nearestCrate ~= nil and _nearestCrate.dist < 150 then

            ctld.displayMessageToGroup(_heli, "FOB Crate Loaded", 10)
            ctld.inTransitFOBCrates[_heli:getName()] = true

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded a FOB Crate ready for delivery!", 10)

            if _side == 1 then
                ctld.droppedFOBCratesRED[_nearestCrate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
            end

            --remove
            _nearestCrate.crateUnit:destroy()

        else
            ctld.displayMessageToGroup(_heli, "There are no friendly logistic units nearby to load a FOB crate from!", 10)
        end

    end

end

function ctld.loadUnloadTroops(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    local _inZone = ctld.inPickupZone(_heli)

    -- first check for extractable troops regardless of if we're in a zone or not

    --    if  not ctld.troopsOnboard(_heli,_troops) then
    --
    --        local _extract
    --
    --        if _troops then
    --            if _heli:getCoalition() == 1 then
    --
    --                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
    --            else
    --
    --                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
    --            end
    --        else
    --
    --            if _heli:getCoalition() == 1 then
    --
    --                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
    --            else
    --
    --                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
    --            end
    --
    --        end
    --
    --        if _extract ~= nil then
    --            -- search for nearest troops to pickup
    --            ctld.extractTroops(_heli,_troops)
    --
    --            return -- stop
    --        end
    --    end

    if _inZone == true and ctld.troopsOnboard(_heli,_troops) then

        if _troops then
            ctld.displayMessageToGroup(_heli, "Dropped troops back to base", 20)
            ctld.inTransitTroops[_heli:getName()].troops = nil

        else
            ctld.displayMessageToGroup(_heli, "Dropped vehicles back to base", 20)
            ctld.inTransitTroops[_heli:getName()].vehicles = nil

        end

    elseif _inZone == false and ctld.troopsOnboard(_heli,_troops) then

        ctld.deployTroops(_heli,_troops)

    elseif _inZone == true and not ctld.troopsOnboard(_heli,_troops) then

        ctld.loadTroops(_heli,_troops)
    else
        -- search for nearest troops to pickup
        ctld.extractTroops(_heli,_troops)
    end

end

function ctld.extractTroops(_heli,_troops)


    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        _onboard =  { troops = nil, vehicles = nil }
    end

    if _troops then

        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end

        if _extractTroops ~= nil then

            _onboard.troops = _extractTroops.details

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted troops in " .. _heli:getTypeName() .. " from combat", 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            --remove
            _extractTroops.group:destroy()

        else
            _onboard.troops = nil
            ctld.displayMessageToGroup(_heli, "No extractable troops nearby and not in a pickup zone", 20)
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

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted vehicles in " .. _heli:getTypeName() .. " from combat", 10)

            --remove
            _extractVehicles.group:destroy()


        else
            _onboard.vehicles = nil
            ctld.displayMessageToGroup(_heli, "No extractable vehicles nearby and not in a pickup zone", 20)
        end

    end

    ctld.inTransitTroops[_heli:getName()] = _onboard

end


function ctld.checkTroopStatus(_args)

    --list onboard troops, if c130
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then

        if ctld.inTransitFOBCrates[_heli:getName()] == true then
            ctld.displayMessageToGroup(_heli, "1 FOB Crate Onboard", 10)
        else
            ctld.displayMessageToGroup(_heli, "No troops onboard", 10)
        end


    else
        local _troops = _onboard.troops
        local _vehicles = _onboard.vehicles

        local _txt = ""

        if _troops ~= nil and _troops.units ~= nil and #_troops.units > 0 then
            _txt = _txt .. " " .. #_troops.units .. " troops onboard\n"
        end

        if _vehicles ~= nil and  _vehicles.units ~= nil and #_vehicles.units > 0 then
            _txt = _txt .. " " .. #_vehicles.units .. " vehicles onboard\n"
        end

        if ctld.inTransitFOBCrates[_heli:getName()] == true then
            _txt = _txt .. " 1 FOB Crate oboard\n"
        end

        if _txt ~= "" then
            ctld.displayMessageToGroup(_heli, _txt, 10)
        else
            if ctld.inTransitFOBCrates[_heli:getName()] == true then
                ctld.displayMessageToGroup(_heli, "1 FOB Crate Onboard", 10)
            else
                ctld.displayMessageToGroup(_heli, "No troops onboard", 10)
            end
        end
    end
end

-- Removes troops from transport when it dies
function ctld.checkTransportStatus()

    timer.scheduleFunction(ctld.checkTransportStatus,nil,timer.getTime()+3)

    for _,_name in ipairs(ctld.transportPilotNames) do

        local _transUnit = ctld.getTransportUnit(_name)

        if _transUnit == nil then
            --env.info("CTLD Transport Unit Dead event")
            ctld.inTransitTroops[_name] = nil
        end

    end

end

--recreates beacons to make sure they work!
function ctld.refreshRadioBeacons()

    timer.scheduleFunction(ctld.refreshRadioBeacons,nil,timer.getTime()+60)

    for _fobName,_beaconDetails in ipairs(ctld.fobBeacons) do
        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist()  and _fob:getLife() > 0 then
            ctld.createRadioBeacon(_beaconDetails.frequency,_fob:getPoint())
        end
    end

end

function ctld.getClockDirection(_heli,_crate)

    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p -- get position of crate
    local _playerPosition = _heli:getPosition().p -- get position of helicopter
    local _relativePosition = mist.vec.sub(_position,_playerPosition)

    local _playerHeading = mist.getHeading(_heli) -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = {x = math.cos(_playerHeading),y=0,z=math.sin(_playerHeading)}

    local _headingVectorPerpendicular = {x = math.cos(_playerHeading+math.pi/2),y=0,z=math.sin(_playerHeading+math.pi/2)}

    local _forwardDistance = mist.vec.dp(_relativePosition,_headingVector)

    local _rightDistance = mist.vec.dp(_relativePosition,_headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance,_forwardDistance)*180/math.pi

    if _angle < 0 then
        _angle = 360+_angle
    end
    _angle = math.floor(_angle*12/360+0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end


function ctld.getCompassBearing(_ref,_unitPos)

    _ref = mist.utils.makeVec3(_ref, 0)  -- turn it into Vec3 if it is not already.
    _unitPos = mist.utils.makeVec3(_unitPos,0) -- turn it into Vec3 if it is not already.

    local _vec = {x = _unitPos.x - _ref.x, y = _unitPos.y - _ref.y, z = _unitPos.z - _ref.z}

    local _dir = mist.utils.getDir(_vec, _ref)

    local _bearing = mist.utils.round(mist.utils.toDegree(_dir), 0)

    return _bearing

end

function ctld.listNearbyCrates(_args)

    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then

        return -- no heli!
    end

    local _crates = ctld.getCratesAndDistance(_heli)

    for _, _crate in pairs(_crates) do

        if _crate.dist < 1000 and _crate.details.unit ~= "FOB" then
            _message = string.format("%s\n%s crate - kg %i - %i m - %d o'clock", _message, _crate.details.desc, _crate.details.weight, _crate.dist,ctld.getClockDirection(_heli,_crate.crateUnit))
        end
    end


    local _fobMsg = ""
    for _, _fobCrate in pairs(_crates) do

        if _fobCrate.dist < 1000 and _fobCrate.details.unit == "FOB" then
            _fobMsg = _fobMsg..string.format("FOB Crate - %d m - %d o'clock\n",  _fobCrate.dist, ctld.getClockDirection(_heli,_fobCrate.crateUnit))
        end
    end

    if _message ~= "" or _fobMsg ~= "" then

        local _txt= ""

        if _message ~= "" then
            _txt = "Nearby Crates:\n" .. _message
        end

        if _fobMsg ~= "" then

            if _message ~= "" then
                _txt = _txt.."\n\n"
            end

            _txt = _txt.."Nearby FOB Crates (Not Slingloadable):\n" .. _fobMsg

        end

        ctld.displayMessageToGroup(_heli, _txt, 20)

    else
        --no crates nearby

        local _txt = "No Nearby Crates"

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end


function ctld.listFOBS(_args)

    local _msg = "FOB Positions:"

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then

        return -- no heli!
    end

    -- get fob positions

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do
        _msg = string.format("%s\nFOB @ %s", _msg, ctld.getFOBPositionString(_fob))
    end

    if _msg == "FOB Positions:" then
        ctld.displayMessageToGroup(_heli, "Sorry, there are no active FOBs!", 20)
    else
        ctld.displayMessageToGroup(_heli, _msg, 20)
    end

end

function ctld.getFOBPositionString(_fob)

    local _lat, _lon = coord.LOtoLL(_fob:getPosition().p)

    local _latLngStr = mist.tostringLL(_lat, _lon,3,false)

    local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_fob:getPosition().p)),5)

    local _message = _latLngStr .. " - MGRS ".._mgrsString

    local _beaconInfo = ctld.fobBeacons[_fob:getName()]

    if _beaconInfo ~=nil then
        _message= string.format("%s - %.2f FM", _message,_beaconInfo.frequency / 1000000)
    end

    return _message
end




function ctld.displayMessageToGroup(_unit, _text, _time)

    trigger.action.outTextForGroup(_unit:getGroup():getID(), _text, _time)

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
        local _crate = StaticObject.getByName(_crateName)

        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0
                and (_crate:inAir() == false or (land.getHeight(_crate:getPoint()) < 200 and mist.vec.mag(_crate:getVelocity()) < 1.0  )) then

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
        local _crate = StaticObject.getByName(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then

            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = {unit="FOB"},  }

            table.insert(_crates, _crateDetails)
        end
    end

    return _crates
end


function ctld.getClosestCrate(_heli, _crates,_type)

    local _closetCrate = nil
    local _shortestDistance = -1
    local _distance = 0

    for _, _crate in pairs(_crates) do

        if(_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                _shortestDistance = _distance
                _closetCrate = _crate
            end
        end
    end

    return _closetCrate
end

function ctld.findNearestHawk(_heli)

    local _closestHawkGroup = nil
    local _shortestDistance = -1
    local _distance = 0

    for _, _groupName in pairs(ctld.completeHawkSystems) do

        local _hawkGroup = Group.getByName(_groupName)

        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() then

            local _leader = _hawkGroup:getUnit(1)

            if _leader ~= nil and _leader:getLife() > 0 then

                _distance = ctld.getDistance(_leader:getPoint(), _heli:getPoint())

                if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                    _shortestDistance = _distance
                    _closestHawkGroup = _hawkGroup
                end
            end

        end
    end

    if _closestHawkGroup ~= nil then
        return {group = _closestHawkGroup, dist = _distance}
    end
    return nil


end



function ctld.unpackCrates(_args)

    -- trigger.action.outText("Unpack Crates".._args[1],10)

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil and _heli:inAir() == false then

        local _crates = ctld.getCratesAndDistance(_heli)
        local _crate = ctld.getClosestCrate(_heli, _crates)

        if _crate ~= nil and _crate.dist < 750 and _crate.details.unit == "FOB" then

            ctld.unpackFOBCrates(_crates,_heli)

            return

        elseif _crate ~= nil and _crate.dist < 200 then

--            if ctld.inLogisticsZone(_heli) == true then
--
--                ctld.displayMessageToGroup(_heli, "You can't unpack that here! Take it to where it's needed!", 20)
--
--                return
--            end

            -- is multi crate?
            if ctld.isMultiCrate(_crate.details) then
                -- multicrate

                ctld.unpackMultiCrate(_heli,_crate,_crates)

            else
                -- single crate
                local _cratePoint = _crate.crateUnit:getPoint()
                local _crateName = _crate.crateUnit:getName()

                -- ctld.spawnCrateStatic( _heli:getCoalition(),mist.getNextUnitId(),{x=100,z=100},_crateName,100)

                --remove crate
                _crate.crateUnit:destroy()

                local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _cratePoint }, { _crate.details.unit })

                if _heli:getCoalition() == 1 then
                    ctld.spawnedCratesRED[_crateName] = nil
                else
                    ctld.spawnedCratesBLUE[_crateName] = nil
                end

                trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully deployed " .. _crate.details.desc .. " to the field", 10)

                if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then

                    local _code = table.remove(ctld.jtacGeneratedLaserCodes,1)
                    --put to the end
                    table.insert(ctld.jtacGeneratedLaserCodes,_code)

                    ctld.JTACAutoLase(_spawnedGroups:getName(),_code) --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
                end
            end

        else

            ctld.displayMessageToGroup(_heli, "No friendly crates close enough to unpack", 20)
        end
    end
end


-- builds a fob!
function ctld.unpackFOBCrates(_crates,_heli)

--    if ctld.inLogisticsZone(_heli) == true then
--
--        ctld.displayMessageToGroup(_heli, "You can't unpack that here! Take it to where it's needed!", 20)
--
--        return
--    end

    -- unpack multi crate
    local _nearbyMultiCrates = {}

    for _, _nearbyCrate in pairs(_crates) do

        if _nearbyCrate.dist < 750 and _nearbyCrate.details.unit == "FOB" then

            table.insert(_nearbyMultiCrates, _nearbyCrate)

            if #_nearbyMultiCrates == ctld.cratesRequiredForFOB then
                break
            end

        end
    end

    --- check crate count
    if #_nearbyMultiCrates == ctld.cratesRequiredForFOB then

        -- destroy crates

        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do

            if _heli:getCoalition() == 1 then
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())

            --destroy
            _crate.crateUnit:destroy()
        end

        local _centroid = ctld.getCentroid(_points)

        timer.scheduleFunction(
            function(_args)

                local _unitId = mist.getNextUnitId()
                local _name = "Deployed FOB #".._unitId

                local _fob = ctld.spawnFOB(_args[2],_unitId,_args[1],_name)

                --make it able to deploy crates
                table.insert(ctld.logisticUnits, _fob:getName())

                local _frequency = ctld.generateRadioFMRadioFrequency()

                ctld.fobBeacons[_name] = {frequency=_frequency, point=_fob:getPoint() }

                --started radio beacon
                ctld.createRadioBeacon(_frequency,_fob:getPoint())

                if ctld.troopPickupAtFOB == true then
                    table.insert(ctld.builtFOBS, _fob:getName())

                    trigger.action.outTextForCoalition(_args[3],"Finished building FOB! Crates and Troops can now be picked up.", 10)
                else
                    trigger.action.outTextForCoalition(_args[3],"Finished building FOB! Crates can now be picked up.", 10)
                end

            end, {_centroid, _heli:getCountry(),_heli:getCoalition()}, timer.getTime() + ctld.buildTimeFOB)

        local _txt = string.format("%s started building FOB using %d FOB crates, it will be finished in %d seconds.\nPosition marked with smoke.",ctld.getPlayerNameOrType(_heli),#_nearbyMultiCrates,ctld.buildTimeFOB)

        trigger.action.smoke(_centroid,trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_heli:getCoalition(), _txt, 10)
    else
        local _txt = string.format("Cannot build FOB!\n\nIt requires %d FOB crates and there are %d \n\nOr the crates are not within 750m of each other",ctld.cratesRequiredForFOB,#_nearbyMultiCrates)
        ctld.displayMessageToGroup(_heli, _txt, 20)
    end

end

function ctld.createRadioBeacon(_frequency, _point)

    trigger.action.radioTransmission(ctld.radioSound, _point, 1, true, _frequency, 1000)
end

function ctld.generateRadioFMRadioFrequency()

    --pick random frequency!
    -- first digit 3-7
    -- second digit 0-5
    -- third digit 0-9
    -- fourth digit 0 or 5
    -- times by 10000


    local _first = math.random(3,7)
    local _second = math.random(0,5)
    local _third = math.random(0,9)

    local _frequency =( (100*_first)+(10*_second)+_third) * 100000 --extra 0 because we didnt bother with 4th digit

    local _found = false
    for _, _beacon in ipairs(ctld.fobBeacons) do

        if _beacon.frequency == _frequency then
            _found = true
            break
        end

    end

    if _found then
    --try again!
        return ctld.generateRadioFMFrequency()
    else
        return _frequency
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

    local _point=  {x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({_point.x, _point.z})

    return _point
end


function ctld.isMultiCrate(_crateDetails)

    if string.match(_crateDetails.desc, "HAWK")
            or (_crateDetails.cratesRequired ~= nil and _crateDetails.cratesRequired > 1) then
        return true
    else
        return false
    end

end

function ctld.rearmHawk(_heli,_nearestCrate,_nearbyCrates)

    -- are we adding to existing hawk system?
    if _nearestCrate.details.unit == "Hawk ln" then

        -- find nearest COMPLETE hawk system
        local _nearestHawk =  ctld.findNearestHawk(_heli)

        if _nearestHawk ~=nil and _nearestHawk.dist < 300 then

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
            end

            local _types = {}
            local _points = {}

            local _units = _nearestHawk.group:getUnits()

            if _units ~= nil and #_units > 0 then

                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        table.insert(_types,_units[x]:getTypeName())
                        table.insert(_points,_units[x]:getPoint())
                    end
                end
            end

            if #_types == 3 and #_points == 3 then

                -- rearm hawk
                -- destroy old group
                ctld.completeHawkSystems[_nearestHawk.group:getName()] = nil

                _nearestHawk.group:destroy()

                local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types)

                ctld.completeHawkSystems[_spawnedGroup:getName()] = _spawnedGroup:getName()

                trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully rearmed a full HAWK AA System in the field", 10)

                return true -- all done so quit
            end
        end
    end

    return false
end

function ctld.unpackHawk(_heli,_nearestCrate,_nearbyCrates)

    if ctld.rearmHawk(_heli,_nearestCrate,_nearbyCrates) then
        -- rearmed hawk
        return
    end


    -- are there all the pieces close enough together
    local _hawkParts = { ["Hawk ln"] = false, ["Hawk tr"] = false, ["Hawk sr"] = false }

    for _, _nearbyCrate in pairs(_nearbyCrates) do

        if _nearbyCrate.dist < 300 then

            if _nearbyCrate.details.unit == "Hawk ln" or _nearbyCrate.details.unit == "Hawk sr" or _nearbyCrate.details.unit == "Hawk tr" then

                _hawkParts[_nearbyCrate.details.unit] = _nearbyCrate

            else
                -- not part of hawk
            end
        end
    end

    local _count = 0
    local _txt = ""

    local _posArray = {}
    local _typeArray = {}
    for _name, _hawkPart in pairs(_hawkParts) do

        if _hawkPart == false then

            if _name == "Hawk ln" then
                _txt = "Missing HAWK Launcher\n"
            elseif _name == "Hawk sr" then
                _txt = _txt .. "Missing HAWK Search Radar\n"
            else
                _txt = _txt .. "Missing HAWK Track Radar\n"
            end
        else
            table.insert(_posArray, _hawkPart.crateUnit:getPoint())
            table.insert(_typeArray, _name)
        end
    end

    if _txt ~= "" then

        ctld.displayMessageToGroup(_heli, "Cannot build Hawk\n" .. _txt .. "\n\nOr the crates are not close enough together", 20)

        return
    else

        -- destroy crates
        for _name, _hawkPart in pairs(_hawkParts) do

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_hawkPart.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_hawkPart.crateUnit:getName()] = nil
            end

            --destroy
            _hawkPart.crateUnit:destroy()
        end

        -- HAWK READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray)

        ctld.completeHawkSystems[_spawnedGroup:getName()] = _spawnedGroup:getName()

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully deployed a full HAWK AA System to the field", 10)
    end
end

function ctld.unpackMultiCrate(_heli,_nearestCrate,_nearbyCrates)

    if string.match(_nearestCrate.details.desc, "HAWK") then
        ctld.unpackHawk(_heli,_nearestCrate,_nearbyCrates)

        return -- stop processing
    end

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

        local _point = _nearestCrate.crateUnit:getPoint()

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
            _crate.crateUnit:destroy()
        end


        local _spawnedGroup = ctld.spawnCrateGroup(_heli,{_point} ,{_nearestCrate.details.unit})

        local _txt = string.format("%s successfully deployed %s to the field using %d crates",ctld.getPlayerNameOrType(_heli),_nearestCrate.details.desc,#_nearbyMultiCrates)

        trigger.action.outTextForCoalition(_heli:getCoalition(), _txt, 10)

    else

        local _txt = string.format("Cannot build %s!\n\nIt requires %d crates and there are %d \n\nOr the crates are not within 300m of each other",_nearestCrate.details.desc,_nearestCrate.details.cratesRequired,#_nearbyMultiCrates)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end


end


function ctld.spawnCrateGroup(_heli, _positions, _types)

    local _id = mist.getNextGroupId()

    local _groupName = _types[1] .. "  #" .. _id

    local _side = _heli:getCoalition()

    local _group = {
        ["visible"] = false,
        ["groupId"] = _id,
        ["hidden"] = false,
        ["units"] = {},
        --        ["y"] = _positions[1].z,
        --        ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["task"] = {},
    }

    if #_positions == 1 then

        local _unitId = mist.getNextUnitId()
        local _details = {type= _types[1], unitId = _unitId, name = string.format("Unpacked %s #%i",_types[1],_unitId)}

        _group.units[1] = ctld.createUnit(_positions[1].x + 5, _positions[1].z + 5, 120, _details)

    else

        for _i, _pos in ipairs(_positions) do

            local _unitId = mist.getNextUnitId()
            local _details = {type= _types[_i], unitId = _unitId, name = string.format("Unpacked %s #%i",_types[_i],_unitId)}

            _group.units[_i] = ctld.createUnit(_pos.x + 5, _pos.z + 5, 120, _details)
        end
    end

    local _spawnedGroup = coalition.addGroup(_heli:getCountry(), Group.Category.GROUND, _group)

    --activate by moving and so we can set ROE and Alarm state

    local _dest = _spawnedGroup:getUnit(1):getPoint()
    _dest = { x = _dest.x + 5, _y = _dest.y + 5, z = _dest.z + 5 }

    ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _dest)

    return _spawnedGroup
end



-- spawn normal group
function ctld.spawnDroppedGroup(_point, _details, _spawnBehind,_maxSearch)

    local _groupName = _details.groupName

    local _group = {
        ["visible"] = false,
        ["groupId"] = _details.groupId,
        ["hidden"] = false,
        ["units"] = {},
        --        ["y"] = _positions[1].z,
        --        ["x"] = _positions[1].x,
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

        local _pos = _point

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * -30
        local _yOffset = math.sin(_angle) * -30


        for _i, _detail in ipairs(_details.units) do
            _group.units[_i] = ctld.createUnit(_pos.x + (_xOffset + 10 * _i), _pos.z + (_yOffset + 10 * _i), _angle,_detail)
        end
    end

    local _spawnedGroup = coalition.addGroup(_details.country, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    if _maxSearch == nil then
        _maxSearch = ctld.maximumSearchDistance
    end

    local _enemyPos = ctld.findNearestEnemy(_details.side,_point,_maxSearch)

    ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _enemyPos)

    return _spawnedGroup
end

function ctld.findNearestEnemy(_side,_point,_searchDistance)

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

        return _closestEnemy
    else

        local _x = _heliPoint.x + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _z = _heliPoint.z + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)

        return { x = _x, z = _z }
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

                local _groupDetails = { groupId = _group:getID(), groupName = _group:getName(),  side = _group:getCoalition(), units = {} }

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then

                        if _leader == nil then
                            _leader = _units[x]
                            -- set country based on leader
                            _groupDetails.country  = _leader:getCountry()
                        end

                        local _unitDetails = {type = _units[x]:getTypeName(), unitId = _units[x]:getID(), name = _units[x]:getName() }

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


function ctld.createUnit(_x, _y, _angle, _details)

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _details.type,
        ["name"] = _details.name,
        ["unitId"] = _details.unitId,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function ctld.orderGroupToMoveToPoint(_leader, _destination)

    local _group = _leader:getGroup()

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points = {
                    [1] = {
                        action = 0,
                        x = _leader:getPoint().x,
                        y = _leader:getPoint().z,
                        speed = 0,
                        ETA = 100,
                        ETA_locked = false,
                        name = "Starting point",
                        task = nil
                    },
                    [2] = {
                        action = 0,
                        x = _destination.x,
                        y = _destination.z,
                        speed = 100,
                        ETA = 100,
                        ETA_locked = false,
                        name = "End Point",
                        task = nil
                    },
                }
            },
        }
    }
    local _controller = _group:getController();
    Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
    Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
    _controller:setTask(_mission)
end

-- are we in pickup zone
function ctld.inPickupZone(_heli)

    if _heli:inAir() then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil then

            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do

        --get distance to center

        local _dist = ctld.getDistance(_heliPoint,_fob:getPoint())

        if _dist <= 150 then
            return true
        end
    end



    return false
end

function ctld.getSpawnedFobs(_heli)

    local _fobs = {}

    for _, _fobName in ipairs(ctld.builtFOBS) do

        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getCoalition() == _heli:getCoalition() and _fob:getLife() > 0 then

           table.insert(_fobs,_fob)
        end
    end

    return _fobs

end

-- are we in a dropoff zone
function ctld.inDropoffZone(_heli)

    if _heli:inAir() then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.dropOffZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil then

            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    return false
end

-- are we near friendly logistics zone
function ctld.inLogisticsZone(_heli)

    if _heli:inAir() then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _name in pairs(ctld.logisticUnits) do

        local _logistic = StaticObject.getByName(_name)

        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() then

            --get distance
            local _dist = ctld.getDistance(_heliPoint, _logistic:getPoint())

            if _dist <= ctld.maximumDistanceLogistic then
                return true
            end
        end
    end

    return false
end

function ctld.refreshSmoke()

    if ctld.disableAllSmoke == true then
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil and _zoneDetails[2] >= 0 then

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

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " dropped " .._colour .." smoke ", 10)
    end
end

function ctld.unitCanCarryVehicles(_unit)

    local _type = string.lower(_unit:getTypeName())

    for _,_name in ipairs(ctld.vehicleTransportEnabled) do
        local _nameLower = string.lower(_name)
        if string.match(_type, _nameLower) then
            return true
        end
    end

    return false
end

function ctld.isJTACUnitType(_type)

    _type = string.lower(_type)

    for _,_name in ipairs(ctld.jtacUnitTypes) do
        local _nameLower = string.lower(_name)
        if string.match(_type, _nameLower) then
            return true
        end

    end

    return false

end



-- checks the status of all AI troop carriers and auto loads and unloads troops
function ctld.checkAIStatus()

    timer.scheduleFunction(ctld.checkAIStatus,nil,timer.getTime()+5)

    for _, _unitName in pairs(ctld.transportPilotNames) do

        local _unit = ctld.getTransportUnit(_unitName)

        if _unit ~= nil and _unit:getPlayerName() == nil then

            -- no player name means AI!

            if ctld.inPickupZone(_unit) and not ctld.troopsOnboard(_unit,true) then

                ctld.loadTroops(_unit,true)

            elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit,true) then

                ctld.deployTroops(_unit,true)
            end

            if ctld.unitCanCarryVehicles(_unit) then

                if ctld.inPickupZone(_unit) and not ctld.troopsOnboard(_unit,false) then

                    ctld.loadTroops(_unit,false)

                elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit,false) then

                    ctld.deployTroops(_unit,false)
                end

            end

        end
    end

end


-- Adds menuitem to all heli units that are active
function ctld.addF10MenuOptions()
    -- Loop through all Heli units

    timer.scheduleFunction(ctld.addF10MenuOptions, nil, timer.getTime() + 5)

    for _, _unitName in pairs(ctld.transportPilotNames) do

        local _unit = ctld.getTransportUnit(_unitName)

        if _unit ~= nil then

            local _groupId = _unit:getGroup():getID()

            if ctld.addedTo[tostring(_groupId)] == nil and _unit:getPlayerName() ~= nil then

                missionCommands.addSubMenuForGroup(_groupId, "Troop Transport")
                missionCommands.addCommandForGroup(_groupId, "Load / Unload Troops", { "Troop Transport" }, ctld.loadUnloadTroops, { _unitName,true })

                if ctld.unitCanCarryVehicles(_unit) then

                    missionCommands.addCommandForGroup(_groupId, "Load / Unload Vehicles", { "Troop Transport" }, ctld.loadUnloadTroops, { _unitName,false })

                    if ctld.enabledFOBBuilding then

                        missionCommands.addCommandForGroup(_groupId, "Load / Unload FOB Crate", { "Troop Transport" }, ctld.loadUnloadFOBCrate, { _unitName,false })
                    end

                end

                missionCommands.addCommandForGroup(_groupId, "Check Cargo", { "Troop Transport" }, ctld.checkTroopStatus, { _unitName })

                if ctld.enableCrates then

                    if ctld.unitCanCarryVehicles(_unit) == false then

                        -- add menu for spawning crates
                        for _subMenuName, _crates in pairs(ctld.spawnableCrates) do

                            missionCommands.addSubMenuForGroup(_groupId, _subMenuName)
                            for _, _crate in pairs(_crates) do

                                if ctld.isJTACUnitType(_crate.unit) == false or ( ctld.isJTACUnitType(_crate.unit) == true and ctld.JTAC_dropEnabled ) then
                                    if _crate.side == nil or (_crate.side == _unit:getCoalition()) then
                                        missionCommands.addCommandForGroup(_groupId, _crate.desc, {_subMenuName }, ctld.spawnCrate, { _unitName,_crate.weight })
                                    end
                                end
                            end
                        end
                    end

                    missionCommands.addSubMenuForGroup(_groupId, "CTLD Commands")
                    missionCommands.addCommandForGroup(_groupId, "List Nearby Crates", { "CTLD Commands" }, ctld.listNearbyCrates, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, "Unpack Any Crate", { "CTLD Commands" }, ctld.unpackCrates, { _unitName })

                    if ctld.enabledFOBBuilding then
                        missionCommands.addCommandForGroup(_groupId, "List FOBs", { "CTLD Commands" }, ctld.listFOBS, { _unitName })
                    end

                    if ctld.enableSmokeDrop then
                        missionCommands.addCommandForGroup(_groupId, "Drop Red Smoke", {  "CTLD Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                        missionCommands.addCommandForGroup(_groupId, "Drop Blue Smoke", {  "CTLD Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                        --    missionCommands.addCommandForGroup(_groupId, "Drop Orange Smoke", { "Crate Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                        missionCommands.addCommandForGroup(_groupId, "Drop Green Smoke", {  "CTLD Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
                    end
                else
                    if ctld.enableSmokeDrop then
                        missionCommands.addSubMenuForGroup(_groupId, "Smoke Markers")
                        missionCommands.addCommandForGroup(_groupId, "Drop Red Smoke", { "Smoke Markers" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                        missionCommands.addCommandForGroup(_groupId, "Drop Blue Smoke", { "Smoke Markers" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                        missionCommands.addCommandForGroup(_groupId, "Drop Orange Smoke", { "Smoke Markers"}, ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                        missionCommands.addCommandForGroup(_groupId, "Drop Green Smoke", { "Smoke Markers" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
                    end
                end

                ctld.addedTo[tostring(_groupId)] = true
            end
        else
            -- env.info(string.format("unit nil %s",_unitName))
        end
    end

    if ctld.JTAC_jtacStatusF10 then
        -- get all BLUE players
        ctld.addJTACRadioCommand(coalition.side.BLUE)

        -- get all RED players
        ctld.addJTACRadioCommand(coalition.side.RED)
    end


end

function ctld.addJTACRadioCommand(_side)

    local _players =  coalition.getPlayers(_side)

    if _players ~= nil then

        for _,_playerUnit in pairs(_players) do

            local _groupId = _playerUnit:getGroup():getID()

            --   env.info("adding command for "..index)
            if ctld.jtacRadioAdded[tostring(_groupId)] == nil then
                -- env.info("about command for "..index)
                missionCommands.addCommandForGroup(_groupId, "JTAC Status", nil, ctld.getJTACStatus, _playerUnit:getCoalition())
                ctld.jtacRadioAdded[tostring(_groupId)] = true
                -- env.info("Added command for " .. index)
            end

        end

    end

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


ctld.jtacLaserPoints = {}
ctld.jtacIRPoints = {}
ctld.jtacSmokeMarks = {}
ctld.jtacUnits = {} -- list of JTAC units for f10 command
ctld.jtacCurrentTargets = {}
ctld.jtacRadioAdded = {} --keeps track of who's had the radio command added
ctld.jtacGeneratedLaserCodes = {} -- keeps track of generated codes, cycles when they run out
ctld.jtacLaserPointCodes = {}


function ctld.JTACAutoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour)


    if _lock == nil then

        _lock = ctld.JTAC_lock
    end


    ctld.jtacLaserPointCodes[_jtacGroupName] = _laserCode

    local _jtacGroup = ctld.getGroup(_jtacGroupName)
    local _jtacUnit

    if _jtacGroup == nil or #_jtacGroup == 0 then

        if ctld.jtacUnits[_jtacGroupName] ~= nil then
            ctld.notifyCoalition("JTAC Group " .. _jtacGroupName .. " KIA!", 10,ctld.jtacUnits[_jtacGroupName].side)
        end

        --remove from list
        ctld.jtacUnits[_jtacGroupName] = nil

        ctld.cleanupJTAC(_jtacGroupName)

        return
    else

        _jtacUnit = _jtacGroup[1]
        --add to list
        ctld.jtacUnits[_jtacGroupName] = {name = _jtacUnit:getName(), side = _jtacUnit:getCoalition()}

        -- work out smoke colour
        if _colour == nil then

            if  _jtacUnit:getCoalition() == 1 then
                _colour = ctld.JTAC_smokeColour_RED
            else
                _colour = ctld.JTAC_smokeColour_BLUE
            end
        end


        if _smoke == nil then

            if  _jtacUnit:getCoalition() == 1 then
                _smoke = ctld.JTAC_smokeOn_RED
            else
                _smoke = ctld.JTAC_smokeOn_BLUE
            end

        end

    end


    -- search for current unit

    if _jtacUnit:isActive() == false then

        ctld.cleanupJTAC(_jtacGroupName)

        env.info(_jtacGroupName .. ' Not Active - Waiting 30 seconds')
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 30)

        return
    end

    local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

    if _enemyUnit == nil and ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then

        local _tempUnitInfo = ctld.jtacCurrentTargets[_jtacGroupName]

        --      env.info("TEMP UNIT INFO: " .. tempUnitInfo.name .. " " .. tempUnitInfo.unitType)

        local _tempUnit = Unit.getByName(_tempUnitInfo.name)

        if _tempUnit ~= nil and _tempUnit:getLife() > 0 and _tempUnit:isActive() == true then
            ctld.notifyCoalition(_jtacGroupName .. " target " .. _tempUnitInfo.unitType .. " lost. Scanning for Targets. ", 10,_jtacUnit:getCoalition())
        else
            ctld.notifyCoalition(_jtacGroupName .. " target " .. _tempUnitInfo.unitType .. " KIA. Good Job! Scanning for Targets. ", 10,_jtacUnit:getCoalition())
        end

        --remove from smoke list
        ctld.jtacSmokeMarks[_tempUnitInfo.name] = nil

        -- remove from target list
        ctld.jtacCurrentTargets[_jtacGroupName] = nil

        --stop lasing
        ctld.cancelLase(_jtacGroupName)

    end


    if _enemyUnit == nil then
        _enemyUnit = ctld.findNearestVisibleEnemy(_jtacUnit, _lock)

        if _enemyUnit ~= nil then

            -- store current target for easy lookup
            ctld.jtacCurrentTargets[_jtacGroupName] = { name = _enemyUnit:getName(), unitType = _enemyUnit:getTypeName(), unitId = _enemyUnit:getID() }

            ctld.notifyCoalition(_jtacGroupName .. " lasing new target " .. _enemyUnit:getTypeName() .. '. CODE: ' .. _laserCode ..ctld.getPositionString(_enemyUnit) , 10,_jtacUnit:getCoalition())

            -- create smoke
            if _smoke == true then

                --create first smoke
                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end
    end

    if _enemyUnit ~= nil then

        ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

        --   env.info('Timer timerSparkleLase '..jtacGroupName.." "..laserCode.." "..enemyUnit:getName())
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 1)


        if _smoke == true then
            local _nextSmokeTime = ctld.jtacSmokeMarks[_enemyUnit:getName()]

            --recreate smoke marker after 5 mins
            if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then

                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end

    else
        -- env.info('LASE: No Enemies Nearby')

        -- stop lazing the old spot
        ctld.cancelLase(_jtacGroupName)
        --  env.info('Timer Slow timerSparkleLase '..jtacGroupName.." "..laserCode.." "..enemyUnit:getName())

        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 5)
    end
end


-- used by the timer function
function ctld.timerJTACAutoLase(_args)

    ctld.JTACAutoLase(_args[1], _args[2], _args[3], _args[4], _args[5])
end

function ctld.cleanupJTAC(_jtacGroupName)
    -- clear laser - just in case
    ctld.cancelLase(_jtacGroupName)

    -- Cleanup
    ctld.jtacUnits[_jtacGroupName] = nil

    ctld.jtacCurrentTargets[_jtacGroupName] = nil
end


function ctld.notifyCoalition(_message, _displayFor, _side)


    trigger.action.outTextForCoalition(_side, _message, _displayFor)
    trigger.action.outSoundForCoalition(_side, "radiobeep.ogg")
end

function ctld.createSmokeMarker(_enemyUnit, _colour)

    --recreate in 5 mins
    ctld.jtacSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0

    -- move smoke 2 meters above target for ease
    local _enemyPoint = _enemyUnit:getPoint()
    trigger.action.smoke({ x = _enemyPoint.x, y = _enemyPoint.y + 2.0, z = _enemyPoint.z }, _colour)
end

function ctld.cancelLase(_jtacGroupName)

    --local index = "JTAC_"..jtacUnit:getID()

    local _tempLase = ctld.jtacLaserPoints[_jtacGroupName]

    if _tempLase ~= nil then
        Spot.destroy(_tempLase)
        ctld.jtacLaserPoints[_jtacGroupName] = nil

        --      env.info('Destroy laze  '..index)

        _tempLase = nil
    end

    local _tempIR = ctld.jtacIRPoints[_jtacGroupName]

    if _tempIR ~= nil then
        Spot.destroy(_tempIR)
        ctld.jtacIRPoints[_jtacGroupName] = nil

        --  env.info('Destroy laze  '..index)

        _tempIR = nil
    end
end

function ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

    --cancelLase(jtacGroupName)

    local _spots = {}

    local _enemyVector = _enemyUnit:getPoint()
    local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

    local _oldLase = ctld.jtacLaserPoints[_jtacGroupName]
    local _oldIR = ctld.jtacIRPoints[_jtacGroupName]

    if _oldLase == nil or _oldIR == nil then

        -- create lase

        local _status, _result = pcall(function()
            _spots['irPoint'] = Spot.createInfraRed(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
            _spots['laserPoint'] = Spot.createLaser(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated, _laserCode)
            return _spots
        end)

        if not _status then
            env.error('ERROR: ' .. _result, false)
        else
            if _result.irPoint then

                --    env.info(jtacUnit:getName() .. ' placed IR Pointer on '..enemyUnit:getName())

                ctld.jtacIRPoints[_jtacGroupName] = _result.irPoint --store so we can remove after

            end
            if _result.laserPoint then

                --	env.info(jtacUnit:getName() .. ' is Lasing '..enemyUnit:getName()..'. CODE:'..laserCode)

                ctld.jtacLaserPoints[_jtacGroupName] = _result.laserPoint
            end
        end

    else

        -- update lase

        if _oldLase ~=nil then
            _oldLase:setPoint(_enemyVectorUpdated)
        end

        if _oldIR ~= nil then
            _oldIR:setPoint(_enemyVectorUpdated)
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
        --   tempPosition = unit:getPosition()

        _tempDist = ctld.getDistance(_unit:getPoint(), _jtacUnit:getPoint() )
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
function ctld.findNearestVisibleEnemy(_jtacUnit, _targetType)

    local _x = 1
    local _i = 1

    local _units = nil
    local _groupName = nil

    local _nearestUnit = nil
    local _nearestDistance = ctld.JTAC_maxDistance

    local _enemyGroups

    if _jtacUnit:getCoalition() == 1 then
        _enemyGroups = coalition.getGroups(2, Group.Category.GROUND)
    else
        _enemyGroups = coalition.getGroups(1, Group.Category.GROUND)
    end

    local _jtacPoint = _jtacUnit:getPoint()
    local _jtacPosition = _jtacUnit:getPosition()

    local _tempPoint = nil
    local _tempPosition = nil

    local _tempDist = nil

    -- finish this function
    for _i = 1, #_enemyGroups do
        if _enemyGroups[_i] ~= nil then
            _groupName = _enemyGroups[_i]:getName()
            _units = ctld.getGroup(_groupName)
            if #_units > 0 then

                for _x = 1, #_units do

                    --check to see if a JTAC has already targeted this unit
                    local _targeted = ctld.alreadyTarget(_jtacUnit, _units[_x])
                    local _allowedTarget = true

                    if _targetType == "vehicle" then

                        _allowedTarget = ctld.isVehicle(_units[_x])

                    elseif _targetType == "troop" then

                        _allowedTarget = ctld.isInfantry(_units[_x])

                    end

                    if _units[_x]:isActive() == true and _targeted == false and _allowedTarget == true then

                        -- calc distance
                        _tempPoint = _units[_x]:getPoint()
                        _tempDist = ctld.getDistance(_tempPoint, _jtacPoint)

                        if _tempDist < ctld.JTAC_maxDistance and _tempDist < _nearestDistance then

                            local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
                            local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }


                            -- calc visible
                            if land.isVisible(_offsetEnemyPos, _offsetJTACPos) then

                                _nearestDistance = _tempDist
                                _nearestUnit = _units[_x]
                            end

                        end
                    end
                end
            end
        end
    end


    if _nearestUnit == nil then
        return nil
    end


    return _nearestUnit
end
-- tests whether the unit is targeted by another JTAC
function ctld.alreadyTarget(_jtacUnit, _enemyUnit)

    for _ , _jtacTarget in pairs(ctld.jtacCurrentTargets) do

        if _jtacTarget.unitId == _enemyUnit:getID() then
            -- env.info("ALREADY TARGET")
            return true
        end

    end

    return false

end


-- Returns only alive units from group but the group / unit may not be active

function ctld.getGroup(groupName)

    local _groupUnits = Group.getByName(groupName)

    local _filteredUnits = {} --contains alive units
    local _x = 1

    if _groupUnits ~= nil then

        _groupUnits = _groupUnits:getUnits()

        if _groupUnits ~= nil and #_groupUnits > 0 then
            for _x = 1, #_groupUnits do
                if _groupUnits[_x]:getLife() > 0 and _groupUnits[_x]:isExist() then
                    table.insert(_filteredUnits, _groupUnits[_x])
                end
            end
        end
    end

    return _filteredUnits
end


-- gets the JTAC status and displays to coalition units
function ctld.getJTACStatus(_side)

    --returns the status of all JTAC units

    local _jtacGroupName = nil
    local _jtacUnit = nil

    local _message = "JTAC STATUS: \n\n"

    for _jtacGroupName, _jtacDetails in pairs(ctld.jtacUnits) do

        --look up units
        _jtacUnit = Unit.getByName(_jtacDetails.name)

        if _jtacUnit ~= nil and _jtacUnit:getLife() > 0 and _jtacUnit:isActive() == true and _jtacUnit:getCoalition() == _side  then

            local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

            local _laserCode =  ctld.jtacLaserPointCodes[_jtacGroupName]

            if _laserCode == nil then
                _laserCode = "UNKNOWN"
            end

            if _enemyUnit ~= nil and _enemyUnit:getLife() > 0 and _enemyUnit:isActive() == true then
                _message = _message .. "" .. _jtacGroupName .. " targeting " .. _enemyUnit:getTypeName().. " CODE: ".. _laserCode .. ctld.getPositionString(_enemyUnit) .. "\n"
            else
                _message = _message .. "" .. _jtacGroupName .. " searching for targets" .. ctld.getPositionString(_jtacUnit) .."\n"
            end
        end
    end

    if _message == "JTAC STATUS: \n\n" then
        _message = "No Active JTACs"
    end


    ctld.notifyCoalition(_message, 10,_side)
end



function ctld.isInfantry(_unit)

    local _typeName = _unit:getTypeName()

    --type coerce tostring
    _typeName = string.lower(_typeName .."")

    local _soldierType = { "infantry","paratrooper","stinger","manpad","mortar"}

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
--  The range used to be bugged so its not 1 - 8 but 0 - 7.
-- function below will use the range 1-7 just incase
function ctld.generateLaserCode()

    ctld.jtacGeneratedLaserCodes = {}

    -- generate list of laser codes
    local _code = 1111

    local _count = 1

    while _code < 1777 and _count < 30 do

        while true do

            _code = _code+1

            if not ctld.containsDigit(_code,8)
                    and not ctld.containsDigit(_code,9)
                    and not ctld.containsDigit(_code,0) then

                table.insert(ctld.jtacGeneratedLaserCodes,_code)

                --env.info(_code.." Code")
                break
            end
        end
        _count = _count + 1
    end

end

function ctld.containsDigit(_number,_numberToFind)

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


function ctld.getPositionString(_unit)

    if ctld.JTAC_location == false then
        return ""
    end

    local _lat, _lon = coord.LOtoLL(_unit:getPosition().p)

    local _latLngStr = mist.tostringLL(_lat, _lon,3,false)

    local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)),5)

    return " @ " .. _latLngStr .. " - MGRS ".. _mgrsString

end


-- ***************** SETUP SCRIPT ****************

assert(mist ~= nil, "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

ctld.addedTo = {}
ctld.spawnedCratesRED = {} -- use to store crates that have been spawned
ctld.spawnedCratesBLUE = {} -- use to store crates that have been spawned

ctld.droppedTroopsRED = {} -- stores dropped troop groups
ctld.droppedTroopsBLUE = {} -- stores dropped troop groups

ctld.droppedVehiclesRED = {} -- stores vehicle groups for c-130 / hercules
ctld.droppedVehiclesBLUE = {} -- stores vehicle groups for c-130 / hercules

ctld.inTransitTroops = {}

ctld.inTransitFOBCrates = {}

ctld.droppedFOBCratesRED = {}
ctld.droppedFOBCratesBLUE = {}

ctld.builtFOBS = {} -- stores fully built fobs

ctld.completeHawkSystems = {} -- stores complete spawned groups from multiple crates

ctld.fobBeacons = {} -- stores radio beacons, refreshed every 60 seconds

--ctld.radioFrequencyRED = 46000000



--used to lookup what the crate will contain
ctld.crateLookupTable = {}

-- Remove intransit troops when heli / cargo plane dies
--ctld.eventHandler = {}
--function ctld.eventHandler:onEvent(_event)
--
--    if _event == nil or _event.initiator == nil then
--        env.info("CTLD null event")
--    elseif _event.id == 9 then
--        -- Pilot dead
--        ctld.inTransitTroops[_event.initiator:getName()] = nil
--
--    elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
--        -- env.info("Event unit - Pilot Ejected or Unit Dead")
--        ctld.inTransitTroops[_event.initiator:getName()] = nil
--
--        -- env.info(_event.initiator:getName())
--    end
--
--end

-- create crate lookup table
for _subMenuName, _crates in pairs(ctld.spawnableCrates) do

    for _, _crate in pairs(_crates) do
        -- convert number to string otherwise we'll have a pointless giant
        -- table. String means 'hashmap' so it will only contain the right number of elements
        ctld.crateLookupTable[tostring(_crate.weight)] = _crate
    end
end


--sort out pickup zones
for _, _zone in pairs(ctld.pickupZones) do

    local _zoneName = _zone[1]
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


-- Scheduled functions (run cyclically)

timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
timer.scheduleFunction(ctld.addF10MenuOptions, nil, timer.getTime() + 5)
timer.scheduleFunction(ctld.checkAIStatus,nil,timer.getTime() + 5)
timer.scheduleFunction(ctld.checkTransportStatus,nil,timer.getTime()+5)
timer.scheduleFunction(ctld.refreshRadioBeacons,nil,timer.getTime()+5)


--event handler for deaths
--world.addEventHandler(ctld.eventHandler)

--env.info("CTLD event handler added")

env.info("Generating Laser Codes")
ctld.generateLaserCode()
env.info("Generated Laser Codes")

env.info("CTLD READY")
--DEBUG FUNCTION
--        for key, value in pairs(getmetatable(_spawnedCrate)) do
--            env.info(tostring(key))
--            env.info(tostring(value))
--        end