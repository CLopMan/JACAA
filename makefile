WORK ?= ./work

.PHONY: run
run: $(WORK)/$(TARGET).ghw

$(WORK)/%-obj93.cf: $(shell find $* -type f -name "*.vhdl")
	@echo "\033[33;1m[Importing $*]\033[0m"
	rm -f $@
	find $* -type f -name '*.vhdl' -exec ghdl -i --work=$* --workdir=$(WORK) {} +

$(WORK)/$(TARGET).ghw: $(WORK)/src-obj93.cf $(WORK)/tests-obj93.cf
	@echo "\033[32;1m[Simulation]\033[0m"
	ghdl -c --work=tests --workdir=$(WORK) -P$(WORK) -r $(TARGET) --wave='$(WORK)/$(TARGET).ghw'
