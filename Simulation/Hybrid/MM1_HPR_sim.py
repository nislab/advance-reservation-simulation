"""
Module to define simulator for M|M|1 queues with Advanced Reservation, and preemtive resume behavior,
but only customers not making AR are preempted.
Monitors queuing wait time as statistic of interest
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

def Simulator(LAM, MU, PHI, meanfile, errfile, normfile, numfile, costfile):
    '''
    LAM - Average arrival rate ("Lambda" is reserved for inline functions in python)
    MU - Service rate (fixed since service is deterministic)
    PHI - Threshold for making AR
    meanfile - file to save mean service rate to
    errfile - file to save error bound to
    normfile - file to save normalized error to
    numfile - file to save mean number of customers per class to (for validation purposes)
    costfle - file containing cost and CI data
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
    EPSILON = .00001 # epsilon of interval to determine cost
    BUCKETS = 20 # number of discrete buckets to graph results for customers
   
    '''
    Define Priority Queue class
    Taken from SO article: https://stackoverflow.com/questions/19745116/python-implementing-a-priority-queue
    '''
    class PriorityQueue:
        def __init__(self):
            self.items = []
        
        # push new entries onto the heap, sorted by priority and entry time - also contains flag for Ghost customers as well as remaining time in service and initial time in service    
        def push(self, priority, entry, isGhost, index, service, init, madeAR):
            heapq.heappush(self.items, (priority, entry, isGhost, index, service, init, madeAR))
        
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
            self.total_w = np.zeros(BUCKETS) # total of observed queue wait during monitoring period, per bucket
            self.n = np.zeros(BUCKETS) # total number of observed packets during monitoring period, per bucket
            self.ghost_w = np.zeros(2) # wait time of customers near threshold
            self.ghost_n = np.zeros(2) # number of customers near threshold
            self.idle = True # flag to trigger activation event
            self.q = PriorityQueue() # queues of pending customers, starts empty
            self.arrvial_proc = env.process(self.arrivals(env))
            self.ghost_proc = env.process(self.ghost(env))
            self.server_proc = env.process(self.server(env))
            self.server_wakeup = env.event() # event trigger to wake up idle server

        def arrivals(self, env):
            '''
            Packets arrive at randomized intervals, and are passed to the server queue for processing
            Packets will be created until simulation time has expired
            '''
            while True:
                yield env.timeout(np.random.exponential(1/LAM)) # randomized interarrival rate
                '''
                priority - random number to determine where customer's arrival time in reservation period falls on distribution
                By assumption, we can map distribution of the arrivals to a uniform distribution over [0,1], corresponding to the CDF
                Thus, we can use the CCDF to define the priority class, where larger numbers respresent greater priority (made AR earlier in the reservation period)
                Since all customers that arrive after the threshold will choose to not make AR, we assign all such customers the lowest possible priority of 0
                For simplicity, we assume that if a customer arrives exactly at the threshold, they choose to make AR to avoid preemption;
                this allows us to determine the cost of making AR for the given threshold as determined by the simulator
                t = 0 is the start point of the service period 
                '''
                priority = 1 - np.random.rand() # Draw priority from interval (0,1], representing CCDF of distribution
                i = int(np.floor(priority*BUCKETS)) # discretized "bucket" to graph results; buckets are [i/BUCKETS, (i+1)/BUCKETS) for i in range(BUCKETS).
                madeAR = True # flag to indicate customer made AR - priority 0 does not automatically imply notAR in this model.
                if priority < PHI:
                    # customer arrived after threshold point, elects to not make AR
                    priority = 0 
                    madeAR = False
                service = np.random.exponential(1/MU) # service time of newly arriving job
                # add arrival to queue, as tuple of (priority, arrival time, nearThresh, index, service); priority is negated due to tuple sorting rules
                self.q.push(-1*priority, env.now, False, i, service, service, madeAR) 
                # if server idle, wake it up
                if self.idle:
                    self.server_wakeup.succeed() # reactivate server
                    self.server_wakeup = env.event() # reset server wakeup trigger
                # otherwise, if new arrival made AR and customer in service did not, trigger preemption
                elif madeAR and (not self.next[6]):
                    self.server_proc.interrupt()

        def ghost(self, env):
            '''
            "Ghost" customers are packets arriving at randomized intervals, with arrival rate equal to a sampling of the actual arrival rate
            Ghosts are imagined to arrive just before the threshold, and make AR but have 0 service time. Ghosts are used to compute the cost of waiting 
            '''
            while True:
                gLAM = LAM/BUCKETS # sample ghosts at rate equivalent to 1/BUCKETS of the overall arrival rate
                yield env.timeout(np.random.exponential(1/gLAM))
                priority = PHI + EPSILON # fix arrival rate to just above threshold 
                # add arrival to queue, as tuple of (priority, arrival time, isGhost, index); priority is negated due to tuple sorting rules
                # index defaults to 1, as that is the index in the ghost customer array for AR customers. Ghosts make AR by default, but have no service time 
                self.q.push(-1*priority, env.now, True, 1, 0, 0, True)
                # if server idle, wake it up - even though Ghosts disappear at the point where they would be served, we still need to wake up the server as it sleeps while the queue is empty
                if self.idle:
                    self.server_wakeup.succeed() # reactivate server
                    self.server_wakeup = env.event() # reset server wakeup trigger
                # otherwise, if customer in service did not make AR, trigger preemption
                elif (not self.next[6]):
                    self.server_proc.interrupt()


        def server(self, env):
            '''
            Serve the packets being held in the queue
            Queue is implemented as a heap, with elements as tuples utilizing standard Python tuple sort
            tuple[0] - Priority: float between -1 and 0, representing CCDF (multiplied by -1 to ensure correct priority sort)
            tuple[1] - Arrival Time: non negative float, representing initial arrival time to the queue
            tuple[2] - nearThresh: customer within epsilon of theshold, collect wait time
            tuple[3] - Index: index to use when storing results to total_w and n arrays
            tuple[4] - service: remaining service time
            tuple[5] - init: initial service length
            tuple[6] - madeAR: boolean denoting whether customer made AR or not, used to determine preemption behavior
            '''
            while True:
                self.idle = True
                # if nothing in queue, put server to sleep - else next part breaks
                if self.q.empty():
                    yield self.server_wakeup # yield until reactivation event succeeds
                # serve job at head of queue - Priority queue automatically sorts by priority, then entry into system
                self.next = self.q.pop() # get next customer - tuple of (priority, entry time)
                # if Ghost customer, drop off immediately and record wait time in queue
                if (self.next[2]):
                    self.ghost_w[1] += env.now - self.next[1]
                    self.ghost_n[1] += 1
                else:
                    # actual customer, serve for tuple[4] time units, unless preempted  
                    self.idle = False
                    start = env.now
                    try:
                        yield env.timeout(self.next[4])
                        if (env.now > T_START):
                            # if beyond threshold add to total_w, increment number of customers seen in arrival precentile
                            waittime = env.now - (self.next[1] + self.next[5])
                            index = self.next[3]
                            self.total_w[index] += waittime
                            self.n[index] += 1
                            if (index == (BUCKETS*PHI - 1)):
                                # if customer arrived in last bucket prior to threshold, treat as if it were a ghost, since a ghost who didn't make AR would have same priority as actual customer who did not
                                self.ghost_w[0] += waittime
                                self.ghost_n[0] += 1
                    except simpy.Interrupt:
                        # current nonAR job interrupted by AR arrival, reinsert into queue with time remaining updated
                        self.q.push(0, self.next[1], False, self.next[3], self.next[4]-(env.now-start), self.next[5], False) # decrement time remaining by amount of time passed            

    '''
    main simulator loop
    '''
    mean_w = np.zeros((ITERATIONS, BUCKETS)) # simulated mean wait time
    num_cust = np.zeros((ITERATIONS, BUCKETS)) # number of customers per iteration per class
    AR_costs = np.zeros(ITERATIONS)
    for k in range(ITERATIONS):
        '''
        start simulation
        '''
        env = simpy.Environment() # establish SimPy enviornment
        sim = SimEnv(env)
        env.run(until=SIM_TIME)
        '''
        compute average queue length, AR cost, store number of customers
        '''
        mean_w[k,:] = sim.total_w/sim.n
        num_cust[k,:] = sim.n
        AR_costs[k] = (sim.ghost_w[0]/sim.ghost_n[0]) - (sim.ghost_w[1]/sim.ghost_n[1]) # cost is dfference between not making AR and making AR at threshold
        

    '''
    compute statistics, save to file        
    '''
    sample_mean = np.mean(mean_w, axis=0) # mean result of average queue length for each class
    error = np.std(mean_w, axis = 0)*stats.norm.ppf(1-ALPHA/2)/(ITERATIONS**0.5) # confidence intervals
    norm_err = error/sample_mean # normalized error of simulation
    with open(meanfile, 'a') as meanout:
        writer = csv.writer(meanout, lineterminator='\n')
        writer.writerow(sample_mean)

    with open(errfile,'a') as errout:
        writer = csv.writer(errout, lineterminator='\n')
        writer.writerow(error)

    with open(normfile, 'a') as normerrout:
        writer = csv.writer(normerrout, lineterminator='\n')
        writer.writerow(norm_err)

    mean_cust = np.mean(num_cust, axis=0) # mean number of customers per class
    with open(numfile, 'a') as numout:
        writer = csv.writer(numout, lineterminator='\n')
        writer.writerow(mean_cust)

    mean_C = np.mean(AR_costs) # mean costs
    error_C = np.std(AR_costs)*stats.norm.ppf(1-ALPHA/2)/(ITERATIONS**0.5) # confidence interval
    C = [mean_C, error_C]
    with open(costfile, 'a') as costout:
        writer = csv.writer(costout, lineterminator='\n')
        writer.writerow(C)
