pragma solidity >=0.5.6;


import "./ERC165.sol";

/**
 * @title ERC721
 * @dev The contract implements ERC721 standard (see https://eips.ethereum.org/EIPS/eip-721).
 */
contract ERC721 is ERC165 {
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

    /**
     * @dev Emits when ownership of a token changes by any mechanism.
     */
    event Transfer
    (
      address indexed from, 
      address indexed to, 
      uint256 indexed tokenID
    );

    /**
     * @dev Emits when the approved address for a token is changed or reaffirmed.
     */
    event Approval
    (
      address indexed owner, 
      address indexed approved,
      uint256 indexed tokenID
    );
    
    /**
     * @dev Emits when an operator is enabled or disabled for a token owner. 
     * The operator can manage all tokens of the owner.
     */
    event ApprovalForAll
    (
      address indexed owner, 
      address indexed operator, 
      bool approved
    );

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
    external 
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
    external
    payable 
    {
      address owner = ownerOf(tokenID);
      require(to != owner);
      require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

      _tokenApproval[tokenID] = to;
      emit Approval(owner, to, tokenID);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenID uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenID) public view returns (address) {
        require(_exists(tokenID));
        return _tokenApproval[tokenID];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorsApproval[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorsApproval[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenID uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenID) public {
        require(_isApprovedOrOwner(msg.sender, tokenID));

        _transferFrom(from, to, tokenID);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenID uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenID) public {
        safeTransferFrom(from, to, tokenID, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenID uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenID, bytes memory _data) public {
        transferFrom(from, to, tokenID);
        require(_checkOnERC721Received(from, to, tokenID, _data));
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenID uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenID) internal view returns (bool) {
        address owner = _tokenOwner[tokenID];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenID uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenID) internal view returns (bool) {
        address owner = ownerOf(tokenID);
        return (spender == owner || getApproved(tokenID) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenID uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenID) internal {
        require(to != address(0));
        require(!_exists(tokenID));

        _tokenOwner[tokenID] = to;
        _ownedTokenCount[to].increment();

        emit Transfer(address(0), to, tokenID);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenID uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenID) internal {
        require(ownerOf(tokenID) == owner);

        _clearApproval(tokenID);

        _ownedTokenCount[owner].decrement();
        _tokenOwner[tokenID] = address(0);

        emit Transfer(owner, address(0), tokenID);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenID uint256 ID of the token being burned
     */
    function _burn(uint256 tokenID) internal {
        _burn(ownerOf(tokenID), tokenID);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenID uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenID) internal {
        require(ownerOf(tokenID) == from);
        require(to != address(0));

        _clearApproval(tokenID);

        _ownedTokenCount[from].decrement();
        _ownedTokenCount[to].increment();

        _tokenOwner[tokenID] = to;

        emit Transfer(from, to, tokenID);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address.
     * The call is not executed if the target address is not a contract.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenID uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenID, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenID, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenID uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenID) private {
        if (_tokenApproval[tokenID] != address(0)) {
            _tokenApproval[tokenID] = address(0);
        }
    }
}