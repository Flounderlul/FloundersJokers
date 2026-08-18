local deck_fps = (G.SETTINGS and G.SETTINGS.reduced_motion) and 0.0001 or 6
SMODS.Atlas { key = 'loaded_deck', path = 'b_loaded.png', px = 71, py = 95, atlas_table = 'ANIMATION_ATLAS', frames = 6, fps = deck_fps }
SMODS.Atlas { key = 'workshop_deck', path = 'b_workshop.png', px = 71, py = 95, atlas_table = 'ANIMATION_ATLAS', frames = 6, fps = deck_fps }
SMODS.Atlas { key = 'curator_deck', path = 'b_curator.png', px = 71, py = 95, atlas_table = 'ANIMATION_ATLAS', frames = 6, fps = deck_fps }

SMODS.Back {
    key = 'loaded', atlas = 'loaded_deck', pos = { x = 0, y = 0 },
    config = { discards = -1 },
    loc_txt = { name = 'Loaded Deck', text = {
        'Start with {C:attention}4 Dice{} and {C:red}4 Cursed Dice{} Seals',
        '{C:red}-1{} discard each round',
    } },
    apply = function(self) FJ_PROGRESSION.queue_loaded_seals() end,
}

local workshop_pool = {
    'j_fj_lucky', 'j_fj_cracked', 'j_fj_shiny',
    'j_fj_spear', 'j_fj_bullet', 'j_fj_missile',
    'j_fj_blood', 'j_fj_lost', 'j_fj_sunken',
}

SMODS.Back {
    key = 'workshop', atlas = 'workshop_deck', pos = { x = 0, y = 0 },
    config = { joker_slot = -1 },
    loc_txt = { name = 'Workshop Deck', text = {
        'Start with a random {C:attention}Eternal{} Common',
        'Flounder Stone, Tool, or Gem Joker', '{C:red}-1{} Joker slot',
    } },
    apply = function(self) FJ_PROGRESSION.queue_starting_joker(workshop_pool, true) end,
}

SMODS.Back {
    key = 'curator', atlas = 'curator_deck', pos = { x = 0, y = 0 },
    config = { hands = -1 },
    loc_txt = { name = 'Curator Deck', text = {
        "Flounder's Jokers have {C:attention}X2{} shop weight",
        '{C:red}-1{} hand each round',
    } },
    apply = function(self) FJ_PROGRESSION.state().curator = true end,
    calculate = function(self, back, context)
        FJ_PROGRESSION.modify_joker_weights(context, 2)
    end,
}
