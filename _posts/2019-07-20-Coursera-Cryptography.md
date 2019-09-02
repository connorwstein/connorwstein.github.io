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

A pseudorandom number generator (PRG) is a deterministic algorithm for generating a sequence of bits from a given seed which appear random. 
It is secure if an adversary is unable to predict the next bit with any high degree of probability. More concretely there is no such algorithm $$ A $$ where: 

$$ 
\begin{align*}
 Pr[A(PRG(k))|_{i..1} = PRG(k)|_{i+1}] > \frac{1}{2} + \epsilon 
\end{align*}
$$

The $$ \frac{1}{2} $$ comes from the fact that its the next _bit_ an adversary is trying to predict. 
$$ \epsilon $$ is a tunable parameter corresponding to the security of the system. Typically something on the order of $$ \begin{align*} \frac{1}{2^{80}} \end{align*} $$ to be considered negligible and thus secure.

**PRF** 

A pseudorandom function (PRF) is 
It is secure if given the set of all functions from X to Y, a secure PRF is indistinguishable from a randomly chosen function X to Y.

**PRP** 

**CPA**

**CCA**

**Authenticated encryption**

 Authenticated encryption is when you have both semantic security against a CPA attack (confidentiality) and you have existential unforgeability under a chosen message attack (integrity)

**Semantic security**




### Stream Ciphers
Symmetric ciphers use the same key to encrypt and decrypt. Given key space K, message space M and ciphertext space C, a symmetric cipher is defined as:

$$
E: K\times M\rightarrow C\\
D: K\times C\rightarrow M\\
\forall k \in K: D(E(k, m)) = m\\
$$

E often produces randomized ciphertext because if not adversaries often have ways of manipulating the ciphertext for attacks and/or learning something about the ciphertext. D must be deterministic,
clearly the secret message we get should not change the more times we decrypt. 

The one time pad (OTP) is a famous simple kind of symmetric cipher where $$K, M, C \in [0,1]^{n}\$$ and $$E(k, m) = k \oplus m$$. A secure cipher is one where no information
is given about the plain text (Shannon's definition). A cipher is "perfectly" secure if the probability of getting a specific ciphertext is equal for all input messages. This is equivalent 
to learning nothing about the plaintext because the attacker fundamentally cannot know if the ciphertext came from m0 or m1 (for any pair of messages m0 and m1). The OTP has perfect secrecy
as long as the keys are never reused and they are randomly generated. There is a theorem stating that for a cipher to be perfectly secure, the key length must be >= the message length.

Why do xor's come into play in the first place? Xors are very fast operations on computers.

The idea of a stream cipher is to use a small truly random key to generate pseudo random keys. This security will be less than perfectly secure and will depend on how these pseudo-random keys are generated, i.e. the depend on the security of the pseudo-random generator. Its called a stream because the PRG generates a never ending stream of bits which we xor with messages as needed to encrypt them. Notably the stream output can only be used once, otherwise attackers can xor the two ciphertexts produced by a reused key together and obtain m0 xor m1 which can reveal info [link to pixel overlay example].

[ TODO elaborate more on the notion of pseudo randomness]

A pseudo-random generator is a function which takes a small seed of bits and produces a much larger string of bits. The much larger string of bits is efficiently computable by a deterministic algorithm.It may appear that we could just make OTP practical by generating keys from this small seed of bits, but unfortunately the key is really just the seed of the PRG, which is smaller than the message size and thus violates our theorem that perfectly secure ciphers must have key lengths >= the message lengths. 

If we can predict the output of the PRG after some observation, then we can predict the keys and thus decrypt subsequent messages. So the security of the stream cipher depends on the predictability of
this PRG. We define the PRG as being predictible if given all the bits up to i you can predict the next bit with probability greater than one-half plus epsilson where epsilon is a tunable value and 
in practice it needs to be < 1/2^80 to be considered secure. The 80 is often used as the security parameter lambda. 

Still more problems with stream ciphers though - the cipher text is malleable. We can take $$ c1 = G(k) \oplus m0 $$ and manipulate m0 via $$ c1 \oplus p = G(k) \oplus (m0 \oplus m1) $$. 

Stream ciphers are semantically secure. [TODO elaborate]

#### Block Ciphers
[Diagram of block ciphers]
Block ciphers are fundamentally different than stream ciphers in that they operate on fixed length blocks of input data. They take a key, expand it into a bunch of pseudo-random keys and using those as inputs to a series of round functions. [Diagram].
How do you encrypt something larger than a block? Depends on the mode of operation. There are a few but the most important ones are:
- Counter mode
    - Each plaintext is simply xored with the output of a PRF(k, counter value) to produce ciphertext.  
- Cipher block chaining
    - Ciphertext output of a block is xor'd with the plaintext of the next block before encrypting that block, thus at any given point the input to an encryption depends on all plaintext up to that point. The encryption itself uses a PRP.

The IV is used to make each ciphertext block unique.

#### Message Integrity
#### Authenticated Encryption
Security in general is defined in the context of a challenger and an adversary. The adversary starts by sending arbitrary messages m0 and m1 to the challenger. The challenger sends back the encrypted version of one of the messages. Using only probabilistic polynomial time algorithms, the probability with which the adversary can correctly identify which of the two messages was encrypted is known as the semantic security of the system. The security lies on a spectrum ranging from 1/2 being secure and 1 being totally insecure.

The adversary may have additional powers aside from simply sending two plaintext messages. For instance some powers we can give are:
- Encrypt any number of adversary specified plaintexts (chosen plaintext)
- Decrypt any number of adversary specified ciphertexts (chosen ciphertext) 
    - A notable exception would be the decryption of the ciphertext in question for the distinguishability test as that would obviously defeat the purpose


##### Diffie Helman Key Exchange

##### Number Theory 
Euler's totient function $$\phi(n)$$ counts the number of positive integers up to n that are relatively prime with N. 
If n itself is prime then the positive integers up to n which are relatively prime with n is all of them except n, 
because gcd(n, n) = n, not 1. 
It is a multiplicative function, so $$ \phi(pq) = \phi(p)\phi(q) $$. 
In the context of RSA, this comes up because the RSA modulus is N = pq and we have to pick our
keys such that ed = k 


##### Public Key Encryption



