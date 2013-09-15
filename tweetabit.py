#!/usr/bin/env python
# -*- coding: utf-8 -*-
#

# pip install tweetpony
# pip install apscheduler

import urllib2
import json
from time import sleep
import tweetpony
from apscheduler.scheduler import Scheduler

# Start the scheduler
sched = Scheduler()
sched.start()
 
class requester:
	def __init__(self, consumer_key="",consumer_secret="",access_token="", access_token_secret=""):
		self.api = tweetpony.API(consumer_key, consumer_secret, access_token, access_token_secret)
 
	def query(self, path):
		req = urllib2.Request("http://data.mtgox.com/api/"+path)
		res = urllib2.urlopen(req)
		return json.load(res)
	
	def parse(self, json_data):
		if json_data["result"]=="success":
			usd = json_data["data"]["last"]
			return usd["value"]+" "+usd["currency"]
		else:
			print "Error connetting to http://data.mtgox.com/api/" 
		return 42
			
	def tweet(self, tweet):
		try:
			self.api.update_status(status = tweet)
		except tweetpony.APIError as err:
			print "Twitter returned error #%i and said: %s" % (err.code, err.description)
		else:
			print "Tweet Sent!"
			print tweet


def job_function():
	q = r.query("2/BTCUSD/money/ticker_fast")
	price_usd = r.parse(q)
	q = r.query("2/BTCEUR/money/ticker_fast")
	price_eur = r.parse(q)
	r.tweet("1 BTC = "+price_usd+" = "+price_eur)


print "TweetABit Started!"

r=requester("","","","")
	
# Schedule job_function to be called every two hours
sched.add_interval_job(job_function, hours=1)
while True:
        sleep(1)

print "TweetABit Finish"
