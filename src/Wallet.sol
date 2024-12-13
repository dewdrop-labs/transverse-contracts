// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./interfaces/IERC20.sol";

contract Wallet {
    address public owner;
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

    constructor(address _owner) {
        require(msg.sender != address(0), "zero address found");
        owner = _owner;
    }

    function createWorldId() onlyOwner external {

    }

    function transfer() onlyOwner external {

    }

    //////////////////////////////////////////////
    //             View Functions              //
    ////////////////////////////////////////////

    function getTransactionHistory(address _user) external view returns (Transaction[] memory) {
        return transactions[_user];
    }

    ////////////////////////////////////////////////
    //             Private Function              //
    //////////////////////////////////////////////

    function recordTransactionHistory() private {

    }
}
