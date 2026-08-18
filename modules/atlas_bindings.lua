-- One-to-one runtime art binding for the complete Flounder's Jokers catalogue.
--
-- Steamodded's 0.9.8 adapter prefixes legacy Joker centers (j_fj_*) and
-- legacy atlases (fj_*) differently.  Relying on implicit lookup therefore
-- allows a valid center to silently render the vanilla Joker atlas.  Bind and
-- validate every packaged Joker after both the legacy and Dice suites exist.

local mod = SMODS.current_mod
local bound = 0
local seen = {}

for _, center in pairs(SMODS.Centers or {}) do
    local owned_by_flounder = center.mod == mod
        or (center.mod and center.mod.id == mod.id)
    if center.set == 'Joker' and owned_by_flounder then
        local original_key = center.original_key or center.key
        original_key = original_key:gsub('^j_fj_', ''):gsub('^fj_', ''):gsub('^j_', '')
        local atlas_key = 'fj_' .. original_key

        assert(SMODS.Atlases and SMODS.Atlases[atlas_key],
            ('Flounder art audit: missing atlas %s for %s'):format(atlas_key, center.key or original_key))
        assert(not seen[atlas_key],
            ('Flounder art audit: atlas %s is assigned to more than one Joker'):format(atlas_key))

        center.atlas = atlas_key
        seen[atlas_key] = true
        bound = bound + 1
    end
end

-- The vanilla catalogue registers 27 legacy Jokers plus the six Dice Jokers.
-- Optional suit integrations expand that same audited set up to all 60.
assert(bound >= 33 and bound <= 60,
    ('Flounder art audit: bound %d Joker atlases; expected 33-60 for the active mod set'):format(bound))

if sendInfoMessage then
    sendInfoMessage(('Bound and verified %d bespoke Joker atlases'):format(bound), mod.id)
end
