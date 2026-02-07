# Product Requirements Document: Mobile Password Manager

## Overview

A mobile password manager application built with Flutter and SQLite that allows users to securely store, organize, and retrieve their credentials locally on their device.

## Goals

- Provide a simple, offline-first password manager for personal use
- Store credentials securely using encryption on the local device
- Deliver a clean, intuitive mobile UI

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter (Dart) |
| Database | SQLite (via `sqflite` package) |
| Encryption | AES-256 (via `encrypt` package) |
| State Management | Provider |
| Platform | Android & iOS |

## Features

### P0 - Must Have

1. **Master Password Authentication**
   - User sets a master password on first launch
   - App locks behind master password on every open
   - Master password hash stored locally (never plaintext)

2. **CRUD Password Entries**
   - Create new credential entries (title, username, password, URL, notes)
   - View list of saved entries
   - View entry details (with password hidden by default)
   - Edit existing entries
   - Delete entries with confirmation

3. **Local Encryption**
   - All stored passwords encrypted at rest using AES-256
   - Encryption key derived from the master password

4. **Search & Filter**
   - Search entries by title or username
   - Filter/sort entries alphabetically or by date

### P1 - Should Have

5. **Password Generator**
   - Generate random passwords with configurable length
   - Options: uppercase, lowercase, numbers, special characters
   - Copy generated password to clipboard

6. **Copy to Clipboard**
   - One-tap copy for username and password fields
   - Auto-clear clipboard after 30 seconds

7. **Categories / Tags**
   - Organize entries into categories (e.g., Social, Work, Finance)
   - Filter entries by category

### P2 - Nice to Have

8. **Biometric Unlock**
   - Fingerprint / Face ID as alternative to master password
9. **Auto-Lock**
   - Lock app after configurable inactivity timeout
10. **Export / Import**
    - Export entries as encrypted file
    - Import from encrypted backup

## Database Schema

### `master` table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| password_hash | TEXT | Hashed master password |
| salt | TEXT | Salt used for hashing |
| created_at | TEXT | Timestamp |

### `categories` table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Category name |
| icon | TEXT | Icon identifier |

### `passwords` table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| title | TEXT | Entry title |
| username | TEXT | Stored username |
| password_encrypted | TEXT | AES-256 encrypted password |
| url | TEXT | Associated URL |
| notes | TEXT | Encrypted notes |
| category_id | INTEGER FK | References categories.id |
| created_at | TEXT | Timestamp |
| updated_at | TEXT | Timestamp |

## Screen Map

```
Splash / Lock Screen
  |
  v
Master Password Input
  |
  v
Home (Password List)
  |-- Search Bar
  |-- Category Filter Chips
  |-- FAB -> Add Entry Screen
  |-- Tap Entry -> Entry Detail Screen
  |       |-- Edit -> Edit Entry Screen
  |       |-- Delete
  |-- Drawer / Settings
        |-- Change Master Password
        |-- Password Generator
        |-- Auto-Lock Settings
        |-- Export / Import
```

## Non-Functional Requirements

- **Security**: No plaintext passwords stored at any point. Encryption key never persisted directly.
- **Performance**: App should load entry list within 500ms for up to 500 entries.
- **Offline**: Fully functional without network access. Zero network calls.
- **Storage**: SQLite database stored in app-private directory (not accessible to other apps).

## Out of Scope

- Cloud sync / multi-device support
- Browser extension or autofill service
- Sharing passwords with other users
- Web or desktop versions
