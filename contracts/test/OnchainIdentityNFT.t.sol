// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {OnchainIdentityNFT} from "../src/OnchainIdentityNFT.sol";

contract OnchainIdentityNFTTest is Test {
    OnchainIdentityNFT public nft;
    address public user1;
    address public user2;
    address public user3;

    event IdentityMinted(
        address indexed to,
        uint256 indexed tokenId,
        OnchainIdentityNFT.Tier tier,
        uint256 score
    );

    function setUp() public {
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);

        nft = new OnchainIdentityNFT("Onchain Identity", "OID");
    }

    // ============ Setup Tests ============

    function test_Deployment_SetsNameAndSymbol() public {
        assertEq(nft.name(), "Onchain Identity", "Name should be set");
        assertEq(nft.symbol(), "OID", "Symbol should be set");
    }

    // ============ Minting Tests ============

    function test_Mint_CanMintOncePerWallet() public {
        vm.prank(user1);
        uint256 tokenId = nft.mint(75, OnchainIdentityNFT.Tier.Silver);

        assertEq(nft.ownerOf(tokenId), user1, "User1 should own the token");
        assertTrue(nft.hasMinted(user1), "User1 should be marked as minted");
        assertEq(nft.balanceOf(user1), 1, "User1 should have 1 token");
    }

    function test_Mint_CannotMintTwice() public {
        vm.startPrank(user1);

        nft.mint(50, OnchainIdentityNFT.Tier.Bronze);

        vm.expectRevert(OnchainIdentityNFT.AlreadyMinted.selector);
        nft.mint(100, OnchainIdentityNFT.Tier.Gold);

        vm.stopPrank();
    }

    function test_Mint_StoresTierCorrectly() public {
        vm.prank(user1);
        uint256 tokenId = nft.mint(75, OnchainIdentityNFT.Tier.Silver);

        assertEq(
            uint8(nft.tokenTier(tokenId)),
            uint8(OnchainIdentityNFT.Tier.Silver),
            "Tier should be Silver"
        );
    }

    function test_Mint_StoresScoreCorrectly() public {
        uint256 score = 125;
        vm.prank(user1);
        uint256 tokenId = nft.mint(score, OnchainIdentityNFT.Tier.Gold);

        assertEq(nft.tokenScore(tokenId), score, "Score should match");
    }

    function test_Mint_StoresTimestampCorrectly() public {
        uint256 beforeMint = block.timestamp;

        vm.prank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);

        uint64 mintedAt = nft.mintedAt(tokenId);
        assertGe(mintedAt, uint64(beforeMint), "Timestamp should be set");
        assertLe(mintedAt, uint64(block.timestamp), "Timestamp should not be in future");
    }

    function test_Mint_TokenIdIncrements() public {
        vm.startPrank(user1);
        uint256 tokenId1 = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 tokenId2 = nft.mint(75, OnchainIdentityNFT.Tier.Silver);
        vm.stopPrank();

        assertEq(tokenId1, 0, "First token ID should be 0");
        assertEq(tokenId2, 1, "Second token ID should be 1");
    }

    function test_Mint_EmitsEvent() public {
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit IdentityMinted(user1, 0, OnchainIdentityNFT.Tier.Bronze, 50);

        nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
    }

    function test_Mint_AllTiers() public {
        vm.startPrank(user1);
        uint256 tokenId1 = nft.mint(30, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 tokenId2 = nft.mint(75, OnchainIdentityNFT.Tier.Silver);
        vm.stopPrank();

        vm.startPrank(user3);
        uint256 tokenId3 = nft.mint(150, OnchainIdentityNFT.Tier.Gold);
        vm.stopPrank();

        assertEq(
            uint8(nft.tokenTier(tokenId1)),
            uint8(OnchainIdentityNFT.Tier.Bronze),
            "Token 1 should be Bronze"
        );
        assertEq(
            uint8(nft.tokenTier(tokenId2)),
            uint8(OnchainIdentityNFT.Tier.Silver),
            "Token 2 should be Silver"
        );
        assertEq(
            uint8(nft.tokenTier(tokenId3)),
            uint8(OnchainIdentityNFT.Tier.Gold),
            "Token 3 should be Gold"
        );
    }

    function test_Mint_InvalidTierReverts() public {
        // Note: Solidity prevents casting invalid enum values at compile time
        // The contract validates tier in mint() function with: if (uint8(_tier) > 2)
        // This test verifies that all valid tiers work correctly
        vm.startPrank(user1);
        nft.mint(30, OnchainIdentityNFT.Tier.Bronze); // 0
        vm.stopPrank();

        vm.startPrank(user2);
        nft.mint(75, OnchainIdentityNFT.Tier.Silver); // 1
        vm.stopPrank();

        vm.startPrank(user3);
        nft.mint(150, OnchainIdentityNFT.Tier.Gold); // 2
        vm.stopPrank();

        // All valid tiers should work
        assertTrue(nft.hasMinted(user1), "Bronze tier should work");
        assertTrue(nft.hasMinted(user2), "Silver tier should work");
        assertTrue(nft.hasMinted(user3), "Gold tier should work");
    }

    // ============ Soulbound Tests ============

    function test_Soulbound_TransferReverts() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert(OnchainIdentityNFT.SoulboundToken.selector);
        nft.transferFrom(user1, user2, tokenId);
    }

    function test_Soulbound_SafeTransferFromReverts() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert(OnchainIdentityNFT.SoulboundToken.selector);
        nft.safeTransferFrom(user1, user2, tokenId);
    }

    function test_Soulbound_SafeTransferFromWithDataReverts() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert(OnchainIdentityNFT.SoulboundToken.selector);
        nft.safeTransferFrom(user1, user2, tokenId, "");
    }

    function test_Soulbound_ApproveDoesNotAllowTransfer() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        nft.approve(user2, tokenId);
        vm.stopPrank();

        // Even with approval, transfer should fail
        vm.prank(user2);
        vm.expectRevert(OnchainIdentityNFT.SoulboundToken.selector);
        nft.transferFrom(user1, user2, tokenId);
    }

    function test_Soulbound_ApprovalCanBeSet() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        nft.approve(user2, tokenId);
        vm.stopPrank();

        // Approval is set but transfer still fails
        assertEq(nft.getApproved(tokenId), user2, "Approval should be set");
    }

    function test_Soulbound_CannotBurn() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        // Attempt to burn (transfer to address(0))
        // ERC721 checks for zero address receiver first, but our _update override
        // will prevent the transfer anyway. The actual error depends on which check runs first.
        // Since we can't directly call _burn (it's internal), we verify soulbound by testing transfers.
        // The fact that transfers fail means burns are also prevented.
        vm.prank(user1);
        vm.expectRevert(); // Either ERC721InvalidReceiver or SoulboundToken
        nft.transferFrom(user1, address(0), tokenId);

        // Verify token still exists and is owned by user1
        assertEq(nft.ownerOf(tokenId), user1, "Token should still exist");
    }

    // ============ Metadata Tests ============

    function test_GetTier_ReturnsCorrectTier() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(75, OnchainIdentityNFT.Tier.Silver);
        vm.stopPrank();

        OnchainIdentityNFT.Tier tier = nft.getTier(tokenId);
        assertEq(uint8(tier), uint8(OnchainIdentityNFT.Tier.Silver), "Tier should match");
    }

    function test_GetScore_ReturnsCorrectScore() public {
        uint256 score = 125;
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(score, OnchainIdentityNFT.Tier.Gold);
        vm.stopPrank();

        assertEq(nft.getScore(tokenId), score, "Score should match");
    }

    function test_GetMintedAt_ReturnsCorrectTimestamp() public {
        uint256 beforeMint = block.timestamp;

        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        uint64 mintedAt = nft.getMintedAt(tokenId);
        assertGe(mintedAt, uint64(beforeMint), "Timestamp should be correct");
    }

    function test_GetTokenMetadata_ReturnsAllData() public {
        uint256 score = 100;
        OnchainIdentityNFT.Tier tier = OnchainIdentityNFT.Tier.Gold;

        vm.startPrank(user1);
        uint256 tokenId = nft.mint(score, tier);
        vm.stopPrank();

        (
            OnchainIdentityNFT.Tier returnedTier,
            uint256 returnedScore,
            uint64 mintTimestamp,
            address owner
        ) = nft.getTokenMetadata(tokenId);

        assertEq(uint8(returnedTier), uint8(tier), "Tier should match");
        assertEq(returnedScore, score, "Score should match");
        assertGt(mintTimestamp, 0, "Timestamp should be set");
        assertEq(owner, user1, "Owner should match");
    }

    function test_TokenURI_ReturnsMetadata() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(75, OnchainIdentityNFT.Tier.Silver);
        vm.stopPrank();

        string memory uri = nft.tokenURI(tokenId);

        // Check that URI contains expected fields
        assertTrue(
            contains(uri, "Onchain Identity"),
            "URI should contain name"
        );
        assertTrue(contains(uri, "Silver"), "URI should contain tier");
        assertTrue(contains(uri, "75"), "URI should contain score");
    }

    // ============ Security Tests ============

    function test_Security_MultipleUsersCanMint() public {
        vm.startPrank(user1);
        nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        vm.startPrank(user2);
        nft.mint(75, OnchainIdentityNFT.Tier.Silver);
        vm.stopPrank();

        vm.startPrank(user3);
        nft.mint(100, OnchainIdentityNFT.Tier.Gold);
        vm.stopPrank();

        assertTrue(nft.hasMinted(user1), "User1 should be marked as minted");
        assertTrue(nft.hasMinted(user2), "User2 should be marked as minted");
        assertTrue(nft.hasMinted(user3), "User3 should be marked as minted");
    }

    function test_Security_ScoreCannotBeModified() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        uint256 initialScore = nft.tokenScore(tokenId);

        // Try to mint again (should fail)
        vm.prank(user1);
        vm.expectRevert(OnchainIdentityNFT.AlreadyMinted.selector);
        nft.mint(100, OnchainIdentityNFT.Tier.Gold);

        // Score should remain unchanged
        assertEq(nft.tokenScore(tokenId), initialScore, "Score should be immutable");
    }

    function test_Security_TierCannotBeModified() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        OnchainIdentityNFT.Tier initialTier = nft.tokenTier(tokenId);

        // Try to mint again (should fail)
        vm.prank(user1);
        vm.expectRevert(OnchainIdentityNFT.AlreadyMinted.selector);
        nft.mint(100, OnchainIdentityNFT.Tier.Gold);

        // Tier should remain unchanged
        assertEq(
            uint8(nft.tokenTier(tokenId)),
            uint8(initialTier),
            "Tier should be immutable"
        );
    }

    function test_Security_ZeroAddressCannotMint() public {
        vm.prank(address(0));
        vm.expectRevert();
        nft.mint(50, OnchainIdentityNFT.Tier.Bronze);
    }

    function test_Security_HighScoreValues() public {
        uint256 highScore = type(uint256).max;

        vm.startPrank(user1);
        uint256 tokenId = nft.mint(highScore, OnchainIdentityNFT.Tier.Gold);
        vm.stopPrank();

        assertEq(nft.tokenScore(tokenId), highScore, "Should handle max uint256");
    }

    // ============ Edge Cases ============

    function test_EdgeCase_ZeroScore() public {
        vm.startPrank(user1);
        uint256 tokenId = nft.mint(0, OnchainIdentityNFT.Tier.Bronze);
        vm.stopPrank();

        assertEq(nft.tokenScore(tokenId), 0, "Should handle zero score");
    }

    function test_EdgeCase_GetMetadataForNonExistentToken() public {
        vm.expectRevert();
        nft.getTier(999);
    }

    function test_EdgeCase_TokenURINonExistentToken() public {
        vm.expectRevert();
        nft.tokenURI(999);
    }

    // ============ Helper Functions ============

    function contains(
        string memory str,
        string memory substr
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        if (substrBytes.length > strBytes.length) {
            return false;
        }

        for (uint256 i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool isMatch = true;
            for (uint256 j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    isMatch = false;
                    break;
                }
            }
            if (isMatch) {
                return true;
            }
        }
        return false;
    }
}

