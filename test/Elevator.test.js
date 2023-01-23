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
    this.vulnContract   = await Elevator.new({ from: owner });
    this.attackContract = await ElevatorAttack.new(this.vulnContract.address, {from: other});
    // check top initially false
    expect(await this.vulnContract.top()).to.be.false;
  });

  it('test attack: use fake interface to mislead elevator & get to the top!', async function () {
    await this.attackContract.attack({from: other});
    // check we have reached the top!
    expect(await this.vulnContract.top()).to.be.true;
  });
});
