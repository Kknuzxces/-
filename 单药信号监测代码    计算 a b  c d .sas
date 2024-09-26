
*�������ݿ�;

libname raw1 "E:\ȥ������\2004-2022ȥ������";
*Ŀ��ҩ�����ݿ�;
libname datalib1 "E:\ȥ������\��ʱ����";
*�Ŵʵ�;
libname MED "E:\ȥ������\05��ܻҽѧ�ʵ�";

/*����ҩ�����ƽ���ɸѡ----  �õ�Ŀ��ҩ���Ӧ�����в�����Ӧ*/
proc sql;
	create table t_Drug as
	select distinct *
	from  raw1.Drug where    ( upcase(drugname) in ('MORPHINE', 'MORPHINE SULFATE')   or   upcase(prod_ai) in ('MORPHINE', 'MORPHINE SULFATE')) and ROLE_COD='PS';
quit;


%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid)||"-"||strip(put(GetDataYear,z2.))||"-"||strip(put(GetDataQT,z2.)) in (select strip(primaryid)||"-"||strip(put(GetDataYear,z2.))||"-"||strip(put(GetDataQT,z2.)) from t_Drug)  ;
quit;

%mend;

%selectdata2(outds=datalib1.DRUG,fromds=raw1.DRUG);
%selectdata2(outds=datalib1.REAC,fromds=raw1.REAC);
%selectdata2(outds=datalib1.DEMO,fromds=raw1.DEMO);
%selectdata2(outds=datalib1.RPSR,fromds=raw1.RPSR);
%selectdata2(outds=datalib1.THER,fromds=raw1.THER);
%selectdata2(outds=datalib1.OUTC,fromds=raw1.OUTC);
%selectdata2(outds=datalib1.INDI,fromds=raw1.INDI);
proc export data=datalib1.DRUG
outfile='D:\QIUWEN\1\datalib1.DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.REAC
outfile='D:\QIUWEN\1\datalib1.REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.DEMO
outfile='D:\QIUWEN\1\datalib1.DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.RPSR
outfile='D:\QIUWEN\1\datalib1.RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.THER
outfile='D:\QIUWEN\1\datalib1.THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.OUTC
outfile='D:\QIUWEN\1\datalib1.OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=datalib1.INDI
outfile='D:\QIUWEN\1\datalib1.INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from datalib1.REAC  as a
	left join datalib1.DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\1\PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set datalib1.drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join datalib1.Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join datalib1.Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\1\�����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\1\�����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\1\������Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.REAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  DATALIB1.REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\1\������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Datalib1.Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\1\�˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set datalib1.outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\1\���ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set Datalib1.demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\1\ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\1\���ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\1\SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

/*Ů�Ժ������������*/
/*Ů�Է���*/
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data datalib1.DEMO1;
 set Datalib1.Demo(keep=SEX AGE REPORTER_COUNTRY primaryid );
 AGE1=input(AGE,BEST32.);
yearsgroup=put(AGE1,AGEAGEfmt.);
 yearsgroup=put(years,AGEAGEfmt.);
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE years AGE1;
Run;

data DEMO2;
set datalib1.DEMO1;
if SEX ='F' then output;
RUN;
data DEMO3;
set datalib1.DEMO1;
if SEX ='M' then output;
RUN;
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO2);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\2\Ů��ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\2\Ů��ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\2\Ů��ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\2\Ů��ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\2\Ů��ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\2\Ů��ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\2\Ů��ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\2\Ů��ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\2\Ů�Բ����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\2\Ů�Բ����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\2\Ů������Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\2\Ů�Բ�����Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\2\Ů���˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\2\Ů�����ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\2\Ů��ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\2\Ů�����ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\2\Ů��SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
/*���Է���*/
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO3);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\2\����ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\2\����ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\2\����ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\2\����ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\2\����ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\2\����ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\2\����ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\2\����ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\2\���Բ����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\2\���Բ����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\2\�в�����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\2\���Բ�����Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\2\�����˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\2\�������ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\2\����ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\2\�������ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\2\����SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
/*�������*/
/*С��18�����*/
Proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data Datalib1.DEMO1;
 set Datalib1.Demo(keep=SEX AGE REPORTER_COUNTRY primaryid );
AGE1=input(AGE,BEST32.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE;
Run;

data DEMO2;
set datalib1.DEMO1;
if yearsgroup ='<18' then output;
RUN;
data DEMO3;
set datalib1.DEMO1;
if yearsgroup ='18-64' then output;
RUN;
data DEMO4;
set datalib1.DEMO1;
if yearsgroup ='>=65' then output;
RUN;
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO2);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\3\С��18��ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\3\С��18��ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\3\С��18��ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\3\С��18��ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\3\С��18��ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\3\С��18��ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\3\С��18��ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\3\С��18��ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\3\С��18�겻���¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\3\С��18�겻���¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\3\С��18�겻����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\3\С��18�겻����Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\3\С��18���˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\3\С��18�����ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\3\С��18��ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=T_drug
outfile='D:\QIUWEN\3\С��18�����ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
proc export data=PPPP
outfile='D:\QIUWEN\3\С��18��SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
/*18-64�����*/

%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO3);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\3\18-64��ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\3\18-64��ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\3\18-64��ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\3\18-64��ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\3\18-64��ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\3\С��18��ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\3\18-64��ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\3\18-64��ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\3\18-64�겻���¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\3\18-64�겻���¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\3\18-64�겻����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\3\18-64�겻����Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\3\18-64���˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\3\18-64�����ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\3\18-64��ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\3\18-64�����ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\3\18-64��SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

/*����64�����*/

%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO4);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\3\����64��ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\3\����64��ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\3\����64��ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\3\����64��ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\3\����64��ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\3\����64��ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\3\����64��ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\3\����64��ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\3\����64�겻���¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\3\����64�겻���¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\3\����64�겻����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\3\����64�겻����Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\3\����64���˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\3\����64�����ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\3\����64��ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\3\����64�����ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\3\����64��SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
/*�������ؽ����������*/
/*С��80kg����*/
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data Datalib1.DEMO1;
 set Datalib1.Demo(keep=primaryid SEX AGE REPORTER_COUNTRY WT);
 WTgroup=put(WT,WTfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop  WT;
Run;

data DEMO2;
set datalib1.DEMO1;
if WTgroup ='<80' then output;
RUN;
data DEMO3;
set datalib1.DEMO1;
if WTgroup ='80-100' then output;
RUN;
data DEMO4;
set datalib1.DEMO1;
if WTgroup ='>100' then output;
RUN;
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO2);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\4\С��80kg����ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\4\С��80kg�����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\4\С��80kg�����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\4\С��80kg����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\4\С��80kg������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\4\С��80kg�˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\4\С��80kg���ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\4\С��80kgÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\4\С��80kg���ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\4\С��80kgSOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
run;

/*80-100kg����*/

%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO3);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\4\80-100kg����ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\4\80-100kg�����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\4\80-100kg�����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\4\80-100kg����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\4\80-100kg������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\4\80-100kg�˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\4\80-100kg���ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\4\80-100kgÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\4\80-100kg���ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\4\80-100kgSOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
run;

/*����100kg����*/
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO4);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\4\����100kg����ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\4\����100kg����ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\4\����100kg����ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\4\����100kg����ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\4\����100kg����ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\4\����100kg����ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\4\����100kg����ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\4\����100kg����ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\4\����100kg�����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\4\����100kg�����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;


%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\4\����100kg����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\4\����100kg������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\4\����100kg�˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\4\����100kg���ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\4\����100kgÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\4\����100kg���ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\4\����100kgSOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
run;
/*������Ӧ�ϱ���Ա�������*/
/*רҵ��Ա����*/
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
Data Datalib1.DEMO1;
 set Datalib1.Demo(keep=SEX AGE REPORTER_COUNTRY primaryid OCCP_COD);
  years=input(AGE,9.);
 yearsgroup=put(years,AGEAGEfmt.);
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
if OCCP_COD in ('HP','LW','MD','OT','PH') then OCCP_COD1='HP';
if OCCP_COD in ('CN') then OCCP_COD1='CN';
if  OCCP_COD not in ('HP','LW','MD','OT','PH','CN') then OCCP_COD1='NA';
drop AGE years;
Run;

data DEMO2;
set datalib1.DEMO1;
if OCCP_COD1 ='HP' then output;
RUN;
data DEMO3;
set datalib1.DEMO1;
if OCCP_COD1 ='CN' then output;
RUN;
%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO2);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\5\רҵ��Ա��������ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\5\רҵ��Ա����ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\5\רҵ��Ա����ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\5\רҵ��Ա�����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\5\רҵ��Ա�����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\5\רҵ��Ա����Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\5\רҵ��Ա������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\5\רҵ��Ա�˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\5\רҵ��Ա���ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\5\רҵ��Աÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\5\רҵ��Ա���ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\5\רҵ��ԱSOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
run;
/*�����߷���*/

%macro selectdata2(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds.  where  strip(primaryid) in (select strip(primaryid) from DEMO3);
quit;

%mend;

%selectdata2(outds=DRUG,fromds=raw1.DRUG);
%selectdata2(outds=REAC,fromds=raw1.REAC);
%selectdata2(outds=DEMO,fromds=raw1.DEMO);
%selectdata2(outds=RPSR,fromds=raw1.RPSR);
%selectdata2(outds=THER,fromds=raw1.THER);
%selectdata2(outds=OUTC,fromds=raw1.OUTC);
%selectdata2(outds=INDI,fromds=raw1.INDI);

proc export data=DRUG
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����DRUG'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=REAC
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����REAC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=DEMO
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����DEMO'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=RPSR
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����RPSR'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=THER
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����THER'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=OUTC
outfile='D:\QIUWEN\5\�����߷�������ԭʼ����OUTC'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=INDI
outfile='D:\QIUWEN\5\�����߷���ԭʼ����INDI'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

proc sql UNDO_POLICY=NONE;
	create table DEMOREAC as
	select distinct a.*,b.*
	from REAC  as a
	left join DEMO as b
	on strip(a.primaryid) =strip(b.primaryid) 
    ;
quit;
proc export data=DEMOREAC
outfile='D:\QIUWEN\5\�����߷���ԭʼ����PTƥ�仼�߸�����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data TTO1; 
set drug(keep=primaryid DRUG_SEQ DRUGNAME prod_ai ROLE_COD);
if  ROLE_COD='PS' then output;
run;
proc sql;
  create table TT02 as 
	select distinct a.*,b.START_DT
	from TTO1  as a
	left join Ther as b
	on a.primaryid =b.primaryid and a.DRUG_SEQ =b.dsg_drug_seq;
quit;
data TT02;
set TT02;
keep primaryid START_DT;
run;
data TT03;
set TT02;
if missing(START_DT) then delete;
run;
proc sql;
  create table TT04 as 
	select distinct a.*,b.EVENT_DT
	from TT03  as a
	left join Demo as b
	on a.primaryid =b.primaryid;
quit;
data Tt04;
set Tt04;
if missing(EVENT_DT) then delete;
if missing(START_DT) then delete;
run;

data TTO5;
set Tt04;
EVENT_DT1=substr(EVENT_DT,1,4);
EVENT_DT2=substr(EVENT_DT,5,2);
EVENT_DT3=substr(EVENT_DT,7,2);
START_DT1=substr(START_DT,1,4);
START_DT2=substr(START_DT,5,2);
START_DT3=substr(START_DT,7,2);
EVENT_DT11=input(EVENT_DT1,BEST32.);
START_DT11=input(START_DT1,BEST32.);
if EVENT_DT11<1000 then delete;
if START_DT11<1000 then delete;
if missing(EVENT_DT1) then delete;
if missing(START_DT1) then delete;
if missing(EVENT_DT2) then delete;
if missing(EVENT_DT3) then delete;
if missing(START_DT2) then delete;
if missing(START_DT3) then delete;
run;
data TTO6;
SET TTO5;
EVENT_DTYYY=input(EVENT_DT,??yymmdd10.);
START_DTYYY=input(START_DT,??yymmdd10.);
IF START_DTYYY>EVENT_DTYYY then delete;
DAY=EVENT_DTYYY-START_DTYYY;
if DAY<=30 THEN DAYGROUP="<=30";
IF 31<=DAY<=60 THEN DAYGROUP="31-60";
IF 61<=DAY<=90 THEN DAYGROUP="61-90";
IF 91<=DAY<=180 THEN DAYGROUP="91-180";
IF 181<=DAY<=360 THEN DAYGROUP="181-360";
IF DAY>360 THEN DAYGROUP=">360";
YEARS=DAY/365;
MONTH=YEARS*12;
KEEP DAY DAYGROUP;
RUN;
DATA data TTO7;
SET TTO6(KEEP=DAYGROUP);
RUN;
proc export data=TTO7
outfile='D:\QIUWEN\\5\�����߲����¼��շ�ʱ�����'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
DATA data TTO8;
SET TTO6(KEEP=DAY);
RUN;
proc export data=TTO8
outfile='D:\QIUWEN\\5\�����߲����¼��շ�ʱ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.Reac));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(DATALIB1.Reac));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct soc_name_en,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from datalib1.Reac 
	group by soc_name_en
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct soc_name_en,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.Reac 
	group by soc_name_en
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.soc_name_en ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.soc_name_en =b.soc_name_en
	order by a desc
	;
quit;
data final;
set temp3;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;

proc export data=final1
outfile='D:\QIUWEN\5\�����߷���������Ӧȫ������(SOC��ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;

%let dsid=%sysfunc(open(RAW1.REAC));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put ���ݿ⣨REAC���ڹ۲��������е�ADE������**************************&nobs;
/*Ŀ��ҩ���Ӧ�ı�����*/
%let dsid=%sysfunc(open(rEAC));
%let nobs2=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%put Ŀ��ҩ���Ӧ�ı�������DATALIB1.REAC�ڹ۲�������a+b����**************************&nobs2;
proc sql UNDO_POLICY=NONE;
	create table temp1 as
	select distinct PT,count(*) as a label="Ŀ��ҩ��-Ŀ�걨�棨a��",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  REAC 
	group by PT
	order by a desc ;
quit;


/*�����ܿ���ÿһ��������Ӧ���������ɵõ� a+c*/
proc sql UNDO_POLICY=NONE;
	create table temp2 as
	select distinct PT,count(*) as ac label="�ϼ�-Ŀ�걨�棨a+c��",&nobs-count(*) as bd label="�ϼ�-�������棨bd��", &nobs as N label="�ϼƣ�a+b+c+d��"
	from  RAW1.REAC 
	group by PT
	order by ac desc ;
quit;
proc sql UNDO_POLICY=NONE;
	create table temp3 as
	select distinct a.PT ,a,b,ac-a as c label="����ҩ��-Ŀ�걨�棨c��",N-ac-b as d label="����ҩ��-�������棨d��",ac,bd,N
	from temp1   as a
	left join  temp2  as b
	on a.PT =b.PT
	order by a desc
	;
quit;

proc sql UNDO_POLICY=NONE;
	create table temp3_1 as
	select distinct a.*,b.pt_name_en,b.pt_name_cn,b.soc_name_en,b.soc_name_cn
	from temp3  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y')) as b on upcase(a.PT) =upcase(b.pt_name_en) ;
quit;
data temp3_1a(drop=soc_name_en pt_name_en) temp3_2;
	set temp3_1;
	if missing(soc_name_en) then output temp3_1a;
	else output temp3_2;
run;
data temp3_1a;;
set temp3_1a;;
drop soc_name;
run;

proc sql UNDO_POLICY=NONE;
	create table temp3_1a as
	select distinct a.*,b.soc_name,b.soc_name_en,b.pt_name_en
	from temp3_1a  as a
	left join MeD.aecode(where=(llt_currency='Y' and primary_soc_fg='Y'))    as b
	on upcase(a.PT) =upcase(b.llt_name_en) 
    ;
quit;

data temp4;
	set temp3_1a temp3_2 ;
run;

data final;
set temp4;
ROR=(a*d)/(b*c);
RORL=exp(log(ROR)-1.96*sqrt(1/a+1/b+1/c+1/d));
RORU=exp(log(ROR)+1.96*sqrt(1/a+1/b+1/c+1/d));
ROR_C=strip(vvalue(ROR))||strip("(")||strip(vvalue(RORL))||strip("-")||strip(vvalue(RORU))||strip(")");

PRR=(a/(a+b))/(c/(c+d));
XX=((a*d-b*c)*(a*d-b*c)*(a+b+c+d))/((a+b)*(c+d)*(a+c)*(b+d));



EBGM=(a*(A+B+C+d))/((A+B)*(A+C));
EBGM05=exp(log(EBGM)-1.64*(sqrt(1/a+1/b+1/c+1/d)));
EBGM_EBGM05=strip(vvalue(EBGM))||strip("(")||strip(vvalue(EBGM05))||strip(")");

IC2=LOG2((a*(a+b+c+d))/((a+c)*(a+b)));
GMAE=((a+b+c+d+2)*(a+b+c+d+2))/((a+b+1)*(a+c+1));
EIC=log2(((a+1)*(a+b+c+d+2)*(a+b+c+d+2))/((a+b+c+d+GMAE)*(a+b+1)*(a+c+1)));
VIC=(1/(log(2)))*(1/(log(2)))*((a+b+c+d-3+GMAE)/(3*(1+a+b+c+d+GMAE))+(a+b+c+d-a-b+1)/((a+b+1)*(1+a+b+C+D+2))+(a+b+c+d-a-c+1)/((a+c+1)*(a+b+c+d+3)));
SD=sqrt(VIC);BCPNN250=EIC-2*SD;
ICO25=IC2-2*SD;
IC2ICO25=strip(vvalue(IC2))||strip("(")||strip(vvalue(ICO25))||strip(")");
format ROR RORL RORU PRR XX EBGM EBGM05 IC2 ICO25 7.2;
label  ROR_C='ROR�㷨�ź�ֵRORֵ��95%Cl'  PRR="PRR�㷨�ź�PRRֵ" XX='����ֵ' EBGM_EBGM05="���鱴Ҷ˹MGPS����ƽ��ֵ�㷨�ź�ֵEBGM�Լ�EBGM05ֵ"
IC2ICO25='��Ҷ˹��BCPNN��ICֵ�Լ�IC025ֵ';
run;
proc sort data=final  out= final1  sortseq=linguistic(numeric_collation=on);by descending a RORL  ;quit;
proc export data=final1
outfile='D:\QIUWEN\5\�����߷���������Ӧȫ������(ROR��BCPNN�ź�ֵ��'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc format;
  value AGEAGEfmt low-<18='<18'
               18-<65='18-64'
			   65-high='>=65';
Run;
proc format;
  value WTfmt low-<80='<80'
               80-<100='80-100'
			   100-high='>100';
Run;
Data basicline1;
set Demo(keep=SEX AGE REPORTER_COUNTRY OCCP_COD WT);
WT1=input(WT,BEST32.);
AGE1=input(AGE,BEST32.);
WTgroup=put(WT1,WTfmt.);
yearsgroup=put(AGE1,AGEAGEfmt.);
if WTgroup not in ('<80','80-100','>100') then WTgroup="NA";
if yearsgroup not in ('<18','>=65','18-64') then yearsgroup="NA";
if SEX not in ('F','M') then SEX="NA";
drop AGE AGE1 WT WT1;
Run;
proc export data=basicline1
outfile='D:\QIUWEN\5\�����߷����˿�ѧ��Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
data outc;
set outc;
if OUTC_COD not in ('DE','DS','HO','OT','LT','RI') then OUTC_COD='NA';
drop GetDataYear GetDataQT primaryid;
run;
proc export data=outc
outfile='D:\QIUWEN\5\�����߷������ƽ����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
Data Adverse_years;
 set demo(keep=GetDataYear);
Run;
proc export data=Adverse_years
outfile='D:\QIUWEN\5\�����߷���ÿ���ϱ�������Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc export data=T_drug
outfile='D:\QIUWEN\5\�����߷������ݿ�����Ŀ��ҩ��ΪPS����Ϣ'
dbms=xlsx replace label;
SHEET="SHEET1";
RUN;
proc sql UNDO_POLICY=NONE;
	create table PPPP as
	select distinct soc_name,count(*) as a label="�����ٸ�PT��Ŀ",&nobs2-count(*) as b label="Ŀ��ҩ��-�������棨b��", &nobs2 as ab label="Ŀ��ҩ�a+b��"
	from  Final1 
	group by soc_name_en
	order by a desc ;
quit;
data PPPP;
set PPPP;
keep soc_name a;
run;
proc export data=PPPP
outfile='D:\QIUWEN\5\�����߷���SOC�漰��PTͳ��'
dbms=xlsx replace label;
SHEET="SHEET1";
run;
