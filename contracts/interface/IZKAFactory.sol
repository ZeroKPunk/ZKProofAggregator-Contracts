// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IZKAFactory {
    struct VerifierMeta {
        string zkpVerifierName;
        string url;
        address deployer;
        uint64 deployTimestamp;
    }

    /// @dev to check if the proof is already in storage
    /// @param proofKey the key of the proof, keccak256(abi.encodePack(proof, ZKAVerifierAddress))
    /// @return the save-timestamp of proof
    function proofInStorage(bytes32 proofKey) external view returns (uint64);

    /// @dev only called by the ZKAVerifier contract
    /// @param proofKey the key of the proof, keccak256(abi.encodePack(proof, ZKAVerifierAddress))
    function proofToStorage(bytes32 proofKey) external;

    /// @dev deploy a new ZKAVerifier contract
    /// @param _zkpVerifierName the name of the ZKAVerifier
    /// @param _url the url of the ZKAVerifier
    /// @param _deployer the deployer of the ZKAVerifier
    /// @param _zkpVerifierAddress the address of the zkpVerifier
    /// @return the address of the new ZKAVerifier contract
    function deployZKAVerifier(
        string memory _zkpVerifierName,
        string memory _url,
        address _deployer,
        address _zkpVerifierAddress
    ) external returns (address);

    /// @dev only called by the owner, set the implementation of ZKAVerifier
    /// @param _implementation the address of the implementation
    function setimplZKAVerifier(address _implementation) external;

    /// @dev get the implementation of ZKAVerifier
    function implZKAVerifier() external view returns (address);

    /// @dev get all the ZKAVerifiers meta data
    function fetchAllZKAVerifiers()
        external
        view
        returns (address[] memory, VerifierMeta[] memory);
}
