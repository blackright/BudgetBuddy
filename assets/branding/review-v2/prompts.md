# Phase 9 arrow preparation prompts

Built-in image_gen tool; three calls, with actual transparency requested. Attempts 1 and 2 edit arrow-v3; attempt 3 recreates a raster arrow without a reference image. All retain diffuse halo and are unselected. Copies are preserved in variants/. No original pixels were overwritten. No CLI/API fallback or package installation.

+## Attempt 1

Use case: background-extraction / precise-object-edit. Edit target: the attached BudgetBuddy arrow-v3 layer. Produce a clean production animation layer of the SAME single curved green 3D arrow, oriented from lower left to upper right. Keep the exact silhouette, broad rounded arrowhead, thick curved shaft, lime top face and emerald side face. Make only this correction: REMOVE the diffuse green outer glow and shadow haze completely. The arrow must be solid opaque satin plastic, with only a narrow antialiased edge, surrounded by actual alpha-zero transparency. No neon, bloom, glow, soft shadow or translucent cloud. No black matte, checkerboard, text or other objects. Preserve source proportions and generous transparent margins. This is a revised proposal for user fidelity review, not a new logo.

## Attempt 2

Reconstruct ONLY the referenced curved upward growth arrow as a clean isolated transparent animation asset. Keep its upward-right broad rounded triangular head and rising curved shaft, lime-green face and emerald-green thickness. IMPORTANT change: this must look like a SOLID die-cut opaque plastic object with a razor-clean antialiased silhouette, not a glowing light. REMOVE every trace of luminous green aura outside the silhouette. NO gradients fading outward from edges, NO soft shadow, NO glow, NO bloom, NO surrounding mist. Use restrained matte green shading WITHIN the solid arrow only. Everything outside the solid arrow must have alpha exactly zero. Transparent background. No other objects, no lettering. Match reference shape and friendly 3D style as closely as possible, but prioritize a clean silhouette over highlights.

## Attempt 3

Create one clean, non-glowing 3D green upward growth arrow asset for BudgetBuddy. Transparent background. Thick gently curved shaft starts at bottom left, curves upward to a broad rounded triangular head pointing to the upper right. Solid matte lime-green top face and opaque emerald-green shallow side extrusion. Soft lighting only on the object itself. Crisp clean silhouette, generous empty transparent margins. NO light source, NO emissive surface, NO outer glow, NO aura, NO bloom, NO mist, NO cast shadow. The object is ordinary opaque green plastic, not neon. No wallet, coins, chart, text, background or other objects. Match a playful polished finance app illustration. This is a recreated animation layer for visual approval.


## Clean alternative

layers/arrow-vector-proposal.svg is a separate code-native geometry recreation with two opaque shaded paths, no blur/shadow filter, and no bitmap edits. It is shown as an explicitly labelled alternative, not an exact source extraction. Its silhouette/material differences need owner fidelity approval before implementation. A future Flutter implementation can use a native CustomPainter without adding an SVG package.
