// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IZKAFactory} from "./interface/IZKAFactory.sol";
import {IZKAVerifier} from "./interface/IZKAVerifier.sol";

contract ZKAFactory is Ownable, IZKAFactory {
    error NotOfficialVerifier();
    address public override implZKAVerifier;
    mapping(bytes32 proofKey => uint64 verifyTimestamp)
        public
        override proofInStorage;
    mapping(address => VerifierMeta) public metaZKAVerifiers;
    address[] public verifierAddress;

    modifier onlyVerifier(address _verifier) {
        if (metaZKAVerifiers[_verifier].deployTimestamp == 0) {
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
        emit proofToStorageInfo(proofKey, uint64(block.timestamp));
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

        metaZKAVerifiers[_zkVerifier] = VerifierMeta({
            zkpVerifierName: _zkpVerifierName,
            url: _url,
            deployer: _deployer,
            deployTimestamp: uint64(block.timestamp)
        });
        verifierAddress.push(_zkVerifier);
        emit newZKAVerifierInfo(_zkVerifier, _zkpVerifierName, _url, _deployer);
        return _zkVerifier;
    }

    function fetchAllZKAVerifiers()
        external
        view
        override
        returns (address[] memory, VerifierMeta[] memory)
    {
        uint256 _length = verifierAddress.length;
        address[] memory _verifiers = new address[](_length);
        VerifierMeta[] memory _meta = new VerifierMeta[](_length);

        for (uint256 i = 0; i < _length; i++) {
            _verifiers[i] = verifierAddress[i];
            _meta[i] = metaZKAVerifiers[verifierAddress[i]];
        }
        return (_verifiers, _meta);
    }
}
