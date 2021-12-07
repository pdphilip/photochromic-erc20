// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lockv2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract LockFactory is Ownable{
    using SafeERC20 for IERC20;
    
    struct Beneficiary {
       LockToken lock;
       uint256 exists;
    }
    
    
    mapping(address => Beneficiary) private _beneficiaries;
    
    uint256 private immutable _numReleaseDays;
    uint256 private immutable _releaseInterval;

    // ERC20 basic token contract being held
    IERC20 private immutable _token;
    
    constructor(IERC20 token_, uint256 numReleaseDays_, uint256 releaseInterval){
        _token = token_;
        _numReleaseDays = numReleaseDays_;
        _releaseInterval = releaseInterval;
    }
    
    /**
     * create a new lock contract with address_ as the benificiary
     */
    function addLock(address address_, uint256 numTokens) public onlyOwner { 
        require(_beneficiaries[address_].exists==0); //make sure beneficiary doesn't exist
        require(_token.balanceOf(address(this))>numTokens);
        _beneficiaries[address_].lock = new LockToken(_token,address_,_numReleaseDays,_releaseInterval);
        _beneficiaries[address_].exists = 1;
        _token.safeTransfer(address(_beneficiaries[address_].lock), numTokens);
    }
    
    /**
     * @return the lock contract for a given benificiary
     */
    function getLock(address address_) public view returns (LockToken){
        require(_beneficiaries[address_].exists>0);
        return _beneficiaries[address_].lock;
    }
    
}