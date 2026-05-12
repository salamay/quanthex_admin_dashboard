const String bnb = "BNB";
const String bsc = "BSC";
const String pol = "POL";
const String eth = "ETH";

// ─────────────────────────────────────────────────────────────
//  Ethereum (Chain ID 1) — Top 30 ERC-20 Tokens
// ─────────────────────────────────────────────────────────────
const String eth_usdt_contract = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
const String eth_usdc_contract = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const String eth_weth_contract = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const String eth_wbtc_contract = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
const String eth_dai_contract = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
/// All Ethereum token addresses in one list.
const List<String> ethTokenAddresses = [
  eth_usdt_contract, eth_usdc_contract, eth_weth_contract, eth_wbtc_contract, eth_dai_contract
];

// ─────────────────────────────────────────────────────────────
//  BSC / BNB Smart Chain (Chain ID 56) — Top 30 BEP-20 Tokens
// ─────────────────────────────────────────────────────────────
const String bsc_usdt_contract = "0x55d398326f99059fF775485246999027B3197955";
const String bsc_usdc_contract = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d";
const String bsc_wbnb_contract = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
const String bsc_doge_contract = "0xbA2aE424d960c26247Dd6c32edC70B295c744C43";


/// All BSC token addresses in one list.
const List<String> bscTokenAddresses = [
  bsc_usdt_contract, bsc_usdc_contract, bsc_wbnb_contract, bsc_doge_contract,
];

// ─────────────────────────────────────────────────────────────
//  Polygon (Chain ID 137) — Top 30 Tokens
// ─────────────────────────────────────────────────────────────
const String polygon_usdt_contract = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
const String polygon_usdc_contract = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359";
const String polygon_doge_contract = "0x12E96C2BFEA6E835CF8Dd38a5834fa61Cf723736";
const String polygon_orio_contract = "0xAC1Cd197931810b6f115D690c72a3438990D3Ba3";


/// All Polygon token addresses in one list.
const List<String> polygonTokenAddresses = [
  polygon_usdt_contract, polygon_usdc_contract,
 polygon_doge_contract,
];