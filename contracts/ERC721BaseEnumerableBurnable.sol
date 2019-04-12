pragma solidity >=0.5.6;


import "./ERC721BaseBurnable.sol";
import "./ERC721BaseEnumerable.sol";

/**
* @title ERC-721Enumerable with enumerable burning functionality.
* @dev See https://eips.ethereum.org/EIPS/eip-721.
*/
contract ERC721BaseEnumerableBurnable is ERC721BaseEnumerable, ERC721BaseBurnable {} 

/**
@notice Check if the overrides work properly.
 */