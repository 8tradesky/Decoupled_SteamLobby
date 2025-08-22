class_name UI按钮基类
extends Button

# UI状态管理器引用
var UI状态管理器: UIStateManager

# 按钮名称 - 子类需要重写
var 按钮名称: String = "未命名按钮"

# 启用状态列表 - 子类需要重写
var 启用状态列表: Array[UIStateManager.UIState] = []

# 禁用状态列表 - 子类可以重写
var 禁用状态列表: Array[UIStateManager.UIState] = []

# 是否自动注册 - 子类可以设置为false来禁用自动注册
var 自动注册: bool = true

func _ready() -> void:
	await get_tree().process_frame
	
	# 获取UI状态管理器引用
	UI状态管理器 = MainController.ui_state_manager
	
	# 自动注册到UI状态管理器
	if 自动注册:
		_注册到UI状态管理器()
	
	# 调用子类的初始化方法
	_按钮初始化()

# 注册到UI状态管理器
func _注册到UI状态管理器() -> void:
	if UI状态管理器 and 按钮名称 != "未命名按钮":
		UI状态管理器.注册按钮(按钮名称, self, 启用状态列表, 禁用状态列表)
		print("按钮 '%s' 已自动注册到UI状态管理器" % 按钮名称)
	else:
		print("警告: UI状态管理器未找到或按钮名称未设置，无法注册按钮")

# 手动注册按钮（如果自动注册被禁用）
func 手动注册按钮() -> void:
	_注册到UI状态管理器()

# 取消注册按钮
func 取消注册按钮() -> void:
	if UI状态管理器 and UI状态管理器.按钮已注册(按钮名称):
		UI状态管理器.取消注册按钮(按钮名称)
		print("按钮 '%s' 已从UI状态管理器取消注册" % 按钮名称)

# 更新启用状态列表
func 更新启用状态(新启用状态: Array[UIStateManager.UIState]) -> void:
	启用状态列表 = 新启用状态
	if UI状态管理器:
		UI状态管理器.更新按钮启用状态(按钮名称, 新启用状态)

# 更新禁用状态列表
func 更新禁用状态(新禁用状态: Array[UIStateManager.UIState]) -> void:
	禁用状态列表 = 新禁用状态
	if UI状态管理器:
		UI状态管理器.更新按钮禁用状态(按钮名称, 新禁用状态)

# 子类需要重写的方法 - 按钮初始化
func _按钮初始化() -> void:
	pass

# 当节点被移除时，自动取消注册
func _exit_tree() -> void:
	取消注册按钮()

# 获取当前UI状态
func 获取当前UI状态() -> UIStateManager.UIState:
	if UI状态管理器:
		return UI状态管理器.获取当前状态()
	return UIStateManager.UIState.INITIALIZED

# 检查是否在特定状态
func 是否在状态(状态: UIStateManager.UIState) -> bool:
	if UI状态管理器:
		return UI状态管理器.是否在状态(状态)
	return false

# 检查按钮是否启用
func 按钮是否启用() -> bool:
	if UI状态管理器:
		return UI状态管理器.获取按钮状态(按钮名称)
	return false

# 手动启用/禁用按钮
func 手动设置按钮状态(启用: bool) -> void:
	if UI状态管理器:
		UI状态管理器.手动设置按钮状态(按钮名称, 启用)

# 重置按钮状态为自动模式
func 重置按钮状态() -> void:
	if UI状态管理器:
		UI状态管理器.重置按钮状态(按钮名称)
