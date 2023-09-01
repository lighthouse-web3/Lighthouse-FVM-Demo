const axios = require('axios')

const deal_status = async(cid) =>{
    const dealStatus = await axios.get(`https://calibration.lighthouse.storage/api/deal_status?cid=${cid}`)
    console.log(dealStatus.data)
}

deal_status("QmTgLAp2Ze2bv7WV2wnZrvtpR5pKJxZ2vtBxZPwr7rM61a")
