pragma solidity >=0.5.6;

/**
 * @title The ERC165 standard.
 * @dev See https://eips.ethereum.org/EIPS/eip-165.
 */
contract ERC165 {
  /**
    * @notice Query if a contract implements an interface
    * @param interfaceID The interface identifier, as specified in ERC-165
    * @dev Interface identification is specified in ERC-165.
    * @return `true` if the contract implements `interfaceID` and
    * `interfaceID` is not 0xffffffff, `false` otherwise
    */
  function supportsInterface
  (
    bytes4 interfaceID
  )
  external
  view
  returns (bool);
}