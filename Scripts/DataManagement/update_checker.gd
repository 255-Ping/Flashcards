extends HTTPRequest

var current_version: String
const REPO := "255-Ping/Flashcards"

var main

var downloader: HTTPRequest

func _ready() -> void:
	main = get_tree().current_scene
	current_version = main.version
	
	downloader = HTTPRequest.new()
	downloader.max_redirects = 8
	add_child(downloader)
	downloader.request_completed.connect(_on_download_completed)
	
	check_for_update()
	
func check_for_update() -> void:
	if OS.has_feature("editor"):
		PanelLogger.log("Update: Skipping check, running in editor")
		return
	request_completed.connect(_on_request_completed)
	request("https://api.github.com/repos/%s/releases/latest" % REPO)
	
func _on_request_completed(_result, _code, _headers, body: PackedByteArray) -> void:
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		PanelLogger.log_error("Update: Failed to parse GitHub API response")
		return
	var latest: String = json["tag_name"].trim_prefix("v")
	
	PanelLogger.log("Current version: " + current_version)
	PanelLogger.log("Latest version: " + latest)
	PanelLogger.log("Match: " + str(latest == current_version))
	
	if latest != current_version:
		if OS.has_feature("web"):
			main.create_popup("Update Available: " + latest + "\nGo to https://github.com/255-Ping/Flashcards/releases")
		elif OS.has_feature("windows"):
			_find_and_download(json, ".exe")
		elif OS.has_feature("linux"):
			_find_and_download(json, ".x86_64")
		else:
			main.create_popup("Update Available: " + latest + "\nGo to https://github.com/255-Ping/Flashcards/releases")

func _find_and_download(json: Variant, extension: String) -> void:
	var assets = json.get("assets", [])
	for asset in assets:
		var download_name: String = asset.get("name", "")
		if download_name.ends_with(extension):
			var url: String = asset.get("browser_download_url", "")
			if url == "":
				main.create_popup("Could not find download URL.", -1.0, "error")
				PanelLogger.log_error("Update: Download URL was empty")
				return
			
			PanelLogger.log("Starting download from: " + url)
			main.create_popup("Downloading update, please wait...")
			
			var save_path: String
			if OS.has_feature("windows"):
				save_path = OS.get_executable_path().get_base_dir() + "/flashcards_new.exe"
			else:
				save_path = OS.get_executable_path().get_base_dir() + "/flashcards_new"
			
			PanelLogger.log("Saving to: " + save_path)
			downloader.download_file = save_path
			downloader.request(url)
			return
	
	main.create_popup("No update file found for your platform.", -1.0, "error")
	PanelLogger.log_error("Update: No asset found with extension " + extension)

func _on_download_completed(result: int, response_code: int, _headers, _body) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		main.create_popup("Download failed. (Result: " + str(result) + ")", -1.0, "error")
		PanelLogger.log_error("Update download failed, result: " + str(result))
		return
	
	var save_path: String
	if OS.has_feature("windows"):
		save_path = OS.get_executable_path().get_base_dir() + "/flashcards_new.exe"
	else:
		save_path = OS.get_executable_path().get_base_dir() + "/flashcards_new"
	
	var file_size := FileAccess.get_file_as_bytes(save_path).size()
	PanelLogger.log("Downloaded file size: " + str(file_size) + " bytes")
	if file_size < 1000000:
		main.create_popup("Downloaded file looks wrong (too small: " + str(file_size) + " bytes)", -1.0, "error")
		PanelLogger.log_error("Update: Downloaded file too small, likely a redirect page not a binary")
		return
	
	PanelLogger.log("Download complete, size looks good: " + str(file_size) + " bytes")
	
	if OS.has_feature("windows"):
		_apply_update_windows()
	elif OS.has_feature("linux"):
		_apply_update_linux()

func _apply_update_windows() -> void:
	var exe_path := OS.get_executable_path().simplify_path()
	var dir := exe_path.get_base_dir()
	var new_exe := dir + "/flashcards_new.exe"
	var bat_path := dir + "/updater.bat"
	
	PanelLogger.log("exe_path: " + exe_path)
	PanelLogger.log("new_exe: " + new_exe)
	
	var bat_content := """@echo off
timeout /t 2 /nobreak > nul
move /y "{new}" "{old}"
start "" "{old}"
""".format({"new": new_exe, "old": exe_path})
	
	var file := FileAccess.open(bat_path, FileAccess.WRITE)
	if file == null:
		main.create_popup("Could not write updater script.", -1.0, "error")
		PanelLogger.log_error("Update: Could not write updater.bat")
		return
	file.store_string(bat_content)
	file.close()
	
	main.create_popup("Update downloaded! Restarting to apply...")
	PanelLogger.log("Update: Launching updater.bat and closing")
	
	await get_tree().create_timer(1.5).timeout
	OS.create_process("cmd", ["/c", bat_path])
	get_tree().quit()

func _apply_update_linux() -> void:
	var exe_path := OS.get_executable_path().simplify_path()
	var dir := exe_path.get_base_dir()
	var new_exe := dir + "/flashcards_new"
	var sh_path := dir + "/updater.sh"
	
	PanelLogger.log("exe_path: " + exe_path)
	PanelLogger.log("dir: " + dir)
	PanelLogger.log("new_exe: " + new_exe)
	PanelLogger.log("sh_path: " + sh_path)
	
	var sh_content := """#!/bin/bash
exec > /tmp/flashcards_updater.log 2>&1
echo "Script started"
echo "new_exe: {new}"
echo "old_exe: {old}"
echo "Waiting for process to die..."
while pgrep -f "{old}" > /dev/null; do
    sleep 0.5
done
echo "Process gone, attempting mv..."
mv -f "{new}" "{old}"
echo "mv exit code: $?"
chmod +x "{old}"
echo "chmod done"
"{old}" &
echo "Launched new process"
rm -- "$0"
""".format({
		"new": new_exe,
		"old": exe_path
	})
	
	var file := FileAccess.open(sh_path, FileAccess.WRITE)
	if file == null:
		main.create_popup("Could not write updater script.", -1.0, "error")
		PanelLogger.log_error("Update: Could not write updater.sh")
		return
	file.store_string(sh_content)
	file.close()
	
	OS.execute("chmod", ["+x", sh_path])
	
	main.create_popup("Update downloaded! Restarting to apply...")
	PanelLogger.log("Update: Launching updater.sh and closing")
	
	await get_tree().create_timer(1.5).timeout
	OS.create_process("bash", [sh_path])
	get_tree().quit()
