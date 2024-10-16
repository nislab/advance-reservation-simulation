# advance-reservation-simulation

Modeling of priority purchasing queuing games, where priorities are derived from an advance reservation system of resource claiming.

Under advance reservation, the time axis is split into a reservation period and a service period. During the reservation period, potential customers arrive and attempt to reserve service at a future point in time during the service period. The priority for claiming service at a particular time is determined by the order of customer arrials, with a potential priority in the interval [1,0)^* offered based on the estimated fraction of customers remaining prior to the start of the service period. If accepted, the potential priority becomes the actual priority; otherwise the customer defaults to priority 0 and is treated as seeking service "on demand" without a reservation. For instance, the first customer to arrive will have priority 1; some customer later on will receive a potential priority of 2/3, implying an estimate of 2/3 of customers remaining before the start of service (or alternatively, 1/3 of customers have already arrived to the system). 

*(the abuse of notation is intentional)

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

The simulation directory contains three branches, corresponding to the policies a system provider can implement with respect to multiple users seeking priority simultaneously:
- `Non Preemptive`, where lower priority users cannot be preempted from the queue while in service.
- `Preemptive Resume`, where lower priority users are preempted from service, but resume from the point of interruption.
- `Hybrid`, where only "on demand" users (priority 0 users) are subject to preeemption.

In all cases, the goal of the simulations is to generate a sufficient stream of customers to validate the claims made in the EJOR paper and related Master's Thesis work regarding the behavior of the customers under each policy. In particular, that the resulting equilibrium state is of a threshold type. As a result, we simulate over the service period, treating arrivals to the queue as the customer's previously requested start times. To simulate their previous arrival during the reservation period, and thus the offered potential priority, we draw a uniform random number *p* between 0 and 1, and compare with a predetermined threshold PHI. If *p* is greater than PHI, that becomes the priority of the new arrival. Otherwise, the priority is forced to 0. The arrival is then added to the queue, with arrivals processed in priority order, with preemption triggering if necessary. 

Simulation Data is stored in the following formats - 



The analysis directory contains MATLAB scripts for further processing of results - 

## 



