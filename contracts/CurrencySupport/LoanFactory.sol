pragma solidity ^0.4.15;
/*
    An oracle for converting between crytpo and fiat currencies. For testing
    purposes this allows the owner to set the price, eventually this will be
    connect to Oraclize to get real update-to-date data. Can also be expanded
    to include other currencies.
    This is modelled after USDOracle
*/
contract CurrencyConversionOracle {

    address public admin;
    // A mapping of 3-letter currency codes to the number of that currency's cents in wei
    bytes3[] public currencyCodes;
    mapping(bytes3 => uint) public currencyCentsToWei;

    function CurrencyConversionOracle() public {
        // Set rates as of Nov 8th 2017
        currencyCodes.push('USD');
        currencyCentsToWei['USD'] = 31971353667114;
        currencyCodes.push('ZAR');
        currencyCentsToWei['ZAR'] = 2261057543643;
    }

    // Whoever calls initialize first is the admin
    function initialize() public {
        admin = msg.sender;
    }

    // The admin is responsible for keeping this up to date
    // Eventually this value will come from Oraclize like USDOracle does
    function setOneCentOfWei(bytes3 _currency, uint _oneCentOfWei) public {
        require(msg.sender == admin);
        if (currencyCentsToWei[_currency] == 0) {
            currencyCodes.push(_currency);
        }
        currencyCentsToWei[_currency] = _oneCentOfWei;
    }
    
    // 1 cent of given currency in WEI eg 31971353667114 for USD cents
    function oneCentOfWei(bytes3 _currency) public view returns (uint) {
        require(currencyCentsToWei[_currency] != 0);
        return currencyCentsToWei[_currency];
    }

    // 1 unit of given currency in WEI eg 3197135366711400 for USD
    // Note: this assumes 100 cents per unit currency
    function oneCurrencyUnitInWei(bytes3 _currency) public view returns (uint) {
        return oneCentOfWei(_currency) * 100;
    }

    // 1 ETH in cents for the given currency eg 31278 USD cents for 1 ETH
    function oneEthInCurrencyCents(bytes3 _currency) public view returns (uint) {
        return 1 ether / oneCentOfWei(_currency);
    }
}