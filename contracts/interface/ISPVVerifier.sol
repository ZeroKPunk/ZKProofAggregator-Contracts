// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ISPVVerifier {
    function verify(bytes32[] memory proof, bytes32 leaf) external;

    function setVerifier(address _verifier) external;

    function spvVerifierImpl() external view returns (address);

    function merkleRoot() external view returns (bytes32);

    function owner() external view returns (address);

    function syncState(bytes32 _newState) external;

    event VerifySuccess(address indexed verifier, bytes32 proofHash);
}
