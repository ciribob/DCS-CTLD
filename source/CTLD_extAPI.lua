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

CTLD_extAPI.getAvgPos        = function(caller, ...)
    if not (framework and framework.getAvgPos) then
        logError('[CTLD_extAPI ERROR] getAvgPos unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.getAvgPos(...)
end

CTLD_extAPI.getGroupRoute    = function(caller, ...)
    if not (framework and framework.getGroupRoute) then
        logError('[CTLD_extAPI ERROR] getGroupRoute unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.getGroupRoute(...)
end

CTLD_extAPI.getHeading       = function(caller, ...)
    if not (framework and framework.getHeading) then
        logError('[CTLD_extAPI ERROR] getHeading unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end

    return framework.getHeading(...)
end

CTLD_extAPI.getUnitsLOS      = function(caller, ...)
    if not (framework and framework.getUnitsLOS) then
        logError('[CTLD_extAPI ERROR] getUnitsLOS unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.getUnitsLOS(...)
end

CTLD_extAPI.makeUnitTable    = function(caller, ...)
    if not (framework and framework.makeUnitTable) then
        logError('[CTLD_extAPI ERROR] makeUnitTable unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.makeUnitTable(...)
end

CTLD_extAPI.scheduleFunction = function(caller, ...)
    if not (framework and framework.scheduleFunction) then
        logError('[CTLD_extAPI ERROR] scheduleFunction unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.scheduleFunction(...)
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
-- ground
-- ================================================================

CTLD_extAPI.ground           = CTLD_extAPI.ground or {}

CTLD_extAPI.ground.buildWP   = function(caller, ...)
    if not (framework and framework.ground and framework.ground.buildWP) then
        logError('[CTLD_extAPI ERROR] ground.buildWP unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.ground.buildWP(...)
end

-- ================================================================
-- utils
-- ================================================================

CTLD_extAPI.utils            = CTLD_extAPI.utils or {}

CTLD_extAPI.utils.deepCopy   = function(caller, ...)
    if not (framework and framework.utils and framework.utils.deepCopy) then
        logError('[CTLD_extAPI ERROR] utils.deepCopy unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.deepCopy(...)
end

CTLD_extAPI.utils.get2DDist  = function(caller, ...)
    if not (framework and framework.utils and framework.utils.get2DDist) then
        logError('[CTLD_extAPI ERROR] utils.get2DDist unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.get2DDist(...)
end

CTLD_extAPI.utils.getDir     = function(caller, ...)
    if not (framework and framework.utils and framework.utils.getDir) then
        logError('[CTLD_extAPI ERROR] utils.getDir unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.getDir(...)
end

CTLD_extAPI.utils.makeVec2   = function(caller, ...)
    if not (framework and framework.utils and framework.utils.makeVec2) then
        logError('[CTLD_extAPI ERROR] utils.makeVec2 unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.makeVec2(...)
end

CTLD_extAPI.utils.makeVec3   = function(caller, ...)
    if not (framework and framework.utils and framework.utils.makeVec3) then
        logError('[CTLD_extAPI ERROR] utils.makeVec3 unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.makeVec3(...)
end

CTLD_extAPI.utils.round      = function(caller, ...)
    if not (framework and framework.utils and framework.utils.round) then
        logError('[CTLD_extAPI ERROR] utils.round unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.round(...)
end

CTLD_extAPI.utils.tableShow  = function(caller, ...)
    if not (framework and framework.utils and framework.utils.tableShow) then
        logError('[CTLD_extAPI ERROR] utils.tableShow unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.tableShow(...)
end

CTLD_extAPI.utils.toDegree   = function(caller, ...)
    if not (framework and framework.utils and framework.utils.toDegree) then
        logError('[CTLD_extAPI ERROR] utils.toDegree unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.toDegree(...)
end

CTLD_extAPI.utils.zoneToVec3 = function(caller, ...)
    if not (framework and framework.utils and framework.utils.zoneToVec3) then
        logError('[CTLD_extAPI ERROR] utils.zoneToVec3 unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.utils.zoneToVec3(...)
end

-- ================================================================
-- vec
-- ================================================================

CTLD_extAPI.vec              = CTLD_extAPI.vec or {}

CTLD_extAPI.vec.dp           = function(caller, ...)
    if not (framework and framework.vec and framework.vec.dp) then
        logError('[CTLD_extAPI ERROR] vec.dp unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.vec.dp(...)
end

CTLD_extAPI.vec.mag          = function(caller, ...)
    if not (framework and framework.vec and framework.vec.mag) then
        logError('[CTLD_extAPI ERROR] vec.mag unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.vec.mag(...)
end

CTLD_extAPI.vec.sub          = function(caller, ...)
    if not (framework and framework.vec and framework.vec.sub) then
        logError('[CTLD_extAPI ERROR] vec.sub unavailable (' ..
            tostring(frameworkName) .. ') Caller: ' .. tostring(caller))
        return nil
    end
    return framework.vec.sub(...)
end

-- ================================================================
-- End of CTLD_extAPI.lua
-- ================================================================
