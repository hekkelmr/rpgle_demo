     H debug bnddir('CSOMQBND':'CIMBNDDIR')
      // Debug dftactgrp(*no) actgrp ('QILE') DATEDIT(*YMD)
      //?***********************************************************************
      //?-Programma: CIMRG067
      //?-Doel     : Het toevoegen van een Polisblad aan een Dispatch Dossier
      //?-Datum    : Februari 2019
      //?-Auteur   : Jan Bijlsma
      //?-Wijz
      //? 2019-08-07 : JBI : Lengte documentnaam max 50
      //? 2024-09-23 : RBO : 36176994 sorteren van de polisbladen om de juiste
      //?                    te kunnen selecteren via array
      //?***********************************************************************
     fCIMMQQPF  IF   E           K DISK    RENAME(CIMMQQPF:rMqqpf)
     fCSCCLM01  IF   E           K DISK
     fCSCSCH01  IF   E           K DISK
     fCSCEXP01  uf   e           k disk    commit rename(rexp:rexp01)
      //?-----------------------------------------------------------------------
      //?procedure prototypes
      //?-----------------------------------------------------------------------
      //?prototypes algemeen:
      /copy *libl/cimRpgCpy,cimrg992B
      /copy *libl/cimRpgCpy,cimrg067
      /copy *libl/cgdRpgCpy,cgdrgT01
      /copy *libl/czzRpgCpy,czzrg001
      /copy *libl/czzRpgCpy,czzrg003
 
      //?-------------------------------------------------------------------
      //?RPG-functies tbv MQ-calls  : CIMRGXML via CIMBNDDIR
      //?-------------------------------------------------------------------
      //?Plaatsen vraag op MQ-queue
     d CIMRGXMPUT      pr            10i 0 extProc('CIMRGXMPUT')
     d  r_Handle                     10i 0
     d  r_LenMsg                     10i 0
     d  r_Msg1                         A   LEN(3999999)
     d  r_Reply                      48A
     d  r_CorId                      24A
     d  r_Reason                     10i 0
      //?Lezen antwoord van MQ-queue
     d CIMRGXMGET      pr            10i 0 extProc('CIMRGXMGET')
     d  r_Handle                     10i 0
     d  r_Msg1                         A   LEN(3999999)
     d  r_LenMsg                     10i 0
     d  r_MsgId                      24A
     d  r_CorId                      24A
     d  r_Wait                       10i 0
     d  r_Reason                     10i 0
      //?Openen MQ-queue
     d CIMRGXMOPN      pr            10i 0 extProc('CIMRGXMOPN')
     d  r_Handle                     10i 0
     d  r_Mode                        1A
     d  r_Name                       48A
     d  r_Reason                     10i 0
      //?Close  MQ-queue
     d CIMRGXMCLS      pr            10i 0 extProc('CIMRGXMCLS')
     d  r_Handle                     10i 0
     d  r_Reason                     10i 0
      //?Disconnect van Qmanager
     d CIMRGXMDIS      pr            10i 0 extProc('CIMRGXMDIS')
     d  r_Reason                     10i 0
      //?Conversie CCSIDs
     d CIMRGCVT        pr            10i00
     d p_fun                         10i00
     d p_inp_ptr                       *
     d p_inp_len                     10i00
     d p_out_ptr                       *
     d p_out_len                     10i00
     d p_rtn_cde                     10i00
 
      //?-------------------------------------------------------------------
      //?Plaatsen document in folder
      //?-------------------------------------------------------------------
     d CZZCL006_pgm    pr                  extPgm('CZZCL006')
     d i@directory                   50a
     d i@folder                      50a
     d i@object                      12a
     d i@omschrijving                50a
     d u@rtcd                         2a
      //?-------------------------------------------------------------------
      //?Loggen van vraag/antwoord
      //?-------------------------------------------------------------------
     d CIMRG800_pgm    pr                  extProc('CIMRG800')
     d  p_LogSrvJob                  10A
     d  p_LogMsgID                    1A
     d  p_LogTim                       Z
     d  p_LogMsg                  65535A
     d  p_Loggen                      1A
      //?-------------------------------------------------------------------
      //?Schrijven van een message in het joblog
      //?-------------------------------------------------------------------
     D Dialog          PR                  extPgm('CZZRGDIAG')
     D                             1024A
     D                                4A
 
     d @dialgSiz       s              4a
     d @dialgMsg       s           1024a
      //?-----------------------------------------------------------------------
      //?procedure prototypes tbv QCMDEXEC
      //?-----------------------------------------------------------------------
     d excCmd          pr                  extPgm('QCMDEXC')
     d  @cmdString                 3000    options(*varSize)
     d                                     const
     d  @cmdLength                   15p 5 const
     d  @cmdOpt                       3a   options(*noPass)
     d                                     const
      //?-----------------------------------------------------------------------
      //?job-variabelen
      //?-----------------------------------------------------------------------
     D PgmStatus      SDS
     D  userid               254    263
     D  jobnr                264    269
 
      //?-----------------------------------------------------------------------
      //?Werkvelden
      //?-----------------------------------------------------------------------
     d @vandaag        s              8S 0
     d @time           ds                  qualified
     d  hhmmss                        6a
     d  hhmm                          4a   overlay(@time)
     d  hhmmn                         4s00 overlay(@time)
     d @dateSch        s             10a
 
     d @waarde         s            250a
     d @error          s              2a
     d @err            s               n
 
     d @ckd            s              3a
     d @exp            s              3a
     d @ok             s               n
     d @fase           s             10a
     d @toegevoegd     s              1a
 
     d @cmdString      s           3002a   varying
     d @melding        s             40a
     d @msg            s            256a
     d @ond            s             40a
 
     d @foutcode       s              2a
     d @foutmsg        s             40a
      //?tbv plaatsen op folder en mailen
     d @directory      s             50a
     d @folder         s             50a
     d @mailadres      s             50a
     d @naamdoc        s             12a
     d @omschrijving   s             50a
     d @retourcode     s              2a
     d @xmlKlein       s          32767a
     d @VARFIELD       s        3999999a   varying
     d @VARLENGTH      s             10P 0
      //?tbv ophalen nieuw nummer
     d @vldn           s              6a
     d @vlgn           s              9a
     d @date           s              8a
     d @rtcd           s              2a
 
     D                 DS
     D Timestamp                       z
     D  Uur                   12     13
     D  min                   15     16
     D  sec                   18     19
     d  milisec               21     22
 
     d HlpSchNum       s             10p 0
     d HlpClmNum       s              5p 0
     d HlpExpNum       s              5p 0
      //?--------------------------------------------------*
      //?Hulpvelden                                        *
      //?--------------------------------------------------*
      //?... om een Blob op te halen uit IFS
     d MY_Blob         S                   SQLTYPE(BLOB:3999999)
     d MY_file         S                   SQLTYPE(BLOB_FILE)
      //?... een IFS Stream-File die als BLOB wordt ingelezen
     D OUTFILE         S                   SQLTYPE(BLOB_FILE)
     D SQL_FILE_OVERWRITE...
     D                 c                   const(16)
     d SQL_FILE_READ...
     d                 c                   const(2)
     d @input64        s            200a
     d @output64       s            268a
     d @data64         s               a   LEN(3999999)
     d @length         s             10i 0
     d @div            s             10i 0
     d @rem            s             10i 0
     d @t              s             10i 0
     d @l              s             10i 0
     d @QQ             s             10i 0
     d @start          s             10i 0
      //?....
     d pos             s             10s 0
     d char8           s              8a
     d XMLwrd          s            300a
     d XMLAlles        s               A   LEN(3999999)
     d @XMLalles       s               A   LEN(3999999)
     d HlpLogV         s        3999999a   varying
     d @lengthV        s             10i 0
      //?-----------------------------------------------------------------------
      //?tbv loggen : Request / Response
      //?-----------------------------------------------------------------------
     D LogSrvJob       s             10
     D LogMsgID        s              1
     D LogMsg          s          32000
     D LogTim          s               Z
     D Loggen          s              1
 
      //?---------------------------------------------------------*
      //? Data area met waardes voor OpenText : per OTAP omgeving
      //?---------------------------------------------------------*
     d CSCOPNTXT       DS                  DTAARA('CSCOPNTXT')
      //? user
     d  @usrOpnTxt                   50A
      //? Categorie ID voor Normale Contracten
     d  @catIdnc                     10A
      //? Categorie ID voor VerzamelContracten
     d  @catIdvc                     10A
      //? parentID voor Normale Contracten
     d  @parentIdnc                  10A
      //? parentID voor VerzamelContracten
     d  @parentIdvc                  10A
      //? automatisch polisblad toevoegen aan Dossier
     d  @polisblad                    1A
      //? reserve
     d  @reserve                      9A
      //? pdfdir
     d  @pdfdir                      50A
 
      //?-----------------------------------------------------------------------
      //?tbv vullen OPENTEXT request
      //?-----------------------------------------------------------------------
     d @idBlad         s            100a
     d @x              s              5S00
     d @y              s              5S00
       //?In eerste instantie oude code maar even afgesterd.
       //d @idCurrent      s            100a
       //d @nameCurrent    s            100a
       //d @nameBlad       s            100a
       //d @dateCurrent    s            100a
       //d @dateBlad       s            100a
       //d @bewaarId       s               n
       //d @gevonden       s               n
 
     d @docBlob        s               A   LEN(3999999)
     d @docName        s            100a
     d @docType        s            100a
 
      //?-----------------------------------------------------------------------
      //?tbv ontleden XML antwoord  :
      //?-----------------------------------------------------------------------
     D Pos0            S              7S 0
     D Pos1            S              7S 0
     D Pos2            S              7S 0
     D Len             S              7S 0
     D WrkFld          S               A   LEN(3999999)
 
      //?-----------------------------------------------------------------------
      //?tbv MQ-afhandeling
      //?-----------------------------------------------------------------------
     D Mode            s              1
     D NaamQueue       s             48
     D Reason          s              6B 0
     D Msg1            s               A   LEN(3999999)
     D Reply           s             48
     D Antwoord        s               A   LEN(3999999)
     D MsgId           s             24
     D CorId           s             24
 
     d reason10        s             10i 0
     d OutQHandle10    s             10i 0
     d InQHandle10     s             10i 0
     d Lengte10        s             10i 0
     D InqWait10       s             10i 0
      //?omzetten CCSIDs
     d p_fun           s             10i 0
     d p_inp_ptr       s               *
     d p_inp_len       s             10i 0
     d p_out_ptr       s               *
     d p_out_len       s             10i 0
     d p_rtn_cde       s             10i 0
 
     d p_out_dta       s        3999999a   based(p_out_ptr)
 
     d HlpLogFld       s               A   LEN(3999999)
 
      //?-------------------------------------------------
      //?Structures WMB
      //?-------------------------------------------------
      //?Foutinformatie  WMB
     D Foutinformatie...
     D                 Ds                  Qualified
     D  returncode                    8
     D  foutcode                      8
     D  melding                      80
 
      //?-------------------------------------------------
      //?Structures OPENTEXT
      //?-------------------------------------------------
      //?DocumentInfos
     D DocumentInfos...
     D                 Ds                  Qualified
     D  DocumentInfo...
     D                                     LikeDs(DocumentInfo) dim(100)
     D  countDocumentInfo...
     D                                5i 0 Inz
      //?DocumentInfo
     D DocumentInfo...
     D                 Ds                  Qualified
     D  Attributes...
     D                                     LikeDs(Attributes)
     D  displayName                 400
     D  Properties...
     D                                     LikeDs(Properties)
      //?Attributes
     D Attributes...
     D                 Ds                  Qualified
     D  Attribute...
     D                                     LikeDs(Attribute) dim(100)
     D  countAttribute...
     D                                5i 0 Inz
      //?Attribute
     D Attribute...
     D                 Ds                  Qualified
     D  name                        100
     D  value                       100
 
      //?Properties
     D Properties...
     D                 Ds                  Qualified
     D  Category...
     D                                     LikeDs(Category)
      //?Category
     D Category...
     D                 Ds                  Qualified
     D  id                          100
     D  Property...
     D                                     LikeDs(Property) dim(100)
     D  countProperty...
     D                                5i 0 Inz
      //?Property
     D Property...
     D                 Ds                  Qualified
     D  name                        100
     D  value                       100
      //?pageDesc
     D pageDesc...
     D                 Ds                  Qualified
     D  actualCount                  10S00
     D  includeCount                 10S00
     D  listHead                     10S00
      //?-------------------
      //?GetDocumentResponse
      //?-------------------
     D GetDocumentResponse...
     D                 Ds                  Qualified
     D  SingleDocument...
     D                                     LikeDs(SingleDocument)
      //?DocumentInfos
     D SingleDocument...
     D                 Ds                  Qualified
     D  displayName                 400
     D  Properties...
     D                                     LikeDs(Properties)
     D  Variant...
     D                                     LikeDs(Variant)
      //?Variant
     D Variant...
     D                 Ds                  Qualified
     D  Blob                               LikeDs(Blob)
      //?Blob
     D Blob            Ds                  Qualified
     D  blobData                3999999A
     D  length                       10S00
     D  mimeType                    100A
     D  name                        100A
     D  nickName                    100A
     D  creationDate                 40A
     D  comment                     100A
     D  parentId                    100A
      //?-------------------------------------------------
      //?Structures DISPATCH
      //?-------------------------------------------------
      //?Header DISPATCH
     D Header          Ds                  Qualified
     D  Returncode                    8
     D  Melding                            LikeDs(Melding)
 
      //?Header.Melding
     D Melding         Ds                  Qualified
     D  Type                          1
     D  Nummer                        6
     D  Omschrijving                300
     D
      //?Detail
     D Detail          Ds                  Qualified
     D  Dossier                            LikeDs(Dossier)
 
      //?Dossier
     D Dossier         Ds                  Qualified
     D  Dossiernummer...
     D                                8a
     D  Opdracht                           LikeDs(Opdracht)
      //?Opdracht
     D Opdracht        Ds                  Qualified
     D  Nummer                        8a
     D  Bijlage                            LikeDs(Bijlage)
      //?Bijlage
     D Bijlage         Ds                  Qualified
     D  Bestandsnaam...
     D                               50a
     D  Toegevoegd                    1a
     D  Foutmelding...
     D                                     LikeDs(Foutmelding)
      //?Foutmelding
     D Foutmelding     Ds                  Qualified
     D  Code                          8a
     D  Omschrijving                 50a
      //?Te sorteren array (T) aflopend op creatiedatum en id.
     d @polisArr       s                   like(@polis) dim(1000) descend
     d @polis          ds
     d  @OTCreateDate               100a
     d  @OTDataID                   100a
     ?*
      //?***********************************************************************
      //?entry procedure definitie
      //?***********************************************************************
     d Cimrg067_pgm    pi
     d i_schadeNr                    10a
     d i_claimNr                      5a
     d i_expOpdr                      5a
     d i_msgNaam                      8a
 
************************DISCLAIMER*******************************

De informatie in dit bericht is vertrouwelijk. Het is daarom niet toegestaan dat u deze informatie openbaar maakt, vermenigvuldigt of verspreidt, tenzij de verzender aangeeft dat dit wel is toegestaan. Als dit e-mailbericht niet voor u bestemd is, vragen wij u vriendelijk maar dringend om het bericht en kopieën daarvan te vernietigen. Dit bericht is gecontroleerd op bekende virussen. Helaas kunnen wij niet garanderen dat het bericht dat u ontvangt volledig en tijdig verzonden is, of tijdig ontvangen wordt en vrij is van virussen of aantasting door derden.

**********************************************************************
/free
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

/include 'qrpgleref/constants.rpgleinc'

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
