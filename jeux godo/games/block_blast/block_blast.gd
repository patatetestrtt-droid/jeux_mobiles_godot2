extends Node2D

signal finished

const GRID_SIZE := 8
const CELL := 55.0
const GRID_POS := Vector2(80, 120)
const TRAY_Y := 600.0
const PIECE_CELL := 40.0

var grid: Array = []
var pieces: Array = []
var selected_piece: Dictionary = {}
var dragging := false
var drag_pos := Vector2.ZERO
var score := 0
var game_over := false
var rng := RandomNumberGenerator.new()

var shapes := [
	[[1,1],[1,1]],
	[[1,1,1],[1,1,1],[1,1,1]],
	[[1,1,1]],
	[[1],[1],[1]],
	[[1,0],[1,0],[1,1]],
	[[0,1],[0,1],[1,1]],
	[[1,1,1],[0,1,0]],
	[[1,1,0],[0,1,1]],
	[[1]]
]

var colors := [
	Color("#ff5c7a"), Color("#5cd6ff"), Color("#ffd84d"),
	Color("#8cff66"), Color("#b77cff"), Color("#ff9f43")
]

func _ready() -> void:
	rng.randomize()

func start_game() -> void:
	grid.clear()
	for y in GRID_SIZE:
		var row := []
		for x in GRID_SIZE:
			row.append(null)
		grid.append(row)

	pieces.clear()
	pieces.append(make_piece(0))
	pieces.append(make_piece(1))
	selected_piece = {}
	dragging = false
	score = 0
	game_over = false
	queue_redraw()

func make_piece(zone: int) -> Dictionary:
	return {
		"shape": shapes[rng.randi_range(0, shapes.size() - 1)],
		"color": colors[rng.randi_range(0, colors.size() - 1)],
		"zone": zone
	}

func _draw() -> void:
	draw_rect(Rect2(0, 0, 600, 800), Color("#184ab8"))
	draw_string(ThemeDB.fallback_font, Vector2(0, 45), "BLOCK BLAST", HORIZONTAL_ALIGNMENT_CENTER, 600, 32, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(0, 82), "SCORE  " + str(score), HORIZONTAL_ALIGNMENT_CENTER, 600, 24, Color.WHITE)

	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var cell_rect := Rect2(GRID_POS + Vector2(x * CELL, y * CELL), Vector2(CELL, CELL))
			var c = Color("#e9eef8") if grid[y][x] == null else grid[y][x]
			draw_style_box(cell_box(c), cell_rect)

	draw_string(ThemeDB.fallback_font, Vector2(0, 570), "FAIS GLISSER UNE PIÈCE", HORIZONTAL_ALIGNMENT_CENTER, 600, 19, Color("#dce9ff"))

	for zone in 2:
		for y in 3:
			for x in 3:
				var r := Rect2(Vector2(110 + zone * 245 + x * PIECE_CELL, TRAY_Y + y * PIECE_CELL), Vector2(PIECE_CELL, PIECE_CELL))
				draw_style_box(cell_box(Color("#e9eef8")), r)

	for p in pieces:
		if not dragging or p != selected_piece:
			draw_piece(p, Vector2(110 + p.zone * 245, TRAY_Y))

	if dragging and not selected_piece.is_empty():
		var pos := grid_position_from_pointer(drag_pos)
		if pos.x >= 0:
			draw_preview(selected_piece, pos)
		draw_piece(selected_piece, drag_pos - Vector2(20, 20))

	if game_over:
		draw_rect(Rect2(50, 260, 500, 250), Color(0.05,0.08,0.18,0.95))
		draw_string(ThemeDB.fallback_font, Vector2(0, 335), "GAME OVER", HORIZONTAL_ALIGNMENT_CENTER, 600, 46, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(0, 390), "Score : " + str(score), HORIZONTAL_ALIGNMENT_CENTER, 600, 26, Color("#dce9ff"))
		draw_button(Rect2(150, 420, 300, 60), "REJOUER")

func cell_box(color: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.border_color = Color.WHITE
	b.set_border_width_all(2)
	b.corner_radius_top_left = 7
	b.corner_radius_top_right = 7
	b.corner_radius_bottom_left = 7
	b.corner_radius_bottom_right = 7
	return b

func draw_button(rect: Rect2, label: String) -> void:
	var b := StyleBoxFlat.new()
	b.bg_color = Color("#ffd84d")
	b.border_color = Color.WHITE
	b.set_border_width_all(3)
	b.set_corner_radius_all(15)
	draw_style_box(b, rect)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + 39), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 25, Color("#202020"))

func draw_piece(piece: Dictionary, origin: Vector2) -> void:
	var shape: Array = piece.shape
	for y in shape.size():
		for x in shape[y].size():
			if shape[y][x] == 1:
				draw_style_box(cell_box(piece.color), Rect2(origin + Vector2(x * PIECE_CELL, y * PIECE_CELL), Vector2(PIECE_CELL, PIECE_CELL)))

func draw_preview(piece: Dictionary, pos: Vector2) -> void:
	var valid := can_place(piece, int(pos.x), int(pos.y))
	var c := Color(piece.color, 0.35) if valid else Color(1, 0.2, 0.2, 0.35)
	var shape: Array = piece.shape
	for y in shape.size():
		for x in shape[y].size():
			if shape[y][x] == 1:
				var gx: int = int(pos.x) + int(x)
				var gy: int = int(pos.y) + int(y)
				if gx >= 0 and gx < GRID_SIZE and gy >= 0 and gy < GRID_SIZE:
					draw_rect(Rect2(GRID_POS + Vector2(gx * CELL, gy * CELL), Vector2(CELL, CELL)), c)

func handle_press(pos: Vector2) -> void:
	if game_over:
		if Rect2(150, 420, 300, 60).has_point(pos):
			start_game()
		return

	if pos.y >= TRAY_Y and pos.y <= TRAY_Y + 120:
		for p in pieces:
			var origin := Vector2(110 + p.zone * 245, TRAY_Y)
			var size := Vector2(p.shape[0].size() * PIECE_CELL, p.shape.size() * PIECE_CELL)
			if Rect2(origin, size).has_point(pos):
				selected_piece = p
				dragging = true
				drag_pos = pos
				queue_redraw()
				return

func handle_release(pos: Vector2) -> void:
	if not dragging or selected_piece.is_empty():
		return

	drag_pos = pos
	var grid_pos := grid_position_from_pointer(pos)
	if grid_pos.x >= 0 and can_place(selected_piece, int(grid_pos.x), int(grid_pos.y)):
		place_piece(selected_piece, int(grid_pos.x), int(grid_pos.y))
		clear_completed()
		pieces.erase(selected_piece)
		pieces.append(make_piece(int(selected_piece.zone)))
		if is_game_over():
			end_game()

	dragging = false
	selected_piece = {}
	queue_redraw()

func grid_position_from_pointer(pos: Vector2) -> Vector2:
	var gx: int = int(round((pos.x - GRID_POS.x - CELL / 2.0) / CELL))
	var gy: int = int(round((pos.y - GRID_POS.y - CELL / 2.0) / CELL))
	if gx < -5 or gx > GRID_SIZE or gy < -5 or gy > GRID_SIZE:
		return Vector2(-99, -99)
	return Vector2(gx, gy)

func can_place(piece: Dictionary, gx: int, gy: int) -> bool:
	var shape: Array = piece.shape
	for y in shape.size():
		for x in shape[y].size():
			if shape[y][x] == 1:
				var xx: int = gx + int(x)
				var yy: int = gy + int(y)
				if xx < 0 or xx >= GRID_SIZE or yy < 0 or yy >= GRID_SIZE:
					return false
				if grid[yy][xx] != null:
					return false
	return true

func place_piece(piece: Dictionary, gx: int, gy: int) -> void:
	for y in piece.shape.size():
		for x in piece.shape[y].size():
			if piece.shape[y][x] == 1:
				grid[gy + int(y)][gx + int(x)] = piece.color
				score += 1

func clear_completed() -> void:
	var remove := {}
	var lines := 0
	var squares := 0

	for y in GRID_SIZE:
		var full := true
		for x in GRID_SIZE:
			if grid[y][x] == null:
				full = false
				break
		if full:
			lines += 1
			for x in GRID_SIZE:
				remove[str(x) + ":" + str(y)] = true

	for x in GRID_SIZE:
		var full := true
		for y in GRID_SIZE:
			if grid[y][x] == null:
				full = false
				break
		if full:
			lines += 1
			for y in GRID_SIZE:
				remove[str(x) + ":" + str(y)] = true

	for sy in range(0, GRID_SIZE - 4):
		for sx in range(0, GRID_SIZE - 4):
			var full := true
			for y in 5:
				for x in 5:
					if grid[sy + y][sx + x] == null:
						full = false
						break
				if not full:
					break
			if full:
				squares += 1
				for y in 5:
					for x in 5:
						remove[str(sx + x) + ":" + str(sy + y)] = true

	score += lines * 100 + squares * 800

	for key in remove.keys():
		var parts: PackedStringArray = key.split(":")
		grid[int(parts[1])][int(parts[0])] = null

func is_game_over() -> bool:
	for p in pieces:
		for y in GRID_SIZE:
			for x in GRID_SIZE:
				if can_place(p, x, y):
					return false
	return true

func end_game() -> void:
	game_over = true
	var best := SaveManager.get_best_score("block_blast")
	if score > best:
		SaveManager.set_best_score("block_blast", score)
	queue_redraw()
