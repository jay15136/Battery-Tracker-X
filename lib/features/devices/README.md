# Devices

Devices are persistent, icon-first inventory records. A name is enough to create one. The editor supports custom category text, manufacturer, model, serial number, location, description, notes, optional Battery Type/quantity/voltage requirements, and requirement notes.

## Workflows

- Open Devices and choose Add Device. The generic Device icon is retained until an explicit icon choice. Category chips reuse existing custom category values; Gaming, Cameras, Communications, and Other offer an explicit suggested icon/color action. Choosing or typing a category never replaces the current visual automatically.
- Search across name, category, manufacturer, model, serial number, location, description, and notes. Filter by category and Active/Inactive/All.
- Select a Device to inspect its UUID, metadata, requirements, current Batteries/Sets, assignment history, and activity. Edit freely without replacing UUIDs, creation dates, photo preference, or assignment rows. Changing requirements does not silently remove installed inventory; the detail screen displays mismatches.
- Photographs uses the shared managed gallery: import, optional camera/drop controls, primary/additional photo selection, explicit icon/photo preference, and missing-file icon fallback.
- Assign Battery Set reuses the Phase 7 transaction and warning/override rules. Remove Set closes the Set parent and linked member assignments while preserving history. Device and Set catalog providers invalidate one another after mutations to avoid stale details.
- Mark Inactive hides a Device from assignment choices while retaining its record. Reactivation checks active-name conflicts. Delete performs a soft deletion and retains historical references/media. Both deactivation and deletion require all currently assigned inventory to be removed first, enforced again within the repository transaction.

Battery assignments opens a scoped manager for individual/multiple Battery installation, removal, and history. Create QR Labels opens the label designer with this Device selected; labels use its permanent UUID.

## Persistence and validation

The repository uses the existing schema v1 Devices, Assignments, DevicePhotos, and ActivityLog tables; there are no migrations or new production dependencies. Required Battery Type references preserve an existing inactive type during ordinary edits, while new selections require active types. Quantity must be a positive integer and voltage a finite positive number when supplied. An active Device name must be unique ignoring case; inactive duplicates can be renamed before reactivation.

Minimal Devices created through Set assignment now delegate to this same repository. Their permanent UUIDs and existing assignments are preserved. File references remain application-managed relative paths, and adding/editing metadata never promotes a photo automatically.

## Verification

Tests cover full-field persistence, file-backed restart, unchanged UUIDs, Phase 7 records, custom categories, active-name/reactivation conflicts, inactive type references, numeric validation, history-write rollback for CRUD/lifecycle operations, requirement overrides, retained assignments after removal/deletion, and photo preference persistence.

Widget tests cover icon-only create/edit, category icon suggestions, narrow dark-mode form validation, search, confirmation cancel/accept, whole-Set assignment warnings/removal, missing-photo fallback, gallery access, and application-shell navigation. Native camera/OS drag gestures retain the earlier Phase 6 manual-verification limitations.
