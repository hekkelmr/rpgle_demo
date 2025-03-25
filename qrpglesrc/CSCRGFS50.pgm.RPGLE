**FREE
//H DatEdit(*YMD)
// ******************************************************************
// -Programmanaam : CSCRGFS50
// -Doel          : Verwerken invoerbestand zacht regres Diba SAP
// -Bolnr         : 16000M
// -Programmeur   : Paul Adema
// -Datum         : November 2012
// -Wijzigingen   :
// 
// Datum     Door        Bolnr  Omschrijving
// 20130304  Paul Adema  16000M Interface Diba bestand gewijzigd
// 20140203  Joop Gerritsma     IM11000099315 'lege'  batch verbetering
// 20200207  Jan  Bijlsma       BBAN IBAN     extra veld IBAN
// ******************************************************************  ***
// Invoer bestand
Dcl-F ceiDibPf  Usage(*Input) 
                Keyed 
                rename(reiDib:reiDibPf);

// Uitvoer bestand
Dcl-F cscFs50Pf Usage(*Input:*Output) 
                Keyed 
                rename(rscFs50:rFs50Pf);

/copy *libl/cscRpgCpy,cscrgfs50
/copy *libl/jzzRpgCpy,jzzrg004

Dcl-C HLPDIGITS     CONST('0123456789');
Dcl-C HLPNEGATIVE   CONST('}JKLMNOPQR');
Dcl-C HLPPOSITIVE   CONST('{ABCDEFGHI');
Dcl-S hlpBedragA    Char(13);
Dcl-S hlpBedragN    Zoned(13:0);
Dcl-S hlpPos        Zoned(2:0);

// ---------------------------------------------------*
// Record Types                                       *
// ---------------------------------------------------*
Dcl-DS f50Vld00;
  recTyp00       Char(2)    Pos(1);
  vlgNmr00       Char(3)    Pos(19);
End-DS;

Dcl-DS f50Vld01 qualified;
  recTyp01       Char(2)    Pos(1);
  rekNmr01       Char(10)   Pos(3);
  dafVnr01       Char(4)    Pos(13);
  mutVnr01       Char(10)   Pos(17);
  tegRek01       Char(10)   Pos(27);
  tegRhd01       Char(24)   Pos(37);
  herCde01       Char(5)    Pos(61);
  datBkn01       Char(8)    Pos(66);
  datVal01       Char(8)    Pos(74);
  datTrs01       Char(8)    Pos(82);
  betKen01       Char(16)   Pos(90);
  nvrGeg01       Char(29)   Pos(106);
  omSchr01       Char(256)  Pos(135);
  bedrag01       Char(13)   Pos(391);
  inddcr01       Char(1)    Pos(404);
  cdeVal01       Char(3)    Pos(405);
  mutTyp01       Char(5)    Pos(408);
  usrIdd01       Char(5)    Pos(413);
  mutSrt01       Char(5)    Pos(418);
  pcdTrk01       Char(6)    Pos(423);
  mutNro01       Char(10)   Pos(429);
  infAnv01       Char(30)   Pos(439);
  trsDat01       Char(8)    Pos(469);
  trsTyd01       Char(5)    Pos(477);
  srtSlt01       Char(1)    Pos(482);
  hrkSlt01       Char(20)   Pos(483);
  IBAN01         Char(34)   Pos(503);
  resOpv01       Char(11)   Pos(537);
End-DS;

// ---------------------------------------------------*
// Hulpvelden                                        *
// ---------------------------------------------------*
Dcl-S @hlpVlgNmr   Packed(3:0);
Dcl-S @dtaVlgNmr   Packed(3:0);
Dcl-S @hlpRecTel   Packed(5:0);
Dcl-S @hlpDatIn    Zoned(8:0);

// ***********************************************************************
// entry procedure definitie
// ***********************************************************************
Dcl-PI cscrgfs50_Pgm;
  @intVlgNrOud   Char(3);
  @intVlgNrNw    Char(3);
  @intFoutCd     Char(2);
End-PI;

//  =====================================================================

initialisatie(f50Vld00:recTyp00:@dtaVlgNmr:@intVlgNrOud:vlgNmr00:@hlpVlgNmr:@intFoutCd:@intVlgNrNw);
if (@intFoutCd = '00');
  verwerking(f50Vld01:recTyp01:@hlpRecTel);
endif;
*inLr = *on;
return;


// ======================================================================
// Controle volgnumer zacht regres
// =================================================================
// 1 - Bepaal volgnummer uit het eerste record van Ceidibpf(type 00)
// 2 - Bepaal hlpnummer = volgnummer (uit ceidibpf) - 1
// 3 - Vanuit DTAARA CSCDTVZR wordt volgnummer oud bepaald in CLP
//     programma CSCCLFS50.(input parameter in dit programma)
// 4 - Hlpnummer moet gelijk zijn @intVlgNrOud uit DTAARA CSCDTVZR
// ==================================================================
Dcl-Proc initialisatie;
  Dcl-Pi *N;
    pf50Vld00 LikeDS(f50Vld00);
    precTyp00 Like(recTyp00);
    p@dtaVlgNmr Like(@dtaVlgNmr);
    p@intVlgNrOud Like(@intVlgNrOud);
    pvlgNmr00 Like(vlgNmr00);
    p@hlpVlgNmr Like(@hlpVlgNmr);
    p@intFoutCd Like(@intFoutCd);
    p@intVlgNrNw Like(@intVlgNrNw);
  End-Pi;

  read  reiDibPf;
  if (not %eof);
    pf50Vld00       = dibText;
    if (precTyp00    = '00');
      p@dtaVlgNmr   =  %dec(p@intVlgNrOud:3:0);

      // Bepalen vorig volgnr. Max volgnr is 999!
      if (%dec(pvlgNmr00:3:0) = 1);
        // Volgnr is over de kop gegaan
        p@hlpVlgNmr = 999;
      else;
        // Volgnr is huidige volgnr - 1
        p@hlpVlgNmr = (%dec(pvlgNmr00:3:0) - 1);
      endif;

      if (p@hlpVlgNmr <> @dtaVlgNmr1);
        p@intFoutCd = '99';
      else;
        p@intFoutCd = '00';
        // Nieuwe volgnummer wordt terugegeven aan CL programma CSCCLFS50
        // en geplaatst in de DTAARA CSCDTVZR
        p@intVlgNrNw = pvlgNmr00;
      endif;
    else;
      p@intFoutCd = '99';
    endif;
  endif;


End-Proc;

// =================================================================
// =================================================================
Dcl-Proc verwerking;
  Dcl-Pi *N;
    pf50Vld01 LikeDS(f50Vld01);
    precTyp01 Like(recTyp01);
    p@hlpRecTel Like(@hlpRecTel);
  End-Pi;

  // Verwerk alleen recordtypes '01'
  read  reiDibPf;
  dow (not %eof);
    pf50Vld01 = dibText;
    if (precTyp01 = '01');
      schrijfZachtRegres(recTyp01:rekNmr01:dafVnr01:mutVnr01:tegRek01:tegRhd01:herCde01:@hlpDatIn:datBkn01:datVal01:datTrs01:betKen01:nvrGeg01:omSchr01:hlpBedragA:bedrag01:hlpBedragN:hlpPos:inddcr01:cdeVal01:mutTyp01:usrIdd01:mutSrt01:pcdTrk01:mutNro01:infAnv01:trsDat01:trsTyd01:srtSlt01:hrkSlt01:resOpv01:IBAN01);
      p@hlpRecTel = p@hlpRecTel + 1;
    endif;
    read  reiDibPf;
  enddo;

End-Proc;

// =================================================================
// =================================================================
Dcl-Proc schrijfZachtRegres;
  Dcl-Pi *N;
    p_recTyp01 Like(recTyp01);
    prekNmr01 Like(rekNmr01);
    pdafVnr01 Like(dafVnr01);
    pmutVnr01 Like(mutVnr01);
    ptegRek01 Like(tegRek01);
    ptegRhd01 Like(tegRhd01);
    pherCde01 Like(herCde01);
    p@hlpDatIn Like(@hlpDatIn);
    pdatBkn01 Like(datBkn01);
    pdatVal01 Like(datVal01);
    pdatTrs01 Like(datTrs01);
    pbetKen01 Like(betKen01);
    pnvrGeg01 Like(nvrGeg01);
    pomSchr01 Like(omSchr01);
    phlpBedragA Like(hlpBedragA);
    pbedrag01 Like(bedrag01);
    phlpBedragN Like(hlpBedragN);
    phlpPos Like(hlpPos);
    pinddcr01 Like(inddcr01);
    pcdeVal01 Like(cdeVal01);
    pmutTyp01 Like(mutTyp01);
    pusrIdd01 Like(usrIdd01);
    pmutSrt01 Like(mutSrt01);
    ppcdTrk01 Like(pcdTrk01);
    pmutNro01 Like(mutNro01);
    pinfAnv01 Like(infAnv01);
    ptrsDat01 Like(trsDat01);
    ptrsTyd01 Like(trsTyd01);
    psrtSlt01 Like(srtSlt01);
    phrkSlt01 Like(hrkSlt01);
    presOpv01 Like(resOpv01);
    pIBAN01 Like(IBAN01);
  End-Pi;

  clear rfs50Pf;

  f50Rectyp = p_recTyp01;             // Record Type
  f50RekNmr = prekNmr01;             // Rekeningnummer
  f50DafVnr = %dec(pdafVnr01:4:0);   // Dagafschrift volgnummer
  f50MutVnr = pmutVnr01;             // Mutatie volgnummer
  f50TegRek = ptegRek01;             // Tegenrekeningnummer
  f50TegRhd = ptegRhd01;             // Tegenrekeninghouder
  f50HerCde = pherCde01;             // Herkomstcode
  p@hlpDatIn = %dec(pdatBkn01:8:0);       f50DatBkn = jzzrg004_getDat(p@hlpDatIn); // Boekingdatum
  p@hlpDatIn = %dec(pdatVal01:8:0);
  f50DatVal = jzzrg004_getDat(p@hlpDatIn); // Valutadatum
  p@hlpDatIn = %dec(pdatTrs01:8:0);
  f50DatTrs = jzzrg004_getDat(p@hlpDatIn); // Transactiedatum
  f50BetKen = pbetKen01;             // Kenmerk
  f50NvrGeg = pnvrGeg01;             // Navraaggegevens
  f50Omschr = pomSchr01;             // Omschrijving
  // Omzetten bedrag
  omzettenBedragVeld(phlpBedragA:pbedrag01:phlpBedragN:phlpPos);
  f50Bedrag = phlpBedragN;           // Bedrag
  f50IndDcr = pinddcr01;             // Indicatie Debet/Credit
  f50CdeVal = pcdeVal01;             // Valutacode
  f50MutTyp = pmutTyp01;             // Mutatietype
  f50UsrIdd = %dec(pusrIdd01:5:0);   // GebruikerID
  f50MutSrt = pmutSrt01;             // Mutatiesoortcode
  f50PcdTrk = ppcdTrk01;             // Postcode tegenrekening
  f50MutNro = pmutNro01;             // Mutatievnr oorspronkelijk
  f50InfAnv = pinfAnv01;             // Informatie aanvullend
  p@hlpDatIn = %dec(ptrsDat01:8:0);
  f50TrsDat = jzzrg004_getDat(p@hlpDatIn); // Transactiedatum
  f50TrsTyd = ptrsTyd01;             // Transactietijd
  f50SrtSlt = psrtSlt01;             // Soort sleutel
  f50HrkSlt = phrkSlt01;             // Herkende sleutel
  f50ResOpv = presOpv01;             // Opvulling
  f50IBAN   = pIBAN01;               // IBAN

  write rFs50Pf;

End-Proc;

// =================================================================
Dcl-Proc omzettenBedragVeld;
  Dcl-Pi *N;
    phlpBedragA Like(hlpBedragA);
    pbedrag01 Like(bedrag01);
    phlpBedragN Like(hlpBedragN);
    phlpPos Like(hlpPos);
  End-Pi;

  phlpBedragA   = pbedrag01;
  phlpBedragN   = 0;
  phlpPos       = 0;
  phlpPos = %scan(%subst(phlpBedragA:13:1):HLPNEGATIVE);
  if (phlpPos <> 0);
    %subst(phlpBedragA:13:1) = %xlate(HLPNEGATIVE:HLPDIGITS:
                                   %subst(phlpBedragA:13:1));
    phlpBedragN = %dec(phlpBedragA:13:0);
    return;
  endif;

  phlpPos = %scan(%subst(phlpBedragA:13:1):HLPPOSITIVE);
  if (phlpPos <> 0);
    %subst(phlpBedragA:13:1) = %xlate(HLPPOSITIVE:HLPDIGITS:
                                   %subst(phlpBedragA:13:1));
    phlpBedragN = %dec(phlpBedragA:13:0);
    return;
  endif;

  phlpBedragN = %dec(phlpBedragA:13:0);

End-Proc;