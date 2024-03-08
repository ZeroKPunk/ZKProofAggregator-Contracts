// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ISPVVerifier} from "./interface/ISPVVerifier.sol";

contract SPVVerifier is ISPVVerifier {
    error NotOwner();
    bytes32 public override state;
    address public override spvVerifierImpl;
    address public override owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function verify(bytes calldata _proof) external override returns (bool) {
        (bool success, ) = spvVerifierImpl.call(_proof);
        return success;
    }

    function setVerifier(address _verifier) public override onlyOwner {
        spvVerifierImpl = _verifier;
    }

    function syncState(bytes32 _newState) external override onlyOwner {
        state = _newState;
    }
}
