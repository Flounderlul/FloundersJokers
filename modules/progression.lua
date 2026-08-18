FJ_PROGRESSION = FJ_PROGRESSION or {}

local P = FJ_PROGRESSION

function P.state()
    if not (G and G.GAME) then return {} end
    G.GAME.fj_progression = G.GAME.fj_progression or {}
    return G.GAME.fj_progression
end

function P.is_fj_joker_key(key)
    return type(key) == 'string' and key:sub(1, 5) == 'j_fj_'
end

function P.modify_joker_weights(context, multiplier)
    if not (context and context.modify_weights and context.pool) then return end
    for _, entry in ipairs(context.pool) do
        if P.is_fj_joker_key(entry.key) then entry.weight = entry.weight * multiplier end
    end
end

local loaded_targets = {
    { suit = 'Spades', rank = '2', seal = function() return FJ_DICE.dice end },
    { suit = 'Hearts', rank = '5', seal = function() return FJ_DICE.dice end },
    { suit = 'Clubs', rank = '8', seal = function() return FJ_DICE.dice end },
    { suit = 'Diamonds', rank = 'Queen', seal = function() return FJ_DICE.dice end },
    { suit = 'Spades', rank = '4', seal = function() return FJ_DICE.cursed end },
    { suit = 'Hearts', rank = '7', seal = function() return FJ_DICE.cursed end },
    { suit = 'Clubs', rank = '10', seal = function() return FJ_DICE.cursed end },
    { suit = 'Diamonds', rank = 'King', seal = function() return FJ_DICE.cursed end },
}

function P.apply_loaded_seals()
    local state = P.state()
    if state.loaded_seals_applied then return end
    state.loaded_seals_applied = true
    for _, target in ipairs(loaded_targets) do
        for _, card in ipairs(G.playing_cards or {}) do
            if card.base and card.base.suit == target.suit and card.base.value == target.rank then
                card:set_seal(target.seal(), true, true)
                break
            end
        end
    end
end

function P.queue_loaded_seals()
    G.E_MANAGER:add_event(Event { trigger = 'after', delay = 0.1, func = function()
        P.apply_loaded_seals()
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('deck', 1, 0.34) end
        return true
    end })
end

function P.queue_starting_joker(pool, eternal)
    G.E_MANAGER:add_event(Event { trigger = 'after', delay = 0.15, func = function()
        local valid = {}
        for _, key in ipairs(pool) do if G.P_CENTERS[key] then valid[#valid + 1] = key end end
        if #valid == 0 or not (G.jokers and G.jokers.config.card_limit > #G.jokers.cards) then return true end
        local key = pseudorandom_element(valid, pseudoseed('fj_workshop_start'))
        local card = create_card('Joker', G.jokers, nil, nil, nil, nil, key, 'fj_workshop')
        card:set_eternal(eternal == true)
        card:add_to_deck()
        G.jokers:emplace(card)
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('deck', 0.96, 0.34) end
        return true
    end })
end

function P.is_new_blind(key)
    return key == 'bl_fj_quarry' or key == 'bl_fj_lock'
        or key == 'bl_fj_house' or key == 'bl_fj_mirror'
end

