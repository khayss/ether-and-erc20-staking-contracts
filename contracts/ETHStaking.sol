// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ETHStaking {
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
    bool private _isActive;

    error ETHStaking_CannotStakeZero();
    error ETHStaking_RewardsCannotBeZero();
    error ETHStaking_InsufficientRewards();
    error ETHStaking_AddressZeroNotAllowed();
    error ETHStaking_NoRewardsToClaim();
    error ETHStaking_UnstakeTooEarly(uint256 timeLeft);
    error ETHStaking_RewardsNotClaimedYet(uint256 rewards);
    error ETHStaking_UnstakeFailed();
    error ETHStaking_DurationTooShort();
    error ETHStaking_DurationTooLong();
    error ETHStaking_RewardClaimFailed();

    event Stake(address indexed staker, uint256 indexed amount);
    event RewardClaim(address indexed staker, uint256 indexed amount);
    event Unstake(address indexed staker, uint256 indexed amount);

    constructor() {}

    function stake(uint stakeDuration) external payable returns (bool success) {
        // Check if the address is not zero
        checkAddressZero(msg.sender);

        // Check if the amount is not zero
        if (msg.value == 0) {
            revert ETHStaking_CannotStakeZero();
        }

        // check if the duration is not zero
        if (stakeDuration == 0) revert ETHStaking_DurationTooShort();
        if (stakeDuration > _maxDuration) revert ETHStaking_DurationTooLong();

        Staker storage staker = _stakers[msg.sender];

        if (!staker.isStaking) {
            staker.isStaking = true;
            staker.startTime = block.timestamp;
            staker.endTime = block.timestamp + stakeDuration;
        }

        _totalStake = _totalStake + msg.value;

        success = true;

        emit Stake(msg.sender, msg.value);
    }

    function unstake() external returns (bool success) {
        // check if the address is not zero
        checkAddressZero(msg.sender);

        Staker storage staker = _stakers[msg.sender];

        // check duration has ended
        if (staker.endTime > block.timestamp)
            revert ETHStaking_UnstakeTooEarly(staker.endTime - block.timestamp);

        uint rewards = calculateRewards(msg.sender);
        // check for no unclaimed rewards
        if (rewards > 0) revert ETHStaking_RewardsNotClaimedYet(rewards);

        uint amount = staker.stakeAmount;

        staker.isStaking = false;
        staker.stakeAmount = 0;
        staker.startTime = 0;
        staker.endTime = 0;

        _totalStake = _totalStake - amount;

        (bool transferSuccess, ) = payable(msg.sender).call{value: amount}("");
        if (!transferSuccess) revert ETHStaking_UnstakeFailed();

        success = true;

        emit Unstake(msg.sender, amount);
    }

    function claimReward() external returns (bool success) {
        // check if the address is not zero
        checkAddressZero(msg.sender);

        uint256 rewards = calculateRewards(msg.sender);

        // check if the rewards are not zero
        if (rewards == 0) revert ETHStaking_NoRewardsToClaim();

        (bool transferSuccess, ) = payable(msg.sender).call{value: rewards}("");
        if (!transferSuccess) revert ETHStaking_RewardClaimFailed();

        success = true;

        emit RewardClaim(msg.sender, rewards);
    }

    function calculateRewards(address _address) public pure returns (uint256) {
        if (_address == address(0)) revert ETHStaking_AddressZeroNotAllowed();

        return 1;
    }

    function checkAddressZero(address _address) private pure {
        if (_address == address(0)) {
            revert ETHStaking_AddressZeroNotAllowed();
        }
    }
}
