require("dotenv").config();
const { ethers } = require("ethers");
const dealStatusABI = require("../abi/dealStatusABI");

const submit = async () => {
  const provider = new ethers.providers.JsonRpcProvider("https://api.calibration.node.glif.io/rpc/v1");
  const privateKey = process.env.PRIVATE_KEY;
  const signer = new ethers.Wallet(privateKey, provider);

  const contractAddress = "0x6ec8722e6543fB5976a547434c8644b51e24785b"

  const contract = new ethers.Contract(contractAddress, dealStatusABI, signer);

  const cid = "Qmc81EUDDKH75ZA1D1cD8UZ6DqNvEgcwhmC8mWGid7YnYy";
  const cidHex = ethers.utils.hexlify(ethers.utils.toUtf8Bytes(cid));
  const submit = await contract.submit(cidHex, {
    gasLimit: 50_000_000,
  });

  const response = await submit.wait();
  console.log("transaction done");

  const eventData = response.events[0].args;
  console.log('Tx Id:', Number(eventData[0]));
  console.log('CID', ethers.utils.toUtf8String(eventData[1]));
};

submit()
