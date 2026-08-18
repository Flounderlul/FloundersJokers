# 3.0 balance and playtest plan

## Invariants

- The original 54 Jokers and six Dice-suite Jokers retain their values and calculations.
- Every deck pays for its opening advantage: Loaded loses a discard, Workshop loses a slot, Curator loses a hand.
- Vouchers alter access and curation, never score directly or increase pack size.
- Boss Blind effects clear per hand or restore exact incoming state on disable and defeat.
- All six challenges are immediately available and provide mastery progression without unlock-gated power.

## Seeded simulation gate

Compare each new deck against the vanilla baseline over identical seeds. White Stake win rate must stay within five percentage points and Gold Stake within eight. Record Ante reached, economy, Joker slots, sealed-card count, and dominant win condition. Treat any result outside the bands as a tuning failure, not evidence to change original Joker values.

## Manual matrix

Complete five runs per challenge (30 total), covering at least one loss before Ante 5 and one run reaching the final Boss where practical. Log crashes, softlocks, save/resume behavior, unclear tooltips, edition/Seal collisions, economy outliers, and strategies that bypass the intended tradeoff. Separately exercise each deck with Reduced Motion on, sound off, missing optional suit mods, and a mixed modded shop pool.

## Release decision

Static and smoke certification can verify safety and registration, but the win-rate bands require recorded full-run telemetry. Until the 30-run matrix exists, 3.0 is technically release-candidate quality rather than evidence-backed final balance.
