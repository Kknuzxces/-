libname alldata "E:\ȥ������\2004-2022ȫ��ԭʼ����";
libname raw1 "E:\ȥ������\2004-2022ȥ������";
 
data DEMO;
	set alldata.DEMO;
	
    fda_dtn=input(fda_dt,??yymmdd10.);
run;
proc sort data=demo  out= demo sortseq=linguistic(numeric_collation=on);by caseid fda_dtn  primaryid ;quit;
data demo;
	set demo;
	by  caseid fda_dtn  primaryid;
	if last.caseid then output;
	drop fda_dtn;
run;
data demo;
	set demo;
	where ^missing(caseid);
run;
/*�޳� primaryid ISR ��ͬ����caseid ��ͬ����Ⱥ��¼�����Ʃ�� ISR=4380035��*/
proc sort data=Demo(keep= primaryid GetDataYear GetDataQT)  out=temp1  dupout=a1_3 nodupkey;
    by  primaryid;
run;
data raw1.primaryid;
	set temp1;
    by  primaryid;
	if last.primaryid then output;
run;

%macro selectdata1(outds=,fromds=);
proc sql UNDO_POLICY=NONE;
	create table &outds. as
	select distinct *
	from  &fromds. where  strip(primaryid)||"-"||strip(put(GetDataYear,z2.))||"-"||strip(put(GetDataQT,z2.)) in (select strip(primaryid)||"-"||strip(put(GetDataYear,z2.))||"-"||strip(put(GetDataQT,z2.)) from  raw1.primaryid)  ;
quit;
%mend;

%selectdata1(outds=raw1.DRUG,fromds=alldata.DRUG);
%selectdata1(outds=raw1.REAC,fromds=alldata.REAC);
%selectdata1(outds=raw1.DEMO,fromds=alldata.DEMO);
%selectdata1(outds=raw1.RPSR,fromds=alldata.RPSR);
%selectdata1(outds=raw1.THER,fromds=alldata.THER);
%selectdata1(outds=raw1.OUTC,fromds=alldata.OUTC);
%selectdata1(outds=raw1.INDI,fromds=alldata.INDI);

