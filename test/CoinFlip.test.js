// test/CoinFlip.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const CoinFlip = artifacts.require('CoinFlip');
const CoinFlipAttack = artifacts.require('CoinFlipAttack');

// start test block
contract('CoinFlip', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await CoinFlip.new({ from: owner });
    this.attackContract = await CoinFlipAttack.new(this.vulnContract.address, {from: other});
    // check no wins at start
    expect(await this.vulnContract.consecutiveWins()).to.be.bignumber.equal(BN('0'));
  });

  it('test attack: 10 consecutive wins', async function () {
    for(let i=1; i<=10; i++){
      await this.attackContract.attack();
      expect(await this.vulnContract.consecutiveWins()).to.be.bignumber.equal(BN(i));
    }
  });
});
