// test/Reentrance.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Reentrance = artifacts.require('Reentrance');
const ReentranceAttack = artifacts.require('ReentranceAttack');

// start test block
contract('Reentrance', function ([ owner, other ]) {
  const initialBalance = "0.001";

  beforeEach(async function () {
    this.reentrance = await Reentrance.new({ from: owner });
    this.reentranceAttack = await ReentranceAttack.new(this.reentrance.address, {from: other});
    // set initial contract balance & check it
    await this.reentrance.donate(owner, {value: ethers.utils.parseEther(initialBalance)});
    expect(ethers.utils.formatEther(await ethers.provider.getBalance(this.reentrance.address))).to.equal(initialBalance);
    expect(ethers.utils.formatEther(await ethers.provider.getBalance(this.reentranceAttack.address))).to.equal("0.0");
  });

  it('test attack: reentrance contract drained of funds', async function () {
    await this.reentranceAttack.attack({from: other, value: ethers.utils.parseEther(initialBalance)});
    expect(ethers.utils.formatEther(await ethers.provider.getBalance(this.reentranceAttack.address))).to.equal("0.002");
    expect(ethers.utils.formatEther(await ethers.provider.getBalance(this.reentrance.address))).to.equal("0.0");
  });
});
