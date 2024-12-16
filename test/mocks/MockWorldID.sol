// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/IWorldID.sol";

contract MockWorldID is IWorldID {
    mapping(address => bool) private _verified;

    function verifyIdentity(address user) external view override returns (bool) {
        return _verified[user];
    }

    function setVerified(address user, bool status) external {
        _verified[user] = status;
    }
}
