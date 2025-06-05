# Academic Literature Repository Makefile
# For managing papers, books, and journal articles

SHELL := /bin/bash
.PHONY: help init structure books research clean serve pdf epub html all

# Default target
help:
	@echo "Academic Literature Repository Management"
	@echo "========================================"
	@echo "Available targets:"
	@echo "  make init       - Initialize repository structure"
	@echo "  make structure  - Create directory structure"
	@echo "  make books      - Generate books from collected research"
	@echo "  make research   - Consolidate research notes"
	@echo "  make pdf        - Generate PDF outputs"
	@echo "  make epub       - Generate EPUB outputs"
	@echo "  make html       - Generate HTML outputs"
	@echo "  make serve      - Start local documentation server"
	@echo "  make clean      - Clean generated files"
	@echo "  make all        - Run all generation tasks"

# Initialize repository
init: structure
	@echo "Initializing repository..."
	@touch Papers/.gitkeep
	@touch Books/.gitkeep
	@touch Journal_Articles/.gitkeep
	@touch Notes/.gitkeep
	@touch References/.gitkeep
	@touch Generated/.gitkeep
	@echo "Repository initialized."

# Create directory structure
structure:
	@echo "Creating directory structure..."
	@mkdir -p Papers/{Computer_Science,Mathematics,Physics,Biology,Philosophy,Economics,Interdisciplinary}
	@mkdir -p Books/{Textbooks,Monographs,Collections,Generated}
	@mkdir -p Journal_Articles/{By_Year,By_Topic,By_Author}
	@mkdir -p Notes/{Summaries,Annotations,Synthesis}
	@mkdir -p References/{BibTeX,Citations,Indexes}
	@mkdir -p Templates/{Book,Article,Report}
	@mkdir -p Scripts/{Generation,Analysis,Consolidation}
	@mkdir -p Generated/{PDF,EPUB,HTML,Markdown}
	@echo "Directory structure created."

# Generate books from research
books: research
	@echo "Generating books from research..."
	@mkdir -p Generated/Books
	@if [ -f Scripts/Generation/generate_book.py ]; then \
		python Scripts/Generation/generate_book.py; \
	else \
		echo "Book generation script not found. Creating template..."; \
		$(MAKE) book-templates; \
	fi

# Consolidate research
research:
	@echo "Consolidating research notes..."
	@mkdir -p Generated/Research
	@if [ -f Scripts/Consolidation/consolidate_research.py ]; then \
		python Scripts/Consolidation/consolidate_research.py; \
	else \
		echo "Research consolidation script not found. Creating template..."; \
		$(MAKE) research-templates; \
	fi

# Generate PDF outputs
pdf: books research
	@echo "Generating PDF outputs..."
	@mkdir -p Generated/PDF
	@command -v pandoc >/dev/null 2>&1 || { echo "pandoc required but not installed."; exit 1; }
	@find Generated/Markdown -name "*.md" -exec sh -c 'pandoc "$$1" -o "Generated/PDF/$$(basename "$$1" .md).pdf" --pdf-engine=xelatex' _ {} \;

# Generate EPUB outputs
epub: books research
	@echo "Generating EPUB outputs..."
	@mkdir -p Generated/EPUB
	@command -v pandoc >/dev/null 2>&1 || { echo "pandoc required but not installed."; exit 1; }
	@find Generated/Markdown -name "*.md" -exec sh -c 'pandoc "$$1" -o "Generated/EPUB/$$(basename "$$1" .md).epub"' _ {} \;

# Generate HTML outputs
html: books research
	@echo "Generating HTML outputs..."
	@mkdir -p Generated/HTML
	@command -v pandoc >/dev/null 2>&1 || { echo "pandoc required but not installed."; exit 1; }
	@find Generated/Markdown -name "*.md" -exec sh -c 'pandoc "$$1" -o "Generated/HTML/$$(basename "$$1" .md).html" --standalone --toc' _ {} \;

# Create book generation templates
book-templates:
	@mkdir -p Scripts/Generation
	@echo "Creating book generation templates..."
	@touch Scripts/Generation/generate_book.py
	@chmod +x Scripts/Generation/generate_book.py

# Create research consolidation templates
research-templates:
	@mkdir -p Scripts/Consolidation
	@echo "Creating research consolidation templates..."
	@touch Scripts/Consolidation/consolidate_research.py
	@chmod +x Scripts/Consolidation/consolidate_research.py

# Start local documentation server
serve: html
	@echo "Starting documentation server..."
	@cd Generated/HTML && python -m http.server 8000

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf Generated/*
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -delete
	@find . -name ".DS_Store" -delete
	@echo "Clean complete."

# Run all generation tasks
all: init books research pdf epub html
	@echo "All tasks completed."