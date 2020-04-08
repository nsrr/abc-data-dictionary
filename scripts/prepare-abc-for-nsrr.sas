*******************************************************************************;
* Program           : prepare-abc-for-nsrr.sas
* Project           : National Sleep Research Resource (sleepdata.org)
* Author            : Michelle Reid (MLR)
* Date Created      : 20180712
* Purpose           : Prepare Apnea, Bariatric, CPAP Study data
*                       for deposition on sleepdata.org.
*******************************************************************************;

*******************************************************************************;
* establish ABC options and libraries                                          ;
*******************************************************************************;
  *set ABC libraries and options;
  libname abc "\\rfawin\bwh-sleepepi-home\projects\trials\abc\Data\SAS\_datasets";
  libname abcids "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_ids";
  options nofmterr;

  %let version = 0.3.0.rc;

*******************************************************************************;
* grab permanent REDCap dataset                                                ;
*******************************************************************************;
  data redcap;
    set abc.abcredcap;
  run;

*******************************************************************************;
* create nsrrid for all screened subjects                                      ;
*******************************************************************************;

  /*

  data abc_nsrr_ids_in;
    set redcap;
    if tx_txarm > .;

    studyid = elig_studyid;

    call streaminit(20180726);
    nsrrid = rand('UNIFORM');

    keep studyid nsrrid;
  run;

  proc rank data = abc_nsrr_ids_in out = abc_nsrr_ids;
    var nsrrid;
    ranks nsrrid;
  run;

  data abcids.abcnsrrids;
    set abc_nsrr_ids;
    nsrrid = 900000 + nsrrid;
  run;

  proc export data=abcids.abcnsrrids
    outfile="\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_ids\abcnsrrids.csv"
    dbms=csv
    replace;
  run;

  */

  data abcnsrrids_in;
    set abcids.abcnsrrids;
  run;

  proc sort data=abcnsrrids_in;
    by studyid;
  run;

*******************************************************************************;
* process data from REDCap and PSG datasets
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

  proc sort data=abc_screening;
    by studyid;
  run;

  data abc_psg;
    set abc.abcpsg;

    ahi_ap0uhp3x3u = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x4u = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x3r = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x4r = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;

    oahi_oa0uhp3x3u = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x4u = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x3r = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x4r = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + oarbp + oarop + oanbp + oanop) / slpprdp;

    cahi_ca0uhp3x3u = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x4u = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x3r = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x4r = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop) / slpprdp;

    cai_ca0u = 60 * (carbp + carop + canbp + canop) / slpprdp;
    oai_oa0u = 60 * (oarbp + oarop + oanbp + oanop) / slpprdp;
    hi_hp3x0u = 60 * (hrembp + hrop + hnrbp + hnrop + urbp + urop + unrbp + unrop) / slpprdp;

    *rename variables;
    rename
      bpmavg = avglvlhr
      slpprdp = ttldursp
      timest1p = pctdursp_s1
      timest2p = pctdursp_s2
      times34p = pctdursp_s3
      timeremp = pctdursp_sr
      timest1 = ttldursp_s1
      timest2 = ttldursp_s2
      timest34 = ttldursp_s3
      timerem = ttldursp_sr
      pctlt90 = pctdursp_o90
      pctlt85 = pctdursp_o85
      pctlt80 = pctdursp_o80
      pctlt75 = pctdursp_o75
      avgsat = avglvlsa
      minsat = minlvlsa
      ;

    keep
      studyid
      studyvisit
      ahi_ap0uhp3x3u
      ahi_ap0uhp3x4u
      ahi_ap0uhp3x3r
      ahi_ap0uhp3x4r
      oahi_oa0uhp3x3u
      oahi_oa0uhp3x4u
      oahi_oa0uhp3x3r
      oahi_oa0uhp3x4r
      cahi_ca0uhp3x3u
      cahi_ca0uhp3x4u
      cahi_ca0uhp3x3r
      cahi_ca0uhp3x4r
      cai_ca0u
      oai_oa0u
      hi_hp3x0u
      bpmavg
      slpprdp
      timeremp
      times34p
      timest1p
      timest2p
      timest2
      timest34
      timest1
      timerem
      pctlt90
      pctlt85
      pctlt80
      pctlt75
      avgsat
      minsat
      bpmavg
      ;
  run;

  proc sort data=abc_psg;
    by
      studyid
      studyvisit
      ;
  run;

  data abc_baseline;
    set redcap;
    if redcap_event_name = '00_bv_arm_1' and hrbp_studyvisit = 0;

    visitnumber = 0;
    gender = rand_gender;
    rand_treatmentarm = tx_txarm;
    surgerydate = tx_lgbmile2;
    studyid = elig_studyid;
    rand_siteid = rand_siteid - 2;

    visitdate_base = tx_randdate;
    format visitdate_base mmddyy10.;

    age_base = (tx_randdate - rand_date_of_birth) / 365.25;

    bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

    daystosurgery = surgerydate - visitdate_base;

    if surgerydate > . then surgery_occurred = 1;
    else surgery_occurred = 0;

    weight = mean(anth_weight1,anth_weight2);

    height = mean(anth_heightcm1,anth_heightcm2);

    visitdate = 01;

    array ess(8) shq_sitread--shq_stoppedcar;
    do i=1 to 8;
      if ess(i) < 0 then ess(i) = .;
    end;
    drop i;
    ess_total = sum(of shq_sitread--shq_stoppedcar);

    rename
        shq_sitread = ess_1sitread
        shq_watchingtv = ess_2watchingtv
        shq_sitinactive = ess_3sitinactive
        shq_ridingforhour = ess_4passenger
        shq_lyingdown = ess_5lyingdown
        shq_sittalk = ess_6sittalk
        shq_afterlunch = ess_7afterlunch
        shq_stoppedcar = ess_8stoppedcar
        ;

    keep
      studyid
      visitnumber
      visitdate
      age_base
      gender
      rand_treatmentarm
      surgery_occurred
      daystosurgery
      bmi
      visitdate_base
      surgery_occurred
      weight
      height
      rand_siteid
      shq_sitread--shq_stoppedcar ess_total;
  run;

  data abc_partial_baseline;
    set abc_baseline;
    keep studyid age_base gender rand_treatmentarm visitdate_base rand_siteid;
  run;

  proc sort data = abc_baseline;
    by studyid;
  run;

  proc sort data = abc_partial_baseline;
    by studyid;
  run;

  data abc_month09;
    set redcap;
    if redcap_event_name = '09_fu_arm_1' and hrbp_studyvisit = 09;

    studyid = elig_studyid;
    visitnumber = 9;
    visitdate_nine = hrbp_date;
    format visitdate_nine mmddyy10.;
    format tx_randdate mmddyy10.;

    bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

    weight = mean(anth_weight1,anth_weight2);

    visitdate = 09;

    array ess(8) shqf_sitread--shqf_stoppedcar;
    do i=1 to 8;
      if ess(i) < 0 then ess(i) = .;
    end;
    drop i;
    ess_total = sum(of shqf_sitread--shqf_stoppedcar);

    rename
      shqf_sitread = ess_1sitread
      shqf_watchingtv = ess_2watchingtv
      shqf_sitinactive = ess_3sitinactive
      shqf_ridingforhour = ess_4passenger
      shqf_lyingdown = ess_5lyingdown
      shqf_sittalk = ess_6sittalk
      shqf_afterlunch = ess_7afterlunch
      shqf_stoppedcar = ess_8stoppedcar
      ;

    keep
      studyid
      visitnumber
      visitdate
      bmi
      visitdate_nine
      weight
      shqf_sitread--shqf_stoppedcar
      ess_total
      ;
  run;

  proc sort data = abc_month09;
    by studyid;
  run;

  data abc_month18;
    set redcap;
    if redcap_event_name = '18_fu_arm_1' and hrbp_studyvisit = 18;

    studyid = elig_studyid;
    visitnumber = 18;
    visitdate_eighteen = hrbp_date;
    format visitdate_eighteen mmddyy10.;

    age = (visitdate_eighteen - rand_date_of_birth) / 365.25;

    bmi = mean(anth_weight1,anth_weight2) / ((mean(anth_heightcm1,anth_heightcm2)/100)**2);

    weight = mean(anth_weight1,anth_weight2);

    visitdate = 18;

    array ess(8) shqf_sitread--shqf_stoppedcar;
    do i=1 to 8;
      if ess(i) < 0 then ess(i) = .;
    end;
    drop i;
    ess_total = sum(of shqf_sitread--shqf_stoppedcar);

    rename
      shqf_sitread = ess_1sitread
      shqf_watchingtv = ess_2watchingtv
      shqf_sitinactive = ess_3sitinactive
      shqf_ridingforhour = ess_4passenger
      shqf_lyingdown = ess_5lyingdown
      shqf_sittalk = ess_6sittalk
      shqf_afterlunch = ess_7afterlunch
      shqf_stoppedcar = ess_8stoppedcar
      ;

    keep
      studyid
      visitnumber
      visitdate
      bmi
      visitdate_eighteen
      weight
      shqf_sitread--shqf_stoppedcar
      ess_total
      ;
  run;

  proc sort data=abc_month18;
    by studyid;
  run;

  data abc_baseline_f;
    length nsrrid 8.;
    merge
      abc_screening
      abc_baseline
      abc_psg (where=(studyvisit=0))
      abcnsrrids_in
      ;
    by studyid;

    age = age_base;
    format age 8.;
    if rand_treatmentarm = . then delete;
    drop
      studyid
      studyvisit
      age_base
      visitdate_base
      visitdate
      ;
  run;

  proc sort data=abc_baseline_f;
    by nsrrid;
  run;

  data abc_month09_f;
    length nsrrid 8.;
    merge
      abc_screening
      abc_partial_baseline
      abc_month09
      abc_psg (where=(studyvisit=9))
      abcnsrrids_in
      ;
    by studyid;

    daystomonth09 = visitdate_nine - visitdate_base;
    age = (age_base + (daystomonth09 / 365));
    format age 8.;
    if visitdate = . then delete;
    drop
      studyid
      studyvisit
      age_base
      visitdate_base
      visitdate_nine
      visitdate
      ;
  run;

  proc sort data=abc_month09_f;
    by nsrrid;
  run;

  data abc_month18_f;
    length nsrrid 8.;
    merge
      abc_screening
      abc_partial_baseline
      abc_month18
      abc_psg (where=(studyvisit=18))
      abcnsrrids_in
      ;
    by studyid;

    daystomonth18 = visitdate_eighteen - visitdate_base;
    age = (age_base + (daystomonth18 / 365));
    format age 8.;
    if visitdate = . then delete;
    drop
      studyid
      studyvisit
      age_base
      visitdate_base
      visitdate_eighteen
      visitdate
      ;
  run;

  proc sort data=abc_month18_f;
    by nsrrid;
  run;

*******************************************************************************;
* make all variable names lowercase ;
*******************************************************************************;
  options mprint;
  %macro lowcase(dsn);
       %let dsid=%sysfunc(open(&dsn));
       %let num=%sysfunc(attrn(&dsid,nvars));
       %put &num;
       data &dsn;
             set &dsn(rename=(
          %do i = 1 %to &num;
          %let var&i=%sysfunc(varname(&dsid,&i));    /*function of varname returns the name of a SAS data set variable*/
          &&var&i=%sysfunc(lowcase(&&var&i))         /*rename all variables*/
          %end;));
          %let close=%sysfunc(close(&dsid));
    run;
  %mend lowcase;

  %lowcase(abc_baseline_f);
  %lowcase(abc_month09_f);
  %lowcase(abc_month18_f);

*******************************************************************************;
* export datasets ;
*******************************************************************************;
  proc export data= abc_baseline_f
    outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-baseline-dataset-&version..csv"
    dbms=csv
    replace;
  run;

  proc export data= abc_month09_f
    outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-month09-dataset-&version..csv"
    dbms=csv
    replace;
  run;

  proc export data= abc_month18_f
    outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-month18-dataset-&version..csv"
    dbms=csv
    replace;
  run;
