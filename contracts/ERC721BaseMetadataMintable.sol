pragma solidity >=0.5.6;


import "./ERC721BaseMintable.sol";
import "./ERC721BaseMetadata.sol";

/**
* @title ERC-721Metadata with metadata minting functionality.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseMetadataMintable is ERC721BaseMetadata, ERC721BaseMintable { 
  /**
   * @dev The constructor.
   */
  constructor 
  (
    string memory name, 
    string memory symbol
  ) 
  ERC721BaseMetadata (name, symbol)
  public 
  {}
  
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
