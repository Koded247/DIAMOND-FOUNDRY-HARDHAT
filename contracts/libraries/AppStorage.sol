// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// AppStorage.sol
struct AppStorage {
    // Token details
    string name;
    string symbol;
    uint8 decimals; // Standard ERC-20 decimals
    uint256 totalSupply; 

    // Balances and allowances
    mapping(address => uint256) balanceOf;
    mapping(address => mapping(address => uint256)) allowance;

    // Staking-related variables
    uint256 totalStaked; // Total amount of tokens staked across all users
    uint256 stakingRewardRate; // Reward rate per second
    uint256 stakingStartTime; // Start time of staking program
    uint256 stakingEndTime; // End time of staking program

    // User staking information
    mapping(address => uint256) stakedBalance; // Amount of tokens staked by each user
    mapping(address => uint256) lastStakeTime; // Timestamp of user's last stake
    mapping(address => uint256) accumulatedRewards; // Accumulated rewards for each user
    mapping(address => uint256) lastRewardCalculationTime; // Last time rewards were calculated for user
}