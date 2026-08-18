local voucher_fps = (G.SETTINGS and G.SETTINGS.reduced_motion) and 0.0001 or 6
for _, key in ipairs { 'wax_stamp', 'sealing_press', 'display_case', 'private_collection' } do
    SMODS.Atlas { key = key, path = 'v_' .. key .. '.png', px = 71, py = 95, atlas_table = 'ANIMATION_ATLAS', frames = 6, fps = voucher_fps }
end

SMODS.Voucher {
    key = 'wax_stamp', atlas = 'wax_stamp', pos = { x = 0, y = 0 }, cost = 10,
    loc_txt = { name = 'Wax Stamp', text = {
        'The first card in each {C:attention}Standard Pack{}',
        'is guaranteed to have a {C:attention}Seal{}',
    } },
    redeem = function(self, card)
        if card and not (G.SETTINGS and G.SETTINGS.reduced_motion) then card:juice_up(0.2, 0.25) end
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('voucher', 0.96, 0.36) end
    end,
}

SMODS.Voucher {
    key = 'sealing_press', atlas = 'sealing_press', pos = { x = 0, y = 0 }, cost = 10,
    requires = { 'v_fj_wax_stamp' },
    loc_txt = { name = 'Sealing Press', text = {
        'The first {C:attention}2{} cards in each {C:attention}Standard Pack{}',
        'are guaranteed to have a {C:attention}Seal{}',
    } },
    redeem = function(self, card)
        if card and not (G.SETTINGS and G.SETTINGS.reduced_motion) then card:juice_up(0.25, 0.3) end
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('voucher', 1.04, 0.38) end
    end,
}

SMODS.Voucher {
    key = 'display_case', atlas = 'display_case', pos = { x = 0, y = 0 }, cost = 10,
    loc_txt = { name = 'Display Case', text = {
        "Flounder's Jokers have {C:attention}X1.5{} shop weight",
    } },
    redeem = function(self, card)
        if card and not (G.SETTINGS and G.SETTINGS.reduced_motion) then card:juice_up(0.2, 0.25) end
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('voucher', 1, 0.36) end
    end,
    calculate = function(self, card, context)
        FJ_PROGRESSION.modify_joker_weights(context, 1.5)
    end,
}

SMODS.Voucher {
    key = 'private_collection', atlas = 'private_collection', pos = { x = 0, y = 0 }, cost = 10,
    requires = { 'v_fj_display_case' },
    loc_txt = { name = 'Private Collection', text = {
        "The first Flounder Joker offered each {C:attention}Ante{}",
        'has a random non-{C:dark_edition}Negative{} Edition',
    } },
    redeem = function(self, card)
        if card and not (G.SETTINGS and G.SETTINGS.reduced_motion) then card:juice_up(0.25, 0.3) end
        if FJ_PLAY_SOUND then FJ_PLAY_SOUND('voucher', 1.06, 0.38) end
    end,
    calculate = function(self, card, context)
        if not (context.modify_shop_card and context.card and context.card.config
            and context.card.config.center and FJ_PROGRESSION.is_fj_joker_key(context.card.config.center.key)) then return end
        local state = FJ_PROGRESSION.state()
        local ante = G.GAME.round_resets.ante
        if state.private_collection_ante == ante then return end
        state.private_collection_ante = ante
        local edition = SMODS.poll_edition { key = 'fj_private_collection_' .. ante, guaranteed = true, no_negative = true }
        if edition then context.card:set_edition(edition, true) end
    end,
}

local seal_options = { 'Gold', 'Red', 'Blue', 'Purple' }
local function standard_pack_card(self, card, index)
    local edition = poll_edition('standard_edition' .. G.GAME.round_resets.ante, 2, true)
    local guarantee = G.GAME.used_vouchers.v_fj_sealing_press and 2
        or (G.GAME.used_vouchers.v_fj_wax_stamp and 1 or 0)
    local seal
    if index <= guarantee then
        local options = { FJ_DICE.dice, FJ_DICE.cursed }
        for _, key in ipairs(seal_options) do options[#options + 1] = key end
        seal = pseudorandom_element(options, pseudoseed('fj_standard_seal_' .. G.GAME.round_resets.ante .. '_' .. index))
    else
        seal = SMODS.poll_seal { mod = 10 }
    end
    return {
        set = pseudorandom(pseudoseed('stdset' .. G.GAME.round_resets.ante)) > 0.6 and 'Enhanced' or 'Base',
        edition = edition, seal = seal, area = G.pack_cards, skip_materialize = true,
        soulable = true, key_append = 'sta', front = false,
    }
end

SMODS.Booster:take_ownership_by_kind('Standard', { create_card = standard_pack_card }, true)
