-- Adds menuitem to a human unit
function ctld.addTransportF10MenuOptions(_unitName)
    ctld.logDebug("ctld.addTransportF10MenuOptions(_unitName=[%s])", ctld.p(_unitName))
    local _unit = ctld.getTransportUnit(_unitName)
    ctld.logTrace("_unit = %s", ctld.p(_unit))

    if _unit then
        local _unitTypename = _unit:getTypeName()
        local _groupId = ctld.utils.getGroupId("ctld.addTransportF10MenuOptions()", _unit)
        if _groupId then
            -- ctld.logTrace("_groupId = %s", ctld.p(_groupId))
            -- ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo[tostring(_groupId)]))
            if ctld.addedTo[tostring(_groupId)] == nil then
                ctld.logTrace("adding CTLD menu for _groupId = %s", ctld.p(_groupId))
                local _rootPath = missionCommands.addSubMenuForGroup(_groupId, ctld.i18n_translate("CTLD"))
                local _unitActions = ctld.getUnitActions(_unitTypename)
                missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Check Cargo"), _rootPath,
                    ctld.checkTroopStatus, { _unitName })
                if _unitActions.troops then
                    local _troopCommandsPath = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Troop Transport"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unload / Extract Troops"),
                        _troopCommandsPath, ctld.unloadExtractTroops, { _unitName })

                    -- local _loadPath = missionCommands.addSubMenuForGroup(_groupId, "Load From Zone", _troopCommandsPath)
                    local _transportLimit = ctld.getTransportLimit(_unitTypename)
                    local itemNb = 0
                    local menuEntries = {}
                    local menuPath = _troopCommandsPath
                    for _, _loadGroup in pairs(ctld.loadableGroups) do
                        if not _loadGroup.side or _loadGroup.side == _unit:getCoalition() then
                            -- check size & unit
                            if _transportLimit >= _loadGroup.total then
                                table.insert(menuEntries,
                                    { text = ctld.i18n_translate("Load ") .. _loadGroup.name, group = _loadGroup })
                            end
                        end
                    end
                    for _i, _menu in ipairs(menuEntries) do
                        -- add the menu item
                        itemNb = itemNb + 1
                        if itemNb == 9 and _i < #menuEntries then -- page limit reached (first item is "unload")
                            menuPath = missionCommands.addSubMenuForGroup(_groupId, ctld.i18n_translate("Next page"),
                                menuPath)
                            itemNb = 1
                        end
                        missionCommands.addCommandForGroup(_groupId, _menu.text, menuPath, ctld.loadTroopsFromZone,
                            { _unitName, true, _menu.group, false })
                    end
                    if ctld.unitCanCarryVehicles(_unit) then
                        local _vehicleCommandsPath = missionCommands.addSubMenuForGroup(_groupId,
                            ctld.i18n_translate("Vehicle / FOB Transport"), _rootPath)
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unload Vehicles"),
                            _vehicleCommandsPath, ctld.unloadTroops, { _unitName, false })
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Load / Extract Vehicles"),
                            _vehicleCommandsPath, ctld.loadTroopsFromZone, { _unitName, false, "", true })

                        if ctld.enabledFOBBuilding and ctld.staticBugWorkaround == false then
                            missionCommands.addCommandForGroup(_groupId,
                                ctld.i18n_translate("Load / Unload FOB Crate"), _vehicleCommandsPath,
                                ctld.loadUnloadFOBCrate, { _unitName, false })
                        end
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Check Cargo"),
                            _vehicleCommandsPath, ctld.checkTroopStatus, { _unitName })
                    end
                end

                if ctld.enableCrates and _unitActions.crates then
                    if ctld.unitCanCarryVehicles(_unit) == false then
                        -- sort the crate categories alphabetically
                        local crateCategories = {}
                        for category, _ in pairs(ctld.spawnableCrates) do
                            table.insert(crateCategories, category)
                        end
                        table.sort(crateCategories)
                        --ctld.logTrace("crateCategories = [%s]", ctld.p(crateCategories))

                        -- add menu for spawning crates
                        local itemNbMain = 0
                        local _cratesMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                            ctld.i18n_translate("Crates: Vehicle / FOB / Drone"), _rootPath)

                        for _i, _category in ipairs(crateCategories) do
                            local _subMenuName = _category
                            local _crates = ctld.spawnableCrates[_subMenuName]

                            -- add the submenu item
                            itemNbMain = itemNbMain + 1
                            if itemNbMain == 10 and _i < #crateCategories then -- page limit reached
                                _cratesMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                                    ctld.i18n_translate("Next page"), _cratesMenuPath)
                                itemNbMain = 1
                            end
                            local itemNbSubmenu = 0
                            local menuEntries = {}
                            local _subMenuPath = missionCommands.addSubMenuForGroup(_groupId, _subMenuName,
                                _cratesMenuPath)
                            for _, _crate in pairs(_crates) do
                                --ctld.logTrace("_crate = [%s]", ctld.p(_crate))
                                if not (_crate.multiple) or ctld.enableAllCrates then
                                    local isJTAC = ctld.isJTACUnitType(_crate.unit)
                                    --ctld.logTrace("isJTAC = [%s]", ctld.p(isJTAC))
                                    if not isJTAC or (isJTAC and ctld.JTAC_dropEnabled) then
                                        if _crate.side == nil or (_crate.side == _unit:getCoalition()) then
                                            local _crateRadioMsg = _crate.desc
                                            --add in the number of crates required to build something
                                            if _crate.cratesRequired ~= nil and _crate.cratesRequired > 1 then
                                                _crateRadioMsg = _crateRadioMsg .. " (" .. _crate.cratesRequired ..
                                                    ")"
                                            end
                                            if _crate.multiple then
                                                _crateRadioMsg = "* " .. _crateRadioMsg
                                            end
                                            local _menuEntry = { text = _crateRadioMsg, crate = _crate }
                                            --ctld.logTrace("_menuEntry = [%s]", ctld.p(_menuEntry))
                                            table.insert(menuEntries, _menuEntry)
                                        end
                                    end
                                end
                            end
                            for _i, _menu in ipairs(menuEntries) do
                                --ctld.logTrace("_menu = [%s]", ctld.p(_menu))
                                -- add the submenu item
                                itemNbSubmenu = itemNbSubmenu + 1
                                if itemNbSubmenu == 10 and _i < #menuEntries then -- page limit reached
                                    _subMenuPath = missionCommands.addSubMenuForGroup(_groupId,
                                        ctld.i18n_translate("Next page"), _subMenuPath)
                                    itemNbSubmenu = 1
                                end
                                missionCommands.addCommandForGroup(_groupId, _menu.text, _subMenuPath,
                                    ctld.spawnCrate, { _unitName, _menu.crate.weight })
                            end
                        end
                    end
                end

                if (ctld.enabledFOBBuilding or ctld.enableCrates) and _unitActions.crates then
                    local _crateCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("CTLD Commands"), _rootPath)
                    if ctld.vehicleCommandsPath[_unitName] == nil then
                        ctld.vehicleCommandsPath[_unitName] = ctld.utils.deepCopy(
                            "ctld.addTransportF10MenuOptions()", _crateCommands)
                    end
                    if ctld.hoverPickup == false or ctld.loadCrateFromMenu == true then
                        if ctld.loadCrateFromMenu then
                            missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Load Nearby Crate(s)"),
                                _crateCommands, ctld.loadNearbyCrate, _unitName)
                        end
                    end

                    if ctld.loadCrateFromMenu or ctld.hoverPickup then
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Crate(s)"),
                            _crateCommands, ctld.dropSlingCrate, { _unitName })
                    end

                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Unpack Any Crate"),
                        _crateCommands, ctld.unpackCrates, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Nearby Crates"),
                        _crateCommands, ctld.listNearbyCrates, { _unitName })

                    if ctld.enabledFOBBuilding then
                        missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List FOBs"), _crateCommands,
                            ctld.listFOBS, { _unitName })
                    end

                    if ctld.enableRepackingVehicles == true then
                        ctld.updateRepackMenu(_unitName) -- add repack menu
                    end
                end

                if ctld.enableSmokeDrop then
                    local _smokeMenu = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Smoke Markers"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Red Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Blue Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Orange Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Green Smoke"), _smokeMenu,
                        ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
                end

                if ctld.enabledRadioBeaconDrop then
                    local _radioCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Radio Beacons"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Beacons"), _radioCommands,
                        ctld.listRadioBeacons, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Drop Beacon"), _radioCommands,
                        ctld.dropRadioBeacon, { _unitName })
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("Remove Closest Beacon"),
                        _radioCommands, ctld.removeRadioBeacon, { _unitName })
                elseif ctld.deployedRadioBeacons ~= {} then
                    local _radioCommands = missionCommands.addSubMenuForGroup(_groupId,
                        ctld.i18n_translate("Radio Beacons"), _rootPath)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Beacons"), _radioCommands,
                        ctld.listRadioBeacons, { _unitName })
                end

                ctld.addedTo[tostring(_groupId)] = true
                ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo))
                ctld.logTrace("done adding CTLD menu for _groupId = %s", ctld.p(_groupId))
            end
        end
    end
end

--******************************************************************************************************
function ctld.buildPaginatedMenu(_menuEntries) --[[ params table :
                                                    { text        = command name menu
                                                    groupId       = playerUnit groupId,
                                                    subMenuPath   = complet MenuPath clicked,
                                                    menuFunction  = function name to run on clicked menu,
                                                    menuArgsTable = table with arguments for the function to run,
                                                    }]]
    local nextSubMenuPath = {}
    local itemNbSubmenu   = 0
    for i, menu in ipairs(_menuEntries) do
        if #nextSubMenuPath ~= 0 then
            menu.subMenuPath = ctld.utils.deepCopy("ctld.buildPaginatedMenu()", nextSubMenuPath)
            --menu.subMenuPath = nextSubMenuPath
        end
        -- add the submenu item
        itemNbSubmenu = itemNbSubmenu + 1
        if itemNbSubmenu == 10 and i < #_menuEntries then -- page limit reached
            nextSubMenuPath = missionCommands.addSubMenuForGroup(menu.groupId, ctld.i18n_translate("Next page"),
                menu.subMenuPath)
            itemNbSubmenu   = 1
        end
        menu.menuArgsTable.subMenuPath      = ctld.utils.deepCopy("ctld.buildPaginatedMenu()", menu.subMenuPath) -- copy the table to avoid overwriting the same table in the next loop
        menu.menuArgsTable.subMenuLineIndex = itemNbSubmenu
        --ctld.logTrace("FG_ boucle[%s].groupId = %s", i, menu.groupId)
        --ctld.logTrace("FG_ boucle[%s].menu.text = %s", i, menu.text)
        --ctld.logTrace("FG_ boucle[%s].menu.subMenuPath = %s", i, menu.subMenuPath)
        --ctld.logTrace("FG_ boucle[%s].menu.menuFunction = %s", i, menu.menuFunction)
        local r                             = missionCommands.addCommandForGroup(menu.groupId, menu.text,
            menu.subMenuPath, menu.menuFunction,
            ctld.utils.deepCopy("ctld.buildPaginatedMenu()", menu.menuArgsTable))
        --ctld.logTrace("FG_ boucle[%s].r = %s", i, r)
        --ctld.logTrace("FG_ boucle[%s].menu.menuArgsTable =  %s", i, ctld.p(menu.menuArgsTable))
    end
end

--******************************************************************************************************
-- return true if  _typeUnitDesc already exist in _MenuEntriesTable
-- ex:  ctld.isUnitInrepackableVehicles(repackableTable, "Humvee - TOW")
function ctld.isUnitInMenuEntriesTable(_MenuEntriesTable, _typeUnitDesc)
    for i = 1, #_MenuEntriesTable do
        if _MenuEntriesTable[i].menuArgsTable.desc == _typeUnitDesc then
            return true
        end
    end
    return false
end

--******************************************************************************************************
function ctld.updateRepackMenu(_playerUnitName)
    local playerUnit = ctld.getTransportUnit(_playerUnitName)
    if playerUnit then
        local _groupId = ctld.utils.getGroupId("ctld.updateRepackMenu()", playerUnit)
        if _groupId == nil then
            return
        end
        if ctld.enableRepackingVehicles then
            local repackableVehicles = ctld.getUnitsInRepackRadius(_playerUnitName,
                ctld.maximumDistanceRepackableUnitsSearch)
            if repackableVehicles then
                --ctld.logTrace("FG_ ctld.vehicleCommandsPath[_playerUnitName] = %s", ctld.p(ctld.vehicleCommandsPath[_playerUnitName]))
                local RepackPreviousMenu                    = ctld.utils.deepCopy("ctld.updateRepackMenu()",
                    ctld.vehicleCommandsPath
                    [_playerUnitName])
                local RepackCommandsPath                    = ctld.utils.deepCopy("ctld.updateRepackMenu()",
                    ctld.vehicleCommandsPath
                    [_playerUnitName])
                local repackSubMenuText                     = ctld.i18n_translate("Repack Vehicles")
                RepackCommandsPath[#RepackCommandsPath + 1] =
                    repackSubMenuText                                            -- add the submenu name to get the complet repack path
                --ctld.logTrace("FG_ RepackCommandsPath = %s", ctld.p(RepackCommandsPath))
                missionCommands.removeItemForGroup(_groupId, RepackCommandsPath) -- remove existing "Repack Vehicles" menu
                --ctld.logTrace("FG_ RepackCommandsPath = %s", ctld.p(RepackCommandsPath))
                --ctld.logTrace("FG_ repackableVehicles = %s", ctld.p(repackableVehicles))
                --ctld.logTrace("FG_ repackSubMenuText  = %s", ctld.p(repackSubMenuText))
                --ctld.logTrace("FG_ RepackPreviousMenu = %s", ctld.p(RepackPreviousMenu))
                local RepackMenuPath = missionCommands.addSubMenuForGroup(_groupId, repackSubMenuText, RepackPreviousMenu)
                local menuEntries = {}
                for i, _vehicle in ipairs(repackableVehicles) do
                    if ctld.isUnitInMenuEntriesTable(menuEntries, _vehicle.desc) == false then
                        _vehicle.playerUnitName = _playerUnitName
                        table.insert(menuEntries, {
                            text          = ctld.i18n_translate("repack ") .. _vehicle.unit,
                            groupId       = _groupId,
                            subMenuPath   = RepackMenuPath,
                            menuFunction  = ctld.repackVehicleRequest,
                            menuArgsTable = ctld.utils.deepCopy("ctld.updateRepackMenu()", _vehicle)
                        })
                    end
                end
                --ctld.logTrace("FG_ menuEntries = %s", ctld.p(menuEntries))
                ctld.buildPaginatedMenu(menuEntries)
            end
        end
    end
end

--******************************************************************************************************
function ctld.autoUpdateRepackMenu(p, t) -- auto update repack menus for each transport unit
    if t == nil then t = timer.getTime() end
    if p.reschedule == nil then p.reschedule = false end
    ctld.logTrace("FG_ ctld.autoUpdateRepackMenu.p.reschedule = %s", p.reschedule)
    if ctld.enableRepackingVehicles then
        for _, _unitName in pairs(ctld.transportPilotNames) do
            if ctld.vehicleCommandsPath[_unitName] ~= nil then
                local status, error = pcall(
                    function()
                        local _unit = ctld.getTransportUnit(_unitName)
                        if _unit then
                            -- if transport unit landed => update repack menus
                            if (ctld.inAir(_unit) == false or (ctld.heightDiff(_unit) <= 0.1 + 3.0 and ctld.utils.vec3Mag("ctld.autoUpdateRepackMenu()", _unit:getVelocity()) < 0.1)) then
                                local _unitTypename = _unit:getTypeName()
                                local _groupId = ctld.utils.getGroupId("ctld.autoUpdateRepackMenu()", _unit)
                                if _groupId then
                                    if ctld.addedTo[tostring(_groupId)] ~= nil then -- if groupMenu on loaded => add RepackMenus
                                        ctld.updateRepackMenu(_unitName)
                                    end
                                end
                            end
                        end
                    end)
                if (not status) then
                    env.error(string.format("Error in ctld.autoUpdateRepackMenu : %s", error), false)
                end
            end
        end
    end
    if p.reschedule == true or p.reschedule == nil then
        return t + 5 -- reschedule every 5 seconds
    end
end

--******************************************************************************************************
function ctld.addOtherF10MenuOptions()
    --ctld.logDebug("ctld.addOtherF10MenuOptions")
    -- reschedule every 10 seconds
    timer.scheduleFunction(ctld.addOtherF10MenuOptions, nil, timer.getTime() + 10)
    local status, error = pcall(function()
        -- now do any player controlled aircraft that ARENT transport units
        if ctld.enabledRadioBeaconDrop then
            ctld.addRadioListCommand(2) -- get all BLUE players
            ctld.addRadioListCommand(1) -- get all RED players
        end

        if ctld.JTAC_jtacStatusF10 then
            ctld.addJTACRadioCommand(2) -- get all BLUE players
            ctld.addJTACRadioCommand(1) -- get all RED players
        end

        if ctld.reconF10Menu then
            ctld.addReconRadioCommand(2) -- get all BLUE players
            ctld.addReconRadioCommand(1) -- get all RED players
        end
    end)

    if (not status) then
        env.error(string.format("Error adding f10 to other players: %s", error), false)
    end
end

--add to all players that arent transport
function ctld.addRadioListCommand(_side)
    local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
            local _groupId = ctld.utils.getGroupId("ctld.addOtherF10MenuOptions()", _playerUnit)

            if _groupId then
                --ctld.logTrace("ctld.addedTo = %s", ctld.p(ctld.addedTo))
                if ctld.addedTo[tostring(_groupId)] == nil then
                    ctld.logTrace("adding List Radio Beacons for _groupId = %s", ctld.p(_groupId))
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("List Radio Beacons"), nil,
                        ctld.listRadioBeacons, { _playerUnit:getName() })
                    ctld.addedTo[tostring(_groupId)] = true
                end
            end
        end
    end
end

function ctld.addJTACRadioCommand(_side)
    local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
            local _groupId = ctld.utils.getGroupId("ctld.addJTACRadioCommand()", _playerUnit)

            if _groupId then
                local newGroup = false
                if ctld.jtacRadioAdded[tostring(_groupId)] == nil then
                    --ctld.logDebug("ctld.addJTACRadioCommand - adding JTAC radio menu for unit [%s]", ctld.p(_playerUnit:getName()))
                    newGroup = true
                    local JTACpath = missionCommands.addSubMenuForGroup(_groupId, ctld.jtacMenuName)
                    missionCommands.addCommandForGroup(_groupId, ctld.i18n_translate("JTAC Status"), JTACpath,
                        ctld.getJTACStatus, { _playerUnit:getName() })
                    ctld.jtacRadioAdded[tostring(_groupId)] = true
                end

                --fetch the time to check for a regular refresh
                local time = timer.getTime()

                --depending on the delay, this part of the radio menu will be refreshed less often or as often as the static JTAC status command, this is for better reliability for the user when navigating through the menus. New groups will get the lists regardless and if a new JTAC is added all lists will be refreshed regardless of the delay.
                if ctld.jtacLastRadioRefresh + ctld.jtacRadioRefreshDelay <= time or ctld.refreshJTACmenu[_side] or newGroup then
                    ctld.jtacLastRadioRefresh = time

                    --build the path to the CTLD JTAC menu
                    local jtacCurrentPagePath = { [1] = ctld.jtacMenuName }
                    --build the path for the NextPage submenu on the first page of the CTLD JTAC menu
                    local NextPageText = "Next Page"
                    local MainNextPagePath = { [1] = ctld.jtacMenuName, [2] = NextPageText }
                    --remove it along with everything that's in it
                    missionCommands.removeItemForGroup(_groupId, MainNextPagePath)

                    --counter to know when to add the next page submenu to fit all of the JTAC group submenus
                    local jtacCounter = 0

                    for _jtacGroupName, jtacUnit in pairs(ctld.jtacUnits) do
                        --ctld.logTrace(string.format("JTAC - MENU - [%s] - processing menu", ctld.p(_jtacGroupName)))

                        --if the JTAC is on the same team as the group being considered
                        local jtacCoalition = ctld.jtacUnits[_jtacGroupName].side
                        if jtacCoalition and jtacCoalition == _side then
                            --only bother removing the submenus on the first page of the CTLD JTAC menu as the other pages were deleted entirely above
                            if ctld.jtacGroupSubMenuPath[_jtacGroupName] and #ctld.jtacGroupSubMenuPath[_jtacGroupName] == 2 then
                                missionCommands.removeItemForGroup(_groupId, ctld.jtacGroupSubMenuPath[_jtacGroupName])
                            end
                            --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacTargetsList = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacTargetsList[_jtacGroupName])))
                            --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacCurrentTargets = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacCurrentTargets[_jtacGroupName])))

                            local jtacActionMenu = false
                            for _, _specialOptionTable in pairs(ctld.jtacSpecialOptions) do
                                if _specialOptionTable.globalToggle then
                                    jtacActionMenu = true
                                    break
                                end
                            end

                            --if JTAC has at least one other target in sight or (if special options are available (NOTE : accessed through the JTAC's own menu also) and the JTAC has at least one target)
                            if (ctld.jtacTargetsList[_jtacGroupName] and #ctld.jtacTargetsList[_jtacGroupName] >= 1) or (ctld.jtacCurrentTargets[_jtacGroupName] and jtacActionMenu) then
                                local jtacGroupSubMenuName = string.format(_jtacGroupName .. " Selection")

                                jtacCounter = jtacCounter + 1
                                --F2 through F10 makes 9 entries possible per page, with one being the NextMenu submenu. F1 is taken by JTAC status entry.
                                if jtacCounter % 9 == 0 then
                                    --recover the path to the current page with space available for JTAC group submenus
                                    jtacCurrentPagePath = missionCommands.addSubMenuForGroup(_groupId, NextPageText,
                                        jtacCurrentPagePath)
                                end
                                --add the JTAC group submenu to the current page
                                ctld.jtacGroupSubMenuPath[_jtacGroupName] = missionCommands.addSubMenuForGroup(_groupId,
                                    jtacGroupSubMenuName, jtacCurrentPagePath)
                                --ctld.logTrace(string.format("JTAC - MENU - [%s] - jtacGroupSubMenuPath = %s", ctld.p(_jtacGroupName), ctld.p(ctld.jtacGroupSubMenuPath[_jtacGroupName])))

                                --make a copy of the JTAC group submenu's path to insert the target's list on as many pages as required. The JTAC's group submenu path only leads to the first page
                                local jtacTargetPagePath = ctld.utils.deepCopy("ctld.addJTACRadioCommand()",
                                    ctld.jtacGroupSubMenuPath[_jtacGroupName])

                                --counter to know when to add the next page submenu to fit all of the targets in the JTAC's group submenu. SMay not actually start at 0 due to static items being present on the first page
                                local itemCounter = 0
                                local jtacSpecialOptPagePath = nil

                                if jtacActionMenu then
                                    --special options
                                    local SpecialOptionsCounter = 0

                                    for _, _specialOption in pairs(ctld.jtacSpecialOptions) do
                                        if _specialOption.globalToggle then
                                            if not jtacSpecialOptPagePath then
                                                itemCounter = itemCounter +
                                                    1 --one item is added to the first JTAC target page
                                                jtacSpecialOptPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                    ctld.i18n_translate("Actions"), jtacTargetPagePath)
                                            end

                                            SpecialOptionsCounter = SpecialOptionsCounter + 1

                                            if SpecialOptionsCounter % 10 == 0 then
                                                jtacSpecialOptPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                    NextPageText, jtacSpecialOptPagePath)
                                                SpecialOptionsCounter = SpecialOptionsCounter +
                                                    1 --Added Next Page item
                                            end

                                            if _specialOption.jtacs then
                                                if _specialOption.jtacs[_jtacGroupName] then
                                                    missionCommands.addCommandForGroup(_groupId,
                                                        ctld.i18n_translate("DISABLE ") .. _specialOption.message,
                                                        jtacSpecialOptPagePath, _specialOption.setter,
                                                        { jtacGroupName = _jtacGroupName, value = false })
                                                else
                                                    missionCommands.addCommandForGroup(_groupId,
                                                        ctld.i18n_translate("ENABLE ") .. _specialOption.message,
                                                        jtacSpecialOptPagePath, _specialOption.setter,
                                                        { jtacGroupName = _jtacGroupName, value = true })
                                                end
                                            else
                                                missionCommands.addCommandForGroup(_groupId,
                                                    ctld.i18n_translate("REQUEST ") .. _specialOption.message,
                                                    jtacSpecialOptPagePath, _specialOption.setter,
                                                    { jtacGroupName = _jtacGroupName, value = false }) --value is not used here
                                            end
                                        end
                                    end
                                end

                                if #ctld.jtacTargetsList[_jtacGroupName] >= 1 then
                                    --ctld.logTrace(string.format("JTAC - MENU - [%s] - adding targets menu", ctld.p(_jtacGroupName)))

                                    --add a reset targeting option to revert to automatic JTAC unit targeting
                                    missionCommands.addCommandForGroup(_groupId,
                                        ctld.i18n_translate("Reset TGT Selection"), jtacTargetPagePath,
                                        ctld.setJTACTarget, { jtacGroupName = _jtacGroupName, targetName = nil })

                                    itemCounter = itemCounter +
                                        1 --one item is added to the first JTAC target page

                                    --indicator table to know which unitType was already added to the radio submenu
                                    local typeNameList = {}
                                    for _, target in pairs(ctld.jtacTargetsList[_jtacGroupName]) do
                                        local targetName = target.unit:getName()
                                        --check if the jtac has a current target before filtering it out if possible
                                        if (ctld.jtacCurrentTargets[_jtacGroupName] and targetName ~= ctld.jtacCurrentTargets[_jtacGroupName].name) then
                                            local targetType_name = target.unit:getTypeName()

                                            if targetType_name then
                                                if typeNameList[targetType_name] then
                                                    typeNameList[targetType_name].amount = typeNameList[targetType_name]
                                                        .amount + 1
                                                else
                                                    typeNameList[targetType_name] = {}
                                                    typeNameList[targetType_name].targetName =
                                                        targetName --store the first targetName
                                                    typeNameList[targetType_name].amount = 1
                                                end
                                            end
                                        end
                                    end

                                    for typeName, info in pairs(typeNameList) do
                                        local amount = info.amount
                                        local targetName = info.targetName
                                        itemCounter = itemCounter + 1

                                        --F1 through F10 makes 10 entries possible per page, with one being the NextMenu submenu.
                                        if itemCounter % 10 == 0 then
                                            jtacTargetPagePath = missionCommands.addSubMenuForGroup(_groupId,
                                                NextPageText, jtacTargetPagePath)
                                            itemCounter = itemCounter +
                                                1 --added the next page item
                                        end

                                        missionCommands.addCommandForGroup(_groupId,
                                            string.format(typeName .. "(" .. amount .. ")"), jtacTargetPagePath,
                                            ctld.setJTACTarget,
                                            { jtacGroupName = _jtacGroupName, targetName = targetName })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if ctld.refreshJTACmenu[_side] then
            ctld.refreshJTACmenu[_side] = false
        end
    end
end
