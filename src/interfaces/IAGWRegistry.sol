// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAGWRegistry {
    function isAGW(address account) external view returns (bool);
}
