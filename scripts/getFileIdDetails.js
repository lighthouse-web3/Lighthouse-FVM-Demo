require("dotenv").config();
const { ethers } = require("ethers");
const dealStatusABI = require("../abi/dealStatusABI");

const callFileDetails = async (fileId) => {
  const provider = new ethers.providers.JsonRpcProvider("https://api.calibration.node.glif.io/rpc/v1");
  const privateKey = process.env.PRIVATE_KEY; //wallet private key
  const signer = new ethers.Wallet(privateKey, provider);

  const contractAddress = "0x6ec8722e6543fB5976a547434c8644b51e24785b";

  const contract = new ethers.Contract(contractAddress, dealStatusABI, signer);

  const cid = "Qmc81EUDDKH75ZA1D1cD8UZ6DqNvEgcwhmC8mWGid7YnYy";
  let fileInfo = await contract.getAllDeals(ethers.utils.hexlify(ethers.utils.toUtf8Bytes(cid)), {
    gasLimit: 50_000_000,
  });

  console.log(fileInfo)
};

callFileDetails(9)
