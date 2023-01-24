// test/Recovery.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const Recovery       = artifacts.require('Recovery');
const RecoveryAttack = artifacts.require('RecoveryAttack');

// start test block
contract('Recovery', function ([ owner, other ]) {

  beforeEach(async function () {
    this.factoryContract = await Recovery.new({ from: owner });
    this.factoryContract.generateToken("Moon", 10000000, { from: owner });

    // https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
    this.recomputedContractAddress = ethers.utils.getContractAddress({
        from: this.factoryContract.address
       ,nonce: 1
    });

    // check initial contract has no balance
    const initialContractBalance = (await ethers.provider.getBalance(this.recomputedContractAddress)).toString();
    expect(initialContractBalance).to.equal("0");

    const SEND_AMOUNT        = "0.001";
    const SEND_AMOUNT_BN_STR = (ethers.utils.parseEther(SEND_AMOUNT)).toString();

    // owner sends 0.001 ether to newly created contract to get their tokens
    const sendTx = {
        to: this.recomputedContractAddress
       ,value: ethers.utils.parseEther(SEND_AMOUNT)
    };

    const sendReceipt = await (await ethers.getSigner(owner)).sendTransaction(sendTx);
    expect(sendReceipt.status == 1);

    // verify contract has received ether sent by owner
    const afterSendContractBalance = (await ethers.provider.getBalance(this.recomputedContractAddress)).toString();
    expect(afterSendContractBalance).to.equal(SEND_AMOUNT_BN_STR);
  });

  it('test attack: recompute contract address & recover ether', async function () {
    const beforeAttackOtherBalance = parseFloat(ethers.utils.formatEther((await ethers.provider.getBalance(other)).toString()));

    // then owner forgets address, we use re-computed address to call selfdestruct & retrieve ether to other account
    this.attackContract = await RecoveryAttack.new(this.recomputedContractAddress, {from: other});
    await this.attackContract.attack(other, {from: owner});

    // check that other balance after selfdestruct greater than before
    const afterAttackOtherBalance = parseFloat(ethers.utils.formatEther((await ethers.provider.getBalance(other)).toString()));

    expect(afterAttackOtherBalance).to.be.greaterThan(beforeAttackOtherBalance);
    
  });
});
