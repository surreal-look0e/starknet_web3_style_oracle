// style_oracle.cairo

use starknet::ContractAddress;
use starknet::get_caller_address;
use starknet::storage::LegacyMap;

#[starknet::contract]
mod web3_style_oracle {
    use super::{ContractAddress, get_caller_address, LegacyMap};

    // Stores a small style config per address:
    // privacy / soundness / performance = 0..100
    // score = average of the three
    // class = 0,1,2 buckets
       /// On-chain style configuration associated with one address.
    #[derive(Copy, Drop, Serde)]
    struct StyleConfig {
        /// 0–100: emphasis on privacy (higher = more privacy-focused).
        privacy: u8,
        /// 0–100: emphasis on soundness / correctness.
        soundness: u8,
        /// 0–100: emphasis on performance / throughput.
        performance: u8,
        /// 0–100: simple average of the three sliders.
        score: u8,
        /// 0,1,2 bucket derived from `score` (0 = conservative, 1 = balanced, 2 = aggressive).
        class: u8,
    }


    #[storage]
    struct Storage {
        configs: LegacyMap<ContractAddress, StyleConfig>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StyleUpdated: StyleUpdated,
    }

    #[derive(Drop, Serde)]
    struct StyleUpdated {
        owner: ContractAddress,
        privacy: u8,
        soundness: u8,
        performance: u8,
        score: u8,
        class: u8,
    }

    /// (Optional) no-op constructor.
    #[constructor]
    fn constructor(ref self: Storage) {
        // nothing to initialize
    }

    /// Compute the average style score (0–100) from three 0–100 inputs.
    fn compute_score(privacy: u8, soundness: u8, performance: u8) -> u8 {
        // Work in u16 to avoid overflow, then cast back.
        let p: u16 = privacy.into();
        let s: u16 = soundness.into();
        let t: u16 = performance.into();

        let sum: u16 = p + s + t;
        let avg: u16 = sum / 3_u16;

        avg.try_into().unwrap()
    }

    /// Classify the score into:
    /// 0 = conservative / low-risk
    /// 1 = balanced
    /// 2 = aggressive / perf-heavy
    fn classify_style(score: u8) -> u8 {
        if score <= 33_u8 {
            0_u8
        } else if score <= 66_u8 {
            1_u8
        } else {
            2_u8
        }
    }

    /// Public helper: given three sliders, return (score, class)
    #[view]
    fn preview_gauge(
        self: @Storage,
        privacy: u8,
        soundness: u8,
        performance: u8,
    ) -> (u8, u8) {
        let score: u8 = compute_score(privacy, soundness, performance);
        let class: u8 = classify_style(score);
        (score, class)
    }

    /// External: store the caller's config in contract storage.
    #[external]
    fn set_style(
        ref self: Storage,
        privacy: u8,
        soundness: u8,
        performance: u8,
    ) {
        let owner: ContractAddress = get_caller_address();

        let score: u8 = compute_score(privacy, soundness, performance);
        let class: u8 = classify_style(score);

        let cfg = StyleConfig {
            privacy,
            soundness,
            performance,
            score,
            class,
        };

        self.configs.write(owner, cfg);

        self.emit(
            Event::StyleUpdated(
                StyleUpdated {
                    owner,
                    privacy,
                    soundness,
                    performance,
                    score,
                    class,
                }
            )
        );
    }

    /// View: read a stored config for a given address.
    /// If none exists yet, returns zeros.
    #[view]
    fn get_style(
        self: @Storage,
        owner: ContractAddress,
    ) -> (u8, u8, u8, u8, u8) {
        match self.configs.read(owner) {
            Option::Some(cfg) => (
                cfg.privacy,
                cfg.soundness,
                cfg.performance,
                cfg.score,
                cfg.class,
            ),
            Option::None(_) => (0_u8, 0_u8, 0_u8, 0_u8, 0_u8),
        }
    }
}
