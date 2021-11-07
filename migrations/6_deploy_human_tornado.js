/* global artifacts */
require('dotenv').config({ path: '../.env' })
const HumanTornado = artifacts.require('HumanTornado')
const Verifier = artifacts.require('Verifier')
const Hasher = artifacts.require('Hasher')
const POHMock = artifacts.require('ProofOfHumanityMock')

module.exports = function (deployer) {
  return deployer.then(async () => {
    const { 
      MERKLE_TREE_HEIGHT, 
      ETH_AMOUNT,
      POH_ADDRESS,
      START_ENROLLMENT,
      START_ANONIMIZATION
    } = process.env
    const verifier = await Verifier.deployed()
    const hasher = await Hasher.deployed()

    let poh = POH_ADDRESS
    if (poh === '') {
      const pohInstance = await deployer.deploy(POHMock)
      poh = pohInstance.address
    }

    const tornado = await deployer.deploy(
      HumanTornado,
      verifier.address,
      hasher.address,
      ETH_AMOUNT, // is not used. 
      MERKLE_TREE_HEIGHT,
      poh,
      START_ENROLLMENT,
      START_ANONIMIZATION,
    )
    console.log('HumanTornado address', tornado.address)
  })
}
