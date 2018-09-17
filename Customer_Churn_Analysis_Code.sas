LIBNAME in "P:\project\Prachi";

/**** Import CSV into SAS data set ****/

proc import datafile = 'P:\project\fermalogis_event_type.csv' out = in.modified_ferma dbms = CSV ;
run;

/***** Exploratory Data Analysis ********************/


data in.modified_ferma1;
set in.modified_ferma;

HoursWorkedDaily = DailyRate/HourlyRate;
HoursWokedMonthly = MonthlyRate/DailyRate;

/*** Correcting Turnover variable using Type ***/

if Type>0 then Turnover='Yes';
else Turnover='No';

/*** Creating Employee Experience category ***/

IF YearsAtCompany <= 5 THEN EmployeeType = 'Young';
ELSE EmployeeType = 'Experienced';
	
YearsBonusRewarded = SUM ( bonus_1 , bonus_2 , bonus_3 , bonus_4 , bonus_5 , 
	bonus_6 , bonus_7 , bonus_8 , bonus_9	, bonus_10 ,
	bonus_11 , bonus_12 , bonus_13	, bonus_14 , bonus_15 ,	bonus_16 ,	
	bonus_17 , bonus_18 , bonus_19 , bonus_20 , bonus_21 , bonus_22	,
	bonus_23 , bonus_24 , bonus_25 , bonus_26 , bonus_27 , bonus_28	,
	bonus_29 , bonus_30 , bonus_31 , bonus_32 , bonus_33 , bonus_34	,
	bonus_35 , bonus_36 , bonus_37 , bonus_38 , bonus_39 , bonus_40);

/*** Calculating Bonus Ratio per year with company ***/	
BonusRewardRatio = ROUND ((YearsBonusRewarded/YearsAtCompany),0.1) ;


/**** Mapping of variables ***/

if environmentsatisfaction=4 then environment_satisfaction='a.Very High';
else if environmentsatisfaction=3 then environment_satisfaction='b.High';
else if environmentsatisfaction=2 then environment_satisfaction='c.Medium';
else if environmentsatisfaction=1 then environment_satisfaction='d.Low';

if jobinvolvement=4 then job_involvement='a.Very High';
else if jobinvolvement=3 then job_involvement='b.High';
else if jobinvolvement=2 then job_involvement='c.Medium';
else if jobinvolvement=1 then job_involvement='d.Low';

attrition_rsn='                ';
if type=0 then attrition_rsn='a. No_Turnover';
else if type=1 then attrition_rsn='b. Retirement';
else if type=2 then attrition_rsn='c. Voluntary';
else if type=3 then attrition_rsn='d. Personal';
else if type=4 then attrition_rsn='e. Fired';

run;

/**** Plotting of variables against Turnover and its types ***/

/* Business Travel vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / GROUP = BusinessTravel;
TITLE 'Business Travel v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / GROUP = BusinessTravel;
TITLE 'Business Travel v/s Turnover Types';
RUN;

/* Education Field vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR EducationField / GROUP = Turnover;
TITLE 'Education Field v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR EducationField / GROUP = Type;
TITLE 'Education Field v/s Turnover Types';
RUN;

/* Distance From Home vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / Response = DistanceFromHome stat=mean;
TITLE 'Distance from home v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / Response = DistanceFromHome stat=mean;
TITLE 'Distance from home v/s Turnover Types';
RUN;

/* Department vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Department / GROUP = Turnover;
TITLE 'Department v/s Turnover';
RUN;

/* Daily rate vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / Response = DailyRate stat=mean;
TITLE 'Daily Rate v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / Response = DailyRate stat=mean;
TITLE 'Daily Rate v/s Turnover Types';
RUN;

/*** Grouping data by Employee Age and Turnover Type ***/

proc sql;
create table agetable as 
select count(*) as tot, age,turnover,type 
from in.modified_ferma 
group by age,type;

/* Age vs Turnover */
PROC SGPLOT DATA = agetable;
series x=age y=tot /group=turnover;
TITLE 'Age vs Total employees grouped by Turnover';
RUN;

PROC SGPLOT DATA = agetable;
series x=age y=tot /group=type;
TITLE 'Age vs Total employees grouped by Turnover Types';
RUN;

/* Stock Option Level vs Turnover */
PROC FREQ DATA = in.Modified_ferma1;
TABLES Turnover * StockOptionLevel / CHISQ;
TITLE 'Turnover v/s stockoptionLevel';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = StockOptionLevel;
LABEL Turnover = 'Events of Turnover';
TITLE 'Turnover v/s stockoptionLevel';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / GROUP = StockOptionLevel GROUPDISPLAY=cluster ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s stockoptionLevel';
RUN;

/* Total Working Years vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
HISTOGRAM TotalWorkingYears/ SHOWBINS;
DENSITY TotalWorkingYears;
*DENSITY TotalWorkingYears/ TYPE = KERNEL;
TITLE 'Over TotalWorkingYears trend';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ RESPONESE=TotalWorkingYears STAT= MEAN;
LABEL Turnover= 'Events of Turnover';
TITLE 'Turnover v/s TotalWorkingYears';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBOX TotalWorkingYears/ CATEGORY = Turnover;
TITLE 'TotalWorkingYears v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 (where=(Turnover = 'Yes'));
VBOX TotalWorkingYears/ CATEGORY = Type;
TITLE 'TotalWorkingYears v/s Event Type';
RUN;

/* Training Times vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONESE= TrainingTimesLastYear STAT=Mean;
LABEL Turnover = 'Events of Turnover';
TITLE 'Turnover  v/s TrainingTimesLastYear';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONESE= TrainingTimesLastYear STAT=Mean;
LABEL Type= 'Events of Turnover';
TITLE 'Types v/s TrainingTimesLastYear';
RUN;

/* Work Life Balance vs Turnover */
PROC FREQ DATA = in.Modified_ferma1;
TABLES Turnover * WorkLifeBalance / CHISQ;
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = WorkLifeBalance;
LABEL Turnover= 'Events of Turnover';
TITLE ' Turnover v/s WorkLifeBalance';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 (where=(Turnover = 'Yes'));
VBAR Type / GROUP = WorkLifeBalance GROUPDISPLAY=cluster;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s WorkLifeBalance ';
RUN;

/* Years at Company vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= YearsAtCompany STAT=mean  ;
LABEL Turnover = 'Events of Turnover';
TITLE 'Turnover v/s YearsAtCompany ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= YearsAtCompany STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsAtCompany ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBOX YearsAtCompany/ CATEGORY = Turnover;
TITLE 'YearsAtCompany v/s Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 (where=(Turnover = 'Yes'));
VBOX YearsAtCompany/ CATEGORY = Type;
TITLE 'YearsAtCompany v/s Event Type';
RUN;

PROC UNIVARIATE DATA = in.Modified_ferma1 (where=(Turnover = 'Yes'));
VAR YearsAtCompany ;
HISTOGRAM YearsAtCompany /NORMAL;
PROBPLOT YearsAtCompany ;
TITLE'YearsAtCompany ';
RUN;

/* Years In Current Role vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= YearsInCurrentRole STAT=mean  ;
TITLE 'Event types v/s YearsInCurrentRole ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= YearsInCurrentRole STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsInCurrentRole ';
RUN;

/* Years at Company vs Years In Current Role by Turnover Types */
PROC SGPLOT DATA = in.Modified_ferma1;
SCATTER X = YearsAtCompany Y = YearsInCurrentRole/ GROUP=Type ;
XAXIS LABEL = 'YearsAtCompany ' VALUES = (0 TO 40 BY 5);
YAXIS LABEL = 'YearsInCurrentRole' VALUES = (0 TO 40 BY 5);
RUN;

/* Years Since Last Promotion vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= YearsSinceLastPromotion STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsSinceLastPromotion ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= YearsSinceLastPromotion STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsSinceLastPromotion ';
RUN;

/* Years With Current Manager vs Turnover */
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= YearsWithCurrManager STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsWithCurrManager ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= YearsWithCurrManager STAT=mean  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s YearsWithCurrManager ';
RUN;

/* Bonus Ratio vs Turnover */

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type/ GROUP= BonusRewardRatio GROUPDISPLAY=cluster  ;
LABEL Type = 'Events of Turnover';
TITLE 'Event types v/s BonusRewardRatio ';
RUN;

/* 
Creating Covariance and Correlation Matrices for Duration variables - 
Total Working Years
Years at Company
Years in Current Role
Years since Last Promotion
Years with Current Manager 
*/

proc corr data=in.Modified_ferma1 noprob outp=OutCorr /** store results **/
          nomiss /** listwise deletion of missing values **/
          cov;   /**  include covariances **/
var TotalWorkingYears YearsAtCompany YearsInCurrentRole YearsSinceLastPromotion	YearsWithCurrManager;
run;

/* Over18 Indicator vs Turnover */
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*Over18 / CHISQ;
TITLE 'Turnover vs Over18';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = Over18;
TITLE 'Turnover vs Over18';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP = Over18 GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs Over18';
RUN;

/* Over Time vs Turnover*/
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*OverTime / CHISQ;
TITLE 'Turnover vs OverTime';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = OverTime;
TITLE 'Turnover vs OverTime';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP = OverTime GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs OverTime';
RUN;

/* Number of companies worked vs Turnover */
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*NumCompaniesWorked / CHISQ;
TITLE 'Turnover vs Number of companies worked';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = NumCompaniesWorked;
TITLE 'Turnover vs Number of companies worked';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP = NumCompaniesWorked GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs Number of companies worked';
RUN;

/* Relationship Satisfaction vs Turnover */
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*RelationshipSatisfaction / CHISQ;
TITLE 'Turnover vs Relationship Satisfaction';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = RelationshipSatisfaction;
TITLE 'Turnover vs Relationship Satisfaction';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP = RelationshipSatisfaction GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs RelationshipSatisfaction';
RUN;

/* Performance Rating vs Turnover*/
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*PerformanceRating / CHISQ;
TITLE 'Turnover vs Performance Rating';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = PerformanceRating;
TITLE 'Turnover vs  Performance Rating';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP =PerformanceRating GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs Performance Rating';
RUN;

/* Standard Working Hours vs Turnover*/
PROC FREQ DATA = in.Modified_ferma1;
TABLES TURNOVER*StandardHours / CHISQ;
TITLE 'Turnover vs Standard Working Hours';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover/ GROUP = StandardHours;
TITLE 'Turnover vs Standard Working Hours';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1 ;
VBAR Type / GROUP =StandardHours GROUPDISPLAY=cluster ;
TITLE 'Types of Turnover vs Standard Working Hours';
RUN;

/* Correlation of Income, Rate and Salary Hike with Types of Turnover*/
PROC CORR DATA= in.Modified_ferma1 Plots=matrix(histogram);
VAR MonthlyIncome MonthlyRate PercentSalaryHike;
WITH TYPE ;
TITLE ' Correlation with Types of Turnover';
RUN;

/* Monthly Income vs Turnover*/
	/*Bar Graph*/
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= MonthlyIncome STAT=mean  ;
TITLE 'Turnover vs  Monthly Income ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= MonthlyIncome STAT=mean  ;
TITLE 'Types of Turnover vs  Monthly Income ';
RUN;

	/*Box Plot*/
PROC SGPLOT DATA =  in.Modified_ferma1;
VBOX  MonthlyIncome/ CATEGORY = Turnover;
TITLE ' Monthly Income vs Turnover';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBOX  MonthlyIncome/ CATEGORY = Type;
TITLE ' Monthly Income vs Types of Turnover';
RUN;

/* Monthly Rate vs Turnover*/
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE=  MonthlyRate STAT=mean  ;
TITLE 'Turnover vs  Monthly Rate ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE=  MonthlyRate STAT=mean  ;
TITLE 'Types of Turnover vs  Monthly Rate ';
RUN;

/* Percentage Salary Hike vs Turnover*/
PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Turnover / RESPONSE= PercentSalaryHike STAT=mean  ;
TITLE 'Turnover vs Percentage Salary Hike ';
RUN;

PROC SGPLOT DATA = in.Modified_ferma1;
VBAR Type / RESPONSE= PercentSalaryHike STAT=mean  ;
TITLE 'Types of Turnover vs Percentage Salary Hike ';
RUN;

/**** Percentile distribution of Employee Number, Hourly Rate, Job Level and Job Satisfaction ***/
proc means data = in.Modified_ferma1 mean p25 p50 p75 min max maxdec=1;
var EmployeeNumber HourlyRate JobLevel JobSatisfaction Age MonthlyIncome DistanceFromHome;
title 'Mean analysis at overall data';
run;

/*** 
Creating variable buckets : 0-p25, p25-p50, p50-p75, p75-p100 
EmployeeNumber : 	<=500, 500-1000, 	1000-1500, 	>1500
HourlyRate :		<=50, 	50-65, 		65-85, 		>85
Age:				<=30,	31-35,		36-45,		>45
Income:				<=3000,	3000-5000,	5000-8500,	>8500
DistfromHome:		<=2,	3-7,		8-14,		>=15	

Job level is already categorical from 1 to 5
Job Satisfaction is also categorical from 1 to 4
***/

/**** Frequency analysis of categorical variables to understand distribution ***/
proc freq data =in.Modified_ferma1;
tables JobLevel JobSatisfaction environment_satisfaction job_involvement Gender JobRole MaritalStatus / norow nocol nopct;
title 'Frequency of categorical variables';
run;

data in.Modified_ferma1;
set in.Modified_ferma1;

ID='               ';
if EmployeeNumber<=500 then ID='a. <=500';
else if EmployeeNumber<=1000 then ID='b. 500-1000';
else if EmployeeNumber<=1500 then ID='c. 1000-1500';
else ID='d. >1500';

Hourly_rate='             ';
if HourlyRate<=50 then Hourly_rate='a. <=50';
else if HourlyRate<=65 then Hourly_rate='b. 50-65';
else if HourlyRate<=85 then Hourly_rate='c. 65-85';
else Hourly_rate='d. >85';

AgeBucket='             ';
if Age<=30 then AgeBucket='a. <=30';
else if Age<=35 then AgeBucket='b. 31-35';
else if Age<=45 then AgeBucket='c. 36-45';
else AgeBucket='d. >=46';

IncomeBucket='             ';
if MonthlyIncome<=3000 then IncomeBucket='a. <=3K';
else if MonthlyIncome<=5000 then IncomeBucket='b. 3K-5K';
else if MonthlyIncome<=8500 then IncomeBucket='c. 5K-8.5K';
else IncomeBucket='d. >=8.5K';

DistanceFromHomeBucket='             ';
if DistanceFromHome<=2 then DistanceFromHomeBucket='a. <=2';
else if DistanceFromHome<=7 then DistanceFromHomeBucket='b. 3-7';
else if DistanceFromHome<=14 then DistanceFromHomeBucket='c. 8-14';
else DistanceFromHomeBucket='d. >=15';

run;

/*** Percentage Bar Charts of Variables vs Turnover Event ***/

proc freq data=in.Modified_ferma1 order=freq;
tables 
turnover*ID
turnover*environment_satisfaction
turnover*Gender
turnover*Hourly_rate
turnover*job_involvement
turnover*JobLevel
turnover*JobRole
turnover*JobSatisfaction
turnover*MaritalStatus 
/ plots=freqplot(twoway=stacked scale=grouppct); 
run;

/*** Percentage Bar Charts of Variables vs Turnover Reason when Turnover event occurs ***/

proc freq data=in.Modified_ferma1 (where=(turnover='Yes')) order=freq;
tables 
attrition_rsn*ID
attrition_rsn*environment_satisfaction
attrition_rsn*Gender
attrition_rsn*Hourly_rate
attrition_rsn*job_involvement
attrition_rsn*JobLevel
attrition_rsn*JobRole
attrition_rsn*JobSatisfaction
attrition_rsn*MaritalStatus 
/ plots=freqplot(twoway=stacked scale=grouppct); 
run;

data in.Modified_ferma1 (drop=Turnover);
set in.Modified_ferma1;

IF Turnover='Yes' then Turn=1 ;
ELSE Turn=0;

run;

data in.Modified_ferma2 (drop=Turn);
set in.Modified_ferma1;

Turnover=Turn;
run;

/* Is there any difference in attrition between different employee groups or categories? */
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA EnvironmentSatisfaction;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA JobInvolvement;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA JobSatisfaction;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA NumCompaniesWorked;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2 METHOD=LIFE;
    TIME YearsAtCompany*Turnover(0);
    STRATA TotalWorkingYears;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA StockOptionLevel;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA TrainingTimesLastYear;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA YearsInCurrentRole;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA YearsWithCurrManager;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA BonusRewardRatio;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA BusinessTravel;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2 PLOT=S(NOCENSOR);
    TIME YearsAtCompany*Turnover(0);
    STRATA EducationField;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2;
    TIME YearsAtCompany*Turnover(0);
    STRATA MaritalStatus;
RUN;
PROC LIFETEST DATA=in.Modified_ferma2 PLOTS=S(NOCENSOR);
    TIME YearsAtCompany*Turnover(0);
    STRATA OverTime;
RUN;

/* Can I combine different event types together? Or do all need to be handled separately? */

/* Is hazard function equal for all event types? */
PROC FREQ data=in.Modified_ferma2;
    WHERE type ne 0;
    TABLES type /chisq;
RUN;

/* Are type hazards linearly related? */
DATA retire;
    SET in.Modified_ferma2;
    event=(Type=1);

    /*this is for censoring out other types, another way to write if statement*/
    reason='retired';

DATA volun;
    SET in.Modified_ferma2;
    event=(Type=2);
    reason='voluntary';
DATA involun;
    SET in.Modified_ferma2;
    event=(Type=3);
    reason='involuntary';
DATA fired;
    SET in.Modified_ferma2;
    event=(Type=4);
    reason='fired';

DATA combine;
    /*we combined the datasets to use them as strata in the graphical analysis*/
    SET retire volun involun fired;

PROC LIFETEST DATA=COMBINE PLOTS=LLS;
    /*LLS plot is requested*/
    TIME YearsAtCompany*event(0);
    STRATA reason /diff=all;
RUN;


/*Test whether coefficients found for each event type is equal to
coefficients found for the model created when no distinction made between types*/
/*IF YES, we don't use the event types to model the data. If there is a difference
then we need to create models for each event type. */

DATA in.Modified_ferma2;
SET in.Modified_ferma2;

    IF MaritalStatus="Divorce" THEN
        MaritalStatus_LE=1;
    ELSE IF MaritalStatus="Single" THEN
        MaritalStatus_LE=2;
    ELSE
        MaritalStatus_LE=3;
            Int_CurrMgr=YearsWithCurrManager * YearsAtCompany;
    Int_CurrRole=YearsInCurrentRole * YearsAtCompany;
    Int_TotWork=TotalWorkingYears * YearsAtCompany;
    Int_MarStat=MaritalStatus_LE * YearsAtCompany;
RUN;

/* Adding Interaction variables */
PROC PHREG DATA=in.Modified_ferma2;
    CLASS BusinessTravel Department EducationField JobRole MaritalStatus 
        AgeBucket IncomeBucket Gender(ref='Female') OverTime(ref='No') 
        DistanceFromHomeBucket EmployeeType;
    MODEL YearsAtCompany*Type(0)=Age DailyRate DistanceFromHome Education 
        EnvironmentSatisfaction HourlyRate JobInvolvement JobLevel 
        JobSatisfaction MonthlyIncome MonthlyRate NumCompaniesWorked 
        PercentSalaryHike PerformanceRating RelationshipSatisfaction 
        StockOptionLevel TotalWorkingYears TrainingTimesLastYear 
        WorkLifeBalance YearsInCurrentRole YearsSinceLastPromotion 
        YearsWithCurrManager HoursWorkedDaily HoursWokedMonthly BusinessTravel 
        Department EducationField JobRole MaritalStatus AgeBucket Int_CurrMgr 
        Int_CurrRole Int_TotWork Int_MarStat IncomeBucket Gender OverTime 
        DistanceFromHomeBucket EmployeeType;
 
RUN;

PROC PHREG DATA=in.Modified_ferma2;
    CLASS BusinessTravel Department EducationField JobRole MaritalStatus 
        AgeBucket IncomeBucket Gender(ref='Female') OverTime(ref='No') 
        DistanceFromHomeBucket EmployeeType;
    MODEL YearsAtCompany*Type(0, 2, 3, 4)=Age DailyRate DistanceFromHome 
        Education EnvironmentSatisfaction HourlyRate JobInvolvement JobLevel 
        JobSatisfaction MonthlyIncome MonthlyRate NumCompaniesWorked 
        PercentSalaryHike PerformanceRating RelationshipSatisfaction 
        StockOptionLevel TotalWorkingYears TrainingTimesLastYear 
        WorkLifeBalance YearsInCurrentRole YearsSinceLastPromotion 
        YearsWithCurrManager HoursWorkedDaily HoursWokedMonthly BusinessTravel 
        Department EducationField JobRole MaritalStatus AgeBucket Int_CurrMgr 
        Int_CurrRole Int_TotWork Int_MarStat IncomeBucket Gender OverTime 
        DistanceFromHomeBucket EmployeeType;
RUN;

PROC PHREG DATA=in.Modified_ferma2;
    CLASS BusinessTravel Department EducationField JobRole MaritalStatus 
        AgeBucket IncomeBucket Gender(ref='Female') OverTime(ref='No') 
        DistanceFromHomeBucket EmployeeType;
    MODEL YearsAtCompany*Type(0, 1, 3, 4)=Age DailyRate DistanceFromHome 
        Education EnvironmentSatisfaction HourlyRate JobInvolvement JobLevel 
        JobSatisfaction MonthlyIncome MonthlyRate NumCompaniesWorked 
        PercentSalaryHike PerformanceRating RelationshipSatisfaction 
        StockOptionLevel TotalWorkingYears TrainingTimesLastYear 
        WorkLifeBalance YearsInCurrentRole YearsSinceLastPromotion 
        YearsWithCurrManager HoursWorkedDaily HoursWokedMonthly BusinessTravel 
        Department EducationField JobRole MaritalStatus AgeBucket Int_CurrMgr 
        Int_CurrRole Int_TotWork Int_MarStat IncomeBucket Gender OverTime 
        DistanceFromHomeBucket EmployeeType;
RUN;

PROC PHREG DATA=in.Modified_ferma2;
    CLASS BusinessTravel Department EducationField JobRole MaritalStatus 
        AgeBucket IncomeBucket Gender(ref='Female') OverTime(ref='No') 
        DistanceFromHomeBucket EmployeeType;
    MODEL YearsAtCompany*Type(0, 1, 2, 4)=Age DailyRate DistanceFromHome 
        Education EnvironmentSatisfaction HourlyRate JobInvolvement JobLevel 
        JobSatisfaction MonthlyIncome MonthlyRate NumCompaniesWorked 
        PercentSalaryHike PerformanceRating RelationshipSatisfaction 
        StockOptionLevel TotalWorkingYears TrainingTimesLastYear 
        WorkLifeBalance YearsInCurrentRole YearsSinceLastPromotion 
        YearsWithCurrManager HoursWorkedDaily HoursWokedMonthly BusinessTravel 
        Department EducationField JobRole MaritalStatus AgeBucket Int_CurrMgr 
        Int_CurrRole Int_TotWork Int_MarStat IncomeBucket Gender OverTime 
        DistanceFromHomeBucket EmployeeType;
RUN;

PROC PHREG DATA=in.Modified_ferma2;
    CLASS BusinessTravel Department EducationField JobRole MaritalStatus 
        AgeBucket IncomeBucket Gender(ref='Female') OverTime(ref='No') 
        DistanceFromHomeBucket EmployeeType;
    MODEL YearsAtCompany*Type(0, 1, 2, 3)=Age DailyRate DistanceFromHome 
        Education EnvironmentSatisfaction HourlyRate JobInvolvement JobLevel 
        JobSatisfaction MonthlyIncome MonthlyRate NumCompaniesWorked 
        PercentSalaryHike PerformanceRating RelationshipSatisfaction 
        StockOptionLevel TotalWorkingYears TrainingTimesLastYear 
        WorkLifeBalance YearsInCurrentRole YearsSinceLastPromotion 
        YearsWithCurrManager HoursWorkedDaily HoursWokedMonthly BusinessTravel 
        Department EducationField JobRole MaritalStatus AgeBucket Int_CurrMgr 
        Int_CurrRole Int_TotWork Int_MarStat IncomeBucket Gender OverTime 
        DistanceFromHomeBucket EmployeeType;
RUN;

DATA LogRatioTest_DoWeNeedThreeModels;
    Nested=2091.492;
    Fired=91.122;
    Voluntary=828.949;
    Involuntary=44.793;
    Retired=311.036;
    Total=Fired+Voluntary+Involuntary+Retired;
    Diff=Nested - Total;
    P_value=1 - probchi(Diff, 117);
    *39*4 coef. in 4 models - 39 coef. in nested;
RUN;

PROC PRINT DATA=LogRatioTest_DoWeNeedThreeModels;
    FORMAT P_Value 5.3;
RUN;




/**************** Creating Models ******************/


/* -----------------------------------Combined Model------------------------------------------------ */
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;		
RUN;

/* Assessment of Non-Proportionality */
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,2,3,1) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ASSESS PH / RESAMPLE ;
RUN;



/* Testing Proportionality assumption using ASSESS by not including time-dependent covariates */ 
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;
	ASSESS PH/ RESAMPLE;
RUN;	

DATA in.Modified_ferma2;
SET in.Modified_ferma2;
IF MaritalStatus = "Divorce" THEN MaritalStatus_LE=1; ELSE IF MaritalStatus = "Single" THEN MaritalStatus_LE=2 ;
ELSE MaritalStatus_LE=3;
RUN;


/* Adding Interaction variables */
PROC PHREG DATA = in.Modified_ferma2;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket Int_CurrMgr Int_CurrRole
	Int_TotWork Int_MarStat IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05; 
	Int_CurrMgr = 	YearsWithCurrManager * YearsAtCompany;
	Int_CurrRole = YearsInCurrentRole * YearsAtCompany;
	Int_TotWork = TotalWorkingYears * YearsAtCompany;
	Int_MarStat = MaritalStatus_LE * YearsAtCompany;
RUN;	


/* Adding variables which caused non-proportianlity into the STRATA statement */
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender 
	OverTime DistanceFromHomeBucket EmployeeType PreviousYearBonus YearsBonusRewarded_cal BonusRewardRatio_cal / TIES=EFRON
	SELECTION=backward SLSTAY=0.05; 
	STRATA YearsInCurrentRole YearsWithCurrManager TotalWorkingYears MaritalStatus;
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;
RUN;	




/* Adding variables which caused non-proportianlity into the STRATA statement but with no Bonus variables*/
PROC PHREG DATA = in.Modified_ferma2 ;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender 
	OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON
	SELECTION=backward SLSTAY=0.05; 
	STRATA YearsInCurrentRole YearsWithCurrManager TotalWorkingYears MaritalStatus;
RUN;

/* ---------------------------------------- Separate Models ---------------------------------------*/

/* Model for Type 1 Turnover (Retirement) */ 
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,2,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;		
RUN;


/* Assessment of Non-Proportionality */
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,2,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ASSESS PH / RESAMPLE ;
RUN;



/* Adding Interaction variables and STRATA statement*/
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,2,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType Int_NumCompaniesWorked Int_YearsWithCurrManager
	 / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;
	Int_NumCompaniesWorked = NumCompaniesWorked * YearsAtCompany;
	Int_YearsWithCurrManager = YearsWithCurrManager * YearsAtCompany;
	STRATA BusinessTravel;
RUN;


/* Model for Type 2 Turnover (Voluntary Termination) */ 
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;		
RUN;


/* Assessment of Non-Proportionality */
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ASSESS PH / RESAMPLE ;
RUN;

/* Adding Interaction variables and STRATA statement */
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,3,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;	
        Int_Age = Age * YearsAtCompany;
        Int_HoursWorkedDaily = HoursWorkedDaily * YearsAtCompany;
	STRATA 	JobRole;
RUN;


/* Model for Type 3 Turnover (InVoluntary Termination) */ 
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,2,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;		
RUN;


/* Assessment of Non-Proportionality */
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,2,1,4) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ASSESS PH / RESAMPLE ;
RUN;


/* Model for Type 4 Turnover (Fired) */ 
PROC PHREG DATA = in.Modified_ferma2;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,2,3) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager YearsBonusRewarded_cal BonusRewardRatio_cal HoursWorkedDaily 
	PreviousYearBonus HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ARRAY bonus_(*) bonus_1-bonus_40;
	PreviousYearBonus = bonus_[YearsAtCompany - 1];
        YearsBonusRewarded_cal = sum(of bonus_1 - bonus_40);
        BonusRewardRatio_cal = YearsBonusRewarded_cal/YearsAtCompany;		
RUN;

/* Assessment of Non-Proportionality */
PROC PHREG DATA = in.Modified_ferma2 PLOTS=SURVIVAL;
	WHERE YearsAtCompany > 1;
	CLASS BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket IncomeBucket Gender(ref = 'Female')
	 OverTime(ref = 'No') DistanceFromHomeBucket EmployeeType ;
	MODEL YearsAtCompany*Type(0,1,2,3) = Age  DailyRate	DistanceFromHome Education EnvironmentSatisfaction HourlyRate	
	JobInvolvement	JobLevel JobSatisfaction MonthlyIncome	MonthlyRate	NumCompaniesWorked	PercentSalaryHike	
	PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance	
	YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager HoursWorkedDaily 
	HoursWokedMonthly BusinessTravel Department EducationField  JobRole MaritalStatus  AgeBucket 
	IncomeBucket Gender OverTime DistanceFromHomeBucket EmployeeType / TIES=EFRON SELECTION=backward SLSTAY=0.05;	
	ASSESS PH / RESAMPLE ;
RUN;













