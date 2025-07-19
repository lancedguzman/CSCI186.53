// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

struct Patent {
    uint patentID;
    address owner;
    string name;
    uint256 dateFiled; // Declares when it was approved
    uint256 dateExpiry; // Declares when it will expire
    bool registered;
}

struct Copyright {
    uint copyrightID;
    address owner;
    string name;
    uint256 dateFiled; // Declares when it was approved
    uint256 dateExpiry; // Declares when it will expire
    bool registered;
}

contract PatentSystem {
    address internal admin;

    uint public registration_fee = 1000000 wei;
    uint public maintenance_fee = 50000 wei;
    uint public transfer_fee = 50000 wei;
    uint public adminBalance;

    mapping(address => uint[]) public registeredPatent;
    mapping(address => uint[]) public registeredCopyright;
    mapping(address => bool) public approvedPatent;
    mapping(address => bool) public approvedCopyright;
    Patent[] public listedPatents;
    Copyright[] public listedCopyrights;

    event PatentRegistered(address indexed owner, uint indexed patentID, string name, uint256 dateFiled);
    event CopyrightRegistered(address indexed owner, uint indexed copyrightID, string name, uint256 dateFiled);

    // @notice Modifier that checks if you are the admin.
    modifier isAdmin() {
        require(msg.sender == admin, "Only admin can access this.");
        _;
    }

    // @notice Modifier that checks if you are not the admin.
    modifier isNotAdmin() {
        require(msg.sender != admin, "You are the admin.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // @notice Modifer to check if patent is expired.
    modifier notExpiredPatent(uint patentID) {
        require(patentID < listedPatents.length, "Invalid patent ID");
        require(block.timestamp <= listedPatents[patentID].dateExpiry, "Patent is expired.");
        _;
    }

    // @notice Modifier to check if copyright is expired.
    modifier notExpiredCopyright(uint copyrightID) {
        require(copyrightID < listedCopyrights.length, "Invalid copyright ID");
        require(block.timestamp <= listedCopyrights[copyrightID].dateExpiry, "Copyright is expired.");
        _;
    }

    // @notice Function to register a patent.
    function registerPatent(string memory _name) public {
        require(bytes(_name).length > 0, "Patent name is required.");
        uint256 newPatentID = listedPatents.length;
        uint256 currentTime = block.timestamp;

        Patent memory newPatent = Patent({
            patentID: newPatentID,
            owner: msg.sender,
            name: _name,
            dateFiled: currentTime,
            dateExpiry: currentTime + 2 minutes, // test value
            registered: true
        });

        listedPatents.push(newPatent);
        registeredPatent[msg.sender].push(newPatentID);
        approvedPatent[msg.sender] = true;

        emit PatentRegistered(msg.sender, newPatentID, _name, currentTime);
    }

    // @notice Function to pay registration fee.
    function payPatentRegistration(uint patentID) external payable notExpiredPatent(patentID) {
        require(msg.sender == listedPatents[patentID].owner, "Not your patent.");
        require(msg.value == maintenance_fee, "Incorrect maintenance amount");
        adminBalance += msg.value;
    }

    // @notice Function to pay maintenance fee.
    function paymaintenance(uint patentID) external payable notExpiredPatent(patentID) {
        require(msg.sender == listedPatents[patentID].owner, "Not your patent.");
        require(msg.value == maintenance_fee, "Incorrect maintenance amount");
        require(admin != address(0), "Admin isn't set.");
        adminBalance += msg.value;
    }

    // @notice Function to transfer patent and pay transfer fee.
    function transferPatent(uint _patentID, address newOwner) external payable notExpiredPatent (_patentID) {
        Patent storage patent = listedPatents[_patentID];
        require(patent.owner == msg.sender, "You do not own this patent");
        require(newOwner != address(0), "New owner cannot be zero address");
        require(msg.value == transfer_fee, "Incorrect transfer fee");

        uint[] storage senderPatents = registeredPatent[msg.sender];
        for (uint i = 0; i < senderPatents.length; i++) {
            if (senderPatents[i] == _patentID) {
                senderPatents[i] = senderPatents[senderPatents.length - 1];
                senderPatents.pop();
                break;
            }
        }
        patent.owner = newOwner;
        registeredPatent[newOwner].push(_patentID);
        adminBalance += msg.value;
    }

    // @notice Function to deactivate expired patents.
    function deactiveExpiredPatent() external isAdmin {
        for (uint i = 0; i < listedPatents.length; i++) {
            if (listedPatents[i].registered && block.timestamp > listedPatents[i].dateExpiry) {
                listedPatents[i].registered = false;
            }
        }
    }

    // @notice returns if patent is expired.
    function isPatentExpired(uint patentID) public view returns (bool) {
        require(patentID < listedPatents.length, "Invalid ID");
        return block.timestamp > listedPatents[patentID].dateExpiry;
    }

    // @notice views the patent of the user.
    function viewMyPatents() external view returns (uint[] memory) {
        return registeredPatent[msg.sender];
    }

    // @notice views all the patents.
    function viewAllPatents() external view returns (Patent[] memory) {
        return listedPatents;
    }

    // @notice Function to register copyright.
    function registerCopyright(string memory _name) public {
        require(bytes(_name).length > 0, "Copyright name is required.");
        uint256 newCopyrightID = listedCopyrights.length;
        uint256 currentTime = block.timestamp;

        Copyright memory newCopyright = Copyright({
            copyrightID: newCopyrightID,
            owner: msg.sender,
            name: _name,
            dateFiled: currentTime,
            dateExpiry: currentTime + 1 minutes, // test value
            registered: true
        });

        listedCopyrights.push(newCopyright);
        registeredCopyright[msg.sender].push(newCopyrightID);
        approvedCopyright[msg.sender] = true;

        emit CopyrightRegistered(msg.sender, newCopyrightID, _name, currentTime);
    }

    // @notice Function to pay registration fee.
    function payCopyrightRegistration(uint copyrightID) external payable notExpiredCopyright (copyrightID) {
        require(listedCopyrights[copyrightID].owner == msg.sender, "This is NOT your copyright");
        require(msg.value == registration_fee, "Incorrect registration amount");
        adminBalance += msg.value;
    }

    // @notice Function to tranfer copyright and pay transfer fee.
    function transferCopyright(uint _copyrightID, address newOwner) external payable notExpiredCopyright (_copyrightID) {
        Copyright storage copyright = listedCopyrights[_copyrightID];
        require(copyright.owner == msg.sender, "You do not own this copyright");
        require(newOwner != address(0), "New owner cannot be zero address");
        require(msg.value == transfer_fee, "Incorrect transfer fee");

        uint[] storage senderCopyrights = registeredCopyright[msg.sender];
        for (uint i = 0; i < senderCopyrights.length; i++) {
            if (senderCopyrights[i] == _copyrightID) {
                senderCopyrights[i] = senderCopyrights[senderCopyrights.length - 1];
                senderCopyrights.pop();
                break;
            }
        }
        copyright.owner = newOwner;
        registeredCopyright[newOwner].push(_copyrightID);
        adminBalance += msg.value;
    }

    // @notice Function to deactivate expired copyrights.
    function deactivateExpiredCopyrights() external isAdmin {
        for (uint i = 0; i < listedCopyrights.length; i++) {
            if (listedCopyrights[i].registered && block.timestamp > listedCopyrights[i].dateExpiry) {
                listedCopyrights[i].registered = false;
            }
        }
    }

    // @notice checks if copyright is expired.
    function isCopyrightExpired(uint copyrightID) public view returns (bool) {
        require(copyrightID < listedCopyrights.length, "Invalid ID");
        return block.timestamp > listedCopyrights[copyrightID].dateExpiry;
    }

    // @notice views the copyrights of the user.
    function viewMyCopyrights() external view returns (uint[] memory) {
        return registeredCopyright[msg.sender];
    }

    // notice views all the copyrights.
    function viewAllCopyrights() external view returns (Copyright[] memory) {
        return listedCopyrights;
    }

    // @notice Function to get admin balance.
    function getAdminBalance() public view returns (uint) {
        return adminBalance;
    }

    // @notice Function to withdraw admin balance.
    function withdraw() external isAdmin {
        payable(admin).transfer(adminBalance);
        adminBalance = 0;
    }
}