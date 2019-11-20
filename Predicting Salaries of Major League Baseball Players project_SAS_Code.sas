/*Template for loading data given as SAS dataset*/
/*(1) Download the dataset from coursesite and save it under a folder under drive H, say H:\M338*/
/*(2) In SAS, create a path:*/
/*ODS RTF FILE="PROJECT.RFT";*/
LIBNAME DH "H:\M338";
/*(3) Load in the data, say XYZ.sas7bdat*/
DATA mlb_hit;
  SET DH.mlb_hit;
RUN;
TITLE 'The first five observations out of 322';
PROC PRINT DATA=mlb_hit (obs=5);
RUN;
/* Show the data description */
proc contents varnum data=mlb_hit;
   ods select position;
run;
/*(4) Proceed analysis on dataset, XYZ, as you usually do. */
/* Exploratory ZData Analysis*/
PROC PRINT DATA=mlb_hit;
RUN;
PROC CONTENTS DATA=mlb_hit VARNUM;
RUN;
PROC MEANS DATA=mlb_hit;                 
RUN;
PROC UNIVARIATE DATA=mlb_hit;
  VAR salary;
  HISTOGRAM;
RUN;
PROC FORMAT;
  VALUE $missfmt ' ' = 'Missing' other = 'Not Missing';
  VALUE missfmt . = 'Missing' other = 'Not Missing';
RUN;
PROC FREQ DATA=mlb_hit;
  FORMAT _CHAR_ $missfmt.;
  FORMAT _NUMERIC_ missfmt.;
  tables _CHAR_ / missing nocum nopercent;
  tables _NUMERIC_ / missing nocum nopercent;
RUN;
/*PROC STDIZE DATA=mlb_hit OUT=Imputed */
/*  oprefix=Orig_         /* prefix for original variables */*/
/*  REPONLY               /* only replace do not standardize */*/
/*  METHOD=MEDIAN;        /* or MEDIAN, MINIMUM, MIDRANGE, etc. */
/*  VAR salary;           /* you can list multiple variables to impute */
/*RUN;*/
/*PROC PRINT DATA=Imputed;*/
/*RUN;*/
/*Fit Full Model(include all the regressors)*/
/*PROC GLM DATA=Imputed;*/
/*  CLASS League Division NewLeague;*/
/*  MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists Errors NewLeague;*/
/*RUN;*/
/*QUIT;*/
/*PROC UNIVARIATE DATA=Imputed;*/
/*  VAR salary;*/
/*  HISTOGRAM;*/
/*RUN;*/
PROC GLM DATA=mlb_hit;
  CLASS League Division NewLeague;
  MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists Errors NewLeague;
RUN;
QUIT;
/*Residual Analysis(model diagnostics)-> Salary */
PROC REG DATA=mlb_hit PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=mlb_hit;
 MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=mlb_hit NOPRINT;
  MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
/*********************************************************************************/
/* Macro NORMTEST is revised from the code in D'Agostino's paper.                */
/* "A Suggestion for Using Powerful and Informative Tests of Normality"          */
/* Author(s): Ralph B. D'Agostino, Albert Belanger, and Ralph B. D'Agostino Jr.  */
/* Source: The American Statistician, Vol. 44, No. 4 (Nov., 1990), pp. 316-321   */
/*																				 */ 
/* Inputs: 																		 */
/* VAR: variable name on that you would like to test Normality                   */
/* DATA: the dataset that contains variables that you want to test nomality on.  */
/*																				 */ 
/* It provides five hypothesis tests                                             */
/* (1) Shapiro-Wilk test                                                         */
/* (2) Kolmogorov-Smirnov test                                                   */
/* (3) Cramer-von Mises test                                                     */
/* (4) Anderson-Darling                                                          */
/* (5) D'Agostino's K^2                                                          */
/* For details about the first four tests, users are referred to SAS online doc  */
/* under UNIVARIATE procedure. As for D'Agostino's test, please refer to the art.*/
/* mentioned above.                                                              */
/* Revised by Ping-Shi Wu Dec. 2015 @ Lehigh University                          */
/* CURRENTLY, IT ONLY WORKS FOR ONE VARIABLE                                     */
/*********************************************************************************/
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
/*REG FAILS TO PROVIDE DW TEST. IF THAT HAPPENS, USE THE FOLLOWING ALTENATIVE -> it is just example*/
/******************************************************************************/
PROC REG DATA=mlb_hit PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL Salary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
QUIT;
/*Variable Transformation*/
DATA mlb_hit_m;
  SET mlb_hit;
  logsalary = log10(salary);
RUN;
/*DATA mlb_hit_Imputed;*/
/*  SET Imputed;*/
/*  logsalary = log10(salary);*/
/*RUN;*/
/*PROC GLM DATA=mlb_hit_Imputed;*/
/*  CLASS League Division NewLeague;*/
/*  MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists Errors NewLeague;*/
/*RUN;*/
PROC UNIVARIATE DATA=mlb_hit_m;
  VAR logsalary;
  HISTOGRAM;
RUN;
PROC GCHART DATA=mlb_hit_m; 
  VBAR salary logSalary; 
RUN;
PROC GLM DATA=mlb_hit_m;
  CLASS League Division NewLeague;
  MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists Errors NewLeague;
RUN;
/*Residual Analysis(model diagnostics)-> logsalary */
PROC REG DATA=mlb_hit_m PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=mlb_hit_m;
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=mlb_hit_m NOPRINT;
  MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
/*********************************************************************************/
/* Macro NORMTEST is revised from the code in D'Agostino's paper.                */
/* "A Suggestion for Using Powerful and Informative Tests of Normality"          */
/* Author(s): Ralph B. D'Agostino, Albert Belanger, and Ralph B. D'Agostino Jr.  */
/* Source: The American Statistician, Vol. 44, No. 4 (Nov., 1990), pp. 316-321   */
/*																				 */ 
/* Inputs: 																		 */
/* VAR: variable name on that you would like to test Normality                   */
/* DATA: the dataset that contains variables that you want to test nomality on.  */
/*																				 */ 
/* It provides five hypothesis tests                                             */
/* (1) Shapiro-Wilk test                                                         */
/* (2) Kolmogorov-Smirnov test                                                   */
/* (3) Cramer-von Mises test                                                     */
/* (4) Anderson-Darling                                                          */
/* (5) D'Agostino's K^2                                                          */
/* For details about the first four tests, users are referred to SAS online doc  */
/* under UNIVARIATE procedure. As for D'Agostino's test, please refer to the art.*/
/* mentioned above.                                                              */
/* Revised by Ping-Shi Wu Dec. 2015 @ Lehigh University                          */
/* CURRENTLY, IT ONLY WORKS FOR ONE VARIABLE                                     */
/*********************************************************************************/
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
PROC REG DATA=mlb_hit_m PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
QUIT;
*Exclude extreme observations;
DATA mlb_hit_outlier; 
 SET mlb_hit_m;  
 IF CAtBat = 14053 and CHits = 4256 THEN DELETE; /* 238 */
 IF CAtBat = 41 and CHits = 9 THEN DELETE; /* 218 */
 IF CAtBat = 9528 and CHits = 2510 THEN DELETE; /* 250 */
 IF CAtBat = 19 and CHits = 4 THEN DELETE; /* 296 */
 IF CAtBat = 2682 and CHits = 667 THEN DELETE; /* 270 */
 IF CAtBat = 711 and CHits = 148 THEN DELETE; /* 280 */
 IF CAtBat = 2964 and CHits = 808 THEN DELETE; /* 154 */
 IF CAtBat = 1750 and CHmRun = 100 THEN DELETE; /* 273 */
RUN;
/*Residual Analysis(model diagnostics)-> logsalary after deleting the outliers */
PROC REG DATA=mlb_hit_outlier PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=mlb_hit_outlier;
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=mlb_hit_outlier NOPRINT;
  MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
/*********************************************************************************/
/* Macro NORMTEST is revised from the code in D'Agostino's paper.                */
/* "A Suggestion for Using Powerful and Informative Tests of Normality"          */
/* Author(s): Ralph B. D'Agostino, Albert Belanger, and Ralph B. D'Agostino Jr.  */
/* Source: The American Statistician, Vol. 44, No. 4 (Nov., 1990), pp. 316-321   */
/*																				 */ 
/* Inputs: 																		 */
/* VAR: variable name on that you would like to test Normality                   */
/* DATA: the dataset that contains variables that you want to test nomality on.  */
/*																				 */ 
/* It provides five hypothesis tests                                             */
/* (1) Shapiro-Wilk test                                                         */
/* (2) Kolmogorov-Smirnov test                                                   */
/* (3) Cramer-von Mises test                                                     */
/* (4) Anderson-Darling                                                          */
/* (5) D'Agostino's K^2                                                          */
/* For details about the first four tests, users are referred to SAS online doc  */
/* under UNIVARIATE procedure. As for D'Agostino's test, please refer to the art.*/
/* mentioned above.                                                              */
/* Revised by Ping-Shi Wu Dec. 2015 @ Lehigh University                          */
/* CURRENTLY, IT ONLY WORKS FOR ONE VARIABLE                                     */
/*********************************************************************************/
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
PROC REG DATA=mlb_hit_outlier PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL logsalary = Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
QUIT;
/* Handling the variables */
DATA mlb_hit_outlier_m;
  SET mlb_hit_outlier;
  Years2 = Years*Years;
  CAtBat2  = CAtBat*CAtBat;
  CHits2  = CHits*CHits;
  CHmRun2  = CHmRun*CHmRun;
  CRuns2  = CRuns*CRuns;
  CRBI2  = CRBI*CRBI;
  CWalks2  = CWalks*CWalks;
RUN;
/*Residual Analysis(model diagnostics)-> logsalary after deleting the outliers */
PROC REG DATA=mlb_hit_outlier_m PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=mlb_hit_outlier_m;
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=mlb_hit_outlier_m NOPRINT;
  MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
/*********************************************************************************/
/* Macro NORMTEST is revised from the code in D'Agostino's paper.                */
/* "A Suggestion for Using Powerful and Informative Tests of Normality"          */
/* Author(s): Ralph B. D'Agostino, Albert Belanger, and Ralph B. D'Agostino Jr.  */
/* Source: The American Statistician, Vol. 44, No. 4 (Nov., 1990), pp. 316-321   */
/*																				 */ 
/* Inputs: 																		 */
/* VAR: variable name on that you would like to test Normality                   */
/* DATA: the dataset that contains variables that you want to test nomality on.  */
/*																				 */ 
/* It provides five hypothesis tests                                             */
/* (1) Shapiro-Wilk test                                                         */
/* (2) Kolmogorov-Smirnov test                                                   */
/* (3) Cramer-von Mises test                                                     */
/* (4) Anderson-Darling                                                          */
/* (5) D'Agostino's K^2                                                          */
/* For details about the first four tests, users are referred to SAS online doc  */
/* under UNIVARIATE procedure. As for D'Agostino's test, please refer to the art.*/
/* mentioned above.                                                              */
/* Revised by Ping-Shi Wu Dec. 2015 @ Lehigh University                          */
/* CURRENTLY, IT ONLY WORKS FOR ONE VARIABLE                                     */
/*********************************************************************************/
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
PROC REG DATA=mlb_hit_outlier_m PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
QUIT;
/*Clinical Significant Regressors*/
DATA mlb_hit_mm;
  SET mlb_hit_outlier_m;
  CBA = CHits/CAtBat;
  HR_H  = HmRun/Hits;
RUN;
PROC GLM DATA=mlb_hit_mm;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs 
                    RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists 
                    Errors NewLeague;
RUN;
QUIT;
DATA mlb_hit_mm; 
 SET mlb_hit_mm;  
 IF CAtBat = 831 and CHits = 210 THEN DELETE; /* 277 */
 IF CAtBat = 680 and CHits = 160 THEN DELETE; /* 276 */
 IF CAtBat = 53481 and CHits = 1369 THEN DELETE; /* 268 */
 IF CAtBat = 730 and CHits = 185 THEN DELETE; /* 274 */
RUN;
/*Residual Analysis(model diagnostics)-> logsalary after clinical significant regressors */
PROC REG DATA=mlb_hit_mm PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=mlb_hit_mm;
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=mlb_hit_mm NOPRINT;
  MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
PROC REG DATA=mlb_hit_mm PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL logsalary = Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
QUIT;
PROC PRINT DATA=mlb_hit_mm;
RUN;
DATA mlb_hit_mm; 
 SET mlb_hit_mm;  
 IF CAtBat = 3070 and CHits = 872 THEN DELETE; /* 273 */
RUN;
PROC STDIZE DATA=mlb_hit_mm METHOD=STD OUT=std_mlb;
  VAR CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs
      RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
/*STANDARDIZING REGRESSORS -> Normally, standardizing the regressors while checking multicollinearity I.E. CENTERING AND SCALING*/
PROC GLM DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs 
                    RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks League Division PutOuts Assists 
                    Errors NewLeague;
RUN;
QUIT;
/*PROC GLM DATA=std_mlb;*/
/*  CLASS League Division NewLeague;*/
/*  MODEL logsalary = CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits Runs */
/*                    RBI Walks Years CAtBat CHits League Division PutOuts;*/
/*RUN;*/
/*QUIT;*/
PROC PRINT DATA=std_mlb (obs=10);
RUN;
PROC MEANS DATA=std_mlb;                 
RUN;
/*Multicollinearity*/
PROC CORR DATA=std_mlb;
  VAR CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs 
      RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;
RUN;
PROC REG DATA=mlb_hit_mm PLOTS(LABEL)=ALL;
  MODEL logsalary = CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs 
                    RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/VIF TOL COLLIN DWPROB;
RUN;
QUIT;
/* Delecting the variables which has high correlation */
PROC REG DATA=mlb_hit_mm PLOTS(LABEL)=ALL;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors/VIF TOL COLLIN DWPROB;
RUN;
QUIT;
PROC GLM DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun League Division PutOuts Assists Errors NewLeague;
RUN;
QUIT;
/*/*STANDARDIZING REGRESSORS, I.E. CENTERING AND SCALING*/*/
/*PROC STDIZE DATA=mlb_hit_mm METHOD=STD OUT=std_mlb;*/
/*  VAR CBA HR_H Years2 CAtBat2 CHits2 CHmRun2 CRuns2 CRBI2 CWalks2 Hits HmRun Runs*/
/*      RBI Walks Years CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors;*/
/*RUN;*/;
/*CHECK WHETHER CENTERING HELP TO SOLVE THE PROBLEM*/
/*PROC REG DATA=std_mlb OUTEST=TMP PLOTS=NONE;*/
/*  MODEL logsalary = yr_major2 cr_hits2 CAB_HR CBA HR_H Hits HmRun Runs RBI Walks CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors/VIF TOL COLLIN;*/
/*RUN;*/
/*QUIT;*/
/* Partial plot */
PROC REG DATA=std_mlb OUTEST=TMP OUTVIF PLOTS=(PARTIAL);
    MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors/PARTIAL;
RUN;
QUIT;
/*NO! CENTERING DOES NOT HELP. */
/*NEXT, IS THERE ANY NEAR-ZERO-COEF REGRESSOR?*/
PROC REG DATA=std_mlb OUTEST=EST_RIDGE RIDGE=0.00001 TO 1 BY 0.01 OUTVIF;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
RUN;
QUIT;
PROC REG DATA=std_mlb OUTEST=EST_RIDGE RIDGE=0.00001 TO 0.04 BY 0.002 OUTVIF;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
  PLOT/RIDGEPLOT VREF=0;
RUN;
QUIT;
PROC GPLOT DATA=EST_RIDGE;
  WHERE _TYPE_ ='RIDGEVIF';
  PLOT (CBA HR_H Years2 CHmRun2 Hits HmRun Walks Years CHmRun PutOuts Assists Errors)*_RIDGE_/OVERLAY VREF=10;
  TITLE 'Series of VIFi';
RUN;
QUIT;
PROC REG DATA=std_mlb OUTVIF plots(only)=ridge(unpack VIFaxis=log)
  OUTEST=rrmlb ridge=0 to 0.10 by .002;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
  PLOT / RIDGEPLOT NOMODEL NOSTAT;
  TITLE 'Logsalary - Ridge Regression Calculation';
RUN;
PROC PRINT DATA=rrmlb;
  TITLE 'Logsalary - Ridge Regression Results';
RUN;
PROC REG DATA=std_mlb OUTVIF plots(only)=ridge(unpack VIFaxis=log)
  OUTEST=rrmlb_final ridge=.002;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
  PLOT / RIDGEPLOT NOMODEL NOSTAT;
  TITLE 'Logsalary - Ridge Regression Calculation';
RUN;
PROC REG DATA=rrmlb_final;
  TITLE 'Logsalary - Ridge Regression Results';
RUN;
PROC PRINT DATA=rrmlb_final;
RUN;
PROC REG DATA=std_mlb PLOTS(LABEL)=ALL;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors/VIF TOL COLLIN DWPROB;
RUN;
QUIT;
/*ALL POSSIBLE REGRESSION MODELS-> Only use numerical variables, not categorical*/
PROC REG DATA=std_mlb PLOTS(ONLY)=CRITERIA;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors/SELECTION=CP AIC BIC SBC ADJRSQ;
RUN;
QUIT;
/*PRINCIPAL COMPONENT REGRESSION*/
/*(1) DETERMINE HOW MANY COMPONENTS TO KEEP */
PROC PRINCOMP DATA=std_mlb OUT=PC_mlb_hit STD PLOTS=(SCREE PROFILE);
  TITLE 'PRINCIPAL COMPONENT REGRESSION';
  VAR CBA HR_H Years2 CHmRun2 Hits HmRun
      Walks Years CHmRun PutOuts Assists Errors;
RUN;
/*(2) PCR */
PROC REG DATA=std_mlb PCOMIT=7 OUTEST=PCR_mlb_hit;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
RUN;
QUIT;
PROC PRINT DATA=PCR_mlb_hit;
RUN;
PROC PLS DATA=std_mlb METHOD=PCR NFAC=4;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors/SOLUTION;
RUN;
QUIT;
/***************************************************/
/*Principal Components analysis*/
PROC FACTOR DATA=std_mlb METHOD=principal MINEIGEN=1 PLOT ROTATE=varimax SCREE;
  VAR CBA HR_H Years2 CHmRun2 Hits HmRun
      Walks Years CHmRun PutOuts Assists Errors;
RUN;
/* Principal Component Regression Example */
PROC PRINCOMP DATA=std_mlb OUT=pcmlb PREFIX=z OUTSTAT=PCRmlb;
  VAR CBA HR_H Years2 CHmRun2 Hits HmRun
      Walks Years CHmRun PutOuts Assists Errors;
RUN;
PROC REG DATA=pcmlb;
  MODEL logsalary = z1 z2 z3 z4/ VIF;
RUN;
PROC PRINT DATA=std_mlb;
RUN;
DATA std_mlb; 
 SET std_mlb;  
 IF CBA = 0.43147 and HR_H = -0.60050 THEN DELETE; /* 154 */
RUN;
/*Residual Analysis(model diagnostics)-> FINALLY CHECKING */
PROC REG DATA=std_mlb PLOTS(LABEL UNPACK ONLY)=(DIAGNOSTICS PARTIAL);
 MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                   Walks Years CHmRun PutOuts Assists Errors/DWPROB PARTIAL;
RUN;
QUIT;
PROC REG DATA=std_mlb;
 MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                   Walks Years CHmRun PutOuts Assists Errors/DWPROB;
RUN;
QUIT;
PROC REG DATA=std_mlb_m NOPRINT;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                    Walks Years CHmRun PutOuts Assists Errors;
  OUTPUT OUT=FIT R=EI RSTUDENT=TI STUDENT=RI PRESS=EPI;
RUN;
QUIT;
/* Detection of serious violation against Normality */
%MACRO NORMTEST(VAR,DATA);
  ODS NOPROCTITLE;
  ODS GRAPHICS /BORDER=OFF;
  ODS SELECT Moments Histogram QQPlot CDFPlot;
  TITLE "NORMAL-TEST";
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
    HISTOGRAM &VAR/NORMAL(MU=EST SIGMA=EST) KERNEL;
    QQPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    CDFPLOT &VAR/NORMAL(MU=EST SIGMA=EST);
    OUTPUT OUT=XXSTAT N=N MEAN=XBAR STD=S SKEWNESS=G1 KURTOSIS=G2;
  RUN;
  ODS SELECT TestsForNormality;
  PROC UNIVARIATE DATA=&DATA NORMAL;
    VAR &VAR;
  RUN;
  TITLE;
  OPTIONS LS=80;
  DATA _NULL_;
    SET XXSTAT;
    SQRTB1=(N-2)/SQRT(N*(N-1))*G1;
    Y=SQRTB1*SQRT((N+1)*(N+3)/(6*(N-2)));
    BETA2=3*(N*N+27*N-70)*(N+1)*(N+3)/((N-2)*(N+5)*(N+7)*(N+9));
    W=SQRT(-1+SQRT(2*(BETA2-1)));
    DELTA=1/SQRT(LOG(W));
    ALPHA=SQRT(2/(W*W-1));
    Z_B1=DELTA*LOG(Y/ALPHA+SQRT((Y/ALPHA)**2+1));
    B2=3*(N-1)/(N+1)+(N-2)*(N-3)/((N+1)*(N-1))*G2;
    MEANB2=3*(N-1)/(N+1);
    VARB2= 24*N*(N-2)*(N-3)/((N+1)*(N+1)*(N+3)*(N+5));
    X=(B2-MEANB2)/SQRT(VARB2);
    MOMENT=6*(N*N-5*N+2)/((N+7)*(N+9))*SQRT(6*(N+3)*(N+5)/(N*(N-2)*(N-3)));
    A=6+8/MOMENT*(2/MOMENT+SQRT(1+4/(MOMENT**2)));
    Z_B2=(1-2/(9*A)-((1-2/A)/(1+ X*SQRT(2/(A-4))))**(1/3))/SQRT(2/(9*A));
    PRZB1=2*(1-PROBNORM(ABS(Z_B1)));
    PRZB2=2*(1-PROBNORM(ABS(Z_B2)));
    CHITEST=Z_B1*Z_B1 + Z_B2*Z_B2;
    PRCHI=1-PROBCHI(CHITEST,2);
    FILE PRINT;
    PUT @22 "D'AGOSTINO TEST OF NORMALITY FOR VARIABLE &VAR, "
    N = /@20 G1=8.5 @33 SQRTB1 =8.5 @50 "Z=" Z_B1 8.5 @65 "P=" PRZB1 6.4
        /@20 G2=8.5 @33 B2=8.5 @50 "Z=" Z_B2 8.5 @65 "P=" PRZB2 6.4
        /@20 "K**2=CHISQ(2 DF)=" CHITEST 8.5 @65 "P=" PRCHI 6.4;
  RUN;
  TITLE;
%MEND NORMTEST;
%NORMTEST(EI,FIT)
PROC REG DATA=std_mlb PLOTS(ONLY)=RESIDUALS(SMOOTH);
 MODEL logsalary = CBA HR_H Years2 CHmRun2 Hits HmRun
                   Walks Years CHmRun PutOuts Assists Errors;
RUN;
QUIT;
/*/* DIFFERENT METHOD */*/
/*DATA std_mlb2;*/
/*  SET std_mlb;*/
/*  experience = mean(yr_major2 cr_hits2 CAB_HR CBA HR_H Hits HmRun Runs RBI Walks CAtBat CHits CHmRun CRuns CRBI CWalks PutOuts Assists Errors);*/
/*RUN;*/
/*PROC REG DATA=std_mlb2;*/
/*  MODEL logsalary =  experience;*/
/*  OUTPUT OUT=regdat p=predict r=resid rstudent=rstudent;*/
/*  PLOT rstudent.*predicted.;*/
/*RUN;*/
/*QUIT;*/
/*PROC TRANSREG DATA=stddata2;*/
/*   MODEL BOXCOX(salary) = IDENTITY(experience);*/
/*RUN;*/
/*DATA stddata3;*/
/*  SET stddata2;*/
/*  logsalary = log(salary);*/
/*  log_experience = log(experience+2);*/
/*RUN;*/
/*MODEL SELECTION*/;
/*PROC REG DATA=mlb_hit_mm PLOTS=NONE;*/
/*  MODEL logsalary = Hits HmRun Runs RBI Walks yr_major2 CAtBat cr_hits2 CHmRun CRuns CRBI CWalks PutOuts Assists Errors/SELECTION=FORWARD;*/
/*RUN;*/
/*  MODEL logsalary = Hits HmRun Runs RBI Walks yr_major2 CAtBat cr_hits2 CHmRun CRuns CRBI CWalks PutOuts Assists Errors/SELECTION=BACKWARD;*/
/*RUN;*/
/*  MODEL logsalary = Hits HmRun Runs RBI Walks yr_major2 CAtBat cr_hits2 CHmRun CRuns CRBI CWalks PutOuts Assists Errors/SELECTION=STEPWISE;*/
/*RUN;*/
/*  MODEL logsalary = Hits HmRun Runs RBI Walks yr_major2 CAtBat cr_hits2 CHmRun CRuns CRBI CWalks PutOuts Assists Errors/INCLUDE=2 SELECTION=STEPWISE;*/
/*RUN;*/
/*QUIT;*/
/* MODEL SELECTION */
PROC HPREG DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague;             
  SELECTION METHOD=forward;
  OUTPUT OUT=EST_M1;
RUN;
PROC HPREG DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague;                
  SELECTION METHOD=backward;
RUN;
PROC HPREG DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague;               
  SELECTION METHOD=stepwise;
RUN;
PROC HPREG DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/ vif clb;
  SELECTION METHOD=stepwise;
  OUTPUT OUT=baseballOut p=predictedLogSalary r h cookd rstudent;
RUN;
/*ADVANCED SELECTION METHODS*/
PROC GLMSELECT DATA=std_mlb PLOTS=NONE;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/SELECTION=LAR;
RUN;
QUIT;

PROC GLMSELECT DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/SELECTION=LASSO(STEP=20 CHOOSE=AICC);
RUN;
QUIT;
PROC GLMSELECT DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/SELECTION=ELASTICNET(STEP=20 CHOOSE=AICC);
RUN;
QUIT;
PROC GLMSELECT DATA=std_mlb;
  CLASS League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                       Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/SELECTION=STEPWISE(SELECT=SL STOP=PRESS);
RUN;
QUIT;
PROC QUANTSELECT DATA=std_mlb;
  Class League Division NewLeague;
  MODEL logsalary = CBA HR_H Years2 CHmRun2 CWalks2 Hits HmRun
                        Walks Years CHmRun CWalks League Division PutOuts Assists Errors NewLeague/QUANTILES=0.1 0.5 0.9 SELECTION=lasso(ADAPTIVE STOP=aic CHOOSE=sbc sh=7);
RUN;
/*ODS RFT CLOSE;*/
/*FOR EXAMPLE*/
/* MODEL1 is from traditional method(forward, backward, stepwise*/
/* MODEL1 is from traditional method(forward, backward, stepwise*/
PROC REG DATA=std_mlb OUTEST=EST_M1 NOPRINT;
  M1:MODEL logsalary = CBA Years2 CWalks2 Hits Years CHmRun CWalks PutOuts;
RUN;
QUIT;
PROC SCORE DATA=std_mlb SCORE=EST_M1 OUT=NewPred_1 TYPE=PARMS NOSTD PREDICT;
  VAR CBA Years2 CWalks2 Hits Years CHmRun CWalks PutOuts;
RUN;
PROC PRINT DATA=NewPred_1;
  SUM ERR2;
RUN;
