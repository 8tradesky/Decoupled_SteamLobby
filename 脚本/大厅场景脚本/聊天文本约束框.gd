extends UI界面基类

@onready var chat_display: RichTextLabel = $"房间内聊天界面/大厅文本"
func _init():
	界面名称 = "聊天界面"
	显示状态列表 =[
			UIStateManager.UIState.IN_LOBBY,
			UIStateManager.UIState.CHAT_INTERFACE
		]

func _界面初始化() -> void:
	var chat := MainController.获取聊天系统()
	if chat:
		chat.设置聊天显示(chat_display)
	

func _on_chat_update(chat_message:String):
	pass
