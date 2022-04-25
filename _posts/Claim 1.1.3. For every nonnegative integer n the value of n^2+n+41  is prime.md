--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\## Question
Claim 1.1.3. \_For every nonnegative integer \_n \_the value of ![](https://cdn.nlark.com/yuque/\_\_latex/383819858ada02de98f8de9faf90fa07.svg#card=math&code=n%5E2%2Bn%2B41&height=18&width=76)
\_ \_is prime.\_

\## Solution
Let’s try some
numerical experimentation to check this proposition. Let

![](https://cdn.nlark.com/yuque/\_\_latex/2c7f8f1def7b51d7b01578a2fe435125.svg#card=math&code=p%28n%29%20%3A%3A%3Dn%5E2%2Bn%2B41&height=20&width=133)











We begin with ![](https://cdn.nlark.com/yuque/\_\_latex/8d37d48cb80d747f307d904798db9954.svg#card=math&code=p%280%29%20%3D%2041%0A&height=18&width=61), which is prime; then

![](https://cdn.nlark.com/yuque/\_\_latex/c0dbad0c42886547c12680c91c0f031e.svg#card=math&code=p%281%29%3D43%2Cp%282%29%3D47%2Cp%283%29%3D53%2C...%2Cp%2820%29%3D461&height=18&width=308)

are each prime. Hmmm, starts to look like a plausible claim. In fact we can keep
checking through ![](https://cdn.nlark.com/yuque/\_\_latex/aab9d9f2d4f14259066a0d212498827c.svg#card=math&code=n%3D39%0A&height=13&width=44) and confirm that ![](https://cdn.nlark.com/yuque/\_\_latex/60bfa0a75ef7b84aaf8815bd9bd7c630.svg#card=math&code=p%2839%29%3D1601&height=18&width=84)is prime.

\*\*Hint\*\*: ![](https://cdn.nlark.com/yuque/\_\_latex/2567e3c220d419b6b6ed1cb0dbdf544f.svg#card=math&code=p%28n%29%20%3D%20n%5E2%20%2B%20n%20%2B%2041%20%3D%20n%28n%2B1%29%20%2B%2041&height=20&width=233), 41 is prime.

But ![](https://cdn.nlark.com/yuque/\_\_latex/4381240dbb32401f01ba6c1064da109f.svg#card=math&code=p%2840%29%3D40%5E2%2B40%2B41%3D41%C2%B741&height=20&width=203), which is not prime.

So Claim1.1.3
is false since it’s not true that p(n) is prime \_for all \_nonnegative integers n.

\## We Learn
Point： this example highlights the point that, in general, you can’t check a claim about
an infinite set by checking a finite sample of its elements, no matter how large the
sample.

\## Homework

1\. You could write your proof as comments.
1\. Find out what n make p(n) is not prime, too.

\## New Concept

\### prime
A \_prime \_is an integer greater than 1 that is not divisible by any other integer
greater than 1.

For example, 2, 3, 5, 7, 11, are the first five primes.