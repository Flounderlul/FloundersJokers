local mod = SMODS.current_mod

local defaults = { sfx_enabled = true, sfx_volume = 0.34, kinetic_effects = true }

mod.config = mod.config or {}
for key, value in pairs(defaults) do
    if mod.config[key] == nil then mod.config[key] = value end
end

-- Preserve in-progress vanilla runs when Steamodded introduces new serialized
-- fields. This migration is packaged with the mod, not applied to a user's
-- Steamodded installation.
assert(SMODS.load_file('modules/save_compat.lua'))()

-- The catalogue remains creator-authored 0.9.8 code. Steamodded maintains an
-- official adapter for it; wrapping just this file preserves its calculation
-- semantics while every new component uses the current object API.
SMODS.compat_0_9_8.with_compat(function()
    assert(SMODS.load_file('FloundersJokers.lua'))()
    for key, initializer in pairs(SMODS.compat_0_9_8.init_queue) do
        initializer()
        SMODS.compat_0_9_8.init_queue[key] = nil
    end
end)

-- Load custom sound cues and presentation polish early so that sound bindings
-- and fallback tables are registered for all subsequent modules.
assert(SMODS.load_file('modules/sounds.lua'))()

-- Dice Seals and their six-card suite are canonical creator content.
assert(SMODS.load_file('modules/dice_seals.lua'))()
assert(SMODS.load_file('modules/dice_suite.lua'))()

-- Fail closed if any Joker could fall back to stock art. This binds all 54
-- creator originals and the six canonical Dice Jokers to distinct atlases.
assert(SMODS.load_file('modules/atlas_bindings.lua'))()

-- The 3.0 progression chapter uses only native current-SMODS objects and
-- namespaced run state. Existing Joker and Seal calculations remain untouched.
assert(SMODS.load_file('modules/progression.lua'))()
assert(SMODS.load_file('modules/decks.lua'))()
assert(SMODS.load_file('modules/vouchers.lua'))()
assert(SMODS.load_file('modules/blinds.lua'))()
assert(SMODS.load_file('modules/challenges.lua'))()

-- Presentation polish is canonical; volume remains configurable in the saved
-- mod config for accessibility and streamer workflows.
assert(SMODS.load_file('modules/presentation.lua'))()
assert(SMODS.load_file('modules/config_ui.lua'))()

