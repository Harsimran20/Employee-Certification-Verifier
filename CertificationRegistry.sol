// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RoleManager.sol";
import "./CertificationVerifier.sol";

contract CertificationRegistry {
    struct Certification {
        string employeeName;
        string certTitle;
        string certHash; // IPFS or hash of JSON file
        address issuedBy;
        uint256 issuedAt;
        bool revoked;
    }

    RoleManager public roles;
    CertificationVerifier public verifier;

    mapping(bytes32 => Certification) public certifications;

    event CertificationIssued(bytes32 indexed id, string employeeName, string certTitle);
    event CertificationRevoked(bytes32 indexed id);

    constructor(address roleManager, address verifierContract) {
        roles = RoleManager(roleManager);
        verifier = CertificationVerifier(verifierContract);
    }

    function issueCertification(string memory employeeName, string memory certTitle, string memory certHash) external {
        require(roles.certifyingAuthorities(msg.sender), "Not authorized issuer");

        bytes32 id = keccak256(abi.encodePacked(employeeName, certTitle, certHash, msg.sender));
        require(certifications[id].issuedAt == 0, "Certification already exists");

        certifications[id] = Certification({
            employeeName: employeeName,
            certTitle: certTitle,
            certHash: certHash,
            issuedBy: msg.sender,
            issuedAt: block.timestamp,
            revoked: false
        });

        verifier.registerHash(certHash);
        emit CertificationIssued(id, employeeName, certTitle);
    }

    function revokeCertification(bytes32 id) external {
        Certification storage cert = certifications[id];
        require(cert.issuedBy == msg.sender, "Only issuer can revoke");
        require(cert.issuedAt != 0 && !cert.revoked, "Invalid certification");

        cert.revoked = true;
        verifier.revokeHash(cert.certHash);
        emit CertificationRevoked(id);
    }

    function getCertification(bytes32 id) external view returns (Certification memory) {
        return certifications[id];
    }

    function isValid(bytes32 id) external view returns (bool) {
        Certification memory cert = certifications[id];
        return cert.issuedAt != 0 && !cert.revoked && verifier.verifyHash(cert.certHash);
    }
}
