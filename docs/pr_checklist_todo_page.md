# Sprint 3 - TodoPage PR Checklist

## 📋 Required Files

- [ ] `lib/features/todo/presentation/pages/todo_page.dart`
- [ ] `lib/features/todo/controllers/todo_controller.dart`
- [ ] `test/features/todo/controllers/todo_controller_test.dart`

## 🎯 Business Logic Implementation

### TodoController
- [ ] Constructor with DI (RandomService, NotificationController, DatabaseService)
- [ ] `getTwoExercises()` method using RandomService
  - [ ] Gets exercises for selected pain points
  - [ ] Ensures exercises are not duplicated
- [ ] `markCompleted()` method
  - [ ] Updates DailyStats (completed count)
  - [ ] Returns to HomePage
- [ ] `handleSnooze()` method
  - [ ] Calls NotificationController.handleSnooze
  - [ ] Returns success/failure status
- [ ] `markSkipped()` method
  - [ ] Updates DailyStats (skipped count)
  - [ ] Returns to HomePage

## 🎨 UI Implementation

### TodoPage
- [ ] Displays 2 random exercises
  - [ ] Exercise name
  - [ ] Exercise description/steps
  - [ ] Target area (optional: pain point icons)
- [ ] Action buttons
  - [ ] Done button (green)
  - [ ] Snooze 15m button (yellow)
  - [ ] Skip button (red)
- [ ] Uses GetX reactive state
- [ ] Proper error handling & loading states

## ✅ Tests Coverage

### Unit Tests
- [ ] Exercise Selection
  - [ ] Verifies 2 unique exercises are selected
  - [ ] Handles empty result case
- [ ] Action Handlers
  - [ ] `markCompleted()` updates DailyStats correctly
  - [ ] `handleSnooze()` calls NotificationController
  - [ ] `markSkipped()` updates DailyStats correctly
- [ ] Navigation
  - [ ] Returns to HomePage after actions

### Integration Tests (if applicable)
- [ ] Button interactions work correctly
- [ ] State updates reflect in UI
- [ ] Navigation flow is correct

## 🔍 Code Quality

- [ ] No hardcoded strings (use constants)
- [ ] Error handling for service calls
- [ ] Clean architecture principles followed
- [ ] GetX best practices followed
- [ ] Code formatted with `flutter format`
- [ ] No analyzer warnings
- [ ] All tests passing

## 📚 Documentation

- [ ] Method documentation
- [ ] Complex logic explained in comments
- [ ] PR description explains implementation approach
- [ ] Screenshots of UI (if applicable)

## 🚨 Breaking Changes

- [ ] No breaking changes to existing features
- [ ] Interface contracts maintained
- [ ] Backward compatible with existing data

## 🏃‍♂️ Testing Instructions

1. Navigate to HomePage
2. Wait for notification or use Test Notification
3. Verify TodoPage shows 2 unique exercises
4. Test each button:
   - Done: Updates success rate
   - Snooze: Shows up again in 15min
   - Skip: Updates stats correctly

---

**Note**: All items must be checked before merging. Each unchecked item requires explanation in PR comments.
