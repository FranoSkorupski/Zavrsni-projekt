extends Node
class_name Player

var hp:int = 20
var energy:int = 3
var deck:Array = []
var hand:Array = []

func draw_card():
	if deck.size() > 0:
		var card = deck.pop_front()
		hand.append(card)
