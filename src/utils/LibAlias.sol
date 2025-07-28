// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibMap} from "solady/utils/LibMap.sol";

/// @title LibAlias
/// @notice A library implementing the alias method for efficient weighted random sampling.
/// @dev The alias method allows O(1) sampling from a discrete probability distribution after O(n) preprocessing.
/// @dev This is particularly useful for applications requiring frequent random sampling from a fixed distribution,
/// such as randomized algorithms, simulations, and games.
/// @dev Implementation uses two arrays: probabilities and aliases, enabling constant-time sampling.
/// @dev Limited size of alias table for gas efficiency and minimized storage writes; no individual weight
/// may be greater than (2^32 - 1) / size, and the total set of probabilities must not exceed 2^32 - 1 items.
library LibAlias {
    using LibMap for LibMap.Uint32Map;

    /// @notice Thrown when input arrays have mismatched lengths.
    error ArrayLengthMismatch();

    /// @notice Main data structure for the alias method.
    /// @dev Stores the preprocessed alias table for efficient sampling.
    /// @param size Number of elements in the distribution.
    /// @param totalWeight Sum of all weights in the original distribution.
    /// @param probs Scaled probabilities for each index (probability * size)
    /// @param aliases Alias indices for rejection sampling
    struct Alias {
        uint32 size;
        uint32 totalWeight;
        LibMap.Uint32Map probs;
        LibMap.Uint32Map aliases;
    }

    /// @notice Temporary state used during alias table construction
    /// @dev Used internally by the fill function for organizing probabilities
    /// @param index Original index in the weight array
    /// @param scaledProb Probability scaled by the distribution size
    struct WorkingState {
        uint32 index;
        uint32 scaledProb;
    }

    /// @notice Select a random index from the alias table
    /// @dev Uses the alias method for O(1) sampling. Splits the seed into two parts:
    /// @dev - Lower 128 bits for column selection
    /// @dev - Upper 128 bits for probability comparison within the column
    /// @param self The alias table to sample from
    /// @param seed Random seed for selection (256-bit value)
    /// @return The selected index (0 to size-1)
    function select(Alias storage self, uint256 seed) internal view returns (uint32) {
        uint32 cachedSize = self.size;
        uint32 colIndex = uint32(uint128(seed) % cachedSize);
        uint256 prob = ((seed >> 128) % self.totalWeight) * cachedSize;

        uint32 col = self.probs.get(colIndex);
        if (prob < col) {
            return colIndex;
        } else {
            return self.aliases.get(colIndex);
        }
    }

    /// @notice Set the alias table from preprocessed data
    /// @dev Use this when you have pre-calculated probabilities and aliases
    /// @dev The probs array should contain scaled probabilities (original_prob * size)
    /// @dev The aliases array should contain the alias indices for each column
    /// @param self The alias table to populate
    /// @param totalWeight Sum of all original weights
    /// @param probs Array of scaled probabilities
    /// @param aliases Array of alias indices
    function setRaw(Alias storage self, uint32 totalWeight, uint256[] calldata probs, uint256[] calldata aliases)
        internal
    {
        uint256 length = probs.length;
        if (length != aliases.length) {
            revert ArrayLengthMismatch();
        }
        for (uint32 i; i < length; ++i) {
            self.probs.map[i] = probs[i];
            self.aliases.map[i] = aliases[i];
        }
        self.totalWeight = totalWeight;
        self.size = uint32(length);
    }

    /// @notice Construct alias table from weight distribution
    /// @dev Implements the alias method construction algorithm with O(n) complexity
    /// @dev Automatically handles the probability scaling and alias assignment
    /// @dev Uses the "small" and "large" probability redistribution technique
    /// @param self The alias table to populate
    /// @param weights Array of weights for each outcome (must be non-zero length)
    function fill(Alias storage self, uint16[] memory weights) internal {
        uint32 size = uint32(weights.length);
        WorkingState[] memory smallProbs = new WorkingState[](size);
        WorkingState[] memory largeProbs = new WorkingState[](size);
        uint256 smallCount;
        uint256 largeCount;
        uint32 totalWeight;

        for (uint32 i; i < size; ++i) {
            totalWeight += weights[i];
        }

        for (uint32 i; i < size; ++i) {
            uint32 scaledProb = weights[i] * size;
            self.probs.set(i, scaledProb);
            self.aliases.set(i, i);

            WorkingState memory workingState = WorkingState({scaledProb: scaledProb, index: i});
            if (scaledProb < totalWeight) {
                smallProbs[smallCount++] = workingState;
            } else {
                largeProbs[largeCount++] = workingState;
            }
        }

        while (smallCount > 0 && largeCount > 0) {
            WorkingState memory small = smallProbs[--smallCount];
            WorkingState memory large = largeProbs[--largeCount];

            self.aliases.set(small.index, large.index);
            self.probs.set(small.index, small.scaledProb);

            large.scaledProb -= (totalWeight - small.scaledProb);

            if (large.scaledProb < totalWeight) {
                smallProbs[smallCount++] = large;
            } else {
                largeCount++;
            }
        }

        while (largeCount > 0) {
            WorkingState memory large = largeProbs[--largeCount];
            self.probs.set(large.index, totalWeight);
            self.aliases.set(large.index, large.index);
        }

        self.size = size;
        self.totalWeight = totalWeight;
    }
}
