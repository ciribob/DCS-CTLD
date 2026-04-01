# DCS-CTLD Modernization Plan

> Status: **Draft**
> Branch: `next` (git flow, `main` stays stable)
> Target: CTLD v2.0

---

## Vision

Rewrite CTLD as a modern, modular, and testable Lua project while
temporarily preserving backward compatibility with existing missions.
The deliverable remains a single `.lua` file produced by an automated build.

---

## Architectural decisions

Key decisions made during the planning phase, for reference.

| # | Topic | Decision |
| - | ----- | -------- |
| 1 | Module split | Separate source files in `src/`, concatenated into a single `dist/CTLD.lua` by a build script (CI) |
| 2 | OOP level | Full OOP Lua 5.1 with metatables and classes — ready to break backward compat when needed |
| 3 | MIST dependency | Middleware layer (`src/mist_compat/`): CTLD never calls `mist.*` directly. Long-term goal: eliminate MIST entirely |
| 4 | API breaking changes | Short/medium term: legacy wrappers with deprecation warnings. Long term (v3): legacy API removed |
| 5 | Lua environment | Lua 5.1 DCS sandbox, desanitized server assumed (`io`, `os`, `lfs` accessible) |
| 6 | Testing | Both: busted + DCS/MIST mocks in CI, and in-game test missions for integration |
| 7 | Documentation | 3 audiences (player, mission maker, developer). Markdown in `docs/`, auto-published to GitHub Pages via MkDocs |
| 8 | i18n | Included in plan: audit missing keys, CI lint for version drift, cleanup empty translations |
| 9 | Priorities | 1-Cleanup, 2-OOP, 3-MIST middleware, 4-Legacy compat, 5-Tests, 6-CI, 7-i18n, 8-Docs |
| 10 | Branching | `next` branch for v2, git flow. `main` stays stable. Feature branches: `feature/<phase>-<description>` |

---

## Guiding principles

- **OOP Lua 5.1**: metatables, classes, state encapsulation.
- **Separate modules** in development, single file in delivery.
- **Zero direct MIST dependency**: all MIST usage goes through a middleware layer.
- **Automated testing**: pure logic tested outside DCS, integration tested in-game.
- **Auto-generated documentation**: from the repo to GitHub Pages.
- **Transitional legacy compatibility**: deprecated wrappers with warnings, removed in v3.

---

## Phases

### Phase 1 — Dead code cleanup

**Goal**: Start from a clean, noise-free baseline.

| Task | Detail |
| ---- | ------ |
| 1.1 | Remove the 18+ identified commented-out code blocks |
| 1.2 | Remove unused functions (`ctld.tools.getRelativeBearing`, etc.) |
| 1.3 | Remove state variables that are never read |
| 1.4 | Clean up obsolete `--TODO`/`--FIXME` markers |
| 1.5 | Validate with existing test missions that nothing breaks |

**Deliverable**: A lighter CTLD.lua, functionally identical.

---

### Phase 2 — Module split + OOP

**Goal**: Transform the procedural monolith into a modular, object-oriented architecture.

#### 2.1 — Lua 5.1 class system

Define a micro class framework based on metatables:

```lua
-- src/lib/class.lua
local function class(base)
    local cls = {}
    cls.__index = cls
    if base then setmetatable(cls, { __index = base }) end
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then instance:init(...) end
        return instance
    end
    return cls
end
```

#### 2.2 — Module layout

Target structure for the `src/` directory:

```text
src/
├── lib/
│   ├── class.lua              -- OOP micro-framework
│   ├── utils.lua              -- Utilities (deepCopy, formatText, logging)
│   └── vec.lua                -- Vector math (2D/3D distance, bearing)
├── core/
│   ├── config.lua             -- User configuration (USER CONFIGURATION)
│   ├── state.lua              -- State manager (replaces 34 global tables)
│   ├── coalition.lua          -- Coalition class (eliminates RED/BLUE duplication)
│   ├── i18n.lua               -- i18n system
│   └── events.lua             -- Event handler + callback system
├── transport/
│   ├── transport.lua          -- Transport class (heli/plane)
│   ├── troops.lua             -- Troop management (load/unload/extract)
│   └── vehicles.lua           -- Vehicle management
├── logistics/
│   ├── crate.lua              -- Crate class
│   ├── crate_manager.lua      -- Spawning, hover, sling load, unpack
│   ├── fob.lua                -- FOB construction and management
│   └── beacon.lua             -- Radio beacons
├── jtac/
│   ├── jtac_controller.lua    -- JTACController class
│   ├── targeting.lua          -- Target acquisition, LOS, priorities
│   ├── lasing.lua             -- Laser/IR point, spot corrections
│   └── menu.lua               -- F10 JTAC menus
├── ui/
│   ├── f10_menu.lua           -- F10 menu construction
│   ├── messages.lua           -- Player messages (displayMessageToGroup)
│   └── smoke.lua              -- Smoke markers
├── recon/
│   └── recon.lua              -- Target recognition on F10 map
├── ai/
│   └── ai_transport.lua       -- AI auto-load/unload logic
├── compat/
│   └── legacy_api.lua         -- Deprecated ctld.* wrappers
├── mist_compat/
│   └── mist_middleware.lua    -- MIST middleware (see Phase 3)
└── ctld.lua                   -- Entry point, initialization, orchestration
```

#### 2.3 — Core classes

| Class | Responsibility | Replaces |
| ----- | -------------- | -------- |
| `Coalition` | Encapsulates side (1/2) and per-coalition state | `ctld.spawnedCratesRED/BLUE`, `ctld.droppedTroopsRED/BLUE`, etc. (34 tables → 2 instances) |
| `Transport` | State of a transport helicopter/plane | `ctld.inTransitTroops[name]`, `ctld.hoverStatus[name]` |
| `Crate` | Represents a logistics crate | Entries from `ctld.spawnableCrates`, `ctld.crateLookupTable` |
| `CrateManager` | Spawn, pickup, drop, unpack crates | `ctld.spawnCrate`, `ctld.unpackCrates`, `ctld.checkHoverStatus` |
| `FOB` | A built Forward Operating Base | `ctld.builtFOBS[name]` |
| `JTACController` | An active JTAC with its lasing state | `ctld.jtacUnits`, `ctld.jtacCurrentTargets`, `ctld.jtacSelectedTarget` |
| `Beacon` | A deployed radio beacon | `ctld.deployedRadioBeacons[name]` |
| `StateManager` | Central registry of all active objects | Replaces 34 global tables |
| `Config` | Typed user configuration | Current USER CONFIGURATION section |

#### 2.4 — Eliminating RED/BLUE duplication

Before (50+ branches):

```lua
if _heli:getCoalition() == 1 then
    _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
else
    _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
end
```

After:

```lua
local side = stateManager:getCoalition(heli:getCoalition())
local extract = side:findNearestDroppedTroop(heli)
```

---

### Phase 3 — MIST middleware

**Goal**: Isolate MIST behind a facade. CTLD never references `mist.*` directly.

| Task | Detail |
| ---- | ------ |
| 3.1 | Inventory the 91 MIST calls and categorize them (trivial / medium / complex) |
| 3.2 | Create `src/mist_compat/mist_middleware.lua` exposing a clean API |
| 3.3 | Rewrite trivial functions: `deepCopy`, `get2DDist`, `round`, `makeVec2/3` |
| 3.4 | Wrap medium functions: `getHeading`, `vec.*`, `tostringLL/MGRS` |
| 3.5 | Delegate complex functions to MIST: `dynAdd`, `dynAddStatic`, `getUnitsLOS` |
| 3.6 | Replace all `mist.*` calls in modules with middleware calls |
| 3.7 | (Long term) Rewrite complex functions to eliminate MIST entirely |

**Deliverable**: CTLD works with or without MIST (graceful degradation when MIST is absent, eventually).

---

### Phase 4 — Legacy API compatibility layer

**Goal**: Existing missions continue to work without modification.

| Task | Detail |
| ---- | ------ |
| 4.1 | List all public `ctld.*` functions documented in the README |
| 4.2 | Create `src/compat/legacy_api.lua` with wrappers that call the new API |
| 4.3 | Each wrapper logs a deprecated warning with the new API name |
| 4.4 | Document old → new migration in `docs/migration-v2.md` |
| 4.5 | Announce the policy: legacy maintained in v2, removed in v3 |

Example:

```lua
-- legacy_api.lua
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    ctld.logWarning("DEPRECATED: ctld.spawnCrateAtZone() -> use CrateManager:spawnAtZone()")
    local side = (_side == "red") and 1 or 2
    return ctld.crateManager:spawnAtZone(side, _weight, _zone)
end
```

---

### Phase 5 — Unit tests

**Goal**: Coverage of pure logic outside DCS + in-game smoke tests.

#### 5.1 — Framework and mocks

| Task | Detail |
| ---- | ------ |
| 5.1.1 | Set up busted (Lua 5.1) + luarocks in the repo |
| 5.1.2 | Create `test/mocks/dcs_env.lua`: stubs for `trigger`, `Unit`, `Group`, `coalition`, `land`, `timer`, `missionCommands`, `coord`, `world`, `env` |
| 5.1.3 | Create `test/mocks/mist_env.lua`: stubs for MIST functions used |
| 5.1.4 | Configure busted to load mocks before tests |

#### 5.2 — Unit tests (outside DCS)

| Module | Priority tests |
| ------ | -------------- |
| `lib/class.lua` | Inheritance, instantiation, override |
| `lib/vec.lua` | 2D/3D distance, bearing, clock direction |
| `lib/utils.lua` | deepCopy, formatText |
| `core/coalition.lua` | Per-coalition state management, lookup |
| `core/i18n.lua` | Translation, fallback, parameters |
| `core/config.lua` | Default values, override |
| `logistics/crate.lua` | Weight uniqueness, lookup |
| `compat/legacy_api.lua` | Wrappers call the correct new API |

#### 5.3 — In-game tests

| Task | Detail |
| ---- | ------ |
| 5.3.1 | Create an automated test mission (DO SCRIPT running a test suite) |
| 5.3.2 | Write results to a file via `io.open` (desanitized server) |
| 5.3.3 | Validate: troop load/unload, crate spawn/unpack, JTAC lasing, FOB build, beacons |

---

### Phase 6 — CI infrastructure

**Goal**: Automate build, tests, and release.

| Task | Detail |
| ---- | ------ |
| 6.1 | **Build script**: Lua (or Python/Bash) script that concatenates `src/**/*.lua` → `dist/CTLD.lua` in the correct order |
| 6.2 | **GitHub Actions — Tests**: install Lua 5.1 + luarocks + busted, run `busted test/` |
| 6.3 | **GitHub Actions — Build**: generate `dist/CTLD.lua` and `dist/CTLD-i18n.lua` |
| 6.4 | **GitHub Actions — Release**: on tag, publish the `.lua` artifact as a GitHub release |
| 6.5 | **GitHub Actions — Docs**: MkDocs build + deploy to GitHub Pages |
| 6.6 | **i18n lint**: CI script comparing keys across languages and checking `translation_version` |

---

### Phase 7 — i18n cleanup + tooling

**Goal**: Reliable i18n with automatic drift detection.

| Task | Detail |
| ---- | ------ |
| 7.1 | Full audit: list EN vs FR vs ES vs KO keys, identify missing ones |
| 7.2 | Fill empty FR keys (crate/equipment names) |
| 7.3 | Update KO (1.1 → 1.6+) or mark it as `incomplete` |
| 7.4 | CI lint script for i18n (see 6.6) |
| 7.5 | Document the process of adding a language in `docs/contributing/i18n.md` |
| 7.6 | Consider extracting i18n into per-language files (`i18n/fr.lua`, `i18n/ko.lua`) |

---

### Phase 8 — Documentation

**Goal**: 3 guides for 3 audiences, auto-published.

#### 8.1 — `docs/` structure

```text
docs/
├── index.md                    -- Landing page
├── user-guide/
│   ├── getting-started.md      -- For the player: F10 menus, in-game workflow
│   ├── troops.md               -- Troop loading/unloading
│   ├── crates.md               -- Crate system
│   ├── jtac.md                 -- Using JTACs
│   ├── fob.md                  -- FOB construction
│   └── beacons.md              -- Radio beacons
├── mission-maker/
│   ├── setup.md                -- Mission installation
│   ├── configuration.md        -- All configurable options
│   ├── api-reference.md        -- Public API (DO SCRIPT)
│   ├── zones.md                -- Pickup/dropoff/waypoint zones
│   ├── jtac-setup.md           -- Advanced JTAC configuration
│   └── examples.md             -- Mission examples
├── developer/
│   ├── architecture.md         -- Module, class, and flow diagrams
│   ├── contributing.md         -- How to contribute
│   ├── building.md             -- Build script, CI
│   ├── testing.md              -- Running tests
│   ├── i18n.md                 -- Adding/maintaining a translation
│   └── migration-v2.md         -- v1 → v2 migration guide
└── mkdocs.yml                  -- MkDocs configuration
```

#### 8.2 — Publishing

- MkDocs Material theme
- GitHub Actions: build + deploy to `gh-pages` on every push to `next`
- Slimmed-down README.md: links to the full documentation site

---

## Indicative timeline

| Phase | Dependencies | Complexity |
| ----- | ------------ | ---------- |
| 1 — Dead code cleanup | None | Low |
| 2 — Modules + OOP | Phase 1 | **High** |
| 3 — MIST middleware | Phase 2 | Medium |
| 4 — Legacy compat | Phase 2 | Medium |
| 5 — Tests | Phases 2-3 | Medium |
| 6 — CI | Phases 2, 5 | Medium |
| 7 — i18n | Phase 2 | Low |
| 8 — Documentation | Phases 2-4 | Medium |

> Phases 3 and 4 can be worked on in parallel.
> Phase 6 can start as early as Phase 2 (build script) and grow incrementally.

---

## Branching strategy

```text
main (stable, v1.x)
  └── next (v2 development)
        ├── feature/phase1-cleanup
        ├── feature/phase2-oop-core
        ├── feature/phase2-oop-jtac
        ├── feature/phase3-mist-middleware
        ├── feature/phase4-legacy-compat
        ├── feature/phase5-tests
        └── ...
```

- `main`: stable v1.x releases, urgent hotfixes only.
- `next`: v2 integration, git flow (feature → next → release).
- Tags: `v2.0-alpha.1`, `v2.0-beta.1`, `v2.0-rc.1`, `v2.0`.

---

## Risks and mitigations

| Risk | Impact | Mitigation |
| ---- | ------ | ---------- |
| Gameplay regressions after OOP refactoring | High | Unit tests + systematic test missions |
| DCS mock divergence from real API | Medium | In-game tests as complement, versioned mocks |
| Incomplete MIST middleware | Medium | Progressive approach, MIST remains as fallback |
| Mission maker resistance to API changes | Medium | Legacy layer + communication + migration guide |
| Build script complexity (module ordering) | Low | Explicit dependencies, build tested in CI |
