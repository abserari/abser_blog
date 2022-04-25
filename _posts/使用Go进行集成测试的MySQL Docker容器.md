--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

[原文链接](https://itnext.io/mysql-docker-container-for-integration-testing-using-go-f784b70a03b)                                                                                     作者：Mitesh

[翻译整理](https://abser.top)                                                                                     翻译整理：Abser

\## Overview
Bug 在实际生产中常常代价高昂。我们可以使用测试用例来在开发过程中捕获它们，以降低我们的成本。测试在所有软件中都非常重要。这有助于确保代码的正确性并有助于防止恶化。单元测试有助于隔离测试组件，而无需任何外部依赖。但是单元测试不足以确保我们能够拥有经过良好测试的稳定系统。实际上，在集成不同组件的过程中会发生故障。如果我们不在真实的环境上测试数据库后端的应用程序将面临的问题，我们可能永远不会注意到由于事务未提交，数据库的错误版本等问题。集成测试在端到端测试中扮演了重要角色。

在当今世界，我们编写了许多软件应用程序，其中包含数据库作为存储后端。模拟这些数据库调用以进行单元测试可能很麻烦。在纲要中进行小的更改可能会导致重写部分或全部。因为查询不会连接到实际的数据库引擎，因此不会验证查询的语法或约束。模拟每个查询都可能导致重复工作。为避免这种情况，我们应该测试一个真正的数据库，在测试完成后可以将其销毁。[Docker](https://www.docker.com/) 非常适合运行测试用例，因为我们可以在几秒钟内运行容器并在完成后终止它们。

\### 安装docker
让我们了解如何启动 MySQL docker 容器并使用它来使用 go 代码进行测试。我们首先需要确保运行我们的测试用例的系统安装了 docker，可以通过运行命令“ \*\*docker ps\*\* ” 来检查。如果未安装docker，请从[此处](https://docs.docker.com/install/)安装 docker 。

\`\`\`go
func（d \* Docker）isInstalled（）bool {
 command：= exec.Command（“docker”，“ps”）
 err：= command.Run（）
 if err！= nil {
 return false
 }
 return true
}
\`\`\`

\### 运行容器
安装 docker 之后，我们需要使用用户和密码运行 MySQL 容器，该用户和密码可用于连接 MySQL 服务器。

\`\`\`bash
docker run --name our-mysql-container -e MYSQL\_ROOT\_PASSWORD = root -e MYSQL\_USER = gouser -e MYSQL\_PASSWORD = gopassword -e MYSQL\_DATABASE = godb -p 3306：3306 --tmpfs / var / lib / mysql mysql：5.7
\`\`\`

这将运行 MySQL 版本 5.7 的 docker 镜像，其容器名称为 “our-mysql-container”。“-e” 指定我们需要为 MySQL docker 容器设置的运行时变量。我们将 root 设置为 root 密码。使用密码“gopassword” 创建用户 “gouser”，我们用它来连接到我们的应用程序中的 MySQL 服务器。我们正在暴露 Docker 容器的 3306 端口，所以我们可以连接到在 docker 容器内运行的 mysql 服务器。我们使用的是 [tmpfs mount](https://docs.docker.com/v17.09/engine/admin/volumes/tmpfs/)，它只将数据存储在主机的内存中。当容器停止时，将删除 tmpfs 挂载。因为我们只是进行测试，所以不需要永久存。

\`\`\`go
type ContainerOption struct {
 Name string
 ContainerFileName string
 Options map[string]string
 MountVolumePath string
 PortExpose string
}

func (d \*Docker) getDockerRunOptions(c ContainerOption) []string {
 portExpose := fmt.Sprintf("%s:%s", c.PortExpose, c.PortExpose)
 var args []string
 for key, value := range c.Options {
 args = append(args, []string{"-e", fmt.Sprintf("%s=%s", key, value)}...)
 }

 args = append(args, []string{"--tmpfs", c.MountVolumePath, c.ContainerFileName}...)

 dockerArgs := append([]string{"run", "-d", "--name", c.Name, "-p", portExpose}, args...)
 return dockerArgs
}

func (d \*Docker) Start(c ContainerOption) (string, error) {
 dockerArgs := d.getDockerRunOptions(c)
 command := exec.Command("docker", dockerArgs...)
 command.Stderr = os.Stderr

 result, err := command.Output()
 if err != nil {
 return "", err
 }

 d.ContainerID = strings.TrimSpace(string(result))
 d.ContainerName = c.Name

 command = exec.Command("docker", "inspect", d.ContainerID)
 result, err = command.Output()
 if err != nil {
 d.Stop()
 return "", err
 }
 return string(result), nil
}

func (m \*MysqlDocker) StartMysqlDocker() {
 mysqlOptions := map[string]string{
 "MYSQL\_ROOT\_PASSWORD": "root",
 "MYSQL\_USER": "gouser",
 "MYSQL\_PASSWORD": "gopassword",
 "MYSQL\_DATABASE": "godb",
 }
 containerOption := ContainerOption{
 Name: "our-mysql-container",
 Options: mysqlOptions,
 MountVolumePath: "/var/lib/mysql",
 PortExpose: "3306",
 ContainerFileName: "mysql:5.7",
 }

 m.Docker = Docker{}
 m.Docker.Start(containerOption)
}
\`\`\`

我们可以通过 containerId 检查容器以获取容器的详细信息。

\`\`\`bash
docker inspect containerId
\`\`\`

一旦我们运行 Docker 容器，我们需要等到我们的 docker 容器启动并运行。我们可以使用以下命令检查这个。

\`\`\`basic
docker ps -a
\`\`\`

\### 使用实例

一旦 docker 启动并运行，我们就可以开始在我们的应用程序中使用它来运行真实数据库的集成测试用例。

\`\`\`go
func (d \*Docker) WaitForStartOrKill(timeout int) error {
 for tick := 0; tick < timeout; tick++ {
 containerStatus := d.getContainerStatus()
 if containerStatus == dockerStatusRunning {
 return nil
 }

 if containerStatus == dockerStatusExited {
 return nil
 }
 time.Sleep(time.Second)
 }

 d.Stop()
 return errors.New("Docker faile to start in given time period so stopped")
}

func (d \*Docker) getContainerStatus() string {
 command := exec.Command("docker", "ps", "-a", "--format", "{{.ID}}\|{{.Status}}\|{{.Ports}}\|{{.Names}}")
 output, err := command.CombinedOutput()
 if err != nil {
 d.Stop()
 return dockerStatusExited
 }

 outputString := string(output)
 outputString = strings.TrimSpace(outputString)
 dockerPsResponse := strings.Split(outputString, "\\n")

 for \_, response := range dockerPsResponse {
 containerStatusData := strings.Split(response, "\|")
 containerStatus := containerStatusData[1]
 containerName := containerStatusData[3]

 if containerName == d.ContainerName {
 if strings.HasPrefix(containerStatus, "Up ") {
 return dockerStatusRunning
 }
 }
 }
 return dockerStatusStarting
}
\`\`\`

我们可以使用下面的连接字符串从 go 代码连接到 docker 中运行的 MySQL服 务器。

\`\`\`bash
gouser:gopassword@tcp(localhost:3306)/godb?charset=utf8&parseTime=True&loc=Local
\`\`\`

\### 结束
这些可以在每次运行时重新创建来模拟使用真实数据库运行集成测试。这有助于确保我们的应用程序已准备好进行生产发布。

完整的代码可以在这个git存储库中找到：[https](https://github.com/MiteshSharma/DockerMysqlGo)：[//github.com/MiteshSharma/DockerMysqlGo](https://github.com/MiteshSharma/DockerMysqlGo)