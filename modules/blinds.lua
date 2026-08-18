local blind_fps = (G.SETTINGS and G.SETTINGS.reduced_motion) and 0.0001 or 6
for _, key in ipairs { 'quarry', 'lock', 'house', 'mirror' } do
    SMODS.Atlas { key = 'blind_' .. key, path = 'bl_' .. key .. '.png', px = 34, py = 34, atlas_table = 'ANIMATION_ATLAS', frames = 6, fps = blind_fps }
end

local function blind_sound(pitch)
    if FJ_PLAY_SOUND then FJ_PLAY_SOUND('blind', pitch or 1, 0.38) end
end

SMODS.Blind {
    key = 'quarry', atlas = 'blind_quarry', pos = { x = 0, y = 0 },
    dollars = 5, mult = 2, boss = { min = 2, max = 10 }, boss_colour = HEX('71675A'),
    loc_txt = { name = 'The Quarry', text = { 'Stone Cards are debuffed' } },
    set_blind = function(self) blind_sound(0.94) end,
    recalc_debuff = function(self, card)
        return card and card.config and card.config.center and card.config.center.key == 'm_stone'
    end,
}

SMODS.Blind {
    key = 'lock', atlas = 'blind_lock', pos = { x = 0, y = 0 },
    dollars = 5, mult = 2, boss = { min = 2, max = 10 }, boss_colour = HEX('B68432'),
    loc_txt = { name = 'The Lock', text = { 'First played card each hand is debuffed' } },
    set_blind = function(self) self.fj_first_id = nil; blind_sound(0.98) end,
    drawn_to_hand = function(self) self.fj_first_id = nil end,
    press_play = function(self)
        self.fj_first_id = G.play and G.play.cards[1] and G.play.cards[1].unique_val or nil
    end,
    recalc_debuff = function(self, card) return card and card.unique_val == self.fj_first_id end,
}

local function restore_house(self)
    local state = FJ_PROGRESSION.state()
    if state.house_probability_original and G.GAME.probabilities then
        G.GAME.probabilities.normal = state.house_probability_original
    end
    state.house_probability_original = nil
    state.house_active = nil
end

SMODS.Blind {
    key = 'house', atlas = 'blind_house', pos = { x = 0, y = 0 },
    dollars = 5, mult = 2, boss = { min = 3, max = 10 }, boss_colour = HEX('A53A2A'),
    loc_txt = { name = 'The House', text = { 'Listed probability numerator is halved', '{C:inactive}(minimum 0.5){}' } },
    set_blind = function(self)
        local state = FJ_PROGRESSION.state()
        if not state.house_active then
            state.house_probability_original = G.GAME.probabilities.normal
            G.GAME.probabilities.normal = math.max(0.5, G.GAME.probabilities.normal * 0.5)
            state.house_active = true
        end
        blind_sound(0.88)
    end,
    disable = function(self) restore_house(self) end,
    defeat = function(self) restore_house(self) end,
}

SMODS.Blind {
    key = 'mirror', atlas = 'blind_mirror', pos = { x = 0, y = 0 },
    dollars = 5, mult = 2, boss = { min = 3, max = 10 }, boss_colour = HEX('778995'),
    loc_txt = { name = 'The Mirror', text = { 'After the first played rank,', 'matching ranks are debuffed that hand' } },
    set_blind = function(self) self.fj_duplicate_ids = {}; blind_sound(1.04) end,
    drawn_to_hand = function(self) self.fj_duplicate_ids = {} end,
    press_play = function(self)
        self.fj_duplicate_ids = {}
        local seen = {}
        for _, card in ipairs(G.play and G.play.cards or {}) do
            local rank = card.base and card.base.value
            if rank and seen[rank] then self.fj_duplicate_ids[card.unique_val] = true end
            if rank then seen[rank] = true end
        end
    end,
    recalc_debuff = function(self, card)
        return card and self.fj_duplicate_ids and self.fj_duplicate_ids[card.unique_val] or false
    end,
}
