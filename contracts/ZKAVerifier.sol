// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IZKAVerifier} from "./interface/IZKAVerifier.sol";
import {IZKAFactory} from "./interface/IZKAFactory.sol";

contract ZKAVerifier is IZKAVerifier {
    error AlreadyInitialized();
    address public override ZKAFactory;
    address public override ZKVerifier;

    constructor() {}

    function initializer(address _ZKAFactory, address _ZKVerifier) external {
        if (ZKAFactory != address(0) || ZKVerifier != address(0)) {
            revert AlreadyInitialized();
        }
        ZKAFactory = _ZKAFactory;
        ZKVerifier = _ZKVerifier;
    }

    function zkpVerify(
        bytes calldata zkProof
    ) external override returns (bool) {
        (bool success, ) = ZKVerifier.call(zkProof);
        IZKAFactory(ZKAFactory).proofToStorage(fetchProofKey(zkProof));
        return success;
    }

    function fetchProofKey(
        bytes calldata proof
    ) internal view returns (bytes32) {
        return keccak256(abi.encode(proof, address(this)));
    }
}
