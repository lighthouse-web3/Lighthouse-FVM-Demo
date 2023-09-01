const axios = require('axios')

const register_job = async() =>{
    const formData = new FormData();
    
    const cid = "QmTgLAp2Ze2bv7WV2wnZrvtpR5pKJxZ2vtBxZPwr7rM61a"
    // Optional Parameters
    const requestReceivedTime = new Date()
    const endDate = requestReceivedTime.setMonth(requestReceivedTime.getMonth() + 1)
    const replicationTarget = 2
    const epochs = 4 // how many epochs before deal end should deal be renewed
    formData.append('cid', cid)
    formData.append('endDate', endDate)
    formData.append('replicationTarget', replicationTarget)
    formData.append('epochs', epochs)

    const response = await axios.post(
        `https://calibration.lighthouse.storage/api/register_job`,
        formData
    )
    console.log(response.data)
}

register_job()
