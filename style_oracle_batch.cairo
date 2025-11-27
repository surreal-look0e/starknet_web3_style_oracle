// style_oracle_batch.cairo
// Extended Web3 style oracle for StarkNet (Cairo 1)

#![no_main]

use core::traits::Into;
use starknet::ContractAddress;
use starknet::get_caller_address;

#[starknet::contract]
mod style_oracle_batch {
    use super::{Into, ContractAddress, get_caller_address};
    use starknet::storage::LegacyMap;

    // -------------------------
    // Storage
    // -------------------------
    #[storage]
    struct Storage {
        // Per-caller last chosen style index (0, 1, or 2).
        style_by_caller: LegacyMap::<ContractAddress, u8>,

                /// Global counter: how many times style 0 (Aztec) was chosen.
        /// NOTE: This is a simple monotonically increasing counter and
        /// does not protect against theoretical u64 overflow (extremely unlikely).
        count_aztec: u64,
        count_zama: u64,
        count_soundness_first: u64,
    }

    // -------------------------
    // Events
    // -------------------------
    #[derive(Drop, starknet::Event)]
    #[event]
    enum Event {
        StyleChosen: StyleChosen,
    }

    #[derive(Drop, Serde)]
    struct StyleChosen {
        caller: ContractAddress,
        style_index: u8,
        // (aztec_score, zama_score, soundness_first_score)
        scores: (u64, u64, u64),
    }

    // -------------------------
    // Constructor
    // -------------------------
    #[constructor]
    fn constructor(ref self: Storage) {
        // Nothing special, everything defaults to zero.
    }

    // -------------------------
    // Internal scoring logic
    // -------------------------
    fn compute_scores(
        privacy: u16,
        fhe: u16,
        soundness: u16,
    ) -> (u64, u64, u64) {
        // Cast u16 → u64 so we can multiply safely.
        let p: u64 = privacy.into();
        let f: u64 = fhe.into();
        let s: u64 = soundness.into();

        // Same scoring model as described in README:
        //
        // Aztec score:        privacy*3 + soundness*2
        // Zama score:         privacy*3 + fhe*3
        // Soundness-first:    soundness*4 + privacy
        let aztec_score: u64 = p * 3_u64 + s * 2_u64;
        let zama_score: u64 = p * 3_u64 + f * 3_u64;
        let soundness_score: u64 = s * 4_u64 + p;

        (aztec_score, zama_score, soundness_score)
    }

    fn choose_best_style(
        aztec_score: u64,
        zama_score: u64,
        soundness_score: u64,
    ) -> u8 {
        let mut best_index: u8 = 0_u8;
        let mut best_score: u64 = aztec_score;

        if zama_score > best_score {
            best_score = zama_score;
            best_index = 1_u8;
        }

        if soundness_score > best_score {
            best_score = soundness_score;
            best_index = 2_u8;
        }

        best_index
    }

    // -------------------------
    // External functions
    // -------------------------

    /// Classify the caller's project into one of three styles.
    ///
    /// Inputs (0–10 recommended, but not enforced):
    /// - privacy
    /// - fhe
    /// - soundness
    ///
    /// Returns:
    /// - style index (0, 1, or 2)
    ///
    /// Side effects:
    /// - updates per-caller mapping
    /// - increments global counters
    /// - emits StyleChosen event
    #[external(v0)]
    fn choose_style_for_caller(
        ref self: Storage,
        privacy: u16,
        fhe: u16,
        soundness: u16,
    ) -> u8 {
        let caller: ContractAddress = get_caller_address();

        let (aztec_score, zama_score, soundness_score) =
            super::compute_scores(privacy, fhe, soundness);

        let style_index: u8 =
            super::choose_best_style(aztec_score, zama_score, soundness_score);

        // Store the result per caller.
        self.style_by_caller.write(caller, style_index);

        // Update global counters.
        match style_index {
            0_u8 => {
                let current = self.count_aztec.read();
                self.count_aztec.write(current + 1_u64);
            },
            1_u8 => {
                let current = self.count_zama.read();
                self.count_zama.write(current + 1_u64);
            },
            _ => {
                // style_index == 2
                let current = self.count_soundness_first.read();
                self.count_soundness_first.write(current + 1_u64);
            },
        }

        // Emit event with scores for analytics.
        self.emit(
            Event::StyleChosen(
                StyleChosen {
                    caller,
                    style_index,
                    scores: (aztec_score, zama_score, soundness_score),
                }
            )
        );

        style_index
    }

    // -------------------------
    // View functions
    // -------------------------

    /// Return the last chosen style for a specific address.
    ///
    /// NOTE: If the address never called `choose_style_for_caller`,
    /// this will return 0 (Aztec) because LegacyMap defaults to zero.
    #[view]
    fn get_last_style_of(
        self: @Storage,
        caller: ContractAddress,
    ) -> u8 {
        self.style_by_caller.read(caller)
    }

    /// Return the global counters for how many times each style
    /// has been chosen.
    ///
    /// Returns:
    ///   (count_aztec, count_zama, count_soundness_first)
    #[view]
    fn get_style_counts(
        self: @Storage,
    ) -> (u64, u64, u64) {
        (
            self.count_aztec.read(),
            self.count_zama.read(),
            self.count_soundness_first.read(),
        )
    }
}
