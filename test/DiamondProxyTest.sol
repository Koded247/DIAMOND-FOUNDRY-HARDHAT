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

    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    uint256 public constant STAKE_AMOUNT = 1000 * 10**18;
    uint256 public constant REWARD_RATE = 1e12; 

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
        token.transfer(address(stakingFacet), 100000 * 10**18);
    }

    function testTokenDeployment() public {
        assertEq(token.name(), "TestToken");
        assertEq(token.symbol(), "TEST");
        assertEq(token.decimals(), 18); // Test decimals()
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - (200000 * 10**18));
    }

    function testTokenTransfer() public {
        uint256 transferAmount = 1000 * 10**18;
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

    // New tests for full coverage
    function testTransferToZeroAddress() public {
        vm.expectRevert("Invalid address");
        vm.prank(user1);
        token.transfer(address(0), 1000 * 10**18);
    }

    function testTransferInsufficientBalance() public {
        vm.expectRevert("Insufficient balance");
        vm.prank(user1);
        token.transfer(user2, 60000 * 10**18); // More than user1's balance
    }

    function testApproveToZeroAddress() public {
        vm.expectRevert("Invalid address");
        vm.prank(user1);
        token.approve(address(0), 1000 * 10**18);
    }

    function testTransferFromInsufficientAllowance() public {
        vm.prank(user1);
        token.approve(user2, 500 * 10**18);
        vm.expectRevert("Allowance exceeded");
        vm.prank(user2);
        token.transferFrom(user1, user2, 1000 * 10**18);
    }

    function testTransferFromInsufficientBalance() public {
        vm.prank(user1);
        token.approve(user2, 60000 * 10**18);
        vm.expectRevert("Insufficient balance");
        vm.prank(user2);
        token.transferFrom(user1, user2, 60000 * 10**18);
    }

    function testTransferFromToZeroAddress() public {
        vm.prank(user1);
        token.approve(user2, 1000 * 10**18);
        vm.expectRevert("Invalid address");
        vm.prank(user2);
        token.transferFrom(user1, address(0), 1000 * 10**18);
    }

    function testMint() public {
        uint256 mintAmount = 1000 * 10**18;
        vm.prank(owner);
        bool success = token.mint(user1, mintAmount);
        assertTrue(success);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
        assertEq(token.balanceOf(user1), 50000 * 10**18 + mintAmount);
    }

    function testMintToZeroAddress() public {
        vm.expectRevert("Invalid address");
        vm.prank(owner);
        token.mint(address(0), 1000 * 10**18);
    }

    function testBurn() public {
        uint256 burnAmount = 1000 * 10**18;
        vm.prank(user1);
        bool success = token.burn(burnAmount);
        assertTrue(success);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
        assertEq(token.balanceOf(user1), 50000 * 10**18 - burnAmount);
    }

    function testBurnInsufficientBalance() public {
        vm.expectRevert("Insufficient balance");
        vm.prank(user1);
        token.burn(60000 * 10**18); // More than user1's balance
    }
}