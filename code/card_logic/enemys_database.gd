extends Node
#0 type - тип карты: 0 - основное действие; 1 - побочное действие; 2 - реакция.
#1 atack - атака карты, если заюзать как атаку на месте
#2 spped - скорость персонажа, если заюзать карту как спринт
#3 defence - защита, если заюзать карту в обход описания защиты или если такого нет
#4 image - изображение
#5 name - название
#6 discription-1 - описание основного эффекта
#7 discription-2 - описание эффекта защиты
#8 metods_main - функции которые триггерит основное описание
#9 metods_def - функции которые триггерит описание защиты
#10 metod_1_vars
#11 metod_2_vars
#12 сard_family - тип карты, в общем смысле (сейчас не используется)
enum {
	worm,
	sentry_gun
}
const DATA = {
	worm: [[4,2],10,2,"гну - червь", "worm", 
	"Перемещается на 5 клеток\nНаносит2 урона\nв радиусе 2",["move", "attack"], [5, [2,2]],
	"Единожды:\nПеремещается на 3 клетки",["move"], 3,
	"После получения урона\nперемещается на 5 клеток", ["move"], 10
	],
	sentry_gun: [ [5,10],0,4,"Турель VZ - 24", "sentry_enemy", 
	"Дважды наносит 2 урона\nв радиусе 10",["attack", "attack"], [[2,10], [2,10]],
	"",[], null,
	"После получения урона\nперемещается на 20 клеток", ["move"], 20
	]
	
}

