*******************************************************************************;
* Program           : prepare-abc-for-nsrr.sas
* Project           : National Sleep Research Resource (sleepdata.org)
* Author            : Michelle Reid (MLR)
* Date Created      : 20180712
* Purpose           : Prepare Apnea, Bariatric, CPAP Study data
*                       for deposition on sleepdata.org.
* Revision History  :
*   Date      Author    Revision
*   
*******************************************************************************;

*******************************************************************************;
* Establish ABC options and libraries
*******************************************************************************;

*set ABC libraries and options;
libname abc "\\rfawin\bwh-sleepepi-home\projects\trials\abc\Data\SAS\_datasets";
options nofmterr;

%let version = 0.1.0.beta1;

***************************************************************************************;
* Grab permanent RedCAP dataset
***************************************************************************************;
  data redcap;
    set abc.abcredcap;
  run;

*******************************************************************************;
* Process data from RedCAP
*******************************************************************************;
data abc_screening;
set redcap;
if redcap_event_name = 'screening_arm_0';

  *recode and create demographic variables;
  studyid = elig_studyid;
  ethnicity = elig_ethnicity; 

  if elig_racewhite = 1 then race = 1;
  else if elig_raceblack = 1 then race = 2;
  else race = 3;

keep studyid ethnicity race;
run;

proc sort data = abc_screening;
  by studyid;
run;

data abc_base;
set redcap;
if redcap_event_name = '00_bv_arm_1' and hrbp_studyvisit = 0;

  gender = rand_gender;
  rand_treatmentarm = tx_txarm;
  surgerydate = tx_lgbmile2;
  studyid = elig_studyid;

  visitdate_base = tx_randdate;
  format visitdate_base mmddyy10.;

  age_base = (tx_randdate - rand_date_of_birth) / 365.25;

  bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

  daystotx = surgerydate - visitdate_base;

  if surgerydate > . then surgery_occurred = 1;
  else surgery_occurred = 0;

  visitdate = 01;

keep studyid visitdate age_base gender rand_treatmentarm surgery_occurred daystotx bmi visitdate_base;
run;

data abc_partial_base;
set abc_base;
  keep studyid age_base gender rand_treatmentarm visitdate_base;
run;

data abc_psg_base;
set abc.abcpsg;
if studyvisit = 0;

  ahi_a0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_o0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_c0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop ) / slpprdp;

  cai_c0 = 60 * (carbp + carop + canbp + canop ) / slpprdp;
  oai_o0 = 60 * (oarbp + oarop + oanbp + oanop ) / slpprdp;
  hi_h0 = 60 * (hrembp + hrop + hnrbp + hnrop + urbp + urop + unrbp + unrop) / slpprdp;

keep studyid ahi_a0h3 ahi_a0h4 ahi_a0h3a ahi_a0h4a ahi_o0h3 ahi_o0h4 ahi_o0h3a ahi_o0h4a ahi_c0h3 ahi_c0h4 ahi_c0h3a ahi_c0h4a cai_c0 oai_o0 hi_h0;
run;

proc sort data = abc_base;
  by studyid;
run;

proc sort data = abc_partial_base;
  by studyid;
run;

proc sort data = abc_psg_base;
  by studyid;
run;


data abc_09;
set redcap;
if redcap_event_name = '09_fu_arm_1' and hrbp_studyvisit = 09;

  studyid = elig_studyid;
  visitdate_nine = hrbp_date;
  format visitdate_nine mmddyy10.;
  format tx_randdate mmddyy10.;

  bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

  visitdate = 09;

keep studyid visitdate bmi visitdate_nine;
run;

data abc_psg_09;
set abc.abcpsg;
if studyvisit = 9;

  ahi_a0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_o0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_c0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop ) / slpprdp;

  cai_c0 = 60 * (carbp + carop + canbp + canop ) / slpprdp;
  oai_o0 = 60 * (oarbp + oarop + oanbp + oanop ) / slpprdp;
  hi_h0 = 60 * (hrembp + hrop + hnrbp + hnrop + urbp + urop + unrbp + unrop) / slpprdp;

keep studyid ahi_a0h3 ahi_a0h4 ahi_a0h3a ahi_a0h4a ahi_o0h3 ahi_o0h4 ahi_o0h3a ahi_o0h4a ahi_c0h3 ahi_c0h4 ahi_c0h3a ahi_c0h4a cai_c0 oai_o0 hi_h0;
run;

proc sort data = abc_09;
  by studyid;
run;

proc sort data = abc_psg_09;
  by studyid;
run;

data abc_18;
set redcap;
if redcap_event_name = '18_fu_arm_1' and hrbp_studyvisit = 18;

  studyid = elig_studyid;
  visitdate_eighteen = hrbp_date;
  format visitdate_eighteen mmddyy10.;

  age = (visitdate_eighteen - rand_date_of_birth) / 365.25;

  bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

  visitdate = 18;

 keep studyid visitdate bmi visitdate_eighteen;
run;

data abc_psg_18;
set abc.abcpsg;
if studyvisit = 18;

  ahi_a0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_a0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_o0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + oarbp + oarop + oanbp + oanop ) / slpprdp;
  ahi_o0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + oarbp + oarop + oanbp + oanop ) / slpprdp;

  ahi_c0h3 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h3a = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop ) / slpprdp;
  ahi_c0h4a = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop ) / slpprdp;

  cai_c0 = 60 * (carbp + carop + canbp + canop ) / slpprdp;
  oai_o0 = 60 * (oarbp + oarop + oanbp + oanop ) / slpprdp;
  hi_h0 = 60 * (hrembp + hrop + hnrbp + hnrop + urbp + urop + unrbp + unrop) / slpprdp;

keep studyid ahi_a0h3 ahi_a0h4 ahi_a0h3a ahi_a0h4a ahi_o0h3 ahi_o0h4 ahi_o0h3a ahi_o0h4a ahi_c0h3 ahi_c0h4 ahi_c0h3a ahi_c0h4a cai_c0 oai_o0 hi_h0;
run;

proc sort data = abc_18;
  by studyid;
run;

proc sort data = abc_psg_18;
  by studyid;
run;

data abc_base_f;
merge abc_screening abc_base abc_psg_base;
by studyid;

  age = age_base;
  if rand_treatmentarm = . then delete;
  drop age_base visitdate_base visitdate daystotx surgery_occurred;
run;

data abc_09_f;
merge abc_screening abc_partial_base abc_09 abc_psg_09;
by studyid;

  daystobase_09 = visitdate_nine - visitdate_base;
  age = (age_base + (daystobase / 365));
  if visitdate = . then delete;
  drop age_base visitdate_base visitdate_nine visitdate daystobase;
run;

data abc_18_f;
merge abc_screening abc_partial_base abc_18 abc_psg_18;
by studyid;

  daystobase_18 = visitdate_eighteen - visitdate_base;
  age = (age_base + (daystobase / 365));
  if visitdate = . then delete;
  drop age_base visitdate_base visitdate_eighteen visitdate daystobase;
run;

*Export dataset;
*baseline;
proc export data= abc_base_f
            outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-visit-00-dataset&version..csv" 
            dbms=csv 
            replace;
run;

proc export data= abc_09_f
            outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-visit-09-dataset&version..csv" 
            dbms=csv 
            replace;
run;

proc export data= abc_18_f
            outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-visit-18-dataset&version..csv" 
            dbms=csv 
            replace;
run;

