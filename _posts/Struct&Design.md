--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\## Server

\### rpcx
\`\`\`go
// Server is rpcx server that use TCP or UDP.
type Server struct {
 ln net.Listener
 readTimeout time.Duration
 writeTimeout time.Duration
 gatewayHTTPServer \*http.Server
 DisableHTTPGateway bool // should disable http invoke or not.
 DisableJSONRPC bool // should disable json rpc or not.

 serviceMapMu sync.RWMutex
 serviceMap map[string]\*service

 mu sync.RWMutex
 activeConn map[net.Conn]struct{}
 doneChan chan struct{}
 seq uint64

 inShutdown int32
 onShutdown []func(s \*Server)

 // TLSConfig for creating tls tcp connection.
 tlsConfig \*tls.Config
 // BlockCrypt for kcp.BlockCrypt
 options map[string]interface{}

 // CORS options
 corsOptions \*CORSOptions

 Plugins PluginContainer

 // AuthFunc can be used to auth.
 AuthFunc func(ctx context.Context, req \*protocol.Message, token string) error

 handlerMsgNum int32
}
\`\`\`

\### gorilla/rpc
\`\`\`go
// Server serves registered RPC services using registered codecs.
type Server struct {
 codecs map[string]Codec
 services \*serviceMap
 interceptFunc func(i \*RequestInfo) \*http.Request
 beforeFunc func(i \*RequestInfo)
 afterFunc func(i \*RequestInfo)
}
\`\`\`

\### grpc-go

\`\`\`go
// Server is a gRPC server to serve RPC requests.
type Server struct {
 opts serverOptions

 mu sync.Mutex // guards following
 lis map[net.Listener]bool
 conns map[transport.ServerTransport]bool
 serve bool
 drain bool
 cv \*sync.Cond // signaled when connections close for GracefulStop
 m map[string]\*service // service name -> service info
 events trace.EventLog

 quit \*grpcsync.Event
 done \*grpcsync.Event
 channelzRemoveOnce sync.Once
 serveWG sync.WaitGroup // counts active Serve goroutines for GracefulStop

 channelzID int64 // channelz unique identification number
 czData \*channelzData
}
\`\`\`

\## Client

\### rpcx
\`\`\`go
// RPCClient is interface that defines one client to call one server.
type RPCClient interface {
 Connect(network, address string) error
 Go(ctx context.Context, servicePath, serviceMethod string, args interface{}, reply interface{}, done chan \*Call) \*Call
 Call(ctx context.Context, servicePath, serviceMethod string, args interface{}, reply interface{}) error
 SendRaw(ctx context.Context, r \*protocol.Message) (map[string]string, []byte, error)
 Close() error

 RegisterServerMessageChan(ch chan<- \*protocol.Message)
 UnregisterServerMessageChan()

 IsClosing() bool
 IsShutdown() bool
}
\`\`\`

\`\`\`go
// Client represents a RPC client.
type Client struct {
 option Option

 Conn net.Conn
 r \*bufio.Reader
 //w \*bufio.Writer

 mutex sync.Mutex // protects following
 seq uint64
 pending map[uint64]\*Call
 closing bool // user has called Close
 shutdown bool // server has told us to stop
 pluginClosed bool // the plugin has been called

 Plugins PluginContainer

 ServerMessageChan chan<- \*protocol.Message
}
\`\`\`

\### grpc-go
\`\`\`go
// ClientConn represents a client connection to an RPC server.
type ClientConn struct {
 ctx context.Context
 cancel context.CancelFunc

 target string
 parsedTarget resolver.Target
 authority string
 dopts dialOptions
 csMgr \*connectivityStateManager

 balancerBuildOpts balancer.BuildOptions
 blockingpicker \*pickerWrapper

 mu sync.RWMutex
 resolverWrapper \*ccResolverWrapper
 sc \*ServiceConfig
 conns map[\*addrConn]struct{}
 // Keepalive parameter can be updated if a GoAway is received.
 mkp keepalive.ClientParameters
 curBalancerName string
 balancerWrapper \*ccBalancerWrapper
 retryThrottler atomic.Value

 firstResolveEvent \*grpcsync.Event

 channelzID int64 // channelz unique identification number
 czData \*channelzData
}
\`\`\`

\## Codec

\### rpcx
\`\`\`go
// Codec defines the interface that decode/encode payload.
type Codec interface {
 Encode(i interface{}) ([]byte, error)
 Decode(data []byte, i interface{}) error
}
\`\`\`

\### gorilla/rpc
\`\`\`go
// Codec creates a CodecRequest to process each request.
type Codec interface {
 NewRequest(\*http.Request) CodecRequest
}

// CodecRequest decodes a request and encodes a response using a specific
// serialization scheme.
type CodecRequest interface {
 // Reads request and returns the RPC method name.
 Method() (string, error)
 // Reads request filling the RPC method args.
 ReadRequest(interface{}) error
 // Writes response using the RPC method reply. The error parameter is
 // the error returned by the method call, if any.
 WriteResponse(http.ResponseWriter, interface{}, error) error
}

\`\`\`

\## Service

\### rpcx
\`\`\`go
type methodType struct {
 sync.Mutex // protects counters
 method reflect.Method
 ArgType reflect.Type
 ReplyType reflect.Type
 // numCalls uint
}

type functionType struct {
 sync.Mutex // protects counters
 fn reflect.Value
 ArgType reflect.Type
 ReplyType reflect.Type
}

type service struct {
 name string // name of service
 rcvr reflect.Value // receiver of methods for the service
 typ reflect.Type // type of the receiver
 method map[string]\*methodType // registered methods
 function map[string]\*functionType // registered functions
}

\`\`\`

\### gorilla/rpc
\`\`\`go
type service struct {
 name string // name of service
 rcvr reflect.Value // receiver of methods for the service
 rcvrType reflect.Type // type of the receiver
 methods map[string]\*serviceMethod // registered methods
 passReq bool
}

type serviceMethod struct {
 method reflect.Method // receiver method
 argsType reflect.Type // type of the request argument
 replyType reflect.Type // type of the response argument
}
\`\`\`

\### grpc-go
\`\`\`go
// MethodDesc represents an RPC service's method specification.
type MethodDesc struct {
 MethodName string
 Handler methodHandler
}

// ServiceDesc represents an RPC service's specification.
type ServiceDesc struct {
 ServiceName string
 // The pointer to the service interface. Used to check whether the user
 // provided implementation satisfies the interface requirements.
 HandlerType interface{}
 Methods []MethodDesc
 Streams []StreamDesc
 Metadata interface{}
}

// service consists of the information of the server serving this service and
// the methods in this service.
type service struct {
 server interface{} // the server for service methods
 md map[string]\*MethodDesc
 sd map[string]\*StreamDesc
 mdata interface{}
}
\`\`\`

\## Option

\### grpc-go

\`\`\`go
// A ServerOption sets options such as credentials, codec and keepalive parameters, etc.
type ServerOption interface {
 apply(\*serverOptions)
}

type serverOptions struct {
 creds credentials.TransportCredentials
 codec baseCodec
 cp Compressor
 dc Decompressor
 unaryInt UnaryServerInterceptor
 streamInt StreamServerInterceptor
 inTapHandle tap.ServerInHandle
 statsHandler stats.Handler
 maxConcurrentStreams uint32
 maxReceiveMessageSize int
 maxSendMessageSize int
 unknownStreamDesc \*StreamDesc
 keepaliveParams keepalive.ServerParameters
 keepalivePolicy keepalive.EnforcementPolicy
 initialWindowSize int32
 initialConnWindowSize int32
 writeBufferSize int
 readBufferSize int
 connectionTimeout time.Duration
 maxHeaderListSize \*uint32
}

\`\`\`

\## Connection

\### rpcx

\#### tcp

\`\`\`go
var makeListeners = make(map[string]MakeListener)

func init() {
 makeListeners["tcp"] = tcpMakeListener("tcp")
 makeListeners["tcp4"] = tcpMakeListener("tcp4")
 makeListeners["tcp6"] = tcpMakeListener("tcp6")
 makeListeners["http"] = tcpMakeListener("tcp")
}

// RegisterMakeListener registers a MakeListener for network.
func RegisterMakeListener(network string, ml MakeListener) {
 makeListeners[network] = ml
}

// MakeListener defines a listener generater.
type MakeListener func(s \*Server, address string) (ln net.Listener, err error)

// block can be nil if the caller wishes to skip encryption in kcp.
// tlsConfig can be nil iff we are not using network "quic".
func (s \*Server) makeListener(network, address string) (ln net.Listener, err error) {
 ml := makeListeners[network]
 if ml == nil {
 return nil, fmt.Errorf("can not make listener for %s", network)
 }
 return ml(s, address)
}

func tcpMakeListener(network string) func(s \*Server, address string) (ln net.Listener, err error) {
 return func(s \*Server, address string) (ln net.Listener, err error) {
 if s.tlsConfig == nil {
 ln, err = net.Listen(network, address)
 } else {
 ln, err = tls.Listen(network, address, s.tlsConfig)
 }

 return ln, err
 }

}
\`\`\`

\#### quic
\> quicconn "github.com/marten-seemann/quic-conn"

\`\`\`go
func init() {
 makeListeners["quic"] = quicMakeListener
}
func quicMakeListener(s \*Server, address string) (ln net.Listener, err error) {
 if s.tlsConfig == nil {
 return nil, errors.New("TLSConfig must be configured in server.Options")
 }
 return quicconn.Listen("udp", address, s.tlsConfig)
}
\`\`\`

\#### utp
\> "github.com/anacrolix/utp"

\`\`\`go
func init() {
 makeListeners["utp"] = utpMakeListener
}
func utpMakeListener(s \*Server, address string) (ln net.Listener, err error) {
 return utp.Listen(address)
}
\`\`\`

\#### kcp
\> import kcp "github.com/xtaci/kcp-go"

\`\`\`go
func init() {
 makeListeners["kcp"] = kcpMakeListener
}

func kcpMakeListener(s \*Server, address string) (ln net.Listener, err error) {
 if s.options == nil \|\| s.options["BlockCrypt"] == nil {
 return nil, errors.New("KCP BlockCrypt must be configured in server.Options")
 }

 return kcp.ListenWithOptions(address, s.options["BlockCrypt"].(kcp.BlockCrypt), 10, 3)
}

// WithBlockCrypt sets kcp.BlockCrypt.
func WithBlockCrypt(bc kcp.BlockCrypt) OptionFn {
 return func(s \*Server) {
 s.options["BlockCrypt"] = bc
 }
}
\`\`\`