/// The lock's states and the events that move between them
/// (data-model §5, `contracts/lock-state-machine.md` §2–3).
///
/// The state is **never persisted**: the app always starts `locked`, and only
/// the lockout record survives a restart, so there is no stored "unlocked" flag
/// to tamper with (data-model §5).
enum LockState {
  /// The session key is absent; only the subject's avatar, name and the single
  /// Unlock action may be shown (FR-023, FR-037).
  locked,

  /// A PIN screen or an OS prompt is up. The session key is still absent.
  unlocking,

  /// The session key is present.
  unlocked,
}

/// Everything that can move the lock (contracts `lock-state-machine.md` §3).
enum LockEvent {
  /// Every protected subject starts here at a cold start (FR-022).
  coldStart,

  /// The user asked to unlock — the PIN screen appears.
  unlockRequested,

  /// `paused` / `hidden` / `detached`: the away window starts, nothing locks
  /// yet. `inactive` deliberately does **not** appear here (FR-022, R4).
  leftForeground,

  /// The phone's own screen lock: the OS reports it as leaving the foreground.
  phoneLocked,

  /// Back before the away-time: the window is discarded.
  returnedBeforeAwayTime,

  /// Back after the away-time: the subject locks (FR-022).
  returnedAfterAwayTime,

  /// Leaving a subject locks it; the arriving one starts locked if protected.
  subjectSwitched,

  /// On-demand lock (FR-022).
  explicitLock,

  /// A correct PIN (FR-011).
  pinAccepted,

  /// A successful biometric inside a session the PIN already opened (FR-018).
  biometricAccepted,

  /// A wrong PIN: stay locked and count it (FR-026).
  pinRejected,

  /// A cancelled / failed / errored biometric: no attempt recorded (FR-019).
  biometricRejected,
}

/// The machine's reducer. Pure, so every rule in the contract's event table is
/// unit-testable without a widget or a database.
///
/// Two rules are guards rather than transitions, and they are the security
/// bearing ones:
///
/// * **A biometric can never open a cold start.** `locked` is where every
///   protected subject begins, so "only a PIN then" is exactly "the subject must
///   already be past [LockEvent.unlockRequested]" (FR-018, FR-048). A biometric
///   event that arrives while merely `locked` is ignored, not honoured.
/// * **A failed biometric is fail-closed from anywhere.** The shortcut only
///   exists inside a session the PIN opened, so an event that arrives outside it
///   is a bug or an attack; locking is the only safe answer (FR-019).
LockState reduceLockState(LockState current, LockEvent event) =>
    switch (event) {
      // Nothing to ask for: the key is already out.
      LockEvent.unlockRequested =>
        current == LockState.locked ? LockState.unlocking : current,
      LockEvent.biometricAccepted =>
        current == LockState.unlocking ? LockState.unlocked : current,
      LockEvent.coldStart ||
      LockEvent.subjectSwitched ||
      LockEvent.explicitLock ||
      LockEvent.returnedAfterAwayTime ||
      LockEvent.pinRejected ||
      LockEvent.biometricRejected =>
        LockState.locked,
      LockEvent.pinAccepted => LockState.unlocked,
      // Leaving the foreground only starts the away window; returning early
      // discards it. Neither changes the state on its own.
      LockEvent.leftForeground ||
      LockEvent.phoneLocked ||
      LockEvent.returnedBeforeAwayTime =>
        current,
    };
