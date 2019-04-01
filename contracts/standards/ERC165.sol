pragma solidity >=0.5.6;


/**
 * @title ERC165
 * @dev The contract implements ERC165 (see https://eips.ethereum.org/EIPS/eip-165) using a mapping.
 */
contract ERC165 {
    bytes4 public constant _INTERFACE_ID_ERC_165 = bytes4(keccak256('supportsInterface(bytes4)'));

    /**
     * @dev Maps whether an interface ID is supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev The ERC165 constructor registers the implementation of ERC165 itself.
     */
    constructor() 
    internal 
    {
      _registerInterface(_INTERFACE_ID_ERC_165);
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
      require(interfaceID != 0xffffffff);
      _supportedInterfaces[interfaceID] = true;
    }
}