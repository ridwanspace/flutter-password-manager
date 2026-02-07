[![Flutter](https://img.shields.io/badge/Flutter-3.6+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20Desktop-blueviolet)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

# Flutter Password Manager

A secure, cross-platform password manager built with Flutter. Protects your credentials with AES-256-CBC encryption and PBKDF2 key derivation, all stored locally on your device.

## Features

| Feature | Description |
|---|---|
| **Master Password** | Single master password to unlock your vault with SHA-256 hashing |
| **AES-256 Encryption** | All passwords and notes encrypted with AES-256-CBC |
| **PBKDF2 Key Derivation** | 100,000 iteration PBKDF2-HMAC-SHA256 key stretching |
| **Password Generator** | Configurable generator (4-64 chars) with strength indicator |
| **Categories** | 7 default categories with custom icon mapping |
| **Search & Filter** | Real-time search across title, username, and URL |
| **Auto-Lock** | Vault locks automatically when app goes to background |
| **Clipboard Security** | Auto-clears clipboard after 30 seconds |
| **Cross-Platform** | Runs on Android, iOS, Web, Linux, macOS, and Windows |

## Architecture

```mermaid
graph TD
    A[UI Layer<br/>Screens & Widgets] --> B[State Management<br/>Providers]
    B --> C[Business Logic<br/>Services]
    C --> D[Data Layer<br/>SQLite Database]

    subgraph Screens
        S1[LockScreen]
        S2[HomeScreen]
        S3[AddEditEntryScreen]
        S4[EntryDetailScreen]
        S5[PasswordGeneratorScreen]
        S6[SettingsScreen]
    end

    subgraph Providers
        P1[AuthProvider]
        P2[PasswordProvider]
        P3[CategoryProvider]
    end

    subgraph Services
        SV1[AuthService]
        SV2[EncryptionService]
        SV3[DatabaseHelper]
        SV4[PasswordGeneratorService]
        SV5[ClipboardService]
    end

    A --- Screens
    B --- Providers
    C --- Services
```

## App Flow

```mermaid
flowchart TD
    Start([App Launch]) --> Init[AuthProvider checks DB]
    Init -->|No master password| Setup[Create Master Password]
    Init -->|Master password exists| Unlock[Enter Master Password]

    Setup --> DeriveKey[Derive encryption key<br/>PBKDF2 100k iterations]
    Unlock --> Verify{Verify password}
    Verify -->|Invalid| Unlock
    Verify -->|Valid| DeriveKey

    DeriveKey --> Home[Home Screen<br/>Password Vault]

    Home --> Add[Add Entry]
    Home --> View[View Entry]
    Home --> Search[Search / Filter]
    Home --> Generator[Password Generator]
    Home --> Settings[Settings]
    Home --> Lock[Lock Vault]

    Add --> Encrypt[Encrypt with AES-256-CBC]
    Encrypt --> Save[Save to SQLite]
    Save --> Home

    View --> Decrypt[Decrypt password]
    View --> Copy[Copy to clipboard<br/>Auto-clear 30s]
    View --> Edit[Edit Entry]
    View --> Delete[Delete Entry]

    Settings --> ChangePW[Change Master Password]
    ChangePW --> ReEncrypt[Re-encrypt all entries<br/>with new key]

    Lock --> Unlock
```

## Encryption Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as AuthProvider
    participant E as EncryptionService
    participant D as Database

    U->>A: Enter master password
    A->>E: generateSalt() → 32-byte random salt
    A->>E: hashPassword(password, salt) → SHA-256
    A->>D: Store hash + salt
    A->>E: deriveKey(password, salt)
    E->>E: PBKDF2-HMAC-SHA256<br/>100,000 iterations → 256-bit key
    E-->>A: Derived key (in memory only)

    Note over U,D: Saving a password entry

    U->>A: Save new entry
    A->>E: encryptText(password, derivedKey)
    E->>E: Generate random 16-byte IV
    E->>E: AES-256-CBC encrypt
    E-->>A: "iv_base64:ciphertext_base64"
    A->>D: Store encrypted entry
```

## Project Structure

```
lib/
├── main.dart                  # App entry point, web DB factory setup
├── app.dart                   # MaterialApp with theme and routing
├── models/
│   ├── master_password.dart   # Master password model
│   ├── password_entry.dart    # Password entry model
│   └── category.dart          # Category model
├── providers/
│   ├── auth_provider.dart     # Authentication state management
│   ├── password_provider.dart # Password vault state management
│   └── category_provider.dart # Category state management
├── screens/
│   ├── lock_screen.dart       # Master password setup / unlock
│   ├── home_screen.dart       # Main vault with search and filters
│   ├── add_edit_entry_screen.dart  # Create / edit password entry
│   ├── entry_detail_screen.dart    # View entry details
│   ├── password_generator_screen.dart  # Password generator tool
│   └── settings_screen.dart   # App settings and master password change
├── services/
│   ├── auth_service.dart      # Authentication logic
│   ├── encryption_service.dart # AES-256 + PBKDF2 cryptography
│   ├── database_helper.dart   # SQLite database operations
│   ├── password_generator_service.dart # Password generation + strength
│   └── clipboard_service.dart # Secure clipboard with auto-clear
├── widgets/
│   ├── password_field.dart    # Password input with visibility toggle
│   ├── password_strength_indicator.dart # Visual strength bar
│   ├── entry_list_tile.dart   # Password entry list item
│   ├── category_chip.dart     # Category filter chip
│   └── confirm_dialog.dart    # Reusable confirmation dialog
└── utils/
    ├── constants.dart         # App-wide constants and defaults
    └── icon_mapper.dart       # String-to-IconData mapping
```

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Framework | Flutter 3.6+ | Cross-platform UI |
| Language | Dart 3.6+ | Application logic |
| State Management | `provider` | Reactive ChangeNotifier-based state |
| Database | `sqflite` | Local SQLite storage |
| Database (Web) | `sqflite_common_ffi_web` | SQLite via WASM for web |
| Encryption | `encrypt` | AES-256-CBC encryption/decryption |
| Hashing | `crypto` | SHA-256 and HMAC-SHA256 |
| Date Formatting | `intl` | Localized date/time display |

## Database Schema

```mermaid
erDiagram
    MASTER_PASSWORD {
        int id PK
        text password_hash
        text salt
        text created_at
    }

    CATEGORIES {
        int id PK
        text name UK
        text icon
    }

    PASSWORD_ENTRIES {
        int id PK
        text title
        text username
        text encrypted_password
        text encrypted_notes
        text url
        int category_id FK
        text created_at
        text updated_at
    }

    CATEGORIES ||--o{ PASSWORD_ENTRIES : "has"
```

## Default Categories

| Category | Icon |
|---|---|
| Social Media | `people` |
| Email | `email` |
| Finance | `account_balance` |
| Shopping | `shopping_cart` |
| Work | `work` |
| Entertainment | `movie` |
| Other | `folder` |

## Getting Started

### Prerequisites

- Flutter SDK 3.6 or higher
- Dart SDK 3.6 or higher

### Installation

```bash
# Clone the repository
git clone https://github.com/ridwanspace/flutter-password-manager.git
cd flutter-password-manager

# Install dependencies
flutter pub get
```

### Running

```bash
# Android / iOS
flutter run

# Web (requires WASM setup)
dart run sqflite_common_ffi_web:setup
flutter run -d chrome

# Linux / macOS / Windows
flutter run -d linux
```

## Security Overview

| Mechanism | Details |
|---|---|
| Password Hashing | SHA-256 with unique random salt per user |
| Key Derivation | PBKDF2-HMAC-SHA256, 100,000 iterations |
| Data Encryption | AES-256-CBC with random IV per entry |
| Salt | 32-byte cryptographically secure random |
| Key Storage | Derived key held in memory only, never persisted |
| Clipboard | Auto-cleared after 30 seconds |
| Auto-Lock | Vault locks on app background/detach |
