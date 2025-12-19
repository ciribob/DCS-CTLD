-------------------------------------------------------------------------------
------------ JTAC -----------

ctld.jtacMenuName = "JTAC" --name of the CTLD JTAC radio menu
ctld.jtacLaserPoints = {}
ctld.jtacIRPoints = {}
ctld.jtacSmokeMarks = {}
ctld.jtacUnits = {}          -- list of JTAC units for f10 command
ctld.jtacStop = {}           -- jtacs to tell to stop lasing
ctld.jtacCurrentTargets = {}
ctld.jtacTargetsList = {}    --current available targets to each JTAC for lasing (targets from other JTACs are filtered out). Contains DCS unit objects with their methods and the distance to the JTAC {unit, dist}
ctld.jtacSelectedTarget = {} --currently user selected target if it contains a unit's name, otherwise contains 1 or nil (if not initialized)
ctld.jtacSpecialOptions = {  --list which contains the status of special options for each jtac, ordered for them to show up in the correct order in the corresponding radio menu
    standbyMode = {          --#1
        globalToggle = ctld.JTAC_allowStandbyMode,
        message = "Standby Mode",
        setter = nil, --ctld.setStdbMode, will be set after declaration of said function
        jtacs = {
            --enable flag for each JTAC
        },
    },              --disable designation by the JTAC
    smokeMarker = { --#4
        globalToggle = ctld.JTAC_allowSmokeRequest,
        message = "Smoke on TGT",
        setter = nil,       --ctld.setSmokeOnTarget
    },                      --smoke marker on target
    laseSpotCorrections = { --#2
        globalToggle = ctld.JTAC_laseSpotCorrections,
        message = "Speed Corrections",
        setter = nil, --ctld.setLaseCompensation
        jtacs = {
            --enable flag for each JTAC
        },
    },         --target speed and wind compensation for laser spot
    _9Line = { --#3
        globalToggle = ctld.JTAC_allow9Line,
        message = "9 Line",
        setter = nil,             --ctld.setJTAC9Line
    },                            --9Line message for JTAC
}
ctld.jtacRadioAdded = {}          --keeps track of who's had the radio command added
ctld.jtacGroupSubMenuPath = {}    --keeps track of which submenu contains each JTAC's target selection menu
ctld.jtacRadioRefreshDelay = 120  --determines how often in seconds the dynamic parts of the jtac radio menu (target lists) will be refreshed
ctld.jtacLastRadioRefresh = 0     -- time at which the target lists were refreshed for everyone at least
ctld.refreshJTACmenu = {}         --indicator to know when a new JTAC is added to a coalition in order to rebuild the corresponding target lists
ctld.jtacGeneratedLaserCodes = {} -- keeps track of generated codes, cycles when they run out
ctld.jtacLaserPointCodes = {}
ctld.jtacRadioData = {}

--[[
        Called when a new JTAC is spawned, it will wait one second for DCS to have time to fill the group with units, and then call ctld.JTACAutoLase.

        The goal here is to correct a bug: when a group is respawned (i.e. when any group with the name of a previously existing group is spawned),
        DCS spawns a group which exists (Group.getByName gets a valid table, and group:isExist returns true), but has no units (i.e. group:getUnits returns an empty table).
        This causes JTACAutoLase to call cleanupJTAC because it does not find the JTAC unit, and the JTAC to be put out of the JTACAutoLase loop, and never processed again.
        By waiting a bit, the group gets populated before JTACAutoLase is called, hence avoiding a trip to cleanupJTAC.
]]
function ctld.JTACStart(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    timer.scheduleFunction(ctld.JTACAutoLase,
        { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
        timer.getTime() + 1)
end

function ctld.JTACAutoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    --ctld.logDebug(string.format("ctld.JTACAutoLase(_jtacGroupName=%s, _laserCode=%s", ctld.p(_jtacGroupName), ctld.p(_laserCode)))
    local _radio = _radio
    if not _radio then
        _radio = {}
        if _laserCode then
            local _laserCode = tonumber(_laserCode)
            if _laserCode and _laserCode >= 1111 and _laserCode <= 1688 then
                local _laserB = math.floor((_laserCode - 1000) / 100)
                local _laserCD = _laserCode - 1000 - _laserB * 100
                local _frequency = tostring(30 + _laserB + _laserCD * 0.05)
                --ctld.logTrace(string.format("_laserB=%s", ctld.p(_laserB)))
                --ctld.logTrace(string.format("_laserCD=%s", ctld.p(_laserCD)))
                --ctld.logTrace(string.format("_frequency=%s", ctld.p(_frequency)))
                _radio.freq = _frequency
                _radio.mod = "fm"
            end
        end
    end

    if _radio and not _radio.name then
        _radio.name = _jtacGroupName
    end

    if ctld.jtacStop[_jtacGroupName] == true then
        ctld.jtacStop[_jtacGroupName] = nil -- allow it to be started again
        ctld.cleanupJTAC(_jtacGroupName)
        return
    end

    if _lock == nil then
        _lock = ctld.JTAC_lock
    end

    ctld.jtacLaserPointCodes[_jtacGroupName] = _laserCode
    ctld.jtacRadioData[_jtacGroupName] = _radio

    local _jtacGroup = ctld.getGroup(_jtacGroupName)
    local _jtacUnit

    if _jtacGroup == nil or #_jtacGroup == 0 then
        --check not in a heli
        if ctld.inTransitTroops then
            for _, _onboard in pairs(ctld.inTransitTroops) do
                if _onboard ~= nil then
                    if _onboard.troops ~= nil and _onboard.troops.groupName ~= nil and _onboard.troops.groupName == _jtacGroupName then
                        --jtac soldier being transported by heli
                        ctld.cleanupJTAC(_jtacGroupName)

                        ctld.logTrace(string.format(
                            "JTAC - LASE - [%s] - in transport, waiting - scheduling JTACAutoLase in %ss at %s",
                            ctld.p(_jtacGroupName), ctld.p(10), ctld.p(timer.getTime() + 10)))
                        timer.scheduleFunction(ctld.timerJTACAutoLase,
                            { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio }, timer.getTime() + 10)
                        return
                    end

                    if _onboard.vehicles ~= nil and _onboard.vehicles.groupName ~= nil and _onboard.vehicles.groupName == _jtacGroupName then
                        --jtac vehicle being transported by heli
                        ctld.cleanupJTAC(_jtacGroupName)

                        ctld.logTrace(string.format(
                            "JTAC - LASE - [%s] - in transport, waiting - scheduling JTACAutoLase in %ss at %s",
                            ctld.p(_jtacGroupName), ctld.p(10), ctld.p(timer.getTime() + 10)))
                        timer.scheduleFunction(ctld.timerJTACAutoLase,
                            { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio }, timer.getTime() + 10)
                        return
                    end
                end
            end
        end

        if ctld.jtacUnits[_jtacGroupName] ~= nil then
            ctld.notifyCoalition(ctld.i18n_translate("JTAC Group %1 KIA!", _jtacGroupName), 10,
                ctld.jtacUnits[_jtacGroupName].side, _radio)
        end

        --remove from list
        ctld.cleanupJTAC(_jtacGroupName)

        return
    else
        _jtacUnit = _jtacGroup[1]
        local _jtacCoalition = _jtacUnit:getCoalition()
        --add to list
        ctld.jtacUnits[_jtacGroupName] = { name = _jtacUnit:getName(), side = _jtacCoalition, radio = _radio }

        --Targets list, special options and Selected target initialization
        if not ctld.jtacTargetsList[_jtacGroupName] then
            --Target list
            ctld.jtacTargetsList[_jtacGroupName] = {}
            if _jtacCoalition then ctld.refreshJTACmenu[_jtacCoalition] = true end

            --Special Options
            for _, _specialOption in pairs(ctld.jtacSpecialOptions) do
                if _specialOption.jtacs then
                    _specialOption.jtacs[_jtacGroupName] = false
                end
            end
        end

        if not ctld.jtacSelectedTarget[_jtacGroupName] then
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
        end

        -- work out smoke colour
        if _colour == nil then
            if _jtacUnit:getCoalition() == 1 then
                _colour = ctld.JTAC_smokeColour_RED
            else
                _colour = ctld.JTAC_smokeColour_BLUE
            end
        end


        if _smoke == nil then
            if _jtacUnit:getCoalition() == 1 then
                _smoke = ctld.JTAC_smokeOn_RED
            else
                _smoke = ctld.JTAC_smokeOn_BLUE
            end
        end
    end


    -- search for current unit

    if _jtacUnit:isActive() == false then
        ctld.cleanupJTAC(_jtacGroupName)

        ctld.logTrace(string.format("JTAC - LASE - [%s] - not active, scheduling JTACAutoLase in 30s at %s",
            ctld.p(_jtacGroupName), ctld.p(timer.getTime() + 30)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + 30)

        return
    end

    local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)
    --update targets list and store the next potential target if the selected one was lost
    local _defaultEnemyUnit = ctld.findNearestVisibleEnemy(_jtacUnit, _lock)

    -- if the JTAC sees a unit and a target was selected by users but is not the current unit, check if the selected target is in the targets list, if it is, then it's been reacquired
    if _enemyUnit and ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 and ctld.jtacSelectedTarget[_jtacGroupName] ~= _enemyUnit:getName() then
        for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
            if target then
                local targetUnit = target.unit
                local targetName = targetUnit:getName()

                if ctld.jtacSelectedTarget[_jtacGroupName] == targetName then
                    ctld.jtacCurrentTargets[_jtacGroupName] = {
                        name = targetName,
                        unitType = targetUnit:getTypeName(),
                        unitId =
                            targetUnit:getID()
                    }
                    _enemyUnit = targetUnit

                    local message = ctld.i18n_translate("%1, selected target reacquired, %2", _jtacGroupName,
                        _enemyUnit:getTypeName())
                    local fullMessage = message ..
                        ctld.i18n_translate(". CODE: %1. POSITION: %2", _laserCode, ctld.getPositionString(_enemyUnit))
                    ctld.notifyCoalition(fullMessage, 10, _jtacUnit:getCoalition(), _radio, message)
                end
            end
        end
    end

    local targetDestroyed = false
    local targetLost = false
    local wasSelected = false

    if _enemyUnit == nil and ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then
        local _tempUnitInfo = ctld.jtacCurrentTargets[_jtacGroupName]

        --            env.info("TEMP UNIT INFO: " .. tempUnitInfo.name .. " " .. tempUnitInfo.unitType)

        local _tempUnit = Unit.getByName(_tempUnitInfo.name)

        wasSelected = (ctld.jtacCurrentTargets[_jtacGroupName].name == ctld.jtacSelectedTarget[_jtacGroupName])

        if _tempUnit ~= nil and _tempUnit:getLife() > 0 and _tempUnit:isActive() == true then
            targetLost = true
        else
            targetDestroyed = true
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
        end

        --remove from smoke list
        ctld.jtacSmokeMarks[_tempUnitInfo.name] = nil

        -- JTAC Unit: resume his route ------------
        trigger.action.groupContinueMoving(Group.getByName(_jtacGroupName))

        -- remove from target list
        ctld.jtacCurrentTargets[_jtacGroupName] = nil

        --stop lasing
        ctld.cancelLase(_jtacGroupName)
    end


    if _enemyUnit == nil then
        if _defaultEnemyUnit ~= nil then
            -- store current target for easy lookup
            ctld.jtacCurrentTargets[_jtacGroupName] = {
                name = _defaultEnemyUnit:getName(),
                unitType = _defaultEnemyUnit
                    :getTypeName(),
                unitId = _defaultEnemyUnit:getID()
            }

            --add check for lasing or not
            local action = ctld.i18n_translate("new target, ")

            if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                action = ctld.i18n_translate("standing by on %1", action)
            else
                action = ctld.i18n_translate("lasing %1", action)
            end

            if wasSelected and targetLost then
                action = ctld.i18n_translate(", temporarily %1", action)
            else
                action = ", " .. action
            end

            if targetLost then
                action = ctld.i18n_translate("target lost") .. action
            elseif targetDestroyed then
                action = ctld.i18n_translate("target destroyed") .. action
            end

            if wasSelected then
                action = ctld.i18n_translate(", selected %1", action)
            elseif targetLost or targetDestroyed then
                action = ", " .. action
            end
            wasSelected = false
            targetDestroyed = false
            targetLost = false

            local message = _jtacGroupName .. action .. _defaultEnemyUnit:getTypeName()
            local fullMessage = message ..
                '. CODE: ' .. _laserCode .. ". POSITION: " .. ctld.getPositionString(_defaultEnemyUnit)
            ctld.notifyCoalition(fullMessage, 10, _jtacUnit:getCoalition(), _radio, message)

            -- JTAC Unit stop his route -----------------
            trigger.action.groupStopMoving(Group.getByName(_jtacGroupName)) -- stop JTAC

            -- create smoke
            if _smoke == true then
                --create first smoke
                ctld.createSmokeMarker(_defaultEnemyUnit, _colour)
            end
        end
    end

    if _enemyUnit ~= nil and not ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
        local refreshDelay = 15 --delay in between JTACAutoLase scheduled calls when a target is tracked
        local targetSpeedVec = _enemyUnit:getVelocity()
        local targetSpeed = math.sqrt(targetSpeedVec.x ^ 2 + targetSpeedVec.y ^ 2 + targetSpeedVec.z ^ 2)
        local maxUpdateDist = 5 --maximum distance the unit will be allowed to travel before the lase spot is updated again
        --ctld.logTrace(string.format("targetSpeed=%s", ctld.p(targetSpeed)))

        ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

        --if the target is going sufficiently fast for it to wander off futher than the maxUpdateDist, schedule laseUnit calls to update the lase spot only (we consider that the unit lives and drives on between JTACAutoLase calls)
        if targetSpeed >= maxUpdateDist / refreshDelay then
            local updateTimeStep = maxUpdateDist /
                targetSpeed --calculate the time step so that the target is never more than maxUpdateDist from it's last lased position
            --ctld.logTrace(string.format("JTAC - LASE - [%s] - target is moving at %s m/s, schedulting lasing steps every %ss", ctld.p(_jtacGroupName), ctld.p(targetSpeed), ctld.p(updateTimeStep)))

            local i = 1
            while i * updateTimeStep <= refreshDelay - updateTimeStep do --while the scheduled time for the laseUnit call isn't greater than the time between two JTACAutoLase() calls minus one time step (because at the next time step JTACAutoLase() should have been called and this in term also calls laseUnit())
                timer.scheduleFunction(ctld.timerLaseUnit, { _enemyUnit, _jtacUnit, _jtacGroupName, _laserCode },
                    timer.getTime() + i * updateTimeStep)
                i = i + 1
            end
            --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduled %s moving target lasing steps", ctld.p(_jtacGroupName), ctld.p(i)))
        end

        --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduling JTACAutoLase in %ss at %s", ctld.p(_jtacGroupName), ctld.p(refreshDelay), ctld.p(timer.getTime() + refreshDelay)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + refreshDelay)

        if _smoke == true then
            local _nextSmokeTime = ctld.jtacSmokeMarks[_enemyUnit:getName()]

            --recreate smoke marker after 5 mins
            if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then
                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end
    else
        --ctld.logDebug(string.format("JTAC - MODE - [%s] - No Enemies Nearby / Standby mode", ctld.p(_jtacGroupName)))

        -- stop lazing the old spot
        --ctld.logDebug(string.format("JTAC - LASE - [%s] - canceling lasing of the old spot", ctld.p(_jtacGroupName)))
        ctld.cancelLase(_jtacGroupName)

        --ctld.logTrace(string.format("JTAC - LASE - [%s] - scheduling JTACAutoLase in %ss at %s", ctld.p(_jtacGroupName), ctld.p(5), ctld.p(timer.getTime() + 5)))
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio },
            timer.getTime() + 5)
    end

    local action = ", "
    if wasSelected then
        action = action .. "selected "
    end

    if targetLost then
        ctld.notifyCoalition(ctld.i18n_translate("%1 %2 target lost.", _jtacGroupName, action), 10,
            _jtacUnit:getCoalition(), _radio)
    elseif targetDestroyed then
        ctld.notifyCoalition(ctld.i18n_translate("%1 %2 target destroyed.", _jtacGroupName, action), 10,
            _jtacUnit:getCoalition(), _radio)
    end
end

function ctld.JTACAutoLaseStop(_jtacGroupName)
    ctld.jtacStop[_jtacGroupName] = true
end

-- used by the timer function
function ctld.timerJTACAutoLase(_args)
    ctld.JTACAutoLase(_args[1], _args[2], _args[3], _args[4], _args[5], _args[6])
end

function ctld.cleanupJTAC(_jtacGroupName)
    -- clear laser - just in case
    ctld.cancelLase(_jtacGroupName)

    -- Cleanup
    ctld.jtacCurrentTargets[_jtacGroupName] = nil

    ctld.jtacTargetsList[_jtacGroupName] = nil

    ctld.jtacSelectedTarget[_jtacGroupName] = nil

    for _, _specialOption in pairs(ctld.jtacSpecialOptions) do --delete jtac specific settings for all special options
        if _specialOption.jtacs then
            _specialOption.jtacs[_jtacGroupName] = nil
        end
    end

    ctld.jtacRadioData[_jtacGroupName] = nil

    --remove the JTAC's group submenu and all of the target pages it potentially contained if the JTAC has or had a menu
    if ctld.jtacUnits[_jtacGroupName] and ctld.jtacUnits[_jtacGroupName].side and ctld.jtacGroupSubMenuPath[_jtacGroupName] then
        local _players = coalition.getPlayers(ctld.jtacUnits[_jtacGroupName].side)

        if _players ~= nil then
            for _, _playerUnit in pairs(_players) do
                local _groupId = ctld.utils.getGroupId("ctld.cleanupJTAC()", _playerUnit)

                if _groupId then
                    missionCommands.removeItemForGroup(_groupId, ctld.jtacGroupSubMenuPath[_jtacGroupName])
                end
            end
        end
    end

    ctld.jtacUnits[_jtacGroupName] = nil

    ctld.jtacGroupSubMenuPath[_jtacGroupName] = nil
end

--- send a message to the coalition
--- if _radio is set, the message will be read out loud via SRS
function ctld.notifyCoalition(_message, _displayFor, _side, _radio, _shortMessage)
    trigger.action.outTextForCoalition(_side, _message, _displayFor)

    local _shortMessage = _shortMessage
    if _shortMessage == nil then
        _shortMessage = _message
    end

    if STTS and STTS.TextToSpeech and _radio and _radio.freq then
        local _freq = _radio.freq
        local _modulation = _radio.mod or "FM"
        local _volume = _radio.volume or "1.0"
        local _name = _radio.name or "JTAC"
        local _gender = _radio.gender or "male"
        local _culture = _radio.culture or "en-US"
        local _voice = _radio.voice
        local _googleTTS = _radio.googleTTS or false
        STTS.TextToSpeech(_shortMessage, _freq, _modulation, _volume, _name, _side, nil, 1, _gender, _culture, _voice,
            _googleTTS)
    else
        trigger.action.outSoundForCoalition(_side, "radiobeep.ogg")
    end
end

function ctld.createSmokeMarker(_enemyUnit, _colour)
    --recreate in 5 mins
    ctld.jtacSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0

    local _enemyPoint = _enemyUnit:getPoint()
    trigger.action.smoke(
        {
            x = _enemyPoint.x + math.random(-ctld.JTAC_smokeMarginOfError, ctld.JTAC_smokeMarginOfError) +
                ctld.JTAC_smokeOffset_x,
            y = _enemyPoint.y + ctld.JTAC_smokeOffset_y,
            z = _enemyPoint.z +
                math.random(-ctld.JTAC_smokeMarginOfError, ctld.JTAC_smokeMarginOfError) + ctld.JTAC_smokeOffset_z
        }, _colour)
end

function ctld.cancelLase(_jtacGroupName)
    --local index = "JTAC_"..jtacUnit:getID()

    local _tempLase = ctld.jtacLaserPoints[_jtacGroupName]

    if _tempLase ~= nil then
        Spot.destroy(_tempLase)
        ctld.jtacLaserPoints[_jtacGroupName] = nil

        --            env.info('Destroy laze    '..index)

        _tempLase = nil
    end

    local _tempIR = ctld.jtacIRPoints[_jtacGroupName]

    if _tempIR ~= nil then
        Spot.destroy(_tempIR)
        ctld.jtacIRPoints[_jtacGroupName] = nil

        --    env.info('Destroy laze    '..index)

        _tempIR = nil
    end
end

-- used by the timer function
function ctld.timerLaseUnit(_args)
    ctld.laseUnit(_args[1], _args[2], _args[3], _args[4])
end

function ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)
    --cancelLase(jtacGroupName)
    --ctld.logTrace("ctld.laseUnit()")

    local _spots = {}

    if _enemyUnit:isExist() then
        local _enemyVector = _enemyUnit:getPoint()
        local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

        if ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] then
            local _enemySpeedVector = _enemyUnit:getVelocity()
            ctld.logTrace(string.format("_enemySpeedVector=%s", ctld.p(_enemySpeedVector)))

            local _WindSpeedVector = atmosphere.getWind(_enemyVectorUpdated)
            ctld.logTrace(string.format("_WindSpeedVector=%s", ctld.p(_WindSpeedVector)))

            --if target speed is greater than 0, calculated using absolute value norm
            if math.abs(_enemySpeedVector.x) + math.abs(_enemySpeedVector.y) + math.abs(_enemySpeedVector.z) > 0 then
                local CorrectionFactor = 1 --correction factor in seconds applied to the target speed components to determine the lasing spot for a direct hit on a moving vehicle

                --correct in the direction of the movement
                _enemyVectorUpdated.x = _enemyVectorUpdated.x + _enemySpeedVector.x * CorrectionFactor
                _enemyVectorUpdated.y = _enemyVectorUpdated.y + _enemySpeedVector.y * CorrectionFactor
                _enemyVectorUpdated.z = _enemyVectorUpdated.z + _enemySpeedVector.z * CorrectionFactor
            end

            --if wind speed is greater than 0, calculated using absolute value norm
            if math.abs(_WindSpeedVector.x) + math.abs(_WindSpeedVector.y) + math.abs(_WindSpeedVector.z) > 0 then
                local CorrectionFactor = 1.05 --correction factor in seconds applied to the wind speed components to determine the lasing spot for a direct hit in adverse conditions

                --correct to the opposite of the wind direction
                _enemyVectorUpdated.x = _enemyVectorUpdated.x - _WindSpeedVector.x * CorrectionFactor
                _enemyVectorUpdated.y = _enemyVectorUpdated.y -
                    _WindSpeedVector.y *
                    CorrectionFactor --not sure about correcting altitude but that component is always 0 in testing
                _enemyVectorUpdated.z = _enemyVectorUpdated.z - _WindSpeedVector.z * CorrectionFactor
            end
            --combination of both should result in near perfect accuracy if the bomb doesn't stall itself following fast vehicles or correcting for heavy winds, correction factors can be adjusted but should work up to 40kn of wind for vehicles moving at 90kph (beware to drop the bomb in a way to not stall it, facing which ever is larger, target speed or wind)
        end

        local _oldLase = ctld.jtacLaserPoints[_jtacGroupName]
        local _oldIR = ctld.jtacIRPoints[_jtacGroupName]

        if _oldLase == nil or _oldIR == nil then
            -- create lase

            local _status, _result = pcall(function()
                _spots['irPoint'] = Spot.createInfraRed(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
                _spots['laserPoint'] = Spot.createLaser(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated,
                    _laserCode)
                return _spots
            end)

            if not _status then
                env.error('ERROR: ' .. _result, false)
            else
                if _result.irPoint then
                    --        env.info(jtacUnit:getName() .. ' placed IR Pointer on '..enemyUnit:getName())

                    ctld.jtacIRPoints[_jtacGroupName] = _result
                        .irPoint --store so we can remove after
                end
                if _result.laserPoint then
                    --    env.info(jtacUnit:getName() .. ' is Lasing '..enemyUnit:getName()..'. CODE:'..laserCode)

                    ctld.jtacLaserPoints[_jtacGroupName] = _result.laserPoint
                end
            end
        else
            -- update lase

            if _oldLase ~= nil then
                _oldLase:setPoint(_enemyVectorUpdated)
            end

            if _oldIR ~= nil then
                _oldIR:setPoint(_enemyVectorUpdated)
            end
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
        --     tempPosition = unit:getPosition()

        _tempDist = ctld.utils.getDistance("ctld.getCurrentUnit()", _unit:getPoint(), _jtacUnit:getPoint())
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
function ctld.findNearestVisibleEnemy(_jtacUnit, _targetType, _distance)
    --local startTime = os.clock()
    local _maxDistance = _distance or ctld.JTAC_maxDistance
    local _nearestDistance = _maxDistance
    local _jtacGroupName = _jtacUnit:getGroup():getName()
    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()
    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }

    local _unitList = {}

    local _search = function(_unit, _coa)
        pcall(function()
            if _unit ~= nil
                and _unit:getLife() > 0
                and _unit:isActive()
                and _unit:getCoalition() ~= _coa
                and not _unit:inAir()
                and not ctld.alreadyTarget(_jtacUnit, _unit) then
                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then
                    local _dist = ctld.utils.getDistance("ctld.findNearestVisibleEnemy()", _offsetJTACPos,
                        _offsetEnemyPos)

                    if _dist < _maxDistance then
                        table.insert(_unitList, { unit = _unit, dist = _dist })
                    end
                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    --log.info(string.format("JTAC Search elapsed time: %.4f\n", os.clock() - startTime))

    -- generate list order by distance & visible

    -- first check
    -- hpriority
    -- priority
    -- vehicle
    -- unit


    ctld.jtacTargetsList[_jtacGroupName] = _unitList
    --from the units in range, build the targets list, unsorted as to keep consistency between radio menu refreshes

    local _sort = function(a, b) return a.dist < b.dist end
    table.sort(_unitList, _sort)
    -- sort list

    -- check for hpriority
    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "hpriority") then
            return _enemyUnit.unit
        end
    end

    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "priority") then
            return _enemyUnit.unit
        end
    end

    local result = nil
    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()
        --log.info(string.format("CTLD - checking _enemyName=%s", _enemyName))

        -- check for air defenses
        --log.info(string.format("CTLD - _enemyUnit.unit:getDesc()[attributes]=%s", ctld.p(_enemyUnit.unit:getDesc()["attributes"])))
        local airdefense = (_enemyUnit.unit:getDesc()["attributes"]["Air Defence"] ~= nil)
        --log.info(string.format("CTLD - airdefense=%s", tostring(airdefense)))

        if (_targetType == "vehicle" and ctld.isVehicle(_enemyUnit.unit)) or _targetType == "all" then
            if airdefense then
                return _enemyUnit.unit
            else
                result = _enemyUnit.unit
            end
        elseif (_targetType == "troop" and ctld.isInfantry(_enemyUnit.unit)) or _targetType == "all" then
            if airdefense then
                return _enemyUnit.unit
            else
                result = _enemyUnit.unit
            end
        end
    end

    return result
end

function ctld.listNearbyEnemies(_jtacUnit)
    local _maxDistance = ctld.JTAC_maxDistance

    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()

    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }
    local _enemies = nil

    local _search = function(_unit, _coa)
        pcall(function()
            if _unit ~= nil
                and _unit:getLife() > 0
                and _unit:isActive()
                and _unit:getCoalition() ~= _coa
                and not _unit:inAir() then
                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then
                    if not _enemies then
                        _enemies = {}
                    end

                    _enemies[_unit:getTypeName()] = _unit:getTypeName()
                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    return _enemies
end

-- tests whether the unit is targeted by another JTAC
function ctld.alreadyTarget(_jtacUnit, _enemyUnit)
    for _, _jtacTarget in pairs(ctld.jtacCurrentTargets) do
        if _jtacTarget.unitId == _enemyUnit:getID() then
            -- env.info("ALREADY TARGET")
            return true
        end
    end

    return false
end

-- Returns only alive units from group but the group / unit may not be active

function ctld.getGroup(groupName)
    local _group = Group.getByName(groupName)

    local _filteredUnits = {} --contains alive units
    local _x = 1

    if _group ~= nil then
        --ctld.logTrace(string.format("ctld.getGroup - %s - group ~= nil", ctld.p(groupName)))
        if _group:isExist() then
            --ctld.logTrace(string.format("ctld.getGroup - %s - group:isExist()", ctld.p(groupName)))
            local _groupUnits = _group:getUnits()

            if _groupUnits ~= nil and #_groupUnits > 0 then
                --ctld.logTrace(string.format("ctld.getGroup - %s - group has %s units", ctld.p(groupName), ctld.p(#_groupUnits)))
                for _x = 1, #_groupUnits do
                    if _groupUnits[_x]:getLife() > 0 then -- removed and _groupUnits[_x]:isExist() as isExist doesnt work on single units!
                        table.insert(_filteredUnits, _groupUnits[_x])
                    else
                        --ctld.logTrace(string.format("ctld.getGroup - %s - dead unit %s", ctld.p(groupName), ctld.p(_groupUnits[_x]:getName())))
                    end
                end
            end
        end
    end

    return _filteredUnits
end

function ctld.getAliveGroup(_groupName)
    local _group = Group.getByName(_groupName)

    if _group and _group:isExist() == true and #_group:getUnits() > 0 then
        return _group
    end

    return nil
end

-- gets the JTAC status and displays to coalition units
function ctld.getJTACStatus(_args)
    --returns the status of all JTAC units unless the status of a single JTAC is asked for (by inserting it's groupName in _args[2])

    local _playerUnit = ctld.getTransportUnit(_args[1])
    local _singleJtacGroupName = _args[2]

    if _playerUnit == nil and _singleJtacGroupName == nil then
        return
    end

    local _side = nil

    if _playerUnit == nil then
        _side = ctld.jtacUnits[_singleJtacGroupName].side
    else
        _side = _playerUnit:getCoalition()
    end

    local _jtacUnit = nil
    local hasJTAC = false
    local _message = ctld.i18n_translate("JTAC STATUS: \n\n")

    for _jtacGroupName, _jtacDetails in pairs(ctld.jtacUnits) do
        --look up units
        if _singleJtacGroupName == nil or (_singleJtacGroupName and _singleJtacGroupName == _jtacGroupName) then --if the status of a single JTAC or if the status of a single JTAC was asked and this is the correct JTAC we're going over in the loop
            _jtacUnit = Unit.getByName(_jtacDetails.name)

            if _jtacUnit ~= nil and _jtacUnit:getLife() > 0 and _jtacUnit:isActive() == true and _jtacUnit:getCoalition() == _side then
                hasJTAC = true

                local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

                local _laserCode = ctld.jtacLaserPointCodes[_jtacGroupName]

                local _start = "->" .. _jtacGroupName
                if (_jtacDetails.radio) then
                    _start = _start ..
                        ctld.i18n_translate(", available on %1 %2,", _jtacDetails.radio.freq, _jtacDetails.radio.mod)
                end

                if _laserCode == nil then
                    _laserCode = ctld.i18n_translate("UNKNOWN")
                end

                if _enemyUnit ~= nil and _enemyUnit:getLife() > 0 and _enemyUnit:isActive() == true then
                    local action = ctld.i18n_translate(" targeting ")

                    if ctld.jtacSelectedTarget[_jtacGroupName] == _enemyUnit:getName() then
                        action = ctld.i18n_translate(" targeting selected unit ")
                    else
                        if ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 then
                            action = ctld.i18n_translate(" attempting to find selected unit, temporarily targeting ")
                        end
                    end

                    if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                        action = action .. ctld.i18n_translate("(Laser OFF) ")
                    end

                    _message = _message ..
                        "" ..
                        _start ..
                        action ..
                        _enemyUnit:getTypeName() .. " CODE: " .. _laserCode .. ctld.getPositionString(_enemyUnit) .. "\n"

                    local _list = ctld.listNearbyEnemies(_jtacUnit)

                    if _list then
                        _message = _message .. ctld.i18n_translate("Visual On: ")

                        for _, _type in pairs(_list) do
                            _message = _message .. _type .. ", "
                        end
                        _message = _message .. "\n"
                    end
                else
                    _message = _message ..
                        "" ..
                        _start .. ctld.i18n_translate(" searching for targets %1\n", ctld.getPositionString(_jtacUnit))
                end
            end
        end
    end

    if not hasJTAC then
        ctld.notifyCoalition(ctld.i18n_translate("No Active JTACs"), 10, _side)
    else
        ctld.notifyCoalition(_message, 10, _side)
    end
end

function ctld.setJTACTarget(_args)
    if _args then
        local _jtacGroupName = _args.jtacGroupName
        local targetName = _args.targetName

        if _jtacGroupName and targetName and ctld.jtacSelectedTarget[_jtacGroupName] and ctld.jtacTargetsList[_jtacGroupName] then
            --look for the unit's (target) name in the Targets List, create the required data structure for jtacCurrentTargets and then assign it to the JTAC called _jtacGroupName
            for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
                if target then
                    local listedTargetUnit = target.unit
                    local ListedTargetName = listedTargetUnit:getName()

                    if ListedTargetName == targetName then
                        ctld.jtacSelectedTarget[_jtacGroupName] = targetName
                        ctld.jtacCurrentTargets[_jtacGroupName] = {
                            name = targetName,
                            unitType = listedTargetUnit
                                :getTypeName(),
                            unitId = listedTargetUnit:getID()
                        }

                        local message = _jtacGroupName ..
                            ctld.i18n_translate(", targeting selected unit, %1", listedTargetUnit:getTypeName())
                        local fullMessage = message ..
                            ctld.i18n_translate(". CODE: %1. POSITION: %2", ctld.jtacLaserPointCodes[_jtacGroupName],
                                ctld.getPositionString(listedTargetUnit))
                        ctld.notifyCoalition(fullMessage, 10, ctld.jtacUnits[_jtacGroupName].side,
                            ctld.jtacRadioData[_jtacGroupName], message)
                    end
                end
            end
        elseif not targetName and ctld.jtacSelectedTarget[_jtacGroupName] ~= 1 then
            ctld.jtacSelectedTarget[_jtacGroupName] = 1
            ctld.jtacCurrentTargets[_jtacGroupName] = nil

            local message = _jtacGroupName .. ctld.i18n_translate(", target selection reset.")
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])

            if ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] then
                ctld.setLaseCompensation({ jtacGroupName = _jtacGroupName, value = false }) --disable laser spot corrections
            end

            if ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] then
                ctld.setStdbMode({ jtacGroupName = _jtacGroupName, value = false }) --make the JTAC exit standby mode after either target selection or targeting selection reset
            end
        end

        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

--special option setters (make sure to affect the function pointer to the corresponding .setter in the special options table after declaration of said function)
function ctld.setSpecialOptionArgsCheck(_args)
    if _args then
        local _jtacGroupName = _args.jtacGroupName
        local _value = _args.value        --expected boolean
        local _notOutput = _args.noOutput --expected boolean

        if _jtacGroupName then
            return { jtacGroupName = _jtacGroupName, value = _value, noOutput = _notOutput }
        end
    end

    return nil
end

function ctld.setStdbMode(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _value = parsedArgs.value
        local _noOutput = parsedArgs.noOutput

        local message = ctld.i18n_translate("%1, laser and smokes enabled", _jtacGroupName)
        if _value then
            message = ctld.i18n_translate("%1, laser and smokes disabled", _jtacGroupName)
        end
        if not _noOutput then
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
        end

        ctld.jtacSpecialOptions.standbyMode.jtacs[_jtacGroupName] = _value
        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

ctld.jtacSpecialOptions.standbyMode.setter = ctld.setStdbMode

function ctld.setLaseCompensation(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _value = parsedArgs.value
        local _noOutput = parsedArgs.noOutput

        local message = ctld.i18n_translate("%1, wind and target speed laser spot compensations enabled", _jtacGroupName)
        if _value then
            message = ctld.i18n_translate("%1, wind and target speed laser spot compensations disabled", _jtacGroupName)
        end
        if not _noOutput then
            ctld.notifyCoalition(message, 10, ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
        end

        ctld.jtacSpecialOptions.laseSpotCorrections.jtacs[_jtacGroupName] = _value
        ctld.refreshJTACmenu[ctld.jtacUnits[_jtacGroupName].side] = true
    end
end

ctld.jtacSpecialOptions.laseSpotCorrections.setter = ctld.setLaseCompensation

function ctld.setSmokeOnTarget(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName
        local _noOutput = parsedArgs.noOutput
        local _enemyUnit = Unit.getByName(ctld.jtacCurrentTargets[_jtacGroupName].name)

        if _enemyUnit then
            if not _noOutput then
                ctld.notifyCoalition(ctld.i18n_translate("%1, WHITE smoke deployed near target", _jtacGroupName), 10,
                    ctld.jtacUnits[_jtacGroupName].side, ctld.jtacRadioData[_jtacGroupName])
            end

            local _enemyPoint = _enemyUnit:getPoint()
            local randomCircleDiam = 30;
            trigger.action.smoke(
                {
                    x = _enemyPoint.x + math.random(randomCircleDiam, -randomCircleDiam),
                    y = _enemyPoint.y + 2.0,
                    z =
                        _enemyPoint.z + math.random(randomCircleDiam, -randomCircleDiam)
                }, 2)
        end
    end
end

ctld.jtacSpecialOptions.smokeMarker.setter = ctld.setSmokeOnTarget

function ctld.setJTAC9Line(_args)
    local parsedArgs = ctld.setSpecialOptionArgsCheck(_args)
    if parsedArgs then
        local _jtacGroupName = parsedArgs.jtacGroupName

        ctld.getJTACStatus({ nil, _jtacGroupName })
    end
end

ctld.jtacSpecialOptions._9Line.setter = ctld.setJTAC9Line

function ctld.setGrpROE(_grp, _ROE)
    if _grp == nil then
        ctld.logError("ctld.setGrpROE called with a nil group")
        return
    end

    if _ROE == nil then
        _ROE = AI.Option.Ground.val.ROE.OPEN_FIRE
    end

    if _grp and _grp:isExist() == true and #_grp:getUnits() > 0 then -- check if the group truly exists
        local _controller = _grp:getController();
        Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
        Controller.setOption(_controller, AI.Option.Ground.id.ROE, _ROE)
        --_controller:setTask(_grp)             -- FG 250510 this line seems to be a bug
    end
end

function ctld.isInfantry(_unit)
    local _typeName = _unit:getTypeName()

    --type coerce tostring
    _typeName = string.lower(_typeName .. "")

    local _soldierType = { "infantry", "paratrooper", "stinger", "manpad", "mortar" }

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
--    The range used to be bugged so its not 1 - 8 but 0 - 7.
-- function below will use the range 1-7 just incase
function ctld.generateLaserCode()
    ctld.jtacGeneratedLaserCodes = {}

    -- generate list of laser codes
    local _code = 1511

    local _count = 1

    while _code < 1777 and _count < 30 do
        while true do
            _code = _code + 1

            if not ctld.containsDigit(_code, 8)
                and not ctld.containsDigit(_code, 9)
                and not ctld.containsDigit(_code, 0) then
                table.insert(ctld.jtacGeneratedLaserCodes, _code)

                --env.info(_code.." Code")
                break
            end
        end
        _count = _count + 1
    end
end

function ctld.containsDigit(_number, _numberToFind)
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

-- 200 - 400 in 10KHz
-- 400 - 850 in 10 KHz
-- 850 - 1250 in 50 KHz
function ctld.generateVHFrequencies()
    --ignore list
    --list of all frequencies in KHZ that could conflict with
    -- 191 - 1290 KHz, beacon range
    local _skipFrequencies = {
        745, --Astrahan
        381,
        384,
        300.50,
        312.5,
        1175,
        342,
        735,
        300.50,
        353.00,
        440,
        795,
        525,
        520,
        690,
        625,
        291.5,
        300.50,
        435,
        309.50,
        920,
        1065,
        274,
        312.50,
        580,
        602,
        297.50,
        750,
        485,
        950,
        214,
        1025, 730, 995, 455, 307, 670, 329, 395, 770,
        380, 705, 300.5, 507, 740, 1030, 515,
        330, 309.5,
        348, 462, 905, 352, 1210, 942, 435,
        324,
        320, 420, 311, 389, 396, 862, 680, 297.5,
        920, 662,
        866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528,
        337, 312.5, 830, 740, 309.5, 641, 312, 722, 682, 1050,
        1116, 935, 1000, 430, 577,
        326 -- Nevada
    }

    ctld.freeVHFFrequencies = {}
    local _start = 200000

    -- first range
    while _start < 400000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end


        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 400000
    -- second range
    while _start < 850000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end


        _start = _start + 10000
    end

    _start = 850000
    -- third range
    while _start <= 1250000 do
        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 50000
    end
end

-- 220 - 399 MHZ, increments of 0.5MHZ
function ctld.generateUHFrequencies()
    ctld.freeUHFFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do
        table.insert(ctld.freeUHFFrequencies, _start)
        _start = _start + 500000
    end
end

-- 220 - 399 MHZ, increments of 0.5MHZ
--        -- first digit 3-7MHz
--        -- second digit 0-5KHz
--        -- third digit 0-9
--        -- fourth digit 0 or 5
--        -- times by 10000
--
function ctld.generateFMFrequencies()
    ctld.freeFMFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do
        _start = _start + 500000
    end

    for _first = 3, 7 do
        for _second = 0, 5 do
            for _third = 0, 9 do
                local _frequency = ((100 * _first) + (10 * _second) + _third) *
                    100000 --extra 0 because we didnt bother with 4th digit
                table.insert(ctld.freeFMFrequencies, _frequency)
            end
        end
    end
end

function ctld.getPositionString(_unit)
    if ctld.JTAC_location == false then
        return ""
    end

    local _lat, _lon  = coord.LOtoLL(_unit:getPosition().p)
    local _latLngStr  = ctld.utils.tostringLL("ctld.getPositionString()", _lat, _lon, 3, ctld.location_DMS)
    local _mgrsString = ctld.utils.tostringMGRS("ctld.getPositionString()",
        coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)
    local _TargetAlti = land.getHeight(ctld.utils.makeVec2FromVec3OrVec2("ctld.getPositionString()", _unit:getPoint()))
    return " @ " ..
        _latLngStr ..
        " - MGRS " ..
        _mgrsString ..
        " - ALTI: " ..
        ctld.utils.round("ctld.getPositionString()", _TargetAlti, 0) ..
        " m / " .. ctld.utils.round("ctld.getPositionString()", _TargetAlti / 0.3048, 0) .. " ft"
end

--**********************************************************************
--  Automaticaly put in orbit over his target a flying JTAC
--
--  Objective   :   This script put in orbit each flying JTAC over his detected target
--                  Associated with CTLD/JTAC function, you can assign a fly route to the JTAC (a drone for example),
--                  this one follow it, and start orbiting when he detects a target.
--                  As soon as it don't detect a target, it restart following its initial route at the nearest waypoint
--  Use : In mission editor:
--                  0> Set ctld.enableAutoOrbitingFlyingJtacOnTarget = true
--      			1> Load MIST + CTLD
--                  2> Create a TRIGGER (once) at Time sup à 6, and a ACTION.EXECUTE SCRIPT :
--							ctld.JTACAutoLase("gdrone1", 1688,false)  -- défine group "gdrone1" as a JTAC
------------------------------------------------------------------------------------
ctld.JTACInRoute = {}                            -- for each JTAC in route, indicates the time of the run
ctld.OrbitInUse = {}                             -- for each Orbit group in use, indicates the time of the run
ctld.enableAutoOrbitingFlyingJtacOnTarget = true -- if true activate the AutoOrbitingFlyinfJtacOnTarget function for all flying JTACS
------------------------------------------------------------------------------------
-- Automatic JTAC orbit on target detect
function ctld.TreatOrbitJTAC(params, t)
    if t == nil then t = timer.getTime() end

    for k, v in pairs(ctld.jtacUnits) do                                     -- vérify state of each active JTAC
        if ctld.isFlyingJtac(k) then
            if ctld.JTACInRoute[k] == nil and ctld.OrbitInUse[k] == nil then -- if JTAC is in route
                ctld.JTACInRoute[k] = timer.getTime()                        -- update time of the last run
            end

            if ctld.jtacCurrentTargets[k] ~= nil then                                            -- if target lased by JTAC
                local droneAlti = Unit.getByName(k):getPoint().y
                if ctld.OrbitInUse[k] == nil then                                                -- if JTAC is not in orbit => start orbiting and update start time
                    ctld.StartOrbitGroup(k, ctld.jtacCurrentTargets[k].name, droneAlti, 100)     -- do orbit JTAC
                    ctld.OrbitInUse[k]  = timer.getTime()                                        -- update time of the last orbit run
                    ctld.JTACInRoute[k] = nil                                                    -- JTAC is in orbit => reset the route time
                else                                                                             -- JTAC already orbiting => update coord for following the target mouvements each 60"
                    if timer.getTime() > (ctld.OrbitInUse[k] + 60) then                          -- each 60" update orbit coord
                        ctld.StartOrbitGroup(k, ctld.jtacCurrentTargets[k].name, droneAlti, 100) -- do orbit JTAC
                        ctld.OrbitInUse[k] = timer.getTime()                                     -- update time of the last orbit run
                    end
                end
            else                                          -- if JTAC have no target
                if ctld.InOrbitList(k) == true then       -- JTAC orbiting, without target => stop orbit
                    --Unit.getByName(k):getController():popTask()	   -- stop orbiting JTAC Task => return to route
                    ctld.backToRoute(k)                   -- return to route from the nearest WP
                    ctld.OrbitInUse[k]  = nil             -- Reset orbit
                    ctld.JTACInRoute[k] = timer.getTime() -- update time of the last start inroute
                end
            end
        end
    end
    return t + 3 --reschedule in 3"
end

------------------------------------------------------------------------------------
-- Make orbit the _jtacUnitName group, on target "_unitTargetName".  _alti in meters, speed in km/h
function ctld.StartOrbitGroup(_jtacUnitName, _unitTargetName, _alti, _speed)
    if (Unit.getByName(_unitTargetName) ~= nil) and (Unit.getByName(_jtacUnitName) ~= nil) then -- si target unit and JTAC group exist
        local orbit = {
            id     = 'Orbit',
            params = {
                pattern = 'Circle',
                --point = ctld.utils.makeVec2FromVec3OrVec2("ctld.StartOrbitGroup()",
                --    ctld.utils.getAvgPos("ctld.StartOrbitGroup()",
                --        CTLD_extAPI.makeUnitTable("ctld.StartOrbitGroup()", { _unitTargetName }))),
                point = ctld.utils.makeVec2FromVec3OrVec2("ctld.StartOrbitGroup()",
                    Unit.getByName(_unitTargetName):getPoint()),
                speed = _speed,
                altitude = _alti
            }
        }
        local jtacGroupName = Unit.getByName(_jtacUnitName):getGroup():getName()
        Unit.getByName(_jtacUnitName):getController():popTask() -- stop current Task
        Group.getByName(jtacGroupName):getController():pushTask(orbit)
    end
end

-------------------------------------------------------------------------------------------
-- test if one unitName already is targeted by a JTAC
function ctld.InOrbitList(_grpName)
    for k, v in pairs(ctld.OrbitInUse) do -- for each orbit in use
        if k == _grpName then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------------
-- return the WayPoint number (on the JTAC route) the most near from the target
function ctld.getNearestWP(_referenceUnitName)
    local WP = 0
    local memoDist = nil                                                                  -- Lower distance checked
    local refGroupName = Unit.getByName(_referenceUnitName):getGroup():getName()
    local JTACRoute = ctld.utils.getGroupRoute("ctld.getNearestWP()", refGroupName, true) -- get the initial editor route of the current group
    if Unit.getByName(_referenceUnitName) ~= nil then                                     --JTAC et unit must exist
        for i = 1, #JTACRoute do
            local ptWP  = { x = JTACRoute[i].x, y = JTACRoute[i].y }
            local ptRef = ctld.utils.makeVec2FromVec3OrVec2("ctld.getNearestWP()",
                Unit.getByName(_referenceUnitName):getPoint())
            local dist  = ctld.utils.get2DDist("ctld.getNearestWP()", ptRef, ptWP) -- distance between 2 points
            if memoDist == nil then
                memoDist = dist
                WP = i
            elseif dist < memoDist then
                memoDist = dist
                WP = i
            end
        end
    end
    return WP
end

----------------------------------------------------------------------------
-- Modify the route deleting all the WP before "firstWP" param, for aligne the orbit on the nearest WP of the target
function ctld.backToRoute(_jtacUnitName)
    local jtacGroupName = Unit.getByName(_jtacUnitName):getGroup():getName()
    --local JTACRoute     = ctld.utils.getGroupRoute("ctld.backToRoute()", jtacGroupName, true)   -- get the initial editor route of the current group
    local JTACRoute     = ctld.utils.deepCopy("ctld.backToRoute()",
        ctld.utils.getGroupRoute("ctld.backToRoute()", jtacGroupName, true)) -- get the initial editor route of the current group
    local newJTACRoute  = ctld.adjustRoute(JTACRoute, ctld.getNearestWP(_jtacUnitName))

    local Mission       = {}
    Mission             = { id = 'Mission', params = { route = { points = newJTACRoute } } }

    -- unactive orbit mode if it's on
    if ctld.InOrbitList(_jtacUnitName) == true then -- if JTAC orbiting => stop it
        ctld.OrbitInUse[_jtacUnitName] = nil
    end
    Unit.getByName(_jtacUnitName):getController():setTask(Mission) -- submit the new route
    return Mission
end

----------------------------------------------------------------------------
function ctld.adjustRoute(_initialRouteTable, _firstWpOfNewRoute) -- create a route based on inital one, starting at _firstWpOfNewRoute WP
    if _firstWpOfNewRoute >= 1 then
        -- if the last WP switch to the first this cycle is recreated
        local adjustedRoute = {}
        local mappingWP = {}
        local idx = 1
        for i = _firstWpOfNewRoute, #_initialRouteTable do -- load each WP route starting from _firstWpOfNewRoute to end
            adjustedRoute[idx] = _initialRouteTable[i]
            mappingWP[i] = idx
            ctld.logDebug("ctld.adjustRoute - mappingWP[%s]=[%s]", ctld.p(i), ctld.p(idx))
            idx = idx + 1
        end
        for i = 1, _firstWpOfNewRoute - 1 do -- load each WP route starting from 1 to _firstWpOfNewRoute-1
            adjustedRoute[idx] = _initialRouteTable[i]
            mappingWP[i] = idx
            ctld.logDebug("ctld.adjustRoute - mappingWP[%s]=[%s]", ctld.p(i), ctld.p(idx))
            idx = idx + 1
        end

        -- apply offset (_firstWpOfNewRoute) to SwitchWaypoint tasks
        local lastWpAsAlreadySwitchWaypoint = false
        for idx2 = 1, #adjustedRoute do
            if #adjustedRoute[idx2] and
                #adjustedRoute[idx2].task and
                #adjustedRoute[idx2].task.params and
                #adjustedRoute[idx2].task.params.tasks then
                for j = 1, #adjustedRoute[idx2].task.params.tasks do
                    if adjustedRoute[idx2].task.params.tasks[j].id and
                        adjustedRoute[idx2].task.params.tasks[j].id ~= "ControlledTask" then
                        if adjustedRoute[idx2].task.params.tasks[j].params and
                            adjustedRoute[idx2].task.params.tasks[j].params.action and
                            adjustedRoute[idx2].task.params.tasks[j].params.action.id and
                            adjustedRoute[idx2].task.params.tasks[j].params.action.id == "SwitchWaypoint" then
                            if adjustedRoute[idx2].task.params.tasks[j].params.action.params then
                                local goToWaypointIndex = adjustedRoute[idx2].task.params.tasks[j].params.action.params
                                    .goToWaypointIndex
                                adjustedRoute[idx2].task.params.tasks[j].params.action.params.fromWaypointIndex = idx2
                                adjustedRoute[idx2].task.params.tasks[j].params.action.params.goToWaypointIndex =
                                    mappingWP[goToWaypointIndex]
                                if idx2 == #adjustedRoute then
                                    lastWpAsAlreadySwitchWaypoint = true
                                end
                            end
                        end
                    else -- for "ControlledTask"
                        if adjustedRoute[idx2].task.params.tasks[j].params and
                            adjustedRoute[idx2].task.params.tasks[j].params.task and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.id and
                            adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.id == "SwitchWaypoint" then
                            if adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params then
                                local goToWaypointIndex = adjustedRoute[idx2].task.params.tasks[j].params.task.params
                                    .action.params.goToWaypointIndex
                                adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params.fromWaypointIndex =
                                    idx2
                                adjustedRoute[idx2].task.params.tasks[j].params.task.params.action.params.goToWaypointIndex =
                                    mappingWP[goToWaypointIndex]
                                if idx2 == #adjustedRoute then
                                    lastWpAsAlreadySwitchWaypoint = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if lastWpAsAlreadySwitchWaypoint == false then
            local newTaskIdx                                                                 = #adjustedRoute
                [#adjustedRoute].task.params.tasks + 1
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx]                      = {
                number  = newTaskIdx,
                auto    = false,
                enabled = true,
                id      = "WrappedAction",
                params  = { action = {} }
            }
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx].params.action.id     = "SwitchWaypoint"
            adjustedRoute[#adjustedRoute].task.params.tasks[newTaskIdx].params.action.params = {
                fromWaypointIndex = #_initialRouteTable,
                goToWaypointIndex = 1
            }
        end
        --ctld.logDebug("ctld.adjustRoute - adjustedRoute = [%s]", ctld.p(adjustedRoute))
        return adjustedRoute
    end
    return nil
end

----------------------------------------------------------------------------
function ctld.isFlyingJtac(_jtacUnitName)
    if Unit.getByName(_jtacUnitName) then
        if Unit.getByName(_jtacUnitName):getCategoryEx() == 0 then -- it's an airplane JTAC
            return true
        end
    end
    return false
end
