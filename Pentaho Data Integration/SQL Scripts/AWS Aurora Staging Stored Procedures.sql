DELIMITER // 
drop function if exists `etl`.`get_numeric` //

CREATE DEFINER=`srvc_bietl`@`%` FUNCTION `etl`.`get_numeric`(str CHAR(32)) RETURNS char(32) CHARSET latin1
begin
declare i, len smallint default 1;
declare num char(32) default '';
declare c char(1);
set len = char_length(str);
while (i < len+1) do
begin
set c = mid(str,i,1);
if c regexp ('[^.0-9$\-]') = 0
then set num = concat(num,c);
end if;
set i = i+1;
end ;
end while;
return num;
end//

DELIMITER // 
drop function if exists `etl`.`ifempty` //

CREATE DEFINER=`srvc_bietl`@`%` FUNCTION `etl`.`ifempty`(s VARCHAR(10000), placeholder VARCHAR(10000)) RETURNS varchar(10000) CHARSET latin1
DETERMINISTIC
RETURN IF(TRIM(COALESCE(s, '')) = '' , placeholder, s)
//

DELIMITER // 
drop procedure if exists `etl`.`sp_load_init`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_load_init`(sql_bookDate date, sql_currentDate date, sql_loadDate datetime)
BEGIN

/*Transaction History - need a table in Aurora because maxSystemId*/
delete from etl.stg_policyhistory
where BookDt > sql_bookDate and BookDt <= sql_currentDate;

insert into etl.stg_policyhistory
( SystemId,
PolicyRef,
TransactionNumber,
TransactionCd,
BookDt,
TransactionEffectiveDt,
ReplacedByTransactionNumber,
ReplacementOfTransactionNumber,
UnAppliedByTransactionNumber,
LoadDt
)
select distinct
txnhist.ApplicationRef SystemId,
txnhist.SystemId PolicyRef,
txnhist.TransactionNumber ,
txnhist.TransactionCd ,
txnhist.BookDt,
txnhist.TransactionEffectiveDt ,
txnhist.ReplacedByTransactionNumber,
txnhist.ReplacementOfTransactionNumber,
txnhist.UnAppliedByTransactionNumber,
sql_loadDate
from prodcse_dw.TransactionHistory txnhist
where txnhist.CMMContainer='Policy'
and txnhist.TransactionEffectiveDt is not null
and txnhist.BookDt is not null
and txnhist.ApplicationRef is not null
and BookDt > sql_bookDate and BookDt <= sql_currentDate;

/*mark latest transaction in a period*/
drop temporary table if exists tmp_agg;
create temporary table tmp_agg as
select
PolicyRef,
max(SystemId) maxSystemId
from etl.stg_policyhistory
group by PolicyRef;

update etl.stg_policyhistory
join tmp_agg
on tmp_agg.PolicyRef=etl.stg_policyhistory.PolicyRef
and tmp_agg.maxSystemId=etl.stg_policyhistory.SystemId
set etl.stg_policyhistory.maxSystemId=tmp_agg.maxsystemId;


END//

DELIMITER // 
drop procedure if exists `etl`.`sp_stg_product`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_product`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
/*4. Just in case if there is a new quote (not approved application) 
* for a new product which is not yet in ProductVersionInfo 
* we need to add at least ProductVersionIdRef and SubTypeCd*/
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select cb.SystemId,cb.cmmContainer
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(sql_bookDate, INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(sql_currentDate, INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);

drop temporary table if exists tmp_BasicProduct;
create temporary table tmp_BasicProduct
select
distinct
bp.ProductVersionIdRef,
bp.SubTypeCd,
l.LineCd
from tmp_scope s
join prodcse_dw.BasicPolicy bp
on s.SystemId=bp.SystemId
and s.CMMCOntainer=bp.CMMContainer
join prodcse_dw.Line l
on s.SystemId=l.SystemId
and bp.CMMContainer=l.CMMContainer
where ifnull(bp.ProductVersionIDRef,'') <> '';
CREATE INDEX idx_tmp1 ON tmp_BasicProduct(ProductVersionIdRef);

select
Source_System as Source_System,
ifnull(pvi.productversionidref, bp.productversionidref) productversionidref,
etl.ifempty(productversion,'~') productversion,
etl.ifempty(name,'~') name,
etl.ifempty(description,'~') description,
etl.ifempty(producttypecd,'~') producttypecd,
etl.ifempty(carriergroupcd,'~') carriergroupcd,
etl.ifempty(carriercd,'~') carriercd,
etl.ifempty(isselect,0) isselect,
ifnull(pvi.linecd, bp.linecd) linecd,
ifnull(pvi.subtypecd,bp.subtypecd) subtypecd,
etl.ifempty(altsubtypecd,'~') altsubtypecd,
etl.ifempty(subtypeshortdesc,'~') subtypeshortdesc,
etl.ifempty(subtypefulldesc,'~') subtypefulldesc,
etl.ifempty(policynumberprefix,'~') policynumberprefix,
etl.ifempty(startdt,'1900-01-01') startdt,
etl.ifempty(stopdt,'2999-12-31') stopdt,
etl.ifempty(renewalstartdt,'1900-01-01') renewalstartdt,
etl.ifempty(renewalstopdt,'2999-12-31') renewalstopdt,
etl.ifempty(statecd,'~') statecd,
etl.ifempty(contract,'~') contract,
etl.ifempty(lob,'~') lob,
etl.ifempty(propertyform,'~') propertyform,
case
when prerenewaldays is null then 0
when prerenewaldays regexp ('[0-9]')=0 then 0
else CAST(prerenewaldays as UNSIGNED)
end prerenewaldays,
case
when autorenewaldays is null then 0
when autorenewaldays regexp ('[0-9]')=0 then 0
else CAST(autorenewaldays as UNSIGNED)
end autorenewaldays,
etl.ifempty(MGAFeePlanCd,'~') MGAFeePlanCd,
etl.ifempty(TPAFeePlanCd,'~') TPAFeePlanCd
,sql_loadDate loaddate
from tmp_BasicProduct bp
left outer join prodcse.ProductVersionInfo pvi
on bp.productversionidref=pvi.productversionidref
union
select
Source_System as Source_System,
etl.ifempty(productversionidref,'~') productversionidref,
etl.ifempty(productversion,'~') productversion,
etl.ifempty(name,'~') name,
etl.ifempty(description,'~') description,
etl.ifempty(producttypecd,'~') producttypecd,
etl.ifempty(carriergroupcd,'~') carriergroupcd,
etl.ifempty(carriercd,'~') carriercd,
etl.ifempty(isselect,0) isselect,
etl.ifempty(linecd,'~') linecd,
etl.ifempty(subtypecd,'~') subtypecd,
etl.ifempty(altsubtypecd,'~') altsubtypecd,
etl.ifempty(subtypeshortdesc,'~') subtypeshortdesc,
etl.ifempty(subtypefulldesc,'~') subtypefulldesc,
etl.ifempty(policynumberprefix,'~') policynumberprefix,
etl.ifempty(startdt,'1900-01-01') startdt,
etl.ifempty(stopdt,'2999-12-31') stopdt,
etl.ifempty(renewalstartdt,'1900-01-01') renewalstartdt,
etl.ifempty(renewalstopdt,'2999-12-31') renewalstopdt,
etl.ifempty(statecd,'~') statecd,
etl.ifempty(contract,'~') contract,
etl.ifempty(lob,'~') lob,
etl.ifempty(propertyform,'~') propertyform,
case
when prerenewaldays is null then 0
when prerenewaldays regexp ('[0-9]')=0 then 0
else CAST(prerenewaldays as UNSIGNED)
end prerenewaldays,
case
when autorenewaldays is null then 0
when autorenewaldays regexp ('[0-9]')=0 then 0
else CAST(autorenewaldays as UNSIGNED)
end autorenewaldays,
etl.ifempty(MGAFeePlanCd,'~') MGAFeePlanCd,
etl.ifempty(TPAFeePlanCd,'~') TPAFeePlanCd
,sql_loadDate loaddate
from prodcse.ProductVersionInfo pvi;
end//

DELIMITER // 
drop procedure if exists `etl`.`sp_stg_insured`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_insured`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);

select
Source_System as source_system
, sql_loadDate as LoadDate,
ifnull(s.PolicySystemId,s.SystemId) SystemId
, ifnull(s.BookDt,'1900-01-01') BookDt
, ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, ifnull(s.PolicyRef,0) as policy_uniqueid
, ifnull(s.PolicySystemId,s.SystemId) as insured_uniqueid
, etl.ifempty(NI.GivenName,'~') as first_name
, etl.ifempty(NI.Surname,'~') as last_name
, etl.ifempty(NI.CommercialName,'~') as CommercialName
, etl.ifempty(CASE WHEN IFNULL(PerI.BirthDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(PerI.BirthDt,str_to_date('1900-01-01', '%Y-%c-%e')) end,'1900-01-01') as DOB
, etl.ifempty(PerI.OccupationClassCd,'~') as occupation
, etl.ifempty(PerI.GenderCd,'~') as gender
, etl.ifempty(PerI.MaritalStatusCd,'~') as maritalStatus
, etl.ifempty(A1.Addr1,'~') as address1
, etl.ifempty(REPLACE(A1.Addr2,'|','/'),'~') as address2
, etl.ifempty(A1.County,'~') as county
, etl.ifempty(A1.City,'~') as city
, etl.ifempty(A1.StateProvCd,'~') as state
, etl.ifempty(A1.RegionCd,'~') as Country
, etl.ifempty(A1.PostalCode,'~') as postalCode
, etl.ifempty(case
when ac.PrimaryPhoneName<>'Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName<>'Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as telephone
, etl.ifempty(case
when ac.PrimaryPhoneName='Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName='Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,'~') as mobile
, etl.ifempty(ac.emailaddr,'~') as email
, etl.ifempty(PerI.PositionTitle,'~') as jobTitle
, etl.ifempty(isc.InsuranceScore,'~') as InsuranceScore
, etl.ifempty(isc.OverriddenInsuranceScore,'~') as OverriddenInsuranceScore
, etl.ifempty(isc.AppliedDt,'1900-01-01') as AppliedDt
, etl.ifempty(isc.InsuranceScoreValue,'~') as InsuranceScoreValue
, etl.ifempty(isc.RatePageEffectiveDt,'1900-01-01') as RatePageEffectiveDt
, etl.ifempty(isc.InsScoreTierValueBand,'~') as InsScoreTierValueBand
, etl.ifempty(isc.FinancialStabilityTier,'~') as FinancialStabilityTier
from tmp_scope s
join prodcse_dw.Insured as I
on I.SystemId = s.SystemId
and I.CMMContainer = s.CMMContainer
join prodcse_dw.PartyInfo as PartyI
on PartyI.SystemId = s.SystemId
and PartyI.ParentId = I.ID
and PartyI.CMMContainer = s.CMMContainer
and PartyI.PartyTypeCd = 'InsuredParty'
join prodcse_dw.NameInfo as NI
on NI.SystemId = s.SystemId
and NI.CMMContainer = s.CMMContainer
and NI.ParentId = PartyI.id
and NI.NameTypeCd = 'InsuredName'
join prodcse_dw.PersonInfo as PerI
on PerI.SystemId = s.SystemId
and PerI.CMMContainer = s.CMMContainer
and PerI.ParentId = PartyI.id
and PerI.PersonTypeCd = 'InsuredPersonal'
join prodcse_dw.Addr as A1
on A1.SystemId = s.SystemId
and A1.CMMContainer = s.CMMContainer
and A1.ParentId = PartyI.id
and A1.AddrTypeCd = 'InsuredMailingAddr'
join prodcse_dw.AllContacts ac
on ac.systemid = s.SystemId
and ac.cmmcontainer = s.CMMContainer
and ac.contacttypecd = 'Insured'
left join prodcse_dw.InsuranceScore isc
on isc.SystemId=s.SystemId
and isc.cmmContainer=s.CMMContainer
and isc.ParentId=I.Id ;



end//

DELIMITER // 
drop procedure if exists `etl`.`sp_stg_policy`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_policy`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */

drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);

/*Fees are related only to policies, not quotes*/
drop temporary table if exists tmp_accounts;
create temporary table tmp_accounts as
select distinct art.SystemId AccountRef
from prodCSE_dw.artrans art
where art.AdjustmentCategoryCd in ('LateFee','NSFFee', 'InstallmentFee')
and art.Amount<>0
and art.BookDt > cast(sql_bookDate as date) and art.BookDt <= cast(sql_currentDate as date)
and art.CMMContainer='Account';
create index temp_SystemId_ind on tmp_accounts (AccountRef);

/*Payments are related only to policies, NOT quotes*/
drop temporary table if exists tmp_payments;
create temporary table tmp_payments as
select distinct a.PolicyRef
from prodcse.AccountStats a
where a.BookDt > cast(sql_bookDate as date) and a.BookDt <= cast(sql_currentDate as date)
group by a.PolicyRef;
create index temp_PolicyRef_ind on tmp_payments (PolicyRef);

/* Adding in the scope policies with Fees and Payments
* but not after sql_currentDate for consistncy
* just to "refresh" existing records*/
insert into tmp_scope
/*from Fees - add in an all policy's records by PolicyRef */
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from prodcse_dw.Policy p
join tmp_accounts a
on p.AccountRef=a.AccountRef
and p.cmmContainer='Policy'
join etl.stg_policyhistory h
on p.SystemId=h.PolicyRef
where h.BookDt <= cast(sql_currentDate as date)
union
/*from payments - add in an all policy's records by PolicyRef*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from tmp_payments p
join etl.stg_policyhistory h
on p.PolicyRef=h.PolicyRef
where h.BookDt <= cast(sql_currentDate as date);


drop temporary table if exists tmp_fees;
create temporary table tmp_fees as
select distinct
bp.SystemId PolicyRef,
art.AdjustmentCategoryCd
from prodCSE_dw.artrans art
join prodCSE_dw.Account a
on art.SystemId=a.SystemId
and art.ParentId=a.Id
and art.CMMContainer=a.CMMContainer
join prodcse_dw.Policy p
on p.AccountRef=a.SystemId
and p.cmmContainer='Policy'
join tmp_scope s
on s.PolicyRef=p.SystemId
join prodcse_dw.BasicPolicy bp
on p.SystemId=bp.SystemId
and p.cmmContainer=bp.cmmContainer
where art.AdjustmentCategoryCd in ('LateFee','NSFFee', 'InstallmentFee')
and a.CMMContainer='Account'
and art.Amount<>0 ;
create index temp_AdjustmentCategoryCdPolicyRef_ind on tmp_fees (AdjustmentCategoryCd,PolicyRef);



drop temporary table if exists tmp_fees_2;
create temporary table tmp_fees_2 like tmp_fees;
insert into tmp_fees_2 select * from tmp_fees;
drop temporary table if exists tmp_fees_3;
create temporary table tmp_fees_3 like tmp_fees;
insert into tmp_fees_2 select * from tmp_fees;
drop temporary table if exists tmp_ppd;
create temporary table tmp_ppd as
select distinct PolicyNumber,
PaperlessDeliveryInd
from prodcse_dw.PaperLessDeliveryPolicy
where PaperlessDeliveryInd = 'Yes';
create index tmp_PolicyNumber_ind on tmp_ppd (PolicyNumber);



drop temporary table if exists tmp_payments_values;
create temporary table tmp_payments_values as
select a.PolicyRef,
min( case when a.PaidAmt > 0 then a.AddDt end) as FirstPayment,
max( case when a.PaidAmt > 0 then a.AddDt end) as LastPayment,
sum(a.BalanceAmt) as BalanceAmt,
sum(a.PaidAmt) as PaidAmt
from prodcse.AccountStats a
join tmp_scope tp
on tp.PolicyRef=a.PolicyRef
group by a.PolicyRef;
create index temp_PolicyRef_ind on tmp_payments_values (PolicyRef);


drop temporary table if exists tmp_bd;
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
from prodcse_dw.Building b
join tmp_scope s
on b.SystemId = s.SystemId
and b.CMMContainer = s.CMMContainer
and b.Status='Active';
create index tmp_bd_ind on tmp_bd (SystemId);


/*Umbrella policies underlying policies*/
drop temporary table if exists tmp_up;
create temporary table tmp_up as
select
bp.SystemId,
bp.cmmContainer,
GROUP_CONCAT(distinct UnderlyingPolicyNumber) UnderlyingPolicyNumber
from tmp_scope s
join prodcse_dw.BasicPolicy bp
on bp.SystemId=s.SystemId
and bp.cmmContainer=s.cmmcontainer
join prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.cmmContainer=s.cmmContainer
join prodcse_dw.location l
on l.SystemId=s.SystemId
and l.Id=r.LocationRef
and l.cmmContainer=s.cmmContainer
where r.TypeCd='Automobile'
and bp.PolicyNumber like '%U%'
and l.UnderlyingPolicyNumber is not null
group by bp.SystemId,bp.cmmContainer;
create index tmp_up_ind on tmp_up (SystemId);

select distinct
Source_System as source_system
, sql_loadDate as LoadDate
, ifnull(s.PolicySystemId,s.SystemId) SystemId
, ifnull(s.BookDt,'1900-01-01') BookDt
, ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, ifnull(s.PolicyRef,0) as policy_uniqueid
, bp.TransactionCd
, bp.ProductVersionIdRef product_uniqueid
, ifnull(concat(LEFT(concat(bp.CarrierCd , ' '),6) , case when bp.CompanyCd > '' then concat('-' , bp.CompanyCd) else '' end),'Unknown') as company_uniqueid
, ifnull(pro.ProviderNumber,'Unknown') producer_uniqueid
, ifnull(s.PolicySystemId,s.SystemId) firstinsured_uniqueid
, ifnull(bp.PolicyNumber,'Unknown') pol_policynumber
, right(RIGHT(concat('000',IFNULL(bp.PolicyVersion,'')),3),2) term
, date_format(bp.EffectiveDt,'%Y-%m-%d') as pol_effectiveDate
, date_format(bp.ExpirationDt,'%Y-%m-%d') as pol_expirationDate
, etl.ifempty(bp.CarrierCd, '~') as CarrierCd
, etl.ifempty(bp.CompanyCd, '~') as CompanyCd
, DATEDIFF(bp.ExpirationDt,bp.EffectiveDt) TermDays
, etl.ifempty(bp.CarrierGroupCd, '~') as CarrierGroupCd
, etl.ifempty(bp.ControllingStateCd, '~') as StateCd
, etl.ifempty(bp.BusinessSourceCd, '~') as BusinessSourceCd
, etl.ifempty(bp.PreviousCarrierCd, '~') as PreviousCarrierCd
, etl.ifempty(bp.SubTypeCd, '~') as PolicyFormCode
, etl.ifempty(bp.SubTypeCd, '~') as SubTypeCd
, etl.ifempty(pv.AltSubTypeCd, '~') as AltSubTypeCd
, etl.ifempty(bp.PayPlanCd, '~') as PayPlanCd
, ifnull(bp.InceptionDt,'1900-01-01') as InceptionDt
, etl.ifempty(bp.priorpolicynumber, '~') as priorpolicynumber
, etl.ifempty(bp.previouspolicynumber, '~') as previouspolicynumber
, etl.ifempty(bp.affinitygroupcd, '~') as affinitygroupcd
, etl.ifempty(bp.programInd, '~') as programInd
, etl.ifempty(l.RelatedPolicyNumber, '~') as RelatedPolicyNumber
, etl.ifempty(bp.QuoteNumber, '~') as QuoteNumber
, etl.ifempty(bp.RenewalTermCd, '~') as RenewalTermCd
, ifnull(bp.RewritePolicyRef,0) RewritePolicyRef
, ifnull(bp.RewriteFromPolicyRef,0) RewriteFromPolicyRef
, etl.ifempty(bp.CancelDt,'1900-01-01') CancelDt
, etl.ifempty(bp.ReinstateDt,'1900-01-01') ReinstateDt
, etl.ifempty(bp.PersistencyDiscountDt,'1900-01-01') PersistencyDiscountDt
, ifnull(PPD.PaperlessDeliveryInd,'No') PaperLessDelivery
, etl.ifempty(l.MultiCarDiscountInd,'No') MultiCarDiscountInd
, case when lf.PolicyRef is null then 'No' else 'Yes' end LateFee
, case when nsf.PolicyRef is null then 'No' else 'Yes' end NSFFee
, case when inf.PolicyRef is null then 'No' else 'Yes' end InstallmentFee
, etl.ifempty(bp.batchquotesourcecd, '~') as batchquotesourcecd
, etl.ifempty(l.WaivePolicyFeeInd, '~') as WaivePolicyFeeInd
/*Liability*/
, etl.ifempty(l.LiabilityLimitCPL, '~') as LiabilityLimitCPL
, etl.ifempty(l.LiabilityReductionInd, '~') as LiabilityReductionInd
, etl.ifempty(l.LiabilityLimitOLT, '~') as LiabilityLimitOLT
, etl.ifempty(l.PersonalLiabilityLimit, '~') as PersonalLiabilityLimit
, etl.ifempty(l.GLOccurrenceLimit, '~') as GLOccurrenceLimit
, etl.ifempty(l.GLAggregateLimit, '~') as GLAggregateLimit
, etl.ifempty(bp.Statuscd, '~') as Policy_SPINN_Status
, etl.ifempty(l.BILimit, '~') as BILimit
, etl.ifempty(l.PDLimit, '~') as PDLimit
, etl.ifempty(l.UMBILimit, '~') as UMBILimit
, etl.ifempty(l.MedPayLimit, '~') as MedPayLimit
, case
when substring(bp.PolicyNumber,3,1)='A' then case when ifnull(l.MultiPolicyDiscountInd,'No')<>'No' or l.MultiPolicyDiscount2Ind='Yes' then 'Yes' else 'No' end
when substring(bp.PolicyNumber,3,1)in ('H','F') then case when ifnull(b.MultiPolicyInd,'No')='Yes' or ifnull(b.AutoHomeInd,'No')='Yes' or ifnull(b.MultiPolicyIndUmbrella,'No')='Yes' then 'Yes' else 'No' end
else 'No'
end MultiPolicyDiscount
-- 
, case when ifnull(b.MultiPolicyInd,'No')='Yes' or ifnull(b.AutoHomeInd,'No')='Yes' then 'Yes' else 'No' end MultiPolicyAutoDiscount
, case when ifnull(b.MultiPolicyInd,'No')='Yes' and etl.ifempty(b.MultiPolicyNumber,'~')<>'~' then etl.ifempty(b.MultiPolicyNumber,'~') else etl.ifempty(b.otherpolicynumber1,'~') end MultiPolicyAutoNumber
-- 
, etl.ifempty(l.MultiPolicyDiscountInd,'No') MultiPolicyHomeDiscount
, etl.ifempty(l.RelatedPolicyNumber,'~') HomeRelatedPolicyNumber
-- 
, case
when substring(bp.PolicyNumber,3,1)='A' then etl.ifempty(l.MultiPolicyDiscount2Ind,'No')
when substring(bp.PolicyNumber,3,1)in ('H','F') then etl.ifempty(b.MultiPolicyIndUmbrella,'No')
else 'No'
end MultiPolicyUmbrellaDiscount
, case
when substring(bp.PolicyNumber,3,1)='A' then etl.ifempty(l.RelatedPolicyNumber2,'~')
when substring(bp.PolicyNumber,3,1)in ('H','F') then etl.ifempty(b.MultiPolicyNumberUmbrella,'~')
else 'No'
end UmbrellaRelatedPolicyNumber
-- 
, case
when substring(bp.PolicyNumber,3,1)='A' then etl.ifempty(CSEEmployeeDiscountInd,'No')
when substring(bp.PolicyNumber,3,1)in ('H','F') then etl.ifempty(b.EmployeeCreditInd,'No')
else 'No'
end CSEEmployeeDiscountInd
, etl.ifempty(l.FullPayDiscountInd,'No') FullPayDiscountInd
, etl.ifempty(l.TwoPayDiscountInd,'No') TwoPayDiscountInd
, case when etl.ifempty(b.PrimaryPolicyNumber,'~')='~' then etl.ifempty(up.UnderlyingPolicyNumber,'~') else etl.ifempty(b.PrimaryPolicyNumber,'~') end PrimaryPolicyNumber
, etl.ifempty(b.LandLordInd,'No') LandLordInd
, etl.ifempty(l.PersonalInjuryInd,'No') PersonalInjuryInd
, etl.ifempty(l.VehicleListConfirmedInd,'No') VehicleListConfirmedInd
, etl.ifempty(tp.FirstPayment,'1900-01-01') FirstPayment
, etl.ifempty(tp.LastPayment,'1900-01-01') LastPayment
, etl.ifempty(tp.BalanceAmt,0) BalanceAmt
, etl.ifempty(tp.PaidAmt,0) PaidAmt
#
, ifnull(bp.WrittenPremiumAmt,0) writtenpremiumamt
, ifnull(bp.fulltermamt,0) fulltermamt
, ifnull(bp.CommissionAmt,0) commissionamt
#
, ifnull(p.AccountRef,0) as AccountRef
#
, coalesce(p.CustomerRef,qi.customerRef,0) CUSTOMER_UNIQUEID
, etl.ifempty(a.ApplicationNumber,'~') ApplicationNumber
, ifnull(str_to_date(substring(a.UpdateTimestamp,1,19) , '%c/%e/%Y %H:%i:%s'),'1900-01-01') Application_UpdateTimestamp
, ifnull(qi.UpdateDt,'1900-01-01') QuoteInfo_UpdateDt
, ifnull(qi.adduser,'Unknown') QuoteInfo_adduser_uniqueid
, etl.ifempty(a.PolicyRef,0) original_policy_uniqueid
, etl.ifempty(a.TypeCd,'~') Application_Type
, etl.ifempty(qi.TypeCd,'~') QuoteInfo_Type
, etl.ifempty(a.Status,'~') Application_Status
, etl.ifempty(qi.Status,'~') QuoteInfo_Status
, etl.ifempty(qi.CloseReasonCd,'~') QuoteInfo_CloseReasonCd
, etl.ifempty(qi.CloseSubReasonCd,'~') QuoteInfo_CloseSubReasonCd
, etl.ifempty(qi.CloseComment,'~') QuoteInfo_CloseComment
, etl.ifempty(bp.MGAFeePlanCd,'~') MGAFeePlanCd
, ifnull(bp.MGAFeePct,0) MGAFeePct
, etl.ifempty(bp.TPAFeePlanCd,'~') TPAFeePlanCd
, ifnull(bp.TPAFeePct,0) TPAFeePct
from tmp_scope s
left outer join prodcse_dw.Policy p
on p.SystemId=s.PolicyRef
left outer join prodcse_dw.Application a
on a.SystemId = case when s.cmmContainer='Application' then s.SystemId else s.PolicySystemId end
left outer join prodcse_dw.QuoteInfo qi
on qi.SystemId = case when s.cmmContainer='Application' then s.SystemId else s.PolicySystemId end
join prodcse_dw.basicpolicy bp
on bp.SystemId = s.SystemId
and bp.CMMContainer = s.CMMContainer
join prodcse_dw.provider pro
on bp.ProviderRef = pro.SystemId
and pro.ProviderTypeCd = 'Producer'
and pro.cmmContainer='Provider'
left outer join prodcse_dw.Line l
on l.SystemId = s.SystemId
and l.CMMContainer = s.CMMContainer
and ((bp.CarrierGroupCd='CommercialLines' and l.LineCd='Liability') or bp.CarrierGroupCd<>'CommercialLines')
left outer join tmp_PPD PPD
on bp.PolicyNumber=PPD.PolicyNumber
left outer join tmp_fees lf
on lf.AdjustmentCategoryCd='LateFee'
and lf.PolicyRef=s.PolicyRef
left outer join tmp_fees_2 nsf
on nsf.AdjustmentCategoryCd='NSFFee'
and nsf.PolicyRef=s.PolicyRef
left outer join tmp_fees_3 inf
on inf.AdjustmentCategoryCd='InstallmentFee'
and inf.PolicyRef=s.PolicyRef
left outer join tmp_bd b
on b.SystemId=s.SystemId
and b.cmmContainer=s.cmmContainer
left outer join tmp_up up
on up.SystemId = s.SystemId
and up.cmmContainer = s.cmmContainer
left outer join prodcse.ProductVersionInfo pv
on bp.ProductVersionIdRef=pv.ProductVersionIdRef
left outer join tmp_payments_values tp
on tp.PolicyRef = s.PolicyRef
;
end//


DELIMITER // 
drop procedure if exists `etl`.`sp_stg_building`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_building`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);

drop temporary table if exists tmp_scope_h;
create temporary table tmp_scope_h like tmp_scope;
insert into tmp_scope_h select * from tmp_scope;


-- Dwelling 
select
'Dwelling' LineCD,
Source_System as source_system,
sql_loadDate as LoadDate,
ifnull(s.PolicySystemId,s.SystemId) SystemId,
ifnull(s.BookDt,'1900-01-01') BookDt,
ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
ifnull(s.PolicyRef,0) as policy_uniqueid,
b.Id SPINNBuilding_Id,
b.ParentId Risk_Uniqueid,
ifnull(r.TypeCd,'~') Risk_Type,
concat(cast(ifnull(s.PolicySystemId,s.SystemId) as char),'_',b.ParentId,'_',ifnull(cast(b.BldgNumber as char),'1')) building_uniqueid,
coalesce(b.Status,r.Status,'Unknown') Status,
ifnull(a.StateProvCd,'~') StateProvCd,
ifnull(a.County,'~') County,
ifnull(a.PostalCode,'~') PostalCode,
ifnull(a.City,'~') City,
ifnull(a.Addr1,'~') Addr1,
ifnull(a.Addr2,'~') Addr2,
ifnull(b.BldgNumber ,0) BldgNumber ,
ifnull(b.BusinessCategory ,'~') BusinessCategory ,
ifnull(b.BusinessClass ,'~') BusinessClass ,
ifnull(b.ConstructionCd ,'~') ConstructionCd ,
ifnull(b.RoofCd ,'~') RoofCd ,
ifnull(b.YearBuilt ,0) YearBuilt ,
ifnull(b.SqFt ,0) SqFt ,
ifnull(b.Stories ,0) Stories ,
ifnull(b.Units ,0) Units ,
ifnull(b.OccupancyCd ,'~') OccupancyCd ,
ifnull(b.ProtectionClass ,'~') ProtectionClass ,
ifnull(b.TerritoryCd ,'~') TerritoryCd ,
ifnull(b.BuildingLimit ,0) BuildingLimit ,
ifnull(b.ContentsLimit ,0) ContentsLimit ,
ifnull(b.ValuationMethod ,'~') ValuationMethod ,
ifnull(b.InflationGuardPct ,0) InflationGuardPct ,
ifnull(b.OrdinanceOrLawInd ,'~') OrdinanceOrLawInd ,
ifnull(b.ScheduledPremiumMod ,0) ScheduledPremiumMod ,
ifnull(b.WindHailExclusion ,'~') WindHailExclusion ,
ifnull(b.CovALimit ,0) CovALimit ,
ifnull(b.CovBLimit ,0) CovBLimit ,
ifnull(b.CovCLimit ,0) CovCLimit ,
ifnull(b.CovDLimit ,0) CovDLimit ,
ifnull(b.CovELimit ,0) CovELimit ,
ifnull(b.CovFLimit ,0) CovFLimit ,
ifnull(b.AllPerilDed ,'~') AllPerilDed ,
ifnull(b.BurglaryAlarmType ,'~') BurglaryAlarmType ,
ifnull(b.FireAlarmType ,'~') FireAlarmType ,
ifnull(b.CovBLimitIncluded ,0) CovBLimitIncluded ,
ifnull(b.CovBLimitIncrease ,0) CovBLimitIncrease ,
ifnull(b.CovCLimitIncluded ,0) CovCLimitIncluded ,
ifnull(b.CovCLimitIncrease ,0) CovCLimitIncrease ,
ifnull(b.CovDLimitIncluded ,0) CovDLimitIncluded ,
ifnull(b.CovDLimitIncrease ,0) CovDLimitIncrease ,
ifnull(b.OrdinanceOrLawPct ,0) OrdinanceOrLawPct ,
ifnull(b.NeighborhoodCrimeWatchInd ,'~') NeighborhoodCrimeWatchInd ,
ifnull(b.EmployeeCreditInd ,'~') EmployeeCreditInd ,
ifnull(b.MultiPolicyInd ,'~') MultiPolicyInd ,
ifnull(b.HomeWarrantyCreditInd ,'~') HomeWarrantyCreditInd ,
ifnull(b.YearOccupied ,0) YearOccupied ,
ifnull(b.YearPurchased ,0) YearPurchased ,
ifnull(b.TypeOfStructure ,'~') TypeOfStructure ,
ifnull(b.FeetToFireHydrant ,0) FeetToFireHydrant ,
ifnull(b.NumberOfFamilies ,0) NumberOfFamilies ,
ifnull(b.MilesFromFireStation ,0) MilesFromFireStation ,
ifnull(b.Rooms ,0) Rooms ,
ifnull(b.RoofPitch ,'~') RoofPitch ,
ifnull(b.FireDistrict ,'~') FireDistrict ,
ifnull(b.SprinklerSystem ,'~') SprinklerSystem ,
ifnull(b.FireExtinguisherInd ,'~') FireExtinguisherInd ,
ifnull(b.KitchenFireExtinguisherInd ,'~') KitchenFireExtinguisherInd ,
ifnull(b.DeadboltInd ,'~') DeadboltInd ,
ifnull(b.GatedCommunityInd ,'~') GatedCommunityInd ,
ifnull(b.CentralHeatingInd ,'~') CentralHeatingInd ,
ifnull(b.Foundation ,'~') Foundation ,
ifnull(b.WiringRenovation ,'~') WiringRenovation ,
ifnull(b.WiringRenovationCompleteYear ,'~') WiringRenovationCompleteYear ,
ifnull(b.PlumbingRenovation ,'~') PlumbingRenovation ,
ifnull(b.HeatingRenovation ,'~') HeatingRenovation ,
ifnull(b.PlumbingRenovationCompleteYear ,'~') PlumbingRenovationCompleteYear ,
ifnull(b.ExteriorPaintRenovation ,'~') ExteriorPaintRenovation ,
ifnull(b.HeatingRenovationCompleteYear ,'~') HeatingRenovationCompleteYear ,
ifnull(b.CircuitBreakersInd ,'~') CircuitBreakersInd ,
ifnull(b.CopperWiringInd ,'~') CopperWiringInd ,
ifnull(b.ExteriorPaintRenovationCompleteYear ,'~') ExteriorPaintRenovationCompleteYear ,
ifnull(b.CopperPipesInd ,'~') CopperPipesInd ,
ifnull(b.EarthquakeRetrofitInd ,'~') EarthquakeRetrofitInd ,
ifnull(b.PrimaryFuelSource ,'~') PrimaryFuelSource ,
ifnull(b.SecondaryFuelSource ,'~') SecondaryFuelSource ,
ifnull(b.UsageType ,'~') UsageType ,
ifnull(b.HomegardCreditInd ,'~') HomegardCreditInd ,
ifnull(b.MultiPolicyNumber ,'~') MultiPolicyNumber ,
ifnull(b.LocalFireAlarmInd ,'~') LocalFireAlarmInd ,
ifnull(b.NumLosses ,0) NumLosses ,
ifnull(b.CovALimitIncrease ,0) CovALimitIncrease ,
ifnull(b.CovALimitIncluded ,0) CovALimitIncluded ,
ifnull(b.MonthsRentedOut ,0) MonthsRentedOut ,
ifnull(b.RoofReplacement ,'~') RoofReplacement ,
ifnull(b.SafeguardPlusInd ,'~') SafeguardPlusInd ,
ifnull(b.CovELimitIncluded ,0) CovELimitIncluded ,
ifnull(b.RoofReplacementCompleteYear ,'~') RoofReplacementCompleteYear ,
ifnull(b.CovELimitIncrease ,0) CovELimitIncrease ,
ifnull(b.OwnerOccupiedUnits ,0) OwnerOccupiedUnits ,
ifnull(b.TenantOccupiedUnits ,0) TenantOccupiedUnits ,
ifnull(b.ReplacementCostDwellingInd ,'~') ReplacementCostDwellingInd ,
ifnull(b.FeetToPropertyLine ,'~') FeetToPropertyLine ,
ifnull(b.GalvanizedPipeInd ,'~') GalvanizedPipeInd ,
ifnull(b.WorkersCompInservant ,0) WorkersCompInservant ,
ifnull(b.WorkersCompOutservant ,0) WorkersCompOutservant ,
ifnull(b.LiabilityTerritoryCd ,'~') LiabilityTerritoryCd ,
ifnull(b.PremisesLiabilityMedPayInd ,'~') PremisesLiabilityMedPayInd ,
ifnull(b.RelatedPrivateStructureExclusion ,'~') RelatedPrivateStructureExclusion ,
ifnull(b.VandalismExclusion ,'~') VandalismExclusion ,
ifnull(b.VandalismInd ,'~') VandalismInd ,
ifnull(b.RoofExclusion ,'~') RoofExclusion ,
ifnull(b.ExpandedReplacementCostInd ,'~') ExpandedReplacementCostInd ,
ifnull(b.ReplacementValueInd ,'~') ReplacementValueInd ,
ifnull(b.OtherPolicyNumber1 ,'~') OtherPolicyNumber1 ,
ifnull(b.OtherPolicyNumber2 ,'~') OtherPolicyNumber2 ,
ifnull(b.OtherPolicyNumber3 ,'~') OtherPolicyNumber3 ,
ifnull(b.PrimaryPolicyNumber ,'~') PrimaryPolicyNumber ,
ifnull(b.OtherPolicyNumbers ,'~') OtherPolicyNumbers ,
ifnull(b.ReportedFireHazardScore ,'~') ReportedFireHazardScore ,
ifnull(b.FireHazardScore ,'~') FireHazardScore ,
ifnull(b.ReportedSteepSlopeInd ,'~') ReportedSteepSlopeInd ,
ifnull(b.SteepSlopeInd ,'~') SteepSlopeInd ,
ifnull(b.ReportedHomeReplacementCost ,0) ReportedHomeReplacementCost ,
ifnull(b.ReportedProtectionClass ,'~') ReportedProtectionClass ,
ifnull(b.EarthquakeZone ,'~') EarthquakeZone ,
ifnull(b.MMIScore ,'~') MMIScore ,
ifnull(b.HomeInspectionDiscountInd ,'~') HomeInspectionDiscountInd ,
ifnull(b.RatingTier ,'~') RatingTier ,
ifnull(b.SoilTypeCd ,'~') SoilTypeCd ,
ifnull(b.ReportedFireLineAssessment ,'~') ReportedFireLineAssessment ,
ifnull(b.AAISFireProtectionClass ,'~') AAISFireProtectionClass ,
ifnull(b.InspectionScore ,'~') InspectionScore ,
ifnull(b.AnnualRents ,0) AnnualRents ,
ifnull(b.PitchOfRoof ,'~') PitchOfRoof ,
ifnull(b.TotalLivingSqFt ,0) TotalLivingSqFt ,
ifnull(b.ParkingSqFt ,0) ParkingSqFt ,
ifnull(b.ParkingType ,'~') ParkingType ,
ifnull(b.RetrofitCompleted ,'~') RetrofitCompleted ,
ifnull(b.NumPools ,'~') NumPools ,
ifnull(b.FullyFenced ,'~') FullyFenced ,
ifnull(b.DivingBoard ,'~') DivingBoard ,
ifnull(b.Gym ,'~') Gym ,
ifnull(b.FreeWeights ,'~') FreeWeights ,
ifnull(b.WireFencing ,'~') WireFencing ,
ifnull(b.OtherRecreational ,'~') OtherRecreational ,
ifnull(b.OtherRecreationalDesc ,'~') OtherRecreationalDesc ,
ifnull(b.HealthInspection ,'~') HealthInspection ,
ifnull(b.HealthInspectionDt ,'1900-01-01') HealthInspectionDt ,
ifnull(b.HealthInspectionCited ,'~') HealthInspectionCited ,
ifnull(b.PriorDefectRepairs ,'~') PriorDefectRepairs ,
ifnull(b.MSBReconstructionEstimate ,'~') MSBReconstructionEstimate ,
ifnull(b.BIIndemnityPeriod ,'~') BIIndemnityPeriod ,
ifnull(b.EquipmentBreakdown ,'~') EquipmentBreakdown ,
ifnull(b.MoneySecurityOnPremises ,'~') MoneySecurityOnPremises ,
ifnull(b.MoneySecurityOffPremises ,'~') MoneySecurityOffPremises ,
ifnull(b.WaterBackupSump ,'~') WaterBackupSump ,
ifnull(b.SprinkleredBuildings ,'~') SprinkleredBuildings ,
ifnull(b.SurveillanceCams ,'~') SurveillanceCams ,
ifnull(b.GatedComplexKeyAccess ,'~') GatedComplexKeyAccess ,
ifnull(b.EQRetrofit ,'~') EQRetrofit ,
ifnull(b.UnitsPerBuilding ,'~') UnitsPerBuilding ,
ifnull(b.NumStories ,'~') NumStories ,
ifnull(b.ConstructionQuality ,'~') ConstructionQuality ,
ifnull(b.BurglaryRobbery ,'~') BurglaryRobbery ,
ifnull(b.NFPAClassification ,'~') NFPAClassification ,
ifnull(b.AreasOfCoverage ,'~') AreasOfCoverage ,
ifnull(b.CODetector ,'~') CODetector ,
ifnull(b.SmokeDetector ,'~') SmokeDetector ,
ifnull(b.SmokeDetectorInspectInd ,'~') SmokeDetectorInspectInd ,
ifnull(b.WaterHeaterSecured ,'~') WaterHeaterSecured ,
ifnull(b.BoltedOrSecured ,'~') BoltedOrSecured ,
ifnull(b.SoftStoryCripple ,'~') SoftStoryCripple ,
ifnull(b.SeniorHousingPct ,'~') SeniorHousingPct ,
ifnull(b.DesignatedSeniorHousing ,'~') DesignatedSeniorHousing ,
ifnull(b.StudentHousingPct ,'~') StudentHousingPct ,
ifnull(b.DesignatedStudentHousing ,'~') DesignatedStudentHousing ,
ifnull(b.PriorLosses ,0) PriorLosses ,
ifnull(b.TenantEvictions ,'~') TenantEvictions ,
ifnull(b.VacancyRateExceed ,'~') VacancyRateExceed ,
ifnull(b.SeasonalRentals ,'~') SeasonalRentals ,
ifnull(b.CondoInsuingAgmt ,'~') CondoInsuingAgmt ,
ifnull(b.GasValve ,'~') GasValve ,
ifnull(b.OwnerOccupiedPct ,'~') OwnerOccupiedPct ,
ifnull(b.RestaurantName ,'~') RestaurantName ,
ifnull(b.HoursOfOperation ,'~') HoursOfOperation ,
ifnull(b.RestaurantSqFt ,0) RestaurantSqFt ,
ifnull(b.SeatingCapacity ,0) SeatingCapacity ,
ifnull(b.AnnualGrossSales ,0) AnnualGrossSales ,
ifnull(b.SeasonalOrClosed ,'~') SeasonalOrClosed ,
ifnull(b.BarCocktailLounge ,'~') BarCocktailLounge ,
ifnull(b.LiveEntertainment ,'~') LiveEntertainment ,
ifnull(b.BeerWineGrossSales ,'~') BeerWineGrossSales ,
ifnull(b.DistilledSpiritsServed ,'~') DistilledSpiritsServed ,
ifnull(b.KitchenDeepFryer ,'~') KitchenDeepFryer ,
ifnull(b.SolidFuelCooking ,'~') SolidFuelCooking ,
ifnull(b.ANSULSystem ,'~') ANSULSystem ,
ifnull(b.ANSULAnnualInspection ,'~') ANSULAnnualInspection ,
ifnull(b.TenantNamesList ,'~') TenantNamesList ,
ifnull(b.TenantBusinessType ,'~') TenantBusinessType ,
ifnull(b.TenantGLLiability ,'~') TenantGLLiability ,
ifnull(b.InsuredOccupiedPortion ,'~') InsuredOccupiedPortion ,
ifnull(b.ValetParking ,'~') ValetParking ,
ifnull(b.LessorSqFt ,0) LessorSqFt ,
ifnull(b.BuildingRiskNumber ,0) BuildingRiskNumber ,
ifnull(b.MultiPolicyIndUmbrella ,'~') MultiPolicyIndUmbrella ,
ifnull(b.PoolInd ,'~') PoolInd ,
ifnull(b.StudsUpRenovation ,'~') StudsUpRenovation ,
ifnull(b.StudsUpRenovationCompleteYear ,'~') StudsUpRenovationCompleteYear ,
ifnull(b.MultiPolicyNumberUmbrella ,'~') MultiPolicyNumberUmbrella ,
ifnull(b.RCTMSBAmt ,'~') RCTMSBAmt ,
ifnull(b.RCTMSBHomeStyle ,'~') RCTMSBHomeStyle ,
ifnull(b.WINSOverrideNonSmokerDiscount ,'~') WINSOverrideNonSmokerDiscount ,
ifnull(b.WINSOverrideSeniorDiscount ,'~') WINSOverrideSeniorDiscount ,
ifnull(b.ITV ,0) ITV ,
ifnull(b.ITVDate ,'1900-01-01') ITVDate ,
ifnull(b.MSBReportType ,'~') MSBReportType ,
ifnull(b.VandalismDesiredInd ,'~') VandalismDesiredInd ,
ifnull(b.WoodShakeSiding ,'~') WoodShakeSiding ,
ifnull(b.CSEAgent ,'~') CSEAgent ,
ifnull(b.PropertyManager ,'~') PropertyManager ,
ifnull(b.RentersInsurance ,'~') RentersInsurance ,
ifnull(b.WaterDetectionDevice ,'~') WaterDetectionDevice ,
ifnull(b.AutoHomeInd ,'~') AutoHomeInd ,
ifnull(b.EarthquakeUmbrellaInd ,'~') EarthquakeUmbrellaInd ,
ifnull(b.LandlordInd ,'~') LandlordInd ,
ifnull(l_LAC.Value ,'~') LossAssessment ,
ifnull(b.GasShutOffInd ,'~') GasShutOffInd ,
ifnull(b.WaterDed ,'~') WaterDed ,
ifnull(b.ServiceLine ,'~') ServiceLine ,
ifnull(b.FunctionalReplacementCost ,'~') FunctionalReplacementCost ,
ifnull(b.MilesOfStreet ,'~') MilesOfStreet ,
ifnull(b.HOAExteriorStructure ,'~') HOAExteriorStructure ,
ifnull(b.RetailPortionDevelopment ,'~') RetailPortionDevelopment ,
ifnull(b.LightIndustrialType ,'~') LightIndustrialType ,
ifnull(b.LightIndustrialDescription ,'~') LightIndustrialDescription ,
ifnull(b.PoolCoverageLimit ,0) PoolCoverageLimit ,
ifnull(b.MultifamilyResidentialBuildings ,0) MultifamilyResidentialBuildings ,
ifnull(b.SinglefamilyDwellings ,0) SinglefamilyDwellings ,
ifnull(b.AnnualPayroll ,0) AnnualPayroll ,
ifnull(b.AnnualRevenue ,0) AnnualRevenue ,
ifnull(b.BedsOccupied ,'~') BedsOccupied ,
ifnull(b.EmergencyLighting ,'~') EmergencyLighting ,
ifnull(b.ExitSignsPosted ,'~') ExitSignsPosted ,
ifnull(b.FullTimeStaff ,'~') FullTimeStaff ,
ifnull(b.LicensedBeds ,'~') LicensedBeds ,
ifnull(b.NumberofFireExtinguishers ,0) NumberofFireExtinguishers ,
ifnull(b.OtherFireExtinguishers ,'~') OtherFireExtinguishers ,
ifnull(b.OxygenTanks ,'~') OxygenTanks ,
ifnull(b.PartTimeStaff ,'~') PartTimeStaff ,
ifnull(b.SmokingPermitted ,'~') SmokingPermitted ,
ifnull(b.StaffOnDuty ,'~') StaffOnDuty ,
ifnull(b.TypeofFireExtinguishers ,'~') TypeofFireExtinguishers ,
case when c_ADDRR.FullTermAmt is null then 'No' else 'Yes' end CovADDRR_SecondaryResidence,
ifnull(c_ADDRR.FullTermAmt,0) CovADDRRPrem_SecondaryResidence,
'No' HODeluxe,
ifnull(a.Latitude,0) Latitude,
ifnull(a.Longitude,0) Longitude,
ifnull(b.WUIClass ,'~') WUIClass,
ifnull(al.CensusBlock,'~') CensusBlock,
ifnull(replace(b.WaterRiskScore,',',''),0) WaterRiskScore,
/*---2022-03-29 CA SFG NX2 DF3; US21484---*/
ifnull(b.LandlordLossPreventionServices , '~' ) LandlordLossPreventionServices ,
ifnull(b.EnhancedWaterCoverage , '~' ) EnhancedWaterCoverage ,
ifnull(b.LandlordProperty , '~' ) LandlordProperty ,
ifnull(b.LiabilityExtendedToOthers , '~' ) LiabilityExtendedToOthers ,
ifnull(b.LossOfUseExtendedTime , '~' ) LossOfUseExtendedTime ,
ifnull(b.OnPremisesTheft , 0 ) OnPremisesTheft ,
ifnull(b.BedBugMitigation , '~' ) BedBugMitigation ,
ifnull(b.HabitabilityExclusion , '~' ) HabitabilityExclusion ,
ifnull(b.WildfireHazardPotential , '~' ) WildfireHazardPotential,
/*---2022-03-29 CA SFG Homeguard for union all---*/
ifnull(b.BackupOfSewersAndDrains,0) BackupOfSewersAndDrains,
ifnull(b.VegetationSetbackFt,0) VegetationSetbackFt,
ifnull(b.YardDebrisCoverageArea,0) YardDebrisCoverageArea,
ifnull(b.YardDebrisCoveragePercentage, '~') YardDebrisCoveragePercentage,
ifnull(b.CapeTrampoline, '~') CapeTrampoline,
ifnull(b.CapePool, '~') CapePool,
ifnull(b.RoofConditionRating, '~') RoofConditionRating,
ifnull(b.TrampolineInd, '~') TrampolineInd,
ifnull(b.PlumbingMaterial, '~') PlumbingMaterial,
ifnull(b.CentralizedHeating, '~') CentralizedHeating,
ifnull(b.FireDistrictSubscriptionCode, '~') FireDistrictSubscriptionCode,
ifnull(b.RoofCondition, '~') RoofCondition
from tmp_scope s
join prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
join prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.CMMContainer=s.CMMContainer
and r.TypeCd <> 'BuildingRisk'
join prodcse_dw.building b on
b.SystemId = s.SystemId
and b.ParentId = r.Id
and b.CMMContainer = s.CMMContainer
join prodcse_dw.addr a on
a.SystemId = s.SystemId
and a.ParentId = b.Id
and a.AddrTypeCd = 'RiskAddr'
and a.CMMContainer = s.CMMContainer
left outer join prodcse_dw.Coverage c_ADDRR
on c_ADDRR.SystemId=s.SystemId
and c_ADDRR.CMMContainer=s.CMMContainer
and c_ADDRR.ParentId=r.Id
and ifnull(c_ADDRR.Status,'Deleted')<>'Deleted'
and c_ADDRR.CoverageCd='ADDRR'
left outer join prodcse_dw.Coverage c_LAC
on c_LAC.SystemId=s.SystemId
and c_LAC.CMMContainer=s.CMMContainer
and c_LAC.ParentId=r.Id
and ifnull(c_LAC.Status,'Deleted')<>'Deleted'
and c_LAC.CoverageCd='LAC'
left outer join prodcse_dw.`limit` l_LAC
on l_LAC.SystemId=s.SystemId
and l_LAC.CMMContainer=s.CMMContainer
and l_LAC.ParentId=c_LAC.Id
and l_LAC.limitCd='Limit1'
left outer join prodcse_dw.addr al on
al.SystemId = s.SystemId
and al.ParentId = b.Id
and al.AddrTypeCd = 'RiskLookupAddr'
and al.CMMContainer = s.CMMContainer
and al.CensusBlock is not null
where
l.LineCD in ('Dwelling') and
ifnull(b.ParentId,'~') not like '%Veh%'
union all
-- Homeowners 
select
'HomeOwners' LineCD,
Source_System as source_system,
sql_loadDate as LoadDate,
ifnull(s.PolicySystemId,s.SystemId) SystemId,
ifnull(s.BookDt,'1900-01-01') BookDt,
ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
ifnull(s.PolicyRef,0) as policy_uniqueid,
b.Id SPINNBuilding_Id,
b.ParentId Risk_Uniqueid,
ifnull(r.TypeCd,'~') Risk_Type,
concat(cast(ifnull(s.PolicySystemId,s.SystemId) as char),'_',b.ParentId,'_',ifnull(cast(b.BldgNumber as char),'1')) building_uniqueid,
coalesce(b.Status,r.Status,'Unknown') Status,
ifnull(a.StateProvCd,'~') StateProvCd,
ifnull(a.County,'~') County,
ifnull(a.PostalCode,'~') PostalCode,
ifnull(a.City,'~') City,
ifnull(a.Addr1,'~') Addr1,
ifnull(a.Addr2,'~') Addr2,
ifnull(b.BldgNumber ,0) BldgNumber ,
ifnull(b.BusinessCategory ,'~') BusinessCategory ,
ifnull(b.BusinessClass ,'~') BusinessClass ,
ifnull(b.ConstructionCd ,'~') ConstructionCd ,
ifnull(b.RoofCd ,'~') RoofCd ,
ifnull(b.YearBuilt ,0) YearBuilt ,
ifnull(b.SqFt ,0) SqFt ,
ifnull(b.Stories ,0) Stories ,
ifnull(b.Units ,0) Units ,
ifnull(b.OccupancyCd ,'~') OccupancyCd ,
ifnull(b.ProtectionClass ,'~') ProtectionClass ,
ifnull(b.TerritoryCd ,'~') TerritoryCd ,
ifnull(b.BuildingLimit ,0) BuildingLimit ,
ifnull(b.ContentsLimit ,0) ContentsLimit ,
ifnull(b.ValuationMethod ,'~') ValuationMethod ,
ifnull(b.InflationGuardPct ,0) InflationGuardPct ,
ifnull(b.OrdinanceOrLawInd ,'~') OrdinanceOrLawInd ,
ifnull(b.ScheduledPremiumMod ,0) ScheduledPremiumMod ,
ifnull(b.WindHailExclusion ,'~') WindHailExclusion ,
ifnull(b.CovALimit ,0) CovALimit ,
ifnull(b.CovBLimit ,0) CovBLimit ,
ifnull(b.CovCLimit ,0) CovCLimit ,
ifnull(b.CovDLimit ,0) CovDLimit ,
ifnull(b.CovELimit ,0) CovELimit ,
ifnull(b.CovFLimit ,0) CovFLimit ,
ifnull(b.AllPerilDed ,'~') AllPerilDed ,
ifnull(b.BurglaryAlarmType ,'~') BurglaryAlarmType ,
ifnull(b.FireAlarmType ,'~') FireAlarmType ,
ifnull(b.CovBLimitIncluded ,0) CovBLimitIncluded ,
ifnull(b.CovBLimitIncrease ,0) CovBLimitIncrease ,
ifnull(b.CovCLimitIncluded ,0) CovCLimitIncluded ,
ifnull(b.CovCLimitIncrease ,0) CovCLimitIncrease ,
ifnull(b.CovDLimitIncluded ,0) CovDLimitIncluded ,
ifnull(b.CovDLimitIncrease ,0) CovDLimitIncrease ,
ifnull(b.OrdinanceOrLawPct ,0) OrdinanceOrLawPct ,
ifnull(b.NeighborhoodCrimeWatchInd ,'~') NeighborhoodCrimeWatchInd ,
ifnull(b.EmployeeCreditInd ,'~') EmployeeCreditInd ,
ifnull(b.MultiPolicyInd ,'~') MultiPolicyInd ,
ifnull(b.HomeWarrantyCreditInd ,'~') HomeWarrantyCreditInd ,
ifnull(b.YearOccupied ,0) YearOccupied ,
ifnull(b.YearPurchased ,0) YearPurchased ,
ifnull(b.TypeOfStructure ,'~') TypeOfStructure ,
ifnull(b.FeetToFireHydrant ,0) FeetToFireHydrant ,
ifnull(b.NumberOfFamilies ,0) NumberOfFamilies ,
ifnull(b.MilesFromFireStation ,0) MilesFromFireStation ,
ifnull(b.Rooms ,0) Rooms ,
ifnull(b.RoofPitch ,'~') RoofPitch ,
ifnull(b.FireDistrict ,'~') FireDistrict ,
ifnull(b.SprinklerSystem ,'~') SprinklerSystem ,
ifnull(b.FireExtinguisherInd ,'~') FireExtinguisherInd ,
ifnull(b.KitchenFireExtinguisherInd ,'~') KitchenFireExtinguisherInd ,
ifnull(b.DeadboltInd ,'~') DeadboltInd ,
ifnull(b.GatedCommunityInd ,'~') GatedCommunityInd ,
ifnull(b.CentralHeatingInd ,'~') CentralHeatingInd ,
ifnull(b.Foundation ,'~') Foundation ,
ifnull(b.WiringRenovation ,'~') WiringRenovation ,
ifnull(b.WiringRenovationCompleteYear ,'~') WiringRenovationCompleteYear ,
ifnull(b.PlumbingRenovation ,'~') PlumbingRenovation ,
ifnull(b.HeatingRenovation ,'~') HeatingRenovation ,
ifnull(b.PlumbingRenovationCompleteYear ,'~') PlumbingRenovationCompleteYear ,
ifnull(b.ExteriorPaintRenovation ,'~') ExteriorPaintRenovation ,
ifnull(b.HeatingRenovationCompleteYear ,'~') HeatingRenovationCompleteYear ,
ifnull(b.CircuitBreakersInd ,'~') CircuitBreakersInd ,
ifnull(b.CopperWiringInd ,'~') CopperWiringInd ,
ifnull(b.ExteriorPaintRenovationCompleteYear ,'~') ExteriorPaintRenovationCompleteYear ,
ifnull(b.CopperPipesInd ,'~') CopperPipesInd ,
ifnull(b.EarthquakeRetrofitInd ,'~') EarthquakeRetrofitInd ,
ifnull(b.PrimaryFuelSource ,'~') PrimaryFuelSource ,
ifnull(b.SecondaryFuelSource ,'~') SecondaryFuelSource ,
ifnull(b.UsageType ,'~') UsageType ,
ifnull(b.HomegardCreditInd ,'~') HomegardCreditInd ,
ifnull(b.MultiPolicyNumber ,'~') MultiPolicyNumber ,
ifnull(b.LocalFireAlarmInd ,'~') LocalFireAlarmInd ,
ifnull(b.NumLosses ,0) NumLosses ,
ifnull(b.CovALimitIncrease ,0) CovALimitIncrease ,
ifnull(b.CovALimitIncluded ,0) CovALimitIncluded ,
ifnull(b.MonthsRentedOut ,0) MonthsRentedOut ,
ifnull(b.RoofReplacement ,'~') RoofReplacement ,
ifnull(b.SafeguardPlusInd ,'~') SafeguardPlusInd ,
ifnull(b.CovELimitIncluded ,0) CovELimitIncluded ,
ifnull(b.RoofReplacementCompleteYear ,'~') RoofReplacementCompleteYear ,
ifnull(b.CovELimitIncrease ,0) CovELimitIncrease ,
ifnull(b.OwnerOccupiedUnits ,0) OwnerOccupiedUnits ,
ifnull(b.TenantOccupiedUnits ,0) TenantOccupiedUnits ,
ifnull(b.ReplacementCostDwellingInd ,'~') ReplacementCostDwellingInd ,
ifnull(b.FeetToPropertyLine ,'~') FeetToPropertyLine ,
ifnull(b.GalvanizedPipeInd ,'~') GalvanizedPipeInd ,
ifnull(b.WorkersCompInservant ,0) WorkersCompInservant ,
ifnull(b.WorkersCompOutservant ,0) WorkersCompOutservant ,
ifnull(b.LiabilityTerritoryCd ,'~') LiabilityTerritoryCd ,
ifnull(b.PremisesLiabilityMedPayInd ,'~') PremisesLiabilityMedPayInd ,
ifnull(b.RelatedPrivateStructureExclusion ,'~') RelatedPrivateStructureExclusion ,
ifnull(b.VandalismExclusion ,'~') VandalismExclusion ,
ifnull(b.VandalismInd ,'~') VandalismInd ,
ifnull(b.RoofExclusion ,'~') RoofExclusion ,
ifnull(b.ExpandedReplacementCostInd ,'~') ExpandedReplacementCostInd ,
ifnull(b.ReplacementValueInd ,'~') ReplacementValueInd ,
ifnull(b.OtherPolicyNumber1 ,'~') OtherPolicyNumber1 ,
ifnull(b.OtherPolicyNumber2 ,'~') OtherPolicyNumber2 ,
ifnull(b.OtherPolicyNumber3 ,'~') OtherPolicyNumber3 ,
ifnull(b.PrimaryPolicyNumber ,'~') PrimaryPolicyNumber ,
ifnull(b.OtherPolicyNumbers ,'~') OtherPolicyNumbers ,
ifnull(b.ReportedFireHazardScore ,'~') ReportedFireHazardScore ,
ifnull(b.FireHazardScore ,'~') FireHazardScore ,
ifnull(b.ReportedSteepSlopeInd ,'~') ReportedSteepSlopeInd ,
ifnull(b.SteepSlopeInd ,'~') SteepSlopeInd ,
ifnull(b.ReportedHomeReplacementCost ,0) ReportedHomeReplacementCost ,
ifnull(b.ReportedProtectionClass ,'~') ReportedProtectionClass ,
ifnull(b.EarthquakeZone ,'~') EarthquakeZone ,
ifnull(b.MMIScore ,'~') MMIScore ,
ifnull(b.HomeInspectionDiscountInd ,'~') HomeInspectionDiscountInd ,
ifnull(b.RatingTier ,'~') RatingTier ,
ifnull(b.SoilTypeCd ,'~') SoilTypeCd ,
ifnull(b.ReportedFireLineAssessment ,'~') ReportedFireLineAssessment ,
ifnull(b.AAISFireProtectionClass ,'~') AAISFireProtectionClass ,
ifnull(b.InspectionScore ,'~') InspectionScore ,
ifnull(b.AnnualRents ,0) AnnualRents ,
ifnull(b.PitchOfRoof ,'~') PitchOfRoof ,
ifnull(b.TotalLivingSqFt ,0) TotalLivingSqFt ,
ifnull(b.ParkingSqFt ,0) ParkingSqFt ,
ifnull(b.ParkingType ,'~') ParkingType ,
ifnull(b.RetrofitCompleted ,'~') RetrofitCompleted ,
ifnull(b.NumPools ,'~') NumPools ,
ifnull(b.FullyFenced ,'~') FullyFenced ,
ifnull(b.DivingBoard ,'~') DivingBoard ,
ifnull(b.Gym ,'~') Gym ,
ifnull(b.FreeWeights ,'~') FreeWeights ,
ifnull(b.WireFencing ,'~') WireFencing ,
ifnull(b.OtherRecreational ,'~') OtherRecreational ,
ifnull(b.OtherRecreationalDesc ,'~') OtherRecreationalDesc ,
ifnull(b.HealthInspection ,'~') HealthInspection ,
ifnull(b.HealthInspectionDt ,'1900-01-01') HealthInspectionDt ,
ifnull(b.HealthInspectionCited ,'~') HealthInspectionCited ,
ifnull(b.PriorDefectRepairs ,'~') PriorDefectRepairs ,
ifnull(b.MSBReconstructionEstimate ,'~') MSBReconstructionEstimate ,
ifnull(b.BIIndemnityPeriod ,'~') BIIndemnityPeriod ,
ifnull(b.EquipmentBreakdown ,'~') EquipmentBreakdown ,
ifnull(b.MoneySecurityOnPremises ,'~') MoneySecurityOnPremises ,
ifnull(b.MoneySecurityOffPremises ,'~') MoneySecurityOffPremises ,
ifnull(b.WaterBackupSump ,'~') WaterBackupSump ,
ifnull(b.SprinkleredBuildings ,'~') SprinkleredBuildings ,
ifnull(b.SurveillanceCams ,'~') SurveillanceCams ,
ifnull(b.GatedComplexKeyAccess ,'~') GatedComplexKeyAccess ,
ifnull(b.EQRetrofit ,'~') EQRetrofit ,
ifnull(b.UnitsPerBuilding ,'~') UnitsPerBuilding ,
ifnull(b.NumStories ,'~') NumStories ,
ifnull(b.ConstructionQuality ,'~') ConstructionQuality ,
ifnull(b.BurglaryRobbery ,'~') BurglaryRobbery ,
ifnull(b.NFPAClassification ,'~') NFPAClassification ,
ifnull(b.AreasOfCoverage ,'~') AreasOfCoverage ,
ifnull(b.CODetector ,'~') CODetector ,
ifnull(b.SmokeDetector ,'~') SmokeDetector ,
ifnull(b.SmokeDetectorInspectInd ,'~') SmokeDetectorInspectInd ,
ifnull(b.WaterHeaterSecured ,'~') WaterHeaterSecured ,
ifnull(b.BoltedOrSecured ,'~') BoltedOrSecured ,
ifnull(b.SoftStoryCripple ,'~') SoftStoryCripple ,
ifnull(b.SeniorHousingPct ,'~') SeniorHousingPct ,
ifnull(b.DesignatedSeniorHousing ,'~') DesignatedSeniorHousing ,
ifnull(b.StudentHousingPct ,'~') StudentHousingPct ,
ifnull(b.DesignatedStudentHousing ,'~') DesignatedStudentHousing ,
ifnull(b.PriorLosses ,0) PriorLosses ,
ifnull(b.TenantEvictions ,'~') TenantEvictions ,
ifnull(b.VacancyRateExceed ,'~') VacancyRateExceed ,
ifnull(b.SeasonalRentals ,'~') SeasonalRentals ,
ifnull(b.CondoInsuingAgmt ,'~') CondoInsuingAgmt ,
ifnull(b.GasValve ,'~') GasValve ,
ifnull(b.OwnerOccupiedPct ,'~') OwnerOccupiedPct ,
ifnull(b.RestaurantName ,'~') RestaurantName ,
ifnull(b.HoursOfOperation ,'~') HoursOfOperation ,
ifnull(b.RestaurantSqFt ,0) RestaurantSqFt ,
ifnull(b.SeatingCapacity ,0) SeatingCapacity ,
ifnull(b.AnnualGrossSales ,0) AnnualGrossSales ,
ifnull(b.SeasonalOrClosed ,'~') SeasonalOrClosed ,
ifnull(b.BarCocktailLounge ,'~') BarCocktailLounge ,
ifnull(b.LiveEntertainment ,'~') LiveEntertainment ,
ifnull(b.BeerWineGrossSales ,'~') BeerWineGrossSales ,
ifnull(b.DistilledSpiritsServed ,'~') DistilledSpiritsServed ,
ifnull(b.KitchenDeepFryer ,'~') KitchenDeepFryer ,
ifnull(b.SolidFuelCooking ,'~') SolidFuelCooking ,
ifnull(b.ANSULSystem ,'~') ANSULSystem ,
ifnull(b.ANSULAnnualInspection ,'~') ANSULAnnualInspection ,
ifnull(b.TenantNamesList ,'~') TenantNamesList ,
ifnull(b.TenantBusinessType ,'~') TenantBusinessType ,
ifnull(b.TenantGLLiability ,'~') TenantGLLiability ,
ifnull(b.InsuredOccupiedPortion ,'~') InsuredOccupiedPortion ,
ifnull(b.ValetParking ,'~') ValetParking ,
ifnull(b.LessorSqFt ,0) LessorSqFt ,
ifnull(b.BuildingRiskNumber ,0) BuildingRiskNumber ,
ifnull(b.MultiPolicyIndUmbrella ,'~') MultiPolicyIndUmbrella ,
ifnull(b.PoolInd ,'~') PoolInd ,
ifnull(b.StudsUpRenovation ,'~') StudsUpRenovation ,
ifnull(b.StudsUpRenovationCompleteYear ,'~') StudsUpRenovationCompleteYear ,
ifnull(b.MultiPolicyNumberUmbrella ,'~') MultiPolicyNumberUmbrella ,
ifnull(b.RCTMSBAmt ,'~') RCTMSBAmt ,
ifnull(b.RCTMSBHomeStyle ,'~') RCTMSBHomeStyle ,
ifnull(b.WINSOverrideNonSmokerDiscount ,'~') WINSOverrideNonSmokerDiscount ,
ifnull(b.WINSOverrideSeniorDiscount ,'~') WINSOverrideSeniorDiscount ,
ifnull(b.ITV ,0) ITV ,
ifnull(b.ITVDate ,'1900-01-01') ITVDate ,
ifnull(b.MSBReportType ,'~') MSBReportType ,
ifnull(b.VandalismDesiredInd ,'~') VandalismDesiredInd ,
ifnull(b.WoodShakeSiding ,'~') WoodShakeSiding ,
ifnull(b.CSEAgent ,'~') CSEAgent ,
ifnull(b.PropertyManager ,'~') PropertyManager ,
ifnull(b.RentersInsurance ,'~') RentersInsurance ,
ifnull(b.WaterDetectionDevice ,'~') WaterDetectionDevice ,
ifnull(b.AutoHomeInd ,'~') AutoHomeInd ,
ifnull(b.EarthquakeUmbrellaInd ,'~') EarthquakeUmbrellaInd ,
ifnull(b.LandlordInd ,'~') LandlordInd ,
ifnull(b.LossAssessment ,'~') LossAssessment ,
ifnull(b.GasShutOffInd ,'~') GasShutOffInd ,
ifnull(b.WaterDed ,'~') WaterDed ,
ifnull(b.ServiceLine ,'~') ServiceLine ,
ifnull(b.FunctionalReplacementCost ,'~') FunctionalReplacementCost ,
ifnull(b.MilesOfStreet ,'~') MilesOfStreet ,
ifnull(b.HOAExteriorStructure ,'~') HOAExteriorStructure ,
ifnull(b.RetailPortionDevelopment ,'~') RetailPortionDevelopment ,
ifnull(b.LightIndustrialType ,'~') LightIndustrialType ,
ifnull(b.LightIndustrialDescription ,'~') LightIndustrialDescription ,
ifnull(b.PoolCoverageLimit ,0) PoolCoverageLimit ,
ifnull(b.MultifamilyResidentialBuildings ,0) MultifamilyResidentialBuildings ,
ifnull(b.SinglefamilyDwellings ,0) SinglefamilyDwellings ,
ifnull(b.AnnualPayroll ,0) AnnualPayroll ,
ifnull(b.AnnualRevenue ,0) AnnualRevenue ,
ifnull(b.BedsOccupied ,'~') BedsOccupied ,
ifnull(b.EmergencyLighting ,'~') EmergencyLighting ,
ifnull(b.ExitSignsPosted ,'~') ExitSignsPosted ,
ifnull(b.FullTimeStaff ,'~') FullTimeStaff ,
ifnull(b.LicensedBeds ,'~') LicensedBeds ,
ifnull(b.NumberofFireExtinguishers ,0) NumberofFireExtinguishers ,
ifnull(b.OtherFireExtinguishers ,'~') OtherFireExtinguishers ,
ifnull(b.OxygenTanks ,'~') OxygenTanks ,
ifnull(b.PartTimeStaff ,'~') PartTimeStaff ,
ifnull(b.SmokingPermitted ,'~') SmokingPermitted ,
ifnull(b.StaffOnDuty ,'~') StaffOnDuty ,
ifnull(b.TypeofFireExtinguishers ,'~') TypeofFireExtinguishers ,
case when c_ADDRR.FullTermAmt is null then 'No' else 'Yes' end CovADDRR_SecondaryResidence,
ifnull(c_ADDRR.FullTermAmt,0) CovADDRRPrem_SecondaryResidence,
case when c_F31025.FullTermAmt is null then 'No' else 'Yes' end HODeluxe,
ifnull(a.Latitude,0) Latitude,
ifnull(a.Longitude,0) Longitude,
ifnull(b.WUIClass ,'~') WUIClass,
ifnull(al.CensusBlock,'~') CensusBlock,
ifnull(replace(b.WaterRiskScore,',',''),0) WaterRiskScore,
/*---2022-03-29 CA SFG NX2 DF3; US21484 for union all ---*/
ifnull(b.LandlordLossPreventionServices , '~' ) LandlordLossPreventionServices ,
ifnull(b.EnhancedWaterCoverage , '~' ) EnhancedWaterCoverage ,
ifnull(b.LandlordProperty , '~' ) LandlordProperty ,
ifnull(b.LiabilityExtendedToOthers , '~' ) LiabilityExtendedToOthers ,
ifnull(b.LossOfUseExtendedTime , '~' ) LossOfUseExtendedTime ,
ifnull(b.OnPremisesTheft , 0 ) OnPremisesTheft ,
ifnull(b.BedBugMitigation , '~' ) BedBugMitigation ,
ifnull(b.HabitabilityExclusion , '~' ) HabitabilityExclusion ,
ifnull(b.WildfireHazardPotential , '~' ) WildfireHazardPotential,
/*---2022-03-29 CA SFG Homeguard ---*/
ifnull(b.BackupOfSewersAndDrains,0) BackupOfSewersAndDrains,
ifnull(b.VegetationSetbackFt,0) VegetationSetbackFt,
ifnull(b.YardDebrisCoverageArea,0) YardDebrisCoverageArea,
ifnull(b.YardDebrisCoveragePercentage, '~') YardDebrisCoveragePercentage,
ifnull(b.CapeTrampoline, '~') CapeTrampoline,
ifnull(b.CapePool, '~') CapePool,
ifnull(b.RoofConditionRating, '~') RoofConditionRating,
ifnull(b.TrampolineInd, '~') TrampolineInd,
ifnull(b.PlumbingMaterial, '~') PlumbingMaterial,
ifnull(b.CentralizedHeating, '~') CentralizedHeating,
ifnull(b.FireDistrictSubscriptionCode, '~') FireDistrictSubscriptionCode,
ifnull(b.RoofCondition, '~') RoofCondition
from
tmp_scope_h s
join prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
join prodcse_dw.risk r
on r.SystemId=s.SystemId
and r.CMMContainer=s.CMMContainer
and r.TypeCd <> 'BuildingRisk'
join prodcse_dw.building b on
b.SystemId = s.SystemId
and b.ParentId = r.Id
and b.CMMContainer = s.CMMContainer
join prodcse_dw.addr a on
a.SystemId = s.SystemId
and a.ParentId = b.Id
and a.AddrTypeCd = 'RiskAddr'
and a.CMMContainer = s.CMMContainer
left outer join prodcse_dw.Coverage c_ADDRR
on c_ADDRR.SystemId=s.SystemId
and c_ADDRR.CMMContainer=s.CMMContainer
and c_ADDRR.ParentId=r.Id
and ifnull(c_ADDRR.Status,'Deleted')<>'Deleted'
and c_ADDRR.CoverageCd='ADDRR'
left outer join prodcse_dw.Coverage c_F31025
on c_F31025.SystemId=s.SystemId
and c_F31025.CMMContainer=s.CMMContainer
and c_F31025.ParentId=r.Id
and ifnull(c_F31025.Status,'Deleted')<>'Deleted'
and c_F31025.CoverageCd='F.31025'
left outer join prodcse_dw.addr al on
al.SystemId = s.SystemId
and al.ParentId = b.Id
and al.AddrTypeCd = 'RiskLookupAddr'
and al.CMMContainer = s.CMMContainer
and al.CensusBlock is not null
where
l.LineCD in ('Homeowners') and
ifnull(b.ParentId,'~') not like '%Veh%'
;
end
//


DELIMITER // 
drop procedure if exists `etl`.`sp_stg_vehicle`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_vehicle`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin

/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);
#Main Select 
select
Source_System as source_system
, sql_loadDate as LoadDate
, ifnull(s.PolicySystemId,s.SystemId) SystemId
, ifnull(s.BookDt,'1900-01-01') BookDt
, ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
, ifnull(s.PolicyRef,0) as policy_uniqueid
, v.Id SPInnVehicle_Id
, v.ParentId Risk_Uniqueid
, ifnull(r.TypeCd,'~') Risk_Type
, concat(cast(ifnull(s.PolicySystemId,s.SystemId) as char),'_',v.Id,'_',ifnull(vehidentificationnumber,'Unknown')) vehicle_uniqueid
, coalesce(r.Status,v.Status,'Unknown') Status
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.StateProvCd else a.StateProvCd end,'~') StateProvCd
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.County else a.County end,'~') County
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.PostalCode else a.PostalCode end,'~') PostalCode
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.City else a.City end,'~') City
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Addr1
else case when rtrim(concat(ifnull(a.PrimaryNumber,''),' ',ifnull(a.PreDirectional,''),' ',ifnull(a.StreetName,''),' ',ifnull(a.Suffix,'')))='' then null else rtrim(concat(ifnull(a.PrimaryNumber,''),' ',ifnull(a.PreDirectional,''),' ',ifnull(a.StreetName,''),' ',ifnull(a.Suffix,''))) end
end,'~') Addr1
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Addr2 else a.Addr2 end,'~') Addr2
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Latitude else a.Latitude end,0) Latitude
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then ga.Longitude else a.Longitude end,0) Longitude
, ifnull(case when ga.StateProvCd is not null and ga.PostalCode is not null and ga.City is not null and ga.Addr1 is not null then 'Yes' else 'No' end,'~') GaragAddrFlg
, coalesce( ga.PostalCode, a.PostalCode, '~') GaragPostalCode
, ifnull(case when ga.PostalCode is not null then 'Yes' else 'No' end,'~') GaragPostalCodeFlg
, ifnull( replace(replace(replace(v.Manufacturer,'"',''),'\r\n',' '),'\n',' ') , '~' ) as Manufacturer
, ifnull( replace(replace(replace(v.Model,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as Model
, ifnull( replace(replace(replace(v.ModelYr,'"',''),'\r\n',' '),'\n',' ') , '~' ) as ModelYr
, ifnull( replace(replace(replace(v.VehIdentificationNumber,'"',''),'\r\n',' '),'\n',' ') , '~' ) as VehIdentificationNumber
, ifnull( replace(replace(replace(v.ValidVinInd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as ValidVinInd
, ifnull( replace(replace(replace(v.VehLicenseNumber,'"','') ,'\r\n',' '),'\n',' '), '~' ) as VehLicenseNumber
, ifnull( replace(replace(replace(v.RegistrationStateProvCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RegistrationStateProvCd
, ifnull( replace(replace(replace(v.VehBodyTypeCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as VehBodyTypeCd
, ifnull( replace(replace(replace(v.PerformanceCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as PerformanceCd
, ifnull( replace(replace(replace(v.RestraintCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RestraintCd
, ifnull( replace(replace(replace(v.AntiBrakingSystemCd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as AntiBrakingSystemCd
, ifnull( replace(replace(replace(v.AntiTheftCd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as AntiTheftCd
, ifnull( replace(replace(replace(v.EngineSize,'"',''),'\r\n',' '),'\n',' ') , '~' ) as EngineSize
, ifnull( replace(replace(replace(v.EngineCylinders,'"','') ,'\r\n',' '),'\n',' '), '~' ) as EngineCylinders
, ifnull( replace(replace(replace(v.EngineHorsePower,'"',''),'\r\n',' '),'\n',' ') , '~' ) as EngineHorsePower
, ifnull( replace(replace(replace(v.EngineType,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as EngineType
, ifnull( replace(replace(replace(v.VehUseCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as VehUseCd
, ifnull( replace(replace(replace(v.GarageTerritory,'"',''),'\r\n',' '),'\n',' ') , 0 ) as GarageTerritory
, ifnull( replace(replace(replace(v.CollisionDed,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CollisionDed
, ifnull( replace(replace(replace(v.ComprehensiveDed,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as ComprehensiveDed
, ifnull( replace(replace(replace(v.StatedAmt,'"','') ,'\r\n',' '),'\n',' '), 0 ) as StatedAmt
, ifnull( replace(replace(replace(v.ClassCd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as ClassCd
, ifnull( replace(replace(replace(v.RatingValue,'"',''),'\r\n',' '),'\n',' ') , '~' ) as RatingValue
, ifnull( replace(replace(replace(v.CostNewAmt,'"',''),'\r\n',' ') ,'\n',' '), 0 ) as CostNewAmt
, ifnull( replace(replace(replace(v.EstimatedAnnualDistance,'"',''),'\r\n',' '),'\n',' ') , 0 ) as EstimatedAnnualDistance
, ifnull( replace(replace(replace(v.EstimatedWorkDistance,'"',''),'\r\n',' ') ,'\n',' '), 0 ) as EstimatedWorkDistance
, ifnull( replace(replace(replace(v.LeasedVehInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as LeasedVehInd
, CASE WHEN IFNULL(PurchaseDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(PurchaseDt,str_to_date('1900-01-01', '%Y-%c-%e')) end PurchaseDt
, ifnull( replace(replace(replace(v.StatedAmtInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as StatedAmtInd
, ifnull( replace(replace(replace(v.NewOrUsedInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as NewOrUsedInd
, ifnull( replace(replace(replace(v.CarPoolInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as CarPoolInd
, ifnull( replace(replace(replace(v.OdometerReading,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as OdometerReading
, ifnull( replace(replace(replace(v.WeeksPerMonthDriven,'"',''),'\r\n',' '),'\n',' ') , '~' ) as WeeksPerMonthDriven
, ifnull( replace(replace(replace(v.DaylightRunningLightsInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as DaylightRunningLightsInd
, ifnull( replace(replace(replace(v.PassiveSeatBeltInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as PassiveSeatBeltInd
, ifnull( replace(replace(replace(v.DaysPerWeekDriven,'"','') ,'\r\n',' '),'\n',' '), '~' ) as DaysPerWeekDriven
, ifnull( replace(replace(replace(v.UMPDLimit,'"','') ,'\r\n',' '),'\n',' '), '~' ) as UMPDLimit
, ifnull( replace(replace(replace(v.TowingAndLaborInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as TowingAndLaborInd
, ifnull( replace(replace(replace(v.RentalReimbursementInd,'"',''),'\r\n',' '),'\n',' ') , '~' ) as RentalReimbursementInd
, ifnull( replace(replace(replace(v.LiabilityWaiveInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as LiabilityWaiveInd
, ifnull( replace(replace(replace(v.RateFeesInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RateFeesInd
, ifnull( replace(replace(replace(v.OptionalEquipmentValue,'"',''),'\r\n',' ') ,'\n',' '), 0 ) as OptionalEquipmentValue
, ifnull( replace(replace(replace(v.CustomizingEquipmentInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CustomizingEquipmentInd
, ifnull( replace(replace(replace(v.CustomizingEquipmentDesc,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CustomizingEquipmentDesc
, ifnull( replace(replace(replace(v.InvalidVinAcknowledgementInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as InvalidVinAcknowledgementInd
, ifnull( replace(replace(replace(v.IgnoreUMPDWCDInd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as IgnoreUMPDWCDInd
, ifnull( replace(replace(replace(v.RecalculateRatingSymbolInd,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as RecalculateRatingSymbolInd
, ifnull( replace(replace(replace(v.ProgramTypeCd,'"','') ,'\r\n',' '),'\n',' '), '~' ) as ProgramTypeCd
, ifnull( replace(replace(replace(v.CMPRatingValue,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as CMPRatingValue
, ifnull( replace(replace(replace(v.COLRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as COLRatingValue
, ifnull( replace(replace(replace(v.LiabilityRatingValue,'"',''),'\r\n',' ') ,'\n',' '), '~' ) as LiabilityRatingValue
, ifnull( replace(replace(replace(v.MedPayRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as MedPayRatingValue
, ifnull( replace(replace(replace(v.RACMPRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RACMPRatingValue
, ifnull( replace(replace(replace(v.RACOLRatingValue,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RACOLRatingValue
, ifnull( replace(replace(replace(v.RABIRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RABIRatingSymbol
, ifnull( replace(replace(replace(v.RAPDRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RAPDRatingSymbol
, ifnull( replace(replace(replace(v.RAMedPayRatingSymbol,'"','') ,'\r\n',' '),'\n',' '), '~' ) as RAMedPayRatingSymbol
, ifnull( replace(replace(replace(v.EstimatedAnnualDistanceOverride,'"',''),'\r\n',' '),'\n',' '),0) as EstimatedAnnualDistanceOverride
, ifnull( replace(replace(replace(v.OriginalEstimatedAnnualMiles,'"',''),'\r\n',' '),'\n',' '),0) as OriginalEstimatedAnnualMiles
, ifnull( replace(replace(replace(v.ReportedMileageNonSave,'"',''),'\r\n',' '),'\n',' '),0) as ReportedMileageNonSave
, ifnull( replace(replace(replace(v.Mileage,'"',''),'\r\n',' '),'\n',' '), '~') as Mileage
, ifnull( replace(replace(replace(v.EstimatedNonCommuteMiles,'"',''),'\r\n',' '),'\n',' '),0) as EstimatedNonCommuteMiles
, ifnull( replace(replace(replace(v.TitleHistoryIssue,'"',''),'\r\n',' '),'\n',' '), '~') as TitleHistoryIssue
, ifnull( replace(replace(replace(v.OdometerProblems,'"',''),'\r\n',' '),'\n',' '), '~') as OdometerProblems
, ifnull( replace(replace(replace(v.Bundle,'"',''),'\r\n',' '),'\n',' '), '~') as Bundle
, ifnull( replace(replace(replace(v.LoanLeaseGap,'"',''),'\r\n',' '),'\n',' '), '~') as LoanLeaseGap
, ifnull( replace(replace(replace(v.EquivalentReplacementCost,'"',''),'\r\n',' '),'\n',' '), '~') as EquivalentReplacementCost
, ifnull( replace(replace(replace(v.OriginalEquipmentManufacturer,'"',''),'\r\n',' '),'\n',' '), '~') as OriginalEquipmentManufacturer
, ifnull( replace(replace(replace(v.OptionalRideshare,'"',''),'\r\n',' '),'\n',' '), '~') as OptionalRideshare
, ifnull( replace(replace(replace(v.MedicalPartsAccessibility,'"',''),'\r\n',' '),'\n',' '), '~') as MedicalPartsAccessibility
, ifnull( replace(replace(replace(v.VehNumber,'"','') ,'\r\n',' '),'\n',' '), 0 ) as VehNumber
, ifnull( replace(replace(replace(OdometerReadingPrior,'"',''),'\r\n',' '),'\n',' '), '~') as OdometerReadingPrior
, CASE WHEN IFNULL(ReportedMileageNonSaveDtPrior,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(ReportedMileageNonSaveDtPrior,str_to_date('1900-01-01', '%Y-%c-%e')) end ReportedMileageNonSaveDtPrior
, ifnull( replace(replace(replace(FullGlassCovInd,'"',''),'\r\n',' '),'\n',' '), '~') as FullGlassCovInd
, ifnull( replace(replace(replace(BoatLengthFeet,'"',''),'\r\n',' '),'\n',' '), '~') BoatLengthFeet
, ifnull( replace(replace(replace(MotorHorsePower,'"',''),'\r\n',' '),'\n',' '), '~') MotorHorsePower
, ifnull(replacementof ,0) replacementof
, CASE WHEN IFNULL(ReportedMileageNonSaveDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(ReportedMileageNonSaveDt,str_to_date('1900-01-01', '%Y-%c-%e')) end ReportedMileageNonSaveDt
, ifnull( replace(replace(replace(v.ManufacturerSymbol,'"',''),'\r\n',' '),'\n',' '), '~') ManufacturerSymbol
, ifnull( replace(replace(replace(v.ModelSymbol,'"',''),'\r\n',' '),'\n',' '), '~') ModelSymbol
, ifnull( replace(replace(replace(v.BodyStyleSymbol,'"',''),'\r\n',' '),'\n',' '), '~') BodyStyleSymbol
, ifnull( replace(replace(replace(v.SymbolCode,'"',''),'\r\n',' '),'\n',' '), '~') SymbolCode
#, ifnull( replace(replace(replace(v.VerifiedMileageOverride,'"',''),'\r\n',' '),'\n',' '), '~') VerifiedMileageOverride 
from tmp_scope s
# 
join prodcse_dw.Vehicle v
on v.SystemId=s.SystemId
and v.CMMContainer=s.CMMContainer
# 
join prodcse_dw.Risk r
on r.SystemId=s.SystemId
and v.ParentId=r.Id
and r.CMMContainer=s.CMMContainer
# 
join prodcse_dw.Addr a
on a.SystemId=s.SystemId
and a.cmmContainer=s.CMMContainer
and a.AddrTypeCd='InsuredLookupAddr'
# 
left outer join prodcse_dw.Addr ga
on ga.SystemId=s.SystemId
and ga.cmmContainer=s.CMMContainer
and ga.AddrTypeCd='VehicleGarageAddr'
and ga.ParentId=v.Id
where r.TypeCd='PrivatePassengerAuto';
end
//


DELIMITER // 
drop procedure if exists `etl`.`sp_stg_driver`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_driver`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);

#Driver points
drop temporary table if exists tmp_DriverPoints;
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
join prodcse_dw.DriverPoints dp
on s.SystemId=dp.SystemId
and s.CMMContainer=dp.CMMContainer
# 
join prodcse_dw.BasicPolicy bp
on s.SystemId=bp.SystemId
and s.CMMContainer=bp.CMMContainer
# 
join prodcse_dw.DriverInfo di
on s.SystemId=di.SystemId
and s.CMMContainer=di.CMMContainer
and di.Id=dp.ParentId
where dp.Status='Active'
and ifnull(dp.IgnoreInd,'No')='No'
group by
dp.SystemId
,dp.Parentid;
create index temp_systemidparentid_ind on tmp_DriverPoints (systemid, parentid);


select
Source_System as source_system,
sql_loadDate as LoadDate,
ifnull(s.PolicySystemId,s.SystemId) SystemId,
ifnull(s.BookDt,'1900-01-01') BookDt,
ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt,
ifnull(s.PolicyRef,0) as policy_uniqueid,
di.ParentId SPINNDriver_Id,
case
when upper(di.ParentId) like '%EXCL%' then
concat(cast(ifnull(s.PolicySystemId,s.SystemId) as char),'_',di.ParentId,'_',ifnull( parti.Status,'Deleted'),'_',cast(ifnull(di.drivernumber,0) as char),'_',DATE_FORMAT(ifnull(di.licensedt,'1900-01-01'),'%Y%m%d'),'_',DATE_FORMAT(ifnull(birthdt,'1900-01-01'),'%Y%m%d'))
else
concat(cast(ifnull(s.PolicySystemId,s.SystemId) as char),'_',di.ParentId,'_',ifnull(di.licensenumber,'Unknown'))
end Driver_UniqueId,
ifnull( parti.Status,'Deleted') Status,
ifnull(NI.GivenName,'~') FirstName ,
ifnull(NI.Surname,'~') LastName ,
ifnull( di.LicenseNumber , 'Unknown' ) LicenseNumber ,
CASE WHEN IFNULL(di.LicenseDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.LicenseDt,str_to_date('1900-01-01', '%Y-%c-%e')) end LicenseDt ,
ifnull( di.DriverInfoCd , '~' ) DriverInfoCd ,
ifnull( di.DriverNumber , 0 ) DriverNumber ,
case when parti.PartyTypeCd = 'NonDriverParty' then ifnull( di.DriverTypeCd , '~' ) else '~' end DriverTypeCd ,
ifnull( di.DriverStatusCd , '~' ) DriverStatusCd , ifnull( di.LicensedStateProvCd , '~' ) LicensedStateProvCd ,
ifnull( di.RelationshipToInsuredCd , '~' ) RelationshipToInsuredCd ,
ifnull( di.ScholasticDiscountInd , '~' ) ScholasticDiscountInd ,
ifnull( di.MVRRequestInd , '~' ) MVRRequestInd ,
CASE WHEN IFNULL(di.MVRStatusDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.MVRStatusDt,str_to_date('1900-01-01', '%Y-%c-%e')) end MVRStatusDt ,
ifnull( di.MVRStatus , '~' ) MVRStatus ,
ifnull( di.MatureDriverInd , '~' ) MatureDriverInd ,
ifnull( di.DriverTrainingInd , '~' ) DriverTrainingInd ,
ifnull( di.GoodDriverInd , '~' ) GoodDriverInd ,
CASE WHEN IFNULL(di.AccidentPreventionCourseCompletionDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.AccidentPreventionCourseCompletionDt,str_to_date('1900-01-01', '%Y-%c-%e')) end AccidentPreventionCourseCompletionDt ,
CASE WHEN IFNULL(di.DriverTrainingCompletionDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.DriverTrainingCompletionDt,str_to_date('1900-01-01', '%Y-%c-%e')) end DriverTrainingCompletionDt ,
ifnull( di.AccidentPreventionCourseInd , '~' ) AccidentPreventionCourseInd ,
CASE WHEN IFNULL(di.ScholasticCertificationDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.ScholasticCertificationDt,str_to_date('1900-01-01', '%Y-%c-%e')) end ScholasticCertificationDt ,
ifnull( di.ActiveMilitaryInd , '~' ) ActiveMilitaryInd ,
ifnull( di.PermanentLicenseInd , '~' ) PermanentLicenseInd ,
ifnull( di.NewToStateInd , '~' ) NewToStateInd ,
ifnull( persi.PersonTypeCd , '~' ) PersonTypeCd ,
ifnull( persi.GenderCd , '~' ) GenderCd ,
CASE WHEN IFNULL(BirthDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(BirthDt,str_to_date('1900-01-01', '%Y-%c-%e')) end BirthDt ,
ifnull( persi.MaritalStatusCd , '~' ) MaritalStatusCd ,
ifnull( persi.OccupationClassCd , '~' ) OccupationClassCd ,
ifnull( persi.PositionTitle , '~' ) PositionTitle ,
ifnull( persi.CurrentResidenceCd , '~' ) CurrentResidenceCd ,
ifnull( persi.CivilServantInd , '~' ) CivilServantInd ,
ifnull( persi.RetiredInd , '~' ) RetiredInd ,
CASE WHEN IFNULL(di.NewTeenExpirationDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.NewTeenExpirationDt,str_to_date('1900-01-01', '%Y-%c-%e')) end NewTeenExpirationDt ,
ifnull(SR22FeeInd, '~' ) SR22FeeInd ,
CASE WHEN IFNULL(di.MatureCertificationDt,str_to_date('1900-01-01', '%Y-%c-%e'))<str_to_date('1900-01-01', '%Y-%c-%e') THEN str_to_date('1900-01-01', '%Y-%c-%e') ELSE IFNULL(di.MatureCertificationDt,str_to_date('1900-01-01', '%Y-%c-%e')) end MatureCertificationDt ,
cast(case
when AgeFirstLicensed is null then 0
when AgeFirstLicensed regexp ('[^.0-9\-]')=1 then etl.get_numeric(AgeFirstLicensed)
else AgeFirstLicensed
end as unsigned) AgeFirstLicensed,
etl.ifempty(AttachedVehicleRef, '~' ) AttachedVehicleRef
-- 
,ifnull(VIOL_PointsChargedTerm,0) VIOL_PointsChargedTerm
,ifnull(ACCI_PointsChargedTerm,0) ACCI_PointsChargedTerm
,ifnull(SUSP_PointsChargedTerm,0) SUSP_PointsChargedTerm
,ifnull(Other_PointsChargedTerm,0) Other_PointsChargedTerm
,ifnull(GoodDriverPoints_chargedterm,0) GoodDriverPoints_chargedterm
-- 
from
tmp_scope s
join prodcse_dw.DriverInfo di
on di.SystemId=s.SystemId
and di.CMMContainer=s.CMMContainer
left outer join prodcse_dw.PartyInfo parti
on parti.SystemId=s.SystemId
and parti.CMMContainer=s.CMMContainer
and di.ParentId = parti.id
and parti.PartyTypeCd in ('DriverParty','NonDriverParty' )
left outer join prodcse_dw.NameInfo as NI
on NI.SystemId = s.Systemid
and NI.CMMContainer = s.CMMContainer
and NI.ParentId = parti.id
and NI.NameTypeCd = 'ContactName'
left outer join prodcse_dw.PersonInfo persi
on persi.SystemId=s.SystemId
and persi.CMMContainer=s.CMMContainer
and persi.PersonTypeCD='ContactPersonal'
and persi.ParentId = di.ParentId
left outer join tmp_DriverPoints dp
on dp.SystemId=s.SystemId
and dp.ParentId=di.Id ;
end
//


DELIMITER // 
drop procedure if exists `etl`.`sp_stg_risk_coverage`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_risk_coverage`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin
/* 1. Scope - full or historical (f,h - any) catch up (c) or daily load (d)*/
/* 2. Load is based on cmmContainer Application with populated or not PolicyRef
* All new quotes (New Business) are included in the scope and approved all other applications 
* 3. Not safe to use xxchangedbeans in Aurora and UpdateTimestamp is varchar
* */
drop temporary table if exists tmp_scope;

if LoadType='d' then
create temporary table tmp_scope
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.xxchangedbeans cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

else

create temporary table tmp_scope as
/*Only NOT approved New Business Applications*/
select
cb.SystemId,
cb.cmmContainer,
null PolicySystemId,
null PolicyRef,
null BookDt,
null TransactionEffectiveDt
from prodcse_dw.application cb
join prodcse_dw.BasicPolicy bp
on cb.SystemId=bp.SystemId
and cb.cmmContainer=bp.cmmContainer
left outer join etl.stg_policyhistory h
on cb.SystemId=h.SystemId
where cb.cmmContainer='Application'
and bp.TransactionCd='New Business'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day)
and h.PolicyRef is null
union all
/*All approved quotes*/
select
case when h.SystemId=h.maxSystemId then h.PolicyRef else h.SystemId end SystemId,
case when h.SystemId=h.maxSystemId then 'Policy' else 'Application' end cmmContainer,
h.SystemId PolicySystemId,
h.PolicyRef,
h.BookDt,
h.TransactionEffectiveDt
from etl.stg_policyhistory h
where h.BookDt > sql_bookDate and h.BookDt <= sql_currentDate;

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);



drop table if exists tmp_coverage;
create temporary table tmp_coverage as
select
ifnull(s.PolicySystemId,s.SystemId) SystemId
,ifnull(s.BookDt,'1900-01-01') BookDt
,ifnull(s.TransactionEffectiveDt,'1900-01-01') TransactionEffectiveDt
,ifnull(s.PolicyRef,0) as policy_uniqueid
,c.ParentId Risk_Uniqueid
,c.CoverageCd
,cm.covx_code
,cm.covx_description
,ifnull(c.FullTermAmt,0) FullTermAmt
,ifnull(l1.Value,0) Limit1
,ifnull(l2.Value,0) Limit2
,ifnull(d1.Value,0) Deductible1
,ifnull(d2.Value,0) Deductible2
from prodcse_dw.Coverage c
join tmp_scope s
on s.SystemId=c.SystemId
and s.cmmContainer=c.cmmContainer
join prodcse_dw.Line l
on l.SystemId=s.SystemId
and l.CMMContainer=s.CMMContainer
left outer join prodcse_dw.limit l1
on c.SystemId=l1.SystemId
and c.cmmContainer=l1.cmmContainer
and c.Id=l1.ParentId
and l1.LimitCd='Limit1'
left outer join prodcse_dw.limit l2
on c.SystemId=l2.SystemId
and c.cmmContainer=l2.cmmContainer
and c.Id=l2.ParentId
and l2.LimitCd='Limit2'
left outer join prodcse_dw.Deductible d1
on c.SystemId=d1.SystemId
and c.cmmContainer=d1.cmmContainer
and c.Id=d1.ParentId
and d1.DeductibleCd='Deductible1'
left outer join prodcse_dw.Deductible d2
on c.SystemId=d2.SystemId
and c.cmmContainer=d2.cmmContainer
and c.Id=d2.ParentId
and d2.DeductibleCd='Deductible2'
join etl.coverage_mapping cm
on c.CoverageCd=cm.CoverageCd
where c.Status='Active'
and l.LineCD in ('Dwelling','Homeowners')
;

select
Source_System as source_system,
sql_loadDate as LoadDate,
SystemId,
BookDt,
TransactionEffectiveDt,
policy_uniqueid,
Risk_uniqueid,
max(case when covx_code='CovA' then Limit1 else 0 end) as CovA_Limit1,
max(case when covx_code='CovA' then Limit2 else 0 end) as CovA_Limit2,
max(case when covx_code='CovA' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as CovA_Deductible1,
max(case when covx_code='CovA' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as CovA_Deductible2,
max(case when covx_code='CovA' then FullTermAmt else 0 end) as CovA_FullTermAmt,
max(case when covx_code='CovB' then Limit1 else 0 end) as CovB_Limit1,
max(case when covx_code='CovB' then Limit2 else 0 end) as CovB_Limit2,
max(case when covx_code='CovB' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as CovB_Deductible1,
max(case when covx_code='CovB' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as CovB_Deductible2,
max(case when covx_code='CovB' then FullTermAmt else 0 end) as CovB_FullTermAmt,
max(case when covx_code='CovC' then Limit1 else 0 end) as CovC_Limit1,
max(case when covx_code='CovC' then Limit2 else 0 end) as CovC_Limit2,
max(case when covx_code='CovC' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as CovC_Deductible1,
max(case when covx_code='CovC' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as CovC_Deductible2,
max(case when covx_code='CovC' then FullTermAmt else 0 end) as CovC_FullTermAmt,
max(case when covx_code='CovD' then Limit1 else 0 end) as CovD_Limit1,
max(case when covx_code='CovD' then Limit2 else 0 end) as CovD_Limit2,
max(case when covx_code='CovD' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as CovD_Deductible1,
max(case when covx_code='CovD' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as CovD_Deductible2,
max(case when covx_code='CovD' then FullTermAmt else 0 end) as CovD_FullTermAmt,
max(case when covx_code='CovE' then Limit1 else 0 end) as CovE_Limit1,
max(case when covx_code='CovE' then Limit2 else 0 end) as CovE_Limit2,
max(case when covx_code='CovE' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as CovE_Deductible1,
max(case when covx_code='CovE' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as CovE_Deductible2,
max(case when covx_code='CovE' then FullTermAmt else 0 end) as CovE_FullTermAmt,
max(case when covx_code='BEDBUG' then Limit1 else 0 end) as BEDBUG_Limit1,
max(case when covx_code='BEDBUG' then Limit2 else 0 end) as BEDBUG_Limit2,
max(case when covx_code='BEDBUG' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as BEDBUG_Deductible1,
max(case when covx_code='BEDBUG' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as BEDBUG_Deductible2,
max(case when covx_code='BEDBUG' then FullTermAmt else 0 end) as BEDBUG_FullTermAmt,
max(case when covx_code='BOLAW' then Limit1 else 0 end) as BOLAW_Limit1,
max(case when covx_code='BOLAW' then Limit2 else 0 end) as BOLAW_Limit2,
max(case when covx_code='BOLAW' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as BOLAW_Deductible1,
max(case when covx_code='BOLAW' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as BOLAW_Deductible2,
max(case when covx_code='BOLAW' then FullTermAmt else 0 end) as BOLAW_FullTermAmt,
max(case when covx_code='COC' then Limit1 else 0 end) as COC_Limit1,
max(case when covx_code='COC' then Limit2 else 0 end) as COC_Limit2,
max(case when covx_code='COC' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as COC_Deductible1,
max(case when covx_code='COC' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as COC_Deductible2,
max(case when covx_code='COC' then FullTermAmt else 0 end) as COC_FullTermAmt,
max(case when covx_code='EQPBK' then Limit1 else 0 end) as EQPBK_Limit1,
max(case when covx_code='EQPBK' then Limit2 else 0 end) as EQPBK_Limit2,
max(case when covx_code='EQPBK' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as EQPBK_Deductible1,
max(case when covx_code='EQPBK' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as EQPBK_Deductible2,
max(case when covx_code='EQPBK' then FullTermAmt else 0 end) as EQPBK_FullTermAmt,
max(case when covx_code='FRAUD' then Limit1 else 0 end) as FRAUD_Limit1,
max(case when covx_code='FRAUD' then Limit2 else 0 end) as FRAUD_Limit2,
max(case when covx_code='FRAUD' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as FRAUD_Deductible1,
max(case when covx_code='FRAUD' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as FRAUD_Deductible2,
max(case when covx_code='FRAUD' then FullTermAmt else 0 end) as FRAUD_FullTermAmt,
max(case when covx_code='H051ST0' then Limit1 else 0 end) as H051ST0_Limit1,
max(case when covx_code='H051ST0' then Limit2 else 0 end) as H051ST0_Limit2,
max(case when covx_code='H051ST0' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as H051ST0_Deductible1,
max(case when covx_code='H051ST0' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as H051ST0_Deductible2,
max(case when covx_code='H051ST0' then FullTermAmt else 0 end) as H051ST0_FullTermAmt,
max(case when covx_code='HO5' then Limit1 else 0 end) as HO5_Limit1,
max(case when covx_code='HO5' then Limit2 else 0 end) as HO5_Limit2,
max(case when covx_code='HO5' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as HO5_Deductible1,
max(case when covx_code='HO5' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as HO5_Deductible2,
max(case when covx_code='HO5' then FullTermAmt else 0 end) as HO5_FullTermAmt,
max(case when covx_code='INCB' then Limit1 else 0 end) as INCB_Limit1,
max(case when covx_code='INCB' then Limit2 else 0 end) as INCB_Limit2,
max(case when covx_code='INCB' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as INCB_Deductible1,
max(case when covx_code='INCB' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as INCB_Deductible2,
max(case when covx_code='INCB' then FullTermAmt else 0 end) as INCB_FullTermAmt,
max(case when covx_code='INCC' then Limit1 else 0 end) as INCC_Limit1,
max(case when covx_code='INCC' then Limit2 else 0 end) as INCC_Limit2,
max(case when covx_code='INCC' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as INCC_Deductible1,
max(case when covx_code='INCC' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as INCC_Deductible2,
max(case when covx_code='INCC' then FullTermAmt else 0 end) as INCC_FullTermAmt,
max(case when covx_code='LAC' then Limit1 else 0 end) as LAC_Limit1,
max(case when covx_code='LAC' then Limit2 else 0 end) as LAC_Limit2,
max(case when covx_code='LAC' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as LAC_Deductible1,
max(case when covx_code='LAC' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as LAC_Deductible2,
max(case when covx_code='LAC' then FullTermAmt else 0 end) as LAC_FullTermAmt,
max(case when covx_code='MEDPAY' then Limit1 else 0 end) as MEDPAY_Limit1,
max(case when covx_code='MEDPAY' then Limit2 else 0 end) as MEDPAY_Limit2,
max(case when covx_code='MEDPAY' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as MEDPAY_Deductible1,
max(case when covx_code='MEDPAY' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as MEDPAY_Deductible2,
max(case when covx_code='MEDPAY' then FullTermAmt else 0 end) as MEDPAY_FullTermAmt,
max(case when covx_code='OccupationDiscount' then Limit1 else 0 end) as OccupationDiscount_Limit1,
max(case when covx_code='OccupationDiscount' then Limit2 else 0 end) as OccupationDiscount_Limit2,
max(case when covx_code='OccupationDiscount' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as OccupationDiscount_Deductible1,
max(case when covx_code='OccupationDiscount' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as OccupationDiscount_Deductible2,
max(case when covx_code='OccupationDiscount' then FullTermAmt else 0 end) as OccupationDiscount_FullTermAmt,
max(case when covx_code='OLT' then Limit1 else 0 end) as OLT_Limit1,
max(case when covx_code='OLT' then Limit2 else 0 end) as OLT_Limit2,
max(case when covx_code='OLT' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as OLT_Deductible1,
max(case when covx_code='OLT' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as OLT_Deductible2,
max(case when covx_code='OLT' then FullTermAmt else 0 end) as OLT_FullTermAmt,
max(case when covx_code='PIHOM' then Limit1 else 0 end) as PIHOM_Limit1,
max(case when covx_code='PIHOM' then Limit2 else 0 end) as PIHOM_Limit2,
max(case when covx_code='PIHOM' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as PIHOM_Deductible1,
max(case when covx_code='PIHOM' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as PIHOM_Deductible2,
max(case when covx_code='PIHOM' then FullTermAmt else 0 end) as PIHOM_FullTermAmt,
max(case when covx_code='PPREP' then Limit1 else 0 end) as PPREP_Limit1,
max(case when covx_code='PPREP' then Limit2 else 0 end) as PPREP_Limit2,
max(case when covx_code='PPREP' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as PPREP_Deductible1,
max(case when covx_code='PPREP' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as PPREP_Deductible2,
max(case when covx_code='PPREP' then FullTermAmt else 0 end) as PPREP_FullTermAmt,
max(case when covx_code='PRTDVC' then Limit1 else 0 end) as PRTDVC_Limit1,
max(case when covx_code='PRTDVC' then Limit2 else 0 end) as PRTDVC_Limit2,
max(case when covx_code='PRTDVC' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as PRTDVC_Deductible1,
max(case when covx_code='PRTDVC' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as PRTDVC_Deductible2,
max(case when covx_code='PRTDVC' then FullTermAmt else 0 end) as PRTDVC_FullTermAmt,
max(case when covx_code='SeniorDiscount' then Limit1 else 0 end) as SeniorDiscount_Limit1,
max(case when covx_code='SeniorDiscount' then Limit2 else 0 end) as SeniorDiscount_Limit2,
max(case when covx_code='SeniorDiscount' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as SeniorDiscount_Deductible1,
max(case when covx_code='SeniorDiscount' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as SeniorDiscount_Deductible2,
max(case when covx_code='SeniorDiscount' then FullTermAmt else 0 end) as SeniorDiscount_FullTermAmt,
max(case when covx_code='SEWER' then Limit1 else 0 end) as SEWER_Limit1,
max(case when covx_code='SEWER' then Limit2 else 0 end) as SEWER_Limit2,
max(case when covx_code='SEWER' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as SEWER_Deductible1,
max(case when covx_code='SEWER' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as SEWER_Deductible2,
max(case when covx_code='SEWER' then FullTermAmt else 0 end) as SEWER_FullTermAmt,
max(case when covx_code='SPP' then Limit1 else 0 end) as SPP_Limit1,
max(case when covx_code='SPP' then Limit2 else 0 end) as SPP_Limit2,
max(case when covx_code='SPP' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as SPP_Deductible1,
max(case when covx_code='SPP' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as SPP_Deductible2,
max(case when covx_code='SPP' then FullTermAmt else 0 end) as SPP_FullTermAmt,
max(case when covx_code='SRORP' then Limit1 else 0 end) as SRORP_Limit1,
max(case when covx_code='SRORP' then Limit2 else 0 end) as SRORP_Limit2,
max(case when covx_code='SRORP' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as SRORP_Deductible1,
max(case when covx_code='SRORP' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as SRORP_Deductible2,
max(case when covx_code='SRORP' then FullTermAmt else 0 end) as SRORP_FullTermAmt,
max(case when covx_code='THEFA' then Limit1 else 0 end) as THEFA_Limit1,
max(case when covx_code='THEFA' then Limit2 else 0 end) as THEFA_Limit2,
max(case when covx_code='THEFA' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as THEFA_Deductible1,
max(case when covx_code='THEFA' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as THEFA_Deductible2,
max(case when covx_code='THEFA' then FullTermAmt else 0 end) as THEFA_FullTermAmt,
max(case when covx_code='UTLDB' then Limit1 else 0 end) as UTLDB_Limit1,
max(case when covx_code='UTLDB' then Limit2 else 0 end) as UTLDB_Limit2,
max(case when covx_code='UTLDB' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as UTLDB_Deductible1,
max(case when covx_code='UTLDB' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as UTLDB_Deductible2,
max(case when covx_code='UTLDB' then FullTermAmt else 0 end) as UTLDB_FullTermAmt,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then Limit1 else 0 end) as WCINC_Limit1,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then Limit2 else 0 end) as WCINC_Limit2,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as WCINC_Deductible1,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as WCINC_Deductible2,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation' then FullTermAmt else 0 end) as WCINC_FullTermAmt,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then Limit1 else 0 end) as WCINC_Limit1_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then Limit2 else 0 end) as WCINC_Limit2_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' and Deductible1 regexp ('[0-9]')<>0 then Deductible1 else 0 end) as WCINC_Deductible1_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' and Deductible2 regexp ('[0-9]')<>0 then Deductible2 else 0 end) as WCINC_Deductible2_o,
max(case when covx_code='WCINC' and covx_description ='Workers Compensation - Occasional Employee' then FullTermAmt else 0 end) as WCINC_FullTermAmt_o
from tmp_coverage
group by
SystemId,
BookDt,
TransactionEffectiveDt,
policy_uniqueid,
Risk_uniqueid;




end
//


DELIMITER // 
drop procedure if exists `etl`.`sp_stg_claim`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_claim`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100))
begin
/*0. Claims processed in the period*/
drop temporary table if exists tmp_stg_claim;
create temporary table tmp_stg_claim
select distinct ClaimRef
from prodcse.ClaimStats
where BookDt > sql_bookDate and BookDt <= sql_currentDate;

CREATE INDEX idx_tmp ON tmp_stg_claim(ClaimRef);

/*1. Join ClaimRef, PolicyRef, Risk Id and Policy SystemId 
* Policy SystemId based on max Policy Transaction Effective Date less then Claim Loss date
* or just first Policy SystemId in the term 
* if there is wrong PolicyRef or Loss Date 
* (beyond PolicyRef term effective - expiration range)*/
drop temporary table if exists tmp_claim_policyrisk;
create temporary table tmp_claim_policyrisk as
select
cl.SystemId ClaimRef,
p.PolicyRef,
r.RiskIdRef,
r.RiskNumber,
coalesce(max(h.SystemId),min(h_p.SystemId)) PolicySystemId
from tmp_stg_claim cs
join prodcse_dw.Claim cl
on cs.ClaimRef=cl.SystemId
join prodcse_dw.PolicyRisk r
on cl.SystemId = r.SystemId
and cl.CMMContainer = r.CMMContainer
and cl.RiskIdRef=r.Id
join prodcse_dw.ClaimPolicyInfo p
on cl.SystemId = p.SystemId
and cl.CMMContainer = p.CMMContainer
and cl.Id=p.ParentId
left outer join etl.stg_policyhistory h
on p.PolicyRef=h.PolicyRef
and cl.LossDt>=h.TransactionEffectiveDt
left outer join etl.stg_policyhistory h_p
on p.PolicyRef=h_p.PolicyRef
where cl.CMMContainer='Claim'
and cl.TypeCd = 'Claim'
group by
cl.SystemId,
p.PolicyRef,
r.RiskNumber,
r.RiskIdRef;

CREATE INDEX idx_tmp ON tmp_claim_policyrisk(ClaimRef);

select
Source_System as source_system,
sql_loadDate as LoadDate,
cast(concat(rtrim(ltrim(cast(cs.TransactionNumber as CHAR))),rtrim(ltrim(cs.ClaimantCd)),
rtrim(ltrim(cast(cs.ClaimantTransactionNumber as CHAR)))) as unsigned) as clm_sequence
/*
, concat(right(concat('000000000' , rtrim(ltrim(cast(cs.ClaimRef as CHAR)))),9),'-'
,right(concat('000' , cast(cs.ClaimantCd as char)),3),'-'
,right(concat(' ',ifnull(cs.RiskCd,'')),3),'-'
,cs.FeatureCd,'-'
,cs.ReserveCd) as claim_uniqueID
*/
,concat(cast(cs.ClaimRef as CHAR),'-'
,cast(cs.ClaimantCd as char),'-'
,cs.FeatureCd
) as claim_uniqueID
, r.policyRef as policy_uniqueID
, r.PolicySystemId
, ifnull(r.RiskIdRef,'Unknown') as primaryrisk_uniqueID
, ifnull(cl.DriverIdRef,'Unknown') as secondaryrisk_uniqueID
, cast(case cs.LineCd when 'Liability' then 'BusinessOwner' else cs.LineCd end as char) linecd
, cs.FeatureCd as CoverageCd
, ifnull(cs.CoverageItemCd,'~') CoverageItemCd
, ifnull(ifnull(cs.RiskCd,lpad(r.RiskNumber,3,'0')),'~') RiskCd
, concat(ct.ID,rtrim(ltrim(cast(cs.ClaimNumber as CHAR))),'-',rtrim(ltrim(cast(cast(cs.ClaimantCd as unsigned) as CHAR)))) as claimant_uniqueID
, AdjusterProviderCd as adjuster_uniqueID
, lpad(cs.ClaimNumber,8,'0') as clm_claimNumber
, concat(ifnull(rtrim(ltrim(cast(cs.FeatureCd as CHAR))),'---') ,rtrim(ltrim(cast(cs.ClaimantCd as CHAR))),'-',ifnull(cs.RiskCd,'---'),'-',rtrim(ltrim(cs.ReserveCd))) as clm_featureNumber
, date_format(cl.LossDt,'%Y-%m-%d') as clm_dateOfLoss
, date_format(cs.ReportDt,'%Y-%m-%d') as clm_lossReportedDate
, case when left(cs.ReserveStatusCd,6) ='Closed' and ReserveStatusChgInd ='true'
then cast(cs.BookDt as datetime) else cast('1900-01-01' as datetime)
end as clm_closedDate
, case rtrim(ltrim(cs.ReserveStatusCd))
when 'Reopen' then 'O'
when 'Open' then 'O'
when 'Closed' then 'C'
end as clm_claimStatusCD
, case rtrim(ltrim(cs.ReserveStatusCd))
when 'Reopen' then 'REO'
when 'Open' then '~'
when 'Closed' then '~'
else '~'
end as clm_substatusCD
, cs.ReserveChangeAmt
, ifnull(a.County,'~') clm_county
, ifnull(a.City,'~') clm_city
, ifnull(a.StateProvCd,'~') clm_state
, left(ifnull(a.PostalCode,'~'),5) clm_postalCode
, cs.BookDt as clm_changeDate
,ifnull(Addr1,'~') CLM_ADDRESS1
,ifnull(Addr2,'~') CLM_ADDRESS2
,case when cs.LineCd = 'PersonalAuto' and cs.AnnualStatementLineCd = '051' then '211' else cs.AnnualStatementLineCd end as AnnualStatementLineCd
,cs.SublineCd
,replace(concat(cast(cs.policyRef as char) , '-'
,ifnull(case cs.LineCd when 'Liability' then 'BusinessOwner' else cs.LineCd end,'~') , '-'
,ifnull(cs.RiskCd,'~') , '-'
,ifnull(cs.FeatureCd,'~') , '-'
,ifnull(cs.CoverageItemCd,'~') , '-'
,ifnull(cs.RateAreaName,'~') , '-'
,ifnull(case when cs.LineCd = 'PersonalAuto' and cs.AnnualStatementLineCd = '051' then '211' else cs.AnnualStatementLineCd end,'~') , '-'
,ifnull(cs.SublineCd,'~'), '-'
,ifnull(cs.Deductible,'~'), '-'
,ifnull(cs.`limit`,'~'), '-~-~'
),' ','~') as coverage_uniqueid
-- 
, ifnull(cs.CarrierCd,'~') as CarrierCd
, ifnull(cs.CompanyCd,'~') as CompanyCd
, ifnull(cs.CarrierGroupCd,'~') as CarrierGroupCd
, ifnull(cs.ClaimantCd,'~') as ClaimantCd
, ifnull(cs.FeatureCd,'~') as FeatureCd
, ifnull(cs.FeatureSubCd,'~') as FeatureSubCd
, ifnull(cs.FeatureTypeCd,'~') as FeatureTypeCd
, ifnull(cs.ReserveCd,'~') as ReserveCd
, ifnull(cs.ReserveTypeCd,'~') as ReserveTypeCd
, ifnull(cl.AtFaultCd,'~') as AtFaultCd
, ifnull(cl.SourceCd,'~') as SourceCd
, ifnull(cl.CategoryCd,'~') as CategoryCd
, ifnull(cl.LossCauseCd,'~') as LossCauseCd
, ifnull(REPLACE(cl.ReportedTo,'|','/'),'~') as ReportedTo
, ifnull(REPLACE(cl.ReportedBy,'|','/'),'~') as ReportedBy
, ifnull(cl.DamageDesc,'~') as DamageDesc
, ifnull(cl.ShortDesc,'~') as ShortDesc
, ifnull(cl.Description,'~') as Description
, ifnull(cl.Comment,'~') as Comment
, ifnull(ca.CatastropheNumber,'Unknown') as clm_catCode
, ifnull(ca.Description,'~')as clm_catDescription
, ifnull(pd.TotalLossInd,'No') as TotalLossInd
, ifnull(pd.SalvageOwnerRetainedInd,'No') as SalvageOwnerRetainedInd
, ifnull(cl.SuitFiledInd,'No') as SuitFiledInd
, ifnull(cl.InSIUInd,'No') as InSIUInd
, ifnull(cl.SubLossCauseCd,'No') as SubLossCauseCd
, ifnull(cl.LossCauseSeverity,'~') as LossCauseSeverity
, ifnull(cl.NegligencePct,0) as NegligencePct
, ifnull(cl.EmergencyService,'~') as EmergencyService
, ifnull(cl.EmergencyServiceVendor,'~') as EmergencyServiceVendor
, ifnull(cl.OccurSite, '~') as OccurSite
, ifnull(cl.ForRecordOnlyInd, '~') as ForRecordOnlyInd
from prodcse.ClaimStats cs
--
join prodcse_dw.Claimant ct
on ct.SystemId=cs.ClaimRef
and ct.ClaimantNumber=cast(cs.ClaimantCd as unsigned)
and ct.CMMContainer='Claim'
--
join prodcse_dw.Claim cl
on cl.SystemId=cs.ClaimRef
and cl.CMMContainer='Claim'
and cl.TypeCd='Claim'
--
join tmp_claim_policyrisk r
on cs.ClaimRef = r.ClaimRef
--
left outer join prodcse_dw.addr a
on cs.ClaimRef=a.SystemId
and a.AddrTypeCd = 'LossLocationAddr'
and a.CMMContainer='Claim'
--
left outer join prodcse_dw.PropertyDamaged pd
on cl.systemid=pd.systemid
and cl.CMMContainer=pd.CMMContainer
and ct.ID=pd.ParentId
and pd.TotalLossInd='Yes'
--
left join prodcse_dw.catastrophe ca
on cl.CatastropheRef = ca.SystemId
and ca.CMMContainer='Catastrophe'
--
order by clm_claimnumber, clm_changedate, clm_sequence;

end//

DELIMITER // 
drop procedure if exists `etl`.`sp_stg_reservestatus`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_reservestatus`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100))
begin

SELECT
Source_System as source_system,
sql_loadDate as LoadDate
, concat(cast(c.SystemId as CHAR),'-'
,right(concat('000' ,cast(IFNULL(cmtRef.ClaimantNumber, cmt.ClaimantNumber) as char)),3),'-'
,fa.FeatureCd
) as claim_uniqueID
, ra.ReserveCd
, ra.StatusCd ReserveStatus
, cmntt.TransactionNumber
, cmntt.BookDt
FROM prodcse_dw.claim c
INNER JOIN prodcse_dw.claimant cmt
ON cmt.SystemId = c.SystemId
AND cmt.ParentId = c.Id
INNER JOIN prodcse_dw.claimanttransaction cmntt
ON cmntt.SystemId = c.SystemId
AND cmntt.ParentId = cmt.Id
INNER JOIN prodcse_dw.featureallocation fa
ON fa.SystemId = cmntt.SystemId
AND fa.ParentId = cmntt.Id
INNER JOIN prodcse_dw.reserveallocation ra
ON ra.SystemId = fa.SystemId
AND ra.ParentId = fa.Id
LEFT JOIN prodcse_dw.claimant cmtRef
ON cmtRef.SystemId = cmt.SystemId
AND cmtRef.Id = cmt.ClaimantLinkIdRef
WHERE c.StatusCd <> 'Deleted'
and ra.StatusCd is not null
and c.CMMContainer='Claim'
and c.TypeCd='Claim'
and cmntt.BookDt >sql_bookDate AND cmntt.BookDt <= sql_currentDate;
end//


DELIMITER //
drop procedure if exists `etl`.`sp_stg_producer` //
CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_producer`( sql_loadDate varchar(50), Source_System varchar(100))
begin

drop temporary table if exists na;
create temporary table na as (
select distinct
SystemId
from prodcse_dw.LicensedProduct lp
where lp.cmmContainer='Provider'
/*not active but may have somet other product acrive*/
and ifnull(lp.StatusCd,'~')<>'Active'
);

drop temporary table if exists a;
create temporary table a as (
select distinct
SystemId
from prodcse_dw.LicensedProduct lp
where lp.cmmContainer='Provider'
and ifnull(lp.StatusCd,'~')='Active'
);

/*no except or minus in Aurora*/
drop temporary table if exists tmp;
create temporary table tmp as
select na.SystemId,
max(NewExpirationDt) latest_NewExpirationDt
from na /*not active but may have somet other product acrive*/
left outer join a /*active*/
on a.SystemId=na.SystemId
join prodcse_dw.LicensedProduct lp
on lp.SystemId=na.SystemId
where lp.cmmContainer='Provider'
and a.SystemId is null /*excluding active*/
group by na.SystemId;


select
Source_System as source_system,
sql_loadDate as LoadDate,
p.ProviderNumber as producer_uniqueid ,
p.ProviderNumber as producer_number ,
etl.ifempty(ni.CommercialName,'~') as producer_name ,
etl.ifempty(pri.LicenseNo,'~') as LicenseNo ,
etl.ifempty(pri.ProducerTypeCd,'~') as agency_type,
etl.ifempty(concat(ac.BestAddr1, ' ', ac.BestAddr2),'~') as address ,
etl.ifempty(ac.BestCity,'~') as city ,
etl.ifempty(ac.BestStateProvCd,'~') as state_cd ,
etl.ifempty(ac.BestPostalCode,'~') as zip ,
etl.ifempty(ac.primaryPhoneNumber,'~') as phone ,
etl.ifempty(ac.Faxnumber,'~') as fax ,
etl.ifempty(ac.EmailAddr,'~') as email ,
etl.ifempty(pri.AgencyGroup,'~') as agency_group ,
etl.ifempty(pri.NationalName,'~') as national_name ,
etl.ifempty(pri.NationalCode,'~') as national_code ,
etl.ifempty(pri.branchcd,'~') as territory ,
etl.ifempty(pri.TerritoryManager,'~') as territory_manager ,
etl.ifempty(ni.DBAName,'~') as dba ,
etl.ifempty(p.Statuscd,'~') as producer_status ,
etl.ifempty(pri.CommissionMaster,'~') as commission_master ,
etl.ifempty(pri.ReportingMaster,'~') as reporting_master ,
etl.ifempty(pri.appointeddt,'1900-01-01') as pn_appointment_date ,
etl.ifempty(pri.ProfitSharingMaster,'~') as profit_sharing_master ,
etl.ifempty(pri.ProducerMaster,'~') as producer_master ,
etl.ifempty(pri.RecognitionTier,'~') as recognition_tier ,
etl.ifempty(concat(a.Addr1, ' ', a.Addr2),'~') as rmaddress ,
etl.ifempty(a.City,'~') as rmcity ,
etl.ifempty(a.StateProvCd,'~') as rmstate ,
etl.ifempty(a.PostalCode,'~') as rmzip ,
ifnull(tmp.latest_NewExpirationDt,'1900-01-01') as new_business_term_date ,
date_format(str_to_date(p.UpdateTimeStamp,'%m/%d/%Y %h:%i:%s.%f%p'), '%Y-%m-%d %H:%i:%s') as ChangeDate
from prodcse_dw.Provider p
join prodcse_dw.PartyInfo pai
on p.SystemId=pai.SystemId
and p.cmmContainer=pai.cmmContainer
and p.id=pai.parentId
and pai.PartyTypeCd='ProviderParty'
#
join prodcse_dw.NameInfo ni
on p.SystemId=ni.SystemId
and p.cmmContainer=ni.cmmContainer
and pai.Id=ni.ParentId
and ni.NameTypeCd='ProviderName'
#
join prodcse_dw.AllContacts ac
on p.SystemId=ac.SystemId
and p.cmmContainer=ac.cmmContainer
and ac.ContactTypeCd='Provider'
and ac.SourceTypeCd='Producer'
#
join prodcse_dw.ProducerInfo pri
on p.SystemId=pri.SystemId
and p.cmmContainer=pri.cmmContainer
and p.Id=pri.ParentId
#
left outer join prodcse_dw.Addr a
on p.SystemId=a.SystemId
and p.cmmContainer=a.cmmContainer
and pai.Id=a.ParentId
and AddrTypeCd='ProviderBillingAddr'
#
left outer join tmp
on p.SystemId=tmp.SystemId
where p.ProviderTypeCd ='Producer'
and p.CMMContainer='Provider'
and ifnull(p.StatusCd,'Deleted') <> 'Deleted'
and lower(ifnull(p.IndexName,'~')) not like '%duplicate%'
/*stage all producers to avoide complications to set into SP LatestProviderUpdateTimeStamp*/
#and date_format(str_to_date(p.UpdateTimeStamp,'%m/%d/%Y %h:%i:%s.%f%p'), '%Y/%m/%d %H:%i:%s.%f') > sql_LatestProviderUpdateTimeStamp
;

end//

DELIMITER // 
drop procedure if exists `etl`.`sp_stg_customer`//

CREATE DEFINER=`srvc_bietl`@`%` PROCEDURE `etl`.`sp_stg_customer`(sql_bookDate date, sql_currentDate date, sql_loadDate varchar(50), Source_System varchar(100), LoadType varchar(1))
begin


/*0. Scope - full (f) catch up (c) or daily load (d)*/
drop temporary table if exists tmp_scope;

if LoadType='d' then

create temporary table tmp_scope
select cb.SystemId
from prodcse_dw.xxchangedbeans cb
where cb.cmmContainer='Customer';

else

create temporary table tmp_scope
select cb.SystemId
from prodcse_dw.customer cb
where cb.cmmContainer='Customer'
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') > date_add(str_to_date(sql_bookDate,'%Y-%m-%d') , INTERVAL -1 day)
and str_to_date(substring(cb.UpdateTimestamp,1, 16),'%m/%d/%Y %H:%i') <= date_add(str_to_date(sql_currentDate,'%Y-%m-%d') , INTERVAL +1 day);

end if;

CREATE INDEX idx_tmp1 ON tmp_scope(SystemId);
drop temporary table if exists tmp_real_customers;
create temporary table tmp_real_customers
select customerRef
from prodcse_dw.Policy
union
select customerRef
from prodcse_dw.QuoteInfo;

CREATE INDEX idx_tmp2 ON tmp_real_customers(customerRef);

select distinct
Source_System as source_system
, sql_loadDate as LoadDate
, c.SystemId as Customer_UniqueId
, coalesce(c.Status,'~') as Status
, coalesce(c.EntityTypeCd ,'~') EntityTypeCd
, coalesce(NI.GivenName,'~') first_name
, coalesce(NI.Surname,'~') as last_name
, coalesce(NI.CommercialName,'~') as CommercialName
, coalesce(case when PerI.BirthDt<str_to_date('1900-01-01', '%Y-%m-%d') then null else PerI.BirthDt end,str_to_date('1900-01-01','%Y-%m-%d')) as DOB
, coalesce(PerI.GenderCd,'~') as gender
, coalesce(PerI.MaritalStatusCd,'~') as maritalStatus
, coalesce(A1.Addr1,'~') as address1
, coalesce(REPLACE(NULLIF(A1.Addr2,''),'|','/'),'~') as address2
, coalesce(A1.County,'~') as county
, coalesce(A1.City,'~') as city
, coalesce(A1.StateProvCd,'~') as state
, coalesce(left(A1.PostalCode,5),'~') as PostalCode
, coalesce(NULLIF(case
when ac.PrimaryPhoneName<>'Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName<>'Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,''),'~') as phone
, coalesce(NULLIF(case
when ac.PrimaryPhoneName='Mobile' and ac.PrimaryPhoneNumber is not null then ac.PrimaryPhoneNumber
when ac.SecondaryPhoneName='Mobile' and ac.SecondaryPhoneNumber is not null then ac.SecondaryPhoneNumber
end,''),'~') as mobile
, coalesce(NULLIF(ac.emailaddr,''),'~') as email
, coalesce(c.PreferredDeliveryMethod,'None') as PreferredDeliveryMethod
, coalesce(cast(substring(c.PortalInvitationSentDt,1,8) as date),str_to_date('1900-01-01','%Y-%m-%d')) as PortalInvitationSentDt
, coalesce(c.PaymentReminderInd,'~') as PaymentReminderInd
, coalesce(str_to_date(UpdateTimestamp , '%c/%e/%Y %H:%i'),str_to_date('1900-01-01','%Y-%m-%d')) ChangeDate
from tmp_scope cu
join prodcse_dw.Customer c
on cu.SystemId=c.SystemId
join tmp_real_customers rc
on c.SystemId=rc.CustomerRef
join prodcse_dw.PartyInfo as PartyI
on PartyI.SystemId = c.SystemId
and PartyI.ParentId = c.id
and PartyI.CMMContainer = c.CMMContainer
and PartyI.PartyTypeCd = 'CustomerParty'
join prodcse_dw.NameInfo as NI
on NI.SystemId = c.SystemId
and NI.CMMContainer = c.CMMContainer
and NI.ParentId = PartyI.id
and NI.NameTypeCd = 'CustomerName'
join prodcse_dw.PersonInfo as PerI
on PerI.SystemId = c.SystemId
and PerI.CMMContainer = c.CMMContainer
and PerI.ParentId = PartyI.id
and PerI.PersonTypeCd = 'CustomerPersonal'
join prodcse_dw.Addr as A1
on A1.SystemId = c.SystemId
and A1.CMMContainer = c.CMMContainer
and A1.ParentId = PartyI.id
and A1.AddrTypeCd = 'CustomerMailingAddr'
join prodcse_dw.AllContacts ac
on ac.systemid = c.SystemId
and ac.PartyInfoIdRef=PartyI.Id
and ac.cmmContainer=c.CMMContainer
where c.CMMContainer='Customer' ;

end//
