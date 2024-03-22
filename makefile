WORK=work
OBJS=ALUTB RegisterBankTB RegisterTB StateRegisterTB Multiplexor2To1TB

.PHONY: run all clean
.PRECIOUS: $(WORK)/%-obj93.cf
all: $(foreach I,$(OBJS),$(WORK)/$I.ghw)

run: $(WORK)/$(TARGET).ghw

clean:
	rm -f $(WORK)/*-obj93.cf $(WORK)/*.ghw

$(WORK):
	@if [ ! -d $(WORK) ]; then mkdir $(WORK); fi

$(WORK)/%-obj93.cf: $(shell find $* -type f -name "*.vhdl") | $(WORK)
	@echo "\033[33;1m[Importing $*]\033[0m"
	@rm -f $@
	@find $* -type f -name '*.vhdl' -exec ghdl -i --work=$* --workdir=$(WORK) {} +

$(WORK)/%.ghw: $(WORK)/src-obj93.cf $(WORK)/tests-obj93.cf | $(WORK)
	@echo "\033[32;1m[Simulation]\033[0m"
	@ghdl -c --work=tests --workdir=$(WORK) -P$(WORK) -r $* --wave='$(WORK)/$*.ghw'
