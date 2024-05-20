'''
MM1_NP_eqanalysis - plots to support the equilibrium analysis for MM1 NP AR queue
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
font = {'family' : 'sans-serif',
        'weight' : 'bold',
        'size'   : 12}
rc('font', **font)

# define values of Phi to plot analytical function
PHI = np.zeros(1001)
for p in range(1001):
	PHI[p] = p/1000

# define values of Phi to plot simulated results
PHI_SIM = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

LAM = [0.1, 0.5, 0.9]

for l in range(3):
	lam = LAM[l]
	# create figure
	workingdir = os.path.dirname(__file__) # absolute path to current directory
	figfile = os.path.join(workingdir, 'eqanalysisfiles/test_lambda_{0}.png'.format(lam))
	os.makedirs(os.path.dirname(figfile), exist_ok = True)
	fig = plt.figure()
	ax = plt.subplot(111)
	# plot analytical Cost for given lambda
	C = np.zeros(1001) 
	for p in range(1001):
		C[p] = ((lam**2)*PHI[p])/((1-lam)*(1-lam*(1-PHI[p]))**2)
	plt.plot(PHI, C, label='$C(\\phi)$ analytical') 
	C_under =  (lam**2)/((1-lam)) # C underbar; defined as C(1)
	#plt.hlines(C_under, PHI[0], PHI[1000], colors='r', linestyles='dashed', label = '$\\underline{C}$')
	if l > 5:
		C_over = lam/(4*((1-lam)**2)) # C overbar; defined as maximum of function, if lambda/mu > 1/2
		#plt.hlines(C_over, PHI[0], PHI[1000], colors='g', linestyles='dashed', label = '$\\overline{C}$')
	# plot simulated results
	C_sim = np.zeros(9)
	C_err = np.zeros(9)
	i = 0
    # read in from CSV files
	costfile = os.path.join(workingdir, 'costfiles/costs_lambda_{0}.csv'.format(lam)) # CSV file containing mean costs - uses default separator, line termination values
	with open(costfile, 'r') as costcsv:
		costs = csv.reader(costcsv)
		for row in costs:
			costvals = [float(m) for m in row]
			C_sim[i] = costvals[0]
			C_err[i] = costvals[1]
			i += 1
	plt.errorbar(PHI_SIM, C_sim, yerr = C_err, fmt = 'x', label = '$C(\\phi)$ simulated')
	# from simulated data, plot results
	plt.xlabel('$\\phi$')
	plt.ylabel('$C$')
	box = ax.get_position()
	ax.set_position([box.x0, box.y0, box.width, box.height*0.9])
	ax.legend(loc = 'upper center', bbox_to_anchor=(0.5,1.2), fancybox = True, shadow=True, ncol=3)
	plt.savefig(figfile)
	plt.close()

