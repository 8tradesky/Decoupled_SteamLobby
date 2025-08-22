extends Node

# Steam相关事件
signal steam_初始化完成
signal steam_连接失败
signal steam_状态变化

# 大厅相关事件
signal 大厅_已创建(lobby_id: int, lobby_data: Dictionary)
signal 大厅_已加入(lobby_id: int, lobby_data: Dictionary)
signal 大厅_已离开(lobby_id: int)
signal 大厅成员_加入(member_id: int, member_name: String)
signal 大厅成员_离开(member_id: int, member_name: String)
signal 大厅成员_被踢出(member_id: int, member_name: String)
signal 大厅_数据已更新(lobby_id: int, data: Dictionary)

# P2P网络事件
signal p2p_连接已建立(steam_id: int)
signal p2p_连接失败(steam_id: int)
signal p2p_收到数据包(steam_id: int, data: Dictionary)
signal p2p_收到握手(steam_id: int, user_name: String)

# 聊天系统事件
signal 聊天_消息已发送(message: String, success: bool)
signal 聊天_收到消息(sender_id: int, sender_name: String, message: String)
signal 聊天系统_就绪

# UI状态事件
signal UI_状态变化(state: String, visible: bool)
signal UI_按钮状态变化(button_name: String, enabled: bool)
signal 大厅列表_已更新(lobby_list: Array)

# 游戏场景事件
signal 游戏场景_请求加载(scene_path: String)
signal 大厅场景_请求加载

# 单例模式
static var instance: EventBus

func _init():
	instance = self

static func get_instance() -> EventBus:
	return instance

# 便捷方法：发送大厅创建事件
func 发射_大厅已创建(lobby_id: int, lobby_data: Dictionary = {}):
	大厅_已创建.emit(lobby_id, lobby_data)

# 便捷方法：发送大厅加入事件
func 发射_大厅已加入(lobby_id: int, lobby_data: Dictionary = {}):
	大厅_已加入.emit(lobby_id, lobby_data)

# 便捷方法：发送大厅离开事件
func 发射_大厅已离开(lobby_id: int):
	大厅_已离开.emit(lobby_id)

# 便捷方法：发送UI状态变化事件
func 发射_UI状态变化(state: String, visible: bool):
	UI_状态变化.emit(state, visible)

# 便捷方法：发送按钮状态变化事件
func 发射_按钮状态变化(button_name: String, enabled: bool):
	UI_按钮状态变化.emit(button_name, enabled)

# 便捷方法：发送聊天消息事件
func 发射_聊天收到消息(sender_id: int, sender_name: String, message: String):
	聊天_收到消息.emit(sender_id, sender_name, message)

# 便捷方法：发送P2P握手事件
func 发射_p2p收到握手(steam_id: int, user_name: String):
	p2p_收到握手.emit(steam_id, user_name)

func 发射_聊天消息已发送(message: String, success: bool):
	聊天_消息已发送.emit(message,success)
