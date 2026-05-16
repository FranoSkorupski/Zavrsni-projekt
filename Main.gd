extends Node

# ── Podaci igre ──────────────────────────
var player
var enemy
var game_over          = false
var player_turn        = true
var waiting_for_input  = false
var player_username    = "Igrac"
var player_email       = ""
var first_card_played  = false
var current_round      = 1
var max_rounds         = 3
var player_max_hp      = 20
var enemy_name         = ""
var enemy_difficulty   = ""
var reward_chosen = false
var player_max_energy = 3

# ── Timer ─────────────────────────────────
var elapsed_seconds    = 0
var timer_label        : Label
var game_timer         : Timer

# ── GUI nodovi ───────────────────────────
var menu_window        : Control
var about_window       : Control
var game_window        : Control
var reward_window      : Control
var end_window         : Control
var status_label       : Label
var hp_label           : Label
var energy_label       : Label
var log_label          : Label
var hand_label         : Label
var card_container     : VBoxContainer
var end_turn_btn       : Button
var round_label        : Label
var enemy_name_label   : Label
var enemy_diff_label   : Label
var end_msg_label  : Label
var time_msg_label : Label
var reward_hp_btn     : Button
var reward_energy_btn : Button

# ── Protivnici po roundu ──────────────────
var round_enemies = {
    1: {"naziv": "Goblin", "difficulty": "easy"},
    2: {"naziv": "Vitez",  "difficulty": "medium"},
    3: {"naziv": "Zmaj",   "difficulty": "hard"},
}


func _ready():
    _copy_db()
    _build_menu()
    _build_about()
    _build_game()
    _build_reward()
    _build_end_screen()

    menu_window.visible   = true
    about_window.visible  = false
    game_window.visible   = false
    reward_window.visible = false
    end_window.visible    = false


# ─────────────────────────────────────────
#  KOPIRANJE BAZE
# ─────────────────────────────────────────

func _copy_db():
    if not FileAccess.file_exists("user://game.db"):
        DirAccess.copy_absolute("res://game.db", "user://game.db")


# ─────────────────────────────────────────
#  GRADNJA GUI-A
# ─────────────────────────────────────────

func _build_menu():
    menu_window = Control.new()
    menu_window.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(menu_window)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.10, 0.12, 0.18)
    menu_window.add_child(bg)

    # Gumb za izlaz gore desno
    # Umjesto korištenja set_anchor_and_offset, koristi Control kao wrapper
    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    menu_window.add_child(center)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20)
    center.add_child(vbox)

    var title = Label.new()
    title.text = "Kartaska Igra"
    title.add_theme_font_size_override("font_size", 36)
    title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var subtitle = Label.new()
    subtitle.text = "Inspirirano igrom Slay the Spire"
    subtitle.add_theme_font_size_override("font_size", 14)
    subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(subtitle)

    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 20)
    vbox.add_child(spacer)

    var play_btn  = _make_button("Pokreni igru", Color(0.20, 0.55, 0.25))
    var about_btn = _make_button("O igri",       Color(0.20, 0.35, 0.60))
    play_btn.pressed.connect(_on_play_pressed)
    about_btn.pressed.connect(_on_about_pressed)
    vbox.add_child(play_btn)
    vbox.add_child(about_btn)


func _build_about():
    about_window = Control.new()
    about_window.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(about_window)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.08, 0.10, 0.16)
    about_window.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    about_window.add_child(center)

    var panel = _make_panel_container(Color(0.14, 0.17, 0.26))
    panel.custom_minimum_size = Vector2(480, 320)
    center.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = "O igri"
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var info = Label.new()
    info.text = "Godot kartaska igra\ninspirirana Slay the Spire.\n\nVerzija 1.0\n\nCilj igre je poraziti protivnika\nodigravanjem karata iz svog spila.\nSvaka karta trosi energiju.\nIgrac i protivnik naizmjenicno\nodigravaju poteze."
    info.add_theme_font_size_override("font_size", 15)
    info.add_theme_color_override("font_color", Color(0.88, 0.88, 0.88))
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(info)

    var close_btn = _make_button("Povratak na glavni izbornik", Color(0.55, 0.20, 0.20))
    close_btn.pressed.connect(_on_about_close)
    vbox.add_child(close_btn)


func _build_game():
    game_window = Control.new()
    game_window.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(game_window)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.10, 0.12, 0.18)
    game_window.add_child(bg)

    # ── Timer gore desno ──
    timer_label = Label.new()
    timer_label.text = "00:00"
    timer_label.add_theme_font_size_override("font_size", 18)
    timer_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    timer_label.set_anchor_and_offset(SIDE_RIGHT,  1.0, -16)
    timer_label.set_anchor_and_offset(SIDE_TOP,    0.0,  12)
    timer_label.set_anchor_and_offset(SIDE_LEFT,   1.0, -120)
    timer_label.set_anchor_and_offset(SIDE_BOTTOM, 0.0,  40)
    game_window.add_child(timer_label)

    # ── Round i protivnik info gore lijevo ──
    var top_left = VBoxContainer.new()
    top_left.set_anchor_and_offset(SIDE_LEFT,   0.0,  16)
    top_left.set_anchor_and_offset(SIDE_TOP,    0.0,  12)
    top_left.set_anchor_and_offset(SIDE_RIGHT,  0.5,   0)
    top_left.set_anchor_and_offset(SIDE_BOTTOM, 0.0,  70)
    game_window.add_child(top_left)

    round_label = Label.new()
    round_label.add_theme_font_size_override("font_size", 15)
    round_label.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80))
    top_left.add_child(round_label)

    var enemy_hbox = HBoxContainer.new()
    enemy_hbox.add_theme_constant_override("separation", 8)
    top_left.add_child(enemy_hbox)

    enemy_name_label = Label.new()
    enemy_name_label.add_theme_font_size_override("font_size", 15)
    enemy_name_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    enemy_hbox.add_child(enemy_name_label)

    enemy_diff_label = Label.new()
    enemy_diff_label.add_theme_font_size_override("font_size", 15)
    enemy_hbox.add_child(enemy_diff_label)

    # ── Glavni sadržaj ──
    var margin = MarginContainer.new()
    margin.set_anchor_and_offset(SIDE_LEFT,   0.0,  0)
    margin.set_anchor_and_offset(SIDE_TOP,    0.0, 70)
    margin.set_anchor_and_offset(SIDE_RIGHT,  1.0,  0)
    margin.set_anchor_and_offset(SIDE_BOTTOM, 1.0,  0)
    margin.add_theme_constant_override("margin_left",   40)
    margin.add_theme_constant_override("margin_right",  40)
    margin.add_theme_constant_override("margin_top",    10)
    margin.add_theme_constant_override("margin_bottom", 30)
    game_window.add_child(margin)

    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 30)
    margin.add_child(hbox)

    # Lijevi panel
    var left = _make_panel_container(Color(0.14, 0.17, 0.26))
    left.size_flags_horizontal    = Control.SIZE_EXPAND_FILL
    left.size_flags_stretch_ratio = 1.2
    hbox.add_child(left)

    var left_vbox = VBoxContainer.new()
    left_vbox.add_theme_constant_override("separation", 12)
    left.add_child(left_vbox)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    left_vbox.add_child(status_label)

    hp_label = Label.new()
    hp_label.add_theme_font_size_override("font_size", 15)
    hp_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
    left_vbox.add_child(hp_label)

    energy_label = Label.new()
    energy_label.add_theme_font_size_override("font_size", 15)
    energy_label.add_theme_color_override("font_color", Color(0.40, 0.80, 1.00))
    left_vbox.add_child(energy_label)

    left_vbox.add_child(HSeparator.new())

    var log_title = Label.new()
    log_title.text = "Dnevnik poteza:"
    log_title.add_theme_font_size_override("font_size", 13)
    log_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
    left_vbox.add_child(log_title)

    log_label = Label.new()
    log_label.text = ""
    log_label.add_theme_font_size_override("font_size", 13)
    log_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    left_vbox.add_child(log_label)

    # Desni panel
    var right = _make_panel_container(Color(0.12, 0.15, 0.22))
    right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(right)

    var right_vbox = VBoxContainer.new()
    right_vbox.add_theme_constant_override("separation", 10)
    right.add_child(right_vbox)

    hand_label = Label.new()
    hand_label.text = "Tvoje karte u ruci:"
    hand_label.add_theme_font_size_override("font_size", 16)
    hand_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    right_vbox.add_child(hand_label)

    var scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right_vbox.add_child(scroll)

    card_container = VBoxContainer.new()
    card_container.add_theme_constant_override("separation", 8)
    card_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(card_container)

    end_turn_btn = _make_button("Završi potez", Color(0.55, 0.25, 0.10))
    end_turn_btn.pressed.connect(_on_end_turn_pressed)
    right_vbox.add_child(end_turn_btn)


func _build_reward():
    reward_window = Control.new()
    reward_window.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(reward_window)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.05, 0.07, 0.12, 0.95)
    reward_window.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    reward_window.add_child(center)

    var panel = _make_panel_container(Color(0.14, 0.18, 0.28))
    panel.custom_minimum_size = Vector2(460, 360)
    center.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 18)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = "Pobjeda! Odaberi nagradu:"
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var desc = Label.new()
    desc.text = "Odaberi JEDNU nagradu za sljedeci round:"
    desc.add_theme_font_size_override("font_size", 14)
    desc.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80))
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(desc)

    vbox.add_child(HSeparator.new())

    reward_hp_btn     = _make_button("+10 Maksimalnog HP-a",    Color(0.60, 0.20, 0.20))
    reward_energy_btn = _make_button("+1 Maksimalna Energija",  Color(0.20, 0.45, 0.55))
    reward_hp_btn.custom_minimum_size     = Vector2(0, 64)
    reward_energy_btn.custom_minimum_size = Vector2(0, 64)
    reward_hp_btn.pressed.connect(_on_reward_hp)
    reward_energy_btn.pressed.connect(_on_reward_energy)
    vbox.add_child(reward_hp_btn)
    vbox.add_child(reward_energy_btn)

    var next_btn = _make_button("Nastavi na sljedeci round ->", Color(0.20, 0.40, 0.60))
    next_btn.pressed.connect(_on_next_round)
    vbox.add_child(next_btn)


func _build_end_screen():
    end_window = Control.new()
    end_window.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(end_window)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.05, 0.05, 0.10)
    end_window.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    end_window.add_child(center)

    var panel = _make_panel_container(Color(0.12, 0.15, 0.22))
    panel.custom_minimum_size = Vector2(480, 340)
    center.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20)
    panel.add_child(vbox)

    # Direktna referenca umjesto get_node()
    end_msg_label = Label.new()
    end_msg_label.add_theme_font_size_override("font_size", 26)
    end_msg_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    end_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    end_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(end_msg_label)

    time_msg_label = Label.new()
    time_msg_label.add_theme_font_size_override("font_size", 16)
    time_msg_label.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80))
    time_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(time_msg_label)

    vbox.add_child(HSeparator.new())

    var restart_btn = _make_button("Igraj ponovo", Color(0.20, 0.55, 0.25))
    var quit_btn    = _make_button("Izlaz iz igre", Color(0.50, 0.15, 0.15))
    restart_btn.pressed.connect(_on_restart)
    quit_btn.pressed.connect(func(): get_tree().quit())
    vbox.add_child(restart_btn)
    vbox.add_child(quit_btn)


# ─────────────────────────────────────────
#  HELPERI
# ─────────────────────────────────────────

func _make_button(text: String, col: Color) -> Button:
    var btn = Button.new()
    btn.text = text
    btn.custom_minimum_size = Vector2(260, 48)
    btn.add_theme_font_size_override("font_size", 15)
    var normal = StyleBoxFlat.new()
    normal.bg_color = col
    normal.set_corner_radius_all(6)
    btn.add_theme_stylebox_override("normal", normal)
    var hover = StyleBoxFlat.new()
    hover.bg_color = col.lightened(0.15)
    hover.set_corner_radius_all(6)
    btn.add_theme_stylebox_override("hover", hover)
    var pressed_style = StyleBoxFlat.new()
    pressed_style.bg_color = col.darkened(0.15)
    pressed_style.set_corner_radius_all(6)
    btn.add_theme_stylebox_override("pressed", pressed_style)
    btn.add_theme_color_override("font_color", Color.WHITE)
    return btn


func _make_panel_container(col: Color) -> PanelContainer:
    var panel = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = col
    style.set_corner_radius_all(8)
    style.set_content_margin_all(16)
    panel.add_theme_stylebox_override("panel", style)
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    return panel


# ─────────────────────────────────────────
#  TIMER
# ─────────────────────────────────────────

func _start_timer():
    elapsed_seconds = 0
    if game_timer:
        game_timer.queue_free()
    game_timer = Timer.new()
    game_timer.wait_time = 1.0
    game_timer.autostart = true
    game_timer.timeout.connect(_on_timer_tick)
    add_child(game_timer)

func _on_timer_tick():
    elapsed_seconds += 1
    var mins = elapsed_seconds / 60
    var secs = elapsed_seconds % 60
    timer_label.text = "%02d:%02d" % [mins, secs]

func _stop_timer():
    if game_timer:
        game_timer.stop()

func _format_time() -> String:
    var mins = elapsed_seconds / 60
    var secs = elapsed_seconds % 60
    return "%02d:%02d" % [mins, secs]


# ─────────────────────────────────────────
#  MENU GUMBI
# ─────────────────────────────────────────

func _on_play_pressed():
    menu_window.visible = false
    game_window.visible = true
    current_round       = 1
    player_max_hp       = 20
    _start_timer()
    start_game()

func _on_about_pressed():
    menu_window.visible  = false
    about_window.visible = true

func _on_about_close():
    about_window.visible = false
    menu_window.visible  = true


# ─────────────────────────────────────────
#  POKRETANJE IGRE / ROUNDA
# ─────────────────────────────────────────

func start_game():
    player            = Player.new()
    enemy             = Enemy.new()
    game_over         = false
    first_card_played = false
    player.hp         = player_max_hp

    load_player_from_database()
    load_cards_for_round()
    load_enemy_for_round()

    for i in range(3):
        player.draw_card()
        enemy.draw_card()

    # Postavi round i enemy info
    round_label.text = "Round " + str(current_round) + " / " + str(max_rounds)
    enemy_name_label.text = enemy_name + "  "
    enemy_diff_label.text = enemy_difficulty.to_upper()
    match enemy_difficulty:
        "easy":   enemy_diff_label.add_theme_color_override("font_color", Color(0.20, 0.85, 0.20))
        "medium": enemy_diff_label.add_theme_color_override("font_color", Color(0.30, 0.60, 1.00))
        "hard":   enemy_diff_label.add_theme_color_override("font_color", Color(1.00, 0.25, 0.25))

    log_label.text = ""
    add_log("Dobrodosao, " + player_username + "! Round " + str(current_round) + " pocinje.")
    update_hud()
    player_phase()


# ─────────────────────────────────────────
#  HUD
# ─────────────────────────────────────────

func update_hud():
    hp_label.text     = "Player HP: " + str(player.hp) + " / " + str(player_max_hp) + \
                        "     |     Enemy HP: " + str(enemy.hp)
    energy_label.text = "Energija: " + str(player.energy)

func add_log(text: String):
    if first_card_played and log_label.text.contains("pocinje"):
        log_label.text = ""
    var lines = log_label.text.split("\n")
    lines.insert(0, text)
    if lines.size() > 7:
        lines.resize(7)
    log_label.text = "\n".join(lines)

func set_status(text: String):
    status_label.text = text

func refresh_hand():
    for child in card_container.get_children():
        child.queue_free()

    if player.hand.size() == 0:
        hand_label.text = "Nemas karata u ruci."
        return

    hand_label.text = "Tvoje karte u ruci:"

    var can_play_any = false
    for card in player.hand:
        if card.cost <= player.energy:
            can_play_any = true
            break

    for i in range(player.hand.size()):
        var card = player.hand[i]
        var affordable = card.cost <= player.energy
        var btn = _make_button(
            str(i + 1) + ".  " + card.naziv +
            "   ATK: " + str(card.attack) +
            "   COST: " + str(card.cost),
            Color(0.22, 0.40, 0.55) if affordable else Color(0.30, 0.30, 0.30)
        )
        btn.disabled = not affordable
        btn.custom_minimum_size = Vector2(0, 48)
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var idx = i
        btn.pressed.connect(func(): _on_card_button_pressed(idx))
        card_container.add_child(btn)

    end_turn_btn.disabled = false
    return can_play_any


# ─────────────────────────────────────────
#  PLAYER FAZA
# ─────────────────────────────────────────

func player_phase():
    player.energy = player_max_energy
    player.draw_card()
    player_turn   = true

    set_status("Tvoj potez, " + player_username + "!")
    update_hud()

    var can_play = refresh_hand()

    if player.hand.size() == 0:
        add_log("Nemas karata u ruci.")
        await get_tree().create_timer(0.8).timeout
        end_player_turn()
        return

    # Automatski završi potez ako nijednu kartu ne može platiti
    if not can_play:
        add_log("Ne mozes platiti nijednu kartu — potez automatski prelazi.")
        waiting_for_input = false
        await get_tree().create_timer(1.0).timeout
        end_player_turn()
        return

    waiting_for_input = true


func _on_card_button_pressed(index: int):
    if not waiting_for_input or game_over:
        return

    var card = player.hand[index]
    if card.cost > player.energy:
        add_log("Nedovoljno energije za: " + card.naziv)
        return

    if not first_card_played:
        first_card_played = true
        log_label.text    = ""

    player.hand.remove_at(index)
    player.energy -= card.cost
    player_attack(card)

    add_log(player_username + " igra: " + card.naziv +
            "  [ATK: " + str(card.attack) + "  COST: " + str(card.cost) + "]")
    update_hud()

    if await check_game_over():
        return

    # Provjeri može li igrati još
    var can_play = false
    for c in player.hand:
        if c.cost <= player.energy:
            can_play = true
            break

    if player.energy == 0:
        add_log("Nemas vise energije — potez se automatski završava.")
        waiting_for_input = false
        refresh_hand()
        await get_tree().create_timer(0.8).timeout
        end_player_turn()
        return

    if player.hand.size() == 0:
        add_log("Nemas vise karata.")
        waiting_for_input = false
        await get_tree().create_timer(0.8).timeout
        end_player_turn()
        return

    if not can_play:
        add_log("Ne mozes platiti nijednu preostalu kartu — potez automatski prelazi.")
        waiting_for_input = false
        refresh_hand()
        await get_tree().create_timer(1.0).timeout
        end_player_turn()
        return

    refresh_hand()


func _on_end_turn_pressed():
    if game_over or not waiting_for_input:
        return
    waiting_for_input = false
    add_log(player_username + " zavrsava potez.")
    end_player_turn()


func end_player_turn():
    end_turn_btn.disabled = true
    for child in card_container.get_children():
        child.disabled = true
    enemy_phase()


# ─────────────────────────────────────────
#  ENEMY FAZA
# ─────────────────────────────────────────

func enemy_phase():
    set_status("Protivnikov potez...")
    player_turn  = false
    enemy.energy = 3
    # Energija ovisno o protivniku
    match enemy_name:
        "Zmaj":  enemy.energy = 3
        _:       enemy.energy = 3
    enemy.draw_card()
    update_hud()

    await get_tree().create_timer(0.8).timeout

    var played_any = true
    while played_any and enemy.hand.size() > 0 and enemy.energy > 0:
        played_any = false
        for i in range(enemy.hand.size()):
            var card = enemy.hand[i]
            if card.cost <= enemy.energy:
                enemy.hand.remove_at(i)
                enemy.energy -= card.cost
                enemy_attack(card)
                add_log(enemy_name + " igra: " + card.naziv +
                        "  [ATK: " + str(card.attack) + "  COST: " + str(card.cost) + "]")
                update_hud()
                played_any = true
                await get_tree().create_timer(0.6).timeout
                break

    if await check_game_over():
        return

    player_phase()


# ─────────────────────────────────────────
#  NAPAD
# ─────────────────────────────────────────

func player_attack(card: Card):
    enemy.hp = max(0, enemy.hp - card.attack)

func enemy_attack(card: Card):
    player.hp = max(0, player.hp - card.attack)


# ─────────────────────────────────────────
#  KRAJ IGRE / ROUNDA
# ─────────────────────────────────────────

func check_game_over() -> bool:
    if enemy.hp <= 0:
        game_over         = true
        waiting_for_input = false
        end_turn_btn.disabled = true

        if current_round >= max_rounds:
            # Pobijedio je sve — kraj igre
            _show_end_screen(true)
        else:
            # Pobijedio je ovaj round — nagrada
            set_status("Pobijedio si " + enemy_name + "a!")
            add_log("POBJEDA u roundu " + str(current_round) + "!")
            await get_tree().create_timer(1.0).timeout
            reward_window.visible = true
        return true

    elif player.hp <= 0:
        game_over         = true
        waiting_for_input = false
        end_turn_btn.disabled = true
        _show_end_screen(false)
        return true

    return false


func _show_end_screen(won: bool):
    _stop_timer()
    var time_str = _format_time()

    if won:
        end_msg_label.text = "Pobijedio si!\nČestitamo, " + player_username + "!"
        end_msg_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
    else:
        end_msg_label.text = "Izgubio si.\nViše sreće drugi put!"
        end_msg_label.add_theme_color_override("font_color", Color(0.90, 0.30, 0.30))

    time_msg_label.text = "Ukupno vrijeme igranja: " + time_str

    game_window.visible   = false
    reward_window.visible = false
    end_window.visible    = true


func _find_label(node: Node, search_name: String, result: Label):
    if node.name == search_name and node is Label:
        result = node
    for child in node.get_children():
        _find_label(child, search_name, result)


# ─────────────────────────────────────────
#  REWARD GUMBI
# ─────────────────────────────────────────

func _on_reward_hp():
    if reward_chosen:
        return
    reward_chosen = true
    player_max_hp += 10
    add_log("Nagrada: +10 max HP! (novi max: " + str(player_max_hp) + ")")
    _disable_reward_buttons()

func _on_reward_energy():
    if reward_chosen:
        return
    reward_chosen     = true
    player_max_energy += 1
    add_log("Nagrada: +1 max energija! (novi max: " + str(player_max_energy) + ")")
    _disable_reward_buttons()

func _disable_reward_buttons():
    reward_hp_btn.disabled     = true
    reward_energy_btn.disabled = true
    # Zasivi boju da je vizualno jasno da su onemoguceni
    var grey = StyleBoxFlat.new()
    grey.bg_color = Color(0.30, 0.30, 0.30)
    grey.set_corner_radius_all(6)
    reward_hp_btn.add_theme_stylebox_override("normal",   grey)
    reward_hp_btn.add_theme_stylebox_override("hover",    grey)
    reward_hp_btn.add_theme_stylebox_override("disabled", grey)
    var grey2 = StyleBoxFlat.new()
    grey2.bg_color = Color(0.30, 0.30, 0.30)
    grey2.set_corner_radius_all(6)
    reward_energy_btn.add_theme_stylebox_override("normal",   grey2)
    reward_energy_btn.add_theme_stylebox_override("hover",    grey2)
    reward_energy_btn.add_theme_stylebox_override("disabled", grey2)

# Također u _on_next_round() resetiraj gumbe za sljedeci round:
func _on_next_round():
    reward_window.visible = false
    reward_chosen         = false
    current_round        += 1
    # Resetiraj izgled gumba za sljedeci round
    reward_hp_btn.disabled     = false
    reward_energy_btn.disabled = false
    var hp_style = StyleBoxFlat.new()
    hp_style.bg_color = Color(0.60, 0.20, 0.20)
    hp_style.set_corner_radius_all(6)
    reward_hp_btn.add_theme_stylebox_override("normal", hp_style)
    reward_hp_btn.add_theme_stylebox_override("hover",  hp_style.duplicate())
    var en_style = StyleBoxFlat.new()
    en_style.bg_color = Color(0.20, 0.45, 0.55)
    en_style.set_corner_radius_all(6)
    reward_energy_btn.add_theme_stylebox_override("normal", en_style)
    reward_energy_btn.add_theme_stylebox_override("hover",  en_style.duplicate())
    start_game()


func _on_restart():
    end_window.visible  = false
    game_window.visible = true
    current_round       = 1
    player_max_hp       = 20
    player_max_energy   = 3
    elapsed_seconds     = 0
    timer_label.text    = "00:00"
    _start_timer()
    start_game()


# ─────────────────────────────────────────
#  BAZA PODATAKA
# ─────────────────────────────────────────

func load_player_from_database():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()
    var result = db.select_rows("korisnik", "", ["id", "username", "email"])
    if result.size() > 0:
        player_username = result[0]["username"]
        player_email    = result[0]["email"]
    db.close_db()


func load_cards_for_round():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()

    # Pronađi deck za korisnika
    var deck_result = db.select_rows(
        "deck", "vlasnik_tip = 'korisnik' AND korisnik_id = 1", ["id"])

    if deck_result.size() == 0:
        db.close_db()
        return

    var deck_id = deck_result[0]["id"]
    var dk      = db.select_rows(
        "deck_karta", "deck_id = " + str(deck_id), ["karta_id", "kolicina"])

    for dk_row in dk:
        var rows = db.select_rows(
            "karta", "id = " + str(dk_row["karta_id"]),
            ["id", "naziv", "attack", "cost"])
        if rows.size() > 0:
            for j in range(dk_row["kolicina"]):
                var card    = Card.new()
                card.id     = rows[0]["id"]
                card.naziv  = rows[0]["naziv"]
                card.attack = rows[0]["attack"]
                card.cost   = rows[0]["cost"]
                player.deck.append(card)

    db.close_db()


func load_enemy_for_round():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()

    var round_info = round_enemies[current_round]
    enemy_name       = round_info["naziv"]
    enemy_difficulty = round_info["difficulty"]

    # Učitaj protivnika iz baze prema nazivu
    var result = db.select_rows(
        "protivnik",
        "naziv = '" + enemy_name + "'",
        ["id", "naziv", "hp", "difficulty"])

    var enemy_id = 1
    if result.size() > 0:
        enemy.hp         = result[0]["hp"]
        enemy.difficulty = result[0]["difficulty"]
        enemy_id         = result[0]["id"]

    # Pronađi enemy deck prema protivnik_id
    var deck_result = db.select_rows(
        "deck",
        "vlasnik_tip = 'protivnik' AND protivnik_id = " + str(enemy_id),
        ["id"])

    if deck_result.size() == 0:
        db.close_db()
        return

    var deck_id = deck_result[0]["id"]
    var dk      = db.select_rows(
        "deck_karta", "deck_id = " + str(deck_id), ["karta_id", "kolicina"])

    for dk_row in dk:
        var rows = db.select_rows(
            "karta", "id = " + str(dk_row["karta_id"]),
            ["id", "naziv", "attack", "cost"])
        if rows.size() > 0:
            for j in range(dk_row["kolicina"]):
                var card    = Card.new()
                card.id     = rows[0]["id"]
                card.naziv  = rows[0]["naziv"]
                card.attack = rows[0]["attack"]
                card.cost   = rows[0]["cost"]
                enemy.deck.append(card)

    db.close_db()
