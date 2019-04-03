pragma solidity >=0.5.6;


import "./ERC165Base.sol";
import "./standards/ERC721.sol";

/**
 * @title ERC721
 * @dev The contract implements ERC721 standard (see https://eips.ethereum.org/EIPS/eip-721).
 */
contract ERC721Base is ERC721, ERC165Base {
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
    public 
    view 
    returns (uint256) 
    {
      require(owner != address(0));
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
    public
    view 
    returns (address) 
    {
      address owner = _tokenOwner[tokenID];
      require(owner != address(0));
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
    public
    payable 
    {
      address owner = ownerOf(tokenID); 
      require(to != owner);
      require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
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
    public 
    view 
    returns (address) 
    {
      require(_tokenExists(tokenID));
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
    public 
    {
      require(to != msg.sender);
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
    public 
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
    public 
    {
      _transferFrom(from, to, tokenID);
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
    public 
    {
      safeTransferFrom(from, to, tokenID, "");
    }

    /**
     * @param from Current owner of the token.
     * @param to Address to receive the ownership of the given token ID.
     * @param tokenID uint256 ID of the token to be transferred.
     * @param _data bytes Data to send along with a safe transfer check.
     */
    function safeTransferFrom
    (
      address from, 
      address to, 
      uint256 tokenID, 
      bytes memory _data
    ) 
    public 
    {
      _transferFrom(from, to, tokenID);
      require(_checkAndCallOnERC721Received(from, to, tokenID, _data)); //TODO: investigate what is the best approach for this
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
     * @dev Transfer ownership of a given token ID to another address.
     * @param from Current owner of the token.
     * @param to Address to receive the ownership of the given token ID.
     * @param tokenID uint256 ID of the token to be transferred.
     */
    function _transferFrom
    (
      address from, 
      address to, 
      uint256 tokenID
    ) 
    internal 
    {
      require(msg.sender == from || msg.sender == getApproved(tokenID) || isApprovedForAll(from, msg.sender));
      require(ownerOf(tokenID) == from);
      require(to != address(0));

      _clearApproval(tokenID);
      _ownedTokenCount[from]--;   // decrease balance of current token owner
      _ownedTokenCount[to]++;     // increase balance of target owner
      _tokenOwner[tokenID] = to;  // assign token ownership to target owner

      emit Transfer(from, to, tokenID);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenID uint256 ID of the token to clear the approval address for.
     */
    function _clearApproval
    (
      uint256 tokenID
    ) 
    private 
    {
      if (_tokenApproval[tokenID] != address(0)) 
      {
          _tokenApproval[tokenID] = address(0);
      }
    }
}