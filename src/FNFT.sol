// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin ERC-1155 contract
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract FNFT is ERC1155 {
    struct NFT {
        address owner;
        uint256 tokenId;
        uint256 fractions;
        uint256 price;
        bool listed;
    }

    mapping(uint256 => NFT) public nfts;

    uint256 public tokenCounter;

    uint256 public constant feeRate = 10 ** 15;

    event Fractionalized(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed fractionTokenId,
        uint256 fractions,
        uint256 price
    );

    event Listed(
        address indexed owner,
        uint256 indexed fractionTokenId,
        bool listed
    );

    event Bought(
        address indexed buyer,
        address indexed seller,
        uint256 indexed fractionTokenId,
        uint256 fractions
    );

    event Transferred(
        address indexed from,
        address indexed to,
        uint256 indexed fractionTokenId,
        uint256 fractions
    );

    constructor(string memory baseURI) ERC1155(baseURI) {}

    modifier onlyOwner(uint256 tokenId) {
        require(
            msg.sender == nfts[tokenId].owner,
            "Only owner can call this function"
        );
        _;
    }

    function fractionalize(
        address nftContract,
        uint256 tokenId,
        uint256 fractions,
        uint256 price
    ) external {
        IERC721(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        tokenCounter++;

        nfts[tokenCounter] = NFT(msg.sender, tokenId, fractions, price, false);

        _mint(msg.sender, tokenCounter, fractions, "");

        emit Fractionalized(
            msg.sender,
            tokenId,
            tokenCounter,
            fractions,
            price
        );
    }

    function setListStatus(
        uint256 fractionTokenId,
        bool status
    ) external onlyOwner(fractionTokenId) {
        nfts[fractionTokenId].listed = status;

        emit Listed(msg.sender, fractionTokenId, status);
    }

    function buy(uint256 fractionTokenId, uint256 fractions) external payable {
        NFT memory nft = nfts[fractionTokenId];

        require(nft.listed == true, "NFT is not listed for sale");

        require(
            fractions > 0 && fractions <= nft.fractions,
            "Invalid number of fractions"
        );

        require(msg.value == nft.price * fractions, "Incorrect value sent");

        uint256 fee = (msg.value * feeRate) / 10 ** 18;
        uint256 amount = msg.value - fee;

        safeTransferFrom(nft.owner, msg.sender, fractionTokenId, fractions, "");

        payable(nft.owner).transfer(amount);

        emit Bought(msg.sender, nft.owner, fractionTokenId, fractions);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        super.safeTransferFrom(from, to, id, amount, data);

        if (from == nfts[id].owner && amount == nfts[id].fractions) {
            nfts[id].owner = to;
        }

        emit Transferred(from, to, id, amount);
    }
}
