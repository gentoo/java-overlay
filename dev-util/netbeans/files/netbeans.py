#! /usr/bin/env python
import os,sys,time
antProcess = os.popen3(sys.argv[1:])
antin = antProcess[0]
antout = antProcess[1]
line = antout.readline()
while line != '':
	sys.stdout.write(line)
	
	if line.endswith('(yes,no)\n'):
		for s in range(10):
			time.sleep(1)
			antin.write("yes\n")
	
		sys.stdout.write('yes\n')
		
	line = antout.readline()
	
