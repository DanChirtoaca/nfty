pragma solidity >=0.5.6;


import "./ERC721Base.sol";

/**
* @title ERC-721 Non-Fungible Token with token supply storage logic.
*/
contract ERC721BaseTokenSupply is ERC721Base {
  /**
   * Array storing all the token IDs.
   */
   uint256[] private _tokenIDs;

  /**
  * Mapping of the token ID to its index in the array of all token IDs (_tokenIDs).
  */
  mapping(uint256 => uint256) private _tokenIndex;


  /**
   * @dev Gives the current total amount of tokens stored in the contract.
   * @return uint256 Represents the total amount of tokens.
   */
  function _totalSupply()
  internal
  view
  returns (uint256)
  {
    return _tokenIDs.length;
  }

  /**
   * @dev Gives the token ID at the supplied index from all the tokens in the contract.
   * Reverts if the index is greater or equal to the total supply of tokens (i.e. 0 indexed array).
   * @param index uint256 Represents the index to be queried.
   * @return uint256 Token ID at the given index in the global token array.
   */
  function _tokenByIndex
  (
    uint256 index
  )
  internal
  view
  returns (uint256)
  {
    require(index < _totalSupply(), "Index out of bounds.");
    return _tokenIDs[index];
  }

  /**
   * @dev Internal function to add a token (unowned) to an account.
   * @notice Does not emit any transfer event. Overrides parent implementation.
   */
  function _addTokenTo
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    super._addTokenTo(to, tokenID);
    _tokenIDs.push(tokenID);                      // add token to global token array
    _tokenIndex[tokenID] = _tokenIDs.length - 1;  // added token has last index
  }

  /**
   * @dev Internal function to remove a token completely.
   * @notice Does not emit any transfer event. Overrides parent implementation.
   */
  function _removeToken
  (
    uint256 tokenID
  )
  internal
  {
    super._removeToken(tokenID);
    uint256 tokenIndex = _tokenIndex[tokenID];
    uint256 lastTokenID = _tokenIDs[_tokenIDs.length - 1];

    _tokenIDs[tokenIndex] = lastTokenID;   // swap last token with the one to be deleted
    _tokenIDs.pop();                       // delete last token - duplicate

    _tokenIndex[lastTokenID] = tokenIndex; // update index of previously last token in array
    _tokenIndex[tokenID] = 0;              // clear the token index of removed token
  }
}
