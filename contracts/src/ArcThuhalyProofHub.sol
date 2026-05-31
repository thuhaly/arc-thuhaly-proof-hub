// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ArcThuhalyProofHub {
    address public owner;
    uint256 public nextTaskId;

    struct TaskProof {
        address actor;
        uint256 usdcBudget;
        bytes32 evidenceHash;
        string label;
        bool closed;
    }

    mapping(uint256 => TaskProof) public taskProofs;

    event TaskOpened(uint256 indexed id, address indexed actor, uint256 usdcBudget, bytes32 evidenceHash, string label);
    event TaskClosed(uint256 indexed id, bool accepted, string uri);

    modifier onlyOwner() { require(msg.sender == owner, "only owner"); _; }

    constructor() { owner = msg.sender; }

    function openTask(uint256 usdcBudget, bytes32 evidenceHash, string calldata label) external returns (uint256 id) {
        require(usdcBudget > 0, "budget=0");
        require(evidenceHash != bytes32(0), "evidence=0");
        require(bytes(label).length > 2, "label short");
        id = ++nextTaskId;
        taskProofs[id] = TaskProof(msg.sender, usdcBudget, evidenceHash, label, false);
        emit TaskOpened(id, msg.sender, usdcBudget, evidenceHash, label);
    }

    function closeTask(uint256 id, bool accepted, string calldata uri) external onlyOwner {
        TaskProof storage proof = taskProofs[id];
        require(proof.actor != address(0), "unknown");
        require(!proof.closed, "closed");
        proof.closed = true;
        emit TaskClosed(id, accepted, uri);
    }
}
