// SPDX-License-Identifier: MIT
// Ethereum Mainnet Contract: https://etherscan.io/address/0x8798249c2e607446efb7ad49ec89dd1865ff4272
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SushiBar is ERC20("SushiBar", "xSUSHI") {
    IERC20 public sushi;

    // Mapping for id => address Staked Address
    mapping(uint256 => address) public stakerAddress;

    // Mapping for Staked Address => staking IDs
    mapping(address => uint256[]) public stakedIDs;

    // Mapping with id => Tokens invested
    mapping(uint256 => uint256) public usersTokens;

    // Mapping with id => Staking Time
    mapping(uint256 => uint256) public stakingStartTime;

    // Mapping with id => Status
    mapping(uint256 => bool) public tokenTransactionStatus;

    // Mapping for keeping track of final withdraw value of staked token
    mapping(uint256 => uint256) public finalWithdrawlStake;

    // Count of no of staking
    uint256 public stakingCount;

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
        stakerAddress[stakingCount] = msg.sender;
        usersTokens[stakingCount] = _amount;
        stakingStartTime[stakingCount] = block.timestamp;
        tokenTransactionStatus[stakingCount] = false;
        stakedIDs[msg.sender].push(stakingCount);
        sushi.transferFrom(msg.sender, address(this), _amount);
        stakingCount++;
    }

    // Leave the bar. Claim back your SUSHIs.
    function leave(uint256 _stakingID) public {
        require(
            stakerAddress[_stakingID] == msg.sender,
            "No staked token found on this address and ID"
        );
        require(
            tokenTransactionStatus[_stakingID] != true,
            "Tokens are already withdrawn"
        );
        // max amount staked that can be withdrawn
        uint256 _share = getTokensToWithdraw(_stakingID);
        uint256 totalShares = totalSupply();
        uint256 what = (_share * (sushi.balanceOf(address(this)))) /
            totalShares;
        _burn(msg.sender, _share);
        sushi.transfer(msg.sender, what);
        finalWithdrawlStake[_stakingID] = what;
        tokenTransactionStatus[_stakingID] = true;
    }

    function getTokensToWithdraw(uint256 _stakingID)
        public
        view
        returns (uint256)
    {
        require(_stakingID < stakingCount, "Invalid Staking ID");
        uint256 totalDays = (block.timestamp - stakingStartTime[_stakingID]) /
            1 days;
        // After tax is calculated it will remain in this pool, rest will be transferred
        if (totalDays > 8) {
            return usersTokens[_stakingID];
        }
        if (totalDays > 6) {
            return (75 * usersTokens[_stakingID]) / 100;
        }
        if (totalDays > 4) {
            return (50 * usersTokens[_stakingID]) / 100;
        }
        if (totalDays > 2) {
            return (25 * usersTokens[_stakingID]) / 100;
        } else return 0;
    }
}
