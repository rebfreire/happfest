---
name: Vibrant Celebration
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#5c3f42'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#906f72'
  outline-variant: '#e5bdc0'
  surface-tint: '#bd0042'
  primary: '#b90040'
  on-primary: '#ffffff'
  primary-container: '#e31754'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb2ba'
  secondary: '#006876'
  on-secondary: '#ffffff'
  secondary-container: '#58e6ff'
  on-secondary-container: '#006573'
  tertiary: '#4648d4'
  on-tertiary: '#ffffff'
  tertiary-container: '#6063ee'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9dc'
  primary-fixed-dim: '#ffb2ba'
  on-primary-fixed: '#400011'
  on-primary-fixed-variant: '#910030'
  secondary-fixed: '#a1efff'
  secondary-fixed-dim: '#44d8f1'
  on-secondary-fixed: '#001f25'
  on-secondary-fixed-variant: '#004e59'
  tertiary-fixed: '#e1e0ff'
  tertiary-fixed-dim: '#c0c1ff'
  on-tertiary-fixed: '#07006c'
  on-tertiary-fixed-variant: '#2f2ebe'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
  success-green: '#22C55E'
  warning-amber: '#F59E0B'
  surface-border: '#E5E7EB'
  text-main: '#111827'
  text-muted: '#6B7280'
typography:
  display:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1.5rem
  stack-lg: 2.5rem
  section-padding: 2rem
---

## Brand & Style

This design system targets a celebratory, energetic marketplace for party planning. The personality is optimistic, inclusive, and high-energy, designed to turn the logistical stress of event planning into an enjoyable creative process.

The visual style is **Corporate / Modern** with a strong infusion of **Soft Minimalism**. It leverages the systematic reliability of the PrimeNG aesthetic—characterized by structured layouts and clear affordances—while softening the "enterprise" edges with a playful color palette and significant roundedness. The interface prioritizes clarity and speed, using generous whitespace to ensure that colorful product imagery remains the focal point.

## Colors

The palette is anchored by a **Vibrant Pink** primary color, used for high-intent actions and brand identification. A **Cyan/Soft Blue** serves as a secondary accent, primarily for icons and decorative logo elements. 

The neutral palette is biased towards a "clean room" aesthetic, utilizing a very light gray (`#F9FAFB`) for background surfaces to make white cards and containers pop. Functional colors (green for success states, indigo for technical PrimeNG-style system indicators) are used sparingly to maintain high signal-to-noise ratios. All chromatic colors must maintain high saturation to evoke a festive mood.

## Typography

The design system uses **Plus Jakarta Sans** across all levels. This font provides a contemporary, slightly rounded geometric feel that aligns with the friendly nature of the brand while maintaining the professional legibility found in PrimeNG-inspired interfaces.

Headlines use a heavier weight (`600` or `700`) and tighter letter spacing to create a strong visual anchor. Body text prioritizes readability with standard weights and generous line heights. Labels for categories and status indicators use a medium weight to differentiate them from standard body copy.

## Layout & Spacing

This system follows a **Fluid Grid** model optimized for mobile-first consumption. 

- **Mobile:** 4-column grid with 16px margins and 16px gutters.
- **Desktop:** 12-column fixed grid (max-width 1200px) centered.

The spacing rhythm follows a 4px/8px base-8 system. Generous vertical "stack" spacing is used between distinct sections (e.g., Categories to Highlights) to prevent the UI from feeling cluttered. Content reflow should prioritize vertical scrolling on mobile, with horizontal "overflow" carousels used exclusively for category pills and quick-select options.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Ambient Shadows**. Surfaces are primarily white, sitting atop a neutral-light (`#F9FAFB`) background.

- **Low Elevation:** Used for product cards and search bars. A very soft, diffused shadow (0px 2px 8px rgba(0,0,0,0.05)) provides subtle separation.
- **High Elevation:** Reserved for Modals and floating action buttons. These use a more pronounced shadow with a larger blur radius (0px 10px 25px rgba(0,0,0,0.1)).
- **Interactive States:** Elements like buttons should slightly "lift" on hover/active states or use a subtle inner glow to signify engagement.

## Shapes

The shape language is consistently **Rounded**. 

Buttons, Input fields, and Category pills use a high radius to feel approachable. Cards use the `rounded-lg` (1rem) setting to create a distinct frame for product photography. This high roundedness is a direct counterpoint to the high-density information often found in marketplaces, making the data feel more digestible and less "technical."

## Components

### Buttons & Inputs
- **Primary Action:** Solid `#FF3366` with white text, 0.5rem roundedness, and 1rem horizontal padding.
- **Search Bar:** Fully rounded (pill-shaped), subtle 1px border (`#E5E7EB`), and a leading icon in the secondary color.
- **Form Inputs:** 0.5rem roundedness with 12px vertical padding. Active states must use a 2px indigo border to align with PrimeNG focus patterns.

### Category Pills
- Circular or highly rounded borders.
- Icons should be monochromatic within the pill, using the secondary color palette.
- Backgrounds should be white with a thin gray border.

### Product Cards
- Image placeholders at the top with a 1:1 or 4:3 aspect ratio.
- Typography within cards should be left-aligned.
- Pricing should use `headline-md` weight to ensure it stands out.
- Status badges (e.g., "PRODUTO", "SERVIÇO") should appear in the bottom-right corner as secondary labels.

### Checkout Stepper
- Horizontal layout on desktop, simplified vertical or header-only on mobile.
- Active steps use a solid primary color circle; completed steps use a green checkmark icon.
- Connecting lines should be thin and neutral-gray.

### Modals & Dialogs
- Centered on screen with a dark, semi-transparent backdrop blur.
- Header includes a clear "X" close icon and a `headline-md` title.
- Footer actions are right-aligned, with "Cancel" as a text button and "Confirm" as a primary solid button.