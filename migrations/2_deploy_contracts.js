const vanityContract = artifacts.require('./VanityName.sol')

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(vanityContract)
    const contractInstance = await vanityContract.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log(`Contract Address: ${contractInstance.address}`)
    console.log('\n*************************************************************************\n')
  })
}
