--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\### DialOptions
DialOptions 是最重要的一环，负责配置每一次 rpc 请求的时候的一应选择。

\#### 结构
先来看看这个的结构

[链接](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/dialoptions.go#L41)
\`\`\`go
// dialOptions configure a Dial call. dialOptions are set by the DialOption
// values passed to Dial.
type dialOptions struct {
 unaryInt UnaryClientInterceptor
 streamInt StreamClientInterceptor

 chainUnaryInts []UnaryClientInterceptor
 chainStreamInts []StreamClientInterceptor

 cp Compressor
 dc Decompressor
 bs backoff.Strategy
 block bool
 insecure bool
 timeout time.Duration
 scChan <-chan ServiceConfig
 authority string
 copts transport.ConnectOptions
 callOptions []CallOption
 // This is used by v1 balancer dial option WithBalancer to support v1
 // balancer, and also by WithBalancerName dial option.
 balancerBuilder balancer.Builder
 // This is to support grpclb.
 resolverBuilder resolver.Builder
 channelzParentID int64
 disableServiceConfig bool
 disableRetry bool
 disableHealthCheck bool
 healthCheckFunc internal.HealthChecker
 minConnectTimeout func() time.Duration
 defaultServiceConfig \*ServiceConfig // defaultServiceConfig is parsed from defaultServiceConfigRawJSON.
 defaultServiceConfigRawJSON \*string
}
\`\`\`
由于命名非常规范，加上注释很容易看懂每一个 field 配置的哪一条属性。如果掠过看的 大概有 压缩解压器，超时阻塞设置，认证安全转发，负载均衡，服务持久化的信息存储 ，配置，心跳检测等。

其一应函数方法都是设置 其中字段的。

\#### 如何设置
这里是 grpc 设计较好的地方，通过函数设置，同时设有生成函数的函数。什么意思呢？首先结合图来理解，这也是整个[ grpc 设置的精华部分](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/dialoptions.go#L74)

![grpc-setOperation.svg](https://cdn.nlark.com/yuque/0/2019/svg/176280/1564060510943-3faee934-4035-474e-ac4d-b8ae9ee446b1.svg#align=left&display=inline&height=261&margin=%5Bobject%20Object%5D&name=grpc-setOperation.svg&originHeight=261&originWidth=714&size=11210&status=done&style=none&width=714)

这里的意思是 ， DialOptions 是一个导出接口，实现函数是 apply 同时接受参数 dialOptions 来修改它。

而实际上，是使用 newFuncDialOption 函数包装一个 修改 dialOptions 的方法给 funcDialOption 结构体，在实际 Dial 调用的时候 是使用闭包 调用 funcDialOption 结构体的 apply 方法。

可以在这里看一下 [Dial 方法的源码](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/clientconn.go#L123)（Dial 调用的是 DialContext

起作用的就是 opt.apply()
\`\`\`go
func DialContext(ctx context.Context, target string, opts ...DialOption) (conn \*ClientConn, err error) {
 cc := &ClientConn{
 target: target,
 csMgr: &connectivityStateManager{},
 conns: make(map[\*addrConn]struct{}),
 dopts: defaultDialOptions(),
 blockingpicker: newPickerWrapper(),
 czData: new(channelzData),
 firstResolveEvent: grpcsync.NewEvent(),
 }
 ···
 for \_, opt := range opts {
 opt.apply(&cc.dopts)
 }
 ···
}
\`\`\`

这里的 options 可以说是 client 发起 rpc 请求的核心中转站。

另一个重要的接口，同时也集中在 dialOptions 结构体中初始化处理的是

\`callOptions []CallOption\`

\### CallOption
CallOption 是一个接口，定义在 rpc\_util 包内

\#### 结构
\`\`\`go
// CallOption configures a Call before it starts or extracts information from
// a Call after it completes.
type CallOption interface {
 // before is called before the call is sent to any server. If before
 // returns a non-nil error, the RPC fails with that error.
 before(\*callInfo) error

 // after is called after the call has completed. after cannot return an
 // error, so any failures should be reported via output parameters.
 after(\*callInfo)
}
\`\`\`

操作的是 callInfo 结构里的数据，其被包含在 \`dialOptions\`  结构体中，

即每一次 dial 的时候进行调用。

\#### callInfo
同时它[自身](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/rpc\_util.go#L176)定义很有意思，操作的是 [\`callInfo\`](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/rpc\_util.go#L155)  结构体
\`\`\`go
// callInfo contains all related configuration and information about an RPC.
type callInfo struct {
 compressorType string
 failFast bool
 stream ClientStream
 maxReceiveMessageSize \*int
 maxSendMessageSize \*int
 creds credentials.PerRPCCredentials
 contentSubtype string
 codec baseCodec
 maxRetryRPCBufferSize int
}
\`\`\`
可以看到 callInfo 中字段用来表示 单次调用中独有的自定义选项如 压缩，流控，认证，编解码器等。

\#### 一个实现
简单看一个 CallOption 接口的实现
\`\`\`go
// Header returns a CallOptions that retrieves the header metadata
// for a unary RPC.
func Header(md \*metadata.MD) CallOption {
 return HeaderCallOption{HeaderAddr: md}
}

// HeaderCallOption is a CallOption for collecting response header metadata.
// The metadata field will be populated \*after\* the RPC completes.
// This is an EXPERIMENTAL API.
type HeaderCallOption struct {
 HeaderAddr \*metadata.MD
}

func (o HeaderCallOption) before(c \*callInfo) error { return nil }
func (o HeaderCallOption) after(c \*callInfo) {
 if c.stream != nil {
 \*o.HeaderAddr, \_ = c.stream.Header()
 }
}
\`\`\`
重点看到，实际操作是在 before 和 after 方法中执行，它们会在 Client 发起请求的时候自动执行，顾名思义，一个在调用前执行，一个在调用后执行。

\#### 实现注意
这里可以看出，这里也是通过函数返回一个拥有这两个方法的结构体，注意这一个设计，可以作为你自己的 Option 设计的时候的参考。

\#### 两种方法
有两种方法让 Client 接受你的 CallOption 设置

1\. 在 Client 使用方法的时候直接作为 参数传递，将刚才所说的函数-返回一个实现了 CallOption 接口的结构体。
1\. 在 生成 Client 的时候就传递设置。具体如下
 1\. 通过 dialOptions.go 中的 函数 grpc.[WithDefaultCallOptions](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/dialoptions.go#L155:59)()
 1\. 这个函数会将 CallOption 设置到 dialOptions 中的字段 []CallOption 中。
\`\`\`go
// WithDefaultCallOptions returns a DialOption which sets the default
// CallOptions for calls over the connection.
func WithDefaultCallOptions(cos ...CallOption) DialOption {
 return newFuncDialOption(func(o \*dialOptions) {
 o.callOptions = append(o.callOptions, cos...)
 })
}
\`\`\`

有没有感觉有点不好理解？给你们一个实例

1\. 使用的第一种方法
\`\`\`go
response, err := myclient.MyCall(ctx, request, grpc.CallContentSubtype("mycodec"))
\`\`\`

2\. 使用第二种方法
\`\`\`go
myclient := grpc.Dial(ctx, target, grpc.WithDefaultCallOptions(grpc.CallContentSubtype("mycodec")))
\`\`\`
这里假设 我们设置了一个 mycodec 的译码器。马上下面解释它的设计。

\#### 另
值得注意的是， 我好像只提到了在 Client 调用时设置，callOption  只在客户端设置的情况是不是让大家感到困惑。

实际上 gRPC server 端会自动检测 callOption 的设置，并检测自己是否支持此项选择，如果不支持则会返回失败。也就是说，在 Server 端注册的所有 Codec 译码器之后，Client 直接使用相应的设置就好了。

\### Codec
在 gRPC 中 Codec 有两个接口定义，一个是 baseCodec 包含正常的 Marshal 和 Unmarshal 方法，另一个是拥有名字的 Codec 定义在 [encoding](https://sourcegraph.com/github.com/grpc/grpc-go/-/blob/encoding/encoding.go#L74:22) 包内，这是由于在注册 registry 的时候会使用到这个方法。

\#### 接口
\`\`\`go
type Codec interface {
 // Marshal returns the wire format of v.
 Marshal(v interface{}) ([]byte, error)
 // Unmarshal parses the wire format into v.
 Unmarshal(data []byte, v interface{}) error
 // String returns the name of the Codec implementation. This is unused by
 // gRPC.
 String() string
}
\`\`\`
就是这个方法
\`\`\`go
// RegisterCodec registers the provided Codec for use with all gRPC clients and
// servers.
//
// The Codec will be stored and looked up by result of its Name() method, which
// should match the content-subtype of the encoding handled by the Codec. This
// is case-insensitive, and is stored and looked up as lowercase. If the
// result of calling Name() is an empty string, RegisterCodec will panic. See
// Content-Type on
// https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md#requests for
// more details.
//
// NOTE: this function must only be called during initialization time (i.e. in
// an init() function), and is not thread-safe. If multiple Compressors are
// registered with the same name, the one registered last will take effect.
func RegisterCodec(codec Codec) {
 if codec == nil {
 panic("cannot register a nil Codec")
 }
 if codec.Name() == "" {
 panic("cannot register Codec with empty string result for Name()")
 }
 contentSubtype := strings.ToLower(codec.Name())
 registeredCodecs[contentSubtype] = codec
}
\`\`\`

\#### Compressor
同时 encoding 包中还定义了 Compressor 接口，参照 Codec 理解即可。
\`\`\`go
// Compressor is used for compressing and decompressing when sending or
// receiving messages.
type Compressor interface {
 // Compress writes the data written to wc to w after compressing it. If an
 // error occurs while initializing the compressor, that error is returned
 // instead.
 Compress(w io.Writer) (io.WriteCloser, error)
 // Decompress reads data from r, decompresses it, and provides the
 // uncompressed data via the returned io.Reader. If an error occurs while
 // initializing the decompressor, that error is returned instead.
 Decompress(r io.Reader) (io.Reader, error)
 // Name is the name of the compression codec and is used to set the content
 // coding header. The result must be static; the result cannot change
 // between calls.
 Name() string
}

\`\`\`

\### MetaData
这个包对应 context 中的 Value field 也就是 key-value 形式的存储

在其他包中简写是 MD

\#### 结构
\`\`\`go
type MD map[string][]string
\`\`\`

\#### 函数
实现了完善的存储功能，从单一读写到批量（采用 pair 模式，...string 作为参数，len(string)%2==1 时会报错，由于会有孤立的没有配对的元信息。

另外几个函数是实现了从 context 中的读取和写入（这里的写入是 使用 context.WithValue 方法，即生成 parent context 的 copy。

\#### 注意⚠️

\- 值得注意的是，在 MetaData 结构体中， value 的结构是 []string 。
\- 同时 key 不可以以 "grpc-" 开头，这是因为在 grpc 的 internal 包中已经保留了。
\- 更为重要的是 在 context 中的读取方式，其实是 MetaData 结构对应的是 context Value 中的 value 值，而 key 值设为 一个空结构体同时区分输入输入
 \- \`type mdIncomingKey struct{}

\`
 \- \`type mdOutgoingKey struct{}\`

\#### Refer
gRPC 官方也有 [MetaData](https://github.com/grpc/grpc-go/blob/master/Documentation/grpc-metadata.md) 的解释