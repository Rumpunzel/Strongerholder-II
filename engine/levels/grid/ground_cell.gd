class_name GroundCell
extends GridCell

var travel_cost: float = 1.0
var times_entered: int = 0

func get_travel_cost() -> float:
	return travel_cost * pow(2.0, -times_entered)
