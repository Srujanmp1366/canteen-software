You are building the FRONTEND ONLY for a Canteen Inventory Management System as a Flutter mobile application.

IMPORTANT CONTEXT

Reference UI repository:
https://github.com/designerhawk12/NGO

The NGO repository is a React/TypeScript web application.

DO NOT port its React code line-by-line.

Instead:
1. Inspect the frontend carefully.
2. Understand its visual language, component patterns, navigation patterns, cards, tables/lists, drawers/modals, filters, badges, stat cards, spacing, typography and general polish.
3. Recreate that visual quality as a Flutter mobile application.
4. Adapt the design properly for MOBILE rather than trying to reproduce a desktop dashboard literally.

BACKEND HAS NOT BEEN DECIDED YET.

Therefore:
- DO NOT implement Spring Boot.
- DO NOT implement Firebase.
- DO NOT hardcode the app around any backend technology.
- DO NOT make direct HTTP calls inside widgets.
- Build a clean frontend architecture with repository/service abstractions and realistic mock data.
- Make it easy to connect a backend later.

==================================================
1. PROJECT GOAL
==================================================

Build a polished Flutter mobile application for:

CANTEEN INVENTORY MANAGEMENT SYSTEM

Main features:

1. Dashboard
2. Raw Materials
3. Stock Batches
4. Stock Transactions
5. Inventory Alerts
6. Suppliers
7. Purchase Orders
8. Purchase Order Items
9. Reports / Analytics
10. Settings

The app should be functional using local/mock data for now.

It should feel like a real inventory management app rather than a collection of static screens.

==================================================
2. REFERENCE UI
==================================================

Inspect:

https://github.com/designerhawk12/NGO

Study especially the concepts represented by:

Dashboard
Volunteers
Teams
Assignments
Settings

Reusable visual ideas to carry into Flutter:

- polished dashboard cards
- clear page headers
- colored status badges
- search bars
- filter chips / filter controls
- structured cards
- detail drawers / detail panels
- add/edit forms
- modal interactions
- summary cards
- empty states
- toast/snackbar feedback
- responsive layouts
- strong spacing and typography
- rounded panels
- subtle shadows/borders
- professional sidebar/topbar equivalents

Do not copy NGO wording or domain concepts.

Remove concepts such as:

Volunteer
Team
Assignment
Food rescue
Driver
Vehicle
Pickup
NGO Coordinator
Bengaluru chapter

The new domain is completely focused on canteen inventory.

==================================================
3. PLATFORM
==================================================

Use Flutter.

Use current stable Flutter and Dart.

Target:

Android first

but structure the app so it can also work on iOS.

The UI should adapt to:

phones
large phones
tablets

Do not design exclusively for one screen size.

==================================================
4. FLUTTER ARCHITECTURE
==================================================

Use a clean feature-oriented project structure.

Recommended:

lib/
|
|-- main.dart
|
|-- app/
|   |-- app.dart
|   |-- theme/
|   |   |-- app_theme.dart
|   |   |-- app_colors.dart
|   |   |-- app_spacing.dart
|   |   |-- app_typography.dart
|   |
|   |-- router/
|       |-- app_router.dart
|
|-- core/
|   |-- widgets/
|   |   |-- app_card.dart
|   |   |-- status_badge.dart
|   |   |-- app_search_bar.dart
|   |   |-- empty_state.dart
|   |   |-- loading_view.dart
|   |   |-- section_header.dart
|   |   |-- stat_card.dart
|   |
|   |-- utils/
|   |   |-- formatters.dart
|   |   |-- validators.dart
|   |
|   |-- constants/
|
|-- models/
|   |-- raw_material.dart
|   |-- inventory.dart
|   |-- stock_batch.dart
|   |-- stock_transaction.dart
|   |-- inventory_alert.dart
|   |-- supplier.dart
|   |-- purchase_order.dart
|   |-- purchase_order_item.dart
|
|-- data/
|   |-- mock/
|   |   |-- mock_inventory_data.dart
|   |
|   |-- repositories/
|       |-- inventory_repository.dart
|       |-- supplier_repository.dart
|       |-- purchase_order_repository.dart
|       |-- mock_inventory_repository.dart
|       |-- mock_supplier_repository.dart
|       |-- mock_purchase_order_repository.dart
|
|-- features/
|   |
|   |-- dashboard/
|   |   |-- presentation/
|   |       |-- dashboard_screen.dart
|   |       |-- widgets/
|   |
|   |-- materials/
|   |-- batches/
|   |-- transactions/
|   |-- alerts/
|   |-- suppliers/
|   |-- purchase_orders/
|   |-- reports/
|   |-- settings/

You may slightly improve this structure if there is a strong architectural reason.

Do not overengineer it.

==================================================
5. STATE MANAGEMENT
==================================================

Use one lightweight state-management solution.

Preferred:

Riverpod

or

Provider

Prefer Riverpod if starting from scratch.

Do not add BLoC, Redux or another heavy architecture unless there is a strong reason.

Keep:

UI
state
repository

separated.

The UI must not directly mutate raw mock lists.

==================================================
6. BACKEND-INDEPENDENT DESIGN
==================================================

Backend is undecided.

Create abstract repository contracts.

Example:

abstract class InventoryRepository {
  Future<List<RawMaterial>> getMaterials();

  Future<RawMaterial?> getMaterialById(String id);

  Future<void> addMaterial(RawMaterial material);

  Future<void> updateMaterial(RawMaterial material);

  Future<void> addStock(...);

  Future<void> removeStock(...);
}

Then create:

MockInventoryRepository

that stores or manipulates mock data.

Later, the team should be able to create:

ApiInventoryRepository

FirebaseInventoryRepository

SupabaseInventoryRepository

etc.

without rewriting screens.

This separation is VERY IMPORTANT.

==================================================
7. DOMAIN MODEL
==================================================

Implement the following Dart models.

-----------------------------------
RAW MATERIAL
-----------------------------------

Fields:

materialId
name
category
unit
reorderLevel
currentQuantity
pricePerUnit
expiryRequired
isActive
createdAt
updatedAt

Computed helpers:

isLowStock
isOutOfStock
stockValue

Units:

KG
GRAM
LITRE
ML
PIECE
PACKET
BOX

Use enum UnitType or another suitable name.

-----------------------------------
INVENTORY
-----------------------------------

Fields:

inventoryId
materialId
totalQuantity
availableQuantity
reservedQuantity
lastUpdated

-----------------------------------
STOCK BATCH
-----------------------------------

Fields:

batchId
materialId
quantity
purchaseDate
expiryDate
purchasePrice
status

BatchStatus:

active
expiringSoon
expired
consumed

Computed:

isExpired
remainingDays

-----------------------------------
STOCK TRANSACTION
-----------------------------------

Fields:

transactionId
transactionType
materialId
batchId
quantity
transactionDate
referenceId
referenceType
notes
createdBy

TransactionType:

stockIn
stockOut
adjustment
transfer

-----------------------------------
INVENTORY ALERT
-----------------------------------

Fields:

alertId
materialId
alertType
thresholdQuantity
currentQuantity
message
status
createdAt
resolvedAt

AlertType:

lowStock
expirySoon
expired
reorder

AlertStatus:

active
resolved
ignored

-----------------------------------
SUPPLIER
-----------------------------------

Fields:

supplierId
supplierName
contactPerson
phoneNumber
email
address
isActive
createdAt
updatedAt

-----------------------------------
PURCHASE ORDER
-----------------------------------

Fields:

orderId
supplierId
orderDate
expectedDeliveryDate
status
totalAmount
notes
createdAt
updatedAt
items

PurchaseOrderStatus:

pending
confirmed
partiallyDelivered
delivered
cancelled

-----------------------------------
PURCHASE ORDER ITEM
-----------------------------------

Fields:

orderItemId
orderId
materialId
quantity
unitPrice
subTotal

Computed:

subTotal = quantity * unitPrice

==================================================
8. APP NAVIGATION
==================================================

This is a mobile app.

Do NOT recreate a permanent desktop sidebar on phones.

Use a mobile-first navigation system.

Recommended:

BottomNavigationBar / NavigationBar

Main tabs:

1. Dashboard
2. Inventory
3. Purchase
4. Alerts
5. More

Inside these:

Inventory:
- Raw Materials
- Stock Batches
- Stock Transactions

Purchase:
- Purchase Orders
- Suppliers

More:
- Reports
- Settings

For tablets:
you may use NavigationRail where appropriate.

Use responsive navigation:

phone:
NavigationBar

tablet:
NavigationRail

Keep route handling clean.

Use go_router if useful.

==================================================
9. APP BRANDING
==================================================

Brand:

Canteen Inventory

Subtitle if needed:

Smart Stock Management

Avoid NGO text.

Use a clean professional theme.

Suggested feel:

fresh
modern
minimal
slightly green / teal inventory theme

Do not make the app overly colorful.

Use semantic colors:

green:
healthy stock
active
delivered

orange:
low stock
pending
expiring soon

red:
out of stock
expired
cancelled

blue:
confirmed
stock in
informational

gray:
inactive
consumed

==================================================
10. DASHBOARD SCREEN
==================================================

Create a polished Dashboard.

App bar:

Canteen Inventory

Optional greeting:

Good morning
Inventory Manager

Main summary section:

Total Materials
Low Stock
Expiring Soon
Pending Orders

On mobile:

use a 2x2 grid of stat cards.

Example:

[ 42 ]
Total Materials

[ 7 ]
Low Stock

[ 4 ]
Expiring Soon

[ 6 ]
Pending Orders

Then sections:

A. Low Stock

Show 3-5 items.

Each card/list row:

Material Name
Current stock
Reorder level
status
progress indicator

Example:

Cooking Oil
8 L / reorder at 15 L
LOW STOCK

B. Expiring Soon

Material
Batch
expiry date
remaining days

C. Recent Transactions

Example:

Rice
+50 kg
Stock In
PO-1002

Milk
-8 L
Stock Out
Kitchen Usage

D. Recent Purchase Orders

Supplier
amount
status
expected date

Each section should have:

"View all"

navigation.

Do not overcrowd the dashboard.

==================================================
11. RAW MATERIALS SCREEN
==================================================

Screen:

Raw Materials

Header action:

+ Add Material

Use:

FloatingActionButton

or

prominent app-bar action.

Search bar:

Search material, category or ID

Filters should open via:

filter icon

and/or FilterChips.

Filters:

Category
Status
Unit
Low Stock
Active/Inactive

List items/cards should display:

Material Name
Material ID
Category
Current Quantity + Unit
Reorder Level
Price Per Unit
Stock Value
Status Badge

Example:

Rice
MAT-001
Grains

85 KG
Reorder: 30 KG

₹52 / KG

₹4,420 stock value

IN STOCK

Tap opens Material Details Screen.

Long press is not required.

Provide popup menu:

Edit
Add Stock
Remove Stock
View Batches
Deactivate

==================================================
12. MATERIAL DETAILS SCREEN
==================================================

Create a complete detail screen.

Top:

Rice

MAT-001

IN STOCK

Summary cards:

Current Stock
Reorder Level
Price / Unit
Stock Value

Details:

Category
Unit
Expiry Tracking
Created
Updated
Active Status

Then:

Recent Transactions

Stock Batches

Buttons:

Add Stock
Remove Stock
Edit Material

Use bottom sheets or dialogs for quick actions.

==================================================
13. ADD / EDIT MATERIAL
==================================================

Create reusable form.

Fields:

Material Name
Category
Unit
Reorder Level
Price Per Unit
Expiry Required

Category could initially use predefined values.

Categories:

Grains
Dairy
Vegetables
Grocery
Beverages
Bakery
Protein
Spices

Allow architecture for custom categories later.

Validation:

name required
category required
unit required
reorder level >= 0
price >= 0

Use proper Flutter Form validation.

Use Snackbar after success.

==================================================
14. ADD STOCK
==================================================

Create Add Stock bottom sheet or full-screen form.

Fields:

Material
Quantity
Batch ID
Purchase Date
Expiry Date
Purchase Price
Reference
Notes

Rules:

quantity > 0

For material.expiryRequired:

Expiry Date should be required.

Otherwise:

Expiry Date optional.

Submitting should update mock app state.

It should:

increase quantity
create/update stock batch
create stockIn transaction
recalculate alerts

This should work locally with mock repository logic.

==================================================
15. REMOVE STOCK
==================================================

Create Remove Stock UI.

Fields:

Material
Batch
Quantity
Reason
Reference
Notes

Reasons:

Kitchen Consumption
Damaged
Wastage
Manual Correction
Other

Validation:

quantity > 0

quantity <= available stock

Upon submit:

decrease stock
update batch quantity
create stockOut transaction
recalculate alerts

Show error Snackbar if quantity exceeds stock.

==================================================
16. STOCK BATCHES SCREEN
==================================================

Create:

Stock Batches

Search:

Batch ID
Material

Filter chips:

All
Active
Expiring Soon
Expired
Consumed

Each list item:

Batch ID
Material
Quantity
Purchase Date
Expiry Date
Remaining Days
Status

Example:

Milk

BAT-102

18 L

Expires 04 Oct

4 days remaining

EXPIRING SOON

Tap opens Batch Details Screen.

==================================================
17. BATCH DETAILS
==================================================

Show:

Batch ID
Material
Current Quantity
Purchase Price
Purchase Date
Expiry Date
Remaining Days
Status

Then:

Transactions involving batch.

If expired:

show clear warning.

If consumed:

show neutral status.

==================================================
18. STOCK TRANSACTIONS SCREEN
==================================================

Use segmented tabs/filter chips:

All
Stock In
Stock Out
Adjustment
Transfer

Search:

Transaction ID
Material
Reference

Transaction item should show:

Material
Transaction Type
Quantity
Date/time
Batch
Reference

Use:

+50 KG

for stock in

and

-8 L

for stock out

Use semantic icons/colors.

Tap opens details.

==================================================
19. TRANSACTION DETAILS
==================================================

Show:

Transaction ID
Material
Batch
Type
Quantity
Date/time
Reference ID
Reference Type
Notes
Created By

Transactions should be read-only.

==================================================
20. INVENTORY ALERTS SCREEN
==================================================

Main Alerts tab.

Display active alerts prominently.

Filter:

All
Low Stock
Expiry Soon
Expired
Reorder

Also allow:

Active
Resolved
Ignored

Alert card:

Icon

Material Name

LOW STOCK

"Cooking Oil is below reorder level."

Current:
8 L

Threshold:
15 L

Created:
Today, 10:20 AM

Actions:

View Material
Resolve
Ignore

For low-stock alerts:

also:

Create Purchase Order

but this can initially navigate to Create Order with material preselected.

==================================================
21. SUPPLIERS SCREEN
==================================================

Create:

Suppliers

Search by:

Supplier name
Contact person
Phone
Email

Filter:

Active
Inactive

Supplier card:

Supplier Name
Contact Person
Phone
Email
Active Orders
Status

Tap -> Supplier Details.

FloatingActionButton:

Add Supplier

==================================================
22. SUPPLIER DETAILS
==================================================

Show:

Supplier Name
Supplier ID
Contact Person
Phone
Email
Address
Status

Metrics:

Total Orders
Active Orders
Total Purchase Value

Recent Orders

Actions:

Edit
Deactivate / Activate
Create Purchase Order

Use url_launcher only if needed for:

phone
email

but avoid unnecessary dependencies if not required.

==================================================
23. ADD / EDIT SUPPLIER
==================================================

Fields:

Supplier Name
Contact Person
Phone
Email
Address

Validation:

Supplier name required
Phone required
Valid email if supplied

==================================================
24. PURCHASE ORDERS SCREEN
==================================================

Create:

Purchase Orders

Status chips:

All
Pending
Confirmed
Partially Delivered
Delivered
Cancelled

Order card:

PO-2026-0012

Fresh Farms

3 items

₹8,550

Expected:
03 Oct 2026

CONFIRMED

Tap -> Purchase Order Details.

FAB:

Create Order

==================================================
25. CREATE PURCHASE ORDER
==================================================

Use full screen form.

Fields:

Supplier
Expected Delivery Date
Notes

Dynamic item list.

Each order item:

Material
Quantity
Unit Price

Display:

Subtotal

Allow:

Add Item
Remove Item

Prevent duplicate material items.

At bottom:

Order Total:
₹8,550

Button:

Create Purchase Order

Validation:

supplier required
at least one item
quantity > 0
unit price >= 0

The mock repository should save the order.

==================================================
26. PURCHASE ORDER DETAILS
==================================================

Display:

Order ID
Supplier
Order Date
Expected Delivery
Status
Notes

Items section:

Rice
50 KG × ₹52
₹2,600

Cooking Oil
30 L × ₹125
₹3,750

Milk
40 L × ₹55
₹2,200

Total

₹8,550

Actions depend on status.

Pending:

Confirm Order
Cancel

Confirmed:

Receive Items
Cancel

Partially Delivered:

Receive Remaining

Delivered:

No modification

Cancelled:

No modification

==================================================
27. RECEIVE ORDER
==================================================

Implement frontend mock workflow.

Receive Order screen/bottom sheet:

For each item:

Material
Ordered
Received
Remaining
Receive Now

Batch ID
Purchase Date
Expiry Date

Upon receive:

create/update batches
increase inventory
create stockIn transactions
update alerts
update purchase order status

If all received:

delivered

If some:

partiallyDelivered

This should work in mock state.

==================================================
28. REPORTS SCREEN
==================================================

Create mobile analytics screen.

Cards:

Inventory Value

Low Stock Count

Expired Stock

Purchase Spend

Sections:

Inventory Value by Category

Stock In vs Stock Out

Monthly Purchase Spending

Most Reordered Materials

Use simple charts.

You may use:

fl_chart

if required.

Do not add multiple chart libraries.

Keep charts mobile-friendly.

Also provide report shortcuts:

Current Stock Report
Low Stock Report
Expiring Stock
Stock Movement
Purchase Report
Supplier Report

For now they can show generated on-screen report lists.

PDF/export is not required yet.

==================================================
29. SETTINGS SCREEN
==================================================

Settings:

Canteen Name
Manager Name
Currency
Expiry Warning Days

Notifications:

Low Stock
Expiry
Purchase Orders

Appearance:

System
Light
Dark

About App

App Version

Since backend is not implemented yet:

do not include server credentials.

==================================================
30. THEME
==================================================

Create centralized theme.

Do not scatter color constants across widgets.

Files:

app_colors.dart
app_theme.dart
app_spacing.dart

Use Material 3.

Support light theme.

Dark theme can also be supported if straightforward.

Recommended characteristics:

soft off-white background
white cards
subtle borders
green/teal accent
rounded corners
clean icons
high readability

Avoid large gradients.

Avoid excessive shadows.

==================================================
31. MOBILE DESIGN RULES
==================================================

Do NOT use giant desktop-style tables on phone screens.

Convert data to:

ListView
Cards
ExpansionTiles
responsive rows

On tablets:

you may use DataTable where it makes sense.

Phone-first examples:

Material list = cards/list tiles

Purchase orders = cards

Transactions = timeline-like rows

Alerts = alert cards

Tables should not be the default mobile representation.

==================================================
32. RESPONSIVE DESIGN
==================================================

Use LayoutBuilder / MediaQuery responsibly.

Create width breakpoints if helpful.

For example:

<600:
phone layout

600-900:
tablet layout

>900:
large tablet

On large screens:

stat cards can show 4 across

on phone:

2 across

Do not hardcode fixed widths that cause overflow.

==================================================
33. MOCK DATA
==================================================

Create realistic mock data.

Materials:

Rice
Wheat Flour
Cooking Oil
Milk
Curd
Tomatoes
Onions
Potatoes
Sugar
Salt
Tea Powder
Coffee Powder
Bread
Eggs
Dal
Paneer

Categories:

Grains
Dairy
Vegetables
Grocery
Beverages
Bakery
Protein
Spices

Suppliers:

Fresh Farms
Metro Food Supplies
Sri Lakshmi Traders
Daily Dairy Distributors
Campus Wholesale Foods

Create:

15+ materials

10+ batches

20+ stock transactions

5+ alerts

5 suppliers

8+ purchase orders

Mix statuses so every UI state can be tested.

Use Indian currency:

₹

Use realistic quantities.

==================================================
34. MOCK BUSINESS LOGIC
==================================================

Mock implementation must behave realistically.

Example:

If stock goes:

20 -> 8

and reorder level is:

10

create LOW_STOCK alert.

If stock becomes:

18

resolve LOW_STOCK alert.

If batch expiry is within configured expiry-warning days:

mark expiringSoon

If expiry date passed:

expired

If batch quantity becomes 0:

consumed

Do not just display prewritten fake statuses.

Derive statuses where possible.

==================================================
35. FEEDBACK
==================================================

Use:

SnackBar

for:

Material added
Material updated
Stock added
Stock removed
Supplier created
Purchase order created
Order confirmed
Stock received
Alert resolved

Use error Snackbar for invalid actions.

==================================================
36. EMPTY STATES
==================================================

Create reusable empty states.

Examples:

No materials found

No active alerts

No purchase orders found

No transactions match your filter

Include helpful actions when appropriate.

==================================================
37. LOADING / ERROR ARCHITECTURE
==================================================

Even though mock data loads instantly, architecture should support:

loading
success
error

So backend integration later does not require a UI rewrite.

Use AsyncValue if using Riverpod.

==================================================
38. SEARCH AND FILTER EXPERIENCE
==================================================

Avoid permanently displaying too many filters.

Mobile UX:

Search field

Filter icon with bottom sheet

Quick FilterChips for common filters

Example Raw Materials:

[All]
[Low Stock]
[Out of Stock]

More filters -> filter bottom sheet.

==================================================
39. FORM UX
==================================================

Use:

TextFormField
DropdownButtonFormField or modern equivalent
Date picker
SwitchListTile
validation messages

Keyboard:

appropriate inputType

price:
numberWithOptions(decimal: true)

quantity:
number

email:
emailAddress

phone:
phone

Use SafeArea.

Ensure keyboard doesn't hide form actions.

==================================================
40. CODE QUALITY
==================================================

Requirements:

Use null safety.

Avoid dynamic where proper models are possible.

Avoid giant widgets.

Extract reusable widgets.

Use const constructors wherever possible.

No unused imports.

No analyzer warnings where practical.

No dead NGO code.

Clear class names.

Do not put all screens into one file.

Avoid business logic directly inside build().

==================================================
41. DEPENDENCIES
==================================================

Keep dependencies minimal.

Recommended:

flutter_riverpod
go_router
intl

Optional:

fl_chart

Do not add packages unnecessarily.

Avoid code generation initially unless it adds major value.

No Freezed required unless already useful.

==================================================
42. DATE / MONEY FORMATTING
==================================================

Use intl.

Dates:

30 Sep 2026

Times:

10:30 AM

Currency:

₹8,550.00

Use Indian locale formatting where suitable.

==================================================
43. IMPLEMENTATION ORDER
==================================================

Do NOT try to create every screen badly in one giant pass.

Build in phases.

PHASE 1

Foundation:

Flutter project structure
theme
router
models
mock repositories
Riverpod setup
bottom navigation
reusable widgets

Then implement:

Dashboard
Raw Materials
Material Details
Add/Edit Material
Add Stock
Remove Stock

Make sure this phase compiles.

PHASE 2

Stock Batches
Batch Details
Transactions
Transaction Details
Inventory Alerts

Compile/test.

PHASE 3

Suppliers
Supplier Details
Purchase Orders
Create Purchase Order
Purchase Order Details
Receive Order

Compile/test.

PHASE 4

Reports
Settings
responsive tablet layouts
empty states
polish
dark theme if implemented

==================================================
44. REUSABLE WIDGETS
==================================================

Create reusable widgets where sensible.

Possible:

InventoryStatCard

StatusBadge

MaterialListTile

TransactionTile

AlertCard

PurchaseOrderCard

SupplierCard

SectionHeader

AppSearchBar

EmptyStateView

QuantityDisplay

MoneyText

FilterBottomSheet

Do not build duplicate versions on every screen.

==================================================
45. STATUS BADGE
==================================================

Create reusable StatusBadge.

It should support statuses across domains.

Examples:

IN STOCK
LOW STOCK
OUT OF STOCK

ACTIVE
EXPIRING SOON
EXPIRED
CONSUMED

STOCK IN
STOCK OUT

PENDING
CONFIRMED
PARTIALLY DELIVERED
DELIVERED
CANCELLED

ACTIVE ALERT
RESOLVED
IGNORED

Use icon/color carefully.

==================================================
46. INVENTORY DOMAIN BEHAVIOR
==================================================

Important:

RawMaterial.currentQuantity and Inventory.availableQuantity should remain consistent in mock logic.

When adding stock:

increase both

When removing stock:

decrease both

Transactions should be automatically generated.

Never allow inventory to become negative.

==================================================
47. PURCHASE ORDER DOMAIN BEHAVIOR
==================================================

Creating order:

pending

Confirm:

confirmed

Receiving partial quantity:

partiallyDelivered

Receiving all:

delivered

Cancel:

cancelled

Cannot cancel delivered order.

Cannot receive cancelled order.

Cannot receive above ordered remaining amount.

Enforce these rules in mock repository/services.

==================================================
48. APP START EXPERIENCE
==================================================

When opened:

show Dashboard immediately.

No authentication is required yet.

Do not build login/signup right now.

Backend/auth can be added after the team decides architecture.

==================================================
49. TESTING
==================================================

At minimum:

Run:

flutter analyze

Ensure no critical analyzer errors.

Run:

flutter test

Add a few basic tests for:

stock cannot become negative

low stock calculation

purchase order total

batch expiry calculation

order receive status logic

Do not spend excessive time on test coverage during first frontend prototype.

==================================================
50. README
==================================================

Create/update README.md.

Explain:

Project name

Canteen Inventory Management

Tech:

Flutter
Dart
Riverpod
go_router
Mock Repository Layer

Explain current status:

FRONTEND PROTOTYPE
NO FINAL BACKEND SELECTED YET

Explain how to run:

flutter pub get
flutter run

Explain architecture.

Mention:

repository interfaces are intentionally backend-agnostic.

Explain future backend integration point.

==================================================
51. IMPORTANT DON'TS
==================================================

Do NOT:

Build React frontend.

Build Spring Boot backend.

Build Firebase integration.

Make direct HTTP requests.

Store all data directly inside widgets.

Copy NGO source code literally.

Leave NGO names/text anywhere.

Use desktop tables everywhere.

Use huge monolithic Dart files.

Hardcode every UI status.

Create fake buttons that do nothing if an action can be reasonably simulated.

Overcomplicate architecture.

==================================================
52. FINAL EXPECTED RESULT
==================================================

The Flutter app should allow a user to:

Open Dashboard

View inventory statistics

Browse materials

Search/filter materials

Add material

Edit material

View material details

Add stock

Remove stock

See batches

See stock transactions

View active alerts

Resolve/ignore alerts

Browse suppliers

Add/edit suppliers

Create purchase orders

Confirm orders

Receive stock from an order

See inventory automatically update

See transactions automatically created

See low-stock alerts update

View reports

Configure settings

All of this should work using mock/local repositories WITHOUT any backend.

==================================================
53. EXECUTION INSTRUCTIONS
==================================================

First inspect the NGO reference repo.

Then inspect the current Flutter repository if one already exists.

Before coding, briefly summarize:

1. Existing project structure
2. Reusable concepts from NGO reference
3. Flutter architecture you will use
4. Files you plan to create/change
5. Phase you are implementing first

Then implement PHASE 1.

After Phase 1:

Run:

flutter pub get
flutter analyze
flutter test

Fix errors.

Do not proceed while the app is broken.

Then report:

- files created
- files modified
- features completed
- remaining phases
- any assumptions

Continue with subsequent phases only when requested, unless explicitly instructed to implement all phases.

The first priority is a CLEAN, COMPILABLE, POLISHED FLUTTER FRONTEND with BACKEND-INDEPENDENT architecture.