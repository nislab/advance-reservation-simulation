# advance-reservation-simulation

Simulation code to model priority purchasing queuing games, where priorities are derived from a system in which resources are claimed on the basis of a system of Advance Reservations.

Under advance reservation, the time axis is split into two distinct periods: a reservation period and a service period. 

During the reservation period, potential customers arrive and attempt to reserve service at a future point in time. Upon arrival, customers are offered a potential priority in the interval [1,0)* based on the estimated fraction of customers remaining prior to the start of the service period. If the offer is accepted, the potential priority becomes the customer's actual priority for service. If rejected, the customer defaults to priority 0, which is equivalent to seeking service "on-demand" at the desired time, as if they never sought the reservation to begin with. The first customer to arrive in a given reservation period is offered priority 1. Some customer later on will receive a potential priority of 2/3, implying an estimate of 2/3 of customers remaining before the start of service (or alternatively, 1/3 of customers have already arrived to the system). 

During the ervice period, customers are queued baed on the desired service time, which is not necessarily the same order in which customers arrived during the reservation period. The reservation priority determines whether a cutomer enters servie at their desired point in time, whether they must wait for service, or whether they are subject to interruption, depending in part on the policy in place for handling instances of higher priority reservations requesting service times starting after a lower priority and/or on-demand user, particularly those already in service at the start of the higher priority user's requested service period:

- `Non Preemptive`, lower priority users cannot be preempted while in service, but the highest prioirty user in the queue takes the next slot, even if it corresponds to a different user's reserved start period.
- `Preemptive Resume`, lower priority users are subject to preemptions by higher priority users upon their arrival, however service progress is not lost and the customer resumes from the point of interruption; therefore total work is the same, but the wait time of an individual user can be extended.
- `Hybrid`, any user with a reservation cannot be preempted while in service, even if a higher priority user arrives to a lower priority user in service; however on-demand users are subject to preemption under Preemptive Resume conditions. 

*(the abuse of notation is intentional)

The below figure provides a visual example, assuming the Preemptive Resume model<sup>[1,2]</sup>: 

![A sample Advance Reservation secnario featuring three customers](/Eran_example.png?raw=true "AR Example")

In this example Customers 1,2,3 arrive in that order at times *t_i* with requesting starting service times *s_i* during the service period. The priority order is determined by the order of arrivals, however here Customer 2 has the earliest request and is permitted to enter service first. With preemptive policies in effect, Customer 1 is permitted to enter service at their start time despite Customer 2 being in service. Customer 3, having the lowest priority, must wait for both the customers to complete service and thus enters service slightly after their desired reservation time.

Readers are directed to the following citation for further details on the AR system:

[1] Chamberlain, Jonathan, Eran Simhon, and David Starobinski. "Preemptible queues with advance reservations: Strategic behavior and revenue management." *European Journal of Operational Research* 293.2 (2021): 561-578.

[2] Figure first appeared in Simhon, Eran and David Starobinski. "Equilibrium and Learning in Queues with Advance Reservations" Preprint: arXiv:1806.08016 [cs.GT]

--------------
# Usage

The simulation directory contains three branches, corresponding to the policies described in the introduction above:

- `Non_Preemptive` - files prefixed with NP
- `Preemptive_Resume` - files prefixed with PR
- `Hybrid` - files prefixed with Hybrid

The simulation code itself consists of a series of scripts interacting with one another, where XX is the corresponding prefix:

 * XX_sim.py - contains the main simulation code for each policy
 * XX_wrapper.py - consists of a wrapper which calls the main simulation, used to enable loops over multiple values of the arrival and service rate parameters as well as the equilibirum threshold, and specify the destination files for the data output by the simulator
 * XX_simanalysis.py - takes the specified number of buckets customers have been sorted into and the current path and plots the simulated results against the analytical delays, accounting for aggregation of customers into groups by number of buckets.
 * XX_eqanalysis.py - plots the costs computed by the simulation against the cost expected from the analytical formula
 * XX_Revsim.py - A modified version of the main simulation code to compute expected revenues, by also accounting for the variable number of customers which can accrue in each simualtion run
 * XX_revwrapper.py - a corresponding wrapper for the Revsim version of the main simulator to facilitate loops.
 * XX_revanalysis.py - plots the revenue computed by the Revsim simulation vs the analytical simulation.

To trigger a simualation, call the appropriate XX_wrapper.py file from the command line, modifying the inputs and parameters as necessary as described below. The wrapper in turn calls the corresponding XX_sim.py to import the Simulator routine itself. Calling the XX_revwrapper.py file triggers an alternative version which computes the associated revenues specifically; this wrapper calls the XX_Revsim.py file to import the Simulator.

To plot visualizations using matplotlib, call the XX_simanalysis.py file in the same folder as the files containing the mean wait times and wait time errors, XX_eqanalysis.py in the same folder as the files containing the AR costs, and XX_revanalysis.py in the same folder as the files contiaining the computed mean revenues and errors. 

For a visualization of how the Hybrid vs the PR wait times and corresponding costs compare analytically, simply call the corresponding XX_wait_time_analysis.py files - these do not depend on any simulations having been run.

## Dependencies

The main simulation utilizes Python code, specifically [SimPy](https://simpy.readthedocs.io/en/latest/contents.html)

The code was originally written in Python 3 using SimPy version 3. 

To utilize the code, in addition to SimPy, it is also necessary to install NumPy and SciPy for statistical analysis. These can be installed using pip:

```
pip install numpy
pip install scipy
pip install simpy
```

The code also used an earlier version of NumPy which utilizes an alternate syntax for the random number generation routine, and may require updates to function correctly.

For visualizations, [Matplotlib](https://matplotlib.org/) is utilized. The code was originally written in version 3.1. 

If necessary to install, Matplotlib can be installed via pip, or conda for users utilizing that method:

'''
python -m pip install -U pip
conda install matplotlib
'''

Any relevant matplotlib dependencies are automatically installed. Alternatively, the simualtor output as described below are CSV files which can be imported into elsewhere, e.g. MATLAB for visualization/analysis if one so chooses.

## Inputs

The intent is that the wrappers be used when calling the simulators, so that multiple simulations can be run in a single routine - however it is possible to run a single iteration by calling the XX_sim.py file directly provided all proper inputs are supplied to save off the relevant data. 

By default, the data is collected and saved in the same directory the simulator code is run in. To customize the save files or paths, it is necessary to modify the following, where lambda_{0} is the corresponding value of lambda from the simulation:
* workingdir - by default this is set to the current directory using os.path.dirname(__file__). To change this, specify the absolute path of the destination. Changing this will change the root directory for all save files noted below. 
* meanfile - the file contiaining the sample mean waiting time for each bucket of user, by default this is workingdir/meanfiles/mean_lambda_{0}.csv.
* errfile - the file containing the 95\% confidence interval of the sample errors for each user bucket, by default this is workingdir/errorfiles/error_lambda_{0}.csv
* normfile - the file containing the normalized error for each user bucket, by default this is workingdir/normfiles/normerr_lambda_{0}.csv
* numfile - the file containing the number of customers in each bucket, by default is workingdir/numfiles/num_cust_lambda_{0}.csv
* costfile - the file containing the cost of making the reservation, defined by the difference in wait times of making or not making AR at the threshold priority PHI, by default this is workingdir/costfiles/costs_lambda_{0}.csv
* revfile - the file containing the sample revenues generated from AR, and the assocaited sample error, when running the revwrapper. This file by default is workingdir/revfiles/revenues_lambda_{0}.csv

The remaining input variables control the base arrival and service rates of the customers

* lam - the customer arrival rate lambda. This is the primary element the wrapper loops over; if changing to one of the other variables, the names of the save files should be changed as appropriate. To update the values under consideration, simply edit the value of lam to alternative values.

Currently, the revwrapper is hardcoded to consider values in the range 0.1 to 0.9 via taking an iterator i in range(1,10) and then setting l = i/10 as the value of lambda.

* mu - the customer service rate. 0 < lambda < mu is required for a stable system; currently mu is hard coded to 1. (therefore lambda < 1 is required) This is represented by the second input to Simulator. Updating this value updates mu; otherwise a new loop can be introduced should it be desired to iterate over multiple values of mu.

* phi - the Advance Reservation threshold, as PHI is a fraction and 0 represents a scenario where all other customers have arrived and thus a reservation leaves the customer with equivalent priority to an on-demand customer regardless, PHI should be in (0,1]. In similar fashion to the revwrapper lam, currently we consdier phi values in the range 0.1 to 0.9 by taking an iterator j in range (1,10) then setting p = j/10 as the value of PHI.

The above values are then passed into the Simulator to iterate over each combination of lambda, mu, and phi specified.

## Parameters

The following parameters within XX_Sim and XX_Revsim can be adjusted to modify the simulation further as necessary:

* SIM_TIME - the length of time to run the simulation over; by default this equals (5*(10**6))/LAM in order to generate an average of 5 million customers per simulation run to acheive sufficient sample sizes, using a sliding time scale dependant on arrival rate.
* ITERATIONS - the number of independent simulations to run, which is then used to compute the simulation statistics. By default 30 is used.
* ALPHA - the width of the confidence interval. By default ALPHA = 0.05 corresponding to 95% CIs.
* FRAC - the fraction of time to wait before collecting statistics, so that the system acheives steady state characteristics before measuring its properties. By default FRAC = 0.1; the corresponding T_START denoting the time to start statistics collection therefore equals 10 percent of the total simulation time.
* EPSILON - the interval for determining the the priorities of "ghost" customers used in analyzing the AR costs (see the Simulator section below); Ghosts making reservation have priority PHI+EPSILON. By default, EPSILON = .00001 is used.
* BUCKETS - the number of discrete buckets to group customers in for analysis. As the total continuum of priroities is the space (0,1], having N buckets results in buckets of size 1/N. By default the number of buckets is 20; thereby grouping customers by potential priorities [1,0.95), [0.95,0.9), [0.9,0.85), etc.

To adjust any of the parameters, the appropriate XX_Sim or XX_Revsim file must be edited directly.

## Simulator  

The main Simulator loop consists of an M/M/1 (Poisson Arrivals, Exponential Service) queue simulator, originally used to validate claims from the EJOR paper cited above and Jonathan Chamberlain's MS thesis. Within the loop, constructs to compute the mean wait time for each discrete bucket of customers, number of customers in each bucket, and the computed cost of reservation are created. 

Each iteration, a fresh simulation enviornment is created, consisting primarily of the following:

- An arrivals process, handling the customer arrivals and determining the priority sort onto the queue
- A service process, handling the service of the customers and preemptions and statistical collections
- A Ghost process, creating zero-service customers to measure wait times near the threshold to validate analytical formulas.

The loop simulates arrivals during the service period, treating arrivals as customers' previously requested start time. Therefore, the arrivals process generates a random number *p* from the uniform distribution [0,1] to simulate the reservation period. *p* is compared with the threshold PHI; if *p* > PHI, the customer is treated as if the reservation was made and *p* becomes their priority. Otherwise, their priroity is forced to 0. The customer is then added to the queue; triggering the queue to wake up if empty. The process then waits a random exponentially distributed amount of time (determined by lambda) before generating a new customer.

The server process takes the top customer off the queue heap in priority sort order. If the next customer is an actual customer, the server waits an exponentially distributed amount of time (determined by mu). In the NP case, because preemptions are not possible this is done within the server itself, with waiting statistics computed immediately upon entering service. However, in the other cases due to the possibilities of preemption occuring, wait time related statistics are computed upon the completion of service, and the service time is generated upon arrival and passed to the queue as one of the customer's attributes. 

As the simulator is built in part on NumPy, alternative distributions for arrivals and service can be implemented by altering the relevant lines of code (in server in NP and in arrivals in PR and Hybrid) to draw from one of the other distributions supported by [NumPy's random sampling module](https://numpy.org/doc/stable/reference/random/index.html). Depending on the chosen distribution, it may be necessary to introduce additional parameters. For instance, to use a Gamma distribution (of which exponential is a special case), the line "servlen = np.random.exponential(1/MU)" would have to be replaced by "servlen = np.random.Generator.gamma(shape, scale)" where shape and scale are the correspondingly named parameters of the Gamma distribution.

If a higher priority customer arrives and the current customer is preemption eligible, an interrupt is triggered - the time elapsed since the start of the current service period is subtracted from the customer's service, and the customer is returned to the queue while the new customer enters service by virtue at being at the top of the queue stack.

The Ghost process is used to validate the cost based on threshold priority; as it is unlikely that sufficient numbers of customers will be generated at the threshold to have a meaningful sample on its own. As waiting time and not service time is the main factor impacting the decision, the Ghosts can occupy space without actually impacting waiting times due to having a service time of zero. The Ghost process is parallel to that of the arrivals process, in that they arrive at an exponential rate determined by lambda, thinned by some fraction of the overall rate (the rate in each group should be consistent with the bucket size - however the code is not 100% consistent in terms of the Ghost generation rate for reasons explained below).

In the PR and NP cases, customers by default arrive at 10% of the overall rate, and are split into AR and non-AR groups with equal probability, with AR ghosts given probability PHI+epsilon, consistent with bucket sizes of 5% (as there are 20 Buckets). Upon reaching the front of the queue, the wait time is immedately recorded and the customer exits, the next customer being processed immediately (if one is present).

In the Hybrid case, the fact that priority 0 customers can be preempted but the others cannot means that this methodology is not fully sound - it works in the PR case due to the fact that the sole difference between a priority 0 and priority PHI customer is that the former cannot preempt the latter, but both are subject to preemption by all other AR customers, and the probability of having any *specific* priority equals 0 due to the nature of the priorities being offered on a continuum and not as a discrete set. Therefore, it is not necessary to simulate the service of Ghosts in the preemptive setting if *all* customers are subject to preemption.

To work around this, in the Hybrid case, Ghosts of priority PHI+epsilon are generated (and thus the arrival rate is lambda/20 by default), and their statistics are recorded as normal. Their wait times are compared against the non-AR customers in the bucket immediately adjacent to the threshold priority, as their wait time statistics are otherwise identical to the desired population.

The wait times of the Ghosts are recorded to be used as the basis for computing the AR costs, as the difference of wait times at the threshold determines whether the offered fee is worth accepting the offer.

## Outputs

Following all iterations, the simulator computes and saves the following into the files specified above in the Inputs section:

* sample_mean - the mean wait time in each bucket
* error - the associated sample error in each bucket, based on the 95% CI (the file stores the actual error; the CI can be determined through combination of sample_mean and error)
* norm_err - the error normalized by the sample_mean
* mean_cust - the mean number of customers generated within each bucket
* mean_C - the mean of the AR_costs; where AR_costs is itself computed as the difference in mean wait times of each group of Ghost customers on each iteration
* error_C - the associated sample error of AR_costs, again based on the 95% CI 
* mean_R - the mean of the revenues collected, based on the analytical value of C and number of AR customers per time unit
* error_R - the associated 95% CI sample error of the revenues

----------
# License


These materials may be freely used and distributed, provided that attribution to this original source is acknowledged. If you reuse the code in this repository, we kindly ask that you refer to the following work (cf. the included citation.bib file in this repository):

Chamberlain, Jonathan, Eran Simhon, and David Starobinski. "Preemptible queues with advance reservations: Strategic behavior and revenue management." *European Journal of Operational Research* 293.2 (2021): 561-578. 



-----------------
# References

If you are using these scripts in your work and would like to be featured in this list, kindly create an issue in this repository and provide us with the reference.

-----------------
# Acknowledgment

Support by the US National Science Foundation is gratefully acknoweldged (project ids: CNS-1717858 and CNS-1908087)

