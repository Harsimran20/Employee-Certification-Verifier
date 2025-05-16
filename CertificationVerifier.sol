// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificationVerifier {
    address public controller;

    mapping(string => bool) public validHashes;

    constructor() {
        controller = msg.sender;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Unauthorized");
        _;
    }

    function registerHash(string memory certHash) external onlyController {
        validHashes[certHash] = true;
    }

    function revokeHash(string memory certHash) external onlyController {
        validHashes[certHash] = false;
    }

    function verifyHash(string memory certHash) external view returns (bool) {
        return validHashes[certHash];
    }
}
