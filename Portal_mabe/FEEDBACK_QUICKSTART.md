# Chat Feedback System - Quick Start Guide

## ✅ What Was Added

### 1. New Files Created
- **ChatFeedback.swift** - SwiftData model for storing feedback
- **ChatFeedbackAnalyticsView.swift** - Beautiful analytics dashboard
- **CHAT_FEEDBACK_README.md** - Complete documentation

### 2. Modified Files
- **ChatScreen.swift** - Added feedback popup system
- **Portal_mabeApp.swift** - Registered ChatFeedback model

---

## 🎯 How It Works

```
User sends message
       ↓
Assistant responds
       ↓
⏰ Wait 3 seconds
       ↓
📱 Popup appears: "¿Fue útil la información?"
       ↓
User clicks 👍 or 👎
       ↓
💾 Saved to SwiftData database
       ↓
✅ Message marked as "feedback given"
```

---

## 🚀 Quick Test

To test the feedback system:

1. **Run the app**
2. **Go to Chat Screen**
3. **Send a message** to the assistant
4. **Wait for the response**
5. **Wait 3 more seconds** - popup will appear
6. **Click thumbs up or down**
7. **Feedback is saved!**

---

## 📊 View Analytics

To add a link to the analytics view, add this anywhere in your app:

```swift
NavigationLink {
    ChatFeedbackAnalyticsView()
} label: {
    Label("Feedback del Chat", systemImage: "chart.bar.fill")
}
```

Or open it with a button:
```swift
Button("Ver Analytics") {
    // In a NavigationStack
    navigationPath.append(ChatFeedbackAnalyticsView())
}
```

---

## 🎨 Popup Features

### Visual Design
- ✨ Smooth fade-in animation
- 🎨 Matches your app's design (uses Color(.background))
- 📱 Centered overlay with blur backdrop
- 🔘 Large, touch-friendly buttons

### User Experience
- ⏰ Appears automatically after 3 seconds
- 🚫 Won't show again for the same message
- 👆 Dismiss by clicking "Cerrar" or tapping outside
- ♿️ Full accessibility support

### Data Captured
Each feedback entry saves:
- 📝 User's question
- 💬 Assistant's response
- 👍/👎 Positive or negative
- 👤 User ID (email)
- 📊 Context sources used
- ⏰ Timestamp

---

## 📈 Analytics Dashboard Features

### Statistics Cards
- **Thumbs Up Count** (green)
- **Thumbs Down Count** (red)
- **Satisfaction Percentage** (blue)

### Filtering
- View all feedback
- Filter positive only
- Filter negative only

### Expandable Details
Tap any feedback to see:
- Full user question
- Complete assistant response
- User email
- Number of context sources
- Timestamp

### Management
- Swipe to delete unwanted entries
- Automatic real-time updates

---

## 🛠 Customization

### Change Popup Delay
File: `ChatScreen.swift`, function `scheduleFeedbackPopup`

```swift
try? await Task.sleep(for: .seconds(5)) // Change 3 to any number
```

### Change Popup Colors
File: `ChatScreen.swift`, computed property `feedbackPopup`

```swift
.foregroundColor(.green)  // Change thumb colors
.foregroundColor(.red)    // Change thumb colors
```

### Add More Feedback Options
File: `ChatFeedback.swift`

```swift
// Add new properties to the model
var rating: Int?           // 1-5 star rating
var comment: String?       // Text feedback
var category: String?      // Type of issue
```

---

## 📱 Example Usage in Code

### Query Positive Feedback
```swift
import SwiftData

@Query(
    filter: #Predicate<ChatFeedback> { $0.isPositive == true },
    sort: \ChatFeedback.timestamp
) 
var positiveFeedback: [ChatFeedback]
```

### Get Recent Negative Feedback
```swift
let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

@Query(
    filter: #Predicate<ChatFeedback> { 
        $0.isPositive == false && $0.timestamp >= lastWeek 
    }
) 
var recentNegativeFeedback: [ChatFeedback]
```

### Calculate Today's Satisfaction
```swift
let today = Calendar.current.startOfDay(for: Date())

@Query(
    filter: #Predicate<ChatFeedback> { $0.timestamp >= today }
) 
var todaysFeedback: [ChatFeedback]

var todaysSatisfaction: Double {
    guard !todaysFeedback.isEmpty else { return 0 }
    let positive = todaysFeedback.filter { $0.isPositive }.count
    return Double(positive) / Double(todaysFeedback.count) * 100
}
```

---

## ✨ What Makes This Implementation Great

1. **Non-intrusive** - Appears after a delay, doesn't interrupt conversation
2. **Smart** - Won't show for the same message twice
3. **Complete** - Captures all relevant context for analysis
4. **Beautiful** - Matches your app's design language
5. **Accessible** - Full VoiceOver support
6. **Persistent** - All data saved to SwiftData
7. **Actionable** - Analytics view to review and improve

---

## 🎉 You're All Set!

The feedback system is ready to use. Every time a user interacts with the chatbot, you'll collect valuable data about what's working and what needs improvement.

Happy coding! 🚀
