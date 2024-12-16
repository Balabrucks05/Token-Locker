//SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenLocker is ReentrancyGuard, Ownable{
    using SafeERC20 for IERC20;

    struct Lock{
        address tokenAddress;       //Address of the ERC20 token
        uint256 amount;             //Amount of the tokens lcoked
        uint256 percentage;         //Percentage of the tokens locked(1 - 100)
        uint256 startTime;          //Lock start timestamp
        uint256 endTime;            //Lock end timestamp
        string title;               //Title of the lock
        string description;         //Description of the lock
        bool isActive;              //Whether the lock is still active
        address owner;              //Owner of the locked tokens
    }

    //Array to store all locks
    Lock[] public locks;

    //Mapping from address to their lock indices
    mapping(address => uint256[]) public userLockIndices;

    //Events
    event TokensLocked(
        uint256 indexed lockID,
        address indexed token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        address indexed owner
    );

    event TokensUnlocked(
        uint256 indexed lockID,
        address indexed token,
        address indexed owner,
        uint256 amount
    );
    
    event EmergencyWithdraw(
        uint256 indexed lockID,
        address indexed token,
        address indexed owner,
        uint256 amount
    );

    constructor()  {}

    /**
    * @dev Creates a new token lock
    * @param tokenAddress The address of the token to lock
    * @param amount The amount of the tokens to lock
    * @param percentage The percentage of the tokens to lock (1 - 100)
    * @param startTime The timestamp when the lock starts
    * @param endTime The timestamp when the lock ends
    * @param description The description of the lock
    * @return lockId The index of the created Lock
    */

     function createLock(
        address tokenAddress,
        uint256 amount, 
        uint256 percentage,
        uint256 startTime,
        uint256 endTime,
        string memory title,
        string memory description
     ) external nonReentrant returns (uint256) {
        require(tokenAddress != address(0), "Invalid Token Address");
        require(amount > 0, "Amount must be greater than 0");
        require(percentage >= 0 && percentage <= 100, "Invalid Percentage");
        require(startTime >= block.timestamp, "Start Time must be in the future");
        require(endTime > startTime, "End time must be after the start time");
        require(bytes(title).length > 0, "Title cannot be empty");

        //Transfer tokens to this contract
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        //Create new Lock
        Lock memory newLock = Lock({
            tokenAddress: tokenAddress,
            amount: amount,
            percentage: percentage,
            startTime: startTime,
            endTime: endTime,
            title: title,
            description: description,
            isActive: true,
            owner: msg.sender
        });

        //Add lock to arrary and get index
        uint256 lockId = locks.length;
        locks.push(newLock);

        //Add lock index to the user's locks
        userLockIndices[msg.sender].push(lockId);

        //Emits the locked tokens
        emit TokensLocked(lockId, tokenAddress, amount, startTime, endTime, msg.sender);
        return lockId;
     }

     /**
     * @dev Unlocks tokens if the lock period has ended
     * @param lockId The index of the lock to unlock
     */

     function unlock(uint256 lockId) external nonReentrant{
        require(lockId < locks.length, "Invalid Lock ID");
        Lock storage lock = locks[lockId];

        require(lock.owner == msg.sender, "Not the lock owner");
        require(lock.isActive, "Lock is not Active");
        require(block.timestamp >= lock.endTime, "Lock period not ended");

        lock.isActive = false;
        IERC20(lock.tokenAddress).safeTransfer(msg.sender, lock.amount);

        emit TokensUnlocked(lockId, lock.tokenAddress, msg.sender, lock.amount);

     }

     /**
     * @dev Emergency Withdraw of locked tokens, deducting 20% as penalty
     * @param lockId The index of the lock to withdraw from
    */
    function emergencyWithdraw(uint256 lockId) external nonReentrant {
        require(lockId < locks.length, "Invalid lock ID");
        Lock storage lock = locks[lockId];

        require(lock.owner == msg.sender, "Not the lock Owner");
        require(lock.isActive, "Lock is not Active");

        uint256 penaltyAmount = (lock.amount * 20) / 100; //20% Penalty
        uint256 amountToWithdraw = lock.amount - penaltyAmount;

        lock.isActive = false;

        //Transfer penalty amount to the contract owner
        IERC20(lock.tokenAddress).safeTransfer(owner(), penaltyAmount);

        //Transfer remaining tokens to lock owner
        IERC20(lock.tokenAddress).safeTransfer(msg.sender, amountToWithdraw);

        //Emit the EmergencyWithdraw event
        emit EmergencyWithdraw(lockId, lock.tokenAddress, msg.sender, amountToWithdraw);
    }

    /**
    * @dev Returns all locks for a specific user
    * @param user The address of the user
    * @return Array of Lock structs
    */

    function getUserLocks(address user) external view returns (Lock[] memory) {
        uint256[] memory indices = userLockIndices[user];
        Lock[] memory userLocks = new Lock[](indices.length);

        for (uint256 i = 0; i < indices.length; i++){
            userLocks[i] = locks[indices[i]];
        }
        return userLocks;
    }
     
    /**
    * @dev Returns the total number of locks created
    */
    function getTotalLocks() public view returns(uint256){
        return locks.length;
    }

    /**
    * @dev Returns the number of locks for a specific user
    * @param user The address of the user
    */
    function getUserLockCount(address user) external view returns(uint256) {
        return userLockIndices[user].length;
    }

    /**
    * @dev checks if a lock is still active
    * @param lockId The index of the lock
    * @return bool True if the lock is Active, otherwise false
    */
    function isLockActive(uint256 lockId) external view returns(bool) {
        require(lockId < locks.length, "Invalid lock ID");
        return locks[lockId].isActive;
    }
}
