// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RoleManager {
    address public admin;

    mapping(address => bool) public certifyingAuthorities;
    mapping(address => bool) public employers;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    function setCertifyingAuthority(address ca, bool status) external onlyAdmin {
        certifyingAuthorities[ca] = status;
    }

    function setEmployer(address employer, bool status) external onlyAdmin {
        employers[employer] = status;
    }

    function isCertifyingAuthority(address ca) external view returns (bool) {
        return certifyingAuthorities[ca];
    }

    function isEmployer(address employer) external view returns (bool) {
        return employers[employer];
    }
}
