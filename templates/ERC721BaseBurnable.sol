<%!
  from dsl_util import put, modify
%>
<%
  pause = put(data, 'pause')
%>
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

  /**
  * @dev External function that exposes the burning of a token.
  */
  function burn
  (
    uint256 tokenID
  )
  external
  ${modify(data, "burn")}
  ${pause}
  {
    _burn(tokenID);
  }
}
