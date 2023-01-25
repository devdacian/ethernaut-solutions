// test/PuzzleProxy.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const PuzzleProxy        = artifacts.require('PuzzleProxy');
const PuzzleWallet       = artifacts.require('PuzzleWallet');
const PuzzleProxyAttack  = artifacts.require('PuzzleProxyAttack');

// start test block
contract('PuzzleProxy', function ([ owner, other ]) {

  beforeEach(async function () {
    const MAX_BAL        = "1000000";
    const MAX_BAL_BN_STR = (ethers.utils.parseEther(MAX_BAL)).toString();

    // setup implementation contract
    this.puzzleWallet = await PuzzleWallet.new({from: owner});
    await this.puzzleWallet.init(ethers.utils.parseEther(MAX_BAL), {from: owner});

    // verify implementation contract has correct initial storage state
    expect(await this.puzzleWallet.owner()).to.equal(owner);
    expect(await this.puzzleWallet.maxBalance()).to.be.bignumber.equal(BN(MAX_BAL_BN_STR));

    // setup proxy contract
    this.vulnContract = await PuzzleProxy.new(owner, this.puzzleWallet.address, 0, {from: owner});
    // very proxy contract admin is owner
    expect(await this.vulnContract.admin()).to.equal(owner);

    this.attackContract = await PuzzleProxyAttack.new(this.vulnContract.address, {from: other});

  });

  it('test attack: steal ownership of PuzzleProxy', async function () {
    await this.attackContract.attack({from: other});

    expect(await this.vulnContract.admin()).to.equal(this.attackContract.address);
  });
});
