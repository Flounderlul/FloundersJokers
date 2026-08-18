-- Steamodded 1814a adds serialized scoring, hand-limit, CardArea, PokerHand,
-- and permanent-bonus fields that are absent from vanilla in-progress runs.
-- Normalize only missing fields in the incoming save table before Steamodded's
-- own loader reads them. Existing modded values are never changed.

local numeric_card_fields = {
    'card_limit', 'extra_slots_used', 'perma_x_chips', 'perma_mult',
    'perma_x_mult', 'perma_h_chips', 'perma_h_x_chips', 'perma_h_mult',
    'perma_h_x_mult', 'perma_p_dollars', 'perma_h_dollars', 'perma_score',
    'perma_h_score', 'perma_x_score', 'perma_h_x_score', 'perma_blind_size',
    'perma_h_blind_size', 'perma_x_blind_size', 'perma_h_x_blind_size',
    'perma_repetitions',
}

local function number_or(value, fallback)
    return tonumber(value) or fallback
end

local function migrate_card(saved_card)
    if type(saved_card) ~= 'table' then return end
    saved_card.ability = saved_card.ability or {}
    for _, key in ipairs(numeric_card_fields) do
        saved_card.ability[key] = number_or(saved_card.ability[key], 0)
    end
end

local function migrate_area(area)
    if type(area) ~= 'table' then return end
    area.config = area.config or {}
    local legacy_limit = number_or(area.config.card_limit, 0)
    area.config.card_limits = area.config.card_limits or {}
    local limits = area.config.card_limits
    limits.base = number_or(limits.base, legacy_limit)
    limits.total_slots = number_or(limits.total_slots, legacy_limit)
    limits.mod = number_or(limits.mod, limits.total_slots - limits.base)
    limits.extra_slots = number_or(limits.extra_slots, 0)
    limits.extra_slots_used = number_or(limits.extra_slots_used, 0)
    for _, saved_card in ipairs(area.cards or {}) do migrate_card(saved_card) end
end

local function migrate_save(save)
    if type(save) ~= 'table' then return end

    save.GAME = save.GAME or {}
    save.GAME.starting_params = save.GAME.starting_params or {}
    local params = save.GAME.starting_params
    params.play_limit = number_or(params.play_limit, 5)
    params.discard_limit = number_or(params.discard_limit, 5)

    if type(save.SCORING_CALC) ~= 'table' or not save.SCORING_CALC.key then
        save.SCORING_CALC = { key = 'multiply', config = {} }
    end

    for _, hand in pairs(save.GAME.hands or {}) do
        if type(hand) == 'table' then
            hand.played_this_ante = number_or(hand.played_this_ante, 0)
        end
    end
    for _, area in pairs(save.cardAreas or {}) do migrate_area(area) end
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    if args and args.savetext then migrate_save(args.savetext) end
    return start_run_ref(self, args)
end

return {
    migrate_save = migrate_save,
    numeric_card_fields = numeric_card_fields,
}
