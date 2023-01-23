// test/Telephone.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Telephone = artifacts.require('Telephone');
const TelephoneAttack = artifacts.require('TelephoneAttack');

// start test block
contract('Telephone', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract = await Telephone.new({ from: owner });
    this.attackContract = await TelephoneAttack.new(this.vulnContract.address, {from: other});
    // check owner initially owns vulnerable contract
    expect(await this.vulnContract.owner()).to.equal(owner);
  });

  it('test attack: steal ownership from owner to other', async function () {
    await this.attackContract.attack({from: other});
    expect(await this.vulnContract.owner()).to.equal(other);
  });
});
