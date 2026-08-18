local seal_fps = (G.SETTINGS and G.SETTINGS.reduced_motion) and 0.0001 or 8

SMODS.Atlas {
    key = 'dice_seal', path = 'dice_seal_animated.png', px = 71, py = 95,
    atlas_table = 'ANIMATION_ATLAS', frames = 12, fps = seal_fps, disable_mipmap = true,
}
SMODS.Atlas {
    key = 'cursed_dice_seal', path = 'cursed_dice_seal_animated.png', px = 71, py = 95,
    atlas_table = 'ANIMATION_ATLAS', frames = 12, fps = seal_fps, disable_mipmap = true,
}
SMODS.Atlas { key = 'oops_all_20s', path = 'c_oops_all_20s.png', px = 71, py = 95 }
SMODS.Atlas { key = 'oops_no_20s', path = 'c_oops_no_20s.png', px = 71, py = 95 }

local function remove_matching_seals(seal_key)
    G.E_MANAGER:add_event(Event {
        trigger = 'after',
        delay = 0.2,
        func = function()
            for _, playing_card in ipairs(G.playing_cards or {}) do
                if playing_card.seal == seal_key then
                    playing_card:set_seal(nil, true, true)
                end
            end
            return true
        end,
    })
end

local function scale_probabilities(multiplier)
    for key, value in pairs(G.GAME.probabilities or {}) do
        G.GAME.probabilities[key] = value * multiplier
    end
end

local dice_seal
dice_seal = SMODS.Seal {
    key = 'dice',
    atlas = 'dice_seal',
    pos = { x = 0, y = 0 },
    badge_colour = HEX('2FBF71'),
    sound = { sound = 'gold_seal', per = 1.08, vol = 0.55 },
    loc_txt = {
        label = 'Dice Seal',
        name = 'Dice Seal',
        text = {
            'When this card is {C:attention}discarded{},',
            '{C:green}double{} all listed probabilities',
            'and remove every {C:green}Dice Seal{}',
            '{C:inactive}(1 in 3 becomes 2 in 3)',
        },
    },
    calculate = function(self, card, context)
        if context.discard and not context.repetition then
            scale_probabilities(2)
            remove_matching_seals(self.key)
            if FJ_PLAY_SOUND then FJ_PLAY_SOUND('dice', 1.04, 0.38) end
            if FJ_VISUAL_EFFECT then FJ_VISUAL_EFFECT(card, 'dice') end
            return { message = 'Odds doubled!', colour = G.C.GREEN }
        end
    end,
}

local cursed_seal
cursed_seal = SMODS.Seal {
    key = 'cursed_dice',
    atlas = 'cursed_dice_seal',
    pos = { x = 0, y = 0 },
    badge_colour = HEX('C93C4A'),
    sound = { sound = 'gold_seal', per = 0.82, vol = 0.55 },
    loc_txt = {
        label = 'Cursed Dice Seal',
        name = 'Cursed Dice Seal',
        text = {
            'When this card is {C:attention}discarded{},',
            '{C:red}halve{} all listed probabilities',
            'and remove every {C:red}Cursed Dice Seal{}',
            '{C:inactive}(1 in 3 becomes 1 in 6)',
        },
    },
    calculate = function(self, card, context)
        if context.discard and not context.repetition then
            scale_probabilities(0.5)
            remove_matching_seals(self.key)
            if FJ_PLAY_SOUND then FJ_PLAY_SOUND('cursed', 0.94, 0.38) end
            if FJ_VISUAL_EFFECT then FJ_VISUAL_EFFECT(card, 'cursed') end
            return { message = 'Odds halved!', colour = G.C.RED }
        end
    end,
}

local function can_mark_one_card()
    return G.hand and #G.hand.highlighted == 1
end

local function apply_seal(consumable, seal)
    local target = G.hand.highlighted[1]
    G.E_MANAGER:add_event(Event {
        trigger = 'after',
        delay = 0.1,
        func = function()
            target:set_seal(seal.key, nil, true)
            if not (G.SETTINGS and G.SETTINGS.reduced_motion) then
                target:juice_up(0.3, 0.35)
            end
            if FJ_PLAY_SOUND then
                FJ_PLAY_SOUND(seal.key == FJ_DICE.cursed and 'cursed' or 'dice', 1, 0.38)
            end
            if FJ_VISUAL_EFFECT then
                FJ_VISUAL_EFFECT(target, seal.key == FJ_DICE.cursed and 'cursed' or 'dice')
            end
            return true
        end,
    })
end

SMODS.Consumable {
    key = 'oops_all_20s',
    set = 'Spectral',
    atlas = 'oops_all_20s',
    pos = { x = 0, y = 0 },
    cost = 4,
    config = { max_highlighted = 1 },
    loc_txt = {
        name = 'Oops! All 20s',
        text = { 'Add a {C:green}Dice Seal{}', 'to {C:attention}1{} selected card' },
    },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue + 1] = { key = dice_seal.key:lower() .. '_seal', set = 'Other' }
        return {}
    end,
    can_use = can_mark_one_card,
    use = function(self, card) apply_seal(card, dice_seal) end,
}

SMODS.Consumable {
    key = 'oops_no_20s',
    set = 'Spectral',
    atlas = 'oops_no_20s',
    pos = { x = 0, y = 0 },
    cost = 4,
    config = { max_highlighted = 1 },
    loc_txt = {
        name = 'Oops! No 20s',
        text = { 'Add a {C:red}Cursed Dice Seal{}', 'to {C:attention}1{} selected card' },
    },
    loc_vars = function(self, info_queue)
        info_queue[#info_queue + 1] = { key = cursed_seal.key:lower() .. '_seal', set = 'Other' }
        return {}
    end,
    can_use = can_mark_one_card,
    use = function(self, card) apply_seal(card, cursed_seal) end,
}

FJ_DICE = { dice = dice_seal.key, cursed = cursed_seal.key }
