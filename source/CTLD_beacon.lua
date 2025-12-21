--spawns a radio beacon made up of two units,
-- one for VHF and one for UHF
-- The units are set to to NOT engage
function ctld.createRadioBeacon(_point, _coalition, _country, _name, _batteryTime, _isFOB)
    local _freq = ctld.generateADFFrequencies()

    --create timeout
    local _battery

    if _batteryTime == nil then
        _battery = timer.getTime() + (ctld.deployedBeaconBattery * 60)
    else
        _battery = timer.getTime() + (_batteryTime * 60)
    end

    local _lat, _lon = coord.LOtoLL(_point)

    local _latLngStr = ctld.utils.tostringLL("ctld.createRadioBeacon()", _lat, _lon, 3, ctld.location_DMS)

    --local _mgrsString = ctld.utils.tostringMGRS("ctld.createRadioBeacon()", coord.LLtoMGRS(coord.LOtoLL(_point)), 5)

    local _freqsText = _name

    if _isFOB then
        --    _message = "FOB " .. _message
        _battery = -1 --never run out of power!
    end

    _freqsText = _freqsText .. " - " .. _latLngStr


    _freqsText = string.format("%.2f kHz - %.2f / %.2f MHz", _freq.vhf / 1000, _freq.uhf / 1000000, _freq.fm / 1000000)

    local _uhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _vhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _fmGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)

    local _beaconDetails = {
        vhf = _freq.vhf,
        vhfGroup = _vhfGroup:getName(),
        uhf = _freq.uhf,
        uhfGroup = _uhfGroup:getName(),
        fm = _freq.fm,
        fmGroup = _fmGroup:getName(),
        text = _freqsText,
        battery = _battery,
        coalition = _coalition,
    }

    ctld.updateRadioBeacon(_beaconDetails)

    table.insert(ctld.deployedRadioBeacons, _beaconDetails)

    return _beaconDetails
end

function ctld.generateADFFrequencies()
    if #ctld.freeUHFFrequencies <= 3 then
        ctld.freeUHFFrequencies = ctld.usedUHFFrequencies
        ctld.usedUHFFrequencies = {}
    end

    --remove frequency at RANDOM
    local _uhf = table.remove(ctld.freeUHFFrequencies, math.random(#ctld.freeUHFFrequencies))
    table.insert(ctld.usedUHFFrequencies, _uhf)


    if #ctld.freeVHFFrequencies <= 3 then
        ctld.freeVHFFrequencies = ctld.usedVHFFrequencies
        ctld.usedVHFFrequencies = {}
    end

    local _vhf = table.remove(ctld.freeVHFFrequencies, math.random(#ctld.freeVHFFrequencies))
    table.insert(ctld.usedVHFFrequencies, _vhf)

    if #ctld.freeFMFrequencies <= 3 then
        ctld.freeFMFrequencies = ctld.usedFMFrequencies
        ctld.usedFMFrequencies = {}
    end

    local _fm = table.remove(ctld.freeFMFrequencies, math.random(#ctld.freeFMFrequencies))
    table.insert(ctld.usedFMFrequencies, _fm)

    return { uhf = _uhf, vhf = _vhf, fm = _fm }
    --- return {uhf=_uhf,vhf=_vhf}
end

function ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _groupId = ctld.getNextGroupId()

    local _unitId = ctld.getNextUnitId()

    local _radioGroup = {
        ["visible"] = false,
        -- ["groupId"] = _groupId,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["y"] = _point.z,
                ["type"] = "TACAN_beacon",
                ["name"] = "Unit #" .. _unitId .. " - " .. _name .. " [" .. _freqsText .. "]",
                --     ["unitId"] = _unitId,
                ["heading"] = 0,
                ["playerCanDrive"] = true,
                ["skill"] = "Excellent",
                ["x"] = _point.x,
            }
        },
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = "Group #" .. _groupId .. " - " .. _name,
        ["task"] = {},
        --added two fields below for MIST
        ["category"] = Group.Category.GROUND,
        ["country"] = _country
    }

    -- return coalition.addGroup(_country, Group.Category.GROUND, _radioGroup)
    return Group.getByName(ctld.utils.dynAdd("ctld.spawnRadioBeaconUnit()", _radioGroup).name)
end

function ctld.updateRadioBeacon(_beaconDetails)
    local _vhfGroup = Group.getByName(_beaconDetails.vhfGroup)

    local _uhfGroup = Group.getByName(_beaconDetails.uhfGroup)

    local _fmGroup = Group.getByName(_beaconDetails.fmGroup)

    local _radioLoop = {}

    if _vhfGroup ~= nil and _vhfGroup:getUnits() ~= nil and #_vhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _vhfGroup, freq = _beaconDetails.vhf, silent = false, mode = 0 })
    end

    if _uhfGroup ~= nil and _uhfGroup:getUnits() ~= nil and #_uhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _uhfGroup, freq = _beaconDetails.uhf, silent = true, mode = 0 })
    end

    if _fmGroup ~= nil and _fmGroup:getUnits() ~= nil and #_fmGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _fmGroup, freq = _beaconDetails.fm, silent = false, mode = 1 })
    end

    local _batLife = _beaconDetails.battery - timer.getTime()

    if (_batLife <= 0 and _beaconDetails.battery ~= -1) or #_radioLoop ~= 3 then
        -- ran out of batteries
        if _vhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_vhfGroup:getName())
            _vhfGroup:destroy()
        end
        if _uhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_uhfGroup:getName())
            _uhfGroup:destroy()
        end
        if _fmGroup ~= nil then
            trigger.action.stopRadioTransmission(_fmGroup:getName())
            _fmGroup:destroy()
        end

        return false
    end

    --fobs have unlimited battery life
    --        if _battery ~= -1 then
    --                _text = _text.." "..ctld.utils.round("ctld.updateRadioBeacon()", _batLife).." seconds of battery"
    --        end

    for _, _radio in pairs(_radioLoop) do
        local _groupController = _radio.group:getController()

        local _sound = ctld.radioSound
        if _radio.silent then
            _sound = ctld.radioSoundFC3
        end

        _sound = "l10n/DEFAULT/" .. _sound

        _groupController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)


        -- stop the transmission at each call to the ctld.updateRadioBeacon method (default each minute)
        trigger.action.stopRadioTransmission(_radio.group:getName())

        -- restart it as the battery is still up
        -- the transmission is set to loop and has the name of the transmitting DCS group (that includes the type - i.e. FM, UHF, VHF)
        trigger.action.radioTransmission(_sound, _radio.group:getUnit(1):getPoint(), _radio.mode, true, _radio.freq, 1000,
            _radio.group:getName())
    end

    return true
end

function ctld.listRadioBeacons(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil then
        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                _message = _message .. _details.text .. "\n"
            end
        end

        if _message ~= "" then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Radio Beacons:\n%1", _message), 20)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Active Radio Beacons"), 20)
        end
    end
end

function ctld.dropRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        --deploy 50 m infront
        --try to spawn at 12 oclock to us
        local _point = ctld.getPointAt12Oclock(_heli, 50)

        ctld.beaconCount = ctld.beaconCount + 1
        local _name = "Beacon #" .. ctld.beaconCount

        local _radioBeaconDetails = ctld.createRadioBeacon(_point, _heli:getCoalition(), _heli:getCountry(), _name, nil,
            false)

        -- mark with flare?

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 deployed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                _radioBeaconDetails.text), 20)
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before you can deploy a Radio Beacon!"),
            20)
    end
end

--remove closet radio beacon
function ctld.removeRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        -- mark with flare?

        local _closestBeacon = nil
        local _shortestDistance = -1
        local _distance = 0

        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                local _group = Group.getByName(_details.vhfGroup)

                if _group ~= nil and #_group:getUnits() == 1 then
                    _distance = ctld.utils.getDistance("ctld.removeRadioBeacon()", _heli:getPoint(),
                        _group:getUnit(1):getPoint())
                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestBeacon = _details
                    end
                end
            end
        end

        if _closestBeacon ~= nil and _shortestDistance then
            local _vhfGroup = Group.getByName(_closestBeacon.vhfGroup)

            local _uhfGroup = Group.getByName(_closestBeacon.uhfGroup)

            local _fmGroup = Group.getByName(_closestBeacon.fmGroup)

            if _vhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_vhfGroup:getName())
                _vhfGroup:destroy()
            end
            if _uhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_uhfGroup:getName())
                _uhfGroup:destroy()
            end
            if _fmGroup ~= nil then
                trigger.action.stopRadioTransmission(_fmGroup:getName())
                _fmGroup:destroy()
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 removed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                    _closestBeacon.text), 20)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Radio Beacons within 500m."), 20)
        end
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before remove a Radio Beacon"), 20)
    end
end
