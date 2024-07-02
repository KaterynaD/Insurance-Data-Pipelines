CREATE OR REPLACE PROCEDURE kdlab.sp_load_defaults(schema_name varchar, table_name varchar)
LANGUAGE plpgsql
AS $$
DECLARE
tables RECORD;
columns RECORD;
insert_statement varchar(10000);
tables_query text;
columns_query varchar(1000);
allowed_schemas varchar(1000);
begin
--
allowed_schemas :='kdlab';
--
IF allowed_schemas not like '%' + schema_name + '%' then
raise exception 'You can not modify data in % schema!', schema_name;
END IF;

--
insert_statement :='insert into '+schema_name+'.'+table_name+ ' values (';
--column values according to the type
columns_query :=
'select column_name, udt_name from information_schema.columns where table_schema='''+schema_name+''' and table_name ='''+table_name+''' ORDER BY ordinal_position';
FOR columns IN EXECUTE columns_query loop
case
when columns.column_name like '%_uniqueid' and columns.udt_name='varchar' then
insert_statement =insert_statement+'''Unknown''';
when columns.column_name like '%_id' and columns.udt_name like '%int%' then
insert_statement =insert_statement+'0' ;
when columns.udt_name='varchar' then
insert_statement =insert_statement+'''~''' ;
when columns.udt_name in ('date','timestamp','datetime') then
insert_statement =insert_statement+'''1900-01-01''' ;
else
insert_statement =insert_statement+'0' ;
end case;
insert_statement =insert_statement+', ' ;
END LOOP;
--
insert_statement = rtrim(rtrim(insert_statement,' '),',');
--
insert_statement =insert_statement+') ';
--
raise info 'Statement to run %',insert_statement;

execute insert_statement;

END;

$$
;



CREATE OR REPLACE PROCEDURE kdlab.sp_fact_policytransaction()
LANGUAGE plpgsql
AS $$
DECLARE
begin

/*systemid should be unique per loads. E.g. there are the same systemid in the daily load portion but not possible to have the same systemid today and yesterday*/
delete from kdlab.fact_policytransaction
where systemid in (select systemid from kdlab.stg_policytransaction stg);


insert into kdlab.fact_policytransaction
select
stg.loaddate,
stg.policy_uniqueid policy_id,
stg.systemid,
cast(to_char(stg.bookdt, 'yyyymmdd') as int) transactiondate_id,
cast(to_char(stg.transactioneffectivedt, 'yyyymmdd') as int) effectivedate_id,
cast(to_char(stg.accountingdt, 'yyyymmdd') as int) accountingdate_id,
stg.policytransaction_uniqueid,
stg.transactionnumber transactionsequence,
stg.TransactionCd,
isnull(pt.policytransactiontype_id,0) policytransactiontype_id,
isnull(co.company_id, 0) company_id,
isnull(p.product_id,0) product_id,
stg.systemid firstinsured_id,
isnull(c.coverage_id,0) coverage_id,
isnull(l.limit_id,0) limit_id,
isnull(d.deductible_id,0) deductible_id,
isnull(r.coveredrisk_id, 0) primaryrisk_id,
isnull(b.building_id, 0) building_id,
isnull(v.vehicle_id, 0) vehicle_id,
isnull(dr.driver_id, 0) driver_id,
isnull(adr.address_id,0) primaryriskaddress_id,
isnull(cs.class_id, 0) class_id,
isnull(a.producer_id, 0) producer_id,
case when pol.term in ('1','01') then 'New' else 'Renewal' end policyneworrenewal,
isnull(pte.policytransactionextension_id, 0) policytransactionextension_id,
stg.writtenpremiumamt amount,
stg.inforcechangeamt term_amount,
stg.writtencommissionamt commission_amount,
stg.policy_uniqueid,
stg.coverage_uniqueid
from kdlab.stg_policytransaction stg
left outer join kdlab.dim_policytransactionextension pte
on pte.policytransaction_uniqueid=stg.policytransaction_uniqueid
left outer join kdlab.dim_company co
on co.company_uniqueid=stg.company_uniqueid
left outer join kdlab.dim_policy pol
on pol.policy_uniqueid=stg.policy_uniqueid
left outer join kdlab.dim_product p
on p.product_uniqueid=stg.product_uniqueid
left outer join kdlab.dim_policytransactiontype pt
on pt.ptrans_4sightbicode=stg.pt_typecode
left outer join kdlab.dim_coverage c
on c.cov_code=stg.cov_code
and c.cov_subcode=stg.cov_subcode
and c.cov_asl=stg.cov_asl
and c.cov_subline=stg.cov_subline
left outer join kdlab.dim_limit l
on l.cov_limit1=stg.cov_limit1
and l.cov_limit2=stg.cov_limit2
left outer join kdlab.dim_deductible d
on d.cov_deductible1=stg.cov_deductible1
and d.cov_deductible2=stg.cov_deductible2
left outer join kdlab.dim_coveredrisk r
on r.risk_uniqueid=stg.primaryrisk_uniqueid
and r.SystemId=stg.SystemId
left outer join kdlab.dim_vehicle v
on v.vehicle_id=r.coveredrisk_id
and v.SystemId=r.SystemId
left outer join kdlab.dim_building b
on b.building_id=r.coveredrisk_id
and b.SystemId=r.SystemId
left outer join kdlab.dim_driver dr
on dr.spinndriver_id=stg.secondaryrisk_uniqueid
and dr.SystemId=stg.SystemId
left outer join kdlab.dim_classification cs
on cs.class_code=stg.cov_classCode
left outer join kdlab.dim_address adr
on adr.address1 = isnull(v.addr1,b.addr1)
and adr.address2 = isnull(v.addr2,b.addr2)
and adr.county = isnull(v.county,b.county)
and adr.city = isnull(v.city,b.city)
and adr.state = isnull(v.stateprovcd,b.stateprovcd)
and adr.postalcode = isnull(v.postalcode,b.postalcode)
left outer join kdlab.dim_producer a
on a.producer_uniqueid=stg.producer_uniqueid
and a.iscurrent=1;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_fact_policycoverage()
LANGUAGE plpgsql
AS $$
BEGIN
/*======================================================== MONEY =====================================================================*/
delete from kdlab.fact_policycoverage
where month_id in (select distinct month_id from kdlab.stg_policycoverage);

insert into kdlab.fact_policycoverage
select
--stg.loaddate,
GetDate() loaddate,
stg.month_id
,stg.policy_uniqueid policy_id
,stg.systemid
,fpt.producer_id
,fpt.product_id
,fpt.company_id
,fpt.firstinsured_id
,stg.policystatus_id
,fpt.coverage_id
,fpt.limit_id
,fpt.deductible_id
,fpt.class_id
,fpt.primaryrisk_id
,fpt.building_id
,fpt.vehicle_id
,fpt.driver_id
,fpt.primaryriskaddress_id
,fpt.policyneworrenewal
,stg.policynewissuedind
,stg.policycancelledissuedind
,stg.policycancelledeffectiveind
,stg.policyexpiredeffectiveind
,cr.deleted_indicator risk_deletedindicator
,stg.policy_uniqueid
,stg.coverage_uniqueid
,stg.comm_amt
,0 comm_amt_ytd
,0 comm_amt_itd
,stg.wrtn_prem_amt
,0 wrtn_prem_amt_ytd
,stg.wrtn_prem_amt_itd
,stg.term_prem_amt
,0 term_prem_amt_ytd
,0 term_prem_amt_itd
,stg.earned_prem_amt
,0 earned_prem_amt_ytd
,0 earned_prem_amt_itd
,stg.spinn_earned_prem_amt
,0 spinn_earned_prem_amt_ytd
,stg.spinn_earned_prem_amt_itd
,stg.unearned_prem
,stg.spinn_unearned_prem
,stg.comm_earned_amt
,0 comm_earned_amt_ytd
,0 comm_earned_amt_itd
,stg.cncl_prem_amt
,0 cncl_prem_amt_ytd
,0 cncl_prem_amt_itd
,stg.fees_amt
,0 fees_amt_ytd
,0 fees_amt_itd
,0 wrtn_exposures
,0 wrtn_exposures_ytd
,0 wrtn_exposures_itd
,0 earned_exposures
,0 earned_exposures_ytd
,0 earned_exposures_itd
from kdlab.stg_policycoverage stg
join kdlab.fact_policytransaction fpt
on stg.coverage_uniqueid=fpt.coverage_uniqueid
and stg.SystemId=fpt.SystemId
join kdlab.dim_coveredrisk cr
on fpt.primaryrisk_id=cr.coveredrisk_id;


/*============================================================= YTD and ITD =============================================================*/

drop table if exists tmp_summaries;
create temporary table tmp_summaries as
with data as (
select
f.month_id,
f.policy_uniqueid,
f.coverage_uniqueid,
sum(f.comm_amt) comm_amt,
sum(f.wrtn_prem_amt) wrtn_prem_amt,
sum(f.term_prem_amt) term_prem_amt,
sum(f.earned_prem_amt) earned_prem_amt,
sum(f.spinn_earned_prem_amt) spinn_earned_prem_amt,
sum(f.comm_earned_amt) comm_earned_amt,
sum(f.cncl_prem_amt) cncl_prem_amt,
sum(f.fees_amt) fees_amt
from kdlab.fact_policycoverage f
/*If I join in from I need to use coverage_uniqueid, and I do not want 
* not sure why (?)
* what if a coverage disapper?*/
where f.policy_uniqueid in (select stg.policy_uniqueid from kdlab.stg_policycoverage stg)
group by
f.month_id,
f.policy_uniqueid,
f.coverage_uniqueid
)
select
f.month_id,
f.policy_uniqueid,
f.coverage_uniqueid,
sum(f.comm_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) comm_amt_ytd,
sum(f.wrtn_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) wrtn_prem_amt_ytd,
sum(f.term_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) term_prem_amt_ytd,
sum(f.earned_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) earned_prem_amt_ytd,
sum(f.spinn_earned_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) spinn_earned_prem_amt_ytd,
sum(f.comm_earned_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) comm_earned_amt_ytd,
sum(f.cncl_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) cncl_prem_amt_ytd,
sum(f.fees_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid, substring(f.month_id,1,4) order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) fees_amt_ytd,
--
sum(f.comm_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) comm_amt_itd,
sum(f.wrtn_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) wrtn_prem_amt_itd,
sum(f.term_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) term_prem_amt_itd,
sum(f.earned_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) earned_prem_amt_itd,
sum(f.spinn_earned_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) spinn_earned_prem_amt_itd,
sum(f.comm_earned_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) comm_earned_amt_itd,
sum(f.cncl_prem_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) cncl_prem_amt_itd,
sum(f.fees_amt) over (partition by f.policy_uniqueid, f.coverage_uniqueid order by f.policy_uniqueid, f.coverage_uniqueid, f.month_id rows unbounded preceding) fees_amt_itd
from data f;


update kdlab.fact_policycoverage
set
comm_amt_ytd = t.comm_amt_ytd,
comm_amt_itd = t.comm_amt_itd,
wrtn_prem_amt_ytd = t.wrtn_prem_amt_ytd,
wrtn_prem_amt_itd = t.wrtn_prem_amt_itd,
term_prem_amt_ytd = t.term_prem_amt_ytd,
term_prem_amt_itd = t.term_prem_amt_itd,
earned_prem_amt_ytd = t.earned_prem_amt_ytd,
earned_prem_amt_itd = t.earned_prem_amt_itd,
spinn_earned_prem_amt_ytd = t.spinn_earned_prem_amt_ytd,
spinn_earned_prem_amt_itd = t.spinn_earned_prem_amt_itd,
comm_earned_amt_ytd = t.comm_earned_amt_ytd,
comm_earned_amt_itd = t.comm_earned_amt_itd,
cncl_prem_amt_ytd = t.cncl_prem_amt_ytd,
cncl_prem_amt_itd = t.cncl_prem_amt_itd,
fees_amt_ytd = t.fees_amt_ytd,
fees_amt_itd = t.fees_amt_itd
from kdlab.fact_policycoverage f
join tmp_summaries t
on f.month_id=t.month_id
and f.policy_uniqueid=t.policy_uniqueid
and f.coverage_uniqueid=t.coverage_uniqueid;

/*====================================================== EXPOSURES ===================================================================*/
/*Incremental Load - update exposures only in a current month(s)*/
/*WE and EE - exposures in integer is calculated but not used in the final table update*/
/*2. calculate exposures for all policy terms from incremental (month) part in all months*/
/*==========================================Part 1 month/1 exposure ===================================================================*/
/*2.1 One (1) month/1 exposure first*/
/*2.1.1 Written exposure*/
drop table if exists WE_data1;
create temporary table WE_data1 as
select
t.month_id,
f.policy_id,
f.policy_uniqueid,
f.coverage_id,
f.coverage_uniqueid,
case
when f.term_amount<0 then -datediff(month, cast(cast(effectivedate_id as varchar) as date), p.expirationdate)
when f.term_amount=0 then 0
else datediff(month, cast(cast(effectivedate_id as varchar) as date), p.expirationdate)
end WE
from kdlab.fact_policytransaction f
join kdlab.dim_coverage c
on f.coverage_id=c.coverage_id
join kdlab.dim_policy p
on f.policy_id=p.policy_id
join kdlab.dim_policytransactiontype dptt
on f.POLICYTRANSACTIONTYPE_ID = dptt.POLICYTRANSACTIONTYPE_ID
and dptt.ptrans_writtenprem = '+'
join kdlab.dim_time t
on f.accountingdate_id=t.time_id
where lower(c.cov_code) not like '%fee%'
/*only policy terms from the incremental part*/
and f.policy_uniqueid in (select stg.policy_uniqueid from kdlab.stg_policycoverage stg);
/*2.1.2 Written exposure aggregated. Maybe not needed step*/
drop table if exists WE1;
create temporary table WE1 as
select
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
sum(WE) WE
from we_data1
group by
month_id,
coverage_id,
coverage_uniqueid,
policy_id,
policy_uniqueid ;
/*2.1.3 For earned exposures and joining to fact_policycoverage we need months*/
drop table if exists mtd_data1;
create temporary table mtd_data1 as
Select
month_id,
row_number() over (partition by f.policy_id,f.coverage_id,f.coverage_uniqueid order by f.month_id) as month_num,
f.policy_id,
f.policy_uniqueid,
f.coverage_uniqueid,
f.coverage_id,
wrtn_prem_amt WP,
earned_prem_amt EP ,
effectivedate,
expirationdate
from kdlab.fact_policycoverage f
join kdlab.dim_coverage c
on f.coverage_id=c.coverage_id
join kdlab.dim_policy p
on f.policy_id=p.policy_id
where lower(c.cov_code) not like '%fee%';
/*2.1.4 unearned exposure, adjusting data with Diff for backdated transactions */
drop table if exists mtd1;
create temporary table mtd1 as
select
month_num,
e.month_id,
e.policy_id,
e.policy_uniqueid,
e.coverage_id,
e.coverage_uniqueid,
WP,
EP,
isnull(WE.WE,0) WE,
case when e.month_id=we.month_id then WE else 0 end WE_adj,
case
when cast(cast(e.month_id as varchar)+'01' as date)>e.expirationdate then 0 --accounting date AFTER expiration 
when month_num=1 and e.month_id > cast(to_char(e.effectivedate, 'YYYYMM') as int) then
isnull(datediff(month,e.effectivedate,dateadd(day,-1,dateadd(month,1,cast(cast(e.month_id as varchar)+'01' as date)))) - 1,0)
else 0
end Diff,
sum(isnull(Diff,0)) over (partition by e.policy_id,e.coverage_id,e.coverage_uniqueid order by e.month_id rows unbounded preceding) Diff_ITD,
sum(isnull(WE.WE,0)) over (partition by e.policy_id,e.coverage_id,e.coverage_uniqueid order by e.month_id rows unbounded preceding) WE_ITD,
case
when cast(cast(e.month_id as varchar)+'01' as date)>e.expirationdate then 0
when WE_ITD - month_num - Diff_ITD <0 then 0
else WE_ITD - month_num - Diff_ITD
end UE_ITD
from mtd_data1 e
left outer join WE1 WE
on e.month_id=WE.month_id
and e.policy_id=WE.policy_id
and e.coverage_id=WE.coverage_id
and e.coverage_uniqueid=WE.coverage_uniqueid;
/*2.1.5 earned exposure*/
drop table if exists mtd_term1;
create temporary table mtd_term1 as
select
month_num,
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
WP,
EP,
WE,
WE_adj,
WE_ITD,
UE_ITD,
isnull(lag(UE_ITD) over (partition by policy_id,coverage_id,coverage_uniqueid order by month_id),0) - UE_ITD + WE_adj EE
from mtd1;
/*==========================================Part 2 1 month/partial exposure based on dates ===================================================================*/
/*2.2 One(1) month/partial exposure based on dates*/
/*2.2.1 Written exposure*/
drop table if exists WE2;
create temporary table WE2 as
select
t.month_id,
f.policy_id,
f.policy_uniqueid,
f.coverage_id,
f.coverage_uniqueid,
sum(case
when f.term_amount<0 then -datediff(day, cast(cast(effectivedate_id as varchar) as date), p.expirationdate)
when f.term_amount=0 then 0
else datediff(day, cast(cast(effectivedate_id as varchar) as date), p.expirationdate)
end/case when p.TermDays = 366 then 30.5 else 30.417 end) WE,
p.expirationdate expirationdate,
cast(cast(effectivedate_id as varchar) as date) effectivedate
from kdlab.fact_policytransaction f
join kdlab.dim_coverage c
on f.coverage_id=c.coverage_id
join kdlab.dim_policy p
on f.policy_id=p.policy_id
join kdlab.dim_policytransactiontype dptt
on f.POLICYTRANSACTIONTYPE_ID = dptt.POLICYTRANSACTIONTYPE_ID
and dptt.ptrans_writtenprem = '+'
join kdlab.dim_time t
on f.accountingdate_id=t.time_id
where lower(c.cov_code) not like '%fee%'
group by
t.month_id,
f.policy_id,
f.policy_uniqueid,
f.coverage_id,
f.coverage_uniqueid,
p.expirationdate,
cast(cast(effectivedate_id as varchar) as date);
/*2.2.2 For earned exposures and joining to fact_policycoverage we need months*/
drop table if exists mtd_data2;
create temporary table mtd_data2 as
Select
f.month_id,
m.mon_enddate,
f.policy_id,
f.policy_uniqueid,
f.coverage_uniqueid,
f.coverage_id,
wrtn_prem_amt WP,
earned_prem_amt EP
from kdlab.fact_policycoverage f
join kdlab.dim_coverage c
on f.coverage_id=c.coverage_id
join kdlab.dim_month m
on f.month_id=m.month_id
where lower(c.cov_code) not like '%fee%';
/*2.2.3 UnearnedFactor based on days */
drop table if exists mtd2;
create temporary table mtd2 as
select
e.month_id,
e.policy_id,
e.policy_uniqueid,
e.coverage_id,
e.coverage_uniqueid,
WP,
EP,
WE,
case when e.month_id=we.month_id then WE else 0 end WE_adj,
mon_enddate,
WE.expirationdate,
WE.effectivedate,
case
when WE.expirationdate <= mon_enddate then 0
when effectivedate> mon_enddate then 1
else round((cast(datediff(day, mon_enddate, expirationdate) as float) - 1.000)/cast(datediff(day, effectivedate, expirationdate) as float),5)
end UnearnedFactor
from mtd_data2 e
join WE2 WE
on e.policy_id=WE.policy_id
and e.coverage_id=WE.coverage_id
and e.coverage_uniqueid=WE.coverage_uniqueid
and WE.month_id<=e.month_id;
/*2.2.4 Unearned Exposure */
drop table if exists mtd_term2_1;
create temporary table mtd_term2_1 as
select
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
UnearnedFactor,
sum(WE) WE,
sum(WE_adj) WE_adj,
sum(WE)*UnearnedFactor UE
from mtd2
group by
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
UnearnedFactor;
/*2.2.5 Aggregating Unearned Exposure */
drop table if exists mtd_term2_2;
create temporary table mtd_term2_2 as
select
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
sum(WE_adj) WE,
sum(UE) UE
from mtd_term2_1
group by
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid
order by month_id;
/*2.2.6 Earned Exposure */
drop table if exists mtd_term2;
create temporary table mtd_term2 as
select
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
WE,
UE ,
lag(UE) over (partition by policy_id,coverage_id,coverage_uniqueid order by policy_id,coverage_id,coverage_uniqueid,month_id) UE_PRIOR,
isnull(UE_PRIOR,0) - UE + WE EE
from mtd_term2_2
order by month_id;
/*============================================================= FINAL =============================================================*/
truncate table kdlab.stg_exposures;
insert into kdlab.stg_exposures
select
mtd_term1.month_id,
mtd_term1.policy_uniqueid,
mtd_term1.coverage_uniqueid,
isnull(mtd_term2.WE,0) WE_RM,
isnull(mtd_term2.EE,0) EE_RM,
null WE_RM_YTD,
null EE_RM_YTD,
null WE_RM_ITD,
null EE_RM_ITD
from mtd_term1
left outer join mtd_term2 on
mtd_term1.month_id=mtd_term2.month_id
and mtd_term1.policy_uniqueid=mtd_term2.policy_uniqueid
and mtd_term1.coverage_uniqueid=mtd_term2.coverage_uniqueid;
/*============================================================= YTD and ITD =============================================================*/
drop table if exists tmp_exposures;
create temporary table tmp_exposures as
select
month_id,
policy_uniqueid,
coverage_uniqueid,
WE_RM,
EE_RM,
sum(WE_RM) over (partition by policy_uniqueid,coverage_uniqueid, substring(month_id,1,4) order by policy_uniqueid,coverage_uniqueid, month_id rows unbounded preceding) WE_RM_YTD,
sum(EE_RM) over (partition by policy_uniqueid,coverage_uniqueid, substring(month_id,1,4) order by policy_uniqueid,coverage_uniqueid, month_id rows unbounded preceding) EE_RM_YTD,
sum(WE_RM) over (partition by policy_uniqueid,coverage_uniqueid order by policy_uniqueid,coverage_uniqueid, month_id rows unbounded preceding) WE_RM_ITD,
sum(EE_RM) over (partition by policy_uniqueid,coverage_uniqueid order by policy_uniqueid,coverage_uniqueid, month_id rows unbounded preceding) EE_RM_ITD
from kdlab.stg_exposures;
update kdlab.stg_exposures
set
WE_RM_YTD=t.WE_RM_YTD
,EE_RM_YTD=t.EE_RM_YTD
,WE_RM_ITD=t.WE_RM_ITD
,EE_RM_ITD=t.EE_RM_ITD
from tmp_exposures t
join kdlab.stg_exposures e
on t.month_id=e.month_id
and t.policy_uniqueid=e.policy_uniqueid
and t.coverage_uniqueid=e.coverage_uniqueid;
/*=============================================================FACT_POLICYCOVERAGE Update =============================================================*/
update kdlab.fact_policycoverage
set
wrtn_exposures = e.we_rm,
wrtn_exposures_ytd = e.we_rm_ytd,
wrtn_exposures_itd = e.we_rm_itd,
earned_exposures = e.ee_rm,
earned_exposures_ytd = e.ee_rm_ytd,
earned_exposures_itd = e.ee_rm_itd
from kdlab.fact_policycoverage f
join kdlab.stg_exposures e
on f.month_id=e.month_id
and f.policy_uniqueid=e.policy_uniqueid
and f.coverage_uniqueid=e.coverage_uniqueid;


END;
$$
;







