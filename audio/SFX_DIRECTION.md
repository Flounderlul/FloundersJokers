# Sound direction

Flounder's Jokers uses fourteen short, dry effect families. Every Joker and progression object receives a stable semantic cue without competing with Balatro's score mix.

| Family | Cards | Mix intent |
|---|---|---|
| Arcana | rarity/tag progression | airy paper flick + restrained glass glint |
| Stone | XMult stones | compact mineral knock + low crystalline tail |
| Weapon | chip tools/weapons | muted mechanical snap; no gunshot realism |
| Coin | money gems | single soft token drop; no coin cascade |
| Gem | Mult valuables | short faceted shimmer with a warm body |
| Echo | retrigger pairs | two quiet, rhythmically exact taps |
| Transform | enhancement makers | rising paper-to-glass morph sweep |
| Conjure | consumable creators | small dimensional pop + card flutter |
| Dice | Dice Seal suite | one felt-table D20 roll and settled click |
| Cursed | Cursed Dice Seal | reversed D20 rattle with a low, brief sting |
| Deck | deck setup | felt roll and compact material knock |
| Voucher | voucher redemption | brass token, paper seal, and restrained lift |
| Blind | Boss Blind activation | low warning body with a short mechanical edge |
| Challenge | mastery completion | bright arcane resolve and single token accent |

Master design constraints: 0.65–1.15 seconds, no speech, no melody, no sub-bass, no long reverb, no clipping, centered mono-compatible image, and enough transient separation to sit beneath score-counting sounds.

Every cue is high-passed at 90 Hz, low-passed at 12 kHz, loudness-normalized around -22 LUFS, and true-peak limited. Short high-crest-factor cues receive a measured second-stage body lift into a non-auto-gaining limiter when one-pass normalization cannot reach the family window without exceeding the peak ceiling.

Runtime mastering adds conservative measured trims only to Stone, Weapon, Dice, and Cursed—the high-crest families that otherwise read slightly quieter at equal peak. A shared 180 ms voice budget leaves the first trigger untouched and progressively tucks overlapping triggers to a 58% floor. Pitch is clamped to 0.92–1.08 and final per-voice gain to 0.45, preserving card identity without allowing a retrigger chain to dominate Balatro's score mix.
