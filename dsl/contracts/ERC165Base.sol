pragma solidity >=0.5.6;


import "./interfaces/ERC165.sol";

/**
* @title ERC165
* @dev The contract implements ERC165 standard (see https://eips.ethereum.org/EIPS/eip-165) using a mapping.
*/
contract ERC165Base is ERC165 {
  /**
    * @dev Mapping whether an interface ID is supported.
    */
  mapping(bytes4 => bool) private _supportedInterfaces;

  bytes4 public constant INTERFACE_ID_ERC_165 = bytes4(keccak256('supportsInterface(bytes4)'));


  /**
    * @dev The ERC165 constructor registers the implementation of ERC165 standard itself.
    */
  constructor()
  internal
  {
    _registerInterface(INTERFACE_ID_ERC_165);
  }

  /**
    * @dev Implement supportsInterface(bytes4) by querying the mapping _supportedInterfaces.
    */
  function supportsInterface
  (
    bytes4 interfaceID
  )
  external
  view
  returns (bool)
  {
    return _supportedInterfaces[interfaceID];
  }

  /**
    * @dev Internal function for registering an interface. To be used by contracts that implement ERC165.
    */
  function _registerInterface
  (
    bytes4 interfaceID
  )
  internal
  {
    require(interfaceID != 0xffffffff, "Interface ID cannot be 0xffffffff.");
    _supportedInterfaces[interfaceID] = true;
  }
}