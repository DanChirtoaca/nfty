pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract ERC721Burnable is ERC721Base {

  function _burn
  (
    uint256 tokenID
  )
  internal
  {
    address owner = _tokenOwner[tokenID];
    require(owner == msg.sender); // probably needs to be handled in modifier to allow costumizability
    _clearApproval(tokenID);
    _ownedTokenCount[owner]--;   // decrease balance of current token owner
    _tokenApproval[tokenID] = address(0);
  
    emit Transfer(owner, address(0), tokenID);
  }
}