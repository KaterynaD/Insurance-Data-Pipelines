CREATE OR REPLACE VIEW kdlab.vstg_policyhistory as															
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
max(ApplicationRef) over( partition by txnhist.SystemId) maxSystemId															
from aurora_prodcse_dw.TransactionHistory txnhist															
join aurora_prodcse_dw.BasicPolicy bp															
on txnhist.SystemId=bp.SystemId															
and txnhist.CMMContainer=bp.CMMContainer															
where txnhist._fivetran_deleted = false															
and txnhist.CMMContainer='Policy'															
and txnhist.TransactionEffectiveDt is not null															
and txnhist.BookDt is not null															
and txnhist.ApplicationRef is not null															
and bp.EffectiveDt >= '2022-01-01' and bp.ExpirationDt <= '2022-12-31'															
order by txnhist.SystemId, txnhist.ApplicationRef;															
															
															
															
DROP TABLE if exists kdlab.stg_policy_scope;							
CREATE TABLE kdlab.stg_policy_scope							
(							
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64							
,systemid INTEGER ENCODE az64							
,cmmcontainer VARCHAR(255) ENCODE lzo							
,policysystemid INTEGER ENCODE az64							
,policyref INTEGER ENCODE az64							
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64							
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64							
)							
DISTSTYLE KEY							
DISTKEY (policyref)							
SORTKEY (							
SystemId							
)							
;							


DROP TABLE if exists kdlab.stg_policy;
CREATE TABLE IF NOT EXISTS kdlab.stg_policy
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,transactioncd VARCHAR(255) ENCODE lzo
,product_uniqueid VARCHAR(255) ENCODE lzo
,company_uniqueid VARCHAR(512) ENCODE lzo
,producer_uniqueid VARCHAR(255) ENCODE lzo
,firstinsured_uniqueid INTEGER ENCODE az64
,policynumber VARCHAR(255) ENCODE lzo
,term VARCHAR(258) ENCODE lzo
,effectivedate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,expirationdate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,carriercd VARCHAR(255) ENCODE lzo
,companycd VARCHAR(255) ENCODE lzo
,termdays BIGINT ENCODE az64
,carriergroupcd VARCHAR(255) ENCODE lzo
,statecd VARCHAR(255) ENCODE lzo
,businesssourcecd VARCHAR(255) ENCODE lzo
,previouscarriercd VARCHAR(255) ENCODE lzo
,policyformcode VARCHAR(255) ENCODE lzo
,subtypecd VARCHAR(255) ENCODE lzo
,altsubtypecd VARCHAR(255) ENCODE lzo
,payplancd VARCHAR(255) ENCODE lzo
,inceptiondt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,priorpolicynumber VARCHAR(255) ENCODE lzo
,previouspolicynumber VARCHAR(255) ENCODE lzo
,affinitygroupcd VARCHAR(255) ENCODE lzo
,programind VARCHAR(255) ENCODE lzo
,relatedpolicynumber VARCHAR(255) ENCODE lzo
,quotenumber VARCHAR(255) ENCODE lzo
,renewaltermcd VARCHAR(255) ENCODE lzo
,rewritepolicyref INTEGER ENCODE az64
,rewritefrompolicyref INTEGER ENCODE az64
,canceldt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,reinstatedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,persistencydiscountdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,paperlessdelivery VARCHAR(128) ENCODE lzo
,multicardiscountind VARCHAR(255) ENCODE lzo
,latefee VARCHAR(3) ENCODE lzo
,nsffee VARCHAR(3) ENCODE lzo
,installmentfee VARCHAR(3) ENCODE lzo
,batchquotesourcecd VARCHAR(255) ENCODE lzo
,waivepolicyfeeind VARCHAR(255) ENCODE lzo
,liabilitylimitcpl VARCHAR(255) ENCODE lzo
,liabilityreductionind VARCHAR(255) ENCODE lzo
,liabilitylimitolt VARCHAR(20) ENCODE lzo
,personalliabilitylimit VARCHAR(255) ENCODE lzo
,gloccurrencelimit VARCHAR(255) ENCODE lzo
,glaggregatelimit VARCHAR(255) ENCODE lzo
,policy_spinn_status VARCHAR(255) ENCODE lzo
,bilimit VARCHAR(255) ENCODE lzo
,pdlimit VARCHAR(255) ENCODE lzo
,umbilimit VARCHAR(255) ENCODE lzo
,medpaylimit VARCHAR(255) ENCODE lzo
,multipolicydiscount VARCHAR(3) ENCODE lzo
,multipolicyautodiscount VARCHAR(3) ENCODE lzo
,multipolicyautonumber VARCHAR(256) ENCODE lzo
,multipolicyhomediscount VARCHAR(255) ENCODE lzo
,homerelatedpolicynumber VARCHAR(255) ENCODE lzo
,multipolicyumbrelladiscount VARCHAR(8) ENCODE lzo
,umbrellarelatedpolicynumber VARCHAR(16) ENCODE lzo
,cseemployeediscountind VARCHAR(255) ENCODE lzo
,fullpaydiscountind VARCHAR(3) ENCODE lzo
,twopaydiscountind VARCHAR(255) ENCODE lzo
,primarypolicynumber VARCHAR(65535) ENCODE lzo
,landlordind VARCHAR(3) ENCODE lzo
,personalinjuryind VARCHAR(4) ENCODE lzo
,vehiclelistconfirmedind VARCHAR(4) ENCODE lzo
,firstpayment TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,lastpayment TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,balanceamt NUMERIC(38,6) ENCODE az64
,paidamt NUMERIC(38,6) ENCODE az64
,writtenpremiumamt NUMERIC(28,6) ENCODE az64
,fulltermamt NUMERIC(28,6) ENCODE az64
,commissionamt NUMERIC(28,6) ENCODE az64
,accountref INTEGER ENCODE az64
,customer_uniqueid INTEGER ENCODE az64
,applicationnumber VARCHAR(255) ENCODE lzo
,application_updatetimestamp DATE ENCODE az64
,quoteinfo_updatedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,quoteinfo_adduser_uniqueid VARCHAR(255) ENCODE lzo
,original_policy_uniqueid INTEGER ENCODE az64
,application_type VARCHAR(255) ENCODE lzo
,quoteinfo_type VARCHAR(255) ENCODE lzo
,application_status VARCHAR(255) ENCODE lzo
,quoteinfo_status VARCHAR(255) ENCODE lzo
,quoteinfo_closereasoncd VARCHAR(255) ENCODE lzo
,quoteinfo_closesubreasoncd VARCHAR(255) ENCODE lzo
,quoteinfo_closecomment VARCHAR(512) ENCODE lzo
,mgafeeplancd VARCHAR(20) ENCODE lzo
,mgafeepct NUMERIC(28,6) ENCODE az64
,tpafeeplancd VARCHAR(20) ENCODE lzo
,tpafeepct NUMERIC(28,6) ENCODE az64
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

DROP TABLE IF EXISTS kdlab.stg_product;
CREATE TABLE kdlab.stg_product
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,product_uniqueid VARCHAR(255) ENCODE lzo
,productversion VARCHAR(24) ENCODE lzo
,name VARCHAR(64) ENCODE lzo
,description VARCHAR(88) ENCODE lzo
,producttypecd VARCHAR(32) ENCODE lzo
,carriergroupcd VARCHAR(16) ENCODE lzo
,carriercd VARCHAR(8) ENCODE lzo
,isselect INTEGER ENCODE az64
,linecd VARCHAR(255) ENCODE lzo
,subtypecd VARCHAR(255) ENCODE lzo
,altsubtypecd VARCHAR(32) ENCODE lzo
,subtypeshortdesc VARCHAR(64) ENCODE lzo
,subtypefulldesc VARCHAR(64) ENCODE lzo
,policynumberprefix VARCHAR(3) ENCODE lzo
,startdt DATE ENCODE az64
,stopdt DATE ENCODE az64
,renewalstartdt DATE ENCODE az64
,renewalstopdt DATE ENCODE az64
,statecd VARCHAR(2) ENCODE lzo
,contract VARCHAR(8) ENCODE lzo
,lob VARCHAR(8) ENCODE lzo
,propertyform VARCHAR(8) ENCODE lzo
,prerenewaldays INT ENCODE az64
,autorenewaldays INT ENCODE az64
,mgafeeplancd VARCHAR(20) ENCODE lzo
,tpafeeplancd VARCHAR(20) ENCODE lzo
)
DISTSTYLE AUTO
;

DROP TABLE IF EXISTS kdlab.stg_insured;
CREATE TABLE IF NOT EXISTS kdlab.stg_insured
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,insured_uniqueid INTEGER ENCODE az64
,first_name VARCHAR(255) ENCODE lzo
,last_name VARCHAR(255) ENCODE lzo
,commercialname VARCHAR(255) ENCODE lzo
,dob TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,occupation VARCHAR(255) ENCODE lzo
,gender VARCHAR(10) ENCODE lzo
,maritalstatus VARCHAR(255) ENCODE lzo
,address1 VARCHAR(255) ENCODE lzo
,address2 VARCHAR(255) ENCODE lzo
,county VARCHAR(255) ENCODE lzo
,city VARCHAR(255) ENCODE lzo
,state VARCHAR(255) ENCODE lzo
,country VARCHAR(255) ENCODE lzo
,postalcode VARCHAR(255) ENCODE lzo
,telephone VARCHAR(255) ENCODE lzo
,mobile VARCHAR(255) ENCODE lzo
,email VARCHAR(255) ENCODE lzo
,jobtitle VARCHAR(255) ENCODE lzo
,insurancescore VARCHAR(255) ENCODE lzo
,overriddeninsurancescore VARCHAR(255) ENCODE lzo
,applieddt DATE ENCODE az64
,insurancescorevalue VARCHAR(3) ENCODE lzo
,ratepageeffectivedt DATE ENCODE az64
,insscoretiervalueband VARCHAR(7) ENCODE lzo
,financialstabilitytier VARCHAR(2) ENCODE lzo
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

DROP TABLE IF EXISTS kdlab.stg_insured;
CREATE TABLE IF NOT EXISTS kdlab.stg_insured
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,insured_uniqueid INTEGER ENCODE az64
,first_name VARCHAR(255) ENCODE lzo
,last_name VARCHAR(255) ENCODE lzo
,commercialname VARCHAR(255) ENCODE lzo
,dob TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,occupation VARCHAR(255) ENCODE lzo
,gender VARCHAR(10) ENCODE lzo
,maritalstatus VARCHAR(255) ENCODE lzo
,address1 VARCHAR(255) ENCODE lzo
,address2 VARCHAR(255) ENCODE lzo
,county VARCHAR(255) ENCODE lzo
,city VARCHAR(255) ENCODE lzo
,state VARCHAR(255) ENCODE lzo
,country VARCHAR(255) ENCODE lzo
,postalcode VARCHAR(255) ENCODE lzo
,telephone VARCHAR(255) ENCODE lzo
,mobile VARCHAR(255) ENCODE lzo
,email VARCHAR(255) ENCODE lzo
,jobtitle VARCHAR(255) ENCODE lzo
,insurancescore VARCHAR(255) ENCODE lzo
,overriddeninsurancescore VARCHAR(255) ENCODE lzo
,applieddt DATE ENCODE az64
,insurancescorevalue VARCHAR(3) ENCODE lzo
,ratepageeffectivedt DATE ENCODE az64
,insscoretiervalueband VARCHAR(7) ENCODE lzo
,financialstabilitytier VARCHAR(2) ENCODE lzo
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

DROP TABLE IF EXISTS kdlab.stg_vehicle;
CREATE TABLE IF NOT EXISTS kdlab.stg_vehicle
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,spinnvehicle_id VARCHAR(255) ENCODE lzo
,risk_uniqueid VARCHAR(255) ENCODE lzo
,risk_type VARCHAR(255) ENCODE lzo
,vehicle_uniqueid VARCHAR(523) ENCODE lzo
,status VARCHAR(255) ENCODE lzo
,stateprovcd VARCHAR(255) ENCODE lzo
,county VARCHAR(255) ENCODE lzo
,postalcode VARCHAR(255) ENCODE lzo
,city VARCHAR(255) ENCODE lzo
,addr1 VARCHAR(1023) ENCODE lzo
,addr2 VARCHAR(255) ENCODE lzo
,latitude VARCHAR(255) ENCODE lzo
,longitude VARCHAR(255) ENCODE lzo
,garagaddrflg VARCHAR(3) ENCODE lzo
,garagpostalcode VARCHAR(255) ENCODE lzo
,garagpostalcodeflg VARCHAR(3) ENCODE lzo
,manufacturer VARCHAR(255) ENCODE lzo
,"model" VARCHAR(255) ENCODE lzo
,modelyr VARCHAR(255) ENCODE lzo
,vehidentificationnumber VARCHAR(255) ENCODE lzo
,validvinind VARCHAR(255) ENCODE lzo
,vehlicensenumber VARCHAR(255) ENCODE lzo
,registrationstateprovcd VARCHAR(255) ENCODE lzo
,vehbodytypecd VARCHAR(255) ENCODE lzo
,performancecd VARCHAR(255) ENCODE lzo
,restraintcd VARCHAR(255) ENCODE lzo
,antibrakingsystemcd VARCHAR(255) ENCODE lzo
,antitheftcd VARCHAR(255) ENCODE lzo
,enginesize VARCHAR(255) ENCODE lzo
,enginecylinders VARCHAR(255) ENCODE lzo
,enginehorsepower VARCHAR(255) ENCODE lzo
,enginetype VARCHAR(255) ENCODE lzo
,vehusecd VARCHAR(255) ENCODE lzo
,garageterritory INTEGER ENCODE az64
,collisionded VARCHAR(255) ENCODE lzo
,comprehensiveded VARCHAR(255) ENCODE lzo
,statedamt NUMERIC(28,6) ENCODE az64
,classcd VARCHAR(255) ENCODE lzo
,ratingvalue VARCHAR(255) ENCODE lzo
,costnewamt NUMERIC(28,6) ENCODE az64
,estimatedannualdistance INTEGER ENCODE az64
,estimatedworkdistance INTEGER ENCODE az64
,leasedvehind VARCHAR(255) ENCODE lzo
,purchasedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,statedamtind VARCHAR(255) ENCODE lzo
,neworusedind VARCHAR(255) ENCODE lzo
,carpoolind VARCHAR(255) ENCODE lzo
,odometerreading VARCHAR(10) ENCODE lzo
,weekspermonthdriven VARCHAR(255) ENCODE lzo
,daylightrunninglightsind VARCHAR(255) ENCODE lzo
,passiveseatbeltind VARCHAR(255) ENCODE lzo
,daysperweekdriven VARCHAR(255) ENCODE lzo
,umpdlimit VARCHAR(255) ENCODE lzo
,towingandlaborind VARCHAR(255) ENCODE lzo
,rentalreimbursementind VARCHAR(255) ENCODE lzo
,liabilitywaiveind VARCHAR(255) ENCODE lzo
,ratefeesind VARCHAR(255) ENCODE lzo
,optionalequipmentvalue INTEGER ENCODE az64
,customizingequipmentind VARCHAR(255) ENCODE lzo
,customizingequipmentdesc VARCHAR(255) ENCODE lzo
,invalidvinacknowledgementind VARCHAR(255) ENCODE lzo
,ignoreumpdwcdind VARCHAR(255) ENCODE lzo
,recalculateratingsymbolind VARCHAR(255) ENCODE lzo
,programtypecd VARCHAR(255) ENCODE lzo
,cmpratingvalue VARCHAR(255) ENCODE lzo
,colratingvalue VARCHAR(255) ENCODE lzo
,liabilityratingvalue VARCHAR(255) ENCODE lzo
,medpayratingvalue VARCHAR(255) ENCODE lzo
,racmpratingvalue VARCHAR(255) ENCODE lzo
,racolratingvalue VARCHAR(255) ENCODE lzo
,rabiratingsymbol VARCHAR(255) ENCODE lzo
,rapdratingsymbol VARCHAR(255) ENCODE lzo
,ramedpayratingsymbol VARCHAR(255) ENCODE lzo
,estimatedannualdistanceoverride VARCHAR(5) ENCODE lzo
,originalestimatedannualmiles VARCHAR(12) ENCODE lzo
,reportedmileagenonsave VARCHAR(12) ENCODE lzo
,mileage VARCHAR(12) ENCODE lzo
,estimatednoncommutemiles VARCHAR(12) ENCODE lzo
,titlehistoryissue VARCHAR(3) ENCODE lzo
,odometerproblems VARCHAR(3) ENCODE lzo
,bundle VARCHAR(15) ENCODE lzo
,loanleasegap VARCHAR(3) ENCODE lzo
,equivalentreplacementcost VARCHAR(3) ENCODE lzo
,originalequipmentmanufacturer VARCHAR(3) ENCODE lzo
,optionalrideshare VARCHAR(3) ENCODE lzo
,medicalpartsaccessibility VARCHAR(4) ENCODE lzo
,vehnumber INTEGER ENCODE az64
,odometerreadingprior VARCHAR(10) ENCODE lzo
,reportedmileagenonsavedtprior DATE ENCODE az64
,fullglasscovind VARCHAR(3) ENCODE lzo
,boatlengthfeet VARCHAR(255) ENCODE lzo
,motorhorsepower VARCHAR(255) ENCODE lzo
,replacementof INTEGER ENCODE az64
,reportedmileagenonsavedt DATE ENCODE az64
,manufacturersymbol VARCHAR(4) ENCODE lzo
,modelsymbol VARCHAR(4) ENCODE lzo
,bodystylesymbol VARCHAR(4) ENCODE lzo
,symbolcode VARCHAR(12) ENCODE lzo
,verifiedmileageoverride VARCHAR(4) ENCODE lzo
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

DROP TABLE IF EXISTS kdlab.stg_driver;
CREATE TABLE kdlab.stg_driver
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,spinndriver_id VARCHAR(255) ENCODE lzo
,driver_uniqueid VARCHAR(573) ENCODE lzo
,status VARCHAR(255) ENCODE lzo
,firstname VARCHAR(255) ENCODE lzo
,lastname VARCHAR(255) ENCODE lzo
,licensenumber VARCHAR(255) ENCODE lzo
,licensedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,driverinfocd VARCHAR(255) ENCODE lzo
,drivernumber INTEGER ENCODE az64
,drivertypecd VARCHAR(255) ENCODE lzo
,driverstatuscd VARCHAR(255) ENCODE lzo
,licensedstateprovcd VARCHAR(255) ENCODE lzo
,relationshiptoinsuredcd VARCHAR(255) ENCODE lzo
,scholasticdiscountind VARCHAR(255) ENCODE lzo
,mvrrequestind VARCHAR(255) ENCODE lzo
,mvrstatusdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,mvrstatus VARCHAR(255) ENCODE lzo
,maturedriverind VARCHAR(255) ENCODE lzo
,drivertrainingind VARCHAR(255) ENCODE lzo
,gooddriverind VARCHAR(8) ENCODE lzo
,accidentpreventioncoursecompletiondt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,drivertrainingcompletiondt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,accidentpreventioncourseind VARCHAR(255) ENCODE lzo
,scholasticcertificationdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,activemilitaryind VARCHAR(255) ENCODE lzo
,permanentlicenseind VARCHAR(255) ENCODE lzo
,newtostateind VARCHAR(255) ENCODE lzo
,persontypecd VARCHAR(255) ENCODE lzo
,gendercd VARCHAR(10) ENCODE lzo
,birthdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,maritalstatuscd VARCHAR(255) ENCODE lzo
,occupationclasscd VARCHAR(255) ENCODE lzo
,positiontitle VARCHAR(255) ENCODE lzo
,currentresidencecd VARCHAR(255) ENCODE lzo
,civilservantind VARCHAR(255) ENCODE lzo
,retiredind VARCHAR(255) ENCODE lzo
,newteenexpirationdt DATE ENCODE az64
,sr22feeind VARCHAR(4) ENCODE lzo
,maturecertificationdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,agefirstlicensed INTEGER ENCODE az64
,attachedvehicleref VARCHAR(255) ENCODE lzo
,viol_pointschargedterm BIGINT ENCODE az64
,acci_pointschargedterm BIGINT ENCODE az64
,susp_pointschargedterm BIGINT ENCODE az64
,other_pointschargedterm BIGINT ENCODE az64
,gooddriverpoints_chargedterm BIGINT ENCODE az64
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

create table kdlab.coverage_mapping
(
CoverageCd varchar(75),
covx_code varchar(75),
covx_description varchar(125)
);
insert into kdlab.coverage_mapping values ( 'H590ST0','SeniorDiscount','Senior Discount');
insert into kdlab.coverage_mapping values ( 'DAU1143','COC','Course of Construction');
insert into kdlab.coverage_mapping values ( 'F34410A','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'F32470','FRAUD','Identity Recovery Coverage');
insert into kdlab.coverage_mapping values ( 'F30630','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'F32465','FRAUD','Identity Recovery Coverage');
insert into kdlab.coverage_mapping values ( 'HO2490-Occasional','WCINC','Workers Compensation - Occasional Employee');
insert into kdlab.coverage_mapping values ( 'F34395A','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'HO5','HO5','Contents Open Perils');
insert into kdlab.coverage_mapping values ( 'H070ST0','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'BOLCC','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'F30655','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'CovC','CovC','Boat Trailer');
insert into kdlab.coverage_mapping values ( 'CovA-EC','CovA','Dwelling (Extended Coverage)');
insert into kdlab.coverage_mapping values ( 'UTLDB','UTLDB','Service Line');
insert into kdlab.coverage_mapping values ( 'SRORP','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'PP','CovC','Personal Property (Extended Coverage)');
insert into kdlab.coverage_mapping values ( 'OccupationCredit','OccupationDiscount','Occupation Discount');
insert into kdlab.coverage_mapping values ( 'F.34415A','OLT','Landlord Eviction Expense Reimbursement');
insert into kdlab.coverage_mapping values ( 'IncreasedOtherStructures','INCB','Other Structures Increased Limit');
insert into kdlab.coverage_mapping values ( 'DAUPI','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'F.34355A','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'BEDBUG','BEDBUG','Bed Bug Coverage');
insert into kdlab.coverage_mapping values ( 'G.30980','SPP','Scheduled Personal Property');
insert into kdlab.coverage_mapping values ( 'G30980','SPP','Scheduled Personal Property');
insert into kdlab.coverage_mapping values ( 'FRAUD','FRAUD','Identity Recovery Coverage');
insert into kdlab.coverage_mapping values ( 'F.32830','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'DAU0463','LAC','Loss Assessment');
insert into kdlab.coverage_mapping values ( 'EQPBK','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'F34355A','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'H082ST0','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'H048ST0','INCB','Other Structures Increased Limit');
insert into kdlab.coverage_mapping values ( 'SPP','SPP','Scheduled Personal Property');
insert into kdlab.coverage_mapping values ( 'SEWER','SEWER','Backup of Sewers and Drains');
insert into kdlab.coverage_mapping values ( 'H051ST0','H051ST0','Building Additions and Alterations Increased Limit');
insert into kdlab.coverage_mapping values ( 'F.31890','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'Senior','SeniorDiscount','Senior Discount');
insert into kdlab.coverage_mapping values ( 'PRTDVC','PRTDVC','Protective Devices (Security/Fire/Other)');
insert into kdlab.coverage_mapping values ( 'H065ST0','INCC','Personal Property Increased Limit');
insert into kdlab.coverage_mapping values ( 'OS','CovB','Other Structures');
insert into kdlab.coverage_mapping values ( 'MBEBU','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'PL','CovE','Personal Liability');
insert into kdlab.coverage_mapping values ( 'F32815','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'WCINC','WCINC','Workers Compensation');
insert into kdlab.coverage_mapping values ( 'BuildingOrdinance','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'THEFA','THEFA','Theft');
insert into kdlab.coverage_mapping values ( 'MedPay','MEDPAY','Medical Payments/Expense');
insert into kdlab.coverage_mapping values ( 'F.32815','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'H500ST0','PPREP','Personal Property Replacement Cost Option');
insert into kdlab.coverage_mapping values ( 'CovC-SF','CovC','Personal Property (Fire and Lightning - Special Form)');
insert into kdlab.coverage_mapping values ( 'F.34395A','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'F34390A','UTLDB','Service Line');
insert into kdlab.coverage_mapping values ( 'CovA','CovA','Dwelling (Fire and Lightning)');
insert into kdlab.coverage_mapping values ( 'LOU','CovD','Loss of Use/Fair Rental Value');
insert into kdlab.coverage_mapping values ( 'ALARM','PRTDVC','Protective Devices (Security/Fire/Other)');
insert into kdlab.coverage_mapping values ( 'MEDPM','MEDPAY','Medical Payments/Expense');
insert into kdlab.coverage_mapping values ( 'LAC','LAC','Loss Assessment');
insert into kdlab.coverage_mapping values ( 'INCC','INCC','Personal Property Increased Limit');
insert into kdlab.coverage_mapping values ( 'F.34420A','PPREP','Personal Property Replacement Cost Option');
insert into kdlab.coverage_mapping values ( 'F.32465','FRAUD','Identity Recovery Coverage');
insert into kdlab.coverage_mapping values ( 'ML0090','WCINC','Workers Compensation');
insert into kdlab.coverage_mapping values ( 'AddCovC','INCC','Personal Property Increased Limit');
insert into kdlab.coverage_mapping values ( 'FireProtection','PRTDVC','Protective Devices (Security/Fire/Other)');
insert into kdlab.coverage_mapping values ( 'F34415A','OLT','Landlord Eviction Expense Reimbursement');
insert into kdlab.coverage_mapping values ( 'H033ST0','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'F.34410A','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'SeniorDiscount','SeniorDiscount','Senior Discount');
insert into kdlab.coverage_mapping values ( 'ML0090Occasional','WCINC','Workers Compensation - Occasional Employee');
insert into kdlab.coverage_mapping values ( 'OLT','OLT','Landlord Eviction Expense Reimbursement');
insert into kdlab.coverage_mapping values ( 'H090CA0','WCINC','Workers Compensation');
insert into kdlab.coverage_mapping values ( 'F32830','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'CovD','CovD','Unattached Boat Equipment');
insert into kdlab.coverage_mapping values ( 'F.34390A','UTLDB','Service Line');
insert into kdlab.coverage_mapping values ( 'ProtectiveDevices','PRTDVC','Protective Devices (Security/Fire/Other)');
insert into kdlab.coverage_mapping values ( 'CovC-EC','CovC','Personal Property (Extended Coverage)');
insert into kdlab.coverage_mapping values ( 'H061ST0','SPP','Scheduled Personal Property');
insert into kdlab.coverage_mapping values ( 'F.32820','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'CovC-FL','CovC','Personal Property (Fire and Lightning)');
insert into kdlab.coverage_mapping values ( 'MEDPAY','MEDPAY','Medical Payments/Expense');
insert into kdlab.coverage_mapping values ( 'DAU0472','THEFA','Theft');
insert into kdlab.coverage_mapping values ( 'F.32825','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'F.34350A','INCB','Other Structures Increased Limit');
insert into kdlab.coverage_mapping values ( 'DWELL','CovA','Dwelling');
insert into kdlab.coverage_mapping values ( 'H037ST0','LAC','Loss Assessment');
insert into kdlab.coverage_mapping values ( 'F.30630','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'H040ST0','SRORP','Structures Rented to Others Residence Premises');
insert into kdlab.coverage_mapping values ( 'CovA-FL','CovA','Dwelling (Fire and Lightning)');
insert into kdlab.coverage_mapping values ( 'F.32470','FRAUD','Identity Recovery Coverage');
insert into kdlab.coverage_mapping values ( 'F.30655','BOLAW','Building Ordinance or Law');
insert into kdlab.coverage_mapping values ( 'INCB','INCB','Other Structures Increased Limit');
insert into kdlab.coverage_mapping values ( 'F32820','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'HO2490','WCINC','Workers Compensation');
insert into kdlab.coverage_mapping values ( 'CovA-SF','CovA','Dwelling (Fire and Lightning - Special Form)');
insert into kdlab.coverage_mapping values ( 'F34420A','PPREP','Personal Property Replacement Cost Option');
insert into kdlab.coverage_mapping values ( 'H090CA0-Occasional','WCINC','Workers Compensation - Occasional Employee');
insert into kdlab.coverage_mapping values ( 'F31890','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'ALEXP','CovE','Additional Living Expenses (Fire and Lightning)');
insert into kdlab.coverage_mapping values ( 'PIHOM','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'CovF','MEDPAY','Medical Payments/Expense');
insert into kdlab.coverage_mapping values ( 'H035ST0','LAC','Loss Assessment');
insert into kdlab.coverage_mapping values ( 'F34350A','INCB','Other Structures Increased Limit');
insert into kdlab.coverage_mapping values ( 'F32825','EQPBK','Equipment Breakdown');
insert into kdlab.coverage_mapping values ( 'MEDEX','MEDPAY','Medical Payments/Expense');
insert into kdlab.coverage_mapping values ( 'L9287','PIHOM','Personal Injury Liability');
insert into kdlab.coverage_mapping values ( 'PPREP','PPREP','Personal Property Replacement Cost Option');
insert into kdlab.coverage_mapping values ( 'H050ST0','INCC','Personal Property Increased Limit');
insert into kdlab.coverage_mapping values ( 'CovE','CovE','Liability');
insert into kdlab.coverage_mapping values ( 'FRV','CovD','Loss of Use/Fair Rental Value (Fire and Lightning)');
insert into kdlab.coverage_mapping values ( 'H216ST0','PRTDVC','Protective Devices (Security/Fire/Other)');
insert into kdlab.coverage_mapping values ( 'MATUR','SeniorDiscount','Senior Discount');
insert into kdlab.coverage_mapping values ( 'H080ST0','THEFA','Theft');
insert into kdlab.coverage_mapping values ( 'CovB','CovB','Other Structures (Extended Coverage)');
insert into kdlab.coverage_mapping values ( 'COC','COC','Course of Construction');
insert into kdlab.coverage_mapping values ( 'BOLAW','BOLAW','Building Ordinance or Law');


DROP TABLE IF EXISTS kdlab.stg_risk_coverage;
CREATE TABLE kdlab.stg_risk_coverage
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,risk_uniqueid VARCHAR(255) ENCODE lzo
,cova_limit1 NUMERIC(13,2) ENCODE az64
,cova_limit2 NUMERIC(13,2) ENCODE az64
,cova_deductible1 NUMERIC(13,2) ENCODE az64
,cova_deductible2 NUMERIC(13,2) ENCODE az64
,cova_fulltermamt NUMERIC(28,6) ENCODE az64
,covb_limit1 NUMERIC(13,2) ENCODE az64
,covb_limit2 NUMERIC(13,2) ENCODE az64
,covb_deductible1 NUMERIC(13,2) ENCODE az64
,covb_deductible2 NUMERIC(13,2) ENCODE az64
,covb_fulltermamt NUMERIC(28,6) ENCODE az64
,covc_limit1 NUMERIC(13,2) ENCODE az64
,covc_limit2 NUMERIC(13,2) ENCODE az64
,covc_deductible1 NUMERIC(13,2) ENCODE az64
,covc_deductible2 NUMERIC(13,2) ENCODE az64
,covc_fulltermamt NUMERIC(28,6) ENCODE az64
,covd_limit1 NUMERIC(13,2) ENCODE az64
,covd_limit2 NUMERIC(13,2) ENCODE az64
,covd_deductible1 NUMERIC(13,2) ENCODE az64
,covd_deductible2 NUMERIC(13,2) ENCODE az64
,covd_fulltermamt NUMERIC(28,6) ENCODE az64
,cove_limit1 NUMERIC(13,2) ENCODE az64
,cove_limit2 NUMERIC(13,2) ENCODE az64
,cove_deductible1 NUMERIC(13,2) ENCODE az64
,cove_deductible2 NUMERIC(13,2) ENCODE az64
,cove_fulltermamt NUMERIC(28,6) ENCODE az64
,bedbug_limit1 NUMERIC(13,2) ENCODE az64
,bedbug_limit2 NUMERIC(13,2) ENCODE az64
,bedbug_deductible1 NUMERIC(13,2) ENCODE az64
,bedbug_deductible2 NUMERIC(13,2) ENCODE az64
,bedbug_fulltermamt NUMERIC(28,6) ENCODE az64
,bolaw_limit1 NUMERIC(13,2) ENCODE az64
,bolaw_limit2 NUMERIC(13,2) ENCODE az64
,bolaw_deductible1 NUMERIC(13,2) ENCODE az64
,bolaw_deductible2 NUMERIC(13,2) ENCODE az64
,bolaw_fulltermamt NUMERIC(28,6) ENCODE az64
,coc_limit1 NUMERIC(13,2) ENCODE az64
,coc_limit2 NUMERIC(13,2) ENCODE az64
,coc_deductible1 NUMERIC(13,2) ENCODE az64
,coc_deductible2 NUMERIC(13,2) ENCODE az64
,coc_fulltermamt NUMERIC(28,6) ENCODE az64
,eqpbk_limit1 NUMERIC(13,2) ENCODE az64
,eqpbk_limit2 NUMERIC(13,2) ENCODE az64
,eqpbk_deductible1 NUMERIC(13,2) ENCODE az64
,eqpbk_deductible2 NUMERIC(13,2) ENCODE az64
,eqpbk_fulltermamt NUMERIC(28,6) ENCODE az64
,fraud_limit1 NUMERIC(13,2) ENCODE az64
,fraud_limit2 NUMERIC(13,2) ENCODE az64
,fraud_deductible1 NUMERIC(13,2) ENCODE az64
,fraud_deductible2 NUMERIC(13,2) ENCODE az64
,fraud_fulltermamt NUMERIC(28,6) ENCODE az64
,h051st0_limit1 NUMERIC(13,2) ENCODE az64
,h051st0_limit2 NUMERIC(13,2) ENCODE az64
,h051st0_deductible1 NUMERIC(13,2) ENCODE az64
,h051st0_deductible2 NUMERIC(13,2) ENCODE az64
,h051st0_fulltermamt NUMERIC(28,6) ENCODE az64
,ho5_limit1 NUMERIC(13,2) ENCODE az64
,ho5_limit2 NUMERIC(13,2) ENCODE az64
,ho5_deductible1 NUMERIC(13,2) ENCODE az64
,ho5_deductible2 NUMERIC(13,2) ENCODE az64
,ho5_fulltermamt NUMERIC(28,6) ENCODE az64
,incb_limit1 NUMERIC(13,2) ENCODE az64
,incb_limit2 NUMERIC(13,2) ENCODE az64
,incb_deductible1 NUMERIC(13,2) ENCODE az64
,incb_deductible2 NUMERIC(13,2) ENCODE az64
,incb_fulltermamt NUMERIC(28,6) ENCODE az64
,incc_limit1 NUMERIC(13,2) ENCODE az64
,incc_limit2 NUMERIC(13,2) ENCODE az64
,incc_deductible1 NUMERIC(13,2) ENCODE az64
,incc_deductible2 NUMERIC(13,2) ENCODE az64
,incc_fulltermamt NUMERIC(28,6) ENCODE az64
,lac_limit1 NUMERIC(13,2) ENCODE az64
,lac_limit2 NUMERIC(13,2) ENCODE az64
,lac_deductible1 NUMERIC(13,2) ENCODE az64
,lac_deductible2 NUMERIC(13,2) ENCODE az64
,lac_fulltermamt NUMERIC(28,6) ENCODE az64
,medpay_limit1 NUMERIC(13,2) ENCODE az64
,medpay_limit2 NUMERIC(13,2) ENCODE az64
,medpay_deductible1 NUMERIC(13,2) ENCODE az64
,medpay_deductible2 NUMERIC(13,2) ENCODE az64
,medpay_fulltermamt NUMERIC(28,6) ENCODE az64
,occupationdiscount_limit1 NUMERIC(13,2) ENCODE az64
,occupationdiscount_limit2 NUMERIC(13,2) ENCODE az64
,occupationdiscount_deductible1 NUMERIC(13,2) ENCODE az64
,occupationdiscount_deductible2 NUMERIC(13,2) ENCODE az64
,occupationdiscount_fulltermamt NUMERIC(28,6) ENCODE az64
,olt_limit1 NUMERIC(13,2) ENCODE az64
,olt_limit2 NUMERIC(13,2) ENCODE az64
,olt_deductible1 NUMERIC(13,2) ENCODE az64
,olt_deductible2 NUMERIC(13,2) ENCODE az64
,olt_fulltermamt NUMERIC(28,6) ENCODE az64
,pihom_limit1 NUMERIC(13,2) ENCODE az64
,pihom_limit2 NUMERIC(13,2) ENCODE az64
,pihom_deductible1 NUMERIC(13,2) ENCODE az64
,pihom_deductible2 NUMERIC(13,2) ENCODE az64
,pihom_fulltermamt NUMERIC(28,6) ENCODE az64
,pprep_limit1 NUMERIC(13,2) ENCODE az64
,pprep_limit2 NUMERIC(13,2) ENCODE az64
,pprep_deductible1 NUMERIC(13,2) ENCODE az64
,pprep_deductible2 NUMERIC(13,2) ENCODE az64
,pprep_fulltermamt NUMERIC(28,6) ENCODE az64
,prtdvc_limit1 NUMERIC(13,2) ENCODE az64
,prtdvc_limit2 NUMERIC(13,2) ENCODE az64
,prtdvc_deductible1 NUMERIC(13,2) ENCODE az64
,prtdvc_deductible2 NUMERIC(13,2) ENCODE az64
,prtdvc_fulltermamt NUMERIC(28,6) ENCODE az64
,seniordiscount_limit1 NUMERIC(13,2) ENCODE az64
,seniordiscount_limit2 NUMERIC(13,2) ENCODE az64
,seniordiscount_deductible1 NUMERIC(13,2) ENCODE az64
,seniordiscount_deductible2 NUMERIC(13,2) ENCODE az64
,seniordiscount_fulltermamt NUMERIC(28,6) ENCODE az64
,sewer_limit1 NUMERIC(13,2) ENCODE az64
,sewer_limit2 NUMERIC(13,2) ENCODE az64
,sewer_deductible1 NUMERIC(13,2) ENCODE az64
,sewer_deductible2 NUMERIC(13,2) ENCODE az64
,sewer_fulltermamt NUMERIC(28,6) ENCODE az64
,spp_limit1 NUMERIC(13,2) ENCODE az64
,spp_limit2 NUMERIC(13,2) ENCODE az64
,spp_deductible1 NUMERIC(13,2) ENCODE az64
,spp_deductible2 NUMERIC(13,2) ENCODE az64
,spp_fulltermamt NUMERIC(28,6) ENCODE az64
,srorp_limit1 NUMERIC(13,2) ENCODE az64
,srorp_limit2 NUMERIC(13,2) ENCODE az64
,srorp_deductible1 NUMERIC(13,2) ENCODE az64
,srorp_deductible2 NUMERIC(13,2) ENCODE az64
,srorp_fulltermamt NUMERIC(28,6) ENCODE az64
,thefa_limit1 NUMERIC(13,2) ENCODE az64
,thefa_limit2 NUMERIC(13,2) ENCODE az64
,thefa_deductible1 NUMERIC(13,2) ENCODE az64
,thefa_deductible2 NUMERIC(13,2) ENCODE az64
,thefa_fulltermamt NUMERIC(28,6) ENCODE az64
,utldb_limit1 NUMERIC(13,2) ENCODE az64
,utldb_limit2 NUMERIC(13,2) ENCODE az64
,utldb_deductible1 NUMERIC(13,2) ENCODE az64
,utldb_deductible2 NUMERIC(13,2) ENCODE az64
,utldb_fulltermamt NUMERIC(28,6) ENCODE az64
,wcinc_limit1 NUMERIC(13,2) ENCODE az64
,wcinc_limit2 NUMERIC(13,2) ENCODE az64
,wcinc_deductible1 NUMERIC(13,2) ENCODE az64
,wcinc_deductible2 NUMERIC(13,2) ENCODE az64
,wcinc_fulltermamt NUMERIC(28,6) ENCODE az64
,wcinc_limit1_o NUMERIC(13,2) ENCODE az64
,wcinc_limit2_o NUMERIC(13,2) ENCODE az64
,wcinc_deductible1_o NUMERIC(13,2) ENCODE az64
,wcinc_deductible2_o NUMERIC(13,2) ENCODE az64
,wcinc_fulltermamt_o NUMERIC(28,6) ENCODE az64
)
DISTSTYLE KEY
DISTKEY (SystemId)
SORTKEY (
SystemId
)
;

DROP TABLE IF EXISTS kdlab.stg_customer;
CREATE TABLE kdlab.stg_customer
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,customer_uniqueid INTEGER ENCODE az64
,status VARCHAR(1020) ENCODE lzo
,entitytypecd VARCHAR(1020) ENCODE lzo
,first_name VARCHAR(255) ENCODE lzo
,last_name VARCHAR(255) ENCODE lzo
,commercialname VARCHAR(255) ENCODE lzo
,dob TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,gender VARCHAR(10) ENCODE lzo
,maritalstatus VARCHAR(255) ENCODE lzo
,address1 VARCHAR(255) ENCODE lzo
,address2 VARCHAR(255) ENCODE lzo
,county VARCHAR(255) ENCODE lzo
,city VARCHAR(255) ENCODE lzo
,state VARCHAR(255) ENCODE lzo
,postalcode VARCHAR(255) ENCODE lzo
,phone VARCHAR(255) ENCODE lzo
,mobile VARCHAR(255) ENCODE lzo
,email VARCHAR(255) ENCODE lzo
,preferreddeliverymethod VARCHAR(1020) ENCODE lzo
,portalinvitationsentdt DATE ENCODE az64
,paymentreminderind VARCHAR(512) ENCODE lzo
,changedate DATE ENCODE az64
)
DISTSTYLE AUTO
;

DROP TABLE if exists kdlab.stg_producer;
CREATE TABLE kdlab.stg_producer
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,producer_uniqueid VARCHAR(20) ENCODE lzo
,producer_number VARCHAR(20) ENCODE lzo
,producer_name VARCHAR(255) ENCODE lzo
,licenseno VARCHAR(255) ENCODE lzo
,agency_type VARCHAR(11) ENCODE lzo
,address VARCHAR(510) ENCODE lzo
,city VARCHAR(80) ENCODE lzo
,state_cd VARCHAR(5) ENCODE lzo
,zip VARCHAR(10) ENCODE lzo
,phone VARCHAR(20) ENCODE lzo
,fax VARCHAR(15) ENCODE lzo
,email VARCHAR(255) ENCODE lzo
,agency_group VARCHAR(255) ENCODE lzo
,national_name VARCHAR(255) ENCODE lzo
,national_code VARCHAR(20) ENCODE lzo
,territory VARCHAR(50) ENCODE lzo
,territory_manager VARCHAR(50) ENCODE lzo
,dba VARCHAR(255) ENCODE lzo
,producer_status VARCHAR(10) ENCODE lzo
,commission_master VARCHAR(20) ENCODE lzo
,reporting_master VARCHAR(20) ENCODE lzo
,pn_appointment_date DATE NOT NULL ENCODE az64
,profit_sharing_master VARCHAR(20) ENCODE lzo
,producer_master VARCHAR(20) ENCODE lzo
,recognition_tier VARCHAR(100) ENCODE lzo
,rmaddress VARCHAR(100) ENCODE lzo
,rmcity VARCHAR(50) ENCODE lzo
,rmstate VARCHAR(25) ENCODE lzo
,rmzip VARCHAR(25) ENCODE lzo
,new_business_term_date DATE NOT NULL ENCODE az64
,changedate DATE ENCODE az64
)
DISTSTYLE AUTO
;

DROP TABLE IF EXISTS kdlab.stg_policytransaction;																													
CREATE TABLE kdlab.stg_policytransaction																													
(																													
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64																													
,systemid INTEGER ENCODE az64																													
,policy_uniqueid INTEGER ENCODE az64																													
,policytransaction_uniqueid VARCHAR(100) ENCODE lzo																													
,primaryrisk_uniqueid VARCHAR(100) ENCODE lzo																													
,secondaryrisk_uniqueid VARCHAR(100) ENCODE lzo																													
,bookdt DATE ENCODE az64																													
,transactionnumber INTEGER ENCODE az64																													
,accountingdt DATE ENCODE az64																													
,transactioneffectivedt DATE ENCODE az64																													
,transactioncd VARCHAR(50) ENCODE lzo																													
,pt_typecode VARCHAR(10) ENCODE lzo																													
,product_uniqueid VARCHAR(100) ENCODE lzo																													
,company_uniqueid VARCHAR(100) ENCODE lzo																													
,producer_uniqueid VARCHAR(100) ENCODE lzo																													
,coverage_uniqueid VARCHAR(1000) ENCODE lzo																													
,cov_code VARCHAR(50) ENCODE lzo																													
,cov_subcode VARCHAR(50) ENCODE lzo																													
,cov_asl VARCHAR(5) ENCODE lzo																													
,cov_subline VARCHAR(5) ENCODE lzo																													
,cov_classcode VARCHAR(100) ENCODE lzo																													
,cov_deductible1 VARCHAR(255) ENCODE lzo																													
,cov_deductible2 VARCHAR(255) ENCODE lzo																													
,cov_limit1 VARCHAR(255) ENCODE lzo																													
,cov_limit2 VARCHAR(255) ENCODE lzo																													
,writtenpremiumamt NUMERIC(28,6) ENCODE az64																													
,writtencommissionamt NUMERIC(28,6) ENCODE az64																													
,inforcechangeamt NUMERIC(28,6) ENCODE az64																													
)																													
DISTSTYLE KEY																													
DISTKEY (systemid)																													
SORTKEY (																													
systemid																													
)																													
;																													
																													
																													
DROP TABLE IF EXISTS kdlab.stg_policytransactionextension;
CREATE TABLE kdlab.stg_policytransactionextension
(
loaddate TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policytransaction_uniqueid VARCHAR(23) ENCODE lzo
,systemid INTEGER ENCODE az64
,bookdt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,transactioneffectivedt TIMESTAMP WITHOUT TIME ZONE ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,transactionnumber INTEGER ENCODE az64
,transactioncd VARCHAR(255) ENCODE lzo
,transactionlongdescription VARCHAR(512) ENCODE lzo
,transactionshortdescription VARCHAR(255) ENCODE lzo
,canceltypecd VARCHAR(255) ENCODE lzo
,cancelrequestedbycd VARCHAR(255) ENCODE lzo
,cancelreason VARCHAR(35) ENCODE lzo
)
DISTSTYLE KEY
DISTKEY (systemid)
SORTKEY (
systemid
)
;

DROP TABLE IF EXISTS kdlab.stg_policycoverage;
CREATE TABLE kdlab.stg_policycoverage
(
month_id INTEGER ENCODE az64
,policy_uniqueid INTEGER ENCODE az64
,systemid INTEGER ENCODE az64
,coverage_uniqueid VARCHAR(1000) ENCODE lzo
,policystatus_id INTEGER ENCODE az64
,term_prem_amt NUMERIC(38,6) ENCODE az64
,wrtn_prem_amt NUMERIC(38,6) ENCODE az64
,earned_prem_amt NUMERIC(38,6) ENCODE az64
,fees_amt NUMERIC(38,6) ENCODE az64
,cncl_prem_amt NUMERIC(38,6) ENCODE az64
,comm_amt NUMERIC(38,6) ENCODE az64
,comm_earned_amt NUMERIC(38,6) ENCODE az64
,unearned_prem NUMERIC(38,6) ENCODE az64
,spinn_unearned_prem NUMERIC(38,6) ENCODE az64
,spinn_earned_prem_amt_itd NUMERIC(38,6) ENCODE az64
,spinn_earned_prem_amt NUMERIC(38,6) ENCODE az64
,wrtn_prem_amt_itd NUMERIC(38,6) ENCODE az64
,policynewissuedind INTEGER ENCODE az64
,policycancelledissuedind INTEGER ENCODE az64
,policycancelledeffectiveind INTEGER ENCODE az64
,policyexpiredeffectiveind INTEGER ENCODE az64
)
DISTSTYLE AUTO
DISTKEY (systemid)
SORTKEY (
systemid
)
;


DROP TABLE if exists kdlab.stg_exposures;					
CREATE TABLE kdlab.stg_exposures					
(					
factpolicycoverage_id INTEGER					
,month_id INTEGER					
,policy_id INTEGER					
,policy_uniqueid VARCHAR(100)					
,coverage_id INTEGER					
,coverage_uniqueid VARCHAR(100)					
,we_rm NUMERIC(38,4)					
,ee_rm NUMERIC(38,4)					
,we_rm_ytd NUMERIC(38,4)					
,ee_rm_ytd NUMERIC(38,4)					
,we_rm_itd NUMERIC(38,4)					
,ee_rm_itd NUMERIC(38,4)					
)					
DISTSTYLE AUTO					
DISTKEY (policy_id)					
SORTKEY (					
month_id					
)					
;					

																													
																													
																													
																													
																													



