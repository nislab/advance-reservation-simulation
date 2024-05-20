'''
MM1_wait_time_analysis - plots analytical wait time and cost formulas to check results make sense
for a system where all customers have PR behavior
'''

import matplotlib.pyplot as plt
from matplotlib import rc
import os
import numpy as np
import csv

'''
Define loop for plots
Lambda varies between 0.1 and 0.9, mu is fixed at 1
Plot analytical curve with respect to Phi from 0 to 1, in increments of 1/1000
Plot simulated results at given thresholds from 0.1 to 0.9
'''
rc('text', usetex = True) # use LaTeX font and formatting

# define values of Phi to plot analytical function
PHI = np.zeros(1001)
for p in range(1001):
	PHI[p] = p/1000


for l in range(1,10):
	lam = l/10
	# create figure
	workingdir = os.path.dirname(__file__) # absolute path to current directory
	figfile = os.path.join(workingdir, 'wtafiles/test_lam_{0}.png'.format(lam))
	os.makedirs(os.path.dirname(figfile), exist_ok = True)
	plt.figure()
	# plot wait time for choosing AR for threshold p, given lambda
	W_AR = np.zeros(1001)
	for p in range(1001):
		W_AR[p] = 1/((1-lam*(1-PHI[p]))**2) - 1
	plt.plot(PHI, W_AR, label='$W_{AR}(\\phi)$')
	# plot wait time for not choosing AR for threshold p, given lambda
	W_nAR = np.zeros(1001)
	for p in range(1001):
		W_nAR[p] = 1/((1-lam)*(1-lam*(1-PHI[p]))) - 1
	plt.plot(PHI, W_nAR, label='$W_{AR\'}(\\phi)$')
	# plot resulting cost for thresholds p, given lambda
	C = W_nAR - W_AR
	plt.plot(PHI, C, label='C($\\phi$)') 
	# from simulated data, plot results
	plt.title('Plot of wait time vs threshold for $\\lambda$ = {0}'.format(lam))
	plt.xlabel('Threshold ($\\phi$)')
	plt.ylabel('Wait time')
	plt.legend()
	plt.savefig(figfile)
	plt.show()
	plt.close()