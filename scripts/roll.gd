extends Node2D

@onready var timer: Timer = $Timer

func start_roll(duration):
	timer.start(duration)
	
func is_rolling():
	return not timer.is_stopped()
