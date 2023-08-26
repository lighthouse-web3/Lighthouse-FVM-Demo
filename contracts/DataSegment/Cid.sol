// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./Const.sol";

/**
 * @title Cid
 * @dev Cid is a library for converting between CIDs and piece commitments.
 */
library Cid {
    /**
     * @dev CID_COMMP_HEADER is the header of a CID for a piece commitment
     */
    function cidToPieceCommitment(bytes memory _cb) public pure returns (bytes32) {
        require(_cb.length == CID_COMMP_HEADER_LENGTH + MERKLE_TREE_NODE_SIZE, "wrong length of CID");
        require(
            keccak256(abi.encodePacked(_cb[0], _cb[1], _cb[2], _cb[3], _cb[4], _cb[5], _cb[6])) ==
                keccak256(abi.encodePacked(CID_COMMP_HEADER)),
            "wrong content of CID header"
        );
        bytes32 res;
        assembly {
            res := mload(add(add(_cb, CID_COMMP_HEADER_LENGTH), MERKLE_TREE_NODE_SIZE))
        }
        return res;
    }

    /**
     * @dev pieceCommitmentToCid converts a piece commitment to a CID
     */
    function pieceCommitmentToCid(bytes32 _commp) public pure returns (bytes memory) {
        bytes memory cb = abi.encodePacked(CID_COMMP_HEADER, _commp);
        return cb;
    }
}