# Library Management Feature Spec

## Overview
The "Library" functions as the main dashboard and home screen for the user. It allows the user to view their dragon, track their coins, start reading sessions, and add new books to their active inventory.

## User Stories

### US-6: Empty Library State
**As a** user with no active books,
**I want to** be prompted directly to add a book from the main screen,
**So that** I can easily begin tracking a new piece of literature.

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
- **Home Screen (`home_screen.dart`)**: Renders the local user `coins` to the top app bar. Dispatches API requests to fetch active books. Dynamically switches the primary CTA between "Add Book" and "Focus Time" based on inventory status.
- **Add Book Modal**: An AlertDialog containing several text fields mapping to the `Book` domain model. Parses `String` inputs for page counts to safe integers.
- **Dragon Art**: Instantiates the `DragonArt` widget passing in the user's color string, rendering it ambiently sitting in the lower third of the library scene.

### API Mappings

| Feature | Endpoint | Method | Payload / Details |
|---------|----------|--------|-------------------|
| Fetch Active Books| `/books?currently_reading=true` | GET | `Authorization: Bearer <token>` |
| Add Book | `/books` | POST | `{'title':'...','author':'...','genre':'...','total_pages': 0,'current_page': 0,'reading': true}` |

