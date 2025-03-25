// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/facets/MyToken.sol";
import "../contracts/facets/StakingFacet.sol";

contract DiamondProxyTest is Test {
    MyToken public token;
    StakingFacet public stakingFacet;

    address public owner;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // Adjusted for 18 decimals
    uint256 public constant STAKE_AMOUNT = 1000 * 10**18;     // Adjusted for 18 decimals
    uint256 public constant REWARD_RATE = 1e12; // 0.000001 tokens per second

    
function setUp() public {
    owner = makeAddr("owner");
    user1 = makeAddr("user1");
    user2 = makeAddr("user2");

    vm.prank(owner);
    token = new MyToken("TestToken", "TEST", 1000000);

    vm.prank(owner);
    stakingFacet = new StakingFacet(address(token));

    vm.prank(owner);
    token.transfer(user1, 50000 * 10**18);
    vm.prank(owner);
    token.transfer(user2, 50000 * 10**18);
    vm.prank(owner);
    token.transfer(address(stakingFacet), 100000 * 10**18); // Still sufficient
}



function testTokenDeployment() public {
    assertEq(token.name(), "TestToken");
    assertEq(token.symbol(), "TEST");
    assertEq(token.totalSupply(), INITIAL_SUPPLY);
    assertEq(token.balanceOf(owner), INITIAL_SUPPLY - (200000 * 10**18)); // 800K tokens
}

    function testTokenTransfer() public {
        uint256 transferAmount = 1000 * 10**18; // Adjusted for decimals
        
        vm.prank(user1);
        bool success = token.transfer(user2, transferAmount);

        assertTrue(success);
        assertEq(token.balanceOf(user1), (50000 * 10**18) - transferAmount);
        assertEq(token.balanceOf(user2), (50000 * 10**18) + transferAmount);
    }

    function testStaking() public {
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(REWARD_RATE, block.timestamp, block.timestamp + 30 days);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        assertEq(stakingFacet.getStakedBalance(user1), STAKE_AMOUNT);
        assertEq(stakingFacet.getTotalStaked(), STAKE_AMOUNT);
    }

  function testUnstaking() public {
    vm.startPrank(owner);
    stakingFacet.setStakingParameters(REWARD_RATE, block.timestamp, block.timestamp + 30 days);
    vm.stopPrank();

    vm.startPrank(user1);
    token.approve(address(stakingFacet), STAKE_AMOUNT);
    stakingFacet.stake(STAKE_AMOUNT);
    vm.stopPrank();

    vm.warp(block.timestamp + 1 days);
    vm.prank(user1);
    stakingFacet.unstake(STAKE_AMOUNT);

    assertEq(stakingFacet.getStakedBalance(user1), 0);
    assertEq(stakingFacet.getTotalStaked(), 0);
}

function testRewardCalculation() public {
    vm.startPrank(owner);
    stakingFacet.setStakingParameters(REWARD_RATE, block.timestamp, block.timestamp + 30 days);
    vm.stopPrank();

    vm.startPrank(user1);
    token.approve(address(stakingFacet), STAKE_AMOUNT);
    stakingFacet.stake(STAKE_AMOUNT);
    vm.stopPrank();

    vm.warp(block.timestamp + 1 days);
    uint256 pendingRewards = stakingFacet.getPendingRewards(user1);
    assertTrue(pendingRewards > 0);

    vm.prank(user1);
    stakingFacet.claimRewards();
}

    function testCannotStakeZero() public {
        vm.expectRevert("Cannot stake 0 tokens");
        vm.prank(user1);
        stakingFacet.stake(0);
    }

    function testCannotUnstakeMoreThanStaked() public {
        vm.startPrank(owner);
        stakingFacet.setStakingParameters(REWARD_RATE, block.timestamp, block.timestamp + 30 days);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(stakingFacet), STAKE_AMOUNT);
        stakingFacet.stake(STAKE_AMOUNT);
        vm.stopPrank();

        vm.expectRevert("Insufficient staked balance");
        vm.prank(user1);
        stakingFacet.unstake(STAKE_AMOUNT + 1);
    }
}