// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PortfolioRegistry
 * @author 0xaqq.eth
 * @notice Immutable on-chain registry for portfolio projects.
 * @dev Projects are stored in an array and can only be added by the owner.
 *      Once added, projects cannot be modified or removed (immutable).
 */
contract PortfolioRegistry is Ownable {
    /// @notice Project struct containing project information
    struct Project {
        uint256 id;
        string title;
        string ipfsHash;
        uint256 timestamp;
    }

    /// @notice Array of all projects
    Project[] private projects;

    /// @notice Event emitted when a new project is added
    /// @param id The unique identifier of the project
    /// @param title The title of the project
    /// @param ipfsHash The IPFS hash containing project metadata
    /// @param timestamp The block timestamp when the project was added
    event ProjectAdded(
        uint256 indexed id,
        string title,
        string ipfsHash,
        uint256 timestamp
    );

    /// @notice Error thrown when attempting to add a project with empty title
    error EmptyTitle();

    /// @notice Error thrown when attempting to add a project with empty IPFS hash
    error EmptyIpfsHash();

    /**
     * @notice Constructor sets the initial owner of the contract
     * @param _initialOwner The address that will be the owner of the contract
     */
    constructor(address _initialOwner) Ownable(_initialOwner) {}

    /**
     * @notice Add a new project to the registry
     * @dev Only the owner can add projects. Projects are immutable once added.
     * @param _title The title of the project
     * @param _ipfsHash The IPFS hash containing project metadata (description, repo, etc.)
     */
    function addProject(
        string calldata _title,
        string calldata _ipfsHash
    ) external onlyOwner {
        if (bytes(_title).length == 0) revert EmptyTitle();
        if (bytes(_ipfsHash).length == 0) revert EmptyIpfsHash();

        uint256 projectId = projects.length;
        uint256 timestamp = uint64(block.timestamp);

        projects.push(
            Project({
                id: projectId,
                title: _title,
                ipfsHash: _ipfsHash,
                timestamp: timestamp
            })
        );

        emit ProjectAdded(projectId, _title, _ipfsHash, timestamp);
    }

    /**
     * @notice Get all projects in the registry
     * @return An array of all projects
     */
    function getProjects() external view returns (Project[] memory) {
        return projects;
    }

    /**
     * @notice Get the total number of projects
     * @return The count of projects in the registry
     */
    function getProjectCount() external view returns (uint256) {
        return projects.length;
    }

    /**
     * @notice Get a specific project by index
     * @param _index The index of the project (0-based)
     * @return The project at the given index
     */
    function getProject(uint256 _index) external view returns (Project memory) {
        require(_index < projects.length, "Index out of bounds");
        return projects[_index];
    }
}
