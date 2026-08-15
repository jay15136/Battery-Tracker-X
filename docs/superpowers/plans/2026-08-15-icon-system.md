# Phase 3 Icon System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the complete offline icon-first registry, selector, color, custom import, management, persistence, and fallback foundation required by Phase 3.

**Architecture:** A pure-Dart asset catalog and icon value objects sit above Drift metadata and a managed-file adapter. `IconLibraryService` coordinates database and file changes, while reusable Flutter widgets render and select resolved definitions without embedding platform paths or plugin types in domain code.

**Tech Stack:** Flutter 3.47, Dart 3.13, Riverpod, Drift/SQLite, `flutter_svg` 2.3.0, `file_selector` 1.1.0, application-managed files.

**Spec:** `docs/superpowers/specs/2026-08-15-icon-system-design.md`

## Global Constraints

- Icons identify inventory; photographs add detail.
- Built-in icons are packaged offline assets and cannot be deleted.
- Custom icons use permanent UUIDs and managed relative paths.
- Color values use uppercase `#RRGGBB`, never host-specific identifiers.
- Missing or deprecated references always resolve to the correct scope default.
- In-use deletion requires transactional replacement; no record may retain a broken custom-icon reference.
- All plugin and filesystem behavior remains behind cross-platform interfaces.
- No required internet, cloud service, account, or Windows-only domain dependency.

---

### Task 1: Domain values and built-in registry

**Files:**
- Create: `lib/features/icons/domain/icon_color.dart`
- Create: `lib/features/icons/domain/icon_definition.dart`
- Create: `lib/features/icons/domain/icon_selection.dart`
- Create: `lib/features/icons/domain/icon_registry.dart`
- Create: `lib/features/icons/data/built_in_icon_registry.dart`
- Test: `test/features/icons/icon_color_test.dart`
- Test: `test/features/icons/built_in_icon_registry_test.dart`

**Interfaces:**
- Produces: `IconColor.parse`, `IconScope`, `IconSource`, `IconDefinition`,
  `IconSelection`, `ResolvedIcon`, and `BuiltInIconRegistry`.

- [ ] Write tests proving uppercase color normalization, invalid-value rejection,
  required defaults, full required catalog names, search/category behavior, and
  deprecated/missing fallback.
- [ ] Run the focused tests and confirm they fail because the icon domain does
  not exist.
- [ ] Implement only the value objects and catalog behavior required by those
  tests.
- [ ] Run the focused tests and keep them green while refactoring catalog data
  into focused files.

### Task 2: Packaged SVG assets and rendering

**Files:**
- Create: `assets/icons/builtin/*.svg`
- Create: `lib/features/icons/presentation/icon_visual.dart`
- Modify: `pubspec.yaml`
- Test: `test/features/icons/icon_visual_test.dart`

**Interfaces:**
- Consumes: `ResolvedIcon` and scope defaults from Task 1.
- Produces: `IconVisual(definition:, color:, applicationSupportRoot:)` with a
  guaranteed asset fallback.

- [ ] Write widget tests that render each default in Light and Dark themes and
  replace a failed managed-file render with the correct default asset.
- [ ] Run the widget tests and verify missing widget/assets fail them.
- [ ] Add the required SVG assets, `flutter_svg`, the asset manifest, and the
  renderer with semantic labels and error fallback.
- [ ] Run the focused tests and an asset-loading smoke test.

### Task 3: Repository and record integration

**Files:**
- Create: `lib/features/icons/domain/icon_repository.dart`
- Create: `lib/features/icons/data/drift_icon_repository.dart`
- Test: `test/features/icons/drift_icon_repository_test.dart`

**Interfaces:**
- Produces: category CRUD, custom metadata CRUD, `usageCount`,
  `saveOwnerSelection`, `recentSelections`, and transactional
  `deactivateAndReplaceReferences`.

- [ ] Write real SQLite tests for category uniqueness, custom-icon restart
  persistence, selections for Battery/Set/Device, bounded recent usage, usage
  counts, refusal without a replacement, replacement with another icon,
  replacement with scope defaults, and activity rows.
- [ ] Run the focused tests and verify they fail for the missing repository.
- [ ] Implement parameterized Drift queries and transactions using existing
  schema version 1 tables.
- [ ] Re-run focused and database tests; refactor only while green.

### Task 4: Managed PNG/SVG storage and lifecycle orchestration

**Files:**
- Create: `lib/features/icons/domain/custom_icon_storage.dart`
- Create: `lib/features/icons/application/icon_library_service.dart`
- Create: `lib/features/icons/data/local_custom_icon_storage.dart`
- Create: `lib/services/file_selector_file_selection_service.dart`
- Modify: `lib/app/app_bootstrap.dart`
- Modify: `lib/app/app_providers.dart`
- Modify: `lib/app/battery_tracker_root.dart`
- Test: `test/features/icons/local_custom_icon_storage_test.dart`
- Test: `test/features/icons/icon_library_service_test.dart`

**Interfaces:**
- Produces: `inspect`, `import`, `replaceSource`, `duplicate`, and `delete`
  workflows plus a production `FileSelectionService` adapter.

- [ ] Write filesystem tests for valid PNG/SVG, bad signatures, unsafe SVG,
  oversize input, managed copying, original-path independence, replacement,
  and deletion.
- [ ] Write service tests proving database-failure cleanup, stable UUID during
  source replacement, duplication with a new UUID, in-use refusal, and
  post-transaction file cleanup.
- [ ] Run focused tests and observe expected missing-feature failures.
- [ ] Implement validation, storage, orchestration, logging, and production
  dependency injection.
- [ ] Run focused tests and all existing bootstrap tests.

### Task 5: Reusable selector and color controls

**Files:**
- Create: `lib/features/icons/application/icon_catalog_controller.dart`
- Create: `lib/features/icons/presentation/icon_color_picker.dart`
- Create: `lib/features/icons/presentation/icon_picker_dialog.dart`
- Test: `test/features/icons/icon_catalog_controller_test.dart`
- Test: `test/features/icons/icon_picker_dialog_test.dart`

**Interfaces:**
- Produces: Riverpod catalog filtering and a dialog returning an
  `IconSelection` only after confirmation.

- [ ] Write controller tests for scope/source/category/search/recent filters and
  refresh after import.
- [ ] Write widget tests for preview, palette, custom hex validation, reset
  color, reset default, cancel, and confirmed selection.
- [ ] Run focused tests and confirm missing controller/widgets cause failure.
- [ ] Implement responsive selector and color components with keyboard focus,
  semantics, concise validation, and no raw exceptions.
- [ ] Run focused tests in Light and Dark themes.

### Task 6: Settings Icon Library management

**Files:**
- Create: `lib/features/icons/presentation/icon_library_page.dart`
- Create: `lib/features/icons/presentation/custom_icon_editor_dialog.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Test: `test/features/icons/icon_library_page_test.dart`
- Modify: `test/app_smoke_test.dart`

**Interfaces:**
- Consumes: the registry, library service, file selector, and reusable selector.
- Produces: Settings navigation and UI for add, preview, rename, category
  change, source replacement, duplicate, and safe deletion.

- [ ] Write widget tests for opening Icon Library, searching built-ins,
  importing through the application boundary, editing metadata, duplicating,
  replacing source, unused deletion, and the in-use replacement prompt.
- [ ] Run widget tests and verify the missing library UI fails them.
- [ ] Implement the responsive industrial catalog UI and concise error dialogs.
- [ ] Re-run focused tests and the application smoke suite.

### Task 7: Documentation and acceptance verification

**Files:**
- Modify: `README.md`
- Modify: `MANIFEST.md`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `docs/DATABASE_PLAN.md`
- Modify: `docs/IMPLEMENTATION_PLAN.md`
- Modify: `lib/features/icons/README.md`

**Interfaces:**
- Produces: current setup, storage, architecture, status, and test guidance.

- [ ] Run `dart format --output=none --set-exit-if-changed .` and fix changes.
- [ ] Run `flutter pub get` and `dart run build_runner build`; confirm generated
  artifacts are current.
- [ ] Run `flutter analyze` and fix every project issue.
- [ ] Run `flutter test` and fix every failure.
- [ ] Run `flutter build windows`, launch the Release executable twice, and
  confirm it stays healthy.
- [ ] Audit the Phase 3 checklist, schema/assets, `git diff --check`, and status;
  then mark Phase 3 complete only when every acceptance requirement has direct
  evidence.
