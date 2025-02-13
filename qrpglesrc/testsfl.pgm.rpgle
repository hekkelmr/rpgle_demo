**free
ctl-opt dftactgrp(*no) actgrp(*new); // Gebruik *NEW activation group

// Bestandsdefinities
dcl-f TESTPF usage(*input)
             prefix('F_')
             usropn;          // Fysieke file met de records
dcl-f MYDSPF workstn
             sfile(SFL1:rrn)
             prefix('D_');                // Display file met de subfile

// Variabelen voor subfile
dcl-s RecordFound ind;               // Indicator of er records zijn
dcl-s rrn packed(5);

// Indicatoren voor subfile bediening
dcl-s EndOfFile ind;                 // Indicator voor einde van file

/include 'qrpgref/constants.rpgleinc'

// Start programma
open TESTPF;
// Stap 1: Scherm leegmaken en subfile resetten
*in40 = *on;
write sflctl;
*in40 = *off;

rrn = 0;

// Stap 2: Records lezen en vullen in subfile
EndOfFile = *off;
RecordFound = *off;
dow (not EndOfFile);
  read TESTPF;
  if (%eof(TESTPF));
    EndOfFile = *on;
  else;
    rrn = rrn + 1;
    D_EMPID = F_EMPID;          // Vul subfilevelden
    D_EMPNAME = F_EMPNAME;

    write SFL1;          // Voeg record toe aan de subfile
    RecordFound = *on;
  endif;
enddo;

// Stap 3: Subfile tonen als er records zijn
if (RecordFound);
  *in41 = *on;
  *in42 = *on;
  exfmt SFLCTL;           // Toont de subfile en wacht op invoer
  *in41 = *off;
  *in42 = *off;
else;
  dsply ('Geen records gevonden!') '';
endif;

// Stap 4: Beëindigen als gebruiker F3 drukt
if (*in03);
  return;
endif;

close TESTPF;
