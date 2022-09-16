## Role of microservice framework

## HTTP Channel and GRPC Channel 

before we begin, let's explore the differences between HTTP and RPC. The reason why gRPC is discussed here is that no one uses common RPC. 

HTTP is a common communication method used for business coding, and its popularity is needless to say. As a Web programmer, HTTP Server programming is its core skill. RPC is also indispensable in microservices. 

Can programmers who are familiar with one of the encoding quickly get started with the business coding of another transmission method? 

After all, the business logic is consistent, which seems to be only different in network transmission. 

Colleagues who have done this know that the differences in business coding are not small. Although the differences are constrained to the transport layer through the abstraction layer during design, there is no framework to block the differences in implementation. Therefore, coding students need to go deep into it and handle it by themselves. 

For example, you need to learn more about envoy and proto files, how to encode requests and return values, and how to use specific protobuf to parse message packets in your business. 

The differences can be shielded at the abstraction level. We still need to write detailed differences in implementation. These are the operations that some programmers can replace with frameworks. 

## Top programmers and beginners, beginners, and idiots 

the role of the framework is to make correct coding behavior without thinking.

There are enough ecological libraries for the current language to help compile various coding types. When lacking, some ecosystems can be transplanted by referring to other languages to reduce the workload. However, not every programmer can do such behavior at any time. 

Google is a friend. Business Code they often get into trouble because of something they don't know so that no matter how their skills or intelligence are, they can't solve the problem.

In the business, some coding work will be compared to moving bricks. Programmers are described as manual work to move code from here to there. However, when someone participates in the process, the error probability will also be related to the state of a person.

Through Murphy's law, we can recognize that errors must occur in these processes. How do reduce personal decisions to ensure high quality and high output of assembly line coding manpower?

If you want to treat yourself as an idiot coder and leave the error-prone parts to tools, the framework will generate great benefits. 


> Nothing is built on Stone; Everything is built on sand, but we must build sand as stone.
>                                 -Jorge Louis Borges 


the following are some examples: 

- code review: 

architects not only need to formulate process standards, but also need to supervise the implementation. Code review is the major part of the workload. However, there are thousands of people, and code writers have their ideas. There may even be a design-based cohesion function, which is scattered at all levels in implementation, and the review process is even more inefficient. 

Constraints can be carried out through the framework, which is also the wisdom of software engineering. By increasing restrictions, standards can be formulated to provide efficiency.

- Best Practices: 

business code usually uses simple addition, deletion, modification, query data, and target resources. At the same time, there are some common functional requirements, such as JWT. 

The framework can shield these differences. For example, JWT only has different types of tokens carried by HTTP, and ORM shields the actual data storage software interfaces in the background for addition, deletion, query, modification, and modification. 

This is another wisdom of computer science, solving problems by adding a middle layer. Framework users can switch to different implementations without thinking.

If the best practices provided by the framework cannot meet the requirements, it is time for the document to show its role. Technical personnel-oriented documentation is useful only when problems occur.

## The dilemma of microservices caused by abstract hierarchy and abstract leakage 

> Google software engineering mentions three key differences between programming and software engineering: **time**, **scope**, and **trade-offs**. 

However, the idea of the framework is beautiful enough, but the realization, in reality, is full of trade-offs and the pursuit of perfection. 

Even if the strange requirements of a specific time limit on the business side are excluded. The design cannot be accomplished overnight and a perfect abstract design can be completed.

Abstract leakage refers to the abstraction of implementation details that should be hidden during software development, which inevitably exposes the underlying details and limitations.

Not to mention that a complete system has more than one or two levels. How to make reasonable abstraction and promote it as a standard is a long-term practice and change in many microservice frameworks and coding fields. 

Abstraction means unification, while behind the abstraction level, it usually means the actual services with different characteristics. Do you use the union or intersection of these services for abstraction? Whether to consider extended compatibility or functionality.

> For more information, see another article. [Mongo Doc access design](), is practical experience. 

> Also The API of Dapr. Many Interfaces of Golang (IO, SQL, and Net) can see abstract practical practices.

For example, designers will struggle with whether to provide a certain function to the outside, so they have done a lot of work to provide it. However, in terms of function usage, it may be a pseudo requirement or a simple shielding. However, in actual scenarios, it is necessary to have a lower layer of functions, and the abstraction level is still broken down. 

At this point, everyone understands that it falls into specific scenarios and analyzes specific problems. Therefore, a microservice framework that has passed the postgraduate entrance examination for a long time must have solved many problems in the target scenario. 

> This reminds me that programmers always pursue new technologies. New microservice frameworks usually have high expectations, hoping that they can completely solve the problems encountered in practice that the old frameworks cannot solve. Finally, expectations often fail. Why can we expect a new untested framework to meet the needs of the technical framework that has been designed and modified many times in practice in specific fields?

Back to our question at the beginning, is there a framework that unifies the HTTP Channel and gRPC Channel, and only needs to write the handler's internal code without paying attention to other work?

 In the modern framework, Dapr did accomplish this. 

What about the abstract cost? 

The field type in the Protobuf is lost, and it is considered a payload. The handler has different self-processing types, which is consistent with HTTP abstraction. 

Is it true that such an abstraction layer has just come up with now? If you have a deeper understanding of computer science, you will find that some past ideas shine brilliantly in new scenarios. 

Time is the most significant variable (for example, previous programmers needed to deduct bytes. Now, do you still need to care about insufficient memory for personal PC and cloud coding?). 

## Summary
The above describes the problems related to the microservice framework considered in the experience. Just raising questions is a hooligan. My opinions and suggestions are mentioned a lot in the article. 

To make a summary, it is: 

providing a fool-like automated microservice framework enables programmers to make fewer decisions and make better decisions. 

Only by using the time saved to innovate business links and business models, and not being involved in non-creative work such as environment building, can workers feel the value of innovation and self-achievement.