# Domain Data Models

## Overview
This document outlines the core data structures utilized by the Flutter client. These models reflect the JSON responses provided by the backend API and are heavily leveraged in local state orchestration.

## Data Structures

### User Model

The `User` object (`lib/models/user.dart`) represents the authenticated identity and their gamification properties.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Primary Key. |
| `username` | `String` | Display name of the user. |
| `email` | `String` | Contact and login identifier. |
| `createdAt` | `DateTime` | Timestamp of account creation. |
| `coins` | `int` | Gamified currency earned via the focus timer. |
| `dragonId` | `int?` | Foreign key to the user's dragon config (if null, setup required). |
| `dragonName` | `String?` | Custom name assigned to the dragon. |
| `dragonColor` | `String?` | String representing the color enum (e.g. `red`, `blue`), driving UI sprite asset resolution. |
| `books` | `List<Book>` | A list of all reading materials associated. |

### Book Model

The `Book` object (`lib/models/book.dart`) structures library data, effectively functioning as quests/tasks that progress alongside the timer.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Primary Key. |
| `title` | `String` | The title of the literary work. |
| `author` | `String` | The creator of the text. Defaults to ''. |
| `totalPages` | `int` | Absolute length of the book. Defaults to 0. |
| `currentPage` | `int` | User's tracked progress bookmark. Defaults to 0. |
| `genre` | `String` | Categorization tag. Defaults to ''. |
| `readCount` | `int` | Tracks how many times the user has fully completed this volume. |
| `reading` | `bool` | Status flag denoting active `currently_reading` state. Filters the library view. |

### Tourney Model

The `Tourney` object (`lib/models/tourney.dart`) represents an active reading challenge in the Tourney Hall.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Primary Key. |
| `name` | `String` | The name of the tourney (e.g., "Grand Library Marathon"). |
| `inviteCode` | `String` | Unique alphanumeric string used to invite others. |
| `dailyProgress` | `DailyProgress` | Nested object tracking current day's progress. |
| `overallProgress` | `OverallProgress` | Nested object tracking total duration progress. |
| `tauntMessages` | `List<String>` | Cycling taunts issued by the knight if the goal is not met. |

#### DailyProgress (Sub-model)
| Field | Type | Description |
|-------|------|-------------|
| `isComplete` | `bool` | True if the daily reading minute goal is met. |
| `minuteGoal` | `int` | The required minutes of focusing per day. |
| `minutesComplete`| `int` | The actual minutes focused today. |

#### OverallProgress (Sub-model)
| Field | Type | Description |
|-------|------|-------------|
| `dayNumber` | `int` | The current day of the challenge (1-indexed). |
| `daysComplete` | `int` | Total number of days where the daily goal was fully met. |
| `daysGoal` | `int` | Total duration of the challenge in days. |
| `isComplete` | `bool` | True if the final day has been reached. |

## Serialization
Models implement standard Dart `fromJson` and `toJson` factory patterns for seamless HTTP layer translation. 

*(e.g., `DateTime.parse(json['created_at'])` translates ISO Strings back into Dart native types.)*
