pragma solidity >=0.5.6;


import "./ERC721Base.sol";
import "./interfaces/ERC721Enumerable.sol";
import "./ERC165Base.sol";

/**
* @title ERC-721 Non-Fungible Token with enumeration extension logic.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseEnumerable is ERC165Base, ERC721Base, ERC721Enumerable {
  /**
   * Array storing all the token IDs.
   */
   uint256[] private _tokenIDs;

  /**
  * Mapping of the token ID to its index in the array of all token IDs (_tokenIDs).
  */
  mapping(uint256 => uint256) private _tokenIndex;

  /**
   * Mapping of the owner to their list of owned token IDs.
   */
   mapping(address => uint256[]) private _ownedTokens;

  /**
   * Mapping of the token ID to its index in the owner array of tokens.
   */
   mapping(uint256 => uint256) private _ownedTokenIndex;

  bytes4 public constant _INTERFACE_ID_ERC_721_ENUMERABLE = 
      bytes4(keccak256('totalSupply()')) ^
      bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
      bytes4(keccak256('tokenByIndex(uint256)'));

  
  /**
   * @dev The ERC721Enumerable constructor registers the implementation of ERC721Enumerable interface.
   */
  constructor() 
  public 
  {
    _registerInterface(_INTERFACE_ID_ERC_721_ENUMERABLE);
  }

  /**
   * @dev Gives the current total amount of tokens stored in the contract.
   * @return uint256 Represents the total amount of tokens.
   */
  function totalSupply() 
  public 
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
  function tokenByIndex
  (
    uint256 index
  ) 
  public 
  view 
  returns (uint256) 
  {
    require(index < totalSupply());
    return _tokenIDs[index];
  }

  /**
   * @dev Gives the token ID at the given index in the token array of the queried owner.
   * @param owner address of the queried owner of tokens.
   * @param index uint256 Represents the index to be accessed in the requested owner's token array.
   * @return uint256 Token ID at the given index of the tokens array of the queried owned.
   */
  function tokenOfOwnerByIndex
  (
    address owner, 
    uint256 index
  ) 
  public 
  view 
  returns (uint256) 
  {
    require(index < _balanceOf(owner));
    return _ownedTokens[owner][index];
  }



  function _transferFrom
  (
    address from, 
    address to, 
    uint256 tokenId
  ) 
  internal 
  {
      super._transferFrom(from, to, tokenId);
      // FINALIZE!!!
  }



  /**
   * @dev Internal function to add a token (unowned) to an account.
   * @notice Does not emit any transfer event.
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
    _ownedTokens[to].push(tokenID);               // add token to owner array of tokens
    _ownedTokenIndex[tokenID] = _ownedTokens[to].length - 1; // added token has last index in owner array
  }

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
    //_tokenIndex[tokenID] = 0;              // 0 is wrong since it is the index of another token

    address owner = _ownerOf(tokenID);
    uint256 tokenIndexInOwner = _ownedTokenIndex[tokenID];
    uint256 lastTokenIDInOwner = _ownedTokens[owner][_ownedTokens[owner].length - 1];

    _ownedTokens[owner][tokenIndexInOwner] = lastTokenIDInOwner;  // swap last token with the one to be deleted
    _ownedTokens[owner].pop();                                    // delete last token - duplicate

    _ownedTokenIndex[lastTokenIDInOwner] = tokenIndexInOwner;     // update index of previously last token in array
    //_ownedTokenIndex[tokenID] = 0;                                 // 0 is wrong since it is the index of another token
  }
    /**
      * @notice Check the issue with the 0 index in array after removal!!!
      * Look into the gas optimization with the balance counter!!!
      */
}
