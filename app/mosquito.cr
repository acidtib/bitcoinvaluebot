require "mosquito"
require "crest"
require "json"
require "moola"
require "redis"
require "twitter-crystal"

REDIS = Redis.new(url: ENV["REDIS_URL"])
TWITTERC = Twitter::REST::Client.new(ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"], ENV["TWITTER_ACCESS_TOKEN"], ENV["TWITTER_ACCESS_TOKEN_SECRET"])

COOLLISTOFCOINS = "BTC,BCH,BSV"

require "../src/services/*"
require "../src/jobs/*"

Mosquito::Runner.start