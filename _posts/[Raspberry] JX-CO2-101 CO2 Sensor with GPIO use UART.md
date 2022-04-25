\##

\## Overview
![树莓派+二氧化碳传感器.png](assert/1613920437373-92a8c1c5-3a9d-4b90-8ba8-2857114d5ab2.png)

\### Snap

\#### Raspberry
![IMG\_2581.png](assert/1612496135723-4376f1f6-188e-45a3-b9de-beea7f2761e3.png)

\#### CO2 Sensor
![image.png](assert/1612599825170-64b0b09a-d041-4ade-a2fc-15066d385df9.png)

\#### 4G HAT
![](https://cdn.nlark.com/yuque/0/2021/jpeg/176280/1613187168406-54938326-00e5-421d-8662-86e25dfcad3b.jpeg?x-oss-process=image/auto-orient,1#align=left&display=inline&height=3024&margin=%5Bobject%20Object%5D&originHeight=3024&originWidth=4032&size=0&status=done&style=none&width=4032)

\### Reading Data
\`\`\`bash
cat /dev/ttyAMA0
\`\`\`
![image.png](assert/1612499197873-7c58f77f-f8b9-40a5-8061-1aeb4f9ba4e8.png)

\## Step

\### RasberryPi 3B+ install golang
\`\`\`bash
wget https://golang.org/dl/go1.15.8.linux-armv6l.tar.gz
tar -C /usr/local -xzf go1.15.8.linux-armv6l.tar.gz && rm -f go1.15.8.linux-armv6l.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bash\_profile
export PATH=$PATH:/usr/local/go/bin
go version
\`\`\`

\### Read Serial Data
\`\`\`go
package main

import (
 "log"
 "time"

 "github.com/tarm/serial"
)

// pi3 should open uart and communicate with device: /dev/ttyAMA0 \| /dev/serial0
func main() {
 c := &serial.Config{Name: "/dev/ttyAMA0", Baud: 9600, ReadTimeout: time.Second \* 5}
 s, err := serial.OpenPort(c)
 if err != nil {
 log.Fatal(err)
 }

 n, err := s.Write([]byte{0xff, 0x01, 0x03, 0x02, 0x00, 0x00, 0x00, 0x00, 0xfb})
 log.Println("write n", n)
 if err != nil {
 log.Fatal(err)
 }

 buf := make([]byte, 128)
 n, err = s.ReadAll(buf)
 if err != nil {
 log.Fatal(err)
 }
 log.Printf("%q", buf[:n])
}

\`\`\`

\### Server
receive data from edge device
\`\`\`go
func (d dioxideDensity) RegistRouter(r gin.IRouter) {
 r.POST("/dioxide", d.Add)
}

func (d dioxideDensity) Add(c \*gin.Context) {
 var req struct {
 DioxideDensity int \`json: "dioxide" binding:"required"\`
 DeviceId string \`json: "deviceId" binding:"required"\`
 // Status int \`json: "status" binding:"required"\`
 ZoneName string \`json: "zoneName" binding:"required"\`
 }

 if err := c.ShouldBind(&req); err != nil {
 c.Error(err)
 c.JSON(http.StatusBadRequest, gin.H{"status": http.StatusBadRequest})
 return
 }

 err := mysql.InsertDioxide(d.db, req.DioxideDensity, 0, req.ZoneName, req.DeviceId)
 if err != nil {
 log.Println(err)
 }
 c.JSON(http.StatusOK, gin.H{"status": http.StatusOK})
}
\`\`\`

\### Data Model
A. 园区省市模式

![image.png](assert/1613187973535-bbfcc6aa-925c-48d4-8a50-886b7faf443b.png)

B. 经纬度地点模式

\- 需要通过 4G 模块上报 GPS 位置

\### Display
![image.png](assert/1613188149016-4c033c66-f189-489a-b747-6946ea35dbf8.png)

\## Resource
适合嵌入 PPT 的代码图片生成

\- [https://codeimg.io/](https://codeimg.io/)
\- [https://carbon.now.sh/](https://carbon.now.sh/)