// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IverifierMock {
    function verify(bytes calldata _proof) external pure returns (bool);
}

contract VerifierMock is IverifierMock {
    function verify(bytes calldata _proof) external pure returns (bool) {
        (_proof);
        return true;
    }

    function getVerifyCalldata(
        string calldata salt
    ) external pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "verify(bytes)",
                (abi.encode("proof", salt))
            );
    }
}
