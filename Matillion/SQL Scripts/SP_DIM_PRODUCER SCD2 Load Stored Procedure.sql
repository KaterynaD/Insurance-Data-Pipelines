CREATE OR REPLACE PROCEDURE kdlab.sp_dim_producer()
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

/*Assuming all columns are historical*/
/*1. existing-changed records - "close" old and insert new*/

drop table if exists tmp_changed;
create table tmp_changed as
select stg.*
,dim.record_version
from kdlab.stg_producer stg
join kdlab.dim_producer dim
on stg.producer_uniqueid=dim.producer_uniqueid
and dim.isCurrent=1
where
(stg.producer_number <> dim.producer_number Or
stg.producer_name <> dim.producer_name Or
stg.licenseno <> dim.licenseno Or
stg.agency_type <> dim.agency_type Or
stg.address <> dim.address Or
stg.city <> dim.city Or
stg.state_cd <> dim.state_cd Or
stg.zip <> dim.zip Or
stg.phone <> dim.phone Or
stg.fax <> dim.fax Or
stg.email <> dim.email Or
stg.agency_group <> dim.agency_group Or
stg.national_name <> dim.national_name Or
stg.national_code <> dim.national_code Or
stg.territory <> dim.territory Or
stg.territory_manager <> dim.territory_manager Or
stg.dba <> dim.dba Or
stg.producer_status <> dim.producer_status Or
stg.commission_master <> dim.commission_master Or
stg.reporting_master <> dim.reporting_master Or
stg.pn_appointment_date <> dim.pn_appointment_date Or
stg.profit_sharing_master <> dim.profit_sharing_master Or
stg.producer_master <> dim.producer_master Or
stg.recognition_tier <> dim.recognition_tier Or
stg.rmaddress <> dim.rmaddress Or
stg.rmcity <> dim.rmcity Or
stg.rmstate <> dim.rmstate Or
stg.rmzip <> dim.rmzip Or
stg.new_business_term_date <> dim.new_business_term_date);

/*1.1 - close */

update kdlab.dim_producer
set valid_todate=tmp_changed.ChangeDate,
isCurrent=0
from tmp_changed
where tmp_changed.producer_uniqueid=kdlab.dim_producer.producer_uniqueid
and kdlab.dim_producer.isCurrent=1;

/*1.2 insert new version*/

insert into kdlab.dim_producer
(loaddate
,producer_uniqueid
,valid_fromdate
,valid_todate
,record_version
,isCurrent
,producer_number
,producer_name
,licenseno
,agency_type
,address
,city
,state_cd
,zip
,phone
,fax
,email
,agency_group
,national_name
,national_code
,territory
,territory_manager
,dba
,producer_status
,commission_master
,reporting_master
,pn_appointment_date
,profit_sharing_master
,producer_master
,recognition_tier
,rmaddress
,rmcity
,rmstate
,rmzip
,new_business_term_date)
select
loaddate
,producer_uniqueid
,stg.ChangeDate valid_fromdate
,'2900-12-31' valid_todate
,stg.record_version+1 record_version
,1 isCurrent
,producer_number
,producer_name
,licenseno
,agency_type
,address
,city
,state_cd
,zip
,phone
,fax
,email
,agency_group
,national_name
,national_code
,territory
,territory_manager
,dba
,producer_status
,commission_master
,reporting_master
,pn_appointment_date
,profit_sharing_master
,producer_master
,recognition_tier
,rmaddress
,rmcity
,rmstate
,rmzip
,new_business_term_date
from tmp_changed stg;


/*2. new records - insert*/

insert into kdlab.dim_producer
(loaddate
,producer_uniqueid
,valid_fromdate
,valid_todate
,record_version
,isCurrent
,producer_number
,producer_name
,licenseno
,agency_type
,address
,city
,state_cd
,zip
,phone
,fax
,email
,agency_group
,national_name
,national_code
,territory
,territory_manager
,dba
,producer_status
,commission_master
,reporting_master
,pn_appointment_date
,profit_sharing_master
,producer_master
,recognition_tier
,rmaddress
,rmcity
,rmstate
,rmzip
,new_business_term_date)
select
stg.loaddate
,stg.producer_uniqueid
,'1900-01-01' valid_fromdate
,'2900-12-31' valid_todate
,1 record_version
,1 isCurrent
,stg.producer_number
,stg.producer_name
,stg.licenseno
,stg.agency_type
,stg.address
,stg.city
,stg.state_cd
,stg.zip
,stg.phone
,stg.fax
,stg.email
,stg.agency_group
,stg.national_name
,stg.national_code
,stg.territory
,stg.territory_manager
,stg.dba
,stg.producer_status
,stg.commission_master
,stg.reporting_master
,stg.pn_appointment_date
,stg.profit_sharing_master
,stg.producer_master
,stg.recognition_tier
,stg.rmaddress
,stg.rmcity
,stg.rmstate
,stg.rmzip
,stg.new_business_term_date
from kdlab.stg_producer stg
left outer join kdlab.dim_producer exst
on stg.producer_uniqueid=exst.producer_uniqueid
where exst.producer_uniqueid is null;

END;

$$
;
