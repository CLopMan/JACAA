WORK ?= ./work

run: $(WORK)/$(TARGET).ghw

.SUFFIXES:

$(WORK)/$(TARGET).ghw: $(shell find $(WORK)/../src -type f -name "*.vhdl") $(shell find $(WORK)/../tests -type f -name "*.vhdl")
	find src -type f -name '*.vhdl' -exec ghdl -i --work=src --workdir=$(WORK) {} +
	find tests -type f -name '*.vhdl' -exec ghdl -i --work=tests --workdir=$(WORK) {} +
	echo "\n\033[32;1m[Simulation]\033[0m"
	ghdl -c --work=tests --workdir=$(WORK) -P$(WORK) -r $(TARGET) --wave='$(WORK)/$(TARGET).ghw'
