#!/usr/bin/env ruby

# gem install twitter
# gem install openwferu-scheduler

require 'net/http'
require 'json'
require 'twitter'
require 'openwfe/util/scheduler'
include OpenWFE
scheduler = Scheduler.new
scheduler.start

class Requester
	def initialize(consumer_key="",consumer_secret="",access_token="", access_token_secret="")
		# Twitter login
		Twitter.configure do |config|
			config.consumer_key = consumer_key
			config.consumer_secret = consumer_secret
			config.oauth_token = access_token
			config.oauth_token_secret = access_token_secret
		end
	end
	def query(path)
		req = Net::HTTP.get_response(URI.parse("http://data.mtgox.com/api/"+path))
		data = JSON.parse(req.body)
		return data
	end
	def parse(data)
		if data["result"]=="success" then
			usd = data["data"]["last"]
			return usd["value"]+" "+usd["currency"]
		else
			puts "Error connetting to http://data.mtgox.com/api/" 
		end
		return 42
	end
	def tweet(text)
		Twitter.update(text)
		puts "Tweet Sent!"
		puts text
	end
end


r = Requester.new("kO6VhP09TQpKbImtMOFXXA",
	"h6chYQ7wQNmUDc6ZUZmSUtszsf6D4QqfhFrmO9CvM6g",
	"1057601774-kZw3YD1B88UHDIHq4CD0o6QlDUzhWJe1G5tJCse",
	"HBO5GCaXTivYwxdLxERQOUpazEqAS5iJRhXFz1R51Wk")

scheduler.schedule_every('1h') { 
	q = r.query("2/BTCUSD/money/ticker_fast")
	price_usd = r.parse(q)
	q = r.query("2/BTCEUR/money/ticker_fast")
	price_eur = r.parse(q)
	r.tweet("1 BTC = "+price_usd+" = "+price_eur)
}

scheduler.join
