// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenProcessor.sol";
import "./mocks/MockERC20.sol";

contract TokenProcessorTest is Test {
    TokenProcessor private tokenProcessor;
    MockERC20 private token1;
    MockERC20 private token2;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");

        tokenProcessor = new TokenProcessor(owner);

        token1 = new MockERC20("Mock Token 1", "MTK1");
        token2 = new MockERC20("Mock Token 2", "MTK2");

        token1.mint(owner, 100 ether);
        token2.mint(owner, 100 ether);

        token1.approve(address(tokenProcessor), type(uint256).max);
        token2.approve(address(tokenProcessor), type(uint256).max);
    }

    function testAddAcceptedToken() public {
        tokenProcessor.addAcceptedToken(address(token1));
        assertTrue(tokenProcessor.isTokenAccepted(address(token1)));
    }

    function testRemoveAcceptedToken() public {
        tokenProcessor.addAcceptedToken(address(token1));
        tokenProcessor.removeAcceptedToken(address(token1));
        assertFalse(tokenProcessor.isTokenAccepted(address(token1)));
    }

    function testFailAddAcceptedTokenFromNonOwner() public {
        vm.prank(user);
        tokenProcessor.addAcceptedToken(address(token1));
    }

    function testProcessTokenTransfer() public {
        tokenProcessor.addAcceptedToken(address(token1));

        token1.mint(user, 50 ether);
        vm.prank(user);
        token1.approve(address(tokenProcessor), 50 ether);

        uint256 initialBalance = token1.balanceOf(owner);

        tokenProcessor.processTokenTransfer(address(token1), user, owner, 10 ether);

        assertEq(token1.balanceOf(owner), initialBalance + 10 ether);
        assertEq(token1.balanceOf(user), 40 ether);
    }

    function testFailProcessTokenWithUnacceptedToken() public {
        tokenProcessor.processTokenTransfer(address(token2), owner, user, 10 ether);
    }

    function testFailProcessTokenWithInsufficientBalance() public {
        tokenProcessor.addAcceptedToken(address(token1));
        vm.prank(user);
        tokenProcessor.processTokenTransfer(address(token1), user, owner, 10 ether);
    }

    function testFailProcessTokenWithZeroAmount() public {
        tokenProcessor.addAcceptedToken(address(token1));
        tokenProcessor.processTokenTransfer(address(token1), owner, user, 0);
    }
}
