# advance-reservation-simulation

Modeling of priority purchasing queuing games, where priorities are derived from an advance reservation system of resource claiming.

Under advance reservation, the time axis is split into a reservation period and a service period. During the reservation period, potential customers arrive and attempt to reserve service at a future point in time during the service period. The priority for claiming service at a particular time is determined by the order of customer arrials, with a potential priority in the interval [1,0)* offered based on the estimated fraction of customers remaining prior to the start of the service period. If accepted, the potential priority becomes the actual priority; otherwise the customer defaults to priority 0 and is treated as seeking service "on demand" without a reservation. For instance, the first customer to arrive will have priority 1; some customer later on will receive a potential priority of 2/3, implying an estimate of 2/3 of customers remaining before the start of service (or alternatively, 1/3 of customers have already arrived to the system). 

*(the abuse of notation is intentional)

The below figure provides additional details: 

![A sample Advance Reservation secnario featuring three customers](/Eran_example.png?raw=true "AR Example")

In this example Customers 1,2,3 arrive in that order at times *t_i* with requesting starting service times *s_i* during the service period. The priority order is determined by the order of arrivals, however here Customer 2 has the earliest request and is permitted to enter service first. With preemptive policies in effect, Customer 1 is permitted to enter service at their start time despite Customer 2 being in service. Customer 3, having the lowest priority, must wait for both the customers to complete service and thus enters service slightly after their desired reservation time.

Readers are directed to the following citation for further details on the AR system:

Chamberlain, Jonathan, Eran Simhon, and David Starobinski. "Preemptible queues with advance reservations: Strategic behavior and revenue management." *European Journal of Operational Research* 293.2 (2021): 561-578.

-------------------
## Dependencies

The main simulation utilizes Python code, specifically [SimPy](https://simpy.readthedocs.io/en/latest/contents.html) 

To utilize the code, in addition to SimPy, it is also necessary to install NumPy and SciPy for statistical analysis. These can be installed using pip:

```
pip install numpy
pip install scipy
pip install simpy
```
--------------
## Usage

The simulation code consists of various scripts which interact with one another. The main simulation loop consists of an M/M/1 queue (Poission Arrivals, Exponential Service, Single Server) which simulates customers over the service period, treating the arrivals as the customer's previously requested start time. To simulate the the reservation period, we we draw a uniform random number *p* between 0 and 1. As the goal is to validate claims from the EJOR paper and related Master's Thesis work of Chamberlain that the resulting equilibrium state is of a threshold type, *p* is compared with a predetermined threshold PHI. If *p* is greater than PHI, that becomes the priority of the new arrival. Otherwise, the priority is forced to 0. The arrival is then added to the queue, with arrivals processed in priority order, with preemption triggering if necessary. 

As the simulator is built in part on NumPy, alternative distributions for arrivals and service can be implemented by altering the relevant lines of code to draw from one of the other distributions supported by [NumPy's random sampling module](https://numpy.org/doc/stable/reference/random/index.html)

The simulation directory contains three branches, corresponding to the policies a system provider can implement with respect to multiple users seeking priority simultaneously:
- `Non Preemptive`, where lower priority users cannot be preempted from the queue while in service.
- `Preemptive Resume`, where lower priority users are preempted from service, but resume from the point of interruption.
- `Hybrid`, where only "on demand" users (priority 0 users) are subject to preeemption.

Each branch consists of the following scripts

 * MM1_*_sim.py - contains the main simulation code for each policy
 * MM1_*_wrapper.py - consists of a wrapper which calls the main simulation, used to enable loops over multiple values of the arrival and service rate parameters as well as the equilibirum threshold, and specify the destination files for the data output by the simulator
 * MM1_*_simanalysis.py - takes the specified number of buckets customers have been sorted into and the current path and plots the simulated results against the analytical delays, accounting for aggregation of customers into groups by number of buckets.
 * MM1_*_eqanalysis.py - plots the costs computed by the simulation against the cost expected from the analytical formula
 * MM1_*_Revsim.py - A modified version of the main simulation code to compute expected revenues, by also accounting for the variable number of customers which can accrue in each simualtion run
 * MM1_*_revwrapper.py - a corresponding wrapper for the Revsim version of the main simulator to facilitate loops.
 * MM1_*_revanalysis.py - plots the revenue computed by the Revsim simulation vs the analytical simulation.
-----------
# Inputs

The simulators are intended to be used by calling the wrappers, however, they can be run directly provided the wrapper parameters are set within the MM1_*_sim.py code themselves.

* lambda - the arrival rate of the customers. lambda should be > 0
* mu - the service rate of the customers. 0 < mu < lambda is required for a stable system.
* phi - the threshold decision for determining whether a reservation is made. PHI should be in the interval (0,1]

Simulation Data is collected and output in the following files, which by default are given the following relative paths/file names but can be customized in the respective wrappers. 
The following are generated by the main simulation code and specified by MM1_*_wrapper.py: 

* meanfile = meanfiles/mean_lambda_{0}.csv - File containing the sample mean waiting time for each "class"
* errfile = errorfiles/error_lambda_{0}.csv - File containing the sample error of the waiting time for each "class"
* normfile = normfiles/normerr_lambda_{0}.csv - File containing the normalized error of the simulation, for each "class"
* numfile = numfiles/num_cust_lambda_{0}.csv - File containing the number of customers in each "class"
* costfile = costfiles/costs_lambda_{0}.csv - File containing the difference in wait times between making and not making AR at the threshold priority; this is the definition of the cost leading to PHI being the threshold and therefore at equilibrium, which the simulator is validating through the comparison

The following is generated by the revenue simulator and is specfied by MM1_*_revwrapper.py:

* revfile = revfiles/revenues_lambda_{0}.csv - File contianing the sample revenues generated from AR AND associated sample error

 # Parameters

In addition to the inputs, the following parameters can be adjusted within the code itself to modify the simulation 

* SIM_TIME - the length of time to run the simulation over; by default the simulations use a relative time scale to generate an average of 5 million customers per simulation run to acheive sufficient sample sizes.
* ITERATIONS - the number of independent simulations to run, which is then used to compute the simulation statistics. By default 30 is used.
* ALPHA - Specifies the width of the confidence interval. By default ALPHA = 0.05 corresponding to 95% CIs.
* FRAC - Specifies the fraction of time to wait before collecting statistics, so that the system acheives steady state characteristics before measuring its properties. By default FRAC = 0.1, resulting in the related T_START equaling 10 percent of the simulation time.
* EPSILON - the interval for determining the the priorities of "ghost" customers who drop off without service with priority PHI+EPSILON and PHI-EPSILON. By default, EPSILON = .00001 is used.
* BUCKETS - the number of discrete buckets to group customers in for analysis. By default the number of buckets is 20; thereby grouping customers by potential priorities [1,0.95), [0.95,0.9), [0.9,0.85), etc.

# Outputs

The simulator outputs are the products contained within the files specified above in the Inputs section:

* meanfile - contains vectors consisting of the sample mean wait times, arranged by bucket in ascending potential priority order.
* errfile - contains vectors corresponding to the delta of the confidence interval for each bucket, such that the CI is extrapolated from the meanfile and errfile data as (mean-delta,mean+delta) for a given bucket. As with the meanfile, the buckets are arranged in ascending potential priority order.
* normfile - contains vectors consisting of the normalized error resulting from computing the error relative to the mean wait times. This is again arranged by bucket in ascending potential priority order.
* numfile - contains vectors corresponding to the number of customers in each bucket, arranged in ascending potential priority order.
* costfile - contains vectors corresponding to the computed cost to make a reservation for the given parameters that leads to the selected PHI being an equilibrium, and the corresponding error bound for the confidence interval, in the form [mean, error].  
* revfile - similarly to the costfile, contains vectors corresponding to the computed revenues from reservations under the assumption that the given parameters and selected PHI have led to an equilibrium state, as well as the corresponding error bound, in the form [mean, error].

## 

# License


These materials may be freely used and distributed, provided that attribution to this original source is acknowledged. If you reuse the code in this repository, we kindly ask that you refer to the following work (cf. the included citation.bib file in this repository):

Chamberlain, Jonathan, Eran Simhon, and David Starobinski. "Preemptible queues with advance reservations: Strategic behavior and revenue management." *European Journal of Operational Research* 293.2 (2021): 561-578. 

-----------------
# References

If you are using these traces in your work and would like to be featured in this list, kindly create an issue in this repository and provide us with the reference.

-----------------
# Acknowledgment

Support by the US National Science Foundation is gratefully acknoweldged (project ids: CNS-1717858 and CNS-1908087)

