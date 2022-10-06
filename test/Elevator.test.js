// test/Elevator.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Elevator = artifacts.require('Elevator');
const ElevatorAttack = artifacts.require('ElevatorAttack');

// start test block
contract('Elevator', function ([ owner, other ]) {

  beforeEach(async function () {
    this.elevator = await Elevator.new({ from: owner });
    this.elevatorAttack = await ElevatorAttack.new(this.elevator.address, {from: other});
    // check top initially false
    expect(await this.elevator.top()).to.be.false;
  });

  it('test attack: use fake interface to mislead elevator & get to the top!', async function () {
    await this.elevatorAttack.attack({from: other});
    // check we have reached the top!
    expect(await this.elevator.top()).to.be.true;
  });
});
