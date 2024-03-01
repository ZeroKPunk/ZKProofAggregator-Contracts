// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ISPVVerifier {
    function verify(bytes calldata _proof) external returns (bool);

    function setVerifier(address _verifier) external;

    function spvVerifierImpl() external view returns (address);

    function state() external view returns (bytes32);

    function owner() external view returns (address);

    function syncState(bytes32 _newState) external;
}
