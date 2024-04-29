--- STEAMODDED HEADER
--- MOD_NAME: Flounder's Jokers
--- MOD_ID: flounderjokers
--- MOD_AUTHOR: [Flounder]
--- MOD_DESCRIPTION: adds 4 jokers with effects: rerolls have chance to add jokers of higher rarity 

----------------------------------------------
------------MOD CODE -------------------------

local config = {
    -- Jokers
    commonJoker = true,
    uncommonJoker = true,
    rareJoker = true,
    legendaryJoker = true,
	luckyStone = true,
	crackedStone = true,
	shinyStone = true,
	spearHead = true,
	bulletTip = true,
	missileTip = true,
	bloodGem = true,
	lostGem = true,
	sunkenGem = true,
	imperialTopaz = true,
	mozambiqueRuby = true,
	blackDiamond = true,
	gunsandRoses = true,
	fishandChips = true,
	saltandPepper = true,
	macaroniandCheese = true,
	
}

local seals = {
    "Gold",
    "Red",
    "Blue",
    "Purple"
}

local function tables_equal(a, b)
    return table.concat(a) == table.concat(b)
end

local function tables_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- Save attributes
local attributes = {
    mult = {
        key = 'mult_dagonet',
        prev_key = 'prev_mult_dagonet',
        min = 0
    },
    mult_mod = {
        key = 'mult_mod_dagonet',
        prev_key = 'prev_mult_mod_dagonet',
        min = 0
    },
    chips = {
        key = 'chips_dagonet',
        prev_key = 'prev_chips_dagonet',
        min = 0
    },
    chip_mod = {
        key = 'chip_mod_dagonet',
        prev_key = 'prev_chips_mod_dagonet',
        min = 0
    },
    Xmult = {
        key = 'Xmult_dagonet',
        prev_key = 'prev_Xmult_dagonet',
        min = 1
    },
    Xmult_mod = {
        key = 'Xmult_mod_dagonet',
        prev_key = 'prev_Xmult_mod_dagonet',
        min = 0
    },
    x_mult = {
        key = 'x_mult_dagonet',
        prev_key = 'prev_x_mult_dagonet',
        min = 1
    },
    t_mult = {
        key = 't_mult_dagonet',
        prev_key = 'prev_t_mult_dagonet',
        min = 0
    },
    t_chips = {
        key = 't_chips_dagonet',
        prev_key = 'prev_t_chips_dagonet',
        min = 0
    },
    s_mult = {
        key = 's_mult_dagonet',
        prev_key = 'prev_s_mult_dagonet',
        min = 0
    },
    dollars = {
        key = 'dollars_dagonet',
        prev_key = 'prev_dollars_dagonet',
        min = 0
    },
    hand_add = {
        key = 'hand_add_dagonet',
        prev_key = 'prev_hand_add_dagonet',
        min = 0
    },
    discard_sub = {
        key = 'discard_sub_dagonet',
        prev_key = 'prev_discard_sub_dagonet',
        min = 0
    },
    odds = {
        key = 'odds_dagonet',
        prev_key = 'prev_odds_dagonet',
        min = 0
    },
    faces = {
        key = 'faces_dagonet',
        prev_key = 'prev_faces_dagonet',
        min = 0
    },
    max = {
        key = 'max_dagonet',
        prev_key = 'prev_max_dagonet',
        min = 0
    },
    min = {
        key = 'min_dagonet',
        prev_key = 'prev_min_dagonet',
        min = 0
    },
    every = {
        key = 'every_dagonet',
        prev_key = 'prev_every_dagonet',
        min = 0
    },
    increase = {
        key = 'increase_dagonet',
        prev_key = 'prev_increase_dagonet',
        min = 0
    },
    d_size = {
        key = 'd_size_dagonet',
        prev_key = 'prev_d_size_dagonet',
        min = 0
    },
    h_mod = {
        key = 'h_mod_dagonet',
        prev_key = 'prev_h_mod_dagonet',
        min = 0
    },
    h_plays = {
        key = 'h_plays_dagonet',
        prev_key = 'prev_h_plays_dagonet',
        min = 0
    },
    discards = {
        key = 'discards_dagonet',
        prev_key = 'prev_discards_dagonet',
        min = 0
    },
    req = {
        key = 'req_dagonet',
        prev_key = 'prev_req_dagonet',
        min = 0
    },
    percentage = {
        key = 'percentage_dagonet',
        prev_key = 'prev_percentage_dagonet',
        min = 0
    },
    base = {
        key = 'base_dagonet',
        prev_key = 'prev_base_dagonet',
        min = 0
    },
    repetitions = {
        key = 'repetitions_dagonet',
        prev_key = 'prev_repetitions_dagonet',
        min = 0
    },
    dollar_gain_one = {
        key = 'dollar_gain_one_dagonet',
        prev_key = 'prev_dollar_gain_one_dagonet',
        min = 0
    },
    dollar_gain_two = {
        key = 'dollar_gain_two_dagonet',
        prev_key = 'prev_dollar_gain_two_dagonet',
        min = 0
    },
    dollar_gain_three = {
        key = 'dollar_gain_three_dagonet',
        prev_key = 'prev_dollar_gain_three_dagonet',
        min = 0
    },
    dollar_gain_four = {
        key = 'dollar_gain_four_dagonet',
        prev_key = 'prev_dollar_gain_four_dagonet',
        min = 0
    },
    dollar_gain_five = {
        key = 'dollar_gain_five_dagonet',
        prev_key = 'prev_dollar_gain_five_dagonet',
        min = 0
    },
    extra = {
        key = 'extra_dagonet',
        prev_key = 'prev_extra_dagonet',
        min = 0
    }
}
local function create_tarot(joker, tarot)
    -- Check consumeable space
    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        -- Add card
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
           trigger = 'before',
           delay = 0.0,
           func = (function()
               local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, tarot, '8ba')
               card:add_to_deck()
               G.consumeables:emplace(card)
               G.GAME.consumeable_buffer = 0
               return true
           end)
        }))

        -- Show message
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
           message = localize('k_plus_tarot'),
           colour = G.C.PURPLE
        })
    else
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = localize('k_no_space_ex')
        })
    end
end

local function create_planet(joker, planet, other_joker)
    if #G.consumeables.cards + G.GAME.consumeable_buffer <
        G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        -- Add card
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.0,
            func = (function()
                local card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet, 'blusl')
                card:add_to_deck()
                G.consumeables:emplace(card)
                G.GAME.consumeable_buffer = 0
                if other_joker then
                    other_joker:juice_up(0.5, 0.5)
                end
                return true
            end)
        }))

        -- Show message
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = localize('k_plus_planet'),
            colour = G.C.SECONDARY_SET.Planet
        })
    else
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = localize('k_no_space_ex')
        })
    end
end

local function create_joker(joker, cjoker, rarity)
    -- Check consumeable space
    if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
        -- Add card
        G.GAME.joker_buffer = G.GAME.joker_buffer + 1
        G.E_MANAGER:add_event(Event({
           trigger = 'before',
           delay = 0.0,
           func = (function()
               local card = create_card('Joker', G.joker, rarity, nil, nil, nil, cjoker, 'len')
               card:add_to_deck()
               G.jokers:emplace(card)
               G.GAME.joker_buffer = 0
               return true
           end)
        }))

        -- Show message
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
           message = localize('k_plus_joker'),
           colour = G.C.PURPLE
        })
    else
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = localize('k_no_space_ex')
        })
    end
end

-- Increase base attributes
local function increase_attributes(k, v, place, multiplier)
    local attr = attributes[k]

    if not attr or type(v) == "string" then
        return
    end

    -- Handle extra seperately
    if type(v) == "table" then
        for k2, v2 in pairs(place.extra) do
            increase_attributes(k2, v2, place.extra, multiplier)
        end
    elseif v > attr.min then
        if place[attr.prev_key] == nil then
            place[attr.prev_key] = multiplier
        end
        if place[attr.key] == nil then
            -- Save base value
            place[attr.key] = v
        else
            if not (v / multiplier == place[attr.key] and place[attr.prev_key] == multiplier) then
                if not (v / multiplier == place[attr.key] or v / place[attr.prev_key] == place[attr.key]) then
                    if v / multiplier ~= place[attr.key] and place[attr.prev_key] == multiplier then
                        -- Update base based on current multiplier
                        local increase = (v / multiplier - place[attr.key]) * multiplier
                        place[attr.key] = place[attr.key] + increase
                    else
                        -- Update base based on previous multiplier
                        local increase = (v / place[attr.prev_key] - place[attr.key]) * place[attr.prev_key]
                        place[attr.key] = place[attr.key] + increase
                    end
                end
            end
        end
        -- Multiply attribute
        place[k] = place[attr.key] * multiplier
        place[attr.prev_key] = multiplier
    end
end

local function not_in_table(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return false
        end
    end
    return true
end

function SMODS.INIT.flounderjokers()

    G.localization.misc.v_dictionary.fj_tags = {"+#1# #2#!"}

    init_localization()

    local flounderJokers = SMODS.findModByID('flounderjokers')

    if config.commonJoker then
        -- Create Common Joker
        local cojo = {
            loc = {
                name = "Common Joker",
                text = {
                    "{C:green}rerolls{} have {C:green}#2# in #1#{} chance",
                    "add a {C:green}Uncommon Tag{}"
                }
            },
            ability_name = "commonJoker",
            slug = "common",
            ability = {
                extra = {odds = 5, tags = 1, tag = 'tag_uncommon', tag_name = 'Uncommon tag'}
            },
            rarity = 1,
            cost = 4,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Common Joker
        local joker_cojo = SMODS.Joker:new(
            cojo.ability_name,
            cojo.slug,
            cojo.ability,
            { x = 0, y = 0 },
            cojo.loc,
            cojo.rarity,
            cojo.cost,
            cojo.unlocked,
            cojo.discovered,
            cojo.blueprint_compat,
            cojo.eternal_compat
        )
        joker_cojo:register()

        -- Initialize Sprite for Jokers
        local sprite_cojo = SMODS.Sprite:new(
            "j_" .. cojo.slug,
            flounderJokers.path,
            "j_" .. cojo.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_cojo:register()

        -- Set local variables for Common Joker
        function SMODS.Jokers.j_common.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.tags, self.ability.extra.tag, self.ability.extra.tag_name}
        end
        -- Calculate
        SMODS.Jokers.j_common.calculate = function(self, context)
            if context.reroll_shop and not context.individual and not context.repetition and not context.blueprint then
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal / self.ability.extra.odds then
                    G.E_MANAGER:add_event(Event({func = function()
                        add_tag(Tag(self.ability.extra.tag))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true end }))
                    return {
                        message = localize {
                            type = 'variable',
                            key= 'fj_tags',
                            vars = {self.ability.extra.tags, self.ability.extra.tag_name}  
                        }
                    }
                end 
            end
        end
    end
    if config.uncommonJoker then
        -- Create Uncommon Joker
        local unjo = {
            loc = {
                name = "Uncommon Joker",
                text = {
                    "{C:green}rerolls{} have {C:green}#2# in #1#{} chance",
                    "add a {C:red}Rare Tag{}"
                }
            },
            ability_name = "uncommonJoker",
            slug = "uncommon",
            ability = {
                extra = {odds = 8, tags = 1, tag = 'tag_rare', tag_name = 'Rare tag'}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Uncommon Joker
        local joker_unjo = SMODS.Joker:new(
            unjo.ability_name,
            unjo.slug,
            unjo.ability,
            { x = 0, y = 0 },
            unjo.loc,
            unjo.rarity,
            unjo.cost,
            unjo.unlocked,
            unjo.discovered,
            unjo.blueprint_compat,
            unjo.eternal_compat
        )
        joker_unjo:register()

        local sprite_unjo = SMODS.Sprite:new(
            "j_" .. unjo.slug,
            flounderJokers.path,
            "j_" .. unjo.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_unjo:register()

        function SMODS.Jokers.j_uncommon.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.tags, self.ability.extra.tag, self.ability.extra.tag_name}
        end
        -- Calculate
        SMODS.Jokers.j_uncommon.calculate = function(self, context)
            if context.reroll_shop and not context.individual and not context.repetition and not context.blueprint then
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal / self.ability.extra.odds then
                    G.E_MANAGER:add_event(Event({func = function()
                        add_tag(Tag(self.ability.extra.tag))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true end }))
                    return {
                        message = localize {
                            type = 'variable',
                            key= 'fj_tags',
                            vars = {self.ability.extra.tags, self.ability.extra.tag_name}  
                        }
                    }
                end 
            end
        end
    end
    if config.rareJoker then
        -- Create Rare Joker
        local rajo = {
            loc = {
                name = "Rare Joker",
                text = {
                    "{C:green}rerolls{} have {C:green}#2# in #1#{} chance",
                    "add a {C:purple}Legendary{} Joker"
                }
            },
            ability_name = "rareJoker",
            slug = "rare",
            ability = {
                extra = {odds = 20, spectrals = 1, spectral = 'c_soul', spectral_name = 'The Soul'}
            },
            rarity = 3,
            cost = 8,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Rare Joker
        local joker_rajo = SMODS.Joker:new(
            rajo.ability_name,
            rajo.slug,
            rajo.ability,
            { x = 0, y = 0 },
            rajo.loc,
            rajo.rarity,
            rajo.cost,
            rajo.unlocked,
            rajo.discovered,
            rajo.blueprint_compat,
            rajo.eternal_compat
        )
        joker_rajo:register()

        local sprite_rajo = SMODS.Sprite:new(
            "j_" .. rajo.slug,
            flounderJokers.path,
            "j_" .. rajo.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_rajo:register()

        function SMODS.Jokers.j_rare.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.spectrals, self.ability.extra.spectral, self.ability.extra.spectral_name}
        end
        -- Calculate
        SMODS.Jokers.j_rare.calculate = function(self, context)
            if context.reroll_shop and not context.individual and not context.repetition and not context.blueprint then
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal / self.ability.extra.odds then
                     play_sound('timpani')
                     create_joker(self, nil, "legendary")  --creates a random legendary joker
                 end
             end
         end
    end
    if config.legendaryJoker then
        -- Create Legendary Joker
        local lejo = {
            loc = {
                name = "Legendary Joker",
                text = {
                    "{C:green}rerolls{} have {C:green}#2# in #1#{} chance",
                    "add a {C:dark_edition}Negative Tag{}"
                }
            },
            ability_name = "legendaryJoker",
            slug = "legendary",
            ability = {
                extra = {odds = 25, tags = 1, tag = 'tag_negative', tag_name = 'Negative tag'}
            },
            rarity = 4,
            cost = 12,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Legendary Joker
        local joker_lejo = SMODS.Joker:new(
            lejo.ability_name,
            lejo.slug,
            lejo.ability,
            { x = 0, y = 0 },
            lejo.loc,
            lejo.rarity,
            lejo.cost,
            lejo.unlocked,
            lejo.discovered,
            lejo.blueprint_compat,
            lejo.eternal_compat
        )
        joker_lejo:register()

        local sprite_lejo = SMODS.Sprite:new(
            "j_" .. lejo.slug,
            flounderJokers.path,
            "j_" .. lejo.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_lejo:register()

        function SMODS.Jokers.j_legendary.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.tags, self.ability.extra.tag, self.ability.extra.tag_name}
        end
        -- Calculate
        SMODS.Jokers.j_legendary.calculate = function(self, context)
            if context.reroll_shop and not context.individual and not context.repetition and not context.blueprint then
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal / self.ability.extra.odds then
                    G.E_MANAGER:add_event(Event({func = function()
                        add_tag(Tag(self.ability.extra.tag))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true end }))
                    return {
                        message = localize {
                            type = 'variable',
                            key= 'fj_tags',
                            vars = {self.ability.extra.tags, self.ability.extra.tag_name}  
                        }
                    }
                end 
            end
        end
    end
  	if config.luckyStone then
        -- Create Lucky Stone
        local lust = {
            loc = {
                name = "Lucky Stone",
                text = {
                    "{C:green}#2# in #1#{} chance for",
                    "played cards with {C:clubs}Club{} suit",
					"to give {X:mult,C:white}X#3#{} mult when scored"
                }
            },
            ability_name = "luckyStone",
            slug = "lucky",
            ability = {
                extra = {odds = 2, Xmult = 1.5}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Lucky Stone
        local joker_lust = SMODS.Joker:new(
            lust.ability_name,
            lust.slug,
            lust.ability,
            { x = 0, y = 0 },
            lust.loc,
            lust.rarity,
            lust.cost,
            lust.unlocked,
            lust.discovered,
            lust.blueprint_compat,
            lust.eternal_compat
        )
        joker_lust:register()

        -- Initialize Sprite for Jokers
        local sprite_lust = SMODS.Sprite:new(
            "j_" .. lust.slug,
            flounderJokers.path,
            "j_" .. lust.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_lust:register()

        -- Set local variables for Lucky Stone
        function SMODS.Jokers.j_lucky.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.Xmult}
        end
        -- Calculate
        SMODS.Jokers.j_lucky.calculate = function(self, context)
	       if self.ability.name ==  'luckyStone' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Clubs") then 
                    if pseudorandom('lucky_money') < G.GAME.probabilities.normal/self.ability.extra.odds then
                        return {
                            x_mult = self.ability.extra.Xmult,
                            card = self
                        }
                    end
			    end
            end	
	    end
	end
    if config.crackedStone then
        -- Create Cracked Stone
        local crst = {
            loc = {
                name = "Cracked Stone",
                text = {
                    "{C:green}#2# in #1#{} chance for",
                    "played cards with {C:spades}Spade{} suit",
					"to give {X:mult,C:white}X#3#{} mult when scored"
                }
            },
            ability_name = "crackedStone",
            slug = "cracked",
            ability = {
                extra = {odds = 2, Xmult = 1.5}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Cracked Stone
        local joker_crst = SMODS.Joker:new(
            crst.ability_name,
            crst.slug,
            crst.ability,
            { x = 0, y = 0 },
            crst.loc,
            crst.rarity,
            crst.cost,
            crst.unlocked,
            crst.discovered,
            crst.blueprint_compat,
            crst.eternal_compat
        )
        joker_crst:register()

        -- Initialize Sprite for Jokers
        local sprite_crst = SMODS.Sprite:new(
            "j_" .. crst.slug,
            flounderJokers.path,
            "j_" .. crst.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_crst:register()

        -- Set local variables for Cracked Stone
        function SMODS.Jokers.j_cracked.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.Xmult}
        end
        -- Calculate
        SMODS.Jokers.j_cracked.calculate = function(self, context)
	       if self.ability.name ==  'crackedStone' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Spades") then 
                    if pseudorandom('lucky_money') < G.GAME.probabilities.normal/self.ability.extra.odds then
                        return {
                            x_mult = self.ability.extra.Xmult,
                            card = self
                        }
                    end
                end
	        end
		end
	end
    if config.shinyStone then
        -- Create Shiny Stone
        local shst = {
            loc = {
                name = "Shiny Stone",
                text = {
                    "{C:green}#2# in #1#{} chance for",
                    "played cards with {C:diamonds}Diamond{} suit",
					"to give {X:mult,C:white}X#3#{} mult when scored"
                }
            },
            ability_name = "shinyStone",
            slug = "shiny",
            ability = {
                extra = {odds = 2, Xmult = 1.5}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Shiny Stone
        local joker_shst = SMODS.Joker:new(
            shst.ability_name,
            shst.slug,
            shst.ability,
            { x = 0, y = 0 },
            shst.loc,
            shst.rarity,
            shst.cost,
            shst.unlocked,
            shst.discovered,
            shst.blueprint_compat,
            shst.eternal_compat
        )
        joker_shst:register()

        -- Initialize Sprite for Jokers
        local sprite_shst = SMODS.Sprite:new(
            "j_" .. shst.slug,
            flounderJokers.path,
            "j_" .. shst.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_shst:register()

        -- Set local variables for Shiny Stone
        function SMODS.Jokers.j_shiny.loc_def(self)
            return { self.ability.extra.odds, '' .. (G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra.Xmult}
        end
		-- Calculate
        SMODS.Jokers.j_shiny.calculate = function(self, context)
	       if self.ability.name ==  'shinyStone' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Diamonds") then 
                    if pseudorandom('lucky_money') < G.GAME.probabilities.normal/self.ability.extra.odds then
                        return {
                            x_mult = self.ability.extra.Xmult,
                            card = self
                        }		
	                end
				end
			end
		end
	end
    if config.spearHead then
        -- Create Spear Head
        local sphe = {
            loc = {
                name = "Spear Head",
                text = {
                    "Played cards with",
                    "{C:clubs}Club{} suit give",
					"{C:chips}+#1#{} Chips when scored"
                }
            },
            ability_name = "spearHead",
            slug = "spear",
            ability = {
                extra = {chips = 50}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Spear Head
        local joker_sphe = SMODS.Joker:new(
            sphe.ability_name,
            sphe.slug,
            sphe.ability,
            { x = 0, y = 0 },
            sphe.loc,
            sphe.rarity,
            sphe.cost,
            sphe.unlocked,
            sphe.discovered,
            sphe.blueprint_compat,
            sphe.eternal_compat
        )
        joker_sphe:register()

        -- Initialize Sprite for Jokers
        local sprite_sphe = SMODS.Sprite:new(
            "j_" .. sphe.slug,
            flounderJokers.path,
            "j_" .. sphe.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_sphe:register()

        -- Set local variables for Spear Head
        function SMODS.Jokers.j_spear.loc_def(self)
            return { self.ability.extra.chips}
        end
		-- Calculate
        SMODS.Jokers.j_spear.calculate = function(self, context)
	       if self.ability.name ==  'spearHead' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Clubs") then 
                    return {
                        chips = self.ability.extra.chips,
                        card = self
                    }		
				end
			end
		end
	end
	if config.bulletTip then
        -- Create Bullet Tip
        local buti = {
            loc = {
                name = "Bullet Tip",
                text = {
                    "Played cards with",
                    "{C:diamonds}Diamond{} suit give",
					"{C:chips}+#1#{} Chips when scored"
                }
            },
            ability_name = "bulletTip",
            slug = "bullet",
            ability = {
                extra = {chips = 50}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Shiny Stone
        local joker_buti = SMODS.Joker:new(
            buti.ability_name,
            buti.slug,
            buti.ability,
            { x = 0, y = 0 },
            buti.loc,
            buti.rarity,
            buti.cost,
            buti.unlocked,
            buti.discovered,
            buti.blueprint_compat,
            buti.eternal_compat
        )
        joker_buti:register()

        -- Initialize Sprite for Jokers
        local sprite_buti = SMODS.Sprite:new(
            "j_" .. buti.slug,
            flounderJokers.path,
            "j_" .. buti.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_buti:register()

        -- Set local variables for Bullet Tip
        function SMODS.Jokers.j_bullet.loc_def(self)
            return { self.ability.extra.chips}
        end
		-- Calculate
        SMODS.Jokers.j_bullet.calculate = function(self, context)
	       if self.ability.name ==  'bulletTip' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Diamonds") then 
                    return {
                        chips = self.ability.extra.chips,
                        card = self
                    }		
				end
			end
		end
	end
    if config.missileTip then
        -- Create Missile Tip
        local miti = {
            loc = {
                name = "Missile Tip",
                text = {
                    "Played cards with",
                    "{C:red}Heart{} suit give",
					"{C:chips}+#1#{} Chips when scored"
                }
            },
            ability_name = "missileTip",
            slug = "missile",
            ability = {
                extra = {chips = 50}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Missile Tip
        local joker_miti = SMODS.Joker:new(
            miti.ability_name,
            miti.slug,
            miti.ability,
            { x = 0, y = 0 },
            miti.loc,
            miti.rarity,
            miti.cost,
            miti.unlocked,
            miti.discovered,
            miti.blueprint_compat,
            miti.eternal_compat
        )
        joker_miti:register()

        -- Initialize Sprite for Jokers
        local sprite_miti = SMODS.Sprite:new(
            "j_" .. miti.slug,
            flounderJokers.path,
            "j_" .. miti.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_miti:register()

        -- Set local variables for Missile Tip
        function SMODS.Jokers.j_missile.loc_def(self)
            return { self.ability.extra.chips}
        end
		-- Calculate
        SMODS.Jokers.j_missile.calculate = function(self, context)
	       if self.ability.name ==  'missileTip' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Hearts") then 
                    return {
                        chips = self.ability.extra.chips,
                        card = self
                    }		
				end
			end
		end
	end
    if config.bloodGem then
        -- Create Blood Gem
        local blge = {
            loc = {
                name = "Blood Gem",
                text = {
                    "Played cards with",
                    "{C:red}Heart{} suit give",
					"{C:money}$#1#{} when scored"
                }
            },
            ability_name = "bloodGem",
            slug = "blood",
            ability = {
                extra = {money = 1}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Blood Gem
        local joker_blge = SMODS.Joker:new(
            blge.ability_name,
            blge.slug,
            blge.ability,
            { x = 0, y = 0 },
            blge.loc,
            blge.rarity,
            blge.cost,
            blge.unlocked,
            blge.discovered,
            blge.blueprint_compat,
            blge.eternal_compat
        )
        joker_blge:register()

        -- Initialize Sprite for Jokers
        local sprite_blge = SMODS.Sprite:new(
            "j_" .. blge.slug,
            flounderJokers.path,
            "j_" .. blge.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_blge:register()

        -- Set local variables for Blood Gem
        function SMODS.Jokers.j_blood.loc_def(self)
            return { self.ability.extra.money}
        end
		-- Calculate
        SMODS.Jokers.j_blood.calculate = function(self, context)
	       if self.ability.name ==  'bloodGem' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Hearts") then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra.money
					G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    return {
                        dollars = self.ability.extra.money,
                        card = self
                    }		
				end
			end
		end
	end
    if config.lostGem then
        -- Create Lost Gem
        local loge = {
            loc = {
                name = "Lost Gem",
                text = {
                    "Played cards with",
                    "{C:spades}Spade{} suit give",
					"{C:money}$#1#{} when scored"
                }
            },
            ability_name = "lostGem",
            slug = "lost",
            ability = {
                extra = {money = 1}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Lost Gem
        local joker_loge = SMODS.Joker:new(
            loge.ability_name,
            loge.slug,
            loge.ability,
            { x = 0, y = 0 },
            loge.loc,
            loge.rarity,
            loge.cost,
            loge.unlocked,
            loge.discovered,
            loge.blueprint_compat,
            loge.eternal_compat
        )
        joker_loge:register()

        -- Initialize Sprite for Jokers
        local sprite_loge = SMODS.Sprite:new(
            "j_" .. loge.slug,
            flounderJokers.path,
            "j_" .. loge.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_loge:register()

        -- Set local variables for Lost Gem
        function SMODS.Jokers.j_lost.loc_def(self)
            return { self.ability.extra.money}
        end
		-- Calculate
        SMODS.Jokers.j_lost.calculate = function(self, context)
	       if self.ability.name ==  'lostGem' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Spades") then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra.money
					G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    return {
                        dollars = self.ability.extra.money,
                        card = self
                    }		
				end
			end
		end
	end
    if config.sunkenGem then
        -- Create Sunken Gem
        local suge = {
            loc = {
                name = "Sunken Gem",
                text = {
                    "Played cards with",
                    "{C:clubs}Club{} suit give",
					"{C:money}$#1#{} when scored"
                }
            },
            ability_name = "sunkenGem",
            slug = "sunken",
            ability = {
                extra = {money = 1}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Sunken Gem
        local joker_suge = SMODS.Joker:new(
            suge.ability_name,
            suge.slug,
            suge.ability,
            { x = 0, y = 0 },
            suge.loc,
            suge.rarity,
            suge.cost,
            suge.unlocked,
            suge.discovered,
            suge.blueprint_compat,
            suge.eternal_compat
        )
        joker_suge:register()

        -- Initialize Sprite for Jokers
        local sprite_suge = SMODS.Sprite:new(
            "j_" .. suge.slug,
            flounderJokers.path,
            "j_" .. suge.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_suge:register()

        -- Set local variables for Sunken Gem
        function SMODS.Jokers.j_sunken.loc_def(self)
            return { self.ability.extra.money}
        end
		-- Calculate
        SMODS.Jokers.j_sunken.calculate = function(self, context)
	       if self.ability.name ==  'sunkenGem' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Clubs") then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra.money
					G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    return {
                        dollars = self.ability.extra.money,
                        card = self
                    }		
				end
			end
		end
	end
    if config.imperialTopaz then
        -- Create Imperial Topaz
        local imto = {
            loc = {
                name = "Imperial Topaz",
                text = {
                    "Played cards with",
                    "{C:diamonds}Diamond{} suit give",
					"{C:mult}+#1#{} Mult when scored"
                }
            },
            ability_name = "imperialTopaz",
            slug = "imperial",
            ability = {
                extra = {mult = 7}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Imperial Topaz
        local joker_imto = SMODS.Joker:new(
            imto.ability_name,
            imto.slug,
            imto.ability,
            { x = 0, y = 0 },
            imto.loc,
            imto.rarity,
            imto.cost,
            imto.unlocked,
            imto.discovered,
            imto.blueprint_compat,
            imto.eternal_compat
        )
        joker_imto:register()

        -- Initialize Sprite for Jokers
        local sprite_imto = SMODS.Sprite:new(
            "j_" .. imto.slug,
            flounderJokers.path,
            "j_" .. imto.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_imto:register()

        -- Set local variables for Imperial Topaz
        function SMODS.Jokers.j_imperial.loc_def(self)
            return { self.ability.extra.mult}
        end
		-- Calculate
        SMODS.Jokers.j_imperial.calculate = function(self, context)
	       if self.ability.name ==  'imperialTopaz' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Diamonds") then
                    return {
                        mult = self.ability.extra.mult,
                        card = self
                    }		
				end
			end
		end
	end
    if config.mozambiqueRuby then
        -- Create Mozambique Ruby
        local moru = {
            loc = {
                name = "Mozambique Ruby",
                text = {
                    "Played cards with",
                    "{C:red}Heart{} suit give",
					"{C:mult}+#1#{} Mult when scored"
                }
            },
            ability_name = "mozambiqueRuby",
            slug = "mozambique",
            ability = {
                extra = {mult = 7}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Mozambique Ruby
        local joker_moru = SMODS.Joker:new(
            moru.ability_name,
            moru.slug,
            moru.ability,
            { x = 0, y = 0 },
            moru.loc,
            moru.rarity,
            moru.cost,
            moru.unlocked,
            moru.discovered,
            moru.blueprint_compat,
            moru.eternal_compat
        )
        joker_moru:register()

        -- Initialize Sprite for Jokers
        local sprite_moru = SMODS.Sprite:new(
            "j_" .. moru.slug,
            flounderJokers.path,
            "j_" .. moru.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_moru:register()

        -- Set local variables for Mozambique Ruby
        function SMODS.Jokers.j_mozambique.loc_def(self)
            return { self.ability.extra.mult}
        end
		-- Calculate
        SMODS.Jokers.j_mozambique.calculate = function(self, context)
	       if self.ability.name ==  'mozambiqueRuby' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Hearts") then
                    return {
                        mult = self.ability.extra.mult,
                        card = self
                    }		
				end
			end
		end
	end
    if config.blackDiamond then
        -- Create Black Diamond
        local bldi = {
            loc = {
                name = "Black Diamond",
                text = {
                    "Played cards with",
                    "{C:spades}Spade{} suit give",
					"{C:mult}+#1#{} Mult when scored"
                }
            },
            ability_name = "blackDiamond",
            slug = "black",
            ability = {
                extra = {mult = 7}
            },
            rarity = 2,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Black Diamond
        local joker_bldi = SMODS.Joker:new(
            bldi.ability_name,
            bldi.slug,
            bldi.ability,
            { x = 0, y = 0 },
            bldi.loc,
            bldi.rarity,
            bldi.cost,
            bldi.unlocked,
            bldi.discovered,
            bldi.blueprint_compat,
            bldi.eternal_compat
        )
        joker_bldi:register()

        -- Initialize Sprite for Jokers
        local sprite_bldi = SMODS.Sprite:new(
            "j_" .. bldi.slug,
            flounderJokers.path,
            "j_" .. bldi.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_bldi:register()

        -- Set local variables for Black Diamond
        function SMODS.Jokers.j_black.loc_def(self)
            return { self.ability.extra.mult}
        end
		-- Calculate
        SMODS.Jokers.j_black.calculate = function(self, context)
	       if self.ability.name ==  'blackDiamond' then
		        if context.cardarea == G.play and not context.repetition and context.other_card:is_suit("Spades") then
                    return {
                        mult = self.ability.extra.mult,
                        card = self
                    }		
				end
			end
		end
	end
    if config.gunsandRoses then
        -- Create Guns and Roses
        local guro = {
            loc = {
                name = "Guns and Roses",
                text = {
                    "Retriggers all",
					"played {C:red}Heart{} cards"
                }
            },
            ability_name = "gunsandRoses",
            slug = "guns",
            ability = {
                extra = {loop_amount = 1}
            },
            rarity = 3,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Guns and Roses
        local joker_guro = SMODS.Joker:new(
            guro.ability_name,
            guro.slug,
            guro.ability,
            { x = 0, y = 0 },
            guro.loc,
            guro.rarity,
            guro.cost,
            guro.unlocked,
            guro.discovered,
            guro.blueprint_compat,
            guro.eternal_compat
        )
        joker_guro:register()

        -- Initialize Sprite for Jokers
        local sprite_guro = SMODS.Sprite:new(
            "j_" .. guro.slug,
            flounderJokers.path,
            "j_" .. guro.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_guro:register()

        -- Set local variables for Guns and Roses
        function SMODS.Jokers.j_guns.loc_def(card)
            return { card.ability.extra.loop_amount}
        end
		-- Calculate
        SMODS.Jokers.j_guns.calculate = function(self, context)
	        if context.repetition and context.cardarea == G.play then
                if context.other_card:is_suit("Hearts") then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = self
                    }		
			    end
			end
	    end
    end
    if config.fishandChips then
        -- Create Fish and Chips
        local fich = {
            loc = {
                name = "Fish and Chips",
                text = {
                    "Retriggers all",
					"played {C:clubs}Club{} cards"
                }
            },
            ability_name = "fishandChips",
            slug = "fish",
            ability = {
                extra = {loop_amount = 1}
            },
            rarity = 3,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Fish and Chips
        local joker_fich = SMODS.Joker:new(
            fich.ability_name,
            fich.slug,
            fich.ability,
            { x = 0, y = 0 },
            fich.loc,
            fich.rarity,
            fich.cost,
            fich.unlocked,
            fich.discovered,
            fich.blueprint_compat,
            fich.eternal_compat
        )
        joker_fich:register()

        -- Initialize Sprite for Jokers
        local sprite_fich = SMODS.Sprite:new(
            "j_" .. fich.slug,
            flounderJokers.path,
            "j_" .. fich.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_fich:register()

        -- Set local variables for Fish and Chips
        function SMODS.Jokers.j_fish.loc_def(card)
            return { card.ability.extra.loop_amount}
        end
		-- Calculate
        SMODS.Jokers.j_fish.calculate = function(self, context)
	        if context.repetition and context.cardarea == G.play then
                if context.other_card:is_suit("Clubs") then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = self
                    }		
			    end
			end
	    end
    end
    if config.saltandPepper then
        -- Create Salt and Pepper
        local sape = {
            loc = {
                name = "Salt and Pepper",
                text = {
                    "Retriggers all",
					"played {C:spades}Spade{} cards"
                }
            },
            ability_name = "saltandPepper",
            slug = "salt",
            ability = {
                extra = {loop_amount = 1}
            },
            rarity = 3,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Salt and Pepper
        local joker_sape = SMODS.Joker:new(
            sape.ability_name,
            sape.slug,
            sape.ability,
            { x = 0, y = 0 },
            sape.loc,
            sape.rarity,
            sape.cost,
            sape.unlocked,
            sape.discovered,
            sape.blueprint_compat,
            sape.eternal_compat
        )
        joker_sape:register()

        -- Initialize Sprite for Jokers
        local sprite_sape = SMODS.Sprite:new(
            "j_" .. sape.slug,
            flounderJokers.path,
            "j_" .. sape.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_sape:register()

        -- Set local variables for Salt and Pepper
        function SMODS.Jokers.j_salt.loc_def(card)
            return { card.ability.extra.loop_amount}
        end
		-- Calculate
        SMODS.Jokers.j_salt.calculate = function(self, context)
	        if context.repetition and context.cardarea == G.play then
                if context.other_card:is_suit("Spades") then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = self
                    }		
			    end
			end
	    end
    end
    if config.macaroniandCheese then
        -- Create Macaroni and Cheese
        local mach = {
            loc = {
                name = "Macaroni and Cheese",
                text = {
                    "Retriggers all",
					"played {C:diamonds}Diamond{} cards"
                }
            },
            ability_name = "macaroniandCheese",
            slug = "macaroni",
            ability = {
                extra = {loop_amount = 1}
            },
            rarity = 3,
            cost = 6,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true
        }

        -- Initialize Macaroni and Cheese
        local joker_mach = SMODS.Joker:new(
            mach.ability_name,
            mach.slug,
            mach.ability,
            { x = 0, y = 0 },
            mach.loc,
            mach.rarity,
            mach.cost,
            mach.unlocked,
            mach.discovered,
            mach.blueprint_compat,
            mach.eternal_compat
        )
        joker_mach:register()

        -- Initialize Macaroni and Cheese
        local sprite_mach = SMODS.Sprite:new(
            "j_" .. mach.slug,
            flounderJokers.path,
            "j_" .. mach.slug .. ".png",
            71,
            95,
            "asset_atli"
        )
        sprite_mach:register()

        -- Set local variables for Macaroni and Cheese
        function SMODS.Jokers.j_macaroni.loc_def(card)
            return { card.ability.extra.loop_amount}
        end
		-- Calculate
        SMODS.Jokers.j_macaroni.calculate = function(self, context)
	        if context.repetition and context.cardarea == G.play then
                if context.other_card:is_suit("Diamonds") then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = self
                    }		
			    end
			end
	    end
    end
end


-- Calculate Chips
local evaluate_playref = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(self, e)
    evaluate_playref(self, e)

    for i = 1, #G.jokers.cards do
        local effects = eval_card(G.jokers.cards[i], {
            card = G.consumeables,
            after = true,
            mmc_scored_chips = hand_chips * mult
        })
        if effects.jokers then
            card_eval_status_text(G.jokers.cards[i], 'jokers', nil, 0.3, nil, effects.jokers)
        end
    end
end

function Tag:init(_tag, for_collection, _blind_type)
    self.key = _tag
    local proto = G.P_TAGS[_tag] or G.tag_undiscovered
    self.config = copy_table(proto.config)
    self.pos = proto.pos
    self.name = proto.name
    self.tally = G.GAME.tag_tally or 0
    self.triggered = false
    G.tagid = G.tagid or 0
    self.ID = G.tagid
    G.tagid = G.tagid + 1
    self.ability = {
        orbital_hand = '['..localize('k_poker_hand')..']',
        blind_type = _blind_type
    }
    G.GAME.tag_tally = G.GAME.tag_tally and (G.GAME.tag_tally + 1) or 1
    if not for_collection then self:set_ability() end
end


----------------------------------------------
------------MOD CODE END---------------------