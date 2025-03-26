// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct AppStorage {
  
    string name;
    string symbol;
    uint8 decimals; 
    uint256 totalSupply; 

    
    mapping(address => uint256) balanceOf;
    mapping(address => mapping(address => uint256)) allowance;

    // Staking variables
    uint256 totalStaked; 
    uint256 stakingRewardRate; 
    uint256 stakingStartTime; 
    uint256 stakingEndTime; 

    // User staking information
    mapping(address => uint256) stakedBalance; 
    mapping(address => uint256) lastStakeTime; 
    mapping(address => uint256) accumulatedRewards; 
    mapping(address => uint256) lastRewardCalculationTime;
}