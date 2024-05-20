"""
Module to define simulator for M|M|1 queues with Advanced Reservation, and Preemptive Resume
Uses simpy to dynamically generate events to facilitate extension of implementation
to Preemptive Resume
Monitors number of customers making reservations as statistic of interest; used for computing the average costs
Author: Jonathan Chamberlain, 2018 jdchambo@bu.edu
"""

# import required packages - numpy, scipy, and simpy required to be installed if not present
import math
import numpy as np
import scipy as sp
import scipy.stats as stats
import simpy
import heapq
import sys
import csv

def Simulator(LAM, MU, PHI, revfile):
    '''
    LAM - Average arrival rate ("Lambda" is reserved for inline functions in python)
    MU - Service rate 
    PHI - Threshold for making AR
    revfile - file to save revenue statistics to
    '''


    '''
    Simulation Global Parameters
    '''
    RHO = LAM/MU # System Load
    SIM_TIME = (5*(10**6))/LAM # Length of time to run simulation over - scale to avg ~5,000,000 customers during timeframe
    FRAC = 0.1 # fraction of time to wait for before collecting statistics
    T_START = FRAC*SIM_TIME # time to start collecting statistics at
    ITERATIONS = 30 # number of independent simulations
    ALPHA = 0.05 # confidence interval is 100*(1-alpha) percent
    C = (RHO*PHI)/(MU*(1-RHO)*(1-RHO*(1-PHI))**2) # Cost to make reservation  
    '''
    Define Priority Queue class
    Taken from SO article: https://stackoverflow.com/questions/19745116/python-implementing-a-priority-queue
    '''
    class PriorityQueue:
        def __init__(self):
            self.items = []
        
        # push new entries onto the heap, sorted by priority and entry time - also contains flag for Ghost customers    
        def push(self, priority, entry, service):
            heapq.heappush(self.items, (priority, entry, service))
        
        # pop items from the queue, to get next item for processing
        def pop(self):
            customer = heapq.heappop(self.items)
            return customer
    
        # define empty check
        def empty(self):
            return not self.items


    '''
    Define simulator enviornment class
    '''

    class SimEnv:
        def __init__(self, env):
            self.env = env # SimPy Enviornment
            self.n = 0 # number of customers purchasing reservation, based on threshold belief
            self.idle = True # flag to trigger activation event
            self.q = PriorityQueue() # queues of pending customers, starts empty
            self.arrvial_proc = env.process(self.arrivals(env))
            self.server_proc = env.process(self.server(env))
            self.server_wakeup = env.event() # event trigger to wake up idle server

        def arrivals(self, env):
            '''
            Packets arrive at randomized intervals, and are passed to the server queue for processing
            Packets will be created until simulation time has expired
            '''
            while True:
                yield env.timeout(np.random.exponential(1/LAM)) # randomized interarrival rate; numpy expontial defined w/r/t 1/lambda and not lambda
                '''
                priority - random number to determine where customer's arrival time in reservation period falls on distribution
                By assumption, we can map distribution of the arrivals to a uniform distribution over [0,1], corresponding to the CDF
                Thus, we can use the CCDF to define the priority class, where larger numbers respresent greater priority (made AR earlier in the reservation period)
                Since all customers that arrive after the threshold will choose to not make AR, we assign all such customers the lowest possible priority of 0
                For simplicity, we assume that if a customer arrives exactly at the threshold, they choose to not make AR as they are otherwise indifferent between AR and not-AR;
                this allows us to determine the cost of making AR for the given threshold as determined by the simulator
                t = 0 is the start point of the service period 
                '''
                priority = 1 - np.random.rand() # Draw priority from interval (0,1], representing CCDF of distribution
                if priority <= PHI:
                    priority = 0 # customer arrived after threshold point, elects to not make AR
                elif (env.now > T_START):
                    self.n += 1 # customer purchased AR, track
                servtime = np.random.exponential(1/MU)
                # add arrival to queue, as tuple of priority is negated due to tuple sorting rules
                self.q.push(-1*priority,env.now,servtime) 
                # if server idle, wake it up
                if self.idle:
                    self.server_wakeup.succeed() # reactivate server
                    self.server_wakeup = env.event() # reset server wakeup trigger
                # otherwise, if new arrival has prioirty over customer currently in service, trigger preemption
                elif(-1*priority) < self.next[0]:
                    self.server_proc.interrupt()

        
        def server(self, env):
            '''
            Serve the packets being held in the queue
            Queue is implemented as a heap, with elements as tuples utilizing standard Python tuple sort
            tuple[0] - Priority: float between -1 and 0, representing CCDF (multiplied by -1 to ensure correct priority sort)
            tuple[1] - Arrival Time: non negative float, representing initial arrival time to the queue
            '''
            while True:
                self.idle = True
                # if nothing in queue, put server to sleep - else next part breaks
                if self.q.empty():
                    yield self.server_wakeup # yield until reactivation event succeeds
                # serve job at head of queue - Priority queue automatically sorts by priority, then entry into system
                self.idle = False
                self.next = self.q.pop() # get next customer - tuple of (priority, entry time)
                start = env.now
                try:
                    yield env.timeout(self.next[2]) # serve customer for some exponential time
                except simpy.Interrupt:
                    # iteruppted, return current customer to the queue, mark time served
                     self.q.push(self.next[0],self.next[1],self.next[2]-(env.now-start))
                
                   

    '''
    main simulator loop
    '''
    AR_revenue = np.zeros(ITERATIONS)
    for k in range(ITERATIONS):
        '''
        start simulation
        '''
        env = simpy.Environment() # establish SimPy enviornment
        sim = SimEnv(env)
        env.run(until=SIM_TIME)
        '''
        compute expected revenue per time unit
        '''
        AR_revenue[k] = (C*sim.n)/((1-FRAC)*SIM_TIME) # divide total revenue collected by the time spent collecting revenue
        

    '''
    compute statistics, save to file        
    '''

    mean_R = np.mean(AR_revenue) # mean revenues
    error_R = np.std(AR_revenue)*stats.norm.ppf(1-ALPHA/2)/(ITERATIONS**0.5) # confidence interval
    R = [mean_R, error_R]
    with open(revfile, 'a') as revout:
        writer = csv.writer(revout, lineterminator='\n')
        writer.writerow(R) 
