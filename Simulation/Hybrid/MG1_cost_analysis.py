'''
MM1_wait_time_analysis - plots analytical wait time and cost formulas to check results make sense
for a hybrid NP/PR system
'''

import matplotlib.pyplot as plt
from matplotlib import rc
import os
import numpy as np
import csv

'''
Define loop for plots
Lambda varies between 0.05 and 0.95, mu is fixed at 1,
K varies between 1 and 10
Plot analytical curve with respect to Phi from 0 to 1, in increments of 1/1000
Plot simulated results at given thresholds from 0.1 to 0.9
'''
rc('text', usetex = True) # use LaTeX font and formatting

# define values of Phi to plot analytical function
PHI = np.zeros(1001)
for p in range(1001):
	PHI[p] = p/1000

workingdir = os.path.dirname(__file__) # absolute path to current directory
for l in range(1,20):
	lam = l/20
	figfile = os.path.join(workingdir, 'arcostfiles/test_lam_{0}.png'.format(lam))
	os.makedirs(os.path.dirname(figfile), exist_ok = True)
	plt.figure()
	for K in range(1,11):
		# plot cost for choosing AR for threshold p, given lambda, K
		C = np.zeros(1001)
		for p in range(1001):
			C[p] = (2*(1-lam*(1-PHI[p]))*(1-lam) + lam*K*PHI[p])/(2*((1-lam*(1-PHI[p]))**2)*(1-lam)) - 1
		plt.plot(PHI,C, label='$K$ = {0}'.format(K))
	plt.title('Plot of wait time vs threshold for $\\lambda$ = {0}'.format(lam))
	plt.xlabel('Threshold ($\\phi$)')
	plt.ylabel('AR Cost')
	plt.legend()
	plt.savefig(figfile)
	plt.close()