项目地址：[https://github.com/yhyddr/caddy-grpc](https://github.com/yhyddr/caddy-grpc)

\-\-\-

\## 前言
上一次我们学习了如何在 Caddy 中扩展自己想要的插件。博客中只提供了大致框架。这一次，我们来根据具体插件 \`caddy-grpc\` 学习。

选取它的原因是，它本身是一个独立的应用，这里把它做成了一个 Caddy 的插件。或许你有进一步理解到 Caddy 的良好设计。

\## 插件作用
该插件的目的与[Improbable-eng/grpc-web/go/grpcwebproxy](https://github.com/improbable-eng/grpc-web/tree/master/go/grpcwebproxy)目的相同，但作为 Caddy 中间件插件而不是独立的Go应用程序。

而这个项目的作用又是什么呢？

\> 这是一个小型反向代理，可以使用gRPC-Web协议支持现有的gRPC服务器并公开其功能，允许从浏览器中使用gRPC服务。
> 特征：
\> \- 结构化记录（就是 log 啦）代理请求到stdout（标准输出）
\> \- 可调试的 HTTP 端口（默认端口\`8080\`）
\> \- Prometheus监视代理请求（\`/metrics\`在调试端点上）
\> \- Request（\`/debug/requests\`）和连接跟踪端点（\`/debug/events\`）
\> \- TLS 1.2服务（默认端口\`8443\`）：
> \- 具有启用客户端证书验证的选项
\> \- 安全（纯文本）和TLS gRPC后端连接：
\> \- 使用可自定义的CA证书进行连接

其实意思就是，把这一个反向代理做到了 caddy 服务器的中间件中。

\### 使用
在你需要的时候，可以通过
\`\`\`
example.com
grpc localhost:9090
\`\`\`
第一行example.com是要服务的站点的主机名/地址。 第二行是一个名为grpc的指令，其中可以指定后端gRPC服务端点地址（即示例中的localhost：9090）。 （注意：以上配置默认为TLS 1.2到后端gRPC服务）

\### Caddyfile 语法
\`\`\`go
grpc backend\_addr {
 backend\_is\_insecure
 backend\_tls\_noverify
 backend\_tls\_ca\_files path\_to\_ca\_file1 path\_to\_ca\_file2
}
\`\`\`

\#### backend\_is\_insecure
默认情况下，代理将使用TLS连接到后端，但是如果后端以明文形式提供服务，则需要添加此选项

\#### backend\_tls\_noverify
默认情况下，要验证后端的TLS。如果不要验证，则需要添加此选项

\#### backend\_tls\_ca\_files
用于验证后端证书的PEM证书链路径（以逗号分隔）。 如果为空，将使用 host 主机CA链。

\## 源码

\### 目录结构
\`\`\`bash
caddy-grpc
├── LICENSE
├── README.md
├── proxy // 代理 grpc proxy 的功能实现
│   ├── DOC.md
│   ├── LICENSE.txt
│   ├── README.md
│   ├── codec.go
│   ├── director.go
│   ├── doc.go
│   └── handler.go
├── server.go // Handle 逻辑文件
└── setup.go // 安装文件
\`\`\`

\## Setup.go
按照我们上次进行的 插件编写的顺序来看，如果不记得，请看：[如何为 caddy 添加插件扩展](https://www.yuque.com/abser/process/brmghw)

首先看 安装的 setup.go 文件

\#### init func
\`\`\`go
func init() {
 caddy.RegisterPlugin("grpc", caddy.Plugin{
 ServerType: "http",
 Action: setup,
 })
}
\`\`\`
可以知道，该插件 注册的 是 http 服务器，名字叫 grpc

\#### setup func
然后我们看到最重要的 setup 函数，刚才提到的使用方法中，负责分析 caddyfile 中的选项的正是它。它也会将分析到的 directive 交由 Caddy 的 controller 来配置自己这个插件
\`\`\`go
// setup configures a new server middleware instance.
func setup(c \*caddy.Controller) error {
 for c.Next() {
 var s server

 if !c.Args(&s.backendAddr) { //loads next argument into backendAddr and fail if none specified
 return c.ArgErr()
 }

 tlsConfig := &tls.Config{}
 tlsConfig.MinVersion = tls.VersionTLS12

 s.backendTLS = tlsConfig
 s.backendIsInsecure = false

 //check for more settings in Caddyfile
 for c.NextBlock() {
 switch c.Val() {
 case "backend\_is\_insecure":
 s.backendIsInsecure = true
 case "backend\_tls\_noverify":
 s.backendTLS = buildBackendTLSNoVerify()
 case "backend\_tls\_ca\_files":
 t, err := buildBackendTLSFromCAFiles(c.RemainingArgs())
 if err != nil {
 return err
 }
 s.backendTLS = t
 default:
 return c.Errf("unknown property '%s'", c.Val())
 }
 }

 httpserver.GetConfig(c).AddMiddleware(func(next httpserver.Handler) httpserver.Handler {
 s.next = next
 return s
 })

 }

 return nil
}
\`\`\`

1\. 我们注意到 依旧是 c.Next() 起手，用来读取配置文件，实际上这里，它读取了 grpc 这个 token 并进行下一步

2\. 然后我们看到，紧跟着 grpc 读取的是 监听地址。
\`\`\`go
if !c.Args(&s.backendAddr) { //loads next argument into backendAddr and fail if none specified
 return c.ArgErr()
 }
\`\`\`
这里正好对应 在 caddyfile 中的配置 \`grpc localhost:9090\`

 1\. 注意 c.Next(), c.Args(), c.NextBlock(),  都是读取 caddyfile 中的配置的函数，在caddy 中我们称为 token

3\. 另外是注意到 tls 的配置，前面有提到，该服务是开启 tls 1.2 的服务的
\`\`\`go
 tlsConfig := &tls.Config{}
 tlsConfig.MinVersion = tls.VersionTLS12

 s.backendTLS = tlsConfig
 s.backendIsInsecure = false
\`\`\`

4\. 然后是上面所说的 caddyfile 语法中的配置读取
\`\`\`go
//check for more settings in Caddyfile
 for c.NextBlock() {
 switch c.Val() {
 case "backend\_is\_insecure":
 s.backendIsInsecure = true
 case "backend\_tls\_noverify":
 s.backendTLS = buildBackendTLSNoVerify()
 case "backend\_tls\_ca\_files":
 t, err := buildBackendTLSFromCAFiles(c.RemainingArgs())
 if err != nil {
 return err
 }
 s.backendTLS = t
 default:
 return c.Errf("unknown property '%s'", c.Val())
 }
 }
\`\`\`
可以看到是通过 \`c.NextBlock()\` 来进行每一个新 token 的分析，使用 c.Val() 读取之后进行不同的配置。

5\. 最后，别忘了我们要把它加入 整个 caddy 的中间件中去
\`\`\`go
httpserver.GetConfig(c).AddMiddleware(func(next httpserver.Handler) httpserver.Handler {
 s.next = next
 return s
 })
\`\`\`

\## server.go
下面进行第二步。

\#### struct
首先查看这一个插件最核心的结构。即存储了哪些数据
\`\`\`go
type server struct {
 backendAddr string
 next httpserver.Handler
 backendIsInsecure bool
 backendTLS \*tls.Config
 wrappedGrpc \*grpcweb.WrappedGrpcServer
}
\`\`\`

\- backendAddr 是 grpc 服务的监听地址
\- next 是下一个插件的 Handler 的处理
\- backendIsInsecure 和 backendTLS 都是后台服务是否启用了不同的安全策略。
\- wrappedGrpc 是这个插件的关键，它实现的是 grpcweb protocol，来让 grpc 服务能够被浏览器访问。

\#### serveHTTP
我们上次的文章中，这是第二重要的部分， serveHTTP 的实现代表着具体的功能。上一次我们的内容只有用来传递给下一个 Handle 的逻辑
\`\`\`go
func (g gizmoHandler) ServeHTTP(w http.ResponseWriter, r \*http.Request) (int, error) {
 return g.next.ServeHTTP(w, r)
}
\`\`\`

现在我们来看 这个 grpc 中添加了什么逻辑吧。
\`\`\`go
// ServeHTTP satisfies the httpserver.Handler interface.
func (s server) ServeHTTP(w http.ResponseWriter, r \*http.Request) (int, error) {
 //dial Backend
 opt := []grpc.DialOption{}
 opt = append(opt, grpc.WithCodec(proxy.Codec()))
 if s.backendIsInsecure {
 opt = append(opt, grpc.WithInsecure())
 } else {
 opt = append(opt, grpc.WithTransportCredentials(credentials.NewTLS(s.backendTLS)))
 }

 backendConn, err := grpc.Dial(s.backendAddr, opt...)
 if err != nil {
 return s.next.ServeHTTP(w, r)
 }

 director := func(ctx context.Context, fullMethodName string) (context.Context, \*grpc.ClientConn, error) {
 md, \_ := metadata.FromIncomingContext(ctx)
 return metadata.NewOutgoingContext(ctx, md.Copy()), backendConn, nil
 }
 grpcServer := grpc.NewServer(
 grpc.CustomCodec(proxy.Codec()), // needed for proxy to function.
 grpc.UnknownServiceHandler(proxy.TransparentHandler(director)),
 /\*grpc\_middleware.WithUnaryServerChain(
 grpc\_logrus.UnaryServerInterceptor(logger),
 grpc\_prometheus.UnaryServerInterceptor,
 ),
 grpc\_middleware.WithStreamServerChain(
 grpc\_logrus.StreamServerInterceptor(logger),
 grpc\_prometheus.StreamServerInterceptor,
 ),\*/ //middleware should be a config setting or 3rd party middleware plugins like for caddyhttp
 )

 // gRPC-Web compatibility layer with CORS configured to accept on every
 wrappedGrpc := grpcweb.WrapServer(grpcServer, grpcweb.WithCorsForRegisteredEndpointsOnly(false))
 wrappedGrpc.ServeHTTP(w, r)

 return 0, nil
}

\`\`\`

\- 首先是 grpc 的配置部分，如果你了解 grpc ，你就会知道这是用来配置 grpc 客户端的选项。这里为我们的客户端增添了 Codec 编解码和不同的安全策略选项。
\`\`\`go
 //dial Backend
 opt := []grpc.DialOption{}
 opt = append(opt, grpc.WithCodec(proxy.Codec()))
 if s.backendIsInsecure {
 opt = append(opt, grpc.WithInsecure())
 } else {
 opt = append(opt, grpc.WithTransportCredentials(credentials.NewTLS(s.backendTLS)))
 }
 backendConn, err := grpc.Dial(s.backendAddr, opt...)
 if err != nil {
 return s.next.ServeHTTP(w, r)
 }
\`\`\`

\- 然后是设置了 grpc 服务器的选项
\`\`\`go
director := func(ctx context.Context, fullMethodName string) (context.Context, \*grpc.ClientConn, error) {
 md, \_ := metadata.FromIncomingContext(ctx)
 return metadata.NewOutgoingContext(ctx, md.Copy()), backendConn, nil
 }
 grpcServer := grpc.NewServer(
 grpc.CustomCodec(proxy.Codec()), // needed for proxy to function.
 grpc.UnknownServiceHandler(proxy.TransparentHandler(director)),
 /\*grpc\_middleware.WithUnaryServerChain(
 grpc\_logrus.UnaryServerInterceptor(logger),
 grpc\_prometheus.UnaryServerInterceptor,
 ),
 grpc\_middleware.WithStreamServerChain(
 grpc\_logrus.StreamServerInterceptor(logger),
 grpc\_prometheus.StreamServerInterceptor,
 ),\*/ //middleware should be a config setting or 3rd party middleware plugins like for caddyhttp
 )
\`\`\`

\- 最后是使用 grpcweb.WrapServer 来实现 web 服务的调用
\`\`\`go
// gRPC-Web compatibility layer with CORS configured to accept on every
 wrappedGrpc := grpcweb.WrapServer(grpcServer, grpcweb.WithCorsForRegisteredEndpointsOnly(false))
 wrappedGrpc.ServeHTTP(w, r)
\`\`\`

\### Proxy
注意到，在上文中使用了 proxy.TransparentHandler 这是在 proxy 的 handler.go 中定义的函数。用来实现 gRPC 服务的代理。这里涉及到 关于 gRPC 的交互的实现，重点是 Client 和 Server 的 stream 传输，与本文关系不大，有兴趣可以下来了解。

\## 结语
思考一下把这个作为 Caddy 的插件带来了什么？

是不是一瞬间获得了很多可以扩展的配置？

而不是将 Caddy 中想要的一些插件的功能做到 最开始说的那个独立应用的项目中。

如果你也在做 HTTP 服务，还在眼馋 Caddy 中的一些功能和它的生态，就像这样接入吧。

它还涉及到了 grpc-web ，如果有兴趣，可以扩展学习一下

\##### grpc-web client implementations/examples：
[Vue.js](https://github.com/b3ntly/vue-gRPC)

[GopherJS](https://github.com/johanbrandhorst/gopherjs-improbable-grpc-web-example)

\## 参考
caddy：[https://github.com/caddyserver/caddy](https://github.com/caddyserver/caddy)

如何写中间件：[https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-HTTP-Middleware](https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-HTTP-Middleware)

caddy-grpc插件：[https://github.com/pieterlouw/caddy-grpc](https://github.com/pieterlouw/caddy-grpc)