WORK=work
OBJS=$(shell find tests -type f -name '*.vhdl' -exec sed --quiet -E 's/entity (.+TB) is/\1/p' {} +)

.PHONY: run all clean lsp
.PRECIOUS: $(WORK)/%-obj93.cf
all: $(foreach I,$(OBJS),$(WORK)/$I.ghw)

run: $(WORK)/$(TARGET).ghw

clean:
	rm -f $(WORK)/*-obj93.cf $(WORK)/*.ghw

check_flash:
	@if [ -z "$(TOP_MODULE)" ]; then \
		echo "TOP_MODULE is not defined"; \
		exit 1; \
	fi
	@if [ -z "$(VIVADO_PATH)" ]; then \
		echo "VIVADO_PATH is not defined: Vivado/<version>"; \
		exit 1; \
	fi

flash: check_flash
#	Exec scripts	
	./scripts/bit_flash.sh $(TOP_MODULE) $(VIVADO_PATH)

clean_proyect:
	rm -rf ./JACAA vivado*

lsp: hdl-prj.json vhdl_ls.toml

hdl-prj.json: $(WORK)/src-obj93.cf $(WORK)/tests-obj93.cf
	printf "{\n\
	    \"options\": {\"ghdl_analysis\": [\"--workdir=$(WORK)\", \"-P$(WORK)\"]},\n\
	    \"files\": [\n$$(\
			find src tests -type f -name '*.vhdl' \
		    | sed -nE "s/(([^\/]+)\/.+)/        {\"file\": \"\1\", \"library\": \"\2\"},/p"\
		    | head --bytes -2\
	    )\n    ]\n\
	}" > $@

vhdl_ls.toml: $(WORK)/src-obj93.cf $(WORK)/tests-obj93.cf
	printf "[libraries]\n\
	Src.files = [\n\
	$$(find src -type f -name '*.vhdl' | sed -nE "s/(.*)/    \"\1\",/p")\n\
	]\n\
	Tests.files = [\n\
	$$(find tests -type f -name '*.vhdl' | sed -nE "s/(.*)/    \"\1\",/p")\n\
	]\
	" > $@

$(WORK):
	@if [ ! -d $(WORK) ]; then mkdir $(WORK); fi

$(WORK)/%-obj93.cf: $(shell find $* -type f -name "*.vhdl") | $(WORK)
	@printf "\033[33;1m[Importing $*]\033[0m\n"
	@rm -f $@
	@find $* -type f -name '*.vhdl' -exec ghdl -i --work=$* --workdir=$(WORK) {} +

$(WORK)/%.ghw: $(WORK)/src-obj93.cf $(WORK)/tests-obj93.cf | $(WORK)
	@printf "\033[32;1m[Simulation $*]\033[0m\n"
	@ghdl -c --work=tests --workdir=$(WORK) -P$(WORK) -r $* --wave='$(WORK)/$*.ghw'
