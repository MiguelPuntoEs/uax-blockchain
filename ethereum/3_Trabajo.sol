// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofOfSubmission {
    struct Submission {
        address student;
        uint64 blockNumber;
        uint64 timestamp;
        bytes32 contentHash;
    }

    mapping(bytes32 => Submission) private submissions;

    event Submitted(
        uint256 indexed assignmentId,
        bytes32 indexed contentHash,
        address indexed student,
        uint64 blockNumber,
        uint64 timestamp,
        bytes32 key
    );

    function submit(uint256 assignmentId, bytes32 contentHash) external returns (bytes32 key) {
        require(contentHash != bytes32(0), "Empty hash");

        key = keccak256(abi.encodePacked(assignmentId, contentHash));
        require(submissions[key].student == address(0), "Already submitted");

        Submission memory s = Submission({
            student: msg.sender,
            blockNumber: uint64(block.number),
            timestamp: uint64(block.timestamp),
            contentHash: contentHash
        });

        submissions[key] = s;

        emit Submitted(assignmentId, contentHash, msg.sender, s.blockNumber, s.timestamp, key);
    }

    function exists(uint256 assignmentId, bytes32 contentHash) external view returns (bool) {
        bytes32 key = keccak256(abi.encodePacked(assignmentId, contentHash));
        return submissions[key].student != address(0);
    }

    function getSubmission(uint256 assignmentId, bytes32 contentHash)
        external
        view
        returns (address student, uint64 blockNumber, uint64 timestamp, bytes32 key)
    {
        key = keccak256(abi.encodePacked(assignmentId, contentHash));
        Submission memory s = submissions[key];
        require(s.student != address(0), "Not found");
        return (s.student, s.blockNumber, s.timestamp, key);
    }
}