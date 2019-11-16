pragma solidity >=0.5.6;


import "./ERC721BaseMintable.sol";
import "./ERC721BaseTokenSupply.sol";

contract ERC721BaseMintableLimited is ERC721BaseMintable, ERC721BaseTokenSupply {
  /**
   * @dev Determines the maximum allowed supply of tokens. If maximum is reached no more
   * tokens can be minted unless tokens are removed through burning.
   */
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
    require(_totalSupply() < maxSupply, "Maximum supply has been reached. No more tokens can be minted.");
    super._mint(to, tokenID);
  }
}