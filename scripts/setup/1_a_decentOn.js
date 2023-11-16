const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {
  const signer = await ethers.getImpersonatedSigner("0x594d425a6c9249f66a00c841a7a2a921b63a0a4c");

  const setDecentralizedModeAbi = [
    "function setDecentralizedMode(bool _is)"
  ];
  const contractInterface = new ethers.Interface(setDecentralizedModeAbi);

  // const contractInterface = new hre.ethers.utils.Interface(setDecentralizedModeAbi);
  const data = contractInterface.encodeFunctionData('setDecentralizedMode', [true]);

  await signer.sendTransaction({
    to: '0x3b92595cbe2fC6063e696460990e69Ae4172c707', // The address you're sending to
    value: ethers.parseEther('0.0'), // The amount of Ether you want to send, in wei
    gasLimit: 100000, // The maximum amount of gas you're willing to use
    gasPrice: ethers.parseUnits('2.0', 'gwei'), // The price you're willing to pay per gas
    data: data, // The data field of the transaction, if any
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
