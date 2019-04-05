pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract ERC721BaseMintable is ERC721Base {
  
  function _mint
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    require(to != address(0));
    require(!_tokenExists(tokenID));

    _tokenOwner[tokenID] = to;
    _ownedTokenCount[to]++;     // increase balance of target owner

    emit Transfer(address(0), to, tokenID);
  }
}