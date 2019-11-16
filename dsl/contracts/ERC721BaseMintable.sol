

pragma solidity >=0.5.6;


import "./ERC721Base.sol";

contract ERC721BaseMintable is ERC721Base {
  /**
    * @dev Internal function that performs minting of a token.
    */
  function _mint
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    _addTokenTo(to, tokenID);
    emit Transfer(address(0), to, tokenID);
  }

  /**
  * @dev External function that exposes minting of a token.
  */
  function mint
  (
    address to,
    uint256 tokenID
  )
  external
  onlyMinter
  whenNotPaused
  {
    _mint(to, tokenID);
  }
}
