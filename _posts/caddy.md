\### GitHub 地址
\- [caddy](https://github.com/caddyserver/caddy/blob/master/README.md)
\- [certmagic](https://github.com/mholt/certmagic)
\> With CertMagic, you can add one line to your Go application to serve securely over TLS, without ever having to touch certificates.
\> Instead of:
\> \*\*\`http.\`\`ListenAndServe\`\`(\`\`":80"\`\`, mux)\`\*\*
\> Use CertMagic:
\> \*\*\`certmagic.\`\`HTTPS\`\`([]\`\`string\`\`{\`\`"example.com"\`\`}, mux)\`\*\*

\### Road

\- [x] [Caddy源码阅读（一）Run详解](https://www.yuque.com/abser/process/ntyfkv)08-28 16:31
\- [x] [Caddy源码阅读（二）启动流程与 Event 事件通知](https://www.yuque.com/abser/process/fz3ngh)08-22 22:31
\- [x] [Caddy源码阅读（三）Caddyfile 解析 by Loader & Parser](https://www.yuque.com/abser/process/nz1nga)08-28 16:32
\- [x] [Caddy源码阅读（四）Plugin & Controller 安装插件](https://www.yuque.com/abser/process/wm4fay)今天 20:25
\- [x] [Caddy源码阅读（五） Instance & Server](https://www.yuque.com/abser/process/bgg20n)今天 20:36
\- [x] [Caddy-plugins（一）如何为 caddy 添写自定义插件](https://www.yuque.com/abser/process/brmghw)08-20 21:47
\- [x] [Caddy-plugins（二）caddy-grpc 反向代理插件例子](https://www.yuque.com/abser/process/exb8es)08-20 21:47
\- [x] [caddy源码全解析（旧版）](https://www.yuque.com/abser/process/ucpear)08-05 00:23
\- [ ] Caddy TLS 最具特点的 Cert Magic

轻松启动 HTTPS 访问和自动续期是之前为人称道的特点

\- Caddy 2
\- [ ] 从插件注册看 Caddy 2 的不同