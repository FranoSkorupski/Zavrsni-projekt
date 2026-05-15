# Main.gd
extends Node

var player
var enemy
var game_over = false
var player_turn = true
var waiting_for_input = false
var player_input_received = -1

func _ready():
    player = Player.new()
    enemy = Enemy.new()
    
    load_cards_from_database()
    load_enemy_from_database()
    
    for i in range(3):
        player.draw_card()
        enemy.draw_card()
    
    print("=== IGRA POČINJE ===")
    print("Player HP: ", player.hp, " | Enemy HP: ", enemy.hp)
    
    player_phase()


# ─────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────

func _input(event):
    if not waiting_for_input:
        return
    
    if event is InputEventKey and event.pressed:
        var key = event.keycode
        
        if key == KEY_0:
            player_input_received = 0
        elif key == KEY_1:
            player_input_received = 1
        elif key == KEY_2:
            player_input_received = 2
        elif key == KEY_3:
            player_input_received = 3
        elif key == KEY_4:
            player_input_received = 4
        elif key == KEY_5:
            player_input_received = 5
        elif key == KEY_6:
            player_input_received = 6
        elif key == KEY_7:
            player_input_received = 7
        elif key == KEY_8:
            player_input_received = 8
        elif key == KEY_9:
            player_input_received = 9
        
        if player_input_received != -1:
            waiting_for_input = false
            handle_player_card_choice(player_input_received)


# ─────────────────────────────────────────
#  GAME LOOP
# ─────────────────────────────────────────

func player_phase():
    player.energy = 3
    player.draw_card()
    
    print("\n--- PLAYEROV POTEZ ---")
    print("Player HP: ", player.hp, " | Enemy HP: ", enemy.hp)
    
    prompt_player()


func prompt_player():
    if player.hand.size() == 0:
        print("Nemaš više karata u ruci.")
        end_player_turn()
        return
    
    if player.energy == 0:
        print("Nemaš više energije.")
        end_player_turn()
        return
    
    print("\nEnergija: ", player.energy)
    print("Tvoje karte:")
    for i in range(player.hand.size()):
        var c = player.hand[i]
        print("  ", i + 1, ". ", c.naziv,
              " | Attack: ", c.attack,
              " | Cost: ", c.cost)
    print("  0. Završi potez")
    print("Pritisni broj karte ili 0 za završetak:")
    
    player_input_received = -1
    waiting_for_input = true


func handle_player_card_choice(input: int):
    if input == 0:
        print("Završavaš potez.")
        end_player_turn()
        return
    
    if input > player.hand.size():
        print("Nema karte s tim brojem, pokušaj ponovo.")
        prompt_player()
        return
    
    var card = player.hand[input - 1]
    
    if card.cost > player.energy:
        print("Nemaš dovoljno energije za tu kartu! (treba ",
              card.cost, ", imaš ", player.energy, ")")
        prompt_player()
        return
    
    player.hand.remove_at(input - 1)
    player.energy -= card.cost
    player_attack(card)
    print("Odigrao si: ", card.naziv,
          " | Attack: ", card.attack,
          " | Ostalo energije: ", player.energy)
    
    if check_game_over():
        return
    
    prompt_player()


func end_player_turn():
    player_turn = false
    enemy_phase()


func enemy_phase():
    print("\n--- PROTIVNIKOV POTEZ ---")
    enemy.energy = 3
    enemy.draw_card()
    
    var played_any = true
    while played_any and enemy.hand.size() > 0 and enemy.energy > 0:
        played_any = false
        
        for i in range(enemy.hand.size()):
            var card = enemy.hand[i]
            if card.cost <= enemy.energy:
                enemy.hand.remove_at(i)
                enemy.energy -= card.cost
                enemy_attack(card)
                print("Enemy igra: ", card.naziv,
                      " | Attack: ", card.attack,
                      " | Ostalo energije: ", enemy.energy)
                played_any = true
                break
    
    print("Player HP: ", player.hp, " | Enemy HP: ", enemy.hp)
    
    if check_game_over():
        return
    
    player_turn = true
    player_phase()


# ─────────────────────────────────────────
#  NAPAD
# ─────────────────────────────────────────

func player_attack(card: Card):
    enemy.hp -= card.attack
    if enemy.hp < 0:
        enemy.hp = 0

func enemy_attack(card: Card):
    player.hp -= card.attack
    if player.hp < 0:
        player.hp = 0


# ─────────────────────────────────────────
#  PROVJERA KRAJA IGRE
# ─────────────────────────────────────────

func check_game_over() -> bool:
    if enemy.hp <= 0:
        print("\n=== ", player_username, " POBJEĐUJE! ===")
        game_over = true
        waiting_for_input = false
        return true
    elif player.hp <= 0:
        print("\n=== ENEMY POBJEĐUJE! ===")
        game_over = true
        waiting_for_input = false
        return true
    return false


# ─────────────────────────────────────────
#  BAZA PODATAKA
# ─────────────────────────────────────────

func load_cards_from_database():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()
    
    # Pronađi player deck (vlasnik_tip = 'korisnik', korisnik_id = 1)
    var deck_result = db.select_rows("deck", "vlasnik_tip = 'korisnik' AND korisnik_id = 1", ["id"])
    
    if deck_result.size() == 0:
        print("Nema decka za playera!")
        db.close_db()
        return
    
    var deck_id = deck_result[0][0]
    
    # Dohvati sve karte iz tog decka s količinama
    var dk_result = db.select_rows("deck_karta", "deck_id = " + str(deck_id), ["karta_id", "kolicina"])
    
    for dk_row in dk_result:
        var karta_id  = dk_row[0]
        var kolicina  = dk_row[1]
        
        var karta_result = db.select_rows("karta", "id = " + str(karta_id), ["id", "naziv", "attack", "cost"])
        
        if karta_result.size() > 0:
            var row = karta_result[0]
            # Dodaj kartu onoliko puta kolika je količina
            for j in range(kolicina):
                var card = Card.new()
                card.id     = row[0]
                card.naziv  = row[1]
                card.attack = row[2]
                card.cost   = row[3]
                player.deck.append(card)
    
    db.close_db()
    print("Učitano ", player.deck.size(), " karata iz player decka.")

func load_player_from_database():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()
    
    # Učitaj prvog korisnika iz baze
    var result = db.select_rows("korisnik", "", ["id", "username", "email"])
    
    if result.size() > 0:
        var row = result[0]
        player_username = row[1]
        player_email    = row[2]
        print("Korisnik učitan: ", player_username, " (", player_email, ")")
    else:
        print("Nema korisnika u bazi, koristim zadano ime.")
    
    db.close_db()

func load_enemy_from_database():
    var db = SQLite.new()
    db.path = "user://game.db"
    db.open_db()
    
    var result = db.select_rows("protivnik", "", ["id", "naziv", "hp", "difficulty"])
    
    if result.size() > 0:
        var row = result[0]
        enemy.hp         = row[2]
        enemy.difficulty = row[3]
        print("Protivnik učitan: ", row[1],
              " | HP: ", enemy.hp,
              " | Težina: ", enemy.difficulty)
    
    var cards = db.select_rows("karta", "", ["id", "naziv", "attack", "cost"])
    for row in cards:
        var card = Card.new()
        card.id     = row[0]
        card.naziv  = row[1]
        card.attack = row[2]
        card.cost   = row[3]
        enemy.deck.append(card)
    
    db.close_db()