pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract ERC721BaseBurnable is ERC721Base {
  /**
    * @dev Internal function that performs burning of a token.
    */
  function _burn
  (
    uint256 tokenID
  )
  internal
  {
    _removeToken(tokenID);
    emit Transfer(_ownerOf(tokenID), address(0), tokenID);
  }
}