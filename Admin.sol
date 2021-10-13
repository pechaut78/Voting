// contracts/Admin.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable{
    mapping(address=>bool) _WhiteList;
    
    
    constructor() Ownable() {}
    
    modifier isNotNull(address addr)
    {
        require(addr!=address(0),"Addres should not be null");
        _;
    }
    
    function whitelist(address white) public onlyOwner() isNotNull(white)
    {
        _WhiteList[white]=true;
    }
    
    function blacklist(address black) public onlyOwner() isNotNull(black)
    {
        _WhiteList[black]=false;
    }
    
    function isWhiteListed(address adr) public view returns( bool)
    {
        return  _WhiteList[adr];
    }
        function isBlackListed(address adr) public view  returns( bool)
    {
        return  !_WhiteList[adr];
    }
    
}
