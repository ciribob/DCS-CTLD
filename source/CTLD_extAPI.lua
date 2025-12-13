-- ================================================================
-- CTLD_extAPI.lua (auto-generated)
-- Mirrors used mist/Moose paths with wrappers (caller-as-first-arg)
-- ================================================================
if trigger == nil then
    trigger = { action = { outText = function(msg, time) print('[DCS outText] '..msg) end } }
end

CTLD_extAPI = CTLD_extAPI or {}
local framework = nil
local frameworkName = nil
if mist ~= nil then framework = mist frameworkName = 'MIST' elseif Moose ~= nil then framework = Moose frameworkName = 'MOOSE' end

local function logError(msg)
    local ok, err = pcall(function()
        if trigger and trigger.action and trigger.action.outText then
            trigger.action.outText(msg, 15)
        else
            print(msg)
        end
        if env and env.info then env.info(msg) end
    end)
end

CTLD_extAPI.DBs = CTLD_extAPI.DBs or {}
CTLD_extAPI.DBs.humansByName = (framework.DBs.humansByName) or nil
CTLD_extAPI.DBs.unitsById = (framework.DBs.unitsById) or nil
CTLD_extAPI.DBs.unitsByName = (framework.DBs.unitsByName) or nil
CTLD_extAPI.dynAdd = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for dynAdd. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.dynAdd
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: dynAdd (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: dynAdd (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.dynAddStatic = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for dynAddStatic. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.dynAddStatic
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: dynAddStatic (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: dynAddStatic (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.getAvgPos = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for getAvgPos. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.getAvgPos
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: getAvgPos (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: getAvgPos (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.getGroupRoute = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for getGroupRoute. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.getGroupRoute
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: getGroupRoute (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: getGroupRoute (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.getHeading = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for getHeading. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.getHeading
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: getHeading (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: getHeading (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.getUnitsLOS = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for getUnitsLOS. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.getUnitsLOS
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: getUnitsLOS (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: getUnitsLOS (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.ground = CTLD_extAPI.ground or {}
CTLD_extAPI.ground.buildWP = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for ground.buildWP. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.ground.buildWP
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: ground.buildWP (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: ground.buildWP (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.makeUnitTable = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for makeUnitTable. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.makeUnitTable
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: makeUnitTable (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: makeUnitTable (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.scheduleFunction = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for scheduleFunction. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.scheduleFunction
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: scheduleFunction (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: scheduleFunction (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.tostringLL = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for tostringLL. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.tostringLL
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: tostringLL (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: tostringLL (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.tostringMGRS = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for tostringMGRS. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.tostringMGRS
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: tostringMGRS (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: tostringMGRS (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils = CTLD_extAPI.utils or {}
CTLD_extAPI.utils.deepCopy = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.deepCopy. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.deepCopy
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.deepCopy (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.deepCopy (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.get2DDist = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.get2DDist. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.get2DDist
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.get2DDist (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.get2DDist (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.getDir = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.getDir. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.getDir
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.getDir (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.getDir (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.makeVec2 = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.makeVec2. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.makeVec2
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.makeVec2 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.makeVec2 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.makeVec3 = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.makeVec3. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.makeVec3
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.makeVec3 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.makeVec3 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.round = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.round. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.round
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.round (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.round (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.tableShow = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.tableShow. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.tableShow
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.tableShow (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.tableShow (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.toDegree = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.toDegree. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.toDegree
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.toDegree (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.toDegree (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.utils.zoneToVec3 = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for utils.zoneToVec3. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.utils.zoneToVec3
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: utils.zoneToVec3 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: utils.zoneToVec3 (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.vec = CTLD_extAPI.vec or {}
CTLD_extAPI.vec.dp = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for vec.dp. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.vec.dp
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: vec.dp (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: vec.dp (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.vec.mag = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for vec.mag. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.vec.mag
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: vec.mag (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: vec.mag (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

CTLD_extAPI.vec.sub = function(caller, ...)
    -- wrapper: check framework and target function existence
    if framework == nil then
        logError('[CTLD_extAPI ERROR] Missing framework for vec.sub. Required: MIST or MOOSE. Caller: '..tostring(caller))
        return nil
    end
    local target = framework.vec.sub
    if target == nil then
        logError('[CTLD_extAPI ERROR] Missing path: vec.sub (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    if type(target) ~= 'function' then
        logError('[CTLD_extAPI ERROR] Target is not a function: vec.sub (framework: '..tostring(frameworkName)..'). Caller: '..tostring(caller))
        return nil
    end
    return target(...)
end

-- End of CTLD_extAPI.lua