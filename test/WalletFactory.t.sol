// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WalletFactory} from "../src/WalletFactory.sol";
import {MockERC20Token, MockWorldIDContract} from "./Transfer.t.sol"; // Import your MockERC20Token contract

contract WalletFactoryTest is Test {
    WalletFactory public factory;
    MockERC20Token public mockUSDT;
    MockWorldIDContract public mockWorldID;


    function setUp() public {
        factory = new WalletFactory();
    }

    function test_CreateWallet() public {
        factory.createWallet(address (mockWorldID), address(mockUSDT));

        assertEq(factory.getWalletClones().length, 1);
    }
}
