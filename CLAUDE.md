# CLAUDE.md

Notes for AI assistants working in `u-struct`.

## Golden rule: maintenance mode — no new features, no breaking changes

`u-struct` was created as an alternative to Ruby's native `Data`, which now
ships with Ruby (3.2+). The gem is therefore considered unnecessary going
forward and is kept **only to support existing applications**. There are **no
plans to add new features** — new code should prefer native `Data`.

The public API is **frozen**: every change must keep existing code working.
Major version bumps are reserved for dependency-floor changes (dropping a Ruby
or Rails version from the supported matrix) per SemVer — they do **not** signal
a behavior break.

So scope work to bug/compatibility fixes and supported-matrix upkeep. If a task
as stated would add a feature or require a breaking change, stop and surface
that — suggest native `Data` for new capabilities, or propose a backward-
compatible path. Don't ship the break or the feature creep.

## How to work in this repo

### 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes,
simplify.

### 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that _your_ changes orphaned. Don't
  remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

### 4. Goal-driven execution

**Define success criteria. Loop until verified.**

Turn vague tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step work, state a brief plan with a verification check per step.

---

## What this is

`u-struct` is a zero-runtime-dependency Ruby gem for building "powered" Structs.
The public surface lives under `lib/micro/struct/` and is exposed through
`Micro::Struct`:

- `Micro::Struct.new(...)` — like `Struct`, but members are **required** by
  default; `optional:` / `required:` tune that, and a block adds custom methods.
- `Micro::Struct.with(*features)` — opt into behaviors before `.new`:
  `:to_ary`, `:to_hash`, `:to_proc`, `:readonly`, `:instance_copy`,
  `:exposed_features`.
- `Micro::Struct[...]` and `Micro::Struct.instance` — shorthand builders.

Internals: `factory/` (`create_struct`, `members`) assembles the Struct,
`features.rb` implements the opt-in behaviors, `normalize_names.rb` handles
member-name coercion. The umbrella `require 'u-struct'` loads everything;
`Micro::Struct::VERSION` lives in `lib/micro/struct/version.rb`.

The gem has **no ActiveModel/ActiveRecord dependency** and touches no Rails
code. The ActiveModel appraisals (see below) exist only to guarantee `u-struct`
loads and behaves correctly inside Rails apps across the supported range — they
are a compatibility smoke test, not coverage of Rails-specific behavior.

## Running tests

```bash
bundle exec rake test                  # default suite, current bundle (no activemodel)
bundle exec appraisal <name> rake test # one ActiveModel appraisal (see Appraisals)
bundle exec rake matrix                # baseline + every ActiveModel appraisal for the active Ruby
```

`bin/setup` reinstalls and refreshes appraisals; `bin/matrix` reinstalls then
runs `rake matrix`. CI runs the matrix across the full Ruby × ActiveModel grid
(Ruby 2.7 → head, ActiveModel 6.0 → 8.1 + edge), and additionally runs
**RuboCop** and **Sorbet** (`srb tc`) on Ruby 3.1 — keep both green:

```bash
bundle exec rubocop                    # Ruby 3.1 toolchain (pinned in the Gemfile)
bundle exec srb tc                     # type-check; sources are `# typed:`-annotated
```

Tests are the success criterion for any behavior change — write or update a
test first, then make it pass (rule 4).

## CHANGELOG and README are part of every change

Both files are user-facing — keep them in sync with the code:

- **`CHANGELOG.md`**: follows [Keep a Changelog](https://keepachangelog.com/).
  Every user-visible change (new API, behavior change, breaking change, dep
  bump that shifts the supported matrix, security fix) gets a bullet under the
  appropriate section (`Added` / `Changed` / `Deprecated` / `Removed` /
  `Fixed` / `Security`) of the `[Unreleased]` block. Pure README/CI/internal-
  refactor changes generally don't need an entry.
- **`README.md`**: the Ruby/Rails badges at the top encode the supported
  matrix, and the **Usage** section documents the public API. Update the badges
  when the supported bounds move, and update the relevant Usage subsection in
  the same commit when you change a documented API.

## Bumping the version

1. Edit `lib/micro/struct/version.rb` — change `Micro::Struct::VERSION`. Follow
   [SemVer](https://semver.org/): patch for fixes, minor for additive
   user-visible changes, major for breaking changes.
2. Add a new entry at the top of `CHANGELOG.md` (`## [X.Y.Z] - YYYY-MM-DD`)
   with a matching `[Diff]`/compare link, and move the `[Unreleased]` items
   into it.
3. If the supported matrix moved, double-check that the README Ruby/Rails
   badges, the Ruby × Rails CI matrix (`.github/workflows/ci.yml`), and the
   `Appraisals` file all reflect the new bounds.

Don't tag, push, or `gem release` — humans do that.
