# Contract: Backup & Recovery (user-held encrypted archive)

**Feature**: 012-cross-device-shared-spaces
**Covers**: FR-012, FR-017, SC-007, SC-008 · **Design**: research R1, R7

The app never transmits data. The user owns the archive and moves it themselves.

---

## 1. Archive Format

```
"BUDDYBK1"                     // magic + version
salt(16) | nonce(12)
AES-256-GCM ciphertext( payload )   // payload is canonical; GCM tag appended
wrappedKeyA( passphrase )      // Argon2id-derived key wrapping
wrappedKeyB( recoveryCode )    // recovery-code-derived key wrapping
```

- **AES-256-GCM** for confidentiality + integrity.
- **Passphrase path**: `Argon2id(passphrase, salt)` → key A.
- **Recovery-code path**: 128-bit code (Crockford base32, shown once; formatted `XXXX-XXXX-XXXX-XXXX`) → key B.
- **Either** wrapped key unlocks the payload (the spec requires both) (FR-012).

## 2. Payload Contents

```
{ identity: { username, publicKey, privateKey(ciphertext-in-payload) },
  contexts: [ { kind, spaceId, changeLog[], currentRows[] } ],
  createdAt }
```

- Includes the identity keypair so a fresh install can restore the same identity (R7).
- Includes shared contexts' change-log + current rows; **excludes** the vault (FR-015) and device-global market data (R6).

## 3. Export Flow

1. User chooses export (Settings → Backup).
2. User sets a **passphrase** and chooses/accepts the **generated recovery code** (both required to be shown).
3. App builds the archive, then uses `file_picker`/`path_provider` to save locally and/or `share_plus` to send it **to the user's own email/storage**.
4. The app shows the recovery code **once** and warns to store it safely.

## 4. Import / Recovery Flow

1. Fresh (or reset) install → "Restore from backup".
2. User picks the archive file and supplies **either** the passphrase or the recovery code.
3. App decrypts, restores `Identity` + contexts + change-log, then continues offline.
4. Live exchange with previously paired peers resumes when next co-present (recovery does **not** need a server) (R7).

## 5. Security Rules

- The app **never** transmits the archive or its contents anywhere (FR-017, SC-008).
- Private key material inside the payload is encrypted; on restore it moves into `flutter_secure_storage` (R1).
- Wrong secret ⇒ decryption fails with a clear message; no partial restore.
- Recovery code is high-entropy and single-show; it is a **second** independent path, not a replacement for the passphrase.

## 6. Failure & Edge Cases

| Case | Behavior |
|---|---|
| Forgotten passphrase but recovery code kept | Restore succeeds via code (FR-012) |
| Forgotten both | Unrecoverable by design (no server escrow); user is warned at export |
| Corrupted/tampered archive | GCM auth fails ⇒ refused; no partial restore |
| Archive from a different app version | Version header checked; unsupported ⇒ clear error |
| Restore onto a device with an existing identity | User chooses: replace or keep separate (one profile per identity, FR-016) |
| Restore while a peer is paired | Fine; cursors reset and catch-up proceeds on next co-presence |

## 7. Non-Goals

No cloud/server escrow · no automatic background backup · no plaintext export · no emailing on the user's behalf (the user sends it to themselves).
