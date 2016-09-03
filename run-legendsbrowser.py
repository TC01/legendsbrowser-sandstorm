#!/usr/bin/env python

# Helper script to actually launch Legends Browser.
# Runs in a separate process; keeps Legends Browser running.

import subprocess
import socket
import sys

# Import fasteners
import fasteners

def run_legendsbrowser(lbargs):
	# Run LB, block until process dies, relaunch!
	while True:
		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		result = sock.connect_ex(('127.0.0.1', 58881))
		if result != 0:
			# Only one version of this process should be able to spawn legendsbrowser
			# (Multiple can get started, this fix is easier).
			with fasteners.InterProcessLock('/var/tmp/run-legendsbrowser-lock'):
				proc = subprocess.Popen(lbargs)
				# We *could* check the output for RAM errors or something ,but now that LB can take
				# 1 GB of RAM it's probably less of a problem.
				proc.wait()

def main():
	# Modify arguments passed to this script; change the executable name.
	lbargs = sys.argv
	lbargs[0] = "legendsbrowser"

	# Run legends browser! (and keep running it unless we run out of RAM)
	run_legendsbrowser(lbargs)

if __name__ == '__main__':
	main()
