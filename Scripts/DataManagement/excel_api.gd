extends Node
class_name ExcelAPI

const SHEETDB_URL = "https://sheetdb.io/api/v1/6g46wjbzhbxrn"

func send_round_data(student_name: String, operator_data: String, number_group: String, questions_incorrect: int, max_questions: int, questions_per_minute: float, time_taken: float): # replace with your endpoint
	
	if !student_name:
		student_name = "No Name"
	if !operator_data:
		operator_data = "+"
	if !number_group:
		number_group = "None Selected"
	if !questions_incorrect:
		questions_incorrect = 0
	if !questions_per_minute:
		questions_per_minute = 0
	if !time_taken:
		time_taken = 0
	if !max_questions:
		max_questions = 0
		
	if operator_data == "+" or operator_data == "-":
		operator_data = str("'", operator_data)
	
	var payload = {
		"data": [{
			"Name": student_name,
			"Operator": operator_data,
			"Number Group": number_group,
			"Questions Incorrect": questions_incorrect,
			"Questions Per Minute": questions_per_minute,
			"Max Questions": max_questions,
			"Time Taken (Seconds)": time_taken
		}]
	}
	
	var json_body = JSON.stringify(payload)

	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = ["Content-Type: application/json"]
	var error = http.request(SHEETDB_URL, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		push_error("HTTP Request failed: %s" % error)
		print(error)
	else:
		print("Request sent to SheetDB!")
		print(error)
