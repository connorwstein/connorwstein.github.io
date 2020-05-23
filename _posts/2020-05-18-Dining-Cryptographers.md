---
layout: post
title: Dining Cryptographers in Golang
---

Say you are out for dinner with a bunch of coworkers and salaries come up. You've heard rumours that some people get paid more than X per year at your company. You're curious whether anyone at the table is in this elite group, but naturally people don't want to reveal their salaries. 

Is there a way to find out without revealing who it is? [David Chaum](https://en.wikipedia.org/wiki/David_Chaum) raised a version of this question in the 1980s - calling it the [Dining Cryptographer's Problem](https://en.wikipedia.org/wiki/Dining_cryptographers_problem) (DC) and developed an elegant protocol to do it. It's a fascinating example of one of the earliest secure multiparty computation protocols. Let's take a look at how it works.

We're basically asking whether ($$ cs $$ = coworker's salary) 

$$ {cs}_{1} > X  || {cs}_{2} > X || ... || {cs}_{N} > X $$

evaluates to true and we want each input to the OR to remain private, hence secure computation.

The steps to achieve this are as follows, using 3 coworkers as an example:

1. Each pair of coworkers get a random bit. For example, they each do a coin flip $$ r_{1}, r_{2}, r_{3} $$ with each other such that we end up with $$ C_{1} = r_{2}, r_{3}, C_{2} = r_{1}, r_{3}, C_{3} = r_{1}, r_{2}$$

2. Each coworker broadcasts a secret share depending on their salary, say for $$ C_{3} $$ this would be:

    $$
    B(salary, X) = \left\{
            \begin{array}{ll}
                (r_{1} \oplus r_{2}) & salary \leq X \\
                \neg(r_{1} \oplus r_{2}) & salary \geq X 
            \end{array}
        \right.
    $$

    $$ C_{3} $$'s salary is secret because we've effectively performed a one time pad encryption on the bit of information they are trying to protect. The broadcasted value $$ B_3 $$ is $$ B = S \oplus R $$ where the key $$ R $$ is the randomness from the two partner-shared bits.

3. Each coworker can then assemble the secret shares and "decrypt" by computing:
$$ B_{1} \oplus B_{2} \oplus B_{3} $$. Its clear than in the case where all coworkers have salaries less than X, we get $$ (r_{1} \oplus r_{2}) \oplus (r_{2} \oplus r_{3}) \oplus (r_{1} \oplus r_{3}) = 0 $$. Say $$ C_{3} $$ has the high salary, then we get $$ \neg(r_{1} \oplus r_{2}) \oplus (r_{2} \oplus r_{3}) \oplus (r_{1} \oplus r_{3}) =  \neg(r_{1} \oplus r_{2}) \oplus (r_{1} \oplus r_{2}) = 1$$. It doesn't matter which coworker has the high salary (we could just relabel them), we'll always get 1. However only one coworker can transmit information at a time, otherwise that reduction will no longer be true.   


Here's some Golang code illustrating the idea ($$ C_{2} $$ has the high salary):
{% highlight golang %}
package main

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type Coworker struct {
	id      int
	salary  int
	recv    []chan int
	send    []chan int
}

func InitCoworker(
	id int,
	salary int,
	recv []chan int,
	send []chan int) *Coworker {
	return &Coworker{
		id:     id,
		salary: salary,
		send:   send,
		recv:   recv,
	}
}

func (c *Coworker) RunDCNet(ctx context.Context, highSalary int, seeds []int) {
	// Don't care about the order, just aggregate receiving values.
	agg := make(chan int)
	for _, ch := range c.recv {
		go func(subch chan int) {
			for msg := range subch {
				agg <- msg
			}
		}(ch)
	}
	toAnnounce := seeds[0]
	for _, s := range seeds[1:] {
		toAnnounce ^= s
	}
	// Default to sending r1 ^ r2
	// if high send ~(r1 ^ r2)
	if c.salary >= highSalary {
		toAnnounce ^= 1
	}
	// Announce our secret share
	go func() {
		for i := 0; i < len(c.send); i++ {
			c.send[i] <- toAnnounce
		}
	}()
	// Gather secret shares and "decrypt"
	highSalaryExists := toAnnounce
	for i := 0; i < len(c.recv); i++ {
		highSalaryExists ^= <-agg
	}
	fmt.Println("coworker", c.id, "high salary exists", highSalaryExists)
}

func main() {
	ctx := context.Background()
	highSalary := 100
	var seeds  = make([]int, 3)
	for i := 0; i < 3; i++ {
		rand.Seed(time.Now().UnixNano())
		seeds[i] = rand.Intn(2)
	}
	// c1 -- c2
	//  \   /
	//   c3
	var backingChannels []chan int
	for i := 0; i < 6; i++ {
		backingChannels = append(backingChannels, make(chan int))
	}
	var wg sync.WaitGroup
	wg.Add(3)
	go func() {
		c1 := InitCoworker(0, 10,
			[]chan int{backingChannels[0], backingChannels[1]},
			[]chan int{backingChannels[2], backingChannels[3]})
		c1.RunDCNet(ctx, highSalary, []int{seeds[1], seeds[2]})
		wg.Done()
	}()
	go func() {
		c2 := InitCoworker(1, 110,
			[]chan int{backingChannels[2], backingChannels[4]},
			[]chan int{backingChannels[0], backingChannels[5]})
		c2.RunDCNet(ctx, highSalary, []int{seeds[2], seeds[0]})
		wg.Done()
	}()
	go func() {
		c3 := InitCoworker(2, 10,
			[]chan int{backingChannels[3], backingChannels[5]},
			[]chan int{backingChannels[1], backingChannels[4]})
		c3.RunDCNet(ctx, highSalary, []int{seeds[0], seeds[1]})
		wg.Done()
	}()
	wg.Wait()
}
{% endhighlight %}

