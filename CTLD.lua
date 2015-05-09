--[[
    Combat Troop and Logistics Drop

    Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via slingloads
    without requiring external mods via sling loads

    Once a crate is dropped in the field, it must be unpacked by landing next to it and using the radio menu to start the unpack

    Some vehicles may require more than one crate in close proximity

    Troop

    Supports usual CTTS functions such as spawn group

    Huey max carry weight = 4000lb / 1814.37 kg
    Mi-8 Max carry weight = 6614lb / 3000 kg
    C-130 Max Carry Weight - 26,634 lb
         - Two HMMWV (ATGM + MG ) and 10 troops
        - It can actually hold  92 ground troops, 64 fully equipped paratroopers, or 74 litter patients
            - Source http://fas.org/man/dod-101/sys/ac/c-130.htm

 ]]

ctld = {}

-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************

ctld.disableAllSmoke = false -- if true, all smoke is diabled regardless of settings below. Leave false to respect settings below
ctld.enableCrates = true -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.enableSmokeDrop = true -- if false, helis and c-130 will not be able to drop smoke

ctld.maxExtractDistance = 125 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic = 200 -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.maximumSearchDistance = 4000 -- max distance for troops to search for enemy
ctld.maximumMoveDistance = 1000 -- max distance for troops to move from drop point if no enemy is nearby

ctld.numberOfTroops = 10 -- default number of troops to load on a transport heli or C-130

ctld.vehiclesForTransport = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 or hercules

ctld.spawnRPGWithCoalition = true --spawns a friendly RPG unit with Coalition forces


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

ctld.vehicleTransportEnabled = {
    "C-130",
}


-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

assert(mist ~= nil, "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

ctld.addedTo = {}
ctld.spawnedCratesRED = {} -- use to store crates that have been spawned
ctld.spawnedCratesBLUE = {} -- use to store crates that have been spawned

ctld.droppedTroopsRED = {} -- stores dropped troop groups
ctld.droppedTroopsBLUE = {} -- stores dropped troop groups

ctld.droppedVehiclesRED = {} -- stores vehicle groups for c-130 / hercules
ctld.droppedVehiclesBLUE = {} -- stores vehicle groups for c-130 / hercules

ctld.inTransitTroops = {}

ctld.completeHawkSystems = {} -- stores complete spawned groups from multiple crates

-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
ctld.spawnableCrates = {
    ["M1045 HMMWV TOW"] = { weight = 1400, desc = "HMMWV - TOW", unit = "M1045 HMMWV TOW" },
    ["M1043 HMMWV Armament"] = { weight = 1200, desc = "HMMWV - MG", unit = "M1043 HMMWV Armament" },
    ["2B11 mortar"] = { weight = 200, desc = "2B11 Mortar", unit = "2B11 mortar" },
    ["Stinger manpad"] = { weight = 210, desc = "MANPAD", unit = "Stinger manpad" },
    ["Hawk ln"] = { weight = 1000, desc = "HAWK Launcher", unit = "Hawk ln" },
    ["Hawk sr"] = { weight = 1010, desc = "HAWK Search Radar", unit = "Hawk sr" },
    ["Hawk tr"] = { weight = 1020, desc = "HAWK Track Radar", unit = "Hawk tr" },
}


--used to lookup what the crate will contain
ctld.crateLookupTable = {}

for _name, _crate in pairs(ctld.spawnableCrates) do
    -- convert number to string otherwise we'll have a pointless giant
    -- table. String means 'hashmap' so it will only contain the right number of elements
    ctld.crateLookupTable[tostring(_crate.weight)] = _name
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


--- - Sort out extractable groups

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


------------ EXTERNAL FUNCTIONS FOR MISSION EDITOR -----------



-----------------------------------------------------------------
-- Spawn group at a trigger and sets them as extractable. Usage:
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

    if _groupSide == "red" then
        _groupSide = 1
    else
        _groupSide = 2
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

    local _types = ctld.generateTroopTypes(_groupSide,_number)

    local _droppedTroops = ctld.spawnDroppedGroup(_groupSide,_pos3, _types, false,_searchRadius);

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




---------------- INTERNAL FUNCTIONS ----------------

-- Remove intransit troops when heli / cargo plane dies
ctld.eventHandler = {}
function ctld.eventHandler:onEvent(_event)

    if _event == nil or _event.initiator == nil then
        env.info("CTLD null event")
    elseif _event.id == 9 then
        -- Pilot dead
        ctld.inTransitTroops[_event.initiator:getName()] = nil

    elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
        -- env.info("Event unit - Pilot Ejected or Unit Dead")
        ctld.inTransitTroops[_event.initiator:getName()] = nil

       -- env.info(_event.initiator:getName())
    end

end

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

function ctld.spawnCrateStatic(_side,_unitId,_point,_name,_weight)

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

    local _spawnedCrate

    if _side == 1 then
        _spawnedCrate = coalition.addStaticObject(_side, _crate)
    else
        _spawnedCrate = coalition.addStaticObject(_side, _crate)
    end

    return _spawnedCrate
end

function ctld.spawnCrate(_args)

    -- use the cargo weight to guess the type of unit as no way to add description :(

    local _crateType = ctld.spawnableCrates[_args[2]]
    local _heli = ctld.getTransportUnit(_args[1])

    if _crateType ~= nil and _heli ~= nil and _heli:inAir() == false then

        if ctld.inLogisticsZone(_heli) == false then

            ctld.displayMessageToGroup(_heli, "You are not close enough to friendly logistics to get a crate!", 10)

            return
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

        local _spawnedCrate =  ctld.spawnCrateStatic(_side,_unitId,{x=_point.x+_xOffset,z=_point.z + _yOffset},_name,_crateType.weight)

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

            if _onboard.troops ~= nil and #_onboard.troops > 0 then
                return true
            else
                return false
            end
        else

            if _onboard.vehicles ~= nil and #_onboard.vehicles > 0 then
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

        if _onboard.troops ~= nil and #_onboard.troops > 0 then

            local _droppedTroops = ctld.spawnDroppedGroup(_heli:getCoalition(),_heli:getPoint(), _onboard.troops, false)

            if _heli:getCoalition() == 1 then

                table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
            else

                table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
            end

            ctld.inTransitTroops[_heli:getName()].troops = {}
            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " dropped troops from " .. _heli:getTypeName() .. " into combat", 10)

        end
    else
        if _onboard.vehicles ~= nil and #_onboard.vehicles > 0 then

            local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getCoalition(),_heli:getPoint(), _onboard.vehicles, true)

            if _heli:getCoalition() == 1 then

                table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
            else

                table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
            end

            ctld.inTransitTroops[_heli:getName()].vehicles = {}

            trigger.action.outTextForCoalition(_heli:getCoalition(),ctld.getPlayerNameOrType(_heli) .. " dropped vehicles from " .. _heli:getTypeName() .. " into combat", 10)

        end
    end

end



function ctld.generateTroopTypes(_side,_count)

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

        _troops[_i] = _unitType
    end

   return _troops
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

    if _troops then

       _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(),_number)

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded ".._number.." troops into " .. _heli:getTypeName(), 10)

    else

        for _i, _type in ipairs(ctld.vehiclesForTransport) do
            _onboard.vehicles[_i] = _type
        end

        local _count = #ctld.vehiclesForTransport

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded ".._count.." vehicles into " .. _heli:getTypeName(), 10)

    end

    ctld.inTransitTroops[_heli:getName()] = _onboard

end

function ctld.loadUnloadTroops(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    local _inZone = ctld.inPickupZone(_heli)

    if _inZone == true and ctld.troopsOnboard(_heli,_troops) then

        if _troops then
            ctld.displayMessageToGroup(_heli, "Dropped troops back to base", 20)
            ctld.inTransitTroops[_heli:getName()].troops = {}

        else
            ctld.displayMessageToGroup(_heli, "Dropped vehicles back to base", 20)
            ctld.inTransitTroops[_heli:getName()].vehicles = {}

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
        _onboard =  { troops = {}, vehicles = {} }
    end

    if _troops then

        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end

        if _extractTroops ~= nil then

            _onboard.troops = _extractTroops.types

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted troops in " .. _heli:getTypeName() .. " from combat", 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            --remove
            _extractTroops.group:destroy()

        else
            _onboard.troops = {}
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
            _onboard.vehicles = _extractVehicles.types

            if _heli:getCoalition() == 1 then

                ctld.droppedVehiclesRED[_extractVehicles.group:getName()] = nil
            else

                ctld.droppedVehiclesBLUE[_extractVehicles.group:getName()] = nil
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted vehicles in " .. _heli:getTypeName() .. " from combat", 10)

            --remove
            _extractVehicles.group:destroy()


        else
            _onboard.vehicles = {}
            ctld.displayMessageToGroup(_heli, "No extractable vehicles nearby and not in a pickup zone", 20)
        end

    end

    ctld.inTransitTroops[_heli:getName()] = _onboard

end


function ctld.checkTroopStatus(_args)

    --list onboard troops, if c130

    -- trigger.action.outText("Troop Status".._args[1],10)


    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        ctld.displayMessageToGroup(_heli, "No troops onboard", 10)
    else
        local _troops = #_onboard.troops
        local _vehicles = #_onboard.vehicles

        local _txt = ""

        if _troops > 0 then
            _txt = _txt .. " " .. _troops .. " troops onboard\n"
        end

        if _vehicles > 0 then
            _txt = _txt .. " " .. _vehicles .. " vehicles onboard\n"
        end

        if _txt ~= "" then
            ctld.displayMessageToGroup(_heli, _txt, 10)
        else
            ctld.displayMessageToGroup(_heli, "No troops onboard", 10)
        end
    end
end

function ctld.listNearbyCrates(_args)

    --trigger.action.outText("Nearby Crates" .. _args[1], 10)

    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil then

        local _crates = ctld.getCratesAndDistance(_heli)

        for _, _crate in pairs(_crates) do

            if _crate.dist < 1000 then
                _message = string.format("%s\n%s crate - kg %i - %i m", _message, _crate.details.desc, _crate.details.weight, _crate.dist)
            end
        end
    end

    if _message ~= "" then

        local _txt = "Nearby Crates:\n" .. _message

        ctld.displayMessageToGroup(_heli, _txt, 20)

    else
        --no crates nearby

        local _txt = "No Nearby Crates"

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.displayMessageToGroup(_unit, _text, _time)

    trigger.action.outTextForGroup(_unit:getGroup():getID(), _text, _time)
end

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

    return _crates
end

function ctld.getClosestCrate(_heli, _crates)

    local _closetCrate = nil
    local _shortestDistance = -1
    local _distance = 0

    for _, _crate in pairs(_crates) do

        _distance = _crate.dist

        if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
            _shortestDistance = _distance
            _closetCrate = _crate
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

        if _crate ~= nil and _crate.dist < 200 then

           if ctld.inLogisticsZone(_heli) == true then

              ctld.displayMessageToGroup(_heli, "You can't unpack that here! Take it to where it's needed!", 20)

              return
          end

            -- is multi crate?
            if string.match(_crate.details.desc, "HAWK") then
                -- multicrate

                -- are we adding to existing hawk system?
                if _crate.details.unit == "Hawk ln" then

                    -- find nearest COMPLETE hawk system
                    local _nearestHawk =  ctld.findNearestHawk(_heli)

                    if _nearestHawk ~=nil and _nearestHawk.dist < 300 then

                        if _heli:getCoalition() == 1 then

                            ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                        else

                            ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
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

                            return -- all done so quit
                        end


                    end

                end


                -- are there all the pieces close enough together
                local _hawkParts = { ["Hawk ln"] = false, ["Hawk tr"] = false, ["Hawk sr"] = false }

                for _, _nearbyCrate in pairs(_crates) do

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

            else
                -- single crate
                local _cratePoint = _crate.crateUnit:getPoint()
                local _crateName = _crate.crateUnit:getName();

             -- ctld.spawnCrateStatic( _heli:getCoalition(),mist.getNextUnitId(),{x=100,z=100},_crateName,100)

                --remove crate
                _crate.crateUnit:destroy()

                 ctld.spawnCrateGroup(_heli, { _cratePoint }, { _crate.details.unit })

                if _heli:getCoalition() == 1 then

                    ctld.spawnedCratesRED[_crateName] = nil
                else

                    ctld.spawnedCratesBLUE[_crateName] = nil
                end

                trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully deployed " .. _crate.details.desc .. " to the field", 10)
            end

        else

            ctld.displayMessageToGroup(_heli, "No friendly crates close enough to unpack", 20)
        end
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

        _group.units[1] = ctld.createUnit(_positions[1].x + 5, _positions[1].z + 5, 120, _types[1])

    else

        for _i, _pos in ipairs(_positions) do
            _group.units[_i] = ctld.createUnit(_pos.x + 5, _pos.z + 5, 120, _types[_i])
        end
    end

    local _spawnedGroup = coalition.addGroup(_side, Group.Category.GROUND, _group)

    --activate by moving and so we can set ROE and Alarm state

    local _dest = _spawnedGroup:getUnit(1):getPoint()
    _dest = { x = _dest.x + 5, _y = _dest.y + 5, z = _dest.z + 5 }

    ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _dest)

    return _spawnedGroup
end



-- spawn normal group
function ctld.spawnDroppedGroup(_side,_point, _types, _spawnBehind,_maxSearch)

    local _id = mist.getNextGroupId()

    local _groupName = "Dropped Group  #" .. _id

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


    if _spawnBehind == false then

        -- spawn in circle around heli

        local _pos = _point

        for _i, _type in ipairs(_types) do

            local _angle = math.pi * 2 * (_i - 1) / #_types
            local _xOffset = math.cos(_angle) * 30
            local _yOffset = math.sin(_angle) * 30

            _group.units[_i] = ctld.createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _type)
        end

    else

        local _pos = _point

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * 30
        local _yOffset = math.sin(_angle) * 30


        for _i, _type in ipairs(_types) do
            _group.units[_i] = ctld.createUnit(_pos.x - (_xOffset + 10 * _i), _pos.z - (_yOffset + 10 * _i), _angle, _type)
        end
    end

    local _spawnedGroup = coalition.addGroup(_side, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    if _maxSearch == nil then
        _maxSearch = ctld.maximumSearchDistance
    end

    local _enemyPos = ctld.findNearestEnemy(_side,_point,_maxSearch)

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

    local _closestGroupTypes = {}
    local _closestGroup = nil

    local _closestGroupDist = ctld.maxExtractDistance

    local _heliPoint = _heli:getPoint()

    for _, _groupName in pairs(_groups) do

        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then

                local _leader = nil

                local _unitTypes = {}

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then

                        if _leader == nil then
                            _leader = _units[x]
                        end

                        table.insert(_unitTypes, _units[x]:getTypeName())
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestGroupDist then
                        _closestGroupDist = _dist
                        _closestGroupTypes = _unitTypes
                        _closestGroup = _group
                    end
                end
            end
        end
    end


    if _closestGroup ~= nil then

        return { group = _closestGroup, types = _closestGroupTypes }
    else

        return nil
    end
end


function ctld.createUnit(_x, _y, _angle, _type)

    local _id = mist.getNextUnitId();

    local _name = string.format("%s #%s", _type, _id)

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _type,
        ["name"] = _name,
        ["unitId"] = _id,
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

    return false
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

    local _type = _unit:getTypeName()

    for _,_name in pairs(ctld.vehicleTransportEnabled) do

        if string.match(_type, _name) then
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
function addTransportMenuItem()
    -- Loop through all Heli units

    timer.scheduleFunction(addTransportMenuItem, nil, timer.getTime() + 5)

    for _, _unitName in pairs(ctld.transportPilotNames) do

        local _unit = ctld.getTransportUnit(_unitName)

        if _unit ~= nil then

            local _groupId = _unit:getGroup():getID()

            if ctld.addedTo[_groupId] == nil and _unit:getPlayerName() ~= nil then

                missionCommands.addSubMenuForGroup(_groupId, "Troop Transport")
                missionCommands.addCommandForGroup(_groupId, "Load / Unload Troops", { "Troop Transport" }, ctld.loadUnloadTroops, { _unitName,true })

                if ctld.unitCanCarryVehicles(_unit) then
                    missionCommands.addCommandForGroup(_groupId, "Load / Unload Vehicles", { "Troop Transport" }, ctld.loadUnloadTroops, { _unitName,false })
                end

                missionCommands.addCommandForGroup(_groupId, "Check Status", { "Troop Transport" }, ctld.checkTroopStatus, { _unitName })

                if ctld.enableCrates then

                    if ctld.unitCanCarryVehicles(_unit) == false then

                        missionCommands.addSubMenuForGroup(_groupId, "Ground Forces")
                        missionCommands.addCommandForGroup(_groupId, "HMMWV - TOW", { "Ground Forces" }, ctld.spawnCrate, { _unitName, "M1045 HMMWV TOW" })
                        missionCommands.addCommandForGroup(_groupId, "HMMWV - MG", { "Ground Forces" }, ctld.spawnCrate, { _unitName, "M1043 HMMWV Armament" })

                        missionCommands.addCommandForGroup(_groupId, "2B11 Mortar", { "Ground Forces" }, ctld.spawnCrate, { _unitName, "2B11 mortar" })

                        missionCommands.addSubMenuForGroup(_groupId, "AA Crates")
                        missionCommands.addCommandForGroup(_groupId, "MANPAD", { "AA Crates" }, ctld.spawnCrate, { _unitName, "Stinger manpad" })

                        missionCommands.addCommandForGroup(_groupId, "HAWK Launcher", { "AA Crates" }, ctld.spawnCrate, { _unitName, "Hawk ln" })
                        missionCommands.addCommandForGroup(_groupId, "HAWK Search Radar", { "AA Crates" }, ctld.spawnCrate, { _unitName, "Hawk sr" })
                        missionCommands.addCommandForGroup(_groupId, "HAWK Track Radar", { "AA Crates" }, ctld.spawnCrate, { _unitName, "Hawk tr" })

                    end

                    missionCommands.addSubMenuForGroup(_groupId, "Crate Commands")
                    missionCommands.addCommandForGroup(_groupId, "List Nearby Crates", { "Crate Commands" }, ctld.listNearbyCrates, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, "Unpack Crate", { "Crate Commands" }, ctld.unpackCrates, { _unitName })

                    if ctld.enableSmokeDrop then
                        missionCommands.addCommandForGroup(_groupId, "Drop Red Smoke", { "Crate Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                        missionCommands.addCommandForGroup(_groupId, "Drop Blue Smoke", { "Crate Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                    --    missionCommands.addCommandForGroup(_groupId, "Drop Orange Smoke", { "Crate Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                        missionCommands.addCommandForGroup(_groupId, "Drop Green Smoke", { "Crate Commands" }, ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
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

                ctld.addedTo[_groupId] = true
            end
        else
            -- env.info(string.format("unit nil %s",_unitName))
        end
    end

    return
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




-- Scheduled functions (run cyclically)

timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
timer.scheduleFunction(addTransportMenuItem, nil, timer.getTime() + 5)
timer.scheduleFunction(ctld.checkAIStatus,nil,timer.getTime() + 5)

--event handler for deaths
world.addEventHandler(ctld.eventHandler)

env.info("CTLD event handler added")

--DEBUG FUNCTION
--        for key, value in pairs(getmetatable(_spawnedCrate)) do
--            env.info(tostring(key))
--            env.info(tostring(value))
--        end
