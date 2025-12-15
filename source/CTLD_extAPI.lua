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
