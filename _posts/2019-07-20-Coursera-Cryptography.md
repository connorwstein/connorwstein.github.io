---
layout: post
title: Coursera's intro to cryptography cheatsheet
---

### Key Definitions
**Pseudorandom**

Pure randomness is measuring something from nature: radioactive decay, coin flips etc. 
Pseudorandomness is when you have something that appears random but if you were to obtain some secret information then it would become non-random or predictable. 
Entropy in this context is a measure of randomness or size of statistical noise, for instance if each possible value in a 128-bit number has an equal probability of getting selected, then there is 128-bits of entropy in that selection process. 
Entropy is obtained in [Linux](https://github.com/torvalds/linux/blob/master/drivers/char/random.c#L69) by pooling the timestamps of interrupt events and taking the SHA hash of those to get random bytes found in /dev/random.
Those random bytes are used to periodically reseed the PRG which outputs /dev/urandom.

**Nonce**

A n(umber-used)once. 
A common use case and a good way to think about this is to imagine someone obtains an encrypted transaction for spending money from someones account. 
Without a nonce as part of the encrypted transaction, the malicious user could broadcast the transaction over and over again to drain the account. 
Strictly speaking, the nonce does not have to be random. 
It can be a pure incremental counter such as in counter mode block ciphers. 
However to prevent certain kinds of attacks it may be required to be random, such as when used as the IV for cipher block chaining mode block ciphers.

**Symmetric Ciphers** 

Symmetric ciphers use the same key to encrypt and decrypt. Given key space K, message space M and ciphertext space C, a symmetric cipher is defined as:

$$ E: K\times M\rightarrow C $$

$$ D: K\times C\rightarrow M $$

$$ \forall k \in K: D(E(k, m)) = m $$

E often produces randomized ciphertext because if it doesn't adversaries often have ways of manipulating the ciphertext for attacks and/or learning something about the ciphertext. 
D must be deterministic, because we definitely do not want the decrypted plaintext to change with additional decryptions. 


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

**MAC** 

A message authentication code (MAC) or tag is designed to ensure both message integrity (message was not modified) and authenticity (message came from the right person). 
They are different from cryptographic signatures in that MACs use a shared symmetric key which is required to run the verify function.
Thus only the recipient can verify the MAC, a 3rd party cannot unless they are also given the symmetric key.

It involves a pair of algorithms "sign" and "verify" $$ S, V $$ such that:

$$ S(k, m) = t $$ 

$$ V(k, m, t) = valid \| invalid $$

It is considered secure if the attacker has the power to request for arbitrary messages to be signed and yet they are unable to produce an existential forgery: another valid MAC for one of the requested messages. 
 
**Authenticated encryption**

Authenticated encryption is when you have both semantic security against a CPA attack (confidentiality) and you have existential unforgeability under a chosen message attack (integrity).


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

Block ciphers are fundamentally different than stream ciphers in that they operate on fixed length blocks of input data. 
They take a key, expand it into a bunch of pseudo-random keys and using those as inputs to a series of round functions.

{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/coursera_block_cipher.png) 
{: refdef}

The round functions $$ R(k_i, m_i) $$ define the block cipher and they are built from PRPs or PRFs. One way to build a block cipher from just a PRF ($$ F: K \times X \rightarrow X $$) is via a Fiestel network:

{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/coursera_fiestel.png) 
{: refdef}

Here the input is plaintext split into two halves $$ R_i, L_i $$. The left circuit above is a single round of encryption and the right one is a single round of decryption.
When we plug the output of the encryption circuit $$ R_i = f_i(R_{i-1}) \oplus L_i, L_i = R_{i-1} $$  into the decryption circuit we get a nice little cancellation: 

$$ L_{i-1} = R_i \oplus f_i(L_{i-1}) = f_i(R_{i-1}) \oplus L_i \oplus  f_i(R_{i-1}) = L_{i-1} $$

$$ R_{i-1} = L_i = R_{i-1} $$

That cancellation is how Fiestel networks can avoid the invertibility requirement of a PRP and only use a PRF. 
The data encryption standard (DES) was a standard block cipher scheme invented in the 70s and eventually broken around 2000.
It uses a 16-round Fiestel network, where the PRF is a substitution-permutation network. 
The substitution portion of the network (S-box) is simply a lookup table which provides cryptographic "confusion" - a term meaning each bit of ciphertext depends on multiple bits of the key. 
The permutation portion of the network (P-box) is to provide cryptographic "diffusion" - a term meaning a change in a single bit of the input should have equal probability of changing any particular ciphertext bit. 
In DES, the permutation portion of the network is just a fixed lookup table, so interestingly the security of DES rests on the design of the substitution lookup table.
A poorly designed S-box is subject to differential cryptanalysis, a CPA attack where by observing changes in ciphertext corresponding to changes in plaintext you can reduce the scope of the key search.
Turns out the S-box wasn't the main weakness that killed DES (though although some differential cryptanalysis attacks were possible), ultimately computers became strong enough to just brute force the relatively small 56-bit key.
Its successor is the the advanced encryption standard (AES), which does not use a Fiestel network at all, just a pure substitution-permutation network based on the Rijndael S-box.

#### Block Cipher Modes
To encrypt something larger than a block, we split up the plaintext into blocks and pad. There are a few ways to do this, the most important being cipher block chaining (CBC) and counter mode (CTR).

In CBC mode, the ciphertext output of a block is XOR'd with the plaintext of the next block before encrypting that block, thus at any given point the input to an encryption depends on all plaintext up to that point. 

{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/wiki_cbc.png) 
{: refdef}

A random initialization vector (IV) is used as an input to ensure that the final output is not deterministic. 
If the IV is predictable, then CBC mode is no longer CPA secure. 
For instance, say some old ciphertext was:

 $$ c = AES(key, {IV}_i \oplus m_{secret}) $$

If I can predict IVs, then I can ask for:

$$ c_{test} = AES(key, {IV}_{i+1} \oplus {IV}_i \oplus m_{guess}) $$

If $$ c_{test} = c $$, then I've just confirmed that $$ m_{guess} = m_{secret} $$.


In CTR mode, rather than ensuring a random IV is used for the first block and then propagated through the rest of the blocks, we just pick a random nonce and append a counter value to the nonce to produce a unique IV for each block. 

{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/wiki_ctr.png) 
{: refdef}

A big win with CTR mode is that blocks can be encrypted in parallel. Assuming that the underlying block cipher is secure, it doesn't matter that the input is biased by the deterministic counter.

### Message Integrity
Some different MAC schemes include: 
- CBC-MAC (PRF-based)
- Carter-Wegman MAC (randomized + a little PRF)
- HMAC (collision resistance based)

#### CBC-MAC
The chain block cipher MAC is the same as a block cipher in CBC mode (AES is often used), except we only use the last cipherblock as the MAC and we just use 0 as the IV. 
The chaining ensures that any change to the plaintext causes the final cipher block to change. 
The important thing to note is that CBC-MAC is only secure for key re-use if the message is the same fixed size every time.
If the message length is variable the attacker can ask for two MACs, say $$ (m[0] || m[1], T), (m'[0] || m'[1], T') $$ then ask for the MAC of different message $$ m || (m'[0] \oplus T || m'[1]) $$.
That crafted message will result in an existential forgery because the MAC will be $$ T' $$ again:

{:refdef: style="text-align: center;"}
![image]({{ site.url }}/assets/cbc_attack.png) 
{: refdef}

because the output of the second block is actually $$ T $$, so it cancels the $$ T $$ from $$ T \oplus m'[0] $$.

One way to get around this is the encrypt-last block approach (ECBC-MAC), whereby encrypting the last block means that in the attack above, the output of the second block is no long $$ T $$ so we don't get the cancellation.

#### Carter-Wegman MAC
One of the downsides of CBC-MAC is that its kind of slow. 
Carter and Wegmen invented the concept of universal hashing and then used it to produce a MAC which runs exceptionally fast on modern machines in what is known as the Carter-Wegman style MAC.

Most hash functions get their fast O(1) performance assuming that the distribution of inputs is equal.
Consider the case of a string hash function which sums all the byte values of the string as 64-bit integers. 
It would be extremely biased towards the small numbers in 64-bit space, degrading to O(n).  
Universal hashing solves this problem by picking a hash function randomly from a family of hash functions where the family ensures that
the probability of a collision with randomly chosen hash function $$ h $$ is $$ \frac{1}{m} $$ where $$ m $$ is the number of hash buckets.
For instance, a universal family for hashing integers which they came up with is: 

$$ h_{a, b}(x) = ((a*x + b) \bmod p) \bmod m $$ 

where $$ p $$ is just some prime chosen such that $$ p >= m $$: 

Ok so how could such a thing be used to produce our pair of MAC functions $$ S(k, m), V(k, m, t) $$? 

The VMAC algorithm is a MAC algorithm that uses this style of MAC generation. Its construction is:

$$ S((k1, k2), m) = UH_{k1}(m) + PRF_{k2}(r) = t $$

where $$ UH $$ is one of these universal hash functions and $$ r $$ is a random nonce shared between sender and receiver. 
By $$ UH_{k1} $$ we mean that a randomly key $$ k1 $$ is used to select the hash function from the hash function family.
The verification function $$ V $$ works by just recomputing $$ t $$ and ensuring that it is the same as the $$ t $$ in question.
Its clever because we use the fast universal hash on the large input and the slower PRF on a much smaller random nonce, yet Carter and Wegman were able to show that security still follows from truly random keys and a secure PRF.

#### HMAC
HMAC is short for hash MAC and its a plug and play MAC suitable for use with any cryptographic hash function. 
It is widely used in IPSec, TLS and JWTs.
At a high level, all we do is hash the message plus a key using a cryptographic hash function and that is the tag.
To verify, assuming we get the hash from a trusted source, we then locally hash the received message plus the key and compare the locally computed one with the public read-only one.
The whole security of hash-based MACs like HMAC rests on collision resistance. 
Given $$ H(m_0) $$, if I can efficiently find $$ m_1 $$ such that $$ H(m_0) = H(m_1) $$, then I can just submit $$ H(m_1) $$ as a forged tag for $$ m_1 $$.
Notably we can't directly hash the key and message like $$ H(k || m) $$ because then adversaries can produce a still valid MAC $$ H(k || m || m_{adversary}) $$ without actually knowning the secret key. 
To resolve this problem, HMAC is of the form $$ H(k_1 || H(k_2 || m)) $$.

### Authenticated Encryption
Encryption gives us CPA security. 
However, if the adversary is active can tamper with messages in flight, then they can perform a CCA attack to break semantic security. 
To protect against CCA attacks given this more powerful adversary, we need to ensure two things:
- Eavsdropping is prevented with CPA secure encryption
- Ciphertext tampering is prevented with a unforgeable MAC  
These two components give us authenticated encryption and they ensure that the system is CCA secure (the adversary has the ability to decrypt some chosen ciphertexts).
When we combine encryption with a MAC, encrypt-then-MAC always provides authenticated encryption whereas MAC-then-encrypt may or may not provide it, but notably it does work if you are using a rand-CBC or rand-CTR mode block cipher for the encryption.
A widely used authenticated encryption scheme is galois counter mode (GCM) which encrypts with a rand-CTR mode block cipher (often AES) and an incremental MAC called GMAC which can be computed in parallel.

### Diffie Helman Key Exchange
The diffie helman (DH) key exchange is a way to agree on a shared secret without ever explicitly sending the shared secret over the wire. 

### Public Key Encryption
Ways to do public key encryption:
- RSA
- El-Gamal

Euler's totient function $$\phi(n)$$ counts the number of positive integers up to n that are relatively prime with N. 
If n itself is prime then the positive integers up to n which are relatively prime with n is all of them except n, 
because gcd(n, n) = n, not 1. 
It is a multiplicative function, so $$ \phi(pq) = \phi(p)\phi(q) $$. 
In the context of RSA, this comes up because the RSA modulus is N = pq and we have to pick our
keys such that ed = k 


### Topics for a second post:
- Hash function design
- Elliptic curve based cryptography
- Lattice based cryptography
- MPC
- ZKPs
- Some other stuff from https://crypto.stanford.edu/pbc/notes/crypto/
- Stuff I've heard about on blockchain podcasts: VDFs, accumulators, on-chain randomness, TEEs etc.


