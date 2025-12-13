-- ====================================================================================================
-- scene datas for mineField deployment: mineFieldSceneDatas.lua
-- ====================================================================================================
------- Dictionary-------------------------------------------------------------
ctld.i18n["en"]["--- mineField Deployed by %1 ---"] = ""
ctld.i18n["en"]["ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"] = ""

-----------------------------------------------------------------
local mineFieldScene = {}
mineFieldScene.name = "mineField"
mineFieldScene.stepsDatas = {
    -- step 1: mineField (FUNCTION)
    {
        delayAfterPreviousStep = 0,
        polar = { distance = 0, angle = 0, altitude = 0 },
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        func = function(triggerUnitObj, stepdatas)
            if trigger and trigger.action and trigger.action.outText then
                local success, spwanedObjs = mineFieldScene.setLandMine(triggerUnitObj, 20, 5, 15, 6, 12)
                --local success, spwanedObjs = mineFieldScene.setLandMine(triggerUnitObj, 20, 1, 1, 6, 12)        -- only 1 mine for test
                trigger.action.outText(
                    ctld.i18n_translate("--- mineField Deployed by %1 ---", triggerUnitObj:getName()),
                    10)
                return success, spwanedObjs
            end
        end
    }
}
----------------------------------------------------------------------------------------------------------

function mineFieldScene.setLandMine(triggerUnitObj, distanceOf1stMineFromHeliInMeter, nbMinesColumns, nbMinesPerColumns,
                                    distanceBetweenColumnsInMeters, distanceBetweenLinesInMeters)
    if triggerUnitObj then
        local triggerUnitPosition = triggerUnitObj:getPosition()
        local triggerUnitHeadingInRadians = ctld.utils.getHeadingInRadians(triggerUnitObj, true)
        local MinesCoord = {}
        local nbMines = nbMinesColumns * nbMinesPerColumns
        local spwanedObjs = {}

        if nbMines > 0 then
            local vec3Points1To4 = {} -- points for draw
            if nbMines == 1 then      --------- 1 Landmine coordinates
                local newVec2Point = ctld.utils.GetRelativeVec2Coords(
                    { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z }, triggerUnitHeadingInRadians,
                    distanceOf1stMineFromHeliInMeter, 0)
                MinesCoord[1] = {}
                MinesCoord[1][1] = {
                    ["x"] = newVec2Point.x,
                    ["y"] = newVec2Point.y
                }
                -- points for draw
                local ofs = 3
                vec3Points1To4[1] = { x = MinesCoord[1][1].x - ofs, y = 0, z = MinesCoord[1][1].y }
                vec3Points1To4[2] = { x = MinesCoord[1][1].x, y = 0, z = MinesCoord[1][1].y + ofs }
                vec3Points1To4[3] = { x = MinesCoord[1][1].x + ofs, y = 0, z = MinesCoord[1][1].y }
                vec3Points1To4[4] = { x = MinesCoord[1][1].x, y = 0, z = MinesCoord[1][1].y - ofs }
            else                                                                  ------------------------- create minefield coordinates
                local memoR                  = distanceOf1stMineFromHeliInMeter
                lineOffsetInMeters           = lineOffsetInMeters or 6            --	en metres
                distanceBetweenLinesInMeters = distanceBetweenLinesInMeters or 12 --	en metres

                -- get 1st point coord of each column
                local Vec2CentralPoint       = ctld.utils.GetRelativeVec2Coords(
                    { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z }, triggerUnitHeadingInRadians,
                    distanceOf1stMineFromHeliInMeter, 0)

                if nbMinesColumns % 2 == 0 then --nbMinesColumns is even
                    for i = 1, nbMinesColumns do
                        MinesCoord[i] = {}
                        if i == 1 then
                            MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(Vec2CentralPoint,
                                triggerUnitHeadingInRadians,
                                (((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters) +
                                (distanceBetweenColumnsInMeters / 2), 90)
                        else
                            MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(MinesCoord[i - 1][1],
                                triggerUnitHeadingInRadians, distanceBetweenColumnsInMeters, -90)
                        end

                        for line = 2, nbMinesPerColumns do
                            MinesCoord[i][line] = ctld.utils.GetRelativeVec2Coords(MinesCoord[i][line - 1],
                                triggerUnitHeadingInRadians, distanceBetweenLinesInMeters, 0)
                        end
                    end
                else --nbMinesColumns is odd
                    for i = 1, nbMinesColumns do
                        MinesCoord[i] = {}
                        if i == 1 then
                            MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(Vec2CentralPoint,
                                triggerUnitHeadingInRadians,
                                (((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters), 90)
                        else
                            MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(MinesCoord[i - 1][1],
                                triggerUnitHeadingInRadians, distanceBetweenColumnsInMeters, -90)
                        end

                        for line = 2, nbMinesPerColumns do
                            MinesCoord[i][line] = ctld.utils.GetRelativeVec2Coords(MinesCoord[i][line - 1],
                                triggerUnitHeadingInRadians, distanceBetweenLinesInMeters, 0)
                        end
                    end
                end

                if nbMinesColumns < 2 then
                    vec3Points1To4[1] = { x = MinesCoord[1][1].x - 3, z = MinesCoord[1][1].y - 3, y = 0 }
                    vec3Points1To4[2] = { x = MinesCoord[1][1].x + 3, z = MinesCoord[1][1].y + 3, y = 0 }
                    vec3Points1To4[4] = {
                        x = MinesCoord[#MinesCoord][#MinesCoord[1]].x - 3,
                        z = MinesCoord[#MinesCoord]
                            [#MinesCoord[1]].y - 3,
                        y = 0
                    }
                    vec3Points1To4[3] = {
                        x = MinesCoord[#MinesCoord][#MinesCoord[1]].x + 3,
                        z = MinesCoord[#MinesCoord]
                            [#MinesCoord[1]].y + 3,
                        y = 0
                    }
                else
                    vec3Points1To4[1] = { x = MinesCoord[1][1].x, z = MinesCoord[1][1].y, y = 0 }
                    vec3Points1To4[2] = { x = MinesCoord[#MinesCoord][1].x, z = MinesCoord[#MinesCoord][1].y, y = 0 }
                    vec3Points1To4[3] = {
                        x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,
                        z = MinesCoord[#MinesCoord]
                            [#MinesCoord[1]].y,
                        y = 0
                    }
                    vec3Points1To4[4] = { x = MinesCoord[1][#MinesCoord[1]].x, z = MinesCoord[1][#MinesCoord[1]].y, y = 0 }
                end
                if nbMinesPerColumns < 2 then
                    vec3Points1To4[1] = { x = MinesCoord[1][1].x, z = MinesCoord[1][1].y - 3, y = 0 }
                    vec3Points1To4[2] = { x = MinesCoord[1][1].x, z = MinesCoord[1][1].y + 3, y = 0 }
                    vec3Points1To4[3] = {
                        x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,
                        z = MinesCoord[#MinesCoord]
                            [#MinesCoord[1]].y + 3,
                        y = 0
                    }
                    vec3Points1To4[4] = {
                        x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,
                        z = MinesCoord[#MinesCoord]
                            [#MinesCoord[1]].y - 3,
                        y = 0
                    }
                end
            end

            -------- spwan mines -------------------------------------------------
            for j = 1, #MinesCoord do
                for i = 1, #MinesCoord[j] do
                    local vars = {
                        country  = triggerUnitObj:getCountry(),
                        category = 'Fortifications',
                        x        = MinesCoord[j][i].x,
                        y        = MinesCoord[j][i].y,
                        type     = "Landmine",
                        name     = "Landmine-" .. ctld.utils.getNextUniqId(),
                        dead     = false,
                        heading  = 0
                    }
                    _spawnedGroup = mist.dynAddStatic(vars)
                    spwanedObjs[#spwanedObjs + 1] = _spawnedGroup
                end
            end

            -------- draw rectangle around minefield on F10 map -----------------------------
            ctld.utils.drawQuad(coalitionId, vec3Points1To4, spwanedObjs[#spwanedObjs].name)
            return true, spwanedObjs
        end
    end
    return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0" -- fail
end

ctld.mineFieldScene = mineFieldScene
ctld.scene.registerSceneModel(ctld.mineFieldScene) -- Register the scene model in the Scene class
-- ====================================================================================================

--[[ ---- TEST -----------------------------------------------------
--ex: setLandMine(triggerUnitObj, distanceOf1stMineFromHeli, nbMinesColumns, nbMinesPerColumns, lineOffsetInMeters, distanceBetweenLinesInMeters )

if true then
    local heliName = "h1-1"
    local triggerUnitObj = Unit.getByName(heliName)
    --ctld.scene.playScene(Unit.getByName(heliName), ctld.farpScene)
    ctld.scene.playScene(Unit.getByName(heliName), ctld.mineFieldScene)
    return ctld.lmsg
end
----------------------------------------------------------------- ]] --
