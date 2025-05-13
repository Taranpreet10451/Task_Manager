# Task Manager

A Flutter task management application with CRUD functionality, offline-first data persistence, and modern UI.

## Features

- **Create, Read, Update, Delete (CRUD) Tasks**: Manage your tasks with a user-friendly interface
- **Offline-First Architecture**: Work with your tasks even when offline
- **Data Synchronization**: Automatically sync your changes when back online
- **Filtering & Sorting**: Organize tasks by priority, status, due date, and more
- **Progress Tracking**: Monitor task completion with visual progress indicators
- **Tagging System**: Categorize tasks with customizable tags
- **Responsive UI**: Works on various screen sizes

## Architecture

This application follows the BLoC (Business Logic Component) pattern for state management and implements a clean architecture approach:

- **Presentation Layer**: UI components, screens, and widgets
- **Domain Layer**: Business logic, entities, and BLoCs
- **Data Layer**: Repositories, data sources, and models

## Technologies Used

- **Flutter**: UI framework
- **flutter_bloc**: State management
- **Hive**: Local data persistence
- **Dio**: HTTP client for API requests
- **Get_It**: Dependency injection
- **Equatable**: Value equality
- **Intl**: Internationalization and formatting
- **UUID**: Generating unique identifiers
- **flutter_slidable**: Swipeable widgets
- **percent_indicator**: Visual progress indicators

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Project Structure

```
lib/
├── data/
│   ├── models/        # Data models
│   ├── repositories/  # Repository implementations
│   └── services/      # API and local storage services
├── di/
│   └── injection.dart # Dependency injection setup
├── domain/
│   ├── blocs/         # BLoC components
│   └── entities/      # Domain entities
├── presentation/
│   ├── screens/       # UI screens
│   ├── theme/         # App theme
│   └── widgets/       # Reusable UI components
├── utils/            # Utility classes and functions
└── main.dart         # Application entry point
```

## Improvements

- **Offline-First Approach**: Tasks are stored locally and synced when online
- **Enhanced UI**: Modern, responsive design with visual task progress indicators
- **Advanced Filtering**: Sort and filter tasks by multiple criteria
- **Task Tagging**: Organize tasks with customizable tags
- **Due Dates**: Set and track task deadlines
- **Progress Tracking**: Visual indicators for task completion percentage
- **Data Synchronization**: Queue operations when offline and sync when online
- **Error Handling**: Robust error handling for API and database operations

Setup Instructions

Prerequisites:
Flutter SDK (3.16 or later)
Dart (3.2 or later)
IDE (VS Code or Android Studio)


Installation:git clone https://github.com/your-repo/task_manager.git
cd task_manager
flutter pub get
flutter pub run build_runner build
flutter run


Dependencies:
flutter_bloc: State management
hive_flutter: Local storage
dio: HTTP requests
get_it: Dependency injection
json_annotation: JSON serialization
logger: Debugging



API Endpoints

GET /todos: Fetch tasks (paginated)
POST /todos: Create a task
PUT /todos/:id: Update a task
DELETE /todos/:id: Delete a task
Mock API: JSONPlaceholder

Usage Instructions

Home Screen: View tasks in a paginated list with search, sort, and filter options.
Add Task: Tap the FAB to create a task with title, description, priority, and category.
Edit Task: Tap a task to edit its details.
Delete Task: Swipe left on a task for deletion with confirmation dialog.
Settings: Toggle between light and dark themes.

Architecture Overview

Data Layer: TaskModel, TaskRepository, ApiService, HiveService
Domain Layer: TaskBloc, TaskEntity
Presentation Layer: HomeScreen, AddTaskScreen, EditTaskScreen, SettingsScreen, reusable widgets
Dependency Injection: get_it for service locator pattern
Offline Sync: Tasks cached in Hive, synced when online

Testing Information

Unit Tests: Test repository and BLoC logic (test/task_repository_test.dart)
Widget Tests: Test UI components (test/home_screen_test.dart)
Run tests:flutter test



Bonus Features

Search with debounce
Sorting and filtering by status/priority
Offline-first with sync
Dark/light theme switching
Pagination for large datasets

Notes

Uses optimistic updates for better UX.
Comprehensive error handling with snackbars.
Responsive UI with card-based layouts.
Logging for debugging.

