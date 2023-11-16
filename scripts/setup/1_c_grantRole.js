
const { ethers } = require("hardhat");
const OWNER_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
const testerAccount = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
async function main() {
  const signer = await ethers.getImpersonatedSigner("0x594d425a6c9249f66a00c841a7a2a921b63a0a4c");

  const grantRole = [
    "function grantRole(bytes32 _role, address _address)"
  ];
  const contractInterface0 = new ethers.Interface(grantRole);
  // function transferOwnership(address newOwner) external;

  const data0 = contractInterface0.encodeFunctionData('grantRole', [
      OWNER_ROLE,  // bytes32 _collateralPoolId
      testerAccount // address _strategy
  ]);
  const accessControlConfigProxy = "0x2cD89769a2D9d992790e76c6A9f55c39fdf2FDc2";
  
  await signer.sendTransaction({
    to: accessControlConfigProxy, // The address you're sending to
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
