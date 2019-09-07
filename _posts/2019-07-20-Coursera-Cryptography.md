---
layout: post
title: Coursera's intro to cryptography cheatsheet
---

### Key Definitions
**Pseudorandom**

Pure randomness is measuring something from nature: radioactive decay, coin flips etc. 
Pseudorandomness is when you have something that appears random - hence the prefix pseudo - but if you were to obtain some secret information then it would become predictable. 
Entropy in this context is a measure of randomness or size of statistical noise, for instance if each value in a 128-bit number have an equal probability of getting selected, then there is 128-bits of entropy. 
Entropy is obtained in [Linux](https://github.com/torvalds/linux/blob/master/drivers/char/random.c#L69) by pooling the timestamps of interrupt events and taking the SHA hash of those to get random bytes found in /dev/random.
Those random bytes are used to periodically reseed the PRG which outputs /dev/urandom.

**Nonce**

A n(umber-used)once. 
A common use case and good way to think about this is to imagine someone obtains an encrypted transaction for spending money from someones account, without a nonce as part of the encrypted transaction, a user could continuously broadcast the transaction to drain the account. 
Strictly speaking, the nonce does not have to be random. 
It can be a pure incremental counter such as in counter mode block ciphers. 
However to prevent certain kinds of attacks it may be required to be random, such as when used as the IV for cipher block chaining mode block ciphers.

**PRG**

A pseudorandom number generator (PRG) is an efficient deterministic algorithm for generating a sequence of bits from a given seed which appear random. 
It is secure if an adversary is unable to predict the next bit with any high degree of probability. More concretely there is no such algorithm $$ A $$ where: 

$$ 
\begin{align*}
 Pr[A(PRG(k))|_{i..1} = PRG(k)|_{i+1}] > \frac{1}{2} + \epsilon 
\end{align*}
$$

The $$ \frac{1}{2} $$ comes from the fact that its the next _bit_ an adversary is trying to predict. 
$$ \epsilon $$ is a tunable parameter corresponding to the security of the system. Typically something on the order of $$ \begin{align*} \frac{1}{2^{80}} \end{align*} $$ to be considered negligible and thus secure.

**PRF** 

$$ F: K \times X \rightarrow Y $$

A pseudorandom function (PRF) is exactly like a PRG but instead of being a stream it has random access. 
Similar to PRGs, for a PRF from set X to Y to be considered secure, the function needs to be indistinguishable from a randomly chosen function in that set.
PRFs can be constructed from PRGs and we can use PRFs to build PRPs, which are used to build block ciphers, the dominant form of encryption used today.

**PRP** 

$$ E: K \times X \rightarrow X $$

A psuedorandom permutation (PRP) is similar to a PRF except it has a few additional properties which make it a permutation:

- $$ D: K \times X \rightarrow X $$ must exist which inverts $$ E $$
- Inputs correspond to exactly one output 

**Semantic security**

Best explained with the diagram from the course:
{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/coursera_semantic_security.png) 
{: refdef}
A system is said to be semantically secure if the adversary gives the challenger messages $$ m_0, m_1 $$ and is unable to determine with any non-negligible probability greater than $$ \frac{1}{2} $$  which message was encrypted. 
Its a probabilistic way to determine whether the adversary has learned _anything_ about the ciphertext. 

**CPA**

If we give the adversary the power to ask for encryptions of arbitrary messages (chosen plaintext) they can learn enough about the encryption mechanism to be able to break semantic security.

**CCA**

If, in addition to the CPA powers, we give the adversary the power to ask for decryptions of chosen ciphertexts they can learn enough about the encryption mechanism to be able to break semantic security.
The one caveat is we necessarily need to exclude asking for the decryption of the challenge texts.

**Authenticated encryption**

Authenticated encryption is when you have both semantic security against a CPA attack (confidentiality) and you have existential unforgeability under a chosen message attack (integrity).

**Symmetric Ciphers** 

Symmetric ciphers use the same key to encrypt and decrypt. Given key space K, message space M and ciphertext space C, a symmetric cipher is defined as:

$$
E: K\times M\rightarrow C\\
D: K\times C\rightarrow M\\
\forall k \in K: D(E(k, m)) = m\\
$$

E often produces randomized ciphertext because if not adversaries often have ways of manipulating the ciphertext for attacks and/or learning something about the ciphertext. 
D must be deterministic, clearly the secret message we get should not change the more times we decrypt. 


### Stream Ciphers
The simplest possible symmetic cipher is known as the one time pad (OTP):

Given a message $$ m \in [0,1]^{n} $$, a random key $$ k \in [0,1]^{n}$$:

$$ E(k, m) = k \oplus m = c $$

$$ D(k, m) = k \oplus c = m $$

and we never re-use the key $$ k $$.

The upsides of the OTP:
- It has perfect secrecy - all ciphertexts have an equal probability of being generated - as long as the keys in fact randomly generated. 
- XOR operations are very fast for computers

The downsides of the OTP:
- We need to generate a new key every time we encrypt
- The key must be as long as the message itself
- The ciphertext is malleable. If I intercept the message $$ c $$ I can $$ c \oplus m_{connor} $$ and the decryptor will happily produce $$ m \oplus m_{connor} $$.
 
Unfortunately, these downsides are just too large for the OTP to be practical. 
Stream ciphers are able to overcome the first two downsides by using a much smaller random key to seed a PRG. 
This PRG then generates a _stream_ of bits which we use to encrypt messages as we need to, never re-using the old stream outputs. 
There is a theorem stating that for a cipher to be perfectly secure, the key length must be >= the message length, so stream ciphers cannot be perfectly secure. 
They can be as secure as the pseudo-random generator used to generate the stream however, and they are semantically secure assuming the PRG is secure.
Without a MAC, stream ciphers still suffer from the malleability problem. 
From a practical standpoint, stream ciphers are hard to get right. 
In particular the requirements of a truly random PRG seed and never re-using the key stream bits can often attacked.  
TODO: quick summary of key re-use attacks and seeding problems. 

### Block Ciphers

Block ciphers are fundamentally different than stream ciphers in that they operate on fixed length blocks of input data. They take a key, expand it into a bunch of pseudo-random keys and using those as inputs to a series of round functions. [Diagram].
How do you encrypt something larger than a block? Depends on the mode of operation. There are a few but the most important ones are:
- Counter mode
    - Each plaintext is simply xored with the output of a PRF(k, counter value) to produce ciphertext.  
- Cipher block chaining
    - Ciphertext output of a block is xor'd with the plaintext of the next block before encrypting that block, thus at any given point the input to an encryption depends on all plaintext up to that point. The encryption itself uses a PRP.

The IV is used to make each ciphertext block unique.

### Message Integrity

### Authenticated Encryption

#### Diffie Helman Key Exchange

#### Number Theory 
Euler's totient function $$\phi(n)$$ counts the number of positive integers up to n that are relatively prime with N. 
If n itself is prime then the positive integers up to n which are relatively prime with n is all of them except n, 
because gcd(n, n) = n, not 1. 
It is a multiplicative function, so $$ \phi(pq) = \phi(p)\phi(q) $$. 
In the context of RSA, this comes up because the RSA modulus is N = pq and we have to pick our
keys such that ed = k 


### Public Key Encryption

