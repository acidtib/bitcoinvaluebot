module BVB::Services
  class CoinMarketCap
    def self.coins
      coins = Array(NamedTuple(symbol: String, price: String, percent_change_1h: String)).new()

      response = Crest.get(
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest",
        headers: {"Content-Type" => "application/json", "X-CMC_PRO_API_KEY" => ENV["COINMARKETCAP_API_KEY"]},
        params: {:symbol => COOLLISTOFCOINS}
      )
      list = JSON.parse(response.body)["data"]

      COOLLISTOFCOINS.split(",").each do |s|
        coin = {
          symbol: s,
          price: list[s]["quote"]["USD"]["price"].to_s,
          percent_change_1h: list[s]["quote"]["USD"]["percent_change_1h"].to_s
        }

        coins.push(coin)
      end

      coins
    end
  end
end