/*AMENDED DO FILE FROM September 28, 2010 - amended from March 8 2010 do-file*/
/*CHANGES: figs in black and white*/


set more off

/* Eliminate all the missing values for legal_thresh by replacing with zero if MD.*/
/*Also, multiply it by 100, so the unit is the percentage, which makes coefficients more intuitive.*/
replace legal_thresh=0 if legal_thresh==.
replace legal_thresh=legal_thresh*100

/*Create a dummy to identify Mixed Member Parallel systems.  (Note the variable compensatory already identifies MMPR systems.)*/
gen MMPL=0
replace MMPL=1 if compensatory==0 | dist_mag_medians==1 & dist_magn>1
replace compensatory=0 if compensatory==.

/*List the particulars from cases that account for the fact that models of Dispropotionality and*/
/*Effective Number of Parties have slightly different numbers of observations.*/
list country election_yr enps enpv disprop dist_mag_medians if enps~=. & disprop==.
list country election_yr enps enpv disprop dist_mag_medians if enps==. & disprop~=.

/*Drop cases where Disproportionality value is missing, such that models should now use all the same*/
/*observations when either Disprop or ENPS is the DV.*/
drop if disprop==.
drop if enps==.

/*Generate dummies for DM intervals*/

gen dm_med1=0
replace dm_med1=1 if dist_mag_medians==1

gen dm_med23=0
replace dm_med23=1 if dist_mag_medians>1 & dist_mag_medians<=3

gen dm_med46=0
replace dm_med46=1 if dist_mag_medians>3 & dist_mag_medians<=6

gen dm_med710=0
replace dm_med710=1 if dist_mag_medians>6 & dist_mag_medians<=10

gen dm_med1120=0
replace dm_med1120=1 if dist_mag_medians>10 & dist_mag_medians<=20

gen dm_med20plus=0
replace dm_med20plus=1 if dist_mag_medians>20

sum dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus


/*set panel ("country2") and time-series ("election_no") parameters*/
xtset country2 election_no, generic


/*Generate asymptotic, and higher-order, terms of dist_mag_medians*/
generate dm_asym=1/(dist_mag_medians)
generate dm_asym_sq=1/(dist_mag_medians^2)
generate dm_asym_cube=1/(dist_mag_medians^3)


/*nb. TABLE 1 is the descriptive table of electoral systems*/

/*nb. FIGURE 1 is the figure showing thhe expected non-linear trade-off between "representation" and "accountability"*/


/*FIGURE 2 - Descritive figure of the disprop vs. ENPS trade-off - including MMPL and Legal_Threshold*/
twoway (scatter enps disprop if dm_med1==1, mcolor(black) msymbol(d) msize(small)) (scatter enps disprop if dm_med23==1, mcolor(black) msymbol(Oh) msize(small)) (scatter enps disprop if dm_med46==1, mcolor(black) msymbol(Oh) msize(small)) (scatter enps disprop if dm_med710==1, mcolor(black) msymbol(Oh) msize(small)) (scatter enps disprop if dm_med1120==1, mcolor(black) msymbol(X)) (scatter enps disprop if dm_med20plus==1, mcolor(black) msymbol(X)), ytitle(Effective Number of Parties-by seats) xtitle(Disproportionality), , legend(off) 

/*Key to FIGURE 2*/
/*SQUARE = dm_med1*/
/*HOLLOW CIRCLE = dm_med23 or dm_med46 or dm_med710*/
/*CROSS = dm_med>10*/


/*TABLE 2 - REPRESENTATION*/

/*Table 2, DV 1 = Disproportionality*/

/*Model 1 - disproportionality - pooled model - LINEAR*/
xtpcse disprop dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 2 - disproportionality - pooled model - ASYMPTOTIC*/
xtpcse disprop dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

predict pred_disprop_asym

/*Model 2A - disproportionality - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse disprop dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 2B - disproportionality - pooled model - ASYMPTOTIC-CUBED*/
xtpcse disprop dist_mag_medians dm_asym dm_asym_sq dm_asym_cube  legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me



/*Model 3 - disproportionality - with country fixed-effects - LINEAR*/
xtreg disprop dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 4 - disproportionality - with country fixed-effects - ASYMPTOTIC*/
xtreg disprop dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 4A - disproportionality - with country fixed-effects - ASYMPTOTIC-SQUARED*/
xtreg disprop dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 4B - disproportionality - with country fixed-effects - ASYMPTOTIC-CUBED*/
xtreg disprop dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 




/*Table 2, DV 2 = Voter-Government Distance*/

/*set panel for voter-government distance DV*/
xtset country2 election_no_vgdist, generic

gen kf_vdist_all = 0
replace kf_vdist_all=kf_vgdist if minority_gvt~=1
replace kf_vdist_all=kf_vpdist if minority_gvt==1
 

/*Model 5 - voter-government distance - pooled model - LINEAR*/
xtpcse kf_vdist_all dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 6 - voter-government distance - pooled model - ASYMPTOTIC*/
xtpcse kf_vdist_all  dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

predict pred_vgdist_asym

/*Model 6A - voter-government distance - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse kf_vdist_all  dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 6B - voter-government distance - pooled model - ASYMPTOTIC-CUBED*/
xtpcse kf_vdist_all  dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 


/*Model 7 - voter-government distance - with country fixed-effects - LINEAR*/
xtreg kf_vdist_all dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 8 - voter-government distance - with country fixed-effects - ASYMPTOTIC*/
xtreg kf_vdist_all dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 8A - voter-government distance - with country fixed-effects - ASYMPTOTIC-SQUARED*/
xtreg kf_vdist_all dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 

/*Model 8B - voter-government distance - with country fixed-effects - ASYMPTOTIC-CUBED*/
xtreg kf_vdist_all dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe 




/*TABLE 3 - ACCOUNTABILITY*/

/*set generic panel*/
xtset country2 election_no, generic

/*Table 3, DV 1 = Party System Fragmentation*/

/*Model 9 - party system fragmentation - pooled model - LINEAR */
xtpcse enps dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 10 - party system fragmentation - pooled model - ASYMPTOTIC*/
xtpcse enps dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

predict pred_enps_asym

/*Model 10A - party system fragmentation - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse enps dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 10B - party system fragmentation - pooled model - ASYMPTOTIC-CUBED*/
xtpcse enps dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 


/*Model 9.1(NOT INCLUDED IN MAIN TABLE) - party system fragmentation - pooled model (adding enpv) - LINEAR */
xtpcse enps dist_mag_medians legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 10.1(NOT INCLUDED IN MAIN TABLE) - party system fragmentation - pooled model (adding enpv) - ASYMPTOTIC*/
xtpcse enps dist_mag_medians dm_asym legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 11 - party system fragmentation - with country fixed-effects - LINEAR*/
xtreg enps dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 12 - party system fragmentation - with country fixed-effects - ASYMPTOTIC*/
xtreg enps dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 12A - party system fragmentation - with country fixed-effects - ASYMPTOTIC-SQUARED*/
xtreg enps dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 12B - party system fragmentation - with country fixed-effects - ASYMPTOTIC-CUBED*/
xtreg enps dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe


/*Model 11.1(NOT INCLUDED IN MAIN TABLE) - party system fragmentation - with country fixed-effects (adding enpv) - LINEAR*/
xtreg enps dist_mag_medians legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 12.1(NOT INCLUDED IN MAIN TABLE) - party system fragmentation - with country fixed-effects (adding enpv) - ASYMPTOTIC*/
xtreg enps dist_mag_medians dm_asym legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe



/*Table 3, DV 2 = No. of Parties in Government*/

/*set panel for parties in government DV*/
xtset country2 election_no_pig, generic

/*Model 13 - PIG - pooled model - LINEAR*/
xtpcse pig dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 14 - PIG - pooled model - ASYMPTOTIC*/
xtpcse pig dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

predict pred_pig_asym

/*Model 14A - PIG - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse pig dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 14B - PIG - pooled model - ASYMPTOTIC-CUBED*/
xtpcse pig dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me


/*Model 13.1(NOT INCLUDED IN MAIN TABLE) - PIG (controlling for enpv) - pooled model - LINEAR*/
xtpcse pig dist_mag_medians legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 14.1(NOT INCLUDED IN MAIN TABLE) - PIG (controlling for enpv) - pooled model - ASYMPTOTIC*/
xtpcse pig dist_mag_medians dm_asym legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 15 - PIG - with country fixed-effects - LINEAR*/
xtreg pig dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 16 - PIG - with country fixed-effects - ASYMPTOTIC*/
xtreg pig dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 16A - PIG - with country fixed-effects - ASYMPTOTIC-SQUARED*/
xtreg pig dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 16B - PIG - with country fixed-effects - ASYMPTOTIC-CUBED*/
xtreg pig dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe


/*Model 15.1(NOT INCLUDED IN MAIN TABLE) - PIG - with country fixed-effects (controlling for enpv) - LINEAR*/
xtreg pig dist_mag_medians legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 16.1(NOT INCLUDED IN MAIN TABLE) - PIG - with country fixed-effects (controlling for enpv) - ASYMPTOTIC*/
xtreg pig dist_mag_medians dm_asym legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe



/*Table 3, DV 3 = Probability of Single Party Government*/

/*Model 17 - Single-Party Government - pooled model - LINEAR*/
logit sng_pty_gvt dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx

/*Model 18 - Single-Party Government - pooled model - ASYMPTOTIC*/
logit sng_pty_gvt dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx

/*Model 18A - Single-Party Government - pooled model - ASYMPTOTIC-SQUARED*/
logit sng_pty_gvt dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx

/*Model 18B - Single-Party Government - pooled model - ASYMPTOTIC-CUBED*/
logit sng_pty_gvt dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx


/*Model 17.1(NOT INCLUDED IN MAIN TABLE) - Single-Party Government (controlling for enpv) - pooled model - LINEAR*/
logit sng_pty_gvt dist_mag_medians legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx

/*Model 18.1(NOT INCLUDED IN MAIN TABLE) - Single-Party Government (controlling for enpv) - pooled model - ASYMPTOTIC*/
logit sng_pty_gvt dist_mag_medians dm_asym legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx



/*TABLE 4 - GOVERNMENT PERFORMANCE*/

/*Table 4, DV 1 = Total Government Spending*/

/*set panel for government spending DV*/
xtset country2 election_no_exp, generic

/*Model 19 - Total government spending - pooled model - LINEAR*/
xtpcse pt_cgexp dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 20 - Total government spending - pooled model - ASYMPTOTIC*/
xtpcse pt_cgexp dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 20A - Total government spending - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse pt_cgexp dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 20B - Total government spending - pooled model - ASYMPTOTIC-CUBED*/
xtpcse pt_cgexp dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me


/*Model 21 - Total government spending - with country fixed effects - LINEAR*/
xtreg pt_cgexp dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 22 - Total government spending - with country fixed effects - ASYMPTOTIC*/
xtreg pt_cgexp dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 22A - Total government spending - with country fixed effects - ASYMPTOTIC-SQUARED*/
xtreg pt_cgexp dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 22B - Total government spending - with country fixed effects - ASYMPTOTIC-CUBED*/
xtreg pt_cgexp dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 



/*Table 4, DV 2 = Central government budget surplus */

/*set panel for government surplus DV*/
xtset country2 election_no_surp, generic

/*Model 23 - Central government budget surplus - pooled model - LINEAR*/
xtpcse pt_cgbgt_spl dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 24 - Central government budget surplus - pooled model - ASYMPTOTIC*/
xtpcse pt_cgbgt_spl dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 24A - Central government budget surplus - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse pt_cgbgt_spl dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 24B - Central government budget surplus - pooled model - ASYMPTOTIC-CUBED*/
xtpcse pt_cgbgt_spl dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me


/*Model 25 - Central government budget surplus - with country fixed effects - LINEAR*/
xtreg pt_cgbgt_spl dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 26 - Central government budget surplus - with country fixed effects - ASYMPTOTIC*/
xtreg pt_cgbgt_spl dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 26A - Central government budget surplus - with country fixed effects - ASYMPTOTIC-SQUARED*/
xtreg pt_cgbgt_spl dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 

/*Model 26B - Central government budget surplus - with country fixed effects - ASYMPTOTIC-CUBED*/
xtreg pt_cgbgt_spl dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal, fe 



/*Table 4, DV 3 = Human Development Index*/

/*set panel for HDI score DV*/
xtset country2 election_no_hdi, generic

/*Model 27 - HDI by DM interval (WITH GINI AND GDP_HEAD DROPPED) - pooled model - LINEAR*/
xtpcse hdi_score dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 27.1 (NOT INCLUDED IN TABLE) - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - pooled model - LINEAR*/
xtpcse hdi_score dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 28 - HDI by DM interval (WITH GINI AND GDP_HEAD DROPPED) - pooled model - ASYMPTOTIC*/
xtpcse hdi_score dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 28A - HDI by DM interval (WITH GINI AND GDP_HEAD DROPPED) - pooled model - ASYMPTOTIC-SQUARED*/
xtpcse hdi_score dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 28B - HDI by DM interval (WITH GINI AND GDP_HEAD DROPPED) - pooled model - ASYMPTOTIC-CUBED*/
xtpcse hdi_score dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 


/*Model 28.1 (NOT INCLUDED IN TABLE) - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - pooled model - ASYMPTOTIC*/
xtpcse hdi_score dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 


/*Model 29 - HDI by DM interval (WITH GINI AND GDP_HEAD DROPPED) - with country fixed-effects - LINEAR*/
xtreg hdi_score dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal, fe

/*Model 29.1 (NOT INCLUDED IN TABLE)- HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - with country fixed-effects - LINEAR*/
xtreg hdi_score dist_mag_medians legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe

/*Model 30 - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - with country fixed-effects - ASYMPTOTIC*/
xtreg hdi_score dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal, fe

/*Model 30A - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - with country fixed-effects - ASYMPTOTIC-SQUARED*/
xtreg hdi_score dist_mag_medians dm_asym dm_asym_sq legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal, fe

/*Model 30B - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - with country fixed-effects - ASYMPTOTIC-CUBED*/
xtreg hdi_score dist_mag_medians dm_asym dm_asym_sq dm_asym_cube legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal, fe


/*Model 30.1 (NOT INCLUDED IN TABLE) - HDI by DM interval (WITH GINI AND GDP_HEAD INCLUDED) - with country fixed-effects - ASYMPTOTIC*/
xtreg hdi_score dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal, fe



*/FIGURE 3 - Predicted Disprop, with Asymptotic Line Fitted and CIs*/
regress pred_disprop_asym dist_mag_medians dm_asym
predict fitted_disprop_asym
predict CI_disprop_asym, stdp
predict xb_disprop_asym, xb
gen upper_disprop_asym = xb_disprop_asym + invttail(e(df_r),0.975)*CI_disprop_asym
gen lower_disprop_asym = xb_disprop_asym - invttail(e(df_r),0.975)*CI_disprop_asym

twoway (rarea upper_disprop_asym lower_disprop_asym dist_mag_medians if dist_mag_medians<20, sort) ///
  (fpfit fitted_disprop_asym dist_mag_medians if dist_mag_medians<20, lpattern(solid)) ///
  (scatter pred_disprop_asym dist_mag_medians if dist_mag_medians<20, mcolor(black) msymbol(o)), ///
  ytitle(Predicted Disproportionality) xtitle(Median District Magnitude) ///
  legend(off) scheme(s2mono)



*/FIGURE 4 - Predicted Voter-Government Distance, with Asymptotic Line Fitted and CIs*/
regress pred_vgdist_asym dist_mag_medians dm_asym
predict fitted_vgdist_asym
predict CI_vgdist_asym, stdp
predict xb_vgdist_asym, xb
gen upper_vgdist_asym = xb_vgdist_asym + invttail(e(df_r),0.975)*CI_vgdist_asym
gen lower_vgdist_asym = xb_vgdist_asym - invttail(e(df_r),0.975)*CI_vgdist_asym

twoway (rarea upper_vgdist_asym lower_vgdist_asym dist_mag_medians if dist_mag_medians<20, sort) ///
  (fpfit fitted_vgdist_asym dist_mag_medians if dist_mag_medians<20, lpattern(solid)) ///
  (scatter pred_vgdist_asym dist_mag_medians if dist_mag_medians<20, mcolor(black) msymbol(o)), ///
  ytitle(Predicted Voter-Government Distance) xtitle(Median District Magnitude) ///
  legend(off) scheme(s2mono)



*/FIGURE 5 - Predicted ENPS, with Asymptotic Line Fitted and CIs*/
regress pred_enps_asym dist_mag_medians dm_asym
predict fitted_enps_asym
predict CI_enps_asym, stdp
predict xb_enps_asym, xb
gen upper_enps_asym = xb_enps_asym + invttail(e(df_r),0.975)*CI_enps_asym
gen lower_enps_asym = xb_enps_asym - invttail(e(df_r),0.975)*CI_enps_asym

twoway (rarea upper_enps_asym lower_enps_asym dist_mag_medians if dist_mag_medians<20, sort) ///
  (fpfit fitted_enps_asym dist_mag_medians if dist_mag_medians<20) ///
  (scatter pred_enps_asym dist_mag_medians if dist_mag_medians<20), ///
  ytitle(Predicted Effective No. of Parties-by seats) xtitle(Median District Magnitude) ///
  legend(off)



*/FIGURE 6 - Predicted PIG, with Asymptotic Line Fitted and CIs*/
regress pred_pig_asym dist_mag_medians dm_asym
predict fitted_pig_asym
predict CI_pig_asym, stdp
predict xb_pig_asym, xb
gen upper_pig_asym = xb_pig_asym + invttail(e(df_r),0.975)*CI_pig_asym
gen lower_pig_asym = xb_pig_asym - invttail(e(df_r),0.975)*CI_pig_asym

twoway (rarea upper_pig_asym lower_pig_asym dist_mag_medians if dist_mag_medians<20, sort) ///
  (fpfit fitted_pig_asym dist_mag_medians if dist_mag_medians<20, lpattern(solid)) ///
  (scatter pred_pig_asym dist_mag_medians if dist_mag_medians<20, mcolor(black) msymbol(o)), ///
  ytitle(Predicted No. of Parties in Govt.) xtitle(Median District Magnitude) ///
  legend(off) scheme(s2mono)




/*FIGUREs 7 & 8 & 9 - probability of good models*/

/*Create variables to indicate that we've got good values on things we value.*/
gen kf_vdist_good=0
replace kf_vdist_good=1 if kf_vdist_all<6

gen disprop_good=0
replace disprop_good=1 if disprop<=5

gen pig_good=0
replace pig_good=1 if pig<=2

gen enps_good=0
replace enps_good=1 if enps<3

gen all_good=0
replace all_good=1 if kf_vdist_all<6 & disprop_good==1 & pig_good==1 & enps_good==1

gen DispENPSgood=0
replace DispENPSgood=1 if disprop_good==1 & enps_good==1

gen DispPIGgood=0
replace DispPIGgood=1 if disprop_good==1 & pig_good==1

gen VGDistENPSgood=0
replace VGDistENPSgood=1 if kf_vdist_all<6 & enps_good==1

gen VGDistPIGgood=0
replace VGDistPIGgood=1 if kf_vdist_all<6 & pig_good==1



/*Model A - disproportionality - pooled model - ASYMPTOTIC*/
logit disprop_good dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_disprop_prob

/*Model B - voter-distance - pooled model - ASYMPTOTIC*/
logit kf_vdist_good dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_kf_vdist_prob

/*Model C - party system fragmentation - pooled model - ASYMPTOTIC*/
logit enps_good dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 
predict pred_enps_prob

/*Model D - PIG - pooled model - ASYMPTOTIC*/
logit pig_good dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_pig_prob

/*Model E - all - pooled model - ASYMPTOTIC*/
logit all_good dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_all_prob

/*Model F - Disprop & ENPS - pooled model - ASYMPTOTIC*/
logit DispENPSgood dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_DispENPS_prob

/*Model G - Disprop & PIG - pooled model - ASYMPTOTIC*/
logit DispPIGgood dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_DispPIG_prob

/*Model H - VG_Distance & ENPS - pooled model - ASYMPTOTIC*/
logit VGDistENPSgood dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_VGDistENPS_prob

/*Model I - VG_Distance & PIG - pooled model - ASYMPTOTIC*/
logit VGDistPIGgood dist_mag_medians dm_asym legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me
predict pred_VGDistPIG_prob


regress pred_disprop_prob dist_mag_medians dm_asym
predict fitted_disprop
predict CI_disprop_prob, stdp
predict xb_disprop_prob, xb
gen upper_disprop_prob = xb_disprop_prob + invttail(e(df_r),0.975)*CI_disprop_prob
gen lower_disprop_prob = xb_disprop_prob - invttail(e(df_r),0.975)*CI_disprop_prob

regress pred_enps_prob dist_mag_medians dm_asym
predict fitted_enps
predict CI_enps_prob, stdp
predict xb_enps_prob, xb
gen upper_enps_prob = xb_enps_prob + invttail(e(df_r),0.975)*CI_enps_prob
gen lower_enps_prob = xb_enps_prob - invttail(e(df_r),0.975)*CI_enps_prob

regress pred_pig_prob dist_mag_medians dm_asym
predict fitted_pig
predict CI_pig_prob, stdp
predict xb_pig_prob, xb
gen upper_pig_prob = xb_pig_prob + invttail(e(df_r),0.975)*CI_pig_prob
gen lower_pig_prob = xb_pig_prob - invttail(e(df_r),0.975)*CI_pig_prob

regress pred_kf_vdist_prob dist_mag_medians dm_asym
predict fitted_vdist
predict CI_vdist_prob, stdp
predict xb_vdist_prob, xb
gen upper_vdist_prob = xb_vdist_prob + invttail(e(df_r),0.975)*CI_vdist_prob
gen lower_vdist_prob = xb_vdist_prob - invttail(e(df_r),0.975)*CI_vdist_prob

regress pred_DispENPS_prob dist_mag_medians dm_asym
predict fitted_DispENPS
predict CI_DispENPS_prob, stdp
predict xb_DispENPS_prob, xb
gen upper_DispENPS_prob = xb_DispENPS_prob + invttail(e(df_r),0.975)*CI_DispENPS_prob
gen lower_DispENPS_prob = xb_DispENPS_prob - invttail(e(df_r),0.975)*CI_DispENPS_prob

regress pred_DispPIG_prob dist_mag_medians dm_asym
predict fitted_DispPIG
predict CI_DispPIG_prob, stdp
predict xb_DispPIG_prob, xb
gen upper_DispPIG_prob = xb_DispPIG_prob + invttail(e(df_r),0.975)*CI_DispPIG_prob
gen lower_DispPIG_prob = xb_DispPIG_prob - invttail(e(df_r),0.975)*CI_DispPIG_prob

regress pred_VGDistENPS_prob dist_mag_medians dm_asym
predict fitted_VGDistENPS
predict CI_VGDistENPS_prob, stdp
predict xb_VGDistENPS_prob, xb
gen upper_VGDistENPS_prob = xb_VGDistENPS_prob + invttail(e(df_r),0.975)*CI_VGDistENPS_prob
gen lower_VGDistENPS_prob = xb_VGDistENPS_prob - invttail(e(df_r),0.975)*CI_VGDistENPS_prob

regress pred_VGDistPIG_prob dist_mag_medians dm_asym
predict fitted_VGDistPIG
predict CI_VGDistPIG_prob, stdp
predict xb_VGDistPIG_prob, xb
gen upper_VGDistPIG_prob = xb_VGDistPIG_prob + invttail(e(df_r),0.975)*CI_VGDistPIG_prob
gen lower_VGDistPIG_prob = xb_VGDistPIG_prob - invttail(e(df_r),0.975)*CI_VGDistPIG_prob

regress pred_all_prob dist_mag_medians dm_asym
predict fitted_all
predict CI_all_prob, stdp
predict xb_all_prob, xb
gen upper_all_prob = xb_all_prob + invttail(e(df_r),0.975)*CI_all_prob
gen lower_all_prob = xb_all_prob - invttail(e(df_r),0.975)*CI_all_prob
gen upperB_all_prob = xb_all_prob + invttail(e(df_r),0.75)*CI_all_prob
gen lowerB_all_prob = xb_all_prob - invttail(e(df_r),0.75)*CI_all_prob


twoway (rarea upper_vdist_prob lower_vdist_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_vdist dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)) ///
  (rarea upper_disprop_prob lower_disprop_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_disprop dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)) ///
  (rarea upper_enps_prob lower_enps_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_enps dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)) ///
  (rarea upper_pig_prob lower_pig_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_pig dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)), ///
  ytitle(Probability) xtitle(Median District Magnitude) /// 
  legend(off) scheme(s2mono)

twoway (rarea upper_DispENPS_prob lower_DispENPS_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_DispENPS dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black))  ///
  (rarea upper_DispPIG_prob lower_DispPIG_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_DispPIG dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black))  ///
  (rarea upper_VGDistENPS_prob lower_VGDistENPS_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_VGDistENPS dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black))  ///
  (rarea upper_VGDistPIG_prob lower_VGDistPIG_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_VGDistPIG dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)),  ///
  ytitle(Probability) xtitle(Median District Magnitude) ///
  legend(off) scheme(s2mono)

twoway (rarea upper_all_prob lower_all_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (rarea upperB_all_prob lowerB_all_prob dist_mag_medians if dist_mag_medians<30, sort) ///
  (fpfit fitted_all dist_mag_medians if dist_mag_medians<30, lpattern(solid) lcolor(black)),  ///
  ytitle(Probability) xtitle(Median District Magnitude) ///
  legend(off) scheme(s2mono)


/*TABLE 5 - ANALYSIS OF DIFFERENT DM THRESHOLDS - REPRESENTATION AND ACCOUNTABILITY*/

/*set generic panel*/
xtset country2 election_no, generic

/*Model 31.P - disproportionality - pooled model*/
xtpcse disprop dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 31.P20 - disproportionality - pooled model - DM>20 BASELINE*/
xtpcse disprop dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 31.FE - disproportionality - fixed effects*/
xtreg disprop dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 31.FE20 - disproportionality - fixed effects - DM>20 BASELINE*/
xtreg disprop dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe


/*set panel for voter-government distance DV*/
xtset country2 election_no_vgdist, generic

/*Model 32.P - voter-government distance - pooled model*/
xtpcse kf_vdist_all dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 32.P20 - voter-government distance - pooled model - DM>20 BASELINE*/
xtpcse kf_vdist_all dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 32.FE - voter-government distance - fixed effects*/
xtreg kf_vdist_all dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 32.FE20 - voter-government distance - fixed effects - DM>20 BASELINE*/
xtreg kf_vdist_all dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe


/*set generic panel */
xtset country2 election_no, generic

/*Model 33.P - party system fragmentation - pooled model */
xtpcse enps dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 33.P20 - party system fragmentation - pooled model - DM>20 BASELINE */
xtpcse enps dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 33.1.P (NOT REPORTED IN MAIN TABLE) - party system fragmentation - pooled model (controlling for enpv) */
xtpcse enps dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 33.FE - party system fragmentation - fixed effects */
xtreg enps dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 33.FE20 - party system fragmentation - fixed effects - DM>20 BASELINE*/
xtreg enps dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe


/*set panel for parties in government DV*/
xtset country2 election_no_pig, generic

/*Model 34.P - PIG - pooled model*/
xtpcse pig dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 34.P20 - PIG - pooled model - DM>20 BASELINE*/
xtpcse pig dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 34.1.P (NOT REPORTED IN MAIN TABLE) - PIG - pooled model (controlling for enpv)*/
xtpcse pig dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 34.FE - PIG - fixed effects*/
xtreg pig dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 34.FE20 - PIG - fixed effects - DM>20 BASELINE*/
xtreg pig dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 35.P - Single-Party Government - pooled model*/
logit sng_pty_gvt dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx

/*Model 35.P20 - Single-Party Government - pooled model - DM>20 BASELINE*/
logit sng_pty_gvt dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx


/*Model 35.1.P (NOT REPORTED IN MAIN TABLE) - Single-Party Government - pooled model (controlling for enpv)*/
logit sng_pty_gvt dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory enpv hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

mfx



/*TABLE 6 - ANALYSIS OF DIFFERENT DM THRESHOLDS - GOVERNMENT PERFORMANCE*/

/*set panel for government spending DV*/
xtset country2 election_no_exp, generic

/*Model 36.P - Total government spending - pooled model*/
xtpcse pt_cgexp dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 36.P20 - Total government spending - pooled model - DM>20 BASELINE*/
xtpcse pt_cgexp dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 36.FE - Total government spending - fixed effects*/
xtreg pt_cgexp dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 36.FE20 - Total government spending - fixed effects - DM>20 BASELINE*/
xtreg pt_cgexp dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*set panel for government surplus DV*/
xtset country2 election_no_surp, generic

/*Model 37.P - Central government budget surplus - pooled model*/
xtpcse pt_cgbgt_spl dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 37.P20 - Central government budget surplus - pooled model - DM>20 BASELINE*/
xtpcse pt_cgbgt_spl dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me

/*Model 37.FE - Central government budget surplus - fixed effects*/
xtreg pt_cgbgt_spl dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 37.FE20 - Central government budget surplus - fixed effects - DM>20 BASELINE*/
xtreg pt_cgbgt_spl dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth pt_trade pt_prop1564 pt_prop65 gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*set panel for HDI score DVs*/
xtset country2 election_no_hdi, generic

/*Model 38.P - HDI by DM interval (WITH GINI & GDP_HEAD DROPPED) - pooled model */
xtpcse hdi_score dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 38.P20 - HDI by DM interval (WITH GINI & GDP_HEAD DROPPED) - pooled model - DM>20 BASELINE*/
xtpcse hdi_score dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 38.1.P (NOT REPORTED IN MAIN TABLE) - HDI by DM interval (WITH GINI & GDP_HEAD INCLUDED) - pooled model */
xtpcse hdi_score dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population gdp_head growth gini age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me 

/*Model 39.FE - HDI by DM interval (WITH GINI & GDP_HEAD DROPPED) - fixed effects */
xtreg hdi_score dm_med23 dm_med46 dm_med710 dm_med1120 dm_med20plus legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe

/*Model 39.FE20 - HDI by DM interval (WITH GINI & GDP_HEAD DROPPED) - fixed effects - DM>20 BASELINE*/
xtreg hdi_score dm_med1 dm_med23 dm_med46 dm_med710 dm_med1120 legal_thresh MMPL compensatory hybrid election_yr pol_freedom econ_freedom population growth age_dem federal pres ethnic_fract_fearon latitude col_uk col_sp_po col_oth americas former_com pacific s_asia africa_me, fe


/*TABLE A1 - DESCRIPTIVE STATS*/

tabstat disprop kf_vdist_all enps pig sng_pty_gvt pt_cgexp pt_cgbgt_spl hdi_score dist_mag_medians dm_asym legal_thresh MMPL compensatory, statistics(count mean median sd min max) columns(variables)

