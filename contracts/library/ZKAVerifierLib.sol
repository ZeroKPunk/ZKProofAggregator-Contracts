// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library ZKAVerifierLib {
    // bytes32 proofKey = keccak256(abi.encode(proof, address(this)))
    function fetchProofKey(
        bytes calldata proof
    ) external view returns (bytes32) {
        return keccak256(abi.encode(proof, address(this)));
    }
}
