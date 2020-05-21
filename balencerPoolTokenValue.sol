pragma solidity >0.6.6;



//maybe import and use safemaths

contract balencerPoolTokenValue{
    address public BtokenAddress;
    uint public weiValue;
    mapping (address => uint256) internal tokenNumbers;
    mapping (address => uint256) internal tokenWeiValues;
        address[] internal currentTokens;
    InterfaceBPool internal BpoolContract;

    
    address constant wETHaddess = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    constructor(address _BtokenAddress) public{
        BtokenAddress = _BtokenAddress;
        BpoolContract = InterfaceBPool(_BtokenAddress);
        
    }
    
    function setPoolContractAddress(address _address) external {
        BpoolContract = InterfaceBPool(_address);
    }
    
    function getPoolTokens() internal view returns(address[] memory){
        //getting the current tokens of the pool
        return(BpoolContract.getCurrentTokens());
    }
    
    //proportions (useless)
    function getTokenPercentage(address _tokenAddress) internal view returns(uint){
        return(BpoolContract.getNormalizedWeight(_tokenAddress));
    }
    
    //How many tokens in the Pool
    function getTokenBalance(address _tokenAddress) view internal returns(uint){
        return(BpoolContract.getBalance(_tokenAddress));
    }
    
    
    //combiens ils valent
    function getWeiValue(address _tokenAddress) internal view returns(uint){
        return(BpoolContract.getSpotPrice(_tokenAddress, wETHaddess));
    }
    
    
    //le nombre total de tokens
    /*function getTotalSupply() internal view returns(uint){
        return(BpoolContract.totalSupply());
    }
    */
    
    
    function getPoolWeiValue() public returns(uint){
        uint poolWeiValue = 0;
        currentTokens = getPoolTokens();
        for(uint i=0; i<currentTokens.length; i++){
            tokenNumbers[currentTokens[i]] = getTokenBalance(currentTokens[i]);
            tokenWeiValues[currentTokens[i]] = BpoolContract.getSpotPrice(currentTokens[i], wETHaddess);
            //integrate Chainlink oracle
            poolWeiValue += tokenNumbers[currentTokens[i]]*tokenWeiValues[currentTokens[i]];
        }
        return(poolWeiValue);
    }
    
    
    /*function getBtokenWeiValue() internal view returns(uint){
        uint tokenValue = getPoolWeiValue()/getTotalSupply();
        return(tokenValue);
    }
    */
    
    //how to imort properly a contract????!!!!!!!!
    
}

interface InterfaceBPool{
    function getCurrentTokens()
        external view
        returns (address[] memory tokens);
    function getSpotPrice(address tokenIn, address tokenOut)
        external view
        returns (uint spotPrice);
    function getNormalizedWeight(address token)
        external view
        returns (uint);
    function getBalance(address token)
        external view //_viewlock_ ?????
        returns (uint);
    
} 
