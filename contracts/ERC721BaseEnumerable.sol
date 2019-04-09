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
      require(index < balanceOf(owner));
      return _ownedTokens[owner][index];
  }

  /**
   * Look and add the function overloads that result from this interface (i.e. transfer, minting, etc.)
   */

}
