pragma solidity >=0.5.6;


import "./ERC721BaseMintable.sol";
import "./ERC721BaseMetadata.sol";

/**
* @title ERC-721Metadata with metadata minting functionality.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseMetadataMintable is ERC721BaseMetadata, ERC721BaseMintable { 
  function _mintWithURI
  (
    address to,
    uint256 tokenID,
    string memory uri
  )
  internal
  {
    _mint(to, tokenID);
    _setTokenURI(tokenID, uri);
  }
}
