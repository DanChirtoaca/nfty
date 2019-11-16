pragma solidity >=0.5.6;


import "./Ownable.sol";

/**
 * @title Pausable
 * @dev The contract Pausable implements a stop mechanism that allows to block access
 * to functions in an emergency.
 */
contract Pausable is Ownable {
  bool public paused = false;

  event Pause();
  event Unpause();


  /**
   * @dev Throws if called when the contract is PAUSED.
   */
  modifier whenNotPaused()
  {
    require(!paused, "Contract is paused.");
    _;
  }

  /**
   * @dev Throws if called when the contract is NOT PAUSED.
   */
  modifier whenPaused()
  {
    require(paused, "Contract is not paused.");
    _;
  }

  /**
   * @dev Allows the contract owner to PAUSE the contract, Pause event is emitted.
   */
  function pause()
  public
  onlyContractOwner
  whenNotPaused
  returns (bool)
  {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev Allows the contract owner to UNPAUSE the contract and return to normal state, Unpause event is emitted.
   */
  function unpause()
  public
  onlyContractOwner
  whenPaused
  returns (bool)
  {
    paused = false;
    emit Unpause();
    return true;
  }
}
