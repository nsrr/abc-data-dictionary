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
  libname abc "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_source\sas-20210408";
  libname abcids "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_ids";
  options nofmterr;

  %let version = 0.5.0.pre;

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

/*
  *checking out race variables;
  proc contents data= redcap;
  run;

proc freq data= redcap;
  table elig_raceamerind  
		elig_raceasian
		elig_raceblack
		elig_racehawaiian  
		elig_raceother
		elig_raceotherspecify  
		elig_racewhite ;
   run;
*/

*******************************************************************************;
* process data from REDCap and PSG datasets
*******************************************************************************;
  data abc_screening;
    set redcap;
    if redcap_event_name = 'screening_arm_0';

    *recode and create demographic variables;
    studyid = elig_studyid;
    ethnicity = elig_ethnicity;
	
	
	 *making new race with 7 categories;
    if ethnicity = 1 and elig_raceother = 1 then elig_raceother = 0;
    race_count = 0;
    array elig_race(5) elig_raceamerind elig_raceasian elig_raceblack elig_racehawaiian elig_racewhite ;
    do i = 1 to 5;
      if elig_race(i) in (0,1) then race_count = race_count + elig_race(i);
    end;
    drop i;

    if elig_racewhite = 1 and race_count = 1 then race = 1; *White;
	if elig_raceamerind = 1 and race_count = 1 then race = 2; *American indian or Alaskan native;
    if elig_raceblack = 1 and race_count = 1 then race = 3; *Black or african american;
    if elig_raceasian = 1 and race_count = 1 then race = 4; *Asian;
	if elig_racehawaii = 1 and race_count = 1 then race =5; *native hawaiian or other pacific islander;
    if elig_raceother = 1 and race_count = 0 then race = 6; *Other;
	if race_count > 1 then race = 7;  *Multiple;
    label race = "Race";

	/*
	* Old race 3 category variable code not using anymore after harmonization
    if elig_racewhite = 1 then race = 1;
    else if elig_raceblack = 1 then race = 2;
    else race = 3;
	*/

    keep studyid ethnicity race;
  run;
/*
  proc freq data= abc_screening;
  table ethnicity
  		race;
  run;
*/
  proc sort data=abc_screening;
    by studyid;
  run;


data abc_bp;
set abc.abcbp24hr;
keep timepoint
     studyid
     sysallmean
     diaallmean
     mapallmean
	 syssleepmean
	 diasleepmean
	 mapsleepmean
	 syswakemean
	 diawakemean
	 mapwakemean;
run;

proc sort data=abc_bp;
by studyid;
run;


  data abc_psg;
    set abc.abcpsg;

    ahi_ap0uhp3x3u_f1t1 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x4u_f1t1 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x3r_f1t1 = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;
    ahi_ap0uhp3x4r_f1t1 = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop + oarbp + oarop + oanbp + oanop) / slpprdp;

    oahi_oa0uhp3x3u_f1t1 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x4u_f1t1 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x3r_f1t1 = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + oarbp + oarop + oanbp + oanop) / slpprdp;
    oahi_oa0uhp3x4r_f1t1 = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + oarbp + oarop + oanbp + oanop) / slpprdp;

    cahi_ca0uhp3x3u_f1t1 = 60 * (hrembp3 + hrop3 + hnrbp3 + hnrop3 + urbp3 + urop3 + unrbp3 + unrop3 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x4u_f1t1 = 60 * (hrembp4 + hrop4 + hnrbp4 + hnrop4 + urbp4 + urop4 + unrbp4 + unrop4 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x3r_f1t1 = 60 * (hremba3 + hroa3 + hnrba3 + hnroa3 + urbpa3 + uropa3 + unrbpa3 + unropa3 + carbp + carop + canbp + canop) / slpprdp;
    cahi_ca0uhp3x4r_f1t1 = 60 * (hremba4 + hroa4 + hnrba4 + hnroa4 + urbpa4 + uropa4 + unrbpa4 + unropa4 + carbp + carop + canbp + canop) / slpprdp;

    cai_ca0u_f1t1 = 60 * (carbp + carop + canbp + canop) / slpprdp;
    oai_oa0u_f1t1 = 60 * (oarbp + oarop + oanbp + oanop) / slpprdp;
    hi_hp3x0u_f1t1 = 60 * (hrembp + hrop + hnrbp + hnrop + urbp + urop + unrbp + unrop) / slpprdp;

    if timebedp ne 0 then do;
        if slplatp > . then slp_maint_eff = 100*(slpprdp/(timebedp-slplatp));
        else if slplatp = . then slp_maint_eff = 100*(slpprdp/timebedp);
    end;
	
    format stloutp_dec stonsetp_dec stlonp_dec 8.2;
	if stloutp < 43200 then stloutp_dec = stloutp/3600 + 24;
	else stloutp_dec = stloutp/3600;
	if stonsetp < 43200 then stonsetp_dec = stonsetp/3600 + 24;
	else stonsetp_dec = stonsetp/3600;
	stlonp_dec = stlonp/3600 + 24;
  
	
    *rename variables;
    rename
      bpmavg = avglvlhr_f1t1
      slpprdp = ttldursp_f1t1
      timest1p = pctdursp_s1_f1t1
      timest2p = pctdursp_s2_f1t1
      times34p = pctdursp_s3_f1t1
      timeremp = pctdursp_sr_f1t1
      timest1 = ttldursp_s1_f1t1
      timest2 = ttldursp_s2_f1t1
      timest34 = ttldursp_s3_f1t1
      timerem = ttldursp_sr_f1t1
      pctlt90 = pctdursp_salt90_f1t1
      pctlt85 = pctdursp_salt85_f1t1
      pctlt80 = pctdursp_salt80_f1t1
      pctlt75 = pctdursp_salt75_f1t1
      avgsat = avglvlsa_f1t1
      minsat = minlvlsa_f1t1
      ;

    keep
      studyid
      studyvisit
      ahi_ap0uhp3x3u_f1t1
      ahi_ap0uhp3x4u_f1t1
      ahi_ap0uhp3x3r_f1t1
      ahi_ap0uhp3x4r_f1t1
      oahi_oa0uhp3x3u_f1t1
      oahi_oa0uhp3x4u_f1t1
      oahi_oa0uhp3x3r_f1t1
      oahi_oa0uhp3x4r_f1t1
      cahi_ca0uhp3x3u_f1t1
      cahi_ca0uhp3x4u_f1t1
      cahi_ca0uhp3x3r_f1t1
      cahi_ca0uhp3x4r_f1t1
      cai_ca0u_f1t1
      oai_oa0u_f1t1
      hi_hp3x0u_f1t1
	  bpmavg
	  slpprdp
	  timest1p
	  timest2p
      times34p
      timeremp
      timest1
      timest2
      timest34
      timerem
      pctlt90
      pctlt85
      pctlt80
      pctlt75
      avgsat
      minsat
	  stloutp
	  stonsetp
	  stlonp
	  slp_eff
	  slp_maint_eff
	  slplatp
	  stloutp_dec
	  stonsetp_dec
	  stlonp_dec
      ;
  run;

  proc sort data=abc_psg;
    by
      studyid
      studyvisit
      ;
  run;

  data abc_baseline;
  retain studyid;
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
  retain studyid;
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
  retain studyid;
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

  *add dataset here;
/*Bloods datatset*/
data abcbloods_baseline;
retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  0;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
  proc sort data = abcbloods_baseline;
    by studyid;
  run;
 data abcbloods_month09;
 retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  9;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
  proc sort data = abcbloods_month09;
    by studyid;
  run;
 data abcbloods_month18;
 retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  9;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
    proc sort data = abcbloods_month18;
    by studyid;
  run;
/*GIQLI*/
data abcgiqli_baseline;
retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  0;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
  proc sort data = abcgiqli_baseline;
    by studyid;
  run;
data abcgiqli_month09;
retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  0;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
  proc sort data = abcgiqli_month09;
    by studyid;
  run;
  data abcgiqli_month18;
retain studyid;
    set abc.abcbloods;
    if bloods_studyvisit =  0;
	studyid=elig_studyid;
    format bloods_datetest mmddyy10.;
	drop elig_studyid;
  run;
  proc sort data = abcgiqli_month18;
    by studyid;
  run;
/*Baseline*/
  data abc_baseline_f;
  retain nsrrid;
    length nsrrid 8.;
    merge
      abc_screening
      abc_baseline
      abc_psg (where=(studyvisit=0))
      abcnsrrids_in
	  abcbloods_baseline
	  abcgiqli_baseline
	  abc.abcbloods(where=(bloods_studyvisit=0) rename=(elig_studyid=studyid))
	  abc_bp(where=(timepoint=0))
	  abc.abcgiqli(where=(giqli_studyvisit=0) rename=(elig_studyid=studyid))
      abc.abceq5d(where=(eq5d_studyvisit=0) rename=(elig_studyid=studyid) keep= elig_studyid 
      eq5d_mobility eq5d_selfcare eq5d_usualact eq5d_paindiscom eq5d_anxiety EQ_index eq5d_studyvisit)
      abc.abcphq8(where=(phq8_studyvisit=0) keep= studyid phq8_interest phq8_down_hopeless
	  phq8_sleep phq8_tired phq8_appetite phq8_bad_failure phq8_troubleconcentrating phq8_movingslowly
      phq8_calc_total phq8_studyvisit)  
;
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
	  phq8_studyvisit
	  eq5d_studyvisit
      ;
  run;

  proc sort data=abc_baseline_f;
    by nsrrid;
  run;

  data abc_month09_f;
   retain nsrrid;
    length nsrrid 8.;
    merge
      abc_screening
      abc_partial_baseline
      abc_month09
      abc_psg (where=(studyvisit=9))
	  abc_bp(where=(timepoint=9))
      abcnsrrids_in
      abcbloods_month09
      abcgiqli_month09
      abc.abcbloods(where=(bloods_studyvisit=9) rename=(elig_studyid=studyid))
	  abc.abcgiqli(where=(giqli_studyvisit=9) rename=(elig_studyid=studyid))
      abc.abceq5d(where=(eq5d_studyvisit=9) rename=(elig_studyid=studyid) keep= elig_studyid 
      eq5d_mobility eq5d_selfcare eq5d_usualact eq5d_paindiscom eq5d_anxiety EQ_index eq5d_studyvisit)
      abc.abcphq8(where=(phq8_studyvisit=9) keep= studyid phq8_interest phq8_down_hopeless
	  phq8_sleep phq8_tired phq8_appetite phq8_bad_failure phq8_troubleconcentrating phq8_movingslowly
      phq8_calc_total phq8_studyvisit)    
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
	  phq8_studyvisit
	  eq5d_studyvisi
      ;
  run;

  proc sort data=abc_month09_f;
    by nsrrid;
  run;

  data abc_month18_f;
  retain nsrrid;
    length nsrrid 8.;
    merge
      abc_screening
      abc_partial_baseline
      abc_month18
      abc_psg (where=(studyvisit=18))
      abcnsrrids_in
      abcbloods_month18
      abcgiqli_month18
	  abc_bp(where=(timepoint=18))
      abc.abcbloods(where=(bloods_studyvisit=18) rename=(elig_studyid=studyid))
	  abc.abcgiqli(where=(giqli_studyvisit=18) rename=(elig_studyid=studyid))
      abc.abceq5d(where=(eq5d_studyvisit=18) rename=(elig_studyid=studyid) keep= elig_studyid 
      eq5d_mobility eq5d_selfcare eq5d_usualact eq5d_paindiscom eq5d_anxiety EQ_index eq5d_studyvisit)
      abc.abcphq8(where=(phq8_studyvisit=18) keep= studyid phq8_interest phq8_down_hopeless
	  phq8_sleep phq8_tired phq8_appetite phq8_bad_failure phq8_troubleconcentrating phq8_movingslowly
      phq8_calc_total phq8_studyvisit)     
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
	  phq8_studyvisit
	  eq5d_studyvisi
      ;
  run;

  proc sort data=abc_month18_f;
    by nsrrid;
  run;




*******************************************************************************;
* create harmonized datasets ;
*******************************************************************************;
* Baseline dataset;
data abc_baseline_f_harmonized;
	set abc_baseline_f;
*demographics
*age;
*use age; 
	format nsrr_age 8.2;
 	if age gt 89 then nsrr_age=90;
	else if age le 89 then nsrr_age = age;

*age_gt89;
*use age;
	format nsrr_age_gt89 $100.; 
	if age gt 89 then nsrr_age_gt89='yes';
	else if age le 89 then nsrr_age_gt89='no';

*sex;
*use gender;
	format nsrr_sex $100.;
    if gender = 1 then nsrr_sex='male';
	else if gender = 2 then nsrr_sex='female';
	else nsrr_sex = 'not reported';

*race;
*race7 created above for hbeat baseline from race variables;
	*race3: 1-->"white" 2-->"black or african american" 3-->"other" others --> "not reported";
    format nsrr_race $100.;
	if race = 1 then nsrr_race = 'white';
    else if race = 2 then nsrr_race = 'american indian or alaska native';
	else if race = 3 then nsrr_race = 'black or african american';
	else if race = 4 then nsrr_race = 'asian';
	else if race = 5 then nsrr_race = 'native hawaiian or other pacific islander';
    else if race = 6 then nsrr_race = 'other';
    else if race = 7 then nsrr_race = 'multiple';
	else nsrr_race  = 'not reported';

*ethnicity;
*use ethnicity;
	format nsrr_ethnicity $100.;
    if ethnicity = 1 then nsrr_ethnicity = 'hispanic or latino';
    else if ethnicity = 2 then nsrr_ethnicity = 'not hispanic or latino';
	else if ethnicity = . then nsrr_ethnicity = 'not reported';

*anthropometry
*bmi;
*use bmi;
	format nsrr_bmi 10.9;
 	nsrr_bmi = bmi;

*clinical data/vital signs
*bp_systolic;
*bp_diastolic;
	*not available;

*lifestyle and behavioral health
*current_smoker;
*ever_smoker;
	*not available;

*polysomnography;
*ahi_ap0uhp3x3u_f1t1;
*use ahi_ap0uhp3x3u_f1t1;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = ahi_ap0uhp3x3u_f1t1;

*nsrr_ahi_hp3r_aasm15;
*use ahi_ap0uhp3x3r_f1t1;
  format nsrr_ahi_hp3r_aasm15 8.2;
  nsrr_ahi_hp3r_aasm15 = ahi_ap0uhp3x3r_f1t1;
 
*nsrr_ahi_hp4u_aasm15;
*use ahi_ap0uhp3x4u_f1t1;
  format nsrr_ahi_hp4u_aasm15 8.2;
  nsrr_ahi_hp4u_aasm15 = ahi_ap0uhp3x4u_f1t1;
  
*nsrr_ahi_hp4r;
*use ahi_ap0uhp3x4r_f1t1;
  format nsrr_ahi_hp4r 8.2;
  nsrr_ahi_hp4r = ahi_ap0uhp3x4r_f1t1;
 
*nsrr_tst_f1;
*use ttldursp_f1t1;
  format nsrr_tst_f1 8.2;
  nsrr_tst_f1 = ttldursp_f1t1;

*nsrr_pctdursp_s1;
*use pctdursp_s1_f1t1;
  format nsrr_pctdursp_s1 8.2;
  nsrr_pctdursp_s1 = pctdursp_s1_f1t1;

*nsrr_pctdursp_s2;
*use pctdursp_s2_f1t1;
  format nsrr_pctdursp_s2 8.2;
  nsrr_pctdursp_s2 = pctdursp_s2_f1t1;

*nsrr_pctdursp_s3;
*use pctdursp_s3_f1t1;
  format nsrr_pctdursp_s3 8.2;
  nsrr_pctdursp_s3 = pctdursp_s3_f1t1;

*nsrr_pctdursp_sr;
*use pctdursp_sr_f1t1;
  format nsrr_pctdursp_sr 8.2;
  nsrr_pctdursp_sr = pctdursp_sr_f1t1;

*nsrr_begtimbd_f1;
*use stloutp;
  format nsrr_begtimbd_f1 time8.;
  nsrr_begtimbd_f1 = stloutp;

*nsrr_endtimbd_f1;
*use stlonp;
  format nsrr_endtimbd_f1 time8.;
  nsrr_endtimbd_f1 = stlonp;

*nsrr_begtimsp_f1;
*use stonsetp;
  format nsrr_begtimsp_f1 time8.;
  nsrr_begtimsp_f1 = stonsetp;

*nsrr_ttleffsp_f1;
*use slp_eff;
  format nsrr_ttleffsp_f1 8.2;
  nsrr_ttleffsp_f1 = slp_eff;  

*nsrr_ttlmefsp_f1;
*use slp_maint_eff;
  format nsrr_ttlmefsp_f1 8.2;
  nsrr_ttlmefsp_f1 = slp_maint_eff;  
  
*nsrr_ttllatsp_f1;
*use slplatp;
  format nsrr_ttllatsp_f1 8.2;
  nsrr_ttllatsp_f1 = slplatp; 

  
	keep 
		nsrrid
		visitnumber
		nsrr_age
		nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity
		nsrr_bmi
		nsrr_ahi_hp3u
		nsrr_ahi_hp3r_aasm15
		nsrr_ahi_hp4u_aasm15
		nsrr_ahi_hp4r
		nsrr_tst_f1
		nsrr_pctdursp_s1
		nsrr_pctdursp_s2
		nsrr_pctdursp_s3
		nsrr_pctdursp_sr
		nsrr_begtimbd_f1
		nsrr_endtimbd_f1
		nsrr_begtimsp_f1
		nsrr_ttleffsp_f1
		nsrr_ttlmefsp_f1
		nsrr_ttllatsp_f1
		;
run;

* 9 month dataset;
data abc_month09_f_harmonized;
	set abc_month09_f;
*demographics
*age;
*use age; 
	format nsrr_age 8.2;
 	if age gt 89 then nsrr_age=90;
	else if age le 89 then nsrr_age = age;

*age_gt89;
*use age;
	format nsrr_age_gt89 $100.; 
	if age gt 89 then nsrr_age_gt89='yes';
	else if age le 89 then nsrr_age_gt89='no';

*sex;
*use gender;
	format nsrr_sex $100.;
    if gender = 1 then nsrr_sex='male';
	else if gender = 2 then nsrr_sex='female';
	else nsrr_sex = 'not reported';

*race;
*race7 created above for hbeat baseline from race variables;
	*race3: 1-->"white" 2-->"black or african american" 3-->"other" others --> "not reported";
    format nsrr_race $100.;
	if race = 1 then nsrr_race = 'white';
    else if race = 2 then nsrr_race = 'american indian or alaska native';
	else if race = 3 then nsrr_race = 'black or african american';
	else if race = 4 then nsrr_race = 'asian';
	else if race = 5 then nsrr_race = 'native hawaiian or other pacific islander';
    else if race = 6 then nsrr_race = 'other';
    else if race = 7 then nsrr_race = 'multiple';
	else nsrr_race  = 'not reported';

*ethnicity;
*use ethnicity;
	format nsrr_ethnicity $100.;
    if ethnicity = 1 then nsrr_ethnicity = 'hispanic or latino';
    else if ethnicity = 2 then nsrr_ethnicity = 'not hispanic or latino';
	else if ethnicity = . then nsrr_ethnicity = 'not reported';

*anthropometry
*bmi;
*use bmi;
	format nsrr_bmi 10.9;
 	nsrr_bmi = bmi;

*clinical data/vital signs
*bp_systolic;
*bp_diastolic;
	*not available;

*lifestyle and behavioral health
*current_smoker;
*ever_smoker;
	*not available;

*polysomnography;
*ahi_ap0uhp3x3u_f1t1;
*use ahi_ap0uhp3x3u_f1t1;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = ahi_ap0uhp3x3u_f1t1;

*nsrr_ahi_hp3r_aasm15;
*use ahi_ap0uhp3x3r_f1t1;
  format nsrr_ahi_hp3r_aasm15 8.2;
  nsrr_ahi_hp3r_aasm15 = ahi_ap0uhp3x3r_f1t1;
 
*nsrr_ahi_hp4u_aasm15;
*use ahi_ap0uhp3x4u_f1t1;
  format nsrr_ahi_hp4u_aasm15 8.2;
  nsrr_ahi_hp4u_aasm15 = ahi_ap0uhp3x4u_f1t1;
  
*nsrr_ahi_hp4r;
*use ahi_ap0uhp3x4r_f1t1;
  format nsrr_ahi_hp4r 8.2;
  nsrr_ahi_hp4r = ahi_ap0uhp3x4r_f1t1;
 
*nsrr_tst_f1;
*use ttldursp_f1t1;
  format nsrr_tst_f1 8.2;
  nsrr_tst_f1 = ttldursp_f1t1;

*nsrr_pctdursp_s1;
*use pctdursp_s1_f1t1;
  format nsrr_pctdursp_s1 8.2;
  nsrr_pctdursp_s1 = pctdursp_s1_f1t1;

*nsrr_pctdursp_s2;
*use pctdursp_s2_f1t1;
  format nsrr_pctdursp_s2 8.2;
  nsrr_pctdursp_s2 = pctdursp_s2_f1t1;

*nsrr_pctdursp_s3;
*use pctdursp_s3_f1t1;
  format nsrr_pctdursp_s3 8.2;
  nsrr_pctdursp_s3 = pctdursp_s3_f1t1;

*nsrr_pctdursp_sr;
*use pctdursp_sr_f1t1;
  format nsrr_pctdursp_sr 8.2;
  nsrr_pctdursp_sr = pctdursp_sr_f1t1;

*nsrr_begtimbd_f1;
*use stloutp;
  format nsrr_begtimbd_f1 time8.;
  nsrr_begtimbd_f1 = stloutp;

*nsrr_endtimbd_f1;
*use stlonp;
  format nsrr_endtimbd_f1 time8.;
  nsrr_endtimbd_f1 = stlonp;

*nsrr_begtimsp_f1;
*use stonsetp;
  format nsrr_begtimsp_f1 time8.;
  nsrr_begtimsp_f1 = stonsetp;

*nsrr_ttleffsp_f1;
*use slp_eff;
  format nsrr_ttleffsp_f1 8.2;
  nsrr_ttleffsp_f1 = slp_eff;  

*nsrr_ttlmefsp_f1;
*use slp_maint_eff;
  format nsrr_ttlmefsp_f1 8.2;
  nsrr_ttlmefsp_f1 = slp_maint_eff;  
  
*nsrr_ttllatsp_f1;
*use slplatp;
  format nsrr_ttllatsp_f1 8.2;
  nsrr_ttllatsp_f1 = slplatp; 

  
	keep 
		nsrrid
		visitnumber
		nsrr_age
		nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity
		nsrr_bmi
		nsrr_ahi_hp3u
		nsrr_ahi_hp3r_aasm15
		nsrr_ahi_hp4u_aasm15
		nsrr_ahi_hp4r
		nsrr_tst_f1
		nsrr_pctdursp_s1
		nsrr_pctdursp_s2
		nsrr_pctdursp_s3
		nsrr_pctdursp_sr
		nsrr_begtimbd_f1
		nsrr_endtimbd_f1
		nsrr_begtimsp_f1
		nsrr_ttleffsp_f1
		nsrr_ttlmefsp_f1
		nsrr_ttllatsp_f1
		;
run;

* 18 month dataset;
data abc_month18_f_harmonized;
	set abc_month18_f;
*demographics
*age;
*use age; 
	format nsrr_age 8.2;
 	if age gt 89 then nsrr_age=90;
	else if age le 89 then nsrr_age = age;

*age_gt89;
*use age;
	format nsrr_age_gt89 $100.; 
	if age gt 89 then nsrr_age_gt89='yes';
	else if age le 89 then nsrr_age_gt89='no';

*sex;
*use gender;
	format nsrr_sex $100.;
    if gender = 1 then nsrr_sex='male';
	else if gender = 2 then nsrr_sex='female';
	else nsrr_sex = 'not reported';

*race;
*race7 created above for hbeat baseline from race variables;
	*race3: 1-->"white" 2-->"black or african american" 3-->"other" others --> "not reported";
    format nsrr_race $100.;
	if race = 1 then nsrr_race = 'white';
    else if race = 2 then nsrr_race = 'american indian or alaska native';
	else if race = 3 then nsrr_race = 'black or african american';
	else if race = 4 then nsrr_race = 'asian';
	else if race = 5 then nsrr_race = 'native hawaiian or other pacific islander';
    else if race = 6 then nsrr_race = 'other';
    else if race = 7 then nsrr_race = 'multiple';
	else nsrr_race  = 'not reported';

*ethnicity;
*use ethnicity;
	format nsrr_ethnicity $100.;
    if ethnicity = 1 then nsrr_ethnicity = 'hispanic or latino';
    else if ethnicity = 2 then nsrr_ethnicity = 'not hispanic or latino';
	else if ethnicity = . then nsrr_ethnicity = 'not reported';

*anthropometry
*bmi;
*use bmi;
	format nsrr_bmi 10.9;
 	nsrr_bmi = bmi;

*clinical data/vital signs
*bp_systolic;
*bp_diastolic;
	*not available;

*lifestyle and behavioral health
*current_smoker;
*ever_smoker;
	*not available;

*polysomnography;
*ahi_ap0uhp3x3u_f1t1;
*use ahi_ap0uhp3x3u_f1t1;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = ahi_ap0uhp3x3u_f1t1;

*nsrr_ahi_hp3r_aasm15;
*use ahi_ap0uhp3x3r_f1t1;
  format nsrr_ahi_hp3r_aasm15 8.2;
  nsrr_ahi_hp3r_aasm15 = ahi_ap0uhp3x3r_f1t1;
 
*nsrr_ahi_hp4u_aasm15;
*use ahi_ap0uhp3x4u_f1t1;
  format nsrr_ahi_hp4u_aasm15 8.2;
  nsrr_ahi_hp4u_aasm15 = ahi_ap0uhp3x4u_f1t1;
  
*nsrr_ahi_hp4r;
*use ahi_ap0uhp3x4r_f1t1;
  format nsrr_ahi_hp4r 8.2;
  nsrr_ahi_hp4r = ahi_ap0uhp3x4r_f1t1;
 
*nsrr_tst_f1;
*use ttldursp_f1t1;
  format nsrr_tst_f1 8.2;
  nsrr_tst_f1 = ttldursp_f1t1;

*nsrr_pctdursp_s1;
*use pctdursp_s1_f1t1;
  format nsrr_pctdursp_s1 8.2;
  nsrr_pctdursp_s1 = pctdursp_s1_f1t1;

*nsrr_pctdursp_s2;
*use pctdursp_s2_f1t1;
  format nsrr_pctdursp_s2 8.2;
  nsrr_pctdursp_s2 = pctdursp_s2_f1t1;

*nsrr_pctdursp_s3;
*use pctdursp_s3_f1t1;
  format nsrr_pctdursp_s3 8.2;
  nsrr_pctdursp_s3 = pctdursp_s3_f1t1;

*nsrr_pctdursp_sr;
*use pctdursp_sr_f1t1;
  format nsrr_pctdursp_sr 8.2;
  nsrr_pctdursp_sr = pctdursp_sr_f1t1;

*nsrr_begtimbd_f1;
*use stloutp;
  format nsrr_begtimbd_f1 time8.;
  nsrr_begtimbd_f1 = stloutp;

*nsrr_endtimbd_f1;
*use stlonp;
  format nsrr_endtimbd_f1 time8.;
  nsrr_endtimbd_f1 = stlonp;

*nsrr_begtimsp_f1;
*use stonsetp;
  format nsrr_begtimsp_f1 time8.;
  nsrr_begtimsp_f1 = stonsetp;

*nsrr_ttleffsp_f1;
*use slp_eff;
  format nsrr_ttleffsp_f1 8.2;
  nsrr_ttleffsp_f1 = slp_eff;  

*nsrr_ttlmefsp_f1;
*use slp_maint_eff;
  format nsrr_ttlmefsp_f1 8.2;
  nsrr_ttlmefsp_f1 = slp_maint_eff;  
  
*nsrr_ttllatsp_f1;
*use slplatp;
  format nsrr_ttllatsp_f1 8.2;
  nsrr_ttllatsp_f1 = slplatp; 
  
	keep 
		nsrrid
		visitnumber
		nsrr_age
		nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity
		nsrr_bmi
		nsrr_ahi_hp3u
		nsrr_ahi_hp3r_aasm15
		nsrr_ahi_hp4u_aasm15
		nsrr_ahi_hp4r
		nsrr_tst_f1
		nsrr_pctdursp_s1
		nsrr_pctdursp_s2
		nsrr_pctdursp_s3
		nsrr_pctdursp_sr
		nsrr_begtimbd_f1
		nsrr_endtimbd_f1
		nsrr_begtimsp_f1
		nsrr_ttleffsp_f1
		nsrr_ttlmefsp_f1
		nsrr_ttllatsp_f1
		;
run;

* concatenate baseline, 9 month and 18 month harmonized datasets;
data abc_harmonized;
   set abc_baseline_f_harmonized abc_month09_f_harmonized abc_month18_f_harmonized;
run;
*******************************************************************************;
* checking harmonized datasets ;
*******************************************************************************;

/* Checking for extreme values for continuous variables */

proc means data=abc_harmonized;
VAR 	nsrr_age
		nsrr_bmi
		nsrr_ahi_hp3u
		nsrr_ahi_hp3r_aasm15
		nsrr_ahi_hp4u_aasm15
		nsrr_ahi_hp4r
		nsrr_tst_f1
		nsrr_pctdursp_s1
		nsrr_pctdursp_s2
		nsrr_pctdursp_s3
		nsrr_pctdursp_sr
		nsrr_begtimbd_f1
		nsrr_endtimbd_f1
		nsrr_begtimsp_f1
		nsrr_ttleffsp_f1
		nsrr_ttlmefsp_f1
		nsrr_ttllatsp_f1
		;
run;

/* Checking categorical variables */

proc freq data=abc_harmonized;
table 	nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity;
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
  %lowcase(abc_harmonized);

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

  proc export data= abc_harmonized
  outfile= "\\rfawin\bwh-sleepepi-home\projects\trials\abc\nsrr-prep\_releases\&version.\abc-harmonized-dataset-&version..csv"
  dbms=csv
  replace;
 run;
