-- ====================================================================================================
-- scene datas for farp deployment:
-- ====================================================================================================
------- Dictionary-------------------------------------------------------------
ctld.i18n["en"]["--- FARP Dynamic Deployment by %1 : Complete! ---"] = ""
ctld.i18n["fr"]["--- FARP Dynamic Deployment by %1 : Complete! ---"] = "--- Deploiement du FARP par %1 : Terminé! ---"
ctld.i18n["es"]["--- FARP Dynamic Deployment by %1 : Complete! ---"] =
"--- Implementación de FARP por %1: ¡Completada! ---"
-------------------------------------------------------------------------------
local farpScene = {}
farpScene.name = "FARP Alpha"
farpScene.stepsDatas = {
    -- Étape 1: FARP Principal (STATIC)
    {
        polar = { distance = 100, angle = 0 },
        delayAfterPreviousStep = 0,
        relativeHeadingInDegrees = 180,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "SINGLE_HELIPAD", -- key for ctld.objectsDescDb table
        -- local script to run after spawning this step
        -- @params: triggerUnitObj - the unit that triggered the sceneTable
        --          spwanedObject - the object that was just spawned in this step ( here the FARP helipad)
        --          stepDatas - the datas of this step
        func = function(triggerUnitObj, spwanedObject, stepDatas) -- spwanedObject is the object that was just spawned in this step ( here the FARP helipad)
            local farpName = spwanedObject:getName()
            if Airbase.getByName(farpName) then
                local w = Airbase.getByName(farpName):getWarehouse()
                --Warehouse.addLiquid(class self , number liquidType , number count )
                w:addLiquid(0, 10000) --0    : jetfuel
                w:addLiquid(1, 10000) --1    : Aviation gasoline
                w:addLiquid(2, 10000) --2    : MW50
                w:addLiquid(3, 10000) --3    : Diesel

                -- warehouse addAmmo ( number ammoType , number count )
                --Warehouse.setItem(class self , string/table itemName/wsType , number count )
                --[[
                local w = Airbase.getByName("SINGLE_HELIPAD-1"):getWarehouse()
                --for k,v in pairs(ctld.WeaponsDb) do
                    --Warehouse.setItem(class self , string/table itemName/wsType , number count )
                    --w:setItem("250-2 - 250kg GP Bombs HD", 500)
                    --w:setItem({ 4, 5, 9, "Redacted" }, 500)
                    --w:setItem({4, 4, 8,"Redacted",}, 500)
                    --w:setItem("weapons.missiles.AIM_54C_Mk47", 500)
                    --w:setItem("weapons.bombs.Type_200A", 500)

                w:setItem("weapons.launcher.M134_R", 00)   			-- miniGun UH   KO
                    --w:setItem("M134_R", 500)   							-- miniGun UH   KO
                    --w:setItem("M134 - 6 x 7.62mm MiniGun right", 500)   	-- miniGun UH   KO
                    --w:setItem({4, 15, 46,"Redacted"}, 500)   				-- miniGun UH   KO
                    --w:setItem("AB-212_m134_r", 500)   				-- miniGun UH   KO
                    --w:setItem({4, 6, 10 }, 500)   				-- miniGun UH   KO
                    --w:setItem("weapons.launcher.{SHOULDER AIM_54C_Mk47 L}", 500)     --KO
                    --w:setItem("SHOULDER AIM_54C_Mk47 L}", 500)     --KO
                    --w:setItem("weapons.shells.M134_7_62_T", 500)    --KO shells._unique_resource_name
                    --w:setItem("M134_SIDE_R", 500)    -- KO
                    --w:setItem("weapons.gunmounts.M134_SIDE_R", 500)   -- KO
                    --w:setItem("M134 Minigun", 500)   --mounts.display_name  KO
                --w:setItem(175, 500)   --mounts.display_name  KO
                --end ]] --
            end
            return true
        end
    },
    -- Étape 2: Tente de Commandement (STATIC)
    {
        polar = { distance = 130, angle = 5 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 90,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "FARP_Tent" -- key for ctld.objectsDescDb table
    },
    -- Étape 3: Stock de Munitions (STATIC)
    {
        polar = { distance = 110, angle = 340 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "FARP_Ammo_Storage" -- key for ctld.objectsDescDb table
    },
    -- Étape 4a: Camion Citerne de Ravitaillement (GROUP)
    {
        polar                    = { distance = 110, angle = 15, altitude = 0 },
        delayAfterPreviousStep   = 5,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey         = "Fuel_Truck" -- key for ctld.objectsDescDb table
    },
    -- Étape 4b: Camion armement + reparation (GROUP)
    {
        polar                    = { distance = 125, angle = 15, altitude = 0 },
        delayAfterPreviousStep   = 5,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey         = "repare_Truck" -- key for ctld.objectsDescDb table
    },
    -- Étape 5: Groupe de Sécurité (GROUP)
    {
        polar                    = { distance = 90, angle = 15, altitude = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey         = "FARP_Security_Guard" -- key for ctld.objectsDescDb table
    },
    -- Étape 6abarrels (STATIC)
    {
        polar = { distance = 100, angle = 350 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "barrels_cargo" -- key for ctld.objectsDescDb table
    },
    -- Étape 6b1:Cargo06 (STATIC)
    {
        polar = { distance = 95, angle = 349 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "Cargo06" -- key for ctld.objectsDescDb table
    },
    -- Étape 6b2:ammo_cargo (STATIC)
    {
        polar = { distance = 105, angle = 351.2 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "ammo_cargo" -- key for ctld.objectsDescDb table
    },
    -- Étape 6c:ammo_cargo2 (STATIC)
    {
        polar = { distance = 106.5, angle = 351.3 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 5,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "ammo_cargo" -- key for ctld.objectsDescDb table
    },
    -- Étape 6d:carrier_shooter
    {
        polar = { distance = 115, angle = 5 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 220,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "us carrier shooter" -- key for ctld.objectsDescDb table
    },
    -- Étape 6e:LightOn
    {
        polar = { distance = 116.7, angle = 353 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 220,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "NF-2_LightOn" -- key for ctld.objectsDescDb table
    },
    -- Étape 6e:Windsock
    {
        polar = { distance = 80, angle = 10 },
        delayAfterPreviousStep = 3,
        relativeHeadingInDegrees = 220,
        relativeAltitudeInMeters = 0,
        objectsDescDbKey = "Windsock" -- key for ctld.objectsDescDb table
    },
    -- Étape 7: Fin de la scène (FUNCTION)
    {
        delayAfterPreviousStep = 0,
        polar = { distance = 0, angle = 0, altitude = 0 },
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        -- @params: triggerUnitObj - the unit that triggered the sceneTable
        --          spwanedObject - the object that was just spawned in this step (here nil)
        --          stepDatas - the datas of this step
        func = function(triggerUnitObj, spwanedObject, stepDatas)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    ctld.i18n_translate("--- FARP Dynamic Deployment by %1 : Complete! ---", triggerUnitObj:getName()),
                    10)
            end
            return nil
        end
    }
}

ctld.farpScene = farpScene
ctld.scene.registerSceneModel(ctld.farpScene) -- Register the scene model in the Scene class
-- ====================================================================================================
