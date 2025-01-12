// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {FirstToken} from "../src/FirstToken.sol";
import {DepployFirstToken} from "../script/DeployFirstToken.s.sol";

contract FirstTokenTest is Test {
    FirstToken public firstToken;
    DepployFirstToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");

    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 public constant BOB_STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DepployFirstToken();
        firstToken = deployer.run();

        vm.prank(address(msg.sender));
        firstToken.transfer(bob, BOB_STARTING_BALANCE);
    }

    function testInitialSupply() public view {
        assertEq(firstToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testBobBalance() public view {
        assertEq(BOB_STARTING_BALANCE, firstToken.balanceOf(bob));
    }

    function testTransfersWork() public {
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        firstToken.transfer(alice, transferAmount);

        assertEq(firstToken.balanceOf(bob), BOB_STARTING_BALANCE - transferAmount);
        assertEq(firstToken.balanceOf(alice), transferAmount);
    }

    function testTransferZeroTokens() public {
        uint256 initialBalance = firstToken.balanceOf(bob);

        vm.prank(bob);
        firstToken.transfer(alice, 0);

        assertEq(firstToken.balanceOf(bob), initialBalance);
        assertEq(firstToken.balanceOf(alice), 0);
    }

    function testTransferExceedingBalance() public {
        uint256 transferAmount = BOB_STARTING_BALANCE + 1 ether;

        vm.prank(bob);
        vm.expectRevert();
        firstToken.transfer(alice, transferAmount);
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 100 ether;
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        firstToken.approve(alice, initialAllowance);

        vm.prank(alice);
        firstToken.transferFrom(bob, carol, transferAmount);

        assertEq(firstToken.balanceOf(carol), transferAmount);
        assertEq(firstToken.balanceOf(bob), BOB_STARTING_BALANCE - transferAmount);
        assertEq(firstToken.allowance(bob, alice), initialAllowance - transferAmount);
    }

    function testAllowanceExceedingSpending() public {
        uint256 initialAllowance = 100 ether;
        uint256 transferAmount = 200 ether;

        vm.prank(bob);
        firstToken.approve(alice, initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        firstToken.transferFrom(bob, carol, transferAmount);
    }

    function testApproveUpdatesAllowance() public {
        uint256 firstAllowance = 500 ether;
        uint256 updatedAllowance = 1000 ether;

        vm.prank(bob);
        firstToken.approve(alice, firstAllowance);
        assertEq(firstToken.allowance(bob, alice), firstAllowance);

        vm.prank(bob);
        firstToken.approve(alice, updatedAllowance);
        assertEq(firstToken.allowance(bob, alice), updatedAllowance);
    }

    function testCannotTransferFromWithoutApproval() public {
        uint256 transferAmount = 500 ether;

        vm.prank(alice);
        vm.expectRevert();
        firstToken.transferFrom(bob, carol, transferAmount);
    }

    function testMintingRestricted() public {
        vm.expectRevert();
        firstToken.mint(alice, 200 ether);
    }

    function testBurningRestricted() public {
        vm.expectRevert();
        firstToken.burn(100 ether);
    }
}
