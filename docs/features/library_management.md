# Library Management Feature Spec

## Overview
The "Library" functions as the main dashboard and home screen for the user. It allows the user to view their dragon, track their coins, start reading sessions, and add new books to their active inventory.

## User Stories

### US-6: Monitoring Progress
**As a** user,
**I want to** view my dragon companion and my current wealth at a glance,
**So that** I feel a sense of progression in the overall gamified experience.

### US-7: Adding a New Book
**As a** user starting a new text,
**I want to** record the title, author, total page count, and my current progress into the system,
**So that** the application can track my progression against the total length of the book.

### US-8: Tracking Coins
**As a** user,
**I want to** immediately see my accrued wealth (coins) in the library dashboard,
**So that** the value of my efforts is visible and rewarding.

## Technical Specifications

### Core Components
- **Home Screen (`home_screen.dart`)**: Acts as a passive dashboard. Renders the local user `coins` and total dragon level. The primary entry point for reading has been moved to the navigation bar to simplify the home interface.
- **Dragon Art**: Instantiates the `DragonArt` widget passing in the user's color string, rendering it ambiently sitting in the lower third of the library scene.

### API Mappings

| Feature | Endpoint | Method | Payload / Details |
|---------|----------|--------|-------------------|
| Fetch Active Books| `/books?currently_reading=true` | GET | `Authorization: Bearer <token>` |
| Add Book | `/books` | POST | `{'title':'...','author':'...','genre':'...','total_pages': 0,'current_page': 0,'reading': true}` |

