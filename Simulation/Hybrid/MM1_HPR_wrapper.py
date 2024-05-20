"""
Wrapper to define values for MM1_HPR_sim Simulator, define save files for statistics, figure
Author: Jonathan Chamberlain, 2018 jdchambo@bu.edu
"""

from MM1_HPR_sim import Simulator
import os

'''
Define loop for simulators
Loop over values of lambda from 0.1 to 0.9
Loop over values of phi from 0.1 to 0.9
Fix Mu at 1
Save Mean wait times, error bounds, normalized error per threshold
Save figures for each run
'''

lam = [0.1, 0.5, 0.9]

for i in range(3):
	l = lam[i]
	for j in range(1,10):
		p = j/10
		# define files and directories to save files
		workingdir = os.path.dirname(__file__) # absolute path to current directory
		meanfile = os.path.join(workingdir, 'meanfiles/mean_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(meanfile), exist_ok = True)
		errfile = os.path.join(workingdir, 'errorfiles/error_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(errfile), exist_ok = True)
		normfile = os.path.join(workingdir, 'normfiles/normerr_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(normfile), exist_ok = True)
		numfile = os.path.join(workingdir, 'numfiles/num_cust_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(numfile), exist_ok = True)
		costfile = os.path.join(workingdir, 'costfiles/costs_lambda_{0}.csv'.format(l))
		os.makedirs(os.path.dirname(costfile), exist_ok = True)
		print('Starting lambda = {0}, phi = {1}'.format(l,p))
		Simulator(l,1,p,meanfile, errfile, normfile, numfile, costfile)

print('Simulations Complete')