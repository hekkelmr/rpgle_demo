**FREE
/copy *libl/csoRpgCpy,csoMqPrg
 
Dcl-S @kentekenAGS Char(6);
Dcl-S @meldcode    Char(4);
Dcl-S @atlTab      Zoned(6:0) DIM(10);
Dcl-S @brandstof   Char(1);
Dcl-S @datum1      Char(8);
Dcl-S @bouwdatum   Char(8);
Dcl-S @voertuig    Char(1);
Dcl-S @ledigGewicht Char(5);
Dcl-S @bpmBedr     Char(6);
Dcl-S @catPrijsIncl Char(7);
Dcl-S @catPrijsExcl Char(7);
Dcl-S @brandstof2  Char(1);
Dcl-S @merk        Char(20);
Dcl-S @model       Char(15);
Dcl-S @type        Char(20);
Dcl-S @motorvermogen Char(4);
Dcl-S @cilinderInh Char(4);
Dcl-S @aantCilinders Char(2);
Dcl-S @koetswerk   Char(8);
Dcl-S @aantDeuren  Char(1);
Dcl-S @topsnelheid Char(3);
Dcl-S @acceleratie Char(3);
Dcl-S @gewicht     Char(5);
Dcl-S @turbo       Char(1);
Dcl-S @laadvermogen Char(5);
Dcl-S @afschrijving Char(1);
Dcl-S @automaat    Char(1);
Dcl-S @catPrijs    Char(6);
Dcl-S @btwNwprijs  Char(6);
Dcl-S @bpmNwprijs  Char(6);
Dcl-S @iDate       Char(8);
Dcl-S @iSign       Char(3);
Dcl-S @iRtcd       Char(2);
 
// ?***********************************************************************
// ?entry procedure definitie
// ?***********************************************************************
Dcl-PI TstMqPrg_pgm;
End-PI;
 
// ?Aanroepen Audascan met soort, kenteken en meldcode
@kentekenAGS = 'V43GLN';
@meldcode    = '8796';
@voertuig    = 'B';
 
csoMqPrg_pgm(@kentekenAGS:
                    @meldcode:
                    @atlTab:
                    @brandstof:
                    @datum1:
                    @bouwdatum:
                    @voertuig:
                    @ledigGewicht:
                    @bpmBedr:
                    @catPrijsIncl:
                    @catPrijsExcl:
                    @brandstof2:
                    @merk:
                    @model:
                    @type:
                    @motorvermogen:
                    @cilinderInh:
                    @aantCilinders:
                    @koetswerk:
                    @aantDeuren:
                    @topsnelheid:
                    @acceleratie:
                    @gewicht:
                    @turbo:
                    @laadvermogen:
                    @afschrijving:
                    @automaat:
                    @catPrijs:
                    @btwNwprijs:
                    @bpmNwprijs:
                    @iDate:
                    @iSign:
                    @iRtcd);
 
if (@iRtcd = 'ER');
  ldaErr = 9999;
  ldaErm = 'Fout in Audascan';
else;
  if (@catPrijs = *blanks);
    ldaErr = 9999;
    ldaErm = 'Geen cataloguswaarde beschikbaar in Audascan';
  else;
    molOcw = %dec(@catPrijs:6:0);
    molCwe = molOcw;
    if (@btwNwprijs <> *blanks);
      molCwe = molOcw - %dec(@btwNwprijs:6:0);
    endif;
    if (@bpmNwprijs <> *blanks);
      molBpb = %dec(@bpmNwprijs:6:0);
    endif;
    if (molIeb = 'N');
      molBdrWrd = molOcw + molAc1;
    else;
      molBdrWrd = molCwe + molAc1;
    endif;
    if (molIvr = 'J');
      molBdrWrd = molBdrWrd - molBpb;
    endif;
  endif;
endif;
 
*inLr = *on;
return;

