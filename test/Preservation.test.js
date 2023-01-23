// test/Privacy.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const LibraryContract    = artifacts.require('LibraryContract');
const Preservation       = artifacts.require('Preservation');
const PreservationAttack = artifacts.require('PreservationAttack');

// start test block
contract('Preservation', function ([ owner, other ]) {

  beforeEach(async function () {
    this.lib1           = await LibraryContract.new({from: owner});
    this.lib2           = await LibraryContract.new({from: owner});
    this.vulnContract   = await Preservation.new(this.lib1.address, this.lib2.address, { from: owner });
    this.attackContract = await PreservationAttack.new(this.vulnContract.address, {from: other});

    // verify intial owner
    expect(await this.vulnContract.owner()).to.equal(owner);
  });

  it('test attack: steal ownership via delegatecall hack', async function () {
    await this.attackContract.attack({from: other});

    expect(await this.vulnContract.owner()).to.equal(other);
  });
});
