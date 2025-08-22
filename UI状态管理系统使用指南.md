# UI状态管理系统使用指南

## 概述

新的UI状态管理系统采用基于注册的解耦架构，让您可以在不修改UI状态管理器代码的情况下添加新界面。

## 核心特性

1. **自动注册**: 界面和按钮可以自动注册到状态管理器
2. **灵活配置**: 每个界面和按钮可以定义在哪些状态下显示/启用
3. **解耦设计**: 添加新界面和按钮不需要修改状态管理器代码
4. **事件驱动**: 基于事件的状态切换
5. **智能状态管理**: 按钮状态根据UI状态自动更新

## 使用方法

### 方法一：继承UI界面基类（推荐）

对于新的界面，推荐继承 `UI界面基类`：

```gdscript
extends UI界面基类

# 重写基类属性
func _init():
	界面名称 = "我的新界面"
	显示状态列表 = [
		UIStateManager.UIState.MAIN_MENU,    # 在主菜单显示
		UIStateManager.UIState.LOBBY_LIST   # 在大厅列表也显示
	]

# 重写界面初始化方法
func _界面初始化() -> void:
	# 在这里进行界面特定的初始化
	pass
```

### 方法二：手动注册

对于现有界面，可以手动注册：

```gdscript
extends Control

func _ready() -> void:
	await get_tree().process_frame
	
	var ui_state_manager = MainController.获取UI状态管理器()
	if ui_state_manager:
		ui_state_manager.注册界面("界面名称", self, [
			UIStateManager.UIState.MAIN_MENU,
			UIStateManager.UIState.LOBBY_LIST
		])
```

### 方法三：在父节点中注册子界面

```gdscript
extends Control

@onready var 子界面1: Control = $子界面1
@onready var 子界面2: Control = $子界面2

func _ready() -> void:
	await get_tree().process_frame
	_注册子界面()

func _注册子界面() -> void:
	var ui_state_manager = MainController.获取UI状态管理器()
	
	if ui_state_manager:
		# 注册子界面1 - 只在主菜单显示
		ui_state_manager.注册界面("子界面1", 子界面1, [
			UIStateManager.UIState.MAIN_MENU
		])
		
		# 注册子界面2 - 在大厅内显示
		ui_state_manager.注册界面("子界面2", 子界面2, [
			UIStateManager.UIState.IN_LOBBY
		])
```

## 按钮状态管理

### 方法一：继承UI按钮基类（推荐）

对于新的按钮，推荐继承 `UI按钮基类`：

```gdscript
extends UI按钮基类

# 重写基类属性
func _init():
	按钮名称 = "我的按钮"
	启用状态列表 = [
		UIStateManager.UIState.MAIN_MENU,    # 在主菜单启用
		UIStateManager.UIState.LOBBY_LIST   # 在大厅列表也启用
	]
	禁用状态列表 = [
		UIStateManager.UIState.IN_LOBBY     # 在大厅内禁用
	]

# 重写按钮初始化方法
func _按钮初始化() -> void:
	# 在这里进行按钮特定的初始化
	pass
```

### 方法二：手动注册按钮

对于现有按钮，可以手动注册：

```gdscript
extends Button

func _ready() -> void:
	await get_tree().process_frame
	
	var ui_state_manager = MainController.获取UI状态管理器()
	if ui_state_manager:
		ui_state_manager.注册按钮("按钮名称", self, [
			UIStateManager.UIState.MAIN_MENU,
			UIStateManager.UIState.LOBBY_LIST
		], [
			UIStateManager.UIState.IN_LOBBY  # 可选的禁用状态
		])
```

### 方法三：批量注册按钮

```gdscript
extends Control

func _ready() -> void:
	await get_tree().process_frame
	_批量注册按钮()

func _批量注册按钮() -> void:
	var ui_state_manager = MainController.获取UI状态管理器()
	
	if ui_state_manager:
		var 按钮配置 = {
			"create_lobby": {
				"引用": $创建大厅按钮,
				"启用状态": [UIStateManager.UIState.MAIN_MENU, UIStateManager.UIState.LOBBY_LIST]
			},
			"join_lobby": {
				"引用": $加入大厅按钮,
				"启用状态": [UIStateManager.UIState.MAIN_MENU, UIStateManager.UIState.LOBBY_LIST]
			},
			"exit_game": {
				"引用": $退出游戏按钮,
				"启用状态": [UIStateManager.UIState.MAIN_MENU]
			}
		}
		
		ui_state_manager.批量注册按钮(按钮配置)
```

## 可用的UI状态

```gdscript
UIStateManager.UIState.INITIALIZED    # 初始化
UIStateManager.UIState.MAIN_MENU      # 主菜单
UIStateManager.UIState.LOBBY_LIST     # 大厅列表
UIStateManager.UIState.IN_LOBBY       # 在大厅中
UIStateManager.UIState.CHAT_INTERFACE # 聊天界面
UIStateManager.UIState.GAME_SCENE     # 游戏场景
```

## 高级功能

### 动态更新显示规则

```gdscript
# 更新界面的显示规则
func 更新显示规则() -> void:
	var 新规则 = [UIStateManager.UIState.MAIN_MENU]
	更新显示规则(新规则)
```

### 动态更新按钮状态

```gdscript
# 更新按钮的启用状态
func 更新按钮启用状态() -> void:
	var 新启用状态 = [UIStateManager.UIState.MAIN_MENU]
	更新启用状态(新启用状态)

# 更新按钮的禁用状态
func 更新按钮禁用状态() -> void:
	var 新禁用状态 = [UIStateManager.UIState.IN_LOBBY]
	更新禁用状态(新禁用状态)
```

### 检查当前状态

```gdscript
# 检查是否在特定状态
if 是否在状态(UIStateManager.UIState.MAIN_MENU):
	print("当前在主菜单")

# 获取当前状态
var 当前状态 = 获取当前UI状态()
```

### 手动切换状态

```gdscript
# 切换到主菜单
切换到状态(UIStateManager.UIState.MAIN_MENU)
```

### 手动控制按钮状态

```gdscript
# 手动启用/禁用按钮
手动设置按钮状态(true)   # 启用
手动设置按钮状态(false)  # 禁用

# 重置按钮状态为自动模式
重置按钮状态()
```

## 最佳实践

1. **界面命名**: 使用有意义的界面名称，便于调试
2. **状态选择**: 仔细考虑界面应该在哪些状态下显示
3. **资源管理**: 界面被移除时会自动取消注册
4. **错误处理**: 检查UI状态管理器是否可用

## 示例：添加新界面的完整流程

假设您要添加一个"设置界面"：

1. **创建界面脚本**:
```gdscript
extends UI界面基类

func _init():
	界面名称 = "设置界面"
	显示状态列表 = [
		UIStateManager.UIState.MAIN_MENU
	]

func _界面初始化() -> void:
	# 设置界面的初始化逻辑
	pass
```

2. **创建场景文件**: 设置界面.tscn

3. **添加到主场景**: 将设置界面添加到主场景中

4. **完成**: 界面会自动注册并在主菜单状态时显示

## 示例：添加新按钮的完整流程

假设您要添加一个"设置按钮"：

1. **创建按钮脚本**:
```gdscript
extends UI按钮基类

func _init():
	按钮名称 = "设置按钮"
	启用状态列表 = [
		UIStateManager.UIState.MAIN_MENU
	]

func _按钮初始化() -> void:
	text = "设置"
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("设置按钮被点击")
```

2. **创建场景文件**: 设置按钮.tscn

3. **添加到主场景**: 将设置按钮添加到主场景中

4. **完成**: 按钮会自动注册并在主菜单状态时启用

## 调试技巧

```gdscript
# 获取所有注册的界面
var 界面列表 = UI状态管理器.获取注册界面列表()
print("已注册的界面: ", 界面列表)

# 检查界面是否已注册
if UI状态管理器.界面已注册("我的界面"):
	print("界面已注册")

# 获取界面的显示规则
var 规则 = UI状态管理器.获取界面显示规则("我的界面")
print("显示规则: ", 规则)

# 获取所有注册的按钮
var 按钮列表 = UI状态管理器.获取注册按钮列表()
print("已注册的按钮: ", 按钮列表)

# 检查按钮是否已注册
if UI状态管理器.按钮已注册("我的按钮"):
	print("按钮已注册")

# 获取按钮的启用状态
var 启用状态 = UI状态管理器.获取按钮启用状态("我的按钮")
print("按钮启用状态: ", 启用状态)

# 获取按钮的禁用状态
var 禁用状态 = UI状态管理器.获取按钮禁用状态("我的按钮")
print("按钮禁用状态: ", 禁用状态)
```

## 迁移指南

如果您有现有的界面需要迁移到新系统：

1. 将界面脚本改为继承 `UI界面基类`
2. 在 `_init()` 中设置界面名称和显示规则
3. 将初始化逻辑移到 `_界面初始化()` 方法中
4. 删除原有的手动注册代码

如果您有现有的按钮需要迁移到新系统：

1. 将按钮脚本改为继承 `UI按钮基类`
2. 在 `_init()` 中设置按钮名称和启用/禁用状态列表
3. 将初始化逻辑移到 `_按钮初始化()` 方法中
4. 删除原有的手动注册代码

这样就完成了从旧系统到新系统的迁移！
