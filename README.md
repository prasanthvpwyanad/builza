# BUILZA

Multi-tenant cashbook and project expense app for construction and interior companies.

Each company has its own isolated workspace and up to two administrators.

```
BUILZA SaaS
   ├── Company A (DRUVA)
   │      ├── Admin 1
   │      ├── Admin 2
   │      └── Projects / Cashbook
   ├── Company B
   │      ├── Admin 1
   │      ├── Admin 2
   │      └── Projects / Cashbook
   └── Company C
          ├── Admin 1
          └── Projects / Cashbook
```

## Current stage
- Flutter UI and navigation
- Firebase authentication with company registration
- Two-admin access, invite codes, and tenant-isolated Firestore rules
- Projects, cashbook, dues and reports still use sample data until those modules are wired

## Requirements
- Flutter stable (3.24+ recommended)
- Dart 3.5+
- A Firebase project with Email/Password auth, Cloud Firestore, and Storage

## Run
```bash
flutter pub get
flutter run
```

Until Firebase is configured, the app opens a setup screen instead of using placeholder credentials.

## Connect Firebase
1. Create a Firebase project in the Firebase Console.
2. Enable **Authentication → Email/Password**, **Cloud Firestore** (production mode), and **Storage**.
3. Install CLIs:
   ```bash
   dart pub global activate flutterfire_cli
   npm install -g firebase-tools
   firebase login
   ```
4. From this repo:
   ```bash
   flutterfire configure
   firebase init
   firebase deploy --only firestore:rules,storage
   ```
5. Restart the app. `lib/firebase_options.dart` must contain a real `projectId` and API key, not `YOUR_PROJECT_ID`.
6. Register the first company as Admin 1, then invite Admin 2 from **Company** in the app bar.

Application IDs currently used by the starter:
- Android: `com.example.builza`
- iOS: `com.example.builza`

Change these before production, then run `flutterfire configure` again.

## Data layout
Financial records are always stored under a company. Never at the root.

```
users/{uid}                          # companyId, role, adminSlot
companies/{companyId}                # name, adminUids (max 2)
companies/{companyId}/projects
companies/{companyId}/transactions
companies/{companyId}/dues
joinCodes/{CODE}                     # one-time Admin 2 invite
```

Firestore rules allow an administrator to read and write only their own company. A second admin can join only with a valid unused invite code.

## Important production notes
- Transaction forms still do not save real cashbook records.
- Use integer paise for all currency values.
- Use immutable transaction records / audit logs for edits and deletions.
- Do not calculate financial totals from untrusted client-side values alone.
- Daily Google Drive backup needs a secure server-side integration. Do not embed private credentials in the app.
