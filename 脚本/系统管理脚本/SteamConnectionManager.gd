class_name SteamConnectionManager
extends Node

# Steam配置
@export var 应用ID: int = 3923510

# Steam状态变量
var steam_initialized: bool = false
var steam_logged_on: bool = false
var steam_id: int = 0
var steam_username: String = ""
var steam_online: bool = false
var steam_owned: bool = false

# Steam信息
#region 新建代码区域
var 已安装仓库: Array
var 可用语言: String
var 应用拥有者: int
var 构建ID: int
var 游戏语言: String
var 安装目录: Dictionary
var 在SteamDeck上: bool
var 在VR中: bool
var 启动命令行: String
var UI语言: String
#endregion

# 事件总线引用
var 事件总线: EventBus

func _ready() -> void:
	# 获取事件总线引用
	事件总线 = EventBus
	
	# 连接事件
	连接事件()
	
	print("Steam连接管理器初始化完成")
	await get_tree().process_frame
	初始化Steam()

func 初始化Steam() -> void:
	# 设置环境变量
	OS.set_environment("SteamAppId", str(应用ID))
	OS.set_environment("SteamGameId", str(应用ID))
	
	# 初始化Steam
	var 初始化结果: Dictionary = Steam.steamInitEx()
	print("Steam初始化结果: ", 初始化结果)
	
	if 初始化结果['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Steam初始化失败，退出游戏: ", 初始化结果)
		事件总线.steam_连接失败.emit()
		#get_tree().quit()
		return
	
	# 获取Steam信息
	获取Steam信息()
	
	# 连接Steam信号
	连接Steam信号()
	
	steam_initialized = true
	事件总线.steam_初始化完成.emit()
	
	print("Steam初始化成功")

func 获取Steam信息() -> void:
	已安装仓库 = Steam.getInstalledDepots(应用ID)
	可用语言 = Steam.getAvailableGameLanguages()
	应用拥有者 = Steam.getAppOwner()
	构建ID = Steam.getAppBuildId()
	游戏语言 = Steam.getCurrentGameLanguage()
	安装目录 = Steam.getAppInstallDir(应用ID)
	在SteamDeck上 = Steam.isSteamRunningOnSteamDeck()
	在VR中 = Steam.isSteamRunningInVR()
	steam_online = Steam.loggedOn()
	steam_owned = Steam.isSubscribed()
	启动命令行 = Steam.getLaunchCommandLine()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	UI语言 = Steam.getSteamUILanguage()
	
	# 更新状态
	steam_logged_on = steam_online
	事件总线.steam_状态变化.emit()

func 连接Steam信号() -> void:
	# 连接Steam状态变化信号
	Steam.persona_state_change.connect(_当用户状态变化)

func _process(_delta: float) -> void:
	if steam_initialized:
		# 限制Steam回调处理频率，避免过度消耗CPU
		if not has_meta("last_steam_callback_time"):
			set_meta("last_steam_callback_time", 0)
		
		var current_time = Time.get_ticks_msec()
		var time_since_last_callback = current_time - get_meta("last_steam_callback_time", 0)
		
		# 每50ms处理一次Steam回调
		if time_since_last_callback >= 50:
			set_meta("last_steam_callback_time", current_time)
			Steam.run_callbacks()

func _当用户状态变化(steam_id: int, flags: int) -> void:
	# 更新用户信息
	if steam_id == self.steam_id:
		steam_username = Steam.getPersonaName()
		事件总线.steam_状态变化.emit()

# 仅用于测试
func 清除成就(成就函数名:String) ->void:
	Steam.clearAchievement(成就函数名)
	Steam.storeStats()
	
func 清除所有数据(是否一并删除成就:bool):
	Steam.resetAllStats(是否一并删除成就)
# 公共接口方法
func 获得统计数据_整数(统计数据名称:String)->int:
	return Steam.getStatInt(统计数据名称)

func 解锁成就(成就函数名:String) -> void:
	Steam.setAchievement(成就函数名)
	Steam.storeStats()
# 检查Steam是否运行
func Steam是否运行() -> bool:
	return Steam.isSteamRunning()

# 检查是否已登录
func 是否已登录() -> bool:
	return Steam.loggedOn()

# 获取Steam ID
func 获取SteamID() -> int:
	return steam_id

# 获取用户名
func 获取用户名() -> String:
	return steam_username

# 检查是否拥有游戏
func 是否拥有游戏() -> bool:
	return steam_owned

# 检查是否在线
func 是否在线() -> bool:
	return steam_online

# 获取应用ID
func 获取应用ID() -> int:
	return 应用ID

# 获取游戏语言
func 获取游戏语言() -> String:
	return 游戏语言

# 获取启动命令行
func 获取启动命令行() -> String:
	return 启动命令行

# 检查是否在Steam Deck上运行
func 在SteamDeck上运行() -> bool:
	return 在SteamDeck上

# 检查是否在VR中运行
func 在VR中运行() -> bool:
	return 在VR中

func 连接事件() -> void:
	pass
