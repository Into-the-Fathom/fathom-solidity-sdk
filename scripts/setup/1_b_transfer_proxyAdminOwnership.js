
const { ethers } = require("hardhat");
const OWNER_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
const testerAccount = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
async function main() {
  const signer = await ethers.getImpersonatedSigner("0x594d425a6c9249f66a00c841a7a2a921b63a0a4c");

  const transferOwnership = [
    "function transferOwnership(address newOwner)"
  ];
  const contractInterface0 = new ethers.Interface(transferOwnership);

  const data0 = contractInterface0.encodeFunctionData('transferOwnership', [
      testerAccount,
  ]);
  const fathomProxyAdmin = "0xb82AD475fc113671840D510B60Cbae5630a07f3B";
  
  await signer.sendTransaction({
    to: fathomProxyAdmin, // The address you're sending to
    value: ethers.parseEther('0.0'), // The amount of Ether you want to send, in wei
    gasLimit: 100000, // The maximum amount of gas you're willing to use
    gasPrice: ethers.parseUnits('1.0', 'gwei'), // The price you're willing to pay per gas
    data: data0, // The data field of the transaction, if any
  });

  // await signer.sendTransaction({
  //   to: testerAccount, // The address you're sending to
  //   value: ethers.parseEther('8888.0'), // The amount of Ether you want to send, in wei
  //   gasLimit: 100000, // The maximum amount of gas you're willing to use
  //   gasPrice: ethers.parseUnits('1.0', 'gwei'), // The price you're willing to pay per gas
  //   data: "0x00"// The data field of the transaction, if any
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
