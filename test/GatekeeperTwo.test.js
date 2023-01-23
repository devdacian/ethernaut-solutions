// test/GatekeeperOne.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const GatekeeperTwo = artifacts.require('GatekeeperTwo');
const GatekeeperTwoAttack = artifacts.require('GatekeeperTwoAttack');

// start test block
contract('GatekeeperTwo', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await GatekeeperTwo.new({ from: owner });
    // verify initial state
    expect(await this.vulnContract.entrant).to.not.equal(other);
  });

  it('test attack: bypass 3 gates to set entrant to user address', async function () {
    this.attackContract = await GatekeeperTwoAttack.new(this.vulnContract.address, {from: other});
    expect(await this.vulnContract.entrant()).to.equal(other);
  });
});
