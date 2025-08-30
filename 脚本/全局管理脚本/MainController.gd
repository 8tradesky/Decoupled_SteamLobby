extends Node

# 组件引用
var steam_connection: SteamConnectionManager
var lobby_manager: LobbyManager
var p2p_manager: P2PNetworkManager
var chat_system: ChatSystem
var ui_state_manager: UIStateManager
var event_bus: EventBus

# 玩家组
 



func _ready() -> void:
	# 等待一帧确保所有节点都准备好
	#await get_tree().process_frame
	
	# 初始化事件总线
	event_bus = EventBus
	
	# 初始化所有组件
	_initialize_components()
	
	# 连接事件
	_connect_events()
	
	print("主控制器初始化完成")

func _initialize_components() -> void:
	# 创建Steam连接管理器
	steam_connection = SteamConnectionManager.new()
	add_child(steam_connection)
	steam_connection.name = "SteamConnectManager"
	
	# 创建大厅管理器
	lobby_manager = LobbyManager.new()
	add_child(lobby_manager)
	lobby_manager.name = "LobbyManager"
	
	# 创建P2P网络管理器
	p2p_manager = P2PNetworkManager.new()
	add_child(p2p_manager)
	p2p_manager.name = "P2PNetworkManager"
	
	# 创建聊天系统
	chat_system = ChatSystem.new()
	add_child(chat_system)
	chat_system.name = "ChatSystem"
	
	# 创建UI状态管理器
	ui_state_manager = UIStateManager.new()
	add_child(ui_state_manager)
	ui_state_manager.name = "UIStateManager"
	

func _connect_events() -> void:
	# 连接Steam相关事件
	event_bus.steam_初始化完成.connect(_on_steam_initialized)
	event_bus.steam_连接失败.connect(_on_steam_connection_failed)
	
	# 连接大厅相关事件
	event_bus.大厅_已创建.connect(_on_lobby_created)
	event_bus.大厅_已加入.connect(_on_lobby_joined)
	event_bus.大厅_已离开.connect(_on_lobby_left)
	
	# 连接P2P网络事件
	event_bus.p2p_连接已建立.connect(_on_p2p_connection_established)
	event_bus.p2p_连接失败.connect(_on_p2p_connection_failed)
	
	# 连接聊天事件
	event_bus.聊天_消息已发送.connect(_on_chat_message_sent)
	event_bus.聊天_收到消息.connect(_on_chat_message_received)
	
	# 连接UI事件
	event_bus.UI_状态变化.connect(_on_ui_state_changed)
	event_bus.UI_按钮状态变化.connect(_on_button_state_changed)

func _process(_delta: float) -> void:
	# 处理P2P数据包，添加频率限制和错误处理
	pass
#region 事件处理函数

func _on_steam_initialized() -> void:
	print("Steam初始化成功，可以开始使用大厅功能")
	#ui_state_manager.切换到主菜单()

func _on_steam_connection_failed() -> void:
	print("Steam连接失败")
	# 可以显示错误界面或重试

func _on_lobby_created(lobby_id: int, lobby_data: Dictionary) -> void:
	print("大厅创建成功: %s" % lobby_id)
	ui_state_manager.切换到大厅内()


func _on_lobby_joined(lobby_id: int, lobby_data: Dictionary) -> void:
	print("成功加入大厅: %s" % lobby_id)
	ui_state_manager.切换到大厅内()

func _on_lobby_left(lobby_id: int) -> void:
	print("已离开大厅: %s" % lobby_id)
	ui_state_manager.切换到主菜单()

func _on_p2p_connection_established(steam_id: int) -> void:
	print("P2P连接建立: %s" % steam_id)

func _on_p2p_connection_failed(steam_id: int) -> void:
	print("P2P连接失败: %s" % steam_id)

func _on_chat_message_sent(message: String, success: bool) -> void:
	if success:
		print("聊天消息发送成功: %s" % message)
	else:
		print("聊天消息发送失败: %s" % message)

func _on_chat_message_received(sender_id: int, sender_name: String, message: String) -> void:
	print("收到聊天消息: %s: %s" % [sender_name, message])

func _on_ui_state_changed(state: String, visible: bool) -> void:
	print("UI状态变化: %s, 可见: %s" % [state, visible])

func _on_button_state_changed(button_name: String, enabled: bool) -> void:
	print("按钮状态变化: %s, 启用: %s" % [button_name, enabled])
#endregion
#region 公共接口方法

# 创建大厅
func 创建大厅() -> void:
	if lobby_manager:
		lobby_manager.创建大厅()

# 加入大厅
func 加入大厅(lobby_id: int) -> void:
	if lobby_manager:
		lobby_manager.加入大厅(lobby_id)

# 离开大厅
func 离开大厅() -> void:
	if lobby_manager:
		lobby_manager.离开大厅()

# 请求大厅列表
func 请求大厅列表() -> void:
	if lobby_manager:
		lobby_manager.请求大厅列表()

# 发送聊天消息
func 发送聊天消息(message: String) -> void:
	if chat_system:
		chat_system.发送聊天消息(message)

# 切换到主菜单
func 切换到主菜单() -> void:
	if ui_state_manager:
		print("正在切换到主菜单")
		ui_state_manager.切换到主菜单()
	else:
		print("切换失败")

# 切换到大厅列表
func 切换到大厅列表() -> void:
	if ui_state_manager:
		ui_state_manager.切换到大厅列表()

# 切换到大厅内
func 切换到大厅内() -> void:
	if ui_state_manager:
		ui_state_manager.切换到大厅内()

# 切换到游戏场景
func 切换到游戏场景() -> void:
	if ui_state_manager:
		ui_state_manager.切换到游戏场景()

# 获取组件引用
func 获取Steam连接() -> SteamConnectionManager:
	return steam_connection

func 获取大厅管理器() -> LobbyManager:
	return lobby_manager

func 获取P2P管理器() -> P2PNetworkManager:
	return p2p_manager

func 获取聊天系统() -> ChatSystem:
	return chat_system

func 获取UI状态管理器() -> UIStateManager:
	return ui_state_manager

# 检查系统状态
func Steam已就绪() -> bool:
	return steam_connection and steam_connection.steam_initialized

func 在大厅中() -> bool:
	return lobby_manager and lobby_manager.在大厅中()

func P2P已连接() -> bool:
	return p2p_manager and p2p_manager.多玩家对等体已连接()
#endregion
