## Open Source History of Dapr project

At the beginning of this open-source column, I wrote this article to describe the birth and development of open-source projects, express my views on the open-source community and ecology, and share it with you. 

Some opinions are out of personal perspective, and there are inevitably some mistakes and mistakes. Please forgive me and correct me. 

## Background
before the birth of the Dapr project, I would like to explain the current situation of the Dapr project for readers to understand the project itself. 

Dapr is a CNCF community-driven open source project with Microsoft as its contributor. Microsoft, according to the author, the first author should be Bai Haishi and Yaron (he is also the author of the Dapr Learning Manual, who proposed OAM and Dapr). 

The work objectives of the Dapr project are described as follows: 

Dapr is a portable, event-driven runtime that enables any developer to quickly build flexible, stateless, and stateful applications that can run on cloud platforms or edge computing. 
Some community students think Dapr is the next form of the service mesh, and some people also call this runtime software of the new era mecha (mecha), mecha provides distributed capabilities for business applications, just like the operator wearing a mecha, to do what he could not have done.

The following figure shows Bilgin Ibryam. Multi-Runtime Microservices Architecture 


![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1658032639778/CRnDlZMU-.png align="left")

therefore, the Dapr project is open-source software that provides distributed capabilities for modern distributed applications. Currently, it is open-source on GitHub and has gained 18.6K stars, which is very popular. 

## Birth 
Tracing back to open source on GitHub, the first submission was on June 21, 2019, 
the birth of open-source projects is usually accompanied by the discovery of practical problems. 

Before saying the problems solved by the Dapr project, there is another project that has to be mentioned, Microsoft's OAM(Open Application Model). 

The two projects have been known to the public for 19 years. I remember that the co-sponsor of OAM is Ali. At that time, Kubernetes was very popular, and the problems on the computing scheduling platform were Kubernetes solved by Golang's killer application. 

However, using Kubernetes puts forward more and higher requirements for Developers, especially its new concept, which covers different APIs and unique working methods. 

How to solve this problem? 

Any problem in the field of computer science can be solved by adding an indirect intermediate layer.

It is believed that smart readers, based on their current knowledge, have already thought that if a new design language can be used as the middle layer to block the similarities and differences of infrastructure developers do not need to pay attention to and focus on business coding, can it be solved? 

In this way, OAM is naturally ready to come out. (If you are concerned about OAM, you can learn about the implementation of this project standard in Alibaba, namely Kubevela project, this project has great potential)

Dapr came up with an idea when Bai Haishi and his Israeli colleagues discussed OAM Yaron Schneider. It designed a new programming mode to encapsulate the common functions of the distributed system into Sidecar(Kubernetes concept, description, and business application in the same Pod container) and expose them to developers through HTTP or gRPC (two common transmission modes, which are compatible with most applications). 

The idea is named Distributed Application Runtime, or Dapr for short. [This paragraph is taken from an interview with Bai Haishi, the founder of OAM and DAPR: a simple idea of a 33-year senior programmer -Zhang Shanyou]] 

Dapr provides several new features to help solve the problems: 

the first is to provide services in the form of Sidecar. In the container orchestration platform, Sidecar provides services in a non-intrusive way. 

For example, Envoy Sidecar acts as a proxy for routing and forwarding. It is independent of major applications and therefore has cross-language features. Users can reuse logic without binding to a programming language, which is especially useful in the microservice era. 

The second is the concept of Building Block, which allows Dapr users to customize different Building blocks, instead of forcing users to use distributed functions provided by Dapr for all functions.

## Open source 

After talking for so long, I finally talked about the open-source features of the Dapr project. 
The benefits of open source can be seen in the summary of my other article. This article will not go into detail, but mainly explore the reasons why Dapr needs to open source and provide material examples for everyone to understand the open source operation mode. 

Dapr can be analyzed from the positioning of its general distributed runtime software, and the standard is its core! 

Standards cannot be achieved by one person or a company. It is necessary to strengthen Dapr's influence and promote its designation of standards that are uniformly recognized by everyone. It is the only choice to establish a community of common contributions through open source.

It is not only a matter of standards. Dapr, as an application in the new era, naturally has many new ideas, which need to be verified. A large number of engineers need to be invested in the verification of the programming mode. 

This part of manpower expenditure and verification cost is extremely large. The continuous development of the project can only be supported by the rapid discussion of design, implementation, and community verification in the form of Community co-construction. 

Therefore, human resources are also considered in most open-source projects. 

Finally, reach users. 

When Dapr is a user-oriented project, there are developers who are more enthusiastic than open-source communities. Open-source is the best choice to make Dapr's development closer to users and the wide application of cloud developers that it wants to achieve. 

We recommend two projects to observe the popularity and activity distribution of open-source projects ( Star-History and OSSInsight ), which are Bytebase and PingCap open-source tools. One picture wins thousands of words, and two pictures are attached to show its function. 

Figure 1: Star harvest trend of open source Dapr project

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1658032918444/FsLL7iu_d.png align="left")

## Development
Since the Dapr project is to serve developers, it is natural to investigate the main functions that developers use in the programming and provide them to users as different building blocks. 

Currently, the capabilities it provides include state management, service development, message sending and receiving, publishing and subscription, security information management, Actor mode (originated from the Orleans project in Microsoft's dotnet ecosystem), etc. In the initial form of state management development, concurrent control, version management, and other capabilities are also added. 

Now, building blocks such as distributed locks and workflows are gradually added. These new functions and new building blocks are all built by community users' needs.

It can be seen from this that Dapr's open source strategy has achieved remarkable results. 

The emergence of Dapr also coincides with the wave of XaaS. It reduces the occupation of the edge environment (more than 50 M binary, only 4 M memory is needed during operation), provides edge devices and applications with low capability, flexibly switches between edge environment and cloud, and supports multiple operating environments, which are its excellent sources of competitiveness. 

The development evaluation of an open source project must pay attention to its related ecology. Dapr, as a similar infrastructure project, will discuss two ecosystems. 

One is the ecosystem that supports the Dapr project operation. That is, driven by various Building blocks, their ecology determines which infrastructure Dapr users can apply.

Take PubSub as an example. Common message queue drivers such as Kafka, Redis, NatsStreaming, and Pulsar provide the runtime capability in the publish/subscribe mode. 

The ecosystem in this area is rich and colorful. The core problem is that drivers are contributed to the community by themselves. The code quality and the functions provided during application runtime are uneven. It can be seen that the idea of standardization cannot be easily achieved in the real world. 

One is the Dapr-based project built on it. This ecology can also be reflected in the cases where most companies use Dapr. 

The main users of Dapr started from the founders Microsoft and Ali, and now companies such as Qingyun have participated in the co-construction and produced many projects and practical cases. 

Taking Microsoft as an example, users who serve it can easily and painlessly switch the underlying dependencies on the cloud (for example, switching message queues from Rabbitmq to kafka). 
For example, Alibaba provides a large number of distributed capabilities for function applications in its functional computing platform. 
For example, Ant Financial has developed a layotto project based on its excellent ServiceMesh development experience, IT has implemented the distributed runtime concept that conforms to its own IT infrastructure (and is open-source).
For example, Qingyun's Openfunction is also built using Dapr in the function computing platform.

Even Microsoft has launched a commercial product container app based on Dapr, which allows users to write function-level services. The infrastructure is provided by context. 
Dapr provides these services with the choice of only focusing on business code logic. 

The developer ecosystem of open-source projects is an important criterion. The number of issues created, the speed of response, the richness of proposal submission, the degree of the active contributor, the entry and loss of new contributors and core contributors, and other indicators are all important bases for us to evaluate the developer ecosystem. This section can praise ossinsight project, which provides you with query services through the website and provides us with powerful data for evaluating open-source projects. 

Figure 2: analysis of open source activities of the Dapr project

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1658033060286/sUkAuPA7c.png align="left")

## Trend 
competition trend of domain software: Hot open-source projects actually symbolize the main competition fields in the current industry. PaaS, which took Kubernetes as the core in the past few years, IaaS, which was recently represented by Infra as Code, DevOps and Security, and SaaS and FaaS, which will further compete fiercely in the future, provide better value-added services. Different fields have their own solutions. We can see how to provide more valuable services from the open-source ecosystem. 

The development trend of programmers: modern developers are generally faced with anxiety problems. As programmers, some of our work contents are boring, but with the passion for programming and the pursuit of a career, we can develop various innovative achievements in our daily work, which may not only achieve ourselves but also benefit the world. At the industry level and even at the national level, open source is embraced. Under such a development trend, open source will integrate young programmers as one of the popular cultures. 
My personal advice is to understand the open source as soon as possible, embrace him, and become a compound talent. The next step for programmers is to explore the open source field. 

And this article has roughly described the context of the Dapr project. Only from the project ecology of Dapr, we can see the fierce competition in the development of cloud computing. We don't know how many projects are floating and disappearing in the tide, or they never appear in our eyes after a wave of waves. I hope readers can have a deeper understanding and ideas about the software life cycle, especially open-source software.
