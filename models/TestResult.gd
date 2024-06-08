class_name TestResult extends Node

var Name: String
var Passed: bool

func _init(name: String, passed: bool) -> void:
	Name = name
	Passed = passed
