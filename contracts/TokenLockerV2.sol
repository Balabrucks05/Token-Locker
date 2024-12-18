//SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

//Import the original TokenLocker Contract
import "./TokenLocker.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TokenLockerV2 is OwnableUpgradeable, TokenLocker {

    event LockExtended(uint256 lockId, uint256 newUnlockTime);


    //Extend to extend Lock period, only Callable by the admin
    function extendLockPeriod(uint256 lockId, uint256 additionalTime) public onlyOwner {
        require(lockId < locks.length, "Invalid Lock ID");
        require(additionalTime > 0, "Additional Time must be greater than 0");

        Lock storage lock = locks[lockId];

        require(lock.endTime > block.timestamp, "Lock period has ended");

        //Extend the unlock Time
        lock.endTime += additionalTime;

        emit LockExtended(lockId, lock.endTime);
    }

    //Initialize the contract (for Upgradeable functionality)
    function initialize(address tokenAddress) public initializer{
        __Ownable_init(); //Initialize the Ownable functinality
    }
}