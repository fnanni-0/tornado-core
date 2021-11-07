// https://tornado.cash
/*
 * d888888P                                           dP              a88888b.                   dP
 *    88                                              88             d8'   `88                   88
 *    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
 *    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
 *    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
 *    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
 * ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Tornado.sol";

interface IPOH {
  function isRegistered(address _submissionID) external view returns (bool);
}

contract HumanTornado is Tornado {

  struct Batch {
    uint64 startEnrollment; // timestamp
    uint64 startAnonymization; // timestamp
  }

  IPOH public poh;
  Batch public batch;
  uint256 public humanCounter;
  uint256 private anonymousCounter;
  mapping(address => bool) public isEnrolled; // Human can only "deposit" once per batch.
  mapping(address => bool) public isRegistered; // Anonymous, sybil-resistant address.

  // Note that this isn't an ERC20 and only implements its interface in order to be compatible with Snapshot.
  string public name = "Anon Human Vote";
  string public symbol = "ANON";
  uint8 public decimals = 0;

  constructor(
    IVerifier _verifier,
    IHasher _hasher,
    uint256 _denomination, // is not used
    uint32 _merkleTreeHeight,
    IPOH _poh,
    uint64 _startEnrollment,
    uint64 _startAnonymization
  ) Tornado(_verifier, _hasher, _denomination, _merkleTreeHeight) {
    poh = _poh;
    batch.startEnrollment = _startEnrollment;
    batch.startAnonymization = _startAnonymization;
  }

  function _processDeposit() internal override {
    require(poh.isRegistered(msg.sender), "Not registered in Proof of Humanity");
    require(isEnrolled[msg.sender] == false, "Already enrolled in this batch");
    require(block.timestamp > batch.startEnrollment, "Enrollment not allowed yet");
    require(block.timestamp < batch.startAnonymization, "Enrollment period over");
    isEnrolled[msg.sender] = true;
    humanCounter++; // Redundant info with Deposit event.
  }

  function _processWithdraw(
    address payable _recipient,
    address payable _relayer,
    uint256 _fee,
    uint256 _refund
  ) internal override {
    require(block.timestamp > batch.startAnonymization, "Enrollment period over");
    require(isRegistered[_recipient] == false, "Address already used in this batch");
    isRegistered[_recipient] = true; // Should this be a number to allow anonymous delegations?
    anonymousCounter++;
  }

  // ******************** //
  // *      IERC20      * //
  // ******************** //
  
  function balanceOf(address _anonHuman) external view returns (uint256) {
    return isRegistered[_anonHuman] ? 1 : 0;
  }

  function totalSupply() external view returns (uint256) {
    return anonymousCounter;
  }

  function transfer(address _recipient, uint256 _amount) external returns (bool) { return false; }

  function allowance(address _owner, address _spender) external view returns (uint256) {}

  function approve(address _spender, uint256 _amount) external returns (bool) { return false; }

  function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool) { return false; }
}
