# Card audit ledger

This ledger covers every Joker in the definitive pack. “Pass” means its original calculation path was retained, its tooltip/config values were cross-checked, it has exact 71×95 and 142×190 art, its trigger receives a curated presentation cue, and its key is collision-safe under the `fj` namespace. Optional legacy suit families remain dependency-gated rather than silently spawning with invalid suits.

| # | Card | Family | Result | Curated QA note |
|---:|---|---|---|---|
| 1 | Common Joker | Rarity ladder | Pass | Uncommon Tag progression retained; independent RNG stream. |
| 2 | Uncommon Joker | Rarity ladder | Pass | Rare Tag progression retained; independent RNG stream. |
| 3 | Rare Joker | Rarity ladder | Pass | Random Legendary Joker creation retains buffer/space behavior. |
| 4 | Legendary Joker | Rarity ladder | Pass | Legendary Tag progression and rarity retained. |
| 5 | Lucky Stone | Stone | Pass | Spade probability and XMult retained. |
| 6 | Cracked Stone | Stone | Pass | Club probability and XMult retained. |
| 7 | Shiny Stone | Stone | Pass | Diamond probability and XMult retained. |
| 8 | Spear Head | Weapon | Pass | Spade chip scoring retained. |
| 9 | Bullet Tip | Weapon | Pass | Club chip scoring retained. |
| 10 | Missile Tip | Weapon | Pass | Diamond chip scoring retained. |
| 11 | Blood Gem | Money gem | Pass | Heart payout retained. |
| 12 | Lost Gem | Money gem | Pass | Spade payout retained. |
| 13 | Sunken Gem | Money gem | Pass | Club payout retained. |
| 14 | Imperial Topaz | Mult gem | Pass | Diamond Mult retained. |
| 15 | Mozambique Ruby | Mult gem | Pass | Heart Mult retained. |
| 16 | Black Diamond | Mult gem | Pass | Spade Mult retained. |
| 17 | Guns and Roses | Pair/retrigger | Pass | Original paired-suit repetition retained. |
| 18 | Fish and Chips | Pair/retrigger | Pass | Original paired-suit repetition retained. |
| 19 | Salt and Pepper | Pair/retrigger | Pass | Original paired-suit repetition retained. |
| 20 | Macaroni and Cheese | Pair/retrigger | Pass | Original paired-suit repetition retained. |
| 21 | The Robber | Transformer | Pass | Spade-to-Steel mutation retained; success cue added. |
| 22 | Hungry Sorcerer | Transformer | Pass | Club-to-Lucky mutation retained; success cue added. |
| 23 | Glass Blower | Transformer | Pass | Diamond-to-Glass mutation retained; success cue added. |
| 24 | Born Wild | Transformer | Pass | Heart-to-Wild mutation retained; success cue added. |
| 25 | Over the Rainbow | Transformer | Pass | Flush-to-Polychrome behavior retained; invalid legacy syntax fixed. |
| 26 | Witch Doctor | Creator | Pass | Codex Arcanum gate and Tarot creation retained. |
| 27 | Palm Reader | Creator | Pass | Tarot creation and consumeable-space guard retained. |
| 28 | Painter | Creator | Pass | MoreFluff Colour creation dependency-gated. |
| 29 | Director | Creator | Pass | Reverie Cine creation dependency-gated. |
| 30 | Orbit | Creator | Pass | Planet creation repaired to use a defined Planet pool and return. |
| 31 | Crystalized Stone | Music | Pass | Notes XMult retained; Musical Suit dependency-gated. |
| 32 | Crystal Magazine | Music | Pass | Notes chip scoring retained. |
| 33 | Pink Panther | Music | Pass | Notes Mult retained. |
| 34 | Love Gem | Music | Pass | Notes payout retained. |
| 35 | Rhythm and Blues | Music | Pass | Notes retrigger retained. |
| 36 | Enhanced Sediment | Music | Pass | Notes enhancement mutation retained; visible spelling corrected. |
| 37 | Luxury Stone | Crowns | Pass | Crown XMult retained; Crowns Suit dependency-gated. |
| 38 | Sun Gun | Crowns | Pass | Crown chip scoring retained. |
| 39 | Holy Gem | Crowns | Pass | Crown payout retained. |
| 40 | Gold Bar | Crowns | Pass | Crown Mult retained. |
| 41 | Bread and Butter | Crowns | Pass | Crown retrigger retained. |
| 42 | Kings Wrath | Crowns | Pass | Crown enhancement mutation retained. |
| 43 | Moon Stone | Moons | Pass | Moon XMult retained; SixSuit dependency-gated. |
| 44 | Space Laser | Moons | Pass | Moon chip scoring retained. |
| 45 | Apollo Gem | Moons | Pass | Moon payout retained. |
| 46 | Meteor Piece | Moons | Pass | Moon Mult retained. |
| 47 | Moon and Sun | Moons | Pass | Moon retrigger retained. |
| 48 | Mathematician | Moons | Pass | Moon enhancement mutation retained; display spelling corrected without changing save key. |
| 49 | Sun Stone | Stars | Pass | Star XMult retained. |
| 50 | Solar Flare | Stars | Pass | Star chip scoring retained. |
| 51 | Radiation Gem | Stars | Pass | Star payout retained. |
| 52 | Star Plasma | Stars | Pass | Star Mult retained. |
| 53 | Sun and Moon | Stars | Pass | Star retrigger retained. |
| 54 | The Boss | Stars | Pass | Star enhancement mutation retained. |
| 55 | Loaded Stone | Dice suite | Pass | Sealed-card 1-in-4 X1.5 risk/reward; no unconditional scaling. |
| 56 | Brass Cup | Dice suite | Pass | +25 Chips per sealed scoring card; common baseline. |
| 57 | Payout Gem | Dice suite | Pass | $1 per sealed scoring card; requires deck investment. |
| 58 | House Edge | Dice suite | Pass | X2 requires both lucky and cursed seals in one scoring hand. |
| 59 | Double Down | Dice suite | Pass | One retrigger per sealed scoring card. |
| 60 | The Croupier | Dice suite | Pass | Non-Blueprint 1-in-6 seal creation; random blessing/curse preserves tension. |

## Canonical non-Joker objects

| Object | Result | QA note |
|---|---|---|
| Dice Seal | Pass | Native animated Seal object; doubles listed probabilities on discard, then removes all Dice Seals. |
| Cursed Dice Seal | Pass | Native animated Seal object; halves listed probabilities on discard, then removes all Cursed Dice Seals. |
| Oops! All 20s | Pass | Native Spectral; exactly one highlighted card; applies Dice Seal. |
| Oops! No 20s | Pass | Native Spectral; exactly one highlighted card; applies Cursed Dice Seal. |
