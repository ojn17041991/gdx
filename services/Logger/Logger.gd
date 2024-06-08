class_name _logger extends Node

func LogInformation(information: String) -> void:
	print(information)

func LogWarning(warning: String) -> void:
	push_warning(warning)

func LogError(error: String) -> void:
	push_error(error)
