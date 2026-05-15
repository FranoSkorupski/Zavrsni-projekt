extends Node

var player
var enemy

func _ready():
	player = Player.new()
	enemy = Enemy.new()

	load_cards_from_database()

	player.draw_card()
	enemy.draw_card()

func load_cards_from_database():
	var db = SQLite.new()
	db.path = "user://game.db"
	db.open_db()

	var result = db.select_rows("karta", "", ["id", "naziv", "attack", "cost"])

	for row in result:
		var card = Card.new()
		card.id = row[0]
		card.naziv = row[1]
		card.attack = row[2]
		card.cost = row[3]

		player.deck.append(card)

func player_attack(card):
	enemy.hp -= card.attack

	if enemy.hp <= 0:
		print("PLAYER WINS")
