class TwitterPostJob < Mosquito::PeriodicJob
  run_every 60.minute

  def perform
    coins = BVB::Services::CoinMarketCap.coins
    sum_of_forks : Float64 = 0

    if REDIS.exists("hourlysum_of_forks") == 0
      coins.each do |coin|
        sum_of_forks = (sum_of_forks + coin["price"].to_f)
      end
      REDIS.set("hourlysum_of_forks", sum_of_forks.to_s)
    else
      coin_lines : String = ""
      archive = [] of NamedTuple(symbol: String, price: String, trend: String, change1h: String)

      coins.each do |coin|
        coin_symbol = coin["symbol"]
        coin_price = coin["price"].to_f
        coin_price_formatted = BVB::Services::Money.new(coin_price)
        coin_percent_change1h = coin["percent_change_1h"]
        coin_percent_change1h_rounded = coin_percent_change1h.to_f.round(2).format(decimal_places: 2).to_s
        coin_trend = trend(coin_percent_change1h)

        new_line = "$#{coin_symbol} = #{coin_price_formatted} #{coin_trend} #{coin_percent_change1h_rounded}%\n"
        sum_of_forks = (sum_of_forks + coin_price)
        coin_lines = coin_lines + new_line

        archive << {
          symbol: coin_symbol,
          price: coin_price_formatted,
          trend: coin_trend,
          change1h: coin_percent_change1h_rounded
        } 
      end

      last_hourly_price = REDIS.get("hourlysum_of_forks").to_s.to_f

      last_hour_diff = percent_diff(last_hourly_price, sum_of_forks).format(decimal_places: 2)

      fork_lines = "Current Bitcoin Price\nAll Forks = #{BVB::Services::Money.new(sum_of_forks)} #{trend(last_hour_diff.to_s)} #{last_hour_diff}%\n--\n" + coin_lines

      REDIS.set("hourlysum_of_forks", sum_of_forks.to_s)
      REDIS.set("hourly_archive", archive.to_json)
      REDIS.set("last_tweet", fork_lines)

      TWITTERC.update(fork_lines) if ENV["APP_ENV"] == "production"
    end
  end

  def trend(value)
    if value.includes? "-"
      trend = "📉"
    else
      trend = "📈"
    end

    trend
  end

  def percent_diff(old_price, new_price)
    (100.0 * ((new_price - old_price) / old_price)).round(2)
  end
end