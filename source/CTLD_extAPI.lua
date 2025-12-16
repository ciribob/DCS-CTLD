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
-- End of CTLD_extAPI.lua
-- ================================================================
