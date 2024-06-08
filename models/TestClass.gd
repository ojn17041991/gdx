class_name TestClass extends Node

var Tests: Array[Callable] = []

func Run() -> Array[TestResult]:
	var results: Array[TestResult] = []
	for test: Callable in Tests:
		var functionName: String = test.get_method()
		var result: bool = test.call()
		results.push_back(
			TestResult.new(
				functionName,
				result
			)
		)
	return results
