# Dragon Companion Feature Spec

## Overview
The "Dragon Companion" acts as the core gamification hook. By logging reading sessions and earning coins, the user levels up their virtual companion. Users configure this companion early in their app lifecycle.

## User Stories

### US-4: Dragon Selection
**As an** authenticated user without a dragon,
**I want to** browse and select from visually distinct dragon variants,
**So that** I have a personalized companion to accompany my reading journey.

### US-5: Ambient Dragon Companion
**As an** authenticated user with a dragon,
**I want to** see my chosen dragon actively represented on the dashboard and reading interfaces,
**So that** I feel connected to my progress.

## Technical Specifications

### Core Components
- **Dragon Selection Screen (`dragon_selection_screen.dart`)**: A prominent `PageView` carousel enabling swipe functionality. Users swipe through dragon options and submit their decision. The selection updates the user's base identity representation.
- **Dragon Gamification Logic**: The application locally assigns different `Color` classes and corresponding `assets/images/dragons/sleeping/{color}.png` sprites based on the saved string of the dragon's color.

### Asset Mapping
Asset references dynamically resolve using a helper `_dragonThemeColor` mapping to ensure the UI highlights match the user's chosen beast.

| Dragon Color Enum | Hex Value | Sprite Path |
|-------------------|-----------|-------------|
| Red | `#CC3333` | `assets/images/dragons/sleeping/red.png` |
| Blue | `#3388CC` | `assets/images/dragons/sleeping/blue.png` |
| Green | `#408000` | `assets/images/dragons/sleeping/moss.png` |
| Gold | `#D4AF37` | `assets/images/dragons/sleeping/gold.png` |
| Pink | `#CC6699` | `assets/images/dragons/sleeping/pink.png` |
| Purple | `#8844AA` | `assets/images/dragons/sleeping/purple.png` |
| Teal | `#008080` | `assets/images/dragons/sleeping/teal.png` |

### API Mappings

| Feature | Endpoint | Method | Payload / Details |
|---------|----------|--------|-------------------|
| Hatch Dragon | `/dragon` | POST | `{'color': 'red', 'name': 'Red Dragon'}` |

