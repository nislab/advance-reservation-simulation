'''
MM1_HPR_simanalysis - plots of results from MM1 HPR AR simulations 
'''


import os
import matplotlib.pyplot as plt
from matplotlib import rc
import numpy as np
import csv


# define number of percentile buckets used to measure customers
BUCKETS = 20

workingdir = os.path.dirname(__file__) # absolute path to current directory

rc('text', usetex = True) # use LaTeX font and formatting

# Loop over Phi, Lambda, plot corresponding results
for i in range(1,10):
	lam = i/10 # cooresponding value of lambda from the index, ranges from 0.1 to 0.9
	# collect data from CSV file
	w_sim = np.zeros((9,BUCKETS))
	meanfile = os.path.join(workingdir, 'meanfiles/mean_lambda_{0}.csv'.format(lam)) # CSV file containing mean wait times; uses defaults for item and line separators
	error = np.zeros((9,BUCKETS))
	errfile = os.path.join(workingdir, 'errorfiles/error_lambda_{0}.csv'.format(lam)) # CSV file containing mean wait errors; uses defaults for item and line separators
	p = 0 # index of phi values in the simulation
	with open(meanfile, 'r') as meancsv:
		wait = csv.reader(meancsv)
		for row in wait:
			w_sim[p,:] = [float(M) for M in row]
			p += 1
	p = 0
	with open(errfile, 'r') as errcsv:
		err = csv.reader(errcsv)
		for row in err:
			error[p,:] = [float(E) for E in row]
			p += 1
	# Plot figures per value of lambda, phi
	for j in range(9):
		phi = (j+1)/10 # corresponding value of phi from the index
		'''
		Analytical formulae, to validate simulation
		'''
		w_ana = np.zeros(BUCKETS)
		for k in range(BUCKETS):
			if ((k)/BUCKETS) < phi:
				w_ana[k] = 1/((1-lam)*(1-lam*(1-phi))) - 1 #AR' customers
			else:
				w_ana[k] = (lam*(1-phi))/((1-lam*(1-k/BUCKETS))*(1-lam*(1-(k+1)/BUCKETS))) #AR customers
		'''
		#plot results
		'''
		x = np.zeros(BUCKETS)
		for i in range(BUCKETS):
			x[i] = i/BUCKETS
		figfile = os.path.join(workingdir, 'figfiles/lambda_{0}_phi_{1}.png'.format(lam,phi))
		os.makedirs(os.path.dirname(figfile), exist_ok = True)
		plt.figure()
		plt.plot(x, w_ana, label='$\\overline{W}_Q$ analytical') # analytical results
		plt.errorbar(x, w_sim[j,:], yerr = error[j,:], fmt = 'x', label = '$\\overline{W}_Q$ simulation') # simulation results with errorbars
		plt.title('Discretized wait times for $\\lambda$ = {0}, $\\mu$ = 1, $\\phi$ = {1}'.format(lam, phi))
		plt.xlabel('Reservation Period CCDF Percentile')
		plt.ylabel('Mean Queue Wait Time $\\overline{W}_Q$')
		plt.legend()
		plt.savefig(figfile)
		plt.close()


