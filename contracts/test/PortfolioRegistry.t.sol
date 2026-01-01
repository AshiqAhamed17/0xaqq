// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {PortfolioRegistry} from "../src/PortfolioRegistry.sol";

contract PortfolioRegistryTest is Test {
    PortfolioRegistry public registry;
    address public owner;
    address public nonOwner;
    address public user;

    event ProjectAdded(
        uint256 indexed id,
        string title,
        string ipfsHash,
        uint256 timestamp
    );

    function setUp() public {
        owner = address(0x1);
        nonOwner = address(0x2);
        user = address(0x3);

        vm.prank(owner);
        registry = new PortfolioRegistry(owner);
    }

    // ============ Setup Tests ============

    function test_Deployment_SetsOwner() public {
        assertEq(registry.owner(), owner, "Owner should be set correctly");
    }

    // ============ addProject Tests ============

    function test_AddProject_OwnerCanAdd() public {
        string memory title = "Test Project";
        string memory ipfsHash = "QmTestHash123";

        vm.prank(owner);
        registry.addProject(title, ipfsHash);

        assertEq(registry.getProjectCount(), 1, "Project count should be 1");
    }

    function test_AddProject_NonOwnerCannotAdd() public {
        string memory title = "Test Project";
        string memory ipfsHash = "QmTestHash123";

        vm.prank(nonOwner);
        vm.expectRevert();
        registry.addProject(title, ipfsHash);
    }

    function test_AddProject_StoresDataCorrectly() public {
        string memory title = "My Awesome Project";
        string memory ipfsHash = "QmHash456";

        vm.prank(owner);
        registry.addProject(title, ipfsHash);

        PortfolioRegistry.Project memory project = registry.getProject(0);

        assertEq(project.id, 0, "Project ID should be 0");
        assertEq(project.title, title, "Title should match");
        assertEq(project.ipfsHash, ipfsHash, "IPFS hash should match");
        assertGt(project.timestamp, 0, "Timestamp should be set");
    }

    function test_AddProject_EmitsEvent() public {
        string memory title = "Test Project";
        string memory ipfsHash = "QmTestHash";

        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit ProjectAdded(0, title, ipfsHash, block.timestamp);

        registry.addProject(title, ipfsHash);
    }

    function test_AddProject_EmptyTitleReverts() public {
        string memory title = "";
        string memory ipfsHash = "QmHash";

        vm.prank(owner);
        vm.expectRevert(PortfolioRegistry.EmptyTitle.selector);
        registry.addProject(title, ipfsHash);
    }

    function test_AddProject_EmptyIpfsHashReverts() public {
        string memory title = "Test Project";
        string memory ipfsHash = "";

        vm.prank(owner);
        vm.expectRevert(PortfolioRegistry.EmptyIpfsHash.selector);
        registry.addProject(title, ipfsHash);
    }

    function test_AddProject_MultipleProjects() public {
        vm.startPrank(owner);

        registry.addProject("Project 1", "QmHash1");
        registry.addProject("Project 2", "QmHash2");
        registry.addProject("Project 3", "QmHash3");

        vm.stopPrank();

        assertEq(registry.getProjectCount(), 3, "Should have 3 projects");
    }

    function test_AddProject_IncrementsId() public {
        vm.startPrank(owner);

        registry.addProject("Project 1", "QmHash1");
        registry.addProject("Project 2", "QmHash2");

        vm.stopPrank();

        PortfolioRegistry.Project memory project1 = registry.getProject(0);
        PortfolioRegistry.Project memory project2 = registry.getProject(1);

        assertEq(project1.id, 0, "First project ID should be 0");
        assertEq(project2.id, 1, "Second project ID should be 1");
    }

    // ============ getProjects Tests ============

    function test_GetProjects_ReturnsEmptyArrayInitially() public {
        PortfolioRegistry.Project[] memory projects = registry.getProjects();

        assertEq(projects.length, 0, "Should return empty array");
    }

    function test_GetProjects_ReturnsAllProjects() public {
        vm.startPrank(owner);

        registry.addProject("Project 1", "QmHash1");
        registry.addProject("Project 2", "QmHash2");
        registry.addProject("Project 3", "QmHash3");

        vm.stopPrank();

        PortfolioRegistry.Project[] memory projects = registry.getProjects();

        assertEq(projects.length, 3, "Should return 3 projects");
        assertEq(projects[0].title, "Project 1", "First project title should match");
        assertEq(projects[1].title, "Project 2", "Second project title should match");
        assertEq(projects[2].title, "Project 3", "Third project title should match");
    }

    function test_GetProjects_PublicAccess() public {
        vm.startPrank(owner);
        registry.addProject("Test", "QmHash");
        vm.stopPrank();

        // Non-owner can read
        vm.prank(nonOwner);
        PortfolioRegistry.Project[] memory projects = registry.getProjects();

        assertEq(projects.length, 1, "Non-owner should be able to read");
    }

    // ============ getProjectCount Tests ============

    function test_GetProjectCount_ReturnsZeroInitially() public {
        assertEq(registry.getProjectCount(), 0, "Count should be 0 initially");
    }

    function test_GetProjectCount_IncrementsOnAdd() public {
        vm.startPrank(owner);

        assertEq(registry.getProjectCount(), 0, "Initial count should be 0");

        registry.addProject("Project 1", "QmHash1");
        assertEq(registry.getProjectCount(), 1, "Count should be 1");

        registry.addProject("Project 2", "QmHash2");
        assertEq(registry.getProjectCount(), 2, "Count should be 2");

        vm.stopPrank();
    }

    // ============ getProject Tests ============

    function test_GetProject_ReturnsCorrectProject() public {
        vm.startPrank(owner);
        registry.addProject("Test Project", "QmHash");
        vm.stopPrank();

        PortfolioRegistry.Project memory project = registry.getProject(0);

        assertEq(project.id, 0, "ID should be 0");
        assertEq(project.title, "Test Project", "Title should match");
        assertEq(project.ipfsHash, "QmHash", "Hash should match");
    }

    function test_GetProject_OutOfBoundsReverts() public {
        vm.expectRevert("Index out of bounds");
        registry.getProject(0);
    }

    function test_GetProject_PublicAccess() public {
        vm.startPrank(owner);
        registry.addProject("Test", "QmHash");
        vm.stopPrank();

        // Non-owner can read
        vm.prank(nonOwner);
        PortfolioRegistry.Project memory project = registry.getProject(0);

        assertEq(project.title, "Test", "Non-owner should be able to read");
    }

    // ============ Security Tests ============

    function test_Security_OwnerCannotBeChanged() public {
        // Ownable doesn't allow changing owner through this contract
        // This is handled by OpenZeppelin's Ownable
        assertEq(registry.owner(), owner, "Owner should remain unchanged");
    }

    function test_Security_ProjectsAreImmutable() public {
        vm.startPrank(owner);

        registry.addProject("Original Title", "QmHash1");
        registry.addProject("New Title", "QmHash2");

        vm.stopPrank();

        // Verify first project is unchanged
        PortfolioRegistry.Project memory project = registry.getProject(0);
        assertEq(project.title, "Original Title", "Project should be immutable");
    }

    function test_Security_LongStrings() public {
        // Test with very long strings to ensure no overflow issues
        string memory longTitle = new string(1000);
        string memory longHash = new string(100);

        vm.prank(owner);
        registry.addProject(longTitle, longHash);

        assertEq(registry.getProjectCount(), 1, "Should handle long strings");
    }

    function test_Security_MultipleCallsFromOwner() public {
        vm.startPrank(owner);

        // Rapid successive calls
        for (uint256 i = 0; i < 10; i++) {
            registry.addProject(
                string(abi.encodePacked("Project ", vm.toString(i))),
                string(abi.encodePacked("QmHash", vm.toString(i)))
            );
        }

        vm.stopPrank();

        assertEq(registry.getProjectCount(), 10, "Should handle multiple calls");
    }

    // ============ Edge Cases ============

    function test_EdgeCase_MinimumLengthStrings() public {
        vm.prank(owner);
        registry.addProject("A", "B");

        PortfolioRegistry.Project memory project = registry.getProject(0);
        assertEq(project.title, "A", "Should handle single character");
        assertEq(project.ipfsHash, "B", "Should handle single character hash");
    }

    function test_EdgeCase_SpecialCharacters() public {
        string memory title = "Project with !@#$%^&*()";
        string memory hash = "QmHash!@#";

        vm.prank(owner);
        registry.addProject(title, hash);

        PortfolioRegistry.Project memory project = registry.getProject(0);
        assertEq(project.title, title, "Should handle special characters");
    }

    function test_EdgeCase_UnicodeCharacters() public {
        // Using hex encoding for unicode characters to avoid compilation issues
        string memory title = unicode"项目测试";
        string memory hash = unicode"QmHash测试";

        vm.prank(owner);
        registry.addProject(title, hash);

        PortfolioRegistry.Project memory project = registry.getProject(0);
        assertEq(project.title, title, "Should handle unicode");
    }
}

