local function challenge(key, name, spec)
    local original_calculate = spec.calculate
    spec.calculate = function(self, context)
        if original_calculate then original_calculate(self, context) end
        if context.end_of_round and G.GAME and G.GAME.blind and G.GAME.blind.boss
            and G.GAME.round_resets.ante >= G.GAME.win_ante then
            local state = FJ_PROGRESSION.state()
            if not state.challenge_completion_played then
                state.challenge_completion_played = true
                if FJ_PLAY_SOUND then FJ_PLAY_SOUND('challenge', 1.04, 0.4) end
            end
        end
    end
    spec.key = key
    spec.loc_txt = { name = name }
    spec.unlocked = function() return true end
    SMODS.Challenge(spec)
end

challenge('first_roll', 'First Roll', {
    rules = { modifiers = { { id = 'discards', value = 2 } } },
    jokers = { { id = 'j_fj_brass_cup' } },
    apply = function(self) FJ_PROGRESSION.queue_loaded_seals() end,
})

challenge('rock_collection', 'Rock Collection', {
    rules = { modifiers = { { id = 'joker_slots', value = 4 } } },
    jokers = { { id = 'j_fj_lucky' }, { id = 'j_fj_cracked' }, { id = 'j_fj_shiny' } },
})

challenge('assembly_line', 'Assembly Line', {
    rules = { modifiers = { { id = 'dollars', value = 0 } } },
    jokers = {
        { id = 'j_fj_robberh', eternal = true }, { id = 'j_fj_hungryso', eternal = true },
        { id = 'j_fj_glassb', eternal = true }, { id = 'j_fj_bornw', eternal = true },
    },
})

challenge('rarity_climb', 'Rarity Climb', {
    rules = { modifiers = { { id = 'reroll_cost', value = 99 } } },
    jokers = { { id = 'j_fj_common' } },
    calculate = function(self, context)
        if not (context.modify_weights and context.pool) then return end
        local allowed = { j_fj_common = true, j_fj_uncommon = true, j_fj_rare = true, j_fj_legendary = true }
        for _, entry in ipairs(context.pool) do
            if entry.key and entry.key:sub(1, 2) == 'j_' and not allowed[entry.key] then entry.weight = 0 end
        end
    end,
})

local vanilla_bosses = {
    'bl_hook', 'bl_ox', 'bl_house', 'bl_wall', 'bl_wheel', 'bl_arm', 'bl_club', 'bl_fish',
    'bl_psychic', 'bl_goad', 'bl_water', 'bl_window', 'bl_manacle', 'bl_eye', 'bl_mouth',
    'bl_plant', 'bl_serpent', 'bl_pillar', 'bl_needle', 'bl_head', 'bl_tooth', 'bl_flint',
    'bl_mark', 'bl_final_acorn', 'bl_final_leaf', 'bl_final_vessel', 'bl_final_heart', 'bl_final_bell',
}
local boss_restrictions = {}
for _, id in ipairs(vanilla_bosses) do boss_restrictions[#boss_restrictions + 1] = { id = id, type = 'blind' } end

challenge('house_rules', 'House Rules', {
    jokers = { { id = 'j_fj_croupier' } },
    restrictions = { banned_other = boss_restrictions },
    apply = function(self)
        local state = FJ_PROGRESSION.state(); state.new_blinds_only = true
        FJ_PROGRESSION.queue_loaded_seals()
    end,
})

challenge('grand_exhibition', 'Grand Exhibition', {
    rules = { modifiers = { { id = 'hands', value = 3 }, { id = 'discards', value = 2 } } },
    apply = function(self)
        local state = FJ_PROGRESSION.state(); state.curator = true; state.new_blinds_enabled = true
    end,
    calculate = function(self, context) FJ_PROGRESSION.modify_joker_weights(context, 2) end,
})
