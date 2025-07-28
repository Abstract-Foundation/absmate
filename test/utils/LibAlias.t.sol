// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {LibAlias} from "../../src/utils/LibAlias.sol";
import {LibMap} from "solady/utils/LibMap.sol";
import {console} from "forge-std/console.sol";

contract LibAliasTest is Test {
    using LibAlias for LibAlias.Alias;
    using LibMap for LibMap.Uint32Map;

    LibAlias.Alias _alias;

    uint32[] public fixtureSize = [10, 100, 1000];

    function test_fill_4_items() public {
        vm.pauseGasMetering();
        uint16[] memory probs = new uint16[](4);
        probs[0] = 270; // 2.7%
        probs[1] = 950; // 9.5%
        probs[2] = 2280; // 22.8%
        probs[3] = 6500; // 65%

        vm.resumeGasMetering();

        _alias.fill(probs);

        vm.pauseGasMetering();

        assertEq(_alias.size, 4);
        assertEq(_alias.probs.get(0), 1080);
        assertEq(_alias.probs.get(1), 3800);
        assertEq(_alias.probs.get(2), 9120);
        assertEq(_alias.probs.get(3), 10000);
        assertEq(_alias.aliases.get(0), 3);
        assertEq(_alias.aliases.get(1), 3);
        assertEq(_alias.aliases.get(2), 3);
        assertEq(_alias.aliases.get(3), 3);

        vm.resumeGasMetering();
    }

    function test_select_4_items() public {
        uint16[] memory probs = new uint16[](4);
        probs[0] = 270; // 2.7%
        probs[1] = 950; // 9.5%
        probs[2] = 2280; // 22.8%
        probs[3] = 6500; // 65%

        _alias.fill(probs);

        // Test direct selections
        assertEq(_alias.select(0x8700000000000000000000000000000000), 0);
        assertEq(_alias.select(0x1db00000000000000000000000000000001), 1);
        assertEq(_alias.select(0x47400000000000000000000000000000002), 2);
        assertEq(_alias.select(0x4e200000000000000000000000000000003), 3);

        // Test alias selections
        assertEq(_alias.select(0x4f600000000000000000000000000000000), 3);
        assertEq(_alias.select(0x79e00000000000000000000000000000001), 3);
        assertEq(_alias.select(0xcd000000000000000000000000000000002), 3);
        assertEq(_alias.select(0xdac00000000000000000000000000000003), 3);
    }

    function test_fill_4_items_notOneSummed() public {
        vm.pauseGasMetering();
        uint16[] memory probs = new uint16[](4);
        probs[0] = 540; // 5.4%
        probs[1] = 1900; // 19%
        probs[2] = 4560; // 45.6%
        probs[3] = 13000; // 130%

        vm.resumeGasMetering();

        _alias.fill(probs);

        vm.pauseGasMetering();

        assertEq(_alias.totalWeight, 20000);

        assertEq(_alias.size, 4);
        assertEq(_alias.probs.get(0), 2160);
        assertEq(_alias.probs.get(1), 7600);
        assertEq(_alias.probs.get(2), 18240);
        assertEq(_alias.probs.get(3), 20000);
        assertEq(_alias.aliases.get(0), 3);
        assertEq(_alias.aliases.get(1), 3);
        assertEq(_alias.aliases.get(2), 3);
        assertEq(_alias.aliases.get(3), 3);

        vm.resumeGasMetering();
    }

    function test_fill_5_items_unbalanced() public {
        uint16[] memory probs = new uint16[](5);
        probs[0] = 1000;
        probs[1] = 2000;
        probs[2] = 2000;
        probs[3] = 4500;
        probs[4] = 5500;

        _alias.fill(probs);
    }

    function test_fill_20_items() public {
        uint16[] memory probs = new uint16[](20);
        probs[0] = 50; // 0.5%
        probs[1] = 100; // 1%
        probs[2] = 150; // 1.5%
        probs[3] = 200; // 2%
        probs[4] = 250; // 2.5%
        probs[5] = 300; // 3%
        probs[6] = 350; // 3.5%
        probs[7] = 400; // 4%
        probs[8] = 450; // 4.5%
        probs[9] = 500; // 5%
        probs[10] = 550; // 5.5%
        probs[11] = 600; // 6%
        probs[12] = 650; // 6.5%
        probs[13] = 700; // 7%
        probs[14] = 750; // 7.5%
        probs[15] = 800; // 8%
        probs[16] = 850; // 8.5%
        probs[17] = 900; // 9%
        probs[18] = 950; // 9.5%
        probs[19] = 500; // 5%

        _alias.fill(probs);

        assertEq(_alias.size, 20);
        assertEq(_alias.probs.get(0), 1000);
        assertEq(_alias.probs.get(1), 2000);
        assertEq(_alias.probs.get(2), 3000);
        assertEq(_alias.probs.get(3), 4000);
        assertEq(_alias.probs.get(4), 5000);
        assertEq(_alias.probs.get(5), 6000);
        assertEq(_alias.probs.get(6), 7000);
        assertEq(_alias.probs.get(7), 8000);
        assertEq(_alias.probs.get(8), 9000);
        assertEq(_alias.probs.get(9), 10000);
        assertEq(_alias.probs.get(10), 10000);
        assertEq(_alias.probs.get(11), 9000);
        assertEq(_alias.probs.get(12), 7000);
        assertEq(_alias.probs.get(13), 4000);
        assertEq(_alias.probs.get(14), 9000);
        assertEq(_alias.probs.get(15), 4000);
        assertEq(_alias.probs.get(16), 6000);
        assertEq(_alias.probs.get(17), 6000);
        assertEq(_alias.probs.get(18), 9000);
        assertEq(_alias.probs.get(19), 9000);
        assertEq(_alias.aliases.get(0), 13);
        assertEq(_alias.aliases.get(1), 15);
        assertEq(_alias.aliases.get(2), 16);
        assertEq(_alias.aliases.get(3), 17);
        assertEq(_alias.aliases.get(4), 17);
        assertEq(_alias.aliases.get(5), 18);
        assertEq(_alias.aliases.get(6), 18);
        assertEq(_alias.aliases.get(7), 18);
        assertEq(_alias.aliases.get(8), 19);
        assertEq(_alias.aliases.get(9), 9);
        assertEq(_alias.aliases.get(10), 10);
        assertEq(_alias.aliases.get(11), 10);
        assertEq(_alias.aliases.get(12), 11);
        assertEq(_alias.aliases.get(13), 12);
        assertEq(_alias.aliases.get(14), 13);
        assertEq(_alias.aliases.get(15), 14);
        assertEq(_alias.aliases.get(16), 15);
        assertEq(_alias.aliases.get(17), 16);
        assertEq(_alias.aliases.get(18), 17);
        assertEq(_alias.aliases.get(19), 18);
    }

    function test_fill_edge_case() public {
        uint16[] memory weights = new uint16[](20);
        weights[0] = 1;
        weights[1] = 1;
        weights[2] = 1;
        weights[3] = 1;
        weights[4] = 1;
        weights[5] = 1;
        weights[6] = 1;
        weights[7] = 1;
        weights[8] = 1;
        weights[9] = 1;
        weights[10] = 1;
        weights[11] = 1;
        weights[12] = 1;
        weights[13] = 1;
        weights[14] = 1;
        weights[15] = 1;
        weights[16] = 1;
        weights[17] = 1;
        weights[18] = 1;
        weights[19] = 65535;

        _alias.fill(weights);

        assertEq(_alias.size, 20);
    }

    function testFuzz_fill_items(uint16[] memory weights) public {
        _alias.fill(weights);

        uint32 totalWeight = 0;
        for (uint32 i; i < weights.length; ++i) {
            totalWeight += weights[i];
        }

        assertEq(_alias.size, weights.length);
        assertEq(_alias.totalWeight, totalWeight);
    }

    function testFuzz_fill_items(uint32 size) public {
        vm.assume(size < 20000);

        uint16[] memory weights = new uint16[](size);
        for (uint32 i; i < size; ++i) {
            weights[i] = uint16(i);
        }

        _alias.fill(weights);

        assertEq(_alias.size, size);
    }
}
