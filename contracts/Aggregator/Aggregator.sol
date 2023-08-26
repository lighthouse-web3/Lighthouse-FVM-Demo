// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.19;

import { IAggregatorOracle } from "../AggregatorOracle/IAggregatorOracle.sol";
import { Proof } from "../DataSegment/Proof.sol";
import { InclusionProof, InclusionVerifierData, InclusionAuxData } from "../DataSegment/ProofTypes.sol";
import { MarketAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";

error INCORRECT_FILE_ID();

contract Aggregator is IAggregatorOracle, Proof {
    /// @notice transaction id of every potential file storage
    uint256 private transactionId;

    /// @notice fileToDeals maps fileLink to deals
    /// @dev fileLink -> deals[]
    mapping(bytes => Deal[]) public fileToDeals;

    /// @notice mapping to track all the file id that are failed to get deal created
    /// @dev file id -> true (if failed to store file)
    // mapping(uint => bool) public failedMigration; ----> additional mapping

    /**
     * @notice mapping to track all the transaction id storage info
     * @dev transactionId -> fileLink
     */
    mapping(uint256 => bytes) public txIdToFile; 
    // previosly this was  ----> mapping(uint256 => fileDetails) public fileIdDetail; 

    /**
     * @notice mapping to store transaction ID against deal Id
     * @dev transaction ID -> deal ID
     */
    mapping(uint => dealDetails) public txIdToDealDetails;

    /**
     * @notice event storing the details of the file
     * @param fileLink link of the file
     * @dev true means free trial, false means Paid user
     * @param fileId file id
     * @dev event listen by the backend services
     */
    // event DataInfo(
    //     bytes fileLink,
    //     uint indexed fileId,
    //     address user,
    //     bytes miner,
    //     uint num_copies,
    //     uint repair_threshold,
    //     uint renew_threshold
    // ); ----> additional event

    /**
     * @notice event to emit when file is not stored
     * @param fileId file id
     */
    // event DealNotCreated(uint fileId); ----> additional event

    /**
     * @notice event to emit when file is stored
     * @param fileId file id
     */
    // event DealCreated(uint fileId, uint dealId, bytes cid);  ----> additional event

    /// @notice Struct to store all the details about proposed file
    // struct fileDetails {
    //     address user; // address of the user
    //     bytes fileLink; // link of the file
    // }   ----> additional struct

    /// @notice Struct to store all the details about stored file
    struct dealDetails {
        uint dealId;
        bytes cid;
    }  

    constructor() {
        transactionId = 0;
    }

    /**
     * @notice function to store file
     * @param fileLink file link of the file
     */
    function submit(bytes memory fileLink,
        bytes memory miner,
        uint num_copies,
        uint repair_threshold,
        uint renew_threshold) external returns (uint256) {
        // increment the fileId
        unchecked {
            ++transactionId;
        }

        //Save _cid
        txIdToFile[transactionId] = fileLink;

        // additional code
        // fileIdToDetails[fileId].user = msg.sender;
        // fileIdToDetails[fileId].fileLink = data_url;

        // emit DataInfo(data_url, fileId, msg.sender, miner, num_copies, repair_threshold, renew_threshold);
        emit SubmitAggregatorRequest(transactionId, fileLink, msg.sender, miner, num_copies, repair_threshold, renew_threshold);
        return transactionId;
    }

    /**
     * @dev complete is a callback function that is called by the aggregator
     * @param _id is the transaction ID
     * @param _dealId is the deal ID
     * @param _minerId is the miner ID
     * @param _proof is the inclusion proof
     * @param _verifierData is the verifier data
     * @return the aux data
     */
    function complete(
        uint256 _id,
        uint64 _dealId,
        uint64 _minerId,
        InclusionProof memory _proof,
        InclusionVerifierData memory _verifierData
    ) external returns (InclusionAuxData memory) {
        require(_id <= transactionId, "complete: invalid file id"); // revert message??
        // Emit the event
        emit CompleteAggregatorRequest(_id, _dealId);

        // save the _dealId if it is not already saved
        bytes memory cid = txIdToFile[_id];
        for (uint256 i = 0; i < fileToDeals[cid].length; i++) {
            if (fileToDeals[cid][i].dealId == _dealId) {
                return this.computeExpectedAuxData(_proof, _verifierData);
            }
        }
        Deal memory deal = Deal(_dealId, _minerId);
        fileToDeals[cid].push(deal);

        // Perform validation logic
        // return this.computeExpectedAuxDataWithDeal(_dealId, _proof, _verifierData);
        return this.computeExpectedAuxData(_proof, _verifierData);
    }

    /**
     * @notice function to store file ID against deal Id
     * @param _transactionId unique id of file
     * @param _dealId deal id
     * @param _cid of the file
     * @dev called by the lighthouse aggregator backend
     */
    function setDealDetails(uint _transactionId, uint _dealId, bytes memory _cid) external {
        // if (!_isMigrated) {
        //     failedMigration[_fileId] = true;
        //     emit DealNotCreated(_fileId);
        //     return;
        // }
        txIdToDealDetails[_transactionId].dealId = _dealId;
        txIdToDealDetails[_transactionId].cid = _cid;
        // emit DealCreated(_fileId, _dealId, _cid);
    } 

    //////////           GETTER FUNCTIONS          ///////////////
    
    /**
     * @notice function get all deals of given file created by the aggregator
     * @param _cid file link of the file
     * @return deals 
     */
    function getAllDeals(bytes memory _cid) external view returns (Deal[] memory) {
        return fileToDeals[_cid];
    }

    /**
     * @notice function get active deals of given file 
     * @param _cid file link of the file
     * @return deals 
     */
    function getActiveDeals(bytes memory _cid) external returns (Deal[] memory) {
        // get all the deal ids for the cid
        Deal[] memory activeDealIds;
        activeDealIds = this.getAllDeals(_cid);

        for (uint256 i = 0; i < activeDealIds.length; i++) {
            uint64 dealID = activeDealIds[i].dealId;
            // get the deal's expiration epoch
            MarketTypes.GetDealActivationReturn memory dealActivationStatus = MarketAPI.getDealActivation(dealID);

            if (dealActivationStatus.terminated > 0 || dealActivationStatus.activated == -1) {
                delete activeDealIds[i];
            }
        }

        return activeDealIds;
    }

    /**
     * @notice function get all deals of given file if they are expiring within `epochs`
     * @param _cid file link of the file
     * @param epochs is the further more epochs
     * @return deals 
     */
    // getExpiringDeals should return all the deals' dealIds if they are expiring within `epochs`
    function getExpiringDeals(bytes memory _cid, uint64 epochs) external returns (Deal[] memory) {
        // the logic is similar to the above, but use this api call:
        // https://github.com/Zondax/filecoin-solidity/blob/master/contracts/v0.8/MarketAPI.sol#LL110C9-L110C9
        Deal[] memory expiringDealIds;
        expiringDealIds = this.getAllDeals(_cid);

        for (uint256 i = 0; i < expiringDealIds.length; i++) {
            uint64 dealId = expiringDealIds[i].dealId;
            // get the deal's expiration epoch
            MarketTypes.GetDealTermReturn memory dealTerm = MarketAPI.getDealTerm(dealId);

            if (block.timestamp < uint64(dealTerm.end) - epochs) {
                delete expiringDealIds[i];
            }
        }

        return expiringDealIds;
    }

    /**
     * @notice function to get the Deal id and CID from file id
     * @param _transactionId unique id of file
     * @dev called by the user
     */
    function getDealDetails(uint _transactionId) external view returns (bytes memory, uint) {
        return (txIdToDealDetails[_transactionId].cid, txIdToDealDetails[_transactionId].dealId);
    }


// additional functions

//     /**
//      * @notice function to check that the file is stored
//      * @param _fileId file id
//      * @dev user will call this function. Return true is file is stored and false if file is not stored
//      */
//     function checkMigration(uint _fileId) public view returns (bool) {
//         if (_fileId > fileId) {
//             revert INCORRECT_FILE_ID();
//         }
//         if (failedMigration[_fileId]) return false;
//         return true;
//     }

//     /**
//      * @notice function to check that this deal is expired or not
//      * @param _dealId Deal Id
//      * @dev if MarketAPI.getDealActivation(_dealId) > 0 then deal is terminated and if the value is zero then deal is still stored in the network
//      */
//     function checkDealExpire(uint64 _dealId) external returns (bool) {
//         MarketTypes.GetDealActivationReturn memory ret = MarketAPI.getDealActivation(_dealId);
//         if (CommonTypes.ChainEpoch.unwrap(ret.terminated) > 0) {
//             return true;
//         } else if (CommonTypes.ChainEpoch.unwrap(ret.activated) > 0) {
//             return false;
//         }
//     }

//     /**
//      * @notice function to get time left before expire
//      * @param _dealId Deal Id
//      */
//     function getTimeToDealExpire(uint64 _dealId) external returns (int) {
//         MarketTypes.GetDealTermReturn memory ret = MarketAPI.getDealTerm(_dealId);
//         int64 end = CommonTypes.ChainEpoch.unwrap(ret.end);
//         uint64 currentBlock = uint64(block.number);
//         int64 currentBlockInt = int64(currentBlock);
//         return (end - currentBlockInt);
//     }

//     /**
//      * @notice getDeals returns all deals for a file
//      * @param data_url Link of the file
//      * @return the deal IDs
//      */
//     function getDeals(bytes memory data_url) external view returns (uint64[] memory) {
//         return fileToDealIds[data_url];
//     }

//     /**
//      * @notice function to get the current fileId
//      */
//     function getLatestId() external view returns (uint) {
//         return fileId;
//     }

//     /**
//      * @notice function to get all the details about the file
//      * @param _fileId fileId
//      * @return address of the user
//      * @return link of the file
//      * @return deal Id of the file
//      * @return check file is migrated
//      */
//     function getFileDetails(uint _fileId) external view returns (address, bytes memory, uint, bool, bytes memory) {
//         bool fileMigrated = checkMigration(_fileId);
//         return (
//             fileIdToDetails[_fileId].user,
//             fileIdToDetails[_fileId].fileLink,
//             fileIdToDealDetails[_fileId].dealId,
//             fileMigrated,
//             fileIdToDealDetails[_fileId].cid
//         );
//     }
}
