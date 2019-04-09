pragma solidity >=0.5.6;


import "./ERC721BaseMintable.sol";
import "./ERC721BaseEnumerable.sol";

contract ERC721BaseMintableLimited is ERC721BaseMintable, ERC721BaseEnumerable {
  uint256 public maxSupply;


  /**
   * @dev The constructor sets the value for the maxSupply.
   */
  constructor(uint256 max) 
  public 
  {
    maxSupply = max;
  }

  /**
   * @dev Function to mint tokens which throws if the total supply 
   * has reached the maximum supply.
   */
  function _mint
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    require(totalSupply() < maxSupply);
    super._mint(to, tokenID);
  }

  /**
   * @notice Ensure inheritance tree with mintable and enumerable has no collisions.
   */

}