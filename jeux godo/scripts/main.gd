extends Node2D

const SCREEN_W := 600.0
const SCREEN_H := 800.0

var screen := "menu"
var best_score := 0
var current_game: Node = null

func _ready() -> void:
    get_viewport().size = Vector2(SCREEN_W, SCREEN_H)
    best_score = SaveManager.get_best_score("block_blast")
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color("#183b91"))
    if screen == "menu":
        draw_menu()
    elif screen == "games":
        draw_game_select()
    elif screen == "block_blast":
        draw_block_blast()

func draw_menu() -> void:
    draw_circle(Vector2(300, 150), 90, Color("#5dd6ff"))
    draw_string(ThemeDB.fallback_font, Vector2(0, 245), "MINI GAMES", HORIZONTAL_ALIGNMENT_CENTER, 600, 52, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(0, 290), "Des mini-jeux simples, hors ligne.", HORIZONTAL_ALIGNMENT_CENTER, 600, 22, Color("#dce9ff"))

    draw_button(Rect2(150, 370, 300, 75), "JOUER")
    draw_button(Rect2(150, 470, 300, 65), "MEILLEUR SCORE")
    draw_string(ThemeDB.fallback_font, Vector2(0, 650), "Prototype Godot • version 1.0", HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color("#c9d7ff"))

func draw_game_select() -> void:
    draw_string(ThemeDB.fallback_font, Vector2(0, 85), "CHOISIS TON JEU", HORIZONTAL_ALIGNMENT_CENTER, 600, 36, Color.WHITE)
    draw_button(Rect2(100, 160, 400, 90), "🧩  BLOCK BLAST")
    draw_string(ThemeDB.fallback_font, Vector2(0, 285), "D'autres jeux pourront être ajoutés ici.", HORIZONTAL_ALIGNMENT_CENTER, 600, 19, Color("#dce9ff"))
    draw_button(Rect2(150, 650, 300, 65), "RETOUR")

func draw_button(rect: Rect2, label: String) -> void:
    draw_style_box(make_box(Color("#ffd84d"), 18, Color.WHITE, 3), rect)
    draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.66), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 28, Color("#202020"))

func make_box(bg: Color, radius: float, border: Color, width: int) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = bg
    box.border_color = border
    box.set_border_width_all(width)
    box.corner_radius_top_left = radius
    box.corner_radius_top_right = radius
    box.corner_radius_bottom_left = radius
    box.corner_radius_bottom_right = radius
    return box

func draw_block_blast() -> void:
    if current_game:
        current_game.queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            handle_press(event.position)
        else:
            handle_release(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            handle_press(event.position)
        else:
            handle_release(event.position)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        go_back()

func handle_press(pos: Vector2) -> void:
    if screen == "menu":
        if Rect2(150, 370, 300, 75).has_point(pos):
            screen = "games"
        elif Rect2(150, 470, 300, 65).has_point(pos):
            best_score = SaveManager.get_best_score("block_blast")
    elif screen == "games":
        if Rect2(100, 160, 400, 90).has_point(pos):
            start_block_blast()
        elif Rect2(150, 650, 300, 65).has_point(pos):
            screen = "menu"
    elif screen == "block_blast":
        if current_game:
            current_game.handle_press(pos)
    queue_redraw()

func handle_release(pos: Vector2) -> void:
    if screen == "block_blast" and current_game:
        current_game.handle_release(pos)
    queue_redraw()

func start_block_blast() -> void:
    screen = "block_blast"
    if current_game:
        current_game.queue_free()
    current_game = preload("res://games/block_blast/block_blast.gd").new()
    add_child(current_game)
    current_game.finished.connect(_on_block_blast_finished)
    current_game.start_game()
    queue_redraw()

func _on_block_blast_finished() -> void:
    best_score = SaveManager.get_best_score("block_blast")
    screen = "games"
    if current_game:
        current_game.queue_free()
        current_game = null
    queue_redraw()

func go_back() -> void:
    if screen == "block_blast":
        _on_block_blast_finished()
    elif screen == "games":
        screen = "menu"
        queue_redraw()
