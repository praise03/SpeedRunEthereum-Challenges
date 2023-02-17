pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:

  uint256 public constant tokensPerEth = 100;

  function buyTokens() public payable{
	  uint256 tokenAmount = (msg.value*tokensPerEth);
	  yourToken.transfer(msg.sender, tokenAmount);

	  emit BuyTokens(msg.sender, msg.value, tokenAmount);
	  

  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

    
  function withdraw() public payable onlyOwner{
	    (bool withdrawSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(withdrawSuccess, "Withdraw failed failed");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  
  function sellTokens(uint256 _amount) external {
    require(_amount>0, "Cant sell 0 Tokens");

    require(yourToken.balanceOf(msg.sender) >= _amount, "Insuffienct amount of tokens");

    (bool approved) = yourToken.approve(address(this), _amount);
    require(approved, "Vendor not approved by user");
    (bool success) = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "Failed to transfer tokens to the vendor");
    uint256 amountInEth = _amount/tokensPerEth;
    (bool ethTransfered, ) = msg.sender.call{value: amountInEth}("");
    require(ethTransfered, "Failed to send ETH to user");

    emit SellTokens(msg.sender, _amount, amountInEth);
  }

}
