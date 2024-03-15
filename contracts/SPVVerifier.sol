// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface ISPVVerifier {
    function verify(
        bytes32[] memory proof,
        bytes32 leaf,
        bytes calldata zkProof
    ) external;

    function setVerifier(address _verifier) external;

    function spvVerifierImpl() external view returns (address);

    function merkleRoot() external view returns (bytes32);

    function owner() external view returns (address);

    function syncRoot(bytes32 _newRoot) external;

    event VerifySuccess(address indexed verifier, bytes32 proofHash);
}

contract SPVVerifier is ISPVVerifier {
    error NotOwner();
    error VerifyError();
    using MerkleProof for bytes32[];
    bytes32 public override merkleRoot;
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

    function verify(
        bytes32[] memory proof,
        bytes32 leaf,
        bytes calldata zkProof
    ) external override {
        bool mptSuccess = proof.verify(merkleRoot, leaf);
        (bool cirSuccess, ) = spvVerifierImpl.call(zkProof);
        if (!mptSuccess || !cirSuccess) {
            revert VerifyError();
        }

        emit VerifySuccess(msg.sender, leaf);
    }

    function setVerifier(address _verifier) public override onlyOwner {
        spvVerifierImpl = _verifier;
    }

    function syncRoot(bytes32 _newRoot) external override onlyOwner {
        merkleRoot = _newRoot;
    }
}
