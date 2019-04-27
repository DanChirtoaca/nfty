// offers and bids
// place offer/ cancel offer
// place bid/ widthdraw bid
// ovverride transfer function

pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract Buyable is ERC721Base {

  struct Offer
  {
    uint256 price;          // in wei
    bool isForSale;
  }

  struct Bid
  {
    address bidder;
    uint256 value;
  }

  mapping (uint256 => Offer) private _tokenOffer;
  mapping (uint256 => Bid) private _tokenBid; // current highest bid for token
  mapping (address => uint256) private _paymentRefund;
 
  

  function createOffer
  (
    uint256 tokenID,
    uint128 price
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    Offer memory offer = Offer(price, true);
    _tokenOffer[tokenID] = offer;
  }

  function cancelOffer
  (
    uint256 tokenID
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    delete _tokenOffer[tokenID];
  }

  function isOnOffer
  (
    uint256 tokenID
  )
  external
  view
  returns (bool)
  {
    return _tokenOffer[tokenID].isForSale;
  }

  function getTokenPrice
  (
    uint256 tokenID
  )
  external
  view
  returns (uint256)
  {
    Offer memory offer = _tokenOffer[tokenID];
    require(offer.isForSale);
    return offer.price;
  }

  function bid
  (
    uint256 tokenID
  )
  external
  payable
  {
    Offer memory offer = _tokenOffer[tokenID];
    require(offer.isForSale);
    require(msg.value >= offer.price);

    Bid memory currentBid = _tokenBid[tokenID];
    require(msg.value > currentBid.value);

    _paymentRefund[currentBid.bidder] += currentBid.value; //preserve refund info on current highest bidder
    _tokenBid[tokenID] = Bid(msg.sender, msg.value);    
  }

  function acceptBid
  (
    uint256 tokenID,
    uint256 minValue
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    Bid memory currentBid = _tokenBid[tokenID];

    require(currentBid.value >= minValue);

    address tokenOwner = _ownerOf(tokenID);
    _transferFrom(tokenOwner, currentBid.bidder, tokenID);

    delete _tokenOffer[tokenID];
    uint256 amount = currentBid.value;
    delete _tokenBid[tokenID];
    _paymentRefund[tokenOwner] += amount;
  }

  function removeBid
  (
    uint256 tokenID
  )
  external
  {
    Bid memory currentBid = _tokenBid[tokenID];
    require(currentBid.bidder == msg.sender);

    uint256 amount = currentBid.value;
    delete _tokenBid[tokenID];
    
    msg.sender.transfer(amount);
  }

  function withdraw() 
  public 
  {
    uint amount = _paymentRefund[msg.sender];
    // Remember to zero the pending refund before
    // sending to prevent re-entrancy attacks
    _paymentRefund[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  /**
   * @notice Overrides the implementation of the transferFrom function.
   */
  function _transferFrom
  (
    address from, 
    address to, 
    uint256 tokenID
  ) 
  internal 
  {
    Offer memory offer = _tokenOffer[tokenID];
    require(!offer.isForSale);
    super._transferFrom(from, to, tokenID);
  }
}
