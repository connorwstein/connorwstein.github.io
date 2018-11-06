---
layout: post
title: RC mid-batch update 
---

###### What actually happened
Aug 13 - Aug 24: 
- A basic bitcoin implementation while reading the Mastering Bitcoin book

Aug 27 - Aug 31:
- Worked on the labs in [MIT 6.824](https://pdos.csail.mit.edu/6.824/)
- Completed lab 1 (map reduce) and lab 2 (raft) 

Sept 3 - Sept 23
- Worked on an implementation of the EVM (can execute the byte code from some simple contracts) while reading the Mastering Ethereum book
- Did ~50 leetcode problems and read some of the Algorithm Design Manual to really learn dynamic programming, backtracking and graphs
- Learned solidity via tutorials like [crypto zombies](https://cryptozombies.io) and [building a full stack hello world voting app](https://medium.com/@mvmurthy/full-stack-hello-world-voting-ethereum-dapp-tutorial-part-1-40d2d0d807c2)

###### Some things that I have learned about learning while at RC
Its really important to break down a nebulous goal like “learn ethereum” into some form of actionable item where you can define success with a way to verify it, measure progress to get there and ideally have frequent, achievable sub-goals. If you miss one of those components you can aimlessly wander reading bits of things and never build towards a deep understanding. 

If the progress component is missing, your productivity will certainly decline. The most productive days at RC thus far have been when I was nearly complete some sub-goal like “be able to send arbitrary amounts of coin between my bitcoin nodes.” The least productive days were when I was between projects and just reading about possible avenues to go down. 

Finding projects which have some way to verify their success is not always easy depending on what you are trying to learn. If its a classic CS topic the best thing to do is find an acclaimed university course with all the materials online - particularly the programming assignments (ideally with test code as well). You are leveraging someones enormous effort to structure the information in a digestible way and in the correct order. For topics where the information is just kind of dispersed among papers/books/blogs, like ethereum, finding some kind of verifiable project is non-trivial. Writing a prototype of the system/idea is probably the best but may be too time consuming. I chose to implement a prototype of a key component, the EVM, which I was able to verify by using real byte code as an input, but it took me a while to land on that. 

###### Some things I have learned about technical presentations
At RC, once or twice a week there is a slot of time where people present what they are working on or topics that interest them. Having been here for 6 weeks I have now seen a lot of technical presentations. The best ones are always the more structured ones which some kind of problem statement and solution format. Nothing ground breaking here, I probably could have guessed that coming in. Among those with that format, the best ones usually built up to some complex idea/tool/practise step-by-step where each step was easily digestible. Having done a few of these myself and gotten feedback from audience members, the tricky part is making sure that the complexity of the final idea or point the  presentation matches the audience’s level of expertise so its interesting and that the pace of steps to get there are appropriate. It is really easy to make steps which are uneven in digestibility, for example 2 or 3 steps early on which are too trivial and then one gigantic jump to the conclusion which goes over peoples heads. It is also easy to make the pace too quick, because by the time you give the presentation you have been steeped deep in the material for a while and things now seem obvious to you. 

###### Some things I have learned about collaboration
Collaboration is a huge pull for RC in general. Its the main reason why people come instead of just hacking away in their basements solo. It has taken many forms. Working on a shared code base and pairing daily is probably the most extreme form and is one which I haven’t really done and hasn’t gone on all that much at RC. A lot of things need to line up for that to happen. You need to be interested in exactly the same topic to the same degree as someone else or one person is willing to deviate from their original trajectory in the name of collaboration and learning about different perspectives. To be interested in the same topic to the same degree is not all that likely given the vast scope of the software world and peoples individual career paths and motivations. Even if you do find a match here, people often still just prefer to work on separate code bases.

Collaboration in the form of a shared code base and daily pairing certainly is not the only way though. A more common pattern has seemed to be people working on similar projects, working through the same course or problem set independently and then interacting when they got stuck on some aspect. Quite similar to the way university projects operate. For me there were other people working on a blockchain implementation and it was helpful to talk when we got stuck, not only to resolve the problem, but also to see how other people approach problems. 

I knew people were going to be working on a huge variety of projects and I knew roughly what their backgrounds were before coming from email threads and the website directory. However, I totally didn’t expect to be as inspired by them in person. I definitely underestimated the power of talking to passionate people in person about their passion. When people hold deep knowledge, excitement and conviction about something it is really easy to become convinced that you should also learn about and work on that topic. 

###### The remaining half
As expected there has been some deviation from the original plan, though not that much. The game theory coursera course has definitely been put on the back burner in favour of algorithms studying. I realized the merkle tree hot-standby project idea probably isn’t the best use of time and learning solidity has replaced that. The EVM project also cropped up as a way to learn ethereum. 

The pieces of the original plan which will occupy the second half are the cryptopals challenges in a functional language and going through SICP to complement that. I will also continue to read and implement prototypes from the world of blockchain papers. Overall RC is awesome and if you want to deep dive something technical its a great place to do it.
