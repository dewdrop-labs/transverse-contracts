// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IWorldID.sol";

contract USDTTransfer {
    // Declare the contract owner, WorldID for identity verification, and USDT token contract
    address public owner;
    IWorldID public worldID;
    IERC20 public usdt;

    // Constructor to initialize WorldID and USDT contract addresses
    constructor(address _worldID, address _usdt) {
        owner = msg.sender;
        worldID = IWorldID(_worldID);
        usdt = IERC20(_usdt);
    }

    // Modifier to ensure that only verified users can call the function
    modifier onlyVerified(address user) {
        require(worldID.verifyIdentity(user), "User not verified");
        _;
    }

    // Transfer function to send USDT from the sender to the recipient
    function transfer(address recipient, uint256 amount) external onlyVerified(msg.sender) {
        require(usdt.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(usdt.transferFrom(msg.sender, recipient, amount), "Transfer failed");
    }
}
