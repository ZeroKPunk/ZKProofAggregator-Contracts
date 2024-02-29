// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IZKAFactory} from "./interface/IZKAFactory.sol";
import {IZKAVerifier} from "./interface/IZKAVerifier.sol";

contract ZKAFactory is Ownable, IZKAFactory {
    error NotOfficialVerifier();
    VerifierInfo public verifierInfo;
    address public override implZKAVerifier;
    mapping(bytes32 proofKey => uint64 verifyTimestamp)
        public
        override proofInStorage;
    mapping(address => VerifierMeta) public listOfZKAVerifiers;

    modifier onlyVerifier(address _verifier) {
        if (listOfZKAVerifiers[_verifier].deployTimestamp == 0) {
            revert NotOfficialVerifier();
        }
        _;
    }

    constructor() payable Ownable(msg.sender) {}

    function setimplZKAVerifier(
        address _implementation
    ) external override onlyOwner {
        implZKAVerifier = _implementation;
    }

    function proofToStorage(
        bytes32 proofKey
    ) external override onlyVerifier(msg.sender) {
        proofInStorage[proofKey] = uint64(block.timestamp);
    }

    function deployZKAVerifier(
        string memory _zkpVerifierName,
        string memory _url,
        address _deployer,
        address _zkpVerifierAddress
    ) external override returns (address) {
        address _zkVerifier = Clones.cloneDeterministic(
            implZKAVerifier,
            keccak256(abi.encode(address(this), _zkpVerifierName))
        );
        IZKAVerifier(_zkVerifier).initializer(
            address(this),
            _zkpVerifierAddress
        );

        listOfZKAVerifiers[_zkVerifier] = VerifierMeta({
            zkpVerifierName: _zkpVerifierName,
            url: _url,
            deployer: _deployer,
            deployTimestamp: uint64(block.timestamp)
        });
        VerifierInfo memory _verifierInfo = verifierInfo;
        _verifierInfo.verifierNumbers += 1;
        _verifierInfo.latestVerifier = _zkVerifier;
        verifierInfo = _verifierInfo;

        return _zkVerifier;
    }

    function fetchAllZKAVerifiers()
        external
        view
        override
        returns (address[] memory, VerifierMeta[] memory)
    {
        address[] memory _zkVerifierAddresses = new address[](
            verifierInfo.verifierNumbers
        );
        VerifierMeta[] memory _zkVerifierMetas = new VerifierMeta[](
            verifierInfo.verifierNumbers
        );
        for (uint64 i = 0; i < verifierInfo.verifierNumbers; i++) {
            _zkVerifierAddresses[i] = address(this);
            _zkVerifierMetas[i] = listOfZKAVerifiers[address(this)];
        }
        return (_zkVerifierAddresses, _zkVerifierMetas);
    }
}
