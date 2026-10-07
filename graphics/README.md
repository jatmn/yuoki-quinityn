# Quinityn inventory icons

The two icons were generated with the built-in imagegen tool on 2026-10-07, then downscaled with ImageMagick to 256×256 RGBA PNGs. They retain transparent alpha. Prototype `icon_size` is 256; Factorio displays them at the appropriate UI size.

`icons/quinityn-salvage.png` references Yuoki's reinforced gear, Durotal structure element and conductive wire. `icons/quinityn-science.png` uses the [Fulgora science bottle](https://wiki.factorio.com/Electromagnetic_science_pack) as a shape reference and Yuoki's Technic Sign as the badge reference. Original reference files remain outside the mod package.

## Final generation prompts

The science badge was subsequently enlarged at the user's request. Final edit prompt (built-in imagegen):

Use case: precise-object-edit. Edit this exact transparent Factorio science bottle inventory icon. Change ONLY the Technic Sign badge on the front: enlarge the complete dark hexagonal backing and red cogwheel together by approximately 25 percent, keeping the badge centered in its existing location and attached naturally to the front glass. It should be easier to read at 64px inventory size. Preserve exactly the bottle silhouette, bottle scale and framing, glass, metallic stopper, violet unicomp liquid color and level, lighting and all other details. Do not enlarge or redesign the bottle. No lettering or new elements. Preserve genuine background alpha transparency. Single square icon.

### Salvage

Use case: stylized-concept. Asset type: transparent Factorio inventory item icon for Yuoki industrial salvage, square. The three supplied images are component references, not separate output icons: a blue-grey reinforced steel gear, a cyan-grey Durotal structural frame, and copper conductive wire. Render ONE compact irregular compressed lump of industrial junk composed of a broken toothed gear with several teeth missing, bent and crushed structural frame plates, and tangled snapped copper wire. Faithful gritty painted 3D Factorio/Yuoki icon style, isometric three-quarter view, strong readable silhouette at 64 pixels, upper-left highlights, dark crevices, restrained blue-grey steel/cyan oxidized metal and warm copper. Entire object contained in frame with small transparent margin. No background, no ground plane, no text, no border, no extra unrelated objects. Genuine transparent alpha. Output a single square icon.

### Science

Use case: stylized-concept. Asset type: single transparent square Factorio science-pack inventory icon. Image 1 is the Fulgora electromagnetic science bottle style/shape reference. Image 2 is the Yuoki Technic Sign badge reference. Make an original small round-bottom glass science bottle following image 1 silhouette: round bulb, short narrow neck, metallic silver stopper, three-quarter isometric painted 3D game icon, upper-left highlights. Replace pink contents with dark violet and luminous purple liquid unicomp, approximately #8726b2 with lavender highlights, liquid visibly held inside translucent glass. On the front of the bulb attach a SMALL label/badge depicting image 2's red cogwheel with concentric central rings on a dark hexagonal backing; badge occupies about one quarter of bulb width so the purple liquid stays dominant. No lettering. Strong readable silhouette suitable for a 64px inventory icon, realistic worn Factorio materials without excessive microdetail. Entire bottle centered, modest transparent padding, no background, no floor, no border, no additional objects. Genuine alpha transparency.
