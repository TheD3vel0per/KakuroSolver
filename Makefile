SWIPL_FLAGS = -O --stand_alone=true
INPUT = kakurosolver.pl
OUTPUT = kakurosolver

kakurosolver:
	swipl $(SWIPL_FLAGS) -o $(OUTPUT) -c $(INPUT)

all: kakurosolver