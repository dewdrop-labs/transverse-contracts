// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./IWorldID.sol";

contract Wallet {
    address public immutable owner;
    IWorldID public immutable worldID;

    mapping(address => Transaction[]) public transactions;
    mapping(address => mapping(address => uint256)) token_balance;
    mapping(address => bool) public supportedTokens;
    mapping(uint256 => bool) public nullifierHashes;

    struct Transaction {
        uint256 amount;
        address token;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // Modifier to ensure that only users with a valid ZK proof can call the function
    modifier onlyValidProof(bytes calldata _zkProof) {
        {
            (uint256 _root, uint256 _signalHash, uint256 _nullifierHash, uint256 _externalNullifierHash, uint256[8] memory _proof) 
            = abi.decode(_zkProof,(uint256, uint256, uint256, uint256, uint256[8]));
            if (nullifierHashes[_nullifierHash]) revert("Invalid Nullifier");
            worldID.verifyProof(_root, _signalHash, _nullifierHash, _externalNullifierHash,_proof);
            nullifierHashes[_nullifierHash] = true;
        }
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
        supportedTokens[_usdt] = true; // Add USDT as a default supported token
    }

    function transfer(address _recipient, address _token, uint256 _amount, bytes calldata _zkProof)
        external 
        onlyValidProof(_zkProof) 
        onlySupportedToken(_token)
    {
        require(_recipient != address(0), "Zero address detected");
        IERC20 token = IERC20(_token);
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount > 0, "Transfer amount must be greater than zero");
        require(token.transferFrom(msg.sender, _recipient, _amount), "Transfer failed");

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

    function getTransactionHistory(address _user) external view returns (Transaction[] memory) {
        return transactions[_user];
    }

    ////////////////////////////////////////////////
    //             Private Function              //
    //////////////////////////////////////////////

    function recordTransactionHistory(address _user, uint256 _amount, address _token) private {
        Transaction memory newTransaction = Transaction({amount: _amount, token: _token});

        transactions[_user].push(newTransaction);
    }
}
