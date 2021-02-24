.PHONY: python_check all

MYPY_FLAGS=\
--show-error-codes \
--ignore-missing-imports \
--warn-unused-configs \
--disallow-any-generics \
--disallow-untyped-calls \
--disallow-untyped-defs \
--disallow-incomplete-defs \
--check-untyped-defs \
--disallow-untyped-decorators \
--no-implicit-optional \
--warn-redundant-casts \
--warn-unused-ignores \
--warn-return-any \
--strict-equality \


YELLOW=93
BLUE=94
define color
	@echo -n "\e[$1m"
	@$2
	@echo -n "\e[0m"
endef

define run_check
	@echo '$(1)'
	$(call color,$(YELLOW),$1)
endef

all: python_check
python_files=$(basename $(shell find . -name '*.py'))
python_check: $(addprefix .python_check/,$(python_files))
	pytest

.python_check/%: %.py
	mkdir -p "$$(dirname "$@")"
	$(call color,$(BLUE),echo check $<)
	@# pylint will return hundreds of false positives based on its own stupid coding style conventions unless
	@# disabled in .pylintrc. No point in even running it if that's the case. And it'll return a few false 
	@# positives even with that, so it isn't an error to have pylint fail
	$(call run_check,python3 -m py_compile $<)
	$(call run_check,mypy $(MYPY_FLAGS) $<)
	$(call run_check,pyflakes3 $<)
	$(call run_check,if [ ! -f "$$HOME/.pylintrc" -a ! -f ".pylintrc" -a ! -f "pylintrc" ]; then echo "No pylintrc found. Skipping pylint step."; else pylint3 -sn $< 2> /dev/null; fi)
	touch $@

aggregate_score: aggregate_score.d process_range.d
	dmd -g -O $^

bif2sample_json: bif2sample_json.d
	dmd -g -O $^

math.pdf: math.tex
	pdflatex $<

