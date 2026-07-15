# Sprite Asset Prompt Template

**Version:** 2 — Magenta chroma-key background
**Resolution:** 512×512 maximum (non-square within 512 bound)
**Format:** PNG post-processed to RGBA with transparency
**Compression:** Godot ETC2 (compress/mode=2) for mobile VRAM

## Background Requirement (v2)

**Sprites are generated on a solid flat #FF00FF (magenta) background.**

Post-processing strips the magenta background via connected-component
flood-fill from image corners. The magenta color is chosen because it
does not appear naturally in any object across all five challenge families.

- Background must be solid, flat, uniform #FF00FF with no gradient
- No desk surface, no floor plane, no studio backdrop visible
- Object centered and isolated, full object visible
- No baked shadows on the background
- No reflections on the background
- Code-side `draw_shadow()` is the only shadow source

## Shadow Rule

**No shadows in the generated image.**

All shadows are drawn in code by `VisualStyleSystem.draw_shadow()` for
consistent direction, opacity, and scale. Do not include cast shadows,
drop shadows, or ground contact shadows.

## Prompt Template (v2)

```
A single [OBJECT NAME], isometric 3/4 top-down perspective, seen from
above at about 45 degrees. [MATERIAL AND COLOR DETAILS]. Clean silhouette,
readable at small size. Muted neutral palette, soft ambient lighting from
upper-left. Isolated object centered on a solid flat magenta #FF00FF
background with no gradient. No shadow, no desk surface, no ground plane.
Product photography style, suitable as a mobile game sprite asset.
No text, no labels, no UI elements, no hands.
```

## Per-Object Variables

| Variable | Examples |
|---|---|
| [OBJECT NAME] | smartphone, ceramic mug, wooden pencil, glass bottle |
| [MATERIAL AND COLOR DETAILS] | dark charcoal body with glossy screen, warm gray ceramic with subtle rim highlight, muted ochre wood with metal ferrule |

## Consistency Rules

1. **Background:** Solid flat uniform #FF00FF – no gradient, no gradient edge
2. **Lighting:** Soft ambient from upper-left on every sprite
3. **Perspective:** Isometric 3/4 top-down (~45°) on every sprite
4. **Palette:** Muted, grounded, realistic — no neon, no pure primaries
5. **Shadow:** NONE in the image — code handles it
6. **Edge:** Clean silhouette, no glow, no outline stroke
7. **Labels:** Never include text, numbers, or readable markings
8. **Scale consistency:** Objects at realistic relative sizes
9. **Isolation:** Object centered, fully visible, not cropped

## Manifest Reference

See `app/src/gameplay/families/_shared/VisualStyleSystem.gd` → `MASTER_MANIFEST`
for the complete visual_kind → sprite_path mapping across all five challenge families.
