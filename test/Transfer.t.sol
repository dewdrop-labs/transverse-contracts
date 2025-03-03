// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/interfaces/IERC20.sol";

import "../src/Wallet.sol";
import "../src/IWorldID.sol";
import {MockWorldID} from "test/mocks/MockWorldID.sol";

// MockERC20Token contract
contract MockERC20Token is IERC20 {
    string public name = "Mock USDT";
    string public symbol = "USDT";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor() {
        _totalSupply = 0;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function mint(address account, uint256 amount) public {
        _totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

// USDTTransferTest contract
contract USDTTransferTest is Test {
    Wallet private transferContract;
    MockERC20Token private mockUSDT;
    MockWorldID private mockWorldID;
    address private user1 = address(0x1);
    address private user2 = address(0x2);
    uint256 private initialBalance = 1000e18;
    address _owner = address(this);

    // Setup function to deploy mocks and the transfer contract
    function setUp() public {
        mockWorldID = new MockWorldID();

        mockUSDT = new MockERC20Token();
        transferContract = new Wallet(_owner, address(mockWorldID), address(mockUSDT));

        // Mint some USDT for user1
        mockUSDT.mint(user1, initialBalance);

        // Approve transferContract to spend user1's tokens
        vm.prank(user1);
        mockUSDT.approve(address(transferContract), initialBalance);
    }

    // Test constructor - Verifying contract state after deployment
    function testConstructor() public view {
        assertEq(transferContract.owner(), address(this));
        assertEq(address(transferContract.worldID()), address(mockWorldID));
        assertTrue(transferContract.supportedTokens(address(mockUSDT)));
    }

    // Test transfer function - Successful transfer
    function testTransferSuccess() public {
        uint256 transferAmount = 100e18;
        uint256 user1BalanceBefore = mockUSDT.balanceOf(user1);
        uint256 user2BalanceBefore = mockUSDT.balanceOf(user2);
        bytes memory validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), true);

        // Perform the transfer
        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount, validZkProof);

        // Assert balances after transfer
        assertEq(mockUSDT.balanceOf(user1), user1BalanceBefore - transferAmount);
        assertEq(mockUSDT.balanceOf(user2), user2BalanceBefore + transferAmount);
    }

    // Test transfer function - Insufficient balance
    function testTransferInsufficientBalance() public {
        uint256 transferAmount = initialBalance + 1e18;
        bytes memory validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), true);

        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        transferContract.transfer(user2, address(mockUSDT), transferAmount, validZkProof);
    }

    // Test transfer function - Unverified user
    function testTransferUnverifiedUser() public {
        uint256 transferAmount = 100e18;
        bytes memory invalidZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), false);

        // Expect revert with specific reason
        vm.expectRevert("NonExistentRoot or ExpiredRoot");
        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount, invalidZkProof);
    }

    // Test transfer function - Transfer with used proof should revert
    function testTransferWithUsedProofReverts() public {
        uint256 transferAmount = 100e18;
        bytes memory validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), true);

        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount, validZkProof);

        // Expect revert with specific reason
        vm.expectRevert("Invalid Nullifier");
        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount, validZkProof);
    }

    // Test transfer function - Multiple consecutive transfers
    function testMultipleConsecutiveTransfers() public {
        uint256 transferAmount1 = 100e18;
        uint256 transferAmount2 = 50e18;
        bytes memory validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), true);

        // User1's initial balance
        uint256 user1BalanceBefore = mockUSDT.balanceOf(user1);
        uint256 user2BalanceBefore = mockUSDT.balanceOf(user2);

        // First transfer
        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount1, validZkProof);

        // Assert balances after first transfer
        assertEq(mockUSDT.balanceOf(user1), user1BalanceBefore - transferAmount1);
        assertEq(mockUSDT.balanceOf(user2), user2BalanceBefore + transferAmount1);

        // Second transfer
        user1BalanceBefore = mockUSDT.balanceOf(user1);
        user2BalanceBefore = mockUSDT.balanceOf(user2);

        validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some other seed")), true);
        vm.prank(user1);
        transferContract.transfer(user2, address(mockUSDT), transferAmount2, validZkProof);

        assertEq(mockUSDT.balanceOf(user1), user1BalanceBefore - transferAmount2);
        assertEq(mockUSDT.balanceOf(user2), user2BalanceBefore + transferAmount2);
    }

    // Test transfer function - Zero amount transfer
    function testTransferZeroAmount() public {
        uint256 transferAmount = 0;
        bytes memory validZkProof = mockWorldID.generateZkProof(uint256(keccak256("some seed")), true);

        vm.prank(user1);

        vm.expectRevert("Transfer amount must be greater than zero");
        transferContract.transfer(user2, address(mockUSDT), transferAmount, validZkProof);
    }
}
