class_name ChatSystem
extends Node

# 聊天配置
@export var 最大聊天历史条数: int = 100
@export var 自动滚动: bool = true

# 聊天数据
var 聊天历史: Array = []
var 大厅ID: int = 0

# UI引用
@onready var 文本显示: RichTextLabel
@onready var 文本输入: TextEdit
@onready var 发送按钮: Button

# 事件总线引用
var 事件总线: EventBus
var 大厅管理器: LobbyManager
var P2P管理器: P2PNetworkManager

func _ready() -> void:
	# 获取事件总线引用
	事件总线 = EventBus
	
	# 连接事件
	连接事件()
	
	print("聊天系统初始化完成")

func 连接事件() -> void:
	大厅管理器 = get_node("/root/MainController/LobbyManager")
	P2P管理器 = get_node_or_null("/root/MainController/P2PNetworkManager")
	
	# 连接事件（已本地化信号名）
	事件总线.大厅_已创建.connect(_当大厅已创建)
	事件总线.大厅_已加入.connect(_当大厅已加入)
	事件总线.大厅_已离开.connect(_当大厅已离开)
	事件总线.聊天_收到消息.connect(_当收到聊天消息)
	事件总线.p2p_收到握手.connect(_当收到P2P握手)
	事件总线.大厅_数据已更新.connect(_当大厅数据已更新)
	事件总线.大厅成员_加入.connect(_当大厅成员加入)
	
	# 连接输入信号
	if 文本输入 and 文本输入.has_signal("text_submitted"):
		文本输入.text_submitted.connect(_当文本提交)
	
	if 发送按钮:
		发送按钮.pressed.connect(_当发送按钮按下)

func _当大厅已加入(加入大厅ID: int, 大厅数据字典: Dictionary) -> void:
	print("收到事件处理器进入大厅信号")
	if self.大厅ID == 加入大厅ID:
		清空聊天()
		添加系统消息("已创建大厅: %s" % 大厅数据字典.get("name", "未知大厅"))
	else:
		self.大厅ID = 加入大厅ID
		添加系统消息("已加入大厅: %s" % 大厅数据字典.get("name", "未知大厅"))

func _当大厅已创建(创建大厅ID: int, 大厅数据字典: Dictionary):
	print("收到事件处理器创建大厅信号")
	self.大厅ID = 创建大厅ID
	清空聊天()
	添加系统消息("已创建大厅: %s" % 大厅数据字典.get("name", "未知大厅"))

func _当大厅已离开(_离开大厅ID: int) -> void:
	self.大厅ID = 0
	添加系统消息("已离开大厅")
	清空聊天()

func _当大厅数据已更新(_this_lobby_id:int ,_data:Dictionary):
	pass

func _当大厅成员加入(_change_id:int, 加入者名称:String):
	添加系统消息("玩家 %s 加入房间!" % 加入者名称)

func _当收到聊天消息(发送者ID: int, 发送者名称: String, 消息内容: String) -> void:
	添加聊天消息(发送者名称, 消息内容, false)

func _当收到P2P握手(_steam_id: int, 用户名: String) -> void:
	添加系统消息("玩家 %s P2P连接完成!" % 用户名)

# 聊天输入处理
func _当文本提交(文本: String) -> void:
	发送聊天消息(文本)

func _当发送按钮按下() -> void:
	if 文本输入:
		var 文本 = 文本输入.text.strip_edges()
		if 文本.length() > 0:
			发送聊天消息(文本)

# 发送聊天消息
func 发送聊天消息(消息: String) -> void:
	if 大厅ID == 0:
		添加系统消息("错误: 未在大厅中")
		return
	
	if 消息.length() == 0:
		return
	
	# 通过Steam大厅聊天发送
	var 已发送: bool = Steam.sendLobbyChatMsg(大厅ID, 消息)
	
	if 已发送:
		# 添加到本地历史
		添加聊天消息(Steam.getPersonaName(), 消息, true)
		
		# 通过P2P发送（如果需要）
		#if P2P管理器:
			#P2P管理器.send_chat_message(消息)
		
		# 清空输入框
		if 文本输入:
			文本输入.clear()
		
		事件总线.发射_聊天消息已发送(消息, true)
	else:
		添加系统消息("错误: 聊天消息发送失败")
		事件总线.发射_聊天消息已发送(消息, false)

# 添加聊天消息到历史
func 添加聊天消息(发送者名称: String, 消息内容: String, 是否本地: bool = false) -> void:
	var 时间戳 = Time.get_datetime_string_from_system()
	var 聊天条目 = {
		"timestamp": 时间戳,
		"sender": 发送者名称,
		"message": 消息内容,
		"is_local": 是否本地
	}
	
	聊天历史.append(聊天条目)
	
	# 限制历史记录数量
	if 聊天历史.size() > 最大聊天历史条数:
		聊天历史.pop_front()
	
	# 更新显示
	更新聊天显示()
	
	# 自动滚动到底部
	if 自动滚动 and 文本显示:
		await get_tree().process_frame
		文本显示.scroll_to_line(文本显示.get_line_count() - 1)

# 添加系统消息
func 添加系统消息(消息: String) -> void:
	var 时间戳 = Time.get_datetime_string_from_system()
	var 聊天条目 = {
		"timestamp": 时间戳,
		"sender": "系统",
		"message": 消息,
		"is_system": true
	}
	
	聊天历史.append(聊天条目)
	
	if 聊天历史.size() > 最大聊天历史条数:
		聊天历史.pop_front()
	
	更新聊天显示()
	
	if 自动滚动 and 文本显示:
		await get_tree().process_frame
		文本显示.scroll_to_line(文本显示.get_line_count() - 1)

# 更新聊天显示
func 更新聊天显示() -> void:
	if not 文本显示:
		return
	
	# 使用RichTextLabel的颜色栈渲染，不依赖BBCode
	文本显示.clear()
	
	for entry in 聊天历史:
		var 时间戳 = entry.get("timestamp", "")
		var 发送者 = entry.get("sender", "")
		var 内容 = entry.get("message", "")
		var 是否系统 = entry.get("is_system", false)
		var 是否本地 = entry.get("is_local", false)
		
		var 时间文本 = "[%s]" % 时间戳
		var 行文本 := ""
		var 颜色 := Color(1, 1, 1, 1) # 默认白色
		
		if 是否系统:
			行文本 = "%s [系统] %s\n" % [时间文本, 内容]
			颜色 = Color(1.0, 0.84, 0.0, 1.0) # 金黄
		elif 是否本地:
			行文本 = "%s [我] %s\n" % [时间文本, 内容]
			颜色 = Color(0.0, 0.8, 0.2, 1.0) # 绿色
		else:
			行文本 = "%s %s: %s\n" % [时间文本, 发送者, 内容]
			颜色 = Color(1, 1, 1, 1) # 白色
		
		文本显示.push_color(颜色)
		文本显示.append_text(行文本)
		文本显示.pop()
	
	# 保持与之前逻辑一致，滚动到底部由调用处处理

# 清空聊天
func 清空聊天() -> void:
	聊天历史.clear()
	if 文本显示:
		文本显示.text = ""

# 设置UI引用
func 设置聊天显示(display: RichTextLabel) -> void:
	文本显示 = display
	更新聊天显示()

func 设置聊天输入(input: TextEdit) -> void:
	文本输入 = input
	print(文本输入.name)
	if 文本输入 and 文本输入.has_signal("text_submitted"):
		文本输入.text_submitted.connect(_当文本提交)

func 设置发送按钮(button: Button) -> void:
	发送按钮 = button
	if 发送按钮:
		发送按钮.pressed.connect(_当发送按钮按下)

# 公共接口
func 获取聊天历史() -> Array:
	return 聊天历史.duplicate()

func 获取最新消息(count: int) -> Array:
	if count >= 聊天历史.size():
		return 聊天历史.duplicate()
	
	var start_index = 聊天历史.size() - count
	return 聊天历史.slice(start_index).duplicate()

func 在大厅中() -> bool:
	return 大厅ID != 0
