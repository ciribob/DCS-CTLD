# DCS-CTLD — As-Is Analysis

> This document captures the current state of the CTLD codebase prior to
> the v2 modernization effort. It serves as a reference and justification
> for the changes outlined in `MODERNIZATION-PLAN.md`.

---

## 1. Overview

| Metric | Value |
| ------ | ----- |
| Primary script | `CTLD.lua` |
| Lines of code | ~8 700 |
| i18n script | `CTLD-i18n.lua` |
| Bundled dependency | `mist.lua` (MIST 4.5 build 128-DYNSLOTS-02) |
| Lua version | 5.1 (DCS sandbox) |
| Public functions (`ctld.*`) | 100+ |
| Local / private functions | 0 (everything is public on the `ctld` table) |
| OOP / metatables usage | None — fully procedural |
| Unit tests | None |

---

## 2. File structure

```text
.
├── CTLD.lua                  -- Main script (monolith)
├── CTLD-i18n.lua             -- Translation tables (FR, ES, KO)
├── mist.lua                  -- MIST library (stock, not customized)
├── beacon.ogg                -- Radio beacon sound
├── beaconsilent.ogg          -- Silent beacon sound (FC3)
├── README.md                 -- User / mission-maker guide
├── demo-mission.miz
├── test-mission.miz
├── test-dev-dynamic.miz
├── test-dev-static.miz
├── test_witchcraft_#131.miz
└── test_witchcraft_#137 et #149.miz
```

No `src/`, no `test/`, no `docs/`, no CI configuration.

---

## 3. CTLD.lua section breakdown

| Section | Lines | Content |
| ------- | ----- | ------- |
| Header + contributors | 1–35 | Credits, links |
| i18n table setup | 36–360 | English reference keys (all `= ""`), `i18n_translate()` |
| USER CONFIGURATION | 403–600 | 50+ tunable parameters |
| Crate configuration | 601–1 200 | `ctld.spawnableCrates`, AA system templates |
| Public API functions | 1 200–1 950 | Functions usable from DO SCRIPT triggers |
| Core gameplay logic | 1 950–4 600 | Troops, vehicles, crates, FOBs, beacons |
| JTAC subsystem | 4 600–7 000 | Targeting, lasing, IR points, F10 menus |
| AI processing + menus | 7 000–8 200 | AI auto-load/unload, F10 menu building |
| `ctld.initialize()` | 8 190–8 400 | State tables init, zone parsing |
| Event handler + tools | 8 400–8 705 | DCS event handler, `ctld.tools` utilities |

---

## 4. State management

34 global tables inside the `ctld` namespace track runtime state.
Most are duplicated per coalition.

### 4.1 — Coalition-duplicated tables (RED / BLUE pairs)

| Table pair | Content |
| ---------- | ------- |
| `ctld.spawnedCratesRED` / `BLUE` | Spawned crate statics |
| `ctld.droppedTroopsRED` / `BLUE` | Deployed infantry groups |
| `ctld.droppedVehiclesRED` / `BLUE` | Deployed vehicles |
| `ctld.droppedFOBCratesRED` / `BLUE` | FOB crates on ground |

This duplication creates **50+ `if coalition == 1 then … RED … else … BLUE`** branches.

### 4.2 — Shared tables

| Table | Content |
| ----- | ------- |
| `ctld.inTransitTroops` | Cargo currently onboard (keyed by unit name) |
| `ctld.inTransitSlingLoadCrates` | Simulated sling-load crates |
| `ctld.builtFOBS` | Completed FOB positions |
| `ctld.completeAASystems` | Assembled AA system groups |
| `ctld.deployedRadioBeacons` | Active beacons |
| `ctld.fobBeacons` | FOB beacon cache (refreshed every 60 s) |
| `ctld.extractZones` | Extract zone definitions |
| `ctld.hoverStatus` | Hover-over-crate tracking |
| `ctld.crateLookupTable` | Crate weight → type lookup |
| `ctld.callbacks` | Registered callback functions |
| `ctld.jtacUnits` | JTAC unit references |
| `ctld.jtacCurrentTargets` | JTAC active targets |
| `ctld.jtacSelectedTarget` | Player-selected JTAC targets |
| `ctld.jtacGeneratedLaserCodes` | Allocated laser codes |
| `ctld.usedUHFFrequencies` / `VHF` / `FM` | Radio frequency pools |

---

## 5. Code duplication patterns

### 5.1 — RED/BLUE branching (most pervasive)

```lua
-- This pattern appears 50+ times
if _heli:getCoalition() == 1 then
    _list = ctld.droppedTroopsRED
else
    _list = ctld.droppedTroopsBLUE
end
```

### 5.2 — Troop / Vehicle symmetry

Many functions have near-identical troop and vehicle variants differentiated
only by a boolean parameter (`true` = troops, `false` = vehicles).

### 5.3 — Sling load vs simulated load

Two code paths for crate pickup depending on `ctld.slingLoad`:

- Real sling load (DCS native, crashy)
- Simulated hover load (custom implementation)

### 5.4 — Zone handling

Pickup zones, dropoff zones, and waypoint zones share similar parsing
(smoke color, coalition check, active flag) but are implemented separately.

---

## 6. MIST dependency

91 calls to `mist.*` functions across the codebase.

| Category | Functions | Call count |
| -------- | --------- | ---------- |
| Utility | `deepCopy`, `round`, `makeVec2/3` | ~28 |
| Distance / vectors | `get2DDist`, `vec.mag`, `vec.dp`, `vec.sub` | ~15 |
| Heading / bearing | `getHeading` | ~8 |
| Coordinate format | `tostringLL`, `tostringMGRS` | ~4 |
| Spawning | `dynAdd`, `dynAddStatic` | ~8 |
| Route / waypoints | `buildWP`, `getGroupRoute` | ~4 |
| LOS / search | `getUnitsLOS`, `getAvgPos`, `makeUnitTable` | ~4 |
| Database | `mist.DBs.unitsByName` | iterated |
| Scheduling | `mist.scheduleFunction` | ~1 |
| Other | misc | ~19 |

No functions provide a fallback if MIST is absent — CTLD hard-crashes on
`assert(mist ~= nil)` during initialization.

---

## 7. Scheduling and timers

20+ `timer.scheduleFunction` calls drive recurring behavior.
All timers reschedule themselves recursively; there are no continuous
polling loops.

| Timer | Interval | Purpose |
| ----- | -------- | ------- |
| `checkTransportStatus` | 3 s | Monitor transport helicopters |
| `checkHoverStatus` | 1 s | Track hover-over-crate countdown |
| `refreshRadioBeacons` | 60 s | Update beacon battery status |
| `refreshSmoke` | 300 s | Refresh smoke markers |
| `checkAIStatus` | 2 s | AI troop behavior check |
| `timerJTACAutoLase` | variable | JTAC targeting loop |
| `timerLaseUnit` | variable | Single-unit lasing |
| `autoUpdateRepackMenu` | 1 s | Refresh vehicle repacking F10 menu |
| `reconRefreshTargetsInLosOnF10Map` | variable | RECON map markers |

---

## 8. Error handling

- **pcall usage**: 12 instances, mainly around crate spawning and hover math.
- **Nil checks**: Extensive `if X == nil then return end` before DCS API calls.
- **No structured error propagation**: errors are logged via `env.error()` /
  `ctld.logError()` and silently swallowed.
- **No stack traces** or exception chaining.

---

## 9. Internationalization (i18n)

| Language | Code | `translation_version` | Completeness |
| -------- | ---- | --------------------- | ------------ |
| English | `en` | 1.6 | Reference (keys only, values = `""`) |
| French | `fr` | 1.6 | Partial — many crate/equipment names empty |
| Spanish | `es` | 1.6 | Similar to French |
| Korean | `ko` | **1.1** | Severely outdated, many missing keys |

Issues:

- No tooling to detect missing keys or version drift.
- Empty string (`""`) is a valid Lua value, so missing translations silently
  fall back to the English key (which is also `""` for reference entries).
- All translations live in a single `CTLD-i18n.lua` file — no per-language
  separation.

---

## 10. Documentation

| Audience | Coverage | Location |
| -------- | -------- | -------- |
| Mission maker | Partial | `README.md` (setup, config, API examples) |
| Player | Minimal | `README.md` (gameplay mechanics mentioned briefly) |
| Developer | None | No architecture doc, no contributing guide |

README strengths:

- Good coverage of pickup/dropoff zone configuration.
- Code examples for DO SCRIPT functions.
- Dynamic loading workflow documented.

README gaps:

- JTAC advanced features poorly explained.
- No API reference table (signatures, parameters, return values).
- No architecture or data flow diagrams.
- Some examples use different defaults than the current code.

---

## 11. Testing

- **No automated tests** of any kind.
- **Manual smoke testing** via `.miz` missions in the repository:
  - `test-mission.miz` — full feature demonstration
  - `test-dev-dynamic.miz` — dynamic script loading for fast iteration
  - `test-dev-static.miz` — static loading variant
  - `test_witchcraft_#131.miz`, `test_witchcraft_#137 et #149.miz` — bug repro missions
- No test framework, no mocks, no CI.

---

## 12. Dead code and technical debt

| Item | Location | Detail |
| ---- | -------- | ------ |
| Commented-out blocks | 18+ blocks across file | Old implementations, debug markers, disabled alternatives |
| Unused function | `ctld.tools.getRelativeBearing` | Defined but never called |
| Unused function | `ctld.tools.isValueInIpairTable` | Called once, could be inlined |
| Commented event handler | `ctld.initialize()` | Old `ctld.eventHandler` pattern, replaced but not removed |
| Disabled vehicle types | Crate config tables | Many entries commented out (`-- BUK`, `-- Strela`, etc.) |
| Debug markers | Various | `--ctld.logTrace("FG_ XXXX...")` left in code |
| Alternate coordinate | `ctld.listFOBS()` | MGRS conversion commented out |

---

## 13. Summary of pain points

1. **Monolithic file**: 8 700 lines, impossible to navigate or review efficiently.
2. **No encapsulation**: 100+ public functions, 0 local functions, all state is global.
3. **RED/BLUE duplication**: 50+ coalition branches + paired tables.
4. **MIST hard dependency**: 91 calls, no fallback, no abstraction layer.
5. **No tests**: zero automated tests, zero mocks, zero CI.
6. **No OOP**: purely procedural, no classes, no metatables.
7. **Dead code**: 18+ commented blocks, unused functions.
8. **i18n drift**: Korean 3 versions behind, many empty translations.
9. **No developer documentation**: new contributors must read 8 700 lines to understand the architecture.
10. **No build system**: the source file IS the deliverable.
