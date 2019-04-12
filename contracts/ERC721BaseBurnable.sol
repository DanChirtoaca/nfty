pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract ERC721BaseBurnable is ERC721Base {

  function _burn
  (
    uint256 tokenID
  )
  internal
  {
    //require(_isApprovedOrOwner(msg.sender, tokenID)); 
    /**
     * @notice Above line -> most likely an extension on the basic burning functionality 
     */
    _removeToken(tokenID);
    emit Transfer(_ownerOf(tokenID), address(0), tokenID);
  }
}