# Chat Feedback System - Implementation Guide

## Overview
I've implemented a complete feedback system for the chatbot that shows a popup asking "¿Fue útil la información?" a few seconds after the assistant responds. Users can give a thumbs up or thumbs down, and all feedback is persisted to a SwiftData database.

## Files Created/Modified

### 1. **ChatFeedback.swift** (NEW)
A SwiftData model that stores all user feedback:
- `id`: Unique identifier
- `timestamp`: When feedback was given
- `userQuery`: The user's original question
- `assistantResponse`: The assistant's response that was rated
- `isPositive`: Boolean (true for thumbs up, false for thumbs down)
- `userId`: Optional tracking of which user gave feedback
- `contextUsed`: The database context that was retrieved for the response

### 2. **ChatScreen.swift** (MODIFIED)
Enhanced with feedback popup functionality:

#### New State Variables:
```swift
@State private var showFeedbackPopup = false
@State private var feedbackMessageId: UUID?
@State private var feedbackTimer: Task<Void, Never>?
```

#### Key Features Added:
1. **Automatic Popup Trigger**: After the assistant responds, a 3-second timer starts
2. **Feedback Tracking**: The `ChatMessage` struct now has a `feedbackGiven` property to prevent duplicate feedback
3. **Beautiful Popup UI**: A centered popup with thumbs up/down buttons
4. **Data Persistence**: Feedback is saved to SwiftData when user clicks thumbs up or down

#### New Functions:
- `scheduleFeedbackPopup(for:)`: Starts a 3-second timer to show the popup
- `saveFeedback(isPositive:)`: Saves the feedback to the database
- `feedbackPopup`: SwiftUI view for the popup interface

### 3. **ChatFeedbackAnalyticsView.swift** (NEW)
A complete analytics view to review all feedback:

#### Features:
- **Statistics Dashboard**: Shows total positive, negative, and satisfaction percentage
- **Filtering**: Filter by all, positive only, or negative only
- **Expandable Rows**: Each feedback entry can be expanded to see:
  - User's original question
  - Assistant's response
  - User ID
  - Number of context sources used
- **Delete Functionality**: Swipe to delete unwanted entries
- **Real-time Updates**: Uses SwiftData @Query for automatic updates

### 4. **Portal_mabeApp.swift** (MODIFIED)
Added `ChatFeedback.self` to the ModelContainer schema so SwiftData can persist the feedback.

## How It Works

### User Flow:
1. User sends a message to the chatbot
2. Assistant responds
3. **3 seconds later**, a popup appears asking "¿Fue útil la información?"
4. User clicks thumbs up 👍 or thumbs down 👎
5. Feedback is saved to the database
6. The message is marked as "feedback given" so the popup won't show again for that message

### Popup Behavior:
- ✅ Only shows once per assistant message
- ✅ Can be dismissed by clicking "Cerrar" or tapping outside
- ✅ Won't show if user has already given feedback for that message
- ✅ Includes smooth animations

## Usage Examples

### To View Analytics:
```swift
// In your navigation or settings view, add:
NavigationLink("Ver Feedback del Chat") {
    ChatFeedbackAnalyticsView()
}
```

### To Query Feedback Programmatically:
```swift
import SwiftData

// Get all positive feedback
let descriptor = FetchDescriptor<ChatFeedback>(
    predicate: #Predicate { $0.isPositive == true }
)
let positiveFeedback = try? modelContext.fetch(descriptor)

// Get feedback from last 7 days
let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let recentDescriptor = FetchDescriptor<ChatFeedback>(
    predicate: #Predicate { $0.timestamp >= sevenDaysAgo }
)
let recentFeedback = try? modelContext.fetch(recentDescriptor)
```

### To Calculate Satisfaction Rate:
```swift
let allFeedback = try? modelContext.fetch(FetchDescriptor<ChatFeedback>())
let positive = allFeedback?.filter { $0.isPositive }.count ?? 0
let total = allFeedback?.count ?? 0
let satisfactionRate = total > 0 ? Double(positive) / Double(total) * 100 : 0
print("Satisfaction rate: \(satisfactionRate)%")
```

## Customization Options

### Change Popup Delay:
In `scheduleFeedbackPopup`, modify the delay:
```swift
try? await Task.sleep(for: .seconds(5)) // 5 seconds instead of 3
```

### Change Popup Styling:
Edit the `feedbackPopup` computed property to customize colors, sizes, fonts, etc.

### Add Additional Feedback Options:
Extend the `ChatFeedback` model to include:
- Text comments
- Rating scale (1-5 stars)
- Category of issue (accuracy, helpfulness, etc.)

### Export Feedback Data:
```swift
func exportFeedbackToJSON() throws -> Data {
    let feedback = try modelContext.fetch(FetchDescriptor<ChatFeedback>())
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(feedback)
}
```

## Accessibility
All feedback UI elements include proper accessibility labels:
- "Thumbs up - La información fue útil"
- "Thumbs down - La información no fue útil"
- Screen readers will announce the popup and options

## Testing Recommendations
1. Test that popup appears 3 seconds after assistant responds
2. Verify feedback saves correctly to database
3. Test that the same message doesn't show popup twice
4. Test analytics view with various amounts of data
5. Test swipe-to-delete in analytics view
6. Verify accessibility with VoiceOver

## Future Enhancements
- Add export to CSV functionality
- Create charts/graphs of satisfaction over time
- Add admin notifications for negative feedback
- Implement feedback categories
- Add follow-up questions after negative feedback

---

Everything is ready to use! The feedback system is fully integrated and will start collecting data immediately.
