---
layout: post
title: Lamport clocks in python
---

While trying to understand distributed systems at a more fundamental level, one paper in particular kept showing up as a favourite among programmers: "Time, Clocks, and the Ordering of Events in a Distributed System" by Leslie Lamport. It was [especially recommended for CS beginners](https://news.ycombinator.com/item?id=15695326) so I thought it would be a perfect one to get started with. Full link to the paper can be found [here](https://lamport.azurewebsites.net/pubs/time-clocks.pdf).

Basically the point of the paper is to show that a total ordering of events can be used to solve synchronization problems. There are two main algorithms described in the paper: one to solve a version of the mutal exclusion problem and one to synchronize physical clocks. In this post I will go through the mutual exclusion problem and provide some working code for the algorithm he describes. 

The paper begins with a lot of precise definitions which are critical to understanding the algorithms. He defines a -> b to be a "happened before" relation or a partial ordering which means that:

* If a and b are events in the same process then a comes before b
* a -> b holds if a describes the sending of a message to process i and b describes the receiving of that message by process j
* If a -> b and b -> c then a -> c

I knew this was going to be a badass paper as soon as he references relativity to describe how this definition is natural if you think of a->b as meaning a has the _potential_ to causally effect b:  "This definition will appear quite natural to the reader familiar with teh invariant space-time formulation of special relativity." How often do you see a relativity reference in a CS paper? Awesome.

The next set of defintions involve systems of logical clocks. You can think of a logical clock as simply a counter in a process. If you increment the counter in between local process events (this is implementation rule 1 in the paper) AND update your clock to be >= the timestamp of a message received from another process (implementation rule 2), then comparing the count between two different events in that process will tell you which one "happened before." This is the essence of the clock condition and how to maintain it. Here's the cool part: if this clock condition is satisfied in your system of processes and logical clocks and you maintain a list of the events and what the clock was at when they occur, then you now have a total or global ordering of the events. Then resolving synchronization problems becomes much easier because based on the total ordering we know exactly what state every process is currently in. 

The mutual exclusion problem he describes is a very realistic and practical one. Let's say you have a number of processes and there is a single shared resource which can only be used by one process at a time. Now imagine these processes can only communicate with one another, there is no centralized scheduler and there are no physical clocks involved. If you had physical clocks which were always perfectly synchronized then the problem would be trivial because you could just have a schedule where each process has an alloted time with which they can proceed. 

The solution is to ensure that every process knows the total ordering of the resource request events, accomplished via maintaining the clock condition and broadcasting resource requests and releases like so (incrementing the logical clock between each event):

1. To request the resource, send a request message to everyone with the timestamp set to your logical clock value
2. If you get a request message, store it in your request queue and send an ack back to the sender
3. When you are done with the resource, remove your request from your request queue and broadcast a release message to everyone else
4. If you receive a release message, remove that request from your request queue
5. You get the resource if when you look at the request queue and your request is the earliest request AND you see later requests from everyone else (this is where we make use of the total ordering)


To implement the algorithm I used threads to represent the processes and queues as channels of communication for the messages. The logical clocks are simply counters in each thread and using the "resource" is simulated by a sleep. There are 3 processes in total and process "A" is initially granted the resource:

{% highlight python %}
import signal
import sys
import time
import threading
from Queue import Queue

initially_granted_proc = "A"
procs = {"A", "B", "C"}
resource_usage_counts = {"A": 0, "B": 0, "C": 0}
message_queues = {"A" : Queue(), "B": Queue(), "C": Queue()}

class Message(object):
    def __init__(self, msg_type, timestamp, sender, receiver):
        self.msg_type = msg_type
        self.timestamp = timestamp
        self.sender = sender
        self.receiver = receiver

    def __repr__(self):
        return "Message {} at {} from {} to {}".format(
        	self.msg_type, self.timestamp, 
        	self.sender, self.receiver)

class Process(threading.Thread):

    def __init__(self, name, initially_granted, other_processes):
        super(Process, self).__init__()
        self.name = name
        self.has_resource = initially_granted == name
        self.other_processes = other_processes
        self.lamport_clock = 0 # tick after each "event"
        self.request_queue = []
        self.requested = False
        self.request_queue.append(Message("request", 
        	-1, initially_granted, initially_granted))

    def remove_request(self, msg_type, sender):
        index_of_req = -1
        for i in range(len(self.request_queue)):
            if self.request_queue[i].msg_type == msg_type and \
               self.request_queue[i].sender == sender:
                index_of_req = i
                break
        if i == -1:
            print("Unable to remove") 
        else:
            del self.request_queue[i]

    def use_resource(self):
        print("Process {} is using resource".format(self.name))
        resource_usage_counts[self.name] += 1
        time.sleep(2)

    def process_message(self, msg):
        # Based on msg_type handle appropriately
        if msg.msg_type == "request":
            # Put in our request queue and send an ack 
            # to the sender
            self.request_queue.append(msg)
            for proc in self.other_processes:
                if proc == msg.sender:
                    message_queues[proc].put(Message(
                    	"ack", self.lamport_clock, 
                    	self.name, msg.sender))
        elif msg.msg_type == "release":
            # Got a release, remove it from our queue
            self.remove_request("request", msg.sender)
        elif msg.msg_type == "ack":
            pass
        else:
            print("Unknown message type")

    def run(self):
        while True:
            if self.has_resource:
                self.use_resource()
                self.remove_request("request", self.name)
                # Tell everyone that we are done
                for proc in self.other_processes:
                    message_queues[proc].put(Message(
                    	"release", self.lamport_clock, 
                    	self.name, proc))
                    self.lamport_clock += 1
                self.has_resource, self.requested = False, False
                continue
            # Want to get the resource
            if not self.requested:
                # Request it
                print("Process {} requesting resource".format(
                	self.name))
                self.request_queue.append(Message(
                	"request", self.lamport_clock, 
                	self.name, self.name))
                # Broadcast this request
                for proc in self.other_processes:
                    message_queues[proc].put(Message(
                    	"request", self.lamport_clock, 
                    	self.name, proc))
                    self.lamport_clock += 1
                self.requested = True
            else:
                # Just wait until it is available by processing messages
                print("Process {} waiting for message".format(self.name))
                msg = message_queues[self.name].get(block=True)        
                # Got a message, check if the timestamp 
                # is greater than our clock, if so advance it
                if msg.timestamp >= self.lamport_clock:
                    self.lamport_clock = msg.timestamp + 1
                print("Got message {}".format(msg))
                self.process_message(msg)
                self.lamport_clock += 1
                # Check after processing if the resource is 
                # available for me now, if so, grab it.
                # We need earliest request to be ours and check that we 
                # have received an older message from everyone else 
                if self.check_available():
                    print("Resource available for {}".format(self.name))
                    self.has_resource = True
            print("Process {}: {}".format(self.name, self.request_queue))
            print("Process {} Clock: {}".format(self.name, self.lamport_clock))
            time.sleep(1)

    def check_available(self):
        got_older = {k: False for k in self.other_processes}
        # Get timestamp of our req
        our_req = None
        for req in self.request_queue:
            if req.sender == self.name:
                our_req = req
        if our_req is None:
            return False
        # We found our req make sure it is younger than 
        # all the others and we have an older one from 
        # the other guys
        for req in self.request_queue:
            if req.sender in got_older and req.timestamp > our_req.timestamp:
                got_older[req.sender] = True
        if all(got_older.values()):
            return True
        return False
{% endhighlight %}

Using the above Process class, we can just spawn the threads and observe the output indicates that the processes take turns utilizing the resource:

{% highlight python %}

t1 = Process("A", initially_granted_proc, list(procs - set("A")))
t2 = Process("B", initially_granted_proc, list(procs - set("B")))
t3 = Process("C", initially_granted_proc, list(procs - set("C")))

# Daemonizing threads means that if main thread dies, so do they. 
# That way the process will exit if the main thread is killed.
t1.setDaemon(True)
t2.setDaemon(True)
t3.setDaemon(True)

try:
    t1.start()
    t2.start()
    t3.start()
    while True:
        # Need some arbitrary timeout here, seems a bit hackish. 
        # If we don't do this then the main thread will just block 
        # forever waiting for the threads to return and the 
        # keyboardinterrupt never gets hit. Interestingly regardless of the 
        # timeout, the keyboard interrupt still occurs immediately 
        # upon ctrl-c'ing
        t1.join(100)
        t2.join(100)
        t3.join(100)
except KeyboardInterrupt:
    print("Ctrl-c pressed")
    print("Resource usage:")
    print(resource_usage_counts)
    sys.exit(1)
{% endhighlight %}

Running that code you will see that only one thread uses the resource at a time and the order in which the resource is used is deterministic such that the 
resource_usage_counts increments as follows:

{'A': 1, 'B': 0, 'C': 0}  
{'A': 1, 'B': 1, 'C': 0}  
{'A': 1, 'B': 1, 'C': 1}  
{'A': 2, 'B': 1, 'C': 1}  
{'A': 2, 'B': 2, 'C': 1}  
{'A': 2, 'B': 2, 'C': 2}  

and so on.

