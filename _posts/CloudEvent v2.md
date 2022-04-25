Now CLoudEvent coming v2.

最大的变化是将 原先 client 下的 transport 层单独抽出作为 protocol 层.

即原先为相同的 client , 不同的 如针对 nats 的 transport 层.

变成了 现在的单独为 nats 适配的 protocol 层. protocol 直接接管了 client 和 transport 的功能.并实现了规定的接口

以 Nats 举例, 通过 环境变量生成 Nats Protocol . Protocol 包含 Nats.Client

使用 Protocol 生成 CloudEvent 标准的 Client. 通过永久 for 循环 Client 的 StartReceiver 方法. 这意味着 startReceiver是阻塞的. 查看 Receive 代码可以发现. 每有一个 Goroutine. 一次 StartReceiver 就会多处理一个信息.
\`\`\`go
package main

import (
 "context"
 "fmt"
 "log"

 "github.com/kelseyhightower/envconfig"

 cenats "github.com/cloudevents/sdk-go/protocol/nats/v2"
 cloudevents "github.com/cloudevents/sdk-go/v2"
)

type envConfig struct {
 // NATSServer URL to connect to the nats server.
 NATSServer string \`envconfig:"NATS\_SERVER" default:"http://localhost:4222" required:"true"\`

 // Subject is the nats subject to subscribe for cloudevents on.
 Subject string \`envconfig:"SUBJECT" default:"sample" required:"true"\`
}

func main() {
 var env envConfig
 if err := envconfig.Process("", &env); err != nil {
 log.Fatalf("Failed to process env var: %s", err)
 }
 ctx := context.Background()

 p, err := cenats.NewConsumer(env.NATSServer, env.Subject, cenats.NatsOptions())
 if err != nil {
 log.Fatalf("failed to create nats protocol, %s", err.Error())
 }

 defer p.Close(ctx)

 c, err := cloudevents.NewClient(p)
 if err != nil {
 log.Fatalf("failed to create client, %s", err.Error())
 }

 for {
 if err := c.StartReceiver(ctx, receive); err != nil {
 log.Printf("failed to start nats receiver, %s", err.Error())
 }
 }
}

type Example struct {
 Sequence int \`json:"id"\`
 Message string \`json:"message"\`
}

func receive(ctx context.Context, event cloudevents.Event) error {
 fmt.Printf("Got Event Context: %+v\\n", event.Context)

 data := &Example{}
 if err := event.DataAs(data); err != nil {
 fmt.Printf("Got Data Error: %s\\n", err.Error())
 }
 fmt.Printf("Got Data: %+v\\n", data)

 fmt.Printf("----------------------------\\n")
 return nil
}
\`\`\`
总结:

CloudEvent 的 go-sdk 虽然没什么大问题, 但是也没什么亮点.各个定义弄得非常复杂.

event 的不同版本的解析, 编解码, 不够简洁.

接口定义过多, 不够简洁, 边界没有定义好.

总的来说, 最多只是一个 sdk 水平.

事情做得太直接一般不是好程序呢.