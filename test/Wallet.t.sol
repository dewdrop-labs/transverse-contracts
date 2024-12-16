// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Wallet.sol";
import "../src/WalletFactory.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockWorldID.sol";

/// @title Wallet Contract Test
/// @notice This contract contains unit tests for the recordTransactionHistory function in the Wallet contract
contract WalletTest is Test {
    Wallet public wallet;
    WalletFactory public factory;
    address public owner;
    address public user1;
    address public user2;
    MockERC20 public usdt;
    MockWorldID public worldID;

    /// @notice Set up the test environment before each test
    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        usdt = new MockERC20("USDT", "USDT");
        worldID = new MockWorldID();

        factory = new WalletFactory();
        (wallet,) = factory.createWallet(address(worldID), address(usdt));

        // Fund users
        usdt.mint(user1, 1000);
        usdt.mint(user2, 1000);

        // Approve wallet for transfers
        vm.prank(user1);
        usdt.approve(address(wallet), type(uint256).max);
        vm.prank(user2);
        usdt.approve(address(wallet), type(uint256).max);

        // Set users as verified in MockWorldID
        worldID.setVerified(user1, true);
        worldID.setVerified(user2, true);
    }

    /// @notice Test recording a single transaction
    function testRecordSingleTransaction() public {
        vm.prank(user1);
        wallet.transfer(user2, 100);

        vm.prank(user1);
        Wallet.Transaction[] memory history = wallet.getTransactionHistory();
        assertEq(history.length, 1);
        assertEq(history[0].amount, 100);
        assertEq(history[0].token, address(usdt));
    }

    /// @notice Test recording multiple transactions
    function testRecordMultipleTransactions() public {
        vm.startPrank(user1);
        wallet.transfer(user2, 100);
        wallet.transfer(user2, 200);

        Wallet.Transaction[] memory history = wallet.getTransactionHistory();
        vm.stopPrank();

        assertEq(history.length, 2);
        assertEq(history[0].amount, 100);
        assertEq(history[0].token, address(usdt));
        assertEq(history[1].amount, 200);
        assertEq(history[1].token, address(usdt));
    }

    /// @notice Test recording transactions for different users
    function testRecordTransactionsForDifferentUsers() public {
        vm.prank(user1);
        wallet.transfer(user2, 100);

        vm.prank(user1);
        wallet.transfer(user2, 50);

        vm.prank(user2);
        wallet.transfer(user1, 50);

        vm.prank(user1);
        Wallet.Transaction[] memory user1History = wallet.getTransactionHistory();

        vm.prank(user2);
        Wallet.Transaction[] memory user2History = wallet.getTransactionHistory();

        assertEq(user1History.length, 2);
        assertEq(user1History[0].amount, 100);
        assertEq(user2History.length, 1);
        assertEq(user2History[0].amount, 50);
    }

    /// @notice Test recording a large amount transaction
    function testRecordLargeAmountTransaction() public {
        uint256 largeAmount = type(uint256).max / 2; // Use half of max to avoid overflow
        usdt.mint(user1, largeAmount);

        vm.startPrank(user1);
        usdt.approve(address(wallet), largeAmount);
        wallet.transfer(user2, largeAmount);

        Wallet.Transaction[] memory history = wallet.getTransactionHistory();
        vm.stopPrank();

        assertEq(history.length, 1, "Transaction was not recorded");
        assertEq(history[0].amount, largeAmount, "Recorded amount does not match");
        assertEq(history[0].token, address(usdt), "Recorded token address does not match");
    }
}
