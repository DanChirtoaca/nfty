pragma solidity >=0.5.6;


import "./Administered.sol";

/**
* @title Mintable
* @dev A contract containing the minting permission modifier and the control functions
* for the list of minters.
*/
contract Mintable is Administered {
  mapping(address => bool) private _minterApproval;

  event MinterRegistered
  (
    address indexed minter
  );

  event MinterDeregistered
  (
    address indexed actingAdmin,
    address indexed minter
  );


  /**
   * @dev Throws if called by any account other than a minter.
   */
  modifier onlyMinter() 
  {
    require(canMint(msg.sender));
    _;
  }

    /**
   * @dev Allows to register an address as a minter.
   */
  function registerMinter
  (
    address minter
  )
  public
  onlyAdmin
  {
    _minterApproval[minter] = true;
    emit MinterRegistered(minter);
  }

  /**
   * @dev Allows to deregister an address from the minter list.
   */
  function deregisterMinter
  (
    address minter
  )
  public
  onlyAdmin
  {
    _minterApproval[minter] = false;
    emit MinterDeregistered(msg.sender, minter);
  }

  /**
   * @dev Checks whether address is allowed to mint (admin has full priviledge).
   */
  function canMint
  (
    address minter
  )
  public
  view
  returns (bool)
  {
    if (isAdmin(minter) || _minterApproval[minter])
    {
      return true;
    }
    return false;
  }

}