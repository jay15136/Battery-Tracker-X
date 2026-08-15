# Battery Tracker — Master ChatGPT Codex Development Prompt

You are a senior software architect and application developer. Build a complete desktop application called **Battery Tracker**.

The application is a rechargeable-battery inventory, battery-set, device-assignment, charge-history, QR-label, and inventory-management system.

The first release will run on **Windows 11**, but the codebase and architecture must be designed from the beginning so the application can later be released for:

- Windows
- Android
- iPhone/iPad
- macOS

Use a cross-platform technology stack so the application does not need to be rewritten for mobile platforms later.

---

# 1. PREFERRED TECHNOLOGY STACK

Use:

- **Flutter** for the application framework and user interface
- **Dart** for application code
- **SQLite** for the local database
- A clean repository/data-access layer
- Local application-managed storage for photographs and custom icons
- Appropriate Flutter packages for:
  - SQLite
  - file selection
  - drag and drop
  - image handling
  - webcam/camera access where practical
  - UUID generation
  - date/time handling
  - QR code generation
  - QR decoding
  - PDF generation
  - Windows printing
  - CSV import/export
  - archive/ZIP creation
  - logging

Use a recognized Flutter state-management approach. Choose a reasonable option and document why it was selected.

The first version must work entirely **offline**.

Do not require:

- a cloud account
- a web server
- an internet connection
- user registration

Design the architecture so cloud synchronization can be added later without rewriting the entire application.

---

# 2. APPLICATION PURPOSE

Battery Tracker allows a user to:

- Maintain an inventory of rechargeable batteries
- Track batteries individually
- Organize batteries into reusable Battery Sets
- Track which batteries or sets are assigned to devices
- Maintain device records
- Record charging activity
- Track battery condition and status
- Use generic or custom icons for fast visual identification
- Optionally add photographs
- Generate and print QR-code labels
- Bulk-create batteries
- Bulk-edit batteries
- Export inventory data
- Back up and restore all application data

Examples of batteries include:

- AA rechargeable batteries
- AAA rechargeable batteries
- C batteries
- D batteries
- 9V batteries
- CR123 rechargeable batteries
- 18650 cells
- 21700 cells
- camera batteries
- power-tool batteries
- drone batteries
- portable-radio batteries
- gaming-controller batteries
- proprietary battery packs
- custom battery types

The application must NOT restrict the user to predefined battery types.

Users must be able to create custom:

- battery types
- manufacturers
- models
- chemistry values
- capacities
- device categories
- icon categories
- notes
- labels

---

# 3. CORE VERSION 1 DESIGN PRINCIPLE

Throughout Battery Tracker, follow this rule:

**Icons identify inventory. Photographs add detail.**

The application must use an:

**ICON-FIRST, PHOTO-OPTIONAL**

design.

Every Battery, Battery Set, and Device must always have a usable visual identifier.

A photograph is optional.

The application must remain fully usable without a single photograph.

A user must be able to create hundreds of Batteries, Battery Sets, and Devices using only:

- names
- IDs
- built-in or custom icons
- icon colors
- specifications
- status
- condition
- assignment data

Photographs are an optional enhancement.

---

# 4. CORE APPLICATION SECTIONS

Use a modern Windows desktop layout with a left navigation sidebar.

Create these main sections:

1. Dashboard
2. Batteries
3. Battery Sets
4. Devices
5. Assignments
6. Battery Types
7. QR Labels
8. History
9. Settings

---

# 5. DASHBOARD

Create a clean dashboard showing current inventory status.

Display summary cards for:

- Total Batteries
- Available Batteries
- Batteries Assigned to Devices
- Batteries in Sets
- Battery Sets
- Batteries Charging
- Batteries Needing Attention
- Retired Batteries
- Total Devices

Also display:

## Recent Activity

Examples:

- Battery created
- Battery updated
- Battery assigned to device
- Battery removed from device
- Battery added to set
- Battery removed from set
- Battery set assigned to device
- Battery marked charged
- Battery set marked charged
- QR label generated
- QR label printed
- Device created
- Battery retired

## Batteries Needing Attention

Examples:

- Condition marked Poor
- Battery marked Damaged
- Battery retired
- Battery has not been charged recently
- Battery has exceeded a user-configured recorded-charge threshold
- Battery in a set has substantially different usage than the other set members

Do not overcomplicate battery-health calculations in Version 1.

---

# 6. BATTERY INVENTORY

The Batteries section is the central inventory screen.

Provide:

- Table View
- Card View
- Search
- Sorting
- Filtering
- Multi-select
- Bulk actions

Filters should include:

- Battery Type
- Manufacturer
- Chemistry
- Status
- Condition
- Device Assignment
- Battery Set
- Batch ID

---

# 7. BATTERY RECORD

Each battery must have its own individual record.

Store at minimum:

## Identification

- Internal database ID
- Permanent UUID
- User Battery ID
- Battery Name
- Battery Type
- Manufacturer
- Model
- Serial Number
- Custom Label
- Batch ID, optional

The permanent UUID must never change.

The editable Battery ID is a user-facing identifier.

Examples:

- AA-001
- AA-002
- AAA-001
- 18650-001
- TOOL-001
- CAM-001

Allow automatic sequential ID suggestions.

Allow users to override suggested IDs.

---

# 8. BATTERY SPECIFICATIONS

Store:

- Battery Type
- Chemistry
- Nominal Voltage
- Capacity
- Capacity Unit
- Rechargeable Yes/No
- Manufacturer
- Model

Chemistry examples:

- NiMH
- NiCd
- Li-ion
- LiPo
- LiFePO4
- Lead Acid
- Proprietary
- Other

Allow custom chemistry values.

---

# 9. BATTERY PURCHASE INFORMATION

Allow optional storage of:

- Purchase Date
- Purchase Location
- Purchase Price
- Total Package Price
- Per-Battery Price
- Warranty Expiration
- Notes

---

# 10. BATTERY STATUS

Provide default statuses:

- Available
- Assigned
- In Set
- Charging
- Storage
- Needs Attention
- Damaged
- Retired

Design the status architecture so additional statuses can be added later.

---

# 11. BATTERY CONDITION

Provide:

- New
- Excellent
- Good
- Fair
- Poor
- Damaged
- Retired

Also provide a free-text condition note.

---

# 12. ICON-FIRST VISUAL SYSTEM

Every Battery, Battery Set, and Device must store:

- Icon Key
- Icon Color
- Icon Source
- Optional Primary Photograph
- Optional Additional Photographs
- Preferred Primary Visual

Preferred Primary Visual supports:

- Icon
- Photograph

The default must be:

**Icon**

Adding a photograph must NOT automatically switch the record to photo-first.

When a photo is added, ask:

- Keep Icon as Primary
- Use Photo as Primary

Default to:

**Keep Icon as Primary**

Icons must remain associated with the record even when photographs exist.

---

# 13. BUILT-IN GENERIC ICON LIBRARY

Create a built-in offline icon library.

Use vector icons where practical.

Do not rely on internet-hosted assets.

## Battery Icons

Include at least:

- AA Battery
- AAA Battery
- C Battery
- D Battery
- 9V Battery
- Coin Cell
- Button Cell
- CR123 Battery
- 18650 Cell
- 21700 Cell
- Cylindrical Battery
- Rectangular Battery
- Camera Battery
- Power Tool Battery
- Radio Battery
- Drone Battery
- Gaming Battery Pack
- Laptop Battery
- Rechargeable Battery Pack
- Generic Battery
- Other Battery

## Device Icons

Include at least:

- Game Controller
- VR Controller
- Flashlight
- Portable Radio
- Camera
- Video Camera
- Drone
- Cordless Drill
- Power Tool
- Remote Control
- Computer Mouse
- Keyboard
- Wireless Microphone
- Headphones
- Speaker
- Phone
- Tablet
- Laptop
- GPS
- Toy
- Medical Device
- Test Equipment
- Smart Home Device
- Security Device
- Generic Electronic Device
- Other Device

## Battery Set Icons

Include at least:

- Battery Pair
- Four-Battery Set
- Battery Group
- Battery Case
- Battery Holder
- Battery Pack
- Generic Battery Set

Do not force a specific icon based on Battery Type or Device Category.

The application may suggest an icon.

The user makes the final selection.

---

# 14. DEFAULT ICONS

If the user does not choose an icon, assign:

Battery:
**Generic Battery**

Battery Set:
**Generic Battery Set**

Device:
**Generic Device**

Never display:

- a blank image box
- a broken image
- a null graphic
- a missing-image placeholder

There must always be a usable visual representation.

---

# 15. ICON SELECTOR

Provide a reusable **Choose Icon** interface.

Support:

- Icon grid
- Search
- Categories
- Built-In Icons
- Custom Icons
- Recently Used Icons
- Selected Icon Preview
- Icon Color
- Reset to Default
- Import Custom Icon

Example categories:

## Batteries
- Standard Cells
- Lithium Cells
- Battery Packs
- Specialty Batteries

## Devices
- Gaming
- Tools
- Lighting
- Cameras
- Radios
- Computer Equipment
- Electronics
- Smart Home
- Other

## Battery Sets
- Groups
- Holders
- Cases
- Packs

---

# 16. ICON COLORS — REQUIRED VERSION 1 FEATURE

Allow users to customize compatible icon colors.

This is required in Version 1.

Provide predefined colors:

- Default
- Black
- Gray
- White
- Red
- Orange
- Yellow
- Green
- Blue
- Purple
- Brown

Also provide a custom color picker.

Store colors using a cross-platform value such as:

- ARGB
- RGBA
- hexadecimal

Example:

`#3F51B5`

Do not store Windows-specific color identifiers.

Allow:

**Reset Icon Color**

Do not rely on color alone for identification.

Always show text identifiers such as:

- AA-001
- SET-001
- Xbox Controller 1

Support Light Mode and Dark Mode.

---

# 17. CUSTOM ICONS — REQUIRED VERSION 1 FEATURE

Allow users to import custom icons into a reusable local icon library.

Provide:

**Import Custom Icon**

Support at minimum:

- PNG
- SVG

Optionally support:

- JPG
- JPEG
- WebP

Prefer PNG and SVG.

## Custom Icon Import Workflow

1. Select Import Custom Icon
2. Select image file
3. Preview icon
4. Enter Icon Name
5. Select Category
6. Optionally specify whether recoloring is supported
7. Save

## Custom Icon Categories

Allow:

- Batteries
- Battery Sets
- Devices
- General
- User-created categories

Examples:

- Gaming
- Police Equipment
- Cameras
- Tools
- Home
- Work
- Electronics

## Custom Icon Management

Create Settings → **Icon Library**

Support:

- Add
- Rename
- Change Category
- Replace Source Image
- Delete
- Duplicate
- Preview

Built-in icons cannot be deleted.

If a custom icon is in use, warn before deletion.

Example:

"This icon is currently used by 7 records."

Provide:

- Cancel
- Replace With Another Icon
- Replace With Default Icons and Delete

Never leave records pointing to missing custom icons.

---

# 18. CUSTOM ICON STORAGE

Store imported icons in application-managed storage.

Example logical layout:

BatteryTracker/
  data/
  images/
  custom_icons/

When importing:

1. Validate file
2. Copy file into application storage
3. Generate permanent icon UUID
4. Store icon metadata in SQLite
5. Reference the application-managed copy

Do not depend on the original user-selected path.

---

# 19. ICON DATABASE AND ARCHITECTURE

Consider a `custom_icons` table with:

- id
- uuid
- name
- category
- file_path
- file_type
- supports_color
- created_at
- modified_at
- is_active

Battery, Battery Set, and Device records should store:

- icon_source
- icon_key
- icon_color

Possible icon_source values:

- builtin
- custom

Built-in icon examples:

- battery_aa
- battery_aaa
- battery_18650
- battery_tool
- device_controller
- device_flashlight
- device_radio
- device_camera
- device_generic

For custom icons, use a permanent custom-icon UUID.

Create a centralized:

**IconService / IconRegistry**

It must handle:

- built-in icon definitions
- custom icon definitions
- icon IDs
- categories
- display names
- search
- filters
- color
- previews
- defaults
- missing icons
- deprecated icons
- import
- replacement
- deletion

Do not scatter icon-loading logic throughout the application.

---

# 20. OPTIONAL PHOTOGRAPHS

Photographs are optional.

Allow:

- Select photograph from computer
- Drag and drop photograph
- Capture photograph with webcam where practical
- Add multiple photographs
- Choose one photograph as primary
- Remove photographs

Do not automatically open a camera or file picker during normal record creation.

Provide:

**Add Photograph**

If the user cancels, continue using the selected icon.

Store photographs in application-managed storage.

Do not store photographs as SQLite BLOBs unless there is a compelling technical reason.

Store relative paths/references in SQLite.

If a primary photograph becomes unavailable:

1. Do not show a broken image
2. Fall back to the selected icon
3. Surface or log the missing file
4. Allow replacement/removal

---

# 21. BATTERY DETAIL SCREEN

Display:

- Large selected icon or photo
- Battery ID
- Battery Name
- Permanent UUID
- Battery Type
- Manufacturer
- Model
- Chemistry
- Voltage
- Capacity
- Status
- Condition
- Current Battery Set
- Current Device Assignment
- Purchase information
- Notes
- Assignment History
- Set Membership History
- Charge History
- Status History
- Photos
- QR Code

Provide actions:

- Edit
- Change Icon
- Change Icon Color
- Add Photograph
- Use Photo as Primary
- Use Icon as Primary
- Assign to Device
- Add to Battery Set
- Remove from Device
- Remove from Battery Set
- Mark Charged
- Change Status
- Generate QR Label
- Print QR Label
- Retire Battery
- Delete

Require confirmation for destructive actions.

---

# 22. BATTERY TYPES

Create customizable Battery Types.

A Battery Type may contain:

- Type Name
- Description
- Chemistry
- Default Voltage
- Default Capacity
- Capacity Unit
- Physical Size
- Notes
- Suggested Default Icon
- Suggested Default Icon Color

Examples:

- AA NiMH
- AAA NiMH
- 18650 Li-ion
- 21700 Li-ion
- Makita 18V Battery Pack
- Canon LP-E6NH
- Meta Quest Rechargeable Controller Battery

Allow unlimited custom types.

Suggested icon and color are defaults only.

Users can override them.

---

# 23. BATTERY SETS — REQUIRED VERSION 1 FEATURE

Battery Sets are first-class Version 1 records.

Battery Sets group batteries intentionally used or charged together.

Examples:

- Xbox AA Set 1
- Camera Flash Set
- Radio Spare Set
- SET-001
- SET-002

A Battery Set must have:

- Internal database ID
- Permanent UUID
- User Set ID
- Set Name
- Battery Type
- Description
- Notes
- Created Date
- Active/Inactive Status
- Icon
- Icon Color
- Optional photographs

Example:

Set ID:
SET-001

Set Name:
Xbox Rechargeable Set 1

Battery Type:
AA NiMH

Members:
AA-001
AA-002
AA-003
AA-004

---

# 24. BATTERY SET ID GENERATION

Support sequential IDs:

- SET-001
- SET-002
- SET-003

Allow:

- configurable prefix
- starting number
- manual override

---

# 25. BATTERY SET MEMBERSHIP

Allow batteries to be:

- added to a set
- removed from a set
- moved between sets

Maintain historical membership records.

Store:

- Battery
- Set
- Added Date
- Removed Date
- Notes

A battery should normally belong to only one active set.

Warn if adding it to another active set.

Allow override if necessary.

---

# 26. BATTERY SET COMPATIBILITY

When adding batteries to a set, compare:

- Battery Type
- Chemistry
- Voltage
- Capacity

If different, warn.

Example:

"AA-004 has a different capacity than the other batteries in this set."

Allow the user to proceed after acknowledging the warning.

---

# 27. BATTERY SET DETAIL SCREEN

Display:

- Set ID
- Set Name
- Permanent UUID
- Icon or photograph
- Battery Type
- Number of Batteries
- Members
- Current Device
- Created Date
- Recorded Charges
- Last Charged
- Notes
- Assignment History
- Membership History
- QR Code

For every member show:

- Battery ID
- Icon/photo
- Manufacturer
- Capacity
- Condition
- Recorded Charges
- Last Charged
- Status

Actions:

- Edit Set
- Change Icon
- Change Icon Color
- Add Battery
- Remove Battery
- Assign Set to Device
- Remove Set from Device
- Mark Entire Set Charged
- Add Photograph
- Generate QR Label
- Print QR Label
- Deactivate Set
- Delete Set

---

# 28. MARK ENTIRE SET CHARGED

Provide:

**Mark Entire Set Charged**

This creates an individual charge record for every current member.

Also create a set-level activity record.

Use a database transaction.

If the operation fails, do not leave partial charge records.

Show:

- Number of times the entire set was marked charged
- Individual recorded-charge count for each member

Do not imply all members have identical lifetime charge counts.

---

# 29. SET ASSIGNMENTS

Allow an entire Battery Set to be assigned to a Device.

When assigned:

- all member batteries become assigned
- the set shows the assigned Device
- each battery shows the assigned Device
- historical records are created

Use a transaction.

If Device requirements match the set, indicate the match.

If quantity/type differs, warn but allow override.

---

# 30. DEVICES

Devices are simple user-created records.

Examples:

- Xbox Controller 1
- Xbox Controller 2
- Meta Quest Controller Left
- Meta Quest Controller Right
- Police Flashlight
- Portable Radio
- Camera
- Cordless Drill
- Drone
- Wireless Microphone
- Remote Control

Store:

- UUID
- Device Name
- Device Category
- Manufacturer
- Model
- Serial Number
- Location
- Description
- Notes
- Date Added
- Active/Inactive Status
- Icon
- Icon Color
- Optional photographs

Allow custom categories.

---

# 31. DEVICE CATEGORY DEFAULT ICONS

Device Categories may optionally specify:

- Suggested Icon
- Suggested Color

Example:

Category:
Gaming

Suggested Icon:
Game Controller

The user remains free to choose another icon.

---

# 32. DEVICE BATTERY REQUIREMENTS

Allow optional Device requirements:

- Battery Type
- Number of Batteries Required
- Voltage
- Notes

Example:

Device:
Xbox Controller 1

Battery Type:
AA

Quantity:
2

Use requirements as guidance.

Do not block overrides.

---

# 33. DEVICE DETAIL SCREEN

Display:

- Icon or photo
- Device Name
- Category
- Manufacturer
- Model
- Serial Number
- Permanent UUID
- Current Batteries
- Current Battery Set
- Required Battery Quantity
- Notes
- Assignment History
- QR Code

Actions:

- Edit Device
- Change Icon
- Change Icon Color
- Assign Batteries
- Assign Battery Set
- Remove Battery
- Remove Battery Set
- Add Photo
- Generate QR Label
- Print QR Label
- Mark Inactive
- Delete Device

---

# 34. BATTERY ASSIGNMENTS

A battery or Battery Set may be assigned to a Device.

A Device may contain one or multiple batteries.

Assignment workflow:

1. Select Device
2. Select individual Battery/Batteries OR Battery Set
3. Select Assignment Date
4. Add optional Notes
5. Confirm

Normally show only available batteries.

Provide an option to show all.

Warn if Battery Type or quantity does not match Device requirements.

Allow override.

---

# 35. ASSIGNMENT HISTORY

Never overwrite assignment history.

Store:

- Battery
- Battery Set if applicable
- Device
- Assigned Date
- Removed Date
- Duration
- Notes

Historical records must remain meaningful.

---

# 36. CHARGE TRACKING

Provide:

**Mark Charged**

Record:

- Battery UUID
- Charge Date
- Optional Starting Charge Percentage
- Optional Ending Charge Percentage
- Optional Charger
- Notes

Maintain:

- Charge History
- Recorded Charge Count
- Last Charged Date

Call the count:

**Recorded Charges**

Do not claim it represents a true electronic battery-cycle count.

Allow an optional manually entered estimated current charge:

0–100%

When Mark Charged is selected, default ending estimate to 100%.

Clearly treat it as user-entered data.

---

# 37. BULK BATTERY CREATION — REQUIRED VERSION 1 FEATURE

Provide:

**Add Multiple Batteries**

Bulk creation is a faster data-entry method.

Every battery must still receive:

- its own individual database record
- its own permanent UUID
- its own editable Battery ID
- its own icon information
- its own history

## Bulk Creation Workflow

Example:

Battery Type:
AA NiMH

Quantity:
20

ID Prefix:
AA

Starting Number:
1

Number Padding:
3

Separator:
-

Preview:

AA-001
AA-002
AA-003
...
AA-020

Do not save until the user confirms the preview.

---

# 38. BULK CREATE SHARED FIELDS

Allow shared values for:

- Battery Type
- Manufacturer
- Model
- Chemistry
- Voltage
- Capacity
- Capacity Unit
- Rechargeable Status
- Purchase Date
- Purchase Location
- Purchase Price
- Warranty Expiration
- Condition
- Status
- Notes
- Built-In or Custom Icon
- Icon Color
- Optional Battery Set
- Optional Batch ID
- Optional Tags

Only apply values entered by the user.

---

# 39. FLEXIBLE ID GENERATION

Support:

- Prefix
- Separator
- Starting Number
- Quantity
- Number Padding

Examples:

AA-001
AA-002

18650-021
18650-022

BAT001
BAT002

Allow no separator.

---

# 40. DUPLICATE ID CHECKING

Check every generated ID before saving.

If duplicates exist, show them.

Provide options:

- Cancel
- Change Starting Number
- Change Prefix
- Skip Existing IDs
- Generate Next Available IDs

Do not silently alter IDs.

Permanent UUIDs must always remain unique.

---

# 41. USE NEXT AVAILABLE IDS

Provide:

**Use Next Available IDs**

Example:

Existing:
AA-001 through AA-004

Requested:
4 new batteries

Suggest:
AA-005 through AA-008

User may accept or change.

---

# 42. BULK PREVIEW AND INDIVIDUAL EDITING

The preview screen must allow individual row edits before saving.

Allow changing per row:

- Battery ID
- Battery Name
- Icon
- Icon Color
- Battery Set
- Notes

Shared defaults should remain intact unless changed.

---

# 43. BATTERY BATCHES

Support an optional internal:

**Batch ID**

A Batch means batteries purchased or entered together.

Example:

BATCH-20260814-001

A Batch is different from a Battery Set.

**Batch**
Batteries purchased or entered together.

**Battery Set**
Batteries intentionally kept or used together.

Example:

BATCH-001 contains eight AA batteries.

SET-001:
AA-001 through AA-004

SET-002:
AA-005 through AA-008

Batch membership is not exclusive.

Allow search/filter by Batch ID.

---

# 44. BULK SET CREATION

During bulk entry, optionally allow:

**Create Battery Set**

Example:

SET-001:
AA-001 through AA-004

SET-002:
AA-005 through AA-008

Every Battery and every Set receives its own UUID.

---

# 45. BULK PURCHASE INFORMATION

Allow user to specify whether Purchase Price means:

- Price Per Battery
- Total Purchase Price

If Total Purchase Price is selected, optionally calculate approximate cost per battery.

Preserve the original total where practical.

---

# 46. BULK DATABASE TRANSACTION

Bulk creation must use a database transaction.

If a fatal error occurs:

- do not leave an unexplained partial batch
- roll back when possible
- report failure clearly

Include set membership changes in the same transaction where appropriate.

---

# 47. BULK EDITING

Provide a separate **Bulk Edit** feature.

Allow selected batteries to be changed together.

Supported actions:

- Change Battery Type
- Change Status
- Change Condition
- Change Icon
- Change Icon Color
- Add to Battery Set
- Remove from Battery Set
- Add Tag
- Add Shared Note
- Change Purchase Information
- Retire Selected Batteries
- Mark Selected Charged

Before applying, show:

- number of records affected
- fields being changed
- old/new values where practical

Require confirmation.

---

# 48. BULK CHARGE ACTION

Provide:

**Mark Selected Charged**

Create an individual charge record for every selected battery.

Use a database transaction.

This is separate from:

**Mark Entire Set Charged**

---

# 49. BULK RETIREMENT

Provide:

**Retire Selected Batteries**

Allow retirement reasons:

- Capacity loss
- Damaged
- Age
- Replaced
- Lost
- Other

Store retirement date and reason per battery.

---

# 50. BULK DELETE SAFETY

Do not prominently encourage bulk deletion.

If provided:

- require explicit selection
- show record count
- warn about active assignments
- warn about set membership
- preserve history appropriately
- require strong confirmation

Prefer retirement/deactivation where practical.

---

# 51. QR CODE LABEL SYSTEM — REQUIRED VERSION 1 FEATURE

Implement QR labels for:

- Batteries
- Battery Sets
- Devices

Each QR code must use the record's permanent UUID.

Do NOT rely on editable IDs such as AA-001.

Suggested internal URI format:

`batterytracker://battery/{UUID}`

`batterytracker://set/{UUID}`

`batterytracker://device/{UUID}`

Structure the QR service so future Android/iOS apps can scan the same codes.

---

# 52. QR LABEL DESIGNER

Create a visual label designer.

Allow:

- Label Width
- Label Height
- QR Code Size
- Text Size
- Fields Displayed
- Orientation
- Margins
- Alignment

Available elements:

- QR Code
- Built-In Icon
- Custom Icon
- Icon Color
- Photograph
- Battery ID
- Battery Name
- Battery Type
- Set ID
- Set Name
- Device Name
- Manufacturer
- Model
- Custom Text

Provide a live preview before printing.

---

# 53. LABEL SIZE PRESETS

Include presets:

- Small Battery Label
- Medium Battery Label
- Device Label
- Address Label Sheet
- Custom Size

Allow custom dimensions in inches.

Store internally in a printer-friendly unit.

---

# 54. SMALL LABEL EXAMPLES

Small Battery Label:

[QR CODE] [Icon]

AA-001

Standard Battery Label:

[QR CODE]

AA-001

Panasonic Eneloop

2000 mAh

Battery Set Label:

[QR CODE]

SET-001

Xbox AA Set 1

4 × AA

Device Label:

[QR CODE]

Xbox Controller 1

Gaming

---

# 55. LABEL PRINTING

Allow:

- Print one label
- Print multiple selected labels
- Print entire Battery Set
- Print selected inventory records
- Print a sheet of labels
- Export labels to PDF
- Print preview

Do not assume a specific printer brand.

Use standard Windows printing where practical.

---

# 56. LABEL SHEETS

Support:

- Paper Size
- Rows
- Columns
- Label Width
- Label Height
- Horizontal Spacing
- Vertical Spacing
- Page Margins
- Starting Label Position

Starting Label Position is important so partially used sheets can be reused.

---

# 57. LABEL TEMPLATES

Allow reusable templates.

Store:

- Template Name
- Dimensions
- Content Fields
- Font Sizes
- QR Size
- Alignment
- Margins
- Layout Configuration

Examples:

- Small AA Battery
- 18650 Battery
- Device Label
- Battery Set Label
- Avery Address Label

Do not hard-code the app to one label manufacturer.

---

# 58. QR LOOKUP

Allow users to:

- Enter QR value manually
- Paste QR value
- Scan with webcam if practical

When recognized, open the correct:

- Battery
- Battery Set
- Device

---

# 59. BULK QR LABEL GENERATION

After bulk battery creation, provide:

**Create QR Labels**

Allow:

- Print all new labels
- Print selected labels
- Export labels to PDF
- Save for later

Every label must encode the permanent UUID.

---

# 60. HISTORY

Create a unified History section.

Include:

- Assignment History
- Battery Set Membership History
- Charge History
- Status Changes
- Battery Additions
- Device Additions
- Set Additions
- QR Label Generation
- QR Label Printing
- Battery Retirement
- Bulk Operations

Filters:

- Date
- Battery
- Battery Set
- Device
- Activity Type

---

# 61. ACTIVITY LOG

Include event types such as:

BATTERY_CREATED
BATTERY_UPDATED
BATTERY_ASSIGNED
BATTERY_UNASSIGNED
BATTERY_CHARGED
BATTERY_STATUS_CHANGED
BATTERY_RETIRED

SET_CREATED
SET_UPDATED
BATTERY_ADDED_TO_SET
BATTERY_REMOVED_FROM_SET
SET_ASSIGNED
SET_UNASSIGNED
SET_CHARGED

DEVICE_CREATED
DEVICE_UPDATED
DEVICE_DEACTIVATED

PHOTO_ADDED

QR_LABEL_GENERATED
QR_LABEL_PRINTED

BULK_BATTERIES_CREATED
BATTERY_BATCH_CREATED
BULK_SET_ASSIGNMENT
BULK_EDIT_APPLIED
BULK_CHARGE_APPLIED
BULK_RETIREMENT_APPLIED

---

# 62. DATABASE DESIGN

Use a normalized relational SQLite database.

At minimum consider:

- batteries
- battery_types
- battery_sets
- battery_set_memberships
- battery_batches
- devices
- assignments
- charge_records
- set_charge_records
- battery_photos
- battery_set_photos
- device_photos
- custom_icons
- icon_categories
- qr_label_templates
- activity_log
- settings

Use:

- UUIDs
- foreign keys
- indexes
- created timestamps
- modified timestamps
- migration/versioning support

Do not put all application information into one table.

---

# 63. DATA INTEGRITY

Prevent accidental corruption.

Examples:

A Battery currently assigned to a Device should not simply be deleted.

A Battery in a Set should trigger a warning before deletion.

Deleting a Set must not automatically delete its member batteries.

Historical records must remain meaningful.

Use soft deletion where appropriate.

Use transactions where multiple related changes must succeed together.

---

# 64. SEARCH

Create fast global search.

Search:

- Battery ID
- Battery Name
- Battery Type
- Battery Set ID
- Battery Set Name
- Manufacturer
- Model
- Serial Number
- Device Name
- Device Manufacturer
- Device Model
- Batch ID
- Notes

---

# 65. SETTINGS

Include:

## Appearance
- Light
- Dark
- System Default

## Data
- Database Location
- Image Storage Location
- Custom Icon Storage Location
- Backup
- Restore

## Automatic IDs
- Battery Prefixes
- Set Prefix
- Batch Prefix
- Number Padding
- Separators

## QR Labels
- Default Battery Template
- Default Set Template
- Default Device Template
- Default Printer
- Default Label Size
- QR Error Correction Preference

## Icon Library
- Built-In Icons
- Custom Icons
- Icon Categories

---

# 66. BACKUP AND RESTORE

Provide:

**Create Backup**

Backup must include:

- SQLite database
- Battery photographs
- Battery Set photographs
- Device photographs
- Custom icon files
- Custom icon metadata
- QR label templates
- Application settings
- icon selections
- icon colors

Built-in icons do not need to be copied because they ship with the app.

Package backup into a single archive if practical.

Example:

BatteryTracker_Backup_2026-08-14.zip

Provide:

**Restore Backup**

Require confirmation before replacing current data.

Validate backup before restore.

After restore:

- built-in icons resolve
- custom icons resolve
- icon colors remain
- photographs display when available
- missing photographs fall back to icons

---

# 67. CSV EXPORT

Allow Battery inventory export to CSV.

Include fields such as:

- Battery ID
- Name
- Type
- Manufacturer
- Model
- Chemistry
- Voltage
- Capacity
- Status
- Condition
- Battery Set
- Assigned Device
- Batch ID
- Purchase Date
- Recorded Charges
- Last Charged

Allow Battery Set export as well.

Design export architecture so Excel and PDF reports can be added later.

---

# 68. CSV IMPORT

Create basic CSV import for batteries.

Provide:

- CSV Template
- Field Mapping
- Preview
- Duplicate Detection
- Validation
- Import Summary

Do not import until user confirms preview.

---

# 69. FIRST RUN

On first launch display:

**Welcome to Battery Tracker**

Description:

"Battery Tracker helps you organize rechargeable batteries, keep battery sets together, track where batteries are being used, record charges, and create QR labels for your equipment."

Provide:

**Get Started**

Optionally allow creation of:

1. First Battery Type
2. First Battery
3. First Battery Set
4. First Device

Do not force a lengthy setup wizard.

---

# 70. SAMPLE DEVELOPMENT DATA

Provide an optional demo dataset.

Battery Types:

- AA NiMH
- AAA NiMH
- 18650 Li-ion
- Xbox Rechargeable Battery Pack

Batteries:

- AA-001
- AA-002
- AA-003
- AA-004
- 18650-001
- 18650-002

Battery Sets:

- SET-001
- SET-002

Devices:

- Xbox Controller 1
- Xbox Controller 2
- Flashlight
- Meta Quest Left Controller
- Meta Quest Right Controller

Production databases start empty.

---

# 71. ERROR HANDLING

Handle errors gracefully.

Do not show raw stack traces to normal users.

Log technical details separately.

Use understandable messages such as:

- "Battery could not be saved."
- "Unable to open the selected image."
- "Backup could not be created."
- "The selected custom icon could not be imported."
- "Some generated Battery IDs already exist."

---

# 72. ARCHITECTURE REQUIREMENTS

Do not create the application as one large file.

Separate:

- UI
- models
- database
- repositories
- services
- state management
- utilities
- image management
- icon management
- battery-set management
- QR generation
- label rendering
- printing
- backup
- import/export
- logging

Create isolated services such as:

- CameraService
- ImageService
- IconService
- DatabaseService
- BatterySetService
- AssignmentService
- ChargeService
- BackupService
- ExportService
- ImportService
- QrCodeService
- LabelService
- PrintService

Keep platform-specific code isolated.

---

# 73. WINDOWS REQUIREMENTS

The initial application must:

- Run on Windows 11
- Build as a Windows desktop application
- Store data locally
- Work without internet access
- Support normal Windows file dialogs
- Support keyboard and mouse
- Handle standard Windows display scaling
- Support maximized and resizable windows
- Preserve database data between upgrades

If practical, create a Windows installer or document how to package one.

---

# 74. CROSS-PLATFORM REQUIREMENTS

Core application logic must remain portable to:

- Android
- iPhone/iPad
- macOS

Do not use Windows-only icon paths or system icons for core data.

The same `icon_key` and UUID values must resolve consistently across supported platforms.

Keep future mobile camera/scanner implementations behind services/interfaces.

---

# 75. FUTURE FEATURES

Do NOT implement these unless required for architecture:

- Android app
- iPhone app
- macOS app
- cloud synchronization
- multiple users
- NFC tags
- barcode scanning
- battery capacity testing
- charger integration
- Bluetooth monitoring
- smart-battery communication
- push notifications
- shared inventories
- equipment kits
- advanced reports
- Excel export
- advanced PDF reports
- icon pack sharing

The following are NOT future features. They are required in Version 1:

- Icon-first, photo-optional design
- Built-in generic icon library
- Icon colors
- User-imported PNG/SVG custom icons
- Battery Sets
- QR labels
- QR label designer
- Bulk Battery Creation
- Automatic sequential Battery IDs
- Bulk Edit
- Optional Batch tracking
- Bulk QR label creation
- Bulk charge actions

---

# 76. DEVELOPMENT PROCESS

Do not attempt to generate the entire program blindly in one pass.

Work systematically.

## Phase 1 — Architecture

Before implementation:

1. Review all requirements
2. Propose architecture
3. Define folder structure
4. Define database schema
5. Define models
6. Define navigation
7. Identify Flutter packages
8. Identify Windows-specific concerns
9. Identify future cross-platform concerns

Then proceed with implementation.

Do not stop after planning.

## Phase 2 — Project Foundation

Create:

- Flutter project
- dependencies
- project structure
- SQLite database
- migration system
- theme
- navigation
- shared components
- logging
- configuration

Verify the project builds.

## Phase 3 — Icon System

Implement:

1. Built-In Icon Registry
2. Default Icons
3. Icon Selector
4. Icon Colors
5. Custom Icon Import
6. Custom Icon Management
7. Battery/Set/Device Integration

Test before proceeding.

## Phase 4 — Battery Types

Implement full Battery Type management.

## Phase 5 — Battery Inventory

Implement:

- list
- card view
- table view
- add
- edit
- details
- search
- filters
- sorting
- status
- condition

## Phase 6 — Optional Photographs

Implement:

- battery photos
- set photos
- device photos
- primary photo
- additional photos
- image selection
- image storage
- webcam capture if practical
- fallback to icon

## Phase 7 — Battery Sets

Implement:

- Set creation
- Set IDs
- Add/remove Batteries
- Compatibility checks
- Membership history
- Set details
- Set icons/photos
- Mark Entire Set Charged
- Set assignment
- Set activity history

## Phase 8 — Devices

Implement full Device management.

## Phase 9 — Assignments

Implement:

- individual assignments
- multi-battery assignments
- Set assignments
- removal
- historical records
- validation

## Phase 10 — Charge Tracking

Implement:

- Mark Charged
- Recorded Charges
- Last Charged
- Set charging
- bulk charging
- estimated percentage

## Phase 11 — Bulk Battery Creation

Implement:

- shared fields
- sequential ID generation
- next available IDs
- duplicate detection
- preview
- row editing
- Batch IDs
- optional Set creation
- transaction-safe save
- completion summary

## Phase 12 — Bulk Edit

Implement:

- icon changes
- color changes
- status
- condition
- Set changes
- purchase information
- retirement
- charge action

## Phase 13 — QR Labels

Implement:

- QR generation
- UUID encoding
- Battery labels
- Set labels
- Device labels
- templates
- designer
- live preview
- icons
- custom icons
- photographs
- batch printing
- sheet printing
- starting label position
- PDF export
- QR lookup

## Phase 14 — Dashboard

Use real database values.

Do not hard-code statistics.

## Phase 15 — History

Implement complete activity/history screens.

## Phase 16 — Backup, Restore, Import, Export

Implement and test all data-management features.

## Phase 17 — Testing and Cleanup

Perform:

- unit tests
- database tests
- repository tests
- assignment logic tests
- set logic tests
- icon tests
- custom icon tests
- QR tests
- bulk creation tests
- backup/restore tests
- UI tests

Fix discovered issues instead of only documenting them.

---

# 77. DEVELOPMENT RULES

Follow these rules:

1. Do not use placeholder functions for required features.
2. Do not leave major Version 1 TODOs.
3. Do not fake database operations.
4. Do not hard-code demo inventory into production code.
5. Validate all user input.
6. Use parameterized queries.
7. Use transactions for multi-record operations.
8. Protect historical data.
9. Confirm destructive actions.
10. Keep UI responsive.
11. Comment complicated logic.
12. Avoid unnecessary comments.
13. Use descriptive names.
14. Follow Dart and Flutter best practices.
15. Run formatting and static analysis.
16. Resolve warnings where practical.
17. Test each major feature after implementation.
18. Do not remove working functionality to fix unrelated issues.
19. Keep platform-specific code isolated.
20. Maintain README throughout development.

---

# 78. README REQUIREMENTS

Create a detailed README covering:

- Application Description
- Screenshots Section
- Features
- Technology Stack
- Project Structure
- Database Overview
- Development Prerequisites
- Flutter Installation
- Windows Development Requirements
- How to Run
- How to Build
- How to Create Windows Release
- Database Location
- Photograph Location
- Custom Icon Location
- Backup Location
- Testing Instructions
- Known Limitations
- Future Roadmap

---

# 79. VERSION INFORMATION

Start as:

**Battery Tracker**
Version **0.1.0**

Use semantic versioning.

---

# 80. REQUIRED TEST SCENARIOS — BATTERY SETS

Test:

1. Create SET-001
2. Add AA-001 through AA-004
3. Remove AA-004
4. Add AA-004 back
5. Attempt incompatible battery
6. Mark SET-001 charged
7. Confirm four individual charge records
8. Assign SET-001 to Device
9. Confirm all four batteries show assignment
10. Remove Set from Device
11. Confirm history remains
12. Move Battery to another Set
13. Confirm warnings
14. Delete/deactivate Set without deleting batteries

---

# 81. REQUIRED TEST SCENARIOS — ICONS

Test:

1. Create Battery with built-in icon only
2. Create Set with built-in icon only
3. Create Device with built-in icon only
4. Change icon color
5. Restart and confirm color persists
6. Use same icon with different colors
7. Reset icon color
8. Import custom PNG
9. Import custom SVG
10. Assign custom icon to Battery
11. Assign custom icon to Device
12. Assign custom icon to Set
13. Restart and confirm custom icons remain
14. Attempt to delete in-use custom icon
15. Replace in-use custom icon
16. Delete unused custom icon
17. Add photograph later
18. Keep Icon as Primary
19. Switch to Photo as Primary
20. Switch back to Icon
21. Remove photograph
22. Delete photograph externally and verify fallback
23. Use colored icon on QR label
24. Use custom icon on QR label
25. Export label to PDF
26. Backup and restore custom icons
27. Confirm icon colors survive restore
28. Test Light Mode
29. Test Dark Mode

---

# 82. REQUIRED TEST SCENARIOS — BULK CREATION

Test:

1. Create 4 batteries AA-001 through AA-004
2. Create 20 batteries AA-001 through AA-020
3. Start at AA-021
4. Use custom prefix
5. Use no separator
6. Change number padding
7. Detect duplicate Battery ID
8. Skip duplicates
9. Generate next available IDs
10. Edit one Battery ID before save
11. Apply built-in icon to entire batch
12. Apply custom icon to entire batch
13. Apply one icon color to entire batch
14. Change individual colors before save
15. Save shared purchase information
16. Assign Batch ID
17. Create Set during bulk entry
18. Divide eight batteries into two Sets
19. Create batteries without Sets
20. Confirm every battery has unique UUID
21. Confirm data survives restart
22. Generate QR labels immediately
23. Export QR labels to PDF
24. Bulk edit icon color
25. Bulk add batteries to Set
26. Bulk remove batteries from Set
27. Mark selected batteries charged
28. Bulk retire selected batteries
29. Simulate database failure and verify rollback
30. Backup and restore bulk-created batch

---

# 83. REQUIRED TEST SCENARIOS — QR LABELS

Test:

1. Generate QR label for AA-001
2. Confirm QR contains permanent UUID
3. Generate label for SET-001
4. Generate Device label
5. Print one Battery label
6. Print multiple labels
7. Print entire Set
8. Print sheet starting at selected position
9. Export labels to PDF
10. Save/reuse label template
11. Change editable Battery ID and confirm QR still resolves through permanent UUID

---

# 84. FINAL USER WORKFLOW GOAL

The completed Version 1 application should allow this workflow:

1. Launch Battery Tracker
2. Create an AA NiMH Battery Type
3. Add 20 batteries in one bulk operation
4. Generate AA-001 through AA-020 automatically
5. Assign a built-in AA icon
6. Choose an icon color
7. Optionally import and use a custom icon
8. Save shared purchase information
9. Create BATCH-001
10. Divide batteries into Battery Sets
11. Create SET-001 and SET-002
12. Create Xbox Controller 1
13. Assign a game-controller icon and color
14. Optionally add a controller photograph
15. Configure controller battery requirements
16. Assign individual Batteries or a Set
17. Preserve assignment history
18. Mark Batteries charged
19. Mark an entire Set charged
20. Use Bulk Mark Charged
21. Generate QR labels for Batteries
22. Generate QR label for Set
23. Generate QR label for Device
24. Design a small label
25. Preview the label
26. Print labels
27. Print an entire sheet
28. Export labels to PDF
29. Enter or scan QR value and open correct record
30. Search for AA-001
31. View Set and Device history
32. Export inventory to CSV
33. Create a full backup
34. Close and reopen application
35. Confirm no information is lost

The application should feel like a real, polished inventory-management program rather than a programming demonstration.

---

# 85. STARTING INSTRUCTIONS FOR CODEX

Start by inspecting the development environment and existing project directory.

If no project exists, initialize the Flutter project.

Then:

1. Create the architecture plan.
2. Define the database.
3. Create the project structure.
4. Identify required packages.
5. Implement the application in the phases above.
6. Run the application.
7. Run tests.
8. Fix errors as they appear.
9. Keep the README current.
10. Continue until the required Version 1 functionality is implemented.

Do not stop after generating code snippets.

Create the actual project files.

Do not stop after planning.

Do not claim a feature is complete until it builds and its core workflow has been tested.
