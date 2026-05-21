# Scanfluence SwiftUI Prototype

A premium SwiftUI prototype demonstrating a Dynamic Island + Live Activity experience for QR/NFC business card scanning.

Built as a UI/UX-focused prototype using SwiftUI, ActivityKit, and WidgetKit.

---

# Features

- Dynamic Island support
- Live Activity integration
- Compact / Expanded / Minimal island states
- Apple-style animations and transitions
- Mock QR/NFC business card scan flow
- Contact saved / connection added state
- Dark premium UI design
- Haptic feedback interactions
- Lock screen Live Activity support
- Smooth spring-based animations
- Modular SwiftUI architecture
- Reference-style showcase screen with stacked iPhone mockups
- Glowing in-app Dynamic Island preview for the scan detected state

---

# Tech Stack

- SwiftUI
- ActivityKit
- WidgetKit
- iOS 17+
- Xcode 15+

---

# Architecture

The project is structured into modular SwiftUI components for clarity and scalability.

## App Structure

- Models
  - Mock data models
  - Contact profile data

- Views
  - Showcase-style main screen UI
  - Business card preview
  - Scan button
  - Success states
  - Reusable UI components

- Activity
  - Live Activity manager
  - ActivityKit integration
  - Dynamic Island states

- Widget Extension
  - Dynamic Island UI
  - Lock screen Live Activity layouts

- Shared
  - Shared activity attributes
  - Shared models between app and widget

---

# Dynamic Island Implementation

The prototype uses ActivityKit and WidgetKit to simulate a real-time business card scan experience.

## Dynamic Island States

### Compact State
Displays:
- Avatar
- Status indicator

### Expanded State
Displays:
- Profile image
- Name
- Designation
- Connection status
- Tap interaction placeholder

### Minimal State
Displays:
- Compact scan status indicator

---

# Live Activity Flow

1. User taps `Scan Card`
2. Mock scan animation begins
3. Live Activity starts
4. Dynamic Island updates
5. Success state appears
6. Contact marked as saved

---

# Mock Data

The app currently uses static mock data only.

Sample contact:
- Sarah Chen
- Product Designer
- Scanfluence

No backend or networking is used in this prototype.

---

# Animation Approach

The UI focuses heavily on Apple-style motion and smoothness.

Implemented using:
- spring animations
- scale transitions
- opacity transitions
- smooth state updates
- subtle haptic feedback
- staged phone mockup transitions
- glowing Dynamic Island scan feedback

The goal was to create a premium native iOS interaction feel.

---

# Running the Project

Requirements:
- Xcode 15+
- iOS 17+ simulator/device

Recommended simulator:
- iPhone 15 Pro
- iPhone 14 Pro

Steps:
1. Open `Scanfluence.xcodeproj`
2. Select iPhone Pro simulator
3. Run the app with Xcode's Run button or `Command + R`

---

# Notes

This is an MVP prototype focused primarily on:
- SwiftUI understanding
- UI polish
- Dynamic Island UX
- animation quality
- interaction design

The implementation intentionally uses mock/static data to focus entirely on user experience and presentation quality.# scaninfluencewweb
