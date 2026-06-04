# Flutter 面试题全集 2026

> 全面覆盖 Dart / Flutter / 状态管理 / 架构 / 性能 / 2026 新趋势
> 目标：大厂中高级 Flutter 岗位面试

## 目录

- [Dart 语言基础](#dart-语言基础)
- [Null Safety 详解](#null-safety-详解)
- [Dart 异步编程](#dart-异步编程)
- [Dart 高级特性](#dart-高级特性)
- [Flutter 三棵树与渲染机制](#flutter-三棵树与渲染机制)
- [Widget 与布局](#widget-与布局)
- [状态管理](#状态管理)
- [路由与导航](#路由与导航)
- [网络与数据持久化](#网络与数据持久化)
- [生命周期](#生命周期)
- [动画](#动画)
- [自定义绘制与 Canvas](#自定义绘制与-canvas)
- [手势与触摸事件](#手势与触摸事件)
- [性能优化](#性能优化)
- [架构设计](#架构设计)
- [平台集成 (Platform Channel)](#平台集成-platform-channel)
- [测试](#测试)
- [CI/CD 与打包发布](#cicd-与打包发布)
- [2026 新趋势](#2026-新趋势)
- [开放性/场景题](#开放性场景题)
- [手写代码题](#手写代码题)

---

## Dart 语言基础

### Q1: Dart 3 的新特性有哪些？请逐一说明。

| 特性 | 说明 | 示例 |
|------|------|------|
| **Records** | 轻量级匿名不可变聚合类型 | `(String name, int age)` |
| **Patterns** | 配合 Records 做模式匹配 | `var (a, b) = (1, 2)` |
| **Sealed Class** | 受限制的继承层次，switch 穷举 | `sealed class Result {}` |
| **Switch 表达式** | switch 可作为表达式返回值 | `return switch (x) { 1 => 'one' };` |
| **Wildcards** | `_` 忽略不使用的变量 | `var (_, y) = point;` |
| **Class Modifiers** | `base` `final` `interface` `mixin` | `base class A {}` |
| **Macros (实验)** | 编译期代码生成，替代 build_runner | `@JsonSerializable()` |

**Sealed class 示例：**
```dart
sealed class NetworkResult {}

class Success<T> extends NetworkResult {
  final T data;
  Success(this.data);
}

class Failure extends NetworkResult {
  final String message;
  Failure(this.message);
}

// switch 必须穷举所有子类，编译期检查
void handleResult(NetworkResult result) => switch (result) {
  Success(data: var d) => print('成功: $d'),
  Failure(message: var m) => print('失败: $m'),
};
```

### Q2: `final` 和 `const` 的区别？

| | final | const |
|--|-------|-------|
| 赋值时机 | 运行时 | 编译期 |
| 可变性 | 不可变（只能赋值一次） | 不可变 |
| 内存 | 每次创建新实例 | 同一值复用（规范化的） |
| 使用位置 | 字段、局部变量 | 常量、构造函数、注解 |

```dart
final now = DateTime.now();  // OK，运行时赋值
const now = DateTime.now();  // 编译错误！DateTime.now() 不是编译时常量

class Foo {
  static const pi = 3.14;         // 正确
  final name = 'Bar';              // 正确
  static final instance = Foo();   // 正确
}
```

### Q3: Dart 中 `??` `?.` `!` `as` 的用法？

```dart
String? nullableString;

// ?. 安全访问
print(nullableString?.length);  // null，不会崩

// ?? 空合并
print(nullableString ?? '默认值');

// ??= 空赋值
nullableString ??= '新值';

// ! 强制解包（断言非空，为 null 会崩）
print(nullableString!.length);

// as 类型转换（失败抛异常）
object as String;

// is / is! 类型检查
if (object is String) { /* 自动类型提升 */ }
```

### Q4: Dart 是值传递还是引用传递？

Dart 中**所有参数都是值传递**，但这个"值"对于对象来说是引用的副本。

```dart
void changeName(Person p) {
  p.name = '新名字';  // 外部对象被修改（引用指向同一对象）
  p = Person('别人'); // 外部不受影响（仅修改了局部引用副本）
}

var person = Person('张三');
changeName(person);
print(person.name); // '新名字'
```

### Q5: Dart 的 `factory` 构造函数有什么用？

- 不总是创建新实例，可以从缓存返回已有实例
- 支持从子类返回实例
- 支持异步初始化（配合 `Future` 但 factory 本身不能异步）

```dart
class Singleton {
  static final Singleton _instance = Singleton._internal();
  Singleton._internal();
  factory Singleton() => _instance;
}

class Cache {
  static final _cache = <String, Cache>{};
  factory Cache(String key) => _cache.putIfAbsent(key, () => Cache._internal(key));
  Cache._internal(this.key);
  final String key;
}
```

### Q6: Dart 中 `mixin` 是什么？和继承的区别？

**mixin** 是一种在多个类层次中重用代码的方式。

```dart
mixin Flyable {
  void fly() => print('飞翔');
}

mixin Swimmable {
  void swim() => print('游泳');
}

class Duck with Flyable, Swimmable {}
```

| | extends | implements | mixin/mixins |
|--|---------|------------|--------------|
| 关系 | 继承一个父类 | 实现接口 | 混入功能 |
| 多个 | ❌ 单继承 | ✅ 多实现 | ✅ 多混入 |
| 方法体 | 可继承/重写 | 必须实现 | 可提供实现 |
| 构造 | 必须调用 super | 无关 | 不能有构造 |

### Q7: `abstract class` 和 `interface`（Dart 3）的区别？

Dart 3 引入 `interface class`：

```dart
// abstract class — 可以有实现，子类用 extends
abstract class Animal {
  void makeSound();  // 抽象方法
  void breathe() => print('呼吸');  // 已有实现
}

// interface class — 只能被 implements，不能被 extends
interface class Drawable {
  void draw();  // 实现类必须重写
}
```

### Q8: `extension` 方法的使用和注意事项？

```dart
extension StringExtension on String {
  bool get isValidEmail => contains('@');
  String get reversed => split('').reversed.join();
}
```

注意：
- 不能访问 `private` 成员
- 同名冲突时，显式指定 `TargetExtension(target).method()`
- 不能声明 `static` 字段（Dart 3.5+ 已支持 `static const`）

### Q9: Dart 的 `typedef` 有哪几种？

```dart
// 函数类型别名
typedef Predicate<T> = bool Function(T value);

// 老式（仅函数）
typedef int Comparator<T>(T a, T b);

// 非函数类型别名（Dart 2.13+）
typedef JsonMap = Map<String, dynamic>;

void main() {
  Predicate<int> isPositive = (x) => x > 0;
  JsonMap data = {'key': 'value'};
}
```

### Q10: Dart 中 `enum` 的增强功能？

Dart 2.17+ enum 支持字段、方法、实现接口：

```dart
enum Status with Comparable<Status> {
  initial(0, '未开始'),
  loading(1, '加载中'),
  success(2, '成功'),
  failure(3, '失败');

  final int code;
  final String label;
  const Status(this.code, this.label);

  bool get isDone => this == success || this == failure;

  @override
  int compareTo(Status other) => code.compareTo(other.code);
}
```

### Q11: `noSuchMethod` 的用途？

拦截对不存在方法的调用，用于代理模式或 Mock：

```dart
class MockProxy {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    print('调用了 ${invocation.memberName}，参数: ${invocation.positionalArguments}');
    return null;
  }
}
```

---

## Null Safety 详解

### Q12: Null Safety 的核心概念？

- `?` — 可空类型：`String?`
- `!` — 强制解包：`str!.length`
- `??` — 空合并：`a ?? b`
- `??=` — 空赋值：`x ??= value`
- `late` — 延迟初始化：`late String name`
- `required` — 命名参数必填
- 类型提升（Type Promotion）

### Q13: `late` 延迟初始化的注意事项？

```dart
late String name;  // 使用时才初始化

// 使用前未赋值 → LateInitializationError
// 常用于：依赖注入、DidChangeDependencies 中初始化
late final String title;  // 只能赋值一次
```

**并发安全：** `late` 不是线程安全的，两个 Isolate 同时访问可能出问题。

### Q14: Dart 的绝对非空类型（Non-nullable by default）对 API 设计的影响？

- 返回值明确标注 `?`，调用者知道可能为 null
- 不再需要 `Optional` 模式
- `Map[key]` 返回 `V?` 而非 `V`（Dart 3 已改）
- `List.firstWhere` 可传 `orElse` 或返回 `T?`

### Q15: 什么是类型提升（Type Promotion）？

```dart
void check(String? text) {
  if (text == null) return;
  print(text.length);  // text 被自动提升为 String（非空）
}

// 多个条件也支持
if (text != null && text.isNotEmpty) { /* 提升 */ }

// 类型提升的限制：类字段不会被提升（局部变量才会）
class Foo {
  String? name;
  void bar() {
    if (name != null) {
      // print(name.length);  // 编译错误！字段不会提升
      print(name!.length);    // 必须用 !
    }
  }
}
```

### Q16: `Object?` 和 `dynamic` 的区别？

```dart
Object? obj = 'hello';     // 可空，但类型已知为 Object?
dynamic dyn = 'hello';     // 完全动态类型，编译期不检查

obj.length;  // 编译错误：Object? 没有 length
dyn.length;  // 编译通过，运行时可能报错

// 正确做法
(obj as String).length;    // OK
```

---

## Dart 异步编程

### Q17: `Future` 的几种创建方式？

```dart
// 1. 直接返回
Future<int> getNumber() async => 42;

// 2. 延时执行
Future.delayed(Duration(seconds: 1), () => 42);

// 3. 异步计算（不阻塞主 Isolate）
Future(() => heavyComputation());  // 调度到事件队列

// 4. 值的 Future
Future.value(42);

// 5. 错误
Future.error(Exception('出错了'));

// 6. 微任务
Future.microtask(() => print('优先执行'));
```

### Q18: `Future.wait`、`Future.any`、`Future.forEach` 的区别？

```dart
// Future.wait — 全部完成后返回
final results = await Future.wait([fetchA(), fetchB()]);

// Future.any — 任意一个完成后立即返回
final first = await Future.any([fetchA(), fetchB()]);

// Future.forEach — 顺序执行
await Future.forEach(items, (item) => process(item));
```

### Q19: `Stream` 的订阅方式有几种？

```dart
// 单订阅 Stream（只能有一个监听器）
StreamController<int>.broadcast();  // 多播

// 常用操作符
stream
  .where((x) => x > 10)
  .map((x) => x.toString())
  .debounce(Duration(milliseconds: 300))
  .distinct()
  .listen(print, onError: (e) {}, onDone: () {});
```

### Q20: `async` 和 `async*` 的区别？

```dart
// async → Future
Future<int> getOne() async => 1;

// async* → Stream
Stream<int> countTo(int n) async* {
  for (var i = 1; i <= n; i++) {
    yield i;  // 产出值
    await Future.delayed(Duration(seconds: 1));
  }
}

// sync* → Iterable (同步生成器)
Iterable<int> range(int n) sync* {
  for (var i = 0; i < n; i++) {
    yield i;
  }
}
```

### Q21: 事件循环（Event Loop）与微任务队列？

```
执行顺序：
1. main() 同步代码
2. 清空微任务队列（MicroTask Queue）
3. 取出一个事件（Event Queue）执行
4. 回到步骤 2
```

```dart
void main() {
  print('1');  // 同步
  Future.microtask(() => print('2'));  // 微任务
  Future(() => print('3'));            // 事件
  print('4');  // 同步
}
// 输出：1 4 2 3
```

### Q22: Isolate 通信方式有哪几种？

```dart
// 1. SendPort / ReceivePort
final receivePort = ReceivePort();
final isolate = await Isolate.spawn(entry, receivePort.sendPort);
receivePort.listen((msg) => print('收到: $msg'));

// 2. compute() 简化版
final result = await compute(heavyFunction, param);

// 3. Isolate.run() (Dart 2.19+)
final result = await Isolate.run(() => heavyComputation());
```

### Q23: `Completer` 的用途和手动控制 Future？

```dart
// 当你有一个回调式 API 需要转为 Future 时
Future<int> waitForCallback() {
  final completer = Completer<int>();
  
  someCallback((result) {
    completer.complete(result);
  }, onError: (e) {
    completer.completeError(e);
  });
  
  return completer.future;
}

// 也可用于延迟 resolve（类似 JS 的 Promise）
final c = Completer<int>();
c.complete(42);   // 手动完成
c.future;         // 获取 Future
```

### Q24: 什么是 Zone？有什么应用场景？

Zone 是 Dart 的异步执行上下文，类似"作用域"，可拦截和修改异步行为。

```dart
// 捕获所有未处理异常
runZonedGuarded(() {
  runApp(MyApp());
}, (error, stack) {
  print('全局异常: $error');
  reportError(error, stack);
});

// 自定义 Zone 值
runZoned(() {
  print(Zone.current['userId']);  // 123
}, zoneValues: {'userId': 123});
```

应用：全局异常捕获、HTTP 请求链路追踪、依赖注入。

---

## Dart 高级特性

### Q25: Dart 的反射（Reflection）有限制吗？

Dart 反射使用 `dart:mirrors`，但 **Flutter 中禁用**（会影响 tree-shaking 和包大小）。替代方案：
- `build_runner` + 代码生成（`json_serializable` `freezed`）
- `reflectable` 库（受限反射）
- `记录（Record）+ Pattern Matching` 替代部分场景

### Q26: `covariant` 关键字的用途？

用于在重写方法时放宽参数类型：

```dart
class Animal {
  void eat(covariant Food food) {}
}
class Dog extends Animal {
  @override
  void eat(DogFood food) {}  // 子类型，不需要 covariant 会报错
}
```

### Q27: Dart 中 `call` 方法是什么？

使类的实例可以像函数一样调用：

```dart
class Adder {
  final int addend;
  Adder(this.addend);
  int call(int value) => value + addend;
}

void main() {
  final add5 = Adder(5);
  print(add5(10));  // 15（看起来像函数调用）
}
```

### Q28: `never` 类型和 `Never` 关键字的用途？

`Never` 表示永远不会正常返回（抛出异常或死循环）：

```dart
Never throwError(String msg) {
  throw Exception(msg);
  // 不需要返回值
}

int parseOrThrow(String input) {
  if (int.tryParse(input) case var n?) {
    return n;
  }
  throwError('解析失败');
  // 这里不需要 return，编译器知道永远不会执行到
}
```

### Q29: 什么是 `late final`？有什么优势？

`late final` 组合了延迟初始化和只赋值一次的特性：

```dart
class ViewModel {
  late final String userId;  // 只能赋值一次

  void init(String id) {
    userId = id;  // 第一次赋值 OK
    // userId = 'other';  // 第二次会抛异常
  }
}
```

用于依赖注入、导航参数初始化等场景。

---

## Flutter 三棵树与渲染机制

### Q30: Widget、Element、RenderObject 三棵树的关系？

```
Widget（配置，不可变，轻量）
   ↓ createElement()
Element（中间层，管理生命周期）
   ↓ createRenderObject() / mount()
RenderObject（布局 + 绘制）
```

- **Widget** — 仅描述配置，每次 `build` 重建，不可变
- **Element** — 持有一个 Widget 引用和一个 RenderObject 引用，负责 diff 和生命周期
- **RenderObject** — 计算布局、执行绘制

**核心流程：**
1. `setState` → 标记 Element dirty
2. 下一帧 `build()` 生成新的 Widget
3. Element 比对新旧 Widget（`canUpdate`）
4. 类型相同 → 更新配置（`updateRenderObject`）
5. 类型不同 → 移除旧 Element，创建新 Element

### Q31: `canUpdate` 的判断逻辑？

```dart
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
```

即：**类型相同且 key 相同**则复用 Element。

### Q32: Element 的生命周期？

```
Widget.createElement() → Element
  ↓ mount()
Child Elements 递归 mount
  ↓ activate()（重新激活，GlobalKey 移动时）
  ↓ deactivate()（移除）
  ↓ unmount()（最终销毁）
```

Key 点：
- 一个 Element 只能有一个 parent
- GlobalKey 允许 Element 在树中移动
- unmount 后不能再次使用

### Q33: RenderObject 的布局流程？

```
Constraints（约束，从父到子）
  ↓
Size（尺寸，从子到父）
  ↓
Offset（偏移，由 parent 在 layout 后设置）
```

```dart
abstract class RenderBox extends RenderObject {
  @override
  void performLayout() {
    // 1. 接收父级约束 constraints
    // 2. 计算自己的尺寸
    // 3. 调用 child.layout() 传入子约束
    // 4. 设置自己的 size
  }
}
```

### Q34: Flutter 的渲染管线？

```
Frame 开始
  ↓
1. Animation — 更新动画值
  ↓
2. Build — 构建/更新 Widget Tree
  ↓
3. Layout — 约束向下传递，尺寸向上返回
  ↓
4. Paint — 绘制 Layer Tree
  ↓
5. Compositing — 合成 Layer 为 Scene
  ↓
6. Rasterize — GPU 栅格化（Platform Thread）
  ↓
Frame 结束（Vsync 信号）
```

### Q35: Widget 的 `canUpdate` 和 Element 的 `update` 区别？

- `canUpdate` — 静态判断，同一位置新旧 Widget 是否能用同一个 Element
- `update` — Element 上更新引用的 Widget，调用 `updateRenderObject`

```dart
class FooElement extends Element {
  @override
  void update(Foo newWidget) {
    super.update(newWidget);  // 更新 _widget
    (renderObject as FooRenderObject).update(newWidget.config);
  }
}
```

### Q36: 什么是 Relayout Boundary 和 Repaint Boundary？

- **Relayout Boundary** — 当父级尺寸变化时，子级不会重新 layout 
  - 自动：`Transform`、`ClipRect`、`SizeChangedLayoutNotifier`
- **Repaint Boundary** — 子级变化不影响父级重绘
  - 手动：`RepaintBoundary` widget
  - 用于：动画列表项、视频播放、地图

### Q37: `GlobalKey` 的内部原理？

```dart
final key = GlobalKey<State<StatefulWidget>>();
```

- GlobalKey 在 Element 树中全局唯一
- 内部维护一个静态 `Map<GlobalKey, Element>` 表
- 当 Element 移动时，Flutter 会先从旧位置 deactivate
- 然后在新位置 activate（而不是重建）
- **影响性能**：每次 builds 都要查找 Map

使用场景：
- Form 校验
- 跨 Widget 访问 State
- AnimatedList
- 保持 TabBarView 状态

---

## Widget 与布局

### Q38: StatelessWidget 和 StatefulWidget 的本质区别？

```dart
// StatelessWidget — 完全由外部配置决定
class TitleText extends StatelessWidget {
  final String text;
  const TitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text);
}

// StatefulWidget — 有可变状态
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}
class _CounterState extends State<Counter> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('$_count'),
    );
  }
}
```

本质区别：**StatefulWidget 有单独的 State 对象 + setState 机制**。State 对象在 Widget 重建时保持。

### Q39: `StatefulWidget` 的生命周期方法？

```
createState()
  ↓
initState()          ← 只调用一次
  ↓
didChangeDependencies()  ← 依赖的 InheritedWidget 变化时
  ↓
build()              ← 可多次调用
  ↓
didUpdateWidget()    ← parent rebuild 传入新 widget 时
  ↓
setState() → build()
  ↓
deactivate()         ← 从树中移除时
  ↓
dispose()            ← 最终销毁
```

### Q40: `const` 构造函数对 Flutter 性能的影响？

```dart
// 好的做法
const Text('Hello');  // 编译期创建，运行时复用

// 不好的做法
Text('Hello');  // 没有 const，每次 build 重建
```

**影响：**
1. `const` Widget 在编译期创建，同一个 const 可以复用实例
2. `const` 构造函数使 `canUpdate` 检查跳过（`operator==` 返回 true）
3. 减少 Widget 创建 → 减少 Element diff 成本

**最佳实践：** 所有不依赖运行时数据的 Widget 都应加 `const`。

### Q41: `Row`、`Column`、`Flex` 的区别？

```dart
Row     → Flex(direction: Axis.horizontal)
Column  → Flex(direction: Axis.vertical)
Flex    → 可自定义 direction
```

内部机制完全相同，都是 `MultiChildRenderObjectWidget` → `RenderFlex`。

### Q42: `Expanded`、`Flexible`、`Spacer` 的区别？

```dart
Row(
  children: [
    Expanded(            // flex: 1, fit: FlexFit.tight（强制填满）
      child: Container(color: Colors.red),
    ),
    Flexible(            // flex: 1, fit: FlexFit.loose（可小于分配空间）
      child: Container(color: Colors.blue),
    ),
    Spacer(),            // Expanded 的别名，无 child
  ],
)
```

### Q43: `MainAxisAlignment` 和 `CrossAxisAlignment` 的理解？

- **MainAxisSize** — 主轴方向（Row 为水平，Column 为垂直）
- **MainAxisAlignment** — 主轴对齐方式
  - `start` `end` `center` `spaceBetween` `spaceAround` `spaceEvenly`
- **CrossAxisAlignment** — 交叉轴对齐方式
  - `start` `end` `center` `stretch` `baseline`

### Q44: `IntrinsicWidth` / `IntrinsicHeight` 的作用和性能问题？

- 强制 widget 在内部确定尺寸（非由父级约束决定）
- **极其耗性能**：需要先对所有子级做一遍 layout 测量

```dart
IntrinsicHeight(  // 所有子项等高
  child: Row(
    children: [card1, card2, card3],
  ),
)
// 在列表中使用会严重卡顿
```

### Q45: `Stack` 和 `Positioned` 的工作原理？

```dart
Stack(
  fit: StackFit.loose,  // 默认
  clipBehavior: Clip.hardEdge,
  children: [
    Positioned(  // 用 left/top/right/bottom 定位
      left: 10, top: 10,
      child: Text('浮层'),
    ),
    Container(),  // 非 Positioned 的子项会按 alignment 对齐
  ],
)
```

- `Stack` 用 `RenderStack` 实现
- 没有 `Positioned` 的子项成为"非定位子项"，影响 Stack 的自身尺寸
- `Positioned` 子项不参与 Stack 尺寸计算

### Q46: `ClipRRect`、`ClipOval`、`ClipPath` 的性能差异？

| 类型 | 性能 | 说明 |
|------|------|------|
| `ClipRRect` | 优 | 圆角矩形，硬件加速友好 |
| `ClipOval` | 中 | 椭圆裁剪 |
| `ClipRect` | 优 | 矩形裁剪 |
| `ClipPath` | 差 | 任意路径，无硬件加速 |

**经验：** 避免在动画或列表中使用 `ClipPath`。

### Q47: `FittedBox` 的工作原理？

```dart
FittedBox(
  fit: BoxFit.contain,  // 类似 CSS object-fit
  alignment: Alignment.center,
  child: Image.asset('...'),
)
```

- 对 child 使用宽松约束，child 会得到自己的尺寸
- 然后根据 `fit` 缩放并放置 child
- 常用于：防止文本溢出、图片适配

### Q48: `Flow` 和 `Wrap` 的区别？

```dart
// Wrap — 自动换行，简单易用
Wrap(
  spacing: 8, runSpacing: 8,
  children: List.generate(20, (i) => Chip(label: Text('Item $i'))),
)

// Flow — 使用 delegate 自定义布局，性能更好
Flow(
  delegate: MyFlowDelegate(),
  children: [...],
)
```

- `Wrap` 适合简单场景，`Flow` 适合高性能自定义换行
- `Flow` 直接操作 `RenderObject`，避免创建额外 Widget

### Q49: `MediaQuery` 和 `LayoutBuilder` 的使用场景？

```dart
// MediaQuery — 获取全局屏幕信息
final width = MediaQuery.of(context).size.width;
final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

// LayoutBuilder — 获取父级约束
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

- `MediaQuery` 从 InheritedWidget 获取，整个子树共享
- `LayoutBuilder` 接收父级约束，每次约束变化时重建

### Q50: OrientationBuilder 的使用？

```dart
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.portrait
        ? PortraitLayout()
        : LandscapeLayout();
  },
)
```

与 `MediaQuery.of(context).orientation` 的区别：
- `OrientationBuilder` 只在方向变化时 rebuild
- 不会因其他 MediaQuery 变化（如键盘弹出）触发 rebuild

---

## 状态管理

### Q51: `setState` 的缺点？

1. **粒度粗** — 整个 `build` 方法重新执行
2. **Prop Drilling** — 状态深传需层层传参
3. **不可复用** — 状态和 UI 耦合在同一个 State 中
4. **跨组件通信难** — 兄弟组件、远亲组件
5. **无副作用管理** — 没有拦截或中间件机制

### Q52: InheritedWidget 原理及自定义？

```dart
class MyTheme extends InheritedWidget {
  final ThemeData theme;
  const MyTheme({
    super.key,
    required this.theme,
    required super.child,
  });

  // 供子 Widget 访问
  static MyTheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<MyTheme>();
    assert(result != null, 'No MyTheme found');
    return result!;
  }

  @override
  bool updateShouldNotify(MyTheme oldWidget) => theme != oldWidget.theme;
}

// 使用
final theme = MyTheme.of(context).theme;
```

**核心：** `dependOnInheritedWidgetOfExactType` 注册依赖 → 父 Widget 变化时自动 rebuild。

### Q53: Provider 的实现原理？

```dart
// Provider 核心实现简化版
class Provider<T> extends InheritedWidget {
  final T value;
  final Widget child;

  static T of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider<T>>()!.value;
  }
}

// ChangeNotifierProvider
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  // 监听 ChangeNotifier → 调用 setState
}
```

流程：ChangeNotifierProvider → 监听 ChangeNotifier → 调用 `setState` → `InheritedWidget` 更新 → 所有 `context.watch<T>()` 的地方 rebuild。

### Q54: Riverpod 的核心概念和原理？

```dart
// Provider 声明
final counterProvider = StateProvider<int>((ref) => 0);
final userProvider = FutureProvider<User>((ref) => fetchUser());
final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(() => TodoNotifier());

// 使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}
```

**核心原理：**
- 使用 `dart:collection` 的 `HashMap` 管理所有 provider 实例
- 通过 Element 树的 `_Ref` 对象关联 Provider 和 Widget
- `ref.watch` 注册依赖，provider 变化时通知所有监听者
- `autoDispose` 用 `ReferenceCounter` 实现

**和 Provider 的关键区别：**
- 不依赖 `BuildContext`
- 编译时安全（provider 类型错误在编译时报错）
- 支持不同作用域（family, autoDispose）

### Q55: Bloc 的核心思想和适用场景？

```dart
// Event
sealed class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}

// Bloc
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}

// UI
BlocBuilder<CounterBloc, int>(
  builder: (context, count) => Text('$count'),
)
```

**适用场景：**
- 复杂业务逻辑（表单验证、支付流程）
- 需要可测试的状态逻辑
- 团队协作大项目
- 需要事件追踪（日志、Analytics）

**优势：** 严格单向数据流、可测试性强、与 UI 完全解耦

### Q56: GetX 为什么受争议？有什么优缺点？

**优点：**
- 上手快，代码量少
- 内置路由、依赖注入、状态管理、国际化
- 性能好（无需 BuildContext）

**缺点：**
- 侵入性强，全局污染
- 不可测试（全局静态方法）
- 缺少类型安全
- 维护不活跃，API 不稳定
- 大团队协作困难

### Q57: Flutter 状态管理选型建议 (2026)？

| 项目规模 | 推荐方案 | 理由 |
|---------|---------|------|
| 小型 / MVP | Provider / StatefulWidget | 简单够用 |
| 中型 | Riverpod | 类型安全、灵活 |
| 大型复杂 | Riverpod 或 Bloc | 可维护、可测试 |
| 已有 Bloc | Bloc | 不推荐迁移 |
| 已有 GetX | GetX | 不推荐迁移 |
| 新项目 | Riverpod | 社区推荐，2026 首选 |

### Q58: `ValueNotifier` 和 `ChangeNotifier` 的区别？

```dart
// ValueNotifier — 单一值监听
final count = ValueNotifier<int>(0);
count.addListener(() => print(count.value));
count.value = 1;  // 触发通知

// ChangeNotifier — 多个属性变化
class UserModel extends ChangeNotifier {
  String _name = '';
  int _age = 0;
  
  String get name => _name;
  int get age => _age;
  
  void updateName(String name) {
    _name = name;
    notifyListeners();  // 手动通知
  }
}
```

### Q59: 什么是状态提升（Lifting State Up）？

```dart
// 子 → 父通信：通过回调把状态放到父级
class Parent extends StatefulWidget {
  @override
  _ParentState createState() => _ParentState();
}
class _ParentState extends State<Parent> {
  String _sharedText = '';  // 提升到父级

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChildA(text: _sharedText),
        ChildB(onChanged: (v) => setState(() => _sharedText = v)),
      ],
    );
  }
}
```

使用场景：兄弟组件共享状态。

---

## 路由与导航

### Q60: Navigator 1.0 和 Navigator 2.0 的架构区别？

| 特性 | Navigator 1.0 | Navigator 2.0 |
|------|--------------|--------------|
| 范式 | 命令式（push/pop） | 声明式（Page 列表） |
| 路由配置 | 分散在各处 | 集中管理 |
| 深度链接 | 不支持 | 原生支持 |
| Web URL | 不匹配 | 自动同步 URL |
| 复杂度 | 简单 | 高 |

### Q61: go_router 的核心特性？

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) => DetailPage(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final loggedIn = /* ... */;
    if (!loggedIn) return '/login';
    return null;
  },
);
```

**特性：**
- `ShellRoute` 共享底部导航、侧边栏布局
- `redirect` 路由守卫（鉴权、A/B 测试）
- 参数化路径（`pathParameters` `queryParameters`）
- 深度链接 + Web URL 自动同步
- 类型安全参数（`@PathParam` 或 `extra`）

### Q62: 命名路由（Named Route）的缺点？

```dart
// 旧式命名路由
routes: {
  '/home': (context) => HomePage(),
  '/detail': (context) => DetailPage(),
}

// MaterialPageRoute
Navigator.pushNamed(context, '/detail', arguments: {'id': 1});
```

**缺点：**
1. 非类型安全 — 参数用 `arguments` 需手动强转
2. 编译期不可检查 — 拼错路由名运行时报错
3. 参数传递隐形 — 调用方不知道需要什么参数
4. 无法在构造函数中接收参数

### Q63: `onGenerateRoute` 的作用？

```dart
MaterialApp(
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/detail':
        final id = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => DetailPage(id: id));
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  },
)
```

- 统一的路由工厂
- 可处理未知路由（返回 404 页面）
- 结合 `initialRoute` 可接收外部 deep link

### Q64: `PageRouteBuilder` 自定义转场动画？

```dart
Navigator.push(context, PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => DetailPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  },
  transitionDuration: const Duration(milliseconds: 300),
));
```

---

## 网络与数据持久化

### Q65: Dio 拦截器的执行顺序？

```dart
// 注册顺序
dio.interceptors.addAll([
  LogInterceptor(),      // 1
  AuthInterceptor(),     // 2
  RetryInterceptor(),    // 3
]);

// 请求拦截器执行顺序：1 → 2 → 3
// 响应拦截器执行顺序：3 → 2 → 1（栈式）
```

实现原理：拦截器形成链表，`handler.next()` 传递到下一个。

### Q66: 如何处理 Token 过期自动刷新？

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${storage.getToken()}';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 1. 刷新 Token
      await refreshToken();
      // 2. 重试原请求
      final retryResponse = await _retry(err.requestOptions);
      handler.resolve(retryResponse);
      return;
    }
    handler.next(err);
  }
}
```

**注意：** 并发请求时 Token 过期会导致多个 401，需要用 `Completer` 做合并刷新（Token 锁）。

### Q67: Flutter 中数据持久化方案对比？

| 方案 | 类型 | 速度 | 适用场景 |
|------|------|------|---------|
| SharedPreferences | 键值对 | 快 | 简单配置、用户偏好 |
| File（JSON/TXT） | 文件 | 中 | 少量结构化数据 |
| sqflite / Drift | SQLite | 中 | 复杂关系型数据 |
| Isar | NoSQL | 极快 | 高性能本地存储 |
| Hive | NoSQL | 快 | 纯 Dart，无原生依赖 |
| ObjectBox | NoSQL | 极快 | 大量数据、IoT |

**推荐 (2026)：**
- 简单配置：`SharedPreferences` + `shared_preferences` 或 `flutter_secure_storage`（敏感数据）
- 复杂数据：`Isar` 或 `Drift`
- 需要搜索：`Drift`

### Q68: `cached_network_image` 的缓存机制？

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheKey: 'unique_key',  // 自定义缓存 key
  placeholder: (_, __) => CircularProgressIndicator(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
  memCacheWidth: 200,  // 按需解码，减少内存
  memCacheHeight: 200,
)
```

**缓存策略：**
1. 内存缓存（LRU，默认 1000 张）
2. 磁盘缓存（默认 250MB）
3. HTTP 缓存头（`Cache-Control`）

### Q69: WebSocket 在 Flutter 中的使用？

```dart
final channel = WebSocketChannel.connect(
  Uri.parse('ws://example.com/ws'),
);

// 发送
channel.sink.add('{"type": "ping"}');

// 接收
channel.stream.listen(
  (data) => print('收到: $data'),
  onError: (error) => print('错误: $error'),
  onDone: () => print('连接关闭'),
);

// 断开
channel.sink.close();
```

---

## 生命周期

### Q70: Flutter App 的应用生命周期（AppLifecycleState）？

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:   // 回到前台
      case AppLifecycleState.inactive:  // 半激活（来电、控制中心）
      case AppLifecycleState.paused:    // 进入后台
      case AppLifecycleState.detached:  // 应用即将被销毁
    }
  }
}
```

| 状态 | 含义 | 常见操作 |
|------|------|---------|
| `resumed` | 用户可见可交互 | 恢复定时器、WebSocket 重连 |
| `paused` | 进入后台 | 保存草稿、暂停动画 |
| `detached` | 引擎分离 | 释放资源 |

### Q71: WidgetsBindingObserver 还能监听什么？

```dart
class Observer extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void didChangeAccessibilityFeatures() {}  // 无障碍功能变化

  @override
  void didChangeLocales(List<Locale>? locales) {}  // 系统语言变化

  @override
  void didChangeMediaQuery(MediaQueryData old) {}  // 系统字体大小等

  @override
  void didChangePlatformBrightness() {}  // 深色模式切换

  @override
  void didHaveMemoryPressure() {}  // 系统内存不足

  @override
  bool handlePopRoute() => true;  // Android 返回键
}
```

### Q72: `RouteAware` 监听页面路由？

```dart
class _MyPageState extends State<MyPage> with RouteAware {
  @override
  void didPush() {}       // 推入栈
  @override
  void didPopNext() {}    // 从下个页面返回
  @override
  void didPushNext() {}   // 推入下个页面（本页面不可见）
  @override
  void didPop() {}        // 从栈中弹出

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver.of(context).subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    RouteObserver.of(context).unsubscribe(this);
    super.dispose();
  }
}
```

用途：埋点统计、页面可见性管理。

### Q73: `TickerProvider` 的作用？

```dart
class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,  // 提供 Ticker
      duration: Duration(seconds: 1),
    );
  }
}
```

`Ticker` 是 Flutter 帧同步信号，每帧回调一次。`SingleTickerProviderStateMixin` 适用于一个 `AnimationController`，`TickerProviderStateMixin` 适用于多个。

---

## 动画

### Q74: AnimationController 的常用方法？

```dart
final controller = AnimationController(
  vsync: this,
  duration: Duration(seconds: 1),
  value: 0.0,    // 初始值
  lowerBound: 0,  // 下限
  upperBound: 1,  // 上限
);

controller.forward();      // 正向播放
controller.reverse();      // 反向播放
controller.repeat();       // 循环
controller.animateTo(0.5); // 跳转到指定位置
controller.stop();         // 停止
controller.reset();        // 重置到 lowerBound
controller.dispose();      // 释放
```

### Q75: `Tween` 和 `Curve` 的作用？

```dart
// Tween — 定义值的变化范围
final tween = Tween<double>(begin: 0, end: 100);
final colorTween = ColorTween(begin: Colors.red, end: Colors.blue);

// Animatable 组合
final sizeTween = Tween<double>(begin: 50, end: 200);
final curve = Curves.easeInOut;

// 应用曲线
final curvedAnimation = CurvedAnimation(
  parent: controller,
  curve: Curves.easeInOut,
);
```

**原理：** `AnimationController` 输出 0.0 ~ 1.0 的线性值，`Tween` 映射到目标范围，`Curve` 改变时间映射。

### Q76: `AnimatedBuilder` 和 `AnimatedWidget` 的区别？

```dart
// AnimatedBuilder — 不需要自定义 Widget
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: controller.value * 2 * pi,
      child: child,  // child 不会 rebuild
    );
  },
  child: Icon(Icons.refresh),
);

// AnimatedWidget — 抽离为独立 Widget
class RotatingIcon extends AnimatedWidget {
  const RotatingIcon({super.key, required super.listenable});
  
  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(
      angle: animation.value * 2 * pi,
      child: Icon(Icons.refresh),
    );
  }
}
```

### Q77: Flutter 隐式动画 Widget 有哪些？

```dart
AnimatedContainer(    // 容器属性变化动画
  duration: Duration(milliseconds: 300),
  width: isExpanded ? 200 : 100,
  color: isActive ? Colors.blue : Colors.grey,
)

AnimatedOpacity(      // 透明度变化
  duration: Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
)

AnimatedPadding(
  duration: Duration(milliseconds: 300),
  padding: EdgeInsets.all(isExpanded ? 20 : 5),
)

AnimatedPositioned(   // 在 Stack 中
  duration: Duration(milliseconds: 300),
  left: isExpanded ? 100 : 0,
  top: isExpanded ? 100 : 0,
)

// 还有 AnimatedCrossFade, AnimatedSwitcher, TweenAnimationBuilder
```

**原理：** 内部维护一个隐式 `AnimationController`，属性变化时自动驱动动画。

### Q78: `Hero` 动画的实现原理？

```dart
// 页面 A
Hero(
  tag: 'avatar',  // 唯一标签
  child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(url)),
)

// 页面 B
Hero(
  tag: 'avatar',
  child: CircleAvatar(radius: 100, backgroundImage: NetworkImage(url)),
)
```

**原理：**
1. 源页面 Hero 在离开屏幕时被"快照"
2. Flutter 在两个页面间寻找相同 `tag` 的 Hero
3. 在 `Overlay` 层插值过渡
4. 目标页面 Hero 从快照位置飞到最终位置

### Q79: `Staggered Animation`（交错动画）的实现？

```dart
class _StaggeredWidgetState extends State<StaggeredWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _opacity = Tween(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.4)),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.5), end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.6)));

  // 不同 Interval 实现交错
}
```

### Q80: 如何做高性能列表动画（`AnimatedList` 或自定义）？

```dart
// 1. AnimatedList
final key = GlobalKey<AnimatedListState>();

AnimatedList(
  key: key,
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(title: Text(items[index])),
    );
  },
)

// 添加
key.currentState!.insertItem(index);

// 2. 更复杂的动画可用 SliverAnimatedList
```

---

## 自定义绘制与 Canvas

### Q81: `CustomPainter` 的基本用法？

```dart
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);
    canvas.drawRect(Rect.fromLTWH(10, 10, 100, 100), paint);
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) => true;
}

// 使用
CustomPaint(painter: MyPainter(), size: Size(200, 200))
```

### Q82: Canvas 常用绘制方法？

```dart
canvas.drawLine(Offset p1, Offset p2, Paint paint);
canvas.drawCircle(Offset center, double radius, Paint paint);
canvas.drawRect(Rect rect, Paint paint);
canvas.drawRRect(RRect rrect, Paint paint);
canvas.drawOval(Rect rect, Paint paint);
canvas.drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint);
canvas.drawPath(Path path, Paint paint);
canvas.drawImage(Image image, Offset offset, Paint paint);
canvas.drawParagraph(Paragraph paragraph, Offset offset);
canvas.clipRect(Rect rect);
canvas.clipRRect(RRect rrect);
canvas.clipPath(Path path);
canvas.save();
canvas.translate(double dx, double dy);
canvas.rotate(double radians);
canvas.scale(double sx, [double sy]);
canvas.restore();
```

### Q83: `Path` 常用操作？

```dart
final path = Path()
  ..moveTo(50, 0)           // 移动到起点
  ..lineTo(100, 100)        // 画直线
  ..quadraticBezierTo(150, 0, 200, 100)  // 二次贝塞尔
  ..cubicTo(250, 150, 300, 50, 350, 100) // 三次贝塞尔
  ..close();                // 闭合路径

path.addRect(Rect.fromLTWH(0, 0, 50, 50));
path.addOval(Rect.fromCircle(center: Offset(100, 100), radius: 50));

// 判断包含
path.contains(Offset(60, 60));

// 路径测量
final metrics = PathMetrics();
```

### Q84: `RepaintBoundary` 与 `CustomPainter` 配合优化？

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: MyPainter(),
        size: Size(200, 200),
      ),
    );
  }
}
```

当 `MyPainter` 频繁更新时，`RepaintBoundary` 确保只有它自己重绘，不影响父级。

### Q85: `ClipPath` 的实现？

```dart
ClipPath(
  clipper: TriangleClipper(),
  child: Container(width: 100, height: 100, color: Colors.blue),
)

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant TriangleClipper oldClipper) => false;
}
```

---

## 手势与触摸事件

### Q86: GestureDetector 和 InkWell 的区别？

| | GestureDetector | InkWell |
|--|----------------|---------|
| 水波纹效果 | ❌ | ✅ |
| 手势类型 | 所有手势 | Tap + LongPress |
| 无障碍 | 需手动配 | 默认支持 |
| 使用场景 | 非 Material 组件 | Material Design 组件 |

### Q87: GestureRecognizer 的类型？

```dart
// 常用 GestureRecognizer
TapGestureRecognizer
DoubleTapGestureRecognizer
LongPressGestureRecognizer
PanGestureRecognizer      // 拖动
ScaleGestureRecognizer    // 缩放
VerticalDragGestureRecognizer
HorizontalDragGestureRecognizer
ForcePressGestureRecognizer  // 3D Touch

// 自定义手势
class MyGestureRecognizer extends OneSequenceGestureRecognizer {
  @override
  void addPointer(PointerEvent event) {}
  @override
  String get debugDescription => 'MyGesture';
}
```

### Q88: 手势冲突的解决？

```dart
// 场景：ListView 中的横向滑动卡片
GestureDetector(
  onHorizontalDragUpdate: (details) {
    // 横向滑动
  },
  child: ListView(
    // 纵向滚动
  ),
)

// 解决方案 1：设置 GestureRecognizer 的 GestureSettings
// 解决方案 2：使用 Listener + 手动判断
Listener(
  onPointerMove: (event) {
    if (event.delta.dx.abs() > event.delta.dy.abs()) {
      // 横向
    } else {
      // 纵向
    }
  },
)

// 解决方案 3：GestureDetector 的 behavior 参数
behavior: HitTestBehavior.opaque,  // 阻止事件传递
```

### Q89: `HitTestBehavior` 各个值的区别？

```dart
GestureDetector(
  behavior: HitTestBehavior.deferToChild,  // 默认：只响应子区域
  behavior: HitTestBehavior.opaque,        // 整个区域都响应
  behavior: HitTestBehavior.translucent,   // 整个区域响应，但不阻止事件穿透
)
```

### Q90: `AbsorbPointer` 和 `IgnorePointer` 的区别？

```dart
AbsorbPointer(    // 吸收事件，子级也不可点击
  absorbing: true,
  child: Button(),
)

IgnorePointer(    // 忽略事件，子级可以单独处理
  ignoring: true,
  child: Button(),
)
```

- `AbsorbPointer` — 事件在此被吸收，不往下传
- `IgnorePointer` — 事件穿透此 Widget，子级可通过 `ignoringSemantics: false` 接收

### Q91: `Draggable` 和 `DragTarget` 的使用？

```dart
Draggable<int>(
  data: 42,
  feedback: Material(child: Container(width: 50, height: 50, color: Colors.blue)),
  childWhenDragging: Opacity(opacity: 0.5, child: child),
  child: child,
)

DragTarget<int>(
  onAcceptWithDetails: (details) {
    print('收到: ${details.data}');
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
    );
  },
)
```

---

## 性能优化

### Q92: Flutter 卡顿（Jank）的根因排查？

**典型原因：**
1. **Widget build 过重** — build 方法内有 I/O、JSON 解析
2. **列表未使用 `builder`** — 一次性构建全部 item
3. **主线程阻塞** — 大文件读取、复杂计算
4. **图片过大** — 未按显示尺寸解码
5. **Shader 编译卡顿** — 首次动画卡（Impeller 已解决）
6. **Overdraw** — 多层半透明叠加
7. **Opacity 滥用** — 用 `ColourFiltered` 或直接改颜色替代

### Q93: 列表性能优化的关键点？

```dart
// 1. 必须用 builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// 2. 固定 item 高度
SizedBox(
  height: 500,
  child: ListView.builder(
    itemExtent: 80,  // 固定高度 → 跳过布局计算
    itemBuilder: ...,
  ),
)

// 3. 使用 const 或自动 keepAlive
// 4. 图片按需解码
// 5. 避免 Item 中有 Save/Rebuild
```

### Q94: `const` widget 的性能原理？

```dart
// 编译期
const Text('Hello');  // 存储在常量池，运行时复用

// 运行时
Text('Hello');  // 每次 build 创建新实例

// 区别：
// const → canUpdate 中 operator== 返回 true（相同引用）
// 非 const → 每次都新实例，operator== 返回 false，Element 需更新
```

### Q95: `ShaderMask` 和 `Opacity` 的性能影响？

```dart
// ❌ 不好
Opacity(
  opacity: 0.5,
  child: ComplexWidget(),
)

// ✅ 更好
ColoredBox(
  color: Colors.white.withOpacity(0.5),
  child: ComplexWidget(),
)

// ❌ 需要避免在动画中频繁用
// 用 AnimatedOpacity 替代
```

**原理：** `Opacity` 需要将子 widget 绘制到离屏 buffer 再合成，增加 GPU 开销。

### Q96: 图片加载优化策略？

```dart
// 1. 按显示尺寸解码
Image.network(
  url,
  cacheWidth: 200,   // 解码时就缩放到 200px
  cacheHeight: 200,
)

// 2. 使用 cached_network_image
// 3. 预缓存
await precacheImage(NetworkImage(url), context);

// 4. 占位图避免布局偏移
// 5. WebP 格式（比 PNG/JPG 小 30%）
// 6. 图片 CDN 裁剪参数
```

### Q97: DevTools 性能分析工具使用？

| 工具 | 用途 |
|------|------|
| **Flutter Inspector** | Widget 树、rebuild 次数 |
| **Performance** | 帧率、Build/Layout/Paint 耗时 |
| **CPU Profiler** | 方法耗时 |
| **Memory** | 内存泄漏、GC 频率 |
| **Network** | HTTP 请求 |
| **App Size** | 包体积分析 |
| **Raster Metrics** | GPU 栅格化瓶颈 |

### Q98: `shouldRepaint` 和 `shouldRebuild` 的优化？

```dart
class MyPainter extends CustomPainter {
  final Color color;

  @override
  void paint(Canvas canvas, Size size) { /* 绘制 */ }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return color != oldDelegate.color;  // 颜色不变就不用重绘
  }
}
```

### Q99: 内存泄漏常见场景和排查？

**常见泄漏：**
1. `AnimationController` 未 `dispose()`
2. `StreamSubscription` 未 `cancel()`
3. `Timer` 未 `cancel()`
4. `BuildContext` 在异步回调中使用（需检查 `mounted`）
5. 闭包持有大对象引用
6. `GlobalKey` 未释放

**排查：**
- DevTools Memory 页拍快照对比
- 反复进入退出页面，观察内存是否持续增长
- `flutter run --profile` 分析

### Q100: 包体积优化策略？

| 策略 | 效果 |
|------|------|
| `--split-debug-info` | 减小 APK |
| `--obfuscate` | 混淆+减小 |
| |--target-platform android-arm,android-arm64` | 只保留 arm64 |
| 图片用 WebP | 减小 30% |
| 移除未使用的字体和包 | — |
| 使用 deferred loading | 按需加载 |
| 移除 unused import | — |

```
flutter build apk --split-debug-info=build/debug-info --obfuscate --target-platform android-arm64
```

### Q101: `compute` 和 Isolate 的使用注意？

```dart
// compute 的使用限制：
// - 参数只能传一个（用 Record 包裹多个参数）
// - 函数必须是顶级函数或静态方法
// - 不能传闭包、不能传 Flutter 对象

// ✅ 正确
int heavyWork(int n) => /* 计算 */;
final result = await compute(heavyWork, 100);

// ❌ 错误
final result = await compute((n) => n + 1, 100);  // 不能传匿名函数
```

---

## 架构设计

### Q102: Clean Architecture 在 Flutter 中的目录结构？

```
lib/
├── core/                    # 通用工具、常量、网络
│   ├── constants/
│   ├── network/
│   ├── theme/
│   └── utils/
├── data/                    # 数据层
│   ├── datasources/         # 数据源（远程/本地）
│   ├── models/              # 数据模型（fromJson/toJson）
│   └── repositories/        # 仓库实现
├── domain/                  # 领域层
│   ├── entities/            # 实体
│   ├── repositories/        # 仓库接口（抽象）
│   └── usecases/            # 用例
└── presentation/            # UI 层
    ├── providers/           # 状态管理
    ├── pages/               # 页面
    └── widgets/             # 组件
```

**依赖规则：** 外层依赖内层，内层不依赖外层。

### Q103: Repository Pattern 的实现？

```dart
// Domain 层定义接口
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
}

// Data 层实现
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  final UserLocalDataSource local;

  @override
  Future<User> getUser(String id) async {
    try {
      final user = await remote.getUser(id);
      await local.saveUser(user);  // 缓存
      return user;
    } catch (e) {
      return await local.getUser(id);  // fallback 到缓存
    }
  }
}
```

### Q104: 依赖注入（DI）在 Flutter 中的实现？

```dart
// 手动注入（无第三方库）
class AppDependencies {
  static final api = Dio(BaseOptions(baseUrl: '...'));
  static final repository = UserRepositoryImpl(api);
}

// get_it 注入
final sl = GetIt.instance;
void setupDependencies() {
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerFactory<UserRepository>(() => UserRepositoryImpl(sl()));
}

// Riverpod 注入
final dioProvider = Provider<Dio>((ref) => Dio());
final userRepoProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(dioProvider));
});
```

### Q105: MVC、MVP、MVVM 在 Flutter 中的体现？

| 模式 | Flutter 对应 |
|------|------------|
| **MVC** | Model = 数据模型，View = Widget，Controller = StatefulWidget State |
| **MVP** | Presenter = Bloc/ChangeNotifier |
| **MVVM** | ViewModel = 状态管理 Provider/Riverpod |

Flutter 本质是 **V + VM 绑定**，Widget = View + ViewModel（状态驱动 UI）。

### Q106: 离线优先（Offline First）架构？

```dart
class OfflineFirstRepository {
  final LocalDataSource local;
  final RemoteDataSource remote;

  Future<List<Item>> getItems() async {
    // 1. 先返回本地数据
    final localItems = await local.getItems();
    
    // 2. 异步请求远程
    try {
      final remoteItems = await remote.getItems();
      await local.saveItems(remoteItems);
      return remoteItems;  // 更新
    } catch (e) {
      return localItems;   // 失败用缓存
    }
  }
}
```

**关键：**
- 本地数据库为单一事实源
- 同步时用 `Conflict Resolution`（时间戳/版本号）
- 写操作先写本地再同步（无网络时队列）

### Q107: 模块化/组件化方案？

```dart
// 按功能模块分包
lib/
├── features/
│   ├── auth/           # 登录注册
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   └── profile/
├── shared/
│   ├── widgets/
│   └── utils/
└── core/
```

更复杂的项目可以用 `module` 包 + 路由解耦：

```dart
abstract class AuthModule {
  static Widget get loginPage => const LoginPage();
  static GoRoute get route => GoRoute(path: '/login', builder: (_, __) => LoginPage());
}
```

### Q108: 错误处理策略？

```dart
// 统一错误类型
sealed class Failure {
  final String message;
  const Failure(this.message);
}
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// UseCase 返回类型
class Result<T> {
  final T? data;
  final Failure? failure;
  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;
}

// UI 层处理
state.when(
  data: (items) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (failure) => ErrorWidget(failure.message),
);
```

---

## 平台集成 (Platform Channel)

### Q109: MethodChannel 与 EventChannel 的区别？

```dart
// MethodChannel — 请求-响应
static const channel = MethodChannel('com.example/channel');
final result = await channel.invokeMethod('getData', {'key': 'value'});

// EventChannel — 持续事件流
static const channel = EventChannel('com.example/events');
channel.receiveBroadcastStream().listen((event) {
  print(event);
});
```

**数据编解码：** `StandardMessageCodec`（默认）或 `JSONMessageCodec`。

### Q110: Platform Channel 的性能？

- 每次调用有 **序列化/反序列化 + IPC** 开销
- 大量数据（如视频帧）不宜用 MethodChannel
- 耗时的原生操作应放在原生线程（不要在主线程）

**替代：**
- 数据量大 → `BasicMessageChannel` + 二进制
- 性能敏感 → `dart:ffi`（直接调用 C 库）
- 图片/文件 → 共享文件路径

### Q111: `dart:ffi` 的使用场景？

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef NativeAdd = Int32 Function(Int32 a, Int32 b);
typedef DartAdd = int Function(int a, int b);

void main() {
  final dylib = DynamicLibrary.open('libmylib.so');
  final add = dylib.lookupFunction<NativeAdd, DartAdd>('add');
  print(add(1, 2));  // 3
}
```

**场景：**
- 音视频编解码（FFmpeg）
- 数据库引擎（SQLite 定制）
- 加密算法
- 游戏引擎
- AI 推理（ONNX Runtime）

### Q112: Flutter 与原生双向通信？

```dart
// Dart → Native
final result = await channel.invokeMethod('getBatteryLevel');

// Native → Dart（通过同一个 channel）
// Native 侧：
// - Android: channel.invokeMethod("onEvent", args)
// - iOS: [channel invokeMethod:@"onEvent" arguments:args]

// 或者用 BasicMessageChannel 做双向消息
```

### Q113: Flutter 如何处理 Android/iOS 特有功能？

```dart
// 使用条件导入（未调用的代码不会被打包）
// android.dart
String getPlatformVersion() => 'Android 14';

// ios.dart
String getPlatformVersion() => 'iOS 18';

// main.dart
import 'platform_stub.dart'
  if (dart.library.io) 'platform_io.dart'
  if (dart.library.html) 'platform_web.dart';
```

---

## 测试

### Q114: 单元测试的最佳实践？

```dart
// 测试 UseCase
void main() {
  late UserRepository repository;
  late GetUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = GetUserUseCase(repository);
  });

  group('GetUserUseCase', () {
    test('should return user when repository succeeds', () async {
      when(() => repository.getUser('1'))
          .thenAnswer((_) async => User(id: '1', name: '张三'));

      final result = await useCase('1');

      expect(result, isA<User>());
      expect(result.name, '张三');
    });

    test('should throw when repository fails', () async {
      when(() => repository.getUser('1')).thenThrow(Exception());

      expect(() => useCase('1'), throwsException);
    });
  });
}
```

### Q115: Widget 测试的写法？

```dart
void main() {
  testWidgets('Counter increments when button is pressed', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterPage()));

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
```

### Q116: Mock 策略？

```dart
// 1. mockito
@GenerateNiceMocks([MockSpec<UserRepository>()])
void main() { /* 使用 MockUserRepository */ }

// 2. fake 实现（轻量）
class FakeUserRepository implements UserRepository {
  final _users = <String, User>{};
  @override
  Future<User> getUser(String id) async => _users[id] ?? User.empty();
}

// 3. Riverpod 覆盖
ProviderScope(
  overrides: [
    userRepositoryProvider.overrideWithValue(mockRepository),
  ],
  child: MaterialApp(home: TestPage()),
)
```

### Q117: 集成测试的要点？

```dart
// integration_test/test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('完整登录流程', (tester) async {
    await tester.pumpWidget(const MyApp());

    // 输入用户名密码
    await tester.enterText(find.byKey(const Key('username')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');

    // 点击登录
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // 验证跳转到首页
    expect(find.text('首页'), findsOneWidget);
  });
}
```

### Q118: `pump`、`pumpWidget`、`pumpAndSettle` 的区别？

```dart
await tester.pump(Duration(seconds: 1));  // 触发一帧 + 可选时间推移
await tester.pumpWidget(MyWidget());       // 创建并渲染 Widget
await tester.pumpAndSettle();              // 持续 pump 直到没有动画/定时器
```

---

## CI/CD 与打包发布

### Q119: Flutter 的 CI/CD 流程？

```yaml
# GitHub Actions 示例
name: Flutter CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: dart analyze
      - run: flutter test
      - run: flutter build apk --release
```

### Q120: Flutter 多渠道打包（Flavor）？

```dart
// Android build.gradle
productFlavors {
  development {
    applicationIdSuffix ".dev"
    versionNameSuffix "-dev"
  }
  production {
    // 默认配置
  }
}

// 运行时读取
const flavor = String.fromEnvironment('FLAVOR');
```

### Q121: Code Push / 热更新方案？

| 方案 | 说明 | 限制 |
|------|------|------|
| **Shorebird** | Flutter 官方推荐 Code Push | 付费，仅 Android |
| **自研** | 下载 patch 包+动态加载 | 复杂，受 App Store 限制 |
| **Flutter Web** | PWA 更新 | 实时更新 |

**注意：** iOS App Store 禁止动态下发可执行代码，Shorebird 目前仅限 Android。

---

## 2026 新趋势

### Q122: Impeller 渲染引擎详解？

**Impeller** 是 Flutter 新一代渲染引擎，替代 Skia。

**优势：**
1. **消除首帧卡顿** — 预编译所有 Shader，运行时无需编译
2. **减少 Jank** — 不再有 SkSL 热缓存问题
3. **更低功耗** — 优化 GPU 使用
4. **更快的动画** — 一致的帧率

**现状 (2026)：**
- iOS：默认启用
- Android：可选（`enable-impeller=true`）
- macOS/Windows：开发中

### Q123: Dart 宏（Macros）的现状？

Dart 3 实验特性，目标是编译期代码生成。

```dart
// 宏的愿景（未来语法）
@JsonSerializable()
class User {
  final String name;
  final int age;
}

// 自动生成：
// User.fromJson(Map<String, dynamic> json)
// Map<String, dynamic> toJson()
```

**相比 build_runner 的优势：**
- 无需额外构建步骤
- IDE 支持更好（不生成文件）
- 类型安全

### Q124: Flutter web 的现状和最佳实践？

**适用场景：**
- 工具型应用（管理后台、数据面板）
- 营销页面
- 内容型网站

**不适用场景：**
- 复杂动画
- 高性能游戏
- SEO 敏感（无 SSR）

**Web 优化：**
- `flutter build web --web-renderer canvaskit`（默认）
- `auto`：移动端用 HTML，桌面端用 CanvasKit
- 代码分割：`deferred as`

### Q125: Dart 3 class modifiers 详解？

```dart
// base — 禁止外部实现
base class Animal {}

// interface — 只能 implements，不能 extends
interface class Drawable {}

// final — 禁止继承/实现
final class Config {}

// sealed — 受限制的继承，switch 穷举
sealed class Result {}

// mixin — 只能作为 mixin 使用
mixin Flyable {}

// abstract mixin — 混合了抽象类
abstract mixin class Logger {
  void log(String msg);
}
```

### Q126: AI 与 Flutter 结合？

- **ML Kit** — 人脸检测、文本识别、翻译
- **TensorFlow Lite** — 端侧模型推理
- **`flutter_llm`** — 端侧 LLM 推理
- **AI 生成 UI** — 用 LLM 生成 Flutter Widget 代码
- **Copilot 辅助** — VSCode/Android Studio AI 补全

### Q127: Flutter 桌面端现状（2026）？

| 平台 | 状态 | 建议 |
|------|------|------|
| **macOS** | 稳定 | 可用于生产 |
| **Windows** | 稳定 | 可用于生产 |
| **Linux** | 稳定 | 可用于生产 |

**大厂案例：**
- Google：内部工具
- 字节跳动：飞书 Flutter 桌面端
- 腾讯：企业微信
- Rivian：车机系统
- 微软：部分 Windows 应用

---

## 开放性/场景题

### Q128: 如何设计一个支持多主题的动态换肤系统？

```dart
// 1. 定义主题数据
class AppTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  // ...
}

// 2. 使用 InheritedWidget 或 Provider
final themeProvider = StateProvider<AppTheme>((ref) => AppTheme.light());

// 3. 主题变化时局部 rebuild
Consumer(builder: (context, ref, _) {
  final theme = ref.watch(themeProvider);
  return Container(color: theme.backgroundColor);
});
```

### Q129: 如何保证 App 不闪白屏（White Flash）？

```dart
// Android: styles.xml
<style name="LaunchTheme" parent="Theme.LaunchTheme">
  <item name="android:windowBackground">@drawable/launch_background</item>
</style>

// iOS: LaunchScreen.storyboard 设置背景色

// Flutter 原生启动页
final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
));

// 设置 Flutter 引擎启动背景
FlutterEngine flutterEngine = new FlutterEngine(context);
flutterEngine.getRenderer().setStartUpRenderer(RendererType.impeller);
```

### Q130: Flutter 页面加载慢怎么优化？

1. **预创建引擎**（`FlutterEngineGroup`）
2. **路由预加载**（`precacheRoute`）
3. **减少首帧 Widget 复杂度**
4. **使用 Skeletons 骨架屏**
5. **延迟加载非首屏组件**（`FutureBuilder`）
6. **图片预缓存**（`precacheImage`）
7. **Impeller 引擎**（消除 Shader 编译）

### Q131: 如何实现 IM 聊天界面？

```dart
// 核心组件
// 1. 消息列表 — ListView.builder + 反向排列
ListView.builder(
  reverse: true,
  itemCount: messages.length,
  itemBuilder: (context, index) => MessageBubble(message: messages[index]),
)

// 2. 消息气泡
Container(
  decoration: BoxDecoration(
    color: isMe ? Colors.blue : Colors.grey[200],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(message.content),
)

// 3. WebSocket 实时通信
// 4. SQLite 本地持久化
```

### Q132: 如何实现图片/视频上传？

```dart
// 1. 选择文件
final picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

// 2. 上传（Dio + FormData + 进度回调）
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    image.path,
    filename: 'upload.jpg',
  ),
});

final response = await dio.post('/upload', data: formData,
  onSendProgress: (sent, total) {
    final progress = sent / total;
    print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// 3. 显示缩略图
Image.file(File(image.path));
```

### Q133: Flutter 中如何做权限管理？

```dart
// 使用 permission_handler
final status = await Permission.camera.request();

if (status.isGranted) {
  // 打开相机
} else if (status.isPermanentlyDenied) {
  // 引导用户去设置
  openAppSettings();
}
```

---

## 手写代码题

### Q134: 手写单例模式（Singleton）

```dart
// 方式 1：factory 构造函数
class Singleton {
  static final Singleton _instance = Singleton._internal();
  Singleton._internal();
  factory Singleton() => _instance;
}

// 方式 2：全局变量
final singleton = Singleton._();
class Singleton {
  Singleton._();
}

// 方式 3：延迟初始化 + 线程安全
class Singleton {
  static Singleton? _instance;
  static final _lock = Object();
  
  Singleton._internal();
  
  static Singleton get instance {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= Singleton._internal();
      });
    }
    return _instance!;
  }
}
```

### Q135: 手写 Future 超时处理

```dart
Future<T> withTimeout<T>(Future<T> future, Duration duration) {
  final completer = Completer<T>();
  
  future.then(
    (value) => completer.complete(value),
    onError: (error) => completer.completeError(error),
  );
  
  Future.delayed(duration, () {
    if (!completer.isCompleted) {
      completer.completeError(TimeoutException('操作超时', duration));
    }
  });
  
  return completer.future;
}

// 使用
try {
  final result = await withTimeout(fetchData(), Duration(seconds: 5));
} on TimeoutException {
  print('请求超时');
}
```

### Q136: 手写 debounce / throttle

```dart
// Debounce — 停止触发后等 N 毫秒执行
class Debounce {
  final Duration delay;
  Timer? _timer;
  
  Debounce(this.delay);
  
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() => _timer?.cancel();
}

// Throttle — N 毫秒内只执行一次
class Throttle {
  final Duration interval;
  DateTime? _lastCall;
  
  Throttle(this.interval);
  
  bool call() {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) >= interval) {
      _lastCall = now;
      return true;  // 可以执行
    }
    return false;    // 被节流
  }
}
```

### Q137: 手写 Stream 转换操作符

```dart
// 简易的 map 操作符
extension StreamExtensions<T> on Stream<T> {
  Stream<R> myMap<R>(R Function(T) transform) async* {
    await for (final event in this) {
      yield transform(event);
    }
  }
  
  Stream<T> myWhere(bool Function(T) test) async* {
    await for (final event in this) {
      if (test(event)) yield event;
    }
  }
  
  Stream<T> myDebounce(Duration duration) async* {
    Timer? timer;
    T? lastValue;
    
    await for (final event in this) {
      lastValue = event;
      timer?.cancel();
      timer = Timer(duration, () {
        if (lastValue != null) {
          // 通过 sync 控制器发送
        }
      });
    }
  }
}
```

### Q138: 手写 Flutter 流式布局（简易版 Wrap）

```dart
class SimpleWrap extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;
  
  SimpleWrap({
    required super.children,
    this.spacing = 0,
    this.runSpacing = 0,
  });
  
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSimpleWrap(spacing: spacing, runSpacing: runSpacing);
  }
  
  @override
  void updateRenderObject(BuildContext context, RenderSimpleWrap renderObject) {
    renderObject.spacing = spacing;
    renderObject.runSpacing = runSpacing;
  }
}

class RenderSimpleWrap extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, SimpleWrapParentData> {
  double spacing;
  double runSpacing;
  
  RenderSimpleWrap({required this.spacing, required this.runSpacing});
  
  @override
  void performLayout() {
    // 遍历 children 计算布局
    // 当当前行宽度不足时换行
    // 设置自身 size
  }
}

class SimpleWrapParentData extends ContainerBoxParentData<RenderBox> {}
```

### Q139: 手写一个简易的网络请求缓存

```dart
class NetworkCache {
  static final _cache = <String, _CacheEntry>{};
  static const _defaultTTL = Duration(minutes: 5);
  
  static Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration ttl = _defaultTTL,
  }) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    
    final data = await fetcher();
    _cache[key] = _CacheEntry(data, ttl: ttl);
    return data;
  }
  
  static void clear() => _cache.clear();
}

class _CacheEntry {
  final dynamic data;
  final DateTime _createdAt;
  final Duration ttl;
  
  _CacheEntry(this.data, {required this.ttl}) : _createdAt = DateTime.now();
  
  bool get isExpired => DateTime.now().difference(_createdAt) > ttl;
}
```

### Q140: 手写 State 管理（简易版 Provider）

```dart
class Provider<T> extends StatefulWidget {
  final T value;
  final Widget child;
  
  const Provider({super.key, required this.value, required this.child});
  
  @override
  State<Provider> createState() => _ProviderState<T>();
  
  static T of<T>(BuildContext context) {
    final state = context.findAncestorStateOfType<_ProviderState<T>>();
    assert(state != null, 'Provider<$T> not found');
    return state!._value;
  }
}

class _ProviderState<T> extends State<Provider> {
  late T _value;
  
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }
  
  @override
  void didUpdateWidget(Provider old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      setState(() => _value = widget.value);
    }
  }
  
  @override
  Widget build(BuildContext context) => widget.child;
}

// 使用
Provider<int>.of(context);  // 获取值
```

### Q141: 手写简易 Form 校验

```dart
class FormValidator {
  static String? required(String? value, [String fieldName = '此字段']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
  
  static String? minLength(int min, String? value) {
    if (value != null && value.length < min) {
      return '最少需要 $min 个字符';
    }
    return null;
  }
  
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
```

### Q142: 手写简易 Redux

```dart
typedef Reducer<S> = S Function(S state, dynamic action);

class Store<S> {
  S _state;
  final Reducer<S> _reducer;
  final _listeners = <void Function()>[];
  
  Store(this._reducer, S initialState) : _state = initialState;
  
  S get state => _state;
  
  void dispatch(dynamic action) {
    _state = _reducer(_state, action);
    _listeners.forEach((l) => l());
  }
  
  VoidCallback listen(void Function() listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }
}

// 使用
enum CounterAction { increment, decrement }

final store = Store<int>((state, action) {
  switch (action) {
    case CounterAction.increment: return state + 1;
    case CounterAction.decrement: return state - 1;
    default: return state;
  }
}, 0);

store.dispatch(CounterAction.increment);
```

### Q143: 手写 Flutter 防连点

```dart
class DebouncedGestureDetector extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Duration delay;
  
  const DebouncedGestureDetector({
    super.key,
    required this.onTap,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
  });
  
  @override
  Widget build(BuildContext context) {
    return _DebouncedGestureDetectorStateful(
      onTap: onTap,
      child: child,
      delay: delay,
    );
  }
}

class _DebouncedGestureDetectorStateful extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Duration delay;
  
  const _DebouncedGestureDetectorStateful({
    required this.onTap,
    required this.child,
    required this.delay,
  });
  
  @override
  State<_DebouncedGestureDetectorStateful> createState() => _DebouncedGestureDetectorState();
}

class _DebouncedGestureDetectorState extends State<_DebouncedGestureDetectorStateful> {
  bool _locked = false;
  
  void _handleTap() {
    if (_locked || widget.onTap == null) return;
    _locked = true;
    widget.onTap!();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _locked = false);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Opacity(
        opacity: _locked ? 0.5 : 1.0,
        child: widget.child,
      ),
    );
  }
}
```

---

## 综合题

### Q144: 简述 Flutter App 从启动到显示第一帧的流程？

1. **原生启动** — iOS/Android 创建 FlutterEngine
2. **引擎初始化** — Dart VM 启动，加载 `main.dart`
3. **runApp()** — 绑定 WidgetsBinding，开始帧循环
4. **创建根 Element** — `WidgetsApp` → `_WidgetsAppState`
5. **创建根 RenderObject** — 渲染附着
6. **第一帧 Build** — 构建 Widget Tree
7. **Layout + Paint** — 布局和绘制
8. **Rasterize** — GPU 栅格化并显示
9. **vsync 回调** — 持续帧循环

### Q145: 如果有 10w 条数据要在列表中展示，你会怎么做？

```dart
// 1. ListView.builder — 必须
// 2. 分页加载（PaginatedListView）
// 3. 固定 item 高度（itemExtent）
// 4. 图片按需解码
// 5. RepaintBoundary 优化滑动
// 6. 数据层面：缓存、虚拟化
// 7. 如需搜索/筛选 → 用 Isar/SQLite 做索引
```

**关键：** ListView.builder 本身支持 10w 条（仅渲染可见项），但需注意：
- 每个 item 不能太重（build 和 paint 成本）
- 回城卡顿配置 `addAutomaticKeepAlives: false`

### Q146: 如何设计一个高性能的图片缓存库？

1. **三级缓存** — 内存（LRU）→ 磁盘 → 网络
2. **按需解码** — `cacheWidth` `cacheHeight` 参数
3. **预加载** — `precacheImage`
4. **占位图/错误图**
5. **内存管理** — `clear()` 低内存时释放
6. **图片复用** — 相同 URL 共用一个下载任务（`Completer`）

### Q147: Flutter 在混合栈（Native + Flutter）中如何通信？

```dart
// 方案 1：FlutterEngineGroup（共享引擎）
final engineGroup = FlutterEngineGroup(context);
final engine = engineGroup.createAndRunDefaultEngine(appBundlePath);

// 方案 2：MethodChannel
// Native → Flutter：FlutterEngine.getDartExecutor().getBinaryMessenger()

// 方案 3：Flutter 插件通信
// 方案 4：事件总线（EventBus）

// 混合栈路由管理：
// flutter_boost / flutter_thrio 等方案
```

### Q148: 如何设计一个 Flutter 跨端组件库？

1. **主题可定制** — `ThemeExtension` 扩展主题
2. **平台自适应** — `Theme.of(context).platform` 区分 iOS/macOS
3. **可选动画** — `AnimationConfiguration`
4. **无障碍** — `Semantics` 标注
5. **测试覆盖** — Widget 测试 + 截图测试
6. **Tree-shaking 友好** — 按需 import

```dart
class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  
  const MyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MyButtonTheme>()!;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == ButtonVariant.primary
            ? theme.primaryColor
            : theme.secondaryColor,
      ),
      child: Text(text),
    );
  }
}
```

---

## Flutter 原理解析（进阶）

### Q149: Flutter 的渲染管线 vs Android View 体系？

| | Flutter | Android View |
|--|---------|-------------|
| 布局 | RenderObject（Dart） | View.onMeasure/Layout（Java） |
| 绘制 | Canvas 直接绘制 | Canvas（通过 Skia） |
| 线程模型 | UI + GPU + IO | Main + Render |
| 视图树 | Widget → Element → RenderObject | View → ViewGroup |
| 更新方式 | setState → Build → Layout → Paint | requestLayout → measure → layout → draw |

### Q150: Flutter 是如何处理文本排版的？

1. `Text` Widget → `RichText` RenderObject
2. `RenderParagraph` 使用 `dart:ui` 的 `ParagraphBuilder`
3. `ParagraphBuilder` 调用 Skia/Impeller 的文本排版引擎
4. 支持复杂的文字排版（双向文本、连字、断行）
5. 字体 fallback 机制

### Q151: Flutter 的 Layer 是做什么的？

- `Layer` 是 RenderObject 绘制结果的"容器"
- 常见的 Layer：`PictureLayer`、`TextureLayer`、`PlatformViewLayer`
- 屏幕外渲染（`saveLayer`）会创建独立的 Layer
- Layer 树最终在 Compositing 阶段合成

### Q152: Flutter 的 `Isolate` vs `Thread` vs `Process`？

| | Isolate | Thread | Process |
|--|---------|--------|---------|
| 内存 | 独立 | 共享 | 独立 |
| 通信 | Port | 直接共享内存 | IPC |
| 创建成本 | 中 | 低 | 高 |
| 安全 | 无竞争 | 需锁 | 无竞争 |
| 适用 | 计算密集型 | 已不推荐 | 沙盒隔离 |

### Q153: 什么是 Flutter 的 `PipelineOwner`？

`PipelineOwner` 管理渲染管线的三个 dirty 集合：
- `_nodesNeedingLayout` — 需要 layout 的节点
- `_nodesNeedingPaint` — 需要 paint 的节点
- `_nodesNeedingCompositingBitsUpdate` — 需要合成

每帧按顺序处理这三个集合，确保 Layout → Paint → Compositing 的有序性。

### Q154: Flutter 的 `Binding` 机制？

```dart
// WidgetsBinding — 顶层绑定
// RendererBinding — 渲染绑定
// SchedulerBinding — 调度绑定
// ServicesBinding — 平台服务绑定

void runApp(Widget app) {
  WidgetsFlutterBinding.ensureInitialized()  // 创建所有 Binding
    ..attachRootWidget(app)
    ..scheduleWarmUpFrame();
}

// Binding 是单例模式，使用 mixin 组合
class WidgetsFlutterBinding extends BindingBase
    with GestureBinding, SchedulerBinding, ServicesBinding,
         PaintingBinding, SemanticsBinding, RendererBinding, WidgetsBinding {
  // ...
}
```

---

> **参考来源：** Flutter 官方文档 / Dart SDK 源码 / Awesome Flutter / 2026 年面试汇总
> **更新日期：** 2026 年 6 月
