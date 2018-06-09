### 1. 路由规则

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;路由规则包括以下几部分构成：

- 1 规则唯一标识

- 2 规则逻辑字符串

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;规则逻辑字符串表示了该规则起作用的逻辑，包括如何匹配请求，匹配请求后走的路由等。

- 3 规则优先级

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;规则优先级用非负数表示，值越大优先级越高。

- 4 规则状态

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;打开状态表示规则目前是起作用的，否则该规则暂时不起作用。

- 5 创建时间

- 6 修改时间

### 2. 规则逻辑字符串

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 一般规则逻辑字符串由多个子规则构成，多个子规则之间使用“|”分割。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. 系统能够包含的规则有一个上限，超过该上限后，规则不允许新增加。



