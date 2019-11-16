

pragma solidity >=0.5.6;

import "./ERC721BaseMetadata.sol";
import "./ERC721BaseEnumerable.sol";
import "./ERC721BaseMintableLimited.sol";
import "./ERC721BaseBurnable.sol";
import "./ERC721BaseBuyable.sol";
import "./ERC721Base.sol";

contract Core is ERC721BaseMetadata("Tokies", "TK"), ERC721BaseEnumerable, ERC721BaseMintableLimited(45000), ERC721BaseBurnable, ERC721BaseBuyable, ERC721Base {}
