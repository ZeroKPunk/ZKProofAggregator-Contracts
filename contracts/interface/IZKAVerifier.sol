// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IZKAVerifier {
    function zkpVerify(bytes calldata zkProof) external;

    function ZKAFactory() external view returns (address);

    function ZKVerifier() external view returns (address);

    function initializer(address _ZKAFactory, address _ZKVerifier) external;

    function fetchProofKey(
        bytes calldata proof
    ) external view returns (bytes32);
}
