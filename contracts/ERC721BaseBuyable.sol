pragma solidity >=0.5.6;


import "./ERC721Base.sol";

/**
 * @title ERC721BaseBuyable - extension to the basic ERC721 that adds ability to
 * create/cancel auctions on tokens, add/remove bids, and withdraw funds from lost bids
 * as well as funds from completing an auction.
 */
contract ERC721BaseBuyable is ERC721Base {

  struct Auction
  {
    uint256 price;          // in wei
    bool isForSale;
  }

  struct Bid
  {
    address bidder;
    uint256 value;
  }
  /**
   * Mapping of tokenIDs to their auction. A token can have at most one open auction on it.
   */
  mapping (uint256 => Auction) private _tokenAuction;

  /**
   * Mapping of the current highest bid for given tokenID.
   * @notice A zero value means no current highest bid available, or the bid was reset to
   * zero after it was cancelled.
   */
  mapping (uint256 => Bid) private _tokenBid; 

  /**
   * Mapping of all addresses that can withdraw ether from the contract either after
   * canceling a bid or completing an auction (accepting a bid).
   */
  mapping (address => uint256) private _pendingWithdrawal;
 
  
  /**
   * @dev Allows to open an auction for a token with a definied initial price. Requires to be 
   * called by the owner of the token or an approved operator.
   */
  function createAuction
  (
    uint256 tokenID,
    uint128 price
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    require(!_isOnAuction(tokenID));  // no auction should be available already
    Auction memory auction = Auction(price, true);
    _tokenAuction[tokenID] = auction;
  }

  /**
   * @dev Allows the owner of the token or an approved operator to cancel an opened auction.
   * If there exists a valid bid, its value is added to the withdrawal mapping.
   */
  function cancelAuction
  (
    uint256 tokenID
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    delete _tokenAuction[tokenID];

    if (_tokenBid[tokenID].bidder != address(0) && _tokenBid[tokenID].value > 0)
    {
      uint256 amount = _tokenBid[tokenID].value;
      address bidder = _tokenBid[tokenID].bidder;
      delete _tokenBid[tokenID];
      _pendingWithdrawal[bidder] += amount;
    }
  }

  /**
   * @dev External function that returns whether token is currently in an open auction.
   */
  function isOnAuction
  (
    uint256 tokenID
  )
  external
  view
  returns (bool)
  {
    return _isOnAuction(tokenID);
  }

  /**
   * @dev Actual implementation of the isOnAuction function.
   */
  function _isOnAuction
  (
    uint256 tokenID
  )
  internal
  view
  returns (bool)
  {
    return _tokenAuction[tokenID].isForSale;
  }

  /**
   * @dev External function that returns the price for a token on auction. 
   * Throws if the token is not currently in an open auction.
   */
  function getTokenPrice
  (
    uint256 tokenID
  )
  external
  view
  returns (uint256)
  {
    require(_isOnAuction(tokenID));
    return _tokenAuction[tokenID].price;
  }

  /**
   * @dev External function that allows to bid on a token in a currently open auction.
   * Throws if the eth value is less than the minimum price in the auction, or if the proposed
   * bid does not exceed the current one in value.
   * @notice A bid with eth value 0 will always be rejected.
   */
  function bid
  (
    uint256 tokenID
  )
  external
  payable
  {
    Auction memory auction = _tokenAuction[tokenID];
    require(_isOnAuction(tokenID));
    require(msg.value >= auction.price);

    Bid memory currentBid = _tokenBid[tokenID];
    require(msg.value > currentBid.value);

    _pendingWithdrawal[currentBid.bidder] += currentBid.value; //add refund to the current highest bidder
    _tokenBid[tokenID] = Bid(msg.sender, msg.value);           // update the highest bid with the new one   
  }

  /**
   * @dev External function allowing token owner to complete the auction by accepting the
   * current highest bid and transfer token ownership to new owner.
   * Throws if the current highest bid does not meet the desired minimum value. 
   */
  function acceptBid
  (
    uint256 tokenID,
    uint256 minValue
  )
  external
  {
    require(_isApprovedOrOwner(msg.sender, tokenID));
    uint256 amount = _tokenBid[tokenID].value;
    address bidder = _tokenBid[tokenID].bidder;
    require(amount >= minValue);    
    delete _tokenAuction[tokenID];
    delete _tokenBid[tokenID];
    _pendingWithdrawal[_ownerOf(tokenID)] += amount;

    _transferFrom(_ownerOf(tokenID), bidder, tokenID);
  }

  /**
   * @dev Allows current highest bidder to cancel their bid and get a refund.
   * @notice Highest bid is deleted (zeroed).
   */
  function cancelBid
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

  /**
   * @dev External function that allows to withdraw any funds sent to this contract 
   * in the form of a bid to a token auction or as a result of selling a token thorugh an auction.
   * @notice If a bid is still active, cancelBid function will refund the bidder. Thus, if a bidder
   * bids more than once, they might need to call both these functions if they decide to get
   * their funds back.
   */
  function withdraw() 
  external 
  {
    uint amount = _pendingWithdrawal[msg.sender];
    // Remember to zero the pending refund before
    // sending to prevent re-entrancy attacks
    _pendingWithdrawal[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  /**
   * @notice Overrides the implementation of the transferFrom function. A token cannot be
   * transfered if it is in an open auction.
   */
  function _transferFrom
  (
    address from, 
    address to, 
    uint256 tokenID
  ) 
  internal 
  {
    require(!_isOnAuction(tokenID));
    super._transferFrom(from, to, tokenID);
  }
}
