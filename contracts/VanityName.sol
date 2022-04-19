// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract VanityName is Ownable{
    
    // log to keep record of reserved hashes
    event hashReserved (bytes32 hash, address owner);
    
    // log to keep record of registerd names
    event nameRegistered (string name, address owner);
    
    // log to keep record of fee withdrawal
    event Withdraw(address owner, uint256 amount);

    uint256 private lockingAmount;
    uint256 private lockingPeriod;

    mapping(string => address) private vanityName;
    mapping (address => uint256) private lockedBalance;
    mapping (address => uint256) private lockedDuration;
    mapping (address => string) private lastVanityName;

    mapping(bytes32 => address) private reserved;
    mapping(address => bytes32) private hashMatching;
    mapping(bytes32 => bool) private occupied;

    // default values
    constructor() {
        lockingAmount = 1 ether;
        lockingPeriod = 5 minutes;
    }

    // set locking amount, can be called by the owner of contract only
    function setLockingAmount(uint256 _newAmount) public onlyOwner {
        lockingAmount = _newAmount;
    }

    // get current locking amount
    function getLockingAmount() public view returns (uint256) {
        return lockingAmount;
    }

    // set locking period, can be called by the owner of contract only
    function setLockingPeriod(uint256 _newPeriod) public onlyOwner {
        lockingAmount = _newPeriod;
    }

    // get current locking period
    function getLockingPeriod() public view returns (uint256) {
        return lockingPeriod;
    }

    // get current owner of vanity name
    function getVanityOwner(string memory _vanityName) public view returns (address) {
        address currentOwner = vanityName[_vanityName];
        uint256 expiryTime = lockedDuration[currentOwner];
        if (expiryTime < block.timestamp)
            return address(0);
        else
            return vanityName[_vanityName];
    }

    // get locked balance of specific user
    function getLockedBalance(address _user) public view returns (uint256) {
        return lockedBalance[_user];
    }

    // get duration of locked balance of specific user
    function getLockedDuration(address _user) public view returns (uint256) {
        if (lockedDuration[_user] < block.timestamp)
            return 0;
        else
            return lockedDuration[_user];
    }

    // get last vanity name registered of specific user
    function getLastVanityName(address _user) public view returns (string memory) {
        return lastVanityName[_user];
    }

    // register vanity name
    // name hash should be reserved first to register name
    function registerVanityName(string memory _vanityName) public payable {
        require(lockedBalance[msg.sender] == 0, "Registration amount already deposited");
        require(msg.value == lockingAmount, "Deposited amount is invalid");
        
        bytes32 nameHash = getHash(_vanityName);
        
        require(occupied[nameHash] == false, "Hash Already occupied");
        require(getHashOwner(nameHash) == msg.sender, "Caller has not reserved the name");
        require(hashMatching[msg.sender] == nameHash, "Name is not matched with the reserved Hash");
        require(getVanityOwner(_vanityName) == address(0), "Vanity name is already taken");
        
        occupied[nameHash] = true;
        uint256 lockedTime = block.timestamp + lockingPeriod;
        
        vanityName[_vanityName] = msg.sender;
        lockedBalance[msg.sender] = msg.value;
        lockedDuration[msg.sender] = lockedTime;
        lastVanityName[msg.sender] = _vanityName;
        emit nameRegistered(_vanityName, msg.sender);
    }

    // renew registration of vanity name
    // this can be done if last registered name is available
    function renewRegistration() public {
        require(lockedBalance[msg.sender] == lockingAmount, "Insufficient locked amount");
        require(getVanityOwner(lastVanityName[msg.sender]) == address(0), "Vanity name is taken");

        vanityName[lastVanityName[msg.sender]] = msg.sender;
        lockedDuration[msg.sender] = block.timestamp + lockingPeriod;
        emit nameRegistered(lastVanityName[msg.sender], msg.sender);
    }

    // withdraw the amount of user upon registration duration expire
    function withdraw() public {
        require(lockedBalance[msg.sender] > 0, "Insufficient Amount");
        require(lockedDuration[msg.sender] < block.timestamp, "Locked duration is not completed");
        uint256 withdrawalAmount = lockedBalance[msg.sender];
        payable(msg.sender).transfer(withdrawalAmount);
        emit Withdraw(msg.sender, withdrawalAmount);
    }

    // get current owner of the vanity name hash
    function getHashOwner(bytes32 _hash) public view returns (address) {
        address currentOwner = reserved[_hash];
        if (occupied[_hash] == false)
            return currentOwner;
        else {
            if (lockedDuration[currentOwner] > block.timestamp)
                return currentOwner;          
            else
                return address(0);
        }
    }

    // reserve the hash of vanity name
    function reserveHash(bytes32 _hash) public {
        require(getHashOwner(_hash) == address(0), "Hash is already reserved");
        reserved[_hash] = msg.sender;
        hashMatching[msg.sender] = _hash;
        occupied[_hash] = false;
        emit hashReserved(_hash, msg.sender);
    }

    // get hash of vanity name
    function getHash(string memory _name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

}
