extends ColorRect


const SECRET_KEY = "SECRET";
const PUBLIC_KEY = "APeIg0FHvDFmrtoB";

onready var final_time_millis: int = int(round(get_node("/root/Game/TimeLabel").now * 1000))
var nickname: String = ""

var leaders_list_item_scene = preload("res://LeadersListItem.tscn")


func _ready():
	var config = ConfigFile.new()
	config.load("user://scores.cfg")
	nickname = config.get_value("main", "nickname", "")
	$RootVBox/SubmitForm/Name.text = nickname

	_on_Name_text_changed($RootVBox/SubmitForm/Name.text)
	_update_leaderboard()
	$AnimationPlayer.play("fade_in")


func _on_Name_text_changed(new_text: String):
	$RootVBox/SubmitForm/SubmitButton.disabled = new_text.strip_escapes().strip_edges().empty()


func _update_leaderboard():
	var url = "https://plassion.com/getrec.php?cod={key}&qty=100".format({
		"key": PUBLIC_KEY
	})
	var error = $GetHTTPRequest.request(url)
	if error != OK:
		_handle_get_error()


func _on_GetHTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var body_string = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200 or body_string.begins_with("err="):
		_handle_get_error()
		return

	for item in $RootVBox/LeadersListWrapper/LeadersList.get_children():
		item.queue_free()

	var pos = 0
	for line in body_string.split('\n'):
		var score_end = line.find(',')
		var nickname_end = line.rfind(',')
		if score_end == nickname_end:
			continue
		var score_string = line.substr(0, score_end)
		var nickname_string = line.substr(score_end + 1, nickname_end - score_end - 1).strip_escapes().strip_edges()
		if not score_string.is_valid_integer() or nickname_string.empty():
			continue
		score_string = _format_millis(int(score_string))
		var leaders_list_item = leaders_list_item_scene.instance()
		pos += 1
		leaders_list_item.get_node("Position").text = String(pos) + "."
		leaders_list_item.get_node("Name").text = nickname_string
		leaders_list_item.get_node("Time").text = score_string
		if nickname_string == nickname:
			leaders_list_item.modulate = Color(1, 1, 0, 1)
		$RootVBox/LeadersListWrapper/LeadersList.add_child(leaders_list_item)

	if has_node("RootVBox/SubmitForm/Name"):
		get_node("RootVBox/SubmitForm/Name").editable = true
	

func _handle_get_error():
	var dialog = _alert("Cannot retrieve leaderboard, try again...", "Error")
	dialog.connect('tree_exiting', self, '_update_leaderboard')

func _on_Name_text_entered(new_text):
	_on_SubmitButton_pressed()


func _on_SubmitButton_pressed():
	nickname = $RootVBox/SubmitForm/Name.text.strip_escapes().strip_edges()
	$RootVBox/SubmitForm/SubmitButton.disabled = true
	$RootVBox/SubmitForm/Name.editable = false
	
	
	var config = ConfigFile.new()
	config.load("user://scores.cfg")
	config.set_value("main", "nickname", nickname)
	config.save("user://scores.cfg")
	
	var url = "https://plassion.com/setrec.php?cod={secret_key}&txt={name}&val={time}&uid={uid}".format({
		"secret_key": SECRET_KEY,
		"name": nickname.http_escape(),
		"time": String(final_time_millis),
		"uid": nickname.hash()
	})
	var error = $SubmitHTTPRequest.request(url)
	if error != OK:
		_handle_submit_error()


func _on_SubmitHTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var body_string = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200 or body_string != "err=0":
		_handle_submit_error()
		return

	$RootVBox/SubmitForm.queue_free()
	_update_leaderboard()
	

func _handle_submit_error():
	$RootVBox/SubmitForm/SubmitButton.disabled = false
	$RootVBox/SubmitForm/Name.editable = true
	var dialog = _alert("Submit failed, try again")


func _alert(text: String, title: String='Error') -> AcceptDialog:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.popup_exclusive = true
	dialog.connect('modal_closed', dialog, 'queue_free')
	dialog.connect('hide', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered()
	return dialog


func _format_millis(millis: int) -> String:
	var total_seconds = float(millis) / 1000
	var seconds: float = fmod(total_seconds, 60.0)
	var minutes: int =  int(total_seconds / 60.0)
	return "%02d:%05.2f" % [minutes, seconds]
