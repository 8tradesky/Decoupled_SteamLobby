extends MarginContainer

@onready var btn_create: Button = $"Panel/加入\\创建前按钮/创建大厅"
@onready var btn_join: Button = $"Panel/加入\\创建前按钮/加入大厅"
@onready var btn_exit: Button = $"Panel/加入\\创建前按钮/退出"

func _ready() -> void:
	if not MainController.is_node_ready():
		await MainController.ready
	await get_tree().process_frame
	btn_create.pressed.connect(_on_create_pressed)
	btn_join.pressed.connect(_on_join_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

func _on_create_pressed() -> void:
	MainController.创建大厅()

func _on_join_pressed() -> void:
	MainController.切换到大厅列表()
	MainController.请求大厅列表()

func _on_exit_pressed() -> void:
	get_tree().quit()
