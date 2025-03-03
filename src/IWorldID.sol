// SPDX-License-Identifier: MIT

// IWorldID.sol
pragma solidity ^0.8.0;

interface IWorldID {
    /// @notice Verifies a WorldID zero knowledge proof.
    /// @dev Note that a double-signaling check is not included here, and should be carried by the
    ///      caller.
    /// @dev It is highly recommended that the implementation is restricted to `view` if possible.
    ///
    /// @param root The root of the Merkle tree
    /// @param signalHash A keccak256 hash of the Semaphore signal
    /// @param nullifierHash The nullifier hash
    /// @param externalNullifierHash A keccak256 hash of the external nullifier
    /// @param proof The zero-knowledge proof
    ///
    /// @custom:reverts string If the `proof` is invalid.
    function verifyProof(
        uint256 root,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) external view;
}
