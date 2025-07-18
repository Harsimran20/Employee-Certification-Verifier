// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TransparentProxy {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "No implementation");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Optional: handle plain ETH
    receive() external payable {}
}
