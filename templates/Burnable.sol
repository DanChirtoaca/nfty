pragma solidity >=0.5.6;


import "./Administered.sol";

/**
* @title Burnable
* @dev A contract containing the burning permission modifier and the control functions
* for the list of burners.
*/
contract Burnable is Administered {
  mapping(address => bool) private _burnerApproval;

  event BurnerRegistered
  (
    address indexed burner
  );

  event BurnerDeregistered
  (
    address indexed actingAdmin,
    address indexed burner
  );


  /**
   * @dev Throws if called by any account other than a burner.
   */
  modifier onlyBurner()
  {
    require(canBurn(msg.sender), "Burner priviledge required.");
    _;
  }

    /**
   * @dev Allows to register an address as a burner.
   */
  function registerBurner
  (
    address burner
  )
  public
  onlyAdmin
  {
    _burnerApproval[burner] = true;
    emit BurnerRegistered(burner);
  }

  /**
   * @dev Allows to deregister an address from the burner list.
   */
  function deregisterBurner
  (
    address burner
  )
  public
  onlyAdmin
  {
    _burnerApproval[burner] = false;
    emit BurnerDeregistered(msg.sender, burner);
  }

  /**
   * @dev Checks whether address is allowed to burn (admin has full priviledge).
   */
  function canBurn
  (
    address burner
  )
  public
  view
  returns (bool)
  {
    if (isAdmin(burner) || _burnerApproval[burner])
    {
      return true;
    }
    return false;
  }

}