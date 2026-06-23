# 户籍管理系统 UML 时序图（PlantUML 统一标准版）

> 本文档包含系统全部12个核心模块的标准PlantUML时序图代码（严格UML生命周期一致版本）

---

## 1. 用户登录 & 权限加载

```plantuml
@startuml

actor 用户
participant 前端
participant LoginController
participant AuthService
participant 校验模块
participant 数据库
participant RBAC
participant Redis
participant 日志

用户 -> 前端 : 登录
前端 -> LoginController : login()

activate LoginController

LoginController -> AuthService
activate AuthService

AuthService -> 校验模块
activate 校验模块
校验模块 --> AuthService
deactivate 校验模块

AuthService -> 数据库
activate 数据库
数据库 --> AuthService
deactivate 数据库

AuthService -> RBAC
activate RBAC
RBAC -> 数据库
数据库 --> RBAC
RBAC --> AuthService
deactivate RBAC

AuthService -> Redis
Redis --> AuthService

AuthService -> 日志
日志 --> AuthService

AuthService --> LoginController
deactivate AuthService

LoginController --> 前端
deactivate LoginController

@enduml
```

---

## 2. 户籍立户申请 & 审核

```plantuml
@startuml

actor 用户
actor 审核员
participant 前端
participant Controller
participant Service
participant 校验
participant 数据库
participant 日志

用户 -> 前端 : 提交立户
前端 -> Controller : submit()

activate Controller

Controller -> Service
activate Service

Service -> 校验
activate 校验
校验 --> Service
deactivate 校验

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 前端
deactivate Controller

@enduml
```

---

## 3. 户口迁入

```plantuml
@startuml

actor 用户
actor 审批员
participant 前端
participant Controller
participant Service
participant 校验
participant 数据库
participant 日志

用户 -> 前端
前端 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> 校验
activate 校验
校验 --> Service
deactivate 校验

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 前端
deactivate Controller

@enduml
```

---

## 4. 户口迁出

```plantuml
@startuml

actor 用户
actor 审核员
participant 前端
participant Controller
participant Service
participant 校验
participant 数据库
participant 日志

用户 -> 前端
前端 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> 校验
activate 校验
校验 --> Service
deactivate 校验

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service --> Controller
deactivate Service

Controller --> 前端
deactivate Controller

@enduml
```

---

## 5. 重点人口管理

```plantuml
@startuml

actor 用户
participant 前端
participant Controller
participant Service
participant 权限系统
participant 数据库
participant 日志

用户 -> Controller

activate Controller

Controller -> 权限系统
activate 权限系统
权限系统 --> Controller
deactivate 权限系统

Controller -> Service
activate Service

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

deactivate Controller

@enduml
```

---

## 6. RBAC角色管理

```plantuml
@startuml

actor 管理员
participant Controller
participant Service
participant 数据库
participant 日志

管理员 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 管理员
deactivate Controller

@enduml
```

---

## 7. 接口权限控制

```plantuml
@startuml

actor 用户
participant 网关
participant 权限服务
participant 数据库
participant Controller

用户 -> 网关

activate 网关

网关 -> 权限服务
activate 权限服务

权限服务 -> 数据库
数据库 --> 权限服务

权限服务 --> 网关
deactivate 权限服务

网关 -> Controller
activate Controller

Controller --> 网关
deactivate Controller

网关 --> 用户
deactivate 网关

@enduml
```

---

## 8. 户籍台账管理

```plantuml
@startuml

actor 用户
participant Controller
participant Service
participant 数据库
participant Redis
participant 日志

用户 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> Redis
Redis --> Service

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 用户
deactivate Controller

@enduml
```

---

## 9. 证件业务管理

```plantuml
@startuml

actor 用户
participant Controller
participant Service
participant 校验
participant 数据库
participant 日志

用户 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> 校验
activate 校验
校验 --> Service
deactivate 校验

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 用户
deactivate Controller

@enduml
```

---

## 10. 日志系统

```plantuml
@startuml

participant 系统
participant LogService
participant 数据库

系统 -> LogService

activate LogService

LogService -> 数据库
activate 数据库
数据库 --> LogService
deactivate 数据库

deactivate LogService

@enduml
```

---

## 11. 菜单管理

```plantuml
@startuml

actor 管理员
participant Controller
participant Service
participant 数据库
participant Redis

管理员 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> Redis
Redis --> Service

Service --> Controller
deactivate Service

Controller --> 管理员
deactivate Controller

@enduml
```

---

## 12. 报表统计分析

```plantuml
@startuml

actor 用户
participant Controller
participant Service
participant 数据库
participant Redis
participant 计算模块
participant 日志

用户 -> Controller

activate Controller

Controller -> Service
activate Service

Service -> Redis
Redis --> Service

Service -> 数据库
activate 数据库
数据库 --> Service
deactivate 数据库

Service -> 计算模块
计算模块 --> Service

Service -> 日志
日志 --> Service

Service --> Controller
deactivate Service

Controller --> 用户
deactivate Controller

@enduml
```

