require("dotenv").config()
import { ethers } from "ethers"
import dealStatusABI from "../abi/dealStatusABI"

const submit = async () => {
  // Signer
  const provider = new ethers.providers.JsonRpcProvider("https://api.calibration.node.glif.io/rpc/v1")
  const privateKey = process.env.PRIVATE_KEY
  const signer = new ethers.Wallet(privateKey, provider)

  // Contract
  const contractAddress = "0x6ec8722e6543fB5976a547434c8644b51e24785b"
  const contract = new ethers.Contract(contractAddress, dealStatusABI, signer)

  // Call submit
  const cid = "QmPb9ghtNywrmK3KbqnQFNJmijNk1sbjhZa37LZg4wgPKy"
  const cidHex = ethers.utils.hexlify(ethers.utils.toUtf8Bytes(cid))
  const submit = await contract.submit(cidHex, {
    gasLimit: 50_000_000,
  })

  const response = await submit.wait()
  const eventData = response.events[0].args
  console.log('Tx Id:', Number(eventData[0]))
  console.log('CID', ethers.utils.toUtf8String(eventData[1]))
};

submit()
