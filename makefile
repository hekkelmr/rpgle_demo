
BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB)
SHELL=/QOpenSys/usr/bin/qsh

all: depts.pgm.sqlrpgle employees.pgm.sqlrpgle testsfl.pgm.rpgle json.pgm.rpgle CSCRGFS50.pgm.RPGLE
test: testsfl.pgm.rpgle

## Targets

depts.pgm.sqlrpgle: depts.dspf department.table
employees.pgm.sqlrpgle: emps.dspf employee.table
testsfl.pgm.rpgle: testpf.pf

## Rules

%.pgm.sqlrpgle: qrpglesrc/%.pgm.sqlrpgle
	system -s "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('$<') COMMIT(*NONE) DBGVIEW(*SOURCE) OPTION(*EVENTF) COMPILEOPT('INCDIR(''qrpgref'')')"

%.pgm.rpgle: qrpglesrc/%.pgm.rpgle
	system -s "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('$<') DBGVIEW(*SOURCE) "

%.dspf:
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./qddssrc/$*.dspf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$*.mbr') MBROPT(*REPLACE)"
	system -s "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*)"

%.pf:
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./qddssrc/$*.pf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$*.mbr') MBROPT(*REPLACE)"
	system -s "DLTF FILE($(BIN_LIB)/$*)"
	system -s "CRTPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*)"

%.table: qddssrc/%.table
	liblist -c $(BIN_LIB);\
	system "RUNSQLSTM SRCSTMF('$<') COMMIT(*NONE)"