# DCS-CTLD
Complete Troops and Logistics Deployment for DCS World

This script is a rewrite of some of the functionality of the original Complete Combat Troop Transport Script (CTTS) by Geloxo (http://forums.eagle.ru/showthread.php?t=108523), as well as adding new features.

The script supports:

* Troop Loading / Unloading via Radio Menu
    * AI Units can also load and unload troops automatically
* Vehicle Loading / Unloading via Radio Menu for C-130 (Other large aircraft can easily be added) (https://www.digitalcombatsimulator.com/en/files/668878/?sphrase_id=1196134)
    * You will need to download the modded version of the C-130 from here (JSGME Ready) that fixes the Radio Menu 
* Coloured Smoke Marker Drops
* Extractable Soldier Spawn at a trigger zone
* Extractable soldier groups added via mission editor
* Unit construction using crates spawned at a logistics area and dropped via cargo sling
    * HAWK AA System requires 3 separate and correct crates to build
        * HAWK system can also be rearmed after construction by dropping another Hawk Launcher nearby and unpacking
    * HMMWV TOW
    * HMMWV MG
    * HMMWV JTAC - Will Auto Lase and mark targets with smoke if enabled
    * Mortar
    * MANPAD
* Pre loading of units into AI vehicles via a DO SCRIPT

A complete test mission is included.

You can also edit the CTLD.lua file to change some configuration options. Make sure you re-add the lua file to the mission after editing by deleting the trigger that loads the file, then readding the trigger and the DO SCRIPT FILE action. 

##Setup in Mission Editor

###Script Setup
**This script requires MIST version 3.6 or above: https://github.com/mrSkortch/MissionScriptingTools**

First make sure MIST is loaded, either as an Initialization Script  for the mission or the first DO SCRIPT with a "TIME MORE" of 1. "TIME MORE" means run the actions after X seconds into the mission.

Load the CTLD a few seconds after MIST using a second trigger with a "TIME MORE" and a DO SCRIPT of CTLD.lua. 
An error will be shown if MIST isn't loaded first.

An example is shown below:

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-25-14-00_zpsmoirc3nz.png~original "Script Setup")

###Script Configuration
The script has lots of configuration options that can be used to futher customise the behaviour.
```lua
-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************
ctld.disableAllSmoke = false -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below
ctld.enableCrates = true -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.enableSmokeDrop = true -- if false, helis and c-130 will not be able to drop smoke

ctld.maxExtractDistance = 125 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic = 200 -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.maximumSearchDistance = 4000 -- max distance for troops to search for enemy
ctld.maximumMoveDistance = 1000 -- max distance for troops to move from drop point if no enemy is nearby

ctld.numberOfTroops = 10 -- default number of troops to load on a transport heli or C-130

ctld.vehiclesForTransport = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130

ctld.spawnRPGWithCoalition = true --spawns a friendly RPG unit with Coalition forces
```

To change what units can be dropped from crates modify the spawnable crates section

```lua

-- ************** SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
ctld.spawnableCrates = {

    -- name of the sub menu on F10 for spawning crates
    ["Ground Forces"] = {

        --crates you can spawn
        -- weight in KG
        -- Desc is the description on the F10 MENU
        -- unit is the model name of the unit to spawn
        { weight = 1400, desc = "HMMWV - TOW", unit = "M1045 HMMWV TOW" },
        { weight = 1200, desc = "HMMWV - MG", unit = "M1043 HMMWV Armament" },
        { weight = 1100, desc = "HMMWV - JTAC", unit = "Hummer" }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 200, desc = "2B11 Mortar", unit = "2B11 mortar" },
    },

    ["AA Crates"] = {

        { weight = 210, desc = "MANPAD", unit = "Stinger manpad" },
        { weight = 1000, desc = "HAWK Launcher", unit = "Hawk ln" },
        { weight = 1010, desc = "HAWK Search Radar", unit = "Hawk sr" },
        { weight = 1020, desc = "HAWK Track Radar", unit = "Hawk tr" },
    },


}
```

**Make sure that after making any changes to the script you remove and re-add the script to the mission. **

###Other Script Functions
You can also preload troops into AI transports once the CTLD script has been loaded, instead of having the AI enter a pickup zone, using the code below where the parameters are:
* Pilot name of the unit
* number of troops / vehicles to load
* true means load with troops, false means load with vehicles

If you try to load vehicles into anything other than a unit listed in ```ctld.vehicleTransportEnabled```, they won't be able to deploy them.
```lua
ctld.preLoadTransport("helicargo1", 10,true)
```

You can also make existing mission editor groups extractable by adding their group name to the ```ctld.extractableGroups``` list

You can also spawn extractable infantry groups at a specified trigger zone using the code below.

The parameters are:
* group side (red or blue)
* number of troops to spawn
* the name of the trigger to spawn the extractable troops at
* the distance the troops should search for enemies on spawning in meters

```lua
ctld.spawnGroupAtTrigger("red", 10, "spawnTrigger", 1000)
```
or
```lua
ctld.spawnGroupAtTrigger("blue", 5, "spawnTrigger2", 2000)
```

####JTAC Automatic Targeting and Laser
This script has been merged with https://github.com/ciribob/DCS-JTACAutoLaze . JTACs can either be deployed by Helicopters and configured with the options in the script or pre added to the mission. By default each side can drop 5 JTACs.

The JTAC Script configuration is shown below and can easily be disabled using the ```ctld.JTAC_dropEnabled``` option.

```lua
-- ***************** JTAC CONFIGURATION *****************
ctld.JTAC_LIMIT_RED = 5 -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE = 5 -- max number of JTAC Crates for the BLUE Side

ctld.JTAC_dropEnabled = true -- allow JTAC Crate spawn from F10 menu

ctld.JTAC_maxDistance = 4000 -- How far a JTAC can "see" in meters (with Line of Sight)

ctld.JTAC_smokeOn_RED = true -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE = true -- enables marking of target with smoke for BLUE forces

ctld.JTAC_smokeColour_RED = 4 -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE = 1 -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4

ctld.JTAC_jtacStatusF10 = false -- enables F10 JTAC Status menu

ctld.JTAC_location = false -- shows location of target in JTAC message

ctld.JTAC_lock =  "all" -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units

```

The script allows a JTAC to mark and hold an IR and Laser point on a target allowing TGP's to lock onto the lase and ease of target location using NV Goggles.

The JTAC will automatically switch targets when a target is destroyed or goes out of Line of Sight.

The JTACs can be configured globally to target only vehicles or troops or all ground targets.

***NOTE: LOS doesn't include buildings or tree's... Sorry! ***

The script can also be useful in daylight by enabling the JTAC to mark enemy positions with Smoke. The JTAC will only move the smoke to the target every 5 minutes (to stop a huge trail of smoke markers) unless the target is destroyed, in which case the new target will be marked straight away with smoke. There is also an F10 menu option for units allowing the JTAC(s) to report their current status but if a JTAC is down it won't report in.

To add JTACS to the mission using the editor place a JTAC unit on the map putting each JTAC in it's own group containing only itself and no
other units. Name the group something easy to remember e.g. JTAC1 and make sure the JTAC units have a unique name which must
not be the same as the group name. The editor should do this for you but be careful if you copy and paste.

Run the code below as a DO SCRIPT at the start of the mission, or after a delay if you prefer to activate a mission JTAC. 

**JTAC HMMWV units deployed by unpacking a crate will automatically activate and begin searching for targets immediately.**

```lua
ctld.JTACAutoLase('JTAC1', 1688)
```

Where JTAC1 is the Group name of the JTAC Group with one and only one JTAC unit and the 1688 is the Laser code.

You can also override global settings set in the script like so:

```lua
ctld.JTACAutoLase('JTAC1', 1688, false,"all") 
```
This means no smoke marks for this JTAC and it will target all ground troops

```lua
ctld.JTACAutoLase('JTAC1', 1688, true,"vehicle")
```
This smoke marks for this JTAC and it will target ONLY ground vehicles

```lua
ctld.JTACAutoLase('JTAC1', 1688, true,"troop")
```
This means smoke marks are enabled for this JTAC and it will target ONLY ground troops

```lua
ctld.JTACAutoLase('JTAC1', 1688, true,"troop",1)
```
This means smoke marks are enabled for this JTAC and it will target ONLY ground troops AND smoke colour will be Red

```lua
ctld.JTACAutoLase('JTAC1', 1688, true,"troop",0)
```
This means smoke marks are enabled for this JTAC and it will target ONLY ground troops AND smoke colour will be Green

```lua
ctld.JTACAutoLase('JTAC1', 1688, true,"all", 4) 
```
This means no smoke marks for this JTAC and it will target all ground troops AND mark with Blue smoke

Smoke colours are: Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4

The script doesn't care if the unit isn't activated when run, as it'll automatically activate when the JTAC is activated in
the mission but there can be a delay of up to 30 seconds after activation for the JTAC to start searching for targets.

###Pickup and Dropoff Zones Setup
Pickup zones are used by transport aircraft and helicopters to load troops and vehicles. A transport unit must be inside of the radius of the trigger in order to load troops and vehicles.
The pickup zone needs to be named the same as one of the pickup zones in the ```ctld.pickupZones``` list or the list can be edited to match the name in the mission editor.

```lua
ctld.pickupZones = {
    { "pickzone1", "blue" },
    { "pickzone2", "blue" },
    { "pickzone3", "none" },
    { "pickzone4", "none" },
    { "pickzone5", "none" },
    { "pickzone6", "none" },
    { "pickzone7", "none" },
    { "pickzone8", "none" },
    { "pickzone9", "none" },
    { "pickzone10", "none" },
}
```

AI transport units will automatically load troops and vehicles when entering a pickup zone as long as they stay in the zone for a few seconds. They do not need to stop to load troops but Aircraft will need to be on the ground in order to load troops.

Example:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-22-48-57_zpsc5u7bymy.png~original "Pickup zone")

Dropoff zones are used by AI units to automatically unload any loaded troops or vehicles. This will occurr as long as the AI unit has some units onboard and stays in the radius of the zone for a few seconds and the zone is named in the ```ctld.dropoffZones``` list. Again units do not need to stop but aircraft need to be on the ground in order to unload the troops.

```lua
ctld.dropOffZones = {
    { "dropzone1", "red" },
    { "dropzone2", "blue" },
    { "dropzone3", "none" },
    { "dropzone4", "none" },
    { "dropzone5", "none" },
    { "dropzone6", "none" },
    { "dropzone7", "none" },
    { "dropzone8", "none" },
    { "dropzone9", "none" },
    { "dropzone10", "none" },
}
```

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-23-15-72_zpsrmfzbdtr.png~original "Dropoff Zone")

Smoke can be enabled or disabled individually for pickup or dropoff zones by editing the second column in the list.

Available colours are:
* ```"green"``` 
* ```"red"```
* ```"white"```
* ```"orange"```
* ```"blue"```
* ```"none"```

Smoke can be disabled for all zones regardless of the settings above using the option ```ctld.disableAllSmoke = true``` in the User Configuration part of the script.

###Transport Unit Setup
Any unit that you want to be able to transport troops needs to have the **"Pilot Name"** in the ```ctld.transportPilotNames``` list. **Player controlled transport units should be in a group of their own and be the only unit in the group, otherwise other players may have radio commands they shouldn't**. The group name isn't important and can be set to whatever you like. A snippet of the list is shown below. 

If the unit is player controlled, troops have to be manually loaded when in a pickup zone, AI units will auto load troops in a pickup zone.

```lua
ctld.transportPilotNames = {
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
    }
```

Example for C-130:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-26-26-40_zpswy4s4p7p.png~original "C-130FR")

Example for Huey:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-26-30-78_zpsm8bxsofc.png~original "Huey")

Example for AI APC:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2015-25-50-65_zpsdiztodm5.png~original "AI APC")


###Logistic Setup
Logistic crates can also be spawned by Player-controlled Transport Helicopters, as long as they are near a friendly logistic unit listed in ```ctld.logisticUnits```. The distance that the heli's can spawn crates at can be configured at the top of the script. Any static object can be used for Logistics.

```lua
ctld.logisticUnits = {
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

```

Example:

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Launcher%202015-05-10%2016-01-53-20_zps1ccbwnop.png~original "Logistic Unit")

#In Game
##Troop Loading and Unloading

Troops can be loaded and unloaded using the F10 Menu. Troops can only be loaded in a pickup zone but can be dropped anywhere you like. Troops dropped by transports can also be extracted by any transport unit using the radio menu, as long as you are close enough.

AI transports will display a message when they Auto load and deploy troops in the field. AI units won't pickup already deployed troops so as not to interfere with players.

The C130 gets an extra radio option for loading and deploying vehicles. By default the C130 can pickup and deploy a  HMMWV TOW and HMMWV MG. This can be changed by editing ```ctld.vehiclesForTransport``` .

##Cargo Spawning and Sling Loading

Cargo can be spawned by transport helicopters if they are close enough to a friendly logistics unit using the F10 menu. Everything except the HAWK AA Missile system requires only one crate to build. Crates are always spawned off the nose of the unit that requested them. Sling cargo weight differs drastically depending on what you are sling loading. The Huey will need to have 20% fuel and no armaments in order to be able to lift a HMMWV TOW crate! The Mi-8 has a higher max lifting weight than a Huey.

Once spawning the crate, to slingload the F6 menu needs to be used to select a cargo of the correct weight. If you've selected the right cargo RED smoke will appear and you can now sling load by hovering over the crate at a height of 15-30 feet or so.

* Huey rough max sling weight = 4000 lb / 1814.37 kg
* Mi-8 rough max sling weight = 6614 lb / 3000 kg

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/dcs%202015-05-10%2016-09-13-61_zpsksnkende.png~original "Spawned Cargo")

After selecting the right crate:

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/dcs%202015-05-10%2016-09-23-08_zpslbed4kpt.png~original "Spawned Cargo")

You can also list nearby crates that have yet to be unpacked using the F10 Crate Commands Menu and also unpack nearby crates using the same menu.

*Crate damage in the script is currently not implemented so as long as the crate isn't destroyed, you should always be able to unpack.*

##Crate Unpacking
Once you have sling loaded and successfully dropped your crate, you can land and list nearby crates that have yet to be unpacked using the F10 Crate Commands Menu, as well as unpack nearby crates using the same menu. Crates cannot be unpacked near a logistics unit.

To build a HAWK AA system you will need to slingload all 3 parts - Launcher, Track Radar and Search Radar - and drop the crates within 100m of each other. If you try to build the system without all the parts, a message will list which parts are missing.

Parts Missing:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/dcs%202015-05-10%2016-45-15-05_zpsv856jhw3.png~original "Hawk Parts missing")

Example of Deployed HAWK System:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/dcs%202015-05-10%2016-45-49-86_zpssmg1tvki.png~original "Hawk Deployed")

You can also rearm a fully deployed HAWK system by dropping another Launcher crate next to the completed system and unpacking it.

Rearming:
![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/dcs%202015-05-10%2016-46-10-44_zpsqr8oducw.png~original "Hawk Rearmed")

**Note: Once unpacked a crate will not disappear from the field or the F6 Menu, but will disappear from the F10 Nearby Crates list. There is currently no way to remove crates due to a DCS Bug AFAIK. This can make picking the right crate tricky, but by using the F10 List crates option, you can keep readjusting your position until you are close to the crate that you want and then it's trial and error, using the F6 menu to pick the right crate for sling loading. **


