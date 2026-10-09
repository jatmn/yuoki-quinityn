# Quinityn artwork

## Landscape artwork and mod thumbnail

[`quinityn-landscape.png`](quinityn-landscape.png) preserves the original
full-resolution generated image, unchanged, for the main README. It shares
the provenance and generation prompt below with the thumbnail.

[`../thumbnail.png`](../thumbnail.png) is the mod portal and in-game mod-browser
thumbnail. [Factorio's mod structure documentation](https://lua-api.factorio.com/latest/auxiliary/mod-structure.html)
specifies `thumbnail.png` beside `info.json` and recommends 144×144 pixels.
The existing package tool includes it at that location inside the mod ZIP.

Generated with the built-in imagegen tool on 2026-10-08 from the landscape
description in this repository's README: ruined industry, ash and slag,
purple unicomp seas and dead trees. No reference images or copied game assets
were supplied. This is concept artwork, not a screenshot or a claim about
the original Yuoki stories. YuokiTani's world/lore credit remains in
[NOTICE](../NOTICE). Copyrightable contributions follow the project's
CC BY-NC-SA 4.0 license; no exclusive copyright is asserted over purely
AI-generated elements.

The square output was downscaled with ImageMagick's Lanczos filter to a
144×144 RGB PNG, stripped of metadata and visually inspected at that size.

Final generation prompt:

> Use case: stylized-concept. Asset type: square mod-browser thumbnail for Yuoki Industries: Quinityn, designed to read clearly when reduced to 144x144 pixels. Create original painterly science-fiction industrial concept artwork: a ruined heavy industrial outpost on a rocky ash-grey and brown slag peninsula surrounded by vivid violet liquid unicomp seas. One large weathered steel processing tower and a few chunky pipes dominate the silhouette, collapsed machinery near the shore, sparse dead trees, hazy polluted lavender sky. Three-quarter elevated landscape view, strong simple shapes, bright violet sea provides clean separation from warm rusty metal and charcoal rock, restrained pale amber machinery highlights. Gritty painted game-art materials, bold readable composition, not a screenshot. Full-bleed opaque square image, no lettering, no words, no logo, no badge, no border, no watermark. No reference images or copied game assets.

## Inventory icons

See [NOTICE](../NOTICE) for credits, licenses and the mixed-reference science
icon's Wube artwork exception. Generated output does not erase rights in its
references; the repository does not offer Wube-derived artwork under CC terms.

The two icons were generated with the built-in imagegen tool on 2026-10-07, then downscaled with ImageMagick to 256×256 RGBA PNGs. They retain transparent alpha. Prototype `icon_size` is 256; Factorio displays them at the appropriate UI size.

`icons/quinityn-salvage.png` references Yuoki's reinforced gear, Durotal structure element and conductive wire. `icons/quinityn-science.png` uses the [Fulgora science bottle](https://wiki.factorio.com/Electromagnetic_science_pack) as a shape reference and Yuoki's Technic Sign as the badge reference. Original reference files remain outside the mod package.

## Final generation prompts

The science badge was enlarged again after the user supplied its actual 32px inventory appearance. The final icon was inspected at 32px, not just 64px. Final edit prompt (built-in imagegen):

Use case: precise-object-edit. Asset type: transparent Factorio inventory science pack icon. Edit the supplied exact bottle. Change ONLY the front Technic Sign badge: enlarge its entire dark hexagonal plate and red cogwheel to approximately 80 percent of the round bottle bulb width (about 1.8 times the current badge width), centered on the lower front bulb. The red cog and central concentric circles must remain crisp, chunky and clearly readable when the entire image is only 32 by 32 pixels. Use strong red highlights and dark edging, no extra fine markings. Keep the identical bottle silhouette, scale, neck and metal stopper, glass reflections and violet unicomp liquid. Keep a visible purple glass/liquid rim around the badge. Keep the same tight square framing, transparent background, no lettering, no shadow outside the bottle, no other objects. Actual alpha transparency.

### Salvage

Use case: stylized-concept. Asset type: transparent Factorio inventory item icon for Yuoki industrial salvage, square. The three supplied images are component references, not separate output icons: a blue-grey reinforced steel gear, a cyan-grey Durotal structural frame, and copper conductive wire. Render ONE compact irregular compressed lump of industrial junk composed of a broken toothed gear with several teeth missing, bent and crushed structural frame plates, and tangled snapped copper wire. Faithful gritty painted 3D Factorio/Yuoki icon style, isometric three-quarter view, strong readable silhouette at 64 pixels, upper-left highlights, dark crevices, restrained blue-grey steel/cyan oxidized metal and warm copper. Entire object contained in frame with small transparent margin. No background, no ground plane, no text, no border, no extra unrelated objects. Genuine transparent alpha. Output a single square icon.

### Science

Use case: stylized-concept. Asset type: single transparent square Factorio science-pack inventory icon. Image 1 is the Fulgora electromagnetic science bottle style/shape reference. Image 2 is the Yuoki Technic Sign badge reference. Make an original small round-bottom glass science bottle following image 1 silhouette: round bulb, short narrow neck, metallic silver stopper, three-quarter isometric painted 3D game icon, upper-left highlights. Replace pink contents with dark violet and luminous purple liquid unicomp, approximately #8726b2 with lavender highlights, liquid visibly held inside translucent glass. On the front of the bulb attach a SMALL label/badge depicting image 2's red cogwheel with concentric central rings on a dark hexagonal backing; badge occupies about one quarter of bulb width so the purple liquid stays dominant. No lettering. Strong readable silhouette suitable for a 64px inventory icon, realistic worn Factorio materials without excessive microdetail. Entire bottle centered, modest transparent padding, no background, no floor, no border, no additional objects. Genuine alpha transparency.
