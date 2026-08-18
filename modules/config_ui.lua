local mod = SMODS.current_mod

mod.config_tab = function()
    local config = mod.config
    return {
        n = G.UIT.ROOT,
        config = {
            align = 'cm', minw = 8, minh = 5.5, padding = 0.25,
            r = 0.1, colour = G.C.BLACK, emboss = 0.05,
        },
        nodes = {
            {
                n = G.UIT.R, config = { align = 'cm', padding = 0.12 },
                nodes = {
                    { n = G.UIT.T, config = { text = 'Presentation', scale = 0.6, colour = G.C.GOLD, shadow = true } },
                },
            },
            {
                n = G.UIT.R, config = { align = 'cm', padding = 0.08 },
                nodes = {
                    create_toggle {
                        label = 'Card sound cues', ref_table = config, ref_value = 'sfx_enabled',
                        active_colour = G.C.GREEN, w = 0, scale = 0.8,
                    },
                },
            },
            {
                n = G.UIT.R, config = { align = 'cm', padding = 0.08 },
                nodes = {
                    create_toggle {
                        label = 'Kinetic trigger effects', ref_table = config, ref_value = 'kinetic_effects',
                        active_colour = G.C.PURPLE, w = 0, scale = 0.8,
                    },
                },
            },
            {
                n = G.UIT.R, config = { align = 'cm', padding = 0.12 },
                nodes = {
                    { n = G.UIT.T, config = {
                        text = 'Balatro Reduced Motion always takes priority.',
                        scale = 0.32, colour = G.C.UI.TEXT_INACTIVE,
                    } },
                },
            },
        },
    }
end
