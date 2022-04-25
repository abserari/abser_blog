\## Learn
Today we learn how to use Ordinary Induction to prove claim. It's important to know where could we use Ordinary Induction to prove, because  somebody even don't admit it.

\## Question
\*\*Theorem 5.1.2. \*\*\_For all \_![](https://cdn.nlark.com/yuque/\_\_latex/44688f1fa0e40a02531aa88a17b7b6b8.svg#card=math&code=n%20%5Cgeq%200&height=16&width=41) \_there exists a tiling of a ![](https://cdn.nlark.com/yuque/\_\_latex/f7309a008c14331e3a9c6b5bf5e7bf03.svg#card=math&code=2%5En%20%5Ctimes%202%5En&height=16&width=54)courtyard with Bill
in a central square.
\_

\_

![image.png](assert/1578232041653-1b6a80ed-ce74-481c-b00a-d6d473ec14a9.png)

![image.png](assert/1578232052180-38f5ec91-748d-4ffe-a1de-7122eb320b8f.png)

![image.png](assert/1578232257816-ea1aedbb-7525-44b6-9d83-ae574baa73ff.png)

First of all. You should try these layout on your paper and see how P(0) or P(1) like.

\## Solution
\*\*\_Proof. \_\*\*\_(doomed attempt)     \_The proof is by induction.

Let ![](https://cdn.nlark.com/yuque/\_\_latex/81ae00dae536d425ed9f277d678f9f3c.svg#card=math&code=P%28n%29&height=20&width=36) be the proposition
that there exists a tiling of a ![](https://cdn.nlark.com/yuque/\_\_latex/bf52a2786d8d4f4a23e003c865c0ea07.svg#card=math&code=2%5En%20%2A%202%5En&height=16&width=50)courtyard with Bill in the center.

\*\*Base case:     \*\*![](https://cdn.nlark.com/yuque/\_\_latex/dfde11e197c21790b1ae9c48352a3ddc.svg#card=math&code=P%280%29&height=20&width=33) is true because Bill fills the whole courtyard.

\*\*Inductive step:    \*\*

Assume that there is a tiling of a ![](https://cdn.nlark.com/yuque/\_\_latex/f7309a008c14331e3a9c6b5bf5e7bf03.svg#card=math&code=2%5En%20%5Ctimes%202%5En&height=16&width=54) courtyard with Bill in the
center for some ![](https://cdn.nlark.com/yuque/\_\_latex/44688f1fa0e40a02531aa88a17b7b6b8.svg#card=math&code=n%20%5Cgeq%200&height=16&width=41). We must prove that there is a way to tile a ![](https://cdn.nlark.com/yuque/\_\_latex/660644ffcff9269e53ee432d2029bb4c.svg#card=math&code=2%5E%7Bn%2B1%7D%20%5Ctimes%202%5E%7Bn%2B1%7D&height=19&width=85) courtyard with Bill in the center . . . . ■

Now we’re in trouble! The ability to tile a smaller courtyard with Bill in the center isn’t much help in tiling a larger courtyard with Bill in the center. We haven’t
figured out how to bridge the gap between ![](https://cdn.nlark.com/yuque/\_\_latex/81ae00dae536d425ed9f277d678f9f3c.svg#card=math&code=P%28n%29%20&height=20&width=36) and ![](https://cdn.nlark.com/yuque/\_\_latex/d9f259a973d4ed34fb181011e34da3b9.svg#card=math&code=P%28n%2B1%29&height=20&width=65).

\-\-\-

\*\*\_Proof.\_\*\*\_ \_\_(successful attempt)\_\_.     \_The proof is by induction.

     Let ![](https://cdn.nlark.com/yuque/\_\_latex/81ae00dae536d425ed9f277d678f9f3c.svg#card=math&code=P%28n%29&height=20&width=36) be the proposition
that for every location of Bill in a ![](https://cdn.nlark.com/yuque/\_\_latex/bf52a2786d8d4f4a23e003c865c0ea07.svg#card=math&code=2%5En%20%2A%202%5En&height=16&width=50) courtyard, there exists a tiling of the
remainder.

\*\*Base case:\*\*     ![](https://cdn.nlark.com/yuque/\_\_latex/dfde11e197c21790b1ae9c48352a3ddc.svg#card=math&code=P%280%29&height=20&width=33) is true because Bill fills the whole courtyard.

\*\*Inductive step:    \*\*

\*\* \*\*Assume that ![](https://cdn.nlark.com/yuque/\_\_latex/81ae00dae536d425ed9f277d678f9f3c.svg#card=math&code=P%28n%29&height=20&width=36) is true for some ![](https://cdn.nlark.com/yuque/\_\_latex/44688f1fa0e40a02531aa88a17b7b6b8.svg#card=math&code=n%20%5Cgeq%200&height=16&width=41); that is, for every location
of Bill in a![](https://cdn.nlark.com/yuque/\_\_latex/f7309a008c14331e3a9c6b5bf5e7bf03.svg#card=math&code=2%5En%20%5Ctimes%202%5En&height=16&width=54) courtyard, there exists a tiling of the remainder. Divide the ![](https://cdn.nlark.com/yuque/\_\_latex/660644ffcff9269e53ee432d2029bb4c.svg#card=math&code=2%5E%7Bn%2B1%7D%20%5Ctimes%202%5E%7Bn%2B1%7D&height=19&width=85)courtyard into four quadrants, each ![](https://cdn.nlark.com/yuque/\_\_latex/f7309a008c14331e3a9c6b5bf5e7bf03.svg#card=math&code=2%5En%20%5Ctimes%202%5En&height=16&width=54) .

One quadrant contains Bill (![](https://cdn.nlark.com/yuque/\_\_latex/9d5ed678fe57bcca610140957afab571.svg#card=math&code=B&height=16&width=12) in the diagram below).

Place a temporary Bill (![](https://cdn.nlark.com/yuque/\_\_latex/02129bb861061d1a052c592e2dc6b383.svg#card=math&code=X&height=16&width=14) in the diagram) in each of
the three central squares lying outside this quadrant as shown in Figure 5.4.





 ![image.png](assert/1578232968822-c8cc6220-bca8-43c4-bd2f-ee5c01f60b74.png)

Now we can tile each of the four quadrants by the induction assumption. Replacing the three temporary Bills with a single L-shaped tile completes the job.

     This
proves that ![](https://cdn.nlark.com/yuque/\_\_latex/81ae00dae536d425ed9f277d678f9f3c.svg#card=math&code=P%28n%29&height=20&width=36) implies ![](https://cdn.nlark.com/yuque/\_\_latex/d9f259a973d4ed34fb181011e34da3b9.svg#card=math&code=P%28n%2B1%29&height=20&width=65) for all ![](https://cdn.nlark.com/yuque/\_\_latex/44688f1fa0e40a02531aa88a17b7b6b8.svg#card=math&code=n%20%5Cgeq%200&height=16&width=41). Thus ![](https://cdn.nlark.com/yuque/\_\_latex/853cd1174954cc061b46ee1b4f4ff2b2.svg#card=math&code=P%28m%29&height=20&width=40) is true for all ![](https://cdn.nlark.com/yuque/\_\_latex/218c0ddfe94139e680432bd4bbccdd86.svg#card=math&code=m%20%5Cin%20%5Cmathbb%20%7BN%7D&height=16&width=47),
and the theorem follows as a special case where we put Bill in a central square. ■

\## Homework

1\. \*\*Theorem 5.1.1. \*\*\_For all ![](https://cdn.nlark.com/yuque/\_\_latex/d6c43e3e35916a79684ea6acb5587869.svg#card=math&code=n%20%5Cin%20%5Cmathbb%20%7BN%7D%20&height=16&width=42),\_

![](https://cdn.nlark.com/yuque/\_\_latex/6783be264d7f5239260b740f78fafa7e.svg#card=math&code=1%20%2B2%2B3%2B%C2%B7%C2%B7%C2%B7%2Bn%20%20%3D%20%5Cfrac%7Bn%28n%2B1%29%7D%7B2%7D&height=41&width=230)

Use These Step to try Ordinary Induction.

\-  ![](https://cdn.nlark.com/yuque/\_\_latex/dfde11e197c21790b1ae9c48352a3ddc.svg#card=math&code=P%280%29&height=20&width=33) is true.

\-  For all ![](https://cdn.nlark.com/yuque/\_\_latex/94e44821f2bd0d0c8181e3de92a4c9ca.svg#card=math&code=%5Cforall%20n%20%5Cin%20%5Cmathbb%20%7BN%7D.%20P%28n%29%20%5Cimplies%20P%28n%2B1%29&height=20&width=206).

2\. Use the Ordinary Induction to prove \*\*the \*\*\*\*False Theorem.\*\* \_All horses are the same color. \_And figure out when can I use it. You would find its solution in next article.







\## Concept & Attachment & Link

\### Ordinary Induction Rule
\*\*Rule. Induction Rule\*\*

![](https://cdn.nlark.com/yuque/\_\_latex/ad9fc3b54e84284415bf147bc176a7ed.svg#card=math&code=%5Cfrac%7BP%280%29%2C%20%5Cforall%20n%20%5Cin%20%5Cmathbb%20%7BN%7D.%20P%28n%29%20%5Cimplies%20P%28n%2B1%29%7D%7B%5Cforall%20m%20%5Cin%20%5Cmathbb%7BN%7D.%20P%28m%29%7D&height=47&width=254)

\#### Steps
![image.png](assert/1578231951399-4693d1a1-e53e-4a11-8436-7c29173c056b.png)