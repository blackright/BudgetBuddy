# Quickstart: Cross-Device Shared Spaces (Peer-to-Peer)

**Feature**: 012-cross-device-shared-spaces
**Purpose**: validate the peer-to-peer design end-to-end. Unit scenarios run offline in CI (fake transport, fake auth); the two-device walkthrough is the manual acceptance test.

---

## 0. Prerequisites

| Need | When |
|---|---|
| Nothing | to read this design, run unit tests, or build 012 |
| 2 Android devices on the **same Wi-Fi/LAN** | for the manual pairing/exchange walkthrough |
| Camera + fingerprints/PIN on both devices | for QR pairing + `local_auth` |
| New deps added to `pubspec.yaml` | before first 012 build: `local_auth`, `flutter_secure_storage`, `cryptography`, `mobile_scanner`, `qr_flutter`, `multicast_dns`/`nsd`, `share_plus` |

Build/verify commands (after implementation):
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Isar codegen for new collections
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

---

## 1. Unit / CI Scenarios (no network, no hardware)

Run: `flutter test`. These extend the current 391+1 suite.

1. **Identity** — create identity ⇒ ed25519 keypair generated, public key in Isar, private key only in secure storage *(fake)*; one profile linked (FR-001/016).
2. **Consent** — notice shown; grant/revoke flips `ConsentRecord.deviceAuthGranted`; revocation recorded (FR-002).
3. **Pairing token** — single-use (`usedAt`), expiry enforced, cancellation invalidates; duplicate claim refused (FR-005).
4. **Fingerprint** — mismatched/tampered QR rejected; `username (fingerprint)` shown (FR-004).
5. **Codec round-trip** — each entity `toPayload`→`fromPayload` is lossless (money fields byte-identical).
6. **HLC determinism** — injected clock; deviceId tiebreak; identical merge outcome regardless of arrival order (R4/FR-007).
7. **Tombstones** — delete beats concurrent upsert; later upsert recreates; no resurrection (FR-006/007).
8. **Apply-time authorization** — removed/demoted author's later changes dropped everywhere; Viewer directory edit dropped; sealed-month edit dropped by any role (FR-008/009/011, SC-005).
9. **Offline matrix** — every 011 operation performs with no peer present; edits queue as changes; status `waitingForPeer` (FR-003/013).
10. **Backup round-trip** — export then import via **passphrase** and via **recovery code** both restore identity + contexts; wrong secret fails; vault excluded; nothing transmitted (FR-012/015/017, SC-007/008).
11. **Migration** — fresh install at v15 and upgrade from v13 both succeed; existing amounts unchanged (SC-003).

Use the **fake transport** + in-memory peer for any test that needs "another device". Never open a real socket in CI.

---

## 2. Manual Acceptance Walkthrough (2 devices)

Run on two Android devices (A = Owner, B = joiner), same Wi-Fi.

1. **A**: create/choose a shared space; create an identity (username); enable device auth (or skip and see the warning).
2. **A**: "Pair a device" → grant role **Editor** → confirm fingerprint → show QR.
3. **B**: create identity → scan QR → confirm A's `username (fingerprint)` → accept. B receives the live space and its history (SC-006: under 2 minutes).
4. **Exchange**: A adds an expense → B sees it within ~30 s of co-presence (SC-001). Add one on B, confirm on A.
5. **Offline**: turn Wi-Fi off on both. Each edits independently. No errors; status shows `waitingForPeer` (FR-003).
6. **Reconnect**: same Wi-Fi → both converge; conflicting edits resolve to one HLC winner and the losing change is surfaced, not lost (FR-007, SC-002).
7. **Sealed month**: A seals a past month → the sealed amounts are identical on B; neither can edit it (FR-011, SC-004).
8. **Roles**: A demotes B to Viewer → B can no longer add expenses; even B's pre-demotion offline editor change is not applied after the demotion HLC (FR-008/009, SC-005).
9. **Remove**: A removes B → B's new edits never appear on A (FR-008).
10. **Backup/recover**: A exports a backup with a passphrase + recovery code; restore on a wiped device A2 via the **recovery code** → identity + spaces return; re-exchange with B works (FR-012, SC-007).
11. **Unpair/leave**: unpair stops exchange; last-Owner cannot leave (FR-014).
12. **Privacy check**: confirm no network traffic leaves beyond the two devices (no cloud calls) and the vault stayed local on both (FR-015/017, SC-008).

---

## 3. Done / Acceptance

| Check | Source |
|---|---|
| All unit scenarios pass, analyze + format clean | CI |
| Two-device walkthrough: pairing < 2 min, convergence < 30 s | SC-006, SC-001 |
| Deterministic convergence; conflicts surfaced | SC-002 |
| Sealed-month totals identical | SC-004 |
| Removed/demoted member's changes never applied | SC-005 |
| Recovery via passphrase AND recovery code | SC-007 |
| No data leaves the devices; vault local | SC-008 |
| No regression to 011 offline behaviour | FR-003 |
