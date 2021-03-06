pragma solidity >=0.5.6;


library Address {
  /**
    * Returns whether the target address is a contract
    * @dev This function will return false if invoked during the constructor of a contract,
    * as the code is not actually created until after the constructor finishes.
    * @param account Address of the account to check.
    * @return Whether the target address is a contract.
    */
  function isContract(address account) internal view returns (bool) {
      uint256 size;
      // XXX Currently there is no better way to check if there is a contract in an address
      // than to check the size of the code at that address.
      // See https://ethereum.stackexchange.com/a/14016/36603
      // for more details about how this works.
      assembly
      {
        size := extcodesize(account)
      }
      return size > 0;
  }
}