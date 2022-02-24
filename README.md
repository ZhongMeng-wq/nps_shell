# nps_shell
nps内网穿透简单安装脚本

nps_install.sh 服务器端脚本<br />
npc-install.sj 客户端安装脚本<br />
autonpc 客户端管理脚本<br />

<p style="text-align: center;"><span style="font-size: 24pt;"><strong>此文章关于NPS内外穿透的linux端一键安装脚本，脚本包括服务器端和客户端</strong></span></p>
此脚本包括服务器端和客户端，目前是初次编写，且功能不多，简单编写，代码量只有一两百行而已，新手编写，写的不好见谅。目前为初次测试，可实现功能不多。

介绍一下NPS：

NPS是一款轻量级、高性能、强大的<strong>内网穿透</strong>代理服务器，具有强大的web管理终端。
<ul dir="auto">
 	<li>全面的协议支持，兼容几乎所有常用协议，如tcp、udp、http(s)、socks5、p2p、http代理...</li>
 	<li>全平台兼容（linux、windows、macos、群晖等），支持简单安装为系统服务。</li>
 	<li>全面控制，允许客户端和服务器控制。</li>
 	<li>Https 集成，支持将后端代理和 Web 服务转换为 https，并支持多个证书。</li>
 	<li>只需在 web ui 上进行简单配置即可完成大部分需求。</li>
 	<li>完整的信息展示，如流量、系统信息、实时带宽、客户端版本等。</li>
 	<li>强大的扩展功能，应有尽有（缓存、压缩、加密、流量限制、带宽限制、端口复用等）</li>
 	<li>域名解析具有自定义标头、404页面配置、主机修改、站点保护、URL路由、泛解析等功能。</li>
 	<li>服务器上的多用户和用户注册支持。</li>
</ul>
上述是原作者的介绍，可以去他的<a href="https://github.com/ehang-io/nps">github</a>看看

个人总结：操作简单，适合小白，功能多

[infobox title="NPS服务器"]

&nbsp;

一键安装脚本
<pre class="hl"><code class="">bash &lt;(curl -Ls http://nps.loline.top/shell/fx/nps_install.sh)</code><code class=""></code></pre>
本脚本支持以下功能

一.安装

1.支持大陆和海外双下载模式

2.支持x86、arm64、 arm_v5

二.卸载

此脚本可兼容默认安装(/etc/nps/)

三.修改/查看配置

1.可操作bridge桥协议(tcp|udp)

2.可操作bridge桥端口

3.可操作web管理页面的账号，密码，端口

4.可操作多用户登录，注册，修改用户名

<img class="aligncenter" src="https://blog.loline.top/wp-content/uploads/2022/02/nps1.png" />
<img class="aligncenter" src="https://blog.loline.top/wp-content/uploads/2022/02/nps2.png" />

后续还会更新更多功能

<em><span style="color: #ff0000;">注:某些服务器商的服务器上IP不是公网IP，10，172，192开头的基本都是内网IP</span></em>

[/infobox]

[infobox title="客户端"]

一键脚本
<pre class="hl"><code class="">bash &lt;(curl -Ls http://nps.loline.top/shell/fx/npc-install.sh)</code><code class=""></code></pre>
客户端没事可说的，就简单安装和删除

同样支持大陆和海外下载
<img class="aligncenter" src="https://blog.loline.top/wp-content/uploads/2022/02/npc1.png" />
<img class="aligncenter" src="https://blog.loline.top/wp-content/uploads/2022/02/npc2.png" />

[/infobox]

更多教程见作者<a href="https://ehang-io.github.io/nps/">官方手册</a>

交流QQ群:606080674
