extends Node

# We set up the timer
@onready var Power_Timer: Timer = $Timer
#We set up the core power usage.
@export var cur_Power: int = 999 # The main Current Power
@export var power_usage: int = 1 # This value can be increased by having more doors down and having the camera up
var drain_time: int = 1

# Set up the core passive drain of the power.
@export var passive_drain: int  = 1 # Can also be updated based off of the current night. 
@export var max_passive_Drain_count: int = 6 # This will be updated based off of the current night
@export var passive_drain_countdown: int = max_passive_Drain_count

#Set up the core charging system
var charge_time: float = 20;
var cur_Charge: float  = 0
var charge_goal: int = 999;
@export var charging: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_up_active_power_drain_timer()
	pass # Replace with function body.

func _set_up_active_power_drain_timer() -> void:
	Power_Timer.wait_time = drain_time
	# Fun fact you can connect multiple functions to a timer timeout, it will stack up on each other.
	# So to utilize the same timer must disconnect from other function.
	if Power_Timer.timeout.is_connected(_Finish_Charge):
		Power_Timer.timeout.disconnect(_Finish_Charge)
	Power_Timer.timeout.connect(_Drain_Power)
	Power_Timer.start()

func _Drain_Power() -> void:
	var drain_amount = power_usage
	passive_drain_countdown -= 1
	if passive_drain_countdown <= 0:
		passive_drain_countdown = max_passive_Drain_count
		drain_amount += passive_drain
		pass
	cur_Power -= drain_amount
#	print("Current Power: ", cur_Power)
	if cur_Power <= 0:
		_Power_Run_Out()
		return
	
	print(_Return_Current_Power_Displayed_Value(), "%")
	pass

func _Power_Run_Out() -> void:
	print("Power has run out. Send Out Signal that Power has Run out.")
	Power_Timer.stop()
	_Charge_Power()
	
func _Charge_Power() -> void:
	Power_Timer.wait_time = charge_time
	if Power_Timer.timeout.is_connected(_Drain_Power):
		Power_Timer.timeout.disconnect(_Drain_Power)
	Power_Timer.timeout.connect(_Finish_Charge)
	print("Charging Phone, it shall be completed in " , charge_time , " seconds.")
	cur_Charge = 0
	charging = true
	Power_Timer.start()

func _Finish_Charge() -> void:
	Power_Timer.stop()
	charging = false
	cur_Power = charge_goal
#	print("Current Charge: ", cur_Power)
	_set_up_active_power_drain_timer()
	
func _Return_Current_Power_Displayed_Value() -> int:
	var displayed_power: int = floor(cur_Power / 10)
	return displayed_power

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if charging == true:
		cur_Charge += delta
		print("Time Elapsed: ", cur_Charge, "s | Charge Percent: ", floor((cur_Charge / charge_time)*100), "%" )
	pass
