// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./IWorldID.sol";

contract Wallet {
    address public owner;
    IWorldID public worldID;
    IERC20 public usdt;

    mapping(address => Transaction[]) public transactions;
    mapping(address => mapping(address => uint256)) token_balance;
    mapping(address => bool) public supportedTokens;

    struct Transaction {
        uint256 amount;
        address token;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // Modifier to ensure that only verified users can call the function
    modifier onlyVerified(address user) {
        require(worldID.verifyIdentity(user), "User not verified");
        _;
    }

    modifier onlySupportedToken(address _token) {
        require(supportedTokens[_token], "Token not supported");
        _;
    }

    constructor(address _owner, address _worldID, address _usdt) {
        require(msg.sender != address(0), "zero address found");
        owner = _owner;
        worldID = IWorldID(_worldID);
        usdt = IERC20(_usdt);
        supportedTokens[_usdt] = true; // Add USDT as a default supported token
    }

    function createWorldId() external onlyOwner {}

    function transfer(
        address _recipient,
        address _token,
        uint256 _amount
    ) external onlyVerified(msg.sender) onlySupportedToken(_token) {
        require(_recipient != address(0), "Zero address detected");
        IERC20 token = IERC20(_token);
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount > 0, "Transfer amount must be greater than zero");
        require(
            token.transferFrom(msg.sender, _recipient, _amount),
            "Transfer failed"
        );

        recordTransactionHistory(msg.sender, _amount, _token);
    }

    function addSupportedToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        supportedTokens[_token] = true;
    }

    function removeSupportedToken(address _token) external onlyOwner {
        require(supportedTokens[_token], "Token not supported");
        supportedTokens[_token] = false;
    }

    //////////////////////////////////////////////
    //             View Functions              //
    ////////////////////////////////////////////

    function getTransactionHistory(
        address _user
    ) external view returns (Transaction[] memory) {
        return transactions[_user];
    }

    ////////////////////////////////////////////////
    //             Private Function              //
    //////////////////////////////////////////////

    function recordTransactionHistory(
        address _user,
        uint256 _amount,
        address _token
    ) private {
        Transaction memory newTransaction = Transaction({
            amount: _amount,
            token: _token
        });

        transactions[_user].push(newTransaction);
    }
}
