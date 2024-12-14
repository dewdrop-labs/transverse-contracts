// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Wallet.sol";

contract WalletFactory {
    Wallet[] wallets;

    function createWallet( address _worldID, address _usdt) external returns (Wallet newWallet_, uint256 length_) {
        newWallet_ = new Wallet(msg.sender , _worldID,  _usdt);

        wallets.push(newWallet_);

        length_ = wallets.length;
    }

    function getWalletClones() external view returns(Wallet[] memory) {
        return wallets;
    }
}
