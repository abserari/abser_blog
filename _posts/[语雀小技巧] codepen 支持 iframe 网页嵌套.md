\## Overview
\> 大家知道我最近写的有关语雀的不少, 今天介绍一个新功能. Codepen 结合 iframe 嵌入各种网页.
\> 同时, ObserveableHQ 是一个 online 的 JS 笔记本, 也提供嵌入方式, 像大家的 BI 工具, 通常也会提供嵌入方式.
\> 大家可以通过这种方式, 嵌入自己的官网, 自己的数据分析页面, 或者自己写的 JS 小应用, 都是非常好玩的.
\> [本博客来源](https://www.yuque.com/abser/solutions/huc6zc),可以在其下留言自己的嵌入页面啦

众所周知，大部分的网站都是不支持 iframe 标签的， 还好语雀支持 codepen 嵌入。

能不能通过 codepen嵌入网页，再通过语雀嵌入codepen展示出来呢？

\## QuickStart
请看下面：
\`\`\`html

\`\`\`
[点击查看【codepen】](https://codepen.io/yhyddr/embed/bGwpgNv)
<a name="Y4cql"></a>
\### FAQ:
虽然我们理论上可以嵌入任何网页, 但是一些网页会拒绝加载在 iframe 标签中, 如果遇到不要惊讶

<a name="d7swk"></a>
\##### 可以用它来干什么!!
<a name="IdwMu"></a>
\## 嵌入自己的数据大屏面板
@pluto-<br />[点击查看【codepen】](https://codepen.io/zhangbokai614/embed/mdObKPy)

\- 刚尝试了一下，把我们的 Dashboard 嵌入了进来，只不过自动变成了手机布局导致比例有点奇怪
<a name="ogqJq"></a>
\## 运行 JS 代码 通过 ObserveableHQ
我们团队一直在使用 ObserveableHQ 作为 JS 的 notebook. ObserveableHQ 可以导出 JS 运行时或者 iframe 的方式嵌入到其他网站, 正好这样能打通我们的需求.

<a name="DeWNB"></a>
\### 语雀知识库中使用浏览器 GPU
下面是我做的 GPU.js 处理视频, 作为嵌入的示例还是不错.<br />[点击查看【codepen】](https://codepen.io/yhyddr/embed/gOwpeYd)
<a name="thFc5"></a>
\### 在语雀上进行机器学习
在语雀中运行 JS 代码, 进行线性回归的模拟.<br />[点击查看【codepen】](https://codepen.io/yhyddr/embed/YzpKvYX)
<a name="9a3b3b9d"></a>
\### 语雀没有的图表? : G6 嵌入
想必语雀的大家都知道 G6 吧<br />[点击查看【codepen】](https://codepen.io/yhyddr/embed/VwmZdQY)

<a name="wfr22"></a>
\## Codepen
不止是 Codepen 本身, 一些在线运行的代码编辑器, 我们可以通过 iframe 标签引入。<br />怎么利用语雀知识库做更有效的教学？有了这些交互性的提升是否能有更有效的方式，希望有同学能够在教学方面的做一些探索分享。