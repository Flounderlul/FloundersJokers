SMODS.Atlas {
    key = 'effect_motes', path = 'fj_effect_motes.png', px = 16, py = 16,
    disable_mipmap = true,
}

local family_slugs = {
    arcana = { 'common', 'uncommon', 'rare', 'legendary' },
    stone = { 'lucky', 'cracked', 'shiny', 'crystalized', 'luxury', 'moonst', 'sunst', 'loaded_stone' },
    weapon = { 'spear', 'bullet', 'missile', 'crystalm', 'sung', 'spacel', 'solarf', 'brass_cup' },
    coin = { 'blood', 'lost', 'sunken', 'lovege', 'holyge', 'radge', 'apollog', 'payout_gem' },
    gem = { 'imperial', 'mozambique', 'pinkpa', 'black', 'goldba', 'meteorpi', 'starpl', 'house_edge' },
    echo = { 'guns', 'fish', 'salt', 'macaroni', 'rhythm', 'bread', 'moonan', 'sunan', 'double_down' },
    transform = { 'robberh', 'hungryso', 'glassb', 'bornw', 'overt', 'enhanceds', 'kingsw', 'mathma', 'thebo' },
    conjure = { 'witchdo', 'palmr', 'paint', 'direc', 'orb' },
    dice = { 'croupier' },
}

local slug_family = {}
for family, slugs in pairs(family_slugs) do
    for _, slug in ipairs(slugs) do slug_family[slug] = family end
end

local last_played = setmetatable({}, { __mode = 'k' })

local glint_shader = {
    arcana = 'hologram', stone = 'voucher', weapon = 'voucher',
    coin = 'voucher', gem = 'hologram', echo = 'hologram',
    transform = 'hologram', conjure = 'hologram', dice = 'voucher',
    cursed = 'negative_shine',
}

local mote_pos = {
    arcana = 3, stone = 0, weapon = 0, coin = 0, gem = 0,
    echo = 3, transform = 3, conjure = 3, dice = 1, cursed = 2,
}

local family_dynamics = {
    arcana = { drift = 0.08, lift = 0.24, spin = 0.12 },
    stone = { drift = 0.03, lift = 0.14, spin = 0.04 },
    weapon = { drift = 0.12, lift = 0.10, spin = -0.08 },
    coin = { drift = -0.06, lift = 0.16, spin = 0.16 },
    gem = { drift = 0.05, lift = 0.22, spin = 0.10 },
    echo = { drift = -0.08, lift = 0.20, spin = -0.12 },
    transform = { drift = 0.10, lift = 0.26, spin = 0.18 },
    conjure = { drift = -0.10, lift = 0.25, spin = -0.16 },
    dice = { drift = 0.07, lift = 0.18, spin = 0.22 },
    cursed = { drift = -0.07, lift = 0.18, spin = -0.22 },
}

local function center_slug(card)
    local key = card and card.config and card.config.center and card.config.center.key or ''
    key = key:gsub('^j_', ''):gsub('^fj_', '')
    return key
end

local function stable_pitch(slug)
    local sum = 0
    for index = 1, #slug do sum = sum + string.byte(slug, index) end
    return 1 + ((sum % 9) - 4) * 0.018
end

function FJ_VISUAL_EFFECT(card, requested_family)
    local config = SMODS.current_mod and SMODS.current_mod.config
    if not card or (config and config.kinetic_effects == false) or (G.SETTINGS and G.SETTINGS.reduced_motion) then return end
    local now = G.TIMERS and G.TIMERS.REAL or 0
    card.fj_effect_family = requested_family or slug_family[center_slug(card)] or 'arcana'
    card.fj_effect_started = now
    card.fj_effect_until = now + 0.32

    if card.children and card.T then
        local mote = card.children.fj_effect_mote
        if not mote then
            local size = 0.42
            mote = SMODS.create_sprite(card.T.x, card.T.y, size, size, 'fj_effect_motes', { x = 0, y = 0 })
            mote.custom_draw = true
            mote.states.hover = card.states.hover
            mote.states.click = card.states.click
            mote.states.collide.can = false
            mote:set_role {
                major = card, role_type = 'Minor', draw_major = card,
                offset = { x = (card.T.w - size) / 2, y = (card.T.h - size) / 2 },
                xy_bond = 'Strong',
            }
            card.children.fj_effect_mote = mote
        end
        mote:set_sprite_pos { x = mote_pos[card.fj_effect_family] or 0, y = 0 }
    end
    if card.juice_up then card:juice_up(0.12, 0.08) end
end

function FJ_EFFECT(card, requested_family)
    if not card then return end
    local now = G.TIMERS and G.TIMERS.REAL or 0
    if last_played[card] and now - last_played[card] < 0.09 then return end
    last_played[card] = now

    local slug = center_slug(card)
    local family = requested_family or slug_family[slug] or 'arcana'
    if FJ_PLAY_SOUND then
        local volume = (SMODS.current_mod and SMODS.current_mod.config and SMODS.current_mod.config.sfx_volume) or 0.34
        FJ_PLAY_SOUND(family, stable_pitch(slug), volume)
    end
    FJ_VISUAL_EFFECT(card, family)
end

-- A short post-edition accent: it preserves editions/seals and exists only for
-- the 320 ms success window. Reduced Motion disables the entire added layer.
SMODS.DrawStep {
    key = 'trigger_glint',
    order = 21,
    conditions = { vortex = false, facing = 'front' },
    func = function(card)
        local config = SMODS.current_mod and SMODS.current_mod.config
        if (config and config.kinetic_effects == false) or (G.SETTINGS and G.SETTINGS.reduced_motion) then return end
        local now = G.TIMERS and G.TIMERS.REAL or 0
        if not card.fj_effect_until or now >= card.fj_effect_until or not card.children.center then return end
        local progress = math.max(0, math.min(1, (now - (card.fj_effect_started or now)) / 0.32))
        local spring = math.sin(progress * math.pi * 3.5) * math.exp(-5.5 * progress)
        card.ARGS.send_to_shader = card.ARGS.send_to_shader or {}
        card.children.center:draw_shader(
            glint_shader[card.fj_effect_family] or 'voucher',
            nil,
            card.ARGS.send_to_shader,
            nil,
            card.children.center,
            0.018 * spring,
            0.012 * spring
        )
    end,
}

-- One semantic mote follows a damped ballistic arc over the shader response.
-- It is a card child, so movement/tilt remain locked to Balatro's own physics.
SMODS.DrawStep {
    key = 'trigger_mote',
    order = 22,
    conditions = { vortex = false, facing = 'front' },
    func = function(card)
        local config = SMODS.current_mod and SMODS.current_mod.config
        if (config and config.kinetic_effects == false) or (G.SETTINGS and G.SETTINGS.reduced_motion) then return end
        local now = G.TIMERS and G.TIMERS.REAL or 0
        local mote = card.children and card.children.fj_effect_mote
        if not mote or not card.fj_effect_until or now >= card.fj_effect_until then return end

        local progress = math.max(0, math.min(1, (now - (card.fj_effect_started or now)) / 0.32))
        local dynamics = family_dynamics[card.fj_effect_family] or family_dynamics.arcana
        local size = 0.42
        local spring = math.sin(progress * math.pi * 4) * math.exp(-5 * progress)
        mote.role.offset.x = (card.T.w - size) / 2 + dynamics.drift * progress + 0.025 * spring
        mote.role.offset.y = (card.T.h - size) / 2 - dynamics.lift * (progress - 0.35 * progress * progress)
        mote:draw_shader(
            'dissolve', nil, nil, nil, card.children.center,
            0.05 * (1 - progress), dynamics.spin * progress + 0.04 * spring
        )
    end,
}

-- Wrap registered definitions before injection and injected centers on reload.
-- The calculation result is returned byte-for-byte untouched.
local function wrap_centers(centers)
    for _, center in pairs(centers or {}) do
        if center.set == 'Joker' and center.mod and center.mod.id == 'flounderjokers'
            and type(center.calculate) == 'function' and not center.fj_presentation_wrapped then
            local calculate_ref = center.calculate
            center.calculate = function(self, card, context)
                local result, triggered = calculate_ref(self, card, context)
                if result or triggered then FJ_EFFECT(card) end
                return result, triggered
            end
            center.fj_presentation_wrapped = true
        end
    end
end

wrap_centers(SMODS.Centers)
wrap_centers(G.P_CENTERS)
