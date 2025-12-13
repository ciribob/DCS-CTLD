utils -- ====================================================================================================
-- CLASSE ctld.scene
-- ====================================================================================================

local scene = {}
ctld.scene = scene

scene.__index = scene
scene.Counter = 0
scene.sceneModels = {}
scene.scenes = {}

function scene.getNextsceneNumber()
    scene.Counter = scene.Counter + 1
    return scene.Counter
end

function scene.getByName(name)
    if scene.scenes[name] then
        return scene.scenes[name]
    end
    return nil
end

function scene.getscenesList()
    return scene.scenes
end

--- @function scene:playscene registerScenModel
-- register a scene model defined by sceneTable into scene.sceneModels
-- @param sceneTable complete scene datas (name, stepsDatas, etc.).
function scene.registersceneModel(sceneTable)
    if sceneTable.name and sceneTable.name ~= "" and scene.sceneModels[sceneTable.name] == nil then
        scene.sceneModels[sceneTable.name] = sceneTable
        return true
    else
        return false
    end
end

--- @function scene:playscene
-- create a scene defined by sceneTable and add steps to scene sequencer
-- @param triggerUnitObj  unit object who trigged the scene
-- @param sceneTable complete scene datas (name, stepsDatas, etc.).
function scene.playscene(triggerUnitObj, sceneTable)
    if triggerUnitObj == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD_scene.lua/scene.playscene - ERROR: Can't find triggerUnitObj"),
            10)
        return
    end

    local triggerUnitName = triggerUnitObj:getName()
    local heliPoint = triggerUnitObj:getPoint()
    local heliHeadingInRadians = ctld.utils.getHeadingInRadians(triggerUnitObj)
    local scn = ctld.scene:new(sceneTable.name, triggerUnitObj) --:createscene()
    scn:addStepToscene(sceneTable.stepsDatas)
    scn:executescene(triggerUnitObj)
    return scn
end

function scene:new(name, triggerUnitObj)
    local newscene = {}
    setmetatable(newscene, scene)
    if name and name ~= "" and scene.scenes[name] == nil then
        newscene.name = name
    else
        newscene.name = string.format("CTLD scene #%d", scene.getNextsceneNumber())
    end
    newscene.steps = {}
    newscene.isRunning = false
    newscene.currentStepIndex = 1
    newscene.basePosition = nil
    newscene.baseHeading = 0 -- Nouveau champ pour le cap de l'appareil déclencheur
    newscene.triggerUnitObj = triggerUnitObj
    newscene.spawnedGroupObjects = {}
    scene.scenes[name] = newscene
    return newscene
end

function scene:addSpwanedGroup(triggerUnitObj, spawnedGroupObjects)
    self.triggerUnitObj = triggerUnitObj
    self.spawnedGroupObjects[#self.spawnedGroupObjects + 1] = spawnedGroupObjects
    return true
end

--- @function scene:addStepToscene
-- Add steps to scene sequencer
-- @param stepsTable  complete steps datas (groupData, type, polar, etc.).
function scene:addStepToscene(stepsTable)
    if type(stepsTable) ~= 'table' then -- control
        return self
    end

    for i, v in ipairs(stepsTable) do
        table.insert(self.steps, v)
    end
    return self
end

--- @function scene:executescene
-- start the scene execution
-- @param triggerUnitObj unit object that trigger the scene
function scene:executescene(triggerUnitObj)
    self.triggerUnitObj = triggerUnitObj
    self.refVec3Point = triggerUnitObj:getPoint() -- vec3
    self.refHeadingInRadians = ctld.utils.getHeadingInRadians(triggerUnitObj)
    self.isRunning = true
    self.currentStepIndex = 0
    self.timeProgressMarker = 0

    -- Set up the timer for the 1st step based on delayAfterPreviousStep
    self.timeProgressMarker = timer.getTime() + (tonumber(self.steps[1].delayAfterPreviousStep) or 0)

    if self.timeProgressMarker > timer.getTime() then
        local function bound_runNextStep()
            self:runNextStep()
        end
        timer.scheduleFunction(bound_runNextStep, nil, self.timeProgressMarker)
    else
        self:runNextStep()
    end
end

--===================================================================================================
function scene:runNextStep()
    self.currentStepIndex = self.currentStepIndex + 1 -- next step to execute

    -- run current step
    local step = self.steps[self.currentStepIndex]
    local refHeadingInRadians = self.refHeadingInRadians

    if step.objectsDescDbKey then
        if step.polar and step.polar.distance ~= nil then
            local relativedistance = step.polar.distance or 0
            local relativeAngle = step.polar.angle or 0
            local relativeHeadingInDegrees = step.relativeHeadingInDegrees or 0
            local relativeAltitudeInMeters = step.relativeAltitudeInMeters or 0
            local magneticDeclinationInDegrees = ctld.utils.getMagneticDeclination()
            local coalitionId = self.triggerUnitObj:getCoalition()
            local countryId = self.triggerUnitObj:getCountry()

            local x, y, magneticHeadingInDegrees, altitude = ctld.utils.getRelativeCoords(self.refVec3Point.x,
                self.refVec3Point.z,
                refHeadingInRadians,
                self.refVec3Point.y,
                relativeAngle,
                relativedistance,
                relativeHeadingInDegrees,
                relativeAltitudeInMeters,
                magneticDeclinationInDegrees)

            --scene:spwanObject(coalitionId, objectKey, countryId, x, y, headinInRadians, altitudeInMeters)
            local ok, success, spawnedObj = pcall(self.spwanObject, self, coalitionId, step.objectsDescDbKey, countryId,
                x, y,
                math.rad(magneticHeadingInDegrees), altitude)
            if not ok then
                --env.info("Runtime error: " .. tostring(success)) -- success = message d’erreur
                local errorMsg = string.format("ctld.scene:runNextStep() ERROR: Failed to spawn step %d. Reason: %s",
                    self.currentStepIndex, step.objectsDescDbKey or "N/A", success)
                trigger.action.outText(errorMsg, 20)
                return nil
            elseif success then
                -- ms("scene:runNextStep().step.objectsDescDbKey.success ok ")
                -- env.info("Object nb spawned: " .. tostring(#spawnedObj))
                -- ms("scene:runNextStep().step.objectsDescDbKey: spawnedObj = " .. mist.utils.tableShow(spawnedObj))
                if step.func then
                    -- Gère les fonctions personnalisées
                    local okFunc, successFunc, spawnedObjFunc = pcall(step.func, self.triggerUnitObj, spawnedObj, step)
                    if not okFunc then
                        --env.info("Runtime error: " .. tostring(successFunc)) -- success = message d’erreur
                        local errorMsg = string.format(
                            "CTLD ERROR: Failed to execute function for step %d. Reason: %s",
                            self.currentStepIndex, successFunc)
                        if trigger and trigger.action and trigger.action.outText then
                            trigger.action.outText(errorMsg, 20)
                        end
                        return false, nil
                    elseif successFunc then
                        --ms("Logic successFunc: " .. tostring(spawnedObjFunc))
                    else
                        --ms("Logic failure: " .. tostring(spawnedObjFunc))
                        return "Logic failure: " .. tostring(spawnedObjFunc)
                    end
                end
            else
                --ms("Logic failure: " .. tostring(spawnedObj))
                return "Logic failure: " .. tostring(spawnedObj)
            end
        end
    elseif step.func then
        -- Gère les fonctions personnalisées
        local ok, success, spawnedObj = pcall(step.func, self.triggerUnitObj, nil, step)
        if not ok then
            --ms("scene:runNextStep().step.func: not ok ")
            --env.info("Runtime error: " .. tostring(success)) -- success = message d’erreur
            local errorMsg = string.format("CTLD ERROR: Failed to execute function for step %d. Reason: %s",
                self.currentStepIndex, success)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(errorMsg, 20)
            end
            return false, nil
        elseif success then
            --ms("Logic successFunc: " .. tostring(spawnedObjFunc))
        else
            --ms("Logic failure: " .. tostring(spawnedObj))
            return "Logic failure: " .. tostring(spawnedObj)
        end
    end

    if self.steps[self.currentStepIndex + 1] then
        local nextStep = self.steps[self.currentStepIndex + 1]
        self.timeProgressMarker = self.timeProgressMarker + (tonumber(step.delayAfterPreviousStep) or 0)
        if self.timeProgressMarker > timer.getTime() then
            -- We use an anonymous function to securely capture 'self' (the instance)
            -- and ensure that the call self:runNextStep() is executed after the required delay.
            local function bound_runNextStep()
                self:runNextStep()
            end
            timer.scheduleFunction(bound_runNextStep, nil, self.timeProgressMarker)
        else
            self:runNextStep()
        end
    else --if self.currentStepIndex + 1 > #self.steps then
        self.isRunning = false
        if env and env.info then env.info(string.format("CTLD.SCENE: Execution of %s finished.", self.name)) end
        return
    end
end

--- @function scene:spawnObject
function scene:spwanObject(coalitionId, objectKey, countryId, x, y, headinInRadians, altitudeInMeters)
    if objectKey and countryId and x and y then
        local groupData = ctld.objectsDescDb[objectKey].desc(coalitionId, countryId, x or 0, y or 0, headinInRadians or 0,
            altitudeInMeters or 0)
        groupData.groupId = ctld.utils.getNextUniqId()
        groupData.name = groupData.name .. '-' .. tostring(groupData.groupId)
        --ms("scene:spwanObject():groupData = " .. mist.utils.tableShow(groupData))

        local success, spawnedObj = ""
        if string.upper(groupData.groupType) == "STATIC" then
            success, spawnedObj = pcall(coalition.addStaticObject, countryId, groupData)
        else -- non-STATIC
            if groupData.units then
                for i, v in ipairs(groupData.units) do
                    groupData.units[i].unitId = ctld.utils.getNextUniqId()
                    groupData.units[i].name = groupData.units[i].name .. '-' .. tostring(groupData.units[i].unitId)
                end
            end
            success, spawnedObj = pcall(coalition.addGroup, countryId, groupData.category, groupData)
        end

        if not success then
            trigger.action.outText(
                "spwanObject()" .. objectKey .. " Deployment: Failed to spawn Object " ..
                groupData.name .. ". Error: " .. tostring(spawnedObj), 15)
            return false, nil
        else
            self:addSpwanedGroup(self.triggerUnitObj, spawnedObj) -- store  spwaned object table
            return true, spawnedObj
        end
    else
        if trigger and trigger.action and trigger.action.outText then
            trigger.action.outText(
                "spwanObject() Deployment: Failed to spawn object. Missing parameters.", 15)
        end
    end
end

--===================================================================================================
if false then
    ---------------------------------------------------
    --- Testing the FARP Deployment scene
    --- ---------------------------------------------------
    if false then
        local heliName = "h1-1"
        local triggerUnitObj = Unit.getByName(heliName)
        ctld.scene.playscene(Unit.getByName(heliName), ctld.scene.sceneModels["FARP Alpha"])
        return ctld.lmsg
    end
    if false then
        local heliName = "h1-1"
        local heliName = "h2-1"
        local triggerUnitObj = Unit.getByName(heliName)
        ctld.scene.playscene(Unit.getByName(heliName), ctld.scene.sceneModels["FARP Alpha"])
        return ctld.lmsg
    else
        ---------------------------------------------------------------------------------
        local ware = {}
        if false then
            local s = StaticObject.getByName("ammo_box_cargo-14")
            ware = Warehouse.getCargoAsWarehouse(s)
        else
            local ab = StaticObject.getByName("SINGLE_HELIPAD-1")
            ware = ab:getWarehouse()
        end


        ware:setItem({ 4, 6, 10, 160 }, 20) --_G["launcher"]["M134_L"] = {CLSID = "M134_L",

        ware:setItem("M134_L", 20)          -- launcher Minigun: name = "M134_L", _unique_resource_name = "weapons.gunmounts.M134_R",
        ware:setItem("M134_7_62_T", 10000)  -- _unique_resource_name = "weapons.shells.M134_7_62_T",name = "M134_7_62_T",

        ware:setItem("launcher.M134_L", 5)
        ware:setItem("gunmounts.M134_L", 20)      -- launcher Minigun: name = "M134_L", _unique_resource_name = "weapons.gunmounts.M134_L",
        ware:setItem("shells.M134_7_62_T", 10000) -- _unique_resource_name = "weapons.shells.M134_7_62_T",name = "M134_7_62_T",


        ware:setItem("weapons.launcher.M134_L", 5)
        ware:setItem("weapons.gunmounts.M134_L", 20)      -- launcher Minigun: name = "M134_L", _unique_resource_name = "weapons.gunmounts.M134_L",
        ware:setItem("weapons.shells.M134_7_62_T", 10000) -- _unique_resource_name = "weapons.shells.M134_7_62_T",name = "M134_7_62_T",

        -- roquettes ----------------------
        ware:setItem("weapons.launcher.XM158_M151", 20) --_G["launcher"]["XM158_M151"] = {CLSID = "XM158_M151",
        ware:setItem("weapons.launcher.XM158_M151", 20) --_G["launcher"]["XM158_M151"] = {CLSID = "XM158_M151",

        ware:setItem("weapons.containers.ab-212_cargo", 20)
        ware:setItem("weapons.adapters.lau-88", 20)
        ------------------------------------------
        ware:setItem("weapons.shells.HYDRA_70_M151", 20) -- Charger 20 pods M151
        ware:setItem("weapons.shells.HYDRA_70_M156", 20) -- Charger 20 pods M156
        ware:setItem("weapons.shells.HYDRA_70_M274", 20)
        ware:setItem("weapons.shells.HYDRA_70_M257", 20)

        return ware:getInventory()
    end
end
