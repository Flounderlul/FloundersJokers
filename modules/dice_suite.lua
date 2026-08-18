local function register_atlas(key)
    SMODS.Atlas { key = key, path = 'j_' .. key .. '.png', px = 71, py = 95 }
end

for _, key in ipairs {
    'loaded_stone', 'brass_cup', 'payout_gem',
    'house_edge', 'double_down', 'croupier',
} do
    register_atlas(key)
end

local function is_dice_sealed(card)
    return card and (card.seal == FJ_DICE.dice or card.seal == FJ_DICE.cursed)
end

local function dice_tooltips(info_queue)
    info_queue[#info_queue + 1] = { key = FJ_DICE.dice:lower() .. '_seal', set = 'Other' }
    info_queue[#info_queue + 1] = { key = FJ_DICE.cursed:lower() .. '_seal', set = 'Other' }
end

SMODS.Joker {
    key = 'loaded_stone',
    atlas = 'loaded_stone', pos = { x = 0, y = 0 },
    rarity = 2, cost = 6, blueprint_compat = true,
    config = { extra = { odds = 4, xmult = 1.5 } },
    loc_txt = {
        name = 'Loaded Stone',
        text = {
            'Each scored card with a {C:attention}Dice Seal{}',
            'has a {C:green}#1# in #2#{} chance to give {X:mult,C:white}X#3#{} Mult',
        },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { G.GAME and G.GAME.probabilities.normal or 1, card.ability.extra.odds, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and is_dice_sealed(context.other_card)
            and pseudorandom('fj_loaded_stone') < G.GAME.probabilities.normal / card.ability.extra.odds then
            if FJ_PLAY_SOUND then FJ_PLAY_SOUND('dice', 1.08, 0.34) end
            return { x_mult = card.ability.extra.xmult }
        end
    end,
}

SMODS.Joker {
    key = 'brass_cup',
    atlas = 'brass_cup', pos = { x = 0, y = 0 },
    rarity = 1, cost = 4, blueprint_compat = true,
    config = { extra = { chips = 25 } },
    loc_txt = {
        name = 'Brass Cup',
        text = { 'Scored cards with a {C:attention}Dice Seal{}', 'give {C:chips}+#1#{} Chips' },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and is_dice_sealed(context.other_card) then
            return { chips = card.ability.extra.chips }
        end
    end,
}

SMODS.Joker {
    key = 'payout_gem',
    atlas = 'payout_gem', pos = { x = 0, y = 0 },
    rarity = 2, cost = 6, blueprint_compat = true,
    config = { extra = { dollars = 1 } },
    loc_txt = {
        name = 'Payout Gem',
        text = { 'Scored cards with a {C:attention}Dice Seal{}', 'earn {C:money}$#1#{}' },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and is_dice_sealed(context.other_card) then
            return { dollars = card.ability.extra.dollars }
        end
    end,
}

SMODS.Joker {
    key = 'house_edge',
    atlas = 'house_edge', pos = { x = 0, y = 0 },
    rarity = 3, cost = 8, blueprint_compat = true,
    config = { extra = { xmult = 2 } },
    loc_txt = {
        name = 'House Edge',
        text = {
            '{X:mult,C:white}X#1#{} Mult if the scoring hand',
            'contains both kinds of {C:attention}Dice Seal{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local has_dice, has_cursed = false, false
            for _, playing_card in ipairs(context.scoring_hand or {}) do
                has_dice = has_dice or playing_card.seal == FJ_DICE.dice
                has_cursed = has_cursed or playing_card.seal == FJ_DICE.cursed
            end
            if has_dice and has_cursed then return { x_mult = card.ability.extra.xmult } end
        end
    end,
}

SMODS.Joker {
    key = 'double_down',
    atlas = 'double_down', pos = { x = 0, y = 0 },
    rarity = 2, cost = 7, blueprint_compat = true,
    config = { extra = { repetitions = 1 } },
    loc_txt = {
        name = 'Double Down',
        text = { 'Retrigger each scored card', 'with a {C:attention}Dice Seal{} {C:attention}#1#{} time' },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and is_dice_sealed(context.other_card) then
            return { repetitions = card.ability.extra.repetitions }
        end
    end,
}

SMODS.Joker {
    key = 'croupier',
    atlas = 'croupier', pos = { x = 0, y = 0 },
    rarity = 3, cost = 8, blueprint_compat = false,
    config = { extra = { odds = 6 } },
    loc_txt = {
        name = 'The Croupier',
        text = {
            'After scoring, {C:green}#1# in #2#{} chance to add',
            'a random {C:attention}Dice Seal{} to a random',
            'unsealed card in the scoring hand',
        },
    },
    loc_vars = function(self, info_queue, card)
        dice_tooltips(info_queue)
        return { vars = { G.GAME and G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint
            and pseudorandom('fj_croupier_roll') < G.GAME.probabilities.normal / card.ability.extra.odds then
            local candidates = {}
            for _, playing_card in ipairs(context.scoring_hand or {}) do
                if not playing_card.seal then candidates[#candidates + 1] = playing_card end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('fj_croupier_target'))
                local seal_key = pseudorandom('fj_croupier_kind') < 0.5 and FJ_DICE.dice or FJ_DICE.cursed
                G.E_MANAGER:add_event(Event {
                    trigger = 'after', delay = 0.1,
                    func = function()
                        target:set_seal(seal_key, nil, true)
                        if not (G.SETTINGS and G.SETTINGS.reduced_motion) then
                            target:juice_up(0.3, 0.35)
                        end
                        if FJ_VISUAL_EFFECT then FJ_VISUAL_EFFECT(target, 'dice') end
                        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('dice', 1, 0.38) end
                        return true
                    end,
                })
                return { message = 'Place your bets!', colour = G.C.PURPLE }
            end
        end
    end,
}
