# Authentication Feature Spec

## Overview
The Book Dragon client utilizes a token-based authentication mechanism. User tokens are securely stored locally and used to validate sessions and perform authorized requests.

## User Stories

### US-1: Automated Session Login
**As a** returning user,
**I want to** automatically jump back into my library,
**So that** I don't have to repeatedly enter my credentials.

### US-2: User Registration
**As a** new user,
**I want to** create a new Book Dragon account,
**So that** I can begin viewing my library and hatch my dragon.

### US-3: Existing User Login
**As an** existing user,
**I want to** securely log in using my email and password,
**So that** I can resume my adventures with my dragon companion.

## Technical Specifications

### Core Components
- **Splash Screen (`splash_screen.dart`)**: Acts as the initial loading state. Checks `SharedPreferences` for a token.
- **Welcome Screen (`welcome_screen.dart`)**: Unauthenticated landing page introducing the gamified concept.
- **Registration Screen (`registration_screen.dart`)**: Collects Username, Email, Password, and Confirm Password. Validation ensures minimum lengths and matches.
- **Login Screen (`login_screen.dart`)**: Collects Email and Password.

### Auth State Flow & Redirection
1. `SplashScreen` retrieves `auth_token` from `SharedPreferences`.
2. If token is invalid or missing, route to `WelcomeScreen`.
3. If token is valid, it calls `/auth/me` to fetch user details.
   - If the user `.dragon_id` is null/0, route to `DragonSelectionScreen`.
   - Otherwise, route to `MainNavigationScreen` (defaulting to the Home tab).

### API Mappings

| Feature | Endpoint | Method | Payload / Details |
|---------|----------|--------|-------------------|
| Validate Token | `/auth/me` | GET | `Authorization: Bearer <token>` |
| Register Account | `/register` | POST | `{'username': '...', 'email': '...', 'password': '...'}` |
| Login Account | `/login` | POST | `{'email': '...', 'password': '...'}` |
| Fetch Dragon Status | `/dragon` | GET | Validates if a user has configured a dragon upon login. |

