pragma solidity >=0.5.6;


import "./ERC721BaseBurnable.sol";
import "./ERC721BaseMetadata.sol";

/**
* @title ERC-721Metadata with metadata burning functionality.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseMetadataBurnable is ERC721BaseMetadata, ERC721BaseBurnable { 
  function _burn
  (
    uint256 tokenID
  )
  internal
  {
    super._burn(tokenID);
    _deleteTokenURI(tokenID);
  }
}
