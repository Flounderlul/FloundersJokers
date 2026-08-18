local files = {
    arcana = 'arcana.ogg',
    stone = 'stone.ogg',
    weapon = 'weapon.ogg',
    coin = 'coin.ogg',
    gem = 'gem.ogg',
    echo = 'echo.ogg',
    transform = 'transform.ogg',
    conjure = 'conjure.ogg',
    dice = 'dice.ogg',
    cursed = 'cursed.ogg',
    deck = 'deck.ogg',
    voucher = 'voucher.ogg',
    blind = 'blind.ogg',
    challenge = 'challenge.ogg',
}

for key, path in pairs(files) do
    if SMODS.NFS.getInfo(SMODS.current_mod.path .. 'assets/sounds/' .. path) then
        SMODS.Sound { key = key, path = path }
    end
end

local fallback = {
    arcana = 'holo1', stone = 'chips1', weapon = 'chips2', coin = 'coin1',
    gem = 'multhit1', echo = 'tarot2', transform = 'tarot1',
    conjure = 'timpani', dice = 'generic1', cursed = 'glass2',
    deck = 'card1', voucher = 'timpani', blind = 'cancel', challenge = 'win',
}

-- Measured trims compensate only for the few deliberately high-crest masters
-- that read quieter at equal peak. Values stay below the release peak ceiling
-- in normal single-voice playback.
local family_trim = {
    stone = 1.12,
    weapon = 1.02,
    dice = 1.09,
    cursed = 1.06,
}

-- A tiny shared voice budget keeps several different Jokers resolving in one
-- scoring burst without muting any card's identity. The first cue is untouched;
-- later cues inside the 180 ms mix window are progressively tucked underneath.
local recent_plays = {}
local mix_window = 0.18

local function density_gain(now)
    for index = #recent_plays, 1, -1 do
        if now - recent_plays[index] > mix_window then table.remove(recent_plays, index) end
    end
    local gain = math.max(0.58, 1 - #recent_plays * 0.16)
    recent_plays[#recent_plays + 1] = now
    return gain
end

function FJ_PLAY_SOUND(key, pitch, volume)
    local config = SMODS.current_mod and SMODS.current_mod.config
    if config and config.sfx_enabled == false then return end

    local now = (G and G.TIMERS and G.TIMERS.REAL)
        or (love and love.timer and love.timer.getTime()) or 0
    local safe_pitch = math.max(0.92, math.min(1.08, pitch or 1))
    local safe_volume = math.max(0, math.min(
        0.45,
        (volume or 0.34) * (family_trim[key] or 1) * density_gain(now)
    ))
    local full_key = 'fj_' .. key
    if SMODS.Sounds and SMODS.Sounds[full_key] then
        play_sound(full_key, safe_pitch, safe_volume)
    elseif fallback[key] then
        play_sound(fallback[key], safe_pitch, safe_volume * 0.78)
    end
end
