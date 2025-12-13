--[[ ---- CTLD_Loader.lua ----------------------------------------------------------------
To use the CTLD in a mission :
> download the entire CTLD pack on https://github.com/ciribob/DCS-CTLD ,
> paste it in your "Saved Games" folder (e.g : "C:/Users/[yourUserName]/Saved Games/DCS.openbeta/Scripts/CTLD/")
> add to your mission an "EXECUTE SCRIPT" trigger at start mission
> copy/paste the small script below,
> replace the path of the ctld.path variable with the "Saved Games" folder path on your computer:

--- script to load CTLD in mission editor ------------------------------------------------
if not ctld then ctld = {} end
ctld.path = "C:/Users/toto/Saved Games/DCS.openbeta/Scripts/CTLD/"  -- replace with your Saved Games path
dofile(ctld.path .. "source/CTLD_Loader.lua")
----- end of script ---------------------------------------------------------------------- ]] --

-- CTLD Loader  ------------------------------------
if ctld.path then
	ctld.path = ctld.path .. "source/"
	local loadMsg = false -- true to enable load messages
	if loadMsg then trigger.action.outText("CTLD loader START !", 10) end
	local m = 0
	dofile(ctld.path .. "mist.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": mist.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_extAPI.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_extAPI.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD-i18n.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD-i18n.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_utils.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_utils.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_DCSWeaponsDb.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_DCSWeaponsDb.lua Loaded",
			10)
	end

	-- Scenes datas and Classes
	dofile(ctld.path .. "dcsObjectsDescDb.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": dcsObjectsDescDb.lua Loaded", 10);
	end
	dofile(ctld.path .. "CTLD_scene.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_scene.lua Loaded", 10);
	end
	dofile(ctld.path .. "farpSceneDatas.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": farpSceneDatas.lua Loaded", 10);
	end
	dofile(ctld.path .. "mineFieldSceneDatas.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": mineFieldSceneDatas.lua Loaded", 10);
	end
	if loadMsg then trigger.action.outText("CTLD loader END -> CTLD loaded", 10) end
else
	trigger.action.outText("No ctld.path found -> CTLD Not loaded !", 10)
end
