// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {LibTanh} from "../../../src/utils/math/LibTanh.sol";

contract LibTanhTest is Test {
    using LibTanh for uint256;

    function testTanh1() public pure {
        uint256 x = 1e18;
        uint256 y = x.tanh();
        // 0.761594155955764888
        assertEq(y, 761594155955764888);
    }

    function testTanh2() public pure {
        uint256 x = 2e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 964027580075816884);
    }

    function testTanh3() public pure {
        uint256 x = 3e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 995054753686730451);
    }

    function testTanh4() public pure {
        uint256 x = 4e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999329299739067043);
    }

    function testTanh5() public pure {
        uint256 x = 5e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999909204262595131);
    }

    function testTanh6() public pure {
        uint256 x = 6e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999987711650795570);
    }

    function testTanh7() public pure {
        uint256 x = 7e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999998336943944671);
    }

    function testTanh8() public pure {
        uint256 x = 8e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999999774929675889);
    }

    function testTanh9() public pure {
        uint256 x = 9e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999999969540040974);
    }

    function testTanh10() public pure {
        uint256 x = 10e18;
        uint256 y = LibTanh.tanh(x);
        assertEq(y, 999999995877692763);
    }

    function testTanhOverflow() public {
        uint256 x = 136e18;
        vm.expectRevert(LibTanh.TanhOverflow.selector);
        LibTanh.tanh(x);
    }

    function testTanhCeilOverflow() public pure {
        uint256 x = 136e18;
        uint256 y = LibTanh.rawTanh(x);
        assertEq(y, 1e18);
    }
}
