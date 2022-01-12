const { ethers, upgrades } = require('hardhat');
const { writeFileSync } = require('fs');
const { getImplementationAddress } = require("@openzeppelin/upgrades-core")

async function deploy(name, ...params) {
  const Contract = await ethers.getContractFactory(name);
  return await Contract.deploy(...params).then(f => f.deployed());
}

async function main() {
  const forwarder = await deploy('MinimalForwarderUpgradeable');
  const MinimalForwarder = forwarder.address
  // const object = require('fs').readFileSync('deploy.json');
  // const { MinimalForwarder } = JSON.parse(object);
  console.log('Deploying ActiveBatch...');
  const activeBatch = await ethers.getContractFactory('ActiveBatch');
  console.log(activeBatch);
  const Proxycontract = await upgrades.deployProxy(activeBatch, ["uri", MinimalForwarder, "0x8422B7530f55E3F9FDb3f13950B24895c56E63a2"], { initializer: 'initialize' });
  await Proxycontract.deployed();
  console.log(Proxycontract)
  const provider = new ethers.providers.JsonRpcProvider("https://polygon-mumbai.g.alchemy.com/v2/{KEY}", 80001);
  const currentImplAddress = await getImplementationAddress(provider, Proxycontract.address);
  writeFileSync('deploy.json', JSON.stringify({
    MinimalForwarder: MinimalForwarder,
    activeBatch: currentImplAddress,
    ActiveBatch: Proxycontract.address
  }, null, 2));
  console.log('Proxycontract Address:', Proxycontract.address);
  console.log('ActiveBatch Address:', currentImplAddress);
  console.log('Forwarder Address:', MinimalForwarder);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
