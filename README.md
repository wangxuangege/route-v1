route代码结构
=========================================================

### 1. db
&nbsp;&nbsp;&nbsp;&nbsp;路由规则创建表sql。

### 2. [quickstart](quickstart/README.md)
&nbsp;&nbsp;&nbsp;&nbsp;如何搭建一个最简单的路由架构的平台，包括入口网关配置+应用网关配置+路由规则管理后台配置。

### 3. route-admin
&nbsp;&nbsp;&nbsp;&nbsp;路由规则后台管理平台，由bootstrap模板+lua后台逻辑搭建，其中lua后台逻辑在src/admin下面。

### 4. src
&nbsp;&nbsp;&nbsp;&nbsp;路由的核心逻辑，包括两大部分：

- 1 路由规则后台管理平台

&nbsp;&nbsp;&nbsp;&nbsp;src/admin/Admin.lua

- 2 路由计算逻辑

&nbsp;&nbsp;&nbsp;&nbsp;src/route/Route.lua

&nbsp;&nbsp;&nbsp;&nbsp;详细代码结构如下：
* src
    * __test 单元测试
    * admin 路由规则后台管理平台
        * Admin 路由规则后台管理入口
        * 其他 支持的操作命令
    * constant
        * Config 系统配置
        * Constant 系统常量
        * ErrCode 错误码
    * respository 数据层服务
    * route
        * Route 路由计算逻辑入口
        * RouteContext 路由计算上下文对象
    * rule 路由规则
    * util 工具类相关