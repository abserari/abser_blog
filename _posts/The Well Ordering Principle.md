--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\## Question
Prove that

\*\*For any positive integers m and n, the fraction m/n can be written in lowest terms, that is, in the form m' /n' where m' and n' are positive integers with no common prime factors.\*\*

You could read the Concept first:

Every \_nonempty\_\_ \_set of \_nonnegative\_\_ \_\_integers\_\_ \_has a \_smallest \_element.

\## Solution
\*\*Proof:\*\*

Suppose to the contrary that there are positive integers m and n such that the
fraction m/n cannot be written in lowest terms.

Now let ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12) be the set of positive
integers that are \*\*numerators \*\*of such fractions. \*\*why use numerators?\*\*



Then  ![](https://cdn.nlark.com/yuque/\_\_latex/58a6f58a444b621585b4f6647a855179.svg#card=math&code=m%20%5Cin%20C&height=16&width=48), so ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12) is nonempty. By
Well Ordering Principle, there must be a smallest integer ![](https://cdn.nlark.com/yuque/\_\_latex/7b911220c34f65b1a432087e0fa3cb80.svg#card=math&code=m\_0%20%5Cin%20C%0A&height=18&width=55). So by definition of ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12) , there is an
integer ![](https://cdn.nlark.com/yuque/\_\_latex/32a5cf969976c0b225fd33c3dd0d2931.svg#card=math&code=n\_0%20%3E0&height=18&width=48) such that

the fraction ![](https://cdn.nlark.com/yuque/\_\_latex/d976f82c405e3138601d7a698a8d884f.svg#card=math&code=%5Cfrac%7Bm\_0%7D%7Bn\_0%7D&height=36&width=28) cannot be written in lowest terms.

This means that ![](https://cdn.nlark.com/yuque/\_\_latex/fed1e4775925bd3f7af0c5d8fc47e4e6.svg#card=math&code=m\_0%0A&height=14&width=22) and ![](https://cdn.nlark.com/yuque/\_\_latex/9f29abde1bb7db037da9d05ea02015db.svg#card=math&code=n\_0&height=14&width=17) must have a common prime factor, we call it p and must have p > 1. But

![](https://cdn.nlark.com/yuque/\_\_latex/a8fd61b4f902716e923daaf7a957d9c6.svg#card=math&code=%5Cfrac%7Bm\_0%2Fp%7D%7Bn\_0%2Fp%7D%20%3D%20%5Cfrac%7Bm\_0%7D%7Bn\_0%7D&height=47&width=96)

so any way of expressing the left-hand fraction in lowest terms would also work for
![](https://cdn.nlark.com/yuque/\_\_latex/4c895ca26617200e3a379594e0fad299.svg#card=math&code=m\_0%2Fn\_0&height=20&width=48), which implies

the fraction ![](https://cdn.nlark.com/yuque/\_\_latex/d476b82d376e1a0816c80b387c118b19.svg#card=math&code=%5Cfrac%7Bm\_0%2Fp%7D%7Bn\_0%2Fp%7D&height=47&width=45) cannot be in written in lowest terms either.

So by definition of ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12), the numerator m0=p is in ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12). But ![](https://cdn.nlark.com/yuque/\_\_latex/5780aa54bfa432ede66bec95d1284bb8.svg#card=math&code=m\_0%2Fp%20%3C%20m\_0&height=20&width=84), which
contradicts the fact that ![](https://cdn.nlark.com/yuque/\_\_latex/fed1e4775925bd3f7af0c5d8fc47e4e6.svg#card=math&code=m\_0%0A&height=14&width=22) is the smallest element of ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12).

Since the assumption that ![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12) is \*\*nonempty\*\* leads to a contradiction, it follows that
![](https://cdn.nlark.com/yuque/\_\_latex/0d61f8370cad1d412f80b84d143e1257.svg#card=math&code=C%0A&height=16&width=12) must be empty. That is, that there are no numerators of fractions that can’t be
written in lowest terms, and hence there are no such fractions at all.                                                                                                                        ■

\## Learn & Homework

1\. Learn about \_Well Ordering \_concept.
1\. We prove by using a well-ordered set in the numerator, can we use the denominator?
1\. Please summarize the template of good order proof, listed like 1,2,3···
1\. Are there any other sets that are also well-ordered. Like 0/1、1/2、2/3 ··· n-1/n. If they are well-ordered, why?
1\. For good order, search more information, ask more questions.

\## Concept

\### The Well Ordering Principle
![image.png](assert/1577180824313-7102478f-8c42-4567-bb79-e9acae126ec3.png)

This statement is known as The \_Well Ordering Principle (WOP)\_.

Do you believe
it? Seems sort of obvious, right?

But notice how tight it is: it requires a \*\*\_nonempty\_\*\*
set—it’s false for the empty set which has \_no \_smallest element because it has no
elements at all.

 And it requires a set of \*\*\_nonnegative\_\*\*\_ \_integers—it’s false for the
set of \_negative \_integers and also false for some sets of nonnegative \_rationals\_—for
example, the set of positive rationals.

So, the Well Ordering Principle captures
something special about the nonnegative integers.