\- [关于使用 bufio.Scanner 读取数据](https://studygolang.com/articles/11905)
\- [字符串拼接如何最快](https://gocn.vip/question/265)-gocn
\- [字符串拼接详细比较-reddit](https://www.reddit.com/r/golang/comments/7j65d0/new\_in\_go\_110\_stringsbuilder\_efficiently\_build/)

参考结论 单次调用性能：操作符+>strings.Join>=bytes.Buffer>fmt.Sprintf 灵活性：bytes.Buffer>fmt.Sprintf>=strings.Join>操作符+

\`\`\`go
package main

import (
 "bufio"
 "bytes"
 "fmt"
 "os"
 "strings"
)

func scanandreadandjoin() {
 input := "foo bar baz" // or os.Stdin
 var buf bytes.Buffer
 scanner := bufio.NewScanner(strings.NewReader(input))
 scanner.Split(bufio.ScanWords)
 for scanner.Scan() {
 fmt.Println(scanner.Bytes())
 buf.Write(scanner.Bytes())
 }

 output := buf.Bytes()
 fmt.Println(output, output[0])
}

func main() {
 var buf bytes.Buffer
 scanner := bufio.NewScanner(os.Stdin)
 scanner.Split(bufio.ScanWords)
 for scanner.Scan() {
 fmt.Println(scanner.Bytes())
 buf.Write(scanner.Bytes())
 }

 output := buf.Bytes()
 fmt.Println(output, output[0])
 // scanandreadandjoin()
}
\`\`\`