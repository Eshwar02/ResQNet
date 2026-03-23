# Design System Document

## 1. Overview & Creative North Star: "The Calm Sentinel"

In high-stakes emergency environments, design must do more than just function; it must reassure. The Creative North Star for this system is **"The Calm Sentinel."** We move away from the frantic, cluttered aesthetics of traditional emergency tools toward a high-end editorial experience that prioritizes absolute clarity through sophisticated minimalism.

By utilizing **intentional asymmetry** and **tonal depth**, we create a UI that feels like a premium, living assistant. We break the "template" look by using exaggerated whitespace and a "floating" architecture. The goal is to reduce cognitive load to near zero, ensuring that in a moment of crisis, the user's eye is led naturally to the single most important action.

---

## 2. Colors: Tonal Authority

Our palette is not just about aesthetics; it is a hierarchy of urgency. We use a sophisticated Material 3-based logic to ensure accessibility while maintaining a bespoke, editorial feel.

### The "No-Line" Rule
**Strict Mandate:** Designers are prohibited from using 1px solid borders for sectioning. Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` (#F3F4F5) section sitting on a `surface` (#F8F9FA) background creates a professional, soft-touch boundary that feels integrated rather than boxed in.

### Color Tokens
- **Primary (The Pulse):** `primary` (#BC0100) and `primary_container` (#EB0000). Use these exclusively for life-saving actions.
- **Secondary (The Information):** `secondary` (#526069) and `tertiary` (#2858B2). These provide a "Soft Blue" calm for non-critical data.
- **Surface Hierarchy:** 
    - `surface_container_lowest` (#FFFFFF) for high-priority cards.
    - `surface` (#F8F9FA) for the main background.
    - `surface_dim` (#D9DADB) for inactive or backgrounded elements.

### The "Glass & Gradient" Rule
To elevate the app above "standard" UI, use **Glassmorphism** for floating action sheets. Apply `surface_container_low` at 80% opacity with a `20px` backdrop blur. For the main Emergency CTA, use a subtle radial gradient transitioning from `primary` (#BC0100) to `on_primary_fixed_variant` (#930100) to give the button a tactile, "weighted" soul.

---

## 3. Typography: Editorial Clarity

We utilize two distinct typefaces to balance authority with readability.

- **Display & Headlines (Manrope):** A modern, geometric sans-serif. Used for high-impact status updates. The wide apertures of Manrope ensure legibility even when the user is in motion or stressed.
- **Body & Labels (Inter):** The gold standard for UI readability. Inter handles all functional data and instructions.

### Scale Application
- **Emergency Header:** `display-lg` (3.5rem) – used for countdowns or critical status.
- **Instructional Text:** `title-md` (1.125rem) – high-contrast `on_surface` color for maximum legibility.
- **Metadata/Labels:** `label-md` (0.75rem) – used for timestamps and secondary coordinates.

---

## 4. Elevation & Depth: Tonal Layering

We convey importance through **Tonal Layering** rather than structural lines or heavy shadows.

- **The Layering Principle:** Depth is achieved by stacking. Place a `surface_container_lowest` card on a `surface_container_low` background to create a soft, natural lift.
- **Ambient Shadows:** When a card must "float" (e.g., the SOS slider), use a highly diffused shadow: `0px 12px 32px rgba(25, 28, 29, 0.06)`. The shadow color is a tinted version of `on_surface` to mimic natural light.
- **The "Ghost Border" Fallback:** If a container sits on a background of the same color, use a `ghost-border`: `outline_variant` at **15% opacity**. Never use 100% opaque lines.
- **Glassmorphism:** Navigation bars and sticky headers should use backdrop blurs. This allows the primary emergency red to "bleed" through softly as the user scrolls, maintaining a constant visual reminder of the app's core purpose.

---

## 5. Components: Intentional Primitives

### Large Touch-Friendly Buttons
- **Primary SOS:** Circular, using the `full` (9999px) roundedness. It must feature a "Subtle Pulse" animation—a scaled-up, low-opacity ring of `primary_container` (#EB0000) emanating from the center every 2 seconds.
- **Action Buttons:** Use `xl` (1.5rem) corner radius. Internal padding should be `16` (5.5rem) on the horizontal axis for a wide, premium look.

### Rounded Cards & Lists
- **Forbid Dividers:** Do not use lines between list items. Use `spacing-4` (1.4rem) to separate content blocks, or alternate background shades between `surface_container_low` and `surface_container_highest`.
- **Card Styling:** Use `lg` (1rem) corner radius. Content should be inset using `spacing-5` (1.7rem) to provide significant breathing room.

### Input Fields
- **Editorial Inputs:** No bottom lines or boxes. Use a `surface_container_high` background with `md` (0.75rem) rounded corners. The focus state should be a `ghost-border` of the `tertiary` blue.

### Specialty Component: The "Single-Action Focus" Sheet
A bottom sheet that covers 90% of the screen, using `surface_container_lowest`. It forces the user to focus on one task (e.g., "Confirm Location") while the background map is still visible through a glassmorphic blur.

---

## 6. Do's and Don'ts

### Do
- **DO** use the `spacing-20` (7rem) scale for hero element margins to create an editorial "breathing" feel.
- **DO** use "Soft Press" animations: when a button is touched, it should scale to 96% and deepen in color slightly.
- **DO** use `tertiary` (#2858B2) for "Information" and "Help" icons to distinguish them from "Action" items.

### Don't
- **DON'T** use pure black (#000000) for text. Always use `on_surface` (#191C1D) for a softer, premium contrast.
- **DON'T** use 1px dividers. If you feel the need for a line, increase the whitespace instead.
- **DON'T** crowd the screen. If a screen has more than 3 interactive elements, it must be split into a stepped flow. Low cognitive load is the priority.