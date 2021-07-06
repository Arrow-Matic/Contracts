// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PoERewards is ERC721URIStorage {
    
    uint256 private tokenId;
    uint256 private bountyId;
    
    
    //mapping of bounty info to bounty ID 
    mapping(uint256 => NFTbounties) bounties;
    
    //mapping to check reward claim status by user
    mapping(address => mapping(uint256=>bool)) userRewards;
    
    struct user{
        uint256 userPoints;
        address userAddress;
    }
    
    struct NFTbounties{
        address contractAddress;
        string URI;
        uint256 distributionNumber;
        uint256 distributedTo;
    }
    
    uint256 private BountyCreationCost;
    user[10] private Leaderboard;
    
    
    
    event Claimed(address indexed _by, uint256 indexed _tokenId);
    event LeaderBoardUpdate(user[10] Leaderboard);
    event BountyCreated(address indexed _contract,string URI,uint256 quantity);
    
    constructor() ERC721("Proof Of Experience","POE"){
        tokenId = 1;
        bountyId = 1;
        BountyCreationCost = 0.05 *1 ether;
        _owner = msg.sender;
    }
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function BountyExists(uint256 bountyID) internal view returns(bool){
        if(bounties[bountyID].contractAddress != address(0))
        {
            return true;
        }
        return false;
    }
    
    function CreateBounty(address contractAdd,string memory URI, uint256 quantity) external payable{
        require(msg.value == BountyCreationCost,"POE : Sent value is not the price");
        NFTbounties memory bounty;
        bounty.contractAddress = contractAdd;
        bounty.URI = URI;
        bounty.distributionNumber = quantity;
        bounties[bountyId] = bounty;
        emit BountyCreated(contractAdd,URI,quantity);
    }
    
    function ClaimBounty(uint256 bountyID,uint256 points) external{
        require(BountyExists(bountyID),"POE : Bounty doesn't exist");
        require(!userRewards[msg.sender][bountyID],"POE: Bounty claimed already");
        userRewards[msg.sender][bountyID] = true;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, bounties[bountyID].URI);
        emit Claimed(msg.sender, tokenId);
        tokenId = tokenId + 1;
        checkLeaderBoard(points);
    }
    
    function checkLeaderBoard(uint256 points) internal returns(bool){
        if(points <=  Leaderboard[9].userPoints){
            return false;
        }
        
        uint i;
        uint tempPoint;
        address tempAdd;
        
        Leaderboard[9].userPoints = points;
        Leaderboard[9].userAddress = msg.sender;
        
        for(i=8;i>=0;i--)
        {
            if (points > Leaderboard[i].userPoints){
                tempPoint = Leaderboard[i].userPoints;
                tempAdd = Leaderboard[i].userAddress;
                
                Leaderboard[i].userPoints = Leaderboard[i+1].userPoints;
                Leaderboard[i].userAddress = Leaderboard[i+1].userAddress;
                
                Leaderboard[i+1].userPoints = tempPoint;
                Leaderboard[i+1].userAddress = tempAdd;
            }
            else{
                break;
            }
        }
        emit LeaderBoardUpdate(Leaderboard);
        return true;
    }
    
    function getLeaderBoard() external view returns(user[10] memory){
        return Leaderboard;
    }
    
    function retrieve() external onlyOwner {
        payable(owner()).transfer(balanceOf(address(this)));
    }
}