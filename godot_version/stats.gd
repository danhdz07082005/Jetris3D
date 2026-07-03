extends Node

const STATS_FILE = "user://tetris_stats.json"

var data = {
	"total_games": 0,
	"best_score": 0,
	"total_lines": 0,
	"max_streak": 0,
	"pieces_spawned": {},
	"total_time_sec": 0,
	"achievements_unlocked": []
}

var current_session_time = 0.0

const ACHIEVEMENTS = {
	"first_game": {"name": "Nguoi Moi", "desc": "Choi van dau tien", "icon": "[+]"},
	"tetris": {"name": "Tetris!", "desc": "Xoa 4 hang cung luc", "icon": "[*]"},
	"streak_3": {"name": "Chuoi 3", "desc": "Tetris 3 lan lien tiep", "icon": "[!]"},
	"score_1000": {"name": "Top 1000", "desc": "Dat 1000 diem", "icon": "[^]"},
	"clear_100": {"name": "Tho Gach", "desc": "Xoa 100 hang tong cong", "icon": "[#]"},
	"level_5": {"name": "Toc Do", "desc": "Dat cap do 5", "icon": "[>]"},
	"score_10k": {"name": "Huyen Thoai", "desc": "Dat 10,000 diem", "icon": "[$]"}
}

signal achievement_unlocked(ach_id, ach_info)

func _ready():
	load_stats()

func _process(delta):
	current_session_time += delta

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		data["total_time_sec"] += int(current_session_time)
		current_session_time = 0.0
		save_stats()

func load_stats():
	if FileAccess.file_exists(STATS_FILE):
		var file = FileAccess.open(STATS_FILE, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(text)
			if error == OK:
				var loaded_data = json.data
				for k in loaded_data.keys():
					data[k] = loaded_data[k]

func save_stats():
	var file = FileAccess.open(STATS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func record_game_over(score: int, lines: int, pieces: Dictionary):
	data["total_games"] += 1
	if score > data["best_score"]:
		data["best_score"] = score
		
	for p in pieces.keys():
		if not data["pieces_spawned"].has(p):
			data["pieces_spawned"][p] = 0
		data["pieces_spawned"][p] += pieces[p]
		
	data["total_time_sec"] += int(current_session_time)
	current_session_time = 0.0
	save_stats()
	_check_unlock("first_game", data["total_games"] > 0)

func check_event(event_type: String, val1 = null, val2 = null):
	if event_type == "score":
		if val1 >= 1000: _check_unlock("score_1000", true)
		if val1 >= 10000: _check_unlock("score_10k", true)
	elif event_type == "lines_cleared":
		if val1 >= 4: _check_unlock("tetris", true)
		data["total_lines"] += val1
		if data["total_lines"] >= 100: _check_unlock("clear_100", true)
	elif event_type == "level":
		if val1 >= 5: _check_unlock("level_5", true)
	elif event_type == "tetris_streak":
		if val1 > data["max_streak"]: data["max_streak"] = val1
		if val1 >= 3: _check_unlock("streak_3", true)

func _check_unlock(ach_id: String, condition: bool):
	if condition and not data["achievements_unlocked"].has(ach_id):
		data["achievements_unlocked"].append(ach_id)
		save_stats()
		emit_signal("achievement_unlocked", ach_id, ACHIEVEMENTS[ach_id])

func get_challenge_hint() -> String:
	if data["total_games"] == 0: return "Hay choi van dau tien!"
	if not data["achievements_unlocked"].has("tetris"): return "Ban chua xoa duoc 4 hang cung luc. Hay kien nhan!"
	if data["best_score"] > 0: return "Ky luc hien tai cua ban la %d. Thu vuot qua nao!" % data["best_score"]
	return "Gi lai ky luc moi!"
