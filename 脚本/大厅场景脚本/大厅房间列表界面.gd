extends Panel

@onready var lobby_list: VBoxContainer = $"大厅列表"
@onready var btn_back: Button = $"MarginContainer/HBoxContainer/返回"

func _ready() -> void:
	if not MainController.is_node_ready():
		await MainController.ready
	await get_tree().process_frame
	btn_back.pressed.connect(_on_back_pressed)
	EventBus.大厅列表_已更新.connect(_on_lobby_list_updated)

func _on_back_pressed() -> void:
	MainController.切换到主菜单()

func _on_lobby_list_updated(list: Array) -> void:
	for child in lobby_list.get_children():
		child.queue_free()
	for lobby_data in list:
		var b := Button.new()
		b.text = "大厅 %s: %s [%s] - %s 人" % [
			lobby_data.get("id", 0),
			lobby_data.get("name", "未知"),
			lobby_data.get("mode", "未知"),
			lobby_data.get("num_members", 0)
		]
		b.custom_minimum_size = Vector2(400, 40)
		b.pressed.connect(_on_join_lobby.bind(lobby_data.get("id", 0)))
		lobby_list.add_child(b)

func _on_join_lobby(lobby_id: int) -> void:
	MainController.加入大厅(lobby_id)
