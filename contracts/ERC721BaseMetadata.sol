pragma solidity >=0.5.6;


import "./ERC721Base.sol";
import "./interfaces/ERC721Metadata.sol";
import "./ERC165Base.sol";

/**
* @title ERC-721 Non-Fungible Token with metadata extension logic.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseMetadata is ERC165Base, ERC721Base, ERC721Metadata {
  /**
   * Token name.
   */
  string private _name;

  /**
   * Token symbol.
   */
  string private _symbol;

  /**
   * Mapping of token URIs.
   */
  mapping(uint256 => string) private _tokenURIs;

  bytes4 public constant _INTERFACE_ID_ERC_721_METADATA = 
      bytes4(keccak256('name()')) ^
      bytes4(keccak256('symbol()')) ^
      bytes4(keccak256('tokenURI(uint256)'));


  /**
   * @dev The ERC721Metadata constructor registers the implementation of ERC721Metadata interface.
   */
  constructor 
  (
    string memory name, 
    string memory symbol
  ) 
  public 
  {
    _name = name;
    _symbol = symbol;
    _registerInterface(_INTERFACE_ID_ERC_721_METADATA);
  }

  /**
   * @return string Returns the representing token name.
   */
  function name() 
  external 
  view 
  returns (string memory) 
  {
    return _name;
  }

  /**
   * @return string Returns the representing token symbol.
   */
  function symbol() 
  external 
  view 
  returns (string memory) 
  {
    return _symbol;
  }

  /**
   * @dev Returns the URI for a given token ID. Throws if the token ID does
   * not exist. May return an empty string.
   * @param tokenID uint256 ID of the token to query.
   */
  function tokenURI
  (
    uint256 tokenID
  ) 
  external 
  view 
  returns (string memory) 
  {
    require(_tokenExists(tokenID));
    return _tokenURIs[tokenID];
  }

  /**
    * @dev Internal function to set the token URI for a given token.
    * Throws if the token ID does not exist.
    * @param tokenID uint256 ID of the token for which the URI is set.
    * @param uri string URI to assign.
    */
  function _setTokenURI
  (
    uint256 tokenID, 
    string memory uri
  ) 
  internal 
  {
    require(_tokenExists(tokenID));
    _tokenURIs[tokenID] = uri;
  }

 /**
    * @dev Internal function to delete the token URI (if the uri exists) for a given token.
    * @param tokenID uint256 ID of the token for which the URI is set.
    * @param uri string URI to assign.
    */
  function _deleteTokenURI
  (
    uint tokenID
  )
  internal
  {
    if (bytes(_tokenURIs[tokenID]).length != 0) 
    {
      delete _tokenURIs[tokenID];
    }
  }
}