#!/usr/bin/env python

import json
import sys
import os
from urllib2 import Request, urlopen, URLError, HTTPError

SERVER = 'https://api.shodan.io/shodan/host/'
ipfile = ''
shodanfile = ''
API_KEY = 'INPUT YOUR SHODAN API HERE'

def shodan_search():
    w = open(shodanfile, 'w')    
    with open(ipfile, 'r') as f:
    		content = f.read().splitlines()
		for line in content:
			try:
				headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
				
				#'https://api.shodan.io/shodan/host/xxx.xxx.xxx.xxx?key=SHODAN_API_KEY'
				
				req = Request(SERVER + line + "?key=" + API_KEY)
				req.add_header('Content-Type', 'application/json')
				res = urlopen(req)
				data = json.load(res)
				jsonData = data["data"]
				try:	
					for item in jsonData:
    						port = item.get("port")
    						banner = item.get("product")
						version = item.get("version")
						w.write("%s, %s:%s/%s\n" % (line, port, banner,version))				
						print "IP: %s, Port: %s, Banner: %s, Version: %s" % (line, port, banner, version)
									
				except:
					print "error"
					pass    
			except HTTPError as e:
						sys.stdout.write('[-] ERROR: HTTP %d for %s\n' % (e.code, line))
						pass
						
			except URLError as e:
						sys.stdout.write('[-] ERROR: UNREACHABLE - %s\n' % e.reason)
						pass
						
    f.close()
    w.close()

if __name__ == '__main__':
    _type = None
    ipfile = os.getcwd()+"/output/"+sys.argv[1]+"/ip.txt"
    shodanfile = os.getcwd()+"/output/"+sys.argv[1]+"/shodan.txt"
    shodan_search()      

