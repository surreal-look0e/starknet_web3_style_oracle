// app.cairo
// Cairo 1 contract for StarkNet: a tiny Web3 style oracle that
// categorizes a project as Aztec-style, Zama-style, or Soundness-first
// based on three numeric preference scores.

#[starknet::contract]
mod web3_style_oracle {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        last_caller: ContractAddress,
        last_style: u8,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StyleChosen: StyleChosen,
    }

    #[derive(Drop, starknet::Event)]
    struct StyleChosen {
        caller: ContractAddress,
        style: u8,
    }

    #[contractimpl]
    impl Web3StyleOracleImpl of web3_style_oracle::Web3StyleOracleImpl {
        #[external]
        fn choose_style(ref self: Storage, privacy: u8, fhe: u8, soundness: u8) -> u8 {
            let caller: ContractAddress = get_caller_address();
            let style: u8 = compute_style(privacy, fhe, soundness);

            self.last_caller.write(caller);
            self.last_style.write(style);

            self.emit(Event::StyleChosen(StyleChosen { caller, style }));

            style
        }

        #[view]
        fn get_last_style(self: @Storage) -> (ContractAddress, u8) {
            let caller: ContractAddress = self.last_caller.read();
            let style: u8 = self.last_style.read();
            (caller, style)
        }
    }

    fn compute_style(privacy: u8, fhe: u8, soundness: u8) -> u8 {
        let p: u16 = privacy.into();
        let f: u16 = fhe.into();
        let s: u16 = soundness.into();

               // Weighted scoring model (purely illustrative):
        // Aztec     = 3 * privacy + 2 * soundness
        // Zama      = 3 * privacy + 3 * FHE
        // Soundness = 4 * soundness + 1 * privacy
        let aztec_score: u16 = p * 3_u16 + s * 2_u16;
        let zama_score: u16 = p * 3_u16 + f * 3_u16;
        let sound_score: u16 = s * 4_u16 + p;


        let mut best_idx: u8 = 0_u8;
        let mut best_score: u16 = aztec_score;

        if zama_score > best_score {
            best_idx = 1_u8;
            best_score = zama_score;
        }

        if sound_score > best_score {
            best_idx = 2_u8;
            best_score = sound_score;
        }

        best_idx
    }
}
