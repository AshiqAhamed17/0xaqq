// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title OnchainIdentityNFT
 * @author 0xaqq.eth
 * @notice Soulbound ERC721 token representing a wallet's on-chain activity tier.
 * @dev This NFT is non-transferable and can only be minted once per wallet.
 *      The tier and score are computed client-side by the frontend and passed
 *      to the mint function. The contract enforces uniqueness (one per wallet)
 *      and immutability (tier and score cannot be modified after mint).
 *
 *      Trust Model:
 *      - Frontend calculates activity score and determines tier
 *      - Contract enforces: one NFT per wallet, no transfers, no burns
 *      - Tier and score are stored on-chain and cannot be modified
 *      - This is a badge of achievement, not a collectible
 */
contract OnchainIdentityNFT is ERC721 {
    /// @notice Activity tier enumeration
    enum Tier {
        Bronze,
        Silver,
        Gold
    }

    /// @notice Error thrown when attempting to mint a second NFT for the same wallet
    error AlreadyMinted();

    /// @notice Error thrown when attempting to transfer a soulbound token
    error SoulboundToken();

    /// @notice Error thrown when attempting to burn a soulbound token
    error CannotBurn();

    /// @notice Error thrown when an invalid tier is provided
    error InvalidTier();

    /// @notice Mapping to track if an address has already minted
    mapping(address => bool) public hasMinted;

    /// @notice Mapping from tokenId to tier
    mapping(uint256 => Tier) public tokenTier;

    /// @notice Mapping from tokenId to activity score
    mapping(uint256 => uint256) public tokenScore;

    /// @notice Mapping from tokenId to mint timestamp
    mapping(uint256 => uint64) public mintedAt;

    /// @notice Counter for token IDs
    uint256 private _tokenIdCounter;

    /// @notice Event emitted when a new identity NFT is minted
    /// @param to The address that received the NFT
    /// @param tokenId The token ID of the minted NFT
    /// @param tier The tier assigned to the NFT
    /// @param score The activity score assigned to the NFT
    event IdentityMinted(
        address indexed to,
        uint256 indexed tokenId,
        Tier tier,
        uint256 score
    );

    /**
     * @notice Constructor initializes the ERC721 token
     * @param _name The name of the NFT collection
     * @param _symbol The symbol of the NFT collection
     */
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    /**
     * @notice Mint a new identity NFT for the caller
     * @dev Only one NFT can be minted per wallet. The tier and score are
     *      provided by the frontend after client-side calculation.
     *      Reverts if the caller has already minted or if tier is invalid.
     * @param _score The activity score calculated by the frontend
     * @param _tier The tier determined by the frontend based on score
     * @return tokenId The ID of the newly minted token
     */
    function mint(uint256 _score, Tier _tier) external returns (uint256) {
        if (hasMinted[msg.sender]) revert AlreadyMinted();
        if (uint8(_tier) > 2) revert InvalidTier(); // Tier enum has 3 values (0, 1, 2)

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        hasMinted[msg.sender] = true;
        tokenTier[tokenId] = _tier;
        tokenScore[tokenId] = _score;
        mintedAt[tokenId] = uint64(block.timestamp);

        _safeMint(msg.sender, tokenId);

        emit IdentityMinted(msg.sender, tokenId, _tier, _score);

        return tokenId;
    }

    /**
     * @notice Get the tier of a specific token
     * @param _tokenId The token ID to query
     * @return The tier of the token
     */
    function getTier(uint256 _tokenId) external view returns (Tier) {
        _requireOwned(_tokenId);
        return tokenTier[_tokenId];
    }

    /**
     * @notice Get the score of a specific token
     * @param _tokenId The token ID to query
     * @return The score of the token
     */
    function getScore(uint256 _tokenId) external view returns (uint256) {
        _requireOwned(_tokenId);
        return tokenScore[_tokenId];
    }

    /**
     * @notice Get the mint timestamp of a specific token
     * @param _tokenId The token ID to query
     * @return The timestamp when the token was minted
     */
    function getMintedAt(uint256 _tokenId) external view returns (uint64) {
        _requireOwned(_tokenId);
        return mintedAt[_tokenId];
    }

    /**
     * @notice Get all metadata for a specific token
     * @param _tokenId The token ID to query
     * @return tier The tier of the token
     * @return score The score of the token
     * @return mintTimestamp The timestamp when the token was minted
     * @return owner The current owner of the token
     */
    function getTokenMetadata(
        uint256 _tokenId
    )
        external
        view
        returns (
            Tier tier,
            uint256 score,
            uint64 mintTimestamp,
            address owner
        )
    {
        _requireOwned(_tokenId);
        return (
            tokenTier[_tokenId],
            tokenScore[_tokenId],
            mintedAt[_tokenId],
            ownerOf(_tokenId)
        );
    }

    /**
     * @notice Override _update to prevent transfers (soulbound enforcement)
     * @dev Reverts if attempting to transfer from a non-zero address.
     *      Only allows minting (from == address(0)).
     * @param to The address receiving the token
     * @param tokenId The token ID being transferred
     * @param auth The address authorized to perform the transfer
     * @return The previous owner address
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);

        // Allow minting (from == address(0))
        // Prevent all transfers and burns (from != address(0))
        if (from != address(0)) {
            revert SoulboundToken();
        }

        // Call parent _update to perform the mint
        return super._update(to, tokenId, auth);
    }

    /**
     * @notice Override _baseURI to return empty string (on-chain metadata only for V1)
     * @dev For V1, we use on-chain metadata. tokenURI can be overridden
     *      in future versions if needed.
     * @return Empty string (on-chain metadata)
     */
    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    /**
     * @notice Override tokenURI to return minimal metadata
     * @dev Returns a simple JSON-like string with on-chain data.
     *      Can be enhanced in future versions with IPFS or full JSON metadata.
     * @param _tokenId The token ID to query
     * @return A string representation of the token metadata
     */
    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        _requireOwned(_tokenId);

        Tier tier = tokenTier[_tokenId];
        uint256 score = tokenScore[_tokenId];
        uint64 timestamp = mintedAt[_tokenId];

        string memory tierString;
        if (tier == Tier.Bronze) {
            tierString = "Bronze";
        } else if (tier == Tier.Silver) {
            tierString = "Silver";
        } else {
            tierString = "Gold";
        }

        // Minimal JSON-like metadata (V1)
        return
            string(
                abi.encodePacked(
                    '{"name":"Onchain Identity #',
                    _toString(_tokenId),
                    '","tier":"',
                    tierString,
                    '","score":',
                    _toString(score),
                    ',"mintedAt":',
                    _toString(timestamp),
                    "}"
                )
            );
    }

    /**
     * @notice Internal helper to convert uint256 to string
     * @param value The value to convert
     * @return The string representation
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

