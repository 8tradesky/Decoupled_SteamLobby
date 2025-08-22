extends UI界面基类

@onready var app_id_label_2: Label = $VBoxContainer/AppID/AppIDLabel2
@onready var steam登入者id_label_2: Label = $VBoxContainer/Steam登入者ID/Steam登入者IDLabel2
@onready var steam登入者名称label_2: Label = $VBoxContainer/Steam登入者名称/Steam登入者名称Label2
@onready var app所有者label_2: Label = $VBoxContainer/APP所有者/App所有者Label2

var Steam连接管理器: SteamConnectionManager
var 事件总线: EventBus
var AppID
var Steam登入者ID
var Steam登入者名称
var App所有者

# 重写基类属性
func _init():
	界面名称 = "初始界面"
	显示状态列表 = [
		UIStateManager.UIState.INITIALIZED,  # 初始化状态时显示
		UIStateManager.UIState.MAIN_MENU    # 主菜单状态时也显示
	]

# 重写界面初始化方法
func _界面初始化() -> void:
	事件总线 = EventBus
	Steam连接管理器 = MainController.steam_connection
	_加载Steam信息()
	
func _加载Steam信息():
	print("初始界面加载Steam信息")
	AppID = Steam连接管理器.应用ID
	Steam登入者ID = Steam连接管理器.steam_id
	Steam登入者名称 = Steam连接管理器.steam_username
	App所有者 = Steam连接管理器.应用拥有者
	_更新信息()

func _更新信息():
	app_id_label_2.text = str(AppID)
	steam登入者id_label_2.text = str(Steam登入者ID)
	steam登入者名称label_2.text = Steam登入者名称
	app所有者label_2.text = str(App所有者)
