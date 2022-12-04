extends ScrollContainer



func _ready():
	var  a = [1,2,4]
	var b = [3,4,7]
	b += a
	print(b)
