## TokenBucket


## Overview
![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657442131915/dUeLDBuYM.png align="left")



- available per second Limit put tokens into the bucket, or, every time 1/Limit add a token to the second bucket 
- maximum storage in buckets burst tokens. If the bucket is full, the new token will be discarded. 
- when an N is consumed when the data packet of the unit arrives N tokens, and then send the packet 
- if the available token in the bucket is less than N, the packet will be cached or discarded 

## token bucket algorithm 

the token bucket algorithm is the most commonly used algorithm in network Traffic Shaping (Traffic Shaping) and Rate Limiting (Rate Limiting). 

Typically, the token bucket algorithm is used to control the number of data sent to the network and allow the sending of burst data. 

### overview 

this package is based on the Token Bucket algorithm (Token Bucket) to implement throttling, which is very easy to use. RateLimiter is often used to limit the access rate to some physical or logical resources. It supports three methods, 

- AllowN() If you can't get it, return it immediately.
- WaitN() It is temporarily lined up. When the token is sufficient, it may be returned to the position because of the Cancel of Context.
- ReserveN() Started directly, but the predecessors dug the pit and filled it. The next request will pay the price for this, and wait until the tokens will make up for the air. There is enough token in the barrel.

### Working instance 
assume that one is working RateLimiter 

#### allow and wait 
For a Ratelimiter that generates a token per second, every second without a token, we will add a token 1.

 If the Ratelimiter does not use it in 10 seconds, then tokens become 10.0. At this time, a request arrives and requests three tokens, we will serve it from the token in Ratelimiter, tokens to 7.0. After this request, another request comes and requests 10 tokens.

 We will from the remaining 7 token cards from RatelimiterFor this request, there are three tokens left, we will get them from the new token produced by Ratelimiter. 

We already know that the Ratelimiter produces 1 new token per second, which means that the above request still requires the three commands required for above request. The card requires it to wait for 3 seconds.

#### reserve
Imagine a Ratelimiter generated a token per second, and now it is not used (in the initial state). If an expensive request requires 100 token cards. If we choose to let this request wait for 100 seconds before allowing it to execute, this is obviously ridiculous. 

Why do we do nothing but just wait for 100 seconds? A better approach is to allow this request to execute immediately (no different from all), and then postpone the subsequent request to the right time point. 

We allow this expensive task to perform immediately and delay the subsequent request for 100 seconds. This strategy is to let the task execute and wait at the same time.

#### About timetoact
An important conclusion: Ratelimit does not remember the last request, but the next request allows the time to execute. This can also tell us very straightforwardly that the time interval of reaching the next scheduling time point. 

The Ratelimiter is also very simple: the next scheduling time has passed. The difference between this time and the current time is how long the Ratelimiter has not been used. We will translate this time into tokens.Limit == 1), and just one request per second, then tokens will not grow.

#### burst
Ratelimiter has a barrel capacity that is directly discarded when the request is greater than the capacity of this barrel.

https://github.com/golang/time/blob/master/rate/rate.go

