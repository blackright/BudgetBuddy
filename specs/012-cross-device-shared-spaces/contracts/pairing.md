# Contract: Pairing (QR + LAN handshake)

**Feature**: 012-cross-device-shared-spaces
**Covers**: FR-004, FR-005, SC-006 · **Design**: research R2, R1

Co-located, in-person, single-use, expirable, cancellable. No server, no directory, no search.

---

## 1. Identity Binding (no registry)

- A username is a **label**, never a lookup key. There is no uniqueness and no search.
- The username ⇄ public-key binding is established **only** by scanning the QR in person.
- Disambiguator shown everywhere a peer appears: `username (fingerprint)`.

## 2. QR Payload (presenter → scanner)

```json
{
  "v": 1,
  "type": "buddy.pairing",
  "identityId": "<fingerprint of presenter public key>",
  "username": "<presenter display name>",
  "publicKey": "<base64 ed25519>",
  "fingerprint": "<short human hash>",
  "spaceId": <int>,                 // presenter's SharedSpace.id (display only)
  "offeredRole": "owner|editor|viewer",
  "token": "<base64url >=128-bit random>",
  "expiresAt": "<ISO-8601 UTC>"
}
```

**Rules**
- The QR encodes a brand-new `PairingToken` (`direction = presented`) with `expiresAt = createdAt + TTL` (default 120 s).
- Remakes and cancellations invalidate the previous token (`usedAt` set / row deleted).
- Scanning requires the scanner to already have an `Identity` (create one first, FR-001).

## 3. Handshake Sequence

1. **Presenter** selects a space + `offeredRole`, confirms the **fingerprint** on screen, and displays the QR. `PairingToken` persisted (`presented`, unused).
2. **Scanner** scans the QR, parses/validates the payload (`v`, token, `expiresAt`), and shows `username (fingerprint)` + space + role for explicit confirmation.
3. Scanner sends a **claim**: `{token, scannerIdentityId, scannerPublicKey, scannerUsername}` over the LAN transport (R2), and also stores the presenter's key locally on confirm.
4. Presenter verifies: token exists, matches `direction=presented`, is **unused**, is **not expired**, and the space still has a valid Owner. On success:
   - Mark `PairingToken.usedAt = now` (**single-use**).
   - Create/refresh `SharedMember{profileId → scanner, role: offeredRole}` **signed by the presenter's identity** with a fresh HLC `version` (R5).
   - Create `PairedPeer` (presenter side) + `PairedContext`.
5. Presenter replies with the space's current signed membership + change-log high-water mark; both sides persist `PairedPeer`/`PairedContext` and open a `SyncCursor`.
6. Both devices converge via the change-log exchange (see `sync-protocol.md`).

## 4. Failure & Edge Cases

| Case | Behavior |
|---|---|
| Token expired | Claim refused; presenter must display a new QR (FR-005) |
| Token already used | Refused — single-use (no replay) (FR-005) |
| Fingerprint mismatch / tampered QR | Refused; scanner shown a mismatch warning |
| Same identity claims twice | Idempotent: existing membership refreshed, duplicate `PairedPeer` refused (FR-005) |
| Scanner has no identity | Prompted to create one (FR-001) |
| Presenter offline mid-claim | Claim fails cleanly; token remains valid until expiry; retry allowed while co-present (FR-013) |
| Space has no Owner | Pairing refused (last-Owner invariant, 011 FR-006) |

## 5. Cancellation & Unpair

- **Cancel**: presenter can cancel a presented token at any time → row invalidated; outstanding QR stops working.
- **Unpair** (FR-014): either side sets `PairedContext.active = false`, tombstones the exchange cursor, and stops accepting that peer's changes. Local data the user already holds remains; no remote wipe is implied (removal is authoritative via signed membership, R5).

## 6. Non-Goals

- No remote pairing (must be co-present) · no QR of secrets/passwords (only a public key + single-use token) · no network discovery of *human* identities (only device advertisements, gated by an earlier QR pairing).
