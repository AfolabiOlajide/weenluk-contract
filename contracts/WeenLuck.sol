// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { LotteryContract } from "./LotteryContract.sol";

contract WeenLuk{
    address public owner;
    bool public paused;

    struct Lottery{
        address lotteryAddress;
        address owner;
        string name;
        uint256 creationTime;
    }

    Lottery[] public lotteries;
    mapping(address => Lottery[]) public userLotteries;

    // @dev : modifiers

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    modifier notPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // @dev : functions

    function createLottery(
        string memory _name,
        string memory _description,
        uint256 _ticketPrice,
        uint256 _maxNumberOfTicket,
        uint256 _durationInDays
    ) external notPaused {
        LotteryContract newCampaign = new LotteryContract(
            msg.sender,
            _name,
            _description,
            _ticketPrice,
            _maxNumberOfTicket,
            _durationInDays
        );
        address lotteryAddress = address(newCampaign);

        Lottery memory campaign = Lottery({
            lotteryAddress: lotteryAddress,
            owner: msg.sender,
            name: _name,
            creationTime: block.timestamp
        });

        lotteries.push(campaign);
        userLotteries[msg.sender].push(campaign);
    }

    function getUserLotteries(address _user) external view returns (Lottery[] memory) {
        return userLotteries[_user];
    }

    function getAllLotteries() external view returns (Lottery[] memory) {
        return lotteries;
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }
}