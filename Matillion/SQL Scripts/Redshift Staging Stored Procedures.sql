CREATE OR REPLACE PROCEDURE kdlab.sp_stg_policy_scope(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN



truncate table kdlab.stg_policy_scope;
insert into kdlab.stg_policy_scope
/*Only NOT approved New Business Applications*/
select
sql_loadDate LoadDate,
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from aurora_prodcse_dw.application cb
join aurora_prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join kdlab.vstg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='Application'
and to_date(substring(UpdateTimestamp,1,10), 'mm/dd/yyyy') > DATEADD(day, -1, sql_bookDate)
and to_date(substring(UpdateTimestamp,1,10), 'mm/dd/yyyy') <= DATEADD(day, 1, sql_currentDate)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
sql_loadDate LoadDate,
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from kdlab.vstg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_policy(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;


/*Fees are related only to policies, not quotes*/
drop table if exists tmp_accounts;
create temporary table tmp_accounts as
select distinct art.SystemId AccountRef
from aurora_prodCSE_dw.artrans art
where art.AdjustmentCategoryCd in ('LateFee','NSFFee', 'InstallmentFee')
and art.Amount<>0
and art.BookDt > sql_bookDate and art.BookDt <= sql_currentDate
and art.CMMContainer='Account';


/*Payments are related only to policies, NOT quotes*/
drop table if exists tmp_payments;
create temporary table tmp_payments as
select distinct a.PolicyRef
from aurora_prodcse.AccountStats a
where
a.BookDt > sql_bookDate and a.BookDt <= sql_currentDate
group by a.PolicyRef;


/* Adding in the scope policies with Fees and Payments
* but not after sql_currentDate for consistncy
* just to "refresh" existing records*/
insert into tmp_scope
/*from Fees - add in an all policy's records by PolicyRef */
select
sql_loadDate LoadDate,
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from aurora_prodcse_dw.Policy p
join tmp_accounts a
on p.AccountRef=a.AccountRef
and p.cmmContainer='Policy'
join kdlab.vstg_policyhistory h
on p.SystemId=h.PolicyRef
where h.BookDt <= sql_currentDate
union
/*from payments - add in an all policy's records by PolicyRef*/
select
sql_loadDate LoadDate,
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from tmp_payments p
join kdlab.vstg_policyhistory h
on p.PolicyRef=h.PolicyRef
where h.BookDt <= sql_currentDate;


drop table if exists tmp_fees;
create temporary table tmp_fees as
select distinct
bp.SystemId PolicyRef,
art.AdjustmentCategoryCd
from aurora_prodCSE_dw.artrans art
join aurora_prodCSE_dw.Account a
on art.SystemId=a.SystemId
and art.ParentId=a.Id
and art.CMMContainer=a.CMMContainer
join aurora_prodcse_dw.Policy p
on p.AccountRef=a.SystemId
and p.cmmContainer='Policy'
join tmp_scope s
on s.PolicyRef=p.SystemId
join aurora_prodcse_dw.BasicPolicy bp
on p.SystemId=bp.SystemId
and p.cmmContainer=bp.cmmContainer
where art.AdjustmentCategoryCd in ('LateFee','NSFFee', 'InstallmentFee')
and a.CMMContainer='Account'
and art.Amount<>0 ;




drop table if exists tmp_ppd;
create temporary table tmp_ppd as
select distinct PolicyNumber,
PaperlessDeliveryInd
from aurora_prodcse_dw.PaperLessDeliveryPolicy
where PaperlessDeliveryInd = 'Yes';



drop table if exists tmp_payments_values;
create temporary table tmp_payments_values as
select a.PolicyRef,
min( case when a.PaidAmt > 0 then a.AddDt end) as FirstPayment,
max( case when a.PaidAmt > 0 then a.AddDt end) as LastPayment,
sum(a.BalanceAmt) as BalanceAmt,
sum(a.PaidAmt) as PaidAmt
from aurora_prodcse.AccountStats a
join tmp_scope tp
on tp.PolicyRef=a.PolicyRef
group by a.PolicyRef;



drop table if exists tmp_bd;
create temporary table tmp_bd as
select distinct
b.SystemId ,
b.CMMContainer,
b.MultiPolicyInd,
b.MultiPolicyNumber,
b.AutoHomeInd,
b.otherpolicynumber1,
b.MultiPolicyIndUmbrella,
b.MultiPolicyNumberUmbrella,
b.EmployeeCreditInd ,
b.PrimaryPolicyNumber,
b.LandlordInd
from aurora_prodcse_dw.Building b
join tmp_scope s
on b.SystemId = s.SystemId
and b.CMMContainer = s.CMMContainer
and b.Status='Active';



/*Umbrella policies underlying policies*/
drop table if exists tmp_up;
create temporary table tmp_up as
select
bp.SystemId,
bp.cmmContainer,
LISTAGG(distinct UnderlyingPolicyNumber) UnderlyingPolicyNumber
from tmp_scope s
join aurora_prodcse_dw.BasicPolicy bp
on bp.SystemId=s.SystemId
and bp.cmmContainer=s.cmmcontainer
join aurora_prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.cmmContainer=s.cmmContainer
join aurora_prodcse_dw.location l
on l.SystemId=s.SystemId
and l.Id=r.LocationRef
and l.cmmContainer=s.cmmContainer
where r.TypeCd='Automobile'
and bp.PolicyNumber like '%U%'
and l.UnderlyingPolicyNumber is not null
group by bp.SystemId,bp.cmmContainer;

truncate table kdlab.stg_policy;
insert into kdlab.stg_policy
select distinct
sql_loadDate as LoadDate
, isnull(s.PolicySystemId,s.SystemId) SystemId
, isnull(s.BookDt,'1900-01-01') BookDt
, isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, isnull(s.PolicyRef,0) as policy_uniqueid
, bp.TransactionCd
, bp.ProductVersionIdRef product_uniqueid
, isnull(concat(LEFT(concat(bp.CarrierCd , ' '),6) , case when bp.CompanyCd > '' then concat('-' , bp.CompanyCd) else '' end),'Unknown') as company_uniqueid
, isnull(pro.ProviderNumber,'Unknown') producer_uniqueid
, isnull(s.PolicySystemId,s.SystemId) firstinsured_uniqueid
, isnull(bp.PolicyNumber,'Unknown') pol_policynumber
, right(RIGHT(concat('000',isnull(bp.PolicyVersion,'')),3),2) term
, bp.EffectiveDt as pol_effectiveDate
, bp.ExpirationDt as pol_expirationDate
, cse_bi.ifempty(bp.CarrierCd, '~') as CarrierCd
, cse_bi.ifempty(bp.CompanyCd, '~') as CompanyCd
, DATEDIFF(day,bp.ExpirationDt,bp.EffectiveDt) TermDays
, cse_bi.ifempty(bp.CarrierGroupCd, '~') as CarrierGroupCd
, cse_bi.ifempty(bp.ControllingStateCd, '~') as StateCd
, cse_bi.ifempty(bp.BusinessSourceCd, '~') as BusinessSourceCd
, cse_bi.ifempty(bp.PreviousCarrierCd, '~') as PreviousCarrierCd
, cse_bi.ifempty(bp.SubTypeCd, '~') as PolicyFormCode
, cse_bi.ifempty(bp.SubTypeCd, '~') as SubTypeCd
, cse_bi.ifempty(pv.AltSubTypeCd, '~') as AltSubTypeCd
, cse_bi.ifempty(bp.PayPlanCd, '~') as PayPlanCd
, isnull(bp.InceptionDt,'1900-01-01') as InceptionDt
, cse_bi.ifempty(bp.priorpolicynumber, '~') as priorpolicynumber
, cse_bi.ifempty(bp.previouspolicynumber, '~') as previouspolicynumber
, cse_bi.ifempty(bp.affinitygroupcd, '~') as affinitygroupcd
, cse_bi.ifempty(bp.programInd, '~') as programInd
, cse_bi.ifempty(l.RelatedPolicyNumber, '~') as RelatedPolicyNumber
, cse_bi.ifempty(bp.QuoteNumber, '~') as QuoteNumber
, cse_bi.ifempty(bp.RenewalTermCd, '~') as RenewalTermCd
, isnull(bp.RewritePolicyRef,0) RewritePolicyRef
, isnull(bp.RewriteFromPolicyRef,0) RewriteFromPolicyRef
, isnull(bp.CancelDt,'1900-01-01') CancelDt
, isnull(bp.ReinstateDt,'1900-01-01') ReinstateDt
, isnull(bp.PersistencyDiscountDt,'1900-01-01') PersistencyDiscountDt
, isnull(PPD.PaperlessDeliveryInd,'No') PaperLessDelivery
, cse_bi.ifempty(l.MultiCarDiscountInd,'No') MultiCarDiscountInd
, case when lf.PolicyRef is null then 'No' else 'Yes' end LateFee
, case when nsf.PolicyRef is null then 'No' else 'Yes' end NSFFee
, case when inf.PolicyRef is null then 'No' else 'Yes' end InstallmentFee
, cse_bi.ifempty(bp.batchquotesourcecd, '~') as batchquotesourcecd
, cse_bi.ifempty(l.WaivePolicyFeeInd, '~') as WaivePolicyFeeInd
/*Liability*/
, cse_bi.ifempty(l.LiabilityLimitCPL, '~') as LiabilityLimitCPL
, cse_bi.ifempty(l.LiabilityReductionInd, '~') as LiabilityReductionInd
, cse_bi.ifempty(l.LiabilityLimitOLT, '~') as LiabilityLimitOLT
, cse_bi.ifempty(l.PersonalLiabilityLimit, '~') as PersonalLiabilityLimit
, cse_bi.ifempty(l.GLOccurrenceLimit, '~') as GLOccurrenceLimit
, cse_bi.ifempty(l.GLAggregateLimit, '~') as GLAggregateLimit
, cse_bi.ifempty(bp.Statuscd, '~') as Policy_SPINN_Status
, cse_bi.ifempty(l.BILimit, '~') as BILimit
, cse_bi.ifempty(l.PDLimit, '~') as PDLimit
, cse_bi.ifempty(l.UMBILimit, '~') as UMBILimit
, cse_bi.ifempty(l.MedPayLimit, '~') as MedPayLimit
, case
when substring(bp.PolicyNumber,3,1)='A' then case when isnull(l.MultiPolicyDiscountInd,'No')<>'No' or l.MultiPolicyDiscount2Ind='Yes' then 'Yes' else 'No' end
when substring(bp.PolicyNumber,3,1)in ('H','F') then case when isnull(b.MultiPolicyInd,'No')='Yes' or isnull(b.AutoHomeInd,'No')='Yes' or isnull(b.MultiPolicyIndUmbrella,'No')='Yes' then 'Yes' else 'No' end
else 'No'
end MultiPolicyDiscount
-- 
, case when isnull(b.MultiPolicyInd,'No')='Yes' or isnull(b.AutoHomeInd,'No')='Yes' then 'Yes' else 'No' end MultiPolicyAutoDiscount
, case when isnull(b.MultiPolicyInd,'No')='Yes' and cse_bi.ifempty(b.MultiPolicyNumber,'~')<>'~' then cse_bi.ifempty(b.MultiPolicyNumber,'~') else cse_bi.ifempty(b.otherpolicynumber1,'~') end MultiPolicyAutoNumber
-- 
, cse_bi.ifempty(l.MultiPolicyDiscountInd,'No') MultiPolicyHomeDiscount
, cse_bi.ifempty(l.RelatedPolicyNumber,'~') HomeRelatedPolicyNumber
-- 
, case
when substring(bp.PolicyNumber,3,1)='A' then cse_bi.ifempty(l.MultiPolicyDiscount2Ind,'No')
when substring(bp.PolicyNumber,3,1)in ('H','F') then cse_bi.ifempty(b.MultiPolicyIndUmbrella,'No')
else 'No'
end MultiPolicyUmbrellaDiscount
, case
when substring(bp.PolicyNumber,3,1)='A' then cse_bi.ifempty(l.RelatedPolicyNumber2,'~')
when substring(bp.PolicyNumber,3,1)in ('H','F') then cse_bi.ifempty(b.MultiPolicyNumberUmbrella,'~')
else 'No'
end UmbrellaRelatedPolicyNumber
-- 
, case
when substring(bp.PolicyNumber,3,1)='A' then cse_bi.ifempty(CSEEmployeeDiscountInd,'No')
when substring(bp.PolicyNumber,3,1)in ('H','F') then cse_bi.ifempty(b.EmployeeCreditInd,'No')
else 'No'
end CSEEmployeeDiscountInd
, cse_bi.ifempty(l.FullPayDiscountInd,'No') FullPayDiscountInd
, cse_bi.ifempty(l.TwoPayDiscountInd,'No') TwoPayDiscountInd
, case when cse_bi.ifempty(b.PrimaryPolicyNumber,'~')='~' then cse_bi.ifempty(up.UnderlyingPolicyNumber,'~') else cse_bi.ifempty(b.PrimaryPolicyNumber,'~') end PrimaryPolicyNumber
, cse_bi.ifempty(b.LandLordInd,'No') LandLordInd
, cse_bi.ifempty(l.PersonalInjuryInd,'No') PersonalInjuryInd
, cse_bi.ifempty(l.VehicleListConfirmedInd,'No') VehicleListConfirmedInd
, isnull(tp.FirstPayment,'1900-01-01') FirstPayment
, isnull(tp.LastPayment,'1900-01-01') LastPayment
, isnull(tp.BalanceAmt,0) BalanceAmt
, isnull(tp.PaidAmt,0) PaidAmt
--
, isnull(bp.WrittenPremiumAmt,0) writtenpremiumamt
, isnull(bp.fulltermamt,0) fulltermamt
, isnull(bp.CommissionAmt,0) commissionamt
--
, isnull(p.AccountRef,0) as AccountRef
--
, coalesce(p.CustomerRef,qi.customerRef,0) CUSTOMER_UNIQUEID
, cse_bi.ifempty(a.ApplicationNumber,'~') ApplicationNumber
, to_date(substring(a.UpdateTimestamp,1,10), 'mm/dd/yyyy') Application_UpdateTimestamp
, isnull(qi.UpdateDt,'1900-01-01') QuoteInfo_UpdateDt
, isnull(qi.adduser,'Unknown') QuoteInfo_adduser_uniqueid
, isnull(a.PolicyRef,0) original_policy_uniqueid
, cse_bi.ifempty(a.TypeCd,'~') Application_Type
, cse_bi.ifempty(qi.TypeCd,'~') QuoteInfo_Type
, cse_bi.ifempty(a.Status,'~') Application_Status
, cse_bi.ifempty(qi.Status,'~') QuoteInfo_Status
, cse_bi.ifempty(qi.CloseReasonCd,'~') QuoteInfo_CloseReasonCd
, cse_bi.ifempty(qi.CloseSubReasonCd,'~') QuoteInfo_CloseSubReasonCd
, cse_bi.ifempty(qi.CloseComment,'~') QuoteInfo_CloseComment
/*, cse_bi.ifempty(bp.MGAFeePlanCd,'~') MGAFeePlanCd
, isnull(bp.MGAFeePct,0) MGAFeePct
, cse_bi.ifempty(bp.TPAFeePlanCd,'~') TPAFeePlanCd
, isnull(bp.TPAFeePct,0) TPAFeePct
*/
, '~' MGAFeePlanCd
, 0 MGAFeePct
, '~' TPAFeePlanCd
, 0 TPAFeePct
from tmp_scope s
left outer join aurora_prodcse_dw.Policy p
on p.SystemId=s.PolicyRef
left outer join aurora_prodcse_dw.Application a
on a.SystemId = case when s.cmmContainer='Application' then s.SystemId else s.PolicySystemId end
left outer join aurora_prodcse_dw.QuoteInfo qi
on qi.SystemId = case when s.cmmContainer='Application' then s.SystemId else s.PolicySystemId end
join aurora_prodcse_dw.basicpolicy bp
on bp.SystemId = s.SystemId
and bp.CMMContainer = s.CMMContainer
join aurora_prodcse_dw.provider pro
on bp.ProviderRef = pro.SystemId
and pro.ProviderTypeCd = 'Producer'
and pro.cmmContainer='Provider'
left outer join aurora_prodcse_dw.Line l
on l.SystemId = s.SystemId
and l.CMMContainer = s.CMMContainer
and ((bp.CarrierGroupCd='CommercialLines' and l.LineCd='Liability') or bp.CarrierGroupCd<>'CommercialLines')
left outer join tmp_PPD PPD
on bp.PolicyNumber=PPD.PolicyNumber
left outer join tmp_fees lf
on lf.AdjustmentCategoryCd='LateFee'
and lf.PolicyRef=s.PolicyRef
left outer join tmp_fees nsf
on nsf.AdjustmentCategoryCd='NSFFee'
and nsf.PolicyRef=s.PolicyRef
left outer join tmp_fees inf
on inf.AdjustmentCategoryCd='InstallmentFee'
and inf.PolicyRef=s.PolicyRef
left outer join tmp_bd b
on b.SystemId=s.SystemId
and b.cmmContainer=s.cmmContainer
left outer join tmp_up up
on up.SystemId = s.SystemId
and up.cmmContainer = s.cmmContainer
left outer join aurora_prodcse.ProductVersionInfo pv
on bp.ProductVersionIdRef=pv.ProductVersionIdRef
left outer join tmp_payments_values tp
on tp.PolicyRef = s.PolicyRef
;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_product(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

drop table if exists tmp_BasicProduct;
create temporary table tmp_BasicProduct as
select
distinct
bp.ProductVersionIdRef,
bp.SubTypeCd,
l.LineCd
from tmp_scope s
join aurora_prodcse_dw.BasicPolicy bp
on s.SystemId=bp.SystemId
and s.CMMCOntainer=bp.CMMContainer
join aurora_prodcse_dw.Line l
on s.SystemId=l.SystemId
and bp.CMMContainer=l.CMMContainer
where isnull(bp.ProductVersionIDRef,'') <> '';

truncate table kdlab.stg_product;
insert into kdlab.stg_product
select
sql_loadDate loaddate,
isnull(pvi.productversionidref, bp.productversionidref) product_uniqueid,
cse_bi.ifempty(productversion,'~') productversion,
cse_bi.ifempty(name,'~') name,
cse_bi.ifempty(description,'~') description,
cse_bi.ifempty(producttypecd,'~') producttypecd,
cse_bi.ifempty(carriergroupcd,'~') carriergroupcd,
cse_bi.ifempty(carriercd,'~') carriercd,
isnull(isselect,0) isselect,
isnull(pvi.linecd, bp.linecd) linecd,
isnull(pvi.subtypecd,bp.subtypecd) subtypecd,
cse_bi.ifempty(altsubtypecd,'~') altsubtypecd,
cse_bi.ifempty(subtypeshortdesc,'~') subtypeshortdesc,
cse_bi.ifempty(subtypefulldesc,'~') subtypefulldesc,
cse_bi.ifempty(policynumberprefix,'~') policynumberprefix,
isnull(startdt,'1900-01-01') startdt,
isnull(stopdt,'2999-12-31') stopdt,
isnull(renewalstartdt,'1900-01-01') renewalstartdt,
isnull(renewalstopdt,'2999-12-31') renewalstopdt,
cse_bi.ifempty(statecd,'~') statecd,
cse_bi.ifempty(contract,'~') contract,
cse_bi.ifempty(lob,'~') lob,
cse_bi.ifempty(propertyform,'~') propertyform,
case
when prerenewaldays is null then 0
when prerenewaldays !~ ('[0-9]') then 0
else CAST(prerenewaldays as int)
end prerenewaldays,
case
when autorenewaldays is null then 0
when autorenewaldays !~ ('[0-9]') then 0
else CAST(autorenewaldays as int)
end autorenewaldays,
--cse_bi.ifempty(MGAFeePlanCd,'~') MGAFeePlanCd,
--cse_bi.ifempty(TPAFeePlanCd,'~') TPAFeePlanCd
'~' MGAFeePlanCd,
'~' TPAFeePlanCd
from tmp_BasicProduct bp
left outer join aurora_prodcse.ProductVersionInfo pvi
on bp.productversionidref=pvi.productversionidref
union
select
sql_loadDate,
cse_bi.ifempty(productversionidref,'~') product_uniqueid,
cse_bi.ifempty(productversion,'~') productversion,
cse_bi.ifempty(name,'~') name,
cse_bi.ifempty(description,'~') description,
cse_bi.ifempty(producttypecd,'~') producttypecd,
cse_bi.ifempty(carriergroupcd,'~') carriergroupcd,
cse_bi.ifempty(carriercd,'~') carriercd,
isnull(isselect,0) isselect,
cse_bi.ifempty(linecd,'~') linecd,
cse_bi.ifempty(subtypecd,'~') subtypecd,
cse_bi.ifempty(altsubtypecd,'~') altsubtypecd,
cse_bi.ifempty(subtypeshortdesc,'~') subtypeshortdesc,
cse_bi.ifempty(subtypefulldesc,'~') subtypefulldesc,
cse_bi.ifempty(policynumberprefix,'~') policynumberprefix,
isnull(startdt,'1900-01-01') startdt,
isnull(stopdt,'2999-12-31') stopdt,
isnull(renewalstartdt,'1900-01-01') renewalstartdt,
isnull(renewalstopdt,'2999-12-31') renewalstopdt,
cse_bi.ifempty(statecd,'~') statecd,
cse_bi.ifempty(contract,'~') contract,
cse_bi.ifempty(lob,'~') lob,
cse_bi.ifempty(propertyform,'~') propertyform,
case
when prerenewaldays is null then 0
when prerenewaldays !~ ('[0-9]') then 0
else CAST(prerenewaldays as int)
end prerenewaldays,
case
when autorenewaldays is null then 0
when autorenewaldays !~ ('[0-9]') then 0
else CAST(autorenewaldays as int)
end autorenewaldays,
--cse_bi.ifempty(MGAFeePlanCd,'~') MGAFeePlanCd,
--cse_bi.ifempty(TPAFeePlanCd,'~') TPAFeePlanCd
'~' MGAFeePlanCd,
'~' TPAFeePlanCd
from aurora_prodcse.ProductVersionInfo pvi
;


END;

$$
;


CREATE OR REPLACE PROCEDURE kdlab.sp_stg_insured(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

truncate table kdlab.stg_insured;
insert into kdlab.stg_insured
select
sql_loadDate as LoadDate,
isnull(s.PolicySystemId,s.SystemId) SystemId
, isnull(s.BookDt,'1900-01-01') BookDt
, isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, isnull(s.PolicyRef,0) as policy_uniqueid
, isnull(s.PolicySystemId,s.SystemId) as insured_uniqueid
, cse_bi.ifempty(NI.GivenName,'~') as first_name
, cse_bi.ifempty(NI.Surname,'~') as last_name
, cse_bi.ifempty(NI.CommercialName,'~') as CommercialName
, CASE WHEN isnull(PerI.BirthDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(PerI.BirthDt,to_date('1900-01-01', 'yyyy-mm-dd')) end as DOB
, cse_bi.ifempty(PerI.OccupationClassCd,'~') as occupation
, cse_bi.ifempty(PerI.GenderCd,'~') as gender
, cse_bi.ifempty(PerI.MaritalStatusCd,'~') as maritalStatus
, cse_bi.ifempty(A1.Addr1,'~') as address1
, cse_bi.ifempty(REPLACE(A1.Addr2,'|','/'),'~') as address2
, cse_bi.ifempty(A1.County,'~') as county
, cse_bi.ifempty(A1.City,'~') as city
, cse_bi.ifempty(A1.StateProvCd,'~') as state
, cse_bi.ifempty(A1.RegionCd,'~') as Country
, cse_bi.ifempty(A1.PostalCode,'~') as postalCode
, cse_bi.ifempty(case
when ac.PrimaryPhoneName<>'Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName<>'Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as telephone
, cse_bi.ifempty(case
when ac.PrimaryPhoneName='Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName='Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as mobile
, cse_bi.ifempty(ac.emailaddr,'~') as email
, cse_bi.ifempty(PerI.PositionTitle,'~') as jobTitle
, cse_bi.ifempty(isc.InsuranceScore,'~') as InsuranceScore
, cse_bi.ifempty(isc.OverriddenInsuranceScore,'~') as OverriddenInsuranceScore
, isnull(to_date(isc.AppliedDt, 'yyyy-mm-dd'),to_date('1900-01-01', 'yyyy-mm-dd')) as AppliedDt
, cse_bi.ifempty(isc.InsuranceScoreValue,'~') as InsuranceScoreValue
, isnull(to_date(isc.RatePageEffectiveDt, 'yyyy-mm-dd'),to_date('1900-01-01', 'yyyy-mm-dd')) as RatePageEffectiveDt
, cse_bi.ifempty(isc.InsScoreTierValueBand,'~') as InsScoreTierValueBand
, cse_bi.ifempty(isc.FinancialStabilityTier,'~') as FinancialStabilityTier
from tmp_scope s
join aurora_prodcse_dw.Insured as I
on I.SystemId = s.SystemId
and I.CMMContainer = s.CMMContainer
join aurora_prodcse_dw.PartyInfo as PartyI
on PartyI.SystemId = s.SystemId
and PartyI.ParentId = I.ID
and PartyI.CMMContainer = s.CMMContainer
and PartyI.PartyTypeCd = 'InsuredParty'
join aurora_prodcse_dw.NameInfo as NI
on NI.SystemId = s.SystemId
and NI.CMMContainer = s.CMMContainer
and NI.ParentId = PartyI.id
and NI.NameTypeCd = 'InsuredName'
join aurora_prodcse_dw.PersonInfo as PerI
on PerI.SystemId = s.SystemId
and PerI.CMMContainer = s.CMMContainer
and PerI.ParentId = PartyI.id
and PerI.PersonTypeCd = 'InsuredPersonal'
join aurora_prodcse_dw.Addr as A1
on A1.SystemId = s.SystemId
and A1.CMMContainer = s.CMMContainer
and A1.ParentId = PartyI.id
and A1.AddrTypeCd = 'InsuredMailingAddr'
join aurora_prodcse_dw.AllContacts ac
on ac.systemid = s.SystemId
and ac.cmmcontainer = s.CMMContainer
and ac.contacttypecd = 'Insured'
left join aurora_prodcse_dw.InsuranceScore isc
on isc.SystemId=s.SystemId
and isc.cmmContainer=s.CMMContainer
and isc.ParentId=I.Id ;



END;

$$
;


CREATE OR REPLACE PROCEDURE kdlab.sp_stg_building(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

truncate table kdlab.stg_building;
insert into kdlab.stg_building
-- Dwelling 
select
'Dwelling' LineCD,
sql_loadDate as LoadDate,
isnull(s.PolicySystemId,s.SystemId) SystemId,
isnull(s.BookDt,'1900-01-01') BookDt,
isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
isnull(s.PolicyRef,0) as policy_uniqueid,
b.Id SPINNBuilding_Id,
b.ParentId Risk_Uniqueid,
isnull(r.TypeCd,'~') Risk_Type,
cast(isnull(s.PolicySystemId,s.SystemId) as varchar)+'_'+b.ParentId+'_'+isnull(cast(b.BldgNumber as varchar),'1') building_uniqueid,
coalesce(b.Status,r.Status,'Unknown') Status,
isnull(a.StateProvCd,'~') StateProvCd,
isnull(a.County,'~') County,
isnull(a.PostalCode,'~') PostalCode,
isnull(a.City,'~') City,
isnull(a.Addr1,'~') Addr1,
isnull(a.Addr2,'~') Addr2,
isnull(b.BldgNumber ,0) BldgNumber ,
isnull(b.BusinessCategory ,'~') BusinessCategory ,
isnull(b.BusinessClass ,'~') BusinessClass ,
isnull(b.ConstructionCd ,'~') ConstructionCd ,
isnull(b.RoofCd ,'~') RoofCd ,
isnull(b.YearBuilt ,0) YearBuilt ,
isnull(b.SqFt ,0) SqFt ,
isnull(b.Stories ,0) Stories ,
isnull(b.Units ,0) Units ,
isnull(b.OccupancyCd ,'~') OccupancyCd ,
isnull(b.ProtectionClass ,'~') ProtectionClass ,
isnull(b.TerritoryCd ,'~') TerritoryCd ,
isnull(b.BuildingLimit ,0) BuildingLimit ,
isnull(b.ContentsLimit ,0) ContentsLimit ,
isnull(b.ValuationMethod ,'~') ValuationMethod ,
isnull(b.InflationGuardPct ,0) InflationGuardPct ,
isnull(b.OrdinanceOrLawInd ,'~') OrdinanceOrLawInd ,
isnull(b.ScheduledPremiumMod ,0) ScheduledPremiumMod ,
isnull(b.WindHailExclusion ,'~') WindHailExclusion ,
isnull(b.CovALimit ,0) CovALimit ,
isnull(b.CovBLimit ,0) CovBLimit ,
isnull(b.CovCLimit ,0) CovCLimit ,
isnull(b.CovDLimit ,0) CovDLimit ,
isnull(b.CovELimit ,0) CovELimit ,
isnull(b.CovFLimit ,0) CovFLimit ,
isnull(b.AllPerilDed ,'~') AllPerilDed ,
isnull(b.BurglaryAlarmType ,'~') BurglaryAlarmType ,
isnull(b.FireAlarmType ,'~') FireAlarmType ,
isnull(b.CovBLimitIncluded ,0) CovBLimitIncluded ,
isnull(b.CovBLimitIncrease ,0) CovBLimitIncrease ,
isnull(b.CovCLimitIncluded ,0) CovCLimitIncluded ,
isnull(b.CovCLimitIncrease ,0) CovCLimitIncrease ,
isnull(b.CovDLimitIncluded ,0) CovDLimitIncluded ,
isnull(b.CovDLimitIncrease ,0) CovDLimitIncrease ,
isnull(b.OrdinanceOrLawPct ,0) OrdinanceOrLawPct ,
isnull(b.NeighborhoodCrimeWatchInd ,'~') NeighborhoodCrimeWatchInd ,
isnull(b.EmployeeCreditInd ,'~') EmployeeCreditInd ,
isnull(b.MultiPolicyInd ,'~') MultiPolicyInd ,
isnull(b.HomeWarrantyCreditInd ,'~') HomeWarrantyCreditInd ,
isnull(b.YearOccupied ,0) YearOccupied ,
isnull(b.YearPurchased ,0) YearPurchased ,
isnull(b.TypeOfStructure ,'~') TypeOfStructure ,
isnull(b.FeetToFireHydrant ,0) FeetToFireHydrant ,
isnull(b.NumberOfFamilies ,0) NumberOfFamilies ,
isnull(b.MilesFromFireStation ,0) MilesFromFireStation ,
isnull(b.Rooms ,0) Rooms ,
isnull(b.RoofPitch ,'~') RoofPitch ,
isnull(b.FireDistrict ,'~') FireDistrict ,
isnull(b.SprinklerSystem ,'~') SprinklerSystem ,
isnull(b.FireExtinguisherInd ,'~') FireExtinguisherInd ,
isnull(b.KitchenFireExtinguisherInd ,'~') KitchenFireExtinguisherInd ,
isnull(b.DeadboltInd ,'~') DeadboltInd ,
isnull(b.GatedCommunityInd ,'~') GatedCommunityInd ,
isnull(b.CentralHeatingInd ,'~') CentralHeatingInd ,
isnull(b.Foundation ,'~') Foundation ,
isnull(b.WiringRenovation ,'~') WiringRenovation ,
isnull(b.WiringRenovationCompleteYear ,'~') WiringRenovationCompleteYear ,
isnull(b.PlumbingRenovation ,'~') PlumbingRenovation ,
isnull(b.HeatingRenovation ,'~') HeatingRenovation ,
isnull(b.PlumbingRenovationCompleteYear ,'~') PlumbingRenovationCompleteYear ,
isnull(b.ExteriorPaintRenovation ,'~') ExteriorPaintRenovation ,
isnull(b.HeatingRenovationCompleteYear ,'~') HeatingRenovationCompleteYear ,
isnull(b.CircuitBreakersInd ,'~') CircuitBreakersInd ,
isnull(b.CopperWiringInd ,'~') CopperWiringInd ,
isnull(b.ExteriorPaintRenovationCompleteYear ,'~') ExteriorPaintRenovationCompleteYear ,
isnull(b.CopperPipesInd ,'~') CopperPipesInd ,
isnull(b.EarthquakeRetrofitInd ,'~') EarthquakeRetrofitInd ,
isnull(b.PrimaryFuelSource ,'~') PrimaryFuelSource ,
isnull(b.SecondaryFuelSource ,'~') SecondaryFuelSource ,
isnull(b.UsageType ,'~') UsageType ,
isnull(b.HomegardCreditInd ,'~') HomegardCreditInd ,
isnull(b.MultiPolicyNumber ,'~') MultiPolicyNumber ,
isnull(b.LocalFireAlarmInd ,'~') LocalFireAlarmInd ,
isnull(b.NumLosses ,0) NumLosses ,
isnull(b.CovALimitIncrease ,0) CovALimitIncrease ,
isnull(b.CovALimitIncluded ,0) CovALimitIncluded ,
isnull(b.MonthsRentedOut ,0) MonthsRentedOut ,
isnull(b.RoofReplacement ,'~') RoofReplacement ,
isnull(b.SafeguardPlusInd ,'~') SafeguardPlusInd ,
isnull(b.CovELimitIncluded ,0) CovELimitIncluded ,
isnull(b.RoofReplacementCompleteYear ,'~') RoofReplacementCompleteYear ,
isnull(b.CovELimitIncrease ,0) CovELimitIncrease ,
isnull(b.OwnerOccupiedUnits ,0) OwnerOccupiedUnits ,
isnull(b.TenantOccupiedUnits ,0) TenantOccupiedUnits ,
isnull(b.ReplacementCostDwellingInd ,'~') ReplacementCostDwellingInd ,
isnull(b.FeetToPropertyLine ,'~') FeetToPropertyLine ,
isnull(b.GalvanizedPipeInd ,'~') GalvanizedPipeInd ,
isnull(b.WorkersCompInservant ,0) WorkersCompInservant ,
isnull(b.WorkersCompOutservant ,0) WorkersCompOutservant ,
isnull(b.LiabilityTerritoryCd ,'~') LiabilityTerritoryCd ,
isnull(b.PremisesLiabilityMedPayInd ,'~') PremisesLiabilityMedPayInd ,
isnull(b.RelatedPrivateStructureExclusion ,'~') RelatedPrivateStructureExclusion ,
isnull(b.VandalismExclusion ,'~') VandalismExclusion ,
isnull(b.VandalismInd ,'~') VandalismInd ,
isnull(b.RoofExclusion ,'~') RoofExclusion ,
isnull(b.ExpandedReplacementCostInd ,'~') ExpandedReplacementCostInd ,
isnull(b.ReplacementValueInd ,'~') ReplacementValueInd ,
isnull(b.OtherPolicyNumber1 ,'~') OtherPolicyNumber1 ,
isnull(b.OtherPolicyNumber2 ,'~') OtherPolicyNumber2 ,
isnull(b.OtherPolicyNumber3 ,'~') OtherPolicyNumber3 ,
isnull(b.PrimaryPolicyNumber ,'~') PrimaryPolicyNumber ,
isnull(b.OtherPolicyNumbers ,'~') OtherPolicyNumbers ,
isnull(b.ReportedFireHazardScore ,'~') ReportedFireHazardScore ,
isnull(b.FireHazardScore ,'~') FireHazardScore ,
isnull(b.ReportedSteepSlopeInd ,'~') ReportedSteepSlopeInd ,
isnull(b.SteepSlopeInd ,'~') SteepSlopeInd ,
isnull(b.ReportedHomeReplacementCost ,0) ReportedHomeReplacementCost ,
isnull(b.ReportedProtectionClass ,'~') ReportedProtectionClass ,
isnull(b.EarthquakeZone ,'~') EarthquakeZone ,
isnull(b.MMIScore ,'~') MMIScore ,
isnull(b.HomeInspectionDiscountInd ,'~') HomeInspectionDiscountInd ,
isnull(b.RatingTier ,'~') RatingTier ,
isnull(b.SoilTypeCd ,'~') SoilTypeCd ,
isnull(b.ReportedFireLineAssessment ,'~') ReportedFireLineAssessment ,
isnull(b.AAISFireProtectionClass ,'~') AAISFireProtectionClass ,
isnull(b.InspectionScore ,'~') InspectionScore ,
isnull(b.AnnualRents ,0) AnnualRents ,
isnull(b.PitchOfRoof ,'~') PitchOfRoof ,
isnull(b.TotalLivingSqFt ,0) TotalLivingSqFt ,
isnull(b.ParkingSqFt ,0) ParkingSqFt ,
isnull(b.ParkingType ,'~') ParkingType ,
isnull(b.RetrofitCompleted ,'~') RetrofitCompleted ,
isnull(b.NumPools ,'~') NumPools ,
isnull(b.FullyFenced ,'~') FullyFenced ,
isnull(b.DivingBoard ,'~') DivingBoard ,
isnull(b.Gym ,'~') Gym ,
isnull(b.FreeWeights ,'~') FreeWeights ,
isnull(b.WireFencing ,'~') WireFencing ,
isnull(b.OtherRecreational ,'~') OtherRecreational ,
isnull(b.OtherRecreationalDesc ,'~') OtherRecreationalDesc ,
isnull(b.HealthInspection ,'~') HealthInspection ,
isnull(b.HealthInspectionDt ,'1900-01-01') HealthInspectionDt ,
isnull(b.HealthInspectionCited ,'~') HealthInspectionCited ,
isnull(b.PriorDefectRepairs ,'~') PriorDefectRepairs ,
isnull(b.MSBReconstructionEstimate ,'~') MSBReconstructionEstimate ,
isnull(b.BIIndemnityPeriod ,'~') BIIndemnityPeriod ,
isnull(b.EquipmentBreakdown ,'~') EquipmentBreakdown ,
isnull(b.MoneySecurityOnPremises ,'~') MoneySecurityOnPremises ,
isnull(b.MoneySecurityOffPremises ,'~') MoneySecurityOffPremises ,
isnull(b.WaterBackupSump ,'~') WaterBackupSump ,
isnull(b.SprinkleredBuildings ,'~') SprinkleredBuildings ,
isnull(b.SurveillanceCams ,'~') SurveillanceCams ,
isnull(b.GatedComplexKeyAccess ,'~') GatedComplexKeyAccess ,
isnull(b.EQRetrofit ,'~') EQRetrofit ,
isnull(b.UnitsPerBuilding ,'~') UnitsPerBuilding ,
isnull(b.NumStories ,'~') NumStories ,
isnull(b.ConstructionQuality ,'~') ConstructionQuality ,
isnull(b.BurglaryRobbery ,'~') BurglaryRobbery ,
isnull(b.NFPAClassification ,'~') NFPAClassification ,
isnull(b.AreasOfCoverage ,'~') AreasOfCoverage ,
isnull(b.CODetector ,'~') CODetector ,
isnull(b.SmokeDetector ,'~') SmokeDetector ,
isnull(b.SmokeDetectorInspectInd ,'~') SmokeDetectorInspectInd ,
isnull(b.WaterHeaterSecured ,'~') WaterHeaterSecured ,
isnull(b.BoltedOrSecured ,'~') BoltedOrSecured ,
isnull(b.SoftStoryCripple ,'~') SoftStoryCripple ,
isnull(b.SeniorHousingPct ,'~') SeniorHousingPct ,
isnull(b.DesignatedSeniorHousing ,'~') DesignatedSeniorHousing ,
isnull(b.StudentHousingPct ,'~') StudentHousingPct ,
isnull(b.DesignatedStudentHousing ,'~') DesignatedStudentHousing ,
isnull(b.PriorLosses ,0) PriorLosses ,
isnull(b.TenantEvictions ,'~') TenantEvictions ,
isnull(b.VacancyRateExceed ,'~') VacancyRateExceed ,
isnull(b.SeasonalRentals ,'~') SeasonalRentals ,
isnull(b.CondoInsuingAgmt ,'~') CondoInsuingAgmt ,
isnull(b.GasValve ,'~') GasValve ,
isnull(b.OwnerOccupiedPct ,'~') OwnerOccupiedPct ,
isnull(b.RestaurantName ,'~') RestaurantName ,
isnull(b.HoursOfOperation ,'~') HoursOfOperation ,
isnull(b.RestaurantSqFt ,0) RestaurantSqFt ,
isnull(b.SeatingCapacity ,0) SeatingCapacity ,
isnull(b.AnnualGrossSales ,0) AnnualGrossSales ,
isnull(b.SeasonalOrClosed ,'~') SeasonalOrClosed ,
isnull(b.BarCocktailLounge ,'~') BarCocktailLounge ,
isnull(b.LiveEntertainment ,'~') LiveEntertainment ,
isnull(b.BeerWineGrossSales ,'~') BeerWineGrossSales ,
isnull(b.DistilledSpiritsServed ,'~') DistilledSpiritsServed ,
isnull(b.KitchenDeepFryer ,'~') KitchenDeepFryer ,
isnull(b.SolidFuelCooking ,'~') SolidFuelCooking ,
isnull(b.ANSULSystem ,'~') ANSULSystem ,
isnull(b.ANSULAnnualInspection ,'~') ANSULAnnualInspection ,
isnull(b.TenantNamesList ,'~') TenantNamesList ,
isnull(b.TenantBusinessType ,'~') TenantBusinessType ,
isnull(b.TenantGLLiability ,'~') TenantGLLiability ,
isnull(b.InsuredOccupiedPortion ,'~') InsuredOccupiedPortion ,
isnull(b.ValetParking ,'~') ValetParking ,
isnull(b.LessorSqFt ,0) LessorSqFt ,
isnull(b.BuildingRiskNumber ,0) BuildingRiskNumber ,
isnull(b.MultiPolicyIndUmbrella ,'~') MultiPolicyIndUmbrella ,
isnull(b.PoolInd ,'~') PoolInd ,
isnull(b.StudsUpRenovation ,'~') StudsUpRenovation ,
isnull(b.StudsUpRenovationCompleteYear ,'~') StudsUpRenovationCompleteYear ,
isnull(b.MultiPolicyNumberUmbrella ,'~') MultiPolicyNumberUmbrella ,
isnull(b.RCTMSBAmt ,'~') RCTMSBAmt ,
isnull(b.RCTMSBHomeStyle ,'~') RCTMSBHomeStyle ,
isnull(b.WINSOverrideNonSmokerDiscount ,'~') WINSOverrideNonSmokerDiscount ,
isnull(b.WINSOverrideSeniorDiscount ,'~') WINSOverrideSeniorDiscount ,
isnull(b.ITV ,0) ITV ,
isnull(b.ITVDate ,'1900-01-01') ITVDate ,
isnull(b.MSBReportType ,'~') MSBReportType ,
isnull(b.VandalismDesiredInd ,'~') VandalismDesiredInd ,
isnull(b.WoodShakeSiding ,'~') WoodShakeSiding ,
isnull(b.CSEAgent ,'~') CSEAgent ,
isnull(b.PropertyManager ,'~') PropertyManager ,
isnull(b.RentersInsurance ,'~') RentersInsurance ,
isnull(b.WaterDetectionDevice ,'~') WaterDetectionDevice ,
isnull(b.AutoHomeInd ,'~') AutoHomeInd ,
isnull(b.EarthquakeUmbrellaInd ,'~') EarthquakeUmbrellaInd ,
isnull(b.LandlordInd ,'~') LandlordInd ,
isnull(l_LAC.Value ,'~') LossAssessment ,
isnull(b.GasShutOffInd ,'~') GasShutOffInd ,
isnull(b.WaterDed ,'~') WaterDed ,
isnull(b.ServiceLine ,'~') ServiceLine ,
isnull(b.FunctionalReplacementCost ,'~') FunctionalReplacementCost ,
isnull(b.MilesOfStreet ,'~') MilesOfStreet ,
isnull(b.HOAExteriorStructure ,'~') HOAExteriorStructure ,
isnull(b.RetailPortionDevelopment ,'~') RetailPortionDevelopment ,
isnull(b.LightIndustrialType ,'~') LightIndustrialType ,
isnull(b.LightIndustrialDescription ,'~') LightIndustrialDescription ,
isnull(b.PoolCoverageLimit ,0) PoolCoverageLimit ,
isnull(b.MultifamilyResidentialBuildings ,0) MultifamilyResidentialBuildings ,
isnull(b.SinglefamilyDwellings ,0) SinglefamilyDwellings ,
isnull(b.AnnualPayroll ,0) AnnualPayroll ,
isnull(b.AnnualRevenue ,0) AnnualRevenue ,
isnull(b.BedsOccupied ,'~') BedsOccupied ,
isnull(b.EmergencyLighting ,'~') EmergencyLighting ,
isnull(b.ExitSignsPosted ,'~') ExitSignsPosted ,
isnull(b.FullTimeStaff ,'~') FullTimeStaff ,
isnull(b.LicensedBeds ,'~') LicensedBeds ,
isnull(b.NumberofFireExtinguishers ,0) NumberofFireExtinguishers ,
isnull(b.OtherFireExtinguishers ,'~') OtherFireExtinguishers ,
isnull(b.OxygenTanks ,'~') OxygenTanks ,
isnull(b.PartTimeStaff ,'~') PartTimeStaff ,
isnull(b.SmokingPermitted ,'~') SmokingPermitted ,
isnull(b.StaffOnDuty ,'~') StaffOnDuty ,
isnull(b.TypeofFireExtinguishers ,'~') TypeofFireExtinguishers ,
case when c_ADDRR.FullTermAmt is null then 'No' else 'Yes' end CovADDRR_SecondaryResidence,
isnull(c_ADDRR.FullTermAmt,0) CovADDRRPrem_SecondaryResidence,
'No' HODeluxe,
isnull(a.Latitude,'0') Latitude,
isnull(a.Longitude,'0') Longitude,
isnull(b.WUIClass ,'~') WUIClass,
isnull(al.CensusBlock,'~') CensusBlock,
case
when b.WaterRiskScore is null then 0
when b.WaterRiskScore !~ ('[0-9]') then 0
else CAST(b.WaterRiskScore as int)
end WaterRiskScore,
/*---2022-03-29 CA SFG NX2 DF3; US21484---*/
isnull(b.LandlordLossPreventionServices , '~' ) LandlordLossPreventionServices ,
isnull(b.EnhancedWaterCoverage , '~' ) EnhancedWaterCoverage ,
isnull(b.LandlordProperty , '~' ) LandlordProperty ,
isnull(b.LiabilityExtendedToOthers , '~' ) LiabilityExtendedToOthers ,
isnull(b.LossOfUseExtendedTime , '~' ) LossOfUseExtendedTime ,
isnull(b.OnPremisesTheft , 0 ) OnPremisesTheft ,
isnull(b.BedBugMitigation , '~' ) BedBugMitigation ,
isnull(b.HabitabilityExclusion , '~' ) HabitabilityExclusion ,
isnull(b.WildfireHazardPotential , '~' ) WildfireHazardPotential,
/*---2022-03-29 CA SFG Homeguard for union all---*/
isnull(b.BackupOfSewersAndDrains,0) BackupOfSewersAndDrains,
isnull(b.VegetationSetbackFt,0) VegetationSetbackFt,
isnull(b.YardDebrisCoverageArea,0) YardDebrisCoverageArea,
isnull(b.YardDebrisCoveragePercentage, '~') YardDebrisCoveragePercentage,
isnull(b.CapeTrampoline, '~') CapeTrampoline,
isnull(b.CapePool, '~') CapePool,
isnull(b.RoofConditionRating, '~') RoofConditionRating,
isnull(b.TrampolineInd, '~') TrampolineInd,
isnull(b.PlumbingMaterial, '~') PlumbingMaterial,
isnull(b.CentralizedHeating, '~') CentralizedHeating,
isnull(b.FireDistrictSubscriptionCode, '~') FireDistrictSubscriptionCode,
isnull(b.RoofCondition, '~') RoofCondition
from tmp_scope s
join aurora_prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
join aurora_prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.CMMContainer=s.CMMContainer
and r.TypeCd <> 'BuildingRisk'
join aurora_prodcse_dw.building b on
b.SystemId = s.SystemId
and b.ParentId = r.Id
and b.CMMContainer = s.CMMContainer
join aurora_prodcse_dw.addr a on
a.SystemId = s.SystemId
and a.ParentId = b.Id
and a.AddrTypeCd = 'RiskAddr'
and a.CMMContainer = s.CMMContainer
left outer join aurora_prodcse_dw.Coverage c_ADDRR
on c_ADDRR.SystemId=s.SystemId
and c_ADDRR.CMMContainer=s.CMMContainer
and c_ADDRR.ParentId=r.Id
and isnull(c_ADDRR.Status,'Deleted')<>'Deleted'
and c_ADDRR.CoverageCd='ADDRR'
left outer join aurora_prodcse_dw.Coverage c_LAC
on c_LAC.SystemId=s.SystemId
and c_LAC.CMMContainer=s.CMMContainer
and c_LAC.ParentId=r.Id
and isnull(c_LAC.Status,'Deleted')<>'Deleted'
and c_LAC.CoverageCd='LAC'
left outer join aurora_prodcse_dw."limit" l_LAC
on l_LAC.SystemId=s.SystemId
and l_LAC.CMMContainer=s.CMMContainer
and l_LAC.ParentId=c_LAC.Id
and l_LAC.limitCd='Limit1'
left outer join aurora_prodcse_dw.addr al on
al.SystemId = s.SystemId
and al.ParentId = b.Id
and al.AddrTypeCd = 'RiskLookupAddr'
and al.CMMContainer = s.CMMContainer
and al.CensusBlock is not null
where
l.LineCD in ('Dwelling') and
isnull(b.ParentId,'~') not like '%Veh%'
union all
-- Homeowners 
select
'HomeOwners' LineCD,
sql_loadDate as LoadDate,
isnull(s.PolicySystemId,s.SystemId) SystemId,
isnull(s.BookDt,'1900-01-01') BookDt,
isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
isnull(s.PolicyRef,0) as policy_uniqueid,
b.Id SPINNBuilding_Id,
b.ParentId Risk_Uniqueid,
isnull(r.TypeCd,'~') Risk_Type,
cast(isnull(s.PolicySystemId,s.SystemId) as varchar)+'_'+b.ParentId+'_'+isnull(cast(b.BldgNumber as varchar),'1') building_uniqueid,
coalesce(b.Status,r.Status,'Unknown') Status,
isnull(a.StateProvCd,'~') StateProvCd,
isnull(a.County,'~') County,
isnull(a.PostalCode,'~') PostalCode,
isnull(a.City,'~') City,
isnull(a.Addr1,'~') Addr1,
isnull(a.Addr2,'~') Addr2,
isnull(b.BldgNumber ,0) BldgNumber ,
isnull(b.BusinessCategory ,'~') BusinessCategory ,
isnull(b.BusinessClass ,'~') BusinessClass ,
isnull(b.ConstructionCd ,'~') ConstructionCd ,
isnull(b.RoofCd ,'~') RoofCd ,
isnull(b.YearBuilt ,0) YearBuilt ,
isnull(b.SqFt ,0) SqFt ,
isnull(b.Stories ,0) Stories ,
isnull(b.Units ,0) Units ,
isnull(b.OccupancyCd ,'~') OccupancyCd ,
isnull(b.ProtectionClass ,'~') ProtectionClass ,
isnull(b.TerritoryCd ,'~') TerritoryCd ,
isnull(b.BuildingLimit ,0) BuildingLimit ,
isnull(b.ContentsLimit ,0) ContentsLimit ,
isnull(b.ValuationMethod ,'~') ValuationMethod ,
isnull(b.InflationGuardPct ,0) InflationGuardPct ,
isnull(b.OrdinanceOrLawInd ,'~') OrdinanceOrLawInd ,
isnull(b.ScheduledPremiumMod ,0) ScheduledPremiumMod ,
isnull(b.WindHailExclusion ,'~') WindHailExclusion ,
isnull(b.CovALimit ,0) CovALimit ,
isnull(b.CovBLimit ,0) CovBLimit ,
isnull(b.CovCLimit ,0) CovCLimit ,
isnull(b.CovDLimit ,0) CovDLimit ,
isnull(b.CovELimit ,0) CovELimit ,
isnull(b.CovFLimit ,0) CovFLimit ,
isnull(b.AllPerilDed ,'~') AllPerilDed ,
isnull(b.BurglaryAlarmType ,'~') BurglaryAlarmType ,
isnull(b.FireAlarmType ,'~') FireAlarmType ,
isnull(b.CovBLimitIncluded ,0) CovBLimitIncluded ,
isnull(b.CovBLimitIncrease ,0) CovBLimitIncrease ,
isnull(b.CovCLimitIncluded ,0) CovCLimitIncluded ,
isnull(b.CovCLimitIncrease ,0) CovCLimitIncrease ,
isnull(b.CovDLimitIncluded ,0) CovDLimitIncluded ,
isnull(b.CovDLimitIncrease ,0) CovDLimitIncrease ,
isnull(b.OrdinanceOrLawPct ,0) OrdinanceOrLawPct ,
isnull(b.NeighborhoodCrimeWatchInd ,'~') NeighborhoodCrimeWatchInd ,
isnull(b.EmployeeCreditInd ,'~') EmployeeCreditInd ,
isnull(b.MultiPolicyInd ,'~') MultiPolicyInd ,
isnull(b.HomeWarrantyCreditInd ,'~') HomeWarrantyCreditInd ,
isnull(b.YearOccupied ,0) YearOccupied ,
isnull(b.YearPurchased ,0) YearPurchased ,
isnull(b.TypeOfStructure ,'~') TypeOfStructure ,
isnull(b.FeetToFireHydrant ,0) FeetToFireHydrant ,
isnull(b.NumberOfFamilies ,0) NumberOfFamilies ,
isnull(b.MilesFromFireStation ,0) MilesFromFireStation ,
isnull(b.Rooms ,0) Rooms ,
isnull(b.RoofPitch ,'~') RoofPitch ,
isnull(b.FireDistrict ,'~') FireDistrict ,
isnull(b.SprinklerSystem ,'~') SprinklerSystem ,
isnull(b.FireExtinguisherInd ,'~') FireExtinguisherInd ,
isnull(b.KitchenFireExtinguisherInd ,'~') KitchenFireExtinguisherInd ,
isnull(b.DeadboltInd ,'~') DeadboltInd ,
isnull(b.GatedCommunityInd ,'~') GatedCommunityInd ,
isnull(b.CentralHeatingInd ,'~') CentralHeatingInd ,
isnull(b.Foundation ,'~') Foundation ,
isnull(b.WiringRenovation ,'~') WiringRenovation ,
isnull(b.WiringRenovationCompleteYear ,'~') WiringRenovationCompleteYear ,
isnull(b.PlumbingRenovation ,'~') PlumbingRenovation ,
isnull(b.HeatingRenovation ,'~') HeatingRenovation ,
isnull(b.PlumbingRenovationCompleteYear ,'~') PlumbingRenovationCompleteYear ,
isnull(b.ExteriorPaintRenovation ,'~') ExteriorPaintRenovation ,
isnull(b.HeatingRenovationCompleteYear ,'~') HeatingRenovationCompleteYear ,
isnull(b.CircuitBreakersInd ,'~') CircuitBreakersInd ,
isnull(b.CopperWiringInd ,'~') CopperWiringInd ,
isnull(b.ExteriorPaintRenovationCompleteYear ,'~') ExteriorPaintRenovationCompleteYear ,
isnull(b.CopperPipesInd ,'~') CopperPipesInd ,
isnull(b.EarthquakeRetrofitInd ,'~') EarthquakeRetrofitInd ,
isnull(b.PrimaryFuelSource ,'~') PrimaryFuelSource ,
isnull(b.SecondaryFuelSource ,'~') SecondaryFuelSource ,
isnull(b.UsageType ,'~') UsageType ,
isnull(b.HomegardCreditInd ,'~') HomegardCreditInd ,
isnull(b.MultiPolicyNumber ,'~') MultiPolicyNumber ,
isnull(b.LocalFireAlarmInd ,'~') LocalFireAlarmInd ,
isnull(b.NumLosses ,0) NumLosses ,
isnull(b.CovALimitIncrease ,0) CovALimitIncrease ,
isnull(b.CovALimitIncluded ,0) CovALimitIncluded ,
isnull(b.MonthsRentedOut ,0) MonthsRentedOut ,
isnull(b.RoofReplacement ,'~') RoofReplacement ,
isnull(b.SafeguardPlusInd ,'~') SafeguardPlusInd ,
isnull(b.CovELimitIncluded ,0) CovELimitIncluded ,
isnull(b.RoofReplacementCompleteYear ,'~') RoofReplacementCompleteYear ,
isnull(b.CovELimitIncrease ,0) CovELimitIncrease ,
isnull(b.OwnerOccupiedUnits ,0) OwnerOccupiedUnits ,
isnull(b.TenantOccupiedUnits ,0) TenantOccupiedUnits ,
isnull(b.ReplacementCostDwellingInd ,'~') ReplacementCostDwellingInd ,
isnull(b.FeetToPropertyLine ,'~') FeetToPropertyLine ,
isnull(b.GalvanizedPipeInd ,'~') GalvanizedPipeInd ,
isnull(b.WorkersCompInservant ,0) WorkersCompInservant ,
isnull(b.WorkersCompOutservant ,0) WorkersCompOutservant ,
isnull(b.LiabilityTerritoryCd ,'~') LiabilityTerritoryCd ,
isnull(b.PremisesLiabilityMedPayInd ,'~') PremisesLiabilityMedPayInd ,
isnull(b.RelatedPrivateStructureExclusion ,'~') RelatedPrivateStructureExclusion ,
isnull(b.VandalismExclusion ,'~') VandalismExclusion ,
isnull(b.VandalismInd ,'~') VandalismInd ,
isnull(b.RoofExclusion ,'~') RoofExclusion ,
isnull(b.ExpandedReplacementCostInd ,'~') ExpandedReplacementCostInd ,
isnull(b.ReplacementValueInd ,'~') ReplacementValueInd ,
isnull(b.OtherPolicyNumber1 ,'~') OtherPolicyNumber1 ,
isnull(b.OtherPolicyNumber2 ,'~') OtherPolicyNumber2 ,
isnull(b.OtherPolicyNumber3 ,'~') OtherPolicyNumber3 ,
isnull(b.PrimaryPolicyNumber ,'~') PrimaryPolicyNumber ,
isnull(b.OtherPolicyNumbers ,'~') OtherPolicyNumbers ,
isnull(b.ReportedFireHazardScore ,'~') ReportedFireHazardScore ,
isnull(b.FireHazardScore ,'~') FireHazardScore ,
isnull(b.ReportedSteepSlopeInd ,'~') ReportedSteepSlopeInd ,
isnull(b.SteepSlopeInd ,'~') SteepSlopeInd ,
isnull(b.ReportedHomeReplacementCost ,0) ReportedHomeReplacementCost ,
isnull(b.ReportedProtectionClass ,'~') ReportedProtectionClass ,
isnull(b.EarthquakeZone ,'~') EarthquakeZone ,
isnull(b.MMIScore ,'~') MMIScore ,
isnull(b.HomeInspectionDiscountInd ,'~') HomeInspectionDiscountInd ,
isnull(b.RatingTier ,'~') RatingTier ,
isnull(b.SoilTypeCd ,'~') SoilTypeCd ,
isnull(b.ReportedFireLineAssessment ,'~') ReportedFireLineAssessment ,
isnull(b.AAISFireProtectionClass ,'~') AAISFireProtectionClass ,
isnull(b.InspectionScore ,'~') InspectionScore ,
isnull(b.AnnualRents ,0) AnnualRents ,
isnull(b.PitchOfRoof ,'~') PitchOfRoof ,
isnull(b.TotalLivingSqFt ,0) TotalLivingSqFt ,
isnull(b.ParkingSqFt ,0) ParkingSqFt ,
isnull(b.ParkingType ,'~') ParkingType ,
isnull(b.RetrofitCompleted ,'~') RetrofitCompleted ,
isnull(b.NumPools ,'~') NumPools ,
isnull(b.FullyFenced ,'~') FullyFenced ,
isnull(b.DivingBoard ,'~') DivingBoard ,
isnull(b.Gym ,'~') Gym ,
isnull(b.FreeWeights ,'~') FreeWeights ,
isnull(b.WireFencing ,'~') WireFencing ,
isnull(b.OtherRecreational ,'~') OtherRecreational ,
isnull(b.OtherRecreationalDesc ,'~') OtherRecreationalDesc ,
isnull(b.HealthInspection ,'~') HealthInspection ,
isnull(b.HealthInspectionDt ,'1900-01-01') HealthInspectionDt ,
isnull(b.HealthInspectionCited ,'~') HealthInspectionCited ,
isnull(b.PriorDefectRepairs ,'~') PriorDefectRepairs ,
isnull(b.MSBReconstructionEstimate ,'~') MSBReconstructionEstimate ,
isnull(b.BIIndemnityPeriod ,'~') BIIndemnityPeriod ,
isnull(b.EquipmentBreakdown ,'~') EquipmentBreakdown ,
isnull(b.MoneySecurityOnPremises ,'~') MoneySecurityOnPremises ,
isnull(b.MoneySecurityOffPremises ,'~') MoneySecurityOffPremises ,
isnull(b.WaterBackupSump ,'~') WaterBackupSump ,
isnull(b.SprinkleredBuildings ,'~') SprinkleredBuildings ,
isnull(b.SurveillanceCams ,'~') SurveillanceCams ,
isnull(b.GatedComplexKeyAccess ,'~') GatedComplexKeyAccess ,
isnull(b.EQRetrofit ,'~') EQRetrofit ,
isnull(b.UnitsPerBuilding ,'~') UnitsPerBuilding ,
isnull(b.NumStories ,'~') NumStories ,
isnull(b.ConstructionQuality ,'~') ConstructionQuality ,
isnull(b.BurglaryRobbery ,'~') BurglaryRobbery ,
isnull(b.NFPAClassification ,'~') NFPAClassification ,
isnull(b.AreasOfCoverage ,'~') AreasOfCoverage ,
isnull(b.CODetector ,'~') CODetector ,
isnull(b.SmokeDetector ,'~') SmokeDetector ,
isnull(b.SmokeDetectorInspectInd ,'~') SmokeDetectorInspectInd ,
isnull(b.WaterHeaterSecured ,'~') WaterHeaterSecured ,
isnull(b.BoltedOrSecured ,'~') BoltedOrSecured ,
isnull(b.SoftStoryCripple ,'~') SoftStoryCripple ,
isnull(b.SeniorHousingPct ,'~') SeniorHousingPct ,
isnull(b.DesignatedSeniorHousing ,'~') DesignatedSeniorHousing ,
isnull(b.StudentHousingPct ,'~') StudentHousingPct ,
isnull(b.DesignatedStudentHousing ,'~') DesignatedStudentHousing ,
isnull(b.PriorLosses ,0) PriorLosses ,
isnull(b.TenantEvictions ,'~') TenantEvictions ,
isnull(b.VacancyRateExceed ,'~') VacancyRateExceed ,
isnull(b.SeasonalRentals ,'~') SeasonalRentals ,
isnull(b.CondoInsuingAgmt ,'~') CondoInsuingAgmt ,
isnull(b.GasValve ,'~') GasValve ,
isnull(b.OwnerOccupiedPct ,'~') OwnerOccupiedPct ,
isnull(b.RestaurantName ,'~') RestaurantName ,
isnull(b.HoursOfOperation ,'~') HoursOfOperation ,
isnull(b.RestaurantSqFt ,0) RestaurantSqFt ,
isnull(b.SeatingCapacity ,0) SeatingCapacity ,
isnull(b.AnnualGrossSales ,0) AnnualGrossSales ,
isnull(b.SeasonalOrClosed ,'~') SeasonalOrClosed ,
isnull(b.BarCocktailLounge ,'~') BarCocktailLounge ,
isnull(b.LiveEntertainment ,'~') LiveEntertainment ,
isnull(b.BeerWineGrossSales ,'~') BeerWineGrossSales ,
isnull(b.DistilledSpiritsServed ,'~') DistilledSpiritsServed ,
isnull(b.KitchenDeepFryer ,'~') KitchenDeepFryer ,
isnull(b.SolidFuelCooking ,'~') SolidFuelCooking ,
isnull(b.ANSULSystem ,'~') ANSULSystem ,
isnull(b.ANSULAnnualInspection ,'~') ANSULAnnualInspection ,
isnull(b.TenantNamesList ,'~') TenantNamesList ,
isnull(b.TenantBusinessType ,'~') TenantBusinessType ,
isnull(b.TenantGLLiability ,'~') TenantGLLiability ,
isnull(b.InsuredOccupiedPortion ,'~') InsuredOccupiedPortion ,
isnull(b.ValetParking ,'~') ValetParking ,
isnull(b.LessorSqFt ,0) LessorSqFt ,
isnull(b.BuildingRiskNumber ,0) BuildingRiskNumber ,
isnull(b.MultiPolicyIndUmbrella ,'~') MultiPolicyIndUmbrella ,
isnull(b.PoolInd ,'~') PoolInd ,
isnull(b.StudsUpRenovation ,'~') StudsUpRenovation ,
isnull(b.StudsUpRenovationCompleteYear ,'~') StudsUpRenovationCompleteYear ,
isnull(b.MultiPolicyNumberUmbrella ,'~') MultiPolicyNumberUmbrella ,
isnull(b.RCTMSBAmt ,'~') RCTMSBAmt ,
isnull(b.RCTMSBHomeStyle ,'~') RCTMSBHomeStyle ,
isnull(b.WINSOverrideNonSmokerDiscount ,'~') WINSOverrideNonSmokerDiscount ,
isnull(b.WINSOverrideSeniorDiscount ,'~') WINSOverrideSeniorDiscount ,
isnull(b.ITV ,0) ITV ,
isnull(b.ITVDate ,'1900-01-01') ITVDate ,
isnull(b.MSBReportType ,'~') MSBReportType ,
isnull(b.VandalismDesiredInd ,'~') VandalismDesiredInd ,
isnull(b.WoodShakeSiding ,'~') WoodShakeSiding ,
isnull(b.CSEAgent ,'~') CSEAgent ,
isnull(b.PropertyManager ,'~') PropertyManager ,
isnull(b.RentersInsurance ,'~') RentersInsurance ,
isnull(b.WaterDetectionDevice ,'~') WaterDetectionDevice ,
isnull(b.AutoHomeInd ,'~') AutoHomeInd ,
isnull(b.EarthquakeUmbrellaInd ,'~') EarthquakeUmbrellaInd ,
isnull(b.LandlordInd ,'~') LandlordInd ,
isnull(b.LossAssessment ,'~') LossAssessment ,
isnull(b.GasShutOffInd ,'~') GasShutOffInd ,
isnull(b.WaterDed ,'~') WaterDed ,
isnull(b.ServiceLine ,'~') ServiceLine ,
isnull(b.FunctionalReplacementCost ,'~') FunctionalReplacementCost ,
isnull(b.MilesOfStreet ,'~') MilesOfStreet ,
isnull(b.HOAExteriorStructure ,'~') HOAExteriorStructure ,
isnull(b.RetailPortionDevelopment ,'~') RetailPortionDevelopment ,
isnull(b.LightIndustrialType ,'~') LightIndustrialType ,
isnull(b.LightIndustrialDescription ,'~') LightIndustrialDescription ,
isnull(b.PoolCoverageLimit ,0) PoolCoverageLimit ,
isnull(b.MultifamilyResidentialBuildings ,0) MultifamilyResidentialBuildings ,
isnull(b.SinglefamilyDwellings ,0) SinglefamilyDwellings ,
isnull(b.AnnualPayroll ,0) AnnualPayroll ,
isnull(b.AnnualRevenue ,0) AnnualRevenue ,
isnull(b.BedsOccupied ,'~') BedsOccupied ,
isnull(b.EmergencyLighting ,'~') EmergencyLighting ,
isnull(b.ExitSignsPosted ,'~') ExitSignsPosted ,
isnull(b.FullTimeStaff ,'~') FullTimeStaff ,
isnull(b.LicensedBeds ,'~') LicensedBeds ,
isnull(b.NumberofFireExtinguishers ,0) NumberofFireExtinguishers ,
isnull(b.OtherFireExtinguishers ,'~') OtherFireExtinguishers ,
isnull(b.OxygenTanks ,'~') OxygenTanks ,
isnull(b.PartTimeStaff ,'~') PartTimeStaff ,
isnull(b.SmokingPermitted ,'~') SmokingPermitted ,
isnull(b.StaffOnDuty ,'~') StaffOnDuty ,
isnull(b.TypeofFireExtinguishers ,'~') TypeofFireExtinguishers ,
case when c_ADDRR.FullTermAmt is null then 'No' else 'Yes' end CovADDRR_SecondaryResidence,
isnull(c_ADDRR.FullTermAmt,0) CovADDRRPrem_SecondaryResidence,
case when c_F31025.FullTermAmt is null then 'No' else 'Yes' end HODeluxe,
isnull(a.Latitude,'0') Latitude,
isnull(a.Longitude,'0') Longitude,
isnull(b.WUIClass ,'~') WUIClass,
isnull(al.CensusBlock,'~') CensusBlock,
case
when b.WaterRiskScore is null then 0
when b.WaterRiskScore !~ ('[0-9]') then 0
else CAST(b.WaterRiskScore as int)
end WaterRiskScore,
/*---2022-03-29 CA SFG NX2 DF3; US21484 for union all ---*/
isnull(b.LandlordLossPreventionServices , '~' ) LandlordLossPreventionServices ,
isnull(b.EnhancedWaterCoverage , '~' ) EnhancedWaterCoverage ,
isnull(b.LandlordProperty , '~' ) LandlordProperty ,
isnull(b.LiabilityExtendedToOthers , '~' ) LiabilityExtendedToOthers ,
isnull(b.LossOfUseExtendedTime , '~' ) LossOfUseExtendedTime ,
isnull(b.OnPremisesTheft , 0 ) OnPremisesTheft ,
isnull(b.BedBugMitigation , '~' ) BedBugMitigation ,
isnull(b.HabitabilityExclusion , '~' ) HabitabilityExclusion ,
isnull(b.WildfireHazardPotential , '~' ) WildfireHazardPotential,
/*---2022-03-29 CA SFG Homeguard ---*/
isnull(b.BackupOfSewersAndDrains,0) BackupOfSewersAndDrains,
isnull(b.VegetationSetbackFt,0) VegetationSetbackFt,
isnull(b.YardDebrisCoverageArea,0) YardDebrisCoverageArea,
isnull(b.YardDebrisCoveragePercentage, '~') YardDebrisCoveragePercentage,
isnull(b.CapeTrampoline, '~') CapeTrampoline,
isnull(b.CapePool, '~') CapePool,
isnull(b.RoofConditionRating, '~') RoofConditionRating,
isnull(b.TrampolineInd, '~') TrampolineInd,
isnull(b.PlumbingMaterial, '~') PlumbingMaterial,
isnull(b.CentralizedHeating, '~') CentralizedHeating,
isnull(b.FireDistrictSubscriptionCode, '~') FireDistrictSubscriptionCode,
isnull(b.RoofCondition, '~') RoofCondition
from
tmp_scope s
join aurora_prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
join aurora_prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.CMMContainer=s.CMMContainer
and r.TypeCd <> 'BuildingRisk'
join aurora_prodcse_dw.building b on
b.SystemId = s.SystemId
and b.ParentId = r.Id
and b.CMMContainer = s.CMMContainer
join aurora_prodcse_dw.addr a on
a.SystemId = s.SystemId
and a.ParentId = b.Id
and a.AddrTypeCd = 'RiskAddr'
and a.CMMContainer = s.CMMContainer
left outer join aurora_prodcse_dw.Coverage c_ADDRR
on c_ADDRR.SystemId=s.SystemId
and c_ADDRR.CMMContainer=s.CMMContainer
and c_ADDRR.ParentId=r.Id
and isnull(c_ADDRR.Status,'Deleted')<>'Deleted'
and c_ADDRR.CoverageCd='ADDRR'
left outer join aurora_prodcse_dw.Coverage c_F31025
on c_F31025.SystemId=s.SystemId
and c_F31025.CMMContainer=s.CMMContainer
and c_F31025.ParentId=r.Id
and isnull(c_F31025.Status,'Deleted')<>'Deleted'
and c_F31025.CoverageCd='F.31025'
left outer join aurora_prodcse_dw.addr al on
al.SystemId = s.SystemId
and al.ParentId = b.Id
and al.AddrTypeCd = 'RiskLookupAddr'
and al.CMMContainer = s.CMMContainer
and al.CensusBlock is not null
where
l.LineCD in ('Homeowners') and
isnull(b.ParentId,'~') not like '%Veh%'
;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_vehicle(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

truncate table kdlab.stg_vehicle;
insert into kdlab.stg_vehicle
select
sql_loadDate as LoadDate
, isnull(s.PolicySystemId,s.SystemId) SystemId
, isnull(s.BookDt,'1900-01-01') BookDt
, isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, isnull(s.PolicyRef,0) as policy_uniqueid
, v.Id SPInnVehicle_Id
, v.ParentId Risk_Uniqueid
, isnull(r.TypeCd,'~') Risk_Type
, cast(isnull(s.PolicySystemId,s.SystemId) as varchar)+'_'+v.Id+'_'+isnull(vehidentificationnumber,'Unknown') vehicle_uniqueid
, coalesce(r.Status,v.Status,'Unknown') Status
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.StateProvCd else a.StateProvCd end,'~') StateProvCd
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.County else a.County end,'~') County
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.PostalCode else a.PostalCode end,'~') PostalCode
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.City else a.City end,'~') City
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Addr1
else case when rtrim(isnull(a.PrimaryNumber,'')+' '+isnull(a.PreDirectional,'')+' '+isnull(a.StreetName,'')+' '+isnull(a.Suffix,''))='' then null
else rtrim(isnull(a.PrimaryNumber,'')+' '+isnull(a.PreDirectional,'')+' '+isnull(a.StreetName,'')+' '+isnull(a.Suffix,'')) end
end,'~') Addr1
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Addr2 else a.Addr2 end,'~') Addr2
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Latitude else a.Latitude end,'0') Latitude
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Longitude else a.Longitude end,'0') Longitude
, isnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then 'Yes' else 'No' end,'~') GaragAddrFlg
, coalesce( ga.PostalCode, a.PostalCode, '~') GaragPostalCode
, isnull(case when ga.PostalCode is not null then 'Yes' else 'No' end,'~') GaragPostalCodeFlg
, isnull( replace(replace(replace(v.Manufacturer,'"',''),'\r\n',' '),'\n',' ') , '~' ) as Manufacturer
, isnull( replace(replace(replace(v.Model,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as Model
, isnull( replace(replace(replace(v.ModelYr,'"',''),'\r\n',' '),'\n',' ') , '~' ) as ModelYr
, isnull( replace(replace(replace(v.VehIdentificationNumber,'"',''),'\r\n',' '),'\n',' ') , '~' ) as VehIdentificationNumber
, isnull( replace(replace(replace(v.ValidVinInd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as ValidVinInd
, isnull( replace(replace(replace(v.VehLicenseNumber,'"','') ,'\r\n',' '),'\n',' '), '~' ) as VehLicenseNumber
, isnull( replace(replace(replace(v.RegistrationStateProvCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RegistrationStateProvCd
, isnull( replace(replace(replace(v.VehBodyTypeCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as VehBodyTypeCd
, isnull( replace(replace(replace(v.PerformanceCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as PerformanceCd
, isnull( replace(replace(replace(v.RestraintCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RestraintCd
, isnull( replace(replace(replace(v.AntiBrakingSystemCd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as AntiBrakingSystemCd
, isnull( replace(replace(replace(v.AntiTheftCd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as AntiTheftCd
, isnull( replace(replace(replace(v.EngineSize,'"',''),'\r\n',' '),'\n',' ') , '~' ) as EngineSize
, isnull( replace(replace(replace(v.EngineCylinders,'"','') ,'\r\n',' '),'\n',' '), '~' ) as EngineCylinders
, isnull( replace(replace(replace(v.EngineHorsePower,'"',''),'\r\n',' '),'\n',' ') , '~' ) as EngineHorsePower
, isnull( replace(replace(replace(v.EngineType,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as EngineType
, isnull( replace(replace(replace(v.VehUseCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as VehUseCd
, isnull( v.GarageTerritory, 0 ) as GarageTerritory
, isnull( replace(replace(replace(v.CollisionDed,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CollisionDed
, isnull( replace(replace(replace(v.ComprehensiveDed,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as ComprehensiveDed
, isnull( v.StatedAmt, 0 ) as StatedAmt
, isnull( replace(replace(replace(v.ClassCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as ClassCd
, isnull( replace(replace(replace(v.RatingValue,'"',''),'\r\n',' '),'\n',' ') , '~' ) as RatingValue
, isnull( v.CostNewAmt, 0 ) as CostNewAmt
, isnull( v.EstimatedAnnualDistance, 0 ) as EstimatedAnnualDistance
, isnull( v.EstimatedWorkDistance, 0 ) as EstimatedWorkDistance
, isnull( replace(replace(replace(v.LeasedVehInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as LeasedVehInd
, CASE WHEN isnull(PurchaseDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(PurchaseDt,to_date('1900-01-01', 'yyyy-mm-dd')) end PurchaseDt
, isnull( replace(replace(replace(v.StatedAmtInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as StatedAmtInd
, isnull( replace(replace(replace(v.NewOrUsedInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as NewOrUsedInd
, isnull( replace(replace(replace(v.CarPoolInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as CarPoolInd
, isnull( replace(replace(replace(v.OdometerReading,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as OdometerReading
, isnull( replace(replace(replace(v.WeeksPerMonthDriven,'"',''),'\r\n',' '),'\n',' ') , '~' ) as WeeksPerMonthDriven
, isnull( replace(replace(replace(v.DaylightRunningLightsInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as DaylightRunningLightsInd
, isnull( replace(replace(replace(v.PassiveSeatBeltInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as PassiveSeatBeltInd
, isnull( replace(replace(replace(v.DaysPerWeekDriven,'"','') ,'\r\n',' '),'\n',' '), '~' ) as DaysPerWeekDriven
, isnull( replace(replace(replace(v.UMPDLimit,'"','') ,'\r\n',' '),'\n',' '), '~' ) as UMPDLimit
, isnull( replace(replace(replace(v.TowingAndLaborInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as TowingAndLaborInd
, isnull( replace(replace(replace(v.RentalReimbursementInd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as RentalReimbursementInd
, isnull( replace(replace(replace(v.LiabilityWaiveInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as LiabilityWaiveInd
, isnull( replace(replace(replace(v.RateFeesInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RateFeesInd
, isnull( v.OptionalEquipmentValue, 0 ) as OptionalEquipmentValue
, isnull( replace(replace(replace(v.CustomizingEquipmentInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CustomizingEquipmentInd
, isnull( replace(replace(replace(v.CustomizingEquipmentDesc,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CustomizingEquipmentDesc
, isnull( replace(replace(replace(v.InvalidVinAcknowledgementInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as InvalidVinAcknowledgementInd
, isnull( replace(replace(replace(v.IgnoreUMPDWCDInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as IgnoreUMPDWCDInd
, isnull( replace(replace(replace(v.RecalculateRatingSymbolInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RecalculateRatingSymbolInd
, isnull( replace(replace(replace(v.ProgramTypeCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as ProgramTypeCd
, isnull( replace(replace(replace(v.CMPRatingValue,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CMPRatingValue
, isnull( replace(replace(replace(v.COLRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as COLRatingValue
, isnull( replace(replace(replace(v.LiabilityRatingValue,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as LiabilityRatingValue
, isnull( replace(replace(replace(v.MedPayRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as MedPayRatingValue
, isnull( replace(replace(replace(v.RACMPRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RACMPRatingValue
, isnull( replace(replace(replace(v.RACOLRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RACOLRatingValue
, isnull( replace(replace(replace(v.RABIRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RABIRatingSymbol
, isnull( replace(replace(replace(v.RAPDRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RAPDRatingSymbol
, isnull( replace(replace(replace(v.RAMedPayRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RAMedPayRatingSymbol
, isnull( v.EstimatedAnnualDistanceOverride,'0') as EstimatedAnnualDistanceOverride
, isnull( v.OriginalEstimatedAnnualMiles,'0') as OriginalEstimatedAnnualMiles
, isnull( v.ReportedMileageNonSave,'0') as ReportedMileageNonSave
, isnull( replace(replace(replace(v.Mileage,'"',''),'\r\n',' '),'\n',' '), '~') as Mileage
, isnull( v.EstimatedNonCommuteMiles,'0') as EstimatedNonCommuteMiles
, isnull( replace(replace(replace(v.TitleHistoryIssue,'"',''),'\r\n',' '),'\n',' '), '~') as TitleHistoryIssue
, isnull( replace(replace(replace(v.OdometerProblems,'"',''),'\r\n',' '),'\n',' '), '~') as OdometerProblems
, isnull( replace(replace(replace(v.Bundle,'"',''),'\r\n',' '),'\n',' '), '~') as Bundle
, isnull( replace(replace(replace(v.LoanLeaseGap,'"',''),'\r\n',' '),'\n',' '), '~') as LoanLeaseGap
, isnull( replace(replace(replace(v.EquivalentReplacementCost,'"',''),'\r\n',' '),'\n',' '), '~') as EquivalentReplacementCost
, isnull( replace(replace(replace(v.OriginalEquipmentManufacturer,'"',''),'\r\n',' '),'\n',' '), '~') as OriginalEquipmentManufacturer
, isnull( replace(replace(replace(v.OptionalRideshare,'"',''),'\r\n',' '),'\n',' '), '~') as OptionalRideshare
, isnull( replace(replace(replace(v.MedicalPartsAccessibility,'"',''),'\r\n',' '),'\n',' '), '~') as MedicalPartsAccessibility
, isnull( v.VehNumber, 0 ) as VehNumber
, isnull( replace(replace(replace(OdometerReadingPrior,'"',''),'\r\n',' '),'\n',' '), '~') as OdometerReadingPrior
, CASE WHEN isnull(ReportedMileageNonSaveDtPrior,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(ReportedMileageNonSaveDtPrior,to_date('1900-01-01', 'yyyy-mm-dd')) end ReportedMileageNonSaveDtPrior
, isnull( replace(replace(replace(FullGlassCovInd,'"',''),'\r\n',' '),'\n',' '), '~') as FullGlassCovInd
, isnull( replace(replace(replace(BoatLengthFeet,'"',''),'\r\n',' '),'\n',' '), '~') BoatLengthFeet
, isnull( replace(replace(replace(MotorHorsePower,'"',''),'\r\n',' '),'\n',' '), '~') MotorHorsePower
, isnull(replacementof ,0) replacementof
, CASE WHEN isnull(ReportedMileageNonSaveDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(ReportedMileageNonSaveDt,to_date('1900-01-01', 'yyyy-mm-dd')) end ReportedMileageNonSaveDt
, isnull( replace(replace(replace(v.ManufacturerSymbol,'"',''),'\r\n',' '),'\n',' '), '~') ManufacturerSymbol
, isnull( replace(replace(replace(v.ModelSymbol,'"',''),'\r\n',' '),'\n',' '), '~') ModelSymbol
, isnull( replace(replace(replace(v.BodyStyleSymbol,'"',''),'\r\n',' '),'\n',' '), '~') BodyStyleSymbol
, isnull( replace(replace(replace(v.SymbolCode,'"',''),'\r\n',' '),'\n',' '), '~') SymbolCode
, isnull( replace(replace(replace(v.VerifiedMileageOverride,'"',''),'\r\n',' '),'\n',' '), '~') VerifiedMileageOverride
from tmp_scope s
--
join aurora_prodcse_dw.Vehicle v
on v.SystemId=s.SystemId
and v.CMMContainer=s.CMMContainer
--
join aurora_prodcse_dw.Risk r
on r.SystemId=s.SystemId
and v.ParentId=r.Id
and r.CMMContainer=s.CMMContainer
--
join aurora_prodcse_dw.Addr a
on a.SystemId=s.SystemId
and a.cmmContainer=s.CMMContainer
and a.AddrTypeCd='InsuredLookupAddr'
--
left outer join aurora_prodcse_dw.Addr ga
on ga.SystemId=s.SystemId
and ga.cmmContainer=s.CMMContainer
and ga.AddrTypeCd='VehicleGarageAddr'
and ga.ParentId=v.Id
where r.TypeCd='PrivatePassengerAuto'
;


END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_driver(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;



--Driver points
drop table if exists tmp_DriverPoints;
create temporary table tmp_DriverPoints as
select dp.SystemId
,dp.Parentid
-- 
,sum(case when TypeCD='VIOL' and dp.ExpirationDt>=bp.EffectiveDt then dp.PointsCharged else 0 end) VIOL_PointsChargedTerm
,sum(case when TypeCD='ACCI' and dp.ExpirationDt>=bp.EffectiveDt then dp.PointsCharged else 0 end) ACCI_PointsChargedTerm
,sum(case when TypeCD='SUSP' and dp.ExpirationDt>=bp.EffectiveDt then dp.PointsCharged else 0 end) SUSP_PointsChargedTerm
,sum(case when TypeCD not in ('VIOL','ACCI','SUSP') and dp.ExpirationDt>=bp.EffectiveDt then dp.PointsCharged else 0 end) Other_PointsChargedTerm
-- 
,sum(case when dp.ExpirationDt>=bp.EffectiveDt then dp.GoodDriverPoints else 0 end) GoodDriverPoints_chargedterm
from
tmp_scope s
join aurora_prodcse_dw.DriverPoints dp
on s.SystemId=dp.SystemId
and s.CMMContainer=dp.CMMContainer
-- 
join aurora_prodcse_dw.BasicPolicy bp
on s.SystemId=bp.SystemId
and s.CMMContainer=bp.CMMContainer
--
join aurora_prodcse_dw.DriverInfo di
on s.SystemId=di.SystemId
and s.CMMContainer=di.CMMContainer
and di.Id=dp.ParentId
where dp.Status='Active'
and isnull(dp.IgnoreInd,'No')='No'
group by
dp.SystemId
,dp.Parentid;


truncate table kdlab.stg_driver;
insert into kdlab.stg_driver
select
sql_loadDate as LoadDate,
isnull(s.PolicySystemId,s.SystemId) SystemId,
isnull(s.BookDt,'1900-01-01') BookDt,
isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
isnull(s.PolicyRef,0) as policy_uniqueid,
di.ParentId SPINNDriver_Id ,
case
when upper(di.ParentId) like '%EXCL%' then
cast(isnull(s.PolicySystemId,s.SystemId) as varchar)+'_'+di.ParentId+'_'+isnull( parti.Status,'Deleted')+'_'+cast(isnull(di.drivernumber,0) as varchar)+'_'+to_char(isnull(di.licensedt,to_date('1900-01-01','yyyy-mm-dd')),'yyyy-mm-dd')+'_'+to_char(isnull(birthdt,to_date('1900-01-01','yyyy-mm-dd')),'yyyy-mm-dd')
else
cast(isnull(s.PolicySystemId,s.SystemId) as varchar)+'_'+di.ParentId+'_'+isnull(di.licensenumber,'Unknown')
end Driver_UniqueId,
isnull( parti.Status,'Deleted') Status,
isnull(NI.GivenName,'~') FirstName ,
isnull(NI.Surname,'~') LastName ,
isnull( di.LicenseNumber , 'Unknown' ) LicenseNumber ,
CASE WHEN isnull(di.LicenseDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.LicenseDt, to_date('1900-01-01', 'yyyy-mm-dd')) end LicenseDt ,
isnull( di.DriverInfoCd , '~' ) DriverInfoCd ,
isnull( di.DriverNumber , 0 ) DriverNumber ,
case when parti.PartyTypeCd = 'NonDriverParty' then isnull( di.DriverTypeCd , '~' ) else '~' end DriverTypeCd ,
isnull( di.DriverStatusCd , '~' ) DriverStatusCd , isnull( di.LicensedStateProvCd , '~' ) LicensedStateProvCd ,
isnull( di.RelationshipToInsuredCd , '~' ) RelationshipToInsuredCd ,
isnull( di.ScholasticDiscountInd , '~' ) ScholasticDiscountInd ,
isnull( di.MVRRequestInd , '~' ) MVRRequestInd ,
CASE WHEN isnull(di.MVRStatusDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.MVRStatusDt, to_date('1900-01-01', 'yyyy-mm-dd')) end MVRStatusDt ,
isnull( di.MVRStatus , '~' ) MVRStatus ,
isnull( di.MatureDriverInd , '~' ) MatureDriverInd ,
isnull( di.DriverTrainingInd , '~' ) DriverTrainingInd ,
isnull( di.GoodDriverInd , '~' ) GoodDriverInd ,
CASE WHEN isnull(di.AccidentPreventionCourseCompletionDt, to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.AccidentPreventionCourseCompletionDt,to_date('1900-01-01', 'yyyy-mm-dd')) end AccidentPreventionCourseCompletionDt ,
CASE WHEN isnull(di.DriverTrainingCompletionDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.DriverTrainingCompletionDt,to_date('1900-01-01', 'yyyy-mm-dd')) end DriverTrainingCompletionDt ,
isnull( di.AccidentPreventionCourseInd , '~' ) AccidentPreventionCourseInd ,
CASE WHEN isnull(di.ScholasticCertificationDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.ScholasticCertificationDt,to_date('1900-01-01', 'yyyy-mm-dd')) end ScholasticCertificationDt ,
isnull( di.ActiveMilitaryInd , '~' ) ActiveMilitaryInd ,
isnull( di.PermanentLicenseInd , '~' ) PermanentLicenseInd ,
isnull( di.NewToStateInd , '~' ) NewToStateInd ,
isnull( persi.PersonTypeCd , '~' ) PersonTypeCd ,
isnull( persi.GenderCd , '~' ) GenderCd ,
CASE WHEN isnull(BirthDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(BirthDt,to_date('1900-01-01', 'yyyy-mm-dd')) end BirthDt ,
isnull( persi.MaritalStatusCd , '~' ) MaritalStatusCd ,
isnull( persi.OccupationClassCd , '~' ) OccupationClassCd ,
isnull( persi.PositionTitle , '~' ) PositionTitle ,
isnull( persi.CurrentResidenceCd , '~' ) CurrentResidenceCd ,
isnull( persi.CivilServantInd , '~' ) CivilServantInd ,
isnull( persi.RetiredInd , '~' ) RetiredInd ,
CASE WHEN isnull(di.NewTeenExpirationDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.NewTeenExpirationDt,to_date('1900-01-01', 'yyyy-mm-dd')) end NewTeenExpirationDt ,
isnull(SR22FeeInd, '~' ) SR22FeeInd ,
CASE WHEN isnull(di.MatureCertificationDt,to_date('1900-01-01', 'yyyy-mm-dd'))<to_date('1900-01-01', 'yyyy-mm-dd') THEN to_date('1900-01-01', 'yyyy-mm-dd') ELSE isnull(di.MatureCertificationDt,to_date('1900-01-01', 'yyyy-mm-dd')) end MatureCertificationDt ,
case
when AgeFirstLicensed is null then 0
when AgeFirstLicensed ~ ('[^.0-9\-]') then cast(public.removenotnumeric(AgeFirstLicensed) as int)
else cast(AgeFirstLicensed as int)
end AgeFirstLicensed,
cse_bi.ifempty(AttachedVehicleRef, '~' ) AttachedVehicleRef
-- 
,isnull(VIOL_PointsChargedTerm,0) VIOL_PointsChargedTerm
,isnull(ACCI_PointsChargedTerm,0) ACCI_PointsChargedTerm
,isnull(SUSP_PointsChargedTerm,0) SUSP_PointsChargedTerm
,isnull(Other_PointsChargedTerm,0) Other_PointsChargedTerm
,isnull(GoodDriverPoints_chargedterm,0) GoodDriverPoints_chargedterm
-- 
from
tmp_scope s
join aurora_prodcse_dw.DriverInfo di
on di.SystemId=s.SystemId
and di.CMMContainer=s.CMMContainer
left outer join aurora_prodcse_dw.PartyInfo parti
on parti.SystemId=s.SystemId
and parti.CMMContainer=s.CMMContainer
and di.ParentId = parti.id
and parti.PartyTypeCd in ('DriverParty','NonDriverParty' )
left outer join aurora_prodcse_dw.NameInfo as NI
on NI.SystemId = s.Systemid
and NI.CMMContainer = s.CMMContainer
and NI.ParentId = parti.id
and NI.NameTypeCd = 'ContactName'
left outer join aurora_prodcse_dw.PersonInfo persi
on persi.SystemId=s.SystemId
and persi.CMMContainer=s.CMMContainer
and persi.PersonTypeCD='ContactPersonal'
and persi.ParentId = di.ParentId
left outer join tmp_DriverPoints dp
on dp.SystemId=s.SystemId
and dp.ParentId=di.Id
;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_risk_coverage(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

drop table if exists tmp_coverage;
create temporary table tmp_coverage as
select
isnull(s.PolicySystemId,s.SystemId) SystemId
,isnull(s.BookDt,'1900-01-01') BookDt
,isnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
,isnull(s.PolicyRef,0) as policy_uniqueid
,c.ParentId Risk_Uniqueid
,c.CoverageCd
,cm.covx_code
,cm.covx_description
,isnull(c.FullTermAmt,0) FullTermAmt
,isnull(l1.Value,'0') Limit1
,isnull(l2.Value,'0') Limit2
,isnull(d1.Value,'0') Deductible1
,isnull(d2.Value,'0') Deductible2
from aurora_prodcse_dw.Coverage c
join tmp_scope s
on s.SystemId=c.SystemId
and s.cmmContainer=c.cmmContainer
join aurora_prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
left outer join aurora_prodcse_dw.limit l1
on c.SystemId=l1.SystemId
and c.cmmContainer=l1.cmmContainer
and c.Id=l1.ParentId
and l1.LimitCd='Limit1'
left outer join aurora_prodcse_dw.limit l2
on c.SystemId=l2.SystemId
and c.cmmContainer=l2.cmmContainer
and c.Id=l2.ParentId
and l2.LimitCd='Limit2'
left outer join aurora_prodcse_dw.Deductible d1
on c.SystemId=d1.SystemId
and c.cmmContainer=d1.cmmContainer
and c.Id=d1.ParentId
and d1.DeductibleCd='Deductible1'
left outer join aurora_prodcse_dw.Deductible d2
on c.SystemId=d2.SystemId
and c.cmmContainer=d2.cmmContainer
and c.Id=d2.ParentId
and d2.DeductibleCd='Deductible2'
join kdlab.coverage_mapping cm
on c.CoverageCd=cm.CoverageCd
where c.Status='Active'
and l.LineCD in ('Dwelling','Homeowners')
;

truncate table kdlab.stg_risk_coverage;

insert into kdlab.stg_risk_coverage
select
sql_loadDate as LoadDate,
SystemId,
BookDt,
TransactionEffectiveDt,
policy_uniqueid,
Risk_uniqueid,
max(case when covx_code='CovA' then cast(Limit1 as float) else 0.0 end) as CovA_Limit1,
max(case when covx_code='CovA' then cast(Limit2 as float) else 0.0 end) as CovA_Limit2,
max(case when covx_code='CovA' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as CovA_Deductible1,
max(case when covx_code='CovA' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as CovA_Deductible2,
max(case when covx_code='CovA' then FullTermAmt else 0.0 end) as CovA_FullTermAmt,
max(case when covx_code='CovB' then cast(Limit1 as float) else 0.0 end) as CovB_Limit1,
max(case when covx_code='CovB' then cast(Limit2 as float) else 0.0 end) as CovB_Limit2,
max(case when covx_code='CovB' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as CovB_Deductible1,
max(case when covx_code='CovB' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as CovB_Deductible2,
max(case when covx_code='CovB' then FullTermAmt else 0.0 end) as CovB_FullTermAmt,
max(case when covx_code='CovC' then cast(Limit1 as float) else 0.0 end) as CovC_Limit1,
max(case when covx_code='CovC' then cast(Limit2 as float) else 0.0 end) as CovC_Limit2,
max(case when covx_code='CovC' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as CovC_Deductible1,
max(case when covx_code='CovC' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as CovC_Deductible2,
max(case when covx_code='CovC' then FullTermAmt else 0.0 end) as CovC_FullTermAmt,
max(case when covx_code='CovD' then cast(Limit1 as float) else 0.0 end) as CovD_Limit1,
max(case when covx_code='CovD' then cast(Limit2 as float) else 0.0 end) as CovD_Limit2,
max(case when covx_code='CovD' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as CovD_Deductible1,
max(case when covx_code='CovD' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as CovD_Deductible2,
max(case when covx_code='CovD' then FullTermAmt else 0.0 end) as CovD_FullTermAmt,
max(case when covx_code='CovE' then cast(Limit1 as float) else 0.0 end) as CovE_Limit1,
max(case when covx_code='CovE' then cast(Limit2 as float) else 0.0 end) as CovE_Limit2,
max(case when covx_code='CovE' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as CovE_Deductible1,
max(case when covx_code='CovE' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as CovE_Deductible2,
max(case when covx_code='CovE' then FullTermAmt else 0.0 end) as CovE_FullTermAmt,
max(case when covx_code='BEDBUG' then cast(Limit1 as float) else 0.0 end) as BEDBUG_Limit1,
max(case when covx_code='BEDBUG' then cast(Limit2 as float) else 0.0 end) as BEDBUG_Limit2,
max(case when covx_code='BEDBUG' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as BEDBUG_Deductible1,
max(case when covx_code='BEDBUG' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as BEDBUG_Deductible2,
max(case when covx_code='BEDBUG' then FullTermAmt else 0.0 end) as BEDBUG_FullTermAmt,
max(case when covx_code='BOLAW' then cast(Limit1 as float) else 0.0 end) as BOLAW_Limit1,
max(case when covx_code='BOLAW' then cast(Limit2 as float) else 0.0 end) as BOLAW_Limit2,
max(case when covx_code='BOLAW' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as BOLAW_Deductible1,
max(case when covx_code='BOLAW' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as BOLAW_Deductible2,
max(case when covx_code='BOLAW' then FullTermAmt else 0.0 end) as BOLAW_FullTermAmt,
max(case when covx_code='COC' then cast(Limit1 as float) else 0.0 end) as COC_Limit1,
max(case when covx_code='COC' then cast(Limit2 as float) else 0.0 end) as COC_Limit2,
max(case when covx_code='COC' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as COC_Deductible1,
max(case when covx_code='COC' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as COC_Deductible2,
max(case when covx_code='COC' then FullTermAmt else 0.0 end) as COC_FullTermAmt,
max(case when covx_code='EQPBK' then cast(Limit1 as float) else 0.0 end) as EQPBK_Limit1,
max(case when covx_code='EQPBK' then cast(Limit2 as float) else 0.0 end) as EQPBK_Limit2,
max(case when covx_code='EQPBK' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as EQPBK_Deductible1,
max(case when covx_code='EQPBK' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as EQPBK_Deductible2,
max(case when covx_code='EQPBK' then FullTermAmt else 0.0 end) as EQPBK_FullTermAmt,
max(case when covx_code='FRAUD' then cast(Limit1 as float) else 0.0 end) as FRAUD_Limit1,
max(case when covx_code='FRAUD' then cast(Limit2 as float) else 0.0 end) as FRAUD_Limit2,
max(case when covx_code='FRAUD' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as FRAUD_Deductible1,
max(case when covx_code='FRAUD' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as FRAUD_Deductible2,
max(case when covx_code='FRAUD' then FullTermAmt else 0.0 end) as FRAUD_FullTermAmt,
max(case when covx_code='H051ST0' then cast(Limit1 as float) else 0.0 end) as H051ST0_Limit1,
max(case when covx_code='H051ST0' then cast(Limit2 as float) else 0.0 end) as H051ST0_Limit2,
max(case when covx_code='H051ST0' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as H051ST0_Deductible1,
max(case when covx_code='H051ST0' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as H051ST0_Deductible2,
max(case when covx_code='H051ST0' then FullTermAmt else 0.0 end) as H051ST0_FullTermAmt,
max(case when covx_code='HO5' then cast(Limit1 as float) else 0.0 end) as HO5_Limit1,
max(case when covx_code='HO5' then cast(Limit2 as float) else 0.0 end) as HO5_Limit2,
max(case when covx_code='HO5' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as HO5_Deductible1,
max(case when covx_code='HO5' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as HO5_Deductible2,
max(case when covx_code='HO5' then FullTermAmt else 0.0 end) as HO5_FullTermAmt,
max(case when covx_code='INCB' then cast(Limit1 as float) else 0.0 end) as INCB_Limit1,
max(case when covx_code='INCB' then cast(Limit2 as float) else 0.0 end) as INCB_Limit2,
max(case when covx_code='INCB' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as INCB_Deductible1,
max(case when covx_code='INCB' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as INCB_Deductible2,
max(case when covx_code='INCB' then FullTermAmt else 0.0 end) as INCB_FullTermAmt,
max(case when covx_code='INCC' then cast(Limit1 as float) else 0.0 end) as INCC_Limit1,
max(case when covx_code='INCC' then cast(Limit2 as float) else 0.0 end) as INCC_Limit2,
max(case when covx_code='INCC' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as INCC_Deductible1,
max(case when covx_code='INCC' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as INCC_Deductible2,
max(case when covx_code='INCC' then FullTermAmt else 0.0 end) as INCC_FullTermAmt,
max(case when covx_code='LAC' then cast(Limit1 as float) else 0.0 end) as LAC_Limit1,
max(case when covx_code='LAC' then cast(Limit2 as float) else 0.0 end) as LAC_Limit2,
max(case when covx_code='LAC' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as LAC_Deductible1,
max(case when covx_code='LAC' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as LAC_Deductible2,
max(case when covx_code='LAC' then FullTermAmt else 0.0 end) as LAC_FullTermAmt,
max(case when covx_code='MEDPAY' then cast(Limit1 as float) else 0.0 end) as MEDPAY_Limit1,
max(case when covx_code='MEDPAY' then cast(Limit2 as float) else 0.0 end) as MEDPAY_Limit2,
max(case when covx_code='MEDPAY' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as MEDPAY_Deductible1,
max(case when covx_code='MEDPAY' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as MEDPAY_Deductible2,
max(case when covx_code='MEDPAY' then FullTermAmt else 0.0 end) as MEDPAY_FullTermAmt,
max(case when covx_code='OccupationDiscount' then cast(Limit1 as float) else 0.0 end) as OccupationDiscount_Limit1,
max(case when covx_code='OccupationDiscount' then cast(Limit2 as float) else 0.0 end) as OccupationDiscount_Limit2,
max(case when covx_code='OccupationDiscount' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as OccupationDiscount_Deductible1,
max(case when covx_code='OccupationDiscount' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as OccupationDiscount_Deductible2,
max(case when covx_code='OccupationDiscount' then FullTermAmt else 0.0 end) as OccupationDiscount_FullTermAmt,
max(case when covx_code='OLT' then cast(Limit1 as float) else 0.0 end) as OLT_Limit1,
max(case when covx_code='OLT' then cast(Limit2 as float) else 0.0 end) as OLT_Limit2,
max(case when covx_code='OLT' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as OLT_Deductible1,
max(case when covx_code='OLT' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as OLT_Deductible2,
max(case when covx_code='OLT' then FullTermAmt else 0.0 end) as OLT_FullTermAmt,
max(case when covx_code='PIHOM' then cast(Limit1 as float) else 0.0 end) as PIHOM_Limit1,
max(case when covx_code='PIHOM' then cast(Limit2 as float) else 0.0 end) as PIHOM_Limit2,
max(case when covx_code='PIHOM' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as PIHOM_Deductible1,
max(case when covx_code='PIHOM' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as PIHOM_Deductible2,
max(case when covx_code='PIHOM' then FullTermAmt else 0.0 end) as PIHOM_FullTermAmt,
max(case when covx_code='PPREP' then cast(Limit1 as float) else 0.0 end) as PPREP_Limit1,
max(case when covx_code='PPREP' then cast(Limit2 as float) else 0.0 end) as PPREP_Limit2,
max(case when covx_code='PPREP' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as PPREP_Deductible1,
max(case when covx_code='PPREP' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as PPREP_Deductible2,
max(case when covx_code='PPREP' then FullTermAmt else 0.0 end) as PPREP_FullTermAmt,
max(case when covx_code='PRTDVC' then cast(Limit1 as float) else 0.0 end) as PRTDVC_Limit1,
max(case when covx_code='PRTDVC' then cast(Limit2 as float) else 0.0 end) as PRTDVC_Limit2,
max(case when covx_code='PRTDVC' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as PRTDVC_Deductible1,
max(case when covx_code='PRTDVC' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as PRTDVC_Deductible2,
max(case when covx_code='PRTDVC' then FullTermAmt else 0.0 end) as PRTDVC_FullTermAmt,
max(case when covx_code='SeniorDiscount' then cast(Limit1 as float) else 0.0 end) as SeniorDiscount_Limit1,
max(case when covx_code='SeniorDiscount' then cast(Limit2 as float) else 0.0 end) as SeniorDiscount_Limit2,
max(case when covx_code='SeniorDiscount' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as SeniorDiscount_Deductible1,
max(case when covx_code='SeniorDiscount' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as SeniorDiscount_Deductible2,
max(case when covx_code='SeniorDiscount' then FullTermAmt else 0.0 end) as SeniorDiscount_FullTermAmt,
max(case when covx_code='SEWER' then cast(Limit1 as float) else 0.0 end) as SEWER_Limit1,
max(case when covx_code='SEWER' then cast(Limit2 as float) else 0.0 end) as SEWER_Limit2,
max(case when covx_code='SEWER' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as SEWER_Deductible1,
max(case when covx_code='SEWER' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as SEWER_Deductible2,
max(case when covx_code='SEWER' then FullTermAmt else 0.0 end) as SEWER_FullTermAmt,
max(case when covx_code='SPP' then cast(Limit1 as float) else 0.0 end) as SPP_Limit1,
max(case when covx_code='SPP' then cast(Limit2 as float) else 0.0 end) as SPP_Limit2,
max(case when covx_code='SPP' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as SPP_Deductible1,
max(case when covx_code='SPP' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as SPP_Deductible2,
max(case when covx_code='SPP' then FullTermAmt else 0.0 end) as SPP_FullTermAmt,
max(case when covx_code='SRORP' then cast(Limit1 as float) else 0.0 end) as SRORP_Limit1,
max(case when covx_code='SRORP' then cast(Limit2 as float) else 0.0 end) as SRORP_Limit2,
max(case when covx_code='SRORP' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as SRORP_Deductible1,
max(case when covx_code='SRORP' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as SRORP_Deductible2,
max(case when covx_code='SRORP' then FullTermAmt else 0.0 end) as SRORP_FullTermAmt,
max(case when covx_code='THEFA' then cast(Limit1 as float) else 0.0 end) as THEFA_Limit1,
max(case when covx_code='THEFA' then cast(Limit2 as float) else 0.0 end) as THEFA_Limit2,
max(case when covx_code='THEFA' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as THEFA_Deductible1,
max(case when covx_code='THEFA' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as THEFA_Deductible2,
max(case when covx_code='THEFA' then FullTermAmt else 0.0 end) as THEFA_FullTermAmt,
max(case when covx_code='UTLDB' then cast(Limit1 as float) else 0.0 end) as UTLDB_Limit1,
max(case when covx_code='UTLDB' then cast(Limit2 as float) else 0.0 end) as UTLDB_Limit2,
max(case when covx_code='UTLDB' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as UTLDB_Deductible1,
max(case when covx_code='UTLDB' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as UTLDB_Deductible2,
max(case when covx_code='UTLDB' then FullTermAmt else 0.0 end) as UTLDB_FullTermAmt,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then cast(Limit1 as float) else 0.0 end) as WCINC_Limit1,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then cast(Limit2 as float) else 0.0 end) as WCINC_Limit2,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as WCINC_Deductible1,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as WCINC_Deductible2,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then FullTermAmt else 0.0 end) as WCINC_FullTermAmt,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then cast(Limit1 as float) else 0.0 end) as WCINC_Limit1_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then cast(Limit2 as float) else 0.0 end) as WCINC_Limit2_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' and Deductible1 ~ ('[0-9]') then cast(Deductible1 as float) else 0.0 end) as WCINC_Deductible1_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' and Deductible2 ~ ('[0-9]') then cast(Deductible2 as float) else 0.0 end) as WCINC_Deductible2_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then FullTermAmt else 0.0 end) as WCINC_FullTermAmt_o
from tmp_coverage
group by
SystemId,
BookDt,
TransactionEffectiveDt,
policy_uniqueid,
Risk_uniqueid
;




END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_customer(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN


/*0. Scope - full (f) catch up (c) or daily load (d)*/
drop table if exists tmp_scope;
create temporary table tmp_scope as
select cb.SystemId
from prodcse_dw.customer cb
where cb.cmmContainer='Customer'
/*and to_date(substring(cb.UpdateTimestamp,1,10), 'mm/dd/yyyy') > DATEADD(day, -1, sql_bookDate)
and to_date(substring(cb.UpdateTimestamp,1,10), 'mm/dd/yyyy') <= DATEADD(day, 1, sql_currentDate);*/
and to_date(substring(cb.UpdateTimestamp,1,10), 'mm/dd/yyyy') > DATEADD(day, -1, '2022-01-01')
and to_date(substring(cb.UpdateTimestamp,1,10), 'mm/dd/yyyy') <= DATEADD(day, 1, '2022-01-04');


drop table if exists tmp_real_customers;
create temporary table tmp_real_customers as
select customerRef
from aurora_prodcse_dw.Policy
union
select customerRef
from aurora_prodcse_dw.QuoteInfo;

truncate table kdlab.stg_customer;
insert into kdlab.stg_customer
select distinct
sql_loadDate as LoadDate
, c.SystemId as Customer_UniqueId
, coalesce(c.Status,'~') as Status
, coalesce(c.EntityTypeCd ,'~') EntityTypeCd
, coalesce(NI.GivenName,'~') first_name
, coalesce(NI.Surname,'~') as last_name
, coalesce(NI.CommercialName,'~') as CommercialName
, coalesce(case when PerI.BirthDt<to_date('1900-01-01', 'yyyy-mm-dd') then to_date('1900-01-01','yyyy-mm-dd') else BirthDt end,to_date('1900-01-01','yyyy-mm-dd')) as DOB
, coalesce(PerI.GenderCd,'~') as gender
, coalesce(PerI.MaritalStatusCd,'~') as maritalStatus
, coalesce(A1.Addr1,'~') as address1
, coalesce(REPLACE(NULLIF(A1.Addr2,''),'|','/'),'~') as address2
, coalesce(A1.County,'~') as county
, coalesce(A1.City,'~') as city
, coalesce(A1.StateProvCd,'~') as state
, coalesce(left(A1.PostalCode,5),'~') as PostalCode
, cse_bi.ifempty(case
when ac.PrimaryPhoneName<>'Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName<>'Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as phone
, cse_bi.ifempty(case
when ac.PrimaryPhoneName='Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName='Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as mobile
, cse_bi.ifempty(ac.emailaddr,'~') as email
, coalesce(c.PreferredDeliveryMethod,'None') as PreferredDeliveryMethod
, coalesce(to_date(substring(c.PortalInvitationSentDt,1,8),'yyyymmdd'),to_date('1900-01-01','yyyy-mm-dd')) as PortalInvitationSentDt
, coalesce(c.PaymentReminderInd,'~') as PaymentReminderInd
, coalesce(to_date(substring(c.UpdateTimestamp,1,10), 'mm/dd/yyyy'),to_date('1900-01-01','yyyy-mm-dd')) ChangeDate
from tmp_scope cu
join prodcse_dw.Customer c
on cu.SystemId=c.SystemId
join tmp_real_customers rc
on c.SystemId=rc.CustomerRef
join aurora_prodcse_dw.PartyInfo as PartyI
on PartyI.SystemId = c.SystemId
and PartyI.ParentId = c.id
and PartyI.CMMContainer = c.CMMContainer
and PartyI.PartyTypeCd = 'CustomerParty'
join aurora_prodcse_dw.NameInfo as NI
on NI.SystemId = c.SystemId
and NI.CMMContainer = c.CMMContainer
and NI.ParentId = PartyI.id
and NI.NameTypeCd = 'CustomerName'
join aurora_prodcse_dw.PersonInfo as PerI
on PerI.SystemId = c.SystemId
and PerI.CMMContainer = c.CMMContainer
and PerI.ParentId = PartyI.id
and PerI.PersonTypeCd = 'CustomerPersonal'
join aurora_prodcse_dw.Addr as A1
on A1.SystemId = c.SystemId
and A1.CMMContainer = c.CMMContainer
and A1.ParentId = PartyI.id
and A1.AddrTypeCd = 'CustomerMailingAddr'
join aurora_prodcse_dw.AllContacts ac
on ac.systemid = c.SystemId
and ac.PartyInfoIdRef=PartyI.Id
and ac.cmmContainer=c.CMMContainer
where c.CMMContainer='Customer' ;


END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_producer(sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

/*Full Load for now...
* Data are refreshed daily and ChangeDate is Date not datetime */

/*For new_business_term_date column:
* SystemId in LicensedProduct is Agent's SystemId
* One Agent - Many Products with teh same SystemId
* Product has Status and New Expiration dt and they are NOT sync
* All Products are Active in all providers now but some expired (?)
* new_business_term_date is a latest date when last products expired, and no active at all?
* 
* */
/*Latest expired product date if all products expired*/
drop table if exists tmp;
create temporary table tmp as
with data as (
--providers with all products expired
select SystemId
from prodcse_dw.LicensedProduct lp
where lp.cmmContainer='Provider'
group by SystemId
--cnt_total_products=cnt_expired_products
having count(*)=sum(case when NewExpirationDt is not null then 1 else 0 end)
)
select
--latest expired date
data.SystemId,
max(NewExpirationDt) latest_NewExpirationDt
from data
join prodcse_dw.LicensedProduct lp
on lp.SystemId=data.SystemId
where lp.cmmContainer='Provider'
group by data.SystemId;



truncate table kdlab.stg_producer;
insert into kdlab.stg_producer
select
sql_loadDate as LoadDate,
p.ProviderNumber as producer_uniqueid ,
p.ProviderNumber as producer_number ,
cse_bi.ifempty(ni.CommercialName,'~') as producer_name ,
cse_bi.ifempty(pri.LicenseNo,'~') as LicenseNo ,
cse_bi.ifempty(pri.ProducerTypeCd,'~') as agency_type,
cse_bi.ifempty(ac.BestAddr1+' '+ac.BestAddr2,'~') as address ,
cse_bi.ifempty(ac.BestCity,'~') as city ,
cse_bi.ifempty(ac.BestStateProvCd,'~') as state_cd ,
cse_bi.ifempty(ac.BestPostalCode,'~') as zip ,
cse_bi.ifempty(ac.primaryPhoneNumber,'~') as phone ,
cse_bi.ifempty(ac.Faxnumber,'~') as fax ,
cse_bi.ifempty(ac.EmailAddr,'~') as email ,
cse_bi.ifempty(pri.AgencyGroup,'~') as agency_group ,
cse_bi.ifempty(pri.NationalName,'~') as national_name ,
cse_bi.ifempty(pri.NationalCode,'~') as national_code ,
cse_bi.ifempty(pri.branchcd,'~') as territory ,
cse_bi.ifempty(pri.TerritoryManager,'~') as territory_manager ,
cse_bi.ifempty(ni.DBAName,'~') as dba ,
cse_bi.ifempty(p.Statuscd,'~') as producer_status ,
cse_bi.ifempty(pri.CommissionMaster,'~') as commission_master ,
cse_bi.ifempty(pri.ReportingMaster,'~') as reporting_master ,
isnull(pri.appointeddt,'1900-01-01') as pn_appointment_date ,
cse_bi.ifempty(pri.ProfitSharingMaster,'~') as profit_sharing_master ,
cse_bi.ifempty(pri.ProducerMaster,'~') as producer_master ,
cse_bi.ifempty(pri.RecognitionTier,'~') as recognition_tier ,
cse_bi.ifempty(a.Addr1+' '+a.Addr2,'~') as rmaddress ,
cse_bi.ifempty(a.City,'~') as rmcity ,
cse_bi.ifempty(a.StateProvCd,'~') as rmstate ,
cse_bi.ifempty(a.PostalCode,'~') as rmzip ,
isnull(tmp.latest_NewExpirationDt,'1900-01-01') as new_business_term_date ,
coalesce(to_date(substring(p.UpdateTimestamp,1,10), 'mm/dd/yyyy'),to_date('1900-01-01','yyyy-mm-dd')) ChangeDate
from aurora_prodcse_dw.Provider p
join aurora_prodcse_dw.PartyInfo pai
on p.SystemId=pai.SystemId
and p.cmmContainer=pai.cmmContainer
and p.id=pai.parentId
and pai.PartyTypeCd='ProviderParty'
--
join aurora_prodcse_dw.NameInfo ni
on p.SystemId=ni.SystemId
and p.cmmContainer=ni.cmmContainer
and pai.Id=ni.ParentId
and ni.NameTypeCd='ProviderName'
--
join aurora_prodcse_dw.AllContacts ac
on p.SystemId=ac.SystemId
and p.cmmContainer=ac.cmmContainer
and ac.ContactTypeCd='Provider'
and ac.SourceTypeCd='Producer'
--
join aurora_prodcse_dw.ProducerInfo pri
on p.SystemId=pri.SystemId
and p.cmmContainer=pri.cmmContainer
and p.Id=pri.ParentId
--
left outer join aurora_prodcse_dw.Addr a
on p.SystemId=a.SystemId
and p.cmmContainer=a.cmmContainer
and pai.Id=a.ParentId
and AddrTypeCd='ProviderBillingAddr'
--
left outer join tmp
on p.SystemId=tmp.SystemId
where p.ProviderTypeCd ='Producer'
and p.CMMContainer='Provider'
and isnull(p.StatusCd,'Deleted') <> 'Deleted'
and lower(isnull(p.IndexName,'~')) not like '%duplicate%'
/*stage all producers to avoide complications to set into SP LatestProviderUpdateTimeStamp*/
--and to_date(substring(p.UpdateTimestamp,1,10), 'mm/dd/yyyy') > sql_LatestProviderUpdateTimeStamp
;

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_policytransaction(sql_bookDate date, sql_currentDate date, sql_loadDate TIMESTAMP WITHOUT TIME ZONE)												
LANGUAGE plpgsql												
AS $$												
DECLARE												
begin												
drop table if exists tmp_scope;												
create temporary table tmp_scope as												
select * from kdlab.stg_policy_scope;												
truncate table kdlab.stg_policytransaction;												
insert into kdlab.stg_policytransaction												
select												
sql_loadDate as LoadDate												
, isnull(h.SystemId, h_r.SystemId) SystemId												
, ps.policyRef as policy_uniqueID												
, case when ps.StatSequenceReplace is null then cast(ps.StatSequence as varchar) else cast(ps.StatSequence as varchar)+'-'+cast(ps.StatSequenceReplace as varchar) end as policyTransaction_uniqueID												
, isnull(ps.RiskId, 'Unknown') as primaryrisk_uniqueID												
, isnull(ps.AssignedDriver, 'Unknown') as secondaryrisk_uniqueID												
, ps.BookDt												
, ps.TransactionNumber												
, ps.AccountingDt												
, ps.TransactionEffectiveDt												
, ps.TransactionCd												
, case												
when ps.TransactionCd ='Cancellation' then												
case												
when ps.TransactionEffectiveDt = ps.EffectiveDt then 'CF'												
else 'CM'												
end												
when ps.TransactionCd ='Endorsement' then 'EN'												
when ps.TransactionCd ='Expire' then 'EXP'												
when ps.TransactionCd ='New Business' then 'NB'												
when ps.TransactionCd ='Non-Renewal' then 'NR'												
when ps.TransactionCd ='Non-Renewal Rescind' then 'NRR'												
when ps.TransactionCd ='Reinstatement' then 'RI'												
when ps.TransactionCd ='Reinstatement With Lapse' then 'RI'												
when ps.TransactionCd ='Renewal' then 'RB'												
when ps.TransactionCd ='Rewrite-Renewal' then 'RB'												
when ps.TransactionCd ='Cancellation - Company' then 'CM'												
when ps.TransactionCd ='Cancellation - Insured' then 'CM'												
when ps.TransactionCd ='Cancellation - NonPay' then 'CM'												
when ps.TransactionCd ='Other' then 'EN'												
when ps.TransactionCd ='Unapply' then 'EN'												
when ps.TransactionCd ='Reapply' then 'EN'												
when ps.TransactionCd ='Commission Reversal' then 'EN'												
end as pt_typeCode												
-- 												
, isnull(ps.ProductVersionIdRef,'Unknown') product_uniqueid												
, isnull(ps.CarrierCd+'-'+ps.CompanyCd,'Unknown') as company_uniqueid												
, isnull(pro.ProviderNumber,'Unknown') producer_uniqueid												
-- 												
, replace(cast(ps.policyRef as varchar) + '-'												
+isnull(case ps.LineCd when 'Liability' then 'BusinessOwner' else ps.LineCd end,'~') + '-'												
+isnull(ps.RiskCd,'~') + '-'												
+coalesce(ps.CoverageCd,ps.FeeCd,'~') + '-'												
+isnull(ps.CoverageItemCd,'~') + '-'												
+isnull(ps.RateAreaName,'~') + '-'												
+isnull(case when ps.LineCd = 'PersonalAuto' and ps.AnnualStatementLineCd = '051' then '211' else ps.AnnualStatementLineCd end,'~') + '-'												
+isnull(ps.SublineCd,'~'),' ','~')												
as coverage_uniqueID												
-- 												
, coalesce(ps.CoverageCd,ps.FeeCd,'~') as cov_code												
, isnull(ps.RateAreaName,'~') as cov_subcode												
, case												
when ps.LineCd = 'PersonalAuto' and ps.AnnualStatementLineCd = '051' then '211'												
else isnull(ps.AnnualStatementLineCd ,'~')												
end as cov_ASL												
, isnull(ps.SublineCd,'~') as cov_subline												
, case												
when ps.ClassCd is null and ps.CoverageItemCd is null then'~'												
when ps.ClassCd is null and ps.CoverageItemCd is not null then isnull(ps.CoverageItemCd,'~')												
when ps.ClassCd is not null and ps.CoverageItemCd is null then isnull(ps.ClassCd,'~')												
else isnull(ps.CoverageItemCd,'~')+'-'+isnull(ps.ClassCd,'~')												
end as cov_classCode												
, isnull(ps.Deductible1,'~') as cov_deductible1												
, isnull(ps.Deductible2,'~') as cov_deductible2												
, isnull(ps.limit1,'~') as cov_limit1												
, isnull(ps.limit2,'~') as cov_limit2												
-- 												
, coalesce(ps.WrittenPremiumAmt, ps.WrittenPremiumFeeAmt,0) WrittenPremiumAmt												
, isnull(ps.WrittenCommissionAmt,0) WrittenCommissionAmt												
, isnull(ps.InforceChangeAmt,0) InforceChangeAmt												
-- 												
from tmp_scope s												
join aurora_prodcse.PolicyStats ps												
on s.PolicyRef=ps.PolicyRef												
and cmmcontainer='Policy'												
left outer join kdlab.vstg_policyhistory h												
on ps.PolicyRef=h.PolicyRef												
and ps.BookDt=h.BookDt												
and ps.TransactionNumber=h.TransactionNumber												
and ps.StatSequenceReplace is null												
left outer join aurora_prodcse.PolicyStats ps_r												
on ps.StatSequenceReplace=ps_r.Systemid												
left outer join kdlab.vstg_policyhistory h_r												
on ps_r.PolicyRef=h_r.PolicyRef												
and ps_r.BookDt=h_r.BookDt												
and ps_r.TransactionNumber=h_r.TransactionNumber												
and ps_r.StatSequenceReplace is null												
left outer join aurora_prodcse_dw.BasicPolicy bp												
on isnull(h.SystemId, h_r.SystemId)=bp.SystemId												
and bp.CMMContainer='Application'												
left outer join prodcse_dw.provider pro												
on bp.ProviderRef = pro.SystemId												
and pro.ProviderTypeCd = 'Producer'												
and pro.cmmContainer='Provider';												
END;												
$$												
;												
												
												
												
												
CREATE OR REPLACE PROCEDURE kdlab.sp_stg_policytransactionextension(sql_bookDate date, sql_currentDate date, sql_loadDate date)
LANGUAGE plpgsql
AS $$
DECLARE
begin

drop table if exists tmp_scope;
create temporary table tmp_scope as
select * from kdlab.stg_policy_scope;

truncate table kdlab.stg_policytransactionextension;
insert into kdlab.stg_policytransactionextension
select distinct
sql_loadDate as LoadDate,
case when ps.StatSequenceReplace is null then cast(ps.StatSequence as varchar) else cast(ps.StatSequence as varchar)+'-'+cast(ps.StatSequenceReplace as varchar) end as policyTransaction_uniqueID,
isnull(th.ApplicationRef,0) SystemId,
isnull(th.BookDt, '1900-01-01') BookDt,
isnull(th.TransactionEffectiveDt, '1900-01-01') TransactionEffectiveDt,
isnull(th.SystemId,0) Policy_Uniqueid,
isnull(th.TransactionNumber,0) TransactionNumber,
isnull(th.TransactionCd,'~') TransactionCd,
isnull(th.TransactionLongDescription,'~') TransactionLongDescription,
isnull(th.TransactionShortDescription,'~') TransactionShortDescription,
isnull(th.CancelTypeCd,'~') CancelTypeCd,
isnull(th.CancelRequestedByCd,'~') CancelRequestedByCd,
isnull(ps.CancelReason,'~') CancelReason
from tmp_scope s
join aurora_prodcse.PolicyStats ps
on s.PolicyRef=ps.PolicyRef
join aurora_prodcse_dw.TransactionHistory th
on ps.PolicyRef=th.SystemId
and ps.TransactionNumber=th.TransactionNumber and ps.TransactionCd=th.TransactionCd
where th.CMMContainer='Policy';

END;

$$
;

CREATE OR REPLACE PROCEDURE kdlab.sp_stg_fpc(pmonth_id int, ploaddate date)														
LANGUAGE plpgsql														
AS $$														
DECLARE														
vmonth_id int;														
processing_date date;														
BEGIN														
vmonth_id=pmonth_id;														
														
IF vmonth_id<200002 THEN														
raise info 'Month_Id is not provided. Processing current month...';														
vmonth_id=cast(to_char(GetDate(),'yyyymm') as int);														
ELSE														
raise info 'Month_Id to process - %', vmonth_Id;														
END IF;														
--processing_date=getDate(); 														
processing_date=ploaddate;														
														
														
														
/*Only coverage is important as a key														
* Coverage_Uniqueid includes PolicyRef and RiskCd														
* Limits, Deductibles, Producer, Company, Product can be added														
* from FACT_POLICYTANSACTION by SystemId later														
* Policy_uniqueId is needed because some calculations at the policy term level														
* */														
														
drop table if exists tmp_stg_policytransaction;														
create temporary table tmp_stg_policytransaction as														
select														
m.month_id,														
isnull(h.SystemId, h_r.SystemId) SystemId														
, ps.policyRef as policy_uniqueID														
, case when ps.StatSequenceReplace is null then cast(ps.StatSequence as varchar) else cast(ps.StatSequence as varchar)+'-'+cast(ps.StatSequenceReplace as varchar) end as policyTransaction_uniqueID														
, replace(cast(ps.policyRef as varchar) + '-'														
+isnull(case ps.LineCd when 'Liability' then 'BusinessOwner' else ps.LineCd end,'~') + '-'														
+isnull(ps.RiskCd,'~') + '-'														
+coalesce(ps.CoverageCd,ps.FeeCd,'~') + '-'														
+isnull(ps.CoverageItemCd,'~') + '-'														
+isnull(ps.RateAreaName,'~') + '-'														
+isnull(case when ps.LineCd = 'PersonalAuto' and ps.AnnualStatementLineCd = '051' then '211' else ps.AnnualStatementLineCd end,'~') + '-'														
+isnull(ps.SublineCd,'~'),' ','~')														
as coverage_uniqueID														
/*----------------------------*/														
, ps.TransactionEffectiveDt														
, ps.AccountingDt														
, ps.EffectiveDt														
, ps.ExpirationDt														
/*----------------------------*/														
, ps.WrittenPremiumAmt														
, ps.WrittenPremiumFeeAmt														
, ps.WrittenCommissionAmt														
, ps.InforceChangeAmt														
/*----------------------------*/														
, ps.TransactionNumber														
, ps.TransactionCd														
/*----------------------------*/														
, case when m.month_id = to_char(ps.AccountingDt,'yyyymm') then ps.WrittenPremiumAmt else 0 end CURRENT_MONTH_AMOUNT														
, case when m.month_id = to_char(ps.AccountingDt,'yyyymm') then ps.WrittenPremiumFeeAmt else 0 end CURRENT_MONTH_FEE_AMOUNT														
, case when m.month_id = to_char(ps.AccountingDt,'yyyymm') then ps.WrittenCommissionAmt else 0 end CURRENT_MONTH_COMMISSION_AMOUNT														
, case when m.month_id = to_char(ps.AccountingDt,'yyyymm') then ps.InforceChangeAmt else 0 end CURRENT_MONTH_TERM_AMOUNT														
/*----------------------------*/														
, ps.EarnDays														
, ps.EndDt														
/*----------------------------*/														
, m.mon_startdate														
, m.mon_enddate														
/*----------------------------*/														
, tt.PTRANS_4SIGHTBICODE														
, tt.PTRANS_COMMISSION														
, tt.PTRANS_WRITTENPREM														
, tt.PTRANS_EARNEDPREM														
, tt.PTRANS_EARNEDCOMMISSION														
, tt.PTRANS_CANCELLATIONPREM														
, tt.PTRANS_FEES														
/*----------------------------*/														
from														
/*The same as in FPT staging*/														
aurora_prodcse.PolicyStats ps														
left outer join kdlab.vstg_policyhistory h														
on ps.PolicyRef=h.PolicyRef														
and ps.BookDt=h.BookDt														
and ps.TransactionNumber=h.TransactionNumber														
and ps.StatSequenceReplace is null														
left outer join aurora_prodcse.PolicyStats ps_r														
on ps.StatSequenceReplace=ps_r.Systemid														
left outer join kdlab.vstg_policyhistory h_r														
on ps_r.PolicyRef=h_r.PolicyRef														
and ps_r.BookDt=h_r.BookDt														
and ps_r.TransactionNumber=h_r.TransactionNumber														
and ps_r.StatSequenceReplace is null														
/*specific for FPC*/														
join kdlab.dim_policytransactiontype tt														
on tt.ptrans_code = case														
when ps.FeeCd is not null then 'FS'														
when ps.TransactionCd ='Cancellation' then														
case														
when ps.TransactionEffectiveDt = ps.EffectiveDt then 'CF'														
else 'CM'														
end														
when ps.TransactionCd ='Endorsement' then 'EN'														
when ps.TransactionCd ='Expire' then 'EXP'														
when ps.TransactionCd ='New Business' then 'NB'														
when ps.TransactionCd ='Non-Renewal' then 'NR'														
when ps.TransactionCd ='Non-Renewal Rescind' then 'NRR'														
when ps.TransactionCd ='Reinstatement' then 'RI'														
when ps.TransactionCd ='Reinstatement With Lapse' then 'RI'														
when ps.TransactionCd ='Renewal' then 'RB'														
when ps.TransactionCd ='Rewrite-Renewal' then 'RB'														
when ps.TransactionCd ='Cancellation - Company' then 'CM'														
when ps.TransactionCd ='Cancellation - Insured' then 'CM'														
when ps.TransactionCd ='Cancellation - NonPay' then 'CM'														
when ps.TransactionCd ='Other' then 'EN'														
when ps.TransactionCd ='Unapply' then 'EN'														
when ps.TransactionCd ='Reapply' then 'EN'														
when ps.TransactionCd ='Commission Reversal' then 'EN'														
end														
and tt.ptrans_subcode=isnull(ps.FeeCd,'~')														
join fsbi_dw_spinn.dim_month m														
on ( (ps.AccountingDt >= m.mon_startdate and ps.AccountingDt <= m.mon_enddate) /*transaction accounting in this month*/														
or (ps.TransactionEffectiveDt <= m.mon_enddate and cast(to_char(ps.ExpirationDt,'yyyy') as int)>= m.mon_year														/*-1 adds 1 year*/
and ps.AccountingDt <= m.mon_enddate) /*OR transaction effective this year and before period End Date and accounting before period End date*/														
)														
and m.month_id=vmonth_id;														
														
														
														
														
--Policy term level operations														
drop table if exists tmp_policy_term_data;														
create temporary table tmp_policy_term_data as														
select distinct														
month_id														
,policy_uniqueID														
,PTRANS_4SIGHTBICODE														
,TransactionNumber														
/*Comparing to Processing date or Month End depends on if it's a current month or historical processing*/														
,case when PTRANS_4SIGHTBICODE IN ('CM', 'CF', 'CS', 'RI', 'CR', 'NR', 'NRR','EXP') then														
kdlab.policy_status(PTRANS_4SIGHTBICODE, cast(EffectiveDt as date), cast(ExpirationDt as date), least(processing_date, mon_enddate))														
else														
kdlab.policy_status('UNK', cast(EffectiveDt as date), cast(ExpirationDt as date), least(processing_date, mon_enddate))														
end status_code														
,max(case when status_code is not null then TransactionNumber else 0 end) over(partition by policy_uniqueID, month_id ) last_status_TransactionNumber														
,case when PTRANS_4SIGHTBICODE = 'RI' then TransactionNumber else 0 end policyReinstated_TransactionNumber														
/* If cancellation effective date is between the period start date and processing date 														
and not a reinstatement (reinstatement is checked below - can not do it at transaction level) 														
then set the policy cancelled effective indicator to 1 */														
/*Comparing to Processing date or Month End depends on if it's a current month or historical processing*/														
,case when TransactionEffectiveDt>=mon_startdate and														
TransactionEffectiveDt<=case when to_char(processing_date,'yyyymm')=to_char(mon_enddate,'yyyymm') then processing_date else greatest(processing_date, mon_enddate) end and														
PTRANS_4SIGHTBICODE IN ('CM', 'CF', 'CS', 'CR') then TransactionNumber else 0 end policyCancelledEffective_TransactionNumber														
														
/* If cancellation accounting date is between the period start date and processing date														
and not a reinstatement (reinstatement is checked below - can not do it at transaction level) 														
then set the policy cancelled issued indicator to 1*/														
/*Comparing to Processing date or Month End depends on if it's a current month or historical processing*/														
,case when AccountingDt>=mon_startdate and														
AccountingDt<=case when to_char(processing_date,'yyyymm')=to_char(mon_enddate,'yyyymm') then processing_date else greatest(processing_date, mon_enddate) end and														
PTRANS_4SIGHTBICODE IN ('CM', 'CF', 'CS', 'CR') then TransactionNumber else 0 end policyCancelledIssued_TransactionNumber														
														
,case when ExpirationDt >= mon_startdate and ExpirationDt <= least(processing_date, mon_enddate) then 1 else 0 end policyExpiredEffectiveInd														
,case when month_id = to_char(AccountingDt,'yyyymm') and PTRANS_4SIGHTBICODE='EN' then 1 else 0 end policyEndorsementIssuedInd														
,case when month_id = to_char(AccountingDt,'yyyymm') and PTRANS_4SIGHTBICODE='NR' then 1 else 0 end policyNonRenewalIssuedInd														
,case when month_id = to_char(AccountingDt,'yyyymm') and PTRANS_4SIGHTBICODE='RB' then 1 else 0 end policyRenewedIssuedInd														
,case when month_id = to_char(AccountingDt,'yyyymm') and PTRANS_4SIGHTBICODE='NB' then 1 else 0 end policyNewIssuedInd														
from tmp_stg_policytransaction														
where coverage_uniqueid not ilike '%fee%'														
order by policy_uniqueID,month_id,TransactionNumber;														
														
														
														
														
--Aggregated Policy term data (last transaction data for now)														
drop table if exists tmp_policy_term_data_grp;														
create temporary table tmp_policy_term_data_grp as														
select														
month_id,														
policy_uniqueID,														
case when max(policyReinstated_TransactionNumber)< max(policyCancelledEffective_TransactionNumber) then 1 else 0 end policyCancelledEffectiveInd,														
case when max(policyReinstated_TransactionNumber)< max(policyCancelledIssued_TransactionNumber) then 1 else 0 end policyCancelledIssuedInd,														
max(policyExpiredEffectiveInd) policyExpiredEffectiveInd,														
max(policyEndorsementIssuedInd) policyEndorsementIssuedInd,														
max(policyNonRenewalIssuedInd) policyNonRenewalIssuedInd,														
max(policyRenewedIssuedInd) policyRenewedIssuedInd,														
max(policyNewIssuedInd) policyNewIssuedInd,														
max(case when TransactionNumber=last_status_TransactionNumber then status_code end) status_code														
from tmp_policy_term_data														
group by														
policy_uniqueID,														
month_id;														
														
														
														
														
--Coverage level EP and UEP calculation														
drop table if exists tmp_coverage_data;														
create temporary table tmp_coverage_data as														
select														
month_id,														
policy_uniqueid,														
SystemId,														
coverage_uniqueid,														
policytransaction_uniqueid,														
TransactionEffectiveDt,														
AccountingDt,														
ExpirationDt,														
WrittenPremiumAmt,														
WrittenPremiumFeeAmt,														
WrittenCommissionAmt,														
InforceChangeAmt,														
/*----------------------------*/														
CURRENT_MONTH_AMOUNT,														
CURRENT_MONTH_FEE_AMOUNT,														
CURRENT_MONTH_COMMISSION_AMOUNT,														
CURRENT_MONTH_TERM_AMOUNT,														
/*----------------------------*/														
kdlab.ep(cast(TransactionEffectiveDt as date), cast(AccountingDt as date), cast(ExpirationDt as date), WrittenPremiumAmt, cast(mon_startdate as date), cast(mon_enddate as date)) earnedPremium,														
kdlab.uep(cast(TransactionEffectiveDt as date), cast(AccountingDt as date), cast(ExpirationDt as date), WrittenPremiumAmt, cast(mon_startdate as date), cast(mon_enddate as date)) unearnedPremium,														
/*----------------------------*/														
TransactionCd,														
PTRANS_COMMISSION,														
PTRANS_WRITTENPREM,														
PTRANS_EARNEDPREM,														
PTRANS_EARNEDCOMMISSION,														
PTRANS_CANCELLATIONPREM,														
PTRANS_FEES														
from tmp_stg_policytransaction														
;														
														
														
														
														
drop table if exists tmp_coverage_data_extended;														
create temporary table tmp_coverage_data_extended as														
select														
month_id,														
policy_uniqueid,														
SystemId,														
coverage_uniqueid,														
policytransaction_uniqueid,														
TransactionEffectiveDt,														
AccountingDt,														
ExpirationDt,														
WrittenPremiumAmt,														
/*----------------------------*/														
earnedPremium,														
unearnedPremium														
/*----------------------------*/														
,TransactionCd														
,case														
when PTRANS_COMMISSION = '+' then WrittenCommissionAmt + WrittenPremiumAmt														
when PTRANS_COMMISSION = '-' then WrittenCommissionAmt - WrittenPremiumAmt														
when PTRANS_COMMISSION = 'E' then WrittenCommissionAmt + earnedPremium														
else CURRENT_MONTH_COMMISSION_AMOUNT														
end COMM_AMT,														
case														
when PTRANS_WRITTENPREM = '+' then CURRENT_MONTH_AMOUNT														
when PTRANS_WRITTENPREM = '-' then - CURRENT_MONTH_AMOUNT														
when PTRANS_WRITTENPREM = 'E' then earnedPremium														
end WRTN_PREM_AMT,														
case														
when PTRANS_EARNEDPREM = '+' then CURRENT_MONTH_AMOUNT														
when PTRANS_EARNEDPREM = '-' then - CURRENT_MONTH_AMOUNT														
when PTRANS_EARNEDPREM = 'E' then earnedPremium														
end EARNED_PREM_AMT,														
case														
when PTRANS_EARNEDCOMMISSION = '+' then CURRENT_MONTH_AMOUNT														
when PTRANS_EARNEDCOMMISSION = '-' then - CURRENT_MONTH_AMOUNT														
when PTRANS_EARNEDCOMMISSION = 'E' then earnedPremium														
end COMM_EARNED_AMT,														
case														
when PTRANS_CANCELLATIONPREM = '+' then CURRENT_MONTH_AMOUNT														
when PTRANS_CANCELLATIONPREM = '-' then - CURRENT_MONTH_AMOUNT														
when PTRANS_CANCELLATIONPREM = 'E' then earnedPremium														
end CNCL_PREM_AMT,														
case														
when PTRANS_FEES = '+' then CURRENT_MONTH_FEE_AMOUNT														
when PTRANS_FEES = '-' then - CURRENT_MONTH_FEE_AMOUNT														
when PTRANS_FEES = 'E' then earnedPremium														
end FEES_AMT,														
CURRENT_MONTH_TERM_AMOUNT TERM_PREM_AMT														
from tmp_coverage_data;														
														
														
														
														
														
														
--Aggregation coverage level data														
drop table if exists tmp_coverage_data_grp;														
create temporary table tmp_coverage_data_grp as														
select														
data.month_id,														
data.policy_uniqueid,														
/*latest, single, entry in PolicyStats by historical SystemId and PolicyStats SystemId (ipolicytransaction_uniqueid) which is not replacment of a previous transaction*/														
max(data.SystemId) SystemId,														
data.coverage_uniqueid,														
sum(isnull(earnedPremium,0)) ep,														
sum(isnull(unearnedPremium,0)) uep,														
sum(isnull(COMM_AMT,0)) COMM_AMT,														
sum(isnull(WRTN_PREM_AMT,0)) WRTN_PREM_AMT,														
sum(isnull(EARNED_PREM_AMT,0)) EARNED_PREM_AMT,														
sum(isnull(COMM_EARNED_AMT,0)) COMM_EARNED_AMT,														
sum(isnull(CNCL_PREM_AMT,0)) CNCL_PREM_AMT,														
sum(isnull(FEES_AMT,0)) FEES_AMT,														
sum(isnull(TERM_PREM_AMT,0)) TERM_PREM_AMT														
from tmp_coverage_data_extended data														
group by														
data.month_id,														
data.policy_uniqueid,														
data.coverage_uniqueid;														
														
/*SystemId in tmp_stg_policytransaction (and then in tmp_coverage_data_extended) is latest historical policy transaction SystemId														
* But it's possible there are more then 1 record per the same SystemId in PolicyStats														
* That's why we need truly latest record in PolicyStats for a policy transaction														
* SystemId in tmp_coverage_data_grp is the latest policy transaction SystemId in a month														
* And now we need the latest PolicyStats.SystemId (PolicyStats record) for this historical policy transaction SystemId*/														
drop table if exists tmp_coverage_data_grp_latest_stg_record;														
create temporary table tmp_coverage_data_grp_latest_stg_record as														
select														
data.month_id,														
data.policy_uniqueid,														
data.coverage_uniqueid,														
data.SystemId,														
/*in majority cases we can get "main" PolicyStats record SystemId per historical policy transaction SystemId (not replacement a prev PolicyStats record)*/														
max(case when stg.policyTransaction_uniqueID like '%-%' then 0 else cast(stg.policyTransaction_uniqueID as bigint) end) policyTransaction_uniqueID,														
/*however there are few cases when it is not available in the processing month, then just any PolicyStats record SystemId*/														
max(stg.policyTransaction_uniqueID) policyTransaction_uniqueID_last_resort														
from tmp_coverage_data_grp data														
join tmp_stg_policytransaction stg														
on data.coverage_uniqueid=stg.coverage_uniqueid														
and data.SystemId=stg.SystemId														
group by														
data.month_id,														
data.policy_uniqueid,														
data.coverage_uniqueid,														
data.SystemId;														
														
														
														
drop table if exists tmp_coverage_data_grp_ld;														
create temporary table tmp_coverage_data_grp_ld as														
select														
grp.month_id,														
grp.policy_uniqueid,														
grp.SystemId,														
grp.coverage_uniqueid,														
grp.ep,														
grp.uep,														
grp.COMM_AMT,														
grp.WRTN_PREM_AMT,														
grp.EARNED_PREM_AMT,														
grp.COMM_EARNED_AMT,														
grp.CNCL_PREM_AMT,														
grp.FEES_AMT,														
grp.TERM_PREM_AMT														
from tmp_coverage_data_grp grp														
join tmp_coverage_data_grp_latest_stg_record grp_lsr														
on grp.month_id=grp_lsr.month_id														
and grp.coverage_uniqueid=grp_lsr.coverage_uniqueid														
and grp.SystemId=grp_lsr.SystemId														
/*transactional info*/														
join tmp_stg_policytransaction stg														
on grp.coverage_uniqueid=stg.coverage_uniqueid														
/*last in the month hist policy transaction SystemId*/														
and grp.SystemId=stg.SystemId														
/*last in the month PolicyStats record SystemId - see above*/														
and stg.policyTransaction_uniqueID = case when grp_lsr.policyTransaction_uniqueID<>0 then cast(grp_lsr.policyTransaction_uniqueID as varchar) else grp_lsr.policyTransaction_uniqueID_last_resort end;														
														
														
/*spinn based calculations*/														
drop table if exists tmp_coverage_spinn_data;														
create temporary table tmp_coverage_spinn_data as														
with														
data as (														
select														
ps.month_id														
,ps.policy_uniqueID														
,ps.coverage_uniqueid														
,sum(ps.WrittenPremiumAmt) wrtn_prem_amt_itd														
,round(sum(case when ps.EndDt>=dateadd(day,1,ps.mon_enddate) then cast(datediff(day,dateadd(day,1,ps.mon_enddate), ps.EndDt) as float)/cast(greatest(ps.EarnDays,1) as float) * ps.WrittenPremiumAmt else 0 end),2) UnearnedPremium														
,wrtn_prem_amt_itd - UnearnedPremium EarnedPremium														
from tmp_stg_policytransaction ps														
group by														
ps.month_id														
,ps.policy_uniqueID														
,ps.coverage_uniqueid														
)														
select														
month_id														
, policy_uniqueID														
, coverage_uniqueid														
, wrtn_prem_amt_itd														
, UnearnedPremium unearned_prem														
, EarnedPremium earned_prem_amt_itd														
, 0 earned_prem_amt														
from data														
order by														
policy_uniqueID														
, coverage_uniqueid														
, month_id;														
														
														
														
														
														
delete from kdlab.stg_policycoverage														
where month_id=vmonth_id;														
														
insert into kdlab.stg_policycoverage														
select distinct														
p.month_id,														
p.policy_uniqueid,														
c.SystemId,														
c.coverage_uniqueid,														
ps.status_id policystatus_id,														
term_prem_amt,														
wrtn_prem_amt,														
c.earned_prem_amt,														
fees_amt,														
cncl_prem_amt,														
comm_amt,														
comm_earned_amt,														
c.uep unearned_prem,														
s.unearned_prem spinn_unearned_prem,														
s.earned_prem_amt_itd spinn_earned_prem_amt_itd,														
s.earned_prem_amt spinn_earned_prem_amt,														
s.wrtn_prem_amt_itd,														
policynewissuedind,														
policycancelledissuedind,														
policycancelledeffectiveind,														
policyexpiredeffectiveind														
from tmp_policy_term_data_grp p														
join tmp_coverage_data_grp_ld c														
on p.month_id=c.month_id														
and p.policy_uniqueid=c.policy_uniqueid														
left outer join fsbi_dw_spinn.DIM_STATUS ps														
on p.status_code=ps.stat_4sightbistatuscd														
join tmp_coverage_spinn_data s														
on s.month_id=c.month_id														
and s.coverage_uniqueid=c.coverage_uniqueid;														
														
														
														
														
/*update monthly spinn earn monthly prem as a diff from prev month itd*/														
with data as (														
select														
month_id,														
policy_uniqueid,														
coverage_uniqueid,														
spinn_earned_prem_amt_itd,														
case														
when spinn_earned_prem_amt_itd<>0 then														
spinn_earned_prem_amt_itd - isnull(lag(spinn_earned_prem_amt_itd,1) over(partition by coverage_uniqueid order by month_id),0)														
when spinn_earned_prem_amt_itd=0 and wrtn_prem_amt<0 then														
wrtn_prem_amt + isnull(lag(spinn_unearned_prem,1) over(partition by coverage_uniqueid order by month_id),0)														
else 0														
end spinn_earned_prem_amt														
from kdlab.stg_policycoverage /*should be replace to fact_policycoverage later*/														
where month_id in (cast(to_char(ADD_MONTHS(to_date(cast(vmonth_id as varchar)+'01','yyyymmdd'),-1),'yyyymm') as int), vmonth_id)														
order by														
policy_uniqueid,														
coverage_uniqueid,														
month_id														
)														
update kdlab.stg_policycoverage														
set spinn_earned_prem_amt=data.spinn_earned_prem_amt														
from data														
where data.month_id=kdlab.stg_policycoverage.month_id														
and data.coverage_uniqueid=kdlab.stg_policycoverage.coverage_uniqueid														
and kdlab.stg_policycoverage.month_id=vmonth_id;														
														
														
END;														
														
$$														
;														


CREATE OR REPLACE PROCEDURE kdlab.sp_load_complete()
LANGUAGE plpgsql
AS $$
BEGIN
/*Most recent SystemId of a mid term change per policy term PolicyId*/
drop table if exists tmp_PolicyBase;
create temporary table tmp_PolicyBase as
select
Policy_Id
,max(SystemId) SystemId
from kdlab.DIM_APPLICATION
where policy_id<>0
group by Policy_Id;
/*Re-set Current Flg*/
/*1. DIM_APPLICATION*/
update kdlab.DIM_APPLICATION
set CurrentFlg=0;
update kdlab.DIM_APPLICATION
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_APPLICATION.policy_id
and pb.SystemId=kdlab.DIM_APPLICATION.SystemId;
/*Populating DIM_POLICY with the most recent data*/
truncate table kdlab.DIM_POLICY;
insert into kdlab.DIM_POLICY
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
from kdlab.DIM_APPLICATION
where CurrentFlg=1;
/*2. DIM_INSURED*/
update kdlab.DIM_INSURED
set CurrentFlg=0;
update kdlab.DIM_INSURED
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_INSURED.policy_id
and pb.SystemId=kdlab.DIM_INSURED.SystemId;
/*3. DIM_COVEREDRISK*/
update kdlab.DIM_COVEREDRISK
set CurrentFlg=0;
update kdlab.DIM_COVEREDRISK
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_COVEREDRISK.policy_id
and pb.SystemId=kdlab.DIM_COVEREDRISK.SystemId;
/*4. DIM_BUILDING*/
update kdlab.DIM_BUILDING
set CurrentFlg=0;
update kdlab.DIM_BUILDING
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_BUILDING.policy_id
and pb.SystemId=kdlab.DIM_BUILDING.SystemId;
/*5. DIM_POLICYTRANSACTIONEXTENSION*/
/*update kdlab.DIM_POLICYTRANSACTIONEXTENSION 
set CurrentFlg=0; 
update kdlab.DIM_POLICYTRANSACTIONEXTENSION 
set CurrentFlg=1 
from tmp_PolicyBase pb 
where pb.policy_id=kdlab.DIM_POLICYTRANSACTIONEXTENSION.policy_id 
and pb.SystemId=kdlab.DIM_POLICYTRANSACTIONEXTENSION.SystemId; */
/*6. DIM_RISK_COVERAGE*/
update kdlab.DIM_RISK_COVERAGE
set CurrentFlg=0;
update kdlab.DIM_RISK_COVERAGE
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_RISK_COVERAGE.policy_id
and pb.SystemId=kdlab.DIM_RISK_COVERAGE.SystemId;
/*7. DIM_VEHICLE*/
update kdlab.DIM_VEHICLE
set CurrentFlg=0;
update kdlab.DIM_VEHICLE
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_VEHICLE.policy_id
and pb.SystemId=kdlab.DIM_VEHICLE.SystemId;
/*8. DIM_DRIVER*/
update kdlab.DIM_DRIVER
set CurrentFlg=0;
update kdlab.DIM_DRIVER
set CurrentFlg=1
from tmp_PolicyBase pb
where pb.policy_id=kdlab.DIM_DRIVER.policy_id
and pb.SystemId=kdlab.DIM_DRIVER.SystemId;
/*Clean up*/
drop table if exists tmp_PolicyBase;
END;
$$
;
												
												
												
												
												
												
