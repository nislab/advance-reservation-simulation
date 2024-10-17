# advance-reservation-simulation

Modeling of priority purchasing queuing games, where priorities are derived from an advance reservation system of resource claiming.

Under advance reservation, the time axis is split into a reservation period and a service period. During the reservation period, potential customers arrive and attempt to reserve service at a future point in time during the service period. The priority for claiming service at a particular time is determined by the order of customer arrials, with a potential priority in the interval [1,0)* offered based on the estimated fraction of customers remaining prior to the start of the service period. If accepted, the potential priority becomes the actual priority; otherwise the customer defaults to priority 0 and is treated as seeking service "on demand" without a reservation. For instance, the first customer to arrive will have priority 1; some customer later on will receive a potential priority of 2/3, implying an estimate of 2/3 of customers remaining before the start of service (or alternatively, 1/3 of customers have already arrived to the system). 

*(the abuse of notation is intentional)

The below figure provides additional details: 

Readers are directed to the following citation for further details on the AR system:
Chamberlain, Jonathan, Eran Simhon, and David Starobinski. "Preemptible queues with advance reservations: Strategic behavior and revenue management." *European Journal of Operational Research* 293.2 (2021): 561-578.

## Dependencies

The main simulation utilizes Python code, specifically [SimPy](https://simpy.readthedocs.io/en/latest/contents.html) 

To utilize the code, in addition to SimPy, it is also necessary to install NumPy and SciPy for statistical analysis. These can be installed using pip:

```
pip install numpy
pip install scipy
pip install simpy
```

## Usage

The simulation code consists of various scripts which interact with one another. The main simulation loop consists of an M/M/1 queue (Poission Arrivals, Exponential Service, Single Server) which simulates customers over the service period, treating the arrivals as the customer's previously requested start time. To simulate the the reservation period, we we draw a uniform random number *p* between 0 and 1. As the goal is to validate claims from the EJOR paper and related Master's Thesis work of Chamberlain that the resulting equilibrium state is of a threshold type, *p* is compared with a predetermined threshold PHI. If *p* is greater than PHI, that becomes the priority of the new arrival. Otherwise, the priority is forced to 0. The arrival is then added to the queue, with arrivals processed in priority order, with preemption triggering if necessary. 

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

Simulation Data is collected and output in the following files, which by default are given the following paths/file names but can be customized in the respective wrappers. The following are generated by the main simulation code and specified by MM1_*_wrapper.py -

* meanfiles/mean_lambda_{0}.csv - The sample mean waiting time for each "class"
* errorfiles/error_lambda_{0}.csv - The sample error of the waiting time for each "class"
* normfiles/normerr_lambda_{0}.csv - The normalized error of the simulation, for each "class"
* numfiles/num_cust_lambda_{0}.csv - The number of customers in each "class"
* costfiles/costs_lambda_{0}.csv - The difference in wait times between making and not making AR at the threshold priority; this is the definition of the cost leading to PHI being the threshold and therefore at equilibrium, which the simulator is validating through the comparison

The following is generated by the revenue simulator and is specfied by MM1_*_revwrapper.py

* revfiles/revenues_lambda_{0}.csv - The sample revenues generated from AR AND associated sample error

## 



