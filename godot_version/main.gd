extends Node

# ╔══════════════════════════════════════════════════╗
# ║             HẰNG SỐ GAME                        ║
# ╚══════════════════════════════════════════════════╝
const GRID_WIDTH  = 10
const GRID_HEIGHT = 20

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
	"I": Color(0.00, 0.85, 1.00),
	"O": Color(1.00, 0.85, 0.00),
	"T": Color(0.72, 0.00, 1.00),
	"S": Color(0.00, 0.92, 0.35),
	"Z": Color(1.00, 0.22, 0.22),
	"J": Color(0.18, 0.35, 1.00),
	"L": Color(1.00, 0.50, 0.00)
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

# Theme: Bang Gia (Ice) — màu băng tuyết dịu mát dễ phân biệt hình dạng
const ICE_COLORS = {
	"I": Color(0.45, 0.90, 1.00), # Xanh băng sáng bừng
	"O": Color(1.00, 0.95, 0.65), # Vàng nhạt băng giá sáng
	"T": Color(0.75, 0.65, 1.00), # Tím hoa anh thảo băng sáng
	"S": Color(0.45, 0.95, 0.75), # Lục bạc frost tươi
	"Z": Color(1.00, 0.60, 0.70), # Hồng phấn băng tuyết rực rỡ
	"J": Color(0.30, 0.60, 1.00), # Lam sậm sông băng tươi sáng
	"L": Color(1.00, 0.75, 0.55)  # Cam đào tuyết phủ sáng
}

# ╔══════════════════════════════════════════════════╗
# ║   BẢNG SRS KICK (Standard Rotation System+)    ║
# ╚══════════════════════════════════════════════════╝
# Key = from_rotation * 4 + to_rotation
# Offset (dx, dy) trong toạ độ lưới (y+ đi xuống)
const SRS_KICKS_JLSTZ = {
	1:  [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1,-1), Vector2i( 0, 2), Vector2i(-1, 2)],  # 0→R
	4:  [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i( 1, 1), Vector2i( 0,-2), Vector2i( 1,-2)],  # R→0
	6:  [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i( 1, 1), Vector2i( 0,-2), Vector2i( 1,-2)],  # R→2
	9:  [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1,-1), Vector2i( 0, 2), Vector2i(-1, 2)],  # 2→R
	11: [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i( 1,-1), Vector2i( 0, 2), Vector2i( 1, 2)],  # 2→L
	14: [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i( 0,-2), Vector2i(-1,-2)],  # L→2
	12: [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i( 0,-2), Vector2i(-1,-2)],  # L→0
	3:  [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i( 1,-1), Vector2i( 0, 2), Vector2i( 1, 2)],  # 0→L
}
const SRS_KICKS_I = {
	1:  [Vector2i( 0, 0), Vector2i(-2, 0), Vector2i( 1, 0), Vector2i(-2, 1), Vector2i( 1,-2)],  # 0→R
	4:  [Vector2i( 0, 0), Vector2i( 2, 0), Vector2i(-1, 0), Vector2i( 2,-1), Vector2i(-1, 2)],  # R→0
	6:  [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i( 2, 0), Vector2i(-1,-2), Vector2i( 2, 1)],  # R→2
	9:  [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i(-2, 0), Vector2i( 1, 2), Vector2i(-2,-1)],  # 2→R
	11: [Vector2i( 0, 0), Vector2i( 2, 0), Vector2i(-1, 0), Vector2i( 2,-1), Vector2i(-1, 2)],  # 2→L
	14: [Vector2i( 0, 0), Vector2i(-2, 0), Vector2i( 1, 0), Vector2i(-2, 1), Vector2i( 1,-2)],  # L→2
	12: [Vector2i( 0, 0), Vector2i( 1, 0), Vector2i(-2, 0), Vector2i( 1, 2), Vector2i(-2,-1)],  # L→0
	3:  [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i( 2, 0), Vector2i(-1,-2), Vector2i( 2, 1)],  # 0→L
}
# Bảng kick cho xoay 180° (không có chuẩn SRS chính thức)
const SRS_KICKS_180 = [
	Vector2i( 0, 0), Vector2i( 0,-1), Vector2i( 1,-1),
	Vector2i(-1,-1), Vector2i( 1, 0), Vector2i(-1, 0)
]


const SHADER_CODE = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform float metallic = 0.3;
uniform float roughness = 0.22;
uniform float emission_energy = 0.6;
uniform vec4 emission : source_color;
uniform float radius = 0.15;
uniform vec3 box_extents = vec3(0.44, 0.44, 0.44);
uniform int theme = 0;

varying vec3 local_pos;

void vertex() {
	vec3 inner_extents = max(box_extents - vec3(radius), vec3(0.0));
	vec3 clamped_v = clamp(VERTEX, -inner_extents, inner_extents);
	vec3 normal = normalize(VERTEX - clamped_v);
	if (length(VERTEX - clamped_v) > 0.001) {
		VERTEX = clamped_v + normal * radius;
		NORMAL = normal;
	}
	local_pos = VERTEX;
}

void fragment() {
	vec3 base_color = albedo.rgb;
	float m = metallic;
	float r = roughness;
	vec3 emit = vec3(0.0);
	
	if (theme == 1) { // Lava: đá nham thạch vân đỏ sáng phát lửa
		float lava_pattern = sin(local_pos.x * 6.0 + TIME * 1.2) * cos(local_pos.y * 6.0 - TIME * 1.0) * sin(local_pos.z * 6.0 + TIME * 0.7);
		lava_pattern = abs(lava_pattern);
		float veins = smoothstep(0.65, 0.85, lava_pattern);
		
		// Đá nham thạch nền có màu tối tự nhiên của viên gạch để tránh ảm đạm khi tắt neon
		vec3 dark_rock = albedo.rgb * 0.32;
		base_color = mix(dark_rock, albedo.rgb * 1.4, veins);
		
		m = 0.2;
		r = mix(0.85, 0.3, veins);
		
		float pulse = 1.0 + 0.15 * sin(TIME * 3.0);
		// Giảm bớt hệ số chói lóa
		emit = (albedo.rgb * 0.15 + albedo.rgb * veins * 1.8) * pulse * emission_energy;
		
		float lava_stone_mask = smoothstep(0.18, 0.24, local_pos.y);
		base_color = mix(base_color, albedo.rgb * 0.22, lava_stone_mask * 0.95);
		emit = mix(emit, vec3(0.0, 0.0, 0.0), lava_stone_mask * 1.0);
	} 
	else if (theme == 2) { // Ice: lõi băng màu sáng, nứt tự nhiên
		float fresnel = pow(1.0 - dot(NORMAL, VIEW), 2.5);
		
		float cracks = sin(local_pos.x * 10.0 + local_pos.y * 12.0) * cos(local_pos.z * 9.0 - local_pos.y * 7.0);
		cracks = smoothstep(0.75, 0.95, abs(cracks));
		
		// Nền băng tươi sáng rực rỡ, không bị tối 30% như trước
		base_color = mix(albedo.rgb * 0.95, vec3(0.9, 0.95, 1.0), fresnel * 0.4);
		base_color = mix(base_color, vec3(0.95, 0.98, 1.0), cracks * 0.5);
		
		m = 0.9;
		r = mix(0.08, 0.22, fresnel);
		
		// Giảm bớt hệ số chói lóa
		emit = albedo.rgb * (fresnel * 0.4 + cracks * 0.5) * 1.4 * emission_energy;
		
		float snow_mask = smoothstep(0.18, 0.24, local_pos.y);
		base_color = mix(base_color, mix(vec3(1.0, 1.0, 1.0), albedo.rgb, 0.15), snow_mask * 0.95);
		emit = mix(emit, vec3(0.08, 0.08, 0.08) * emission_energy, snow_mask * 0.95);
	} 
	else { // Default
		float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.5);
		base_color = mix(albedo.rgb, vec3(1.0), fresnel * 0.2);
		m = metallic;
		r = roughness;
		// Giảm bớt hệ số chói lóa
		emit = (albedo.rgb * 0.45 + vec3(1.0) * fresnel * 0.35) * emission_energy;
	}
	
	ALBEDO = base_color;
	METALLIC = m;
	ROUGHNESS = r;
	EMISSION = emit;
	ALPHA = albedo.a;
}
"""


# ╔══════════════════════════════════════════════════╗
# ║             THAM CHIẾU NODE                     ║
# ╚══════════════════════════════════════════════════╝
@onready var locked_node  : Node3D            = $World3D/LockedBlocks
@onready var active_node  : Node3D            = $World3D/ActiveBlock
@onready var ghost_node   : Node3D            = $World3D/GhostBlock
@onready var camera_3d    : Camera3D          = $World3D/Camera3D
@onready var sun_light    : DirectionalLight3D = $World3D/SunLight
@onready var fill_light   : DirectionalLight3D = $World3D/FillLight

@onready var sfx_move     : AudioStreamPlayer = $AudioPlayers/SfxMove
@onready var sfx_rotate   : AudioStreamPlayer = $AudioPlayers/SfxRotate
@onready var sfx_clear    : AudioStreamPlayer = $AudioPlayers/SfxClear
@onready var sfx_gameover : AudioStreamPlayer = $AudioPlayers/SfxGameOver
@onready var bg_music     : AudioStreamPlayer = $AudioPlayers/BgMusic

@onready var hud_control                      = $HUD/HUDControl
@onready var stats_node                       = $Stats

# ╔══════════════════════════════════════════════════╗
# ║             TRẠNG THÁI GAME                     ║
# ╚══════════════════════════════════════════════════╝
var grid         : Array  = []
var score        : int    = 0
var level        : int    = 1
var lines_cleared: int    = 0
var game_over    : bool   = false
var paused       : bool   = false
var show_settings: bool   = false
var show_stats   : bool   = false
var bag          : Array  = []
var can_hold     : bool   = true
var fall_accum   : float  = 0.0

var current_name     : String = ""
var current_shape    : Array  = []
var current_color    : Color  = Color.WHITE
var current_size     : int    = 0
var current_x        : int    = 0
var current_y        : int    = 0
var current_rotation : int    = 0  # 0=spawn, 1=CW, 2=180, 3=CCW

var hold_name  : String = ""
var hold_shape : Array  = []
var hold_color : Color  = Color.WHITE
var hold_size  : int    = 0

var pieces_spawned_this_game = {}
var tetris_streak = 0
var settings = {
	"music_vol": 0.8,
	"sfx_vol": 0.8,
	"music_on": true,
	"start_level": 1,
	"das_delay": 0.085,
	"arr_delay": 0.010,
	"theme": "default",
	"show_ghost": true,
	"fall_speed_scale": 1.0,
	"soft_drop_speed": "trung",
	"grid_style": "standard",
	"dcd_delay": 0.0,
	"neon_mode": true,
	"bindings": {
		"move_left":  KEY_LEFT,
		"move_right": KEY_RIGHT,
		"soft_drop":  KEY_DOWN,
		"hard_drop":  KEY_SPACE,
		"rotate_cw":  KEY_UP,
		"rotate_ccw": KEY_X,
		"rotate_180": KEY_A,
		"hold":       KEY_C,
	}
}
var shader_mat_cache = {}
var shared_box_mesh : BoxMesh = null
var shared_shader : Shader = null
var board_container : Node3D = null
var grid_lines_node : Node3D = null

var b2b_active: bool = false
var last_kick_index: int = -1
var dcd_timer: float = 0.0
var current_lock_spin_type: String = "none"

# Finesse tracking variables
var finesse_faults: int = 0
var time_elapsed: float = 0.0
var cur_piece_left_inputs: int = 0
var cur_piece_right_inputs: int = 0
var cur_piece_rot_cw_inputs: int = 0
var cur_piece_rot_ccw_inputs: int = 0
var cur_piece_rot_180_inputs: int = 0
var last_action_label: String = ""
var clears_history: Array = []


# ╔══════════════════════════════════════════════════╗
# ║             GAME FEEL & VFX (TETR.IO STYLE)     ║
# ╚══════════════════════════════════════════════════╝
var camera_shake_intensity: float = 0.0
var camera_shake_dir: float = 0.0  # -1=left bias, 1=right bias, 0=random
var base_camera_pos: Vector3 = Vector3(8.22, -9.5, 23.0)
var is_clearing_lines: bool = false
var particle_materials = {}

# Board Spring Bounce
var board_offset_y: float = 0.0
var board_velocity_y: float = 0.0

# Theme system
var current_theme: String = "default"
var board_glow_mat: StandardMaterial3D = null
var show_game_over_overlay: bool = false
var prev_wall_hit_dir: int = 0

# Combo & T-Spin System
var combo_count: int = -1
var t_spin_triggered: bool = false
var last_action_was_rotate: bool = false
var active_visual_pos: Vector3 = Vector3.ZERO

# DAS & ARR - Quản lý thủ công, bỏ hoàn toàn OS key repeat
var key_left_held:  bool  = false
var key_right_held: bool  = false
var key_down_held:  bool  = false
var das_direction:  int   = 0  # -1=left, 1=right, 0=none
var das_timer:      float = 0.0
var arr_timer:      float = 0.0
var active_target_pos: Vector3 = Vector3.ZERO

var next_queue: Array = []
var perfect_clear_triggered: bool = false

const LOCK_DELAY_MAX: float = 0.5 # 500ms để xoay sở khi chạm đáy
var lock_timer: float = 0.0
var is_touching_ground: bool = false
var lock_moves_count: int = 0
const MAX_LOCK_MOVES: int = 15 # Chỉ cho di chuyển tối đa 15 lần khi chạm đáy để chống stall

# ╔══════════════════════════════════════════════════╗
# ║             KHỞI ĐỘNG                           ║
# ╚══════════════════════════════════════════════════╝
func _ready() -> void:
	randomize()
	
	# Khởi tạo mesh và shader dùng chung để tối ưu hiệu năng
	shared_box_mesh = BoxMesh.new()
	shared_box_mesh.size = Vector3(0.88, 0.88, 0.88)
	shared_box_mesh.subdivide_width = 5
	shared_box_mesh.subdivide_height = 5
	shared_box_mesh.subdivide_depth = 5

	shared_shader = Shader.new()
	shared_shader.code = SHADER_CODE
	
	# Khởi tạo container bảng chơi để chạy hiệu ứng rơi khi thua
	board_container = Node3D.new()
	board_container.name = "BoardContainer"
	$World3D.add_child(board_container)
	
	$World3D.remove_child(locked_node)
	$World3D.remove_child(active_node)
	$World3D.remove_child(ghost_node)
	board_container.add_child(locked_node)
	board_container.add_child(active_node)
	board_container.add_child(ghost_node)

	_load_settings()
	_setup_3d_scene()
	_setup_particle_materials()
	
	if stats_node:
		stats_node.achievement_unlocked.connect(_on_achievement_unlocked)
		
	reset_game()
	bg_music.finished.connect(_on_bgmusic_finished)
	_apply_audio_settings()


func _on_bgmusic_finished() -> void:
	if settings.music_on:
		bg_music.play()

func _setup_3d_scene() -> void:
	# Camera shift sang phai de khung game hien thi can giua vung choi (trai sidebar)
	base_camera_pos = Vector3(8.22, -9.5, 23.0)
	camera_3d.position = base_camera_pos
	camera_3d.look_at(Vector3(8.22, -9.5, 0.0), Vector3.UP)
	camera_3d.fov = 55.0
	camera_3d.near = 0.1
	camera_3d.far  = 200.0

	sun_light.rotation_degrees = Vector3(-45.0, 20.0, 0.0)
	sun_light.light_energy     = 1.8
	sun_light.light_color      = Color(1.0, 0.98, 0.95)
	sun_light.shadow_enabled   = true

	fill_light.rotation_degrees = Vector3(30.0, -160.0, 0.0)
	fill_light.light_color      = Color(0.5, 0.6, 0.9)
	fill_light.light_energy     = 1.0

	_create_board_frame()

func _setup_particle_materials() -> void:
	for shape in SHAPE_COLORS.keys():
		var mat = StandardMaterial3D.new()
		mat.albedo_color = SHAPE_COLORS[shape]
		mat.emission_enabled = true
		mat.emission = SHAPE_COLORS[shape]
		mat.emission_energy_multiplier = 3.0
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.billboard_keep_scale = true
		particle_materials[shape] = mat

func _create_board_frame() -> void:
	var backdrop := MeshInstance3D.new()
	var bdm      := BoxMesh.new()
	bdm.size                   = Vector3(10.5, 20.5, 0.25)
	backdrop.mesh              = bdm
	backdrop.position          = Vector3(4.5, -9.5, -0.65)
	var bd_mat                 := StandardMaterial3D.new()
	bd_mat.albedo_color        = Color(0.03, 0.03, 0.05, 1.0)
	bd_mat.metallic            = 0.2
	bd_mat.roughness           = 0.8
	backdrop.material_override = bd_mat
	board_container.add_child(backdrop)

	board_glow_mat             = StandardMaterial3D.new()
	board_glow_mat.albedo_color      = Color(0.1, 0.2, 0.6)
	board_glow_mat.metallic          = 0.7
	board_glow_mat.roughness         = 0.15
	board_glow_mat.emission_enabled  = true
	board_glow_mat.emission          = Color(0.2, 0.5, 1.0)
	board_glow_mat.emission_energy_multiplier = 3.0
	var glow_mat = board_glow_mat

	_add_border_bar(board_container, Vector3(0.2, 20.5, 0.4), Vector3(-0.6, -9.5,  0.0), glow_mat)
	_add_border_bar(board_container, Vector3(0.2, 20.5, 0.4), Vector3( 9.6, -9.5,  0.0), glow_mat)
	_add_border_bar(board_container, Vector3(10.4, 0.2, 0.4), Vector3( 4.5,   0.6, 0.0), glow_mat)
	_add_border_bar(board_container, Vector3(10.4, 0.2, 0.4), Vector3( 4.5, -19.6, 0.0), glow_mat)
	_create_grid_lines()


func _add_border_bar(parent: Node3D, sz: Vector3, pos: Vector3, mat: Material) -> void:
	var bar   := MeshInstance3D.new()
	var bm    := BoxMesh.new()
	bm.size   = sz
	bar.mesh  = bm
	bar.position          = pos
	bar.material_override = mat
	parent.add_child(bar)

func _create_grid_lines() -> void:
	if grid_lines_node:
		grid_lines_node.queue_free()
		grid_lines_node = null
	
	if not board_container:
		return
		
	var grid_style = settings.get("grid_style", "standard")
	if grid_style == "none":
		return
		
	grid_lines_node = Node3D.new()
	grid_lines_node.name = "GridLines"
	board_container.add_child(grid_lines_node)
	
	var alpha = 0.2
	var show_horizontal = true
	var show_vertical = true
	
	match grid_style:
		"limited":
			alpha = 0.08
		"vertical":
			show_horizontal = false
			alpha = 0.2
		"full":
			alpha = 0.4
		"standard", _:
			alpha = 0.2
			
	var line_mat = StandardMaterial3D.new()
	line_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var base_col = Color(0.2, 0.3, 0.6)
	var cur_theme = settings.get("theme", "default")
	if cur_theme == "lava":
		base_col = Color(0.8, 0.3, 0.1)
	elif cur_theme == "ice":
		base_col = Color(0.3, 0.6, 0.8)
		
	line_mat.albedo_color = Color(base_col.r, base_col.g, base_col.b, alpha)
	line_mat.emission_enabled = (grid_style == "full") and settings.get("neon_mode", true)
	if line_mat.emission_enabled:
		line_mat.emission = base_col
		line_mat.emission_energy_multiplier = 0.5
	
	if show_vertical:
		for c in range(GRID_WIDTH - 1):
			var x = c + 0.5
			var bar = MeshInstance3D.new()
			var bm = BoxMesh.new()
			bm.size = Vector3(0.015, 20.0, 0.015)
			bar.mesh = bm
			bar.position = Vector3(x, -9.5, -0.52)
			bar.material_override = line_mat
			grid_lines_node.add_child(bar)
			
	if show_horizontal:
		for r in range(GRID_HEIGHT - 1):
			var y = -(r + 0.5)
			if grid_style == "limited" and (r + 1) % 4 != 0:
				continue
			var bar = MeshInstance3D.new()
			var bm = BoxMesh.new()
			bm.size = Vector3(10.0, 0.015, 0.015)
			bar.mesh = bm
			bar.position = Vector3(4.5, y, -0.52)
			bar.material_override = line_mat
			grid_lines_node.add_child(bar)

func shake_camera(intensity: float, dir: float = 0.0) -> void:
	camera_shake_intensity = max(camera_shake_intensity, intensity)
	if dir != 0.0:
		camera_shake_dir = dir

# Sinh hạt lấp lánh (Sparkles) khi ăn hàng
func spawn_line_clear_particles(y_pos: float, color: Color) -> void:
	var particles = GPUParticles3D.new()
	
	var pmat = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(5.0, 0.4, 0.4)
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 4.0
	pmat.initial_velocity_max = 8.0
	pmat.gravity = Vector3(0, -15.0, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.15
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 1.5
	mat.emission_energy_multiplier = 4.0
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(1, 1, 1)
	mesh.material = mat
	
	particles.amount = 50
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.process_material = pmat
	particles.draw_pass_1 = mesh
	
	particles.position = Vector3(4.5, y_pos, 0.5)
	$World3D.add_child(particles)
	particles.emitting = true
	
	get_tree().create_timer(1.2).timeout.connect(func(): particles.queue_free())

# Hiệu ứng Hard Drop Trail
func spawn_hard_drop_trail(x: float, top_y: float, bot_y: float, color: Color) -> void:
	var trail = MeshInstance3D.new()
	var h = abs(top_y - bot_y)
	if h <= 0.1: return
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.6, h, 0.2)
	trail.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.4
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	trail.material_override = mat
	
	trail.position = Vector3(x, -(top_y + bot_y)/2.0, -0.2)
	$World3D.add_child(trail)
	
	var tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(trail, "scale:x", 0.1, 0.25)
	tween.chain().tween_callback(func(): trail.queue_free())

# ╔══════════════════════════════════════════════╗
# ║          THEME & ANIMATION SYSTEM               ║
# ╚══════════════════════════════════════════════╝
func apply_theme(theme_name: String) -> void:
	current_theme = theme_name
	if current_name != "":
		current_color = _get_theme_color(current_name)
	if board_glow_mat:
		var neon_on = settings.get("neon_mode", true)
		match theme_name:
			"lava":
				board_glow_mat.albedo_color             = Color(0.20, 0.02, 0.0)
				board_glow_mat.emission                 = Color(0.60, 0.15, 0.0)
				board_glow_mat.emission_energy_multiplier = 1.2 if neon_on else 0.15
			"ice":
				board_glow_mat.albedo_color             = Color(0.04, 0.16, 0.28)
				board_glow_mat.emission                 = Color(0.20, 0.45, 0.60)
				board_glow_mat.emission_energy_multiplier = 1.0 if neon_on else 0.1
			_:
				board_glow_mat.albedo_color             = Color(0.1, 0.2, 0.6)
				board_glow_mat.emission                 = Color(0.2, 0.5, 1.0)
				board_glow_mat.emission_energy_multiplier = 3.0 if neon_on else 0.2
	_refresh_all()


func _get_theme_color(shape_name: String) -> Color:
	match current_theme:
		"lava": return LAVA_COLORS.get(shape_name, Color.WHITE)
		"ice":  return ICE_COLORS.get(shape_name, Color.WHITE)
		_:      return SHAPE_COLORS.get(shape_name, Color.WHITE)

func spawn_theme_landing_effect() -> void:
	match current_theme:
		"lava": _spawn_lava_sparks()
		"ice":  _spawn_ice_splash()

func _spawn_particle_burst(world_pos: Vector3, dir_y: float, spread: float,
		v_min: float, v_max: float, grav_y: float, amount: int, lifetime: float,
		explosiveness: float, albedo: Color, emission: Color, emission_e: float) -> void:
	var particles = GPUParticles3D.new()
	var pmat = ParticleProcessMaterial.new()
	pmat.emission_shape         = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents   = Vector3(float(current_size) * 0.4, 0.15, 0.1)
	pmat.direction              = Vector3(0, dir_y, 0)
	pmat.spread                 = spread
	pmat.initial_velocity_min   = v_min
	pmat.initial_velocity_max   = v_max
	pmat.gravity                = Vector3(0, grav_y, 0)
	pmat.scale_min              = 0.04
	pmat.scale_max              = 0.13
	var mat = StandardMaterial3D.new()
	mat.albedo_color            = albedo
	mat.emission_enabled        = true
	mat.emission                = emission
	mat.emission_energy_multiplier = emission_e
	var mesh = BoxMesh.new()
	mesh.size = Vector3(1, 1, 1)
	mesh.material = mat
	particles.amount            = amount
	particles.lifetime          = lifetime
	particles.one_shot          = true
	particles.explosiveness     = explosiveness
	particles.process_material  = pmat
	particles.draw_pass_1       = mesh
	particles.position          = world_pos
	$World3D.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(lifetime + 0.3).timeout.connect(func(): particles.queue_free())

func _spawn_lava_sparks() -> void:
	var cx = float(current_x) + current_size * 0.5
	var cy = float(-(current_y + current_size - 1))
	_spawn_particle_burst(Vector3(cx, cy, 0.5), 1.0, 80.0, 2.0, 5.5, -12.0, 22, 0.65, 0.88,
		Color(1.0, 0.5, 0.0), Color(1.0, 0.2, 0.0), 6.0)

func _spawn_ice_splash() -> void:
	var cx = float(current_x) + current_size * 0.5
	var cy = float(-(current_y + current_size - 1))
	_spawn_particle_burst(Vector3(cx, cy, 0.5), 1.0, 110.0, 1.5, 4.5, -7.0, 20, 0.75, 0.80,
		Color(0.72, 0.96, 1.0), Color(0.5, 0.88, 1.0), 3.5)

func spawn_fire_cascade() -> void:
	for _i in range(7):
		var particles = GPUParticles3D.new()
		var pmat = ParticleProcessMaterial.new()
		pmat.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		pmat.direction            = Vector3(0, -1, 0)
		pmat.spread               = 22.0
		pmat.initial_velocity_min = 5.0
		pmat.initial_velocity_max = 11.0
		pmat.gravity              = Vector3(0, -4.0, 0)
		pmat.scale_min            = 0.07
		pmat.scale_max            = 0.22
		var mat = StandardMaterial3D.new()
		mat.albedo_color          = Color(1.0, randf_range(0.1, 0.5), 0.0)
		mat.emission_enabled      = true
		mat.emission              = Color(1.0, 0.3, 0.0)
		mat.emission_energy_multiplier = 8.0
		var mesh = BoxMesh.new()
		mesh.size = Vector3(1, 1, 1)
		mesh.material = mat
		particles.amount          = 20
		particles.lifetime        = 1.2
		particles.one_shot        = true
		particles.explosiveness   = 0.78
		particles.process_material = pmat
		particles.draw_pass_1     = mesh
		particles.position        = Vector3(randf_range(0.5, 8.5), 2.0, 0.5)
		$World3D.add_child(particles)
		particles.emitting = true
		get_tree().create_timer(1.8).timeout.connect(func(): particles.queue_free())

func spawn_snow_cascade() -> void:
	var particles = GPUParticles3D.new()
	var pmat = ParticleProcessMaterial.new()
	pmat.emission_shape         = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents   = Vector3(5.0, 0.1, 0.1)
	pmat.direction              = Vector3(0, -1, 0)
	pmat.spread                 = 30.0
	pmat.initial_velocity_min   = 1.5
	pmat.initial_velocity_max   = 4.5
	pmat.gravity                = Vector3(randf_range(-0.3, 0.3), -2.5, 0)
	pmat.scale_min              = 0.04
	pmat.scale_max              = 0.14
	var mat = StandardMaterial3D.new()
	mat.albedo_color            = Color(0.92, 0.97, 1.0)
	mat.emission_enabled        = true
	mat.emission                = Color(0.6, 0.88, 1.0)
	mat.emission_energy_multiplier = 3.0
	var mesh = BoxMesh.new()
	mesh.size = Vector3(1, 1, 1)
	mesh.material = mat
	particles.amount            = 70
	particles.lifetime          = 2.5
	particles.one_shot          = true
	particles.explosiveness     = 0.3
	particles.process_material  = pmat
	particles.draw_pass_1       = mesh
	particles.position          = Vector3(4.5, 2.0, 0.5)
	$World3D.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(3.2).timeout.connect(func(): particles.queue_free())

func _start_game_over_fall() -> void:
	shake_camera(1.5)
	var tween = create_tween()
	# Bounce nhẹ lên rồi rơi sụp xuống dưới màn hình
	tween.tween_property(board_container, "position:y",  2.2, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(board_container, "position:y", -45.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		board_offset_y    = 0.0
		board_velocity_y  = 0.0
		show_game_over_overlay = true
		_notify_hud()
	)


# ╔══════════════════════════════════════════════════╗
# ║             LOGIC GAME                          ║
# ╚══════════════════════════════════════════════════╝
# ── Binding Helpers ──────────────────────────────────────────────────────────
func _default_bindings() -> Dictionary:
	return {
		"move_left":  KEY_LEFT,  "move_right": KEY_RIGHT,
		"soft_drop":  KEY_DOWN,  "hard_drop":  KEY_SPACE,
		"rotate_cw":  KEY_UP,    "rotate_ccw": KEY_X,
		"rotate_180": KEY_A,     "hold":       KEY_C,
	}

func _key_matches(event: InputEventKey, action: String) -> bool:
	var bindings = settings.get("bindings", {})
	var bound_key: int = bindings.get(action, _default_bindings().get(action, -1))
	if bound_key < 0: return false
	return event.keycode == bound_key or event.physical_keycode == bound_key

# ─────────────────────────────────────────────────────────────────────────────
func get_fall_speed_sec() -> float:
	# Công thức trọng lực Tetris chuẩn: (0.8 - (level-1)*0.007)^(level-1)
	var base_speed = pow(0.8 - (level - 1) * 0.007, level - 1)
	var scale_val = settings.get("fall_speed_scale", 1.0)
	if scale_val <= 0.01: scale_val = 0.01
	return max(0.007, base_speed / scale_val)

func _get_next_shape_name() -> String:
	if bag.is_empty():
		bag = SHAPES.keys().duplicate()
		bag.shuffle()
	return bag.pop_back()

func _spawn_piece(shape_name: String) -> void:
	current_name  = shape_name
	current_shape = []
	for row in SHAPES[shape_name]:
		current_shape.append(row.duplicate())
	current_color = _get_theme_color(shape_name)
	current_size  = current_shape.size()
	current_x     = int(GRID_WIDTH / 2 - current_size / 2)
	current_y     = -1 if shape_name == "I" else 0
	
	is_touching_ground = false
	lock_timer = 0.0
	lock_moves_count = 0
	fall_accum = 0.0
	current_rotation = 0
	last_kick_index = -1
	current_lock_spin_type = "none"
	cur_piece_left_inputs = 0
	cur_piece_right_inputs = 0
	cur_piece_rot_cw_inputs = 0
	cur_piece_rot_ccw_inputs = 0
	cur_piece_rot_180_inputs = 0
	dcd_timer = settings.get("dcd_delay", 0.0)
	
	if not pieces_spawned_this_game.has(shape_name):
		pieces_spawned_this_game[shape_name] = 0
	pieces_spawned_this_game[shape_name] += 1
	
	last_action_was_rotate = false
	active_target_pos = Vector3(current_x, -current_y, 0.0)
	active_visual_pos = active_target_pos
	active_node.position = active_target_pos
	
	# DAS Carry-over: nếu đang giữ phím khi spawn gạch mới,
	# tiếp tục DAS với hướng hiện tại mà không reset timer.
	# Nếu DAS đã charge đủ, ngay lập tức bắt đầu ARR.
	if not (key_left_held or key_right_held):
		das_direction = 0
		das_timer     = 0.0
		arr_timer     = 0.0

	_refresh_active(true)
	_refresh_ghost()

func _spawn_next_from_queue() -> void:
	var shape_name = next_queue.pop_front()
	next_queue.append(_get_next_shape_name())
	_spawn_piece(shape_name)



func reset_game() -> void:
	if game_over and stats_node and pieces_spawned_this_game.size() > 0:
		stats_node.record_game_over(score, lines_cleared, pieces_spawned_this_game)
		
	grid = []
	for _r in range(GRID_HEIGHT):
		var row := []
		for _c in range(GRID_WIDTH):
			row.append(null)
		grid.append(row)

	score = 0
	level = settings.get("start_level", 1)
	lines_cleared = 0
	game_over = false; paused = false; show_settings = false; show_stats = false
	is_clearing_lines = false
	bag = []; can_hold = true; fall_accum = 0.0
	tetris_streak = 0
	combo_count = -1
	t_spin_triggered = false
	perfect_clear_triggered = false
	last_action_was_rotate = false
	board_offset_y = 0.0
	board_velocity_y = 0.0
	b2b_active = false
	last_kick_index = -1
	dcd_timer = 0.0
	current_lock_spin_type = "none"
	finesse_faults = 0
	time_elapsed = 0.0
	last_action_label = ""
	clears_history.clear()
	cur_piece_left_inputs = 0
	cur_piece_right_inputs = 0
	cur_piece_rot_cw_inputs = 0
	cur_piece_rot_ccw_inputs = 0
	cur_piece_rot_180_inputs = 0
	key_left_held  = Input.is_key_pressed(KEY_LEFT)
	key_right_held = Input.is_key_pressed(KEY_RIGHT)
	key_down_held  = Input.is_key_pressed(KEY_DOWN)
	if key_left_held:
		das_direction = -1
	elif key_right_held:
		das_direction = 1
	else:
		das_direction = 0
	das_timer      = 0.0
	arr_timer      = 0.0
	pieces_spawned_this_game.clear()

	next_queue.clear()
	for _i in range(6):
		next_queue.append(_get_next_shape_name())
	_spawn_next_from_queue()
	show_game_over_overlay = false
	board_container.position.y = 0.0
	apply_theme(settings.get("theme", "default"))
	hold_name = ""; hold_shape = []; hold_size = 0


	_refresh_all()

func check_collision(offset_x: int = 0, offset_y: int = 0, check_shape: Array = []) -> bool:
	var sh := check_shape if not check_shape.is_empty() else current_shape
	for r in range(current_size):
		for c in range(current_size):
			if sh[r][c]:
				var gx := current_x + c + offset_x
				var gy := current_y + r + offset_y
				if gx < 0 or gx >= GRID_WIDTH or gy >= GRID_HEIGHT:
					return true
				if gy >= 0 and grid[gy][gx] != null:
					return true
	return false

func move_piece(dx: int, dy: int, silent: bool = false) -> bool:
	if is_clearing_lines or game_over or paused: return false
	if not check_collision(dx, dy):
		current_x += dx
		current_y += dy
		active_target_pos = Vector3(current_x, -current_y, 0.0)
		if dx != 0 or dy != 0:
			last_action_was_rotate = false
		if dy > 0:
			lock_moves_count = 0 # Reset đếm xoay sở khi rơi xuống tầng mới
		if dx != 0 and not silent: 
			_play_sfx(sfx_move)
			# Reset lock delay nếu di chuyển thành công
			if is_touching_ground and lock_moves_count < MAX_LOCK_MOVES:
				lock_timer = 0.0
				lock_moves_count += 1
		
		_update_ground_state()
		if not silent:
			_refresh_active()
			_refresh_ghost()
			_notify_hud()
		return true
	return false

func rotate_piece(dir: int = 1) -> void:
	if is_clearing_lines or game_over or paused: return
	var old_shape    := current_shape.duplicate(true)
	var old_rotation := current_rotation
	var n            := current_size
	var rotated      := []
	for _r in range(n):
		var row := []; for _c in range(n): row.append(0)
		rotated.append(row)
	
	var new_rotation: int
	if dir == 1:    # CW
		new_rotation = (current_rotation + 1) % 4
		for r in range(n):
			for c in range(n): rotated[c][n - 1 - r] = current_shape[r][c]
	elif dir == -1: # CCW
		new_rotation = (current_rotation + 3) % 4
		for r in range(n):
			for c in range(n): rotated[n - 1 - c][r] = current_shape[r][c]
	elif dir == 2:  # 180
		new_rotation = (current_rotation + 2) % 4
		for r in range(n):
			for c in range(n): rotated[n - 1 - r][n - 1 - c] = current_shape[r][c]
	else:
		return
	current_shape = rotated

	# Chọn bảng SRS kick phù hợp
	var kick_key := old_rotation * 4 + new_rotation
	var kicks: Array
	if dir == 2:  # 180° không có trong bảng SRS → dùng bảng riêng
		kicks = SRS_KICKS_180.duplicate()
	elif current_name == "I":
		kicks = SRS_KICKS_I.get(kick_key, [Vector2i(0, 0)])
	elif current_name == "O":
		kicks = [Vector2i(0, 0)]
	else:
		kicks = SRS_KICKS_JLSTZ.get(kick_key, [Vector2i(0, 0)])

	var kicked := false
	var kick_idx := -1
	for idx in range(kicks.size()):
		var offset = kicks[idx]
		if not check_collision(offset.x, offset.y):
			current_x += offset.x
			current_y += offset.y
			kicked = true
			kick_idx = idx
			break

	if not kicked:
		current_shape = old_shape
		current_rotation = old_rotation
	else:
		current_rotation = new_rotation
		last_kick_index = kick_idx
		dcd_timer = settings.get("dcd_delay", 0.0)
		_play_sfx(sfx_rotate)
		last_action_was_rotate = true
		if is_touching_ground and lock_moves_count < MAX_LOCK_MOVES:
			lock_timer = 0.0
			lock_moves_count += 1
		_update_ground_state()
		active_target_pos = Vector3(current_x, -current_y, 0.0)
		_refresh_active(true)
		_refresh_ghost()
		_notify_hud()

func _update_ground_state() -> void:
	is_touching_ground = check_collision(0, 1)

func hold_current_piece() -> void:
	if is_clearing_lines or not can_hold: return
	_play_sfx(sfx_rotate)

	var prev_hold := hold_name
	hold_name  = current_name
	hold_shape = []
	for row in SHAPES[current_name]: hold_shape.append(row.duplicate())
	hold_color = _get_theme_color(current_name)
	hold_size  = hold_shape.size()

	if prev_hold == "":
		_spawn_next_from_queue()
	else:
		_spawn_piece(prev_hold)

	can_hold = false

	if check_collision():
		game_over = true
		_on_game_over()

	_refresh_all()

func get_ghost_y_offset() -> int:
	var off := 0
	while not check_collision(0, off + 1): off += 1
	return off

func hard_drop() -> void:
	if is_clearing_lines or game_over or paused: return
	var off := get_ghost_y_offset()
	var start_y = current_y
	current_y += off
	score += off * 2
	
	# Tính tâm X để vẽ đuôi Hard Drop
	var center_x = current_x + current_size / 2.0
	spawn_hard_drop_trail(center_x, float(start_y), float(current_y), current_color)
	
	shake_camera(0.6)
	if stats_node: stats_node.check_event("score", score)
	
	board_velocity_y = -18.0
	
	active_target_pos = Vector3(current_x, -current_y, 0.0)
	active_visual_pos = active_target_pos
	active_node.position = active_target_pos
	_lock_piece()

func _check_spin() -> String:
	if not last_action_was_rotate:
		return "none"
		
	if current_name == "T":
		var corners = [
			Vector2i(current_x, current_y),
			Vector2i(current_x + 2, current_y),
			Vector2i(current_x, current_y + 2),
			Vector2i(current_x + 2, current_y + 2)
		]
		var occupied_count = 0
		for corner in corners:
			var cx = corner.x
			var cy = corner.y
			if cx < 0 or cx >= GRID_WIDTH or cy >= GRID_HEIGHT:
				occupied_count += 1
			elif cy >= 0 and grid[cy][cx] != null:
				occupied_count += 1
				
		if occupied_count >= 3:
			var front_occupied_count = 0
			match current_rotation:
				0:
					if _is_cell_occupied(current_x, current_y): front_occupied_count += 1
					if _is_cell_occupied(current_x + 2, current_y): front_occupied_count += 1
				1:
					if _is_cell_occupied(current_x + 2, current_y): front_occupied_count += 1
					if _is_cell_occupied(current_x + 2, current_y + 2): front_occupied_count += 1
				2:
					if _is_cell_occupied(current_x, current_y + 2): front_occupied_count += 1
					if _is_cell_occupied(current_x + 2, current_y + 2): front_occupied_count += 1
				3:
					if _is_cell_occupied(current_x, current_y): front_occupied_count += 1
					if _is_cell_occupied(current_x, current_y + 2): front_occupied_count += 1
			
			if last_kick_index == 4:
				return "t_spin"
			if front_occupied_count == 2:
				return "t_spin"
			else:
				return "mini_t_spin"
		return "none"
	else:
		if check_collision(1, 0) and check_collision(-1, 0) and check_collision(0, 1):
			return "spin"
		return "none"

func _is_cell_occupied(cx: int, cy: int) -> bool:
	if cx < 0 or cx >= GRID_WIDTH or cy >= GRID_HEIGHT:
		return true
	if cy >= 0 and grid[cy][cx] != null:
		return true
	return false

func _lock_piece() -> void:
	active_node.position = active_target_pos
	
	# Finesse evaluation
	var faults = 0
	if cur_piece_left_inputs > 0 and cur_piece_right_inputs > 0:
		faults += 1
	if cur_piece_rot_cw_inputs > 0 and cur_piece_rot_ccw_inputs > 0:
		faults += 1
	if cur_piece_rot_cw_inputs >= 3 or cur_piece_rot_ccw_inputs >= 3:
		faults += 1
	if cur_piece_rot_180_inputs > 1:
		faults += 1
	finesse_faults += faults

	var spin_type = _check_spin()
	current_lock_spin_type = spin_type
	
	if spin_type != "none":
		if spin_type == "t_spin" or spin_type == "mini_t_spin":
			t_spin_triggered = true
		_play_sfx(sfx_rotate)
		shake_camera(0.4)
		board_velocity_y = -12.0
	else:
		if board_velocity_y >= 0.0:
			board_velocity_y = -6.0
			
	for r in range(current_size):
		for c in range(current_size):
			if current_shape[r][c]:
				var gy := current_y + r
				var gx := current_x + c
				if gy < 0: game_over = true
				else: grid[gy][gx] = current_name


	# Xoá gạch đang rơi và bóng mờ ngay lập tức khi khoá để tránh trùng lặp hiển thị
	_clear_node_children(active_node)
	_clear_node_children(ghost_node)

	if game_over:
		_on_game_over()
		return

	# Hiệu ứng nảy nhẹ khi khóa
	shake_camera(0.15)
	spawn_theme_landing_effect()
	
	# Highlight nhẹ những ô vừa khóa
	for child in locked_node.get_children():
		pass # Tương lai có thể thêm material override tại đây

	_check_and_clear_lines()

func _check_and_clear_lines() -> void:
	var to_clear := []
	for r in range(GRID_HEIGHT):
		var full := true
		for c in range(GRID_WIDTH):
			if grid[r][c] == null:
				full = false
				break
		if full: to_clear.append(r)

	if to_clear.is_empty():
		if current_lock_spin_type != "none":
			var spin_pts = 0
			var action_label = ""
			if current_lock_spin_type == "t_spin":
				spin_pts = 400
				action_label = "T-Spin"
			elif current_lock_spin_type == "mini_t_spin":
				spin_pts = 100
				action_label = "Mini T-Spin"
			else:
				spin_pts = 400
				action_label = current_name + "-Spin"
			
			score += spin_pts * level
			last_action_label = action_label
			if stats_node:
				stats_node.check_event("score", score)
		
		tetris_streak = 0
		combo_count = -1
		_play_sfx(sfx_move)
		_next_turn()
		return

	is_clearing_lines = true
	_play_sfx(sfx_clear)
	shake_camera(0.5 + 0.15 * to_clear.size()) 
	board_velocity_y = 12.0
	
	if hud_control and to_clear.size() >= 4:
		hud_control.trigger_screen_flash()

	_refresh_locked_blocks()
	var tween = create_tween().set_parallel(true)
	
	for child in locked_node.get_children():
		var cy = int(-child.position.y)
		if cy in to_clear:
			tween.tween_property(child, "scale", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(child, "rotation_degrees:z", randf_range(-90, 90), 0.25)
	
	for cy in to_clear:
		spawn_line_clear_particles(float(-cy), current_color)

	tween.chain().tween_callback(Callable(self, "_finish_clear_lines").bind(to_clear))

func _finish_clear_lines(to_clear: Array) -> void:
	var n = to_clear.size()
	to_clear.sort()
	to_clear.reverse()
	for ri in to_clear: grid.remove_at(ri)

	for _i in range(n):
		var empty := []
		for _c in range(GRID_WIDTH): empty.append(null)
		grid.insert(0, empty)

	# Kiểm tra Perfect Clear (Dọn sạch hoàn toàn bảng)
	var is_perfect_clear = true
	for r in range(GRID_HEIGHT):
		for c in range(GRID_WIDTH):
			if grid[r][c] != null:
				is_perfect_clear = false
				break
		if not is_perfect_clear:
			break
			
	if is_perfect_clear:
		perfect_clear_triggered = true
		var pc_bonus = 0
		if n == 1:
			pc_bonus = 800
		elif n == 2:
			pc_bonus = 1200
		elif n == 3:
			pc_bonus = 1800
		elif n == 4:
			if b2b_active:
				pc_bonus = 3200
			else:
				pc_bonus = 2000
		score += pc_bonus * level
		board_velocity_y = 25.0
		shake_camera(1.0)
		match current_theme:
			"lava":
				spawn_fire_cascade()
			"ice":
				spawn_snow_cascade()
			_:
				for py in [-4.0, -9.0, -14.0]:
					spawn_line_clear_particles(py, Color(randf(), randf(), randf()))

	combo_count += 1
	var had_spin_type = current_lock_spin_type
	
	var base_pts = 0
	var is_difficult = false
	var action_name = ""

	# 1. Determine base points and difficult status
	if had_spin_type == "t_spin":
		is_difficult = (n > 0)
		if n == 0:
			base_pts = 400
			action_name = "T-Spin"
		elif n == 1:
			base_pts = 800
			action_name = "T-Spin Single"
		elif n == 2:
			base_pts = 1200
			action_name = "T-Spin Double"
		elif n == 3:
			base_pts = 1600
			action_name = "T-Spin Triple"
	elif had_spin_type == "mini_t_spin":
		is_difficult = (n > 0)
		if n == 0:
			base_pts = 100
			action_name = "Mini T-Spin"
		elif n == 1:
			base_pts = 200
			action_name = "Mini T-Spin Single"
		elif n == 2:
			base_pts = 400
			action_name = "Mini T-Spin Double"
	elif had_spin_type == "spin":
		# Non-T spins
		is_difficult = (n > 0)
		var piece_prefix = current_name + "-Spin"
		if n == 0:
			base_pts = 400
			action_name = piece_prefix
		elif n == 1:
			base_pts = 800
			action_name = piece_prefix + " Single"
		elif n == 2:
			base_pts = 1200
			action_name = piece_prefix + " Double"
		elif n == 3:
			base_pts = 1600
			action_name = piece_prefix + " Triple"
	else:
		# Normal clear
		if n == 1:
			base_pts = 100
			action_name = "Single"
		elif n == 2:
			base_pts = 300
			action_name = "Double"
		elif n == 3:
			base_pts = 500
			action_name = "Triple"
		elif n == 4:
			base_pts = 800
			is_difficult = true
			action_name = "Tetris"

	# 2. Check for specialized openers/combos (DT Cannon / TKI)
	if n > 0:
		if clears_history.is_empty():
			# First clear of the game
			if had_spin_type == "t_spin" and n == 2:
				action_name = "TKI Opener (T-Spin Double)"
		else:
			# Check last clear in history
			var last_clear = clears_history[-1]
			if last_clear.get("spin") == "t_spin" and last_clear.get("lines") == 2:
				if had_spin_type == "t_spin" and n == 3:
					action_name = "DT Cannon (T-Spin Triple)"

	# 3. Apply B2B if difficult
	var b2b_mult = 1.0
	if n > 0:
		if is_difficult:
			if b2b_active:
				b2b_mult = 1.5
				action_name = "B2B " + action_name
			b2b_active = true
		else:
			b2b_active = false

	var final_base = base_pts * b2b_mult

	# 4. Add Combo points
	if combo_count > 0:
		final_base += combo_count * 50
		action_name += " (Combo x%d)" % combo_count

	if n > 0:
		score += int(final_base * level)
		last_action_label = action_name
		
		# Record to history for openers
		clears_history.append({
			"lines": n,
			"spin": had_spin_type,
			"piece": current_name
		})

	if n >= 4:
		tetris_streak += 1
		if stats_node: stats_node.check_event("tetris_streak", tetris_streak)
	elif n > 0:
		tetris_streak = 0

	lines_cleared += n
	
	var start_lvl = settings.get("start_level", 1)
	var new_level = start_lvl + int(lines_cleared / 10.0)
	if new_level > level:
		board_velocity_y = 20.0
		level = new_level
	
	if stats_node:
		stats_node.check_event("score", score)
		stats_node.check_event("lines_cleared", n)
		stats_node.check_event("level", level)

	is_clearing_lines = false
	_next_turn()

func _next_turn() -> void:
	_spawn_next_from_queue()
	can_hold = true

	if check_collision():
		game_over = true
		_on_game_over()

	_refresh_all()

func _on_game_over() -> void:
	_play_sfx(sfx_gameover)
	if stats_node:
		stats_node.record_game_over(score, lines_cleared, pieces_spawned_this_game)
	show_game_over_overlay = false
	_refresh_locked_blocks()
	_notify_hud()     # Hiển thị game state KHÔNG có overlay
	_start_game_over_fall()  # Bắt đầu animation rớt

# ╔══════════════════════════════════════════════════╗
# ║             3D SHADER RENDERING                 ║
# ╚══════════════════════════════════════════════════╝
func _get_shader_material(color: Color, alpha: float, theme_idx: int) -> ShaderMaterial:
	var cache_key = "%s_%.2f_%d" % [color.to_html(), alpha, theme_idx]
	if shader_mat_cache.has(cache_key):
		return shader_mat_cache[cache_key]
		
	var mat = ShaderMaterial.new()
	mat.shader = shared_shader
	mat.set_shader_parameter("albedo", Color(color.r, color.g, color.b, alpha))
	mat.set_shader_parameter("metallic", 0.3)
	mat.set_shader_parameter("roughness", 0.22)
	mat.set_shader_parameter("radius", 0.15)
	mat.set_shader_parameter("box_extents", Vector3(0.44, 0.44, 0.44))
	mat.set_shader_parameter("theme", theme_idx)
	
	var neon_on = settings.get("neon_mode", true)
	if alpha < 1.0:
		mat.set_shader_parameter("emission", color * 0.3)
		mat.set_shader_parameter("emission_energy", 0.35 if neon_on else 0.0)
	else:
		mat.set_shader_parameter("emission", color * 0.25)
		mat.set_shader_parameter("emission_energy", 1.35 if neon_on else 0.15)
		
	shader_mat_cache[cache_key] = mat
	return mat

func _make_rounded_cube(col: int, row: int, color: Color, alpha: float = 1.0) -> MeshInstance3D:
	var theme_idx = 0
	if current_theme == "lava":
		theme_idx = 1
	elif current_theme == "ice":
		theme_idx = 2
		
	var inst := MeshInstance3D.new()
	inst.mesh = shared_box_mesh

	var mat = _get_shader_material(color, alpha, theme_idx)
	inst.material_override = mat
	if alpha < 1.0:
		inst.transparency = 1.0 # Alpha pass
		
	inst.position = Vector3(float(col), float(-row), 0.0)
	return inst


func _clear_node_children(node: Node3D) -> void:
	for child in node.get_children():
		child.queue_free()

func _refresh_locked_blocks() -> void:
	_clear_node_children(locked_node)
	for r in range(GRID_HEIGHT):
		for c in range(GRID_WIDTH):
			var shape_name = grid[r][c]
			if shape_name != null:
				var color = _get_theme_color(shape_name)
				locked_node.add_child(_make_rounded_cube(c, r, color))


func _refresh_active(with_pop_effect: bool = false) -> void:
	_clear_node_children(active_node)
	if current_name == "": return
	
	var cubes = []
	for r in range(current_size):
		for c in range(current_size):
			if current_shape[r][c]:
				var py := current_y + r
				if py >= 0:
					var cube = _make_rounded_cube(c, r, current_color)
					active_node.add_child(cube)
					cubes.append(cube)
					
	if with_pop_effect and cubes.size() > 0:
		var tween = create_tween().set_parallel(true)
		for c in cubes:
			c.scale = Vector3(0.6, 0.6, 0.6)
			tween.tween_property(c, "scale", Vector3.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _refresh_ghost() -> void:
	_clear_node_children(ghost_node)
	if not settings.get("show_ghost", true): return
	if current_name == "" or game_over or paused or is_clearing_lines: return
	var goff := get_ghost_y_offset()
	if goff <= 0: return # Không vẽ bóng mờ nếu đè lên mảnh gạch đang rơi
	for r in range(current_size):
		for c in range(current_size):
			if current_shape[r][c]:
				var px := current_x + c
				var py := current_y + r + goff
				if py >= 0:
					# Bóng mờ hơn trước (alpha 0.12)
					ghost_node.add_child(_make_rounded_cube(px, py, current_color, 0.12))

func _refresh_all() -> void:
	_refresh_locked_blocks()
	_refresh_active()
	_refresh_ghost()
	_notify_hud()

func _notify_hud() -> void:
	if not hud_control: return
	var stats_data = null
	var hint = ""
	if stats_node:
		stats_data = stats_node.data
		hint = stats_node.get_challenge_hint()
		
	hud_control.update_hud(
		score, level, lines_cleared,
		next_queue,
		hold_name, hold_shape, hold_color, hold_size,
		can_hold, game_over and show_game_over_overlay, paused, show_settings, show_stats,
		stats_data, hint, settings,
		combo_count, t_spin_triggered, perfect_clear_triggered,
		finesse_faults, time_elapsed, last_action_label
	)
	t_spin_triggered = false
	perfect_clear_triggered = false
	last_action_label = ""

func _on_achievement_unlocked(_ach_id: String, info: Dictionary):
	if hud_control:
		hud_control.show_achievement(info["name"], info["desc"], info["icon"])

# ╔══════════════════════════════════════════════════╗
# ║             INPUT & PROCESS                     ║
# ╚══════════════════════════════════════════════════╝
func _process(delta: float) -> void:
	if not game_over and not paused and not show_settings and not show_stats and not is_clearing_lines:
		time_elapsed += delta
	if dcd_timer > 0.0:
		dcd_timer = max(0.0, dcd_timer - delta)

	if camera_shake_intensity > 0.0:
		camera_shake_intensity = lerpf(camera_shake_intensity, 0.0, delta * 15.0)
		var sx: float
		if camera_shake_dir != 0.0:
			# Rung co huong (khi dung sat tuong)
			sx = camera_shake_dir * camera_shake_intensity * 0.75
			if camera_shake_intensity < 0.02:
				camera_shake_dir = 0.0
		else:
			sx = randf_range(-camera_shake_intensity, camera_shake_intensity)
		var shake_offset = Vector3(sx, randf_range(-camera_shake_intensity, camera_shake_intensity) * 0.35, 0)
		camera_3d.position = base_camera_pos + shake_offset
	else:
		camera_shake_dir = 0.0
		camera_3d.position = base_camera_pos

	# Board Spring Bounce Logic (Lực lò xo đàn hồi)
	var spring_k = 300.0
	var spring_c = 18.0
	var force = -spring_k * board_offset_y - spring_c * board_velocity_y
	board_velocity_y += force * delta
	board_offset_y += board_velocity_y * delta

	# Áp dụng offset cho LockedBlocks và GhostBlock
	locked_node.position.y = board_offset_y
	ghost_node.position.y = board_offset_y

	# Nội suy mượt mà vị trí của mảnh gạch đang điều khiển + board bounce
	if active_node and current_name != "" and not game_over and not paused:
		active_visual_pos.x = active_target_pos.x # Phản hồi ngang tức thì
		active_visual_pos.y = lerpf(active_visual_pos.y, active_target_pos.y, 1.0 - exp(-100.0 * delta)) # Rơi mượt mà nhưng cực nhanh
		active_visual_pos.z = active_target_pos.z
		active_node.position = active_visual_pos + Vector3(0.0, board_offset_y, 0.0)

	if game_over or paused or show_settings or show_stats or is_clearing_lines:
		return
		
	# Fall & Lock Logic
	fall_accum += delta
	var speed  := get_fall_speed_sec()
	if key_down_held:
		var sd_speed = settings.get("soft_drop_speed", "trung")
		if sd_speed == "tuc_thi":
			var moved = true
			var cells_dropped = 0
			while moved:
				moved = move_piece(0, 1, true)
				if moved:
					score += 1
					cells_dropped += 1
			if cells_dropped > 0:
				_refresh_active()
				_refresh_ghost()
				_notify_hud()
			_update_ground_state()
		else:
			var mult = 0.05
			match sd_speed:
				"cham":     mult = 0.5
				"trung":    mult = 0.1
				"nhanh":    mult = 0.03
				"sieu_toc":  mult = 0.005
			speed *= mult

	_update_ground_state()
	
	if is_touching_ground:
		lock_timer += delta
		if lock_timer >= LOCK_DELAY_MAX:
			_lock_piece()
	else:
		lock_timer = 0.0
		# Phòng chống tràn vòng lặp do lag đột ngột
		if fall_accum > speed * 22.0:
			fall_accum = speed * 22.0
		if fall_accum >= speed:
			var score_changed = false
			var moved_at_all = false
			while fall_accum >= speed and not is_touching_ground:
				fall_accum -= speed
				var moved = move_piece(0, 1, true)
				if moved:
					moved_at_all = true
					if key_down_held:
						score += 1
						score_changed = true
				_update_ground_state()
			if moved_at_all:
				_refresh_active()
				_refresh_ghost()
				_notify_hud()
			elif score_changed:
				_notify_hud()

	# ╔══════════════════════════════════════════════╗
	# ║  DAS/ARR thuần delta-time, bỏ OS key repeat ║
	# ╚══════════════════════════════════════════════╝
	var das_cfg: float = settings.get("das_delay", 0.085)
	var arr_cfg: float = settings.get("arr_delay", 0.010)

	# Xác định hướng ưu tiên: phím bấm sau cùng được ưu tiên
	var want_dir: int = 0
	if key_left_held and key_right_held:
		# Cả hai đang giữ → ưu tiên phím giữ lâu hơn (das_direction)
		want_dir = das_direction if das_direction != 0 else -1
	elif key_left_held:
		want_dir = -1
	elif key_right_held:
		want_dir = 1

	if want_dir != 0:
		if das_direction != want_dir:
			# Vừa đổi hướng hoặc bấm mới: di chuyển ngay 1 ô, reset timer
			das_direction = want_dir
			das_timer     = 0.0
			arr_timer     = 0.0
			move_piece(das_direction, 0)
		else:
			# Đang giữ cùng hướng: tích lũy DAS (chỉ khi dcd_timer <= 0)
			if dcd_timer <= 0.0:
				das_timer += delta
				if das_timer >= das_cfg:
					if arr_cfg <= 0.001:
						# ARR = 0 → snap tức thì sát tường
						while move_piece(das_direction, 0):
							pass
					else:
						arr_timer += delta
						while arr_timer >= arr_cfg:
							arr_timer -= arr_cfg
							if not move_piece(das_direction, 0):
								arr_timer = 0.0
								break
	else:
		das_direction = 0
		das_timer     = 0.0
		arr_timer     = 0.0

	# Wall-hit shake: rung nhe khi dung sat tuong trai/phai
	if not game_over and current_name != "":
		var wall_hit = 0
		if das_direction == -1 and check_collision(-1, 0):
			wall_hit = -1
		elif das_direction == 1 and check_collision(1, 0):
			wall_hit = 1
		if wall_hit != 0 and prev_wall_hit_dir != wall_hit:
			shake_camera(0.18, float(wall_hit))
		prev_wall_hit_dir = wall_hit if (key_left_held or key_right_held) else 0

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	# Nhường cho HUD nếu đang chờ nhập phím gán lại
	if hud_control and hud_control.is_capturing_key(): return

	var kc := (event as InputEventKey).keycode
	var pk := (event as InputEventKey).physical_keycode
	var is_left  = _key_matches(event as InputEventKey, "move_left")
	var is_right = _key_matches(event as InputEventKey, "move_right")
	var is_down  = _key_matches(event as InputEventKey, "soft_drop")



	# ── KeyUp: cập nhật trạng thái held, bỏ qua echo ──
	if not event.pressed:
		if is_left:
			key_left_held = false
			# Nếu vẫn đang giữ phải thì chuyển sang phải
			if key_right_held:
				das_direction = 1
				das_timer     = 0.0
				arr_timer     = 0.0
				if not (game_over or paused or show_settings or show_stats or is_clearing_lines):
					move_piece(1, 0)
			else:
				das_direction = 0
				das_timer     = 0.0
				arr_timer     = 0.0
		elif is_right:
			key_right_held = false
			if key_left_held:
				das_direction = -1
				das_timer     = 0.0
				arr_timer     = 0.0
				if not (game_over or paused or show_settings or show_stats or is_clearing_lines):
					move_piece(-1, 0)
			else:
				das_direction = 0
				das_timer     = 0.0
				arr_timer     = 0.0
		elif is_down:
			key_down_held = false
		return

	# Bỏ qua tất cả echo (OS key repeat) - chúng ta tự quản lý hoàn toàn
	if event.is_echo():
		return

	# ── KeyDown: xử lý một lần duy nhất ──
	if is_left:
		key_left_held = true
		if not (game_over or paused or show_settings or show_stats or is_clearing_lines):
			cur_piece_left_inputs += 1
			# Di chuyển ngay 1 ô, sau đó reset DAS để bắt đầu charge
			das_direction = -1
			das_timer     = 0.0
			arr_timer     = 0.0
			move_piece(-1, 0)
		return

	if is_right:
		key_right_held = true
		if not (game_over or paused or show_settings or show_stats or is_clearing_lines):
			cur_piece_right_inputs += 1
			das_direction = 1
			das_timer     = 0.0
			arr_timer     = 0.0
			move_piece(1, 0)
		return

	if is_down:
		key_down_held = true
		return

	# Phím hệ thống (Esc, Tab, P, R) - không bị chặn bởi game state
	if kc == KEY_ESCAPE or pk == KEY_ESCAPE:
		if not game_over:
			show_settings = not show_settings
			show_stats = false
			_notify_hud()
		return
	if kc == KEY_TAB or pk == KEY_TAB:
		if not game_over and not show_settings:
			show_stats = not show_stats
			_notify_hud()
		return

	if show_settings: return

	var ev_k := event as InputEventKey
	if kc == KEY_R or pk == KEY_R:
		reset_game()
	elif kc == KEY_P or pk == KEY_P:
		paused = not paused
		_refresh_ghost()
		_notify_hud()
	elif _key_matches(ev_k, "rotate_cw") or kc == KEY_Z or pk == KEY_Z:
		if not game_over and not paused and not show_stats and not is_clearing_lines:
			cur_piece_rot_cw_inputs += 1
			rotate_piece(1)
	elif _key_matches(ev_k, "rotate_ccw"):
		if not game_over and not paused and not show_stats and not is_clearing_lines:
			cur_piece_rot_ccw_inputs += 1
			rotate_piece(-1)
	elif _key_matches(ev_k, "rotate_180"):
		if not game_over and not paused and not show_stats and not is_clearing_lines:
			cur_piece_rot_180_inputs += 1
			rotate_piece(2)
	elif _key_matches(ev_k, "hard_drop"):
		if not game_over and not paused and not show_stats and not is_clearing_lines:
			hard_drop()
	elif _key_matches(ev_k, "hold") or kc == KEY_SHIFT or pk == KEY_SHIFT:
		if not game_over and not paused and not show_stats and not is_clearing_lines:
			hold_current_piece()


# ╔══════════════════════════════════════════════════╗
# ║             SETTINGS API                        ║
# ╚══════════════════════════════════════════════════╝
func _load_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.READ)
	if file:
		var txt = file.get_as_text()
		var json = JSON.new()
		if json.parse(txt) == OK:
			var d = json.data
			if d.has("music_vol"):   settings.music_vol   = d.music_vol
			if d.has("sfx_vol"):     settings.sfx_vol     = d.sfx_vol
			if d.has("music_on"):    settings.music_on    = d.music_on
			if d.has("start_level"): settings.start_level = int(d.start_level)
			if d.has("das_delay"):   settings.das_delay   = d.das_delay
			if d.has("arr_delay"):   settings.arr_delay   = d.arr_delay
			if d.has("theme"):       settings.theme       = d.theme
			if d.has("show_ghost"):  settings.show_ghost  = bool(d.show_ghost)
			if d.has("fall_speed_scale"): settings.fall_speed_scale = d.fall_speed_scale
			if d.has("soft_drop_speed"):  settings.soft_drop_speed  = d.soft_drop_speed
			if d.has("grid_style"):       settings.grid_style       = d.grid_style
			if d.has("dcd_delay"):        settings.dcd_delay        = d.dcd_delay
			if d.has("neon_mode"):        settings.neon_mode        = bool(d.neon_mode)
			if d.has("bindings") and d.bindings is Dictionary:
				if not settings.has("bindings"): settings["bindings"] = {}
				for k in d.bindings:
					settings["bindings"][k] = int(d.bindings[k])

func _save_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		# Cần convert int keys của bindings để JSON hóa được
		var save_data = settings.duplicate(true)
		file.store_string(JSON.stringify(save_data))

func _apply_audio_settings():
	bg_music.volume_db = linear_to_db(settings.music_vol * 0.5)
	var sfx_db = linear_to_db(settings.sfx_vol)
	sfx_move.volume_db   = sfx_db
	sfx_rotate.volume_db = sfx_db
	sfx_clear.volume_db  = sfx_db
	sfx_gameover.volume_db = sfx_db
	if settings.music_on and not bg_music.playing: bg_music.play()
	elif not settings.music_on and bg_music.playing: bg_music.stop()

func update_setting(key: String, value):
	if key == "bindings" and value is Dictionary:
		if not settings.has("bindings"): settings["bindings"] = {}
		for k in value: settings["bindings"][k] = value[k]
	else:
		settings[key] = value
	if key == "start_level":
		level = value; lines_cleared = 0
	elif key == "theme":
		apply_theme(value)
		_create_grid_lines()
	elif key == "grid_style":
		_create_grid_lines()
	elif key == "show_ghost":
		_refresh_ghost()
	elif key == "neon_mode":
		shader_mat_cache.clear()
		apply_theme(settings.get("theme", "default"))
		_create_grid_lines()
	_apply_audio_settings()
	_save_settings()
	_notify_hud()

func _play_sfx(player: AudioStreamPlayer) -> void:
	if player and settings.sfx_vol > 0:
		player.play()
