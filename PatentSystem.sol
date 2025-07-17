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
    uint public maintanence_fee = 50000 wei;
    uint public transfer_fee = 50000 wei;
    uint public adminBalance;

    mapping(address => uint[]) public register;
    mapping(address => bool) public approvedPatent;
    mapping(address => bool) public approvedCopyright;
    Patent[] public listedPatents;
    Copyright[] public listedCopyrights;

    event PatentRegistered(address indexed owner, uint indexed patentID, string name, uint256 dateFiled);
    event CopyrightRegistered(address indexed owner, uint indexed copyrightID, string name, uint256 dateFiled);

    // @notice Modifier that checks if you are the admin.
    modifier isAdmin() {
        require(msg.sender == admin, "You are the admin.");
        _;
    }

    // @notice Modifier that checks if you are not the admin.
    modifier isNotAdmin() {
        require(msg.sender != admin, "Only admin can access this.");
        _;
    }

    // @notice Modifier that checks if your patent is registered.
    modifier isRegistered() {
        require(register[msg.sender].length > 0, "Your intellectual property is NOT registered.");
        _;
    }

    // @notice Modifier that checks if your patent is registered.
    modifier isNotRegistered() {
        require(register[msg.sender].length == 0, "Your intellectual property is already registered.");
        _;
    }

    constructor() {
        admin = msg.sender;
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
        register[msg.sender].push(newPatentID);
        approvedPatent[msg.sender] = true;

        emit PatentRegistered(msg.sender, newPatentID, _name, currentTime);
    }

    // @notice Function to pay registration for patent.
    function payPatentRegistration(uint patentID) external payable isRegistered {
        require(patentID < listedPatents.length, "Invalid patent ID");
        require(listedPatents[patentID].owner == msg.sender, "This is NOT your patent.");
        require(msg.value == registration_fee, "Incorrect registration amount");
        require(admin != address(0), "Admin isn't set.");

        adminBalance += msg.value;
    }

    // @notice Function to renew a patent after a given amount of time.
    function payMaintanence() external payable isRegistered {
        require(msg.value == maintanence_fee, "Incorrect maintanence amount");
        require(admin != address(0), "Admin isn't set.");

        adminBalance += msg.value;
    }

    // @notice Function to transfer a patent to another owner.
    function transferPatent(uint _patentID, address newOwner) external payable{
        require(_patentID < listedPatents.length, "Invalid patent ID");
        Patent storage patent = listedPatents[_patentID];
        require(patent.owner == msg.sender, "You do not own this patent");
        require(newOwner != address(0), "New owner cannot be zero address");
        require(msg.value == transfer_fee, "Incorrect transfer fee");
        require(admin != address(0), "Admin address not set");

        uint[] storage currentOwnerPatents = register[msg.sender];
        for (uint i = 0; i < currentOwnerPatents.length; i++) {
            if (currentOwnerPatents[i] == _patentID) {
                currentOwnerPatents[i] = currentOwnerPatents[currentOwnerPatents.length - 1];
                currentOwnerPatents.pop();
                break;
            }
        }

        patent.owner = newOwner;
        register[newOwner].push(_patentID);
        adminBalance += msg.value;
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
        register[msg.sender].push(newCopyrightID);
        approvedCopyright[msg.sender] = true;

        emit CopyrightRegistered(msg.sender, newCopyrightID, _name, currentTime);
    }

    function payCopyrightRegistration(uint copyrightID) external payable {
        // TO-DO: checks if copyright is registered, then pays balance.
    }

    function transferCopyright(uint _copyrightID, address newOwner) external payable {
        // TO-DO: transfers to the next owner, then pays the transfer fee to admin.
    }

    // @notice Function to get admin balance.
    function getAdminBalance() public view returns (uint) {
        return adminBalance;
    }
}

// contract PatentContract {
//     address private parent;
//     address public owner;
//     uint public patentID;
//     uint256 public dateFiled;
//     uint256 public dateExpiry; 
//     bool public registered;

//     receive() external payable{}

//     constructor(address _parent, address _owner, uint _patentID) {
//         parent = _parent;
//         owner = _owner;
//         patentID = _patentID;
//     }
// }

// contract CopyrightContract {
//     uint private duration = 30 seconds; // For testing
// }