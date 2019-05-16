<%!
  from dsl_util import put, modify
%>
<%

  pause = put(data, 'pausable')
%>
pragma solidity >=0.5.6;


import "./ERC721Base.sol";

/**
* @title ERC721Extended contract that allows for storing token data.
*/
contract ERC721Extended is ERC721Base {
  struct TokenData
  {
    ${token_struct_data}
  }

  /**
    * @dev Mapping from token ID to token data.
    */
  mapping (uint256 => TokenData) internal _tokenData;

  /**
    * @dev Mapping from token ID to bool determining whether the token data was set.
    */
  mapping (uint256 => bool) private _hasTokenData;


  /**
   * @dev Exernal function that allows to set the token data for a token.
   * This is a one time setter.
   * @notice This is a Mock function. Has to be extended with the eventual fields of the struct
   */
  function setTokenData
  (
    uint256 tokenID,
    ${token_setter_data}
  )
  external
  ${modify(data, "setTokenData")}
  ${pause}
  {
  TokenData memory tokenData = TokenData(${token_constructor_data}); // use provided arguments of the struct
    _setTokenData(tokenID, tokenData);
  }

  /**
   * @dev Mock function to return token data for given tokenID. Should return all fields in the
   * defined TokenData struct
   */
  function getTokenData
  (
    uint256 tokenID
  )
  external
  view
  ${modify(data, "getTokenData")}
  returns (uint256,bool)
  {
    require(_tokenExists(tokenID), "Token does not exist.");
    require(_hasTokenData[tokenID], "Token has no token data.");

    TokenData memory tokenData = _tokenData[tokenID];
    return (0, true); // should return a tuple containing the fields of the struct
  }

  /**
   * @dev Internal function to remove a token from the owner's account. Override parent implementation.
   * @notice Does not emit any transfer event. Does not check token permissions.
   */
  function _removeToken
  (
    uint256 tokenID
  )
  internal
  {
    super._removeToken(tokenID);
    delete _tokenData[tokenID];
  }

  /**
   * @dev Internal function to set the token data struct for a token.
   * @notice Does not check token permissions. Can be called once per token.
   */
  function _setTokenData
  (
    uint256 tokenID,
    TokenData memory tokenData
  )
  internal
  {
    require(_tokenExists(tokenID), "Token does not exist.");
    require(!_hasTokenData[tokenID], "Token already has token data.");
    _hasTokenData[tokenID] = true;
    _tokenData[tokenID] = tokenData;
  }
}
