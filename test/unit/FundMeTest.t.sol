// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMETest is Test,HelperConfig {
    FundMe public fundme;
    HelperConfig public helperConfig;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
    
      DeployFundMe deployer = new DeployFundMe();
      (fundme, helperConfig) = deployer.deployFundMe();
      vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIs5() public {
        assertEq(fundme.MINIMUM_USD(),5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundme.getVersion();
        assertEq(version , 4);
    }
    function testFundFailswithoutEnoughETH() public {
        vm.expectRevert(); // the next line should revert
        fundme.fund(); // sends 0 value
    }
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //The next transcation will be sent by USER
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }
    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }
    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        //Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundme).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundme.getOwner().balance);
    }
       function testWithdrawFromMultipleFundersCheaper() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundme).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundme.getOwner().balance);
    }
}
