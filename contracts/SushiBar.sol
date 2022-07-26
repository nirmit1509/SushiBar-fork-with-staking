// SPDX-License-Identifier: MIT
// Ethereum Mainnet Contract: https://etherscan.io/address/0x8798249c2e607446efb7ad49ec89dd1865ff4272
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SushiBar is ERC20("SushiBar", "xSUSHI") {
    IERC20 public sushi;

    constructor(IERC20 _sushi) {
        sushi = _sushi;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    function enter(uint256 _amount) public {
        uint256 totalSushi = sushi.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 what = (_amount * totalShares) / (totalSushi);
            _mint(msg.sender, what);
        }
        sushi.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your SUSHIs.
    function leave(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what = (_share * (sushi.balanceOf(address(this)))) /
            totalShares;
        _burn(msg.sender, _share);
        sushi.transfer(msg.sender, what);
    }
}
