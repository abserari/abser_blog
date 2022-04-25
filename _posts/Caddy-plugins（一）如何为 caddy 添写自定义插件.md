--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

项目地址：[https://github.com/yhyddr/quicksilver/tree/master/gosample/caddy-plugin](https://github.com/yhyddr/quicksilver/tree/master/gosample/caddy-plugin)

\-\-\-

\## 前言
Caddy附带一个HTTP服务器，但是你可以实现其他服务器类型并将它们插入Caddy中。其他类型的服务器可以是SSH、SFTP、TCP、内部使用的其他东西等等。

对于Caddy来说，服务器的概念是任何可以\`Listen()\`和\`Serve()\`的东西。这意味着什么、如何运作都取决于你。你可以自由地发挥你的创造力去使用它。

那么怎样去扩展 Caddy 呢？

不同的服务器类型，可以根据自己的需要定制不同的插件。我们在这里，通过添加最简单的不做任何事的插件，来熟悉如何扩展 Caddy 服务器。

\## Plugin for HTTP
我们会一步一步构建出一个 HTTP Plugin 的框架，到时候你只需要填充自己处理逻辑即可！那还等什么，让我们开始吧。

构建一个 HTTP Plugin ，代码部分仅需要两步，注意事项也有两个。

\### 创建一个 Go Package
首先为 caddy 创建一个 插件的 Go Package ，你可以新建一个文件夹达到这个效果。比如

\`\`\`bash
├── caddy-plugin
│   ├── gizmo.go
│   └── setup.go
\`\`\`

这里分为了两个 Go 文件，接下来详细讲每一个 Go 文件的作用。

\### 代码🀙：注册 caddy plugin
首先我们看到 setup.go

\#### setup.go
创建 setup.go 文件并写入以下信息
\`\`\`go
import "github.com/mholt/caddy"

func init() {
 caddy.RegisterPlugin("gizmo", caddy.Plugin{
 ServerType: "http",
 Action: setup,
 })
}
\`\`\`
这里是 建立了一个新插件，caddy 包来做到插件的注册。

1\. 注意到 “gizmo” 这是 插件的名字，同时也是指令的名字，请为你的插件取一个独一无二的名字吧。（注意：名字需要是单词小写哦。）
1\. 因为是针对 HTTP 服务器的插件，所以 ServerType 字段值是 “http”
1\. 另一个设置的字段是 setup ，实际上，我们接下来会填充这个函数的逻辑。它的作用就是将我们插件的处理逻辑安装到 Caddy 中。

\#### setup
现在我们来实现 setup 函数

假如我们希望在Caddyfile中有一行这样的行：
\`\`\`
gizmo foobar
\`\`\`

我们可以得到刚才所说的 \`c.Next()\` 第一个参数(“foobar”)的值，如下所示：
\`\`\`go
for c.Next() { // skip the directive name
 if !c.NextArg() { // expect at least one value
 return c.ArgErr() // otherwise it's an error
 }
 value := c.Val() // use the value
}
\`\`\`
我们首先注意到， c.Next() 是真正我们读取 caddyfile 逻辑的地方，caddyfile 就是配置服务器的配置文件的名字。我们注意到，这里的操作实际上是使用 caddy.Controller 来实现的。它的存在 让编写插件的开发者只需要关注如何使用它来执行你的命令，这是一项优秀的设计，有兴趣可以看我的源码阅读部分关于 Plugin 的具体实现。

在 Caddy 解析了Caddyfile之后，它将迭代每个指令名(按照服务器类型规定的顺序)，并在每次遇到指令名时调用指令的setup函数。setup函数的职责是解析指令的标识并配置自己。

您可以通过遍历\`c.Next()\`来解析为指令提供的标识，只要有更多的标识需要解析，那么\`c.Next()\`就会返回\`true\`。由于一个指令可能出现多次，你必须遍历\`c.Next()\`以获得所有出现的指令并使用第一个标识(即指令名)。

有关caddyfile包，请参阅[godoc](https://godoc.org/github.com/mholt/caddy/caddyfile)以了解如何更充分地使用分发器，并查看任何其他现有插件。

\### 代码 🀚：Handler 实现

\#### gizmo.go：
查看[httpserver包的godoc](http://godoc.org/github.com/mholt/caddy/caddyhttp/httpserver)。最重要的两种类型是[httpserver.Handler](https://godoc.org/github.com/mholt/caddy/caddyhttp/httpserver#Handler)和[httpserver.Middleware](https://godoc.org/github.com/mholt/caddy/caddyhttp/httpserver#Middleware)。

1\. \`Handler\`是一个处理HTTP请求的函数。
1\. \`Middleware\`是一种连接\`Handler\`的方式。

Caddy将负责为你设置HTTP服务器的所有簿记(bookkeeping)工作，但是你需要实现这两种类型。

\#### Struct
\`httpserver.Handler\`是一个几乎和\`http.Handler\`完全一样的接口，除了\`ServeHTTP\`方法返回\`(int, error)\`。

这个方法签名遵循Go语言博客中[关于与中间件相关的错误处理的建议](http://blog.golang.org/error-handling-and-go)。

\`int\`是HTTP状态码，\`error\`应该被处理和/或记录。有关这些返回值的详细信息，请参阅godoc。

\`Handler\`通常是一个结构体，至少包含一个\`Next\`字段，用来链接下一个\`Handler\`：
\`\`\`go
type gizmoHandler struct {
 next httpserver.Handler
}
\`\`\`

除了这些之外，可以添加一些自己使用的参数，考虑 grpc 的 plugin 实现，解释放在代码块中的注释中
\`\`\`go
type server struct {
 backendAddr string // 监听地址
 next httpserver.Handler // 作为中间件必须有的字段
 backendIsInsecure bool // 是否启用 Insecure() 选项，是 grpc 的一项配置
 backendTLS \*tls.Config // 关于 TLS 的使用的证书文件
 wrappedGrpc \*grpcweb.WrappedGrpcServer // 通过 grpcweb 的 协议实现 HTTP 请求等
}
\`\`\`
这就是参考的一个 字段的使用。可以根据自己的需要，调整在 caddyfile 中读取的指令应该如何配置。

\#### httpserver.Handler
为了实现\`httpserver.Handler\`接口，我们需要编写一个名为\`ServeHTTP\`的方法。这个方法是实际的处理程序函数，除非它自己处理完毕请求，否则它应该调用链中的下一个\`Handler\`：即使用 \`g.next.ServeHTTP(w, r)\`
\`\`\`go
func (g gizmoHandler) ServeHTTP(w http.ResponseWriter, r \*http.Request) (int, error) {
 return g.next.ServeHTTP(w, r)
}
\`\`\`
这里只是框架，具体逻辑可以自行填充，可以参照已有的 Plugin 实现。

\#### 第二步，注册 Middleware
然后我们可以进行第二步，将这个 handler 注册到整个 caddy 的 http 调用链上。

我们需要回到 刚才的 setup.go 文件中，

回到设置函数。你刚刚解析了标识并使用所有适当的配置设置了中间件处理程序：
\`\`\`go
func setup(c \*caddy.Controller) error {
 g := gizmoHandler{} // 用来实现 HTTPHandler 的 next 的结构，用来构建 中间件。也可以加入一些自己的字段

 for c.Next() {
 // 获取配置文件，并处理
 }
 // 现在开始注册中间件
 httpserver.GetConfig(c).AddMiddleware(func(next httpserver.Handler) httpserver.Handler {
 g.next = next
 return g
 })

 return nil
}
\`\`\`
这样，代码部分就全部完成了。

下面我们查看需要注意的事项。实际上是关乎于怎样将写好的插件集成在 caddy 中。

\### 排序
要做的事情是告诉服务器类型在进程的什么地方执行你的指令。这一点很重要，因为其他指令可能会设置你所依赖的更原始的配置，因此执行指令的顺序不能是随意的。

每个服务器类型都有一个字符串列表，其中每个项都是一个指令的名称。例如，查看[HTTP服务器支持的指令列表](https://github.com/mholt/caddy/blob/d3860f95f59b5f18e14ddf3d67b4c44dbbfdb847/caddyhttp/httpserver/plugin.go#L314-L355)。将指令添加到适当的位置。

\## 插入你的插件
最后，不要忘记导入你的插件包！Caddy必须导入插件来注册并执行它。这通常是在[run.go](https://github.com/mholt/caddy/blob/master/caddy/caddymain/run.go)的\`import\`部分的尾部完成的：

\`\`\`go
\_ "your/plugin/package/here"
\`\`\`

请注意：包名前的\`\_\`是必需的。

\## 总结
就是这样！可以用你的插件来构建caddy，然后用你的新指令写一个Caddyfile来查看它的运行情况。

虽然还没完善的她只是一个框架，还不能做任何事情，但是她很简单，很美不是吗？她能帮你做任何事情。因为记住 caddy 的服务器是设置的非常抽象的。她就想 net 包中 conn 一样完美的 接口设计，能够兼容和扩展任何 需要 listen()  和 serve() 的东西，只要你的创造力足够。

现在，发挥你的想象力，填充这个框架吧，可以参考我的简单项目地址。

项目地址：[https://github.com/yhyddr/quicksilver/tree/master/gosample/caddy-plugin](https://github.com/yhyddr/quicksilver/tree/master/gosample/caddy-plugin)

同时记得多多寻找别人的插件实现方式，你会找到让你耳目一新的实现。[https://www.yuque.com/fengyfei/idznuk/sumapn](https://www.yuque.com/fengyfei/idznuk/sumapn)

\## 参考
![image.png](assert/1565363529670-bb10335a-9c42-41b6-9098-8230757271df.png)

我刚编辑过哦

[https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-Directives](https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-Directives)

[https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-Server-Type](https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-Server-Type)

[https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-HTTP-Middleware](https://github.com/caddyserver/caddy/wiki/Writing-a-Plugin:-HTTP-Middleware)