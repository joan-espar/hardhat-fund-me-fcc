// Scripts auxiliars

// import
const { run } = require("hardhat")

// async function verify(contractAddress, args) {
const verify = async (contractAddress, args) => {
  console.log("Verifying contract...")
  // mirem que no estigui ja verificat
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified!")
    } else {
      console.log("Different Error: ", e)
    }
  }
}

module.exports = { verify }
