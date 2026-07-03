extends Control

# ╔══════════════════════════════════════════════════╗
# ║             HẰNG SỐ HÌNH DẠNG & MÀU SẮC        ║
# ╚══════════════════════════════════════════════════╝
const SHAPES = {
	"I": [[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]],
	"O": [[1,1],[1,1]],
	"T": [[0,1,0],[1,1,1],[0,0,0]],
	"S": [[0,1,1],[1,1,0],[0,0,0]],
	"Z": [[1,1,0],[0,1,1],[0,0,0]],
	"J": [[1,0,0],[1,1,1],[0,0,0]],
	"L": [[0,0,1],[1,1,1],[0,0,0]]
}
const SHAPE_COLORS = {
	"I": Color(0.00, 0.85, 1.00), "O": Color(1.00, 0.85, 0.00), "T": Color(0.72, 0.00, 1.00),
	"S": Color(0.00, 0.92, 0.35), "Z": Color(1.00, 0.22, 0.22), "J": Color(0.18, 0.35, 1.00), "L": Color(1.00, 0.50, 0.00)
}
# Theme: Dung Nham (Lava) — màu nham thạch rực lửa theo chuẩn gạch dễ nhận diện
const LAVA_COLORS = {
	"I": Color(1.00, 0.75, 0.15), # Vàng lửa tươi sáng
	"O": Color(1.00, 0.50, 0.00), # Cam sáng
	"T": Color(0.80, 0.20, 0.70), # Tím nham thạch rực rỡ hơn
	"S": Color(0.75, 0.95, 0.15), # Lửa vàng xanh tươi
	"Z": Color(1.00, 0.15, 0.10), # Đỏ dung nham rực
	"J": Color(0.25, 0.45, 1.00), # Lam hoả volcanic sáng
	"L": Color(1.00, 0.35, 0.00)  # Cam nhạt lửa sáng tươi
}
const ICE_COLORS = {
	"I": Color(0.45, 0.90, 1.00), # Xanh băng sáng bừng
	"O": Color(1.00, 0.95, 0.65), # Vàng nhạt băng giá sáng
	"T": Color(0.75, 0.65, 1.00), # Tím hoa anh thảo băng sáng
	"S": Color(0.45, 0.95, 0.75), # Lục bạc frost tươi
	"Z": Color(1.00, 0.60, 0.70), # Hồng phấn băng tuyết rực rỡ
	"J": Color(0.30, 0.60, 1.00), # Lam sậm sông băng tươi sáng
	"L": Color(1.00, 0.75, 0.55)  # Cam đào tuyết phủ sáng
}

func _get_piece_color(piece_name: String) -> Color:
	match _settings.get("theme", "default"):
		"lava": return LAVA_COLORS.get(piece_name, Color.WHITE)
		"ice":  return ICE_COLORS.get(piece_name, Color.WHITE)
		_:      return SHAPE_COLORS.get(piece_name, Color.WHITE)

# ╔══════════════════════════════════════════════════╗
# ║             DỮ LIỆU TỪ GAME                    ║
# ╚══════════════════════════════════════════════════╝
var _score        : int    = 0
var _level        : int    = 1
var _lines        : int    = 0
var _next_queue   : Array  = []
var _hold_name    : String = ""
var _hold_shape   : Array  = []
var _hold_color   : Color  = Color.WHITE
var _hold_size    : int    = 0
var _can_hold     : bool   = true
var _game_over    : bool   = false
var _paused       : bool   = false
var _show_settings: bool   = false
var _show_stats   : bool   = false
var _stats_data   = null
var _hint         : String = ""
var _settings     = {}
var _ach_queue    = []
var _current_ach  = null
var _ach_timer    = 0.0
var _flash_timer  = 0.0
var _finesse_faults: int    = 0
var _time_elapsed  : float  = 0.0
var _last_action_label : String = ""
var _action_label_timer : float = 0.0

# ╔══════════════════════════════════════════════════╗
# ║             THIẾT KẾ & LAYOUT                  ║
# ╚══════════════════════════════════════════════════╝
const SIDEBAR_W    = 265.0
const CONTENT_W    = 238.0
const HOLD_PANEL_W = 120.0
const HOLD_PANEL_H = 115.0

var sidebar_x : float = 620.0
var content_x : float = 634.0

const C_BG        = Color(0.05, 0.06, 0.10, 0.90)
const C_BG_DARK   = Color(0.03, 0.03, 0.07, 0.92)
const C_TEXT      = Color(0.96, 0.96, 0.98, 1.0)
const C_MUTED     = Color(0.52, 0.55, 0.68, 1.0)
const C_ACCENT    = Color(0.00, 0.72, 1.00, 1.0)
const C_BORDER    = Color(0.20, 0.25, 0.50, 0.85)
const C_BORDER_DIM= Color(0.12, 0.14, 0.28, 0.70)
const C_DANGER    = Color(1.00, 0.22, 0.22, 1.0)
const C_SUCCESS   = Color(0.18, 0.85, 0.35, 1.0)

# Rects cho slider/button (gán trong _draw)
var btn_rect_music_vol    : Rect2
var btn_rect_sfx_vol      : Rect2
var btn_rect_music_toggle : Rect2
var btn_rect_ghost_toggle : Rect2
var btn_rect_neon_toggle  : Rect2
var btn_rect_level_slider : Rect2
var btn_rect_fall_speed_slider : Rect2
var btn_rect_dcd_slider   : Rect2
var btn_rects_soft_drop        : Array[Rect2] = []
var btn_rects_grid_style       : Array[Rect2] = []
var btn_rect_das_slider   : Rect2
var btn_rect_arr_slider   : Rect2
var btn_rect_speed_sidebar: Rect2
var btn_rect_theme_default: Rect2
var btn_rect_theme_lava   : Rect2
var btn_rect_theme_ice    : Rect2
var btn_rect_tab_game     : Rect2
var btn_rect_tab_controls : Rect2
var _remap_buttons        : Dictionary = {}  # action -> Rect2

var active_slider : String = ""
var _settings_tab : int    = 0   # 0 = Trò chơi, 1 = Điều khiển
var _remap_action : String = ""  # Đang chờ gán phím cho action này

# ╔══════════════════════════════════════════════════╗
# ║             TIMERS & HIỆU ỨNG                  ║
# ╚══════════════════════════════════════════════════╝
var _combo_count       : int   = 0
var combo_timer        : float = 0.0
var level_up_timer     : float = 0.0
var t_spin_timer       : float = 0.0
var perfect_clear_timer: float = 0.0

# ╔══════════════════════════════════════════════════╗
# ║             API TỪ MAIN                        ║
# ╚══════════════════════════════════════════════════╝
func update_hud(
	score: int, level: int, lines: int,
	next_q: Array,
	h_name: String, h_shape: Array, h_color: Color, h_size: int,
	can_hold: bool, is_go: bool, is_paused: bool,
	show_set: bool, show_st: bool, stats_d, hint_text: String, set_d: Dictionary,
	combo_c: int = 0, t_spin: bool = false, perfect_clear: bool = false,
	finesse: int = 0, elapsed_time: float = 0.0, action_label: String = ""
) -> void:
	if _level > 0 and level > _level:
		level_up_timer = 2.5
	if combo_c > 0 and combo_c != _combo_count:
		combo_timer = 1.8
	_combo_count = combo_c
	if t_spin:       t_spin_timer       = 1.8
	if perfect_clear: perfect_clear_timer = 3.0
	if action_label != "":
		_last_action_label = action_label
		_action_label_timer = 1.8

	_score         = score
	_level         = level
	_lines         = lines
	_next_queue    = next_q.duplicate()
	_hold_name     = h_name
	_hold_shape    = h_shape
	_hold_color    = h_color
	_hold_size     = h_size
	_can_hold      = can_hold
	_game_over     = is_go
	_paused        = is_paused
	_show_settings = show_set
	_show_stats    = show_st
	_stats_data    = stats_d
	_hint          = hint_text
	_settings      = set_d
	_finesse_faults = finesse
	_time_elapsed   = elapsed_time
	queue_redraw()

func show_achievement(name: String, desc: String, icon: String):
	_ach_queue.append({"name": name, "desc": desc, "icon": icon})

func trigger_screen_flash():
	_flash_timer = 1.0
	queue_redraw()

# Dùng bởi main.gd để biết HUD đang chờ phím gán lại
func is_capturing_key() -> bool:
	return _show_settings and _remap_action != ""

# Trả về tên phím dạng đọc được
func _key_name(keycode: int) -> String:
	if keycode <= 0: return "?"
	return OS.get_keycode_string(keycode as Key)

# ╔══════════════════════════════════════════════════╗
# ║             PROCESS                             ║
# ╚══════════════════════════════════════════════════╝
func _process(delta):
	_time_elapsed += delta
	var needs_redraw = false
	if _current_ach:
		_ach_timer -= delta
		if _ach_timer <= 0: _current_ach = null
		needs_redraw = true
	elif _ach_queue.size() > 0:
		_current_ach = _ach_queue.pop_front()
		_ach_timer = 3.5
		needs_redraw = true
	if _flash_timer > 0:   _flash_timer -= delta * 5.0; needs_redraw = true
	if combo_timer > 0:    combo_timer -= delta;        needs_redraw = true
	if level_up_timer > 0: level_up_timer -= delta;     needs_redraw = true
	if t_spin_timer > 0:   t_spin_timer -= delta;       needs_redraw = true
	if _action_label_timer > 0: _action_label_timer -= delta; needs_redraw = true
	if perfect_clear_timer > 0: perfect_clear_timer -= delta; needs_redraw = true
	if needs_redraw: queue_redraw()

# ╔══════════════════════════════════════════════════╗
# ║             INPUT                               ║
# ╚══════════════════════════════════════════════════╝
func _input(event):
	sidebar_x = size.x - SIDEBAR_W - 15.0
	content_x = sidebar_x + 14.0

	# ── Bắt phím gán lại điều khiển ──────────────────────
	if _show_settings and _remap_action != "" and event is InputEventKey and event.pressed and not event.is_echo():
		var kc := (event as InputEventKey).keycode
		if kc == KEY_ESCAPE:
			_remap_action = ""
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
		if kc > 0 and kc != KEY_UNKNOWN:
			var mn = get_parent().get_parent()
			var bindings = _settings.get("bindings", {}).duplicate(true)
			bindings[_remap_action] = kc
			mn.update_setting("bindings", bindings)
			_remap_action = ""
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

	# ── Chuột ─────────────────────────────────────────────
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mn = get_parent().get_parent()
		if event.pressed:
			var p = get_local_mouse_position()
			# Chuyển tab settings
			if _show_settings:
				if btn_rect_tab_game.has_point(p):
					_settings_tab = 0; _remap_action = ""; queue_redraw(); return
				elif btn_rect_tab_controls.has_point(p):
					_settings_tab = 1; _remap_action = ""; queue_redraw(); return

			# Game tab controls
			if _show_settings and _settings_tab == 0:
				if   btn_rect_music_vol.has_point(p):    active_slider = "music_vol"
				elif btn_rect_sfx_vol.has_point(p):      active_slider = "sfx_vol"
				elif btn_rect_level_slider.has_point(p): active_slider = "level_slider"
				elif btn_rect_fall_speed_slider.has_point(p): active_slider = "fall_speed_slider"
				elif btn_rect_das_slider.has_point(p):   active_slider = "das_slider"
				elif btn_rect_arr_slider.has_point(p):   active_slider = "arr_delay"
				elif btn_rect_dcd_slider.has_point(p):   active_slider = "dcd_slider"
				elif btn_rect_music_toggle.has_point(p):
					mn.update_setting("music_on", not _settings.get("music_on", true))
				elif btn_rect_ghost_toggle.has_point(p):
					mn.update_setting("show_ghost", not _settings.get("show_ghost", true))
				elif btn_rect_neon_toggle.has_point(p):
					mn.update_setting("neon_mode", not _settings.get("neon_mode", true))
				elif btn_rect_theme_default.has_point(p): mn.update_setting("theme", "default")
				elif btn_rect_theme_lava.has_point(p):    mn.update_setting("theme", "lava")
				elif btn_rect_theme_ice.has_point(p):     mn.update_setting("theme", "ice")
				else:
					for i in range(btn_rects_soft_drop.size()):
						if btn_rects_soft_drop[i].has_point(p):
							var sd_opts = ["cham", "trung", "nhanh", "sieu_toc", "tuc_thi"]
							mn.update_setting("soft_drop_speed", sd_opts[i])
					for i in range(btn_rects_grid_style.size()):
						if btn_rects_grid_style[i].has_point(p):
							var grid_opts = ["none", "standard", "limited", "vertical", "full"]
							mn.update_setting("grid_style", grid_opts[i])

			# Controls tab — nút gán lại phím
			elif _show_settings and _settings_tab == 1:
				for action_name in _remap_buttons:
					if _remap_buttons[action_name].has_point(p):
						_remap_action = action_name
						queue_redraw()
						return

			# Speed sidebar (luôn hiển thị)
			if btn_rect_speed_sidebar.has_point(p):
				active_slider = "speed_sidebar"

			if active_slider != "":
				_update_slider_value(active_slider, p)
		else:
			active_slider = ""

	elif event is InputEventMouseMotion and active_slider != "":
		_update_slider_value(active_slider, get_local_mouse_position())

func _update_slider_value(slider_name: String, pos: Vector2) -> void:
	var mn = get_parent().get_parent()
	match slider_name:
		"music_vol":
			var pct = clampf((pos.x - btn_rect_music_vol.position.x) / btn_rect_music_vol.size.x, 0.0, 1.0)
			mn.update_setting("music_vol", pct)
		"sfx_vol":
			var pct = clampf((pos.x - btn_rect_sfx_vol.position.x) / btn_rect_sfx_vol.size.x, 0.0, 1.0)
			mn.update_setting("sfx_vol", pct)
		"level_slider":
			var pct = clampf((pos.x - btn_rect_level_slider.position.x) / btn_rect_level_slider.size.x, 0.0, 1.0)
			mn.update_setting("start_level", int(round(1.0 + pct * 14.0)))
		"fall_speed_slider":
			var pct = clampf((pos.x - btn_rect_fall_speed_slider.position.x) / btn_rect_fall_speed_slider.size.x, 0.0, 1.0)
			var scale_val = round((0.1 + pct * 2.9) * 10.0) / 10.0
			mn.update_setting("fall_speed_scale", scale_val)
		"das_slider":
			var pct = clampf((pos.x - btn_rect_das_slider.position.x) / btn_rect_das_slider.size.x, 0.0, 1.0)
			mn.update_setting("das_delay", 0.050 + pct * 0.200)
		"arr_delay":
			var pct = clampf((pos.x - btn_rect_arr_slider.position.x) / btn_rect_arr_slider.size.x, 0.0, 1.0)
			var arr = pct * 0.060
			if arr < 0.002: arr = 0.0
			mn.update_setting("arr_delay", arr)
		"dcd_slider":
			var pct = clampf((pos.x - btn_rect_dcd_slider.position.x) / btn_rect_dcd_slider.size.x, 0.0, 1.0)
			var dcd = pct * 0.1
			mn.update_setting("dcd_delay", dcd)
		"speed_sidebar":
			var pct = clampf((pos.x - btn_rect_speed_sidebar.position.x) / btn_rect_speed_sidebar.size.x, 0.0, 1.0)
			mn.update_setting("start_level", int(round(1.0 + pct * 14.0)))

# ╔══════════════════════════════════════════════════╗
# ║             VẼ HUD CHÍNH                       ║
# ╚══════════════════════════════════════════════════╝
func _draw() -> void:
	sidebar_x = size.x - SIDEBAR_W - 15.0
	content_x = sidebar_x + 14.0
	var font  := get_theme_font("font")

	_draw_topbar(font)

	# Panel sidebar phải
	_draw_panel(Rect2(sidebar_x, 46.0, SIDEBAR_W, size.y - 56.0), C_BG, C_BORDER)

	# Màu accent theo theme
	var accent_col: Color
	match _settings.get("theme", "default"):
		"lava": accent_col = Color(0.80, 0.25, 0.00)
		"ice":  accent_col = Color(0.28, 0.60, 0.82)
		_:      accent_col = C_ACCENT

	# GACH TIEP THEO (Phóng to khung gạch tiếp theo ở bên phải)
	_ts(font, "GACH TIEP THEO", content_x + 10.0, 60.0, 12, C_MUTED)
	
	if _next_queue.size() >= 5:
		var panel_w := 180.0
		var panel_h := 570.0
		var panel_x := sidebar_x + (SIDEBAR_W - panel_w) * 0.5
		var panel_y := 80.0
		_draw_panel(Rect2(panel_x, panel_y, panel_w, panel_h), C_BG_DARK, C_BORDER)
		
		# Khung hiển thị gạch kế tiếp đầu tiên
		var box_next1 := Rect2(panel_x + 10.0, panel_y + 10.0, panel_w - 20.0, 130.0)
		draw_rect(box_next1, Color(0.04, 0.04, 0.08, 0.6), true)
		draw_rect(box_next1, C_BORDER_DIM, false, 0.8)
		var p1_shape = SHAPES.get(_next_queue[0], [])
		_draw_piece_preview_scaled(box_next1, p1_shape, _get_piece_color(_next_queue[0]), p1_shape.size(), 1.2)
		
		# Đường phân cách
		var line_y : float = panel_y + 150.0
		draw_line(Vector2(panel_x + 15.0, line_y), Vector2(panel_x + panel_w - 15.0, line_y), C_BORDER_DIM, 1.0)
		
		# 4 gạch tiếp theo xếp dọc gọn gàng
		var start_y : float = line_y + 15.0
		var item_h := 85.0
		var gap := 10.0
		for i in range(1, 5):
			var pn = _next_queue[i]
			var ps = SHAPES.get(pn, [])
			var box_i = Rect2(panel_x + 15.0, start_y + (i - 1) * (item_h + gap), panel_w - 30.0, item_h)
			draw_rect(box_i, Color(0.04, 0.04, 0.08, 0.4), true)
			draw_rect(box_i, C_BORDER_DIM * Color(1,1,1,0.5), false, 0.8)
			_draw_piece_preview_scaled(box_i, ps, _get_piece_color(pn), ps.size(), 0.85)

	# ── Hold panel bên TRÁI & Stats bên TRÁI ─────────────
	_draw_left_hold_panel(font, accent_col)
	_draw_left_stats(font, accent_col)

	# Vẽ Combo bên trái trong khoảng trống giữa Hold và Stats
	if combo_timer > 0 and _combo_count > 0:
		var alpha = clampf(combo_timer / 0.4, 0.0, 1.0)
		var t_sp  = clampf((1.8 - combo_timer) / 0.2, 0.0, 1.0)
		var fsz_title = 10
		var fsz_val   = int(24.0 * (1.0 + (1.0 - t_sp) * 0.2))
		var cx_left   := 10.0
		var cy_left   := 285.0
		var combo_box := Rect2(cx_left, cy_left - 10.0, HOLD_PANEL_W, 60.0)
		draw_rect(combo_box, Color(0.00, 0.40, 0.50, 0.12 * alpha), true)
		draw_rect(combo_box, Color(0.00, 0.72, 1.00, 0.40 * alpha), false, 1.0)
		draw_string(font, Vector2(cx_left + 10.0, cy_left + 12.0), "COMBO CHUOI", HORIZONTAL_ALIGNMENT_LEFT, -1, fsz_title, Color(0.0, 0.8, 1.0, alpha))
		draw_string(font, Vector2(cx_left + 10.0, cy_left + 42.0), "x" + str(_combo_count), HORIZONTAL_ALIGNMENT_LEFT, -1, fsz_val, Color(0.0, 1.0, 1.0, alpha))

	# ── Overlays ─────────────────────────────────────────
	if _show_stats:
		_draw_stats_panel(font)
	elif _show_settings:
		_draw_settings_panel(font)
	elif _paused:
		_draw_overlay_multiline(font, "TAM DUNG", "Nhan P de tiep tuc", C_ACCENT)
	elif _game_over:
		_draw_overlay_multiline(font, "THUA CUOC", _hint + "\n(Nhan R de choi lai)", C_DANGER)

	if _current_ach:
		_draw_achievement_popup(font)

	# ── Pop-up effects ────────────────────────────────────
	_draw_popups(font, accent_col)

	# Screen Flash
	if _flash_timer > 0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 1.0, 1.0, _flash_timer * 0.3), true)

# ── Hold panel trái ────────────────────────────────────────────────────
func _draw_left_hold_panel(font: Font, accent_col: Color) -> void:
	var hx := 10.0
	var hy := 58.0
	var hw := HOLD_PANEL_W
	var hh := HOLD_PANEL_H
	_draw_panel(Rect2(hx, hy, hw, hh + 22.0), C_BG, C_BORDER)
	_ts(font, "GIU GACH", hx + 5.0, hy + 8.0, 10, C_MUTED)
	var box := Rect2(hx + 4.0, hy + 22.0, hw - 8.0, hh - 14.0)
	_draw_panel(box, C_BG_DARK, C_BORDER_DIM)
	if _hold_name != "":
		var hc := _hold_color if _can_hold else Color(0.36, 0.36, 0.40)
		_draw_piece_preview(box, _hold_shape, hc, _hold_size)
	_ts(font, "(C/Shift)", hx + 4.0, hy + hh + 10.0, 10, accent_col if _can_hold else C_MUTED)

func _draw_left_stats(font: Font, accent_col: Color) -> void:
	var lx := 10.0
	var ly := 430.0
	var lw := HOLD_PANEL_W
	
	draw_line(Vector2(lx, ly - 8.0), Vector2(lx + lw, ly - 8.0), C_BORDER_DIM, 1.0)
	
	_ts(font, "FINESSE", lx, ly, 10, C_MUTED)
	_ts(font, str(_finesse_faults), lx, ly + 14.0, 16, C_TEXT)
	ly += 38.0
	
	_ts(font, "DIEM SO", lx, ly, 10, C_MUTED)
	_ts(font, str(_score), lx, ly + 12.0, 24, C_TEXT)
	ly += 46.0
	
	_ts(font, "CAP DO", lx, ly, 10, C_MUTED)
	_ts(font, str(_level), lx, ly + 14.0, 16, C_TEXT)
	ly += 38.0
	
	_ts(font, "DA XOA", lx, ly, 10, C_MUTED)
	_ts(font, str(_lines), lx, ly + 14.0, 16, C_TEXT)
	ly += 38.0
	
	_ts(font, "THOI GIAN", lx, ly, 10, C_MUTED)
	_ts(font, _fmt_time(_time_elapsed), lx, ly + 14.0, 13, C_TEXT)

# ── Pop-up hiệu ứng ───────────────────────────────────────────────────
func _draw_popups(font: Font, accent_col: Color) -> void:
	var play_cx = sidebar_x * 0.5

	if level_up_timer > 0:
		var alpha = clampf(level_up_timer / 0.5, 0.0, 1.0)
		if level_up_timer > 2.0: alpha = clampf((2.5 - level_up_timer) / 0.5, 0.0, 1.0)
		var t_sp = clampf((2.5 - level_up_timer) / 0.3, 0.0, 1.0)
		var fsz  = int(36.0 * (1.0 + (1.0 - t_sp) * 0.5))
		var text = "LEVEL UP!"
		var tw   = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x
		var dp   = Vector2(play_cx - tw * 0.5, 220.0)
		draw_string(font, dp + Vector2(2, 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, Color(0.4, 0.4, 0.0, alpha * 0.5))
		draw_string(font, dp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, Color(1.0, 0.9, 0.0, alpha))

	# (Combo is now drawn on the left sidebar)

	if _action_label_timer > 0 and _last_action_label != "":
		var alpha = clampf(_action_label_timer / 0.4, 0.0, 1.0)
		var t_sp  = clampf((1.8 - _action_label_timer) / 0.2, 0.0, 1.0)
		var fsz   = int(26.0 * (1.0 + (1.0 - t_sp) * 0.4))
		var tw    = font.get_string_size(_last_action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x
		var dp    = Vector2(play_cx - tw * 0.5, 370.0)
		draw_string(font, dp + Vector2(2, 2), _last_action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, Color(0.0, 0.0, 0.0, alpha * 0.5))
		var col = Color(0.9, 0.1, 1.0, alpha)
		if _last_action_label.contains("B2B"):
			col = Color(1.0, 0.8, 0.0, alpha)
		elif _last_action_label.contains("Tetris"):
			col = Color(0.0, 0.85, 1.0, alpha)
		elif _last_action_label.contains("Single") or _last_action_label.contains("Double") or _last_action_label.contains("Triple"):
			col = Color(0.96, 0.96, 0.98, alpha)
		draw_string(font, dp, _last_action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, col)

	if perfect_clear_timer > 0:
		var alpha = clampf(perfect_clear_timer / 0.5, 0.0, 1.0)
		if perfect_clear_timer > 2.5: alpha = clampf((3.0 - perfect_clear_timer) / 0.5, 0.0, 1.0)
		var t_sp  = clampf((3.0 - perfect_clear_timer) / 0.3, 0.0, 1.0)
		var fsz   = int(36.0 * (1.0 + (1.0 - t_sp) * 0.6))
		var text  = "PERFECT CLEAR!"
		var tw    = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x
		var dp    = Vector2(play_cx - tw * 0.5, 260.0)
		var gc    = Color.from_hsv(fmod(_time_elapsed * 1.2, 1.0), 0.9, 1.0, alpha * 0.4)
		for dx in [-2, 0, 2]:
			for dy in [-2, 0, 2]:
				if dx != 0 or dy != 0:
					draw_string(font, dp + Vector2(dx, dy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, gc)
		draw_string(font, dp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, Color(1.0, 1.0, 1.0, alpha))

# ╔══════════════════════════════════════════════════╗
# ║             SETTINGS PANEL (2 TAB)             ║
# ╚══════════════════════════════════════════════════╝
func _draw_settings_panel(font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.52), true)
	var bw  := 440.0
	var bh  := 550.0
	var bx  := (size.x - bw) * 0.5
	var by  := (size.y - bh) * 0.5
	var cur_theme = _settings.get("theme", "default")
	var acc: Color
	match cur_theme:
		"lava": acc = Color(0.80, 0.25, 0.00)
		"ice":  acc = Color(0.28, 0.60, 0.82)
		_:      acc = C_ACCENT
	_draw_panel(Rect2(bx, by, bw, bh), C_BG_DARK, acc)

	# Tiêu đề
	var title = "CAI DAT"
	var tw = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	_ts(font, title, bx + (bw - tw) * 0.5, by + 18.0, 20, C_TEXT)

	# Tab headers
	var tab_w = (bw - 30.0) * 0.5
	btn_rect_tab_game     = Rect2(bx + 10.0,          by + 46.0, tab_w, 26.0)
	btn_rect_tab_controls = Rect2(bx + 20.0 + tab_w,  by + 46.0, tab_w, 26.0)
	_draw_panel(btn_rect_tab_game,
		acc if _settings_tab == 0 else Color(0.08, 0.08, 0.14), C_BORDER_DIM)
	_draw_panel(btn_rect_tab_controls,
		acc if _settings_tab == 1 else Color(0.08, 0.08, 0.14), C_BORDER_DIM)
	_ts(font, "TRO CHOI",   bx + 10.0 + 18.0,       by + 52.0, 12, C_TEXT)
	_ts(font, "DIEU KHIEN", bx + 20.0 + tab_w + 18.0, by + 52.0, 12, C_TEXT)

	# Nội dung tab
	if _settings_tab == 0:
		_draw_game_tab(font, bx, by + 82.0, bw, acc)
	else:
		_draw_controls_tab(font, bx, by + 82.0, bw, acc)

	_ts(font, "ESC = Dong va luu", bx + (bw - font.get_string_size("ESC = Dong va luu", HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x) * 0.5,
		by + bh - 18.0, 11, C_MUTED)

# ── Tab Trò Chơi ──────────────────────────────────────────────────────
func _draw_game_tab(font: Font, bx: float, by: float, bw: float, acc: Color) -> void:
	var cx = bx + 20.0
	var sw = bw - 40.0
	var y  = by
	var cur_theme = _settings.get("theme", "default")

	# Âm lượng nhạc
	_ts(font, "Am luong Nhac:", cx, y, 12, C_MUTED)
	btn_rect_music_vol = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_music_vol, Color(0.08, 0.08, 0.14), true)
	draw_rect(Rect2(cx, y + 15.0, sw * _settings.get("music_vol", 0.8), 12.0), C_ACCENT, true)
	draw_rect(btn_rect_music_vol, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# Âm lượng SFX
	_ts(font, "Am luong Hieu ung:", cx, y, 12, C_MUTED)
	btn_rect_sfx_vol = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_sfx_vol, Color(0.08, 0.08, 0.14), true)
	draw_rect(Rect2(cx, y + 15.0, sw * _settings.get("sfx_vol", 0.8), 12.0), C_SUCCESS, true)
	draw_rect(btn_rect_sfx_vol, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# Nhạc nền, Bóng mờ Ghost & Neon (Song song nhau để tiết kiệm diện tích)
	var toggle_w = (sw - 28.0) / 3.0
	
	# Music Toggle
	btn_rect_music_toggle = Rect2(cx, y, toggle_w, 22.0)
	var music_on = _settings.get("music_on", true)
	_draw_panel(btn_rect_music_toggle, C_ACCENT if music_on else Color(0.14, 0.14, 0.20), C_BORDER)
	var music_txt = "Nhac: " + ("BAT" if music_on else "TAT")
	var music_txt_w = font.get_string_size(music_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	_ts(font, music_txt, cx + (toggle_w - music_txt_w) * 0.5, y + 5.0, 10, Color.WHITE)

	# Ghost Toggle
	btn_rect_ghost_toggle = Rect2(cx + toggle_w + 14.0, y, toggle_w, 22.0)
	var ghost_on = _settings.get("show_ghost", true)
	_draw_panel(btn_rect_ghost_toggle, Color(0.12, 0.35, 0.38) if ghost_on else Color(0.14, 0.14, 0.20), C_BORDER)
	var ghost_txt = "Ghost: " + ("BAT" if ghost_on else "TAT")
	var ghost_txt_w = font.get_string_size(ghost_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	_ts(font, ghost_txt, cx + toggle_w + 14.0 + (toggle_w - ghost_txt_w) * 0.5, y + 5.0, 10, Color.WHITE)

	# Neon Toggle
	btn_rect_neon_toggle = Rect2(cx + (toggle_w + 14.0) * 2.0, y, toggle_w, 22.0)
	var neon_on = _settings.get("neon_mode", true)
	_draw_panel(btn_rect_neon_toggle, Color(0.65, 0.15, 0.65) if neon_on else Color(0.14, 0.14, 0.20), C_BORDER)
	var neon_txt = "Neon: " + ("BAT" if neon_on else "TAT")
	var neon_txt_w = font.get_string_size(neon_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	_ts(font, neon_txt, cx + (toggle_w + 14.0) * 2.0 + (toggle_w - neon_txt_w) * 0.5, y + 5.0, 10, Color.WHITE)

	y += 28.0

	# Cấp độ bắt đầu
	var start_lv = _settings.get("start_level", 1)
	_ts(font, "Cap do bat dau: " + str(start_lv), cx, y, 12, C_MUTED)
	btn_rect_level_slider = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_level_slider, Color(0.08, 0.08, 0.14), true)
	draw_rect(Rect2(cx, y + 15.0, sw * float(start_lv - 1) / 14.0, 12.0), Color(0.88, 0.62, 0.00), true)
	draw_rect(btn_rect_level_slider, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# Hệ số tốc độ rơi (Fall Speed Scale)
	var fall_speed = _settings.get("fall_speed_scale", 1.0)
	_ts(font, "He so toc do roi: " + str(fall_speed) + "x", cx, y, 12, C_MUTED)
	btn_rect_fall_speed_slider = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_fall_speed_slider, Color(0.08, 0.08, 0.14), true)
	var speed_mult_pct = clampf((fall_speed - 0.1) / 2.9, 0.0, 1.0)
	draw_rect(Rect2(cx, y + 15.0, sw * speed_mult_pct, 12.0), Color(0.92, 0.22, 0.22), true)
	draw_rect(btn_rect_fall_speed_slider, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# DAS (Độ trễ DAS)
	var das_ms = int(_settings.get("das_delay", 0.085) * 1000.0)
	_ts(font, "DAS (Do tre bat dau truot): " + str(das_ms) + " ms", cx, y, 12, C_MUTED)
	btn_rect_das_slider = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_das_slider, Color(0.08, 0.08, 0.14), true)
	var das_pct = clampf((_settings.get("das_delay", 0.085) - 0.050) / 0.200, 0.0, 1.0)
	draw_rect(Rect2(cx, y + 15.0, sw * das_pct, 12.0), Color(0.65, 0.18, 0.88), true)
	draw_rect(btn_rect_das_slider, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# ARR (Tốc độ lướt)
	var arr_ms = int(_settings.get("arr_delay", 0.010) * 1000.0)
	_ts(font, "ARR (Do tre giua cac o): " + (str(arr_ms) + " ms" if arr_ms > 0 else "0 ms (Tuc thoi)"), cx, y, 12, C_MUTED)
	btn_rect_arr_slider = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_arr_slider, Color(0.08, 0.08, 0.14), true)
	var arr_pct = clampf(_settings.get("arr_delay", 0.010) / 0.060, 0.0, 1.0)
	draw_rect(Rect2(cx, y + 15.0, sw * arr_pct, 12.0), Color(0.00, 0.65, 0.88), true)
	draw_rect(btn_rect_arr_slider, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# DCD (DAS Cut Delay)
	var dcd_ms = int(_settings.get("dcd_delay", 0.0) * 1000.0)
	_ts(font, "DCD (Do tre sau xoay/spawn): " + str(dcd_ms) + " ms", cx, y, 12, C_MUTED)
	btn_rect_dcd_slider = Rect2(cx, y + 15.0, sw, 12.0)
	draw_rect(btn_rect_dcd_slider, Color(0.08, 0.08, 0.14), true)
	var dcd_pct = clampf(_settings.get("dcd_delay", 0.0) / 0.1, 0.0, 1.0)
	draw_rect(Rect2(cx, y + 15.0, sw * dcd_pct, 12.0), Color(0.18, 0.88, 0.65), true)
	draw_rect(btn_rect_dcd_slider, C_BORDER_DIM, false, 1.0)
	y += 33.0

	# SDF (Soft Drop Factor - Tốc độ thả nhẹ)
	_ts(font, "SDF (Soft Drop Factor):", cx, y, 12, C_MUTED)
	var sd_opts = ["cham", "trung", "nhanh", "sieu_toc", "tuc_thi"]
	var sd_labels = ["1x (Cham)", "10x", "20x", "40x", "Vo cuc"]
	var sd_w = (sw - 16.0) / 5.0
	btn_rects_soft_drop.clear()
	var cur_sd = _settings.get("soft_drop_speed", "trung")
	for i in range(5):
		var rx = cx + i * (sd_w + 4.0)
		var ry = y + 15.0
		var r = Rect2(rx, ry, sd_w, 22.0)
		btn_rects_soft_drop.append(r)
		var is_active = (cur_sd == sd_opts[i])
		var opt_bg = acc if is_active else Color(0.08, 0.08, 0.14)
		_draw_panel(r, opt_bg, C_BORDER if is_active else C_BORDER_DIM)
		var txt = sd_labels[i]
		var txt_w = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		_ts(font, txt, rx + (sd_w - txt_w) * 0.5, ry + 5.0, 9, Color.WHITE if is_active else C_MUTED)
	y += 42.0

	# Khung (Grid Style)
	_ts(font, "Khung ban choi (Grid):", cx, y, 12, C_MUTED)
	var grid_opts = ["none", "standard", "limited", "vertical", "full"]
	var grid_labels = ["Khong", "Chuan", "Gioi han", "Doc", "Day du"]
	var grid_w = (sw - 16.0) / 5.0
	btn_rects_grid_style.clear()
	var cur_grid = _settings.get("grid_style", "standard")
	for i in range(5):
		var rx = cx + i * (grid_w + 4.0)
		var ry = y + 15.0
		var r = Rect2(rx, ry, grid_w, 22.0)
		btn_rects_grid_style.append(r)
		var is_active = (cur_grid == grid_opts[i])
		var opt_bg = acc if is_active else Color(0.08, 0.08, 0.14)
		_draw_panel(r, opt_bg, C_BORDER if is_active else C_BORDER_DIM)
		var txt = grid_labels[i]
		var txt_w = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		_ts(font, txt, rx + (grid_w - txt_w) * 0.5, ry + 5.0, 10, Color.WHITE if is_active else C_MUTED)
	y += 42.0

	# Theme (Chủ đề)
	_ts(font, "CHU DE:", cx, y, 12, C_MUTED)
	var tb_w = (sw - 10.0) / 3.0
	btn_rect_theme_default = Rect2(cx,               y + 15.0, tb_w, 22.0)
	btn_rect_theme_lava    = Rect2(cx + 5.0 + tb_w,  y + 15.0, tb_w, 22.0)
	btn_rect_theme_ice     = Rect2(cx + 10.0 + tb_w * 2, y + 15.0, tb_w, 22.0)
	_draw_panel(btn_rect_theme_default, acc if cur_theme == "default" else Color(0.08, 0.08, 0.14), C_BORDER)
	_ts(font, "Mac dinh", cx + (tb_w - font.get_string_size("Mac dinh", HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x) * 0.5, y + 20.0, 10, Color.WHITE)
	_draw_panel(btn_rect_theme_lava, Color(0.62, 0.18, 0.00) if cur_theme == "lava" else Color(0.08, 0.08, 0.14), C_BORDER)
	_ts(font, "Dung nham", cx + tb_w + 5.0 + (tb_w - font.get_string_size("Dung nham", HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x) * 0.5, y + 20.0, 10, Color.WHITE)
	_draw_panel(btn_rect_theme_ice, Color(0.18, 0.42, 0.62) if cur_theme == "ice" else Color(0.08, 0.08, 0.14), C_BORDER)
	_ts(font, "Bang gia", cx + tb_w * 2.0 + 10.0 + (tb_w - font.get_string_size("Bang gia", HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x) * 0.5, y + 20.0, 10, Color.WHITE)

# ── Tab Điều Khiển ────────────────────────────────────────────────────
func _draw_controls_tab(font: Font, bx: float, by: float, bw: float, acc: Color) -> void:
	var cx = bx + 18.0
	var sw = bw - 36.0
	var y  = by
	_remap_buttons.clear()

	var actions = [
		["move_left",  "Di chuyen trai",  KEY_LEFT],
		["move_right", "Di chuyen phai",  KEY_RIGHT],
		["soft_drop",  "Tha nhe (Soft)",  KEY_DOWN],
		["hard_drop",  "Tha manh (Hard)", KEY_SPACE],
		["rotate_cw",  "Xoay phai CW",    KEY_UP],
		["rotate_ccw", "Xoay trai CCW",   KEY_X],
		["rotate_180", "Xoay 180 do",     KEY_A],
		["hold",       "Giu gach (Hold)", KEY_C],
	]
	var bindings = _settings.get("bindings", {})

	if _remap_action != "":
		_ts(font, ">> Nhan phim moi... (ESC = huy)", cx, y, 12, Color(1.0, 0.8, 0.0))
	else:
		_ts(font, "Click [DOI PHIM] de thay doi phim", cx, y, 11, C_MUTED)
	y += 24.0

	for act_info in actions:
		var aname  : String = act_info[0]
		var alabel : String = act_info[1]
		var adef   : int    = act_info[2]
		var bound  : int    = bindings.get(aname, adef)
		var is_this = (_remap_action == aname)

		# Nền hàng
		var row_bg = Color(0.18, 0.18, 0.32) if is_this else Color(0.06, 0.06, 0.11)
		draw_rect(Rect2(cx, y, sw, 23.0), row_bg, true)
		draw_rect(Rect2(cx, y, sw, 23.0), C_BORDER_DIM, false, 0.8)

		# Nhãn action
		_ts(font, alabel, cx + 6.0, y + 5.0, 12, C_TEXT)

		# Badge phím
		var key_text = ">> ..." if is_this else ("[" + _key_name(bound) + "]")
		var key_col  = Color(1.0, 0.8, 0.0) if is_this else Color(0.35, 0.85, 1.0)
		_ts(font, key_text, cx + sw - 120.0, y + 5.0, 12, key_col)

		# Nút "Đổi phím"
		var btn := Rect2(cx + sw - 55.0, y + 3.5, 50.0, 16.0)
		_remap_buttons[aname] = btn
		_draw_panel(btn,
			Color(0.48, 0.25, 0.00) if is_this else Color(0.22, 0.10, 0.32),
			C_BORDER_DIM)
		_ts(font, "DOI PHIM", cx + sw - 53.0, y + 5.0, 9, Color.WHITE)

		y += 27.0

# ╔══════════════════════════════════════════════════╗
# ║             CÁC HÀM VẼ HELPER                  ║
# ╚══════════════════════════════════════════════════╝
func _draw_topbar(font: Font) -> void:
	draw_rect(Rect2(0, 0, size.x, 44.0), Color(0.03, 0.03, 0.07, 0.95), true)

func _draw_panel(rect: Rect2, bg: Color, border: Color, radius: float = 6.0) -> void:
	draw_rect(rect, bg, true)
	draw_rect(rect, border, false, 1.2)

func _ts(font: Font, text: String, x: float, y: float, size_px: int, color: Color) -> void:
	draw_string(font, Vector2(x, y + font.get_ascent(size_px)), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func _draw_piece_preview(container: Rect2, shape: Array, color: Color, n: int) -> void:
	if shape.is_empty() or n == 0: return
	var cell_size = min(container.size.x, container.size.y) / 4.0 * 0.85
	var ox = container.position.x + (container.size.x - cell_size * n) * 0.5
	var oy = container.position.y + (container.size.y - cell_size * n) * 0.5
	var cur_theme = _settings.get("theme", "default")
	for r in range(n):
		for c in range(n):
			if r < shape.size() and c < shape[r].size() and shape[r][c] != 0:
				var rx = ox + c * cell_size + 1.0
				var ry = oy + r * cell_size + 1.0
				var rs = cell_size - 2.0
				var neon_on = _settings.get("neon_mode", true)
				if neon_on:
					draw_rect(Rect2(rx - 1.5, ry - 1.5, rs + 3.0, rs + 3.0), Color(color.r, color.g, color.b, 0.25), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.2), true)
					draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, rs - 3.0), color, true)
					if cur_theme == "ice":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color.WHITE, true)
					elif cur_theme == "lava":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color(0.25, 0.04, 0.04), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.lightened(0.6), false, 1.2)
				else:
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.4), true)
					draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, rs - 3.0), color, true)
					if cur_theme == "ice":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color.WHITE, true)
					elif cur_theme == "lava":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color(0.25, 0.04, 0.04), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.1), false, 1.0)

func _draw_piece_preview_scaled(container: Rect2, shape: Array, color: Color, n: int, scale_f: float) -> void:
	if shape.is_empty() or n == 0: return
	var cell_size = min(container.size.x, container.size.y) / 4.0 * 0.85 * scale_f
	var ox = container.position.x + (container.size.x - cell_size * n) * 0.5
	var oy = container.position.y + (container.size.y - cell_size * n) * 0.5
	var cur_theme = _settings.get("theme", "default")
	for r in range(n):
		for c in range(n):
			if r < shape.size() and c < shape[r].size() and shape[r][c] != 0:
				var rx = ox + c * cell_size + 1.0
				var ry = oy + r * cell_size + 1.0
				var rs = cell_size - 2.0
				var neon_on = _settings.get("neon_mode", true)
				if neon_on:
					draw_rect(Rect2(rx - 1.5, ry - 1.5, rs + 3.0, rs + 3.0), Color(color.r, color.g, color.b, 0.25), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.2), true)
					draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, rs - 3.0), color, true)
					if cur_theme == "ice":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color.WHITE, true)
					elif cur_theme == "lava":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color(0.25, 0.04, 0.04), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.lightened(0.6), false, 1.2)
				else:
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.4), true)
					draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, rs - 3.0), color, true)
					if cur_theme == "ice":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color.WHITE, true)
					elif cur_theme == "lava":
						draw_rect(Rect2(rx + 1.5, ry + 1.5, rs - 3.0, (rs - 3.0) * 0.25), Color(0.25, 0.04, 0.04), true)
					draw_rect(Rect2(rx, ry, rs, rs), color.darkened(0.1), false, 1.0)

func _draw_overlay_multiline(font: Font, heading: String, sub: String, theme: Color) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.75), true)
	var bw  := 500.0
	var bh  := 180.0
	var bx  := (size.x - bw) * 0.5
	var by  := (size.y - bh) * 0.5
	_draw_panel(Rect2(bx, by, bw, bh), Color(0.06, 0.06, 0.12, 0.97), theme)
	var h_w := font.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	_ts(font, heading, bx + (bw - h_w) * 0.5, by + 30.0, 32, C_TEXT)
	var t_pos = Vector2(bx + 30.0, by + 100.0 + font.get_ascent(16))
	draw_multiline_string(font, t_pos, sub, HORIZONTAL_ALIGNMENT_CENTER, bw - 60.0, 16, -1, C_MUTED)

func _draw_stats_panel(font: Font) -> void:
	if not _stats_data: return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.5), true)
	var bw := 440.0
	var bh := 350.0
	var bx := (size.x - bw) * 0.5
	var by := (size.y - bh) * 0.5
	_draw_panel(Rect2(bx, by, bw, bh), C_BG_DARK, C_SUCCESS)
	_ts(font, "THONG KE BI (BUSINESS INTELLIGENCE)", bx + 30, by + 20, 15, C_SUCCESS)
	var y = by + 60
	var items = [
		["Tong so van choi:",       str(_stats_data.get("total_games", 0))],
		["Ky luc diem:",            str(_stats_data.get("best_score", 0))],
		["Tong so hang xoa:",       str(_stats_data.get("total_lines", 0))],
		["Chuoi Tetris dai nhat:",  str(_stats_data.get("max_streak", 0))],
		["Tong T-Spin:",            str(_stats_data.get("total_t_spins", 0))],
		["Tong Perfect Clear:",     str(_stats_data.get("total_perfect_clears", 0))],
		["Thoi gian choi:",         _fmt_time(_stats_data.get("total_time_played", 0.0))],
	]
	for item in items:
		_ts(font, item[0], bx + 30, y, 14, C_MUTED)
		_ts(font, item[1], bx + 290, y, 14, C_TEXT)
		y += 32
	_ts(font, "TAB = Dong", bx + 180, by + bh - 24, 12, C_MUTED)

func _draw_achievement_popup(font: Font) -> void:
	if not _current_ach: return
	var alpha = clampf(_ach_timer / 0.5, 0.0, 1.0)
	if _ach_timer > 3.0: alpha = clampf((3.5 - _ach_timer) / 0.5, 0.0, 1.0)
	var pw  := 320.0
	var ph  := 70.0
	var px  := size.x - pw - 20.0
	var py  := size.y - ph - 20.0
	draw_rect(Rect2(px, py, pw, ph), Color(0.04, 0.08, 0.04, 0.90 * alpha), true)
	draw_rect(Rect2(px, py, pw, ph), C_SUCCESS * Color(1, 1, 1, alpha), false, 1.5)
	_ts(font, _current_ach.get("icon", "★") + " " + _current_ach.get("name", ""), px + 10, py + 12, 15, Color(C_SUCCESS, alpha))
	_ts(font, _current_ach.get("desc", ""), px + 10, py + 40, 12, Color(C_MUTED, alpha))

func _fmt_time(seconds: float) -> String:
	var s  = int(seconds)
	var h  = s / 3600
	var m  = (s % 3600) / 60
	var ss = s % 60
	return "%02d:%02d:%02d" % [h, m, ss]
