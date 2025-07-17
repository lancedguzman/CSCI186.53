// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

struct Patent {
    uint patentID;
    address owner;
    string name;
    string description;
    string ipfsHash;
    uint256 dateApproved; // Declares when it was approved
    uint256 dateExpiry; // Declares when it will expire
    bool active;
    bool registered;
}

struct Copyright {
    uint copyrightID;
    address owner;
    string name;
    string description;
    uint256 dateApproved; // Declares when it was approved
    uint256 dateExpiry; // Declares when it will expire
    bool active;
    bool registered;
}

contract PatentSystem {
    address internal owner;

    uint public registration_fee = 1000000 wei;
    uint public renewal_fee = 50000 wei;
    uint public transfer_fee = 50000 wei;

    mapping(address => bool) public register;

    // @notice Modifier that checks if you are the owner.
    modifier isOwner() {
        require(msg.sender == owner, "You are the owner.");
        _;
    }

    // @notice Modifier that checks if you are not the owner.
    modifier isNotOwner() {
        require(msg.sender != owner, "Only owner can access this.");
        _;
    }

    // @notice Modifier that checks if your patent is registered.
    modifier isRegistered() {
        require(register[msg.sender], "Your patent is registered.");
        _;
    }

    // @notice Modifier that checks if your patent is registered.
    modifier isNotRegistered() {
        require(!register[msg.sender], "Your patent is not registered.");
        _;
    }

    // @notice Function to register a patent.
    function registerIP(uint _patentID, address _owner, string memory _name, uint256 _dateApproved) public payable {
        // TO-DO
    }

    // @notice Function to renew a patent after a given amount of time.
    function renewPatent(uint _patentID, address _owner, uint256 _dateApproved, uint256 _dateExpiry) public payable {
        // TO-DO
    }

    // @notice Function to transfer a patent to another owner.
    function transferIP() public {
        // TO-DO
    }
}

contract PatentContract {
    
}