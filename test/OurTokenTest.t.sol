// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken ourToken;
    DeployOurToken deployer;
    uint256 constant INITIAL_USER_BALANCE = 10 ether;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, INITIAL_USER_BALANCE);
    }

    function testBobBalance() public view {
        assert(ourToken.balanceOf(bob) == INITIAL_USER_BALANCE);
    }

    function testAllowances() public {
        uint initialAllowance = 5 ether;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint transferAmount = 3 ether;
        vm.prank(alice);

        ourToken.transferFrom(bob, alice, transferAmount);

        assert(
            ourToken.balanceOf(bob) == INITIAL_USER_BALANCE - transferAmount
        );
        assert(ourToken.balanceOf(alice) == transferAmount);
    }

    function testInitialSupply() public view {
        assert(ourToken.totalSupply() == deployer.INITIAL_SUPPLY());
    }

    function testNameAndSymbol() public view {
        assert(
            keccak256(abi.encodePacked(ourToken.name())) ==
                keccak256("OurToken")
        );
        assert(
            keccak256(abi.encodePacked(ourToken.symbol())) == keccak256("OT")
        );
    }

    function testDecimals() public view {
        assert(ourToken.decimals() == 18); // Assuming you're using 18 decimals
    }

    function testTransfer() public {
        uint transferAmount = 3 ether;
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);
        assert(
            ourToken.balanceOf(bob) == INITIAL_USER_BALANCE - transferAmount
        );
        assert(ourToken.balanceOf(alice) == transferAmount);
    }

    function testInsufficientAllowance() public {
        uint initialAllowance = 2 ether;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint transferAmount = 3 ether;
        // Attempt transfer exceeding allowance should fail
        vm.expectRevert();

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
    }
}
