// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/facets/MyToken.sol"; // Adjust path as needed;
import "../contracts/facets/StakingFacet.sol"; // Adjust path as needed;

contract DiamondProxyTest is Test {
    MyToken public token;
    StakingFacet public stakingFacet;

    address public owner;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_SUPPLY = 1000000;
    uint256 public constant STAKE_AMOUNT = 1000;
    uint256 public constant REWARD_RATE = 1e16; // 0.01 tokens per second

    function setUp() public {
        // Set up test addresses
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy token contract
        vm.prank(owner);
        token = new MyToken("TestToken", "TEST", INITIAL_SUPPLY);

        // Deploy staking facet
        vm.prank(owner);
        stakingFacet = new StakingFacet();

        // Transfer tokens to test users
        vm.prank(owner);
        token.transfer(user1, 50000);
        vm.prank(owner);
        token.transfer(user2, 50000);
    }

    // Token Contract Tests
    function testTokenDeployment() public {
        assertEq(token.name(), "TestToken");
        assertEq(token.symbol(), "TEST");
        assertEq(token.totalSupply(), INITIAL_SUPPLY * 10**18);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10**18 - 100000);
    }

    function testTokenTransfer() public {
        uint256 transferAmount = 1000;
        
        vm.prank(user1);
        bool success = token.transfer(user2, transferAmount);

        assertTrue(success);
        assertEq(token.balanceOf(user1), 50000 - transferAmount);
        assertEq(token.balanceOf(user2), 50000 + transferAmount);
    }

    // Staking Contract Tests
    function testStaking() public {
        // Set up staking parameters
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(
            REWARD_RATE, 
            block.timestamp, 
            block.timestamp + 30 days
        );
        vm.stopPrank();

        // User1 stakes tokens
        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        // Check staked balance
        assertEq(stakingFacet.getStakedBalance(user1), STAKE_AMOUNT);
        assertEq(stakingFacet.getTotalStaked(), STAKE_AMOUNT);
    }

    function testUnstaking() public {
        // Set up staking
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(
            REWARD_RATE, 
            block.timestamp, 
            block.timestamp + 30 days
        );
        vm.stopPrank();

        // User1 stakes tokens
        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        // Time passes
        vm.warp(block.timestamp + 1 days);

        // User1 unstakes
        vm.prank(user1);
        stakingFacet.unstake(STAKE_AMOUNT);

        assertEq(stakingFacet.getStakedBalance(user1), 0);
        assertEq(stakingFacet.getTotalStaked(), 0);
    }

    function testRewardCalculation() public {
        // Set up staking
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(
            REWARD_RATE, 
            block.timestamp, 
            block.timestamp + 30 days
        );
        vm.stopPrank();

        // User1 stakes tokens
        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        // Time passes
        vm.warp(block.timestamp + 1 days);

        // Check pending rewards
        uint256 pendingRewards = stakingFacet.getPendingRewards(user1);
        assertTrue(pendingRewards > 0);

        // Claim rewards
        vm.prank(user1);
        stakingFacet.claimRewards();
    }

    // Error case tests
    function testCannotStakeZero() public {
        vm.expectRevert("Cannot stake 0 tokens");
        vm.prank(user1);
        stakingFacet.stake(0);
    }

    function testCannotUnstakeMoreThanStaked() public {
        // Set up staking
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(
            REWARD_RATE, 
            block.timestamp, 
            block.timestamp + 30 days
        );
        vm.stopPrank();

        // User1 stakes tokens
        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        // Try to unstake more than staked
        vm.expectRevert("Insufficient staked balance");
        vm.prank(user1);
        stakingFacet.unstake(STAKE_AMOUNT + 1);
    }
}