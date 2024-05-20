# advance-reservation-simulation
Modeling of priority based advance reservation of system resources, based on queuing games 

## Dependencies

The main simulation utilizes Python code, specifically [SimPy](https://simpy.readthedocs.io/en/latest/contents.html) 

To utilize the code, in addition to SimPy, it is also necessary to install NumPy and SciPy for statistical analysis. These can be installed using pip:

```
pip install numpy
pip install scipy
pip install simpy
```

## Usage

The simulation directory contains three branches:
- `Non Preemptive`, where lower priority users cannot be preempted from the queue while in service.
- `Preemptive Resume`, where lower priority users are preempted from service, but resume from the point of interruption.
- `Hybrid`, where only users who do not make a reservation (priority 0 users) are subject to preeemption.

In all cases, blah blah blah

The analysis directory contains MATLAB scripts for further processing of results.

## 



