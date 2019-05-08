pragma solidity >=0.5.6;


import "./ERC165.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard.
 * @dev See https://eips.ethereum.org/EIPS/eip-721.
 * @notice The ERC-165 identifier for this interface is 0x80ac58cd.
 */

contract ERC721 is ERC165 {
  /**
   * @dev Emits when ownership of any NFT changes by any mechanism.
   * This event emits when NFTs are created (`from` == 0) and destroyed
   * (`to` == 0). Exception: during contract creation, any number of NFTs
   * may be created and assigned without emitting Transfer. At the time of
   * any transfer, the approved address for that NFT (if any) is reset to none.
   */
  event Transfer
  (
    address indexed from,
    address indexed to,
    uint256 indexed tokenID
  );

  /**
   * @dev Emits when the approved address for an NFT is changed or
   * reaffirmed. The zero address indicates there is no approved address.
   * When a Transfer event emits, this also indicates that the approved
   * address for that NFT (if any) is reset to none.
   */
  event Approval
  (
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenID
  );

  /**
   * @dev Emits when an operator is enabled or disabled for an owner.
   * The operator can manage all NFTs of the owner.
   */
  event ApprovalForAll
  (
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function balanceOf
  (
    address owner
  )
  external
  view
  returns (uint256);

  function ownerOf
  (
    uint256 tokenID
  )
  external
  view
  returns (address);

  function transferFrom
  (
    address from,
    address to,
    uint256 tokenID
  )
  external
  payable;

  function safeTransferFrom
  (
    address from,
    address to,
    uint256 tokenID,
    bytes calldata data
  )
  external
  payable;

  function safeTransferFrom
  (
    address from,
    address to,
    uint256 tokenID
  )
  external
  payable;

  function approve
  (
    address approved,
    uint256 tokenID
  )
  external
  payable;

  function setApprovalForAll
  (
    address operator,
    bool approved
  )
  external;

  function getApproved
  (
    uint256 tokenID
  )
  external
  view
  returns (address);

  function isApprovedForAll
  (
    address owner,
    address operator
  )
  external
  view
  returns (bool);
}