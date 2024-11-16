// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotteryContract{
    string public name;
    string public description;
    uint256 public ticketPrice;
    uint256 public maxNumberOfTicket;
    uint256 public totalTicketBought;
    uint256 public deadline;
    address public owner;
    bool public paused;
    address public winner;
    enum LotteryState { Active, Completed }
    LotteryState public state;
    address[] public usersInPool;

    mapping(address => bool) boughtTicket;

    // @dev : modifiers

    modifier isOpen(){
        require(paused == false, "Lottery is currently paused");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier lotteryOpen() {
        require(state == LotteryState.Active, "Lottery is not active.");
        _;
    }

    modifier lotteryClosed() {
        require(state == LotteryState.Completed, "Lottery is still active.");
        _;
    }

    // @dev : constructor

    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint256 _ticketPrice,
        uint256 _maxNumberOfTicket,
        uint256 _durationInDays
    ) {
        name = _name;
        description = _description;
        ticketPrice = _ticketPrice;
        maxNumberOfTicket = _maxNumberOfTicket;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = _owner;
        state = LotteryState.Active;
    }

    // @dev : fucntions

    function checkAndUpdateLotteryState() internal {
        if(state == LotteryState.Active) {            
            if(block.timestamp >= deadline) {
                state = LotteryState.Completed;   
                pickWinner();         
            } else if(totalTicketBought == maxNumberOfTicket) {
                state = LotteryState.Completed;  
                pickWinner();         
            }
        }
    }

    function buyTicket() public payable lotteryOpen isOpen{
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(boughtTicket[msg.sender] == false, "You can only have access to buy one ticket");

        totalTicketBought = totalTicketBought + 1;
        usersInPool.push(msg.sender);
        boughtTicket[msg.sender] = true;
        checkAndUpdateLotteryState();
    }

    function pickWinner() internal lotteryClosed{
        require(usersInPool.length > 0, "No participants in the lottery");

        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    usersInPool.length
                )
            )
        ) % usersInPool.length;

        winner = usersInPool[randomIndex];

        payable(winner).transfer(address(this).balance);
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function extendDeadline(uint256 _daysToAdd) public onlyOwner lotteryOpen {
        deadline += _daysToAdd * 1 days;
    }

    function getUsersInPool() public view returns (address[] memory){
        return usersInPool;
    }
}