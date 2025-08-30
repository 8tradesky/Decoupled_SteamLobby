extends UI界面基类

@onready var input_chat: TextEdit = $"VBoxContainer/聊天框/Chat"
@onready var btn_send: Button = $"VBoxContainer/聊天框/发送"
@onready var btn_leave: Button = $"VBoxContainer/底部按钮/返回"
@onready var btn_connect: Button = $"VBoxContainer/底部按钮/连接Godot并加入玩家实例"
func _init():
	界面名称 = "大厅内界面"
	显示状态列表 = [
			UIStateManager.UIState.IN_LOBBY
		]

func _界面初始化() -> void:
	var chat := MainController.获取聊天系统()
	print(chat.name)
	if chat:
		# ChatSystem 需要 RichTextLabel/LineEdit/Button，这里做最接近的适配
		# 如果你有 `界面/聊天文本约束框` 中的 RichTextLabel，可在 大厅.gd 里统一设置
		chat.设置聊天输入(input_chat)
		chat.设置发送按钮(btn_send)
	
	
	btn_send.pressed.connect(_on_send)
	btn_leave.pressed.connect(_on_leave)
	btn_connect.pressed.connect(_on_connect)

func _on_send() -> void:
	var text := input_chat.text.strip_edges()
	if text.length() > 0:
		MainController.发送聊天消息(text)

func _on_leave() -> void:
	MainController.离开大厅()

func _on_connect() -> void:
	
	EventBus.发射_多人游戏开始()
	# 示例：这里可触发进入游戏或连接逻辑，按需替换
	print("连接Godot并加入玩家实例：请在此实现你的逻辑")
