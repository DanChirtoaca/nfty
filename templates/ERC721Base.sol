<%!
  from dsl_util import put, modify, get_imports, get_extensions    
%>
<%
  imports = get_imports(data, "base_imports")
  extensions = get_extensions(data, "base_extensions")
  if extensions: extensions = ", " + extensions
  pause = put(data, 'pause')
%>

pragma solidity >=0.5.6;


import "./ERC165Base.sol";
import "./interfaces/ERC721.sol";
import "./interfaces/ERC721TokenReceiver.sol";
import "./utils/Address.sol";
${imports}

/**
* @title ERC721
* @dev The contract implements ERC721 standard (see https://eips.ethereum.org/EIPS/eip-721).
*/
contract ERC721Base is ERC721, ERC165Base ${extensions} {
  using Address for address;

  /**
   * @dev Mapping from token ID to owner address.
   */
  mapping (uint256 => address) private _tokenOwner;

  /**
   * @dev Mapping from token ID to approved address.
   */
  mapping (uint256 => address) private _tokenApproval;

  /**
   * @dev Mapping from token owner address to number of owned tokens.
   */
  mapping (address => uint256) private _ownedTokenCount;

  /**
   * @dev Mapping from token owner address to operator(s) approval.
   */
  mapping (address => mapping (address => bool)) private _operatorsApproval;

  bytes4 public constant INTERFACE_ID_ERC_721 =
      bytes4(keccak256('balanceOf(address)')) ^
      bytes4(keccak256('ownerOf(uint256)')) ^
      bytes4(keccak256('approve(address,uint256)')) ^
      bytes4(keccak256('getApproved(uint256)')) ^
      bytes4(keccak256('setApprovalForAll(address,bool)')) ^
      bytes4(keccak256('isApprovedForAll(address,address)')) ^
      bytes4(keccak256('transferFrom(address,address,uint256)')) ^
      bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
      bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));

  bytes4 public constant INTERFACE_ID_ERC_721_TOKEN_RECEIVER =
      bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));


  /**
   * @dev Modifier which throws if msg.sender is not the current token owner.
   */
  modifier onlyTokenOwner
  (
    uint256 tokenID
  )
  {
    require(msg.sender == _ownerOf(tokenID), "Only token owner can perform this action.");
    _;
  }

  /**
  * @dev Modifier which throws if msg.sender is not the current token owner or an approved operator.
  */
  modifier onlyTokenOwnerOrApproved
  (
    uint256 tokenID
  )
  {
    require(_isApprovedOrOwner(msg.sender, tokenID), "Only token owner or approved operator can perform this action.");
    _;
  }

  /**
   * @dev The ERC721 constructor registers the implementation of ERC721 standard.
   */
  constructor()
  public
  {
    _registerInterface(INTERFACE_ID_ERC_721);
  }

  /**
   * @dev Gives the balance (number of owned tokens) of the specified address.
   * @param owner Address to query the balance of.
   * @return uint256 Represents the amount of owned tokens by the queried address.
   */
  function balanceOf
  (
    address owner
  )
  external
  view
  ${modify(data, "balanceOf")}
  returns (uint256)
  {
    return _balanceOf(owner);
  }

  /**
   * @notice Actual implementation of the balanceOf function.
   */
  function _balanceOf
  (
    address owner
  )
  internal
  view
  returns (uint256)
  {
    require(owner != address(0), "Owner with address(0) is not available.");
    return _ownedTokenCount[owner];
  }

  /**
   * @dev Gives the owner address of the specified token ID.
   * @param tokenID ID of the token to query the owner of.
   * @return address Address marking the current owner of the given token ID.
   */
  function ownerOf
  (
    uint256 tokenID
  )
  external
  view
  ${modify(data, "ownerOf")}
  returns (address)
  {
    return _ownerOf(tokenID);
  }

  /**
   * @notice Actual implementation of the ownerOf function.
   */
  function _ownerOf
  (
    uint256 tokenID
  )
  internal
  view
  returns (address)
  {
    address owner = _tokenOwner[tokenID];
    require(owner != address(0), "Owner with address(0) is not available.");
    return owner;
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param to Address to be approved for the given token ID.
   * @param tokenID uint256 ID of the token to be approved.
   */
  function approve
  (
    address to,
    uint256 tokenID
  )
  external
  payable
  ${pause}
  {
    _approve(to, tokenID);
  }

  /**
   * @notice Actual implementation of the approve function.
   */
  function _approve
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    address owner = _ownerOf(tokenID);
    require(to != owner, "Owner of token does not need approval.");
    require(msg.sender == owner || _isApprovedForAll(owner, msg.sender), "Only owner or approved operator can perform this action.");
    _tokenApproval[tokenID] = to;
    emit Approval(owner, to, tokenID);
  }

  /**
    * @dev Gives the approved address for a token ID, or zero if no address set.
    * Reverts if the token ID does not exist.
    * @param tokenID uint256 ID of the token to query the approval of.
    * @return address Currently approved address for the given token ID.
    */
  function getApproved
  (
    uint256 tokenID
  )
  external
  view
  ${modify(data, "getApproved")}
  returns (address)
  {
    return _getApproved(tokenID);
  }

  /**
   * @notice Actual implementation of the getApproved function.
   */
  function _getApproved
  (
    uint256 tokenID
  )
  internal
  view
  returns (address)
  {
    require(_tokenExists(tokenID), "Token does not exist.");
    return _tokenApproval[tokenID];
  }

  /**
    * @dev Sets or unsets the approval of a given operator.
    * An operator is allowed to transfer all tokens of the sender on their behalf.
    * @param to Operator address for which the approval will be set.
    * @param approved Represents the status of the approval to be set.
    */
  function setApprovalForAll
  (
    address to,
    bool approved
  )
  external
  ${modify(data, "setApprovalForAll")}
  ${pause}
  {
    _setApprovalForAll(to, approved);
  }

  /**
   * @notice Actual implementation of the setApprovalForAll function.
   */
  function _setApprovalForAll
  (
    address to,
    bool approved
  )
  internal
  {
    require(to != msg.sender, "Owner of token(s) does not need approval.");
    _operatorsApproval[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
  }

  /**
    * @dev Tells whether an operator is approved by a given owner.
    * @param owner Owner address which you want to query the approval of.
    * @param operator Operator address which you want to query the approval of.
    * @return bool Tells whether the given operator is approved by the given owner.
    */
  function isApprovedForAll
  (
    address owner,
    address operator
  )
  external
  view
  ${modify(data, "isApprovedForAll")}
  returns (bool)
  {
    return _isApprovedForAll(owner, operator);
  }

  /**
   * @notice Actual implementation of the isApprovedForAll function.
   */
  function _isApprovedForAll
  (
    address owner,
    address operator
  )
  internal
  view
  returns (bool)
  {
    return _operatorsApproval[owner][operator];
  }

  /**
    * @dev Transfers the ownership of a given token ID to another address.
    * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
    * Requires the msg.sender to be the owner, approved, or operator.
    * @param from Current owner of the token.
    * @param to Address to receive the ownership of the given token ID.
    * @param tokenID uint256 ID of the token to be transferred.
    */
  function transferFrom
  (
    address from,
    address to,
    uint256 tokenID
  )
  external
  payable
  ${pause}
  {
    _transferFrom(from, to, tokenID);
  }

  /**
   * @notice Actual implementation of the transferFrom function.
   */
  function _transferFrom
  (
    address from,
    address to,
    uint256 tokenID
  )
  internal
  onlyTokenOwnerOrApproved(tokenID)
  {
    require(_ownerOf(tokenID) == from, "Incorrect token owner specified.");
    require(to != address(0), "Cannot transfer token to address(0).");

    _clearApproval(tokenID);
    _ownedTokenCount[from]--;   // decrease balance of current token owner
    _ownedTokenCount[to]++;     // increase balance of target owner
    _tokenOwner[tokenID] = to;  // assign token ownership to target owner

    emit Transfer(from, to, tokenID);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted. Requires the msg.sender to be the owner, approved, or operator.
   * @param from Current owner of the token.
   * @param to Address to receive the ownership of the given token ID.
   * @param tokenID uint256 ID of the token to be transferred.
   */
  function safeTransferFrom
  (
    address from,
    address to,
    uint256 tokenID
  )
  external
  payable
  ${pause}
  {
    _safeTransferFrom(from, to, tokenID, "");
  }

  /**
    * @param from Current owner of the token.
    * @param to Address to receive the ownership of the given token ID.
    * @param tokenID uint256 ID of the token to be transferred.
    * @param data bytes Data to send along with a safe transfer check.
    */
  function safeTransferFrom
  (
    address from,
    address to,
    uint256 tokenID,
    bytes calldata data
  )
  external
  payable
  ${pause}
  {
    _safeTransferFrom(from, to, tokenID, data);
  }

 /**
   * @notice Actual implementation of the safeTransferFrom function.
   */
  function _safeTransferFrom
  (
    address from,
    address to,
    uint256 tokenID,
    bytes memory data
  )
  internal
  {
    _transferFrom(from, to, tokenID);
    if (to.isContract())
    {
      bytes4 ack = ERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenID, data);
      require(ack == INTERFACE_ID_ERC_721_TOKEN_RECEIVER, "ERC721TokenReceiver not supported by receiving contract.");
    }
  }

  /**
    * @dev Returns whether the specified token exists.
    * @param tokenID uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
  function _tokenExists
  (
    uint256 tokenID
  )
  internal
  view
  returns (bool)
  {
    return _tokenOwner[tokenID] != address(0);
  }

  /**
    * @dev Internal function to clear current approval of a given token ID.
    * @param tokenID uint256 ID of the token to clear the approval address for.
    */
  function _clearApproval
  (
    uint256 tokenID
  )
  internal
  {
    if (_tokenApproval[tokenID] != address(0))
    {
      _tokenApproval[tokenID] = address(0);
    }
  }

  /**
    * @dev Internal function to add a token (unowned) to an account.
    * @notice Does not emit any transfer event.
    */
  function _addTokenTo
  (
    address to,
    uint256 tokenID
  )
  internal
  {
    require(!_tokenExists(tokenID), "Token already exists.");
    require(to != address(0), "Target owner cannot be address(0).");
    _ownedTokenCount[to]++;           // increase balance of target owner
    _tokenOwner[tokenID] = to;        // assign token ownership to target owner
  }

  /**
    * @dev Internal function to remove a token from the owner's account.
    * @notice Does not emit any transfer event. Does not check token permissions.
    */
  function _removeToken
  (
    uint256 tokenID
  )
  internal
  {
    address owner = _tokenOwner[tokenID];
    _clearApproval(tokenID);
    _ownedTokenCount[owner]--;        // decrease balance of current token owner
    _tokenOwner[tokenID] = address(0);
  }

  /**
    * @dev Tells whether the given address can operate a given token ID.
    * @param user Address of the queried user.
    * @param tokenID uint256 ID of the queried token.
    * @return bool Whether the user is approved for the given token ID,
    * is an operator (isApprovedForAll) for the owner, or is the owner of the token.
    */
  function _isApprovedOrOwner
  (
    address user,
    uint256 tokenID
    )
    internal
    view
    returns (bool)
    {
      address owner = _ownerOf(tokenID);
      return (user == owner || _getApproved(tokenID) == user || _isApprovedForAll(owner, user));
  }
}
