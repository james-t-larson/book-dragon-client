# Book Dragon Client Overview

## Introduction
Book Dragon is a gamified reading companion mobile application built to encourage reading through progress tracking and rewards. The application pairs the user with a virtual dragon companion that grows as the user reads.

## Core Technologies
*   **Framework**: Flutter (Dart)
*   **Styling**: Material Design with a custom dark, medieval-themed UI (`app_theme.dart`).
*   **Networking**: Standard `http` package for RESTful JSON API interactions.
*   **Storage**: `shared_preferences` for local data persistence (e.g., authentication tokens).
*   **Typography**: `google_fonts` (`MedievalSharp` for display headings, `Rosarivo` for body text).

## System Architecture

The application follows a standard Flutter single-page application structure relying on local `State` orchestration (`StatefulWidget`) and direct asynchronous REST API calls. 

```mermaid
graph TD
    Client[Flutter Client] --> HTTP[HTTP API Client]
    HTTP --> |REST API| Backend[Book Dragon API]
    Client --> Storage[Shared Preferences]
```

## Application Navigation Flow

The user journey is straightforward, heavily centered on whether the user is authenticated and whether they have initialized a dragon.

```mermaid
stateDiagram-v2
    [*] --> SplashScreen: Launch App

    SplashScreen --> WelcomeScreen: No token or Invalid Auth
    SplashScreen --> DragonSelectionScreen: Authenticated doesn't have a dragon
    SplashScreen --> HomeScreen: Authenticated has dragon

    WelcomeScreen --> LoginScreen: Taps Login
    WelcomeScreen --> RegistrationScreen: Taps Register

    RegistrationScreen --> DragonSelectionScreen: Successful Auth
    LoginScreen --> DragonSelectionScreen: Authenticated doesn't have a dragon
    LoginScreen --> HomeScreen: Authenticated has dragon

    DragonSelectionScreen --> HomeScreen: Selects Dragon

    HomeScreen --> FocusTimerScreen: Bottom Nav: "Focus"
    HomeScreen --> TourneyScreen: Bottom Nav: "Tourney"
    FocusTimerScreen --> HomeScreen: Bottom Nav: "Home"
```

## Navigation Menu

```mermaid
graph TD
    subgraph Navigation_Menu
        Clock[Clock: Focus - Tab 0]
        Home[Home: Library - Tab 1]
        Swords["Swords: Tourney - Tab 2"]
    end

    Clock -.-> FocusTimerScreen
    Home -.-> HomeScreen
    Swords -.-> TourneyScreen
```


```flowchart TD
    A[User opens Challenges] --> B[Select Challenge Type]

    B --> T[Tournament]

    %% Tournament
    subgraph Tournament Flow
        T --> T1[View available tournaments]
        T1 --> T2{User has enough coins?}
        T2 -- No --> T3[Prompt user to earn or acquire coins]
        T2 -- Yes --> T4[Confirm 10-coin buy-in]
        T4 --> T5[Create tournament entry]
        T5 --> T6[Add user to participant pool]
        T6 --> T7[Wait for tournament start]
        T7 --> T8[Challenge status = Active]
        T8 --> T9[User logs reading session]
        T9 --> T10[Validate timer/stopwatch session]
        T10 --> T11[Update player score]
        T11 --> T12[Refresh leaderboard]
        T12 --> T13{Tournament ended?}
        T13 -- No --> T9
        T13 -- Yes --> T14[Lock leaderboard]
        T14 --> T15[Rank users]
        T15 --> T16[Distribute prize pool: 1st 50%, 2nd 30%, 3rd 20%]
        T16 --> T17[Mark challenge Settled]
        T17 --> T18[Send results + reward notifications]
    end
```
