const { inputToConfig } = require("@ethereum-waffle/compiler")
const { getNamedAccounts, ethers, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { assert } = require("chai")

// aixo es com un if statement pero en una linea
// let variable = false
// let someVar = variable ? "yes" : "no"
// equivalent a: if (variable) { someVar = "yes"} else {someVar = "No"}

// volem fer el test que en cas que estiguem en una developmentChains saltem el describe i sino el fem :)
developmentChains.includes(network.name)
  ? describe.skip
  : describe("FundMe", async function () {
      let fundMe
      let deployer
      const sendValue = ethers.utils.parseEther("1")

      beforeEach(async function () {
        deployer = (await getNamedAccounts()).deployer
        fundMe = await ethers.getContract("FundMe", deployer)
      })

      it("allows people to fund and withdraw", async function () {
        await fundMe.fund({ value: sendValue })
        await fundMe.withdraw()
        const endingBalance = await fundMe.provider.getBalance(fundMe.address)
        assert.equal(endingBalance.toString(), "0")
      })
    })
