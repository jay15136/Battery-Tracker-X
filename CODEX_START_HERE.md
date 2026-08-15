# Battery Tracker — Start Here for Codex

## First command

Open a terminal in this repository root.

If this repository does not yet contain Flutter-generated platform files, run:

```powershell
flutter create . --project-name battery_tracker --platforms=windows,android,ios,macos
```

Then review the generated files before overwriting anything. Preserve the repository instruction and documentation files already present.

## First Codex instruction

Paste this into Codex from the repository root:

```text
Read AGENTS.md, CODEX_INSTRUCTIONS.md, Battery_Tracker_Master_Codex_Prompt.md,
docs/IMPLEMENTATION_PLAN.md, and docs/ARCHITECTURE.md before changing files.

Inspect the repository and the local Flutter/Windows development environment.
Reconcile the Flutter-generated project files with the existing starter source
without deleting the project-control documents.

Begin with the first incomplete phase in docs/IMPLEMENTATION_PLAN.md. Do not stop
at planning or scaffolding. Implement the phase, run formatting, static analysis,
tests, and a Windows build where applicable. Fix failures before moving on.

Preserve all Version 1 requirements, especially permanent UUID identity,
historical records, transaction safety, icon-first/photo-optional behavior,
Battery Sets, bulk creation, QR labels, backup/restore, and cross-platform
service boundaries.
```

## Expected first actions

Codex should:

1. Read all repository instructions.
2. Inspect installed Flutter and Windows build tooling.
3. Run `flutter doctor -v`.
4. Run `flutter pub get`.
5. Review `pubspec.yaml`.
6. Confirm the starter shell compiles.
7. Update `docs/IMPLEMENTATION_PLAN.md` with environment findings.
8. Begin the first incomplete implementation phase.
9. Keep the repository runnable after each coherent change.

## Do not do this

Do not ask Codex to "build the entire app in one response."

The repository already contains a phased execution plan. Use it.

Do not let Codex:

- replace the master specification with a shorter interpretation
- move required Version 1 features into the roadmap
- use editable Battery IDs as permanent identifiers
- store user photos or imported custom icons outside application-managed storage
- silently discard assignment or membership history
- stop after creating mock screens
