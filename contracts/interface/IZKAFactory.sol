// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IZKAFactory {
    struct VerifierMeta {
        string zkpVerifierName;
        string url;
        address deployer;
        uint64 deployTimestamp;
    }

    function verifierAddress() external view returns (address[]);

    function proofInStorage(bytes32 proofKey) external view returns (uint64);

    function proofToStorage(bytes32 proofKey) external;

    function deployZKAVerifier(
        string memory _zkpVerifierName,
        string memory _url,
        address _deployer,
        address _zkpVerifierAddress
    ) external returns (address);

    function setimplZKAVerifier(address _implementation) external;

    function implZKAVerifier() external view returns (address);

    function fetchAllZKAVerifiers()
        external
        view
        returns (address[] memory, VerifierMeta[] memory);
}
