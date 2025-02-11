// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/IWorldID.sol";

contract MockWorldID is IWorldID {
    mapping(bytes32 => bool) private _validProofs;

    function verifyProof(
        uint256 root,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) external view override {
        bytes32 proofHash = keccak256(
            abi.encode(
                root,
                signalHash,
                nullifierHash,
                externalNullifierHash,
                proof
            )
        );
        if (!_validProofs[proofHash]) revert("NonExistentRoot or ExpiredRoot");
    }

    function generateZkProof(uint256 seed, bool set) external returns (bytes memory zkProof) {
        uint256 root = uint256(keccak256(abi.encodePacked(seed, "root")));
        uint256 signalHash = uint256(keccak256(abi.encodePacked(seed, "signalHash")));
        uint256 nullifierHash = uint256(keccak256(abi.encodePacked(seed, "nullifierHash")));
        uint256 externalNullifierHash = uint256(keccak256(abi.encodePacked(seed, "externalNullifierHash")));
        uint256[8] memory proof;
        for (uint256 i = 0; i < 8; i++) {
            proof[i] = uint256(keccak256(abi.encodePacked(seed, i)));
        }
        if(set) {
            bytes32 proofHash = keccak256(
            abi.encode(
                root,
                signalHash,
                nullifierHash,
                externalNullifierHash,
                proof
            )
            );
            _validProofs[proofHash] = true;
        }
        return abi.encode(root, signalHash, nullifierHash, externalNullifierHash, proof);
    }
}
