class_name Result extends Node

var ResultType: int
var Data

func _init(resultType: int, data: Variant) -> void:
	ResultType = resultType
	Data = data
