pragma solidity >=0.5.6;


import "./ERC721BaseMintable.sol";
import "./ERC721BaseEnumerable.sol";

/**
* @title ERC-721Enumerable with enumerable minting functionality.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseEnumerableMintable is ERC721BaseEnumerable, ERC721BaseMintable {}

/**
@notice Check if the overrides work properly.
 */