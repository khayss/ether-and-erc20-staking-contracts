// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyTokenStaking {
    struct Staker {
        uint256 stakeAmount;
        uint256 startTime;
        uint256 endTime;
        bool isStaking;
    }

    mapping(address => Staker) private _stakers;
    uint256 private _totalStake;
    uint256 private _totalRewards;
    uint256 private _rewardPerSecond;
    uint256 private _maxStakeTime;
    uint256 private _maxStakeAmount;
    uint256 private _stakeStart;
    uint256 private _maxDuration;
    address private immutable _token;
    bool private _isActive;

    error MyTokenStaking_CannotStakeZero();
    error MyTokenStaking_RewardsCannotBeZero();
    error MyTokenStaking_InsufficientRewards();
    error MyTokenStaking_AddressZeroNotAllowed();
    error MyTokenStaking_NoRewardsToClaim();
    error MyTokenStaking_UnstakeTooEarly(uint256 timeLeft);
    error MyTokenStaking_RewardsNotClaimedYet(uint256 rewards);
    error MyTokenStaking_UnstakeFailed();
    error MyTokenStaking_DurationTooShort();
    error MyTokenStaking_DurationTooLong();
    error MyTokenStaking_RewardClaimFailed();
    error MyTokenStaking_StakingFailed();

    event Stake(address indexed staker, uint256 indexed amount);
    event RewardClaim(address indexed staker, uint256 indexed amount);
    event Unstake(address indexed staker, uint256 indexed amount);

    constructor(address token) {
        _token = token;
    }

    function stake(
        uint256 amount,
        uint stakeDuration
    ) external payable returns (bool success) {
        // Check if the address is not zero
        checkAddressZero(msg.sender);

        // Check if the amount is not zero
        if (amount == 0) {
            revert MyTokenStaking_CannotStakeZero();
        }

        // check if the duration is not zero
        if (stakeDuration == 0) revert MyTokenStaking_DurationTooShort();
        if (stakeDuration > _maxDuration)
            revert MyTokenStaking_DurationTooLong();

        bool transferSuccess = IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!transferSuccess) revert MyTokenStaking_StakingFailed();

        Staker storage staker = _stakers[msg.sender];

        if (!staker.isStaking) {
            staker.isStaking = true;
            staker.startTime = block.timestamp;
            staker.endTime = block.timestamp + stakeDuration;
        }

        _totalStake = _totalStake + amount;

        success = true;

        emit Stake(msg.sender, amount);
    }

    function unstake() external returns (bool success) {
        // check if the address is not zero
        checkAddressZero(msg.sender);

        Staker storage staker = _stakers[msg.sender];

        // check duration has ended
        if (staker.endTime > block.timestamp)
            revert MyTokenStaking_UnstakeTooEarly(
                staker.endTime - block.timestamp
            );

        uint rewards = calculateRewards(msg.sender);
        // check for no unclaimed rewards
        if (rewards > 0) revert MyTokenStaking_RewardsNotClaimedYet(rewards);

        uint amount = staker.stakeAmount;

        staker.isStaking = false;
        staker.stakeAmount = 0;
        staker.startTime = 0;
        staker.endTime = 0;

        _totalStake = _totalStake - amount;

        bool transferSuccess = IERC20(_token).transfer(msg.sender, amount);
        if (!transferSuccess) revert MyTokenStaking_UnstakeFailed();

        success = true;

        emit Unstake(msg.sender, amount);
    }

    function claimReward() external returns (bool success) {
        // check if the address is not zero
        checkAddressZero(msg.sender);

        uint256 rewards = calculateRewards(msg.sender);

        // check if the rewards are not zero
        if (rewards == 0) revert MyTokenStaking_NoRewardsToClaim();

        bool transferSuccess = IERC20(_token).transfer(msg.sender, rewards);
        if (!transferSuccess) revert MyTokenStaking_RewardClaimFailed();

        success = true;

        emit RewardClaim(msg.sender, rewards);
    }

    function calculateRewards(address _address) public pure returns (uint256) {
        if (_address == address(0))
            revert MyTokenStaking_AddressZeroNotAllowed();

        return 1;
    }

    function checkAddressZero(address _address) private pure {
        if (_address == address(0)) {
            revert MyTokenStaking_AddressZeroNotAllowed();
        }
    }
}
