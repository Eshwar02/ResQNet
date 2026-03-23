# ResQNet

**"Because every second matters."**

ResQNet is a smart emergency response network designed to connect people, ambulances, and hospitals in real time.
With one-tap SOS activation, live ambulance tracking, and instant access to nearby medical facilities, ResQNet ensures help is always within reach when every second counts.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [App Flow](#app-flow)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Hospital Database](#hospital-database)
- [Permissions](#permissions)
- [Configuration](#configuration)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### SOS Emergency Trigger
- **Hold-to-activate SOS button** with a 2-second press-and-hold mechanism to prevent accidental triggers
- Expanding circle animation with visual progress feedback
- Immediate transition into the emergency flow

### Emergency Type Classification
- Classify your emergency into one of four categories:
  - **Road Accident** (marked as Highest Priority)
  - **Fire / Burn**
  - **Cardiac**
  - **General**
- Each type is color-coded with descriptive icons

### Real-Time Ambulance Tracking (Uber-style)
- Full-screen OpenStreetMap with live markers for:
  - User location (pulsing blue dot)
  - Hospital destination (cyan marker)
  - Ambulance (red moving vehicle)
- Realistic ambulance movement along a 40-point Bezier curve route
- Live ETA calculation (distance x 3.5 min/km)
- 3-stage progress indicator: **Assigned -> On the way -> Arrived**
- Driver info display: name, vehicle number, rating
- 800ms update intervals for smooth animation

### Live Navigation
- Full-screen map navigation to hospital
- ETA countdown, traffic info, and distance cards
- Driver contact options
- "LIVE EMERGENCY SYNC" indicator

### Hospital Discovery
- Auto-detects user location via GPS (fallback to Chennai)
- Lists **60 real hospitals** from Chennai, Tamil Nadu
- Filter by speciality: All, Trauma, Cardiac, Pediatrics, Orthopedic
- Hospital cards showing:
  - Distance (km/m), speciality, bed count
  - Capability chips: 24/7 Emergency, ICU, Trauma Center, Ambulance
  - Direct call button (dials 108)

### Interactive Map View
- OpenStreetMap displaying user and 15 nearest hospitals
- Color-coded markers (red for trauma centers, cyan for others)
- Tap a hospital to view details in a bottom sheet
- "My Location" button to re-center

### Emergency Contact Management
- Add, edit, delete, and search emergency contacts
- Contacts stored locally via SharedPreferences
- Priority contact highlighted with star icon and larger call button
- Quick-dial global emergency services:
  - **108** - Ambulance
  - **100** - Police
  - **101** - Fire
  - **1298** - EMRI

### Emergency History
- Automatic logging of each emergency incident
- Vertical timeline view with:
  - Incident type and severity (CRITICAL / MINOR)
  - Date, time, location, and hospital visited
- Color-coded timeline nodes

### Offline Mode
- Detects loss of internet connectivity
- Emergency call to **108** still works offline
- Displays cached local hospital data
- Retry connection with loading feedback

### Nearby Helpers
- Map view showing CPR-certified responders nearby
- Live responder count
- Draggable bottom sheet with helper details:
  - Distance, certification tags (Medical Trained, CPR Certified, First Aid)
  - Online status indicator

### Notification Updates
- Glass-morphism styled notification feed during emergencies
- Timeline updates: Ambulance Dispatched, Arrival Update, Helper Nearby
- Action buttons: "Track Live", "Call Driver"
- Backdrop blur visual effects

---

## App Flow

### SOS Emergency Flow
```
HomePage (2-sec hold on SOS button)
  |
  v
EmergencyTypeScreen (select incident type)
  |
  v
EmergencyLoadingScreen (3-stage animation over 6 seconds)
  |  Stage 1: "Locating your location..."
  |  Stage 2: "Contacting Emergency Services..."
  |  Stage 3: "Assigning Ambulance..."
  |
  v
AmbulanceStatusScreen (real-time tracking with live map)
  |
  v
LiveNavigationScreen (full-screen navigation to hospital)
```

### Bottom Navigation
```
Home  |  Hospitals  |  Contacts  |  History
```

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.10.3+ |
| Language | Dart |
| Maps | OpenStreetMap via `flutter_map` |
| Location | `geolocator` (GPS) |
| Storage | `shared_preferences` (local) |
| Networking | `http` package |
| Connectivity | `connectivity_plus` |
| Design | Material Design 3 |
| Platforms | Android, iOS |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, theme setup
├── data/
│   └── hospital_data.dart             # 60 real Chennai hospitals database
├── models/
│   ├── hospital.dart                  # Hospital model with Haversine distance
│   ├── emergency_contact.dart         # Emergency contact model
│   └── emergency_record.dart          # Emergency history record model
├── screens/
│   ├── main_shell.dart                # Root navigation shell (bottom nav)
│   ├── home_page.dart                 # SOS dashboard with hold-to-trigger
│   ├── emergency_type_screen.dart     # Emergency classification selection
│   ├── emergency_loading_screen.dart  # 3-stage loading animation
│   ├── ambulance_status_screen.dart   # Real-time ambulance tracking
│   ├── live_navigation_screen.dart    # Full-screen hospital navigation
│   ├── hospital_list_screen.dart      # Filterable hospital list
│   ├── map_screen.dart                # Interactive hospital map
│   ├── contacts_screen.dart           # Emergency contact management
│   ├── priority_contacts_screen.dart  # Quick-access priority contacts
│   ├── emergency_history_screen.dart  # Timeline of past emergencies
│   ├── offline_mode_screen.dart       # No-internet fallback screen
│   ├── nearby_helpers_screen.dart     # Nearby CPR-certified responders
│   └── notification_updates_screen.dart # Glass-morphism notification feed
├── services/
│   └── storage_service.dart           # SharedPreferences singleton service
└── utils/
    ├── app_config.dart                # API URLs, timeouts, app constants
    ├── app_theme.dart                 # Material 3 theme & color system
    ├── constants.dart                 # Shared constants
    └── theme.dart                     # Additional theme utilities
```

---

## Data Models

### Hospital
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Hospital name |
| `address` | `String` | Full address |
| `latitude` / `longitude` | `double` | GPS coordinates |
| `phone` | `String` | Contact number |
| `distance` | `double?` | Calculated from user location |
| `hasAmbulance` | `bool` | Ambulance availability |
| `totalBeds` | `int` | Total bed capacity |
| `speciality` | `String` | Hospital speciality |
| `emergency24x7` | `bool` | 24/7 emergency services |
| `icuAvailable` | `bool` | ICU facility |
| `traumaCenter` | `bool` | Trauma center designation |

Uses the **Haversine formula** for great-circle distance calculation.

### EmergencyContact
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Contact name |
| `phone` | `String` | Phone number |
| `relationship` | `String` | Relationship to user |

### EmergencyRecord
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `type` | `String` | Road Accident / Cardiac / Fire-Burn / General |
| `severity` | `String` | critical / minor |
| `date` | `DateTime` | Incident timestamp |
| `location` | `String` | Incident location |
| `hospitalName` | `String` | Hospital visited |

---

## Hospital Database

The app includes a built-in database of **60 real hospitals** from Chennai, Tamil Nadu, India. Notable hospitals include:

| Hospital | Beds | Speciality | Trauma Center |
|----------|------|-----------|---------------|
| Apollo Hospitals Greams Road | 550 | Cardiac | Yes |
| MIOT International | 1000 | Orthopedic/Trauma | Yes |
| Gleneagles Global Health City | 1000 | Transplant | Yes |
| Fortis Malar Hospital | 180 | Cardiac/Neuro | No |
| SIMS Hospital | 345 | Multispeciality | Yes |

Utility functions:
- `getNearestHospitals(lat, lng, limit)` - Returns hospitals sorted by distance
- `getNearestHospital(lat, lng)` - Returns the single closest hospital
- `getBySpeciality(speciality, lat, lng)` - Filter by hospital speciality
- `getTraumaCenters(lat, lng)` - Returns only trauma centers

---

## Permissions

### Android
| Permission | Purpose |
|-----------|---------|
| `INTERNET` | API calls and map tile loading |
| `ACCESS_FINE_LOCATION` | Precise GPS for ambulance tracking |
| `ACCESS_COARSE_LOCATION` | Approximate location fallback |
| `ACCESS_BACKGROUND_LOCATION` | Continuous tracking during emergency |
| `CALL_PHONE` | Direct dialing to 108 and emergency services |
| `ACCESS_NETWORK_STATE` | Connectivity detection for offline mode |

### iOS
- Location When In Use / Always
- Phone calling capability

---

## Configuration

Key configuration values in `lib/utils/app_config.dart`:

| Setting | Value |
|---------|-------|
| Emergency Number | `108` (Indian Ambulance) |
| Default Location | Chennai (13.0827°N, 80.2707°E) |
| Default Map Zoom | 13.0 |
| Map Zoom Range | 5 - 18 |
| Ambulance Update Interval | 2 seconds |
| API Timeout | 30 seconds |
| Location Accuracy Threshold | 100 meters |

---

## Design System

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Emergency Red | `#BC0100` | Primary accent, SOS button |
| Muted Slate | `#526069` | Secondary text |
| Calm Blue | `#2858B2` | Medical/calm accent |
| Error Red | `#BA1A1A` | Error states |
| Surface | `#F3F4F5` | Background surfaces |

### Typography
| Font | Usage |
|------|-------|
| **Manrope** | Headings, buttons, emphasis |
| **Inter** | Body text, descriptions |

### Design Principles
- **Material Design 3** with custom color scheme
- High contrast for emergency readability
- Large touch targets (40-56px) for stress situations
- Smooth animations (easeOutCubic, easeInOut)
- Pulsing effects for active/live indicators
- Portrait-only orientation lock

---

## Getting Started

### Prerequisites
- Flutter SDK >= 3.10.3
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extension
- An Android or iOS device/emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Eshwar02/ResQNet.git
   cd ResQNet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for release**
   ```bash
   # Android APK
   flutter build apk --release

   # Android App Bundle
   flutter build appbundle --release

   # iOS
   flutter build ios --release
   ```

---

## Dependencies

### Production
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_map` | ^8.2.2 | OpenStreetMap integration |
| `geolocator` | ^14.0.2 | GPS location services |
| `url_launcher` | ^6.3.2 | Phone dialing & URL launching |
| `connectivity_plus` | ^7.0.0 | Network connectivity detection |
| `latlong2` | ^0.9.1 | Latitude/longitude coordinates |
| `flutter_map_marker_cluster` | ^8.2.2 | Map marker clustering |
| `flutter_spinkit` | ^5.2.2 | Loading spinner animations |
| `shared_preferences` | ^2.5.4 | Local key-value storage |
| `permission_handler` | ^12.0.1 | Runtime permission management |
| `http` | ^1.6.0 | HTTP client for API calls |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Development
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit & widget testing |
| `flutter_lints` | ^6.0.0 | Dart/Flutter linting rules |

---

## Roadmap

- [ ] Backend API integration (currently uses localhost:3000 placeholder)
- [ ] Real-time location sharing with emergency responders
- [ ] Medical profile and Medical ID setup
- [ ] Insurance information storage
- [ ] Family member notification during emergencies
- [ ] Hospital bed availability (live integration)
- [ ] In-app messaging with ambulance driver
- [ ] Push notifications for emergency updates
- [ ] Biometric authentication for app access
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Integration with government emergency systems

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is developed as part of an emergency response initiative. All rights reserved.

---

<p align="center">
  <b>ResQNet</b> — Because every second counts in an emergency.
</p>
