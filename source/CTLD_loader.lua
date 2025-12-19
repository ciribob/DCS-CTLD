--[[ ---- Dynamic CTLD_Loader.lua ----------------------------------------------------------------
Dynamic CTLD loading is designed to streamline the CTLD developer workflow.
It does not allow CTLD code to be embedded directly into the mission's .miz file.
Therefore, it is not a suitable method for deploying standalone .miz files.

It is an alternative to static loading via a "DO SCRIPT FILE" trigger,
which allows for the deployment of standalone .miz files containing CTLD.

To use the dynamic CTLD in a mission :
> download the entire CTLD pack on https://github.com/ciribob/DCS-CTLD ,
> paste it in your "Saved Games" folder (e.g : "C:/Users/[yourUserName]/Saved Games/DCS.openbeta/Scripts/CTLD/") or anywhere else
> add to your mission an "EXECUTE SCRIPT" trigger at start mission
> copy/paste the small script below,
> replace the path of the ctld.path variable with the CTLD folder path on your computer:

Each time ou run (LShift + R) the mission CTLD files are relaoded dynamically

--- script to load CTLD in mission editor ------------------------------------------------
if ctld == nil then ctld = {}; end
ctld.path = "F:\\Temp\\CTLD\\"  -- replace with your CTLD folder path
dofile(ctld.path .. "source\\CTLD_loader.lua")
----- end of script ---------------------------------------------------------------------- ]] --
-- CTLD Loader  ------------------------------------
if ctld.path then
	ctld.path = ctld.path .. "source/"
	local loadMsg = false -- true to enable load messages
	if loadMsg then trigger.action.outText("CTLD loader START !", 10) end
	local m = 0
	-----------------------------------------------------------------------
	dofile(ctld.path .. "CTLD-i18n.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD-i18n.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_beacon.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_beacon.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_menus.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_menus.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_jtac.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_jtac.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_recon.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_recon.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_core.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_core.lua Loaded", 10)
	end
	dofile(ctld.path .. "CTLD_utils.lua")
	if loadMsg then
		m = m + 1
		trigger.action.outText(tostring(m) .. ": CTLD_utils.lua Loaded", 10)
	end

	if loadMsg then trigger.action.outText("CTLD loader END -> CTLD loaded", 10) end
else
	trigger.action.outText("No ctld.path found -> CTLD Not loaded !", 10)
end
