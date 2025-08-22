class_name LobbyManager
extends Node

# 大厅配置
@export var 最大成员数: int = 10
@export var 大厅类型: int = Steam.LOBBY_TYPE_PUBLIC

# 大厅状态
var 当前大厅ID: int = 0
var 大厅房主ID: int = 0
var 大厅成员列表: Array = []
var 大厅数据: Dictionary = {}
var 大厅列表: Array = []

# 事件总线引用
var 事件总线: EventBus

func _ready() -> void:
	# 获取事件总线引用
	事件总线 = EventBus
	
	# 连接事件
	连接事件()
	
	print("大厅管理器初始化完成")

func 连接事件() -> void:
	连接大厅信号()

func 连接大厅信号() -> void:
	Steam.lobby_created.connect(_当大厅创建回调)
	Steam.lobby_joined.connect(_当大厅加入回调)
	Steam.lobby_message.connect(_当收到大厅聊天消息)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.lobby_chat_update.connect(_当大厅聊天变更)
	Steam.lobby_match_list.connect(_当收到大厅列表)
	Steam.join_requested.connect(_当请求加入大厅)

func _检查命令行参数() -> void:
	var arguments: Array = OS.get_cmdline_args()
	if arguments.size() > 0 and arguments[0] == "+connect_lobby":
		if int(arguments[1]) > 0:
			加入大厅(int(arguments[1]))

# 大厅创建
func 创建大厅() -> void:
	if 当前大厅ID != 0:
		print("已在大厅中，无法创建新大厅")
		return
	
	# 检查Steam是否已初始化
	if not Steam.isSteamRunning():
		print("错误: Steam未运行")
		return
	
	print("创建大厅")
	Steam.createLobby(大厅类型, 最大成员数)

func _当收到大厅聊天消息(_this_lobby_id: int, user: int, message: String, chat_type: int):
	if _this_lobby_id == 当前大厅ID and chat_type == Steam.ChatEntryType.CHAT_ENTRY_TYPE_CHAT_MSG and user != Steam.getSteamID():
		事件总线.发射_聊天收到消息(user,Steam.getFriendPersonaName(user),message)

func _当大厅创建回调(connect: int, lobby_id: int) -> void:
	print("Steam试图创建房间")
	if connect == 1:
		当前大厅ID = lobby_id
		大厅房主ID = Steam.getSteamID()
		
		# 设置大厅属性
		Steam.setLobbyJoinable(lobby_id, true)
		
		var lobby_name: String = Steam.getPersonaName() + "的大厅"
		var lobby_mode: String = "GodotSteam测试"
		Steam.setLobbyData(lobby_id, "name", lobby_name)
		Steam.setLobbyData(lobby_id, "mode", lobby_mode)
		
		大厅数据 = {
			"name": lobby_name,
			"mode": lobby_mode,
			"owner_id": 大厅房主ID
		}
		print("创建完成,发送完成信号")
		事件总线.发射_大厅已创建(lobby_id, 大厅数据)
		
		# 延迟获取成员信息，避免在回调中立即调用
		await get_tree().process_frame
		获取大厅成员()
	else:
		print("大厅创建失败")

# 大厅加入
func 加入大厅(lobby_id: int) -> void:
	if lobby_id <= 0:
		print("错误: 无效的大厅ID")
		return
	
	# 检查Steam是否已初始化
	if not Steam.isSteamRunning():
		print("错误: Steam未运行")
		return
	
	大厅成员列表.clear()
	大厅数据.clear()
	print("正在加入大厅: %s" % lobby_id)
	Steam.joinLobby(lobby_id)

func _当大厅加入回调(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	print("大厅加入响应: lobby_id=%s, response=%s" % [lobby_id, response])
	
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		当前大厅ID = lobby_id
		大厅房主ID = Steam.getLobbyOwner(lobby_id)
		
		var lobby_name: String = Steam.getLobbyData(lobby_id, "name")
		var lobby_mode: String = Steam.getLobbyData(lobby_id, "mode")
		
		大厅数据 = {
			"name": lobby_name,
			"mode": lobby_mode,
			"owner_id": 大厅房主ID
		}
		
		print("成功加入大厅: %s" % lobby_id)
		
		# 延迟获取成员信息
		await get_tree().process_frame
		获取大厅成员()
		事件总线.发射_大厅已加入(lobby_id, 大厅数据)
	else:
		print("加入大厅失败，响应码: %s" % response)

func _当请求加入大厅(lobby_id: int, friend_id: int) -> void:
	加入大厅(lobby_id)

# 大厅离开
func 离开大厅() -> void:
	if 当前大厅ID == 0:
		return
	
	Steam.leaveLobby(当前大厅ID)
	
	var old_lobby_id = 当前大厅ID
	当前大厅ID = 0
	大厅房主ID = 0
	大厅成员列表.clear()
	大厅数据.clear()
	
	事件总线.发射_大厅已离开(old_lobby_id)

# 获取大厅成员
func 获取大厅成员() -> void:
	大厅成员列表.clear()
	var num_members: int = Steam.getNumLobbyMembers(当前大厅ID)
	
	for i in range(num_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(当前大厅ID, i)
		var member_name: String = Steam.getFriendPersonaName(member_steam_id)
		大厅成员列表.append({
			"steam_id": member_steam_id,
			"name": member_name
		})

# 大厅列表
func 请求大厅列表() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _当收到大厅列表(lobbies: Array) -> void:
	大厅列表.clear()
	for lobby_id in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby_id, "name")
		var lobby_mode: String = Steam.getLobbyData(lobby_id, "mode")
		var num_members: int = Steam.getNumLobbyMembers(lobby_id)
		大厅列表.append({
			"id": lobby_id,
			"name": lobby_name,
			"mode": lobby_mode,
			"num_members": num_members
		})
	事件总线.大厅列表_已更新.emit(大厅列表)

func _当大厅聊天变更(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		事件总线.大厅成员_加入.emit(change_id,changer_name)
		print("%s has joined the lobby." % changer_name)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		事件总线.大厅成员_离开.emit(change_id,changer_name)
		print("%s has left the lobby." % changer_name)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)

	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)

	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)

	# Update the lobby now that a change has occurred
	获取大厅成员()

# 公共接口
func 获取当前大厅ID() -> int:
	return 当前大厅ID

func 在大厅中() -> bool:
	return 当前大厅ID != 0
