// test/King.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const King = artifacts.require('King');
const KingAttack = artifacts.require('KingAttack');

// start test block
contract('King', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await King.new({ from: owner, value: 1 });
    this.attackContract = await KingAttack.new(this.vulnContract.address, {from: other});
    // check initial King is owner & prize is 1
    expect(await this.vulnContract._king()).to.equal(owner);
    expect(await this.vulnContract.prize()).to.be.bignumber.equal(BN('1'));
  });

  it('test attack: become king then prevent all future kings!', async function () {
    await this.attackContract.attack({from: other, value: 2});

    // check attack contract is now King & prize is 2
    expect(await this.vulnContract._king()).to.equal(this.attackContract.address);
    expect(await this.vulnContract.prize()).to.be.bignumber.equal(BN('2'));
  });
});
