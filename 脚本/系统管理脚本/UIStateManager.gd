class_name UIStateManager
extends Node

# UI状态枚举
enum UIState {
	INITIALIZED,    # 初始化
	MAIN_MENU,      # 主菜单
	LOBBY_LIST,     # 大厅列表
	IN_LOBBY,       # 在大厅中
	CHAT_INTERFACE, # 聊天界面
	GAME_SCENE      # 游戏场景
}

# 当前UI状态
var 当前状态: UIState = UIState.INITIALIZED

# 注册的UI界面字典 - 键为界面名称，值为界面引用和显示规则
var 注册界面字典: Dictionary = {}

# 按钮状态管理 - 基于注册的系统
var 按钮状态字典: Dictionary = {}
var 按钮注册字典: Dictionary = {}  # 存储按钮的注册信息

# 事件总线引用
var 事件总线: EventBus
var 大厅管理器: LobbyManager

func _ready() -> void:
	# 获取事件总线引用
	事件总线 = EventBus
	
	# 连接事件
	连接事件()
	
	print("UI状态管理器初始化完成")

#region ==================== 界面注册系统 ====================

# 注册界面到状态管理器
func 注册界面(界面名称: String, 界面引用: Control, 显示规则: Array[UIState]) -> void:
	注册界面字典[界面名称] = {
		"引用": 界面引用,
		"显示规则": 显示规则,
		"默认可见": 界面引用.visible if 界面引用 else false
	}
	print("界面 '%s' 已注册到UI状态管理器" % 界面名称)

# 取消注册界面
func 取消注册界面(界面名称: String) -> void:
	if 注册界面字典.has(界面名称):
		注册界面字典.erase(界面名称)
		print("界面 '%s' 已从UI状态管理器取消注册" % 界面名称)

# 更新界面的显示规则
func 更新界面显示规则(界面名称: String, 新显示规则: Array[UIState]) -> void:
	if 注册界面字典.has(界面名称):
		注册界面字典[界面名称]["显示规则"] = 新显示规则
		print("界面 '%s' 的显示规则已更新" % 界面名称)
#endregion

#region ==================== 状态切换系统 ====================

# 切换UI状态
func 切换到状态(新状态: UIState) -> void:
	print("切换到状态: ", 新状态)
	if 当前状态 == 新状态:
		return
	
	var 旧状态 = 当前状态
	当前状态 = 新状态
	
	# 更新所有注册界面的可见性
	更新所有界面可见性()
	
	# 更新按钮状态
	更新按钮状态(新状态)
	
	# 发送状态变化事件
	事件总线.发射_UI状态变化(str(新状态), true)
	
	print("UI状态从 %s 切换到 %s" % [旧状态, 新状态])

# 更新所有注册界面的可见性
func 更新所有界面可见性() -> void:
	for 界面名称 in 注册界面字典:
		var 界面数据 = 注册界面字典[界面名称]
		var 界面引用 = 界面数据["引用"]
		var 显示规则 = 界面数据["显示规则"]
		
		if 界面引用 and is_instance_valid(界面引用):
			var 应该显示 = 显示规则.has(当前状态)
			界面引用.visible = 应该显示
			
			if 应该显示:
				print("显示界面: %s" % 界面名称)
			else:
				print("隐藏界面: %s" % 界面名称)

# 根据状态显示对应UI
func 显示对应状态界面(状态: UIState) -> void:
	# 这个方法现在由 更新所有界面可见性() 处理
	pass

# 隐藏所有UI
func 隐藏所有界面() -> void:
	print("正在隐藏所有UI")
	for 界面名称 in 注册界面字典:
		var 界面数据 = 注册界面字典[界面名称]
		var 界面引用 = 界面数据["引用"]
		
		if 界面引用 and is_instance_valid(界面引用):
			界面引用.visible = false
#endregion

#region ==================== 按钮状态管理 ====================

# 注册按钮到状态管理器
func 注册按钮(按钮名称: String, 按钮引用: Control, 启用状态列表: Array[UIState], 禁用状态列表: Array[UIState] = []) -> void:
	按钮注册字典[按钮名称] = {
		"引用": 按钮引用,
		"启用状态": 启用状态列表,
		"禁用状态": 禁用状态列表,
		"默认启用": true
	}
	print("按钮 '%s' 已注册到状态管理器" % 按钮名称)

# 取消注册按钮
func 取消注册按钮(按钮名称: String) -> void:
	if 按钮注册字典.has(按钮名称):
		按钮注册字典.erase(按钮名称)
		print("按钮 '%s' 已从状态管理器取消注册" % 按钮名称)

# 更新按钮的启用状态列表
func 更新按钮启用状态(按钮名称: String, 新启用状态: Array[UIState]) -> void:
	if 按钮注册字典.has(按钮名称):
		按钮注册字典[按钮名称]["启用状态"] = 新启用状态
		print("按钮 '%s' 的启用状态已更新" % 按钮名称)

# 更新按钮的禁用状态列表
func 更新按钮禁用状态(按钮名称: String, 新禁用状态: Array[UIState]) -> void:
	if 按钮注册字典.has(按钮名称):
		按钮注册字典[按钮名称]["禁用状态"] = 新禁用状态
		print("按钮 '%s' 的禁用状态已更新" % 按钮名称)

# 更新所有按钮状态
func 更新按钮状态(状态: UIState) -> void:
	for 按钮名称 in 按钮注册字典:
		var 按钮数据 = 按钮注册字典[按钮名称]
		var 按钮引用 = 按钮数据["引用"]
		var 启用状态列表 = 按钮数据["启用状态"]
		var 禁用状态列表 = 按钮数据["禁用状态"]
		
		if 按钮引用 and is_instance_valid(按钮引用):
			var 应该启用 = 启用状态列表.has(状态) and not 禁用状态列表.has(状态)
			设置按钮状态(按钮名称, 应该启用)

# 设置按钮状态
func 设置按钮状态(按钮名称: String, 启用: bool) -> void:
	按钮状态字典[按钮名称] = 启用
	
	# 更新按钮的实际状态
	if 按钮注册字典.has(按钮名称):
		var 按钮数据 = 按钮注册字典[按钮名称]
		var 按钮引用 = 按钮数据["引用"]
		
		if 按钮引用 and is_instance_valid(按钮引用):
			if 按钮引用.has_method("set_disabled"):
				按钮引用.set_disabled(not 启用)
			elif 按钮引用.has_method("set_visible"):
				按钮引用.set_visible(启用)
	
	事件总线.发射_按钮状态变化(按钮名称, 启用)

# 获取按钮状态
func 获取按钮状态(按钮名称: String) -> bool:
	return 按钮状态字典.get(按钮名称, false)

# 手动设置按钮状态（覆盖自动状态）
func 手动设置按钮状态(按钮名称: String, 启用: bool) -> void:
	设置按钮状态(按钮名称, 启用)

# 重置按钮状态为自动模式
func 重置按钮状态(按钮名称: String) -> void:
	if 按钮注册字典.has(按钮名称):
		var 按钮数据 = 按钮注册字典[按钮名称]
		var 启用状态列表 = 按钮数据["启用状态"]
		var 禁用状态列表 = 按钮数据["禁用状态"]
		
		var 应该启用 = 启用状态列表.has(当前状态) and not 禁用状态列表.has(当前状态)
		设置按钮状态(按钮名称, 应该启用)
#endregion

#region ==================== 事件处理 ====================

# 事件处理
func _当大厅已创建(lobby_id: int, lobby_data: Dictionary) -> void:
	切换到状态(UIState.IN_LOBBY)

func _当大厅已加入(lobby_id: int, lobby_data: Dictionary) -> void:
	切换到状态(UIState.IN_LOBBY)

func _当大厅已离开(lobby_id: int) -> void:
	切换到状态(UIState.MAIN_MENU)

func _当大厅列表已更新(lobby_list: Array) -> void:
	# 如果当前在大厅列表中，保持状态
	if 当前状态 == UIState.LOBBY_LIST:
		return
	
	# 否则切换到大厅列表
	切换到状态(UIState.LOBBY_LIST)

func _当游戏场景请求加载(scene_path: String) -> void:
	切换到状态(UIState.GAME_SCENE)
#endregion

#region ==================== 公共接口方法 ====================

# 切换到主菜单
func 切换到主菜单() -> void:
	print("UI控件管理正在切换到主菜单")
	切换到状态(UIState.MAIN_MENU)

# 切换到大厅列表
func 切换到大厅列表() -> void:
	切换到状态(UIState.LOBBY_LIST)

# 切换到大厅内
func 切换到大厅内() -> void:
	切换到状态(UIState.IN_LOBBY)

# 切换到聊天界面
func 切换到聊天界面() -> void:
	切换到状态(UIState.CHAT_INTERFACE)

# 切换到游戏场景
func 切换到游戏场景() -> void:
	切换到状态(UIState.GAME_SCENE)

# 获取当前状态
func 获取当前状态() -> UIState:
	return 当前状态

# 检查是否在特定状态
func 是否在状态(状态: UIState) -> bool:
	return 当前状态 == 状态

# 检查是否在大厅中
func 在大厅中() -> bool:
	return 当前状态 == UIState.IN_LOBBY

# 检查是否在游戏中
func 在游戏中() -> bool:
	return 当前状态 == UIState.GAME_SCENE
#endregion

#region ==================== 调试和工具方法 ====================

# 获取所有注册的界面
func 获取注册界面列表() -> Array:
	return 注册界面字典.keys()

# 检查界面是否已注册
func 界面已注册(界面名称: String) -> bool:
	return 注册界面字典.has(界面名称)

# 获取界面的显示规则
func 获取界面显示规则(界面名称: String) -> Array[UIState]:
	if 注册界面字典.has(界面名称):
		return 注册界面字典[界面名称]["显示规则"]
	return []
#endregion

#region ==================== 按钮调试和工具方法 ====================

# 获取所有注册的按钮
func 获取注册按钮列表() -> Array:
	return 按钮注册字典.keys()

# 检查按钮是否已注册
func 按钮已注册(按钮名称: String) -> bool:
	return 按钮注册字典.has(按钮名称)

# 获取按钮的启用状态列表
func 获取按钮启用状态(按钮名称: String) -> Array[UIState]:
	if 按钮注册字典.has(按钮名称):
		return 按钮注册字典[按钮名称]["启用状态"]
	return []

# 获取按钮的禁用状态列表
func 获取按钮禁用状态(按钮名称: String) -> Array[UIState]:
	if 按钮注册字典.has(按钮名称):
		return 按钮注册字典[按钮名称]["禁用状态"]
	return []

# 批量注册按钮
func 批量注册按钮(按钮配置: Dictionary) -> void:
	for 按钮名称 in 按钮配置:
		var 配置 = 按钮配置[按钮名称]
		if 配置.has("引用") and 配置.has("启用状态"):
			var 禁用状态 = 配置.get("禁用状态", [])
			注册按钮(按钮名称, 配置["引用"], 配置["启用状态"], 禁用状态)
#endregion

func 连接事件() -> void:
	# 连接大厅相关事件
	事件总线.大厅_已创建.connect(_当大厅已创建)
	事件总线.大厅_已加入.connect(_当大厅已加入)
	事件总线.大厅_已离开.connect(_当大厅已离开)
	事件总线.大厅列表_已更新.connect(_当大厅列表已更新)
	事件总线.游戏场景_请求加载.connect(_当游戏场景请求加载)
