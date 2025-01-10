// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
contract InteractionsTest is Test{
    FundMe public fundme;
    HelperConfig public helperConfig;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external{
        DeployFundMe deployer = new DeployFundMe();
        (fundme, helperConfig)  = deployer.deployFundMe();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testUserCanFundInteractions() public{ 
        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(USER, 1e18);
        fundFundMe.fundFundMe(address(fundme));

       address funder = fundme.getFunder(0);
    
       WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
       withdrawFundMe.withdrawFundMe(address(fundme));
       assert(address(fundme).balance == 0);

    }
}
