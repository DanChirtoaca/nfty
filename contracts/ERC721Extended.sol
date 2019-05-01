pragma solidity >=0.5.6;


import "./ERC721Base.sol";

/**
* @title ERC721Extended contract that allows for storing token data.
*/
contract ERC721Extended is ERC721Base {
  struct TokenData
  {
    uint256 hashValue; // barebones example, this can be costumized (i.e. extend the struct)
  }


  /**
    * @dev Mapping from token ID to token data.
    */
  mapping (uint256 => TokenData) internal _tokenData;


  function _getTokenData
  (
    uint256 tokenID
  )
  internal
  view
  returns (TokenData memory)
  {
    require(_tokenExists(tokenID));
    return _tokenData[tokenID];

  }
}
