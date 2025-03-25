// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

contract StakingFacet {
    // Remove AppStorage dependency
    IERC20 public stakingToken;

    // Local storage for staking data
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakeTime;
    mapping(address => uint256) public lastRewardCalculationTime;
    mapping(address => uint256) public accumulatedRewards;
    uint256 public totalStaked;
    uint256 public stakingRewardRate;
    uint256 public stakingStartTime;
    uint256 public stakingEndTime;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }


 function stake(uint256 _amount) external {
    require(_amount > 0, "Cannot stake 0 tokens");
    require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
    stakedBalance[msg.sender] += _amount;
    totalStaked += _amount;
    lastStakeTime[msg.sender] = block.timestamp;
    lastRewardCalculationTime[msg.sender] = block.timestamp;
    emit Staked(msg.sender, _amount);
}

function unstake(uint256 _amount) external {
    require(_amount > 0, "Cannot unstake 0 tokens");
    require(stakedBalance[msg.sender] >= _amount, "Insufficient staked balance");
    _calculateRewards(msg.sender);
    stakedBalance[msg.sender] -= _amount;
    totalStaked -= _amount;
    require(stakingToken.transfer(msg.sender, _amount), "Transfer failed");
    emit Unstaked(msg.sender, _amount);
}

function claimRewards() external {
    _calculateRewards(msg.sender);
}

function _calculateRewards(address _user) internal {
    require(block.timestamp >= stakingStartTime && block.timestamp <= stakingEndTime, "Staking is not active");
    uint256 timeElapsed = block.timestamp - lastRewardCalculationTime[_user];
    uint256 pendingRewards = (stakedBalance[_user] * stakingRewardRate * timeElapsed) / 1e18;
    accumulatedRewards[_user] += pendingRewards;
    lastRewardCalculationTime[_user] = block.timestamp;
    if (pendingRewards > 0) {
        require(stakingToken.transfer(_user, pendingRewards), "Reward transfer failed");
        emit RewardPaid(_user, pendingRewards);
    }
}

    function setStakingParameters(uint256 _rewardRate, uint256 _startTime, uint256 _endTime) external {
        require(_endTime > _startTime, "Invalid time parameters");
        stakingRewardRate = _rewardRate;
        stakingStartTime = _startTime;
        stakingEndTime = _endTime;
    }

    function getStakedBalance(address _user) external view returns (uint256) {
        return stakedBalance[_user];
    }

    function getPendingRewards(address _user) external view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastRewardCalculationTime[_user];
        return (stakedBalance[_user] * stakingRewardRate * timeElapsed) / 1e18 + accumulatedRewards[_user];
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }
}