# Remaster art direction

## Native-scale finishing standard

The 71×95 texture is the visual authority. High-resolution composition masters are edge-aware smoothed, reduced to a maximum 24-colour per-card palette with rare semantic accents retained, and inspected for low-contrast micro-texture chatter before export. The 142×190 companion must be an exact nearest-neighbour reconstruction of that native texture—never a separately cropped or differently aligned illustration.

Deck backs, Vouchers, and Blind emblems use transparent surroundings and tightly occupied silhouettes. Their six-frame sheets share identical cell geometry and subject placement; animation may move a glint or small semantic accent but cannot resize or drift the main object. The automated gate requires at least 30% foreground occupancy for every progression frame.

## The visual system

Every card follows the same production rules: a tall vintage Joker frame, vertical `JOKER` lettering, a source-derived limited palette, crisp pixel clusters, controlled dithering, printed-paper texture, strong thumbnail silhouette, layered light, and a unique mechanic-driven centerpiece.

The collection is unified by treatment, not by repeating one object. Each card should feel like a different drawer in Flounder's curio cabinet.

## Family language

- **Rarity:** escalating reroll machinery, from a wooden shop crank to a cosmic negative-tag press.
- **Stones:** unique relics and instruments—a pierced luck stone, stitched fault, jeweler's wheel, geode gramophone, royal reliquary, lunar astrolabe, and solar dial.
- **Weapons:** complete environments—a forest shrine, gunsmith bench, launch complex, musical armory, royal solar sidearm, lunar observatory, and star forge.
- **Gems:** narrative discoveries and displays—apothecary, expedition map, seafloor helmet, imperial desk, coastal treasure case, security vault, cathedral reliquary, and lunar lab.
- **Retriggers:** recurrence shown through echoes, performance, doubled motion, orbit trails, and staged repetition.
- **Enhancements:** the transformation is visibly underway in a workshop, forge, cauldron, carnival, observatory, or card press.
- **Dice suite:** one coherent casino-curio family expressed through six different material stories: a weighted geode, brass dice cup, mechanical payout gem, impossible house table, mirrored scoring bell, and faceless croupier. Emerald and crimson are accents, not full-card recolours.

## Animated token language

The 3.0 progression chapter extends the curio-cabinet premise beyond Jokers. Loaded Deck uses emerald felt and brass dice corners; Workshop Deck uses a scarred maker's bench; Curator Deck uses a dark illuminated cabinet. Boss Blinds reduce their concepts to quarry stone, lock brass, marquee light, and fractured silver. Voucher art remains tactile: wax, press, glass case, velvet cabinet. Each uses a six-frame diagonal material glint at 6 fps, frozen by Reduced Motion.

Dice and Cursed Dice Seals are small transparent overlays, so silhouette and value separation take priority over card-scale detail. Each token uses one central D20/eye emblem, a heavy wax-and-enamel rim, and ample transparent padding. The native twelve-frame sheet performs restrained squash/stretch, secondary settle, and a traveling specular glint at 8 fps. Alpha-centroid drift is capped by QA so it never reads as rank/suit movement or obscures card information.

Trigger feedback uses a four-cell semantic mote atlas—gold, Dice, cursed, and arcane—over one 320 ms damped ballistic arc. A separate post-edition DrawStep supplies the family glint. Both layers bind to the card's existing transform rather than replacing Balatro's card physics, and both are suppressed by Reduced Motion.

The animation is deliberately authored as presentation rather than power feedback: gameplay state remains communicated by badge colour, tooltip text, and the discard result. This keeps the seals readable with editions, high-contrast palettes, and other render-layer mods.

## Prompt record

The built-in image generation workflow used a source image for each card as the frame and palette reference. The shared final prompt was:

> Redesign this card as its own final mechanic-driven scene. Preserve the creator's tall Joker-card proportions, rounded border, vertical lettering, and palette family. Replace temporary or repeated center art with a singular narrative composition tied to the card's name and effect. Use a decisive focal action, supporting props, foreground/background separation, atmospheric light, material-specific rendering, crisp retro pixel clusters, controlled dithering, and vintage print texture. Keep it readable at 71x95. No generic floating icon, repeated template, extra text, watermark, logo, photorealism, or glossy 3D.

Each card then received its own subject specification—for example, Missile Tip became a heart-marked launch complex, Lucky Stone a clover-pierced hag stone, Crystalized Stone a geode gramophone, Blood Gem an apothecary chalice, and The Boss a private star-casino office.

The progression atlas was generated in built-in ImageGen mode as a strict eleven-object contact sheet, then cropped and nearest-neighbour reduced into runtime atlases. The preserved source is `archive/remaster-sources/fj-progression-source.png`; names and rules are rendered by Balatro rather than baked into art.
