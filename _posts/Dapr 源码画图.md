\# Actor Enhanced
[actors](https://github.com/dapr/docs/blob/334ff4c626e9a1921dbf22260da3f11a9d44f007/concepts/actors/README.md): is an enhanced model when you need

\- Your problem space involves a large number (thousands or more) of small, independent, and isolated units of state and logic.
\- You want to work with single-threaded objects that do not require significant interaction from external components, including querying state across a set of actors.
\- Your actor instances won't block callers with unpredictable delays by issuing I/O operations.

It builds on dapr components with statestore to store the state and appchannel what is using to communicate. and user code register to compute the incoming data.

![dapr-actors.svg](assert/1596863824768-007e2604-eafe-423b-872e-428147e28914.svg)

\-\-\-

\### Reference

[research/project/orleans-virtual-actors](https://www.microsoft.com/en-us/research/project/orleans-virtual-actors/)

\# Signal
![dapr-signal.svg](https://cdn.nlark.com/yuque/0/2020/svg/176280/1596864217207-529bf7d6-915b-4db9-a01a-0f70aa3b9a8e.svg#align=left&display=inline&height=256&margin=%5Bobject%20Object%5D&name=dapr-signal.svg&originHeight=256&originWidth=191&size=10469&status=done&style=none&width=191)

\# Components

\## Components Overview
![image.png](assert/1593958358817-024c4413-cac4-4211-82f7-488fa26d96e8.png)

\### Components-Realize example by pubsub
![dapr-compoents-pubsub.svg](https://cdn.nlark.com/yuque/0/2020/svg/176280/1596864179677-aaa5d5d5-34dc-4158-bf86-66d2955ccf3b.svg#align=left&display=inline&height=409&margin=%5Bobject%20Object%5D&name=dapr-compoents-pubsub.svg&originHeight=409&originWidth=490&size=16812&status=done&style=none&width=490)

\# fswatcher
![dapr-watch.svg](https://cdn.nlark.com/yuque/0/2020/svg/176280/1596864262799-c3d05a5b-094d-4372-b2bb-baf8afa50701.svg#align=left&display=inline&height=194&margin=%5Bobject%20Object%5D&name=dapr-watch.svg&originHeight=194&originWidth=371&size=13908&status=done&style=none&width=371)