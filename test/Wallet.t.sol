// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public owner;
    address public user1;
    address public user2;
    address public token1;
    address public token2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        token1 = address(0x3);
        token2 = address(0x4);

        wallet = new Wallet(owner);
    }
}