# fvm-starter-kit

Welcome to the FVM Starter Kit! This repository serves as a foundation for participants to kickstart their projects. Follow these instructions to set up your environment and build innovative solutions.

## Getting Started

1. **Fork and Clone:**
   
   Fork this repository to your GitHub account and then clone the forked repository to your local machine.

   ```bash
   git clone https://github.com/your-username/fvm-starter-kit.git
   cd hackathon-starter-kit
   ```

2. **Install Dependencies**
   
   After cloning, navigate to the project directory and install all the required dependencies using npm.

   ```bash
   npm install
   ```

3. **Compile Aggregator Contract**

   The aggregator contract is a core component of this kit. To compile the aggregator contract, run the following command.

   ```bash
   npx hardhat compile
   ```
   
4. **Deploy Contracts**

   Before deploying the contract, you need to set up your private key in a __.env__ file. Create a __.env__ file in the project
   directory and add your private key in the following format:

   ```bash
   PRIVATE_KEY=your_private_key
   ```

   Replace "your_private_key" with your actual private key having sufficient calibration testnet FIL.
   
   Once you've set up the .env file, you can deploy the contract to the calibration testnet using the following command.

   ```bash
   npx hardhat deploy
   ```
   This command will deploy the contract to the calibration testnet using the private key provided in the .env file.

## Participating in the hackathon
   
  Congratulations, you're all set to participate using this Starter Kit!
  Customize the contract functionality, build your user interface, and implement any additional features that align with your project idea.
   
   

