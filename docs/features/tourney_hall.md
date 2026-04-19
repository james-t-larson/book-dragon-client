# Tourney Hall (Challenges) Feature Spec

## Overview
The Tourney Hall is the competitive and social layer of Book Dragon. It allows users to engage in reading challenges with their dragon companion, either by creating their own or joining others. Challenges require a daily reading commitment (e.g., 5-10 minutes) for a set duration (e.g., 7-30 days).

## User Stories

### US-13: Joining a Challenge
**As a** social reader,
**I want to** join existing challenges using an invite code,
**So that** I can compete or read alongside others.

### US-14: Creating a Custom Challenge
**As a** goal-oriented reader,
**I want to** define my own challenge parameters (length and daily duration),
**So that** I can tailor my reading habits to my personal schedule.

### US-15: Daily Progress & Motivation
**As a** participant in a challenge,
**I want to** receive visual feedback of my progress and see my dragon in the arena,
**So that** I stay motivated to complete my daily quota.

### US-16: Competitive Taunts
**As a** challenger,
**I want to** see a rival knight issuing taunts if I haven't finished my reading for the day,
**So that** I feel a sense of urgency to focus.

## Technical Specifications

### Core Components
- **Tourney Screen (`tourney_screen.dart`)**: A multifaceted screen that switches between "No Active Challenge" and "Active Challenge" states. 
    - **No Active Challenge**: Shows an empty arena with a "Plus" button to open join/create options.
    - **Active Challenge**: Features the dragon flying in the arena, a knight character (NPC) that taunts the user, and a progress tracker.
- **Tourney Service (`tourney_service.dart`)**: Handles all communication with the backend for tourney lifecycle management.
- **Join/Create Dialogs**: Interactive modals that guide the user through entering an invite code or selecting parameters for a new challenge.

### API Mappings

| Feature | Endpoint | Method | Payload / Details |
|---------|----------|--------|-------------------|
| Fetch Configuration | `/constants` | GET | Returns available durations and daily goals |
| Get Active Tourney | `/tourney` | GET | Returns the current user's tourney or 404 |
| Join Tourney | `/join_tourney` | POST | `{'invite_code': '...'}` |
| Create Tourney | `/tourney` | POST | `{'name': '...', 'duration_days': 7, 'daily_goal_minutes': 10}` |

## Challenge Flow

```mermaid
flowchart TD
    subgraph Tourney_Hall
        Start[User Enters Tourney Hall] --> CheckActive{Is a Challenge<br/>Active?}

        CheckActive -- No --> NoChallenge[State: No Challenge Active]
        NoChallenge --> NoDragonInfo[Elements:<br/>- Plus button on top right<br/>- No Dragon art]
        NoDragonInfo --> ClickPlus[Click Plus Button]
        ClickPlus --> OpenDialog[Opens Join/Create Dialog]
        
        OpenDialog --> JoinTab[Tab: Join Tourney]
        JoinTab --> UseInvite[Submit Invite Code / Join]
        UseInvite --> SetChallengeActive[Challenge Becomes Active]

        OpenDialog --> CreateTab[Tab: Create Tourney]
        CreateTab --> DefineParams[Define Name, Duration & Daily Goal]
        DefineParams --> ClickStart[Click Start Challenge]
        ClickStart --> SetChallengeActive

        CheckActive -- Yes --> ChallengeActiveState[State: Challenge Active]
        SetChallengeActive --> ChallengeActiveState
        ChallengeActiveState --> ActiveElements[Elements:<br/>- Dragon flying in arena<br/>- Share button (Invite Code)<br/>- Stats & Progress Bar in AppBar]

        ActiveElements --> DailyCheck{Reading goal met<br/>for the day?}

        DailyCheck -- No --> ReadingNotDone[State: Reading Not Completed]
        ReadingNotDone --> KnightInfo[Show Knight NPC with<br/>cycling taunt bubbles]
        KnightInfo --> UserReads[User Completes Focus Session]
        UserReads --> CompleteForDay[Daily Progress Recorded]

        DailyCheck -- Yes --> CompleteForDay
        CompleteForDay --> GoalCheck{Overall Duration<br/>Met?}

        GoalCheck -- No --> WaitNextDay[Wait for next day]
        WaitNextDay --> DailyCheck

        GoalCheck -- Yes --> ChallengeEnds[Challenge Ends]
        ChallengeEnds --> NoChallenge
    end
```

### Challenge Life-cycle
1. **Selection**: User enters Tourney Hall and chooses to Join or Create.
2. **Active State**: The user sees their dragon and progress.
3. **Daily Goal**: The Focus Timer (see `focus_timer.md`) automatically updates progress towards the daily tourney goal when a session is completed.
4. **Taunts**: If the daily goal is not met, a "Rival Knight" sprite appears with cycling taunt messages.
5. **Completion**: Once the total duration is reached, the challenge ends and returns the user to the selection state.
