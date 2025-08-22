extends MarginContainer

@onready var chat_display: RichTextLabel = $"房间内聊天界面/大厅文本"

func _ready() -> void:
	if not MainController.is_node_ready():
		await MainController.ready
	await get_tree().process_frame
	var chat := MainController.获取聊天系统()
	if chat:
		chat.设置聊天显示(chat_display)

func _on_chat_update(chat_message:String):
	pass
