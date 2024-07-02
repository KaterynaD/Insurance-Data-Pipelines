CREATE OR REPLACE PROCEDURE DW_MGA.sp_load_complete()					
LANGUAGE plpgsql					
AS $$					
BEGIN					
/*Most recent SystemId of a mid term change per policy term PolicyId*/					
drop table if exists tmp_PolicyBase;					
create temporary table tmp_PolicyBase as					
select					
Policy_Id					
,max(SystemId) SystemId					
from DW_MGA.DIM_APPLICATION					
where policy_id<>0					
group by Policy_Id;					
/*Re-set Current Flg*/					
/*1. DIM_APPLICATION*/					
update DW_MGA.DIM_APPLICATION					
set CurrentFlg=0;					
update DW_MGA.DIM_APPLICATION					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_APPLICATION.policy_id					
and pb.SystemId=DW_MGA.DIM_APPLICATION.SystemId;					
/*Populating DIM_POLICY with the most recent data*/					
truncate table DW_MGA.DIM_POLICY;					
insert into DW_MGA.DIM_POLICY					
select					
SOURCE_SYSTEM					
,LOADDATE					
,POLICY_ID					
,SystemId					
,CurrentFlg					
,BookDt					
,TransactionEffectiveDt					
,POLICY_UNIQUEID					
,TransactionCd					
,POLICYNUMBER					
,TERM					
,EFFECTIVEDATE					
,EXPIRATIONDATE					
,CarrierCd					
,CompanyCd					
,TermDays					
,CarrierGroupCd					
,StateCD					
,BusinessSourceCd					
,PreviouscarrierCd					
,PolicyFormCode					
,SubTypeCd					
,payPlanCd					
,InceptionDt					
,PriorPolicyNumber					
,PreviousPolicyNumber					
,AffinityGroupCd					
,ProgramInd					
,RelatedPolicyNumber					
,TwoPayDiscountInd					
,QuoteNumber					
,RenewalTermCd					
,RewritePolicyRef					
,RewriteFromPolicyRef					
,CancelDt					
,ReinstateDt					
,PersistencyDiscountDt					
,PaperLessDelivery					
,MultiCarDiscountInd					
,LateFee					
,NSFFee					
,InstallmentFee					
,batchquotesourcecd					
,WaivePolicyFeeInd					
,LiabilityLimitCPL					
,LiabilityReductionInd					
,LiabilityLimitOLT					
,PersonalLiabilityLimit					
,GLOccurrenceLimit					
,GLAggregateLimit					
,Policy_SPINN_Status					
,BILimit					
,PDLimit					
,UMBILimit					
,MedPayLimit					
,MultiPolicyDiscount					
,MultiPolicyAutoDiscount					
,MultiPolicyAutoNumber					
,MultiPolicyHomeDiscount					
,HomeRelatedPolicyNumber					
,MultiPolicyUmbrellaDiscount					
,UmbrellaRelatedPolicyNumber					
,CSEEmployeeDiscountInd					
,FullPayDiscountInd					
,PrimaryPolicyNumber					
,LandLordInd					
,PersonalInjuryInd					
,VehicleListConfirmedInd					
,AltSubTypeCd					
,FirstPayment					
,LastPayment					
,BalanceAmt					
,PaidAmt					
,PRODUCT_UNIQUEID					
,COMPANY_UNIQUEID					
,PRODUCER_UNIQUEID					
,FIRSTINSURED_UNIQUEID					
,AccountRef					
,CUSTOMER_UNIQUEID					
,MGAFeePlanCd					
,MGAFeePct					
,TPAFeePlanCd					
,TPAFeePct					
from DW_MGA.DIM_APPLICATION					
where CurrentFlg=1;					
/*2. DIM_INSURED*/					
update DW_MGA.DIM_INSURED					
set CurrentFlg=0;					
update DW_MGA.DIM_INSURED					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_INSURED.policy_id					
and pb.SystemId=DW_MGA.DIM_INSURED.SystemId;					
/*3. DIM_COVEREDRISK*/					
update DW_MGA.DIM_COVEREDRISK					
set CurrentFlg=0;					
update DW_MGA.DIM_COVEREDRISK					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_COVEREDRISK.policy_id					
and pb.SystemId=DW_MGA.DIM_COVEREDRISK.SystemId;					
/*4. DIM_BUILDING*/					
update DW_MGA.DIM_BUILDING					
set CurrentFlg=0;					
update DW_MGA.DIM_BUILDING					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_BUILDING.policy_id					
and pb.SystemId=DW_MGA.DIM_BUILDING.SystemId;					
/*5. DIM_POLICYTRANSACTIONEXTENSION*/					
update DW_MGA.DIM_POLICYTRANSACTIONEXTENSION					
set CurrentFlg=0;					
update DW_MGA.DIM_POLICYTRANSACTIONEXTENSION					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_POLICYTRANSACTIONEXTENSION.policy_id					
and pb.SystemId=DW_MGA.DIM_POLICYTRANSACTIONEXTENSION.SystemId;					
/*6. DIM_RISK_COVERAGE*/					
update DW_MGA.DIM_RISK_COVERAGE					
set CurrentFlg=0;					
update DW_MGA.DIM_RISK_COVERAGE					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_RISK_COVERAGE.policy_id					
and pb.SystemId=DW_MGA.DIM_RISK_COVERAGE.SystemId;					
/*7. DIM_VEHICLE*/					
update DW_MGA.DIM_VEHICLE					
set CurrentFlg=0;					
update DW_MGA.DIM_VEHICLE					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_VEHICLE.policy_id					
and pb.SystemId=DW_MGA.DIM_VEHICLE.SystemId;					
/*8. DIM_DRIVER*/					
update DW_MGA.DIM_DRIVER					
set CurrentFlg=0;					
update DW_MGA.DIM_DRIVER					
set CurrentFlg=1					
from tmp_PolicyBase pb					
where pb.policy_id=DW_MGA.DIM_DRIVER.policy_id					
and pb.SystemId=DW_MGA.DIM_DRIVER.SystemId;					
/*Clean up*/					
drop table if exists tmp_PolicyBase;					
END;					
$$					
;					
					
					
CREATE OR REPLACE PROCEDURE dw_mga.sp_exposures_mga()
LANGUAGE plpgsql
AS $$
BEGIN

/*Incremental Load - update exposures only in a current month(s)*/

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
from dw_mga.fact_policytransaction f
join dw_mga.dim_coverage c
on f.coverage_id=c.coverage_id
join dw_mga.dim_policy p
on f.policy_id=p.policy_id
join dw_mga.dim_policytransactiontype dptt
on f.POLICYTRANSACTIONTYPE_ID = dptt.POLICYTRANSACTIONTYPE_ID
and dptt.ptrans_writtenprem = '+'
join dw_mga.dim_time t
on f.accountingdate_id=t.time_id
where lower(c.cov_code) not like '%fee%';
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
factpolicycoverage_id,
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
from dw_mga.fact_policycoverage f
join dw_mga.dim_coverage c
on f.coverage_id=c.coverage_id
join dw_mga.dim_policy p
on f.policy_id=p.policy_id
where lower(c.cov_code) not like '%fee%';
/*2.1.4 unearned exposure, adjusting data with Diff for backdated transactions */
drop table if exists mtd1;
create temporary table mtd1 as
select
factpolicycoverage_id,
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
factpolicycoverage_id,
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
from dw_mga.fact_policytransaction f
join dw_mga.dim_coverage c
on f.coverage_id=c.coverage_id
join dw_mga.dim_policy p
on f.policy_id=p.policy_id
join dw_mga.dim_policytransactiontype dptt
on f.POLICYTRANSACTIONTYPE_ID = dptt.POLICYTRANSACTIONTYPE_ID
and dptt.ptrans_writtenprem = '+'
join dw_mga.dim_time t
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
f.factpolicycoverage_id,
f.month_id,
m.mon_enddate,
f.policy_id,
f.policy_uniqueid,
f.coverage_uniqueid,
f.coverage_id,
wrtn_prem_amt WP,
earned_prem_amt EP
from dw_mga.fact_policycoverage f
join dw_mga.dim_coverage c
on f.coverage_id=c.coverage_id
join dw_mga.dim_month m
on f.month_id=m.month_id
where lower(c.cov_code) not like '%fee%';
/*2.2.3 UnearnedFactor based on days */
drop table if exists mtd2;
create temporary table mtd2 as
select
factpolicycoverage_id,
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
factpolicycoverage_id,
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
factpolicycoverage_id,
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
factpolicycoverage_id,
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
sum(WE_adj) WE,
sum(UE) UE
from mtd_term2_1
group by factpolicycoverage_id,
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
factpolicycoverage_id,
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
truncate table dw_mga.stg_exposures;
insert into dw_mga.stg_exposures
select
mtd_term1.factpolicycoverage_id,
mtd_term1.month_id,
mtd_term1.policy_id,
mtd_term1.policy_uniqueid,
mtd_term1.coverage_id,
mtd_term1.coverage_uniqueid,
mtd_term1.WE WE,
mtd_term1.EE EE,
null WE_YTD,
null EE_YTD,
null WE_ITD,
null EE_ITD,
isnull(mtd_term2.WE,0) WE_RM,
isnull(mtd_term2.EE,0) EE_RM,
null WE_RM_YTD,
null EE_RM_YTD,
null WE_RM_ITD,
null EE_RM_ITD
from mtd_term1
left outer join mtd_term2 on
mtd_term1.factpolicycoverage_id=mtd_term2.factpolicycoverage_id ;
/*============================================================= YTD and ITD =============================================================*/
drop table if exists tmp_exposures;
create temporary table tmp_exposures as
select
factpolicycoverage_id,
month_id,
policy_id,
policy_uniqueid,
coverage_id,
coverage_uniqueid,
WE,
EE,
sum(WE) over (partition by policy_id,coverage_id,coverage_uniqueid, substring(month_id,1,4) order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) WE_YTD,
sum(EE) over (partition by policy_id,coverage_id,coverage_uniqueid, substring(month_id,1,4) order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) EE_YTD,
sum(WE) over (partition by policy_id,coverage_id,coverage_uniqueid order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) WE_ITD,
sum(EE) over (partition by policy_id,coverage_id,coverage_uniqueid order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) EE_ITD,
WE_RM,
EE_RM,
sum(WE_RM) over (partition by policy_id,coverage_id,coverage_uniqueid, substring(month_id,1,4) order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) WE_RM_YTD,
sum(EE_RM) over (partition by policy_id,coverage_id,coverage_uniqueid, substring(month_id,1,4) order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) EE_RM_YTD,
sum(WE_RM) over (partition by policy_id,coverage_id,coverage_uniqueid order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) WE_RM_ITD,
sum(EE_RM) over (partition by policy_id,coverage_id,coverage_uniqueid order by policy_id,coverage_id,coverage_uniqueid, month_id rows unbounded preceding) EE_RM_ITD
from dw_mga.stg_exposures;
update dw_mga.stg_exposures
set
WE_YTD=t.WE_YTD
,EE_YTD=t.EE_YTD
,WE_ITD=t.WE_ITD
,EE_ITD=t.EE_ITD
,WE_RM_YTD=t.WE_RM_YTD
,EE_RM_YTD=t.EE_RM_YTD
,WE_RM_ITD=t.WE_RM_ITD
,EE_RM_ITD=t.EE_RM_ITD
from tmp_exposures t
join dw_mga.stg_exposures e
on t.factpolicycoverage_id=e.factpolicycoverage_id;
/*=============================================================FACT_POLICYCOVERAGE Update =============================================================*/
update dw_mga.fact_policycoverage
set
we = e.we,
ee = e.ee,
we_ytd = e.we_ytd,
ee_ytd = e.ee_ytd,
we_itd = e.we_itd,
ee_itd = e.ee_itd,
we_rm = e.we_rm,
ee_rm = e.ee_rm,
we_rm_ytd = e.we_rm_ytd,
ee_rm_ytd = e.ee_rm_ytd,
we_rm_itd = e.we_rm_itd,
ee_rm_itd = e.ee_rm_itd
from dw_mga.fact_policycoverage f
join dw_mga.stg_exposures e
on f.factpolicycoverage_id=e.factpolicycoverage_id
and f.policy_id=e.policy_id;
END;


$$
;

CREATE OR REPLACE PROCEDURE dw_mga.sp_coverageextension_load()
LANGUAGE plpgsql
AS $$
BEGIN

INSERT INTO dw_mga.dim_coverageextension
select dce.*, null as FeeType from public.dim_coverageextension dce where dce.coverage_id = 0
and dce.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension)
union
select distinct dc.coverage_id as coverageextension_id, dc.coverage_id as coverage_id,
dce.covx_code, dce.covx_name, case when dce.covx_description = 'Dwelling (Fire and Lightning)' then 'Dwelling' else dce.covx_description end as covx_description,
case when dce.covx_subcode = '~' then '~' else dce.covx_subcode end as covx_subcode, dce.covx_subcodename, dce.covx_subcodedescription,
dce.covx_asl, dce.covx_subline, dce.codetype, dce.coveragetype, dce.act_rag, dce.fin_schedp, dce.act_modeldata_auto,
dce.act_modeldata_ho_ll, dce.act_modeldata_ho_ll_claims, dce.claim_features, dce.act_map, dce.clm_cov_group, dce.act_eris, dce.clm_subropotential, dce.clm_toolkit,
CASE
WHEN dce.covx_code::text = 'ICSFee'::character varying::text OR dce.covx_code::text = 'PolicyFee'::character varying::text OR dce.covx_code::text = 'InspectionFee'::character varying::text OR dce.covx_code::text = 'SSCFee'::character varying::text OR dce.covx_code::text = 'SeismicSafetyCommissionFee'::character varying::text THEN 'PolicyFee'::text
WHEN dce.codetype::text = 'Fee'::character varying::text AND dce.covx_code::text <> 'PolicyFee'::character varying::text AND dce.covx_code::text <> 'InspectionFee'::character varying::text AND dce.covx_code::text <> 'SSCFee'::character varying::text AND dce.covx_code::text <> 'ICSFee'::character varying::text AND dce.covx_code::text <> 'SeismicSafetyCommissionFee'::character varying::text THEN 'OtherFee'::text
ELSE NULL::text
END AS feetype
from dw_mga.dim_coverage dc
join fsbi_dw_spinn.dim_coverage dc2 on dc.cov_code = dc2.cov_code
join public.dim_coverageextension dce on dc2.coverage_id = dce.coverage_id and dc.cov_subcode = dce.covx_subcode and dc.cov_asl = dce.covx_asl and dc.cov_subline = dce.covx_subline
where dc.coverage_id <> 0
and dc.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension);

INSERT INTO dw_mga.dim_coverageextension
select distinct dc.coverage_id as coverageextension_id, dc.coverage_id as coverage_id,
dce.covx_code, dce.covx_name, case when dce.covx_description = 'Dwelling (Fire and Lightning)' then 'Dwelling' else dce.covx_description end as covx_description, '~' as covx_subcode, dce.covx_subcodename, dce.covx_subcodedescription,
dce.covx_asl, dce.covx_subline, dce.codetype, dce.coveragetype, dce.act_rag, dce.fin_schedp, dce.act_modeldata_auto,
dce.act_modeldata_ho_ll, dce.act_modeldata_ho_ll_claims, dce.claim_features, dce.act_map, dce.clm_cov_group, dce.act_eris, dce.clm_subropotential, dce.clm_toolkit,
CASE
WHEN dce.covx_code::text = 'ICSFee'::character varying::text OR dce.covx_code::text = 'PolicyFee'::character varying::text OR dce.covx_code::text = 'InspectionFee'::character varying::text OR dce.covx_code::text = 'SSCFee'::character varying::text OR dce.covx_code::text = 'SeismicSafetyCommissionFee'::character varying::text THEN 'PolicyFee'::text
WHEN dce.codetype::text = 'Fee'::character varying::text AND dce.covx_code::text <> 'PolicyFee'::character varying::text AND dce.covx_code::text <> 'InspectionFee'::character varying::text AND dce.covx_code::text <> 'SSCFee'::character varying::text AND dce.covx_code::text <> 'ICSFee'::character varying::text AND dce.covx_code::text <> 'SeismicSafetyCommissionFee'::character varying::text THEN 'OtherFee'::text
ELSE NULL::text
END AS feetype
from dw_mga.dim_coverage dc
join fsbi_dw_spinn.dim_coverage dc2 on dc.cov_code = dc2.cov_code
join public.dim_coverageextension dce on dc2.coverage_id = dce.coverage_id and dc.cov_asl = dce.covx_asl and dc.cov_subline = dce.covx_subline
where dc.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension);

INSERT INTO dw_mga.dim_coverageextension
select distinct dc.coverage_id as coverageextension_id, dc.coverage_id as coverage_id,
dce.covx_code, dce.covx_name, case when dce.covx_description = 'Dwelling (Fire and Lightning)' then 'Dwelling' else dce.covx_description end as covx_description, '~' as covx_subcode, dce.covx_subcodename, dce.covx_subcodedescription,
dce.covx_asl, dce.covx_subline, dce.codetype, dce.coveragetype, dce.act_rag, dce.fin_schedp, dce.act_modeldata_auto,
dce.act_modeldata_ho_ll, dce.act_modeldata_ho_ll_claims, dce.claim_features, 'Other' as act_map, dce.clm_cov_group, dce.act_eris, dce.clm_subropotential, dce.clm_toolkit,
CASE
WHEN dce.covx_code::text = 'ICSFee'::character varying::text OR dce.covx_code::text = 'PolicyFee'::character varying::text OR dce.covx_code::text = 'InspectionFee'::character varying::text OR dce.covx_code::text = 'SSCFee'::character varying::text OR dce.covx_code::text = 'SeismicSafetyCommissionFee'::character varying::text THEN 'PolicyFee'::text
WHEN dce.codetype::text = 'Fee'::character varying::text AND dce.covx_code::text <> 'PolicyFee'::character varying::text AND dce.covx_code::text <> 'InspectionFee'::character varying::text AND dce.covx_code::text <> 'SSCFee'::character varying::text AND dce.covx_code::text <> 'ICSFee'::character varying::text AND dce.covx_code::text <> 'SeismicSafetyCommissionFee'::character varying::text THEN 'OtherFee'::text
ELSE NULL::text
END AS feetype
from dw_mga.dim_coverage dc
join fsbi_dw_spinn.dim_coverage dc2 on dc.cov_code = dc2.cov_code
join public.dim_coverageextension dce on dc2.coverage_id = dce.coverage_id and dc.cov_asl = dce.covx_asl --and dc.cov_subline = dce.covx_subline 
where dc.cov_code in ( 'DWELL', 'FVREP', 'LOU') and dc.cov_subcode = '~' and dc.cov_asl = '010' and dc.cov_subline = 428
and dc.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension);

INSERT INTO dw_mga.dim_coverageextension
select distinct dc.coverage_id as coverageextension_id, dc.coverage_id as coverage_id,
dce.covx_code, dce.covx_name, case when dce.covx_description = 'Dwelling (Fire and Lightning)' then 'Dwelling' else dce.covx_description end as covx_description, '~' as covx_subcode, dce.covx_subcodename, dce.covx_subcodedescription,
dce.covx_asl, dce.covx_subline, dce.codetype, dce.coveragetype, dce.act_rag, dce.fin_schedp, dce.act_modeldata_auto,
dce.act_modeldata_ho_ll, dce.act_modeldata_ho_ll_claims, dce.claim_features, 'Other' as act_map, dce.clm_cov_group, dce.act_eris, dce.clm_subropotential, dce.clm_toolkit,
CASE
WHEN dce.covx_code::text = 'ICSFee'::character varying::text OR dce.covx_code::text = 'PolicyFee'::character varying::text OR dce.covx_code::text = 'InspectionFee'::character varying::text OR dce.covx_code::text = 'SSCFee'::character varying::text OR dce.covx_code::text = 'SeismicSafetyCommissionFee'::character varying::text THEN 'PolicyFee'::text
WHEN dce.codetype::text = 'Fee'::character varying::text AND dce.covx_code::text <> 'PolicyFee'::character varying::text AND dce.covx_code::text <> 'InspectionFee'::character varying::text AND dce.covx_code::text <> 'SSCFee'::character varying::text AND dce.covx_code::text <> 'ICSFee'::character varying::text AND dce.covx_code::text <> 'SeismicSafetyCommissionFee'::character varying::text THEN 'OtherFee'::text
ELSE NULL::text
END AS feetype
from dw_mga.dim_coverage dc
join fsbi_dw_spinn.dim_coverage dc2 on dc.cov_code = dc2.cov_code
join public.dim_coverageextension dce on dc2.coverage_id = dce.coverage_id and dce.covx_asl = '040' --and dc.cov_subline = dce.covx_subline 
where dc.cov_code in ('LOU','PP') and dc.cov_subcode = '~' and dc.cov_asl = '120' and dc.cov_subline = '460'
and dc.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension);

INSERT INTO dw_mga.dim_coverageextension
select distinct dc.coverage_id as coverageextension_id, dc.coverage_id as coverage_id,
dce.covx_code, dce.covx_name, case when dce.covx_description = 'Workers Compensation - Occasional Employee' then 'Workers Compensation' else dce.covx_description end as covx_description, '~' as covx_subcode, dce.covx_subcodename, dce.covx_subcodedescription,
dce.covx_asl, dce.covx_subline, dce.codetype, dce.coveragetype, dce.act_rag, dce.fin_schedp, dce.act_modeldata_auto,
dce.act_modeldata_ho_ll, dce.act_modeldata_ho_ll_claims, dce.claim_features, dce.act_map, dce.clm_cov_group, dce.act_eris, dce.clm_subropotential, dce.clm_toolkit,
CASE
WHEN dce.covx_code::text = 'ICSFee'::character varying::text OR dce.covx_code::text = 'PolicyFee'::character varying::text OR dce.covx_code::text = 'InspectionFee'::character varying::text OR dce.covx_code::text = 'SSCFee'::character varying::text OR dce.covx_code::text = 'SeismicSafetyCommissionFee'::character varying::text THEN 'PolicyFee'::text
WHEN dce.codetype::text = 'Fee'::character varying::text AND dce.covx_code::text <> 'PolicyFee'::character varying::text AND dce.covx_code::text <> 'InspectionFee'::character varying::text AND dce.covx_code::text <> 'SSCFee'::character varying::text AND dce.covx_code::text <> 'ICSFee'::character varying::text AND dce.covx_code::text <> 'SeismicSafetyCommissionFee'::character varying::text THEN 'OtherFee'::text
ELSE NULL::text
END AS feetype
from dw_mga.dim_coverage dc
join fsbi_dw_spinn.dim_coverage dc2 on dc.cov_code = dc2.cov_code
join public.dim_coverageextension dce on dc2.coverage_id = dce.coverage_id --and dc.cov_asl = dce.covx_asl --and dc.cov_subline = dce.covx_subline 
where dc.cov_code in ('WCINC') and dc.cov_subcode = '~' and dce.covx_asl = '040'
and dc.coverage_id not in (select coverage_id from dw_mga.dim_coverageextension);

END;


$$
;

CREATE OR REPLACE PROCEDURE dw_mga.process_adjuster_examiner(sql_bookDate timestamp, sql_currentDate timestamp)
LANGUAGE plpgsql
AS $$

-- =============================================
-- Author: Fausto Huezo
-- Create date: 2020-04-07
-- Description: Pull the lastes assignments for adjusters and examiners
-- 2021-02-22 FHUEZO Added logic for pulling claims born with adjuster assigned
-- 2022-05-20 FHUEZO Adaptation to pull adjuster assigned from feature
-- 2023-09-15 GOROKHL Adapted for mga, has to be updated to point to a new fivetran schema
-- 2023-10-16 KD - NULLIF changed to COALESCE; removed "fixing" part, added sql_bookDate and sql_CurrentDate (standard ETL) parameters
-- =============================================
BEGIN
drop table if exists #STG_ADJUSTER_EXAMINER;

SELECT c.SystemId, REPLACE(REPLACE(c.ClaimNumber, 'TX', ''), '-', '')ClaimNumber, trunc(cti.TransactionDt) as TransactionDt
, trunc(cti.BookDt) as BookDt, cti.TransactionNumber, coalesce(cmt.ClaimantNumber, cmtRef.ClaimantNumber) ClaimantNumber
, f.FeatureCd , ap.AssignedProviderTypeCd, ad.ProviderNumber as Adjuster, ex.ProviderNumber as Examiner
into #STG_ADJUSTER_EXAMINER
FROM
(
SELECT DISTINCT c1.SystemId
FROM mga_local_prodcse_dw.claim c1
-- WHERE c1.claimnumber NOT LIKE 'TX%'
)T
INNER JOIN mga_local_prodcse_dw.claim c ON c.ClaimRef = T.SystemId
AND c.StatusCd <> 'Deleted'
INNER JOIN mga_local_prodcse_dw.claimtransactioninfo cti
ON cti.SystemId = c.SystemId
AND cti.ParentId = c.Id
INNER JOIN mga_local_prodcse_dw.claimant cmt
ON cmt.SystemId = cti.SystemId
AND cmt.ParentId = cti.ParentId
INNER JOIN mga_local_prodcse_dw.feature f
ON f.ParentId = cmt.Id
AND f.SystemId = cmt.SystemId
INNER JOIN mga_local_prodcse_dw.assignedprovider ap
ON ap.systemid = C.systemid
AND ap.ParentId = cmt.Id
AND ap.AssignedProviderTypeCd = 'AssignedAdjuster'
/*LEFT join to Provider tables changed by KD because of test data? Does not return anything otherwise*/
LEFT JOIN mga_local_prodcse_dw.provider ad ON ad.SystemId = coalesce(ap.providerRef, f.ProviderRef ) /*Looks like IFNULL in the original Aurora SP was translated to NULLIF which is just the opposite to COALESCE*/
LEFT JOIN mga_local_prodcse_dw.provider ex ON ex.SystemId = c.ExaminerProviderRef
LEFT JOIN mga_local_prodcse_dw.claimant cmtRef
ON cmtRef.SystemId = cmt.SystemId
AND cmtRef.Id = cmt.ClaimantLinkIdRef
WHERE cti.BookDt > sql_bookDate and cti.BookDt <= sql_currentDate;
/* Next (removed) part is for some fixes in Production. vNullAdjusterFix view in ETL schema is based on a static table in Aurpra*/

DELETE FROM DW_MGA.Adjuster_Examiner_Tran
using #STG_Adjuster_Examiner STG
WHERE STG.SystemId = Adjuster_Examiner_Tran.SystemId
OR(STG.ClaimNumber = Adjuster_Examiner_Tran.ClaimNumber
AND STG.ClaimantNumber = Adjuster_Examiner_Tran.ClaimantNumber
AND STG.TransactionNumber = Adjuster_Examiner_Tran.TransactionNumber
AND STG.FeatureCd = Adjuster_Examiner_Tran.FeatureCd);

INSERT INTO DW_MGA.Adjuster_Examiner_Tran
(
SystemId
, ClaimNumber
, TransactionDt
, BookDt
, TransactionNumber
, ClaimantNumber
, FeatureCd
, AssignedProviderTypeCd
, Adjuster
, Examiner
)
SELECT DISTINCT
SystemId
, ClaimNumber
, TransactionDt
, BookDt
, TransactionNumber
, ClaimantNumber
, FeatureCd
, AssignedProviderTypeCd
, Adjuster
, Examiner
FROM #STG_Adjuster_Examiner;
END;


$$
;


CREATE OR REPLACE PROCEDURE dw_mga.process_dim_provider(sql_bookdate timestamp, sql_currentdate timestamp)
LANGUAGE plpgsql
AS $$

BEGIN


DROP TABLE IF EXISTS #tmp_deltas;
SELECT *
, CAST( 'N' AS VARCHAR(1)) ActionFlg
,CAST(SystemId AS INT) ProviderID
,CAST('Y' AS VARCHAR(1) )LastVersion
, ROW_NUMBER() OVER(ORDER BY SYSTEMID) RowKey
, ROW_NUMBER() OVER(PARTITION BY SYSTEMID ORDER BY SYSTEMID) RowVersion
INTO #tmp_deltas
FROM
(
SELECT DISTINCT
p.SystemId, to_date(p.updatetimestamp, 'mm/dd/YYYY' ) UpdateTimeStamp, TRIM(p.IndexName) AS IndexName, p.ProviderTypeCd, p.StatusCd, p.ProviderNumber,
ac.CommercialName, ac.PrimaryPhoneNumber, ac.EmailAddr, ac.MailingAddr1, ac.MailingCity, ac.MailingPostalCode, ac.BillingAddr1, ac.BillingCity, ac.BillingPostalCode, ac.BestAddr1, ac.BestCity, ac.BestPostalCode
, RIGHT(ti_FEIN.FEIN, 4) ProviderIndex2, RIGHT(ti_SS.SSN, 4) ProviderIndex1
, MD5(ti_FEIN.FEIN) FULLIndex2, MD5(ti_SS.SSN) FULLIndex1
FROM mga_local_prodcse_dw.provider p
INNER JOIN mga_local_prodcse_dw.allcontacts ac
ON AC.SourceIdRef = p.Id
AND AC.ContactTypeCd = 'Provider'
INNER JOIN mga_local_prodcse_dw.partyinfo pi ON pi.ParentId = p.Id
LEFT JOIN mga_local_prodcse_dw.taxinfo ti_FEIN ON ti_FEIN.ParentId = pi.Id
AND ti_FEIN.TaxIdTypeCd = 'FEIN'
LEFT JOIN mga_local_prodcse_dw.taxinfo ti_SS ON ti_SS.ParentId = pi.Id
AND ti_SS.TaxIdTypeCd = 'SSN'
WHERE to_date(p.updatetimestamp, 'mm/dd/YYYY') > DATEADD( day, -1,sql_bookDate)
and to_date(p.updatetimestamp, 'mm/dd/YYYY') <= DATEADD( day, +11,sql_currentDate)
)SQ;



--Just an update of data (Last version is populated before inserting) 
UPDATE #tmp_deltas
SET ProviderID = DP.ProviderID
, ActionFlg = 'U'
FROM fhuezo.DIM_Provider DP
WHERE DP.SystemId = #tmp_deltas.SystemId;
--Match on ProviderNumber from SPINN
UPDATE #tmp_deltas
SET ProviderID = DP.ProviderID
, ActionFlg = 'R'
FROM fhuezo.DIM_Provider DP
WHERE DP.ProviderNumber = #tmp_deltas.ProviderNumber
AND #tmp_deltas.ActionFlg = 'N'
AND LEN(#tmp_deltas.ProviderNumber) > 1;

--Match by tax data 1
UPDATE #tmp_deltas
SET ProviderID = DP.SystemId
, ActionFlg = 'R'
FROM fhuezo.DIM_Provider DP
WHERE DP.ProviderIndex1 = #tmp_deltas.ProviderIndex1
AND DP.FULLIndex1 = #tmp_deltas.FULLIndex1
AND #tmp_deltas.ActionFlg = 'N'
AND LEN(#tmp_deltas.ProviderIndex1) > 1
AND #tmp_deltas.ProviderIndex1 NOT IN('9999', '0000');

--Match by tax data 2
UPDATE #tmp_deltas
SET ProviderID = DP.SystemId
, ActionFlg = 'R'
FROM fhuezo.DIM_Provider DP
WHERE DP.ProviderIndex2 = #tmp_deltas.ProviderIndex2
AND DP.FULLIndex2 = #tmp_deltas.FULLIndex2
AND #tmp_deltas.ActionFlg = 'N'
AND LEN(#tmp_deltas.ProviderIndex2) > 1
AND #tmp_deltas.ProviderIndex2 NOT IN('9999', '0000');


UPDATE #tmp_deltas
SET ProviderID = SQ.ProviderID
, ActionFlg = 'R'
, LastVersion = 'N'
FROM
(
SELECT t.systemid, t.ProviderID
FROM #tmp_deltas t
WHERE t.RowVersion = 1
)SQ
WHERE #tmp_deltas.systemid = SQ.systemid
AND #tmp_deltas.RowVersion > 1
AND #tmp_deltas.ActionFlg IN ('R', 'N')
AND #tmp_deltas.LastVersion = 'Y';

UPDATE #tmp_deltas
SET ActionFlg = 'R'
, LastVersion = 'N'
FROM
(
SELECT MIN(RowKey)RowKey, ProviderID
FROM #tmp_deltas
WHERE LastVersion = 'Y'
GROUP BY ProviderID HAVING COUNT(1) > 1
)SQ
WHERE #tmp_deltas.LastVersion = 'Y'
AND SQ.ProviderID = #tmp_deltas.ProviderID
AND SQ.RowKey <> #tmp_deltas.RowKey;

UPDATE #tmp_deltas
SET ProviderID = SQ.SystemId
, ActionFlg = 'R'
, LastVersion = 'N'
FROM
(
SELECT MIN(RowKey)RowKey, MIN(SystemId)SystemId, FULLIndex2
FROM #tmp_deltas
WHERE LEN(ProviderIndex2) > 1
AND ProviderIndex2 NOT IN('9999', '0000')
GROUP BY ProviderIndex2, FULLIndex2
)SQ
WHERE SQ.FULLIndex2 = #tmp_deltas.FULLIndex2
AND SQ.RowKey <> #tmp_deltas.RowKey
AND #tmp_deltas.ActionFlg IN ('R', 'N')
AND #tmp_deltas.LastVersion = 'Y';

UPDATE #tmp_deltas
SET ProviderID = SQ.SystemId
, ActionFlg = 'R'
, LastVersion = 'N'
FROM ( SELECT MIN(RowKey)RowKey, MIN(SystemId)SystemId, CommercialName FROM #tmp_deltas GROUP BY CommercialName ) SQ
WHERE TRIM(SQ.CommercialName) = TRIM(#tmp_deltas.CommercialName)
AND SQ.RowKey <> #tmp_deltas.RowKey
AND #tmp_deltas.ActionFlg IN ('R', 'N')
AND #tmp_deltas.LastVersion = 'Y';

UPDATE #tmp_deltas
SET ProviderID = SQ.SystemId
, ActionFlg = 'R'
, LastVersion = 'N'
FROM (SELECT MIN(RowKey)RowKey, MIN(SystemId)SystemId, ProviderNumber FROM #tmp_deltas GROUP BY ProviderNumber) SQ
WHERE SQ.ProviderNumber = #tmp_deltas.ProviderNumber
AND SQ.RowKey <> #tmp_deltas.RowKey
AND #tmp_deltas.ActionFlg IN ('R', 'N')
AND #tmp_deltas.LastVersion = 'Y';

--LastVersion update for those missing pieces of data in the day but matched from previous rows
UPDATE #tmp_deltas
SET LastVersion = 'N'
FROM (SELECT MIN(RowKey)RowKey, ProviderID FROM #tmp_deltas GROUP BY ProviderID) SQ
WHERE SQ.ProviderID = #tmp_deltas.ProviderID
AND SQ.RowKey <> #tmp_deltas.RowKey
AND #tmp_deltas.ActionFlg IN ('R', 'N')
AND #tmp_deltas.LastVersion = 'Y';

--Lastly, any provider duplicated the same day will get fixed before inserting
UPDATE #tmp_deltas
SET ActionFlg = 'R'
, LastVersion = 'N'
FROM (SELECT MIN(RowKey)RowKey, ProviderID FROM #tmp_deltas WHERE LastVersion = 'Y' GROUP BY ProviderID HAVING COUNT(1) > 1) SQ
WHERE SQ.ProviderID = #tmp_deltas.ProviderID
AND SQ.RowKey <> #tmp_deltas.RowKey
AND #tmp_deltas.LastVersion = 'Y';


IF(SELECT COUNT(1) FROM #tmp_deltas) > 0
THEN
DELETE FROM dw_mga.DIM_Provider
WHERE EXISTS(SELECT 1 FROM #tmp_deltas t WHERE t.SystemId = dw_mga.DIM_Provider.SystemId);
UPDATE dw_mga.DIM_Provider
SET LastVersion = 'N'
FROM #tmp_deltas t
WHERE t.ProviderID = dw_mga.DIM_Provider.ProviderID
AND dw_mga.DIM_Provider.LastVersion = 'Y';
INSERT INTO dw_mga.DIM_Provider
(
ProviderID
,LastVersion
,SystemId
,UpdateTimeStamp
,IndexName
,ProviderTypeCd
,StatusCd
,ProviderNumber
,CommercialName
,PrimaryPhoneNumber
,EmailAddr
,MailingAddr1
,MailingCity
,MailingPostalCode
,BillingAddr1
,BillingCity
,BillingPostalCode
,BestAddr1
,BestCity
,BestPostalCode
,ProviderIndex2
,ProviderIndex1
,FULLIndex2
,FULLIndex1
,insertby
,insertdate
)
SELECT DISTINCT
ProviderID
,LastVersion
,SystemId
,UpdateTimeStamp
,IndexName
,ProviderTypeCd
,StatusCd
,ProviderNumber
,CommercialName
,PrimaryPhoneNumber
,EmailAddr
,MailingAddr1
,MailingCity
,MailingPostalCode
,BillingAddr1
,BillingCity
,BillingPostalCode
,BestAddr1
,BestCity
,BestPostalCode
,ProviderIndex2
,ProviderIndex1
,FULLIndex2
,FULLIndex1
,current_user
,GetDate()
FROM #tmp_deltas;

END IF;
END;


$$
;



					
