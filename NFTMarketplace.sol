// SPDX: License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public owner;

    struct Listing {
        uint256 price;
        address seller;
        bool isActive;
    }

  mapping(uint256 => Listing) public listings;

  // events to emit once the NFT is listed and sold 
  event NFTListed(uint256 indexed tokenId, uint256 price, address indexed seller);
  event NFTSold(uint256 indexed tokenId, uint256 price, address indexed buyer, address indexed seller);

constructoERC721("NFTMarketplace", "NFTM") {
        owner = payable(msg.sender);
    }

  // NFT Minting function which takes address on which the NFT is to be minted and returning NFT Token Id.
  //The function mintNFT increments the token id once someone calls the function, sets the latest token id, uses the _mint function from ERC721.sol contract and at the end returns the tokenid with name newItemId.

  function mintNFT(address to) external returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        return newItemId;
    }

    //  a listing NFT function to sale the NFT. The function first list the NFT on the marketplace taking in token Id and price of the NFT.
    //First we need to create an event that will be emitted once the NFT is listed. 
    // The listing NFT function checks the conditions like does the NFT exists, are you the owner, and is price more than 0. Once these conditions are met only then the NFT is listed and the event is triggered. 

function listNFTForSale(uint256 tokenId, uint256 price) external {
       require(ownerOf(tokenId) != address(0), "Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(price > 0, "Price must be greater than zero");

        listings[tokenId] = Listing(price, msg.sender, true);
        emit NFTListed(tokenId, price, msg.sender);
    }
// a buyNFT function to buy the NFT. The function takes in token id as a parameter and emits the event once someone buys the NFT.
//The function adds the condition that is the NFT listed or not and checks that is sufficient balance exists in the account buying the NFT,
//Once the condition is met, the ownership is transferred followed by the price of the NFT from buyer to the owner of the NFT. The NFT is then delisted from the marketplace and an event is emitted reflecting the important information of the transaction

    function buyNFT(uint256 tokenId) external payable {
        require(listings[tokenId].isActive, "This NFT is not listed for sale");
        require(msg.value >= listings[tokenId].price, "Insufficient payment");

        address payable seller = payable(listings[tokenId].seller);
        seller.transfer(listings[tokenId].price);
        _transfer(seller, msg.sender, tokenId);
        listings[tokenId].isActive = false;
        emit NFTSold(tokenId, listings[tokenId].price, msg.sender, seller);
    }
// a function to get the details of the NFT by taking in the Token ID and returning price, seller, and status of the listing. 
// The function uses the structure and mapping parameters to get the value and reflect the details from the structure of the provided NFT or Token ID

    function inquireByTokenId(uint256 tokenId) external view returns (uint256 price, address seller, bool isActive) {
        Listing memory listing = listings[tokenId];
        return (listing.price, listing.seller, listing.isActive);
    }
}
