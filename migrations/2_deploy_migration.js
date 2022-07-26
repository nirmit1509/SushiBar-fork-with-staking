const SushiToken = artifacts.require("SushiToken");
const SushiBar = artifacts.require("SushiBar");

module.exports = async function (deployer, network, accounts) {
  // Deploy Sushi Token smart contract
  await deployer.deploy(SushiToken, {
    from: accounts[0],
  });
  const sushiTokenInstance = await SushiToken.deployed();
  await sushiTokenInstance.mint(
    accounts[0],
    web3.utils.toBN("1000000000000000000000"),
    {
      from: accounts[0],
    }
  );

  const sushiBarInstance = await deployer.deploy(SushiBar, SushiToken.address, {
    from: accounts[0],
  });
  await sushiTokenInstance.transfer(
    SushiBar.address,
    web3.utils.toBN("500000000000000000000"),
    {
      from: accounts[0],
    }
  );
};
