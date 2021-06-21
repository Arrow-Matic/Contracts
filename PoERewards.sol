// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./EIP712MetaTransaction.sol";

contract PoERewards is ERC721URIStorage,EIP712MetaTransaction("PoERewards","1") {
    
    uint256 private tokenId;
    address private _owner;
    
    
    
    struct user{
        address userAddress;
        uint256 userPoints;
    }
    
    user[10] public Leaderboard;
    
    event Claimed(address indexed _by, uint256 indexed _tokenId);
    event LeaderBoardUpdate(user[10] Leaderboard);

    
    
    constructor() ERC721("Proof Of Experience","POE"){
        tokenId = 1;
        _owner = msg.sender;
    }
    
    function Claim(string memory tokenURI,uint256 points) external{
        _safeMint(msgSender(), tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit Claimed(msgSender(), tokenId);
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
        Leaderboard[9].userAddress = msgSender();
        
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
    }
    

    
}