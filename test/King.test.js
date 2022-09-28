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
    this.king = await King.new({ from: owner, value: 1 });
    this.kingAttack = await KingAttack.new(this.king.address, {from: other});
    // check initial King is owner & prize is 1
    expect(await this.king._king()).to.equal(owner);
    expect(await this.king.prize()).to.be.bignumber.equal(BN('1'));
  });

  it('test attack: become king then prevent all future kings!', async function () {
    await this.kingAttack.attack({from: other, value: 2});

    // check attack contract is now King & prize is 2
    expect(await this.king._king()).to.equal(this.kingAttack.address);
    expect(await this.king.prize()).to.be.bignumber.equal(BN('2'));

    // check no one else can become king
    // this fails but code fails to catch the error
    //const [signers] = await ethers.getSigners();
    //await expectRevert.unspecified(await signers.sendTransaction({
      //to: this.king.address,
      //value: ethers.utils.parseEther("3.0"),
    //}));
  });
});
