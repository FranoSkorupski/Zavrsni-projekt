extends Node
class_name Player

var hp:int = 20
var energy:int = 3
var deck:Array = []
var hand:Array = []

func draw_card():
	if deck.size() > 0:
		var random_index = randi() % deck.size()
		var card = deck[random_index]
		deck.remove_at(random_index)
		hand.append(card)
