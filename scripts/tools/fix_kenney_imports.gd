@tool
extends EditorScript

## Script to fix Kenney UI pack import settings for mobile optimization
## Requirements: mipmaps off, filter on, VRAM compression mode 2

func _run():
	print("=== Kenney Asset Import Settings Fixer ===")
	print("Scanning assets/ui_packs/ for PNG textures...")
	
	var issues_found = []
	var files_fixed = 0
	var files_scanned = 0
	
	# Scan all color pack folders
	var color_packs = ["Blue", "Yellow", "Red", "Green", "Grey", "Extra"]
	var variants = ["Default", "Double"]
	
	for pack in color_packs:
		for variant in variants:
			var dir_path = "res://assets/ui_packs/" + pack + "/" + variant
			if not DirAccess.dir_exists_absolute(dir_path):
				continue
			
			var dir = DirAccess.open(dir_path)
			if dir:
				dir.list_dir_begin()
				var file_name = dir.get_next()
				
				while file_name != "":
					if file_name.ends_with(".png.import"):
						files_scanned += 1
						var import_path = dir_path + "/" + file_name
						var result = check_and_fix_import(import_path)
						
						if result.has_issues:
							issues_found.append({
								"file": import_path,
								"issues": result.issues
							})
							if result.fixed:
								files_fixed += 1
					
					file_name = dir.get_next()
				
				dir.list_dir_end()
	
	# Print report
	print("\n=== Scan Complete ===")
	print("Files scanned: ", files_scanned)
	print("Files with issues: ", issues_found.size())
	print("Files fixed: ", files_fixed)
	
	if issues_found.size() > 0:
		print("\n=== Issues Found ===")
		for issue in issues_found:
			print("\nFile: ", issue.file)
			for problem in issue.issues:
				print("  - ", problem)
	
	if files_fixed > 0:
		print("\n✓ Import settings have been updated.")
		print("⚠ You need to reimport assets for changes to take effect.")
		print("  Go to Project > Reload Current Project or restart Godot.")
	else:
		print("\n✓ All import settings are correct!")

func check_and_fix_import(import_path: String) -> Dictionary:
	var result = {
		"has_issues": false,
		"issues": [],
		"fixed": false
	}
	
	var file = FileAccess.open(import_path, FileAccess.READ)
	if not file:
		result.issues.append("Could not open file")
		result.has_issues = true
		return result
	
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	var needs_fix = false
	
	# Check compress/mode (should be 2 for VRAM Compressed)
	if content.contains("compress/mode=0"):
		result.issues.append("compress/mode=0 (should be 2 for VRAM Compressed)")
		result.has_issues = true
		needs_fix = true
		content = content.replace("compress/mode=0", "compress/mode=2")
	elif content.contains("compress/mode=1"):
		result.issues.append("compress/mode=1 (should be 2 for VRAM Compressed)")
		result.has_issues = true
		needs_fix = true
		content = content.replace("compress/mode=1", "compress/mode=2")
	elif content.contains("compress/mode=3"):
		result.issues.append("compress/mode=3 (should be 2 for VRAM Compressed)")
		result.has_issues = true
		needs_fix = true
		content = content.replace("compress/mode=3", "compress/mode=2")
	elif content.contains("compress/mode=4"):
		result.issues.append("compress/mode=4 (should be 2 for VRAM Compressed)")
		result.has_issues = true
		needs_fix = true
		content = content.replace("compress/mode=4", "compress/mode=2")
	
	# Check vram_texture metadata (should be true for mode 2)
	if content.contains('"vram_texture": false'):
		result.issues.append('vram_texture: false (should be true for VRAM compression)')
		result.has_issues = true
		needs_fix = true
		content = content.replace('"vram_texture": false', '"vram_texture": true')
	
	# Verify mipmaps are disabled (correct for UI)
	if content.contains("mipmaps/generate=true"):
		result.issues.append("mipmaps/generate=true (should be false for crisp UI)")
		result.has_issues = true
		needs_fix = true
		content = content.replace("mipmaps/generate=true", "mipmaps/generate=false")
	
	# Write fixes if needed
	if needs_fix:
		var write_file = FileAccess.open(import_path, FileAccess.WRITE)
		if write_file:
			write_file.store_string(content)
			write_file.close()
			result.fixed = true
		else:
			result.issues.append("Failed to write fixes")
	
	return result
