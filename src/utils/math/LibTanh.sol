// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {console2} from "forge-std/console2.sol";

library LibTanh {
    using SafeCastLib for uint256;
    using SafeCastLib for int256;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint256;

    error TanhOverflow();

    int256 private constant MAX_EXP_WAD = 135305999368893231588;

    /// @notice Computes the hyperbolic tangent of a number.
    /// @param x The number to compute the hyperbolic tangent of.
    /// @return The hyperbolic tangent of x.
    /// @dev tanh can be computed as (exp(x) - exp(-x)) / (exp(x) + exp(-x))
    ///      but we need to be careful with overflow: x must be less than 135 * WAD.
    ///      This function will revert if the calculation overflows.
    function tanh(uint256 x) public pure returns (uint256) {
        return _tanh(x, true);
    }

    /// @notice Computes the hyperbolic tangent of a number, with no revert on overflow.
    /// @param x The number to compute the hyperbolic tangent of.
    /// @return The hyperbolic tangent of x.
    /// @dev tanh can be computed as (exp(x) - exp(-x)) / (exp(x) + exp(-x))
    ///      x must be less than 135 * WAD or the calculation will overflow; this function
    ///      will return the absolute ceiling of 1e18 in this case.
    function rawTanh(uint256 x) public pure returns (uint256) {
        return _tanh(x, false);
    }

    function _tanh(uint256 x, bool checked) private pure returns (uint256) {
        int256 xInt = x.toInt256();

        if (xInt > MAX_EXP_WAD) {
            if (checked) {
                revert TanhOverflow();
            }
            xInt = MAX_EXP_WAD;
        }
        uint256 expX = xInt.expWad().toUint256();
        uint256 invExpX = (xInt * -1).expWad().toUint256();

        return (expX - invExpX).fullMulDiv(1e18, expX + invExpX);
    }
}
