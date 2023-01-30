// SPDX-License-Identifier: MIT
// 0.8.7+commit.e28d00a7
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MontePlatform is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant LOCK_TRANSFER_ROLE = keccak256("LOCK_TRANSFER_ROLE");

    mapping(address => bool) internal _fullLockList;

    constructor() ERC20("Monte Marketing Platform Coin", "MMPC") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        uint256 _total = 1* 10 ** 8 * 10 ** decimals();
        _mint(0x489dBD9f82b7FD2f9eD5DE4414571a2fe9E3DE10, _total/4);
        _mint(0xCE5162513C77B83625304fbC0dc008b80A54365d, _total/4);
        _mint(0x17fECD6ba3BfFC5bde9f85AD29c839e044Fe43Ca, _total/4);
        _mint(0x7F495Eae30634b335e09eAabD130bEDFd68d59AC, _total/4);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(LOCK_TRANSFER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function fullLockAddress(address account) external onlyRole(LOCK_TRANSFER_ROLE) returns (bool) {
        _fullLockList[account] = true;
        return true;
    }

    function unFullLockAddress(address account) external onlyRole(LOCK_TRANSFER_ROLE) returns (bool) {
        delete _fullLockList[account];
        return true;
    }

    function fullLockedAddressList(address account) external view virtual returns (bool) {
        return _fullLockList[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        require(!_fullLockList[from], "Token transfer from LockedAddressList");
        super._beforeTokenTransfer(from, to, amount);
    }
}