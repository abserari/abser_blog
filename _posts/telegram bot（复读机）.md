\## Doc
[https://core.telegram.org/bots/api](https://core.telegram.org/bots/api)

\## 尝试
用 Go 语言做了一个 telegram 的 bot . 用来简单实现对话（复读）。

\### 获得 telegram bot token
和 BotFather 交谈即可

中途需要设置一下名字和查找路径

![image.png](assert/1564137455171-abad4275-4e67-48e7-a142-02ae689d9f40.png)

\### go get
首先获取 api 包
\`\`\`go
go get -u github.com/go-telegram-bot-api/telegram-bot-api
\`\`\`

\### code
\`\`\`go
package main

import (
 "log"
 "os"

 "github.com/go-telegram-bot-api/telegram-bot-api"
)

func main() {
 bot, err := tgbotapi.NewBotAPI(os.Getenv("TELEGRAM\_APITOKEN"))
 if err != nil {
 log.Panic(err)
 }

 bot.Debug = true

 log.Printf("Authorized on account %s", bot.Self.UserName)

 u := tgbotapi.NewUpdate(0)
 u.Timeout = 60

 updates, err := bot.GetUpdatesChan(u)

 for update := range updates {
 if update.Message == nil { // ignore any non-Message Updates
 continue
 }

 msg := tgbotapi.NewMessage(update.Message.Chat.ID, update.Message.Text)
 msg.ReplyToMessageID = update.Message.MessageID

 if \_, err := bot.Send(msg); err != nil {
 log.Panic(err)
 }
 }
}
\`\`\`

\## Run
注意 终端需要能访问 telegram 的 API

![image.png](assert/1564137569674-685f6d36-eb30-4465-8ee1-ded45ae1d5a8.png)

\### 效果
![image.png](assert/1564137638524-2d23dafe-59fe-4dfa-9117-a90edcd18de8.png)