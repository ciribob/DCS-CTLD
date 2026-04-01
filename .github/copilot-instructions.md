# Copilot Instructions for DCS-CTLD

## Working mode / Mode de travail

- **Communication language**: French (français) for all conversations and commit messages.
- **Documentation language**: English for all technical documentation (code comments, docs/, README). French summaries in docs are acceptable but English is the primary language.
- **Development methodology**: TDD (Test-Driven Development) — write tests before implementation when possible.
- **Programming paradigm**: OOP Lua 5.1 with metatables and classes. No procedural spaghetti.
- **Branching strategy**: Git flow on the `next` branch. Feature branches named `feature/<phase>-<description>`. Never commit directly to `main` or `next`.
- **Commit style**: Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
- **Build target**: Individual source modules in `src/` are concatenated into a single `dist/CTLD.lua` deliverable by a build script. Never edit the built file directly.
- **MIST dependency**: CTLD code must never call `mist.*` directly. All MIST usage goes through the middleware layer (`src/mist_compat/`).
- **Legacy API**: When refactoring a public `ctld.*` function, always create a deprecated wrapper in `src/compat/legacy_api.lua` that logs a warning and delegates to the new API.
- **Refer to the modernization plan**: See `.github/MODERNIZATION-PLAN.md` for the full roadmap and architectural decisions.

## Project context
- This repository contains Lua mission scripts for DCS World.
- The primary script is CTLD.lua.
- Internationalization tables are split between CTLD.lua (English reference keys) and CTLD-i18n.lua (translated values).
- Runtime is DCS mission scripting environment (Lua 5.1, metatables available, no LuaJIT, no goto).
- Assumes desanitized server (io, os, lfs accessible).
- MIST is being progressively replaced by an internal middleware layer.

## Architecture (v2 target)

- Source modules live in `src/` organized by domain: `lib/`, `core/`, `transport/`, `logistics/`, `jtac/`, `ui/`, `recon/`, `ai/`, `compat/`, `mist_compat/`.
- OOP via a micro class system using metatables (`src/lib/class.lua`).
- State is managed by a `StateManager` singleton and per-coalition `Coalition` instances — no more `ctld.xxxRED`/`ctld.xxxBLUE` table pairs.
- Tests live in `test/` and use busted with DCS/MIST mocks.

## Compatibility (v1 legacy)
- Preserve existing public ctld.* APIs used by Mission Editor DO SCRIPT triggers.
- Do not rename exported ctld functions or change their parameter semantics unless explicitly requested.
- Keep behavior compatible with existing .miz missions in this repository.
- Keep script load order assumptions intact: MIST first, CTLD-i18n.lua before CTLD.lua.

## CTLD.lua editing rules
- Keep user-tunable options in the USER CONFIGURATION section with clear comments and safe defaults.
- Keep coalition conventions consistent:
  - 1 = red
  - 2 = blue
  - 0 = both (where applicable)
- Keep pickup/dropoff/waypoint zone tuple formats compatible with current parser logic.
- Keep crate weight values unique in ctld.spawnableCrates.
- Preserve callback behavior and action names used by ctld.processCallback.
- Use defensive nil checks before calling methods on DCS objects (Unit/Group/zone lookups).
- Prefer existing logging patterns (ctld.logInfo, env.info, env.error) over ad-hoc prints.
- Avoid adding heavy polling loops; prefer bounded searches and scheduled checks.

## I18N rules
- For every new player-visible string, add an English reference key and use ctld.i18n_translate at call sites.
- Do not hardcode new menu or gameplay text without i18n_translate.
- When adding keys, keep translation_version alignment in mind and add placeholders in CTLD-i18n.lua tables.
- Do not remove or rename existing i18n keys unless all language tables are updated.

## Testing expectations
- Prefer the dynamic loading workflow documented in README for fast iteration.
- After gameplay logic changes, validate at least:
  - troop load/unload flows
  - crate spawn/load/unpack flows
  - JTAC-related flows (if touched)
- Use repository missions for smoke tests when relevant:
  - test-dev-dynamic.miz
  - test-dev-static.miz
  - test-mission.miz
- If user-facing behavior or configuration changes, update README examples in the same change.

## Code style conventions

- Follow existing file style and indentation.
- OOP Lua 5.1: use the project class system (`src/lib/class.lua`) for new classes.
- For internal helpers, follow existing naming patterns (local variables often prefixed with _).
- Keep mission-designer guidance comments concise and practical.
- No direct `mist.*` calls — use the middleware.
- Every new public function should have at least one unit test.
