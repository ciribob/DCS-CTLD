-- DcsObjectsDescDb.lua
-- Database of DCS objects descriptions for CTLD object spawning
----------------------------------------------------------------
ctld.objectsDescDb = {}
ctld.objectsDescDb["FARP"] = {
    desc =
        function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
            return {
                groupType = "STATIC",
                shape_name = "FARPS",
                type = "FARP",
                name = "FARP", -- groupName Prefix
                category = "Heliports",
                countryId = countryId,
                x = x,
                y = y, --vec3.z
                task = "Ground Nothing",
                skill = "High",
                start_time = 0,                  -- If 0 the group will spawn immediately
                transportable = { randomTransportable = false },
                heading = headingInRadians or 0, -- In Radians
                heliport_frequency = "127.5",
                heliport_callsign_id = 1,
                heliport_modulation = 0,
            } -- groupData
        end
}
-----------------------------------------------------------
ctld.objectsDescDb["SINGLE_HELIPAD"] = {
    desc =
        function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
            return {
                groupType = "STATIC",
                name = "SINGLE_HELIPAD", -- groupName Prefix
                category = "Heliports",
                countryId = countryId,
                x = x,
                y = y, -- vec3.z
                task = "Ground Nothing",
                skill = "High",
                start_time = 0, -- If 0 the group will spawn immediately
                shape_name = "FARP",
                type = "SINGLE_HELIPAD",
                unitName = "SINGLE_HELIPAD_Unit", -- unitNamePrefix
                transportable = { randomTransportable = false },
                heading = headingInRadians or 0,  -- In Radians
                heliport_frequency = "127.5",
                heliport_callsign_id = 1,
                heliport_modulation = 0,
            } -- groupData
        end
}
-----------------------------------------------------------
ctld.objectsDescDb["Farp_FG_Petit_Helipad"] = {
    desc =
        function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- specific mod !
            return {
                groupType = "STATIC",
                shape_name = "Farp_FG_Petit_Helipad.edm",
                type = "Farp_FG_Petit_Helipad",
                name = "FARP_Helipad", -- groupName Prefix
                category = "Heliports",
                countryId = countryId,
                x = x,
                y = y, -- vec3.z
                task = "Ground Nothing",
                skill = "High",
                start_time = 0,                  -- If 0 the group will spawn immediately
                transportable = { randomTransportable = false },
                heading = headingInRadians or 0, -- In Radians
                heliport_frequency = "127.5",
                heliport_callsign_id = 1,
                heliport_modulation = 0,
            } -- groupData
        end
}
-----------------------------------------------------------
ctld.objectsDescDb["FARP_Tent"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType = "STATIC",
            name = "FARP_Tent", -- groupName Prefix
            category = Object.Category.STATIC,
            countryId = countryId,
            x = x,
            y = y,          -- vec3.z
            task = "Ground Nothing",
            start_time = 0, -- If 0 the group will spawn immediately
            skill = "High",
            type = "FARP Tent",
            transportable = { randomTransportable = false },
            heading = headingInRadians or 0, -- In Radians
        }                                    -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["FARP_Ammo_Storage"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType = "STATIC",
            name = "FARP_Ammo_Storage", -- groupName Prefix
            category = Object.Category.STATIC,
            countryId = countryId,
            x = x,
            y = y,          --vec3.z
            task = "Ground Nothing",
            start_time = 0, -- If 0 the group will spawn immediately
            skill = "High",
            type = "FARP Ammo Dump Coating",
            transportable = { randomTransportable = false },
            heading = headingInRadians or 0, -- In Radians
        }                                    -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["barrels_cargo"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType = "STATIC",
            name = "barrels_cargo", -- groupName Prefix
            category = "Cargos",
            countryId = countryId,
            x = x,
            y = y,          --vec3.z
            task = "Ground Nothing",
            start_time = 0, -- If 0 the group will spawn immediately
            skill = "High",
            rate = 100,
            type = "barrels_cargo",
            shape_name = "barrels_cargo",
            transportable = { randomTransportable = false },
            heading = headingInRadians or 0, -- In Radians
        }                                    -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["ammo_cargo"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType = "STATIC",
            name = "ammo_box_cargo", -- groupName Prefix
            category = "Cargos",
            countryId = countryId,
            x = x,
            y = y,          --vec3.z
            task = "Ground Nothing",
            start_time = 0, -- If 0 the group will spawn immediately
            skill = "High",
            rate = 1,
            type = "ammo_cargo",
            shape_name = "ammo_box_cargo",
            transportable = { randomTransportable = false },
            heading = headingInRadians or 0, -- In Radians
        }                                    -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["Cargo06"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType = "STATIC",
            name = "ammo_box06", -- groupName Prefix
            category = "Cargos",
            countryId = countryId,
            x = x,
            y = y,          --vec3.z
            task = "Ground Nothing",
            start_time = 0, -- If 0 the group will spawn immediately
            skill = "High",
            rate = 1,
            type = "Cargo06",
            shape_name = "M92_Cargo06",
            transportable = { randomTransportable = false },
            heading = headingInRadians or 0, -- In Radians
        }                                    -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["us carrier shooter"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType     = "STATIC",
            name          = "carrier_shooter", -- groupName Prefix
            category      = "Personnel",
            countryId     = countryId,
            x             = x,
            y             = y, --vec3.z
            task          = "Ground Nothing",
            start_time    = 0, -- If 0 the group will spawn immediately
            skill         = "High",
            rate          = 20,
            type          = "us carrier shooter",
            shape_name    = "carrier_shooter",
            livery_id     = "blue",
            transportable = { randomTransportable = false },
            heading       = headingInRadians or 0, -- In Radians
        }                                          -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["Tower Crane"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType     = "STATIC",
            name          = "TowerCrane", -- groupName Prefix
            category      = "Fortifications",
            countryId     = countryId,
            x             = x,
            y             = y, --vec3.z
            task          = "Ground Nothing",
            start_time    = 0, -- If 0 the group will spawn immediately
            rate          = 100,
            type          = "Tower Crane",
            shape_name    = "TowerCrane_01",
            transportable = { randomTransportable = false },
            heading       = headingInRadians or 0, -- In Radians
        }                                          -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["NF-2_LightOn"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType     = "STATIC",
            name          = "LightOn", -- groupName Prefix
            category      = "Fortifications",
            countryId     = countryId,
            x             = x,
            y             = y, --vec3.z
            task          = "Ground Nothing",
            start_time    = 0, -- If 0 the group will spawn immediately
            rate          = 100,
            type          = "NF-2_LightOn",
            shape_name    = "M92_NF-2_LightOn",
            transportable = { randomTransportable = false },
            heading       = headingInRadians or 0, -- In Radians
        }                                          -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["Windsock"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        return {
            groupType     = "STATIC",
            name          = "Windsock", -- groupName Prefix
            category      = "Fortifications",
            countryId     = countryId,
            x             = x,
            y             = y, --vec3.z
            task          = "Ground Nothing",
            start_time    = 0, -- If 0 the group will spawn immediately
            rate          = 3,
            type          = "Windsock",
            shape_name    = "H-Windsock_RW",
            transportable = { randomTransportable = false },
            heading       = headingInRadians or 0, -- In Radians
        }                                          -- groupData
    end
}
--------------------------------------------------------
ctld.objectsDescDb["Fuel_Truck"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        local unitType = "M978 HEMTT Tanker"                                          -- by default blueSide
        if coalitionId == coalition.side.RED then
            unitType = "ATZ-10"
        end

        return {
            groupType = "GROUND",
            name = "Fuel_Truck_Grp", -- groupName Prefixes},
            category = Unit.Category["GROUND_UNIT"],
            coalitionId = coalitionId,
            countryId = countryId,
            hidden = false,
            task = "Ground Nothing",
            visible = false,
            tasks = {},
            startTime = 0,
            start_time = 0, -- If 0 the group will spawn immediately
            units = {
                [1] = {
                    type = unitType,          -- DCS typeName
                    category = Unit.Category["GROUND_UNIT"],
                    name = "Fuel_Truck_Unit", -- unitNamePrefix
                    transportable = { randomTransportable = false },
                    skill = "High",
                    playerCanDrive = false,
                    x = x,
                    y = y,                           -- vec3.z
                    heading = headingInRadians or 0, -- In Radians
                }
            }
        }
    end
}
--------------------------------------------------------
ctld.objectsDescDb["repare_Truck"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        local unitType = "M 818"                                                      -- by default blueSide
        if coalitionId == coalition.side.RED then
            unitType = "Ural-375"
        end

        return {
            groupType = "GROUND",
            name = "repare_Truck_Grp", -- groupName Prefixes},
            category = Unit.Category["GROUND_UNIT"],
            visible = false,
            --coalition = "blue",
            coalitionId = coalitionId,
            countryId = countryId,
            hidden = false,
            task = "Ground Nothing",
            visible = false,
            tasks = {},
            startTime = 0,
            start_time = 0, -- If 0 the group will spawn immediately
            units = {
                [1] = {
                    type = unitType,            -- DCS typeName
                    category = Unit.Category["GROUND_UNIT"],
                    name = "repare_Truck_Unit", -- unitNamePrefix
                    transportable = { randomTransportable = false },
                    skill = "High",
                    playerCanDrive = false,
                    x = x,
                    y = y,                           -- vec3.z
                    heading = headingInRadians or 0, -- In Radians
                }
            }
        }
    end
}
--------------------------------------------------------
ctld.objectsDescDb["FARP_Security_Guard"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters) -- DCS standard object
        local unitType = "Soldier M4"                                                 -- by default blueSide
        if coalitionId == coalition.side.RED then
            unitType = "Infantry AK"
        end

        return {
            groupType = "GROUND",
            name = "FARP_Guard_Grp", -- groupName Prefixes},
            category = Unit.Category["GROUND_UNIT"],
            visible = false,
            --coalition = "blue",
            coalitionId = coalitionId,
            countryId = countryId,
            hidden = false,
            task = "Ground Nothing",
            visible = false,
            tasks = {},
            startTime = 0,
            start_time = 0, -- If 0 the group will spawn immediately
            units = {
                { name = "Guard_Infantry", type = unitType, x = x,     y = y,     alt = altitudeInMeters, heading = headingInRadians or 0,                       playerCanDrive = false, skill = "High" },
                { name = "Guard_Infantry", type = unitType, x = x + 3, y = y + 1, alt = altitudeInMeters, heading = headingInRadians + 0.610865 or 0 + 0.610865, playerCanDrive = false, skill = "High" }, --headingInRadians+0,610865 or 0+0,610865
                { name = "Guard_Infantry", type = unitType, x = x + 6, y = y,     alt = altitudeInMeters, heading = headingInRadians + 3.49066 or 0 + 3.49066,   playerCanDrive = false, skill = "High" }, --heading = headingInRadians+3.49066 or 0+3.49066
            }
        }
    end
}

--[[ ---- TEST -----------------------------------------------------
function ctld.spwanObject(coalitionId, objectKey, countryId, x, y, headinInRadians, altitudeInMeters)
    if objectKey and countryId and x and y then
        local groupData = ctld.objectsDescDb[objectKey].desc(coalitionId, countryId, x or 0, y or 0, headinInRadians or 0,
            altitudeInMeters or 0)

        groupData.groupId = ctld.utils.getNextUniqId()
        groupData.name = groupData.name .. '-' .. tostring(groupData.groupId)

        local success, obj = ""
        if string.upper(groupData.groupType) == "STATIC" then
            success, obj = pcall(coalition.addStaticObject, countryId, groupData)
        else -- non-STATIC
            if groupData.units then
                for i, v in ipairs(groupData.units) do
                    groupData.units[i].unitId = ctld.utils.getNextUniqId()
                    groupData.units[i].name = groupData.units[i].name .. '-' .. tostring(groupData.units[i].unitId)
                end
            end
            ms("spawnObject():Pass...1 groupData = " .. mist.utils.tableShow(groupData))
            success, obj = pcall(coalition.addGroup, countryId, groupData.category, groupData)
        end

        if not success then
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    "spwanObject()" .. objectKey .. " Deployment: Failed to spawn Object " ..
                    groupData.name .. ". Error: " .. tostring(obj), 15)
            end
            if env and env.error then env.error("coalition.addStaticObject failed: " .. tostring(obj)) end
            return false
        else
            return obj
        end
    else
        if trigger and trigger.action and trigger.action.outText then
            trigger.action.outText(
                "spwanObject() Deployment: Failed to spawn object. Missing parameters.", 15)
        end
    end
end ]]

--[[ ---------------------------------------------------
local heliName = "h1-1"
local oHeli = Unit.getByName(heliName)
local heliPoint = oHeli:getPoint()
local heliCoalition = oHeli:getCoalition()
local heliHeadingInRadians = mist.getHeading(oHeli, false) -- rawHeading
local heliHeadingInDegrees = math.deg(heliHeadingInRadians)

--local obj = ctld.spwanObject(heliCoalition, "FARP", 2, heliPoint.x - 200, heliPoint.z, heliHeadingInRadians, 100)
--local obj = ctld.spwanObject(heliCoalition, "SINGLE_HELIPAD", 2, heliPoint.x - 400, heliPoint.z, heliHeadingInRadians, 100)
--local obj = ctld.spwanObject(heliCoalition, "Farp_FG_Petit_Helipad", 2, heliPoint.x - 800, heliPoint.z, heliHeadingInRadians, 100)
--local obj = ctld.spwanObject(heliCoalition, "FARP_Tent", 2, heliPoint.x - 40, heliPoint.z, heliHeadingInRadians, 100)
--local obj = ctld.spwanObject(heliCoalition, "FARP_Ammo_Storage", 2, heliPoint.x - 50, heliPoint.z, heliHeadingInRadians, 100)
--local obj = ctld.spwanObject(heliCoalition, "Fuel_Truck", 2, heliPoint.x - 60, heliPoint.z + 50, heliHeadingInRadians, 100)
local obj = ctld.spwanObject(heliCoalition, "FARP_Security_Guard", 2, heliPoint.x - 60, heliPoint.z + 50,
    heliHeadingInRadians, 100)

return mist.utils.tableShow(obj)
 ]]
