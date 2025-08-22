class_name P2PNetworkManager
extends Node

const 数据包读取限制: int = 32

var 房主SteamID: int
# P2P连接状态
var steam对等体: SteamMultiplayerPeer
var 已连接对等体: Array = []
var 大厅ID: int = 0

# 事件总线引用
var 事件总线: EventBus
var 大厅管理器: LobbyManager

func _ready() -> void:
	# 获取事件总线引用
	await get_tree().process_frame
	事件总线 = EventBus
	大厅管理器 = get_node("/root/MainController/LobbyManager")
	
	# 连接事件
	连接事件()
	
	print("P2P网络管理器初始化完成")

func 连接事件() -> void:
	Steam.lobby_created.connect(_当大厅创建回调)
	Steam.lobby_joined.connect(_当大厅加入回调)
	事件总线.大厅_已离开.connect(_当大厅离开回调)
	multiplayer.connected_to_server.connect(_连接服务器回调)

func _连接服务器回调():
	print("连接到")
	发送P2P握手()

func _当大厅创建回调(connect: int, lobby_id: int) -> void:
	self.大厅ID = lobby_id
	print("创建大厅完成,正在设置Steam对等体")
	创建Steam套接字()

func _当大厅加入回调(this_lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	self.大厅ID = this_lobby_id
	var id = Steam.getLobbyOwner(this_lobby_id)
	print("加入大厅完成,正在设置Steam对等体")
	if id != Steam.getSteamID():
		房主SteamID = id
		连接Steam套接字(房主SteamID)

func _当大厅离开回调(lobby_id: int) -> void:
	self.大厅ID = 0
	断开所有对等体()

# 创建Steam Socket（作为房主）
func 创建Steam套接字() -> void:
	steam对等体 = SteamMultiplayerPeer.new()
	steam对等体.create_host(8080)
	multiplayer.set_multiplayer_peer(steam对等体)
	
	# 允许P2P数据包中继
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print("允许Steam中继备份: %s" % set_relay)

# 连接到Steam Socket（作为客户端）
func 连接Steam套接字(steam_id: int) -> void:
	steam对等体 = SteamMultiplayerPeer.new()
	steam对等体.create_client(steam_id, 8080)
	multiplayer.set_multiplayer_peer(steam对等体)
	print("连接到Steam ID: %s" % steam_id)

# 断开所有P2P连接
func 断开所有对等体() -> void:
	if 大厅管理器:
		var members = 大厅管理器.大厅成员列表
		for member in members:
			var member_steam_id = member.get("steam_id", 0)
			if member_steam_id != 0:
				Steam.closeP2PSessionWithUser(member_steam_id)
	
	已连接对等体.clear()

# 发送P2P数据包
func 发送P2P数据包(目标ID: int, 数据包内容: Dictionary, 发送类型: int = 0) -> void:
	var channel: int = 0
	var data: PackedByteArray = var_to_bytes(数据包内容)
	
	if 目标ID == 0:  # 发送给所有成员
		print("P2P数据包正在发送给所有用户")
		if 大厅管理器:
			var members = 大厅管理器.大厅成员列表
			for member in members:
				var member_steam_id = member.get("steam_id", 0)
				if member_steam_id != 0:
					Steam.sendP2PPacket(member_steam_id, data, 发送类型, channel)
	else:  # 发送给特定用户
		print("P2P数据包正在发送给%s" % 目标ID)
		Steam.sendP2PPacket(目标ID, data, 发送类型, channel)

# 读取P2P数据包
func 读取所有P2P数据包(读取计数: int = 0) -> void:
	# 检查P2P连接状态
	if not _P2P是否就绪():
		print("警告: P2P连接未就绪，跳过数据包读取")
		return
	if 读取计数 >= 数据包读取限制:
		return
		
	if Steam.getAvailableP2PPacketSize(0) >=0:
		读取P2P数据包()
		读取所有P2P数据包(读取计数 + 1)

# 检查P2P连接是否就绪
func _P2P是否就绪() -> bool:
	# 检查Steam是否运行
	if not Steam.isSteamRunning():
		print("Steam未运行")
		return false
	
	# 检查是否在大厅中
	if 大厅ID <= 0:
		print("未处于大厅中")
		return false
	
	# 检查SteamMultiplayerPeer状态
	if steam对等体 == null:
		print("steam对等体未设置")
		return false
	
	# 检查连接状态
	var connection_status = steam对等体.get_connection_status()
	if connection_status != MultiplayerPeer.CONNECTION_CONNECTED:
		print("未连接,Steam对等体连接状态为:",connection_status)
		return false
	
	return true

func 读取P2P数据包() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size <= 0:
		return  # 没有数据包
	
	# 限制数据包大小，防止过大的数据包导致问题
	if packet_size > 1024 * 1024:  # 1MB限制
		print("警告: 数据包过大，跳过: %s bytes" % packet_size)
		# 丢弃过大的数据包
		var dummy_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		return
	
	# 添加异常捕获
	var packet: Dictionary
	var readable_data: Dictionary
	
	# 安全读取数据包
	packet = Steam.readP2PPacket(packet_size, 0)
	if packet.is_empty():
		print("警告: 读取P2P数据包失败")
		return
	
	# 检查数据包结构
	if not packet.has('remote_steam_id') or not packet.has('data'):
		print("警告: P2P数据包结构无效")
		return
	
	var sender_id: int = packet.get('remote_steam_id', 0)
	var packet_data: PackedByteArray = packet.get('data', PackedByteArray())
	
	if sender_id == 0 or packet_data.is_empty():
		print("警告: P2P数据包数据无效")
		return
	
	# 安全解析数据
	if packet_data.size() > 0:
		# 使用Godot的错误处理方式
		var parse_success = false
		
		# 检查数据包是否包含有效的Godot变量数据
		if packet_data.size() >= 4:  # 至少需要4字节的头部
			# 尝试解析数据
			readable_data = bytes_to_var(packet_data)
			
			# 检查解析结果
			if readable_data != null:
				parse_success = true
			else:
				print("警告: P2P数据包解析返回null")
		else:
			print("警告: P2P数据包太小，无法解析")
		
		if parse_success and readable_data != null:
			处理P2P数据包(sender_id, readable_data)
		else:
			print("警告: P2P数据包解析失败")
	else:
		print("警告: P2P数据包大小为0")

func 处理P2P数据包(发送者ID: int, 数据: Dictionary) -> void:
	if not 数据.has("message"):
		print("警告: P2P数据包缺少message字段")
		return
	
	match 数据["message"]:
		"handshake":
			var user_name = 数据.get("user_name", "未知用户")
			事件总线.发射_p2p收到握手(发送者ID, user_name)
			print("收到P2P握手: %s" % user_name)
		"chat":
			var message = 数据.get("content", "")
			var sender_name = 数据.get("sender_name", "未知用户")
			事件总线.发射_聊天收到消息(发送者ID, sender_name, message)
		_:
			print("未知P2P消息类型: %s" % 数据["message"])

func _process(delta: float) -> void:
	if 大厅ID > 0 :
		读取所有P2P数据包()
# 发送P2P握手

func 发送P2P握手() -> void:
	# 检查连接状态
	print("正在尝试P2P握手")
	if not _P2P是否就绪():
		print("警告: 无法发送P2P握手，连接未就绪")
		return
	
	var handshake_data = {
		"message": "handshake",
		"steam_id": Steam.getSteamID(),
		"user_name": Steam.getPersonaName(),
		"timestamp": Time.get_ticks_msec()
	}
	
	print("发送P2P握手数据: %s" % handshake_data)
	发送P2P数据包(0, handshake_data,2)

# 发送聊天消息
func 发送聊天消息(消息: String) -> void:
	# 检查连接状态
	if not _P2P是否就绪():
		print("警告: 无法发送聊天消息，连接未就绪")
		return
	
	var chat_data = {
		"message": "chat",
		"content": 消息,
		"sender_name": Steam.getPersonaName(),
		"timestamp": Time.get_ticks_msec()
	}
	发送P2P数据包(0, chat_data)

# 公共接口
func 多玩家对等体已连接() -> bool:
	return steam对等体 != null and steam对等体.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func 获取连接状态() -> int:
	if steam对等体:
		return steam对等体.get_connection_status()
	return MultiplayerPeer.CONNECTION_DISCONNECTED

func 获取唯一ID() -> int:
	if steam对等体:
		return steam对等体.get_unique_id()
	return 0
