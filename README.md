# Canteen Inventory Management

**FRONTEND PROTOTYPE — NO FINAL BACKEND SELECTED YET**

A mobile-first Flutter application built from `PROJ_SPEC.md`. Phase 1 implements inventory management using session-local mock repositories. Android is the primary target; iOS scaffolding and a Flutter web preview target are included.

## Run

Requires Flutter 3.47+ stable / Dart 3.13+. This workspace was validated with Flutter 3.47.5 and Dart 3.13.4.

```powershell
flutter pub get
flutter run
```

The selected SDK is `C:\src\flutter`, as requested. Its SDK package metadata is valid. To use it explicitly from this workspace:

```powershell
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run
```

Connect an Android device with USB debugging or start an emulator first. For browser preview, append `-d chrome`. Building iOS requires macOS and Xcode. `.tooling/` contains an unused fallback SDK downloaded during initial setup, and `.reference/` contains the design reference. Both are ignored by Git. The app uses the selected SDK at `C:\src\flutter`.

## Phase 1 features

- Dashboard with live counts, inventory value, low-stock materials, expiry previews, transactions, and purchase summaries.
- Responsive bottom navigation on phones and navigation rail at 700 px and above; adaptive cards on tablets.
- Material search by name/category/ID; stock, category, unit, and active/inactive filters.
- Material details, add/edit forms, activation/deactivation, and batch/history previews.
- Add stock with batch/date/expiry validation. Remove stock from a selected batch with quantity and reason validation.
- Repository-enforced non-negative stock, consistent material/inventory balances, automatic stock transactions, and recalculated low-stock/expiry alerts.
- Loading, error/retry, empty states, and success/error snackbars.
- 16 materials, 16 batches, 32 opening/usage transactions, derived alerts, 5 suppliers, and 8 purchase-order samples.

Purchase and alert tabs currently provide read-only summaries. Full management screens are deliberately deferred according to the phased instructions in the specification. More describes the prototype and planned settings/reports.

## Architecture

- `lib/app/`: app startup, centralized Material 3 colors/spacing/typography, go_router routes and responsive shell.
- `lib/models/`: immutable domain entities and derived helpers.
- `lib/data/repositories/`: backend-independent repository contracts and mock implementations.
- `lib/data/mock/`: realistic relative-date sample data.
- `lib/features/materials/application/`: Riverpod repository providers and AsyncNotifier state/controller.
- `lib/features/*/presentation/`: dashboard, material screens/forms and read-only workspace summaries.
- `lib/core/`: reusable cards, status badges, async/empty states, form controls, validators and Indian date/currency formatting.
- `test/`: repository invariants and mobile/tablet widget workflows.

Widgets invoke controller commands. The controller delegates to `InventoryRepository` and publishes a fresh immutable snapshot. Widgets never mutate mock lists or issue HTTP requests. Supplier and purchase-order contracts expose read operations for Phase 1 and can be extended with commands when their workflows are implemented.

To integrate a future backend, implement these repository contracts and replace the providers in `inventory_controller.dart`. Keep server validation and atomic stock updates behind that boundary. No Spring Boot, Firebase, authentication, or backend-specific client is included.

## Mock rules and assumptions

- Changes are in memory and reset when the app restarts; no persistence is implied.
- `currentQuantity` equals inventory `availableQuantity` and the sum of remaining batch quantities. Reservations are zero in Phase 1. Physical expired stock remains counted until disposed of.
- Low stock means quantity is at or below the reorder level. A healthy replenishment resolves the alert; falling below the threshold reopens it.
- Expiry uses local calendar dates: a batch remains usable on its expiry date, is expired the next day, and warns within seven days. Empty batches are consumed.
- Expired batches cannot be removed for kitchen consumption; disposal/correction is supported.
- Units cannot change after stock history exists. Enabling mandatory expiry tracking is rejected while undated stock remains.
- An existing batch can be topped up only when material, purchase date, expiry and price match. Rejected commands leave all balances and transactions unchanged.
- Stock value uses the material's current unit price. Batch purchase prices are retained separately.
- Seeded stock movements reconcile to current stock. Purchase orders are independent demonstration records, not a complete historical purchase ledger.

## Verification

The analyzer reports no issues. All 13 domain/UI tests and both phone/tablet preview checks pass with `C:\src\flutter`. The release web build also succeeds. An Android SDK is not installed on this machine, so native Android packaging has not been verified. iOS packaging requires macOS/Xcode.

```powershell
C:\src\flutter\bin\flutter.bat analyze
C:\src\flutter\bin\flutter.bat test
C:\src\flutter\bin\flutter.bat build web
```

To render disposable phone/tablet previews using the selected SDK (override `FLUTTER_SDK` with `--dart-define` for another installation):

```powershell
C:\src\flutter\bin\flutter.bat test tool/render_preview.dart
```

PNG previews are written to `build/previews/`.

## Remaining phases

2. Dedicated batch and transaction lists/details, filters, alert resolve/ignore actions.
3. Supplier CRUD, purchase-order creation/confirmation/cancellation, partial and complete receiving with inventory updates.
4. Reports/charts, settings, notification preferences, appearance and final polish.

The model-level purchase total and receipt-status calculation are tested now; the purchase receiving workflow itself is not implemented in Phase 1.

## Design reference

The [reference UI](https://github.com/designerhawk12/NGO) informed forest-green accents, off-white surfaces, bordered rounded cards, status pills, clear page headers, search/filter patterns, and detail/form interactions. These concepts were adapted to Flutter phone and tablet layouts. No React implementation or domain text is shipped with this app.
