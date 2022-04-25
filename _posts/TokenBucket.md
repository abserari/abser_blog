--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\## Overview
![](https://cdn.nlark.com/yuque/0/2018/jpeg/176280/1545212178266-d31f3e97-98a4-4715-b6b9-80ee9b9a16c6.jpeg#align=left&display=inline&height=528&originHeight=528&originWidth=836&status=done&style=none&width=691)

\- 每秒会有 \`Limit\`个令牌放入桶中，或者说，每过 \`1/Limit\` 秒桶中增加一个令牌

\- 桶中最多存放 \`burst\` 个令牌，如果桶满了，新放入的令牌会被丢弃

\- 当一个 \`n\` 单元的数据包到达时，消耗 \`n\` 个令牌，然后发送该数据包

\- 如果桶中可用令牌小于 \`n\`，则该数据包将被缓存或丢弃

\## 令牌桶算法
令牌桶算法是网络流量整形（Traffic Shaping）和速率限制（Rate Limiting）中最常使用的一种算法。典型情况下，令牌桶算法用来控制发送到网络上的数据的数目，并允许突发数据的发送。

\## RateLimiter 中的令牌桶算法

\### 简介
该包基于令牌桶算法(Token Bucket)来完成限流,非常易于使用.RateLimiter经常用于限制对一些物理资源或者逻辑资源的访问速率.它支持三种方式,：

·\`AllowN()\`是如果拿不到立刻返回。

·\`WaitN() \`是暂时排队，等到足够的令牌再出发，中途可能因为context的cancel而cancel，同时归还占位。

·\`ReserveN()\`是直接出发，但是前人挖坑后人填，下一次请求将为此付出代价，一直等到令牌亏空补上，并且桶中有足够本次请求使用的令牌为止。

\### 工作实例
假设正在工作的一个\`RateLimiter\`

\#### allow和wait
对一个每秒产生一个令牌的\`RateLimiter\`,每有一个没有使用令牌的一秒,我们就将\`tokens\`加 1 ,如果\`RateLimiter\`在 10 秒都没有使用,则\`tokens\`变成10.0.这个时候,一个请求到来并请求三个令牌,我们将从\`RateLimiter\`中的令牌为其服务,\`tokens\`变为7.0.这个请求之后立马又有一个请求到来并请求10个令牌,我们将从\`RateLimiter\`剩余的 7 个令牌给这个请求,剩下还需要三个令牌,我们将从\`RateLimiter\`新产生的令牌中获取.我们已经知道,\`RateLimiter\`每秒新产生 1 个令牌,就是说上面这个请求还需要的 3 个令牌就要求其等待 3 秒.

\#### reserve
想象一个\`RateLimiter\`每秒产生一个令牌,现在完全没有使用(处于初始状态),如果一个昂贵的请求要求 100 个令牌.如果我们选择让这个请求等待100秒再允许其执行,这显然很荒谬.我们为什么什么也不做而只是傻傻的等待100秒,一个更好的做法是允许这个请求立即执行(和\`allow\`没有区别),然后将随后到来的请求推迟到正确的时间点.这种策略,我们允许这个昂贵的任务立即执行,并将随后到来的请求推迟100秒.这种策略就是让任务的执行和等待同时进行.

\#### 关于 timeToAct
一个重要的结论:\`RateLimiter\`不会记最后一个请求,而是即下一个请求允许执行的时间.这也可以很直白的告诉我们到达下一个调度时间点的时间间隔.然后定一个一段时间未使用的\`Ratelimiter\`也很简单:下一个调度时间点已经过去,这个时间点和现在时间的差就是\`Ratelimiter\`多久没有被使用,我们会将这一段时间翻译成\`tokens\`.所有,如果每秒钟产生一个令牌(\`Limit==1\`),并且正好每秒来一个请求,那么\`tokens\`就不会增长.

\#### burst
\`RateLimiter\`有一个桶容量，当请求大于这个桶容量时，直接丢弃。

\### 链接

\#### ·\*\* \*\*[Golang实现RateLimiter源码导航](https://github.com/golang/time/blob/master/rate/rate.go)

\#### · [RateLimiter语雀阅读](https://www.yuque.com/hx8m0t/go-code/ko1zq4)
ratelimit