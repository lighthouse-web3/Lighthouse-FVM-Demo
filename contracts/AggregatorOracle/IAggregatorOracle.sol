// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../DataSegment/Proof.sol";

/**
 * @title IAggregatorOracle
 * @dev IAggregatorOracle is an interface for an oracle that is used by the aggregator
 */
interface IAggregatorOracle {
    struct Deal {
        // A unique identifier for the deal.
        uint64 dealId;
        // The miner that is storing the data for the deal.
        uint64 minerId;
    }

    // Submit Aggregator Request Event
    event SubmitAggregatorRequest(
        uint256 indexed transactionId,
        bytes fileLink,
        address userAddress,
        bytes miner,
        uint num_copies,
        uint repair_threshold,
        uint renew_threshold);

    // Complete Aggregator Request Event
    event CompleteAggregatorRequest(uint256 indexed _id, uint64 indexed _dealId);

    /**
     * @dev submit submits a new request to the oracle
     * @param fileLink is the cid of the data segment
     * @return id the transaction ID
     */
    function submit(bytes memory fileLink,
        bytes memory miner,
        uint num_copies,
        uint repair_threshold,
        uint renew_threshold) external returns (uint256);

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
    ) external returns (InclusionAuxData memory);

    /**
     * @notice function to store file ID against deal Id
     * @param _transactionId unique id of file
     * @param _dealId deal id
     * @param _cid of the file
     * @dev called by the lighthouse aggregator backend
     */
    function setDealDetails(uint _transactionId, uint _dealId, bytes memory _cid) external;

    /**
     * @dev getAllDeals returns all deals for a given cid
     * @param _cid is the cid of the data segment
     * @return the deal IDs
     */
    function getAllDeals(bytes memory _cid) external returns (Deal[] memory);

    /**
     * @dev getActiveDeals returns all active deals for a given cid
     * @param _cid is the cid of the data segment
     * @return the deal IDs
     */
    function getActiveDeals(bytes memory _cid) external returns (Deal[] memory);

    /**
     * @dev getExpiringDeals returns all deals for a given cid if they are expiring within `epochs`
     * @param _cid is the cid of the data segment
     * @param epochs is the further more epochs
     * @return the deal IDs
     */
    function getExpiringDeals(bytes memory _cid, uint64 epochs) external returns (Deal[] memory);

    /**
     * @notice function to get the Deal id and CID from file id
     * @param _transactionId unique id of file
     * @dev called by the user
     */
    function getDealDetails(uint _transactionId) external view returns (bytes memory, uint);
}
