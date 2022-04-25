\## 框架

\### Codec
负责处理编解码，处理不同的网络传输协议或者文本

\- Marshall：2[]byte
\- UnMarshall：2protocol

\### Server
监听&调用，同时可以作为注册中心。

\- Register：注册服务到 Server 中
\- ServeConn：服务端口链接，处理并进行调用
 \- ReadRequest：use codec read request
 \- SendResponse: use codec write reply
\- Listen：监听不同协议请求

\### Client
客户端发起调用，接收返回数据

\- Call：远端调用
\- Go：异步远端调用

\### Context&EndPoint
中间件等，超时 TimeOut ，认证 Auth ，心跳 等实现

\## 使用

\### Service&Call
服务实例