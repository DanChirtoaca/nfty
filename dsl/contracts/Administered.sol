pragma solidity >=0.5.6;


import "./Ownable.sol";

/**
* @title Administered
* @dev A contract containing the permission modifier and the control functions
* for the list of admins.
*/
contract Administered is Ownable {
  mapping(address => bool) private _adminApproval;

  event AdminRegistered
  (
    address indexed admin
  );

  event AdminDeregistered
  (
    address indexed actingAdmin,
    address indexed oldAdmin
  );


  /**
   * @dev The Administered constructor sets the contract owner as an admin.
   */
  constructor()
  public
  {
    registerAdmin(owner);
  }

  /**
   * @dev Throws if called by any account other than an admin.
   */
  modifier onlyAdmin()
  {
    require(_adminApproval[msg.sender], "Admin priviledge required.");
    _;
  }

  /**
   * @dev Allows to register an address as an admin.
   */
  function registerAdmin
  (
    address admin
  )
  public
  onlyContractOwner
  {
    _adminApproval[admin] = true;
    emit AdminRegistered(admin);
  }

  /**
   * @dev Allows to deregister an address from the admin list.
   */
  function deregisterAdmin
  (
    address admin
  )
  public
  onlyAdmin
  {
    _adminApproval[admin] = false;
    emit AdminDeregistered(msg.sender, admin);
  }

  /**
   * @dev Checks whether address is an admin.
   */
  function isAdmin
  (
    address admin
  )
  public
  view
  returns (bool)
  {
    return _adminApproval[admin];
  }
}