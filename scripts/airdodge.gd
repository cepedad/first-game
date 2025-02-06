extends Node2D

@onready var dodge_timer: Timer = $DodgeTimer
@onready var hang_timer: Timer = $HangTimer

func start_airdodge(dodge_dur, hang_dur):
	dodge_timer.start(dodge_dur)
	await dodge_timer.timeout
	hang_timer.start(hang_dur)
	
func is_airdodging():
	return not dodge_timer.is_stopped()

func is_hanging():
	return not hang_timer.is_stopped()
