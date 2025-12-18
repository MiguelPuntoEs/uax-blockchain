// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PresentationOrderNames {
    address public immutable teacher;
    uint256 public constant MAX = 15;

    string[] private participants;
    mapping(bytes32 => bool) private isParticipantHash;

    bool public rosterLocked;
    bool public finalized;

    modifier onlyTeacher() {
        require(msg.sender == teacher, "not teacher");
        _;
    }

    constructor() {
        teacher = msg.sender;
    }

    /// Add a participant by name (e.g., "Maria")
    function addParticipant(string calldata name) external onlyTeacher {
        require(!rosterLocked, "roster locked");
        require(participants.length < MAX, "max 15");
        require(bytes(name).length > 0, "empty name");

        bytes32 h = keccak256(bytes(name));
        require(!isParticipantHash[h], "duplicate name");

        isParticipantHash[h] = true;
        participants.push(name);
    }

    function addParticipants(string[] calldata names) external onlyTeacher {
        require(!rosterLocked, "roster locked");
        require(names.length > 0, "empty list");
        require(participants.length + names.length <= MAX, "too many participants");

        for (uint256 i = 0; i < names.length; i++) {
            string calldata name = names[i];
            require(bytes(name).length > 0, "empty name");

            bytes32 h = keccak256(bytes(name));
            require(!isParticipantHash[h], "duplicate name");

            isParticipantHash[h] = true;
            participants.push(name);
        }
    }

    /// Lock roster before shuffling
    function lockRoster() external onlyTeacher {
        require(!rosterLocked, "already locked");
        require(participants.length > 0, "no participants");
        rosterLocked = true;
    }

    /// Shuffle names in-place and finalize
    function finalizeOrder() external onlyTeacher {
        require(rosterLocked, "lock roster first");
        require(!finalized, "already finalized");

        bytes32 seed = keccak256(
            abi.encodePacked(
                blockhash(block.number - 1),
                address(this),
                block.chainid,
                participants.length
            )
        );

        // Fisher–Yates shuffle
        for (uint256 i = participants.length - 1; i > 0; i--) {
            uint256 j = uint256(keccak256(abi.encodePacked(seed, i))) % (i + 1);

            string memory tmp = participants[i];
            participants[i] = participants[j];
            participants[j] = tmp;
        }

        finalized = true;
    }

    /// Get final presentation order
    function getOrder() external view returns (string[] memory) {
        require(finalized, "not finalized yet");
        return participants;
    }

    function participantCount() external view returns (uint256) {
        return participants.length;
    }
}