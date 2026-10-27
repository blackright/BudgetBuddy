# Review asset generation prompts

Prepared 2026-10-27 with the built-in `image_gen` tool. Source poster: `C:/Users/Admin/Downloads/SplashScreen.png`. Original logo is copied unchanged; no replacement logo was generated. Output is proposed reconstructed artwork for fidelity review, not a pixel-identical extraction. All calls requested a transparent background.

## Wallet - final prompt

Use case: precise-object-edit / background-extraction. Prepare one proposed animation asset from the supplied BudgetBuddy splash artwork. Edit target: the smiling blue wallet hero in supplied image. Preserve its precise friendly 3D style, blue/cyan material, happy closed eyes, pink cheeks, open smiling mouth, silver clasp, banknotes and white medical card behind it. Remove the entire background, all text, clouds, chart bars, leaves, yellow coin and green growth arrow so those can later be independently layered. Reconstruct only small formerly occluded edges if necessary. Output ONLY the wallet with banknotes and medical card as a centered isolated transparent PNG, with comfortable transparent margins. No text, border, new symbol or extra decoration. This is a proposed derived asset for owner fidelity review, not a new logo. Preserve the source proportions and color identity closely.

## Coin - final prompt

Use case: background-extraction. Edit target: ONLY the gold coin from the supplied BudgetBuddy splash illustration. Prepare one separate proposed animation layer. Reconstruct the complete circular gold coin with its embossed dollar symbol, rounded thick gold rim and soft polished 3D lighting, matching the source yellow gold, angle and friendly style closely. Isolate the coin alone centered on a genuinely transparent background with comfortable margin. Remove wallet, notes, card, arrow, all background and all other text and decorations. Preserve the exact embossed dollar motif as decorative artwork. No new design, no extra coins, no drop-shadow rectangle.

## Arrow - initial prompt

Use case: background-extraction. Edit target: ONLY the green growth arrow from supplied BudgetBuddy splash. Prepare one proposed independent animation layer. Isolate and reconstruct the complete thick 3D lime-to-emerald green arrow: starts at lower left, curves gently upward toward a broad arrowhead pointing upper right, matching the shape, perspective, smooth material and rounded edges of the supplied illustration closely. Output ONLY this single upward-curving arrow centered with generous margin on genuinely transparent background. Remove wallet, coin, banknotes, card, chart bars, leaves, clouds, all background and all text. No chart axes, no extra arrows, no new design. Owner fidelity-review candidate, not a pixel-identical extraction.

## Arrow - first targeted revision prompt

Use case: precise-object-edit. Image 1 is the arrow edit target. Image 2 is the original BudgetBuddy splash reference for color/material. Make one targeted correction to Image 1: REMOVE ALL outer glow, light bloom, colored fog and soft colored aura around the arrow. Keep the arrow geometry, rounded 3D lime/green material, upper-right orientation and proportions unchanged. Match the original source's clean non-glowing edges. The entire area outside the solid arrow must be fully transparent, including generous margins. No shadow haze, no black matte, no background, no text. Output only the clean arrow.

The first two arrow results are unselected intermediates and is not referenced by the preview. No CLI/API fallback, package installation or external account was used. HTML composition and motion are code-native preview work, separate from bitmap editing.

## Arrow - selected third proposal prompt

Extract/recreate ONLY the solid green upward curved arrow shown in this reference. This is a non-emissive matte-to-satin 3D plastic arrow, NOT neon. Keep its original broad rounded head and thick curved shaft pointing upper right. Original lime green top face, dark green side face, source-like simple clean edges. Genuinely transparent PNG. CRITICAL: hard clean anti-aliased silhouette; EVERY pixel beyond the narrow antialias edge must be alpha zero. Absolutely no glow, bloom, haze, colored mist, soft shadow or light outside the solid arrow. No black background. No objects/text besides the solid arrow. Center with margins. This is an isolated layer matching the supplied BudgetBuddy arrow, not a neon redesign.

Review limit: the selected result still shows a soft halo. It remains a proposal, not a certified production cutout.
