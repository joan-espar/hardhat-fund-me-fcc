// Ususally we do:
// import
// main function
// calling the main function
// But now, with the deploy package, we don't need to do this.
// The package will call the function :)

const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

// OPTION 1
// function deployFunc(hre) {
//   console.log("Hi")
// }
// module.exports.default = deployFunc

// OPTION 2: BETTER because it's simpler and we don't use a name for the function
// module.exports = async (hre) => {
//   const { getNamedAccounts, deployments } = hre
// }

// Just to remember, this is equivalent to:
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig

// OPTION 3: BEST: async nameless function
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  // How do we know the address for thje price feed contract?
  // We can use the chainId -> if chainId is X use address Y
  // take a look to the aave contract -> helper hardhat config

  //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  let ethUsdPriceFeedAddress
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await get("MockV3Aggregator")
    ethUsdPriceFeedAddress = ethUsdAggregator.address
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  }

  // And for the local network? -> Mocks
  // if the contract doesn't exist, we deploy a minimal version of it
  // for our local testing. Deploying mocks -> deploy script

  // When going for localhost or hardhat network we want to use a mock
  // But, what happens when we want to change chains?
  const args = [ethUsdPriceFeedAddress]
  console.log("---------", network.config.blockConfirmations, "-----------")
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, // put price feed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1, // or 1 :)
  })
  // We want to verify if we are not in a development chain and we have the key
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    // verify
    await verify(fundMe.address, args)
  }
  log("--------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
