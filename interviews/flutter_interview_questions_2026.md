# Flutter 面试题 2026

## 目录
- [Dart 基础](#dart-基础)
- [Flutter 核心](#flutter-核心)
- [状态管理](#状态管理)
- [Widget & 布局](#widget--布局)
- [路由 & 导航](#路由--导航)
- [网络 & 数据持久化](#网络--数据持久化)
- [性能优化](#性能优化)
- [架构设计](#架构设计)
- [平台集成](#平台集成)
- [测试 & CI/CD](#测试--cicd)
- [2026 新趋势](#2026-新趋势)

---

## Dart 基础

### Q1: Dart 3 的新特性有哪些？
**sealed class、records、pattern matching、destructuring、wildcards。**
- `sealed class` — 限制类继承层次，结合 `switch` 穷举检查
- `records` — 轻量级聚合多个值，替代 `Map`/`List` 传参
- `pattern matching` — `if case`、`switch` 表达式、`for` 解构
- `destructuring` — `var (x, y) = point`
- `wildcards` — `_` 忽略不使用的参数

### Q2: final 和 const 的区别？
- `final` — 运行时常量，赋值后不可变，**只初始化一次**
- `const` — 编译时常量，在编译期就确定值，不可变且**同一对象复用**
- `const` 可用于类级常量、构造函数（`const constructor`）

### Q3: Null safety 的核心概念？
- `?` 可空类型、`!` 强制解包、`??` 空合并、`late` 延迟初始化
- 类型提升（Type Promotion）：局部变量判空后自动转为非空类型
- `required` 参数不可为空

### Q4: Future 和 Stream 的区别？
- `Future` — 一次性异步结果（网络请求、文件读取）
- `Stream` — 多次异步事件序列（WebSocket、按钮点击流）
- `StreamController` 可控制 `Stream` 的添加和关闭

### Q5: Isolate 和 async/await 的区别？
- `async/await` — 单线程内的协程调度，不阻塞 UI，但不利用多核 CPU
- `Isolate` — 独立内存空间的并发执行，通过 `SendPort`/`ReceivePort` 通信
- 计算密集型任务用 `Isolate`（`compute()` 简化用法）

---

## Flutter 核心

### Q6: Widget、Element、RenderObject 三棵树的关系？
- **Widget** — 配置描述（不可变，轻量），每次 build 重建
- **Element** — 中间层，持有 Widget 引用和 RenderObject 引用，管理生命周期
- **RenderObject** — 实际布局和绘制（大小、位置、绘制）
- 流程：Widget → Element → RenderObject，`setState` 触发重建 Widget，Element 比对后决定是否复用 RenderObject

### Q7: Flutter 的渲染管道有几阶段？
1. **Animation** — 动画回调
2. **Build** — 构建 Widget Tree
3. **Layout** — 约束向下传递，尺寸向上返回
4. **Paint** — 绘制到 Layer
5. **Compositing** — 合成 Layer 树
6. **Rasterize** — 栅格化显示

### Q8: Key 的作用和使用场景？
- 唯一标识 Element，帮助框架在 Widget 树变化时正确匹配复用 Element
- `ValueKey` — 值唯一标识
- `ObjectKey` — 对象唯一标识
- `UniqueKey` — 每次都不同（强制重建）
- 场景：列表项增删、状态保持、Form 表单重置

### Q9: BuildContext 是什么？
- Element 的接口，提供访问 Widget 树位置的能力
- 可访问 Theme、MediaQuery、Navigator、InheritedWidget
- **异步后使用 context 需检查 mounted**，否则会报错

### Q10: Hot Reload 和 Hot Restart 的区别？
- **Hot Reload** — 保留状态，注入更新后的 Widget 代码，触发 rebuild（不支持修改 `main()`、`initState()` 等）
- **Hot Restart** — 重新创建整个 App，丢失状态

---

## 状态管理

### Q11: setState 的工作原理？
- 标记当前 State 为 dirty
- 下一帧触发 `build()` 重新渲染
- **问题**：粒度太大，子树全部重建，性能随规模下降

### Q12: Provider、Riverpod、Bloc 怎么选？
| 方案 | 特点 | 适用场景 |
|------|------|---------|
| Provider | 基于 InheritedWidget，简单易用 | 中小项目、学习入门 |
| Riverpod | 编译安全、不依赖 Widget 树、支持自动释放 | 中大型项目、推荐 2026 首选 |
| Bloc | 事件驱动、严格单向数据流、可测试性强 | 大型复杂业务、团队协作 |

### Q13: Riverpod 相比 Provider 的优势？
- 不依赖 `BuildContext`，在异步代码外也可访问
- 编译时错误检查，无运行时 `ProviderNotFoundException`
- `autoDispose` 自动释放资源
- 支持 `family` 参数化、`keepAlive` 生命周期

### Q14: InheritedWidget 的原理？
- 从 `build()` 调用处向上遍历 Element 树查找
- 通过 `dependOnInheritedWidgetOfExactType` 注册依赖
- 被依赖的 Widget 更新时，所有依赖它的子 Widget 自动 rebuild

---

## Widget & 布局

### Q15: Container 和 SizedBox 的区别？
- `Container` — 合成 Widget，包含 padding、margin、decoration、transform 等
- `SizedBox` — 轻量，只强制宽高，无额外开销
- 不需要 decoration 时用 `SizedBox` 性能更好

### Q16: Expanded 和 Flexible 的区别？
- `Expanded` — `Flexible(flex: 1, fit: FlexFit.tight)`，强制子元素填满空间
- `Flexible` — `FlexFit.loose`，子元素可以小于分配的空间
- 用在 Row/Column/Flex 中

### Q17: ListView.builder 和 ListView 的区别？
- `ListView` — 一次性构建所有 item，不适合长列表
- `ListView.builder` — 按需构建可见 item，回收不可见 item，性能好
- 长列表必须用 `.builder` / `.separated`

### Q18: SingleChildScrollView 和 ListView 的区别？
- `SingleChildScrollView` — 单个子 Widget 滚动（表单、长文本）
- `ListView` — 多个同类型 item 滚动列表
- SingleChildScrollView 会一次性 layout 所有子节点，内容极长时性能差

---

## 路由 & 导航

### Q19: Navigator 1.0 和 Navigator 2.0 的区别？
- **1.0** — 命令式 `push`/`pop`，简单直观
- **2.0** — 声明式基于 `Page` 列表，URL 驱动，适合 Web 和深度链接
- `go_router` 基于 2.0 封装，推荐使用

### Q20: go_router 的核心特性？
- 声明式路由配置
- 深度链接支持
- 路由重定向和守卫
- ShellRoute 共享布局
- 类型安全参数传递

---

## 网络 & 数据持久化

### Q21: Dio 的核心功能和拦截器？
- 请求/响应拦截器 — Token 注入、日志、重试
- 转换器 — 请求体序列化、响应体反序列化
- 取消请求 — `CancelToken`
- 文件上传/下载进度回调

### Q22: 数据持久化方案怎么选？
| 方案 | 场景 | 特点 |
|------|------|------|
| SharedPreferences | 简单键值对 | 同步读取、小数据 |
| SQLite / sqflite | 结构化数据 | 关系型、复杂查询 |
| Hive / Isar | 本地 NoSQL | 快、类型安全 |
| Drift (moor) | 复杂本地数据库 | 编译时 SQL 检查 |

---

## 性能优化

### Q23: Flutter 卡顿（jank）的常见原因？
- 不必要的 `setState` / rebuild 范围过大
- 列表不回收（不用 `.builder`）
- 主线程执行耗时操作（JSON 解析、图片解码）
- Build 方法中创建对象或执行 I/O
- `Opacity` / `ClipPath` 在不需要时使用

### Q24: Flutter 性能优化工具有哪些？
- **DevTools** — 性能分析、帧率、内存
- **Flutter Inspector** — Widget 树、rebuild 次数
- **Profile Mode** — 模拟真机性能
- **Raster Metrics** — 检测栅格化瓶颈

### Q25: const widget 对性能的影响？
- `const` widget 在编译期创建，运行时复用同一实例
- `const` 构造函数使 Flutter 跳过 `canUpdate` 的相等检查
- 优先将不依赖运行时状态的 widget 声明为 `const`

### Q26: RepaintBoundary 的作用？
- 将子 widget 隔离到独立的 Layer 中
- 子树变化时不影响父级重绘
- 适用：动画列表项、地图、视频等频繁变化区域

---

## 架构设计

### Q27: Clean Architecture 在 Flutter 中的分层？
```
UI Layer (Widgets)
    ↕
State Management (Provider/Riverpod/Bloc)
    ↕
Domain Layer (Use Cases, Entities)
    ↕
Data Layer (Repositories, Data Sources)
```
- **依赖倒置** — Data 层实现 Domain 层定义的接口
- **单向依赖** — UI → State → Domain → Data

### Q28: Repository Pattern 的作用？
- 屏蔽数据来源（网络 / 本地缓存）
- 统一数据获取接口
- 方便测试（Mock Repository）
- 实现离线优先策略：先读缓存，再请求网络刷新

### Q29: 如何设计离线优先架构？
1. 本地数据库作为单一事实源
2. 先返回缓存数据展示
3. 异步请求网络更新
4. 更新成功后写入本地并刷新 UI
5. 失败时保留缓存数据，队列待重试

---

## 平台集成

### Q30: Platform Channel 通信机制？
```
Flutter (Dart) → MethodChannel → Native (Kotlin/Swift)
```
- `MethodChannel` — 方法调用（请求-响应）
- `EventChannel` — 事件流（原生→Flutter）
- `BasicMessageChannel` — 双向消息
- 数据类型通过 `StandardMessageCodec` 序列化

### Q31: Flutter FFI 的使用场景？
- 直接调用 C/C++ 库（OpenGL、音视频编解码）
- 性能敏感场景（游戏引擎、信号处理）
- 相比 Platform Channel 延迟更低

### Q32: 如何实现 iOS/Android 多渠道打包（Flavor）？
- `--flavor` 参数 + `flavorDimensions`
- Android: `productFlavors` in `build.gradle`
- iOS: Xcode Schemes + Build Configurations
- 配合 `flutter_flavor` 或 `envied` 管理环境变量

---

## 测试 & CI/CD

### Q33: Flutter 测试金字塔？
1. **单元测试** — 测试 Model、Use Case、Repository（最快）
2. **Widget 测试** — 测试单个 widget 的交互和渲染
3. **集成测试** — 测试完整用户流程（`integration_test` 包）

### Q34: Widget 测试如何 Mock 依赖？
- `mockito` + `build_runner` 生成 Mock 类
- 用 `ProviderScope.overrides`（Riverpod）注入 Mock

### Q35: CI/CD 流程包含哪些环节？
- 代码检查（`dart analyze`）
- 单元测试 + Widget 测试
- 构建 iOS Archive / Android AAB
- 发布到 TestFlight / Play Console
- 自动化截图测试（`golden_test`）

---

## 2026 新趋势

### Q36: Impeller 渲染引擎的优势？
- Flutter 新一代渲染引擎，取代 Skia
- 优势：消除首帧卡顿、减少编译着色器的时间
- 更好的动画流畅度、更低的功耗
- iOS 默认启用，Android 可选

### Q37: Dart 宏（Macros）是什么？
- Dart 3 实验特性，编译时代码生成
- 替代部分 `build_runner` 功能（如 JSON 序列化）
- 无需额外构建步骤

### Q38: Flutter 桌面端和 Web 的发展？
- **桌面** — macOS/Linux/Windows 稳定，可用于生产
- **Web** — 适合工具类应用、营销页面，不推荐复杂动画应用
- 大厂案例：Google Earth、Rivian、SHEIN

### Q39: AI 与 Flutter 的结合？
- ML Kit / TensorFlow Lite 集成
- 端侧 LLM 推理（`llama.cpp`）
- 通过 dart:ffi 调用 ONNX Runtime
- 图片识别、语音交互、智能推荐

---

> 参考来源：Flutter Interview Guide 2026、面试鸭、JustAcademy、DistantJob
