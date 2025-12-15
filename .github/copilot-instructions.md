# DCS-CTLD AI Coding Agent Instructions

## Project Overview
DCS-CTLD (Combat Troops and Logistics Deployment) is a Lua scripting framework for DCS World flight simulator. It enables helicopter and transport aircraft to dynamically spawn, transport, and deploy troops, vehicles, and logistics via interactive radio menus. The project is undergoing **feature_modularisation** (separate from master branch) to improve code organization.

## Architecture

### Module Loading Pipeline
**Critical**: Modules must load in this EXACT order ([source/CTLD_loader.lua](source/CTLD_loader.lua)):
1. `mist.lua` - Bundled MIST framework (Mission Scripting Tools)
2. `CTLD_extAPI.lua` - API wrapper for framework abstraction
3. `CTLD-i18n.lua` - Translations (FR, ES, KO)
4. `CTLD.lua` - Core logic (8919 lines—main configuration)
5. `CTLD_utils.lua` - Utility functions (geo calculations, logging)
6. `CTLD_DCSWeaponsDb.lua` - Weapon/equipment database
7. `dcsObjectsDescDb.lua` - Object spawn descriptors
8. `CTLD_scene.lua` - Scene sequencing/animation system
9. `farpSceneDatas.lua` - FARP deployment scene definitions
10. `mineFieldSceneDatas.lua` - Mine field scene definitions

**Rationale**: Each module depends on globals initialized by previous ones. The namespace `ctld = ctld or {}` is pre-created by first module.

### Core Modules

| Module | Purpose | Key Globals |
|--------|---------|------------|
| [CTLD.lua](source/CTLD.lua) | Configuration & primary event hooks | `ctld.Version`, `ctld.i18n_lang`, `ctld.Debug`, `ctld.dontInitialize` |
| [CTLD_scene.lua](source/CTLD_scene.lua) | Step-by-step animation/spawn sequencer | `ctld.scene` class: `.playscene()`, `.registerSceneModel()` |
| [CTLD_extAPI.lua](source/CTLD_extAPI.lua) | Adapter for MIST/MOOSE framework functions | Wrappers: `dynAdd`, `dynAddStatic`, `getAvgPos` |
| [dcsObjectsDescDb.lua](source/dcsObjectsDescDb.lua) | Database of DCS object spawn templates | `ctld.objectsDescDb[key]` tables with `.desc()` factories |
| [CTLD_utils.lua](source/CTLD_utils.lua) | Coordinate transforms, heading calculations | `ctld.utils.getRelativeCoords()`, `drawQuad()` |
| [CTLD-i18n.lua](source/CTLD-i18n.lua) | Language strings (EN ref; FR/ES/KO translations) | `ctld.i18n[lang][key] = "translated string"` |

### Data Flow Example: FARP Deployment
1. Mission triggers `ctld.scene.playscene(heliUnit, ctld.farpScene)` ([farpSceneDatas.lua](source/farpSceneDatas.lua#L180))
2. Scene sequencer iterates `stepsDatas` array, each step defines:
   - `polar` = relative position (distance, angle from heli)
   - `objectsDescDbKey` = lookup in `ctld.objectsDescDb` for spawn template
   - `func` = custom Lua callback (e.g., configure warehouse after spawn)
3. Utils convert polar coords + heli heading → absolute world coords
4. `CTLD_extAPI.dynAdd()` spawns object via MIST framework
5. Step's `func` callback executes (e.g., add fuel/ammo to FARP warehouse)

## Key Conventions

### Naming & Structure
- **Namespace**: All globals under `ctld.*` (never pollute global scope)
- **Classes**: Lua tables with metatable; e.g., `ctld.scene` has `scene.__index = scene`
- **Factories**: `desc()` functions return DCS-compatible group data tables
- **Locale Keys**: English reference in `CTLD.lua` (lines 85-130); translations mirror structure in `CTLD-i18n.lua`

### Coordinate System (Critical)
- **DCS uses**:  X = North, Z = East, Y = Altitude (3D), or vec2 = {x, y}
- **Angles**: Clockwise from North in radians (0 rad = North, π/2 = East)
- **Functions**: `getRelativeCoords()` ([CTLD_utils.lua#L77](source/CTLD_utils.lua#L77)) computes polar→absolute; always accounts for magnetic declination
- **Headings**: Functions accept radians; use `math.rad(degrees)` / `math.deg(radians)` for conversions

### i18n Pattern
```lua
-- In CTLD.lua (reference):
ctld.i18n["en"]["Standard Group"] = ""

-- In CTLD-i18n.lua (translation):
ctld.i18n["fr"]["Standard Group"] = "Groupe standard"

-- At runtime:
ctld.i18n_lang = "fr"  -- User selects language
local text = ctld.i18n[ctld.i18n_lang]["Standard Group"] or ctld.i18n["en"]["Standard Group"]
```

### Object Spawn Pattern
All spawnable objects defined as descriptor tables:
```lua
ctld.objectsDescDb["SINGLE_HELIPAD"] = {
    desc = function(coalitionId, countryId, x, y, headingInRadians, altitudeInMeters)
        return { groupType = "STATIC", type = "SINGLE_HELIPAD", ... }
    end
}
-- Usage: local groupData = ctld.objectsDescDb["SINGLE_HELIPAD"].desc(1, 2, 500, 600, 0, 100)
```

## Integration Points

### External Framework (MIST/MOOSE)
- Abstracted via [CTLD_extAPI.lua](source/CTLD_extAPI.lua)—wrappers check framework existence
- Key functions wrapped: `dynAdd()`, `dynAddStatic()`, `getAvgPos()`
- **Do not call MIST directly**; use `CTLD_extAPI` wrappers instead

### DCS Trigger/Event API
- `trigger.action.outText()` — display messages to players
- `Unit.getByName()`, `Group.getByName()` — retrieve mission objects
- `Airbase.getByName()`, `Airbase.getWarehouse()` — access FARP logistics
- Full API documented in DCS Scripting Engine docs; rarely change here

## Testing & Debugging

### Debug Logging
- Set `ctld.Debug = true` or `ctld.Trace = true` in [CTLD.lua](source/CTLD.lua#L47-L48)
- Logs written to `dcs.log` prefixed with `CTLD - `
- Use `env.info(ctld.Id .. "message")` for consistent formatting

### Mission Test Files
- `test-mission.miz` — baseline test mission
- `test-dev-static.miz`, `test-dev-dynamic.miz` — development variants
- `demo-mission.miz` — feature showcase

## Modularisation Notes (feature_modularisation branch)
- **Goal**: Split monolithic [CTLD.lua](source/CTLD.lua) (8919 lines) into feature modules
- **Strategy**: Extract logical subsystems (troop loading, vehicle transport, JTAC) while preserving load order
- **Constraint**: Maintain backward compatibility with existing mission editor scripts
- **Test Coverage**: Run against test-mission.miz variants after refactoring

## Common Tasks

### Adding a New Deployable Unit
1. Add name/translation to [CTLD.lua](source/CTLD.lua#L103-L130) + [CTLD-i18n.lua](source/CTLD-i18n.lua#L39-L45)
2. Create descriptor in [dcsObjectsDescDb.lua](source/dcsObjectsDescDb.lua):
   ```lua
   ctld.objectsDescDb["MyUnit"] = {
       desc = function(coalitionId, countryId, x, y, heading, altitude)
           return { groupType = "STATIC", type = "MyUnit", ... }
       end
   }
   ```
3. Add to deployment list in scene data file (e.g., [farpSceneDatas.lua](source/farpSceneDatas.lua))

### Adding a Scene (Animated Sequence)
1. Define data table (e.g., `local myScene = { name = "My Scene", stepsDatas = { ... } }`)
2. Each step: `polar`, `delayAfterPreviousStep`, `relativeHeadingInDegrees`, `objectsDescDbKey`, optional `func`
3. Register: `ctld.scene.registerSceneModel(myScene)`
4. Access: `ctld.scene.playscene(triggerUnit, myScene)`

### Modifying Translations
1. Find string key in [CTLD.lua](source/CTLD.lua) `ctld.i18n["en"][key]`
2. Add/update translation in [CTLD-i18n.lua](source/CTLD-i18n.lua) under correct language block
3. Match `translation_version` compatibility string
