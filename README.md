[README.md](https://github.com/user-attachments/files/32148069/README.md)
# 💌 Letterfly

**Letterfly** (codename *PawLetter*) is an iOS app for couples to write letters to each other — text or voice, with photos, moods, gifts, and shared memories on a map. Built solo as a first independent iOS project, from first commit to App Store submission.

> Write to each other, always.

---

## ✨ Features

### Core
- **Letters** — write text or voice messages to your partner, with optional photo attachments
- **Real-time sync** — every letter, reaction, and event syncs instantly via Firestore listeners
- **Pairing** — connect with your partner through a simple 6-character invite code
- **Sign in with Apple / Google** — no passwords, no email verification hassle

### Expression
- **Mood tags** — attach how you were feeling (love / happy / thankful / missing you) to a letter
- **Surprises** — a randomized selection of 30 gift stickers to attach to a letter, so the picker feels fresh each time
- **Reactions** — the recipient can react to a letter with a paw, hug, or heart
- **Handwriting font** — an optional custom typeface for letter text, toggleable in Settings
- **Send animation** — a hand-tuned envelope-folds-and-flies-away animation on send

### Memories
- **Calendar** — an infinite-scroll monthly calendar (Snapchat Memories–style) showing which days have letters
- **Memories Map** — every letter with a location becomes a pin on a map, with mood/surprise-aware pin styles, staggered entrance animation, radius search, and multi-select filters
- **Pair Events** — a shared list of recurring (birthdays, anniversaries) or one-time dates, with a banner on the calendar
- **Time Capsule letters** — schedule a letter to unlock on a future date, or link it to an upcoming Pair Event; the recipient sees that a letter is coming but not its contents until the date arrives
- **Pair stats** — days together, total letters, and photos shared, shown in Profile

### Polish
- **Light / Dark appearance** toggle
- **Haptic feedback** across nearly every interactive element
- **Offline photo caching** (Kingfisher) so images are still visible without a connection
- **Push notifications** — new letter, Time Capsule unlocking soon, upcoming Pair Event, and a daily reminder if no letter was sent that day

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI, `@Observable` |
| Auth | Firebase Auth (Sign in with Apple, Google) |
| Database | Cloud Firestore (real-time listeners) |
| File storage | Firebase Storage (photos, voice messages) |
| Push | Firebase Cloud Messaging + Cloud Functions (Node.js/TypeScript) |
| Maps & Location | MapKit, CoreLocation |
| Audio | AVFoundation (`AVAudioRecorder` / `AVAudioPlayer`) |
| Image loading/caching | Kingfisher |
| Testing | Swift Testing (`@Test` / `#expect`) |

---

## 🏗 Architecture

**Navigation flow:**

```
AuthView (Sign in with Apple / Google)
   → NameSetupView (choose display name)
      → PairView (share / enter invite code)
         → MainTabView
              ├── Home       — letter feed, search, sort
              ├── Calendar   — monthly grid + Pair Events banner
              ├── Memories   — map with location-tagged letters
              └── Profile    — account, partner, appearance, stats
```

**Firestore structure:**

```
users/{uid}
  ├── displayName, avatarURL, inviteCode
  └── pairID

pairs/{pairID}
  ├── members: [uid1, uid2]
  ├── startDate
  ├── letters/{letterID}
  │     ├── authorID, subject, text?, audioURL?, photoURL?
  │     ├── mood?, surprise?, reaction?
  │     ├── location? { latitude, longitude, placeName }
  │     ├── unlockDate?, linkedEventID?   (Time Capsule)
  │     └── isRead, editedAt?
  └── events/{eventID}
        ├── title, date, isRecurring, createdBy
```

**Design principles that shaped the codebase:**
- Services are protocol-backed (`LetterServiceProtocol`, `UserServiceProtocol`, …) where unit testing adds value; hardware-facing services (`LocationService`, `AudioRecorderService`, `PushNotificationService`) are used directly — mocking system delegates adds complexity without real benefit
- Shared state (e.g. `HomeViewModel`, `PairEventsViewModel`, `LocationService`) is lifted to `MainTabView` and injected down, so every tab reads from a single Firestore listener instead of duplicating reads
- Reusable UI is generic where it pays off — `ChipPicker<T: ChipDisplayable>` powers mood, surprise, and reaction selection with one implementation
- Firestore & Storage Security Rules are membership-based (`request.auth.uid in pairs/{pairID}.members`), with narrow exceptions (e.g. a partner may update only the `isRead` field on a letter they didn't author)

---

## 📁 Project Structure

```
Letterfly/
├── App/                 # App entry point, AppDelegate
├── Auth/                # Sign in, name setup, pairing
├── Home/                # Letter feed, letter detail, new/edit letter
│   └── Letter Details/, New Letter/
├── Calendar/             # Monthly calendar, day detail, Pair Events
├── Map/                  # Memories map, pins, filters
├── Pair/                 # Pairing flow
├── Profile/               # Account, partner info, appearance
├── Models/                # Letter, Pair, PairEvent, MoodType, SurpriseType, ReactionType
├── Services/              # Firestore/Storage/Auth service layer (protocol-backed)
├── Shared/                # Reusable views & view modifiers (ChipPicker, PressScaleEffect, LoadingView…)
└── Resources/             # Assets, fonts, Info.plist, entitlements
```

---

## 🧪 Testing

Unit tests (Swift Testing) cover the app's pure logic and view-model behavior with dependency-injected mock services:

- `Letter.isLocked(for:)`, `Letter.formattedDate`
- `PairEvent.nextOccurrence` (recurring vs. one-time dates)
- `NewLetterViewModel.send` — create vs. edit, no-op edit detection, upload failure handling
- `AuthViewModel.loadUserData`, `mapError`
- `MapViewModel` — filtering, nearby-count radius search
- `CalendarViewModel` — grouping letters by day
- `ProfileViewModel.loadPair`

Firebase Auth–dependent code paths (anything touching `Auth.auth().currentUser` directly) are intentionally left untested — see [Architecture](#-architecture) for the reasoning.

---

## 🚀 Getting Started

### Requirements
- Xcode 16+
- iOS 17.0+ deployment target
- A Firebase project (Auth, Firestore, Storage, Cloud Messaging enabled)
- Apple Developer Program membership (required for Sign in with Apple & Push Notifications)

### Setup
1. Clone the repo
2. Add your own `GoogleService-Info.plist` to the project root (not committed — see `.gitignore`)
3. Enable **Sign in with Apple** and **Push Notifications** capabilities in Signing & Capabilities
4. Deploy Cloud Functions:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```
5. Publish the Firestore and Storage security rules found in `firestore.rules` / `storage.rules`
6. Build and run

---

## 🗺 Roadmap / Known Trade-offs

Deliberately deferred beyond the initial release:
- VoiceOver / full accessibility pass
- Streaks & a growing shared "companion" feature (needs illustration work)
- Offline letter queueing (sending while offline)
- Map pin clustering (revisit once real usage produces enough pins to need it)

---

## 📄 License

This project is a personal/portfolio project. All rights reserved unless stated otherwise.

---

## 👤 Author

**Nazar Dydyn** — Software Engineering student, Lviv Polytechnic National University.
