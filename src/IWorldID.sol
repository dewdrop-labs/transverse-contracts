// SPDX-License-Identifier: MIT

// IWorldID.sol
pragma solidity ^0.8.0;

interface IWorldID {
    function verifyIdentity(address user) external view returns (bool);
}
