extends Control

@export_enum("hero", "briarling", "goblin", "ogre") var character: String = "hero"
const PIXEL := 6.0
const COLORS := {".": Color(0, 0, 0, 0), "K": Color("211b2c"), "S": Color("e7b78f"), "H": Color("75464c"), "C": Color("c7c2ce"), "B": Color("44536b"), "G": Color("7d9a70"), "L": Color("b6bf83"), "R": Color("9c6556"), "O": Color("b8784d"), "Y": Color("e7bd78"), "W": Color("eee5d8")}
const HERO := ["......KKKK......", ".....KHHHHK.....", ".....KSSSSK.....", "....KSSSSSSK....", "....KSKSSKSK....", "....KSSSSSSK....", ".....KSSSSK.....", "......KHHK......", ".....KCCCCK.....", "....KCCYYCCK....", "....KBBBBBBK....", "....KBB..BBK....", "....KKK..KKK....", "...KKK....KKK...", "...KK......KK...", "................"]
const BRIAR := ["................", "......KKKK......", ".....KGGGGK.....", "....KGGLLGGK....", "...KGGLKKLGGK...", "...KGGGKKGGGK...", "....KGGLLGGK....", ".....KGGGGK.....", "......KKKK......", ".....KGGGGK.....", "....KGGGGGGK....", "...KGGG..GGGK...", "...KKK....KKK...", "..KKK......KKK..", "................", "................"]
const GOBLIN := ["................", ".....KKKK.......", "....KGGGGKK.....", "...KGGLLLLGGK...", "..KGGGWWGWWGGK..", "..KGGGGKKGGGGK..", "...KGGGKKGGGK...", "....KGGGGGGK....", ".....KKKKKK.....", "....KRRRRRRK....", "...KRRRRRRRRK...", "..KRRKRRRRKRRK..", "..KKK..KK..KKK..", ".KKK...KK...KKK.", "................", "................"]
const OGRE := ["................", "....KKKKKK......", "...KOOOOOOK.....", "..KOOOYYOOOOK...", "..KOOOKKOOOOK...", "..KOOOOOOOOOK...", "...KOOOOOOOK....", "....KKKKKKK.....", "...KRRRRRRRRK...", "..KRRRRRRRRRRK..", "..KRRKRRRRKRRK..", "..KRRRRRRRRRRK..", ".KKKKK....KKKKK.", ".KKK........KKK.", "................", "................"]

func _ready() -> void:
	custom_minimum_size = Vector2(112, 112)
	queue_redraw()

func _draw() -> void:
	var rows: Array = HERO
	if character == "briarling": rows = BRIAR
	elif character == "goblin": rows = GOBLIN
	elif character == "ogre": rows = OGRE
	var start := (size - Vector2(16.0 * PIXEL, 16.0 * PIXEL)) * 0.5
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			var color: Color = COLORS.get(rows[y][x], Color.TRANSPARENT)
			if color.a > 0.0:
				draw_rect(Rect2(start + Vector2(x, y) * PIXEL, Vector2(PIXEL, PIXEL)), color)
