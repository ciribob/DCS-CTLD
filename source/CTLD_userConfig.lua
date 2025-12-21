------------ example script yaml ---------------------------------
-- File : CTLD_userConfig.lua
-- to execute with a trigger at START MISSION in "DO SCRIPT FILE" action
------------------------------------------------------------------
if ctld == nil then ctld = {} end
ctld.yamlConfigDatas = [[
config_mission:
  usr_configuration:
    #DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE
    ctld.staticBugWorkaround: false
    #if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below
    ctld.disableAllSmoke: false
  auto_start: true
  max_players: 10
  briefing: |
    Welcome to "Steel Rain"opération.
    objective 1 : Destroy the radars.
    objective 2 : Return to base.
  targets:
    - SAM-6
    - ZU-23
  scenes:
    FARP Alpha:
      steps:
        - polar:
            distance: 100
            angle: 0
          delayAfterPreviousStep: 0
          relativeHeadingInDegrees: 180
          relativeAltitudeInMeters: 0
          objectsDescDbKey: SINGLE_HELIPAD
          func: |
            function(triggerUnitObj, spwanedObject, stepDatas)
                -- Custom logic here
                return true
            end
        - polar:
            distance: 130
            angle: 5
          delayAfterPreviousStep: 3
          relativeHeadingInDegrees: 90
          relativeAltitudeInMeters: 0
          objectsDescDbKey: COMMAND_TENT
]]
