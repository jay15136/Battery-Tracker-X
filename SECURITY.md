# Security Policy

## Scope

Battery Tracker is an offline-first Windows desktop application. It does not
run a server, does not have a user account system, and does not transmit
data over a network — all data is stored locally on the machine running it
(see `README.md` for exactly where). Realistic security concerns here are
things like:

- A malicious or malformed backup archive (`.zip`), custom icon file (SVG in
  particular), or CSV file causing unintended behavior on import/restore
- Path traversal or unsafe file handling in application-managed storage
- A dependency with a known vulnerability

If you're unsure whether something you found qualifies, report it anyway —
it's easier to close a false positive than to miss something real.

## Supported Versions

This project is pre-1.0 (`0.1.x`) with a single actively developed line.
Security fixes are applied to the latest commit on `main`; there are no
older maintained release branches.

| Version | Supported |
| ------- | --------- |
| latest on `main` | :white_check_mark: |
| anything else | :x: |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Preferred: use
[GitHub's private vulnerability reporting](https://github.com/jay15136/Battery-Tracker-X/security/advisories/new)
for this repository (Security tab → Report a vulnerability). This keeps the
report private between you and the maintainer until a fix is available.

If that's not available, contact [**@jay15136**](https://github.com/jay15136)
directly on GitHub with:

- A description of the issue and its potential impact
- Steps to reproduce, or a proof-of-concept file (e.g., the crafted backup
  archive, icon file, or CSV that triggers it)
- Your assessment of severity, if you have one

You should expect an initial response within a few days. This is a
single-maintainer project run outside of working hours, so please be patient
— but every report will get a response.

## Disclosure

Please give a reasonable amount of time to investigate and fix an issue
before any public disclosure. Credit will be given in the fix's commit
message / release notes unless you'd prefer to remain anonymous.
