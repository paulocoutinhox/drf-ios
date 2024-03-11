ROOT_DIR=${PWD}

.DEFAULT_GOAL := help
.PHONY: pods

# tasks
help:
	@echo "Type: make [rule]. Available options are:"
	@echo ""
	@echo "- help"
	@echo "- clean-derived-data"
	@echo "- format"
	@echo ""

clean-derived-data:
	rm -rf ~/Library/Developer/Xcode/DerivedData

format:
	swiftformat drf/
