// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./interfaces/IERC20.sol";
import "./IWorldID.sol";

contract Wallet {
    address public owner;
    IWorldID public worldID;
    IERC20 public usdt;

    mapping(address => Transaction[]) transactions;
    mapping(address => mapping(address => uint256)) token_balance;

    struct Transaction {
        uint256 amount;
        address token;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    // Modifier to ensure that only verified users can call the function
    modifier onlyVerified(address user) {
        require(worldID.verifyIdentity(user), "User not verified");
        _;
    }


    constructor(address _owner, address _worldID, address _usdt) {
        require(msg.sender != address(0), "zero address found");
        owner = _owner;
         worldID = IWorldID(_worldID);
        usdt = IERC20(_usdt);
    }

    function createWorldId() onlyOwner external {

    }

    function transfer(address recipient, uint256 amount) external onlyVerified(msg.sender) {

        require(usdt.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(usdt.transferFrom(msg.sender, recipient, amount), "Transfer failed");

    }

    //////////////////////////////////////////////
    //             View Functions              //
    ////////////////////////////////////////////

    function getTransactionHistory() external view returns (Transaction[] memory) {

    }

    ////////////////////////////////////////////////
    //             Private Function              //
    //////////////////////////////////////////////

    function recordTransactionHistory() private {

    }
}
