--**********************************************************************
--                                     RECOGNITION SUPPORT FUNCTIONS
-- Shows/remove/refresh marks in F10 map on targets in LOS of a unit passed in params
---------------------------------------------------------------------
-- examples ---------------------------------------------------------
--ctld.reconRefreshTargetsInLosOnF10Map(Unit.getByName("uh2-1"), 2000, 200)
--ctld.reconRemoveTargetsInLosOnF10Map(Unit.getByName("uh2-1"))
--ctld.reconShowTargetsInLosOnF10Map(Unit.getByName("uh2-1"), 2000, 200)
----------------------------------------------------------------------
--if ctld == nil then    ctld = {} end
if ctld.lastMarkId == nil then
    ctld.lastMarkId = 0
end

-- ***************** RECON CONFIGURATION *****************
ctld.reconF10Menu                   = true                         -- enables F10 RECON menu
ctld.reconMenuName                  = ctld.i18n_translate("RECON") --name of the CTLD JTAC radio menu
ctld.reconRadioAdded                = {}                           --stores the groups that have had the radio menu added
ctld.reconLosSearchRadius           = 2000                         -- search radius in meters
ctld.reconLosMarkRadius             = 100                          -- mark radius dimension in meters
ctld.reconAutoRefreshLosTargetMarks = false                        -- if true recon LOS marks are automaticaly refreshed on F10 map
ctld.reconLastScheduleIdAutoRefresh = 0

---- F10 RECON Menus ------------------------------------------------------------------
function ctld.addReconRadioCommand(_side) -- _side = 1 or 2 (red    or blue)
    if ctld.reconF10Menu then
        if _side == 1 or _side == 2 then
            local _players = coalition.getPlayers(_side)
            if _players ~= nil then
                for _, _playerUnit in pairs(_players) do
                    local _groupId = ctld.utils.getGroupId("ctld.addReconRadioCommand()", _playerUnit)
                    if _groupId then
                        if ctld.reconRadioAdded[tostring(_groupId)] == nil then
                            --ctld.logDebug("ctld.addReconRadioCommand - adding RECON radio menu for unit [%s]", ctld.p(_playerUnit:getName()))
                            local RECONpath = missionCommands.addSubMenuForGroup(_groupId, ctld.reconMenuName)
                            missionCommands.addCommandForGroup(_groupId,
                                ctld.i18n_translate("Show targets in LOS (refresh)"), RECONpath,
                                ctld.reconRefreshTargetsInLosOnF10Map, {
                                    _groupId      = _groupId,
                                    _playerUnit   = _playerUnit,
                                    _searchRadius = ctld.reconLosSearchRadius,
                                    _markRadius   = ctld.reconLosMarkRadius,
                                    _boolRemove   = true
                                })
                            missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Hide targets in LOS"),
                                RECONpath, ctld.reconRemoveTargetsInLosOnF10Map, _playerUnit)
                            if ctld.reconAutoRefreshLosTargetMarks then
                                missionCommands.addCommandForGroup(_groupId,
                                    ctld.i18n_translate("STOP autoRefresh targets in LOS"), RECONpath,
                                    ctld.reconStopAutorefreshTargetsInLosOnF10Map,
                                    _groupId,
                                    _playerUnit,
                                    ctld.reconLosSearchRadius,
                                    ctld.reconLosMarkRadius,
                                    true)
                            else
                                missionCommands.addCommandForGroup(_groupId,
                                    ctld.i18n_translate("START autoRefresh targets in LOS"), RECONpath,
                                    ctld.reconStartAutorefreshTargetsInLosOnF10Map,
                                    _groupId,
                                    _playerUnit,
                                    ctld.reconLosSearchRadius,
                                    ctld.reconLosMarkRadius,
                                    true
                                )
                            end
                            ctld.reconRadioAdded[tostring(_groupId)] = timer.getTime() --fetch the time to check for a regular refresh
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------
function ctld.reconStopAutorefreshTargetsInLosOnF10Map(_groupId, _playerUnit, _searchRadius, _markRadius, _boolRemove)
    ctld.reconAutoRefreshLosTargetMarks = false

    if ctld.reconLastScheduleIdAutoRefresh ~= 0 then
        timer.removeFunction(ctld.reconLastScheduleIdAutoRefresh) -- reset last schedule
    end

    ctld.reconRemoveTargetsInLosOnF10Map(_playerUnit)
    missionCommands.removeItemForGroup(_groupId,
        { ctld.reconMenuName, ctld.i18n_translate("STOP autoRefresh targets in LOS") })
    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("START autoRefresh targets in LOS"),
        { ctld.reconMenuName },
        ctld.reconStartAutorefreshTargetsInLosOnF10Map,
        _groupId,
        _playerUnit,
        _searchRadius,
        _markRadius,
        _boolRemove)
end

--------------------------------------------------------------------
function ctld.reconStartAutorefreshTargetsInLosOnF10Map(_groupId, _playerUnit, _searchRadius, _markRadius, _boolRemove)
    ctld.reconAutoRefreshLosTargetMarks = true
    ctld.reconRefreshTargetsInLosOnF10Map({
            _groupId      = _groupId,
            _playerUnit   = _playerUnit,
            _searchRadius = _searchRadius or ctld.reconLosSearchRadius,
            _markRadius   = _markRadius or ctld.reconLosMarkRadius,
            _boolRemove   = _boolRemove or true
        },
        timer.getTime())
    missionCommands.removeItemForGroup(_groupId,
        { ctld.reconMenuName, ctld.i18n_translate("START autoRefresh targets in LOS") })
    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("STOP autoRefresh targets in LOS"),
        { ctld.reconMenuName },
        ctld.reconStopAutorefreshTargetsInLosOnF10Map,
        _groupId,
        _playerUnit,
        _searchRadius,
        _markRadius,
        _boolRemove)
end

--------------------------------------------------------------------
function ctld.reconShowTargetsInLosOnF10Map(_playerUnit, _searchRadius, _markRadius) -- _groupId targeting
    -- _searchRadius and _markRadius in meters
    if _playerUnit then
        local TargetsInLOS = {}

        local enemyColor = "red"
        local color = { 1, 0, 0, 0.2 } -- red

        if _playerUnit:getCoalition() == 1 then
            enemyColor = "blue"
            color = { 51 / 255, 51 / 255, 1, 0.2 } -- blue
        end

        local enemyUnitsListNames = {}
        for i, v in ipairs(coalition.getGroups(coalition.side[string.upper(enemyColor)], Group.Category.GROUND)) do
            local groupUnits = v:getUnits()
            for ii, vv in ipairs(groupUnits) do
                enemyUnitsListNames[#enemyUnitsListNames + 1] = vv:getName()
            end
        end
        --local t = ctld.utils.getUnitsLOS("ctld.reconShowTargetsInLosOnF10Map()", { _playerUnit:getName() }, 180,
        --    CTLD_extAPI.makeUnitTable("ctld.reconShowTargetsInLosOnF10Map()", { '[' .. enemyColor .. '][vehicle]' }),
        --    180, _searchRadius)

        local t = ctld.utils.getUnitsLOS("ctld.reconShowTargetsInLosOnF10Map()",
            { _playerUnit:getName() },
            180,
            enemyUnitsListNames,
            180, _searchRadius)

        local MarkIds = {}
        if t then
            for i = 1, #t do                                   -- for each unit having los on enemies
                for j = 1, #t[i].vis do                        -- for each enemy unit in los
                    local targetPoint = t[i].vis[j]:getPoint() -- point of each target on LOS
                    ctld.lastMarkId = ctld.lastMarkId + 1
                    trigger.action.circleToAll(_playerUnit:getCoalition(), ctld.lastMarkId, targetPoint, _markRadius,
                        color, color, 1, false, nil)
                    MarkIds[#MarkIds + 1] = ctld.lastMarkId
                    TargetsInLOS[#TargetsInLOS + 1] = {
                        targetObject   = t[i].vis[j]:getName(),
                        targetTypeName = t[i].vis[j]:getTypeName(),
                        targetPoint    = targetPoint
                    }
                end
            end
        end
        ctld.unitsWithPlayer[_playerUnit:getName()].losMarkIds =
            MarkIds -- store list of marksIds generated and showed on F10 map
        return TargetsInLOS
    else
        return nil
    end
end

---------------------------------------------------------
function ctld.reconRemoveTargetsInLosOnF10Map(_playerUnit)
    local unitName = _playerUnit:getName()
    if ctld.unitsWithPlayer[unitName].losMarkIds then
        for i = 1, #ctld.unitsWithPlayer[unitName].losMarkIds do -- for each unit having los on enemies
            trigger.action.removeMark(ctld.unitsWithPlayer[unitName].losMarkIds[i])
        end
        ctld.unitsWithPlayer[unitName].losMarkIds = nil
    end
end

---------------------------------------------------------
function ctld.reconRefreshTargetsInLosOnF10Map(_params, _t) -- _params._playerUnit targeting
    -- _params._searchRadius and _params._markRadius in meters
    -- _params._boolRemove = true to remove previous marksIds
    if _t == nil then _t = timer.getTime() end

    if ctld.reconAutoRefreshLosTargetMarks then -- to follow mobile enemy targets
        ctld.reconLastScheduleIdAutoRefresh = timer.scheduleFunction(ctld.reconRefreshTargetsInLosOnF10Map,
            {
                _groupId      = _params._groupId,
                _playerUnit   = _params._playerUnit,
                _searchRadius = _params._searchRadius,
                _markRadius   = _params._markRadius,
                _boolRemove   = _params._boolRemove
            },
            timer.getTime() + 10)
    end

    if _params._boolRemove == true then
        ctld.reconRemoveTargetsInLosOnF10Map(_params._playerUnit)
    end

    return ctld.reconShowTargetsInLosOnF10Map(_params._playerUnit, _params._searchRadius, _params._markRadius) -- returns TargetsInLOS table
end

--- test ------------------------------------------------------
--local unitName = "uh2-1"                    --"uh1-1"    --"uh2-1"
--ctld.reconShowTargetsInLosOnF10Map(Unit.getByName(unitName),2000,200)
