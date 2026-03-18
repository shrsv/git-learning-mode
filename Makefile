SHELL := bash

.PHONY: list-objects object-type

list-objects:
	find .git/objects -type f

object-type:
	@source ./options.select.bash; \
	object_paths=($$(find .git/objects -type f -regextype posix-extended -regex '.git/objects/[0-9a-f]{2}/[0-9a-f]{38}' | sort)); \
	if [ $${#object_paths[@]} -eq 0 ]; then echo "No loose objects found."; exit 1; fi; \
	prompt="Please, select an object path! [%index]/[%total]"; \
	command tput smcup; \
	options.select object_paths "$$prompt"; \
	command tput rmcup; \
	selected_path="$$SELECTED"; \
	obj_hash=$$(echo "$$selected_path" | sed -E 's#^\.git/objects/([0-9a-f]{2})/([0-9a-f]{38})$$#\1\2#'); \
	echo "Running: git cat-file -t $$obj_hash"; \
	echo "Selected: $$selected_path"; \
	echo -n "Type: "; git cat-file -t "$$obj_hash"
