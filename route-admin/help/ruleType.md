### 1. 规则分类

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;系统支持的路由规则有：

- 1 IP区间规则

- 2 参数尾部匹配规则

### 2. IP区间规则

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IP区间规则是指，调用方的IP若属于IP区间内算命中该路由。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 每一个子规则包括：1）IP区间段；2）命中的upstream。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. IP区间段支持IP表达法为IP地址或者数字IP。例如：IP地址 192.168.1.1等价于数字IP 3232235777。IP区间段的2个IP使用“~”分割。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. 多个IP区间子规则使用“|”符号分割，IP子规则的IP区间段和命中的路由使用符号“，”分割。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. IP区间规则对应的多条子规则，IP段不允许重叠，若重叠，表示规则还可以继续简化或者表示规则自身由冲突，因此不支持。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. IP区间规则串举例：192.168.1.1-192.168.1.9,upstream1|192.15.4.10-192.15.4.255,upstream2。该规则表示，若调用方IP在192.168.1.1到192.168.1.9，那么路由为upstream1；若调用方IP在192.15.4.10到192.15.4.255，那么路由为upstream2；否则，那么没有命中该规则。

### 3. 参数尾部匹配规则

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;参数尾部匹配规则是值，请求提取的参数对应的值，若尾部与参数尾部相匹配，那么命中该路由。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 每一个子规则包括：1）参数key；2）尾部长度；3）匹配的尾部数组。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. 匹配的尾部数组的所有长度必须等于尾部长度，否则规则无效。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. 多个子规则使用“|”分割，参数key与尾部长度与匹配的尾部之间分别使用“~”分割，尾部数组的多个尾部使用“，”分割。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. 所有子规则的尾部数组都互不相同，若相同，表示子规则可以简化或者子规则之间相互冲突。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. 参数key与尾部长度构成唯一的键，若不唯一，表示子规则可以简化。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp6. 参数尾部匹配规则举例：mid~3~upstream1,000,001,5DD,003,444,007|instMid~6~upstream2,DEFAULT,123456。该规则表示，若请求的参数mid对应的值的末尾3位在000、001、5DD、003、444、007中，那么命中路由upstream1；若请求的参数instMid对应的值的末尾6位在DEFAULT、123456中，那么命中路由upstream；否则，没有命中该规则。




