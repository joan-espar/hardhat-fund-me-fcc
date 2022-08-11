// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Get funds form users
// Withdrawal funds
// Set a minimum funding value in USD

import "./PriceConverter.sol";

error FundMe__NotOwner();

/** @title A contract for crowd funding
 *  @author Me
 *  @notice this contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
  using PriceConverter for uint256;

  // State variables
  mapping(address => uint256) private s_addressToAmountFunded;
  address[] private s_funders;
  address private immutable i_owner;
  // address public owner;
  uint256 public constant MINIMUM_USD = 50 * 1e18;

  AggregatorV3Interface private s_priceFeed;

  modifier onlyOwner() {
    //require(msg.sender == i_owner, "Sender is not the owner");
    if (msg.sender != i_owner) {
      revert FundMe__NotOwner();
    } // manera alternativa de fer el mateix pero amb menos gas
    _;
  }

  constructor(address priceFeedAddress) {
    // gets called at the moment that the contract is created
    i_owner = msg.sender; // owner = whoever deploys the contract
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  // What happens if someone sends this contract ETH without calling the fund() function? -> receive and fallback
  // receive() external payable {
  //   fund();
  // }

  // fallback() external payable {
  //   fund();
  // }

  function fund() public payable {
    /*
        // Want to be able to to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?
        // require(msg.value >= 1e18, "Didn't send enough ETH"); // 1e18 = 1 * 10 ** 18 = 1000000000000000000
        
        // Now we want to use the minimumUSD threshold instead of the ETH threshold.
        // We ned to convert the ETH to USD -> we need the price feed ETH/USD -> Oracle (Chainlink)
        require(getConversionRate(msg.value) >= minimumUSD, "Didn't send enough ETH");
        // What is reverting? -> Undo any action before, and sendremaining gas back
        */

    // Library version:
    require(
      msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
      "Didn't send enough ETH"
    );

    // Add address to funders list
    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] = msg.value;
  }

  function withdraw() public onlyOwner {
    // We need to reset the array and mapping
    for (
      uint256 funderIndex = 0;
      funderIndex < s_funders.length;
      funderIndex++
    ) {
      // code
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    // reset the array
    s_funders = new address[](0);

    // actually withdraw the funds - transfer, send, call
    // en teoria call es la millor que podem utilitzar, pero les diferencies son petites
    // caldria mirar en detall per a cada cas quina es la millor.

    // transfer
    // msg.sender = address
    // payable(msg.sender) = payable address
    // payable(msg.sender).transfer(address(this).balance);

    // send
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send failed")

    // call
    //(bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  function cheaperWithdraw() public payable onlyOwner {
    address[] memory funders = s_funders;
    // mapping can't be in memory, sorry :)
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    (bool success, ) = i_owner.call{value: address(this).balance}("");
    require(success, "Call failed");
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
  }

  function getAddressToAmountFunded(address funder)
    public
    view
    returns (uint256)
  {
    return s_addressToAmountFunded[funder];
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}
