// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20.sol";

contract TokenProcessor is Ownable {
    mapping(address => bool) private acceptedTokens;

    constructor(address initialOwner) Ownable(initialOwner) {}

    event TokenWhitelistUpdated(address token, bool isAccepted);

    function addAcceptedToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        acceptedTokens[token] = true;
        emit TokenWhitelistUpdated(token, true);
    }

    function removeAcceptedToken(address token) external onlyOwner {
        require(acceptedTokens[token], "Token not in whitelist");
        acceptedTokens[token] = false;
        emit TokenWhitelistUpdated(token, false);
    }

    function isTokenAccepted(address token) public view returns (bool) {
        return acceptedTokens[token];
    }

    function processTokenTransfer(address token, address from, address to, uint256 amount) external {
        require(isTokenAccepted(token), "Token not accepted");
        require(amount > 0, "Invalid amount");

        bool success = IERC20(token).transferFrom(from, to, amount);
        require(success, "Token transfer failed");
    }
}
