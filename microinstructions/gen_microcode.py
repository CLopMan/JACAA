import sys

# CONSTANTS
FIELD_WIDTH =  [3, 1, 1, 4, 5, 5, 5, 5, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 5, 5, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]

OPVALUE = {
    "FETCH"    : 0,
    "OP-IMM"   : int("0010011", 2),
    "LUI"      : int("0110111", 2),
    "AUIPC"    : int("0010111", 2),
    "OP"       : int("0110011", 2),
    "JAL"      : int("1101111", 2),
    "JALR"     : int("1100111", 2),
    "BRANCH"   : int("1100011", 2),
    "LOAD"     : int("0000011", 2),
    "STORE"    : int("0100011", 2),
    "MISC-MEM" : int("0001111", 2),
    "SYSTEM"   : int("1110011", 2),

}
# *** END CONSTANTS *** #

# get number of cycles for instruction
# preprocess
def preprocess(file_name) -> dict:
    cpi = {} # cycles per instruccion
    opcodes = {}
    with open(file_name, "r") as fd:
        fd.readline() # discard first line
        line = fd.readline()
        while True:
            name = ""
            opcode = ""
            cycle_count = 1
            c = 0
            # get instruction name
            while line[c].isalpha():
                name += line[c]
                c += 1
            # get opcode
            if c != 0:
                c += 1
                while line[c] != ',':
                    opcode += line[c]
                    c += 1
                opcodes[name] = OPVALUE[opcode]
            line = fd.readline() # get next line
            if not line:
                cpi[name] = cycle_count
                return cpi, opcodes

            while not line[0].isalpha():
                cycle_count += 1
                line = fd.readline()
            cpi[name] = cycle_count

# Gen control memory string for vhdl
def parse_csv(file_name: str):
    control_memory = ""
    code_to_micro = ""
    fd = open(file_name, "r")
    fd.readline() # discard first line (headers)
    cpi, opcodes = preprocess(file_name)
    ins_count = 0
    for ins in cpi:
        for cycle in range(cpi[ins]):
            # control memory generation
            line = fd.readline().strip() # delete \n
            comma_count = 0
            c = 0
            while comma_count < 2:
                if line[c] == ",":
                    comma_count += 1
                c += 1
            line = line[c:]
            line_output = ""
            field = "" # field value
            n_field = 0 # index of field
            for _ in line:
                if _ == ',':
                    #print(">>>", field)
                    line_output += field.rjust(FIELD_WIDTH[n_field], '0')
                    n_field += 1
                    field = ""
                else:
                    field += _
            line_output = line_output.replace(',', '')
            endchar = ",\n"
            if ins == tuple(cpi.keys())[-1]:
                endchar = ""
            control_memory += f"x\"{hex(int(line_output, 2))[2:].rjust(22, '0')}\"{endchar}"
        # code to microadress generation
        microcomma = ","
        if ins == tuple(cpi.keys())[-1]:
            microcomma = ""
        code_to_micro += f"{opcodes[ins]} => ('0',x\"{hex(ins_count)[2:].rjust(3, '0')}\"){microcomma}\t-- Opcode {bin(opcodes[ins])[2:].rjust(7, "0")}\n"
        ins_count += cpi[ins]
    fd.close()
    return control_memory, code_to_micro

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"USAGE: python {sys.argv[0]} <file.csv> <isa-name>")
    else:
        ctrl_mem, cod2maddr = parse_csv(sys.argv[1]) 
        with open(f"{sys.argv[2]}-control_memory.txt", "w") as mem_fd:
            mem_fd.write(ctrl_mem)
        with open(f"{sys.argv[2]}-co2maddr.txt", "w") as maddr_fd:
            maddr_fd.write(cod2maddr)
    print("*** finish ***")
