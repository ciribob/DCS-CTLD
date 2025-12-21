 
-- ==================================================================================================== 
-- Start : CTLD_i18n.lua 
--[[
    Combat Troop and Logistics Drop - Internationalization (I18N) - EnglishFrench, Spanish and Korean translations

    Dear translators: find the english version in the main CTLD.lua file (it's called `ctld.i18n["en"]`) and use it as a template to build your translation.

    Hall of fame:
    - FullGas1 (concept, FR and ES translations)
    - rising_star (KO translation)
]]
if not ctld then ctld = {} end -- DONT REMOVE!
ctld.i18n = {}

-- These are the string translations
-- If you want to change the text then do so here
-- If you want to add a new language then create a new block
-- following the same format as the current ones

-- ***************************************************************
-- *************** Internationalization (I18N) *******************
-- ***************************************************************

-- If you want to change the language replace "en" with the language you want to use

--========    ENGLISH - the reference ===========================================================================
ctld.i18n_lang = "en"
--========    FRENCH - FRANCAIS =================================================================================
--ctld.i18n_lang = "fr"
--======    SPANISH : ESPAÑOL ====================================================================================
--ctld.i18n_lang = "es"
--======    Korean : 한국어 ====================================================================================
--ctld.i18n_lang = "ko"

if not ctld.i18n then -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    ctld.i18n = {}    -- DONT REMOVE!
end

-- This is the default language
-- If a string is not found in the current language then it will default to this language
-- Note that no translation is provided for this language (obviously) but that we'll maintain this table to help the translators.
ctld.i18n["en"] = {}
ctld.i18n["en"].translation_version =
"1.6" -- make sure that all the translations are compatible with this version of the english language texts
local lang = "en"; env.info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
    tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["en"]["Standard Group"] = ""
ctld.i18n["en"]["Anti Air"] = ""
ctld.i18n["en"]["Anti Tank"] = ""
ctld.i18n["en"]["Mortar Squad"] = ""
ctld.i18n["en"]["JTAC Group"] = ""
ctld.i18n["en"]["Single JTAC"] = ""
ctld.i18n["en"]["2x - Standard Groups"] = ""
ctld.i18n["en"]["2x - Anti Air"] = ""
ctld.i18n["en"]["2x - Anti Tank"] = ""
ctld.i18n["en"]["2x - Standard Groups + 2x Mortar"] = ""
ctld.i18n["en"]["3x - Standard Groups"] = ""
ctld.i18n["en"]["3x - Anti Air"] = ""
ctld.i18n["en"]["3x - Anti Tank"] = ""
ctld.i18n["en"]["3x - Mortar Squad"] = ""
ctld.i18n["en"]["5x - Mortar Squad"] = ""
ctld.i18n["en"]["Mortar Squad Red"] = ""

--- crates names
ctld.i18n["en"]["Humvee - MG"] = ""
ctld.i18n["en"]["Humvee - TOW"] = ""
ctld.i18n["en"]["Light Tank - MRAP"] = ""
ctld.i18n["en"]["Med Tank - LAV-25"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams"] = ""
ctld.i18n["en"]["BTR-D"] = ""
ctld.i18n["en"]["BRDM-2"] = ""
ctld.i18n["en"]["Hummer - JTAC"] = ""
ctld.i18n["en"]["M-818 Ammo Truck"] = ""
ctld.i18n["en"]["M-978 Tanker"] = ""
ctld.i18n["en"]["SKP-11 - JTAC"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck"] = ""
ctld.i18n["en"]["KAMAZ Ammo Truck"] = ""
ctld.i18n["en"]["EWR Radar"] = ""
ctld.i18n["en"]["FOB Crate - Small"] = ""
ctld.i18n["en"]["MQ-9 Repear - JTAC"] = ""
ctld.i18n["en"]["RQ-1A Predator - JTAC"] = ""
ctld.i18n["en"]["MLRS"] = ""
ctld.i18n["en"]["SpGH DANA"] = ""
ctld.i18n["en"]["T155 Firtina"] = ""
ctld.i18n["en"]["Howitzer"] = ""
ctld.i18n["en"]["SPH 2S19 Msta"] = ""
ctld.i18n["en"]["M1097 Avenger"] = ""
ctld.i18n["en"]["M48 Chaparral"] = ""
ctld.i18n["en"]["Roland ADS"] = ""
ctld.i18n["en"]["Gepard AAA"] = ""
ctld.i18n["en"]["LPWS C-RAM"] = ""
ctld.i18n["en"]["9K33 Osa"] = ""
ctld.i18n["en"]["9P31 Strela-1"] = ""
ctld.i18n["en"]["9K35M Strela-10"] = ""
ctld.i18n["en"]["9K331 Tor"] = ""
ctld.i18n["en"]["2K22 Tunguska"] = ""
ctld.i18n["en"]["HAWK Launcher"] = ""
ctld.i18n["en"]["HAWK Search Radar"] = ""
ctld.i18n["en"]["HAWK Track Radar"] = ""
ctld.i18n["en"]["HAWK PCP"] = ""
ctld.i18n["en"]["HAWK CWAR"] = ""
ctld.i18n["en"]["HAWK Repair"] = ""
ctld.i18n["en"]["NASAMS Launcher 120C"] = ""
ctld.i18n["en"]["NASAMS Search/Track Radar"] = ""
ctld.i18n["en"]["NASAMS Command Post"] = ""
ctld.i18n["en"]["NASAMS Repair"] = ""
ctld.i18n["en"]["KUB Launcher"] = ""
ctld.i18n["en"]["KUB Radar"] = ""
ctld.i18n["en"]["KUB Repair"] = ""
ctld.i18n["en"]["BUK Launcher"] = ""
ctld.i18n["en"]["BUK Search Radar"] = ""
ctld.i18n["en"]["BUK CC Radar"] = ""
ctld.i18n["en"]["BUK Repair"] = ""
ctld.i18n["en"]["Patriot Launcher"] = ""
ctld.i18n["en"]["Patriot Radar"] = ""
ctld.i18n["en"]["Patriot ECS"] = ""
ctld.i18n["en"]["Patriot ICC"] = ""
ctld.i18n["en"]["Patriot EPP"] = ""
ctld.i18n["en"]["Patriot AMG (optional)"] = ""
ctld.i18n["en"]["Patriot Repair"] = ""
ctld.i18n["en"]["S-300 Grumble TEL C"] = ""
ctld.i18n["en"]["S-300 Grumble Flap Lid-A TR"] = ""
ctld.i18n["en"]["S-300 Grumble Clam Shell SR"] = ""
ctld.i18n["en"]["S-300 Grumble Big Bird SR"] = ""
ctld.i18n["en"]["S-300 Grumble C2"] = ""
ctld.i18n["en"]["S-300 Repair"] = ""
ctld.i18n["en"]["Humvee - TOW - All crates"] = ""
ctld.i18n["en"]["Light Tank - MRAP - All crates"] = ""
ctld.i18n["en"]["Med Tank - LAV-25 - All crates"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams - All crates"] = ""
ctld.i18n["en"]["Hummer - JTAC - All crates"] = ""
ctld.i18n["en"]["M-818 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["M-978 Tanker - All crates"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["EWR Radar - All crates"] = ""
ctld.i18n["en"]["MLRS - All crates"] = ""
ctld.i18n["en"]["SpGH DANA - All crates"] = ""
ctld.i18n["en"]["T155 Firtina - All crates"] = ""
ctld.i18n["en"]["Howitzer - All crates"] = ""
ctld.i18n["en"]["SPH 2S19 Msta - All crates"] = ""
ctld.i18n["en"]["M1097 Avenger - All crates"] = ""
ctld.i18n["en"]["M48 Chaparral - All crates"] = ""
ctld.i18n["en"]["Roland ADS - All crates"] = ""
ctld.i18n["en"]["Gepard AAA - All crates"] = ""
ctld.i18n["en"]["LPWS C-RAM - All crates"] = ""
ctld.i18n["en"]["9K33 Osa - All crates"] = ""
ctld.i18n["en"]["9P31 Strela-1 - All crates"] = ""
ctld.i18n["en"]["9K35M Strela-10 - All crates"] = ""
ctld.i18n["en"]["9K331 Tor - All crates"] = ""
ctld.i18n["en"]["2K22 Tunguska - All crates"] = ""
ctld.i18n["en"]["HAWK - All crates"] = ""
ctld.i18n["en"]["NASAMS - All crates"] = ""
ctld.i18n["en"]["KUB - All crates"] = ""
ctld.i18n["en"]["BUK - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""

--- mission design error messages
ctld.i18n["en"]["CTLD.lua ERROR: Can't find trigger called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find crate with weight %1"] = ""

--- runtime messages
ctld.i18n["en"]["You are not close enough to friendly logistics to get a crate!"] = ""
ctld.i18n["en"]["No more JTAC Crates Left!"] = ""
ctld.i18n["en"]["Sorry you must wait %1 seconds before you can get another crate"] = ""
ctld.i18n["en"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into %3"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into %3"] = ""
ctld.i18n["en"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = ""
ctld.i18n["en"]["%1 dropped vehicles from %2 into combat"] = ""
ctld.i18n["en"]["%1 loaded troops into %2"] = ""
ctld.i18n["en"]["%1 loaded %2 vehicles into %3"] = ""
ctld.i18n["en"]["%1 delivered a FOB Crate"] = ""
ctld.i18n["en"]["Delivered FOB Crate 60m at 6'oclock to you"] = ""
ctld.i18n["en"]["FOB Crate dropped back to base"] = ""
ctld.i18n["en"]["FOB Crate Loaded"] = ""
ctld.i18n["en"]["%1 loaded a FOB Crate ready for delivery!"] = ""
ctld.i18n["en"]["There are no friendly logistic units nearby to load a FOB crate from!"] = ""
ctld.i18n["en"]["This area has no more reinforcements available!"] = ""
ctld.i18n["en"]["You are not in a pickup zone and no one is nearby to extract"] = ""
ctld.i18n["en"]["You are not in a pickup zone"] = ""
ctld.i18n["en"]["No one to unload"] = ""
ctld.i18n["en"]["Dropped troops back to base"] = ""
ctld.i18n["en"]["Dropped vehicles back to base"] = ""
ctld.i18n["en"]["You already have troops onboard."] = ""
ctld.i18n["en"]["Count Infantries limit in the mission reached, you can't load more troops"] = ""
ctld.i18n["en"]["You already have vehicles onboard."] = ""
ctld.i18n["en"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = ""
ctld.i18n["en"]["%1 extracted troops in %2 from combat"] = ""
ctld.i18n["en"]["No extractable troops nearby!"] = ""
ctld.i18n["en"]["%1 extracted vehicles in %2 from combat"] = ""
ctld.i18n["en"]["No extractable vehicles nearby!"] = ""
ctld.i18n["en"]["%1 troops onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["%1 vehicles onboard (%2)\n"] = ""
ctld.i18n["en"]["1 FOB Crate oboard (%1 kg)\n"] = ""
ctld.i18n["en"]["%1 crate onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["Total weight of cargo : %1 kg\n"] = ""
ctld.i18n["en"]["No cargo."] = ""
ctld.i18n["en"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
""
ctld.i18n["en"]["Loaded %1 crate!"] = ""
ctld.i18n["en"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["You must land before you can load a crate!"] = ""
ctld.i18n["en"]["No Crates within 50m to load!"] = ""
ctld.i18n["en"]["Maximum number of crates are on board!"] = ""
ctld.i18n["en"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = ""
ctld.i18n["en"]["FOB Crate - %1 m - %2 o'clock\n"] = ""
ctld.i18n["en"]["No Nearby Crates"] = ""
ctld.i18n["en"]["Nearby Crates:\n%1"] = ""
ctld.i18n["en"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = ""
ctld.i18n["en"]["FOB Positions:"] = ""
ctld.i18n["en"]["%1\nFOB @ %2"] = ""
ctld.i18n["en"]["Sorry, there are no active FOBs!"] = ""
ctld.i18n["en"]["You can't unpack that here! Take it to where it's needed!"] = ""
ctld.i18n["en"]["Sorry you must move this crate before you unpack it!"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field"] = ""
ctld.i18n["en"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = ""
ctld.i18n["en"]["Finished building FOB! Crates and Troops can now be picked up."] = ""
ctld.i18n["en"]["Finished building FOB! Crates can now be picked up."] = ""
ctld.i18n["en"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
""
ctld.i18n["en"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
""
ctld.i18n["en"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = ""
ctld.i18n["en"]["%1 crate has been safely dropped below you"] = ""
ctld.i18n["en"]["You were too high! The crate has been destroyed"] = ""
ctld.i18n["en"]["Radio Beacons:\n%1"] = ""
ctld.i18n["en"]["No Active Radio Beacons"] = ""
ctld.i18n["en"]["%1 deployed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["You need to land before you can deploy a Radio Beacon!"] = ""
ctld.i18n["en"]["%1 removed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["No Radio Beacons within 500m."] = ""
ctld.i18n["en"]["You need to land before remove a Radio Beacon"] = ""
ctld.i18n["en"]["%1 successfully rearmed a full %2 in the field"] = ""
ctld.i18n["en"]["Missing %1\n"] = ""
ctld.i18n["en"]["Out of parts for AA Systems. Current limit is %1\n"] = ""
ctld.i18n["en"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = ""
ctld.i18n["en"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = ""
ctld.i18n["en"]["%1 successfully repaired a full %2 in the field."] = ""
ctld.i18n["en"]["Cannot repair %1. No damaged %2 within 300m"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field using %3 crates."] = ""
ctld.i18n["en"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
""
ctld.i18n["en"]["%1 dropped %2 smoke."] = ""

--- JTAC messages
ctld.i18n["en"]["JTAC Group %1 KIA!"] = ""
ctld.i18n["en"]["%1, selected target reacquired, %2"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"]["new target, "] = ""
ctld.i18n["en"]["standing by on %1"] = ""
ctld.i18n["en"]["lasing %1"] = ""
ctld.i18n["en"][", temporarily %1"] = ""
ctld.i18n["en"]["target lost"] = ""
ctld.i18n["en"]["target destroyed"] = ""
ctld.i18n["en"][", selected %1"] = ""
ctld.i18n["en"]["%1 %2 target lost."] = ""
ctld.i18n["en"]["%1 %2 target destroyed."] = ""
ctld.i18n["en"]["JTAC STATUS: \n\n"] = ""
ctld.i18n["en"][", available on %1 %2,"] = ""
ctld.i18n["en"]["UNKNOWN"] = ""
ctld.i18n["en"][" targeting "] = ""
ctld.i18n["en"][" targeting selected unit "] = ""
ctld.i18n["en"][" attempting to find selected unit, temporarily targeting "] = ""
ctld.i18n["en"]["(Laser OFF) "] = ""
ctld.i18n["en"]["Visual On: "] = ""
ctld.i18n["en"][" searching for targets %1\n"] = ""
ctld.i18n["en"]["No Active JTACs"] = ""
ctld.i18n["en"][", targeting selected unit, %1"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"][", target selection reset."] = ""
ctld.i18n["en"]["%1, laser and smokes enabled"] = ""
ctld.i18n["en"]["%1, laser and smokes disabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations enabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations disabled"] = ""
ctld.i18n["en"]["%1, WHITE smoke deployed near target"] = ""
--- F10 menu messages
ctld.i18n["en"]["Actions"] = ""
ctld.i18n["en"]["Troop Transport"] = ""
ctld.i18n["en"]["Unload / Extract Troops"] = ""
ctld.i18n["en"]["Next page"] = ""
ctld.i18n["en"]["Load "] = ""
ctld.i18n["en"]["Vehicle / FOB Transport"] = ""
ctld.i18n["en"]["Crates: Vehicle / FOB / Drone"] = ""
ctld.i18n["en"]["Unload Vehicles"] = ""
ctld.i18n["en"]["Load / Extract Vehicles"] = ""
ctld.i18n["en"]["Load / Unload FOB Crate"] = ""
ctld.i18n["en"]["Repack Vehicles"] = ""
ctld.i18n["en"]["CTLD Commands"] = ""
ctld.i18n["en"]["CTLD"] = ""
ctld.i18n["en"]["Check Cargo"] = ""
ctld.i18n["en"]["Load Nearby Crate(s)"] = ""
ctld.i18n["en"]["Unpack Any Crate"] = ""
ctld.i18n["en"]["Drop Crate(s)"] = ""
ctld.i18n["en"]["List Nearby Crates"] = ""
ctld.i18n["en"]["List FOBs"] = ""
ctld.i18n["en"]["List Beacons"] = ""
ctld.i18n["en"]["List Radio Beacons"] = ""
ctld.i18n["en"]["Smoke Markers"] = ""
ctld.i18n["en"]["Drop Red Smoke"] = ""
ctld.i18n["en"]["Drop Blue Smoke"] = ""
ctld.i18n["en"]["Drop Orange Smoke"] = ""
ctld.i18n["en"]["Drop Green Smoke"] = ""
ctld.i18n["en"]["Drop Beacon"] = ""
ctld.i18n["en"]["Radio Beacons"] = ""
ctld.i18n["en"]["Remove Closest Beacon"] = ""
ctld.i18n["en"]["JTAC Status"] = ""
ctld.i18n["en"]["DISABLE "] = ""
ctld.i18n["en"]["ENABLE "] = ""
ctld.i18n["en"]["REQUEST "] = ""
ctld.i18n["en"]["Reset TGT Selection"] = ""
-- F10 RECON menus
ctld.i18n["en"]["RECON"] = ""
ctld.i18n["en"]["Show targets in LOS (refresh)"] = ""
ctld.i18n["en"]["Hide targets in LOS"] = ""
ctld.i18n["en"]["START autoRefresh targets in LOS"] = ""
ctld.i18n["en"]["STOP autoRefresh targets in LOS"] = ""


--=================================================================================================================
--========  FRENCH - FRANCAIS =====================================================================================
ctld.i18n["fr"] = {}
ctld.i18n["fr"].translation_version =
"1.6" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "fr"; env.info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
    tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["fr"]["Standard Group"] = "Groupe standard"
ctld.i18n["fr"]["Anti Air"] = "Défense aérienne"
ctld.i18n["fr"]["Anti Tank"] = "Anti Tank"
ctld.i18n["fr"]["Mortar Squad"] = "Groupe mortier"
ctld.i18n["fr"]["JTAC Group"] = "Groupe JTAC"
ctld.i18n["fr"]["Single JTAC"] = "JTAC seul"
ctld.i18n["fr"]["2x - Standard Groups"] = "2x - Groupes standards"
ctld.i18n["fr"]["2x - Anti Air"] = "2x - Défenses aériennes"
ctld.i18n["fr"]["2x - Anti Tank"] = "2x - Anti Tank"
ctld.i18n["fr"]["2x - Standard Groups + 2x Mortar"] = "2x - Groupes standards + 2x Groupes mortiers"
ctld.i18n["fr"]["3x - Standard Groups"] = "3x - Groupes standards"
ctld.i18n["fr"]["3x - Anti Air"] = "3x - Défenses aériennes"
ctld.i18n["fr"]["3x - Anti Tank"] = "3x - Anti Tank"
ctld.i18n["fr"]["3x - Mortar Squad"] = "3x - Groupes mortiers"
ctld.i18n["fr"]["5x - Mortar Squad"] = "5x - Groupes mortiers"
ctld.i18n["fr"]["Mortar Squad Red"] = "Groupe mortier rouge"

--- crates names
ctld.i18n["fr"]["Humvee - MG"] = ""
ctld.i18n["fr"]["Humvee - TOW"] = ""
ctld.i18n["fr"]["Light Tank - MRAP"] = ""
ctld.i18n["fr"]["Med Tank - LAV-25"] = ""
ctld.i18n["fr"]["Heavy Tank - Abrams"] = ""
ctld.i18n["fr"]["BTR-D"] = ""
ctld.i18n["fr"]["BRDM-2"] = ""
ctld.i18n["fr"]["Hummer - JTAC"] = ""
ctld.i18n["fr"]["M-818 Ammo Truck"] = ""
ctld.i18n["fr"]["M-978 Tanker"] = ""
ctld.i18n["fr"]["SKP-11 - JTAC"] = ""
ctld.i18n["fr"]["Ural-375 Ammo Truck"] = ""
ctld.i18n["fr"]["KAMAZ Ammo Truck"] = ""
ctld.i18n["fr"]["EWR Radar"] = ""
ctld.i18n["fr"]["FOB Crate - Small"] = ""
ctld.i18n["fr"]["MQ-9 Repear - JTAC"] = ""
ctld.i18n["fr"]["RQ-1A Predator - JTAC"] = ""
ctld.i18n["fr"]["MLRS"] = ""
ctld.i18n["fr"]["SpGH DANA"] = ""
ctld.i18n["fr"]["T155 Firtina"] = ""
ctld.i18n["fr"]["Howitzer"] = ""
ctld.i18n["fr"]["SPH 2S19 Msta"] = ""
ctld.i18n["fr"]["M1097 Avenger"] = ""
ctld.i18n["fr"]["M48 Chaparral"] = ""
ctld.i18n["fr"]["Roland ADS"] = ""
ctld.i18n["fr"]["Gepard AAA"] = ""
ctld.i18n["fr"]["LPWS C-RAM"] = ""
ctld.i18n["fr"]["9K33 Osa"] = ""
ctld.i18n["fr"]["9P31 Strela-1"] = ""
ctld.i18n["fr"]["9K35M Strela-10"] = ""
ctld.i18n["fr"]["9K331 Tor"] = ""
ctld.i18n["fr"]["2K22 Tunguska"] = ""
ctld.i18n["fr"]["HAWK Launcher"] = ""
ctld.i18n["fr"]["HAWK Search Radar"] = ""
ctld.i18n["fr"]["HAWK Track Radar"] = ""
ctld.i18n["fr"]["HAWK PCP"] = ""
ctld.i18n["fr"]["HAWK CWAR"] = ""
ctld.i18n["fr"]["HAWK Repair"] = ""
ctld.i18n["fr"]["NASAMS Launcher 120C"] = ""
ctld.i18n["fr"]["NASAMS Search/Track Radar"] = ""
ctld.i18n["fr"]["NASAMS Command Post"] = ""
ctld.i18n["fr"]["NASAMS Repair"] = ""
ctld.i18n["fr"]["KUB Launcher"] = ""
ctld.i18n["fr"]["KUB Radar"] = ""
ctld.i18n["fr"]["KUB Repair"] = ""
ctld.i18n["fr"]["BUK Launcher"] = ""
ctld.i18n["fr"]["BUK Search Radar"] = ""
ctld.i18n["fr"]["BUK CC Radar"] = ""
ctld.i18n["fr"]["BUK Repair"] = ""
ctld.i18n["fr"]["Patriot Launcher"] = ""
ctld.i18n["fr"]["Patriot Radar"] = ""
ctld.i18n["fr"]["Patriot ECS"] = ""
ctld.i18n["fr"]["Patriot ICC"] = ""
ctld.i18n["fr"]["Patriot EPP"] = ""
ctld.i18n["fr"]["Patriot AMG (optional)"] = ""
ctld.i18n["fr"]["Patriot Repair"] = ""
ctld.i18n["fr"]["S-300 Grumble TEL C"] = ""
ctld.i18n["fr"]["S-300 Grumble Flap Lid-A TR"] = ""
ctld.i18n["fr"]["S-300 Grumble Clam Shell SR"] = ""
ctld.i18n["fr"]["S-300 Grumble Big Bird SR"] = ""
ctld.i18n["fr"]["S-300 Grumble C2"] = ""
ctld.i18n["fr"]["S-300 Repair"] = ""
ctld.i18n["fr"]["Humvee - TOW - All crates"] = "Humvee - TOW - Toutes les caisses"
ctld.i18n["fr"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Toutes les caisses"
ctld.i18n["fr"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Toutes les caisses"
ctld.i18n["fr"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Toutes les caisses"
ctld.i18n["fr"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Toutes les caisses"
ctld.i18n["fr"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["M-978 Tanker - All crates"] = "M-978 Tanker - Toutes les caisses"
ctld.i18n["fr"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["EWR Radar - All crates"] = "EWR Radar - Toutes les caisses"
ctld.i18n["fr"]["MLRS - All crates"] = "MLRS - Toutes les caisses"
ctld.i18n["fr"]["SpGH DANA - All crates"] = "SpGH DANA - Toutes les caisses"
ctld.i18n["fr"]["T155 Firtina - All crates"] = "T155 Firtina - Toutes les caisses"
ctld.i18n["fr"]["Howitzer - All crates"] = "Howitzer - Toutes les caisses"
ctld.i18n["fr"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Toutes les caisses"
ctld.i18n["fr"]["M1097 Avenger - All crates"] = "M1097 Avenger - Toutes les caisses"
ctld.i18n["fr"]["M48 Chaparral - All crates"] = "M48 Chaparral - Toutes les caisses"
ctld.i18n["fr"]["Roland ADS - All crates"] = "Roland ADS - Toutes les caisses"
ctld.i18n["fr"]["Gepard AAA - All crates"] = "Gepard AAA - Toutes les caisses"
ctld.i18n["fr"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Toutes les caisses"
ctld.i18n["fr"]["9K33 Osa - All crates"] = "9K33 Osa - Toutes les caisses"
ctld.i18n["fr"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Toutes les caisses"
ctld.i18n["fr"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Toutes les caisses"
ctld.i18n["fr"]["9K331 Tor - All crates"] = "9K331 Tor - Toutes les caisses"
ctld.i18n["fr"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Toutes les caisses"
ctld.i18n["fr"]["HAWK - All crates"] = "HAWK - Toutes les caisses"
ctld.i18n["fr"]["NASAMS - All crates"] = "NASAMS - Toutes les caisses"
ctld.i18n["fr"]["KUB - All crates"] = "KUB - Toutes les caisses"
ctld.i18n["fr"]["BUK - All crates"] = "BUK - Toutes les caisses"
ctld.i18n["fr"]["Patriot - All crates"] = "Patriot - Toutes les caisses"
ctld.i18n["fr"]["Patriot - All crates"] = "Patriot - Toutes les caisses"

--- mission design error messages
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find trigger called %1"] =
"CTLD.lua ERREUR : Impossible de trouver le déclencheur appelé %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone called %1"] =
"CTLD.lua ERREUR : Impossible de trouver la zone appelée %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone or ship called %1"] =
"CTLD.lua ERREUR : Impossible de trouver la zone ou le navire appelé %1"
ctld.i18n["fr"]["CTLD.lua ERROR: Can't find crate with weight %1"] =
"CTLD.lua ERREUR : Impossible de trouver une caisse avec un poids de %1"

--- runtime messages
ctld.i18n["fr"]["You are not close enough to friendly logistics to get a crate!"] =
"Vous n'êtes pas assez proche de la logistique alliée pour obtenir une caisse !"
ctld.i18n["fr"]["No more JTAC Crates Left!"] = "Plus de caisses JTAC disponibles !"
ctld.i18n["fr"]["Sorry you must wait %1 seconds before you can get another crate"] =
"Désolé, vous devez attendre %1 secondes avant de pouvoir obtenir une autre caisse"
ctld.i18n["fr"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"Une caisse %1 pesant %2 kg a été apportée et se trouve à vos %3 heure"
ctld.i18n["fr"]["%1 fast-ropped troops from %2 into combat"] = "%1 a largué rapidement des troupes de %2 au combat"
ctld.i18n["fr"]["%1 dropped troops from %2 into combat"] = "%1 a largué des troupes de %2 au combat"
ctld.i18n["fr"]["%1 fast-ropped troops from %2 into %3"] = "%1 a largué rapidement des troupes de %2 à %3"
ctld.i18n["fr"]["%1 dropped troops from %2 into %3"] = "%1 a largué des troupes de %2 à %3"
ctld.i18n["fr"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"Trop haut ou trop rapide pour larguer des troupes au combat ! Survolez en dessous de %1 pieds ou atterrissez."
ctld.i18n["fr"]["%1 dropped vehicles from %2 into combat"] = "%1 a largué des véhicules de %2 au combat"
ctld.i18n["fr"]["%1 loaded troops into %2"] = "%1 a chargé des troupes dans %2"
ctld.i18n["fr"]["%1 loaded %2 vehicles into %3"] = "%1 a chargé %2 véhicules dans %3"
ctld.i18n["fr"]["%1 delivered a FOB Crate"] = "%1 a livré une caisse FOB"
ctld.i18n["fr"]["Delivered FOB Crate 60m at 6'oclock to you"] = "Caisse FOB livrée à 60 m à 6 heures de vous"
ctld.i18n["fr"]["FOB Crate dropped back to base"] = "Caisse FOB ramenée à la base"
ctld.i18n["fr"]["FOB Crate Loaded"] = "Caisse FOB chargée"
ctld.i18n["fr"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 a chargé une caisse FOB prête à être livrée !"
ctld.i18n["fr"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"Il n'y a pas d'unités logistiques alliée à proximité pour charger une caisse FOB !"
ctld.i18n["fr"]["This area has no more reinforcements available!"] = "Cette zone n'a plus de renforts disponibles !"
ctld.i18n["fr"]["You are not in a pickup zone and no one is nearby to extract"] =
"Vous n'êtes pas dans une zone d'embarquement et personne n'est à proximité pour être extrait."
ctld.i18n["fr"]["You are not in a pickup zone"] = "Vous n'êtes pas dans une zone d'embarquement"
ctld.i18n["fr"]["No one to unload"] = "Personne à débarquer"
ctld.i18n["fr"]["Dropped troops back to base"] = "Troupes larguées à la base"
ctld.i18n["fr"]["Dropped vehicles back to base"] = "Véhicules largués à la base"
ctld.i18n["fr"]["You already have troops onboard."] = "Vous avez déjà des troupes à bord."
ctld.i18n["fr"]["Count Infantries limit in the mission reached, you can't load more troops"] =
"Nombre maximum de troupes sur mission atteint, vous ne pouvez pas charger plus de troupes"
ctld.i18n["fr"]["You already have vehicles onboard."] = "Vous avez déjà des véhicules à bord."
ctld.i18n["fr"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"Désolé - Le groupe de %1 est trop important. \n\nLa limite est de %2 pour %3"
ctld.i18n["fr"]["%1 extracted troops in %2 from combat"] = "%1 troupes extraites du combat en %2"
ctld.i18n["fr"]["No extractable troops nearby!"] = "Aucune troupe extractible à proximité !"
ctld.i18n["fr"]["%1 extracted vehicles in %2 from combat"] = "%1 véhicules extraits du combat en %2"
ctld.i18n["fr"]["No extractable vehicles nearby!"] = "Aucun véhicule extractible à proximité !"
ctld.i18n["fr"]["%1 troops onboard (%2 kg)\n"] = "%1 troupes à bord (%2 kg)\n"
ctld.i18n["fr"]["%1 vehicles onboard (%2)\n"] = "%1 véhicules à bord (%2)\n"
ctld.i18n["fr"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caisse FOB à bord (%1 kg)\n"
ctld.i18n["fr"]["%1 crate onboard (%2 kg)\n"] = "%1 caisse à bord (%2 kg)\n"
ctld.i18n["fr"]["Total weight of cargo : %1 kg\n"] = "Poids total de la cargaison : %1 kg\n"
ctld.i18n["fr"]["No cargo."] = "Aucune cargaison."
ctld.i18n["fr"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"Stationaire au-dessus de la caisse %1. \n\nMaintenez le stationaire pendant %2 secondes ! \n\nSi le compte à rebours s'arrête, vous êtes trop loin !"
ctld.i18n["fr"]["Loaded %1 crate!"] = "Caisse %1 chargée !"
ctld.i18n["fr"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Trop bas pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
ctld.i18n["fr"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Trop haut pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
ctld.i18n["fr"]["You must land before you can load a crate!"] =
"Vous devez atterrir avant de pouvoir charger une caisse !"
ctld.i18n["fr"]["No Crates within 50m to load!"] = "Aucune caisse à moins de 50 m pour charger !"
ctld.i18n["fr"]["Maximum number of crates are on board!"] = "Nombre maximal de caisses à bord !"
ctld.i18n["fr"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caisse - kg %3 - %4 m - %5 heures"
ctld.i18n["fr"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caisse FOB - %1 m - %2 heures\n"
ctld.i18n["fr"]["No Nearby Crates"] = "Aucune caisse à proximité"
ctld.i18n["fr"]["Nearby Crates:\n%1"] = "Caisses à proximité :\n%1"
ctld.i18n["fr"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Caisses FOB à proximité (non chargeables par élingue) :\n%1"
ctld.i18n["fr"]["FOB Positions:"] = "Positions FOB :"
ctld.i18n["fr"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["fr"]["Sorry, there are no active FOBs!"] = "Désolé, il n'y a pas de FOB actif !"
ctld.i18n["fr"]["You can't unpack that here! Take it to where it's needed!"] =
"Vous ne pouvez déballer ça ici ! Emmenez-le là où vous en avez besoin !"
ctld.i18n["fr"]["Sorry you must move this crate before you unpack it!"] =
"Désolé, vous devez déplacer cette caisse avant de la déballer !"
ctld.i18n["fr"]["%1 successfully deployed %2 to the field"] = "%1 a déployé avec succès %2 sur le terrain."
ctld.i18n["fr"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"Aucune caisse alliée n'est suffisamment proche pour être déballée, ou la caisse est trop proche d'un avion."
ctld.i18n["fr"]["Finished building FOB! Crates and Troops can now be picked up."] =
"Construction du FOB terminée ! Les caisses et les troupes peuvent maintenant embarqués."
ctld.i18n["fr"]["Finished building FOB! Crates can now be picked up."] =
"Construction du FOB terminée ! Les caisses peuvent maintenant être embarqués."
ctld.i18n["fr"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 a commencé à construire le FOB en utilisant %2 caisses FOB, il sera terminé dans %3 secondes.\nPosition marquée par le fumigène."
ctld.i18n["fr"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"Impossible de construire le FOB !\n\nIl nécessite %1 grandes caisses FOB (3 petites caisses FOB équivalent à 1 grande caisse FOB) et il y a l'équivalent de %2 grandes caisses FOB à proximité\n\nOu les caisses ne sont pas à moins de 750 m les unes des autres autre"
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, survolez la caisse pendant %1 secondes ou atterrissez et utilisez les commandes de caisse F10."
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour ramasser une caisse, survolez la caisse pendant %1 secondes."
ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, atterrissez et utilisez les commandes de caisse F10."
ctld.i18n["fr"]["%1 crate has been safely unhooked and is at your %2 o'clock"] =
"%1 caisse a été décrochée en toute sécurité et se trouve à vos %2 heures"
ctld.i18n["fr"]["%1 crate has been safely dropped below you"] = "%1 caisse a été déposée en toute sécurité sous vous"
ctld.i18n["fr"]["You were too high! The crate has been destroyed"] = "Vous étiez trop haut! La caisse a été détruite"
ctld.i18n["fr"]["Radio Beacons:\n%1"] = "Balises radio :\n%1"
ctld.i18n["fr"]["No Active Radio Beacons"] = "Aucune balise radio active"
ctld.i18n["fr"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 a déployé une balise radio.\n\n%2"
ctld.i18n["fr"]["You need to land before you can deploy a Radio Beacon!"] =
"Vous devez atterrir avant de pouvoir déployer une balise radio !"
ctld.i18n["fr"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 a supprimé une balise radio.\n\n%2"
ctld.i18n["fr"]["No Radio Beacons within 500m."] = "Aucune balise radio à moins de 500m."
ctld.i18n["fr"]["You need to land before remove a Radio Beacon"] =
"Vous devez atterrir avant de retirer une balise radio"
ctld.i18n["fr"]["%1 successfully rearmed a full %2 in the field"] =
"%1 a réarmé avec succès un %2 complet sur le terrain"
ctld.i18n["fr"]["Missing %1\n"] = "%1 manquant\n"
ctld.i18n["fr"]["Out of parts for AA Systems. Current limit is %1\n"] =
"Plus de pièces pour les systèmes AA. La limite actuelle est de %1\n"
ctld.i18n["fr"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"Impossible de construire %1\n%2\n\nOu les caisses ne sont pas assez proches les unes des autres"
ctld.i18n["fr"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 a déployé avec succès un %2 complet sur le terrain. \n\nLa limite du système actif AA est : %3\nActif : %4"
ctld.i18n["fr"]["%1 successfully repaired a full %2 in the field."] =
"%1 a réparé avec succès un %2 complet sur le terrain."
ctld.i18n["fr"]["Cannot repair %1. No damaged %2 within 300m"] =
"Impossible de réparer %1. Aucun %2 endommagé à moins de 300 m"
ctld.i18n["fr"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 a déployé avec succès %2 sur le terrain en utilisant %3 caisses."
ctld.i18n["fr"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"Impossible de construire %1 !\n\nIl faut %2 caisses et il y en a %3 \n\nOu les caisses ne sont pas à moins de 300 m les unes des autres"
ctld.i18n["fr"]["%1 dropped %2 smoke."] = "%1 a largué un fumigène %2."

--- JTAC messages
ctld.i18n["fr"]["JTAC Group %1 KIA!"] = "Groupe JTAC %1 KIA !"
ctld.i18n["fr"]["%1, selected target reacquired, %2"] = "%1, cible sélectionnée réacquise, %2"
ctld.i18n["fr"][". CODE: %1. POSITION: %2"] = ". CODE : %1. POSITION : %2"
ctld.i18n["fr"]["new target, "] = "nouvelle cible, "
ctld.i18n["fr"]["standing by on %1"] = "en attente sur %1"
ctld.i18n["fr"]["lasing %1"] = "laser %1"
ctld.i18n["fr"][", temporarily %1"] = ", temporairement %1"
ctld.i18n["fr"]["target lost"] = "cible perdue"
ctld.i18n["fr"]["target destroyed"] = "cible détruite"
ctld.i18n["fr"][", selected %1"] = ", %1 sélectionné"
ctld.i18n["fr"]["%1 %2 target lost."] = "%1 %2 cible perdue."
ctld.i18n["fr"]["%1 %2 target destroyed."] = "%1 %2 cible détruite."
ctld.i18n["fr"]["JTAC STATUS: \n\n"] = "ÉTAT JTAC : \n\n"
ctld.i18n["fr"][", available on %1 %2,"] = ", disponible sur %1 %2,"
ctld.i18n["fr"]["UNKNOWN"] = "INCONNU"
ctld.i18n["fr"][" targeting "] = " ciblage "
ctld.i18n["fr"][" targeting selected unit "] = " ciblage de l'unité sélectionnée "
ctld.i18n["fr"][" attempting to find selected unit, temporarily targeting "] =
" tentative de recherche de l'unité sélectionnée, ciblage temporaire "
ctld.i18n["fr"]["(Laser OFF) "] = "(Laser INACTIF) "
ctld.i18n["fr"]["Visual On: "] = "Visuel activé : "
ctld.i18n["fr"][" searching for targets %1\n"] = " recherche de cibles %1\n"
ctld.i18n["fr"]["No Active JTACs"] = "Aucun JTAC actif"
ctld.i18n["fr"][", targeting selected unit, %1"] = ", ciblage de l'unité sélectionnée, %1"
ctld.i18n["fr"][". CODE: %1. POSITION: %2"] = ". CODE : %1. POSITION : %2"
ctld.i18n["fr"][", target selection reset."] = ", sélection de cible réinitialisée."
ctld.i18n["fr"]["%1, laser and smokes enabled"] = "%1, laser et fumigènes activés"
ctld.i18n["fr"]["%1, laser and smokes disabled"] = "%1, laser et fumigènes désactivés"
ctld.i18n["fr"]["%1, wind and target speed laser spot compensations enabled"] =
"%1, compensations activées de la vitesse du vent et de la cible pour le spot laser"
ctld.i18n["fr"]["%1, wind and target speed laser spot compensations disabled"] =
"%1, compensations désactivées de la vitesse du vent et de la cible pour le spot laser"
ctld.i18n["fr"]["%1, WHITE smoke deployed near target"] = "%1, fumigène BLANCHE déployée près de la cible"

--- F10 menu messages
ctld.i18n["fr"]["Actions"] = "Actions"
ctld.i18n["fr"]["Troop Transport"] = "Transport troupes"
ctld.i18n["fr"]["Unload / Extract Troops"] = "Débarqt / Embarqt Troupes"
ctld.i18n["fr"]["Next page"] = "page suiv."
ctld.i18n["fr"]["Load "] = "Charger "
ctld.i18n["fr"]["Vehicle / FOB Transport"] = "Transport Vehicule / FOB"
ctld.i18n["fr"]["Crates: Vehicle / FOB / Drone"] = "Caisses Vehicule / FOB / Drone"
ctld.i18n["fr"]["Unload Vehicles"] = "Décharger Vehicles"
ctld.i18n["fr"]["Load / Extract Vehicles"] = "Chargt / Déchargt Vehicules"
ctld.i18n["fr"]["Load / Unload FOB Crate"] = "Chargt / Déchargt Caisse FOB"
ctld.i18n["fr"]["Repack Vehicles"] = "Ré-emballer véhicules"
ctld.i18n["fr"]["CTLD Commands"] = "Commandes CTLD"
ctld.i18n["fr"]["CTLD"] = "CTLD"
ctld.i18n["fr"]["Check Cargo"] = "Vérif° chargement"
ctld.i18n["fr"]["Load Nearby Crate(s)"] = "Charger caisse(s) proche"
ctld.i18n["fr"]["Unpack Any Crate"] = "Déballer caisses"
ctld.i18n["fr"]["Drop Crate(s)"] = "Décharger caisse(s)"
ctld.i18n["fr"]["List Nearby Crates"] = "Liste caisses proches"
ctld.i18n["fr"]["List FOBs"] = "Liste FOBs"
ctld.i18n["fr"]["List Beacons"] = "Liste balises"
ctld.i18n["fr"]["List Radio Beacons"] = "Liste Radio balises"
ctld.i18n["fr"]["Smoke Markers"] = "Marques Fumées"
ctld.i18n["fr"]["Drop Red Smoke"] = "Déposer Fumi Rouge"
ctld.i18n["fr"]["Drop Blue Smoke"] = "Déposer Fumi Bleu"
ctld.i18n["fr"]["Drop Orange Smoke"] = "Déposer Fumi Orange"
ctld.i18n["fr"]["Drop Green Smoke"] = "Déposer Fumi Vert"
ctld.i18n["fr"]["Drop Beacon"] = "Déposer Fumi Vert"
ctld.i18n["fr"]["Radio Beacons"] = "Déposer Balise"
ctld.i18n["fr"]["Remove Closest Beacon"] = "Supprimer Balise +proche"
ctld.i18n["fr"]["JTAC Status"] = "Statut JTAC"
ctld.i18n["fr"]["DISABLE "] = "DESACTIVE "
ctld.i18n["fr"]["ENABLE "] = "ACTIVE "
ctld.i18n["fr"]["REQUEST "] = "DEMANDE"
ctld.i18n["fr"]["Reset TGT Selection"] = "Réinitialiser sélection TGT"
-- F10 RECON menus
ctld.i18n["fr"]["RECON"] = "RECONNAISSANCE"
ctld.i18n["fr"]["Show targets in LOS (refresh)"] = "Marquer cibles visibles sur carte F10"
ctld.i18n["fr"]["Hide targets in LOS"] = "Effacer marques sur carte F10"
ctld.i18n["fr"]["START autoRefresh targets in LOS"] = "Lancer suivi automatique des cibles"
ctld.i18n["fr"]["STOP autoRefresh targets in LOS"] = "Stopper suivi automatique des cibles"

--======  SPANISH : ESPAÑOL====================================================================================
ctld.i18n["es"] = {}
ctld.i18n["es"].translation_version =
"1.6" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "es"; env
    .info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
        tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["es"]["Standard Group"] = "Grupo estándar"
ctld.i18n["es"]["Anti Air"] = "Defensa aérea"
ctld.i18n["es"]["Anti Tank"] = "Antitanque"
ctld.i18n["es"]["Mortar Squad"] = "Grupo mortero"
ctld.i18n["es"]["JTAC Group"] = "Grupo JTAC"
ctld.i18n["es"]["Single JTAC"] = "JTAC solo"
ctld.i18n["es"]["2x - Standard Groups"] = "2x - Grupos estándares"
ctld.i18n["es"]["2x - Anti Air"] = "2x - Defensas aéreas"
ctld.i18n["es"]["2x - Anti Tank"] = "2x - Antitanque"
ctld.i18n["es"]["2x - Standard Groups + 2x Mortar"] = "2x - Grupos estándar + 2x Grupos morteros"
ctld.i18n["es"]["3x - Standard Groups"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Air"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Tank"] = "3x - Antitanque"
ctld.i18n["es"]["3x - Mortar Squad"] = "3x - Grupos de morteros"
ctld.i18n["es"]["5x - Mortar Squad"] = "5x - Grupos de morteros"
ctld.i18n["es"]["Mortar Squad Red"] = "Grupo mortero rojo"

--- crates names
ctld.i18n["es"]["Humvee - MG"] = "Humvee - Antipersonal .50 cal"
ctld.i18n["es"]["Humvee - TOW"] = "Humvee - Antitanque TOW"
ctld.i18n["es"]["Light Tank - MRAP"] = "Tanque ligero - MRAP"
ctld.i18n["es"]["Med Tank - LAV-25"] = "Tanque Med - LAV-25"
ctld.i18n["es"]["Heavy Tank - Abrams"] = "Tanque pesado - Abrams"
ctld.i18n["es"]["BTR-D"] = "BTR-D - Transporte de tropas"
ctld.i18n["es"]["BRDM-2"] = "BRDM-2 - Reconocimiento"
ctld.i18n["es"]["Hummer - JTAC"] = "JTAC Hummer"
ctld.i18n["es"]["M-818 Ammo Truck"] = "Camión M-818 de municiones"
ctld.i18n["es"]["M-978 Tanker"] = "Camión cisterna M-978"
ctld.i18n["es"]["SKP-11 - JTAC"] = "JTAC SKP-11"
ctld.i18n["es"]["Ural-375 Ammo Truck"] = "Camión Ural-375 de municiones"
ctld.i18n["es"]["KAMAZ Ammo Truck"] = "Camión KAMAZ de municiones"
ctld.i18n["es"]["EWR Radar"] = "Radar Alerta Temprana"
ctld.i18n["es"]["FOB Crate - Small"] = "Caja FOB - Pequeña"
ctld.i18n["es"]["MQ-9 Repear - JTAC"] = "JTAC MQ-9 Repear"
ctld.i18n["es"]["RQ-1A Predator - JTAC"] = "JTAC RQ-1A Predator"
ctld.i18n["es"]["MLRS"] = "MLRS - Artilleria de cohetes"
ctld.i18n["es"]["SpGH DANA"] = "Obus autopropulsado SpGH DANA"
ctld.i18n["es"]["T155 Firtina"] = "Obus autopropulsado T155 Firtina"
ctld.i18n["es"]["Howitzer"] = "Obus autopropulsado M109A6 Paladin"
ctld.i18n["es"]["SPH 2S19 Msta"] = "SPH 2S19 Msta - Obus Autopropulsado"
ctld.i18n["es"]["M1097 Avenger"] = "M1097 Avenger - SAM Corta Distancia"
ctld.i18n["es"]["M48 Chaparral"] = "M48 Chaparral - SAM Corta Distancia"
ctld.i18n["es"]["Roland ADS"] = "Roland ADS - Lanzador"
ctld.i18n["es"]["Gepard AAA"] = "Gepard AAA - AAA"
ctld.i18n["es"]["LPWS C-RAM"] = "LPWS C-RAM - AAA"
ctld.i18n["es"]["9K33 Osa"] = "9K33 Osa - SA-8 Gecko"
ctld.i18n["es"]["9P31 Strela-1"] = "9P31 Strela-1 - SA-9 Gaskin"
ctld.i18n["es"]["9K35M Strela-10"] = "9K35M Strela-10 - SA-13 Gopher"
ctld.i18n["es"]["9K331 Tor"] = "9K331 Tor - SA-15 Tor"
ctld.i18n["es"]["2K22 Tunguska"] = "2K22 Tunguska - SA-19 Tunguska"
ctld.i18n["es"]["HAWK Launcher"] = "HAWK - Lanzador"
ctld.i18n["es"]["HAWK Search Radar"] = "HAWK - Radar de Búsqueda"
ctld.i18n["es"]["HAWK Track Radar"] = "HAWK - Radar de Seguimiento"
ctld.i18n["es"]["HAWK PCP"] = "HAWK - Puesto de Comando"
ctld.i18n["es"]["HAWK CWAR"] = "HAWK - Sistema de Control de Guerra"
ctld.i18n["es"]["HAWK Repair"] = "Reparar HAWK"
ctld.i18n["es"]["NASAMS Launcher 120C"] = "NASAMS - Lanzador 120C"
ctld.i18n["es"]["NASAMS Search/Track Radar"] = "NASAMS - Radar de Búsqueda/Seguimiento"
ctld.i18n["es"]["NASAMS Command Post"] = "NASAMS - Puesto de Mando"
ctld.i18n["es"]["NASAMS Repair"] = "Reparar NASAMS"
ctld.i18n["es"]["KUB Launcher"] = "KUB - Lanzador"
ctld.i18n["es"]["KUB Radar"] = "KUB - Radar"
ctld.i18n["es"]["KUB Repair"] = "Reparar KUB"
ctld.i18n["es"]["BUK Launcher"] = "BUK - Lanzador"
ctld.i18n["es"]["BUK Search Radar"] = "BUK - Radar de Búsqueda"
ctld.i18n["es"]["BUK CC Radar"] = "BUK - Radar de Control de Combate"
ctld.i18n["es"]["BUK Repair"] = "Reparar BUK"
ctld.i18n["es"]["Patriot Launcher"] = "Patriot - Lanzador"
ctld.i18n["es"]["Patriot Radar"] = "Patriot - Radar de Búsqueda"
ctld.i18n["es"]["Patriot ECS"] = "Patriot - Puesto de Mando"
ctld.i18n["es"]["Patriot ICC"] = "Patriot - Sistema de Control de Fuego"
ctld.i18n["es"]["Patriot EPP"] = "Patriot - Generador"
ctld.i18n["es"]["Patriot AMG (optional)"] = ""
ctld.i18n["es"]["Patriot Repair"] = "Reparar Patriot"
ctld.i18n["es"]["S-300 Grumble TEL C"] = "S-300 Grumble TEL C - Lanzador"
ctld.i18n["es"]["S-300 Grumble Flap Lid-A TR"] = "S-300 Grumble Flap Lid-A TR - Radar de Seguimiento"
ctld.i18n["es"]["S-300 Grumble Clam Shell SR"] = "S-300 Grumble Clam Shell SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble Big Bird SR"] = "S-300 Grumble Big Bird SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble C2"] = "S-300 Grumble C2 - Puesto de Mando"
ctld.i18n["es"]["S-300 Repair"] = "Reparar S-300"
ctld.i18n["es"]["Humvee - TOW - All crates"] = "Humvee - TOW - Todas las cajas"
ctld.i18n["es"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Todas las cajas"
ctld.i18n["es"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Todas las cajas"
ctld.i18n["es"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Todas las cajas"
ctld.i18n["es"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Todas las cajas"
ctld.i18n["es"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["M-978 Tanker - All crates"] = "M-978 Tanker - Todas las cajas"
ctld.i18n["es"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["EWR Radar - All crates"] = "EWR Radar - Todas las cajas"
ctld.i18n["es"]["MLRS - All crates"] = "MLRS - Todas las cajas"
ctld.i18n["es"]["SpGH DANA - All crates"] = "SpGH DANA - Todas las cajas"
ctld.i18n["es"]["T155 Firtina - All crates"] = "T155 Firtina - Todas las cajas"
ctld.i18n["es"]["Howitzer - All crates"] = "Howitzer - Todas las cajas"
ctld.i18n["es"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Todas las cajas"
ctld.i18n["es"]["M1097 Avenger - All crates"] = "M1097 Avenger - Todas las cajas"
ctld.i18n["es"]["M48 Chaparral - All crates"] = "M48 Chaparral - Todas las cajas"
ctld.i18n["es"]["Roland ADS - All crates"] = "Roland ADS - Todas las cajas"
ctld.i18n["es"]["Gepard AAA - All crates"] = "Gepard AAA - Todas las cajas"
ctld.i18n["es"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Todas las cajas"
ctld.i18n["es"]["9K33 Osa - All crates"] = "9K33 Osa - Todas las cajas"
ctld.i18n["es"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Todas las cajas"
ctld.i18n["es"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Todas las cajas"
ctld.i18n["es"]["9K331 Tor - All crates"] = "9K331 Tor - Todas las cajas"
ctld.i18n["es"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Todas las cajas"
ctld.i18n["es"]["HAWK - All crates"] = "HAWK - Todas clas ajas"
ctld.i18n["es"]["NASAMS - All crates"] = "NASAMS - Todas las cajas"
ctld.i18n["es"]["KUB - All crates"] = "KUB - Todas las cajas"
ctld.i18n["es"]["BUK - All crates"] = "BUK - Todas las cajas"
ctld.i18n["es"]["Patriot - All crates"] = "Patriot - Todas las cajas"
ctld.i18n["es"]["Patriot - All crates"] = "Patriot - Todas las cajas"

--- mission design error messages
ctld.i18n["es"]["CTLD.lua ERROR: Can't find trigger called %1"] =
"CTLD.lua ERROR : Imposible encontrar el activador llamado %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua ERROR : Imposible encontrar la zona llamada %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone or ship called %1"] =
"CTLD.lua ERROR : Imposible encontrar la zona o el barco llamado %1"
ctld.i18n["es"]["CTLD.lua ERROR: Can't find crate with weight %1"] =
"CTLD.lua ERROR : Imposible encontrar una caja con un peso de %1"

--- runtime messages
ctld.i18n["es"]["You are not close enough to friendly logistics to get a crate!"] =
"¡No estás lo suficientemente cerca de la logística aliada para solicitar una caja!"
ctld.i18n["es"]["No more JTAC Crates Left!"] = "¡No hay más cajas JTAC disponibles!"
ctld.i18n["es"]["Sorry you must wait %1 seconds before you can get another crate"] =
"Lo sentimos, debes esperar %1 segundos antes de poder solicitar otra caja"
ctld.i18n["es"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"Una caja %1 pesando %2 kg ha sido preparada y está a tus %3 en punto "
ctld.i18n["es"]["%1 fast-ropped troops from %2 into combat"] = "%1 descolgo tropas con cuerdas de %2 al combate"
ctld.i18n["es"]["%1 dropped troops from %2 into combat"] = "%1 descargo tropas de %2 al combate"
ctld.i18n["es"]["%1 fast-ropped troops from %2 into %3"] = "%1 descolgo tropas con cuerdas de %2 a %3"
ctld.i18n["es"]["%1 dropped troops from %2 into %3"] = "%1 arrojó tropas de %2 a %3"
ctld.i18n["es"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"¡Demasiado alto o rápido para lanzar tropas al combate! Manten estacionario por debajo de % 1 pies o aterriza."
ctld.i18n["es"]["%1 dropped vehicles from %2 into combat"] = "%1 descargo vehículos de %2 al combate"
ctld.i18n["es"]["%1 loaded troops into %2"] = "%1 cargó tropas en %2"
ctld.i18n["es"]["%1 loaded %2 vehicles into %3"] = "%1 cargó %2 vehículos en %3"
ctld.i18n["es"]["%1 delivered a FOB Crate"] = "%1 entregó una caja FOB"
ctld.i18n["es"]["Delivered FOB Crate 60m at 6 o'clock to you"] = "Se le entregó la caja FOB de 60 m a sus 6 en punto"
ctld.i18n["es"]["FOB Crate dropped back to base"] = "Caja FOB devuelta a la base"
ctld.i18n["es"]["FOB Crate Loaded"] = "Caja FOB cargada"
ctld.i18n["es"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 cargó una caja FOB lista para su entrega!"
ctld.i18n["es"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"¡No hay unidades logísticas amigas cerca para cargar una caja FOB!"
ctld.i18n["es"]["This area has no more reinforcements available!"] = "¡Esta área no tiene más refuerzos disponibles!"
ctld.i18n["es"]["You are not in a pickup zone and no one is nearby to extract"] =
"No estás en una zona de carga y/o no hay nadie cerca para extraccion"
ctld.i18n["es"]["You are not in a pickup zone"] = "No estás en una zona de carga"
ctld.i18n["es"]["No one to unload"] = "Nadie / Nada para descargar"
ctld.i18n["es"]["Dropped troops back to base"] = "Tropas descargados de vuelta a la base"
ctld.i18n["es"]["Dropped vehicles back to base"] = "Vehículos descargados de vuelta a la base"
ctld.i18n["es"]["You already have troops onboard."] = "Ya tienes tropas a bordo."
ctld.i18n["es"]["Count Infantries limit in the mission reached, you can't load more troops"] =
"Se alcanzó el límite de infantería en la misión, no puedes cargar más tropas"
ctld.i18n["es"]["You already have vehicles onboard."] = "Ya tienes vehículos a bordo."
ctld.i18n["es"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"Lo sentimos, el grupo de %1 es demasiado grande. \n \nEl límite es %2 para %3"
ctld.i18n["es"]["%1 extracted troops in %2 from combat"] = "%1 tropas extraídas del combate en %2"
ctld.i18n["es"]["No extractable troops nearby!"] = "¡No hay tropas extraíbles cerca!"
ctld.i18n["es"]["%1 extracted vehicles in %2 from combat"] = "%1 vehículos extraídos del combate en %2"
ctld.i18n["es"]["No extractable vehicles nearby!"] = "¡No hay vehículos extraíbles cerca!"
ctld.i18n["es"]["%1 troops onboard (%2 kg)\n"] = "%1 tropas a bordo (%2 kg)\n"
ctld.i18n["es"]["%1 vehicles onboard (%2)\n"] = "%1 vehículos a bordo (%2)\n"
ctld.i18n["es"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caja FOB a bordo (%1 kg)\n"
ctld.i18n["es"]["%1 crate onboard (%2 kg)\n"] = "%1 caja a bordo (%2 kg)\n"
ctld.i18n["es"]["Total weight of cargo : %1 kg\n"] = "Peso total de la carga: %1 kg\n"
ctld.i18n["es"]["No cargo."] = "Sin carga."
ctld.i18n["es"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"En estacionario sobre la caja %1 \n\n¡Mantenlo durante %2 segundos! \n\n¡Si la cuenta atras se detiene, estás demasiado lejos!"
ctld.i18n["es"]["Loaded %1 crate!"] = "Caja %1 cargada !"
ctld.i18n["es"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado bajo para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado alto para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
ctld.i18n["es"]["No Crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡El número máximo de cajas está a bordo!"
ctld.i18n["es"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caja - kg %3 - %4 m - a tus %5 en punto"
ctld.i18n["es"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caja FOB - %1 m - a las %2 en punto\n"
ctld.i18n["es"]["No Nearby Crates"] = "Ninguna caja de proximidad"
ctld.i18n["es"]["Nearby Crates:\n%1"] = "Cajas cercanas:\n%1"
ctld.i18n["es"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Cajas FOB cercanas (no se pueden cargar con eslinga):\n%1"
ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"
ctld.i18n["es"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["es"]["Sorry, there are no active FOBs!"] = "¡Lo sentimos, no hay FOB activos!"
ctld.i18n["es"]["No cargo."] = "Sin carga."
ctld.i18n["es"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"En estacionario sobre la caja %1 \n\n¡Mantenlo durante %2 segundos! \n\n¡Si la cuenta atras se detiene, estás demasiado lejos!"
ctld.i18n["es"]["Loaded %1 crate!"] = "¡Caja %1 cargada!"
ctld.i18n["es"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado bajo para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] =
"Demasiado alto para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
ctld.i18n["es"]["No Crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡Número máximo de cajas a bordo!"
ctld.i18n["es"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caja - kg %3 - %4 m - a tus %5 en punto"
ctld.i18n["es"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caja FOB - %1 m - a tus %2 en punto\n"
ctld.i18n["es"]["No Nearby Crates"] = "No hay cajas cerca"
ctld.i18n["es"]["Nearby Crates:\n%1"] = "Cajas cercanas:\n%1"
ctld.i18n["es"]["Nearby FOB Crates (Not Slingloadable):\n%1"] =
"Cajas FOB cercanas (no se pueden cargar con eslinga):\n%1"
ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"
ctld.i18n["es"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
ctld.i18n["es"]["Sorry, there are no active FOBs!"] = "¡Lo sentimos, no hay FOB activos!"
ctld.i18n["es"]["You can't unpack that here! Take it to where it's needed!"] =
"¡No puedes desembalar eso aquí! ¡Llévalo a donde lo necesiten!"
ctld.i18n["es"]["Sorry you must move this crate before you unpack it!"] =
"¡Lo siento, debes mover esta caja antes de desembalar!"
ctld.i18n["es"]["%1 successfully deployed %2 to the field"] = "%1 Desplego %2 con exito en el campo."
ctld.i18n["es"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"No hay cajas amigas lo suficientemente cerca por desembalar, o la caja está demasiado cerca de un avión"
ctld.i18n["es"]["Finished building FOB! Crates and Troops can now be picked up."] =
"¡Construcción FOB completada! Ahora se pueden recoger cajas y tropas"
ctld.i18n["es"]["Finished building FOB! Crates can now be picked up."] =
"¡Construcción FOB completada! Ahora se pueden recoger cajas."
ctld.i18n["es"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 comenzó a construir FOB usando %2 cajas FOB , estará terminado en %3 segundos.\nPosición marcada con bomba de humo."
ctld.i18n["es"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"¡No se puede construir el FOB!\n\nSe requiere %1 cajas FOB grandes (3 cajas FOB pequeñas equivalente a 1 caja FOB grande) y hay el equivalente a %2 cajas FOB grandes cerca\n\nO las cajas no están a menos de 750 m una de otra"
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"Actualmente no estás transportando ninguna caja.\n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos o aterrice y use los comandos de caja F10."
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos."
ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, aterriza y usa los controles de la caja F10."
ctld.i18n["es"]["%1 crate has been safely unhooked and is at your %2 o'clock"] =
"%1 caja desenganchada de forma segura y está en tus %2 en punto"
ctld.i18n["es"]["%1 crate has been safely dropped below you"] = "%1 caja ha soltado de forma segura debajo de ti"
ctld.i18n["es"]["You were too high! The crate has been destroyed"] = "¡Estabas demasiado alto! La caja ha sido destruida"
ctld.i18n["es"]["Radio Beacons:\n%1"] = "Balizas de radio:\n%1"
ctld.i18n["es"]["No Active Radio Beacons"] = "No hay radiobalizas activas"
ctld.i18n["es"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 Despliega una radiobaliza.\n\n%2"
ctld.i18n["es"]["You need to land before you can deploy a Radio Beacon!"] =
"¡Debes aterrizar antes de poder desplegar una radiobaliza!"
ctld.i18n["es"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 eliminó una radiobaliza.\n\n%2"
ctld.i18n["es"]["No Radio Beacons within 500m."] = "No hay radiobalizas a menos de 500 m."
ctld.i18n["es"]["You need to land before remove a Radio Beacon"] =
"Es necesario aterrizar antes de eliminar una radiobaliza"
ctld.i18n["es"]["%1 successfully rearmed a full %2 in the field"] = "%1 rearmó con exito un %2 completo en el campo"
ctld.i18n["es"]["Missing %1\n"] = "Faltan: %1\n"
ctld.i18n["es"]["Out of parts for AA Systems. Current limit is %1\n"] =
"Sin piezas para sistemas AA. El límite actual es %1\n"
ctld.i18n["es"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"Imposible construir %1\n%2\n\nO las cajas no están lo suficientemente cerca unas de otras."
ctld.i18n["es"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 Despliegue con exito un % 2 completo en el campo \n\nEl límite AA del sistema activo es: %3\nActivo: %4"
ctld.i18n["es"]["%1 successfully repaired a full %2 in the field."] = "%1 reparó con exito un %2 completo en el campo."
ctld.i18n["es"]["Cannot repair %1. No damaged %2 within 300m"] =
"Imposible reparar %1. No hay daños en %2 en 300 m al rededor"
ctld.i18n["es"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 Despliegue con exito de %2 en el campo usando %3 cajas."
ctld.i18n["es"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"Imposible construir %1 !\n\nNecesita %2 cajas y hay %3 \n\nO las cajas están a no menos de 300 m una de otra"
ctld.i18n["es"]["%1 dropped %2 smoke."] = "%1 lanzo humo %2."

--- JTAC messages
ctld.i18n["es"]["JTAC Group %1 KIA!"] = "¡Grupo JTAC %1 KIA!"
ctld.i18n["es"]["%1, selected target reacquired, %2"] = "%1, objetivo seleccionado readquirido, %2"
ctld.i18n["es"][". CODE: %1. POSITION: %2"] = ". CÓDIGO: %1. POSICIÓN: %2"
ctld.i18n["es"]["new target, "] = "nuevo objetivo, "
ctld.i18n["es"]["standing by on %1"] = "en espera en %1"
ctld.i18n["es"]["lasing %1"] = "láser %1"
ctld.i18n["es"][", temporarily %1"] = ", temporalmente %1"
ctld.i18n["es"]["target lost"] = "objetivo perdido"
ctld.i18n["es"]["target destroyed"] = "objetivo destruido"
ctld.i18n["es"][", selected %1"] = ", %1 seleccionado"
ctld.i18n["es"]["%1 %2 target lost."] = "%1 %2 objetivo perdido."
ctld.i18n["es"]["%1 %2 target destroyed."] = "%1 %2 objetivo destruido."
ctld.i18n["es"]["JTAC STATUS: \n\n"] = "ESTADO JTAC: \n\n"
ctld.i18n["es"][", available on %1 %2,"] = ", disponible en %1 %2,"
ctld.i18n["es"]["UNKNOWN"] = "DESCONOCIDO"
ctld.i18n["es"][" targeting "] = " apuntando "
ctld.i18n["es"][" targeting selected unit "] = " apuntando a la unidad indicada"
ctld.i18n["es"][" attempting to find selected unit, temporarily targeting "] =
" intentando encontrar la unidad indicada, laser activo "
ctld.i18n["es"]["(Laser OFF) "] = "(Láser INACTIVO) "
ctld.i18n["es"]["Visual On: "] = "Visual activado: "
ctld.i18n["es"][" searching for targets %1\n"] = " buscando objetivos %1\n"
ctld.i18n["es"]["No Active JTACs"] = "Sin JTAC activos"
ctld.i18n["es"][", targeting selected unit, %1"] = ", apuntando a la unidad indicada, %1"
ctld.i18n["es"][". CODE: %1. POSITION: %2"] = ". CÓDIGO: %1. POSICIÓN: %2"
ctld.i18n["es"][", target selection reset."] = ", reinicio de selección de objetivo."
ctld.i18n["es"]["%1, laser and smokes enabled"] = "%1, láser y humo habilitados"
ctld.i18n["es"]["%1, laser and smokes disabled"] = "%1, láser y humo deshabilitados"
ctld.i18n["es"]["%1, wind and target speed laser spot compensations enabled"] =
"%1, compensaciones habilitadas del viento y de velocidad del objetivo para el punto láser"
ctld.i18n["es"]["%1, wind and target speed laser spot compensations disabled"] =
"%1, compensaciones deshabilitadas del viento y de velocidad del objetivo para el punto láser"
ctld.i18n["es"]["%1, WHITE smoke deployed near target"] = "%1, humo BLANCO desplegado cerca del objetivo"

--- F10 menu messages
ctld.i18n["es"]["Actions"] = "Acciones"
ctld.i18n["es"]["Troop Transport"] = "Transporte de tropas"
ctld.i18n["es"]["Unload / Extract Troops"] = "Descargar/Extraer tropas"
ctld.i18n["es"]["Next page"] = "Página siguiente"
ctld.i18n["es"]["Load "] = "Cargar "
ctld.i18n["es"]["Vehicle / FOB Transport"] = "Transporte de Vehículo / FOB"
ctld.i18n["es"]["Vehicle / FOB Crates / Drone"] = "Cajas de Vehículo / FOB / Dron"
ctld.i18n["es"]["Unload Vehicles"] = "Descargar vehículos"
ctld.i18n["es"]["Load / Extract Vehicles"] = "Cargar/Extraer vehículos"
ctld.i18n["es"]["Load / Unload FOB Crate"] = "Cargar/Descargar caja FOB"
ctld.i18n["es"]["Repack Vehicles"] = "Reenvolver vehículos"
ctld.i18n["es"]["CTLD Commands"] = "Comandos CTLD"
ctld.i18n["es"]["CTLD"] = "CTLD"
ctld.i18n["es"]["Check Cargo"] = "Verificar carga"
ctld.i18n["es"]["Load Nearby Crate(s)"] = "Cargar caja(s) cercana(s)"
ctld.i18n["es"]["Unpack Any Crate"] = "Desempaquetar cajas"
ctld.i18n["es"]["Drop Crate(s)"] = "Soltar caja(s)"
ctld.i18n["es"]["List Nearby Crates"] = "Enumerar cajas cercanas"
ctld.i18n["es"]["List FOBs"] = "Enumerar FOBs"
ctld.i18n["es"]["List Beacons"] = "Enumerar balizas"
ctld.i18n["es"]["List Radio Beacons"] = "Enumerar radiobalizas"
ctld.i18n["es"]["Smoke Markers"] = "Marcadores de humo"
ctld.i18n["es"]["Drop Red Smoke"] = "Lanzar humo rojo"
ctld.i18n["es"]["Drop Blue Smoke"] = "Lanzar humo azul"
ctld.i18n["es"]["Drop Orange Smoke"] = "Lanzar humo naranja"
ctld.i18n["es"]["Drop Green Smoke"] = "Lanzar humo verde"
ctld.i18n["es"]["Drop Beacon"] = "Desplegar baliza"
ctld.i18n["es"]["Radio Beacons"] = "Balizas de radio"
ctld.i18n["es"]["Remove Closest Beacon"] = "Quitar la baliza mas cercana"
ctld.i18n["es"]["JTAC Status"] = "Estado de JTAC"
ctld.i18n["es"]["DISABLE "] = "DESHABILITAR "
ctld.i18n["es"]["ENABLE "] = "HABILITAR "
ctld.i18n["es"]["REQUEST "] = "SOLICITUD "
ctld.i18n["es"]["Reset TGT Selection"] = "Restablecer selección de objetivo"
-- F10 RECON menus
ctld.i18n["es"]["RECON"] = "RECONOCIMIENTO"
ctld.i18n["es"]["Show targets in LOS (refresh)"] = "Marcar objetivos visibles en el mapa F10"
ctld.i18n["es"]["Hide targets in LOS"] = "Borrar marcas del mapa F10"
ctld.i18n["es"]["START autoRefresh targets in LOS"] = "Iniciar el seguimiento automático de objetivos"
ctld.i18n["es"]["STOP autoRefresh targets in LOS"] = "Detener el seguimiento automático de objetivos"


--=================================================================================================================
--========  Korean - 한국어 =====================================================================================
ctld.i18n["ko"] = {}
ctld.i18n["ko"].translation_version =
"1.1" -- make sure that this translation is compatible with the current version of the english language texts (ctld.i18n["en"].translation_version)
local lang = "ko"; env
    .info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
        tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["ko"]["Standard Group"] = "표준 그룹"
ctld.i18n["ko"]["Anti Air"] = "방공"
ctld.i18n["ko"]["Anti Tank"] = "대기갑"
ctld.i18n["ko"]["Mortar Squad"] = "박격포 분대"
ctld.i18n["ko"]["JTAC Group"] = "JTAC 그룹"
ctld.i18n["ko"]["Single JTAC"] = "싱글 JTAC"
ctld.i18n["ko"]["2x - Standard Groups"] = "표준 그룹 2x"
ctld.i18n["ko"]["2x - Anti Air"] = "방공 2x"
ctld.i18n["ko"]["2x - Anti Tank"] = "대기갑 2x"
ctld.i18n["ko"]["2x - Standard Groups + 2x Mortar"] = "표준 그룹 2x + 박격포 분대 2x"
ctld.i18n["ko"]["3x - Standard Groups"] = "표준 그룹 3x"
ctld.i18n["ko"]["3x - Anti Air"] = "방공 3x"
ctld.i18n["ko"]["3x - Anti Tank"] = "대기갑 3x"
ctld.i18n["ko"]["3x - Mortar Squad"] = "박격포 분대 3x"
ctld.i18n["ko"]["5x - Mortar Squad"] = "박격포 분대 5x"
ctld.i18n["ko"]["Mortar Squad Red"] = "레드 박격포 분대"

--- crates names
ctld.i18n["ko"]["Humvee - MG"] = "험비 - MG"
ctld.i18n["ko"]["Humvee - TOW"] = "험비 - TOW"
ctld.i18n["ko"]["Light Tank - MRAP"] = nil
ctld.i18n["ko"]["Med Tank - LAV-25"] = nil
ctld.i18n["ko"]["Heavy Tank - Abrams"] = "M1 에이브럼스"
ctld.i18n["ko"]["BTR-D"] = nil
ctld.i18n["ko"]["BRDM-2"] = nil
ctld.i18n["ko"]["Hummer - JTAC"] = "험머 - JTAC"
ctld.i18n["ko"]["M-818 Ammo Truck"] = "M-818 탄약 차량"
ctld.i18n["ko"]["M-978 Tanker"] = "M-978 연료 차량"
ctld.i18n["ko"]["SKP-11 - JTAC"] = nil
ctld.i18n["ko"]["Ural-375 Ammo Truck"] = "Ural-375 탄약 차량"
ctld.i18n["ko"]["KAMAZ Ammo Truck"] = "KAMAZ 탄약 차량"
ctld.i18n["ko"]["EWR Radar"] = "조기경보 레이더"
ctld.i18n["ko"]["FOB Crate - Small"] = "FOB 화물 - 小"
ctld.i18n["ko"]["MLRS"] = nil
ctld.i18n["ko"]["SpGH DANA"] = "DANA 자주곡사포"
ctld.i18n["ko"]["T155 Firtina"] = "T-155 프르트나"
ctld.i18n["ko"]["Howitzer"] = nil
ctld.i18n["ko"]["SPH 2S19 Msta"] = "2S19 므스타 자주곡사포"
ctld.i18n["ko"]["M1097 Avenger"] = "M1097 어벤저"
ctld.i18n["ko"]["M48 Chaparral"] = "M48 채퍼럴"
ctld.i18n["ko"]["Roland ADS"] = "롤랑 ADS"
ctld.i18n["ko"]["Gepard AAA"] = "게파트 자주대공포"
ctld.i18n["ko"]["LPWS C-RAM"] = nil
ctld.i18n["ko"]["9K33 Osa"] = "9K33 오사"
ctld.i18n["ko"]["9P31 Strela-1"] = "9P31 스트렐라-1"
ctld.i18n["ko"]["9K35M Strela-10"] = "9K35M 스트렐라-10"
ctld.i18n["ko"]["9K331 Tor"] = "9K331 토르"
ctld.i18n["ko"]["2K22 Tunguska"] = "2K22 퉁구스카"
ctld.i18n["ko"]["HAWK Launcher"] = "호크 포대"
ctld.i18n["ko"]["HAWK Search Radar"] = "호크 탐지 레이더"
ctld.i18n["ko"]["HAWK Track Radar"] = "호크 추적 레이더"
ctld.i18n["ko"]["HAWK PCP"] = "호크 PCP"
ctld.i18n["ko"]["HAWK CWAR"] = "호크 CWAR"
ctld.i18n["ko"]["HAWK Repair"] = "호크 수리킷"
ctld.i18n["ko"]["NASAMS Launcher 120C"] = "NASAMS 포대 120C"
ctld.i18n["ko"]["NASAMS Search/Track Radar"] = "NASAMS 레이더"
ctld.i18n["ko"]["NASAMS Command Post"] = "NASAMS 관제소"
ctld.i18n["ko"]["NASAMS Repair"] = "NASAMS 수리킷"
ctld.i18n["ko"]["KUB Launcher"] = "SA-6 포대"
ctld.i18n["ko"]["KUB Radar"] = "SA-6 레이더"
ctld.i18n["ko"]["KUB Repair"] = "SA-6 수리킷"
ctld.i18n["ko"]["BUK Launcher"] = "SA-11 포대"
ctld.i18n["ko"]["BUK Search Radar"] = "SA-11 탐지 레이더"
ctld.i18n["ko"]["BUK CC Radar"] = "SA-11 CC"
ctld.i18n["ko"]["BUK Repair"] = "SA-11 수리킷"
ctld.i18n["ko"]["Patriot Launcher"] = "패트리어트 포대"
ctld.i18n["ko"]["Patriot Radar"] = "패트리어트 탐지 레이더"
ctld.i18n["ko"]["Patriot ECS"] = "패트리어트 ECS"
ctld.i18n["ko"]["Patriot ICC"] = "패트리어트 ICC"
ctld.i18n["ko"]["Patriot EPP"] = "패트리어트 EPP"
ctld.i18n["ko"]["Patriot AMG (optional)"] = "패트리어트 AMG (선택 사항)"
ctld.i18n["ko"]["Patriot Repair"] = "패트리어트 수리킷"
ctld.i18n["ko"]["S-300 Grumble TEL C"] = "S-300 C 포대"
ctld.i18n["ko"]["S-300 Grumble Flap Lid-A TR"] = "S-300 5N63 추적 레이더"
ctld.i18n["ko"]["S-300 Grumble Clam Shell SR"] = "S-300 Clam Shell 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble Big Bird SR"] = "S-300 Big Bird 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble C2"] = "S-300 관제소"
ctld.i18n["ko"]["S-300 Repair"] = "S-300 수리킷"

--- mission design error messages
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find trigger called %1"] = "CTLD.lua 오류 : %1 트리거를 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua 오류 : %1 존을 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = "CTLD.lua 오류 : %1 존 또는 함선을 찾을 수 없음"
ctld.i18n["ko"]["CTLD.lua ERROR: Can't find crate with weight %1"] = "CTLD.lua 오류 : %1 의 무게를 가진 화물을 찾을 수 없음"

--- runtime messages
ctld.i18n["ko"]["You are not close enough to friendly logistics to get a crate!"] = "아군 보급계가 화물을 싣기에 충분한 거리에 있지 않습니다!"
ctld.i18n["ko"]["No more JTAC Crates Left!"] = "JTAC 화물이 남아있지 않습니다!"
ctld.i18n["ko"]["Sorry you must wait %1 seconds before you can get another crate"] = "죄송합니다, 다른 화물을 얻기까지 %1 초 기다려야 합니다."
ctld.i18n["ko"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] =
"%2 KG의 %1 화물이 %3 시 방향에 있습니다."
ctld.i18n["ko"]["%1 fast-ropped troops from %2 into combat"] = "%1 이(가) %2 에서 공수부대를 투입했습니다."
ctld.i18n["ko"]["%1 dropped troops from %2 into combat"] = "%1 이(가) %2 에서 병력을 투입했습니다."
ctld.i18n["ko"]["%1 fast-ropped troops from %2 into %3"] = "%1 이(가) %2 에서 %3 로 공수부대를 투입했습니다."
ctld.i18n["ko"]["%1 dropped troops from %2 into %3"] = "%1 이(가) %2에서 %3 로 병력을 투입했습니다."
ctld.i18n["ko"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] =
"병력을 투입하기에 너무 빠르거나 너무 높습니다! %1 피트 아래로 호버링 하거나 착륙하십시오."
ctld.i18n["ko"]["%1 dropped vehicles from %2 into combat"] = "%1 이(가) %2 에서 차량(들)을 투입했습니다."
ctld.i18n["ko"]["%1 loaded troops into %2"] = "%1 이 %2 로 병력을 실었습니다."
ctld.i18n["ko"]["%1 loaded %2 vehicles into %3"] = "%1 이 %2 대의 차량을 %3 로 실었습니다."
ctld.i18n["ko"]["%1 delivered a FOB Crate"] = "%1 이 FOB 화물을 배달했습니다."
ctld.i18n["ko"]["Delivered FOB Crate 60m at 6'oclock to you"] = "FOB 화물이 6시 방향 60m 거리에 있습니다."
ctld.i18n["ko"]["FOB Crate dropped back to base"] = "FOB 화물이 기지로 돌아갔습니다."
ctld.i18n["ko"]["FOB Crate Loaded"] = "FOB 화물 적재 완료"
ctld.i18n["ko"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 이 배달 준비가 완료된 FOB 화물을 실었습니다!"
ctld.i18n["ko"]["There are no friendly logistic units nearby to load a FOB crate from!"] =
"아군 보급계가 FOB 화물을 싣기에 충분한 거리에 있지 않습니다!"
ctld.i18n["ko"]["You already have troops onboard."] = "이미 병력이 탑승중입니다."
ctld.i18n["ko"]["You already have vehicles onboard."] = "이미 차량이 적재되어 있습니다."
ctld.i18n["ko"]["This area has no more reinforcements available!"] = "이 구역은 지원이 불가합니다!"
ctld.i18n["ko"]["You are not in a pickup zone and no one is nearby to extract"] = "픽업 구역이 아니고 근처에 철수할 병력이 없습니다."
ctld.i18n["ko"]["You are not in a pickup zone"] = "픽업 구역이 아닙니다."
ctld.i18n["ko"]["No one to unload"] = "내릴 사람 없음"
ctld.i18n["ko"]["Dropped troops back to base"] = "병력을 기지로 돌려보냈습니다."
ctld.i18n["ko"]["Dropped vehicles back to base"] = "차량을 기지로 돌려보냈습니다."
ctld.i18n["ko"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] =
"죄송합니다. %1 그룹이 너무 무겁습니다. \n\n%3 의 무게 제한은 %2 입니다."
ctld.i18n["ko"]["%1 extracted troops in %2 from combat"] = "%1 이 %2 에서 병력을 철수시켰습니다."
ctld.i18n["ko"]["No extractable troops nearby!"] = "철수시킬 병력이 근처에 없습니다!"
ctld.i18n["ko"]["%1 extracted vehicles in %2 from combat"] = "%1 이 %2 에서 차량을 철수시켰습니다."
ctld.i18n["ko"]["No extractable vehicles nearby!"] = "철수시킬 차량이 근처에 없습니다!"
ctld.i18n["ko"]["%1 troops onboard (%2 kg)\n"] = "탑승중인 병력 : %1 (%2 kg)\n"
ctld.i18n["ko"]["%1 vehicles onboard (%2)\n"] = "적재된 차량 : %1 (%2 kg)\n"
ctld.i18n["ko"]["1 FOB Crate oboard (%1 kg)\n"] = "FOB 화물 1개 적재됨 (%1 kg)\n"
ctld.i18n["ko"]["%1 crate onboard (%2 kg)\n"] = "적재된 화물 : %1 (%2 kg)\n"
ctld.i18n["ko"]["Total weight of cargo : %1 kg\n"] = "총 화물 무게 : %1 kg\n"
ctld.i18n["ko"]["No cargo."] = "화물 없음."
ctld.i18n["ko"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
"%1 화물 위 호버링 중. \n\n%2 초 동안 호버링하세요! \n\n카운트다운이 멈추면 너무 멀다는 뜻입니다!"
ctld.i18n["ko"]["Loaded %1 crate!"] = "%1 화물 적재 완료!"
ctld.i18n["ko"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = "%1 화물을 싣기에 너무 낮습니다.\n\n%2 초 동안 호버링하세요."
ctld.i18n["ko"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = "%1 화물을 싣기에 너무 높습니다.\n\n%2 초 동안 호버링하세요."
ctld.i18n["ko"]["You must land before you can load a crate!"] = "화물을 싣기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["No Crates within 50m to load!"] = "50m 내에 실을 화물이 없습니다!"
ctld.i18n["ko"]["Maximum number of crates are on board!"] = "이미 화물을 최대로 실었습니다!"
ctld.i18n["ko"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 화물 - kg %3 - %4 m - %5 시 방향"
ctld.i18n["ko"]["FOB Crate - %1 m - %2 o'clock\n"] = "FOB 화물 - %1 m - %2 시 방향\n"
ctld.i18n["ko"]["No Nearby Crates"] = "근처 화물 없음."
ctld.i18n["ko"]["Nearby Crates:\n%1"] = "근처 화물:\n%1"
ctld.i18n["ko"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = "근처 FOB 화물 (슬링로드 불가):\n%1"
ctld.i18n["ko"]["FOB Positions:"] = "FOB 위치:"
ctld.i18n["ko"]["%1\nFOB @ %2"] = nil
ctld.i18n["ko"]["Sorry, there are no active FOBs!"] = "죄송합니다, 활성화된 FOB가 없습니다."
ctld.i18n["ko"]["You can't unpack that here! Take it to where it's needed!"] = "여기에 풀 수 없습니다! 필요한 곳에 가져가세요!"
ctld.i18n["ko"]["Sorry you must move this crate before you unpack it!"] = "죄송합니다, 풀기 전에 이 화물을 옮겨야 합니다!"
ctld.i18n["ko"]["%1 successfully deployed %2 to the field"] = "%1 이 %2 를 성공적으로 배치했습니다."
ctld.i18n["ko"]["No friendly crates close enough to unpack, or crate too close to aircraft."] =
"풀 아군 화물이 가깝지 않거나 너무 가깝습니다."
ctld.i18n["ko"]["Finished building FOB! Crates and Troops can now be picked up."] = "FOB 건설 완료! 이제 화물과 병력을 실을 수 있습니다."
ctld.i18n["ko"]["Finished building FOB! Crates can now be picked up."] = "FOB 건설 완료! 이제 화물을 실을 수 있습니다."
ctld.i18n["ko"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
"%1 이 %2 개의 FOB 화물을 이용하여 FOB 건설을 시작했습니다. %3 초 후 완료됩니다.\n위치가 연막으로 표시됐습니다."
ctld.i18n["ko"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
"FOB를 건설할 수 없습니다!\n\n%1 개의 FOB 화물 - 大 가 필요합니다! (3개의 FOB 화물 - 小 는 1개의 FOB 화물 - 大 와 동일합니다.) 근처에 %2 개의 FOB 화물 - 大 가 있습니다.\n\n또는 화물들이 서로 750m 거리보다 멀리 있습니다."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 화물 위에서 %1 초 동안 호버링하거나 착륙하여 F10 화물 명령어를 사용하세요."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 화물 위에서 %1 초 동안 호버링하세요."
ctld.i18n["ko"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
"현재 화물을 운송하고 있지 않습니다. \n\n화물을 실으려면, 착륙하여 F10 화물 명령어를 사용하세요."
ctld.i18n["ko"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = "%1 화물이 안전하게 내려졌고 %2 시 방향에 있습니다."
ctld.i18n["ko"]["%1 crate has been safely dropped below you"] = "%1 화물이 밑에 안전하게 내려졌습니다."
ctld.i18n["ko"]["You were too high! The crate has been destroyed"] = "너무 높았습니다! 화물이 파괴되었습니다."
ctld.i18n["ko"]["Radio Beacons:\n%1"] = "라디오 비콘 :\n%1"
ctld.i18n["ko"]["No Active Radio Beacons"] = "활성화된 라디오 비콘 없음."
ctld.i18n["ko"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 이(가) 라디오 비콘을 배치했습니다.\n\n%2"
ctld.i18n["ko"]["You need to land before you can deploy a Radio Beacon!"] = "라디오 비콘을 배치하려면 착륙해야 합니다!"
ctld.i18n["ko"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 이(가) 라디오 비콘을 제거했습니다.\n\n%2"
ctld.i18n["ko"]["No Radio Beacons within 500m."] = "500m 내에 라디오 비콘 없음."
ctld.i18n["ko"]["You need to land before remove a Radio Beacon"] = "라디오 비콘을 제거하려면 착륙해야 합니다."
ctld.i18n["ko"]["%1 successfully rearmed a full %2 in the field"] = "%1 이(가) %2 을(를) 성공적으로 재무장 시켰습니다."
ctld.i18n["ko"]["Missing %1\n"] = "%1 없음\n"
ctld.i18n["ko"]["Out of parts for AA Systems. Current limit is %1\n"] = "방공 시스템 필요 부분 없음. 현재 제한 : %1\n"
ctld.i18n["ko"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] =
"%1 건설 불가\n%2\n\n또는 화물이 서로 가까이 있지 않습니다."
ctld.i18n["ko"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] =
"%1 이(가) 완전한 %2 를 성공적으로 투입했습니다. \n\n방공 시스템 제한 : %3\n활성화된 방공 시스템 : %4"
ctld.i18n["ko"]["%1 successfully repaired a full %2 in the field."] = "%1 이(가) 완전한 %2 을(를) 성공적으로 수리했습니다."
ctld.i18n["ko"]["Cannot repair %1. No damaged %2 within 300m"] = "%1 수리 불가. 300m 내에 손상을 입은 %2 없음."
ctld.i18n["ko"]["%1 successfully deployed %2 to the field using %3 crates."] =
"%1 이 %3 개의 화물을 이용하여 %2 을(를) 성공적으로 배치했습니다."
ctld.i18n["ko"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] =
"%1 건설 불가!\n\n%2 개의 화물이 필요하지만 %3 개 있습니다. \n\n또는 화물들이 서로 300m 내의 거리에 있지 않습니다."
ctld.i18n["ko"]["%1 dropped %2 smoke."] = "%1 이(가) %2 연막을 투하했습니다."

--- JTAC messages
ctld.i18n["ko"]["JTAC Group %1 KIA!"] = "JTAC 그룹 %1 전사!"
ctld.i18n["ko"]["%1, selected target reacquired, %2"] = "%1, 선택된 목표물 재습득, %2"
ctld.i18n["ko"][". CODE: %1. POSITION: %2"] = ". 코드: %1. 위치: %2"
ctld.i18n["ko"]["new target, "] = "새 목표물, "
ctld.i18n["ko"]["standing by on %1"] = "%1 대기 중"
ctld.i18n["ko"]["lasing %1"] = "%1 레이저 조준 중"
ctld.i18n["ko"][", temporarily %1"] = ", 임시로 %1"
ctld.i18n["ko"]["target lost"] = "목표물 놓침"
ctld.i18n["ko"]["target destroyed"] = "목표물 파괴됨"
ctld.i18n["ko"][", selected %1"] = ", %1 선택 완료"
ctld.i18n["ko"]["%1 %2 target lost."] = "%1 %2 목표물 놓침."
ctld.i18n["ko"]["%1 %2 target destroyed."] = "%1 %2 목표물 파괴됨."
ctld.i18n["ko"]["JTAC STATUS: \n\n"] = "JTAC 상태 : \n\n"
ctld.i18n["ko"][", available on %1 %2,"] = ", %1 %2 가능,"
ctld.i18n["ko"]["UNKNOWN"] = "미상"
ctld.i18n["ko"][" targeting "] = " 조준 중 : "
ctld.i18n["ko"][" targeting selected unit "] = " 선택한 유닛 조준 중 "
ctld.i18n["ko"][" attempting to find selected unit, temporarily targeting "] = " 선택한 유닛 찾는 중, 임시로 조준 중 : "
ctld.i18n["ko"]["(Laser OFF) "] = "(레이저 끔) "
ctld.i18n["ko"]["Visual On: "] = "육안 식별 : "
ctld.i18n["ko"][" searching for targets %1\n"] = " %1 목표물 찾는 중\n"
ctld.i18n["ko"]["No Active JTACs"] = "활성화된 JTAC 없음"
ctld.i18n["ko"][", targeting selected unit, %1"] = ", 선택한 유닛 조준 중, %1"
ctld.i18n["ko"][". CODE: %1. POSITION: %2"] = ". 코드: %1. 위치: %2"
ctld.i18n["ko"][", target selection reset."] = ", 목표물 선택 초기화."
ctld.i18n["ko"]["%1, laser and smokes enabled"] = "%1, 레이저 및 연막 사용"
ctld.i18n["ko"]["%1, laser and smokes disabled"] = "%1, 레이저 및 연막 미사용"
ctld.i18n["ko"]["%1, wind and target speed laser spot compensations enabled"] = "%1, 바람, 목표물 속도 보정 사용"
ctld.i18n["ko"]["%1, wind and target speed laser spot compensations disabled"] = "%1, 바람, 목표물 속도 보정 미사용"
ctld.i18n["ko"]["%1, WHITE smoke deployed near target"] = "%1, 목표물 근처 백색 연막"

--- F10 menu messages
ctld.i18n["ko"]["Actions"] = "행동"
ctld.i18n["ko"]["Troop Transport"] = "병력 수송"
ctld.i18n["ko"]["Unload / Extract Troops"] = "병력 하차 / 철수"
ctld.i18n["ko"]["Next page"] = "다음 페이지"
ctld.i18n["ko"]["Load "] = "싣기 : "
ctld.i18n["ko"]["Vehicle / FOB Transport"] = "차량 / FOB 수송"
ctld.i18n["ko"]["Vehicle / FOB Crates"] = "차량 / FOB 화물"
ctld.i18n["ko"]["Unload Vehicles"] = "차량 하역"
ctld.i18n["ko"]["Load / Extract Vehicles"] = "차량 적재 / 철수"
ctld.i18n["ko"]["Load / Unload FOB Crate"] = "FOB 화물 적재 / 철수"
ctld.i18n["ko"]["CTLD Commands"] = "CTLD 명령"
ctld.i18n["ko"]["CTLD"] = "CTLD"
ctld.i18n["ko"]["Check Cargo"] = "화물 확인"
ctld.i18n["ko"]["Load Nearby Crate"] = "근처 화물 싣기"
ctld.i18n["ko"]["Unpack Any Crate"] = "화물 풀기"
ctld.i18n["ko"]["Drop Crate"] = "화물 투하"
ctld.i18n["ko"]["List Nearby Crates"] = "근처 화물 목록"
ctld.i18n["ko"]["List FOBs"] = "FOB 목록"
ctld.i18n["ko"]["List Beacons"] = "비콘 목록"
ctld.i18n["ko"]["List Radio Beacons"] = "라디오 비콘 목록"
ctld.i18n["ko"]["Smoke Markers"] = "연막 마커"
ctld.i18n["ko"]["Drop Red Smoke"] = "적색 연막 투하"
ctld.i18n["ko"]["Drop Blue Smoke"] = "청색 연막 투하"
ctld.i18n["ko"]["Drop Orange Smoke"] = "주황색 연막 투하"
ctld.i18n["ko"]["Drop Green Smoke"] = "녹색 연막 투하"
ctld.i18n["ko"]["Drop Beacon"] = "비콘 투하"
ctld.i18n["ko"]["Radio Beacons"] = "라디오 비콘"
ctld.i18n["ko"]["Remove Closest Beacon"] = "가까운 비콘 제거"
ctld.i18n["ko"]["JTAC Status"] = "JTAC 상태"
ctld.i18n["ko"]["DISABLE "] = "비활성화 "
ctld.i18n["ko"]["ENABLE "] = "활성화 "
ctld.i18n["ko"]["REQUEST "] = "요청 "
ctld.i18n["ko"]["Reset TGT Selection"] = "TGT 선택 초기화"

--========================================================================================================================
--- Translates a string (text) with parameters (parameters) to the language defined in ctld.i18n_lang
---@param text string The text to translate, with the parameters as %1, %2, etc. (all strings!!!!)
---@param ... any (list) The parameters to replace in the text, in order (all paremeters will be converted to string)
---@return string the translated and formatted text
function ctld.i18n_translate(text, ...)
    local _text

    if not ctld.i18n[ctld.i18n_lang] then
        env.info(string.format(" E - CTLD.i18n_translate: Language %s not found, defaulting to 'en'",
            tostring(ctld.i18n_lang)))
        _text = ctld.i18n["en"][text]
    else
        _text = ctld.i18n[ctld.i18n_lang][text]
    end

    -- default to english
    if _text == nil then
        _text = ctld.i18n["en"][text]
    end

    -- default to the provided text
    if _text == nil or _text == "" then
        _text = text
    end

    if arg and arg.n and arg.n > 0 then
        local _args = {}
        for i = 1, arg.n do
            _args[i] = tostring(arg[i]) or ""
        end
        for i = 1, #_args do
            _text = string.gsub(_text, "%%" .. i, _args[i])
        end
    end

    return _text
end

--========================================================================================================================
-- End : CTLD_i18n.lua 
-- ==================================================================================================== 
-- Start : CTLD_utils.lua 
-- Fichier: ctld_module.lua (Classes complètes et mises à jour)

-- 1. Définition du namespace global 'ctld'
ctld = ctld or {}

-- ====================================================================================================
-- CLASS ctld.utils
-- ====================================================================================================

local utils = {}
ctld.utils = utils
if not ctld.utils.marks then ctld.utils.marks = {}; end

function ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
    local coalitionId = coalitionId or 2
    local markId = ctld.utils.getNextUniqId()

    -- Color
    local tableColor = { 0, 0, 255, 0.4 }  --blue  by default
    if coalitionId == 1 then
        tableColor = { 1, 0, 0, 0.4 }      --red  % of (r,g,b,alpha)    red
    elseif coalitionId == 2 then
        tableColor = { 0, 0, 255, 0.4 }    --blue  % of (r,g,b,alpha)   blue
    elseif coalitionId == 0 then
        tableColor = { 2, 173, 33, 0.4 }   --green  % of (r,g,b,alpha)  neutral
    elseif coalitionId == -1 then
        tableColor = { 247, 179, 30, 0.4 } --orange  % of (r,g,b,alpha) All
    end

    local tableFillColor = { 0, 0, 255, 0.4 } --tableColor
    local lineType = 1                        --solid
    local message = message or ""
    ctld.utils.marks[markId] = message

    --trigger.action.quadToAll(number coalition , number id , vec3 point1 , vec3 point2 , vec3 point3 , vec3 point4 , table color , table fillColor , number lineType , boolean readOnly, string message)
    trigger.action.quadToAll(coalitionId, markId,
        vec3Points1To4[1], vec3Points1To4[2], vec3Points1To4[3], vec3Points1To4[4],
        tableColor, tableFillColor, lineType, true, message)

    --[[-example ------------------------------------------------------------
local heliName = "h1-1"
local triggerUnitObj = Unit.getByName(heliName)
local vec3StartPoint = triggerUnitObj:getPosition().p
local vec3EndPoint = {x = vec3StartPoint.x+1000,z=vec3StartPoint.z+1000,y=vec3StartPoint.y}
ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
]] --
end

--------------------------------------------------------------------------------------------------------
-- Calculates the absolute coordinates (x, y, heading, altitude) of a target point
-- based on a reference point and a relative offset, respecting the DCS coordinate system
-- (X=North, Y=East) and magnetic declination.
---------------------------------------------------------------------------------------------
-- @param refX X coordinate (North) of the reference point.
-- @param refY Y coordinate (East) of the reference point.
-- @param refHeading True/Geographic Heading of the reference unit in degrees.
-- @param refAltitude Altitude of the reference unit.
-- @param offsetAngleInDegrees Angle of the offset relative to the reference heading (0 = directly ahead).
-- @param offsetDistance Distance of the offset.
-- @param offsetHeading True/Geographic Heading for the final point.
-- @param offsetAltitude Altitude difference to add to the reference altitude.
-- @param magneticDeclinationInDegrees Magnetic Declination (subtract from True Heading to get Magnetic Heading).
--
-- @return x Absolute X coordinate (North) of the target point.
-- @return y Absolute Y coordinate (East) of the target point.
-- @return magneticHeadingInDegrees Magnetic Heading of the target point in degrees.
-- @return altitude Absolute altitude of the target point.
---
function ctld.utils.getRelativeCoords(
    refX, refY, refHeading, refAltitude,
    offsetAngleInDegrees, offsetDistanceInMeters,
    offsetHeadingInDegrees, offsetAltitudeInMeters,
    magneticDeclinationInDegrees
)
    -------------------------------------------------------------------------
    -- 1. Convert reference heading (radians → degrees)
    --    refHeading is a DCS true heading in radians, clockwise, 0 = North.
    -------------------------------------------------------------------------
    local refHeadingDeg = math.deg(refHeading)

    -------------------------------------------------------------------------
    -- 2. Compute the world angle used to project the new position.
    --    offsetAngleInDegrees is relative to the aircraft's heading.
    -------------------------------------------------------------------------
    local worldAngleDeg = refHeadingDeg + offsetAngleInDegrees

    -- Convert to radians for math.sin/cos (DCS uses clockwise headings)
    local worldAngleRad = math.rad(worldAngleDeg)

    -------------------------------------------------------------------------
    -- 3. Compute position deltas using DCS Cartesian coordinates:
    --    X axis = South/North, positive to the North.
    --    Y axis (vec3.z) = West/East, positive to the East.
    -------------------------------------------------------------------------
    local dx = math.cos(worldAngleRad) * offsetDistanceInMeters
    local dy = math.sin(worldAngleRad) * offsetDistanceInMeters

    local newX = refX + dx
    local newY = refY + dy

    -------------------------------------------------------------------------
    -- 4. Compute the object's final magnetic heading.
    --
    --    refHeadingDeg            = reference TRUE heading
    --    + offsetHeadingInDegrees = rotation relative to the reference
    --    - magneticDeclination    = convert true → magnetic
    -------------------------------------------------------------------------
    local magneticHeadingDeg =
        refHeadingDeg +
        offsetHeadingInDegrees -
        magneticDeclinationInDegrees

    -- Normalize to 0–360°
    magneticHeadingDeg = (magneticHeadingDeg % 360 + 360) % 360

    -------------------------------------------------------------------------
    -- 5. Compute altitude
    -------------------------------------------------------------------------
    local newAltitude = refAltitude + offsetAltitudeInMeters

    return newX, newY, magneticHeadingDeg, newAltitude
end

--------------------------------------------------------------------------------------------------------
-- Return a Vec2 point relative to  a reference point (position & heading DCS)
function ctld.utils.GetRelativeVec2Coords(refVec2Point, refHeadingInRadians, distanceFromRef,
                                          angleInDegreesFromRefHeading)
    -- absolue Heading in radians
    local absoluteHeadingInRadians = refHeadingInRadians + math.rad(angleInDegreesFromRefHeading)
    -- in DCS : x = Nord (+), z = Est (+)
    local dx = math.cos(absoluteHeadingInRadians) * distanceFromRef -- displacement North/South
    local dy = math.sin(absoluteHeadingInRadians) * distanceFromRef -- displacement Est/West

    local newCoords = {
        x = refVec2Point.x + dx,
        y = refVec2Point.y + dy,
    }
    return newCoords
end

------------------------------------------------------------------------------------
--- Calculates the relative bearing of a destination point from a reference point.
--- The bearing is expressed relative to the reference heading.
---
--- Input conventions (DCS-compatible):
---  - refLat / destLat are in decimal degrees
---  - refLon / destLon are in decimal degrees
---  - refHeading is in DEGREES (user-facing), converted to radians internally
---  - bearing output can be in radians, degrees, or clock position
---
--- Output formats:
---  - "radian" : relative bearing in radians [-pi .. +pi]
---  - "degree" : relative bearing in degrees [0 .. 360[
---  - "clock"  : clock position (12 = ahead, 3 = right, 6 = behind, etc.)
---
--- @param caller string Calling context (for logging)
--- @param refLat number Reference latitude in decimal degrees
--- @param refLon number Reference longitude in decimal degrees
--- @param refHeading number Heading in degrees (0-360)
--- @param destLat number Destination latitude in decimal degrees
--- @param destLon number Destination longitude in decimal degrees
--- @param resultFormat string Output format ("radian", "degree", "clock")
--- @return number, string Relative bearing and format
------------------------------------------------------------------------------------
function ctld.utils.getRelativeBearing(
    caller,
    refLat,
    refLon,
    refHeadingInDegrees,
    destLat,
    destLon,
    resultFormat
)
    -- Input validation
    if not refLat or not refLon or not refHeadingInDegrees or not destLat or not destLon then
        if env and env.error then
            env.error("ctld.utils.getRelativeBearing()." .. tostring(caller) ..
                ": All input values (refLat, refLon, refHeadingInDegrees, destLat, destLon) must be provided.")
        end
        return 0, resultFormat
    end

    -- Convert degrees to radians for calculations
    local refLatRad = math.rad(refLat)
    local refLonRad = math.rad(refLon)
    local destLatRad = math.rad(destLat)
    local destLonRad = math.rad(destLon)

    -- Calculate delta in radians
    local dLat = destLatRad - refLatRad
    local dLon = destLonRad - refLonRad

    -- Calculate bearing using haversine-like formula (forward azimuth)
    -- atan2(sin(dLon) * cos(destLat), cos(refLat) * sin(destLat) - sin(refLat) * cos(destLat) * cos(dLon))
    local trueBearingRad = math.atan2(
        math.sin(dLon) * math.cos(destLatRad),
        math.cos(refLatRad) * math.sin(destLatRad) -
        math.sin(refLatRad) * math.cos(destLatRad) * math.cos(dLon)
    )

    -- Normalize true bearing to [0, 2π)
    if trueBearingRad < 0 then
        trueBearingRad = trueBearingRad + 2 * math.pi
    end

    -- Convert reference heading from degrees to radians
    local refHeadingRad = math.rad(refHeadingInDegrees)

    -- Compute relative bearing (subtract reference heading)
    local relativeRad = trueBearingRad - refHeadingRad

    -- Normalize relative bearing to [-π, +π]
    relativeRad = (relativeRad + math.pi) % (2 * math.pi) - math.pi

    -- Output formats
    if resultFormat == "radian" then
        return relativeRad, resultFormat
    end

    -- Convert to degrees [0, 360)
    local relativeDeg = math.deg(relativeRad)
    if relativeDeg < 0 then
        relativeDeg = relativeDeg + 360
    end

    if resultFormat == "clock" then
        -- 12 o'clock = ahead (0°), each hour = 30 degrees
        -- Clock 3 = right (90°), 6 = behind (180°), 9 = left (270°)
        local clock = math.floor((relativeDeg + 15) / 30) % 12
        if clock == 0 then clock = 12 end
        return clock, resultFormat
    end

    -- Default: degrees [0, 360)
    return relativeDeg, "degree"
end

--------------------------------------------------------------------------------------------------------
--- Returns magnetic variation of given DCS point (vec2 or vec3).
-- borrowed from mist
function ctld.utils.getNorthCorrectionInRadians(caller, vec2OrVec3Point) --gets the correction needed for true north (magnetic variation)
    if vec2OrVec3Point == nil then
        if env and env.error then
            env.error("ctld.utils.getNorthCorrectionInRadians()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return 0
    end

    local point = ctld.utils.deepCopy("ctld.utils.getNorthCorrectionInRadians()", vec2OrVec3Point)
    if not point.z then --Vec2; convert to Vec3
        point.z = point.y
        point.y = 0
    end
    local lat, lon = coord.LOtoLL(point)
    local north_posit = coord.LLtoLO(lat + 1, lon)
    return math.atan(north_posit.z - point.z, north_posit.x - point.x)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:getHeadingInRadians
-- @-- borrowed from mist
---@param unitObject any
---@param rawHeading boolean (true=geographic/false=magnetic)
---@return integer       --- @--return "magneticHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, false)))..", geographicHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, true)))
function ctld.utils.getHeadingInRadians(caller, unitObject, rawHeading) --rawHeading: boolean (true=geographic/false=magnetic)
    if not unitObject then
        if env and env.error then
            env.error("ctld.utils.getHeadingInRadians()." .. tostring(caller) .. ": Invalid unit object provided.")
        end
        return 0
    end
    rawHeading = rawHeading or false
    local unitpos = unitObject:getPosition()
    if unitpos then
        local HeadingInRadians = math.atan2(unitpos.x.z, unitpos.x.x)
        if not rawHeading then
            HeadingInRadians = HeadingInRadians +
                ctld.utils.getNorthCorrectionInRadians("ctld.utils.getHeadingInRadians()", unitpos.p)
        end
        if HeadingInRadians < 0 then
            HeadingInRadians = HeadingInRadians + 2 * math.pi -- put heading in range of 0 to 2*pi
        end
        return HeadingInRadians
    end
    return 0
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec2 to a Vec3.
-- @-- borrowed from mist
-- @tparam Vec2 vec the 2D vector
-- @param y optional new y axis (altitude) value. If omitted it's 0.
function ctld.utils.makeVec3FromVec2OrVec3(caller, vec, y)
    if not vec then
        if env and env.error then
            env.error("ctld.utils.makeVec3FromVec2OrVec3()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return { x = vec.x, y = y, z = vec.y }
    else
        return { x = vec.x, y = vec.y, z = vec.z } -- it was already Vec3, actually.
    end
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec3 to a Vec2.
-- @tparam Vec3 vec the 3D vector
-- @return vector converted to Vec2
function ctld.utils.makeVec2FromVec3OrVec2(caller, vec)
    if vec == nil then
        if env and env.error then
            env.error("ctld.utils.makeVec2FromVec3OrVec2()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if vec.z then
        return { x = vec.x, y = vec.z }
    else
        return { x = vec.x, y = vec.y } -- it was actually already vec2.
    end
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:rotateVec3
-- Calcule l'offset cartésien absolu en appliquant la rotation du cap de l'appareil.
-- (Conçu pour le format de données : relative = {x, y, z})
function ctld.utils.rotateVec3(relativeVec, headingDeg)
    local x_rel = relativeVec.x
    local z_rel = relativeVec.z
    -- y_rel n'est pas utilisé dans le calcul de rotation, mais sera dans le retour
    local y_rel = relativeVec.y or 0

    -- Vérification des données (X et Z sont obligatoires)
    if x_rel == nil or z_rel == nil then
        local msg = "CTLD.utils:rotateVec3: Missing X or Z component in relative position data."
        if env and env.error then
            env.error(msg)
            -- Lève une erreur qui sera capturée par pcall (si appelé)
            error(msg)
        else
            error(msg)
        end
    end

    local headingRad = math.rad(headingDeg)
    local cos_h = math.cos(headingRad)
    local sin_h = math.sin(headingRad)

    local x_rot = (z_rel * sin_h) + (x_rel * cos_h)
    local z_rot = (z_rel * cos_h) - (x_rel * sin_h)

    return { x = x_rot, y = y_rel, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
-- Add 2 position vectors (Vec3) of DCS.
function ctld.utils.addVec3(vec1, vec2)
    return {
        -- Use or 0 to avoid 'nil'
        x = (vec1.x or 0) + (vec2.x or 0),
        y = (vec1.y or 0) + (vec2.y or 0),
        z = (vec1.z or 0) + (vec2.z or 0),
    }
end

--------------------------------------------------------------------------------------------------------
--- Vector substraction.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn Vec3 new vector, vec2 substracted from vec1.
function ctld.utils.subVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.subVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return nil
    end
    return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
end

--------------------------------------------------------------------------------------------------------
--- Vector dot product.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn number dot product of given vectors
function ctld.utils.multVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.multVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

--------------------------------------------------------------------------------------------------------
--- Returns the center of a zone as Vec3.
-- @-- borrowed from mist
-- @tparam string|table zone trigger zone name or table
-- @treturn Vec3 center of the zone
function ctld.utils.zoneToVec3(caller, zone, gl)
    if zone == nil then
        if env and env.error then
            env.error("ctld.utils.zoneToVec3()." .. tostring(caller) .. ": Invalid zone provided.")
        end
        return nil
    end

    local new = {}
    if type(zone) == 'table' then
        if zone.point then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        elseif zone.x and zone.y and zone.z then
            new = ctld.utils.deepCopy("ctld.utils.zoneToVec3()", zone)
        end
        return new
    elseif type(zone) == 'string' then
        zone = trigger.misc.getZone(zone)
        if zone then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        end
    end
    if new.x and gl then
        new.y = land.getHeight({ x = new.x, y = new.z })
    end
    return new
end

--------------------------------------------------------------------------------------------------------
--- Vector magnitude
-- @tparam Vec3 (3D with x,y,z)vec vector
-- @treturn number magnitude of vector vec
function ctld.utils.vec3Mag(caller, vec3)
    if vec3 == nil or vec3.x == nil or vec3.y == nil or vec3.z == nil then
        if env and env.error then
            env.error("ctld.utils.vec3Mag()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return 0
    end

    return (vec3.x ^ 2 + vec3.y ^ 2 + vec3.z ^ 2) ^ 0.5
end

--------------------------------------------------------------------------------------------------------
--- Returns distance in meters between two points.
-- @-- borrowed from mist
-- @tparam Vec2|Vec3 point1 first point
-- @tparam Vec2|Vec3 point2 second point
-- @treturn number distance between given points.
function ctld.utils.get2DDist(caller, point1, point2)
    if point1 == nil or point2 == nil then
        if env and env.error then
            env.error("ctld.utils.get2DDist()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    if not point1 then
        log:warn("ctld.utils.get2DDist()  1st input value is nil")
    end
    if not point2 then
        log:warn("ctld.utils.get2DDist()  2nd input value is nil")
    end
    point1 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point1)
    point2 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point2)
    return ctld.utils.vec3Mag("ctld.utils.get2DDist()", { x = point1.x - point2.x, y = 0, z = point1.z - point2.z })
end

--get distance in meters assuming a Flat world
function ctld.utils.getDistance(caller, _point1, _point2)
    if _point1 == nil or _point2 == nil then
        if env and env.error then
            env.error("ctld.utils.getDistance()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

----------------------------------------------------------------------------------------------------------
-- gets the center of a bunch of points!
-- return proper DCS point with height
function ctld.utils.getCentroid(caller, _points)
    if _points == nil or #_points == 0 then
        if env and env.error then
            env.error("ctld.utils.getCentroid()." .. tostring(caller) .. ": Invalid points provided.")
        end
        return nil
    end
    local _tx, _ty = 0, 0
    for _index, _point in ipairs(_points) do
        _tx = _tx + _point.x
        _ty = _ty + _point.z
    end

    local _npoints = #_points

    local _point = { x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({ _point.x, _point.z })

    return _point
end

--------------------------------------------------------------------------------------------------------
--- Simple rounding function.
-- @-- borrowed from mist
-- From http://lua-users.org/wiki/SimpleRound
-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
-- @tparam number num number to round
-- @param idp
function ctld.utils.round(caller, num, idp)
    if num == nil or type(num) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.round()." .. tostring(caller) .. ": Invalid number provided.")
        end
        return 0
    end
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------------------------------
-- initialize the random number generator to make it almost random
math.random(); math.random(); math.random()
--------------------------------------------------------------------------------------------------------
function ctld.utils.RandomReal(caller, mini, maxi)
    if mini == nil or maxi == nil then
        if env and env.error then
            env.error("ctld.RandomReal()." .. tostring(caller) .. ": Both min and max values must be provided.")
        end
        return 0
    end
    local rand = math.random()                 --random value between 0 and 1
    local result = mini + rand * (maxi - mini) --	scale the random value between [mini, maxi]
    return result
end

--------------------------------------------------------------------------------------------------------
--[[acc:
in DM: decimal point of minutes.
In DMS: decimal point of seconds.
position after the decimal of the least significant digit:
So:
42.32 - acc of 2.
]]
function ctld.utils.tostringLL(caller, lat, lon, acc, DMS)
    if lat == nil or lon == nil then
        if env and env.error then
            env.error("ctld.utils.tostringLL()." .. tostring(caller) .. ": Invalid latitude or longitude provided.")
        end
        return ""
    end
    local latHemi, lonHemi
    if lat > 0 then
        latHemi = 'N'
    else
        latHemi = 'S'
    end

    if lon > 0 then
        lonHemi = 'E'
    else
        lonHemi = 'W'
    end

    lat = math.abs(lat)
    lon = math.abs(lon)

    local latDeg = math.floor(lat)
    local latMin = (lat - latDeg) * 60

    local lonDeg = math.floor(lon)
    local lonMin = (lon - lonDeg) * 60

    if DMS then -- degrees, minutes, and seconds.
        local oldLatMin = latMin
        latMin = math.floor(latMin)
        local latSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLatMin - latMin) * 60, acc)

        local oldLonMin = lonMin
        lonMin = math.floor(lonMin)
        local lonSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLonMin - lonMin) * 60, acc)

        if latSec == 60 then
            latSec = 0
            latMin = latMin + 1
        end

        if lonSec == 60 then
            lonSec = 0
            lonMin = lonMin + 1
        end

        local secFrmtStr -- create the formatting string for the seconds place
        if acc <= 0 then -- no decimal place.
            secFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) ..
            ' ' ..
            string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
            ..
            string.format('%02d', lonDeg) ..
            ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi
    else -- degrees, decimal minutes.
        latMin = ctld.utils.round("ctld.utils.tostringLL()", latMin, acc)
        lonMin = ctld.utils.round("ctld.utils.tostringLL()", lonMin, acc)

        if latMin == 60 then
            latMin = 0
            latDeg = latDeg + 1
        end

        if lonMin == 60 then
            lonMin = 0
            lonDeg = lonDeg + 1
        end

        local minFrmtStr -- create the formatting string for the minutes place
        if acc <= 0 then -- no decimal place.
            minFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
            .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi
    end
end

--------------------------------------------------------------------------------------------------------
--- Returns MGRS coordinates as string.
-- @tparam string MGRS MGRS coordinates
-- @tparam number acc the accuracy of each easting/northing.
-- Can be: 0, 1, 2, 3, 4, or 5.
function ctld.utils.tostringMGRS(caller, MGRS, acc)
    if MGRS == nil or MGRS == "" or type(MGRS) ~= 'string' then
        if env and env.error then
            env.error("ctld.utils.tostringMGRS()." .. tostring(caller) .. ": Invalid MGRS coordinates provided.")
        end
        return ""
    end
    if acc == 0 then
        return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
    else
        return MGRS.UTMZone ..
            ' ' ..
            MGRS.MGRSDigraph ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Easting / (10 ^ (5 - acc)), 0))
            ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Northing / (10 ^ (5 - acc)), 0))
    end
end

--------------------------------------------------------------------------------------------------------
ctld.utils.UniqIdCounter = 0 -- Compteur statique pour les ID uniques
--- @function ctld.utils:getNextUniqId
-- Génère un ID unique incrémental, comme requis pour 'unitId' dans groupData.
function ctld.utils.getNextUniqId()
    ctld.utils.UniqIdCounter = ctld.utils.UniqIdCounter + 1
    return ctld.utils.UniqIdCounter
end

--- Converts angle in radians to degrees.
-- @param angle angle in radians
-- @return angle in degrees
function ctld.utils.radianToDegree(caller, angleInRadians)
    if angle == nil or type(angle) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.toDegree()." .. tostring(caller) .. ": Invalid angle provided.")
        end
        return 0
    end
    return math.deg(angleInRadians)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:normalizeHeading
-- Normalise a heading between 0 et 360 degrees.
function ctld.utils.normalizeHeadingInDegrees(caller, offsetHeadingInDegrees)
    if offsetHeadingInDegrees == nil then
        if env and env.error then
            env.error("CTLD.utils.normalizeHeadingInDegrees()." .. tostring(caller) .. ": Invalid heading provided.")
        end
        return 0
    end
    local result = offsetHeadingInDegrees % 360
    if result < 0 then
        result = result + 360
    end
    return result
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:polarToCartesian
-- Convertit une distance (rho), un angle (theta) et un cap de référence (headingDeg)
-- en coordonnées cartésiennes absolues (x, z) de la carte DCS.
-- @param distance number La distance au point de référence.
-- @param relativeAngle number L'angle relatif au point de référence (0 = devant, 90 = droite).
-- @param headingDeg number Le cap absolu de l'appareil (point de référence).
-- @return table L'offset cartésien absolu { x, y=0, z }.
function ctld.utils.polarToCartesian(distance, relativeAngle, headingDeg)
    local absoluteAngle = headingDeg + relativeAngle
    local angleRad = math.rad(absoluteAngle)

    -- Correction du facteur distance (20m -> 10m)
    local dist = (distance or 0) * 2

    -- X (Nord/Sud, l'axe de référence du cap 0°) : Utilise COS
    local x_rot = dist * math.cos(angleRad)

    -- Z (Est/Ouest) : Utilise SIN. La trigonométrie standard sin(angle) augmente CCW.
    -- Nous ne touchons pas au signe car la trigonométrie de DCS peut être non standard.
    local z_rot = dist * math.sin(angleRad)

    return { x = x_rot, y = 0, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
--- Converts kilometers per hour to meters per second.
-- @param kmph speed in km/h
-- @return speed in m/s
function ctld.utils.kmphToMps(caller, kmph)
    if kmph == nil or type(kmph) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.kmphToMps()." .. tostring(caller) .. ": Invalid speed provided.")
        end
        return 0
    end
    return kmph / 3.6
end

--------------------------------------------------------------------------------------------------------
--- Builds a ground waypoint from a point definition.
-- No longer accepts path
function ctld.utils.buildWP(caller, point, overRideForm, overRideSpeed)
    if point == nil then
        if env and env.error then
            env.error("ctld.utils.buildWP()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return nil
    end

    local wp = {}
    wp.x = point.x

    if point.z then
        wp.y = point.z
    else
        wp.y = point.y
    end
    local form, speed

    if point.speed and not overRideSpeed then
        wp.speed = point.speed
    elseif type(overRideSpeed) == 'number' then
        wp.speed = overRideSpeed
    else
        wp.speed = ctld.utils.kmphToMps("ctld.utils.buildWP()", 20)
    end

    if point.form and not overRideForm then
        form = point.form
    else
        form = overRideForm
    end

    if not form then
        wp.action = 'Cone'
    else
        form = string.lower(form)
        if form == 'off_road' or form == 'off road' then
            wp.action = 'Off Road'
        elseif form == 'on_road' or form == 'on road' then
            wp.action = 'On Road'
        elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest' then
            wp.action = 'Rank'
        elseif form == 'cone' then
            wp.action = 'Cone'
        elseif form == 'diamond' then
            wp.action = 'Diamond'
        elseif form == 'vee' then
            wp.action = 'Vee'
        elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
            wp.action = 'EchelonL'
        elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
            wp.action = 'EchelonR'
        else
            wp.action = 'Cone' -- if nothing matched
        end
    end

    wp.type = 'Turning Point'

    return wp
end

--------------------------------------------------------------------------------------------------------
function ctld.utils.getUnitsLOS(caller, unitset1, altoffset1, unitset2, altoffset2, radius)
    --log:info("$1, $2, $3, $4, $5", unitset1, altoffset1, unitset2, altoffset2, radius)
    if unitset1 == nil or unitset2 == nil or altoffset1 == nil or altoffset2 == nil or radius == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsLOS()." .. tostring(caller) .. ": parameters sets cannot be nil.")
        end
        return {}
    end

    radius = radius or math.huge
    local unit_info1 = {}
    local unit_info2 = {}

    -- get the positions all in one step, saves execution time.
    for unitset1_ind = 1, #unitset1 do
        local unit1 = Unit.getByName(unitset1[unitset1_ind])
        if unit1 then
            local lCat = Object.getCategory(unit1)
            if ((lCat == 1 and unit1:isActive()) or lCat ~= 1) and unit1:isExist() == true then
                unit_info1[#unit_info1 + 1] = {}
                unit_info1[#unit_info1].unit = unit1
                unit_info1[#unit_info1].pos = unit1:getPosition().p
            end
        end
    end

    for unitset2_ind = 1, #unitset2 do
        local unit2 = Unit.getByName(unitset2[unitset2_ind])
        if unit2 then
            local lCat = Object.getCategory(unit2)
            if ((lCat == 1 and unit2:isActive()) or lCat ~= 1) and unit2:isExist() == true then
                unit_info2[#unit_info2 + 1] = {}
                unit_info2[#unit_info2].unit = unit2
                unit_info2[#unit_info2].pos = unit2:getPosition().p
            end
        end
    end

    local LOS_data = {}
    -- now compute los
    for unit1_ind = 1, #unit_info1 do
        local unit_added = false
        for unit2_ind = 1, #unit_info2 do
            if radius == math.huge or (ctld.utils.vec3Mag("ctld.utils.getUnitsLOS()", ctld.utils.subVec3("ctld.utils.getUnitsLOS()", unit_info1[unit1_ind].pos, unit_info2[unit2_ind].pos)) < radius) then -- inside radius
                local point1 = {
                    x = unit_info1[unit1_ind].pos.x,
                    y = unit_info1[unit1_ind].pos.y + altoffset1,
                    z =
                        unit_info1[unit1_ind].pos.z
                }
                local point2 = {
                    x = unit_info2[unit2_ind].pos.x,
                    y = unit_info2[unit2_ind].pos.y + altoffset2,
                    z =
                        unit_info2[unit2_ind].pos.z
                }
                if land.isVisible(point1, point2) then
                    if unit_added == false then
                        unit_added = true
                        LOS_data[#LOS_data + 1] = {}
                        LOS_data[#LOS_data].unit = unit_info1[unit1_ind].unit
                        LOS_data[#LOS_data].vis = {}
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    else
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    end
                end
            end
        end
    end

    return LOS_data
end

--------------------------------------------------------------------------------------------------------
--- Returns GroundUnitsListNames for a given coalition
function ctld.utils.getUnitsListNamesByCategory(caller, coalitionId, categoryTable)
    if coalitionId == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsListNamesByCategory()." ..
                tostring(caller) .. ": Invalid coalition ID provided.")
        end
        return {}
    end

    if categoryTable == nil then -- all categories requested
        categoryTable = {
            Group.Category.AIRPLANE,
            Group.Category.HELICOPTER,
            Group.Category.GROUND,
            Group.Category.SHIP,
            Group.Category.TRAIN,
        }
    end

    local groupList = {}
    for _, v in ipairs(categoryTable) do
        local categGroupList = coalition.getGroups(coalitionId, v)
        if categGroupList then
            for _, group in ipairs(categGroupList) do
                table.insert(groupList, group)
            end
        end
    end

    local UnitsListNames = {}
    for _, v in ipairs(groupList) do
        local groupUnits = v:getUnits()
        for _, vv in ipairs(groupUnits) do
            UnitsListNames[#UnitsListNames + 1] = vv:getName()
        end
    end
    return UnitsListNames
end

--------------------------------------------------------------------------------------------------------
-- same as getGroupPoints but returns speed and formation type along with vec2 of point}
function ctld.utils.getGroupRoute(caller, groupName, task)
    if groupName == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupRoute()." .. tostring(caller) .. ": Invalid group name provided.")
        end
        return nil
    end
    -- refactor to search by groupId and allow groupId and groupName as inputs
    local gpId = groupName
    --if mist.DBs.MEgroupsByName[groupName] then
    if Group.getByName[groupName] then
        gpId = Group.getByName[groupName]:getID()
    else
        log:error("ctld.utils.getGroupRoute()." .. tostring(caller) .. '$1 not found in mist.DBs.MEgroupsByName',
            groupName)
    end

    for coa_name, coa_data in pairs(env.mission.coalition) do
        if type(coa_data) == 'table' then
            if coa_data.country then --there is a country table
                for cntry_id, cntry_data in pairs(coa_data.country) do
                    for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                        if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then                       -- only these types have points
                            if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
                                for group_num, group_data in pairs(obj_cat_data.group) do
                                    if group_data and group_data.groupId == gpId then                                                                                -- this is the group we are looking for
                                        if group_data.route and group_data.route.points and #group_data.route.points > 0 then
                                            local points = {}

                                            for point_num, point in pairs(group_data.route.points) do
                                                local routeData = {}
                                                if env.mission.version > 7 and env.mission.version < 19 then
                                                    routeData.name = env.getValueDictByKey(point.name)
                                                else
                                                    routeData.name = point.name
                                                end
                                                if not point.point then
                                                    routeData.x = point.x
                                                    routeData.y = point.y
                                                else
                                                    routeData.point = point
                                                        .point --it's possible that the ME could move to the point = Vec2 notation.
                                                end
                                                routeData.form = point.action
                                                routeData.speed = point.speed
                                                routeData.alt = point.alt
                                                routeData.alt_type = point.alt_type
                                                routeData.airdromeId = point.airdromeId
                                                routeData.helipadId = point.helipadId
                                                routeData.type = point.type
                                                routeData.action = point.action
                                                if task then
                                                    routeData.task = point.task
                                                end
                                                points[point_num] = routeData
                                            end

                                            return points
                                        end
                                        log:error('Group route not defined in mission editor for groupId: $1', gpId)
                                        return
                                    end --if group_data and group_data.name and group_data.name == 'groupname'
                                end     --for group_num, group_data in pairs(obj_cat_data.group) do
                            end         --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
                        end             --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
                    end                 --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                end                     --for cntry_id, cntry_data in pairs(coa_data.country) do
            end                         --if coa_data.country then --there is a country table
        end                             --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
    end                                 --for coa_name, coa_data in pairs(mission.coalition) do
end

--------------------------------------------------------------------------------------------------------
--- Returns the groupId for a given unit.
function ctld.utils.getGroupId(caller, _unitId)
    if _unitId == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupId()." .. tostring(caller) .. ": Invalid unit provided.")
        end
        return nil
    end

    return _unitId:getGroup():getID()
end

--------------------------------------------------------------------------------------------------------
--- Spawns a static object to the game world.
-- Borrowed from mist.dynAddStatic and modified.
-- @todo write good docs
-- @tparam table staticObj table containing data needed for the object creation
function ctld.utils.dynAddStatic(caller, n)
    if n == nil then
        if env and env.error then
            env.error("ctld.utils.dynAddStatic()." .. tostring(caller) .. ": Invalid static object data provided.")
        end
        return false
    end
    --local newObj = mist.utils.deepCopy(n)
    local newObj = ctld.utils.deepCopy("ctld.utils.dynAddStatic()", n)
    --log:warn(newObj)
    if newObj.units and newObj.units[1] then -- if its mist format
        for entry, val in pairs(newObj.units[1]) do
            if newObj[entry] and newObj[entry] ~= val or not newObj[entry] then
                newObj[entry] = val
            end
        end
    end
    --log:info(newObj)

    local cntry = newObj.country
    if newObj.countryId then
        cntry = newObj.countryId
    end

    local newCountry = ''

    for countryId, countryName in pairs(country.name) do
        if type(cntry) == 'string' then
            cntry = cntry:gsub("%s+", "_")
            if tostring(countryName) == string.upper(cntry) then
                newCountry = countryName
            end
        elseif type(cntry) == 'number' then
            if countryId == cntry then
                newCountry = countryName
            end
        end
    end

    if newCountry == '' then
        log:error("Country not found: $1", cntry)
        return false
    end

    if newObj.clone or not newObj.groupId then
        newObj.groupId = ctld.utils.getNextUniqId()
    end

    if newObj.clone or not newObj.unitId then
        newObj.unitId = ctld.utils.getNextUniqId()
    end

    newObj.name = newObj.name or newObj.unitName

    if newObj.clone or not newObj.name then
        newObj.name = (newCountry .. ' static ' .. tostring(newObj.groupId))
    end

    if not newObj.dead then
        newObj.dead = false
    end

    if not newObj.heading then
        newObj.heading = math.rad(math.random(360))
    end

    if newObj.categoryStatic then
        newObj.category = newObj.categoryStatic
    end
    if newObj.mass then
        newObj.category = 'Cargos'
    end

    if newObj.shapeName then
        newObj.shape_name = newObj.shapeName
    end

    if not newObj.shape_name then
        log:info('shape_name not present')
    end
    if newObj.x and newObj.y and newObj.type and type(newObj.x) == 'number' and type(newObj.y) == 'number' and type(newObj.type) == 'string' then
        --log:warn(newObj)
        coalition.addStaticObject(country.id[newCountry], newObj)

        return newObj
    end
    log:error("Failed to add static object due to missing or incorrect value. X: $1, Y: $2, Type: $3", newObj.x,
        newObj.y, newObj.type)
    return false
end

--------------------------------------------------------------------------------------------------------
--- Spawns a dynamic group into the game world.
-- Borrowed from mist.dynAddStatic and modified.
-- Will generate groupId, groupName, unitId, and unitName if needed
-- @tparam table newGroup table containting values needed for spawning a group.
function ctld.utils.dynAdd(caller, ng)
    if ng == nil then
        if env and env.error then
            env.error("ctld.utils.dynAdd()." .. tostring(caller) .. ": Invalid group data provided.")
        end
        return false
    end
    local newGroup = ctld.utils.deepCopy(" ctld.utils.dynAdd()", ng)
    --log:warn(newGroup)
    --mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, 'newGroupOrig.lua')
    local cntry = newGroup.country
    if newGroup.countryId then
        cntry = newGroup.countryId
    end

    local groupType = newGroup.category
    local newCountry = ''
    -- validate data
    for countryId, countryName in pairs(country.name) do
        if type(cntry) == 'string' then
            cntry = cntry:gsub("%s+", "_")
            if tostring(countryName) == string.upper(cntry) then
                newCountry = countryName
            end
        elseif type(cntry) == 'number' then
            if countryId == cntry then
                newCountry = countryName
            end
        end
    end

    if newCountry == '' then
        log:error("Country not found: $1", cntry)
        return false
    end

    local newCat = ''
    for catName, catId in pairs(Unit.Category) do
        if type(groupType) == 'string' then
            if tostring(catName) == string.upper(groupType) then
                newCat = catName
            end
        elseif type(groupType) == 'number' then
            if catId == groupType then
                newCat = catName
            end
        end

        if catName == 'GROUND_UNIT' and (string.upper(groupType) == 'VEHICLE' or string.upper(groupType) == 'GROUND') then
            newCat = 'GROUND_UNIT'
        elseif catName == 'AIRPLANE' and string.upper(groupType) == 'PLANE' then
            newCat = 'AIRPLANE'
        end
    end
    local typeName
    if newCat == 'GROUND_UNIT' then
        typeName = ' gnd '
    elseif newCat == 'AIRPLANE' then
        typeName = ' air '
    elseif newCat == 'HELICOPTER' then
        typeName = ' hel '
    elseif newCat == 'SHIP' then
        typeName = ' shp '
    elseif newCat == 'BUILDING' then
        typeName = ' bld '
    end
    if newGroup.clone or not newGroup.groupId then
        newGroup.groupId = ctld.utils.getNextUniqId()
    end
    if newGroup.groupName or newGroup.name then
        if newGroup.groupName then
            newGroup.name = newGroup.groupName
        elseif newGroup.name then
            newGroup.name = newGroup.name
        end
    else
        newGroup.name = tostring(newCountry) .. "_" .. tostring(typeName) .. "_" .. tostring(newGroup.groupId)
    end

    if not newGroup.hidden then
        newGroup.hidden = false
    end

    if not newGroup.visible then
        newGroup.visible = false
    end

    if (newGroup.start_time and type(newGroup.start_time) ~= 'number') or not newGroup.start_time then
        if newGroup.startTime then
            newGroup.start_time = ctld.utils.round("mist.dynAdd()", newGroup.start_time)
        else
            newGroup.start_time = 0
        end
    end


    for unitIndex, unitData in pairs(newGroup.units) do
        local originalName = newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name
        if newGroup.clone or not unitData.unitId then
            newGroup.units[unitIndex].unitId = ctld.utils.getNextUniqId()
        end
        if newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name then
            if newGroup.units[unitIndex].unitName then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].unitName
            elseif newGroup.units[unitIndex].name then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].name
            end
        end
        if not unitData.name then
            newGroup.units[unitIndex].name = tostring(newGroup.name) .. '_unit_' .. tostring(unitIndex)
        end

        if not unitData.skill then
            newGroup.units[unitIndex].skill = 'Random'
        end

        if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
            if newGroup.units[unitIndex].alt_type and newGroup.units[unitIndex].alt_type ~= 'BARO' or not newGroup.units[unitIndex].alt_type then
                newGroup.units[unitIndex].alt_type = 'RADIO'
            end
            if not unitData.speed then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].speed = 60
                end
            end
            -- if not unitData.payload then
            --     newGroup.units[unitIndex].payload = mist.getPayload(originalName)
            -- end
            if not unitData.alt then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].alt = 2000
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].alt = 500
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 60
                end
            end
        elseif newCat == 'GROUND_UNIT' then
            if nil == unitData.playerCanDrive then
                unitData.playerCanDrive = true
            end
        end
    end
    if newGroup.route then
        if newGroup.route and not newGroup.route.points then
            if newGroup.route[1] then
                local copyRoute = ctld.utils.deepCopy("ctld.utils.dynAdd()", newGroup.route)
                newGroup.route = {}
                newGroup.route.points = copyRoute
            end
        end
    else -- if aircraft and no route assigned. make a quick and stupid route so AI doesnt RTB immediately
        --if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
        newGroup.route = {}
        newGroup.route.points = {}
        newGroup.route.points[1] = {}
        --end
    end
    newGroup.country = newCountry

    -- update and verify any self tasks
    if newGroup.route and newGroup.route.points then
        --log:warn(newGroup.route.points)
        for i, pData in pairs(newGroup.route.points) do
            if pData.task and pData.task.params and pData.task.params.tasks and #pData.task.params.tasks > 0 then
                for tIndex, tData in pairs(pData.task.params.tasks) do
                    if tData.params and tData.params.action then
                        if tData.params.action.id == "EPLRS" then
                            tData.params.action.params.groupId = newGroup.groupId
                        elseif tData.params.action.id == "ActivateBeacon" or tData.params.action.id == "ActivateICLS" then
                            tData.params.action.params.unitId = newGroup.units[1].unitId
                        end
                    end
                end
            end
        end
    end
    --mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, newGroup.name ..'.lua')
    --log:warn(newGroup)
    -- sanitize table
    newGroup.groupName = nil
    newGroup.clone = nil
    newGroup.category = nil
    newGroup.country = nil

    newGroup.tasks = {}

    for unitIndex, unitData in pairs(newGroup.units) do
        newGroup.units[unitIndex].unitName = nil
    end

    ctld.logTrace("ctld.utils.dynAdd().nexGroup =  %s", ctld.p(newGroup))
    coalition.addGroup(country.id[newCountry], Unit.Category[newCat], newGroup)

    return newGroup
end

--------------------------------------------------------------------------------------------------------
--Gets the average position of a group of units (by name)
function ctld.utils.getAvgPos(caller, unitNames)
    if unitNames == nil or #unitNames == 0 then
        if env and env.error then
            env.error("ctld.utils.getAvgPos()." .. tostring(caller) .. ": Invalid unit names provided.")
        end
        return nil
    end

    local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
    for i = 1, #unitNames do
        local unit
        if Unit.getByName(unitNames[i]) then
            unit = Unit.getByName(unitNames[i])
        elseif StaticObject.getByName(unitNames[i]) then
            unit = StaticObject.getByName(unitNames[i])
        end
        if unit and unit:isExist() == true then
            local pos = unit:getPosition().p
            if pos then -- you never know O.o
                avgX = avgX + pos.x
                avgY = avgY + pos.y
                avgZ = avgZ + pos.z
                totNum = totNum + 1
            end
        end
    end
    if totNum ~= 0 then
        return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
    end
end

--------------------------------------------------------------------------------------------------------
--- Checks if a value exists in an ipairs table.
function ctld.utils.isValueInIpairTable(caller, tab, value)
    if tab == nil or type(tab) ~= "table" then
        if env and env.error then
            env.error("ctld.utils.isValueInIpairTable()." .. tostring(caller) .. ": Invalid table provided.")
        end
        return false
    end
    for i, v in ipairs(tab) do
        if v == value then
            return true -- La valeur existe
        end
    end
    return false -- La valeur n'existe pas
end

--------------------------------------------------------------------------------------------------------
--- Counts the number of entries in a table.
function ctld.utils.countTableEntries(caller, _table)
    if type(_table) ~= "table" then
        if env and env.error then
            env.error("ctld.utils.countTableEntries()." .. tostring(caller) .. ": Invalid table provided.")
        end
        return 0
    end
    if _table == nil then
        return 0
    end

    local _count = 0
    for _key, _value in pairs(_table) do
        _count = _count + 1
    end

    return _count
end

--------------------------------------------------------------------------------------------------------
--- Creates a deep copy of a object.
-- @-- borrowed from mist
-- Usually this object is a table.
-- See also: from http://lua-users.org/wiki/CopyTable
-- @param object object to copy
-- @return copy of object
function ctld.utils.deepCopy(caller, object)
    local lookup_table = {}
    if object == nil then
        if env and env.error then
            env.error("ctld.utils.deepCopy()." .. tostring(caller) .. ": Attempt to deep copy a nil object.")
        end
        return nil
    end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--------------------------------------------------------------------------------------------------------
--- return table as a lua script string
function ctld.utils.tableShowScript(caller, tblObj, tblName)
    if tblObj == nil then
        if env and env.error then
            env.error("ctld.utils.tableShowScript(): Attempt to show a nil table.")
        end
        return "nil"
    end
    if tblName == nil then
        tblName = "tbl"
    end

    local tScript = "local " .. tblName .. " = " .. ctld.utils.tableShow("ctld.utils.tableShowScript()", tblObj)
    return tScript
end

--------------------------------------------------------------------------------------------------------
--- Returns table in a easy readable string representation.
-- borrowed from mist
-- this function is not meant for serialization because it uses
-- newlines for better readability.
-- @param tbl table to show
-- @param loc
-- @param indent
-- @param tableshow_tbls
-- @return human readable string representation of given table
function ctld.utils.tableShow(caller, tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
    if tbl == nil then
        if env and env.error then
            env.error("ctld.utils.tableShow()." .. tostring(caller) .. ": Attempt to show a nil table.")
        end
        return "nil"
    end

    tableshow_tbls = tableshow_tbls or {} --create table of tables
    loc = loc or ""
    indent = indent or ""
    if type(tbl) == 'table' then --function only works for tables!
        tableshow_tbls[tbl] = loc
        local tbl_str = {}
        --tbl_str[#tbl_str + 1] = indent .. '{\n'
        tbl_str[#tbl_str + 1] = '{\n'

        for ind, val in pairs(tbl) do
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'nil' then -- won't ever happen, right?
                tbl_str[#tbl_str + 1] = 'nil,\n'
            elseif type(val) == 'table' then
                if tableshow_tbls[val] then
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                else
                    --tableshow_tbls[val] = loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']'
                    --tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                    --[[
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val,
                    loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']',
                    indent .. '    ',
                    tableshow_tbls) ]] --
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val, loc, indent .. '    ')
                    tbl_str[#tbl_str + 1] = ',\n'
                end
            elseif type(val) == 'function' then
                if debug and debug.getinfo then
                    local fcnname = tostring(val)
                    local info = debug.getinfo(val, "S")
                    if info.what == "C" then
                        tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                    else
                        if (string.sub(info.source, 1, 2) == [[./]]) then
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                fcnname ..
                                ', defined in (' ..
                                info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) .. ',\n'
                        else
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                    fcnname ..
                                    ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..
                                ',\n'
                        end
                    end
                else
                    tbl_str[#tbl_str + 1] = 'a function,\n'
                end
            else
                tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
                    ctld.utils.basicSerialize("ctld.utils.tableShow()", type(val)) .. ' at index ' .. tostring(ind)
            end
        end
        --string.sub("Hello, World!", -6, -1)
        if string.sub(table.concat(tbl_str), - #indent - 2, -1) == '{\n' then
            trigger.action.outText(string.sub(table.concat(tbl_str), - #indent - 2, -1), 10)
            for i = 1, #indent do
                tbl_str[#tbl_str] = nil
            end
            tbl_str[#tbl_str + 1] = '{}'
        else
            tbl_str[#tbl_str + 1] = indent .. '}'
        end
        return table.concat(tbl_str)
    end
end

--======================================================================================================
--- Serializes the give variable to a string.
-- borrowed from slmod
-- @param var variable to serialize
-- @treturn string variable serialized to string
function ctld.utils.basicSerialize(caller, var)
    if var == nil then
        if env and env.error then
            env.error("ctld.utils.basicSerialize()." .. tostring(caller) .. ": Attempt to serialize a nil variable.")
        end
        return "nil"
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata')) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end
-- End : CTLD_utils.lua 
-- ==================================================================================================== 
-- Start : CTLD_menus.lua 
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
-- End : CTLD_menus.lua 
-- ==================================================================================================== 
-- Start : CTLD_beacon.lua 
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
                _radioBeaconDetails.text, 20))
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
                    _closestBeacon.text, 20))
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Radio Beacons within 500m."), 20)
        end
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before remove a Radio Beacon"), 20)
    end
end
-- End : CTLD_beacon.lua 
-- ==================================================================================================== 
-- Start : CTLD_jtac.lua 
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
-- End : CTLD_jtac.lua 
-- ==================================================================================================== 
-- Start : CTLD_recon.lua 
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
-- End : CTLD_recon.lua 
-- ==================================================================================================== 
-- Start : CTLD_core.lua 
--[[ ! IMPORTANT : You must must use the version of MIST supplied in the CTLD pack to correctly manage dynamic spwans

        Combat Troop and Logistics Drop

        Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
        without requiring external mods.

        Supports all of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

        Supports deployment of Auto Lasing JTAC to the field

        See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

        Contributors:
                - Steggles - https://github.com/Bob7heBuilder
                - mvee - https://github.com/mvee
                - jmontleon - https://github.com/jmontleon
                - emilianomolina - https://github.com/emilianomolina
                - davidp57 - https://github.com/veaf
                - Queton1-1 - https://github.com/Queton1-1
                - Proxy404 - https://github.com/Proxy404
                - atcz - https://github.com/atcz
                - marcos2221- https://github.com/marcos2221
                - FullGas1 - https://github.com/FullGas1 (i18n concept, FR and SP translations)

        Add [issues](https://github.com/ciribob/DCS-CTLD/issues) to the GitHub repository if you want to report a bug or suggest a new feature.

        Contact Zip [on Discord](https://discordapp.com/users/421317390807203850) or [on Github](https://github.com/davidp57) if you need help or want to have a friendly chat.

        Send beers (or kind messages) to Ciribob [on Discord](https://discordapp.com/users/204712384747536384), he's the reason we have CTLD ^^
 ]]

if not ctld then -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    trigger.action.outText(
        "\n\n** HEY MISSION-DESIGNER! **\n\nCTLD-i18n has not been loaded!\n\nMake sure CTLD-i18n is loaded\n*before* running this script!\n\nIt contains all the translations!\n",
        10)
    ctld = {} -- DONT REMOVE!
end

--- Identifier. All output in DCS.log will start with this.
ctld.Id = "CTLD - "

--- Version.
ctld.Version = "1.6.4"

-- To add debugging messages to dcs.log, change the following log levels to `true`; `Debug` is less detailed than `Trace`
ctld.Debug = false
ctld.Trace = true

if ctld.Debug then
    env.info(ctld.Id .. "Debug logging is ENABLED")
end

ctld.dontInitialize = false -- if true, ctld.initialize() will not run; instead, you'll have to run it from your own code - it's useful when you want to override some functions/parameters before the initialization takes place


-- ************************************************************************
-- *********************    USER CONFIGURATION ******************************
-- ************************************************************************
ctld.staticBugWorkaround                  = false                                                                                                                                                                                           --    DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE

ctld.disableAllSmoke                      = false                                                                                                                                                                                           -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below

-- Allow units to CTLD by aircraft type and not by pilot name - this is done everytime a player enters a new unit
ctld.addPlayerAircraftByType              = true

ctld.hoverPickup                          = true                                                                                                                                                                                            --    if set to false you can load crates with the F10 menu instead of hovering... Only if not using real crates!
ctld.loadCrateFromMenu                    = true                                                                                                                                                                                            -- if set to true, you can load crates with the F10 menu OR hovering, in case of using choppers and planes for example.

ctld.enableCrates                         = true                                                                                                                                                                                            -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.enableAllCrates                      = true                                                                                                                                                                                            -- if false, the "all crates" menu items will not be displayed
ctld.slingLoad                            = false                                                                                                                                                                                           -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
-- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
-- to use the other method.
-- Set staticBugFix    to FALSE if use set ctld.slingLoad to TRUE
ctld.enableSmokeDrop                      = true                                                                                                                                                                                            -- if false, helis and c-130 will not be able to drop smoke
ctld.maxExtractDistance                   = 125                                                                                                                                                                                             -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic              = 200                                                                                                                                                                                             -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.enableRepackingVehicles              = true                                                                                                                                                                                            -- if true, vehicles can be repacked into crates
ctld.maximumDistanceRepackableUnitsSearch = 200                                                                                                                                                                                             -- max distance from transportUnit to search force repackable units in meters
ctld.maximumSearchDistance                = 4000                                                                                                                                                                                            -- max distance for troops to search for enemy
ctld.maximumMoveDistance                  = 2000                                                                                                                                                                                            -- max distance for troops to move from drop point if no enemy is nearby
ctld.minimumDeployDistance                = 1000                                                                                                                                                                                            -- minimum distance from a friendly pickup zone where you can deploy a crate
ctld.numberOfTroops                       = 10                                                                                                                                                                                              -- default number of troops to load on a transport heli or C-130
-- also works as maximum size of group that'll fit into a helicopter unless overridden
ctld.enableFastRopeInsertion              = true                                                                                                                                                                                            -- allows you to drop troops by fast rope
ctld.fastRopeMaximumHeight                = 18.28                                                                                                                                                                                           -- in meters which is 60 ft max fast rope (not rappell) safe height
ctld.vehiclesForTransportRED              = {
    "BRDM-2", "BTR_D" }                                                                                                                                                                                                                     -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
ctld.vehiclesForTransportBLUE             = {
    "M1045 HMMWV TOW", "M1043 HMMWV Armament" }                                                                                                                                                                                             -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}
ctld.vehiclesWeight                       = {
    ["BRDM-2"] = 7000,
    ["BTR_D"] = 8000,
    ["M1045 HMMWV TOW"] = 3220,
    ["M1043 HMMWV Armament"] = 2500
}

ctld.spawnRPGWithCoalition                = true                                                                                                                                                                                            --spawns a friendly RPG unit with Coalition forces
ctld.spawnStinger                         = false                                                                                                                                                                                           -- spawns a stinger / igla soldier with a group of 6 or more soldiers!
ctld.enabledFOBBuilding                   = true                                                                                                                                                                                            -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
-- In future i'd like it to be a FARP but so far that seems impossible...
-- You can also enable troop Pickup at FOBS
ctld.cratesRequiredForFOB                 = 3                                                                                                                                                                                           -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
-- The large crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled
-- Small FOB crates can be moved by helicopter. The FOB will require ctld.cratesRequiredForFOB larges crates and small crates are 1/3 of a large fob crate
-- To build the FOB entirely out of small crates you will need ctld.cratesRequiredForFOB * 3

ctld.troopPickupAtFOB                     = true                                                                                                                                                                                               -- if true, troops can also be picked up at a created FOB
ctld.buildTimeFOB                         = 120                                                                                                                                                                                                --time in seconds for the FOB to be built
ctld.crateWaitTime                        = 40                                                                                                                                                                                                 -- time in seconds to wait before you can spawn another crate
ctld.forceCrateToBeMoved                  = true                                                                                                                                                                                               -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam
ctld.radioSound                           =
"beacon.ogg"                                                                                                                                                                                                                                   -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
ctld.radioSoundFC3                        =
"beaconsilent.ogg"                                                                                                                                                                                                                             -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)
ctld.deployedBeaconBattery                = 30                                                                                                                                                                                                 -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed
ctld.enabledRadioBeaconDrop               = true                                                                                                                                                                                               -- if its set to false then beacons cannot be dropped by units
ctld.allowRandomAiTeamPickups             = false                                                                                                                                                                                              -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones
-- Limit the dropping of infantry teams -- this limit control is inactive if ctld.nbLimitSpawnedTroops = {0, 0} ----
ctld.nbLimitSpawnedTroops                 = { 0, 0 }                                                                                                                                                                                           -- {redLimitInfantryCount, blueLimitInfantryCount} when this cumulative number of troops is reached, no more troops can be loaded onboard
ctld.InfantryInGameCount                  = { 0, 0 }                                                                                                                                                                                           -- {redCoaInfantryCount, blueCoaInfantryCount}

-- Simulated Sling load configuration
ctld.minimumHoverHeight                   = 7.5                                                                                                                                                                                            -- Lowest allowable height for crate hover
ctld.maximumHoverHeight                   = 12.0                                                                                                                                                                                           -- Highest allowable height for crate hover
ctld.maxDistanceFromCrate                 = 5.5                                                                                                                                                                                            -- Maximum distance from from crate for hover
ctld.hoverTime                            = 10                                                                                                                                                                                             -- Time to hold hover above a crate for loading in seconds

-- end of Simulated Sling load configuration

-- ***************** AA SYSTEM CONFIG *****************
ctld.aaLaunchers                          = 3                                                                                                                                                                                           -- controls how many launchers to add to the AA systems when its spawned if no amount is specified in the template.
-- Sets a limit on the number of active AA systems that can be built for RED.
-- A system is counted as Active if its fully functional and has all parts
-- If a system is partially destroyed, it no longer counts towards the total
-- When this limit is hit, a player will still be able to get crates for an AA system, just unable
-- to unpack them

ctld.AASystemLimitRED                     = 20                                                                                                                                                                                           -- Red side limit
ctld.AASystemLimitBLUE                    = 20                                                                                                                                                                                           -- Blue side limit

-- Allows players to create systems using as many crates as they like
-- Example : an amount X of patriot launcher crates allows for Y launchers to be deployed, if a player brings 2*X+Z crates (Z being lower then X), then deploys the patriot site, 2*Y launchers will be in the group and Z launcher crate will be left over

ctld.AASystemCrateStacking                = false
--END AA SYSTEM CONFIG ------------------------------------

-- ***************** JTAC CONFIGURATION *****************
ctld.JTAC_LIMIT_RED                       = 10                                                                                                                                                                                              -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE                      = 10                                                                                                                                                                                              -- max number of JTAC Crates for the BLUE Side
ctld.JTAC_dropEnabled                     = true                                                                                                                                                                                            -- allow JTAC Crate spawn from F10 menu
ctld.JTAC_maxDistance                     = 10000                                                                                                                                                                                           -- How far a JTAC can "see" in meters (with Line of Sight)
ctld.JTAC_smokeOn_RED                     = false                                                                                                                                                                                           -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE                    = false                                                                                                                                                                                           -- enables marking of target with smoke for BLUE forces
ctld.JTAC_smokeColour_RED                 = 4                                                                                                                                                                                               -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE                = 1                                                                                                                                                                                               -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeMarginOfError              = 50                                                                                                                                                                                              -- error that the JTAC is allowed to make when popping a smoke (in meters)
ctld.JTAC_smokeOffset_x                   = 0.0                                                                                                                                                                                             -- distance in the X direction from target to smoke (meters)
ctld.JTAC_smokeOffset_y                   = 2.0                                                                                                                                                                                             -- distance in the Y direction from target to smoke (meters)
ctld.JTAC_smokeOffset_z                   = 0.0                                                                                                                                                                                             -- distance in the z direction from target to smoke (meters)
ctld.JTAC_jtacStatusF10                   = true                                                                                                                                                                                            -- enables F10 JTAC Status menu
ctld.JTAC_location                        = true                                                                                                                                                                                            -- shows location of target in JTAC message
ctld.location_DMS                         = false                                                                                                                                                                                           -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes
ctld.JTAC_lock                            =
"all"                                                                                                                                                                                                                                       -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units
ctld.JTAC_allowStandbyMode                = true                                                                                                                                                                                            -- if true, allow players to toggle lasing on/off
ctld.JTAC_laseSpotCorrections             = true                                                                                                                                                                                            -- if true, each JTAC will have a special option (toggle on/off) available in it's menu to attempt to lead the target, taking into account current wind conditions and the speed of the target (particularily useful against moving heavy armor)
ctld.JTAC_allowSmokeRequest               = true                                                                                                                                                                                            -- if true, allow players to request a smoke on target (temporary)
ctld.JTAC_allow9Line                      = true                                                                                                                                                                                            -- if true, allow players to ask for a 9Line (individual) for a specific JTAC's target

-- ***************** Pickup, dropoff and waypoint zones *****************

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",
-- Use any of the predefined names or set your own ones
-- You can add number as a third option to limit the number of soldier or vehicle groups that can be loaded from a zone.
-- Dropping back a group at a limited zone will add one more to the limit
-- If a zone isn't ACTIVE then you can't pickup from that zone until the zone is activated by ctld.activatePickupZone
-- using the Mission editor
-- You can pickup from a SHIP by adding the SHIP UNIT NAME instead of a zone name
-- Side - Controls which side can load/unload troops at the zone
-- Flag Number - Optional last field. If set the current number of groups remaining can be obtained from the flag value
--pickupZones = { "Zone name or Ship Unit Name", "smoke color", "limit (-1 unlimited)", "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", flag number (optional) }
ctld.pickupZones                          = {
    { "pickzone1",   "blue", -1, "yes", 0 },
    { "pickzone2",   "red",  -1, "yes", 0 },
    { "pickzone3",   "none", -1, "yes", 0 },
    { "pickzone4",   "none", -1, "yes", 0 },
    { "pickzone5",   "none", -1, "yes", 0 },
    { "pickzone6",   "none", -1, "yes", 0 },
    { "pickzone7",   "none", -1, "yes", 0 },
    { "pickzone8",   "none", -1, "yes", 0 },
    { "pickzone9",   "none", 5,  "yes", 1 }, -- limits pickup zone 9 to 5 groups of soldiers or vehicles, only red can pick up
    { "pickzone10",  "none", 10, "yes", 2 }, -- limits pickup zone 10 to 10 groups of soldiers or vehicles, only blue can pick up

    { "pickzone11",  "blue", 20, "no",  2 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone12",  "red",  20, "no",  1 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone13",  "none", -1, "yes", 0 },
    { "pickzone14",  "none", -1, "yes", 0 },
    { "pickzone15",  "none", -1, "yes", 0 },
    { "pickzone16",  "none", -1, "yes", 0 },
    { "pickzone17",  "none", -1, "yes", 0 },
    { "pickzone18",  "none", -1, "yes", 0 },
    { "pickzone19",  "none", 5,  "yes", 0 },
    { "pickzone20",  "none", 10, "yes", 0, 1000 }, -- optional extra flag number to store the current number of groups available in

    { "USA Carrier", "blue", 10, "yes", 0, 1001 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
}

-- dropOffZones = {"name","smoke colour",0,side 1 = Red or 2 = Blue or 0 = Both sides}
ctld.dropOffZones                         = {
    { "dropzone1",  "green",  2 },
    { "dropzone2",  "blue",   2 },
    { "dropzone3",  "orange", 2 },
    { "dropzone4",  "none",   2 },
    { "dropzone5",  "none",   1 },
    { "dropzone6",  "none",   1 },
    { "dropzone7",  "none",   1 },
    { "dropzone8",  "none",   1 },
    { "dropzone9",  "none",   1 },
    { "dropzone10", "none",   1 },
}

--wpZones = { "Zone name", "smoke color",    "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", }
ctld.wpZones                              = {
    { "wpzone1",  "green",  "yes", 2 },
    { "wpzone2",  "blue",   "yes", 2 },
    { "wpzone3",  "orange", "yes", 2 },
    { "wpzone4",  "none",   "yes", 2 },
    { "wpzone5",  "none",   "yes", 2 },
    { "wpzone6",  "none",   "yes", 1 },
    { "wpzone7",  "none",   "yes", 1 },
    { "wpzone8",  "none",   "yes", 1 },
    { "wpzone9",  "none",   "yes", 1 },
    { "wpzone10", "none",   "no",  0 }, -- Both sides as its set to 0
}

-- ******************** Transports names **********************
-- If ctld.addPlayerAircraftByType = True, comment or uncomment lines to allow aircraft's type carry CTLD
ctld.aircraftTypeTable                    = {
    --%%%%% MODS %%%%%
    --"Bronco-OV-10A",
    --"Hercules",
    --"SK-60",
    --"UH-60L",
    --"T-45",

    --%%%%% CHOPPERS %%%%%
    --"Ka-50",
    --"Ka-50_3",
    "Mi-8MT",
    "Mi-24P",
    --"SA342L",
    --"SA342M",
    --"SA342Mistral",
    --"SA342Minigun",
    "UH-1H",
    "CH-47Fbl1",

    --%%%%% AIRCRAFTS %%%%%
    --"C-101EB",
    --"C-101CC",
    --"Christen Eagle II",
    --"L-39C",
    --"L-39ZA",
    --"MB-339A",
    --"MB-339APAN",
    --"Mirage-F1B",
    --"Mirage-F1BD",
    --"Mirage-F1BE",
    --"Mirage-F1BQ",
    --"Mirage-F1DDA",
    --"Su-25T",
    --"Yak-52",

    --%%%%% WARBIRDS %%%%%
    --"Bf-109K-4",
    --"Fw 190A8",
    --"FW-190D9",
    --"I-16",
    --"MosquitoFBMkVI",
    --"P-47D-30",
    --"P-47D-40",
    --"P-51D",
    --"P-51D-30-NA",
    --"SpitfireLFMkIX",
    --"SpitfireLFMkIXCW",
    --"TF-51D",
}

-- Use any of the predefined names or set your own ones
ctld.transportPilotNames                  = {
    "helicargo1",
    "helicargo2",
    "helicargo3",
    "helicargo4",
    "helicargo5",
    "helicargo6",
    "helicargo7",
    "helicargo8",
    "helicargo9",
    "helicargo10",

    "helicargo11",
    "helicargo12",
    "helicargo13",
    "helicargo14",
    "helicargo15",
    "helicargo16",
    "helicargo17",
    "helicargo18",
    "helicargo19",
    "helicargo20",

    "helicargo21",
    "helicargo22",
    "helicargo23",
    "helicargo24",
    "helicargo25",

    "MEDEVAC #1",
    "MEDEVAC #2",
    "MEDEVAC #3",
    "MEDEVAC #4",
    "MEDEVAC #5",
    "MEDEVAC #6",
    "MEDEVAC #7",
    "MEDEVAC #8",
    "MEDEVAC #9",
    "MEDEVAC #10",
    "MEDEVAC #11",
    "MEDEVAC #12",
    "MEDEVAC #13",
    "MEDEVAC #14",
    "MEDEVAC #15",
    "MEDEVAC #16",

    "MEDEVAC RED #1",
    "MEDEVAC RED #2",
    "MEDEVAC RED #3",
    "MEDEVAC RED #4",
    "MEDEVAC RED #5",
    "MEDEVAC RED #6",
    "MEDEVAC RED #7",
    "MEDEVAC RED #8",
    "MEDEVAC RED #9",
    "MEDEVAC RED #10",
    "MEDEVAC RED #11",
    "MEDEVAC RED #12",
    "MEDEVAC RED #13",
    "MEDEVAC RED #14",
    "MEDEVAC RED #15",
    "MEDEVAC RED #16",
    "MEDEVAC RED #17",
    "MEDEVAC RED #18",
    "MEDEVAC RED #19",
    "MEDEVAC RED #20",
    "MEDEVAC RED #21",

    "MEDEVAC BLUE #1",
    "MEDEVAC BLUE #2",
    "MEDEVAC BLUE #3",
    "MEDEVAC BLUE #4",
    "MEDEVAC BLUE #5",
    "MEDEVAC BLUE #6",
    "MEDEVAC BLUE #7",
    "MEDEVAC BLUE #8",
    "MEDEVAC BLUE #9",
    "MEDEVAC BLUE #10",
    "MEDEVAC BLUE #11",
    "MEDEVAC BLUE #12",
    "MEDEVAC BLUE #13",
    "MEDEVAC BLUE #14",
    "MEDEVAC BLUE #15",
    "MEDEVAC BLUE #16",
    "MEDEVAC BLUE #17",
    "MEDEVAC BLUE #18",
    "MEDEVAC BLUE #19",
    "MEDEVAC BLUE #20",
    "MEDEVAC BLUE #21",

    -- *** AI transports names (different names only to ease identification in mission) ***

    -- Use any of the predefined names or set your own ones
    "transport1",
    "transport2",
    "transport3",
    "transport4",
    "transport5",
    "transport6",
    "transport7",
    "transport8",
    "transport9",
    "transport10",

    "transport11",
    "transport12",
    "transport13",
    "transport14",
    "transport15",
    "transport16",
    "transport17",
    "transport18",
    "transport19",
    "transport20",

    "transport21",
    "transport22",
    "transport23",
    "transport24",
    "transport25",
}

-- *************** Optional Extractable GROUPS *****************

-- Use any of the predefined names or set your own ones
ctld.extractableGroups                    = {
    "extract1",
    "extract2",
    "extract3",
    "extract4",
    "extract5",
    "extract6",
    "extract7",
    "extract8",
    "extract9",
    "extract10",

    "extract11",
    "extract12",
    "extract13",
    "extract14",
    "extract15",
    "extract16",
    "extract17",
    "extract18",
    "extract19",
    "extract20",

    "extract21",
    "extract22",
    "extract23",
    "extract24",
    "extract25",
}

-- ************** Logistics UNITS FOR CRATE SPAWNING ******************

-- Use any of the predefined names or set your own ones
-- When a logistic unit is destroyed, you will no longer be able to spawn crates
ctld.dynamicLogisticUnitsIndex            = 0                                                                                                                                                                                           -- This is the unit that will be spawned first and then subsequent units will be from the next in the list
ctld.logisticUnits                        = {
    "logistic1",
    "logistic2",
    "logistic3",
    "logistic4",
    "logistic5",
    "logistic6",
    "logistic7",
    "logistic8",
    "logistic9",
    "logistic10",
}

-- ************** UNITS ABLE TO TRANSPORT VEHICLES ******************
-- Add the model name of the unit that you want to be able to transport and deploy vehicles
-- units db has all the names or you can extract a mission.miz file by making it a zip and looking
-- in the contained mission file
ctld.vehicleTransportEnabled              = {
    "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
    "Hercules",
    --"CH-47Fbl1",
}

-- ************** Units able to use DCS dynamic cargo system ******************
-- DCS (version) added the ability to load and unload cargo from aircraft.
-- Units listed here will spawn a cargo static that can be loaded with the standard DCS cargo system
-- We will also use this to make modifications to the menu and other checks and messages
ctld.dynamicCargoUnits                    = {
    "CH-47Fbl1",
    "UH-1H",
    "Mi-8MT",
    "Mi-24P",
}

-- ************** Maximum Units SETUP for UNITS ******************
-- Put the name of the Unit you want to limit group sizes too
-- i.e
-- ["UH-1H"] = 10,
--
-- Will limit UH1 to only transport groups with a size 10 or less
-- Make sure the unit name is exactly right or it wont work

ctld.unitLoadLimits                       = {
    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = 4,
    -- ["SA342L"] = 4,
    -- ["SA342M"] = 4,

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = 4,
    ["Hercules"] = 30,
    --["SK-60"] = 1,
    ["UH-60L"] = 12,
    --["T-45"] = 1,

    --%%%%% CHOPPERS %%%%%
    ["Mi-8MT"] = 16,
    ["Mi-24P"] = 10,
    --["SA342L"] = 4,
    --["SA342M"] = 4,
    --["SA342Mistral"] = 4,
    --["SA342Minigun"] = 3,
    ["UH-1H"] = 8,
    ["CH-47Fbl1"] = 33,

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = 1,
    --["C-101CC"] = 1,
    --["Christen Eagle II"] = 1,
    --["L-39C"] = 1,
    --["L-39ZA"] = 1,
    --["MB-339A"] = 1,
    --["MB-339APAN"] = 1,
    --["Mirage-F1B"] = 1,
    --["Mirage-F1BD"] = 1,
    --["Mirage-F1BE"] = 1,
    --["Mirage-F1BQ"] = 1,
    --["Mirage-F1DDA"] = 1,
    --["Su-25T"] = 1,
    --["Yak-52"] = 1,

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = 1,
    --["Fw 190A8"] = 1,
    --["FW-190D9"] = 1,
    --["I-16"] = 1,
    --["MosquitoFBMkVI"] = 1,
    --["P-47D-30"] = 1,
    --["P-47D-40"] = 1,
    --["P-51D"] = 1,
    --["P-51D-30-NA"] = 1,
    --["SpitfireLFMkIX"] = 1,
    --["SpitfireLFMkIXCW"] = 1,
    --["TF-51D"] = 1,
}

-- Put the name of the Unit you want to enable loading multiple crates
ctld.internalCargoLimits                  = {

    -- Remove the -- below to turn on options
    ["Mi-8MT"] = 2,
    ["CH-47Fbl1"] = 8,
    --["UH-1H"] = 3, -- to remove after debug
}


-- ************** Allowable actions for UNIT TYPES ******************
-- Put the name of the Unit you want to limit actions for
-- NOTE - the unit must've been listed in the transportPilotNames list above
-- This can be used in conjunction with the options above for group sizes
-- By default you can load both crates and troops unless overriden below
-- i.e
-- ["UH-1H"] = {crates=true, troops=false},
--
-- Will limit UH1 to only transport CRATES but NOT TROOPS
--
-- ["SA342Mistral"] = {crates=fales, troops=true},
-- Will allow Mistral Gazelle to only transport crates, not troops

ctld.unitActions = {

    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = {crates=true, troops=true},
    -- ["SA342L"] = {crates=false, troops=true},
    -- ["SA342M"] = {crates=false, troops=true},

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = {crates=true, troops=true},
    ["Hercules"] = { crates = true, troops = true },
    ["SK-60"] = { crates = true, troops = true },
    ["UH-60L"] = { crates = true, troops = true },
    --["T-45"] = {crates=true, troops=true},

    --%%%%% CHOPPERS %%%%%
    --["Ka-50"] = {crates=true, troops=false},
    --["Ka-50_3"] = {crates=true, troops=false},
    ["Mi-8MT"] = { crates = true, troops = true },
    ["Mi-24P"] = { crates = true, troops = true },
    --["SA342L"] = {crates=false, troops=true},
    --["SA342M"] = {crates=false, troops=true},
    --["SA342Mistral"] = {crates=false, troops=true},
    --["SA342Minigun"] = {crates=false, troops=true},
    ["UH-1H"] = { crates = true, troops = true },
    ["CH-47Fbl1"] = { crates = true, troops = true },

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = {crates=true, troops=true},
    --["C-101CC"] = {crates=true, troops=true},
    --["Christen Eagle II"] = {crates=true, troops=true},
    --["L-39C"] = {crates=true, troops=true},
    --["L-39ZA"] = {crates=true, troops=true},
    --["MB-339A"] = {crates=true, troops=true},
    --["MB-339APAN"] = {crates=true, troops=true},
    --["Mirage-F1B"] = {crates=true, troops=true},
    --["Mirage-F1BD"] = {crates=true, troops=true},
    --["Mirage-F1BE"] = {crates=true, troops=true},
    --["Mirage-F1BQ"] = {crates=true, troops=true},
    --["Mirage-F1DDA"] = {crates=true, troops=true},
    --["Su-25T"]= {crates=true, troops=false},
    --["Yak-52"] = {crates=true, troops=true},

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = {crates=true, troops=false},
    --["Fw 190A8"] = {crates=true, troops=false},
    --["FW-190D9"] = {crates=true, troops=false},
    --["I-16"] = {crates=true, troops=false},
    --["MosquitoFBMkVI"] = {crates=true, troops=true},
    --["P-47D-30"] = {crates=true, troops=false},
    --["P-47D-40"] = {crates=true, troops=false},
    --["P-51D"] = {crates=true, troops=false},
    --["P-51D-30-NA"] = {crates=true, troops=false},
    --["SpitfireLFMkIX"] = {crates=true, troops=false},
    --["SpitfireLFMkIXCW"] = {crates=true, troops=false},
    --["TF-51D"] = {crates=true, troops=true},
}

-- ************** WEIGHT CALCULATIONS FOR INFANTRY GROUPS ******************

-- Infantry groups weight is calculated based on the soldiers' roles, and the weight of their kit
-- Every soldier weights between 90% and 120% of ctld.SOLDIER_WEIGHT, and they all carry a backpack and their helmet (ctld.KIT_WEIGHT)
-- Standard grunts have a rifle and ammo (ctld.RIFLE_WEIGHT)
-- AA soldiers have a MANPAD tube (ctld.MANPAD_WEIGHT)
-- Anti-tank soldiers have a RPG and a rocket (ctld.RPG_WEIGHT)
-- Machine gunners have the squad MG and 200 bullets (ctld.MG_WEIGHT)
-- JTAC have the laser sight, radio and binoculars (ctld.JTAC_WEIGHT)
-- Mortar servants carry their tube and a few rounds (ctld.MORTAR_WEIGHT)

ctld.SOLDIER_WEIGHT = 80 -- kg, will be randomized between 90% and 120%
ctld.KIT_WEIGHT = 20     -- kg
ctld.RIFLE_WEIGHT = 5    -- kg
ctld.MANPAD_WEIGHT = 18  -- kg
ctld.RPG_WEIGHT = 7.6    -- kg
ctld.MG_WEIGHT = 10      -- kg
ctld.MORTAR_WEIGHT = 26  -- kg
ctld.JTAC_WEIGHT = 15    -- kg

-- ************** INFANTRY GROUPS FOR PICKUP ******************
-- Unit Types
-- inf is normal infantry
-- mg is M249
-- at is RPG-16
-- aa is Stinger or Igla
-- mortar is a 2B11 mortar unit
-- jtac is a JTAC soldier, which will use JTACAutoLase
-- You must add a name to the group for it to work
-- You can also add an optional coalition side to limit the group to one side
-- for the side - 2 is BLUE and 1 is RED
ctld.loadableGroups = {
    { name = ctld.i18n_translate("Standard Group"),                   inf = 6,    mg = 2,  at = 2 }, -- will make a loadable group with 6 infantry, 2 MGs and 2 anti-tank for both coalitions
    { name = ctld.i18n_translate("Anti Air"),                         inf = 2,    aa = 3 },
    { name = ctld.i18n_translate("Anti Tank"),                        inf = 2,    at = 6 },
    { name = ctld.i18n_translate("Mortar Squad"),                     mortar = 6 },
    { name = ctld.i18n_translate("JTAC Group"),                       inf = 4,    jtac = 1 }, -- will make a loadable group with 4 infantry and a JTAC soldier for both coalitions
    { name = ctld.i18n_translate("Single JTAC"),                      jtac = 1 },             -- will make a loadable group witha single JTAC soldier for both coalitions
    { name = ctld.i18n_translate("2x - Standard Groups"),             inf = 12,   mg = 4,  at = 4 },
    { name = ctld.i18n_translate("2x - Anti Air"),                    inf = 4,    aa = 6 },
    { name = ctld.i18n_translate("2x - Anti Tank"),                   inf = 4,    at = 12 },
    { name = ctld.i18n_translate("2x - Standard Groups + 2x Mortar"), inf = 12,   mg = 4,  at = 4, mortar = 12 },
    { name = ctld.i18n_translate("3x - Standard Groups"),             inf = 18,   mg = 6,  at = 6 },
    { name = ctld.i18n_translate("3x - Anti Air"),                    inf = 6,    aa = 9 },
    { name = ctld.i18n_translate("3x - Anti Tank"),                   inf = 6,    at = 18 },
    { name = ctld.i18n_translate("3x - Mortar Squad"),                mortar = 18 },
    { name = ctld.i18n_translate("5x - Mortar Squad"),                mortar = 30 },
    -- {name = ctld.i18n_translate("Mortar Squad Red"), inf = 2, mortar = 5, side =1 }, --would make a group loadable by RED only
}

-- ************** SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
ctld.spawnableCrates = {
    -- name of the sub menu on F10 for spawning crates
    ["Combat Vehicles"] = {
        --crates you can spawn
        -- weight in KG
        -- Desc is the description on the F10 MENU
        -- unit is the model name of the unit to spawn
        -- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
        -- side is optional but 2 is BLUE and 1 is RED

        -- Some descriptions are filtered to determine if JTAC or not!

        --- BLUE
        { weight = 1000.01,                                  desc = ctld.i18n_translate("Humvee - MG"),                      unit = "M1043 HMMWV Armament", side = 2 }, --careful with the names as the script matches the desc to JTAC types
        { weight = 1000.02,                                  desc = ctld.i18n_translate("Humvee - TOW"),                     unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
        { multiple = { 1000.02, 1000.02 },                   desc = ctld.i18n_translate("Humvee - TOW - All crates"),        side = 2 },
        { weight = 1000.03,                                  desc = ctld.i18n_translate("Light Tank - MRAP"),                unit = "MaxxPro_MRAP",         side = 2, cratesRequired = 2 },
        { multiple = { 1000.03, 1000.03 },                   desc = ctld.i18n_translate("Light Tank - MRAP - All crates"),   side = 2 },
        { weight = 1000.04,                                  desc = ctld.i18n_translate("Med Tank - LAV-25"),                unit = "LAV-25",               side = 2, cratesRequired = 3 },
        { multiple = { 1000.04, 1000.04, 1000.04 },          desc = ctld.i18n_translate("Med Tank - LAV-25 - All crates"),   side = 2 },
        { weight = 1000.05,                                  desc = ctld.i18n_translate("Heavy Tank - Abrams"),              unit = "M-1 Abrams",           side = 2, cratesRequired = 4 },
        { multiple = { 1000.05, 1000.05, 1000.05, 1000.05 }, desc = ctld.i18n_translate("Heavy Tank - Abrams - All crates"), side = 2 },

        --- RED
        { weight = 1000.11,                                  desc = ctld.i18n_translate("BTR-D"),                            unit = "BTR_D",                side = 1 },
        { weight = 1000.12,                                  desc = ctld.i18n_translate("BRDM-2"),                           unit = "BRDM-2",               side = 1 },
        -- need more redfor!
    },
    ["Support"] = {
        --- BLUE
        { weight = 1001.01,                         desc = ctld.i18n_translate("Hummer - JTAC"),                    unit = "Hummer",            side = 2,          cratesRequired = 2 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { multiple = { 1001.01, 1001.01 },          desc = ctld.i18n_translate("Hummer - JTAC - All crates"),       side = 2 },
        { weight = 1001.02,                         desc = ctld.i18n_translate("M-818 Ammo Truck"),                 unit = "M 818",             side = 2,          cratesRequired = 2 },
        { multiple = { 1001.02, 1001.02 },          desc = ctld.i18n_translate("M-818 Ammo Truck - All crates"),    side = 2 },
        { weight = 1001.03,                         desc = ctld.i18n_translate("M-978 Tanker"),                     unit = "M978 HEMTT Tanker", side = 2,          cratesRequired = 2 },
        { multiple = { 1001.03, 1001.03 },          desc = ctld.i18n_translate("M-978 Tanker - All crates"),        side = 2 },

        --- RED
        { weight = 1001.11,                         desc = ctld.i18n_translate("SKP-11 - JTAC"),                    unit = "SKP-11",            side = 1 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 1001.12,                         desc = ctld.i18n_translate("Ural-375 Ammo Truck"),              unit = "Ural-375",          side = 1,          cratesRequired = 2 },
        { multiple = { 1001.12, 1001.12 },          desc = ctld.i18n_translate("Ural-375 Ammo Truck - All crates"), side = 1 },
        { weight = 1001.13,                         desc = ctld.i18n_translate("KAMAZ Ammo Truck"),                 unit = "KAMAZ Truck",       side = 1,          cratesRequired = 2 },

        --- Both
        { weight = 1001.21,                         desc = ctld.i18n_translate("EWR Radar"),                        unit = "FPS-117",           cratesRequired = 3 },
        { multiple = { 1001.21, 1001.21, 1001.21 }, desc = ctld.i18n_translate("EWR Radar - All crates") },
        { weight = 1001.22,                         desc = ctld.i18n_translate("FOB Crate - Small"),                unit = "FOB-SMALL" }, -- Builds a FOB! - requires 3 * ctld.cratesRequiredForFOB

    },
    ["Artillery"] = {
        --- BLUE
        { weight = 1002.01,                         desc = ctld.i18n_translate("MLRS"),                       unit = "MLRS",         side = 2, cratesRequired = 3 },
        { multiple = { 1002.01, 1002.01, 1002.01 }, desc = ctld.i18n_translate("MLRS - All crates"),          side = 2 },
        { weight = 1002.02,                         desc = ctld.i18n_translate("SpGH DANA"),                  unit = "SpGH_Dana",    side = 2, cratesRequired = 3 },
        { multiple = { 1002.02, 1002.02, 1002.02 }, desc = ctld.i18n_translate("SpGH DANA - All crates"),     side = 2 },
        { weight = 1002.03,                         desc = ctld.i18n_translate("T155 Firtina"),               unit = "T155_Firtina", side = 2, cratesRequired = 3 },
        { multiple = { 1002.03, 1002.03, 1002.03 }, desc = ctld.i18n_translate("T155 Firtina - All crates"),  side = 2 },
        { weight = 1002.04,                         desc = ctld.i18n_translate("Howitzer"),                   unit = "M-109",        side = 2, cratesRequired = 3 },
        { multiple = { 1002.04, 1002.04, 1002.04 }, desc = ctld.i18n_translate("Howitzer - All crates"),      side = 2 },

        --- RED
        { weight = 1002.11,                         desc = ctld.i18n_translate("SPH 2S19 Msta"),              unit = "SAU Msta",     side = 1, cratesRequired = 3 },
        { multiple = { 1002.11, 1002.11, 1002.11 }, desc = ctld.i18n_translate("SPH 2S19 Msta - All crates"), side = 1 },

    },
    ["SAM short range"] = {
        --- BLUE
        { weight = 1003.01,                         desc = ctld.i18n_translate("M1097 Avenger"),                unit = "M1097 Avenger",       side = 2, cratesRequired = 3 },
        { multiple = { 1003.01, 1003.01, 1003.01 }, desc = ctld.i18n_translate("M1097 Avenger - All crates"),   side = 2 },
        { weight = 1003.02,                         desc = ctld.i18n_translate("M48 Chaparral"),                unit = "M48 Chaparral",       side = 2, cratesRequired = 2 },
        { multiple = { 1003.02, 1003.02 },          desc = ctld.i18n_translate("M48 Chaparral - All crates"),   side = 2 },
        { weight = 1003.03,                         desc = ctld.i18n_translate("Roland ADS"),                   unit = "Roland ADS",          side = 2, cratesRequired = 3 },
        { multiple = { 1003.03, 1003.03, 1003.03 }, desc = ctld.i18n_translate("Roland ADS - All crates"),      side = 2 },
        { weight = 1003.04,                         desc = ctld.i18n_translate("Gepard AAA"),                   unit = "Gepard",              side = 2, cratesRequired = 3 },
        { multiple = { 1003.04, 1003.04, 1003.04 }, desc = ctld.i18n_translate("Gepard AAA - All crates"),      side = 2 },
        { weight = 1003.05,                         desc = ctld.i18n_translate("LPWS C-RAM"),                   unit = "HEMTT_C-RAM_Phalanx", side = 2, cratesRequired = 3 },
        { multiple = { 1003.05, 1003.05, 1003.05 }, desc = ctld.i18n_translate("LPWS C-RAM - All crates"),      side = 2 },

        --- RED
        { weight = 1003.11,                         desc = ctld.i18n_translate("9K33 Osa"),                     unit = "Osa 9A33 ln",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.11, 1003.11, 1003.11 }, desc = ctld.i18n_translate("9K33 Osa - All crates"),        side = 1 },
        { weight = 1003.12,                         desc = ctld.i18n_translate("9P31 Strela-1"),                unit = "Strela-1 9P31",       side = 1, cratesRequired = 3 },
        { multiple = { 1003.12, 1003.12, 1003.12 }, desc = ctld.i18n_translate("9P31 Strela-1 - All crates"),   side = 1 },
        { weight = 1003.13,                         desc = ctld.i18n_translate("9K35M Strela-10"),              unit = "Strela-10M3",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.13, 1003.13, 1003.13 }, desc = ctld.i18n_translate("9K35M Strela-10 - All crates"), side = 1 },
        { weight = 1003.14,                         desc = ctld.i18n_translate("9K331 Tor"),                    unit = "Tor 9A331",           side = 1, cratesRequired = 3 },
        { multiple = { 1003.14, 1003.14, 1003.14 }, desc = ctld.i18n_translate("9K331 Tor - All crates"),       side = 1 },
        { weight = 1003.15,                         desc = ctld.i18n_translate("2K22 Tunguska"),                unit = "2S6 Tunguska",        side = 1, cratesRequired = 3 },
        { multiple = { 1003.15, 1003.15, 1003.15 }, desc = ctld.i18n_translate("2K22 Tunguska - All crates"),   side = 1 },
    },
    ["SAM mid range"] = {
        --- BLUE
        -- HAWK System
        { weight = 1004.01,                         desc = ctld.i18n_translate("HAWK Launcher"),             unit = "Hawk ln",              side = 2 },
        { weight = 1004.02,                         desc = ctld.i18n_translate("HAWK Search Radar"),         unit = "Hawk sr",              side = 2 },
        { weight = 1004.03,                         desc = ctld.i18n_translate("HAWK Track Radar"),          unit = "Hawk tr",              side = 2 },
        { weight = 1004.04,                         desc = ctld.i18n_translate("HAWK PCP"),                  unit = "Hawk pcp",             side = 2 },
        { weight = 1004.05,                         desc = ctld.i18n_translate("HAWK CWAR"),                 unit = "Hawk cwar",            side = 2 },
        { weight = 1004.06,                         desc = ctld.i18n_translate("HAWK Repair"),               unit = "HAWK Repair",          side = 2 },
        { multiple = { 1004.01, 1004.02, 1004.03 }, desc = ctld.i18n_translate("HAWK - All crates"),         side = 2 },
        -- End of HAWK

        -- NASAMS Sysyem
        { weight = 1004.11,                         desc = ctld.i18n_translate("NASAMS Launcher 120C"),      unit = "NASAMS_LN_C",          side = 2 },
        { weight = 1004.12,                         desc = ctld.i18n_translate("NASAMS Search/Track Radar"), unit = "NASAMS_Radar_MPQ64F1", side = 2 },
        { weight = 1004.13,                         desc = ctld.i18n_translate("NASAMS Command Post"),       unit = "NASAMS_Command_Post",  side = 2 },
        { weight = 1004.14,                         desc = ctld.i18n_translate("NASAMS Repair"),             unit = "NASAMS Repair",        side = 2 },
        { multiple = { 1004.11, 1004.12, 1004.13 }, desc = ctld.i18n_translate("NASAMS - All crates"),       side = 2 },
        -- End of NASAMS

        --- RED
        -- KUB SYSTEM
        { weight = 1004.21,                         desc = ctld.i18n_translate("KUB Launcher"),              unit = "Kub 2P25 ln",          side = 1 },
        { weight = 1004.22,                         desc = ctld.i18n_translate("KUB Radar"),                 unit = "Kub 1S91 str",         side = 1 },
        { weight = 1004.23,                         desc = ctld.i18n_translate("KUB Repair"),                unit = "KUB Repair",           side = 1 },
        { multiple = { 1004.21, 1004.22 },          desc = ctld.i18n_translate("KUB - All crates"),          side = 1 },
        -- End of KUB

        -- BUK System
        { weight = 1004.31,                         desc = ctld.i18n_translate("BUK Launcher"),              unit = "SA-11 Buk LN 9A310M1", side = 1 },
        { weight = 1004.32,                         desc = ctld.i18n_translate("BUK Search Radar"),          unit = "SA-11 Buk SR 9S18M1",  side = 1 },
        { weight = 1004.33,                         desc = ctld.i18n_translate("BUK CC Radar"),              unit = "SA-11 Buk CC 9S470M1", side = 1 },
        { weight = 1004.34,                         desc = ctld.i18n_translate("BUK Repair"),                unit = "BUK Repair",           side = 1 },
        { multiple = { 1004.31, 1004.32, 1004.33 }, desc = ctld.i18n_translate("BUK - All crates"),          side = 1 },
        -- END of BUK
    },
    ["SAM long range"] = {
        --- BLUE
        -- Patriot System
        { weight = 1005.01,                                           desc = ctld.i18n_translate("Patriot Launcher"),            unit = "Patriot ln",        side = 2 },
        { weight = 1005.02,                                           desc = ctld.i18n_translate("Patriot Radar"),               unit = "Patriot str",       side = 2 },
        { weight = 1005.03,                                           desc = ctld.i18n_translate("Patriot ECS"),                 unit = "Patriot ECS",       side = 2 },
        -- { weight = 1005.04, desc = ctld.i18n_translate("Patriot ICC"), unit = "Patriot cp", side = 2 },
        -- { weight = 1005.05, desc = ctld.i18n_translate("Patriot EPP"), unit = "Patriot EPP", side = 2 },
        { weight = 1005.06,                                           desc = ctld.i18n_translate("Patriot AMG (optional)"),      unit = "Patriot AMG",       side = 2 },
        { weight = 1005.07,                                           desc = ctld.i18n_translate("Patriot Repair"),              unit = "Patriot Repair",    side = 2 },
        { multiple = { 1005.01, 1005.02, 1005.03 },                   desc = ctld.i18n_translate("Patriot - All crates"),        side = 2 },
        -- End of Patriot

        -- S-300 SYSTEM
        { weight = 1005.11,                                           desc = ctld.i18n_translate("S-300 Grumble TEL C"),         unit = "S-300PS 5P85C ln",  side = 1 },
        { weight = 1005.12,                                           desc = ctld.i18n_translate("S-300 Grumble Flap Lid-A TR"), unit = "S-300PS 40B6M tr",  side = 1 },
        { weight = 1005.13,                                           desc = ctld.i18n_translate("S-300 Grumble Clam Shell SR"), unit = "S-300PS 40B6MD sr", side = 1 },
        { weight = 1005.14,                                           desc = ctld.i18n_translate("S-300 Grumble Big Bird SR"),   unit = "S-300PS 64H6E sr",  side = 1 },
        { weight = 1005.15,                                           desc = ctld.i18n_translate("S-300 Grumble C2"),            unit = "S-300PS 54K6 cp",   side = 1 },
        { weight = 1005.16,                                           desc = ctld.i18n_translate("S-300 Repair"),                unit = "S-300 Repair",      side = 1 },
        { multiple = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = ctld.i18n_translate("Patriot - All crates"),        side = 1 },
        -- End of S-300
    },
    ["Drone"] = {
        --- BLUE MQ-9 Repear
        { weight = 1006.01, desc = ctld.i18n_translate("MQ-9 Repear - JTAC"),    unit = "MQ-9 Reaper",    side = 2 },
        -- End of BLUE MQ-9 Repear

        --- RED MQ-1A Predator
        { weight = 1006.11, desc = ctld.i18n_translate("MQ-1A Predator - JTAC"), unit = "RQ-1A Predator", side = 1 },
        -- End of RED MQ-1A Predator
    },
    --["FARP Alpha"] = {{ weight = 1007.01, desc = ctld.i18n_translate("FARP Alpha"), unit = "FARP Alpha", cratesRequired = 1 }, },
    --- Single Farp
    --["mineField"] = {{ weight = 1007.02, desc = ctld.i18n_translate("mineField"), unit = "mineField", cratesRequired = 1 },},
}

ctld.spawnableCratesModels = {
    ["load"] = {
        ["category"] = "Cargos", --"Fortifications"
        ["type"] = "ammo_cargo", --"uh1h_cargo"    --"Cargo04"
        ["canCargo"] = false,
    },
    ["sling"] = {
        ["category"] = "Cargos",
        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",
        ["canCargo"] = true
    },
    ["dynamic"] = {
        ["category"] = "Cargos",
        ["type"] = "ammo_cargo",
        ["canCargo"] = true
    }
}


--[[ Placeholder for different type of cargo containers. Let's say pipes and trunks, fuel for FOB building
        ["shape_name"] = "ab-212_cargo",
        ["type"] = "uh1h_cargo" --new type for the container previously used

        ["shape_name"] = "ammo_box_cargo",
        ["type"] = "ammo_cargo",

        ["shape_name"] = "barrels_cargo",
        ["type"] = "barrels_cargo",

        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",

        ["shape_name"] = "f_bar_cargo",
        ["type"] = "f_bar_cargo",

        ["shape_name"] = "fueltank_cargo",
        ["type"] = "fueltank_cargo",

        ["shape_name"] = "iso_container_cargo",
        ["type"] = "iso_container",

        ["shape_name"] = "iso_container_small_cargo",
        ["type"] = "iso_container_small",

        ["shape_name"] = "oiltank_cargo",
        ["type"] = "oiltank_cargo",

        ["shape_name"] = "pipes_big_cargo",
        ["type"] = "pipes_big_cargo",

        ["shape_name"] = "pipes_small_cargo",
        ["type"] = "pipes_small_cargo",

        ["shape_name"] = "tetrapod_cargo",
        ["type"] = "tetrapod_cargo",

        ["shape_name"] = "trunks_long_cargo",
        ["type"] = "trunks_long_cargo",

        ["shape_name"] = "trunks_small_cargo",
        ["type"] = "trunks_small_cargo",
]] --

-- if the unit is on this list, it will be made into a JTAC when deployed
ctld.jtacUnitTypes     = {
    "SKP", "Hummer",          -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
    "MQ", "RQ"                --"MQ-9 Repear", "RQ-1A Predator"}
}
ctld.jtacDroneRadius   = 1000 -- JTAC offset radius in meters for orbiting drones
ctld.jtacDroneAltitude = 7000 -- JTAC altitude in meters for orbiting drones
-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************

-----------------------------------------------------------------
-- Spawn group at a trigger and set them as extractable. Usage:
-- ctld.spawnGroupAtTrigger("groupside", number, "triggerName", radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group description
-- "triggerName" = trigger name in mission editor between commas
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtTrigger("red", 2, "spawn1", 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtTrigger("blue", {mg=1,at=2,aa=3,inf=4,mortar=5},"spawn2", 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
--
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    local _spawnTrigger = trigger.misc.getZone(_triggerName) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find trigger called %1", _triggerName), 10)
        return
    end

    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_pos3, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-----------------------------------------------------------------
-- Spawn group at a Vec3 Point and set them as extractable. Usage:
-- ctld.spawnGroupAtPoint("groupside", number,Vec3 Point, radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group Description
-- Vec3 Point = A vec3 point like {x=1,y=2,z=3}. Can be obtained from a unit like so: Unit.getName("Unit1"):getPoint()
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtPoint("red", 2, {x=1,y=2,z=3}, 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtPoint("blue", {mg=1,at=2,aa=3,inf=4,mortar=5}, {x=1,y=2,z=3}, 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
function ctld.spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)
    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_point, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-- Preloads a transport with troops or vehicles
-- replaces any troops currently on board
function ctld.preLoadTransport(_unitName, _number, _troops)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        -- will replace any units currently on board
        --                if not ctld.troopsOnboard(_unit,_troops)    then
        ctld.loadTroops(_unit, _troops, _number)
        --                end
    end
end

-- Continuously counts the number of crates in a zone and sets the value of the passed in flag
-- to the count amount
-- This means you can trigger actions based on the count and also trigger messages before the count is reached
-- Just pass in the zone name and flag number like so as a single (NOT Continuous) Trigger
-- This will now work for Mission Editor and Spawned Crates
-- e.g. ctld.cratesInZone("DropZone1", 5)
function ctld.cratesInZone(_zone, _flagNumber)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.cratesInZone()", _zone)

    --ignore side, if crate has been used its discounted from the count
    local _crateTables = { ctld.spawnedCratesRED, ctld.spawnedCratesBLUE, ctld.missionEditorCargoCrates }

    local _crateCount = 0

    for _, _crates in pairs(_crateTables) do
        for _crateName, _dontUse in pairs(_crates) do
            --get crate
            local _crate = ctld.getCrateObject(_crateName)

            --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
            if _crate ~= nil and _crate:getLife() > 0
                and (ctld.inAir(_crate) == false) then
                local _dist = ctld.utils.getDistance("ctld.cratesInZone()", _crate:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    _crateCount = _crateCount + 1
                end
            end
        end
    end

    --set flag stuff
    trigger.action.setUserFlag(_flagNumber, _crateCount)

    -- env.info("FLAG ".._flagNumber.." crates ".._crateCount)

    --retrigger in 5 seconds
    timer.scheduleFunction(function(_args)
        ctld.cratesInZone(_args[1], _args[2])
    end, { _zone, _flagNumber }, timer.getTime() + 5)
end

-- Creates an extraction zone
-- any Soldiers (not vehicles) dropped at this zone by a helicopter will disappear
-- and be added to a running total of soldiers for a set flag number
-- The idea is you can then drop say 20 troops in a zone and trigger an action using the mission editor triggers
-- and the flag value
--
-- The ctld.createExtractZone function needs to be called once in a trigger action do script.
-- if you dont want smoke, pass -1 to the function.
--Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4, NO SMOKE = -1
--
-- e.g. ctld.createExtractZone("extractzone1", 2, -1) will create an extraction zone at trigger zone "extractzone1", store the number of troops dropped at
-- the zone in flag 2 and not have smoke
--
--
--
function ctld.createExtractZone(_zone, _flagNumber, _smoke)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    trigger.action.setUserFlag(_flagNumber, 0) --start at 0

    local _details = { point = _pos3, name = _zone, smoke = _smoke, flag = _flagNumber, radius = _triggerZone.radius }

    ctld.extractZones[_zone .. "-" .. _flagNumber] = _details

    if _smoke ~= nil and _smoke > -1 then
        local _smokeFunction

        _smokeFunction = function(_args)
            local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]
            -- check zone is still active
            if _extractDetails == nil then
                -- stop refreshing smoke, zone is done
                return
            end


            trigger.action.smoke(_args.point, _args.smoke)
            --refresh in 5 minutes
            timer.scheduleFunction(_smokeFunction, _args, timer.getTime() + 300)
        end

        --run local function
        _smokeFunction(_details)
    end
end

-- Removes an extraction zone
--
-- The smoke will take up to 5 minutes to disappear depending on the last time the smoke was activated
--
-- The ctld.removeExtractZone function needs to be called once in a trigger action do script.
--
-- e.g. ctld.removeExtractZone("extractzone1", 2) will remove an extraction zone at trigger zone "extractzone1"
-- that was setup with flag 2
--
--
--
function ctld.removeExtractZone(_zone, _flagNumber)
    local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]

    if _extractDetails ~= nil then
        --remove zone
        ctld.extractZones[_zone .. "-" .. _flagNumber] = nil
    end
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- GROUPS in a zone and store the values in two flags
-- A group is only counted as being in a zone when the leader of that group
-- is in the zone
-- Use: ctld.countDroppedGroupsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedGroupsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedGroupsInZone()", _zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }
    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedGroupsInZone()", _zone)
                local _dist = ctld.utils.getDistance("ctld.countDroppedGroupsInZone()", _groupUnits[1]:getPoint(),
                    _zonePos)

                if _dist <= _triggerZone.radius then
                    if (_groupUnits[1]:getCoalition() == 1) then
                        _redCount = _redCount + 1;
                    else
                        _blueCount = _blueCount + 1;
                    end
                end
            end
        end
    end
    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Groups in zone ".._blueCount.." ".._redCount)
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- UNITS in a zone and store the values in two flags

-- Use: ctld.countDroppedUnitsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedUnitsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedUnitsInZone()", _zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }

    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = ctld.utils.zoneToVec3("ctld.countDroppedUnitsInZone()", _zone)
                for _, _unit in pairs(_groupUnits) do
                    local _dist = ctld.utils.getDistance("ctld.countDroppedUnitsInZone()", _unit:getPoint(), _zonePos)

                    if _dist <= _triggerZone.radius then
                        if (_unit:getCoalition() == 1) then
                            _redCount = _redCount + 1;
                        else
                            _blueCount = _blueCount + 1;
                        end
                    end
                end
            end
        end
    end


    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Units in zone ".._blueCount.." ".._redCount)
end

--***************************************************************
function ctld.getNextDynamicLogisticUnitIndex()
    ctld.dynamicLogisticUnitsIndex = ctld.dynamicLogisticUnitsIndex + 1
    return ctld.dynamicLogisticUnitsIndex
end

-- Creates a radio beacon on a random UHF - VHF and HF/FM frequency for homing
-- This WILL NOT WORK if you dont add beacon.ogg and beaconsilent.ogg to the mission!!!
-- e.g. ctld.createRadioBeaconAtZone("beaconZone","red", 1440,"Waypoint 1") will create a beacon at trigger zone "beaconZone" for the Red side
-- that will last 1440 minutes (24 hours ) and named "Waypoint 1" in the list of radio beacons
--
-- e.g. ctld.createRadioBeaconAtZone("beaconZoneBlue","blue", 20) will create a beacon at trigger zone "beaconZoneBlue" for the Blue side
-- that will last 20 minutes
function ctld.createRadioBeaconAtZone(_zone, _coalition, _batteryLife, _name)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = ctld.utils.zoneToVec3("ctld.createRadioBeaconAtZone()", _zone)

    ctld.beaconCount = ctld.beaconCount + 1

    if _name == nil or _name == "" then
        _name = "Beacon #" .. ctld.beaconCount
    end

    if _coalition == "red" then
        ctld.createRadioBeacon(_zonePos, 1, 0, _name, _batteryLife) --1440
    else
        ctld.createRadioBeacon(_zonePos, 2, 2, _name, _batteryLife) --1440
    end
end

-- Activates a pickup zone
-- Activates a pickup zone when called from a trigger
-- EG: ctld.activatePickupZone("pickzone3")
-- This is enable pickzone3 to be used as a pickup zone for the team set
function ctld.activatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone or ship called %1", _zoneName), 10)
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[4] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[4] = 1                  --activate zone

            if ctld.disableAllSmoke == true then --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a pickup zone
-- Deactivates a pickup zone when called from a trigger
-- EG: ctld.deactivatePickupZone("pickzone3")
-- This is disables pickzone3 and can no longer be used to as a pickup zone
-- These functions can be called by triggers, like if a set of buildings is used, you can trigger the zone to be 'not operational'
-- once they are destroyed
function ctld.deactivatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            -- i'd just ignore it if its already been deactivated
            _zoneDetails[4] = 0 --deactivate zone
        end
    end
end

-- Change the remaining groups currently available for pickup at a zone
-- e.g. ctld.changeRemainingGroupsForPickupZone("pickup1", 5) -- adds 5 groups
-- ctld.changeRemainingGroupsForPickupZone("pickup1", -3) -- remove 3 groups
function ctld.changeRemainingGroupsForPickupZone(_zoneName, _amount)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            ctld.updateZoneCounter(_zoneName, _amount)
        end
    end
end

-- Activates a Waypoint zone
-- Activates a Waypoint zone when called from a trigger
-- EG: ctld.activateWaypointZone("pickzone3")
-- This means that troops dropped within the radius of the zone will head to the center
-- of the zone instead of searching for troops
function ctld.activateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position


    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)

        return
    end

    for _, _zoneDetails in pairs(ctld.wpZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[3] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[3] = 1                  --activate zone

            if ctld.disableAllSmoke == true then --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a Waypoint zone
-- Deactivates a Waypoint zone when called from a trigger
-- EG: ctld.deactivateWaypointZone("wpzone3")
-- This disables wpzone3 so that troops dropped in this zone will search for troops as normal
-- These functions can be called by triggers
function ctld.deactivateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            _zoneDetails[3] = 0 --deactivate zone
        end
    end
end

-- Continuous Trigger Function
-- Causes an AI unit with the specified name to unload troops / vehicles when
-- an enemy is detected within a specified distance
-- The enemy must have Line or Sight to the unit to be detected
function ctld.unloadInProximityToEnemy(_unitName, _distance)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil and _unit:getPlayerName() == nil then
        -- no player name means AI!
        -- the findNearest visible enemy you'd want to modify as it'll find enemies quite far away
        -- limited by    ctld.JTAC_maxDistance
        local _nearestEnemy = ctld.findNearestVisibleEnemy(_unit, "all", _distance)

        if _nearestEnemy ~= nil then
            if ctld.troopsOnboard(_unit, true) then
                ctld.deployTroops(_unit, true)
                return true
            end

            if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
                ctld.deployTroops(_unit, false)
                return true
            end
        end
    end

    return false
end

-- Unit will unload any units onboard if the unit is on the ground
-- when this function is called
function ctld.unloadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        if ctld.troopsOnboard(_unit, true) then
            ctld.unloadTroops({ _unitName, true })
        end

        if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
            ctld.unloadTroops({ _unitName, false })
        end
    end
end

-- Loads Troops and Vehicles from a zone or picks up nearby troops or vehicles
function ctld.loadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        ctld.loadTroopsFromZone({ _unitName, true, "", true })

        if ctld.unitCanCarryVehicles(_unit) then
            ctld.loadTroopsFromZone({ _unitName, false, "", true })
        end
    end
end

-- adds a callback that will be called for many actions ingame
function ctld.addCallback(_callback)
    table.insert(ctld.callbacks, _callback)
end

-- Spawns a sling loadable crate at a Trigger Zone
--
-- Weights can be found in the ctld.spawnableCrates list
-- e.g. ctld.spawnCrateAtZone("red", 500,"triggerzone1") -- spawn a humvee at triggerzone 1 for red side
-- e.g. ctld.spawnCrateAtZone("blue", 505,"triggerzone1") -- spawn a tow humvee at triggerzone1 for blue side
--
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    local _spawnTrigger = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _point = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side)
end

-- Spawns a sling loadable crate at a Point
--
-- Weights can be found in the ctld.spawnableCrates list
-- Points can be made by hand or obtained from a Unit position by Unit.getByName("PilotName"):getPoint()
-- e.g. ctld.spawnCrateAtPoint("red", 500,{x=1,y=2,z=3}) -- spawn a humvee at triggerzone 1 for red side at a specified point
-- e.g. ctld.spawnCrateAtPoint("blue", 505,{x=1,y=2,z=3}) -- spawn a tow humvee at triggerzone1 for blue side at a specified point
--
--
function ctld.spawnCrateAtPoint(_side, _weight, _point, _hdg)
    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side, _hdg)
end

-- ***************************************************************
function ctld.getSecureDistanceFromUnit(_unitName) -- return a distance between the center of unitName, to be sure not touch the unitName
    local rotorDiameter = 0                        --19    -- meters  -- õk for UH & CH47
    if Unit.getByName(_unitName) then
        local unitUserBox = Unit.getByName(_unitName):getDesc().box
        local SecureDistanceFromUnit = 0
        if math.abs(unitUserBox.max.x) >= math.abs(unitUserBox.min.x) then
            SecureDistanceFromUnit = math.abs(unitUserBox.max.x) + (rotorDiameter / 2)
        else
            SecureDistanceFromUnit = math.abs(unitUserBox.min.x) + (rotorDiameter / 2)
        end
        return SecureDistanceFromUnit
    end
    return nil
end

-- ***************************************************************
--               Repack vehicules crates functions
-- ***************************************************************
ctld.repackRequestsStack = {}                 -- table to store the repack request
ctld.inAirMemorisation   = {}                 -- last helico state of InAir()
function ctld.updateRepackMenuOnlanding(p, t) -- update helo repack menu when a helo landing is detected
    if t == nil then t = timer.getTime() + 1; end
    if ctld.transportPilotNames then
        for _, _unitName in pairs(ctld.transportPilotNames) do
            if Unit.getByName(_unitName) ~= nil and Unit.getByName(_unitName):isActive() == true then
                if ctld.inAirMemorisation[_unitName] == nil then ctld.inAirMemorisation[_unitName] = false end -- init InAir() state
                local _heli = Unit.getByName(_unitName)
                if ctld.inAir(_heli) == false then
                    if ctld.inAirMemorisation[_unitName] == true then -- if transition from inAir to Landed => updateRepackMenu
                        ctld.updateRepackMenu(_unitName)
                    end
                    ctld.inAirMemorisation[_unitName] = false
                else
                    ctld.inAirMemorisation[_unitName] = true
                end
            end
        end
    end
    return t + 5 -- reschdule each 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInRepackRadius(_PlayerTransportUnitName, _radius)
    if _radius == nil then
        _radius = ctld.maximumDistanceRepackableUnitsSearch
    end

    local unit = ctld.getTransportUnit(_PlayerTransportUnitName)
    if unit == nil then
        return
    end

    local unitsNamesList  = ctld.getNearbyUnits(unit:getPoint(), _radius, unit:getCoalition())

    local repackableUnits = {}
    for i = 1, #unitsNamesList do
        local unitObject     = Unit.getByName(unitsNamesList[i])
        local repackableUnit = ctld.isRepackableUnit(unitsNamesList[i])
        if repackableUnit then
            repackableUnit["repackableUnitGroupID"] = unitObject:getGroup():getID()
            table.insert(repackableUnits, ctld.utils.deepCopy("ctld.getUnitsInRepackRadius()", repackableUnit))
        end
    end
    return repackableUnits
end

-- ***************************************************************
function ctld.getNearbyUnits(_point, _radius, _coalition)
    if _coalition == nil then
        _coalition = 4 -- all coalitions
    end
    local unitsByDistance = {}
    local cpt = 1
    local _units = {}
    for _, _unitName in pairs(ctld.utils.getUnitsListNamesByCategory("ctld.getNearbyUnits()", _coalition, { Group.Category.GROUND })) do
        local u = Unit.getByName(_unitName)
        local e = (u and u:isExist()) or false
        -- pcall is needed because getCoalition() fails if the unit is an object without coalition (like a smoke effect)
        local c = nil
        pcall(function() c = (u and e and u:getCoalition()) or nil end)
        if u and e and (_coalition == 4 or c == _coalition) then
            local _dist = ctld.utils.get2DDist("ctld.getNearbyUnits()", u:getPoint(), _point)
            if _dist <= _radius then
                unitsByDistance[cpt] = { id = cpt, dist = _dist, unit = _unitName, typeName = u:getTypeName() }
                cpt = cpt + 1
            end
        end
    end

    --table.sort(unitsByDistance, function(a,b) return a.dist < b.dist end)       -- sort the table by distance (the nearest first)
    table.sort(unitsByDistance, function(a, b) return a.typeName < b.typeName end) -- sort the table by typeNAme
    for i, v in ipairs(unitsByDistance) do
        table.insert(_units, v.unit)                                               -- insert nearby unitName
    end
    return _units
end

-- ***************************************************************
function ctld.isRepackableUnit(_unitName)
    local unitObject = Unit.getByName(_unitName)
    local unitType   = unitObject:getTypeName()
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _unitName then
                if ctld.spawnableCrates[k][i].unit == unitType then
                    local repackableUnit = ctld.utils.deepCopy("ctld.isRepackableUnit", ctld.spawnableCrates[k]
                        [i])
                    repackableUnit["repackableUnitName"] = _unitName
                    return repackableUnit
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.getCrateDesc(_crateWeight)
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _crateWeight then
                if ctld.spawnableCrates[k][i].weight == _crateWeight then
                    return ctld.spawnableCrates[k][i]
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.repackVehicleRequest(_params) -- update rrs table 'repackRequestsStack' with the request
    --ctld.logTrace("FG_    ctld.repackVehicleRequest._params = " .. ctld.p(_params))
    ctld.repackRequestsStack[#ctld.repackRequestsStack + 1] = _params
end

-- ***************************************************************
function ctld.repackVehicle(_params, t) -- scan rrs table 'repackRequestsStack' to process each request
    --ctld.logTrace("FG_ XXXXXXXXXXXXXXXXXXXXXXXXXXX ctld.repackVehicle.ctld.repackRequestsStack XXXXXXXXXXXXXXXXXXXXXXXXXXX")
    if t == nil then
        t = timer.getTime()
    end
    if #ctld.repackRequestsStack ~= 0 then
        ctld.logTrace("FG_    ctld.repackVehicle.ctld.repackRequestsStack = %s", ctld.p(ctld.repackRequestsStack))
    end
    for ii, v in ipairs(ctld.repackRequestsStack) do
        ctld.logTrace("FG_    ctld.repackVehicle.v[%s] = %s", ii, ctld.p(v))
        local repackableUnitName = v.repackableUnitName
        local repackableUnit     = Unit.getByName(repackableUnitName)
        local crateWeight        = v.weight
        local playerUnitName     = v.playerUnitName
        if repackableUnit then
            if repackableUnit:isExist() then
                local PlayerTransportUnit = Unit.getByName(playerUnitName)
                local playerCoa           = PlayerTransportUnit:getCoalition()
                local refCountry          = PlayerTransportUnit:getCountry()
                -- calculate the heading of the spawns to be carried out
                local playerHeading       = ctld.utils.getHeadingInRadians("ctld.repackVehicle()", PlayerTransportUnit)
                local playerPoint         = PlayerTransportUnit:getPoint()
                local offset              = 5
                local randomHeading       = ctld.utils.RandomReal("ctld.repackVehicle()", playerHeading - math.pi / 4,
                    playerHeading + math.pi / 4)
                if ctld.unitDynamicCargoCapable(PlayerTransportUnit) ~= false then
                    randomHeading = ctld.utils.RandomReal("ctld.repackVehicle()", playerHeading + math.pi - math.pi / 4,
                        playerHeading + math.pi + math.pi / 4)
                end
                repackableUnit:destroy() -- destroy repacked unit
                for i = 1, v.cratesRequired or 1 do
                    -- see to spawn the crate at random position heading the transport unit
                    local _unitId        = ctld.getNextUnitId()
                    local _name          = string.format("%s_%i", v.desc, _unitId)
                    local secureDistance = ctld.getSecureDistanceFromUnit(playerUnitName) or 10
                    local relativePoint  = ctld.getRelativePoint(playerPoint, secureDistance + (i * offset),
                        randomHeading) -- 7 meters from the transport unit

                    if ctld.unitDynamicCargoCapable(PlayerTransportUnit) == false then
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa,
                            playerHeading, nil)
                    else
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa,
                            playerHeading, "dynamic")
                    end
                end
            end
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
        end
        ctld.repackRequestsStack[ii] = nil                                                                 -- remove the processed request from the stacking table
    end



    if ctld.enableRepackingVehicles == true then
        return t + 3 -- reschedule the function in 3 seconds
    else
        return nil   --stop scheduling
    end
end

-- ***************************************************************
function ctld.addStaticLogisticUnit(_point, _country) -- create a temporary logistic unit with a Windsock object
    local dynamicLogisticUnitName = "%dynLogisticName_" .. tostring(ctld.getNextDynamicLogisticUnitIndex())
    ctld.logisticUnits[#ctld.logisticUnits + 1] = dynamicLogisticUnitName
    local LogUnit = {
        ["category"] = "Fortifications",
        ["shape_name"] = "H-Windsock_RW",
        ["type"] = "Windsock",
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = dynamicLogisticUnitName,
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    LogUnit["country"] = _country
    ctld.utils.dynAddStatic("ctld.addStaticLogisticUnit", LogUnit)
    return StaticObject.getByName(LogUnit["name"])
end

-- ***************************************************************
function ctld.updateDynamicLogisticUnitsZones() -- remove Dynamic Logistic Units if no statics units (crates) are in the zone
    local _units = {}
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if string.sub(logUnit, 1, 17) == "%dynLogisticName_" then -- check if the unit is a dynamic logistic unit
            local unitsInLogisticUnitZone = ctld.getUnitsInLogisticZone(logUnit)
            if #unitsInLogisticUnitZone == 0 then
                local _logUnit = StaticObject.getByName(logUnit)
                if _logUnit then
                    _logUnit:destroy()          -- destroy the    dynamic Logistic unit object from map
                    ctld.logisticUnits[i] = nil -- remove the dynamic Logistic unit from the list
                end
            end
        end
    end
    return 5 -- reschedule the function in 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInLogisticZone(_logisticUnitName, _coalition)
    local _unit = StaticObject.getByName(_logisticUnitName)
    if _unit then
        local _point = _unit:getPoint()
        local _unitList = ctld.getNearbyUnits(_point, ctld.maximumDistanceLogistic, _coalition)
        return _unitList
    end
    return {}
end

-- ***************************************************************
function ctld.isUnitInNamedLogisticZone(_unitName, _logisticUnitName) -- check if a unit is in the named logistic zone
    --ctld.logTrace("FG_    ctld.isUnitInNamedLogisticZone._logisticUnitName = %s", ctld.p(_logisticUnitName))
    local _unit = Unit.getByName(_unitName)
    if _unit == nil then
        return false
    end
    local unitPoint = _unit:getPoint()
    if StaticObject.getByName(_logisticUnitName) then
        local logisticUnitPoint = StaticObject.getByName(_logisticUnitName):getPoint()
        local _dist = ctld.utils.getDistance("ctld.isUnitInNamedLogisticZone()", unitPoint, logisticUnitPoint)
        if _dist <= ctld.maximumDistanceLogistic then
            return true
        end
    end
    return false
end

-- ***************************************************************
function ctld.isUnitInALogisticZone(_unitName) -- check if a unit is in a logistic zone if true then return the logisticUnitName of the zone
    --ctld.logTrace("FG_    ctld.isUnitInALogisticZone._unitName = %s", ctld.p(_unitName))
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if ctld.isUnitInNamedLogisticZone(_unitName, logUnit) then
            return logUnit
        end
    end
    return nil
end

-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

--- Tells CTLD What multipart AA Systems there are and what parts they need
-- A New system added here also needs the launcher added
-- The number of times that each part is spawned for each system is specified by the entry "amount", NOTE : they will be spawned in a circle with the corresponding headings, NOTE 2 : launchers will use the default ctld.aaLauncher amount if nothing is specified
-- If a component does not require a crate, it can be specified via the entry "NoCrate" set to true
ctld.AASystemTemplate = {

    {
        name = "HAWK AA System",
        count = 5,
        parts = {
            { name = "Hawk ln",   desc = "HAWK Launcher",     launcher = true },
            { name = "Hawk tr",   desc = "HAWK Track Radar",  amount = 2 },
            { name = "Hawk sr",   desc = "HAWK Search Radar", amount = 2 },
            { name = "Hawk pcp",  desc = "HAWK PCP",          NoCrate = true },
            { name = "Hawk cwar", desc = "HAWK CWAR",         amount = 2,     NoCrate = true },
        },
        repair = "HAWK Repair",
    },
    {
        name = "Patriot AA System",
        count = 4,
        parts = {
            { name = "Patriot ln",  desc = "Patriot Launcher",               launcher = true, amount = 8 },
            { name = "Patriot ECS", desc = "Patriot Control Unit" },
            { name = "Patriot str", desc = "Patriot Search and Track Radar", amount = 2 },
            --{name = "Patriot cp", desc = "Patriot ICC", NoCrate = true},
            --{name = "Patriot EPP", desc = "Patriot EPP", NoCrate = true},
            { name = "Patriot AMG", desc = "Patriot AMG DL relay",           NoCrate = true },
        },
        repair = "Patriot Repair",
    },
    {
        name = "NASAMS AA System",
        count = 3,
        parts = {
            { name = "NASAMS_LN_C",          desc = "NASAMS Launcher 120C",     launcher = true },
            { name = "NASAMS_Radar_MPQ64F1", desc = "NASAMS Search/Track Radar" },
            { name = "NASAMS_Command_Post",  desc = "NASAMS Command Post" },
        },
        repair = "NASAMS Repair",
    },
    {
        name = "BUK AA System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher",    launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1",  desc = "BUK Search Radar" },
        },
        repair = "BUK Repair",
    },
    {
        name = "KUB AA System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln",  desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "KUB Repair",
    },
    {
        name = "S-300 AA System",
        count = 6,
        parts = {
            { desc = "S-300 Grumble TEL C",         name = "S-300PS 5P85C ln", launcher = true, amount = 1 },
            { desc = "S-300 Grumble TEL D",         name = "S-300PS 5P85D ln", NoCrate = true,  amount = 2 },
            { desc = "S-300 Grumble Flap Lid-A TR", name = "S-300PS 40B6M tr" },
            { desc = "S-300 Grumble Clam Shell SR", name = "S-300PS 40B6MD sr" },
            { desc = "S-300 Grumble Big Bird SR",   name = "S-300PS 64H6E sr" },
            { desc = "S-300 Grumble C2",            name = "S-300PS 54K6 cp" },
        },
        repair = "S-300 Repair",
    },
}


ctld.crateWait = {}
ctld.crateMove = {}

---------------- INTERNAL FUNCTIONS ----------------
---
---
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- print an object for a debugging log
function ctld.p(o, level)
    local MAX_LEVEL = 20
    if level == nil then level = 0 end
    if level > MAX_LEVEL then
        ctld.logError("max depth reached in ctld.p : " .. tostring(MAX_LEVEL))
        return ""
    end
    local text = ""
    if (type(o) == "table") then
        text = "\n"
        for key, value in pairs(o) do
            for i = 0, level do
                text = text .. " "
            end
            text = text .. "." .. key .. "=" .. ctld.p(value, level + 1) .. "\n"
        end
    elseif (type(o) == "function") then
        text = "[function]"
    elseif (type(o) == "boolean") then
        if o == true then
            text = "[true]"
        else
            text = "[false]"
        end
    else
        if o == nil then
            text = "[nil]"
        else
            text = tostring(o)
        end
    end
    return text
end

function ctld.formatText(text, ...)
    if not text then
        return ""
    end
    if type(text) ~= 'string' then
        text = ctld.p(text)
    else
        local args = ...
        if args and args.n and args.n > 0 then
            local pArgs = {}
            for i = 1, args.n do
                pArgs[i] = ctld.p(args[i])
            end
            text = text:format(unpack(pArgs))
        end
    end
    local fName = nil
    local cLine = nil
    if debug and debug.getinfo then
        local dInfo = debug.getinfo(3)
        fName = dInfo.name
        cLine = dInfo.currentline
    end
    if fName and cLine then
        return fName .. '|' .. cLine .. ': ' .. text
    elseif cLine then
        return cLine .. ': ' .. text
    else
        return ' ' .. text
    end
end

function ctld.logError(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" E - " .. ctld.Id .. message)
end

function ctld.logWarning(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" W - " .. ctld.Id .. message)
end

function ctld.logInfo(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" I - " .. ctld.Id .. message)
end

function ctld.logDebug(message, ...)
    if message and ctld.Debug then
        message = ctld.formatText(message, arg)
        env.info(" D - " .. ctld.Id .. message)
    end
end

function ctld.logTrace(message, ...)
    if message and ctld.Trace then
        message = ctld.formatText(message, arg)
        env.info(" T - " .. ctld.Id .. message)
    end
end

ctld.nextUnitId = 1;
ctld.getNextUnitId = function()
    ctld.nextUnitId = ctld.nextUnitId + 1

    return ctld.nextUnitId
end

ctld.nextGroupId = 1;

ctld.getNextGroupId = function()
    ctld.nextGroupId = ctld.nextGroupId + 1

    return ctld.nextGroupId
end

function ctld.getTransportUnit(_unitName)
    if _unitName == nil then
        return nil
    end

    local transportUnitObject = Unit.getByName(_unitName)

    if transportUnitObject ~= nil and transportUnitObject:isActive() and transportUnitObject:getLife() > 0 then
        return transportUnitObject
    end
    return nil
end

function ctld.spawnCrateStatic(_country, _unitId, _point, _name, _weight, _side, _hdg, _model_type)
    local _crate
    local _spawnedCrate

    local hdg = _hdg or 0

    if ctld.staticBugWorkaround and ctld.slingLoad == false then
        local _groupId = ctld.getNextGroupId()
        local _groupName = "Crate Group #" .. _groupId

        local _group = {
            ["visible"] = false,
            -- ["groupId"] = _groupId,
            ["hidden"] = false,
            ["units"] = {},
            --                ["y"] = _positions[1].z,
            --                ["x"] = _positions[1].x,
            ["name"] = _groupName,
            ["task"] = {},
        }

        _group.units[1] = ctld.createUnit(_point.x, _point.z, hdg, { type = "UAZ-469", name = _name, unitId = _unitId })

        --switch to MIST
        _group.category = Group.Category.GROUND;
        _group.country = _country;

        local _spawnedGroup = Group.getByName(ctld.utils.dynAdd("ctld.spawnCrateStatic", _group).name)

        -- Turn off AI
        trigger.action.setGroupAIOff(_spawnedGroup)

        _spawnedCrate = Unit.getByName(_name)
    else
        if _model_type ~= nil then
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels[_model_type])
        elseif ctld.slingLoad then
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels["sling"])
        else
            _crate = ctld.utils.deepCopy("ctld.spawnCrateStatic", ctld.spawnableCratesModels["load"])
        end

        _crate["y"] = _point.z
        _crate["x"] = _point.x
        _crate["mass"] = _weight
        _crate["name"] = _name
        _crate["heading"] = hdg
        _crate["country"] = _country

        ctld.utils.dynAddStatic("ctld.spawnCrateStatic()", _crate)

        _spawnedCrate = StaticObject.getByName(_crate["name"])
    end


    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _side == 1 then
        ctld.spawnedCratesRED[_name] = _crateType
    else
        ctld.spawnedCratesBLUE[_name] = _crateType
    end

    return _spawnedCrate
end

function ctld.spawnFOBCrateStatic(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["shape_name"] = "konteiner_red1",
        ["type"] = "Container red 1",
        --     ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country

    ctld.utils.dynAddStatic("ctld.spawnFOBCrateStatic", _crate)

    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end

function ctld.spawnFOB(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["type"] = "outpost",
        --    ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country
    ctld.utils.dynAddStatic("ctld.spawnFOB", _crate)
    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    local _id = ctld.getNextUnitId()
    local _tower = {
        ["type"] = "house2arm",
        --     ["unitId"] = _id,
        ["rate"] = 100,
        ["y"] = _point.z + -36.57142857,
        ["x"] = _point.x + 14.85714286,
        ["name"] = "FOB Watchtower #" .. _id,
        ["category"] = "Fortifications",
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    --coalition.addStaticObject(_country, _tower)
    _tower["country"] = _country

    ctld.utils.dynAddStatic("ctld.spawnFOB", _tower)

    return _spawnedCrate
end

function ctld.spawnCrate(_arguments, bypassCrateWaitTime)
    local _status, _err = pcall(function(_args)
        -- use the cargo weight to guess the type of unit as no way to add description :(
        local _crateType = ctld.crateLookupTable[tostring(_args[2])]
        local _heli = ctld.getTransportUnit(_args[1])
        if not _heli then
            return
        end

        -- check crate spam
        if not (bypassCrateWaitTime) and _heli:getPlayerName() ~= nil and ctld.crateWait[_heli:getPlayerName()] and ctld.crateWait[_heli:getPlayerName()] > timer.getTime() then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("Sorry you must wait %1 seconds before you can get another crate",
                    (ctld.crateWait[_heli:getPlayerName()] - timer.getTime())), 20)
            return
        end

        if _crateType and _crateType.multiple then
            for _, weight in pairs(_crateType.multiple) do
                local _aCrateType = ctld.crateLookupTable[tostring(weight)]
                if _aCrateType then
                    ctld.spawnCrate({ _args[1], _aCrateType.weight }, true)
                end
            end
            return
        end

        if _crateType ~= nil and _heli ~= nil and ctld.inAir(_heli) == false then
            if ctld.inLogisticsZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You are not close enough to friendly logistics to get a crate!"), 10)
                return
            end

            if ctld.isJTACUnitType(_crateType.unit) then
                local _limitHit = false

                if _heli:getCoalition() == 1 then
                    if ctld.JTAC_LIMIT_RED == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_RED = ctld.JTAC_LIMIT_RED - 1
                    end
                else
                    if ctld.JTAC_LIMIT_BLUE == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_BLUE = ctld.JTAC_LIMIT_BLUE - 1
                    end
                end

                if _limitHit then
                    ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No more JTAC Crates Left!"), 10)
                    return
                end
            end

            if _heli:getPlayerName() ~= nil then
                ctld.crateWait[_heli:getPlayerName()] = timer.getTime() + ctld.crateWaitTime
            end

            local _heli = ctld.getTransportUnit(_args[1])

            local _model_type = nil

            local _point = ctld.getPointAt12Oclock(_heli, 15)
            local _position = "12"

            if ctld.unitDynamicCargoCapable(_heli) then
                _model_type = "dynamic"
                _point = ctld.getPointAt6Oclock(_heli, 15)
                _position = "6"
            end

            local _unitId = ctld.getNextUnitId()

            local _side = _heli:getCoalition()

            local _name = string.format("%s #%i", _crateType.desc, _unitId)

            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crateType.weight, _side, 0, _model_type)

            -- add to move table
            ctld.crateMove[_name] = _name

            local refPoint = _heli:getPoint()
            local refLat, refLon = coord.LOtoLL(refPoint)
            local unitPos = _heli:getPosition()
            --local refHeading = math.deg(math.atan2(unitPos.x.z, unitPos.x.x))
            local refHeading = math.deg(ctld.utils.getHeadingInRadians("ctld.spawnCrate", _heli, true))
            local destLat, destLon, destAlt = coord.LOtoLL(_point)

            local relativePos, forma = ctld.utils.getRelativeBearing("ctld.spawnCrate", refLat, refLon, refHeading,
                destLat, destLon,
                'clock')

            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock ",
                    _crateType.desc, _crateType.weight, relativePos), 20)
        else
            env.info("Couldn't find crate item to spawn")
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

--***************************************************************
ctld.randomCrateSpacing = 15 -- meters
function ctld.getPointAt12Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, 0)
end

function ctld.getPointAt6Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, math.pi)
end

function ctld.getPointInFrontSector(_unit, _offset)
    if _unit then
        local playerHeading = ctld.utils.getHeadingInRadians("ctld.getPointInFrontSector", _unit)
        local randomHeading = ctld.utils.RandomReal("ctld.getPointInFrontSector", playerHeading - math.pi / 4,
            playerHeading + math.pi / 4)
        if _offset == nil then
            _offset = 20
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function ctld.getPointInRearSector(_unit, _offset)
    if _unit then
        local playerHeading = ctld.utils.getHeadingInRadians("ctld.getPointInRearSector", _unit)
        local randomHeading = ctld.utils.RandomReal("ctld.getPointInRearSector", playerHeading + math.pi - math.pi / 4,
            playerHeading + math.pi + math.pi /
            4)
        if _offset == nil then
            _offset = 30
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function ctld.getPointAtDirection(_unit, _offset, _directionInRadian)
    if _offset == nil then
        _offset = ctld.getSecureDistanceFromUnit(_unit:getName())
    end
    --ctld.logTrace("_offset = %s", ctld.p(_offset))
    local _randomOffsetX = math.random(0, ctld.randomCrateSpacing * 2) - ctld.randomCrateSpacing
    local _randomOffsetZ = math.random(0, ctld.randomCrateSpacing)
    --ctld.logTrace("_randomOffsetX = %s", ctld.p(_randomOffsetX))
    --ctld.logTrace("_randomOffsetZ = %s", ctld.p(_randomOffsetZ))
    local _position      = _unit:getPosition()
    local _angle         = math.atan(_position.x.z, _position.x.x) + _directionInRadian
    local _xOffset       = math.cos(_angle) * (_offset + _randomOffsetX)
    local _zOffset       = math.sin(_angle) * (_offset + _randomOffsetZ)
    local _point         = _unit:getPoint()
    return { x = _point.x + _xOffset, z = _point.z + _zOffset, y = _point.y }
end

function ctld.getRelativePoint(_refPointXZTable, _distance, _angle_radians) -- return coord point at distance and angle from _refPointXZTable
    local relativePoint = {}
    relativePoint.x = _refPointXZTable.x + _distance * math.cos(_angle_radians)
    if _refPointXZTable.z == nil then
        relativePoint.y = _refPointXZTable.y + _distance * math.sin(_angle_radians)
    else
        relativePoint.z = _refPointXZTable.z + _distance * math.sin(_angle_radians)
    end
    return relativePoint
end

function ctld.troopsOnboard(_heli, _troops)
    if ctld.inTransitTroops[_heli:getName()] ~= nil then
        local _onboard = ctld.inTransitTroops[_heli:getName()]

        if _troops then
            if _onboard.troops ~= nil and _onboard.troops.units ~= nil and #_onboard.troops.units > 0 then
                return true
            else
                return false
            end
        else
            if _onboard.vehicles ~= nil and _onboard.vehicles.units ~= nil and #_onboard.vehicles.units > 0 then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

-- if its dropped by AI then there is no player name so return the type of unit
function ctld.getPlayerNameOrType(_heli)
    if _heli:getPlayerName() == nil then
        return _heli:getTypeName()
    else
        return _heli:getPlayerName()
    end
end

function ctld.inExtractZone(_heli)
    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.extractZones) do
        --get distance to center
        local _dist = ctld.utils.getDistance("ctld.inExtractZone()", _heliPoint, _zoneDetails.point)

        if _dist <= _zoneDetails.radius then
            return _zoneDetails
        end
    end

    return false
end

-- safe to fast rope if speed is less than 0.5 Meters per second
function ctld.safeToFastRope(_heli)
    if ctld.enableFastRopeInsertion == false then
        return false
    end

    --landed or speed is less than 8 km/h and height is less than fast rope height
    if (ctld.inAir(_heli) == false or (ctld.heightDiff(_heli) <= ctld.fastRopeMaximumHeight + 3.0 and ctld.utils.vec3Mag("ctld.safeToFastRope()", _heli:getVelocity()) < 2.2)) then
        return true
    end
end

function ctld.metersToFeet(_meters)
    local _feet = _meters * 3.2808399

    return ctld.utils.round("ctld.metersToFeet", _feet)
end

function ctld.inAir(_heli)
    if _heli:inAir() == false then
        return false
    end

    -- less than 5 cm/s a second so landed
    -- BUT AI can hold a perfect hover so ignore AI
    if ctld.utils.vec3Mag("ctld.inAir()", _heli:getVelocity()) < 0.05 and _heli:getPlayerName() ~= nil then
        return false
    end
    return true
end

function ctld.deployTroops(_heli, _troops)
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    -- deloy troops
    if _troops then
        if _onboard.troops ~= nil and #_onboard.troops.units > 0 then
            if ctld.inAir(_heli) == false or ctld.safeToFastRope(_heli) then
                -- check we're not in extract zone
                local _extractZone = ctld.inExtractZone(_heli)

                if _extractZone == false then
                    local _droppedTroops = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.troops, false)
                    if _onboard.troops.jtac or _droppedTroops:getName():lower():find("jtac") then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)
                        ctld.JTACStart(_droppedTroops:getName(), _code)
                    end

                    if _heli:getCoalition() == 1 then
                        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
                    else
                        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
                    end

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into combat",
                                ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into combat", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName()), 10)
                    end

                    ctld.processCallback({ unit = _heli, unloaded = _droppedTroops, action = "dropped_troops" })
                else
                    --extract zone!
                    local _droppedCount = trigger.misc.getUserFlag(_extractZone.flag)

                    _droppedCount = (#_onboard.troops.units) + _droppedCount

                    trigger.action.setUserFlag(_extractZone.flag, _droppedCount)

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Too high or too fast to drop troops into combat! Hover below %1 feet or land.",
                        ctld.metersToFeet(ctld.fastRopeMaximumHeight)), 10)
            end
        end
    else
        if ctld.inAir(_heli) == false then
            if _onboard.vehicles ~= nil and #_onboard.vehicles.units > 0 then
                local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.vehicles, true)

                if _heli:getCoalition() == 1 then
                    table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
                else
                    table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
                end

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
                ctld.adaptWeightToCargo(_heli:getName())

                ctld.processCallback({ unit = _heli, unloaded = _droppedVehicles, action = "dropped_vehicles" })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 dropped vehicles from %2 into combat", ctld.getPlayerNameOrType(_heli),
                        _heli:getTypeName()), 10)
            end
        end
    end
end

function ctld.insertIntoTroopsArray(_troopType, _count, _troopArray, _troopName)
    for _i = 1, _count do
        local _unitId = ctld.getNextUnitId()
        table.insert(_troopArray,
            {
                type = _troopType,
                unitId = _unitId,
                name = string.format("Dropped %s #%i", _troopName or _troopType,
                    _unitId)
            })
    end

    return _troopArray
end

function ctld.generateTroopTypes(_side, _countOrTemplate, _country)
    local _troops = {}
    local _weight = 0
    local _hasJTAC = false

    local function getSoldiersWeight(count, additionalWeight)
        local _weight = 0
        for i = 1, count do
            local _soldierWeight = math.random(90, 120) * ctld.SOLDIER_WEIGHT / 100
            _weight = _weight + _soldierWeight + ctld.KIT_WEIGHT + additionalWeight
        end
        return _weight
    end

    if type(_countOrTemplate) == "table" then
        if _countOrTemplate.aa then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier stinger", _countOrTemplate.aa, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("SA-18 Igla manpad", _countOrTemplate.aa, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.aa, ctld.MANPAD_WEIGHT)
        end

        if _countOrTemplate.inf then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.inf, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.inf, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.inf, ctld.RIFLE_WEIGHT)
        end

        if _countOrTemplate.mg then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M249", _countOrTemplate.mg, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Paratrooper AKS-74", _countOrTemplate.mg, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mg, ctld.MG_WEIGHT)
        end

        if _countOrTemplate.at then
            _troops = ctld.insertIntoTroopsArray("Paratrooper RPG-16", _countOrTemplate.at, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.at, ctld.RPG_WEIGHT)
        end

        if _countOrTemplate.mortar then
            _troops = ctld.insertIntoTroopsArray("2B11 mortar", _countOrTemplate.mortar, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mortar, ctld.MORTAR_WEIGHT)
        end

        if _countOrTemplate.jtac then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.jtac, _troops, "JTAC")
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.jtac, _troops, "JTAC")
            end
            _hasJTAC = true
            _weight = _weight + getSoldiersWeight(_countOrTemplate.jtac, ctld.JTAC_WEIGHT + ctld.RIFLE_WEIGHT)
        end
    else
        for _i = 1, _countOrTemplate do
            local _unitType = "Infantry AK"

            if _side == 2 then
                if _i <= 2 then
                    _unitType = "Soldier M249"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "Soldier stinger"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Soldier M4 GRG"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            else
                if _i <= 2 then
                    _unitType = "Paratrooper AKS-74"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "SA-18 Igla manpad"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Infantry AK"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            end

            local _unitId = ctld.getNextUnitId()

            _troops[_i] = { type = _unitType, unitId = _unitId, name = string.format("Dropped %s #%i", _unitType, _unitId) }
        end
    end

    local _groupId = ctld.getNextGroupId()
    local _groupName = "Dropped Group"
    if _hasJTAC then
        _groupName = "Dropped JTAC Group"
    end
    local _details = {
        units = _troops,
        groupId = _groupId,
        groupName = string.format("%s %i", _groupName, _groupId),
        side =
            _side,
        country = _country,
        weight = _weight,
        jtac = _hasJTAC
    }

    return _details
end

--Special F10 function for players for troops
function ctld.unloadExtractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return false
    end


    local _extract = nil
    if not ctld.inAir(_heli) then
        if _heli:getCoalition() == 1 then
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end
    end

    if _extract ~= nil and not ctld.troopsOnboard(_heli, true) then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), true })
    else
        return ctld.unloadTroops({ _heli:getName(), true, true })
    end
end

-- load troops onto vehicle
function ctld.loadTroops(_heli, _troops, _numberOrTemplate)
    -- load troops + vehicles if c130 or herc
    -- "M1045 HMMWV TOW"
    -- "M1043 HMMWV Armament"
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    --number doesnt apply to vehicles
    if _numberOrTemplate == nil or (type(_numberOrTemplate) ~= "table" and type(_numberOrTemplate) ~= "number") then
        _numberOrTemplate = ctld.getTransportLimit(_heli:getTypeName())
    end

    if _onboard == nil then
        _onboard = { troops = {}, vehicles = {} }
    end

    local _list
    if _heli:getCoalition() == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    if _troops then
        _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(), _numberOrTemplate, _heli:getCountry())
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded troops into %2", ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)

        ctld.processCallback({ unit = _heli, onboard = _onboard.troops, action = "load_troops" })
    else
        _onboard.vehicles = ctld.generateVehiclesForTransport(_heli:getCoalition(), _heli:getCountry())

        local _count = #_list

        ctld.processCallback({ unit = _heli, onboard = _onboard.vehicles, action = "load_vehicles" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded %2 vehicles into %3", ctld.getPlayerNameOrType(_heli), _count,
                _heli:getTypeName()), 10)
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())
end

function ctld.generateVehiclesForTransport(_side, _country)
    local _vehicles = {}
    local _list
    if _side == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end


    for _i, _type in ipairs(_list) do
        local _unitId = ctld.getNextUnitId()
        local _weight = ctld.vehiclesWeight[_type] or 2500
        _vehicles[_i] = {
            type = _type,
            unitId = _unitId,
            name = string.format("Dropped %s #%i", _type, _unitId),
            weight =
                _weight
        }
    end


    local _groupId = ctld.getNextGroupId()
    local _details = {
        units = _vehicles,
        groupId = _groupId,
        groupName = string.format("Dropped Group %i", _groupId),
        side =
            _side,
        country = _country
    }

    return _details
end

function ctld.loadUnloadFOBCrate(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    if ctld.inAir(_heli) == true then
        return
    end


    local _side = _heli:getCoalition()

    local _inZone = ctld.inLogisticsZone(_heli)
    local _crateOnboard = ctld.inTransitFOBCrates[_heli:getName()] ~= nil

    if _inZone == false and _crateOnboard == true then
        ctld.inTransitFOBCrates[_heli:getName()] = nil

        local _position = _heli:getPosition()

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_position.x.z, _position.x.x)
        local _xOffset = math.cos(_angle) * -60
        local _yOffset = math.sin(_angle) * -60

        local _point = _heli:getPoint()

        local _side = _heli:getCoalition()

        local _unitId = ctld.getNextUnitId()

        local _name = string.format("FOB Crate #%i", _unitId)

        local _spawnedCrate = ctld.spawnFOBCrateStatic(_heli:getCountry(), ctld.getNextUnitId(),
            { x = _point.x + _xOffset, z = _point.z + _yOffset }, _name)

        if _side == 1 then
            ctld.droppedFOBCratesRED[_name] = _name
        else
            ctld.droppedFOBCratesBLUE[_name] = _name
        end

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 delivered a FOB Crate", ctld.getPlayerNameOrType(_heli)), 10)

        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Delivered FOB Crate 60m at 6'oclock to you"), 10)
    elseif _inZone == true and _crateOnboard == true then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate dropped back to base"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = nil
    elseif _inZone == true and _crateOnboard == false then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = true

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)
    else
        -- nearest Crate
        local _crates = ctld.getCratesAndDistance(_heli)
        local _nearestCrate = ctld.getClosestCrate(_heli, _crates, "FOB")

        if _nearestCrate ~= nil and _nearestCrate.dist < 150 then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)
            ctld.inTransitFOBCrates[_heli:getName()] = true

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)

            if _side == 1 then
                ctld.droppedFOBCratesRED[_nearestCrate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
            end

            --remove
            _nearestCrate.crateUnit:destroy()
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("There are no friendly logistic units nearby to load a FOB crate from!"), 10)
        end
    end
end

function ctld.updateTroopsInGame(params, t) -- return count of troops in game by Coalition
    if t == nil then t = timer.getTime() + 1; end
    ctld.InfantryInGameCount = { 0, 0 }
    for coalitionId = 1, 2 do                                                          -- for each CoaId
        for k, v in ipairs(coalition.getGroups(coalitionId, Group.Category.GROUND)) do -- for each GROUND type group
            for index, unitObj in pairs(v:getUnits()) do                               -- for each unit in group
                if unitObj:getDesc().attributes.Infantry then
                    ctld.InfantryInGameCount[coalitionId] = ctld.InfantryInGameCount[coalitionId] + 1
                end
            end
        end
    end
    return 5 -- reschedule each 5"
end

function ctld.loadTroopsFromZone(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]
    local _groupTemplate = _args[3] or ""
    local _allowExtract = _args[4]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end
        return false
    end

    local _extract

    if _allowExtract then
        -- first check for extractable troops regardless of if we're in a zone or not
        if _troops then
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
            end
        else
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
            end
        end
    end

    if _extract ~= nil then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), _troops })
    elseif _zone.inZone == true then
        local heloCoa = _heli:getCoalition()
        ctld.logTrace("FG_ heloCoa =  %s", ctld.p(heloCoa))
        ctld.logTrace("FG_ (ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0) =  %s",
            ctld.p(ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0))
        ctld.logTrace("FG_ ctld.InfantryInGameCount[heloCoa] =  %s", ctld.p(ctld.InfantryInGameCount[heloCoa]))
        ctld.logTrace("FG_ _groupTemplate.total =  %s", ctld.p(_groupTemplate.total))
        ctld.logTrace("FG_ ctld.nbLimitSpawnedTroops[%s].total =  %s", ctld.p(heloCoa),
            ctld.p(ctld.nbLimitSpawnedTroops[heloCoa]))

        local limitReached = true
        if (ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0) and (ctld.InfantryInGameCount[heloCoa] + _groupTemplate.total > ctld.nbLimitSpawnedTroops[heloCoa]) then -- load troops only if Coa limit not reached
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("Count Infantries limit in the mission reached, you can't load more troops"), 10)
            return false
        end
        if _zone.limit - 1 >= 0 then
            -- decrease zone counter by 1
            ctld.updateZoneCounter(_zone.index, -1)
            ctld.loadTroops(_heli, _troops, _groupTemplate)
            return true
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("This area has no more reinforcements available!"), 20)
            return false
        end
    else
        if _allowExtract then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("You are not in a pickup zone and no one is nearby to extract"), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You are not in a pickup zone"), 10)
        end

        return false
    end
end

function ctld.unloadTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)
    if not ctld.troopsOnboard(_heli, _troops) then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No one to unload"), 10)

        return false
    else
        -- troops must be onboard to get here
        if _zone.inZone == true then
            if _troops then
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped troops back to base"), 20)

                ctld.processCallback({
                    unit = _heli,
                    unloaded = ctld.inTransitTroops[_heli:getName()].troops,
                    action =
                    "unload_troops_zone"
                })

                ctld.inTransitTroops[_heli:getName()].troops = nil
            else
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped vehicles back to base"), 20)

                ctld.processCallback({
                    unit = _heli,
                    unloaded = ctld.inTransitTroops[_heli:getName()].vehicles,
                    action =
                    "unload_vehicles_zone"
                })

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
            end

            ctld.adaptWeightToCargo(_heli:getName())

            -- increase zone counter by 1
            ctld.updateZoneCounter(_zone.index, 1)

            return true
        elseif ctld.troopsOnboard(_heli, _troops) then
            return ctld.deployTroops(_heli, _troops)
        end
    end
end

function ctld.extractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    if ctld.inAir(_heli) then
        return false
    end

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end

        return false
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        _onboard = { troops = nil, vehicles = nil }
    end

    local _extracted = false

    if _troops then
        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end


        if _extractTroops ~= nil then
            local _limit = ctld.getTransportLimit(_heli:getTypeName())

            local _size = #_extractTroops.group:getUnits()

            if _limit < #_extractTroops.group:getUnits() then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3", _size,
                        _limit, _heli:getTypeName()), 20)

                return
            end

            _onboard.troops = _extractTroops.details
            _onboard.troops.weight = #_extractTroops.group:getUnits() * 130 -- default to 130kg per soldier

            if _extractTroops.group:getName():lower():find("jtac") then
                _onboard.troops.jtac = true
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted troops in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            ctld.processCallback({ unit = _heli, extracted = _extractTroops, action = "extract_troops" })

            --remove
            _extractTroops.group:destroy()

            _extracted = true
        else
            _onboard.troops = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable troops nearby!"), 20)
        end
    else
        local _extractVehicles


        if _heli:getCoalition() == 1 then
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
        else
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
        end

        if _extractVehicles ~= nil then
            _onboard.vehicles = _extractVehicles.details

            if _heli:getCoalition() == 1 then
                ctld.droppedVehiclesRED[_extractVehicles.group:getName()] = nil
            else
                ctld.droppedVehiclesBLUE[_extractVehicles.group:getName()] = nil
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted vehicles in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            ctld.processCallback({ unit = _heli, extracted = _extractVehicles, action = "extract_vehicles" })
            --remove
            _extractVehicles.group:destroy()
            _extracted = true
        else
            _onboard.vehicles = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable vehicles nearby!"), 20)
        end
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())

    return _extracted
end

function ctld.checkTroopStatus(_args)
    local _unitName = _args[1]
    --list onboard troops, if c130
    local _heli = ctld.getTransportUnit(_unitName)

    if _heli == nil then
        return
    end

    local _, _message = ctld.getWeightOfCargo(_unitName)
    if _message and _message ~= "" then
        ctld.displayMessageToGroup(_heli, _message, 10)
    end
end

-- Removes troops from transport when it dies
function ctld.checkTransportStatus()
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 3)

    for _, _name in ipairs(ctld.transportPilotNames) do
        local _transUnit = ctld.getTransportUnit(_name)

        if _transUnit == nil then
            --env.info("CTLD Transport Unit Dead event")
            ctld.inTransitTroops[_name] = nil
            ctld.inTransitFOBCrates[_name] = nil
            ctld.inTransitSlingLoadCrates[_name] = nil
        end
    end
end

function ctld.adaptWeightToCargo(unitName)
    local _weight = ctld.getWeightOfCargo(unitName)
    trigger.action.setUnitInternalCargo(unitName, _weight)
end

function ctld.getWeightOfCargo(unitName)
    local FOB_CRATE_WEIGHT = 800
    local _weight = 0
    local _description = ""

    ctld.inTransitSlingLoadCrates[unitName] = ctld.inTransitSlingLoadCrates[unitName] or {}

    -- add troops weight
    if ctld.inTransitTroops[unitName] then
        local _inTransit = ctld.inTransitTroops[unitName]
        if _inTransit then
            local _troops = _inTransit.troops
            if _troops and _troops.units then
                _description = _description ..
                    ctld.i18n_translate("%1 troops onboard (%2 kg)\n", #_troops.units, _troops.weight)
                _weight = _weight + _troops.weight
            end
            local _vehicles = _inTransit.vehicles
            if _vehicles and _vehicles.units then
                for _, _unit in pairs(_vehicles.units) do
                    _weight = _weight + _unit.weight
                end
                _description = _description ..
                    ctld.i18n_translate("%1 vehicles onboard (%2)\n", #_vehicles.units, _weight)
            end
        end
    end

    -- add FOB crates weight
    if ctld.inTransitFOBCrates[unitName] then
        _weight = _weight + FOB_CRATE_WEIGHT
        _description = _description .. ctld.i18n_translate("1 FOB Crate oboard (%1 kg)\n", FOB_CRATE_WEIGHT)
    end

    -- add simulated slingload crates weight
    for i = 1, #ctld.inTransitSlingLoadCrates[unitName] do
        local _crate = ctld.inTransitSlingLoadCrates[unitName][i]
        if _crate and _crate.simulatedSlingload then
            _weight = _weight + _crate.weight
            _description = _description .. ctld.i18n_translate("%1 crate onboard (%2 kg)\n", _crate.desc, _crate.weight)
        end
    end
    if _description ~= "" then
        _description = _description .. ctld.i18n_translate("Total weight of cargo : %1 kg\n", _weight)
    else
        _description = ctld.i18n_translate("No cargo.")
    end

    return _weight, _description
end

function ctld.checkHoverStatus()
    timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1.0)

    local _status, _result = pcall(function()
        for _, _name in ipairs(ctld.transportPilotNames) do
            local _reset = true
            local _transUnit = ctld.getTransportUnit(_name)
            local _transUnitTypeName = _transUnit and _transUnit:getTypeName()
            local _cargoCapacity = ctld.internalCargoLimits[_transUnitTypeName] or 1
            ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

            --only check transports that are hovering and not planes
            if _transUnit ~= nil and #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity and ctld.inAir(_transUnit) and ctld.unitCanCarryVehicles(_transUnit) == false and not ctld.unitDynamicCargoCapable(_transUnit) then
                local _crates = ctld.getCratesAndDistance(_transUnit)

                for _, _crate in pairs(_crates) do
                    local _crateUnitName = _crate.crateUnit:getName()
                    if _crate.dist < ctld.maxDistanceFromCrate and _crate.details.unit ~= "FOB" then
                        --check height!
                        local _height = _transUnit:getPoint().y - _crate.crateUnit:getPoint().y
                        if _height > ctld.minimumHoverHeight and _height <= ctld.maximumHoverHeight then
                            local _time = ctld.hoverStatus[_name]

                            if _time == nil then
                                ctld.hoverStatus[_name] = ctld.hoverTime
                                _time = ctld.hoverTime
                            else
                                _time = ctld.hoverStatus[_name] - 1
                                ctld.hoverStatus[_name] = _time
                            end

                            if _time > 0 then
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate(
                                        "Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!",
                                        _crate.details.desc, _time), 10, true)
                            else
                                ctld.hoverStatus[_name] = nil
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc), 10, true)

                                --crates been moved once!
                                ctld.crateMove[_crateUnitName] = nil

                                if _transUnit:getCoalition() == 1 then
                                    ctld.spawnedCratesRED[_crateUnitName] = nil
                                else
                                    ctld.spawnedCratesBLUE[_crateUnitName] = nil
                                end

                                _crate.crateUnit:destroy()

                                local _copiedCrate = ctld.utils.deepCopy("ctld.checkHoverStatus()", _crate
                                    .details)
                                _copiedCrate.simulatedSlingload = true
                                table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                                ctld.adaptWeightToCargo(_name)
                            end

                            _reset = false

                            break
                        elseif _height <= ctld.minimumHoverHeight then
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too low to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        else
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too high to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        end
                    end
                end
            end

            if _reset then
                ctld.hoverStatus[_name] = nil
            end
        end
    end)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _result))
    end
end

function ctld.loadNearbyCrate(_name)
    local _transUnit = ctld.getTransportUnit(_name)

    if _transUnit ~= nil then
        local _cargoCapacity = ctld.internalCargoLimits[_transUnit:getTypeName()] or 1
        ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

        if ctld.inAir(_transUnit) then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("You must land before you can load a crate!"), 10,
                true)
            return
        end

        local _crates = ctld.getCratesAndDistance(_transUnit)
        local loaded = false
        for _, _crate in pairs(_crates) do
            if _crate.dist < 50.0 then
                if #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity then
                    ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc),
                        10)

                    if _transUnit:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                    else
                        ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                    end

                    ctld.crateMove[_crate.crateUnit:getName()] = nil

                    _crate.crateUnit:destroy()

                    local _copiedCrate = ctld.utils.deepCopy("ctld.loadNearbyCrate()", _crate.details)
                    _copiedCrate.simulatedSlingload = true
                    table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                    loaded = true
                    ctld.adaptWeightToCargo(_name)
                else
                    -- Max crates onboard
                    local outputMsg = ctld.i18n_translate("Maximum number of crates are on board!")
                    for i = 1, _cargoCapacity do
                        outputMsg = outputMsg .. "\n" .. ctld.inTransitSlingLoadCrates[_name][i].desc
                    end
                    ctld.displayMessageToGroup(_transUnit, outputMsg, 10, true)
                    return
                end
            end
        end
        if not loaded then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("No Crates within 50m to load!"), 10, true)
        end
    end
end

--check each minute if the beacons' batteries have failed, and stop them accordingly
--there's no more need to actually refresh the beacons, since we set "loop" to true.
function ctld.refreshRadioBeacons()
    timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 60)


    for _index, _beaconDetails in ipairs(ctld.deployedRadioBeacons) do
        if ctld.updateRadioBeacon(_beaconDetails) == false then
            --search used frequencies + remove, add back to unused

            for _i, _freq in ipairs(ctld.usedUHFFrequencies) do
                if _freq == _beaconDetails.uhf then
                    table.insert(ctld.freeUHFFrequencies, _freq)
                    table.remove(ctld.usedUHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedVHFFrequencies) do
                if _freq == _beaconDetails.vhf then
                    table.insert(ctld.freeVHFFrequencies, _freq)
                    table.remove(ctld.usedVHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedFMFrequencies) do
                if _freq == _beaconDetails.fm then
                    table.insert(ctld.freeFMFrequencies, _freq)
                    table.remove(ctld.usedFMFrequencies, _i)
                end
            end

            --clean up beacon table
            table.remove(ctld.deployedRadioBeacons, _index)
        end
    end
end

function ctld.getClockDirection(_heli, _crate)
    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p      -- get position of crate
    local _playerPosition = _heli:getPosition().p -- get position of helicopter
    local _relativePosition = ctld.utils.subVec3("ctld.getClockDirection()", _position, _playerPosition)

    local _playerHeading = ctld.utils.getHeadingInRadians("ctld.getClockDirection()", _heli) -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = { x = math.cos(_playerHeading), y = 0, z = math.sin(_playerHeading) }

    local _headingVectorPerpendicular = {
        x = math.cos(_playerHeading + math.pi / 2),
        y = 0,
        z = math.sin(_playerHeading +
            math.pi / 2)
    }

    local _forwardDistance = ctld.utils.multVec3("ctld.getClockDirection()", _relativePosition, _headingVector)

    local _rightDistance = ctld.utils.multVec3("ctld.getClockDirection()", _relativePosition, _headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance, _forwardDistance) * 180 / math.pi

    if _angle < 0 then
        _angle = 360 + _angle
    end
    _angle = math.floor(_angle * 12 / 360 + 0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end

function ctld.listNearbyCrates(_args)
    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    local _crates = ctld.getCratesAndDistance(_heli)

    --sort
    local _sort = function(a, b) return a.dist < b.dist end
    table.sort(_crates, _sort)

    for _, _crate in pairs(_crates) do
        if _crate.dist < 1000 and _crate.details.unit ~= "FOB" then
            _message = ctld.i18n_translate("%1\n%2 crate - kg %3 - %4 m - %5 o'clock", _message, _crate.details.desc,
                _crate.details.weight, _crate.dist, ctld.getClockDirection(_heli, _crate.crateUnit))
        end
    end


    local _fobMsg = ""
    for _, _fobCrate in pairs(_crates) do
        if _fobCrate.dist < 1000 and _fobCrate.details.unit == "FOB" then
            _fobMsg = _fobMsg ..
                ctld.i18n_translate("FOB Crate - %1 m - %2 o'clock\n", _fobCrate.dist,
                    ctld.getClockDirection(_heli, _fobCrate.crateUnit))
        end
    end

    local _txt = ctld.i18n_translate("No Nearby Crates")
    if _message ~= "" or _fobMsg ~= "" then
        _txt = ""

        if _message ~= "" then
            _txt = ctld.i18n_translate("Nearby Crates:\n%1", _message)
        end

        if _fobMsg ~= "" then
            if _txt ~= "" then
                _txt = _txt .. "\n\n"
            end

            _txt = _txt .. ctld.i18n_translate("Nearby FOB Crates (Not Slingloadable):\n%1", _fobMsg)
        end
    end
    ctld.displayMessageToGroup(_heli, _txt, 20)
end

function ctld.listFOBS(_args)
    local _msg = ctld.i18n_translate("FOB Positions:")

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    -- get fob positions
    local _fobs = ctld.getSpawnedFobs(_heli)

    if _fobs and #_fobs > 0 then
        -- now check spawned fobs
        for _, _fob in ipairs(_fobs) do
            _msg = ctld.i18n_translate("%1\nFOB @ %2", _msg, ctld.getFOBPositionString(_fob))
        end
    else
        _msg = ctld.i18n_translate("Sorry, there are no active FOBs!")
    end
    ctld.displayMessageToGroup(_heli, _msg, 20)
end

function ctld.getFOBPositionString(_fob)
    local _lat, _lon = coord.LOtoLL(_fob:getPosition().p)

    local _latLngStr = ctld.utils.tostringLL("ctld.getFOBPositionString()", _lat, _lon, 3, ctld.location_DMS)

    --     local _mgrsString = ctld.utils.tostringMGRS("ctld.getFOBPositionString()", coord.LLtoMGRS(coord.LOtoLL(_fob:getPosition().p)), 5)

    local _message = _latLngStr

    local _beaconInfo = ctld.fobBeacons[_fob:getName()]

    if _beaconInfo ~= nil then
        _message = string.format("%s - %.2f KHz ", _message, _beaconInfo.vhf / 1000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.uhf / 1000000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.fm / 1000000)
    end

    return _message
end

function ctld.displayMessageToGroup(_unit, _text, _time, _clear)
    local _groupId = ctld.utils.getGroupId("ctld.displayMessageToGroup()", _unit)
    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time, _clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

function ctld.heightDiff(_unit)
    local _point = _unit:getPoint()

    -- env.info("heightunit " .. _point.y)
    --env.info("heightland " .. land.getHeight({ x = _point.x, y = _point.z }))

    return _point.y - land.getHeight({ x = _point.x, y = _point.z })
end

--includes fob crates!
function ctld.getCratesAndDistance(_heli)
    local _crates = {}

    local _allCrates
    if _heli:getCoalition() == 1 then
        _allCrates = ctld.spawnedCratesRED
    else
        _allCrates = ctld.spawnedCratesBLUE
    end

    for _crateName, _details in pairs(_allCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0
            and (ctld.inAir(_crate) == false) then
            local _dist = ctld.utils.getDistance("ctld.getCratesAndDistance()", _crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = _details }

            table.insert(_crates, _crateDetails)
        end
    end

    local _fobCrates
    if _heli:getCoalition() == 1 then
        _fobCrates = ctld.droppedFOBCratesRED
    else
        _fobCrates = ctld.droppedFOBCratesBLUE
    end

    for _crateName, _details in pairs(_fobCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then
            local _dist = ctld.utils.getDistance("ctld.getCratesAndDistance()", _crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = { unit = "FOB" }, }

            table.insert(_crates, _crateDetails)
        end
    end

    return _crates
end

function ctld.getClosestCrate(_heli, _crates, _type)
    local _closestCrate     = nil
    local _shortestDistance = -1
    local _distance         = 0
    local _minimumDistance  = 5  -- prevents dynamic cargo crates from unpacking while in cargo hold
    local _maxDistance      = 25 -- prevents onboard dynamic cargo crates from unpacking requested by other helo
    for _, _crate in pairs(_crates) do
        if (_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) and _distance > _minimumDistance and _distance < _maxDistance then
                _shortestDistance = _distance
                _closestCrate = _crate
            end
        end
    end

    return _closestCrate
end

function ctld.findNearestAASystem(_heli, _aaSystem)
    local _closestHawkGroup = nil
    local _shortestDistance = -1
    local _distance = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() and _hawkDetails[1].system.name == _aaSystem.name then
            local _units = _hawkGroup:getUnits()

            for _, _leader in pairs(_units) do
                if _leader ~= nil and _leader:getLife() > 0 then
                    _distance = ctld.utils.getDistance("ctld.findNearestAASystem()", _leader:getPoint(), _heli:getPoint())

                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestHawkGroup = _hawkGroup
                    end

                    break
                end
            end
        end
    end

    if _closestHawkGroup ~= nil then
        return { group = _closestHawkGroup, dist = _shortestDistance }
    end
    return nil
end

function ctld.getCrateObject(_name)
    local _crate

    if ctld.staticBugWorkaround then
        _crate = Unit.getByName(_name)
    else
        _crate = StaticObject.getByName(_name)
    end
    return _crate
end

function ctld.unpackCrates(_arguments)
    ctld.logTrace("FG_ ctld.unpackCrates._arguments =  %s", ctld.p(_arguments))
    local _status, _err = pcall(function(_args)
        local _heli = ctld.getTransportUnit(_args[1])
        ctld.logTrace("FG_ ctld.unpackCrates._args =  %s", ctld.p(_args))
        if _heli ~= nil and ctld.inAir(_heli) == false then
            local _crates = ctld.getCratesAndDistance(_heli)
            local _crate = ctld.getClosestCrate(_heli, _crates)
            ctld.logTrace("FG_ ctld.unpackCrates._crate =  %s", ctld.p(_crate))

            if ctld.inLogisticsZone(_heli) == true or ctld.farEnoughFromLogisticZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)
                return
            end

            if _crate ~= nil and _crate.dist < 750
                and (_crate.details.unit == "FOB" or _crate.details.unit == "FOB-SMALL") then
                ctld.unpackFOBCrates(_crates, _heli)

                return
            elseif _crate ~= nil and _crate.dist < 200 then
                if ctld.forceCrateToBeMoved and ctld.crateMove[_crate.crateUnit:getName()] and not ctld.unitDynamicCargoCapable(_heli) then
                    ctld.displayMessageToGroup(_heli,
                        ctld.i18n_translate("Sorry you must move this crate before you unpack it!"), 20)
                    return
                end


                local _aaTemplate = ctld.getAATemplate(_crate.details.unit)

                if _aaTemplate then
                    if _crate.details.unit == _aaTemplate.repair then
                        ctld.repairAASystem(_heli, _crate, _aaTemplate)
                    else
                        ctld.unpackAASystem(_heli, _crate, _crates, _aaTemplate)
                    end

                    return -- stop processing
                    -- is multi crate?
                elseif _crate.details.cratesRequired ~= nil and _crate.details.cratesRequired > 1 then
                    -- multicrate

                    ctld.unpackMultiCrate(_heli, _crate, _crates)

                    return
                else
                    ctld.logTrace("single crate =  %s", ctld.p(_arguments))
                    -- single crate
                    --local _cratePoint = _crate.crateUnit:getPoint()
                    local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                    if ctld.unitDynamicCargoCapable(_heli) == true then
                        _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                        if _crate.details.unit == "MQ-9 Reaper" or _crate.details.unit == "RQ-1A Predator" then
                            --special case to increase spawn altitude for drones
                            _point.y = _point.y + 1000 -- set spawn altitude to 1000m
                        end
                    end
                    local _crateName = _crate.crateUnit:getName()
                    local _crateHdg  = ctld.utils.getHeadingInRadians("ctld.unpackCrates()", _crate.crateUnit, true)

                    --remove crate
                    --    if ctld.slingLoad == false then
                    _crate.crateUnit:destroy()
                    -- end
                    ctld.logTrace("_crate =  %s", ctld.p(_crate))
                    ctld.logTrace("single _point =  %s", ctld.p(_point))
                    ctld.logTrace("single _crate.details.unit =  %s", ctld.p(_crate.details.unit))
                    local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _point }, { _crate.details.unit }, { _crateHdg })
                    ctld.logTrace("_spawnedGroups.name =  %s", ctld.p(_spawnedGroups:getName()))
                    ctld.logTrace("_spawnedGroups =  %s", ctld.p(_spawnedGroups))

                    if _heli:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crateName] = nil
                    else
                        ctld.spawnedCratesBLUE[_crateName] = nil
                    end

                    ctld.processCallback({ unit = _heli, crate = _crate, spawnedGroup = _spawnedGroups, action = "unpack" })

                    if _crate.details.unit == "1L13 EWR" then
                        ctld.addEWRTask(_spawnedGroups)

                        --             env.info("Added EWR")
                    end


                    trigger.action.outTextForCoalition(_heli:getCoalition(),
                        ctld.i18n_translate("%1 successfully deployed %2 to the field", ctld.getPlayerNameOrType(_heli),
                            _crate.details.desc), 10)
                    timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
                    if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        --put to the end
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)

                        ctld.JTACStart(_spawnedGroups:getName(), _code) --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("No friendly crates close enough to unpack, or crate too close to aircraft."), 20)
            end
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

-- builds a fob!
function ctld.unpackFOBCrates(_crates, _heli)
    if ctld.inLogisticsZone(_heli) == true then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)

        return
    end

    -- unpack multi crate
    local _nearbyMultiCrates = {}

    local _bigFobCrates = 0
    local _smallFobCrates = 0
    local _totalCrates = 0

    for _, _nearbyCrate in pairs(_crates) do
        if _nearbyCrate.dist < 750 then
            if _nearbyCrate.details.unit == "FOB" then
                _bigFobCrates = _bigFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            elseif _nearbyCrate.details.unit == "FOB-SMALL" then
                _smallFobCrates = _smallFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            end

            --catch divide by 0
            if _smallFobCrates > 0 then
                _totalCrates = _bigFobCrates + (_smallFobCrates / 3.0)
            else
                _totalCrates = _bigFobCrates
            end

            if _totalCrates >= ctld.cratesRequiredForFOB then
                break
            end
        end
    end

    --- check crate count
    if _totalCrates >= ctld.cratesRequiredForFOB then
        -- destroy crates

        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do
            if _heli:getCoalition() == 1 then
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())

            --destroy
            _crate.crateUnit:destroy()
        end

        local _centroid = ctld.utils.getCentroid("ctld.unpackFOBCrates()", _points)

        timer.scheduleFunction(function(_args)
            local _unitId = ctld.getNextUnitId()
            local _name = "Deployed FOB #" .. _unitId

            local _fob = ctld.spawnFOB(_args[2], _unitId, _args[1], _name)

            --make it able to deploy crates
            table.insert(ctld.logisticUnits, _fob:getName())

            ctld.beaconCount = ctld.beaconCount + 1

            local _radioBeaconName = "FOB Beacon #" .. ctld.beaconCount

            local _radioBeaconDetails = ctld.createRadioBeacon(_args[1], _args[3], _args[2], _radioBeaconName, nil, true)

            ctld.fobBeacons[_name] = {
                vhf = _radioBeaconDetails.vhf,
                uhf = _radioBeaconDetails.uhf,
                fm =
                    _radioBeaconDetails.fm
            }

            if ctld.troopPickupAtFOB == true then
                table.insert(ctld.builtFOBS, _fob:getName())

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates and Troops can now be picked up."), 10)
            else
                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates can now be picked up."), 10)
            end
        end, { _centroid, _heli:getCountry(), _heli:getCoalition() }, timer.getTime() + ctld.buildTimeFOB)

        ctld.processCallback({ unit = _heli, position = _centroid, action = "fob" })

        trigger.action.smoke(_centroid, trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
                "%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke.",
                ctld.getPlayerNameOrType(_heli), _totalCrates, ctld.buildTimeFOB), 10)
    else
        local _txt = ctld.i18n_translate(
            "Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other",
            ctld.cratesRequiredForFOB, _totalCrates)
        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

--unloads the sling crate when the helicopter is on the ground or between 4.5 - 10 meters
function ctld.dropSlingCrate(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    ctld.inTransitSlingLoadCrates[_unitName] = ctld.inTransitSlingLoadCrates[_unitName] or {}

    if _heli == nil then
        return -- no heli!
    end

    local _currentCrate = ctld.inTransitSlingLoadCrates[_unitName][#ctld.inTransitSlingLoadCrates[_unitName]]

    if _currentCrate == nil then
        if ctld.hoverPickup and ctld.loadCrateFromMenu then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands.",
                    ctld.hoverTime), 10)
        elseif ctld.hoverPickup then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate.",
                    ctld.hoverTime), 10)
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                    "You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."),
                10)
        end
    else
        local _point = _heli:getPoint()
        local _side = _heli:getCoalition()
        local _hdg = ctld.utils.getHeadingInRadians("ctld.dropSlingCrate()", _heli, true)
        local _heightDiff = ctld.heightDiff(_heli)

        if _heightDiff > 40.0 then
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.adaptWeightToCargo(_unitName)
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You were too high! The crate has been destroyed"), 10)
            return
        end
        local _loadedCratesCopy = ctld.utils.deepCopy("ctld.dropSlingCrate()",
            ctld.inTransitSlingLoadCrates[_unitName])
        ctld.logTrace("_loadedCratesCopy = %s", ctld.p(_loadedCratesCopy))
        for _, _crate in pairs(_loadedCratesCopy) do
            ctld.logTrace("_crate = %s", ctld.p(_crate))
            ctld.logTrace("ctld.inAir(_heli) = %s", ctld.p(ctld.inAir(_heli)))
            ctld.logTrace("_heightDiff = %s", ctld.p(_heightDiff))
            local _unitId = ctld.getNextUnitId()
            local _name = string.format("%s #%i", _crate.desc, _unitId)
            local _model_type = nil
            if ctld.inAir(_heli) == false or _heightDiff <= 7.5 then
                _point = ctld.getPointAt12Oclock(_heli, 15)
                local _position = "12"
                if ctld.unitDynamicCargoCapable(_heli) then
                    _model_type = "dynamic"
                    _point = ctld.getPointAt6Oclock(_heli, 15)
                    _position = "6"
                end
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely unhooked and is at your %2 o'clock", _crate.desc,
                        _position), 10)
            elseif _heightDiff > 7.5 and _heightDiff <= 40.0 then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely dropped below you", _crate.desc), 10)
            end
            --remove crate from cargo
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crate.weight, _side, _hdg, _model_type)
        end
        ctld.adaptWeightToCargo(_unitName)
    end
end

function ctld.getAATemplate(_unitName)
    for _, _system in pairs(ctld.AASystemTemplate) do
        if _system.repair == _unitName then
            return _system
        end

        for _, _part in pairs(_system.parts) do
            if _unitName == _part.name then
                return _system
            end
        end
    end

    return nil
end

function ctld.getLauncherUnitFromAATemplate(_aaTemplate)
    for _, _part in pairs(_aaTemplate.parts) do
        if _part.launcher then
            return _part.name
        end
    end

    return nil
end

function ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    -- are we adding to existing aa system?
    -- check to see if the crate is a launcher
    if ctld.getLauncherUnitFromAATemplate(_aaSystemTemplate) == _nearestCrate.details.unit then
        -- find nearest COMPLETE AA system
        local _nearestSystem = ctld.findNearestAASystem(_heli, _aaSystemTemplate)

        if _nearestSystem ~= nil and _nearestSystem.dist < 300 then
            local _uniqueTypes = {} -- stores each unique part of system
            local _types = {}
            local _points = {}
            local _hdgs = {}

            local _units = _nearestSystem.group:getUnits()

            if _units ~= nil and #_units > 0 then
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        --this allows us to count each type once
                        _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                        table.insert(_points, _units[x]:getPoint())
                        table.insert(_types, _units[x]:getTypeName())
                        table.insert(_hdgs, ctld.utils.getHeadingInRadians("ctld.rearmAASystem()", _units[x], true))
                    end
                end
            end

            -- do we have the correct number of unique pieces and do we have enough points for all the pieces
            if ctld.utils.countTableEntries("ctld.rearmAASystem", _uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                -- rearm aa system
                -- destroy old group
                ctld.completeAASystems[_nearestSystem.group:getName()] = nil

                _nearestSystem.group:destroy()

                local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

                ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup,
                    _aaSystemTemplate)

                ctld.processCallback({
                    unit = _heli,
                    crate = _nearestCrate,
                    spawnedGroup = _spawnedGroup,
                    action =
                    "rearm"
                })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 successfully rearmed a full %2 in the field", ctld.getPlayerNameOrType(_heli),
                        _aaSystemTemplate.name, 20))

                if _heli:getCoalition() == 1 then
                    ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
                else
                    ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
                end

                -- remove crate
                --         if ctld.slingLoad == false then
                _nearestCrate.crateUnit:destroy()
                --    end

                return true -- all done so quit
            end
        end
    end

    return false
end

function ctld.getAASystemDetails(_hawkGroup, _aaSystemTemplate)
    local _units = _hawkGroup:getUnits()

    local _hawkDetails = {}

    for _, _unit in pairs(_units) do
        table.insert(_hawkDetails,
            {
                point = _unit:getPoint(),
                unit = _unit:getTypeName(),
                name = _unit:getName(),
                system = _aaSystemTemplate,
                hdg =
                    ctld.utils.getHeadingInRadians("ctld.getAASystemDetails()", _unit, true)
            })
    end

    return _hawkDetails
end

function ctld.unpackAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    ctld.logTrace("_nearestCrate = %s", ctld.p(_nearestCrate))
    ctld.logTrace("_nearbyCrates = %s", ctld.p(_nearbyCrates))
    ctld.logTrace("_aaSystemTemplate = %s", ctld.p(_aaSystemTemplate))

    if ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate) then
        -- rearmed system
        return
    end

    local _systemParts = {}

    --initialise list of parts
    for _, _part in pairs(_aaSystemTemplate.parts) do
        local _systemPart = {
            name = _part.name,
            desc = _part.desc,
            launcher = _part.launcher,
            amount = _part.amount,
            NoCrate =
                _part.NoCrate,
            found = 0,
            required = 1
        }
        -- if the part is a NoCrate required, it's found by default
        if _systemPart.NoCrate ~= nil then
            _systemPart.found = 1
        end
        _systemParts[_part.name] = _systemPart
    end

    local _cratePositions = {}
    local _crateHdg = {}

    local crateDistance = 500

    -- find all crates close enough and add them to the list if they're part of the AA System
    for _, _nearbyCrate in pairs(_nearbyCrates) do
        ctld.logTrace("_nearbyCrate = %s", ctld.p(_nearbyCrate))
        if _nearbyCrate.dist < crateDistance then
            local _name = _nearbyCrate.details.unit
            ctld.logTrace("_name = %s", ctld.p(_name))

            if _systemParts[_name] ~= nil then
                local foundCount = _systemParts[_name].found
                ctld.logTrace("foundCount = %s", ctld.p(foundCount))

                if not _cratePositions[_name] then
                    _cratePositions[_name] = {}
                end
                if not _crateHdg[_name] then
                    _crateHdg[_name] = {}
                end

                -- if this is our first time encountering this part of the system
                if foundCount == 0 then
                    local _foundPart = _systemParts[_name]

                    _foundPart.found = 1

                    -- store the number of crates required to compute how many crates will have to be removed later and to see if the system can be deployed
                    local cratesRequired = _nearbyCrate.details.cratesRequired
                    ctld.logTrace("cratesRequired = %s", ctld.p(cratesRequired))
                    if cratesRequired ~= nil then
                        _foundPart.required = cratesRequired
                    end

                    _systemParts[_name] = _foundPart
                else
                    -- otherwise, we found another crate for the same part
                    _systemParts[_name].found = foundCount + 1
                end

                -- add the crate to the part info along with it's position and heading
                local crateUnit = _nearbyCrate.crateUnit
                if not _systemParts[_name].crates then
                    _systemParts[_name].crates = {}
                end
                table.insert(_systemParts[_name].crates, _nearbyCrate)
                table.insert(_cratePositions[_name], crateUnit:getPoint())
                table.insert(_crateHdg[_name], ctld.utils.getHeadingInRadians("ctld.unpackAASystem()", crateUnit, true))
            end
        end
    end

    -- Compute the centroids for each type of crates and then the centroid of all the system crates which is used to find the spawn location for each part and a position for the NoCrate parts respectively
    -- One issue, all crates are considered for the centroid and the headings but not all of them may be used if crate stacking is allowed
    local _crateCentroids = {}
    local _idxCentroids = {}
    for _partName, _partPositions in pairs(_cratePositions) do
        _crateCentroids[_partName] = ctld.utils.getCentroid("ctld.unpackAASystem()", _partPositions)
        table.insert(_idxCentroids, _crateCentroids[_partName])
    end
    local _crateCentroid = ctld.utils.getCentroid("ctld.unpackAASystem()", _idxCentroids)

    -- Compute the average heading for each type of crates to know the heading to spawn the part
    local _aveHdg = {}
    -- Headings of each group of crates
    for _partName, _crateHeadings in pairs(_crateHdg) do
        local crateCount = #_crateHeadings
        _aveHdg[_partName] = 0
        -- Heading of each crate within a group
        for _index, _crateHeading in pairs(_crateHeadings) do
            _aveHdg[_partName] = _crateHeading / crateCount + _aveHdg[_partName]
        end
    end

    local spawnDistance = 50 -- circle radius to spawn units in a circle and randomize position relative to the crate location
    local arcRad = math.pi * 2

    local _txt = ""

    local _posArray = {}
    local _hdgArray = {}
    local _typeArray = {}
    -- for each part of the system parts
    for _name, _systemPart in pairs(_systemParts) do
        -- check if enough crates were found to build the part
        if _systemPart.found < _systemPart.required then
            _txt = _txt .. ctld.i18n_translate("Missing %1\n", _systemPart.desc)
        else
            -- use the centroid of the crates for this part as a spawn location
            local _point = _crateCentroids[_name]
            -- in the case this centroid does not exist (NoCrate), use the centroid of all crates found and add some randomness
            if _point == nil then
                _point = _crateCentroid
                _point = {
                    x = _point.x + math.random(0, 3) * spawnDistance,
                    y = _point.y,
                    z = _point.z +
                        math.random(0, 3) * spawnDistance
                }
            end

            -- use the average heading to spawn the part at
            local _hdg = _aveHdg[_name]
            -- if non are found (NoCrate), random heading
            if _hdg == nil then
                _hdg = math.random(0, arcRad)
            end

            -- search for the amount of times this part needs to be spawned, by default 1 for any unit and aaLaunchers for launchers
            local partAmount = 1
            if _systemPart.amount == nil then
                if _systemPart.launcher ~= nil then
                    partAmount = ctld.aaLaunchers
                end
            else
                -- but the amount may also be specified in the template
                partAmount = _systemPart.amount
            end
            -- if crate stacking is allowed, then find the multiplication factor for the amount depending on how many crates are required and how many were found
            if ctld.AASystemCrateStacking then
                _systemPart.amountFactor = _systemPart.found - _systemPart.found % _systemPart.required
            else
                _systemPart.amountFactor = 1
            end
            partAmount = partAmount * _systemPart.amountFactor

            --handle multiple units per part by spawning them in a circle around the crate
            if partAmount > 1 then
                local angular_step = arcRad / partAmount

                for _i = 1, partAmount do
                    local _angle = (angular_step * (_i - 1) + _hdg) % arcRad
                    local _xOffset = math.cos(_angle) * spawnDistance
                    local _yOffset = math.sin(_angle) * spawnDistance

                    table.insert(_posArray, { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset })
                    table.insert(_hdgArray, _angle) -- also spawn them perpendicular to that point of the circle
                    table.insert(_typeArray, _name)
                end
            else
                table.insert(_posArray, _point)
                table.insert(_hdgArray, _hdg)
                table.insert(_typeArray, _name)
            end
        end
    end

    local _activeLaunchers = ctld.countCompleteAASystems(_heli)

    local _allowed = ctld.getAllowedAASystems(_heli)

    env.info("Active: " .. _activeLaunchers .. " Allowed: " .. _allowed)

    if _activeLaunchers + 1 > _allowed then
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("Out of parts for AA Systems. Current limit is %1\n", _allowed, 10))
        return
    end

    if _txt ~= "" then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot build %1\n%2\n\nOr the crates are not close enough together",
                _aaSystemTemplate.name, _txt), 20)
        return
    else
        -- destroy crates
        for _name, _systemPart in pairs(_systemParts) do
            -- if there is a crate to delete in the first place
            if _systemPart.NoCrate ~= true then
                -- figure out how many crates to delete since we searched for as many as possible, not all of them might have been used
                local amountToDel = _systemPart.amountFactor * _systemPart.required
                local DelCounter = 0

                -- for each crate found for this part
                for _index, _crate in pairs(_systemPart.crates) do
                    -- if we still need to delete some crates
                    if DelCounter < amountToDel then
                        if _heli:getCoalition() == 1 then
                            ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                        else
                            ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                        end

                        --destroy
                        -- if ctld.slingLoad == false then
                        _crate.crateUnit:destroy()
                        DelCounter = DelCounter +
                            1 -- count up for one more crate has been deleted
                        --end
                    else
                        break
                    end
                end
            end
        end

        -- HAWK / BUK READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray, _hdgArray)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
                "%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4",
                ctld.getPlayerNameOrType(_heli), _aaSystemTemplate.name, _allowed, (_activeLaunchers + 1)), 10)
    end
end

--count the number of captured cities, sets the amount of allowed AA Systems
function ctld.getAllowedAASystems(_heli)
    if _heli:getCoalition() == 1 then
        return ctld.AASystemLimitBLUE
    else
        return ctld.AASystemLimitRED
    end
end

function ctld.countCompleteAASystems(_heli)
    local _count = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() then
            local _units = _hawkGroup:getUnits()

            if _units ~= nil and #_units > 0 then
                --get the system template
                local _aaSystemTemplate = _hawkDetails[1].system

                local _uniqueTypes = {} -- stores each unique part of system
                local _types = {}
                local _points = {}

                if _units ~= nil and #_units > 0 then
                    for x = 1, #_units do
                        if _units[x]:getLife() > 0 then
                            --this allows us to count each type once
                            _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                            table.insert(_points, _units[x]:getPoint())
                            table.insert(_types, _units[x]:getTypeName())
                        end
                    end
                end

                -- do we have the correct number of unique pieces and do we have enough points for all the pieces
                if ctld.utils.countTableEntries("ctld.countCompleteAASystems", _uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                    _count = _count + 1
                end
            end
        end
    end

    return _count
end

function ctld.repairAASystem(_heli, _nearestCrate, _aaSystem)
    -- find nearest COMPLETE AA system
    local _nearestHawk = ctld.findNearestAASystem(_heli, _aaSystem)



    if _nearestHawk ~= nil and _nearestHawk.dist < 300 then
        local _oldHawk = ctld.completeAASystems[_nearestHawk.group:getName()]

        --spawn new one

        local _types = {}
        local _hdgs = {}
        local _points = {}

        for _, _part in pairs(_oldHawk) do
            table.insert(_points, _part.point)
            table.insert(_hdgs, _part.hdg)
            table.insert(_types, _part.unit)
        end

        --remove old system
        ctld.completeAASystems[_nearestHawk.group:getName()] = nil
        _nearestHawk.group:destroy()

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystem)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "repair" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 successfully repaired a full %2 in the field.", ctld.getPlayerNameOrType(_heli),
                _aaSystem.name), 10)

        if _heli:getCoalition() == 1 then
            ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
        else
            ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
        end

        -- remove crate
        -- if ctld.slingLoad == false then
        _nearestCrate.crateUnit:destroy()
        -- end
    else
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot repair %1. No damaged %2 within 300m", _aaSystem.name, _aaSystem.name), 10)
    end
end

function ctld.unpackMultiCrate(_heli, _nearestCrate, _nearbyCrates)
    --ctld.logTrace("FG_ ctld.unpackMultiCrate, _nearestCrate =  %s", ctld.p(_nearestCrate))
    -- unpack multi crate
    local _nearbyMultiCrates = {}

    for _, _nearbyCrate in pairs(_nearbyCrates) do
        if _nearbyCrate.dist < 300 then
            if _nearbyCrate.details.unit == _nearestCrate.details.unit then
                table.insert(_nearbyMultiCrates, _nearbyCrate)
                if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
                    break
                end
            end
        end
    end

    --- check crate count
    if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
        --local _point    = _nearestCrate.crateUnit:getPoint()
        --local _point    = _heli:getPoint()
        --local secureDistanceFromUnit = ctld.getSecureDistanceFromUnit(_heli:getName())
        --_point.x = _point.x + secureDistanceFromUnit
        local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        if ctld.unitDynamicCargoCapable(_heli) == true then
            _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        end

        local _crateHdg = ctld.utils.getHeadingInRadians("ctld.unpackMultiCrate()", _nearestCrate.crateUnit, true)

        -- destroy crates
        for _, _crate in pairs(_nearbyMultiCrates) do
            if _point == nil then
                _point = _crate.crateUnit:getPoint()
            end

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            --destroy
            --     if ctld.slingLoad == false then
            _crate.crateUnit:destroy()
            --     end
        end

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, { _point }, { _nearestCrate.details.unit }, { _crateHdg })
        if _spawnedGroup == nil then
            ctld.logError("ctld.unpackMultiCrate group was not spawned - skipping setGrpROE")
        else
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1) -- for add unpacked unit in repack menu
            ctld.setGrpROE(_spawnedGroup)
            ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })
            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 successfully deployed %2 to the field using %3 crates.",
                    ctld.getPlayerNameOrType(_heli), _nearestCrate.details.desc, #_nearbyMultiCrates), 10)
        end
    else
        local _txt = ctld.i18n_translate(
            "Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other",
            _nearestCrate.details.desc, _nearestCrate.details.cratesRequired, #_nearbyMultiCrates)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.spawnCrateGroup(_heli, _positions, _types, _hdgs)
    --ctld.logTrace("_heli      =  %s", ctld.p(_heli))
    --ctld.logTrace("_positions =  %s", ctld.p(_positions))
    --ctld.logTrace("_types     =  %s", ctld.p(_types))
    --ctld.logTrace("_hdgs      =  %s", ctld.p(_hdgs))

    local _id = ctld.getNextGroupId()
    local _groupName = _types[1] .. "    #" .. _id
    local _side = _heli:getCoalition()
    local _group = {
        ["visible"]    = false,
        ["groupId"]    = _id,
        ["hidden"]     = false,
        ["units"]      = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"]       = _groupName,
        ["tasks"]      = {},
        ["radioSet"]   = false,
        ["task"]       = "Reconnaissance",
        ["route"]      = {},
        ["start_time"] = 0,
    }
    local _hdg = 120 * math.pi / 180 -- radians = 120 degrees

    --------------------------------------------------------------------------------------
    if true then -- disable scene crates for now
        --if ctld.scene.SceneModels[_types[1]] == nil then -- if DCS standard typeName
        local _spreadMin = 5
        local _spreadMax = 5
        local _spreadMult = 1
        for _i, _pos in ipairs(_positions) do
            local _unitId = ctld.getNextUnitId()
            local _details = {
                type = _types[_i],
                unitId = _unitId,
                name = string.format("Unpacked %s #%i", _types[_i], _unitId)
            }
            --ctld.logTrace("Group._details =  %s", ctld.p(_details))
            if _hdgs and _hdgs[_i] then
                _hdg = _hdgs[_i]
            end
            local _unit_x = _pos.x + math.random(_spreadMin, _spreadMax) * _spreadMult
            local _unit_y = _pos.z + math.random(_spreadMin, _spreadMax) * _spreadMult

            local _unit_speed = 0
            local _unit_alt = _pos.y
            if _types[_i] ~= "MQ-9 Reaper" and _types[_i] ~= "RQ-1A Predator" then
                _unit_alt = nil
                _unit_speed = nil
            else                 -- for drones
                _unit_alt = 4000 --meters
                _unit_speed = 54 -- kts
            end

            _group.units[_i] = ctld.createUnit(_unit_x, _unit_y, _hdg, _details, _unit_alt, _unit_speed)
            _group.units[_i].speed = 54
        end
        if _types[1] ~= "MQ-9 Reaper" and _types[1] ~= "RQ-1A Predator" then
            _group.speed = _group.units[1].speed
            _group.category = Group.Category.GROUND
        else
            _group.category = Group.Category.AIRPLANE -- for drones
            _group.communication = true
            _group.frequency = 124
            _group.route = {
                ["points"] =
                {
                    [1] =
                    {
                        ["alt"] = _group.units[1].alt,
                        ["action"] = "Turning Point",
                        ["alt_type"] = "BARO",
                        ["properties"] = { ["addopt"] = {},
                        }
                        , -- end of ["properties"]
                        ["speed"] = _group.speed,
                        ["task"] =
                        {
                            ["id"] = "ComboTask",
                            ["params"] =
                            {
                                ["tasks"] =
                                {
                                    [1] = {
                                        ["number"] = 1,
                                        ["auto"] = true,
                                        ["id"] = "WrappedAction",
                                        ["enabled"] = true,
                                        ["params"] =
                                        {
                                            ["action"] = {
                                                ["id"] = "EPLRS",
                                                ["params"] = {
                                                    ["value"] = true,
                                                    ["groupId"] = _group.groupId,
                                                },
                                            },
                                        },
                                    },
                                    [2] = {
                                        ["number"] = 2,
                                        ["auto"] = false,
                                        ["id"] = "Orbit",
                                        ["enabled"] = true,
                                        ["params"] = {
                                            ["altitude"] = _group.units[1].alt,
                                            ["pattern"] = "Circle",
                                            ["speed"] = _group.speed,
                                        },
                                    },
                                },
                            },
                        },
                        ["type"] = "Turning Point",
                        ["ETA"] = 0,
                        ["ETA_locked"] = true,
                        ["y"] = _group.units[1].y,
                        ["x"] = _group.units[1].x,
                        ["speed_locked"] = true,
                        ["formation_template"] = "",
                    },
                },
            }
        end

        _group.country = _heli:getCountry()
        local _spawnedGroup = Group.getByName(ctld.utils.dynAdd("ctld.spawnCrateGroup()", _group).name)
        return _spawnedGroup
    else -- if scene crate requested
        return ctld.scene.playScene(_heli, ctld.scene.SceneModels[_types[1]])
    end
end

-- spawn normal group
function ctld.spawnDroppedGroup(_point, _details, _spawnBehind, _maxSearch)
    local _groupName = _details.groupName

    local _group = {
        ["visible"] = false,
        --    ["groupId"] = _details.groupId,
        ["hidden"] = false,
        ["units"] = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["task"] = {},
    }


    if _spawnBehind == false then
        -- spawn in circle around heli

        local _pos = _point

        for _i, _detail in ipairs(_details.units) do
            local _angle = math.pi * 2 * (_i - 1) / #_details.units
            local _xOffset = math.cos(_angle) * 30
            local _yOffset = math.sin(_angle) * 30

            _group.units[_i] = ctld.createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _detail)
        end
    else
        local _pos     = _point

        --try to spawn at 6 oclock to us
        local _angle   = math.atan(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * -30
        local _yOffset = math.sin(_angle) * -30


        for _i, _detail in ipairs(_details.units) do
            _group.units[_i] = ctld.createUnit(_pos.x + (_xOffset + 10 * _i), _pos.z + (_yOffset + 10 * _i), _angle,
                _detail)
        end
    end

    --switch to MIST
    _group.category = Group.Category.GROUND;
    _group.country = _details.country;

    local _spawnedGroup = Group.getByName(ctld.utils.dynAdd("ctld.spawnDroppedGroup()", _group).name)

    --local _spawnedGroup = coalition.addGroup(_details.country, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    if _maxSearch == nil then
        _maxSearch = ctld.maximumSearchDistance
    end

    local _wpZone = ctld.inWaypointZone(_point, _spawnedGroup:getCoalition())

    if _wpZone.inZone then
        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _wpZone.point)
        env.info("Heading to waypoint - In Zone " .. _wpZone.name)
    else
        local _enemyPos = ctld.findNearestEnemy(_details.loadTroops, _point, _maxSearch)

        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _enemyPos)
    end

    return _spawnedGroup
end

function ctld.findNearestEnemy(_side, _point, _searchDistance)
    local _closestEnemy = nil

    local _groups

    local _closestEnemyDist = _searchDistance

    local _heliPoint = _point

    if _side == 2 then
        _groups = coalition.getGroups(1, Group.Category.GROUND)
    else
        _groups = coalition.getGroups(2, Group.Category.GROUND)
    end

    for _, _group in pairs(_groups) do
        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        _leader = _units[x]
                        break
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.utils.getDistance("ctld.findNearestEnemy()", _heliPoint, _leaderPos)
                    if _dist < _closestEnemyDist then
                        _closestEnemyDist = _dist
                        _closestEnemy = _leaderPos
                    end
                end
            end
        end
    end


    -- no enemy - move to random point
    if _closestEnemy ~= nil then
        -- env.info("found enemy")
        return _closestEnemy
    else
        local _x = _heliPoint.x + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _z = _heliPoint.z + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _y = _heliPoint.y + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)

        return { x = _x, z = _z, y = _y }
    end
end

function ctld.findNearestGroup(_heli, _groups)
    local _closestGroupDetails = {}
    local _closestGroup = nil

    local _closestGroupDist = ctld.maxExtractDistance

    local _heliPoint = _heli:getPoint()

    for _, _groupName in pairs(_groups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                local _groupDetails = {
                    groupId = _group:getID(),
                    groupName = _group:getName(),
                    side = _group
                        :getCoalition(),
                    units = {}
                }

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        if _leader == nil then
                            _leader = _units[x]
                            -- set country based on leader
                            _groupDetails.country = _leader:getCountry()
                        end

                        local _unitDetails = {
                            type = _units[x]:getTypeName(),
                            unitId = _units[x]:getID(),
                            name = _units
                                [x]:getName()
                        }

                        table.insert(_groupDetails.units, _unitDetails)
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.utils.getDistance("ctld.findNearestGroup()", _heliPoint, _leaderPos)
                    if _dist < _closestGroupDist then
                        _closestGroupDist = _dist
                        _closestGroupDetails = _groupDetails
                        _closestGroup = _group
                    end
                end
            end
        end
    end


    if _closestGroup ~= nil then
        return { group = _closestGroup, details = _closestGroupDetails }
    else
        return nil
    end
end

function ctld.createUnit(_x, _y, _angle, _details, _altitude, _speed)
    local _alt_type = "BARO"
    local _payload = {}
    local _callsign = {
        [1] = 7,
        [2] = 1,
        ["name"] = "Chevy11",
        [3] = 1,
    }
    if _altitude == nil then
        _alt_type = nil
        _speed = nil
        _payload = nil
        _callsign = nil
    end
    local _newUnit = {
        ["alt"] = _altitude,
        ["alt_type"] = _alt_type,
        ["speed"] = _speed,
        ["payload"] = _payload,
        ["callsign"] = _callsign,
        ["y"] = _y,
        ["type"] = _details.type,
        ["name"] = _details.name,
        --    ["unitId"] = _details.unitId,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function ctld.addEWRTask(_group)
    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_ewrGroup)
        local _grp = ctld.getAliveGroup(_ewrGroup)

        if _grp ~= nil then
            local _controller = _grp:getController();
            local _EWR = {
                id = 'EWR',
                auto = true,
                params = {
                }
            }
            _controller:setTask(_EWR)
        end
    end
    , _group:getName(), timer.getTime() + 2)
end

function ctld.orderGroupToMoveToPoint(_leader, _destination)
    local _group = _leader:getGroup()

    local _path = {}
    table.insert(_path, ctld.utils.buildWP("ctld.orderGroupToMoveToPoint()", _leader:getPoint(), 'Off Road', 50))
    table.insert(_path, ctld.utils.buildWP("ctld.orderGroupToMoveToPoint()", _destination, 'Off Road', 50))

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points = _path
            },
        },
    }


    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_arg)
        local _grp = ctld.getAliveGroup(_arg[1])

        if _grp ~= nil then
            local _controller = _grp:getController();
            Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
            Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            _controller:setTask(_arg[2])
        end
    end
    , { _group:getName(), _mission }, timer.getTime() + 2)
end

-- are we in pickup zone
function ctld.inPickupZone(_heli)
    if ctld.inAir(_heli) then
        return { inZone = false, limit = -1, index = -1 }
    end

    local _heliPoint = _heli:getPoint()

    for _i, _zoneDetails in pairs(ctld.pickupZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone == nil then
            local _ship = ctld.getTransportUnit(_zoneDetails[1])

            if _ship then
                local _point = _ship:getPoint()
                _triggerZone = {}
                _triggerZone.point = _point
                _triggerZone.radius = 200 -- should be big enough for ship
            end
        end

        if _triggerZone ~= nil then
            --get distance to center

            local _dist = ctld.utils.getDistance("ctld.inPickupZone()", _heliPoint, _triggerZone.point)
            if _dist <= _triggerZone.radius then
                local _heliCoalition = _heli:getCoalition()
                if _zoneDetails[4] == 1 and (_zoneDetails[5] == _heliCoalition or _zoneDetails[5] == 0) then
                    return { inZone = true, limit = _zoneDetails[3], index = _i }
                end
            end
        end
    end

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do
        --get distance to center

        local _dist = ctld.utils.getDistance("ctld.inPickupZone()", _heliPoint, _fob:getPoint())

        if _dist <= 150 then
            return { inZone = true, limit = 10000, index = -1 };
        end
    end



    return { inZone = false, limit = -1, index = -1 };
end

function ctld.getSpawnedFobs(_heli)
    local _fobs = {}

    for _, _fobName in ipairs(ctld.builtFOBS) do
        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getCoalition() == _heli:getCoalition() and _fob:getLife() > 0 then
            table.insert(_fobs, _fob)
        end
    end

    return _fobs
end

-- are we in a dropoff zone
function ctld.inDropoffZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.dropOffZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil and (_zoneDetails[3] == _heli:getCoalition() or _zoneDetails[3] == 0) then
            --get distance to center

            local _dist = ctld.utils.getDistance("ctld.inDropoffZone()", _heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    return false
end

-- are we in a waypoint zone
function ctld.inWaypointZone(_point, _coalition)
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --right coalition and active?
        if _triggerZone ~= nil and (_zoneDetails[4] == _coalition or _zoneDetails[4] == 0) and _zoneDetails[3] == 1 then
            --get distance to center

            local _dist = ctld.utils.getDistance("ctld.inWaypointZone()", _point, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return { inZone = true, point = _triggerZone.point, name = _zoneDetails[1] }
            end
        end
    end

    return { inZone = false }
end

-- are we near friendly logistics zone
function ctld.inLogisticsZone(_heli)
    --ctld.logDebug("ctld.inLogisticsZone(), _heli = %s", ctld.p(_heli))

    if ctld.inAir(_heli) then
        return false
    end
    local _heliPoint = _heli:getPoint()
    ctld.logDebug("_heliPoint = %s", ctld.p(_heliPoint))
    for _, _name in pairs(ctld.logisticUnits) do
        ctld.logDebug("_name = %s", ctld.p(_name))
        local _logistic = StaticObject.getByName(_name)
        if not _logistic then
            _logistic = Unit.getByName(_name)
        end
        ctld.logDebug("_logistic = %s", ctld.p(_logistic))
        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() and _logistic:getLife() > 0 then
            --get distance
            local _dist = ctld.utils.getDistance("ctld.inLogisticsZone()", _heliPoint, _logistic:getPoint())
            if _dist <= ctld.maximumDistanceLogistic then
                return true
            end
        end
    end

    return false
end

-- are far enough from a friendly logistics zone
function ctld.farEnoughFromLogisticZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    local _farEnough = true

    for _, _name in pairs(ctld.logisticUnits) do
        local _logistic = StaticObject.getByName(_name)

        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() then
            --get distance
            local _dist = ctld.utils.getDistance("ctld.farEnoughFromLogisticZone()", _heliPoint, _logistic:getPoint())
            -- env.info("DIST ".._dist)
            if _dist <= ctld.minimumDeployDistance then
                -- env.info("TOO CLOSE ".._dist)
                _farEnough = false
            end
        end
    end

    return _farEnough
end

function ctld.refreshSmoke()
    if ctld.disableAllSmoke == true then
        return
    end

    for _, _zoneGroup in pairs({ ctld.pickupZones, ctld.dropOffZones }) do
        for _, _zoneDetails in pairs(_zoneGroup) do
            local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

            if _triggerZone == nil then
                local _ship = ctld.getTransportUnit(_triggerZone)

                if _ship then
                    local _point = _ship:getPoint()
                    _triggerZone = {}
                    _triggerZone.point = _point
                end
            end


            --only trigger if smoke is on AND zone is active
            if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[4] == 1 then
                -- Trigger smoke markers

                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end

    --waypoint zones
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --only trigger if smoke is on AND zone is active
        if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[3] == 1 then
            -- Trigger smoke markers

            local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
            local _alt = land.getHeight(_pos2)
            local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

            trigger.action.smoke(_pos3, _zoneDetails[2])
        end
    end


    --refresh in 5 minutes
    timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 300)
end

function ctld.dropSmoke(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil then
        local _colour = ""

        if _args[2] == trigger.smokeColor.Red then
            _colour = "RED"
        elseif _args[2] == trigger.smokeColor.Blue then
            _colour = "BLUE"
        elseif _args[2] == trigger.smokeColor.Green then
            _colour = "GREEN"
        elseif _args[2] == trigger.smokeColor.Orange then
            _colour = "ORANGE"
        end

        local _point = _heli:getPoint()

        local _pos2 = { x = _point.x, y = _point.z }
        local _alt = land.getHeight(_pos2)
        local _pos3 = { x = _point.x, y = _alt, z = _point.z }

        trigger.action.smoke(_pos3, _args[2])

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 dropped %2 smoke.", ctld.getPlayerNameOrType(_heli), _colour), 10)
    end
end

function ctld.unitCanCarryVehicles(_unit)
    local _type = string.lower(_unit:getTypeName())

    for _, _name in ipairs(ctld.vehicleTransportEnabled) do
        local _nameLower = string.lower(_name)
        if string.find(_type, _nameLower, 1, true) then
            return true
        end
    end

    return false
end

function ctld.unitDynamicCargoCapable(_unit)
    local cache = {}
    local _type = string.lower(_unit:getTypeName())
    local result = cache[_type]
    if result == nil then
        result = false
        --ctld.logDebug("ctld.unitDynamicCargoCapable(_type=[%s])", ctld.p(_type))
        for _, _name in ipairs(ctld.dynamicCargoUnits) do
            local _nameLower = string.lower(_name)
            if string.find(_type, _nameLower, 1, true) then --string.match does not work with patterns containing '-' as it is a magic character
                result = true
                break
            end
        end
        cache[_type] = result
    end
    return result
end

function ctld.isJTACUnitType(_type)
    if _type then
        _type = string.lower(_type)
        for _, _name in ipairs(ctld.jtacUnitTypes) do
            local _nameLower = string.lower(_name)
            if string.match(_type, _nameLower) then
                return true
            end
        end
    end
    return false
end

function ctld.updateZoneCounter(_index, _diff)
    if ctld.pickupZones[_index] ~= nil then
        ctld.pickupZones[_index][3] = ctld.pickupZones[_index][3] + _diff

        if ctld.pickupZones[_index][3] < 0 then
            ctld.pickupZones[_index][3] = 0
        end

        if ctld.pickupZones[_index][6] ~= nil then
            trigger.action.setUserFlag(ctld.pickupZones[_index][6], ctld.pickupZones[_index][3])
        end
        --    env.info(ctld.pickupZones[_index][1].." = " ..ctld.pickupZones[_index][3])
    end
end

function ctld.processCallback(_callbackArgs)
    for _, _callback in pairs(ctld.callbacks) do
        local _status, _result = pcall(function()
            _callback(_callbackArgs)
        end)

        if (not _status) then
            env.error(string.format("CTLD Callback Error: %s", _result))
        end
    end
end

-- checks the status of all AI troop carriers and auto loads and unloads troops
-- as long as the troops are on the ground
function ctld.checkAIStatus()
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 2)


    for _, _unitName in pairs(ctld.transportPilotNames) do
        local status, error = pcall(function()
            local _unit = ctld.getTransportUnit(_unitName)

            -- no player name means AI!
            if _unit ~= nil and _unit:getPlayerName() == nil then
                local _zone = ctld.inPickupZone(_unit)
                --    env.error("Checking.. ".._unit:getName())
                if _zone.inZone == true and not ctld.troopsOnboard(_unit, true) then
                    --     env.error("in zone, loading.. ".._unit:getName())

                    if ctld.allowRandomAiTeamPickups == true then
                        -- Random troop pickup implementation
                        local _team = nil
                        if _unit:getCoalition() == 1 then
                            _team = math.floor((math.random(#ctld.redTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.redTeams[_team]], true })
                        else
                            _team = math.floor((math.random(#ctld.blueTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.blueTeams[_team]], true })
                        end
                    else
                        ctld.loadTroopsFromZone({ _unitName, true, "", true })
                    end
                elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, true) then
                    --         env.error("in dropoff zone, unloading.. ".._unit:getName())
                    ctld.unloadTroops({ _unitName, true })
                end

                if ctld.unitCanCarryVehicles(_unit) then
                    if _zone.inZone == true and not ctld.troopsOnboard(_unit, false) then
                        ctld.loadTroopsFromZone({ _unitName, false, "", true })
                    elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, false) then
                        ctld.unloadTroops({ _unitName, false })
                    end
                end
            end
        end)

        if (not status) then
            env.error(string.format("Error with ai status: %s", error), false)
        end
    end
end

function ctld.getTransportLimit(_unitType)
    if ctld.unitLoadLimits[_unitType] then
        return ctld.unitLoadLimits[_unitType]
    end

    return ctld.numberOfTroops
end

function ctld.getUnitActions(_unitType)
    if ctld.unitActions[_unitType] then
        return ctld.unitActions[_unitType]
    end

    return { crates = true, troops = true }
end

--**********************************************************************

-- ***************** SETUP SCRIPT ****************
function ctld.initialize()
    ctld.logInfo(string.format("Initializing version %s", ctld.Version))

    -- assert(mist ~= nil,
    --     "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

    ctld.unitsWithPlayer = {}     -- stores units that have players in them
    ctld.addedTo = {}             -- stores units that have had the CTLD F10 menu added
    ctld.spawnedCratesRED = {}    -- use to store crates that have been spawned
    ctld.spawnedCratesBLUE = {}   -- use to store crates that have been spawned

    ctld.droppedTroopsRED = {}    -- stores dropped troop groups
    ctld.droppedTroopsBLUE = {}   -- stores dropped troop groups

    ctld.droppedVehiclesRED = {}  -- stores vehicle groups for c-130 / hercules
    ctld.droppedVehiclesBLUE = {} -- stores vehicle groups for c-130 / hercules

    ctld.inTransitTroops = {}

    ctld.inTransitFOBCrates = {}

    ctld.inTransitSlingLoadCrates = {} -- stores crates that are being transported by helicopters for alternative to real slingload

    ctld.droppedFOBCratesRED = {}
    ctld.droppedFOBCratesBLUE = {}

    ctld.builtFOBS = {}            -- stores fully built fobs

    ctld.completeAASystems = {}    -- stores complete spawned groups from multiple crates

    ctld.fobBeacons = {}           -- stores FOB radio beacon details, refreshed every 60 seconds

    ctld.deployedRadioBeacons = {} -- stores details of deployed radio beacons

    ctld.beaconCount = 1

    ctld.usedUHFFrequencies = {}
    ctld.usedVHFFrequencies = {}
    ctld.usedFMFrequencies = {}
    ctld.freeUHFFrequencies = {}
    ctld.freeVHFFrequencies = {}
    ctld.freeFMFrequencies = {}

    --used to lookup what the crate will contain
    ctld.crateLookupTable = {}
    ctld.extractZones = {}             -- stored extract zones
    ctld.missionEditorCargoCrates = {} -- crates added by mission editor for triggering cratesinzone
    ctld.hoverStatus = {}              -- tracks status of a helis hover above a crate
    ctld.callbacks = {}                -- function callback
    ctld.vehicleCommandsPath = {}      -- memory of F10 c=CTLD menu path bay unitNames

    -- Remove intransit troops when heli / cargo plane dies
    --ctld.eventHandler = {}
    --function ctld.eventHandler:onEvent(_event)
    --
    --        if _event == nil or _event.initiator == nil then
    --                env.info("CTLD null event")
    --        elseif _event.id == 9 then
    --                -- Pilot dead
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --        elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
    --                -- env.info("Event unit - Pilot Ejected or Unit Dead")
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --                -- env.info(_event.initiator:getName())
    --        end
    --
    --end

    -- create crate lookup table
    for _subMenuName, _crates in pairs(ctld.spawnableCrates) do
        for _, _crate in pairs(_crates) do
            -- convert number to string otherwise we'll have a pointless giant
            -- table. String means 'hashmap' so it will only contain the right number of elements
            if _crate.multiple then
                local _totalWeight = 0
                for _, _weight in pairs(_crate.multiple) do
                    _totalWeight = _totalWeight + _weight
                end
                _crate.weight = _totalWeight
            end
            ctld.crateLookupTable[tostring(_crate.weight)] = _crate
        end
    end


    --sort out pickup zones
    for _, _zone in pairs(ctld.pickupZones) do
        local _zoneName = _zone[1]
        local _zoneColor = _zone[2]
        local _zoneActive = _zone[4]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        -- add in counter for troops or units
        if _zone[3] == -1 then
            _zone[3] = 10000;
        end

        -- change active to 1 / 0
        if _zoneActive == "yes" then
            _zone[4] = 1
        else
            _zone[4] = 0
        end
    end

    --sort out dropoff zones
    for _, _zone in pairs(ctld.dropOffZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        _zone[4] = 1
    end

    --sort out waypoint zones
    for _, _zone in pairs(ctld.wpZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1 -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        -- change active to 1 / 0
        if _zone[3] == "yes" then
            _zone[3] = 1
        else
            _zone[3] = 0
        end
    end

    -- Sort out extractable groups
    for _, _groupName in pairs(ctld.extractableGroups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            if _group:getCoalition() == 1 then
                table.insert(ctld.droppedTroopsRED, _group:getName())
            else
                table.insert(ctld.droppedTroopsBLUE, _group:getName())
            end
        end
    end


    -- Seperate troop teams into red and blue for random AI pickups
    if ctld.allowRandomAiTeamPickups == true then
        ctld.redTeams = {}
        ctld.blueTeams = {}
        for _, _loadGroup in pairs(ctld.loadableGroups) do
            if not _loadGroup.side then
                table.insert(ctld.redTeams, _)
                table.insert(ctld.blueTeams, _)
            elseif _loadGroup.side == 1 then
                table.insert(ctld.redTeams, _)
            elseif _loadGroup.side == 2 then
                table.insert(ctld.blueTeams, _)
            end
        end
    end

    -- add total count

    for _, _loadGroup in pairs(ctld.loadableGroups) do
        _loadGroup.total = 0
        if _loadGroup.aa then
            _loadGroup.total = _loadGroup.aa + _loadGroup.total
        end

        if _loadGroup.inf then
            _loadGroup.total = _loadGroup.inf + _loadGroup.total
        end


        if _loadGroup.mg then
            _loadGroup.total = _loadGroup.mg + _loadGroup.total
        end

        if _loadGroup.at then
            _loadGroup.total = _loadGroup.at + _loadGroup.total
        end

        if _loadGroup.mortar then
            _loadGroup.total = _loadGroup.mortar + _loadGroup.total
        end
    end

    --*************************************************************************************************
    -- Scheduled functions (run cyclically) -- but hold execution for a second so we can override parts
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 1)
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 5)

    timer.scheduleFunction(function()
        timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.addOtherF10MenuOptions, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.updateDynamicLogisticUnitsZones, nil, timer.getTime() + 5)
        if ctld.enableCrates == true and ctld.hoverPickup == true then
            timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1)
        end
        if ctld.enableRepackingVehicles == true then
            timer.scheduleFunction(ctld.updateRepackMenuOnlanding, nil, timer.getTime() + 1) -- update helo repack menu when a helo landing is detected
            timer.scheduleFunction(ctld.repackVehicle, nil, timer.getTime() + 1)
        end
        if ctld.enableAutoOrbitingFlyingJtacOnTarget then
            timer.scheduleFunction(ctld.TreatOrbitJTAC, {}, timer.getTime() + 3)
        end
        if ctld.nbLimitSpawnedTroops[1] ~= 0 or ctld.nbLimitSpawnedTroops[2] ~= 0 then
            timer.scheduleFunction(ctld.updateTroopsInGame, {}, timer.getTime() + 1)
        end
    end, nil, timer.getTime() + 1)

    --event handler for deaths
    --world.addEventHandler(ctld.eventHandler)

    --env.info("CTLD event handler added")

    env.info("Generating Laser Codes")
    ctld.generateLaserCode()
    env.info("Generated Laser Codes")



    env.info("Generating UHF Frequencies")
    ctld.generateUHFrequencies()
    env.info("Generated    UHF Frequencies")

    env.info("Generating VHF Frequencies")
    ctld.generateVHFrequencies()
    env.info("Generated VHF Frequencies")


    env.info("Generating FM Frequencies")
    ctld.generateFMFrequencies()
    env.info("Generated FM Frequencies")

    -- Search for crates
    -- Crates are NOT returned by coalition.getStaticObjects() for some reason
    -- Search for crates in the mission editor instead
    env.info("Searching for Crates")
    for _coalitionName, _coalitionData in pairs(env.mission.coalition) do
        if (_coalitionName == 'red' or _coalitionName == 'blue')
            and type(_coalitionData) == 'table' then
            if _coalitionData.country then --there is a country table
                for _, _countryData in pairs(_coalitionData.country) do
                    if type(_countryData) == 'table' then
                        for _objectTypeName, _objectTypeData in pairs(_countryData) do
                            if _objectTypeName == "static" then
                                if ((type(_objectTypeData) == 'table')
                                        and _objectTypeData.group
                                        and (type(_objectTypeData.group) == 'table')
                                        and (#_objectTypeData.group > 0)) then
                                    for _groupId, _group in pairs(_objectTypeData.group) do
                                        if _group and _group.units and type(_group.units) == 'table' then
                                            for _unitNum, _unit in pairs(_group.units) do
                                                if _unit.canCargo == true then
                                                    local _cargoName = env.getValueDictByKey(_unit.name)
                                                    ctld.missionEditorCargoCrates[_cargoName] = _cargoName
                                                    env.info("Crate Found: " .. _unit.name .. " - Unit: " .. _cargoName)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    env.info("END search for crates")

    -- register event handler
    ctld.logInfo("registering event handler")
    world.addEventHandler(ctld.eventHandler)
    env.info("CTLD READY")
end

--- Handle world events.
ctld.eventHandler = {}
function ctld.eventHandler:onEvent(event)
    --ctld.logTrace("ctld.eventHandler:onEvent()")
    if event == nil then
        ctld.logError("Event handler was called with a nil event!")
        return
    end

    local eventName = "unknown"
    -- check that we know the event
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        eventName = "S_EVENT_PLAYER_ENTER_UNIT"
    elseif event.id == world.event.S_EVENT_BIRTH then
        eventName = "S_EVENT_BIRTH"
    else
        --ctld.logTrace("Ignoring event %s", ctld.p(event))
        return
    end
    ctld.logDebug("caught event %s: %s", ctld.p(eventName), ctld.p(event))

    -- find the originator unit
    local unitName = nil
    if event.initiator ~= nil and event.initiator.getName then
        ctld.logDebug(" event.initiator = [%s]", ctld.p(event.initiator))
        ctld.logDebug("event.initiator.getName = [%s]", ctld.p(event.initiator:getName()))
        unitName = event.initiator:getName()
        ctld.logDebug("unitName = [%s]", ctld.p(unitName))
        local unit = Unit.getByName(unitName)
        if unit and unit.getPlayerName then
            if Unit.getByName(unitName):getPlayerName() ~= nil then -- it's a human player
                --ctld.logTrace("calling the 'processHumanPlayer' function immediately")
                ctld.logTrace("in the 'processHumanPlayer' function processHumanPlayer()- unitName = %s",
                    ctld.p(unitName))
                ctld.logDebug("caught event %s for human unit [%s]", ctld.p(eventName), ctld.p(unitName))
                local _unit = Unit.getByName(unitName)
                if _unit ~= nil then
                    local _groupId = _unit:getGroup():getID()
                    ctld.logTrace("_unit = %s", ctld.p(_unit))

                    local playerTypeName = _unit:getTypeName()
                    ctld.logTrace("playerTypeName = %s", ctld.p(playerTypeName))

                    -- update ctld.DB.unitsWithPlayer
                    ctld.unitsWithPlayer[unitName] = {}
                    ctld.unitsWithPlayer[unitName].desc = ctld.utils.deepCopy("ctld.eventHandler:onEvent()",
                        _unit:getDesc())
                    ctld.unitsWithPlayer[unitName].typeName = playerTypeName
                    ctld.unitsWithPlayer[unitName].groupId = _groupId
                    ctld.unitsWithPlayer[unitName].coalition = _unit:getCoalition()
                    ctld.unitsWithPlayer[unitName].unit = _unit
                    ctld.unitsWithPlayer[unitName].playerName = _unit:getPlayerName()
                    ctld.unitsWithPlayer[unitName].F10Menu = {}

                    -- Allow units to CTLD by aircraft type and not by pilot name
                    if ctld.addPlayerAircraftByType then
                        for _, aircraftType in pairs(ctld.aircraftTypeTable) do
                            if aircraftType == playerTypeName then
                                ctld.logTrace("adding by aircraft type, unitName = %s", ctld.p(unitName))
                                if ctld.utils.isValueInIpairTable("ctld.eventHandler:onEvent()", ctld.transportPilotNames, unitName) == false then
                                    table.insert(ctld.transportPilotNames, unitName) -- add transport unit to the list
                                end
                                if ctld.addedTo[tostring(_groupId)] == nil then      -- only if menu not already set up
                                    ctld.addTransportF10MenuOptions(unitName)        -- add transport radio menu
                                    break
                                end
                            end
                        end
                    else
                        for _, _unitName in pairs(ctld.transportPilotNames) do
                            if _unitName == unitName then
                                ctld.logTrace("adding by transportPilotNames, unitName = %s", ctld.p(unitName))
                                ctld.addTransportF10MenuOptions(unitName) -- add transport radio menu
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    if not unitName then
        ctld.logInfo("no unitname found in event %s", ctld.p(event))
        return
    end
end

function ctld.i18n_check(language, verbose)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        ctld.logError(string.format("CTLD.i18n_check: Language %s not found", language))
        return false
    end
    local englishVersion = english.translation_version
    local tocheckVersion = tocheck.translation_version
    if englishVersion ~= tocheckVersion then
        ctld.logError(string.format("CTLD.i18n_check: Language version mismatch: EN has version %s, %s has version %s",
            englishVersion, language, tocheckVersion))
    end
    --ctld.logTrace(string.format("english = %s", ctld.p(english)))
    for textRef, textEnglish in pairs(english) do
        if textRef ~= "translation_version" then
            local textTocheck = tocheck[textRef]
            if not textTocheck then
                ctld.logError(string.format("CTLD.i18n_check: NOT FOUND: checking %s text [%s]", language, textRef))
            elseif textTocheck == textEnglish then
                ctld.logWarning(string.format("CTLD.i18n_check:         SAME: checking %s text [%s] as in EN", language,
                    textRef))
            elseif verbose then
                ctld.logInfo(string.format("CTLD.i18n_check:             OK: checking %s text [%s]", language, textRef))
            end
        end
    end
end

-- example of usage:
--ctld.i18n_check("fr")

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

-- initialize CTLD
-- if you need to have a chance to modify the configuration before initialization in your other scripts, please set ctld.dontInitialize to true and call ctld.initialize() manually
if ctld.dontInitialize then
    ctld.logInfo(string.format("Skipping initializion of version %s because ctld.dontInitialize is true", ctld.Version))
else
    ctld.initialize()
end
-- End : CTLD_core.lua 
