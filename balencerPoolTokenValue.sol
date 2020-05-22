pragma solidity 0.5.12;


import "./BPool.sol";
//maybe import and use safemaths

contract balencerPoolTokenValue{
    address public BtokenAddress;
    uint public weiValue;
    mapping (address => uint256) internal tokenNumbers;
    mapping (address => uint256) internal tokenWeiValues;
    address[] internal currentTokens;
    BPool BpoolContract;

    
    address constant wETHaddess = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    constructor(address _BtokenAddress) public{
        BtokenAddress = _BtokenAddress;
        BpoolContract = BPool(_BtokenAddress);
        
    }
    
    function setPoolContractAddress(address _address) external {
        BpoolContract = BPool(_address);
    }
    
    function getPoolTokens() internal view returns(address[] memory){
        //getting the current tokens of the pool
        return(BpoolContract.getCurrentTokens());
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
    function getTotalSupply() internal view returns(uint){
        return(BpoolContract.totalSupply());
    }
    
    
    //tokens getSpotPrice
    function requestEthereumPrice(bytes32 _jobId, string _currency) public returns (bytes32 requestId) {
  // newRequest takes a JobID, a callback address, and callback function as input
  Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillEthereumPrice.selector);
  // Adds a URL with the key "get" to the request parameters
  req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,JPY");
  // Uses input param (dot-delimited string) as the "path" in the request parameters
  req.add("path", _currency);
  // Adds an integer with the key "times" to the request parameters
  req.addInt("times", 100);
  // Sends the request with 1 LINK to the oracle contract
  requestId = sendChainlinkRequest(req, 1 * LINK);
    }
    
    
    
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
    
    
    function getBtokenWeiValue() internal returns(uint){
        uint tokenValue = getPoolWeiValue()/getTotalSupply();
        return(tokenValue);
    }
    
    

    
}

/*interface InterfaceBPool{
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
    
} */
