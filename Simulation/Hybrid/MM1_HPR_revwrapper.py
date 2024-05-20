"""
Wrapper to define values for MM1_NP_Revsim Simulator, define save files for statistics, figure
Author: Jonathan Chamberlain, 2018 jdchambo@bu.edu
"""

from MM1_HPR_Revsim import Simulator
import os

'''
Define loop for simulators
Loop over values of lambda from 0.1 to 0.9
Loop over values of phi from 0.1 to 0.9
Fix Mu at 1
Save Mean wait times, error bounds, normalized error per threshold
Save figures for each run
'''

for i in range(1,10):
	l = i/10
	for j in range(1,10):
		p = j/10
		# define files and directories to save files
		workingdir = os.path.dirname(__file__) # absolute path to current directory
		revfile = os.path.join(workingdir, 'revfiles/revenues_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(revfile), exist_ok = True)
		print('Starting lambda = {0}, phi = {1}'.format(l,p))
		Simulator(l,1,p,revfile)

print('Simulations Complete')