// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../libraries/AppStorage.sol";

contract StakingFacet {
    AppStorage internal storex;

    // Events for staking operations
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);

    // Stake tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(storex.balanceOf[msg.sender] >= _amount, "Insufficient balance");

        // Update user's staked balance
        storex.stakedBalance[msg.sender] += _amount;
        storex.totalStaked += _amount;

        // Update user's token balance
        storex.balanceOf[msg.sender] -= _amount;

        // Update last stake time and reward calculation time
        storex.lastStakeTime[msg.sender] = block.timestamp;
        storex.lastRewardCalculationTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, _amount);
    }

    // Unstake tokens
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Cannot unstake 0 tokens");
        require(storex.stakedBalance[msg.sender] >= _amount, "Insufficient staked balance");

        // Calculate and distribute any pending rewards
        _calculateRewards(msg.sender);

        // Update user's staked balance
        storex.stakedBalance[msg.sender] -= _amount;
        storex.totalStaked -= _amount;

        // Return tokens to user's balance
        storex.balanceOf[msg.sender] += _amount;

        emit Unstaked(msg.sender, _amount);
    }

    // Claim accumulated rewards
    function claimRewards() external {
        _calculateRewards(msg.sender);
    }

    // Internal function to calculate rewards
    function _calculateRewards(address _user) internal {
        // Check if staking is active
        require(block.timestamp >= storex.stakingStartTime && 
                block.timestamp <= storex.stakingEndTime, 
                "Staking is not active");

        // Calculate time elapsed since last reward calculation
        uint256 timeElapsed = block.timestamp - storex.lastRewardCalculationTime[_user];
        
        // Calculate rewards
        uint256 pendingRewards = (storex.stakedBalance[_user] * 
                                  storex.stakingRewardRate * 
                                  timeElapsed) / 1e18;

        // Update accumulated rewards
        storex.accumulatedRewards[_user] += pendingRewards;

        // Update last reward calculation time
        storex.lastRewardCalculationTime[_user] = block.timestamp;

        // Transfer rewards if any
        if (pendingRewards > 0) {
            // Mint or transfer rewards (adjust based on your tokenomics)
            // For this example, we'll assume minting new tokens
            storex.balanceOf[_user] += pendingRewards;
            storex.totalSupply += pendingRewards;

            emit RewardPaid(_user, pendingRewards);
        }
    }

    // Admin function to set staking parameters
    function setStakingParameters(
        uint256 _rewardRate, 
        uint256 _startTime, 
        uint256 _endTime
    ) external {
        // Add access control (e.g., onlyOwner) in a real implementation
        require(_endTime > _startTime, "Invalid time parameters");
        
        storex.stakingRewardRate = _rewardRate;
        storex.stakingStartTime = _startTime;
        storex.stakingEndTime = _endTime;
    }

    // View functions to get staking information
    function getStakedBalance(address _user) external view returns (uint256) {
        return storex.stakedBalance[_user];
    }

    function getPendingRewards(address _user) external view returns (uint256) {
        // Calculate pending rewards without modifying state
        uint256 timeElapsed = block.timestamp - storex.lastRewardCalculationTime[_user];
        
        return (storex.stakedBalance[_user] * 
                storex.stakingRewardRate * 
                timeElapsed) / 1e18 + 
               storex.accumulatedRewards[_user];
    }

    function getTotalStaked() external view returns (uint256) {
        return storex.totalStaked;
    }
}