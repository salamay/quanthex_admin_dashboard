class ApiConstants {
  ApiConstants._();
  static String quoteHistorical="https://pro-api.coinmarketcap.com/v3/cryptocurrency/quotes/historical";
  static String marketQuotes="https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest";
  static String tokenPrice="https://pro-api.coingecko.com/api/v3/simple/token_price";
  static String quoteById="https://pro-api.coingecko.com/api/v3/simple/price";
  static String assetPlatform="https://pro-api.coingecko.com/api/v3/asset_platforms";
  static String moralisTokenMetadata="https://deep-index.moralis.io/api/v2.2/erc20/metadata";
  static String moralisErc20Transfers="https://deep-index.moralis.io/api/v2.2";
  static String moralisNativeTransfers="https://deep-index.moralis.io/api/v2.2/";
  static String cmcListings="https://pro-api.coinmarketcap.com/v3/cryptocurrency/listings/latest";
  // static String BSCRpc="https://bsc-dataseed3.binance.org/";
  static String BSCRpc="https://go.getblock.io/afb9702b784d4b2fa1b1b43290ecf787";
  // static String BSCRpc="https://go.getblock.io/119fad79ee5d4ffda4c3de8fdc77618e";
  static String BSCRpcSocket="wss://go.getblock.io/ef494243c89a43308efe513aad8ab92c";
  static String ETHRpc="https://go.getblock.io/e290a2fbe2574872924a89852fa341f0";
  static String ETHRpcSocket="wss://go.getblock.io/b06c5d91b66d48be86ccd822d2414b2b";
  static String polygonRpc="https://go.getblock.io/64929c98232f46928335f57b7faeeb07";
  static String polygonRpcSocket="wss://go.getblock.io/92b3a24103dd49f58fd58358209cba12";
  static String boorioRpc="https://rpc1.boorio.tech/";
  static String arbitrumRpc="https://go.getblock.us/26a2bfa624654defa1a3f343262bc62f";
  static String arbitrumRpcSocket="wss://go.getblock.us/a0aa69781d5e486e84f2bad4c296bd28";
  static String avalancheRpc="https://go.getblock.us/26a2bfa624654defa1a3f343262bc62f";
  static String avalancheRpcSocket="wss://go.getblock.io/c1f9505172024d1089b03c83f1a3eae8/ext/bc/C/rpc";
  // Change this to your admin backend base URL
  static const String baseUrl = 'https://api.quanthex.io/adminapi';
  // static const String baseUrl = 'http://127.0.0.1:9243/adminapi';

  static String login = '$baseUrl/auth/login';
  static String minings = '$baseUrl/products/minings';
  static String submitPayment = '$baseUrl/products/submit-payment';
  static String manualMiningPayment = '$baseUrl/products/manual-mining-payment';
  static String stakings = '$baseUrl/products/stakings';
  static String stakingSettings = '$baseUrl/products/staking-settings';
  static String submitStakingPayment = '$baseUrl/products/submit-staking-payment';
  static String stakingUplinePayments = '$baseUrl/products/staking-upline-payments';
  static String submitUplinePayment = '$baseUrl/products/submit-upline-payment';
  static String miningPayments = '$baseUrl/products/mining-payments';
  static String stakingPayments = '$baseUrl/products/staking-payments';
  static String dailyRoiSettings = '$baseUrl/products/daily-roi-settings';
  static String dailyRoiEligible = '$baseUrl/products/daily-roi-eligible';
  static String dailyRoiPay = '$baseUrl/products/daily-roi-pay';
  static String dailyRoiPayAll = '$baseUrl/products/daily-roi-pay-all';
  static String dailyRoiPayments = '$baseUrl/products/daily-roi-payments';

}
