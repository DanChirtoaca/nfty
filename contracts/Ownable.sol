pragma solidity >=0.5.6;


/**
 * @title Ownable
 * @dev The contract Ownable defines an owner address and implements the basic authorization control. 
 * This contract follows the premises in the EIP-173 proposal http://eips.ethereum.org/EIPS/eip-173.
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred
  (
    address indexed oldOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the sender account as the original `owner` of the contract.
   */
  constructor() 
  public 
  {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyContractOwner() 
  {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to the account of a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership
  (
    address newOwner
  ) 
  public 
  onlyContractOwner 
  {
    require(newOwner != address(0));
    require(newOwner != owner); // preventing redundant ownership transfer
    
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);    
  }
}