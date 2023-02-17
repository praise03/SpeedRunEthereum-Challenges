// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  mapping ( address => uint256 ) public balances;


  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool openForWithdraw = false;
  
  event Stake(address staker, uint256 amount);

  modifier notCompleted() {
	  require(!exampleExternalContract.completed(), "External contract not completed yet");
	  _;
  }

  function stake() public payable {
    // require(msg.value > 0, "Need to send some ETH");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public notCompleted {
   require(block.timestamp >= deadline, "Deadline has not passed");

   if (address(this).balance >= threshold) {
     exampleExternalContract.complete{value: address(this).balance}();
   } else {
     openForWithdraw = true;
   } 
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public payable notCompleted {
		require(openForWithdraw, "Not open for withdraw");

		(bool withdrawSuccess, ) = payable(msg.sender).call{value: balances[msg.sender]}("");
		require(withdrawSuccess, "Withdraw failed");
	}


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

	function timeLeft() public view returns(uint256){
		if (block.timestamp > deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;	
		}
	}

  // Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		stake();
 	}

}