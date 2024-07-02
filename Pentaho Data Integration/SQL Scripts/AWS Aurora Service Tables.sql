CREATE TABLE etl.stg_policyhistory (
SystemId int NOT NULL,
maxSystemId int DEFAULT NULL,
PolicyRef int NOT NULL,
TransactionNumber int NOT NULL,
TransactionCd varchar(255) NOT NULL,
BookDt datetime NOT NULL,
TransactionEffectiveDt datetime NOT NULL,
ReplacedByTransactionNumber int DEFAULT NULL,
ReplacementOfTransactionNumber int DEFAULT NULL,
UnAppliedByTransactionNumber int DEFAULT NULL,
LoadDt datetime NOT NULL,
KEY PolicyRef (PolicyRef),
KEY SystemId (SystemId),
KEY BookDt (BookDt),
KEY maxSystemId (maxSystemId)
) ;

create table etl.coverage_mapping												
(												
CoverageCd varchar(75),												
covx_code varchar(75),												
covx_description varchar(125)												
);												
												
insert into etl.coverage_mapping values ( 'H590ST0','SeniorDiscount','Senior Discount');												
												
insert into etl.coverage_mapping values ( 'DAU1143','COC','Course of Construction');												
insert into etl.coverage_mapping values ( 'F34410A','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'F32470','FRAUD','Identity Recovery Coverage');												
insert into etl.coverage_mapping values ( 'F30630','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'F32465','FRAUD','Identity Recovery Coverage');												
insert into etl.coverage_mapping values ( 'HO2490-Occasional','WCINC','Workers Compensation - Occasional Employee');												
insert into etl.coverage_mapping values ( 'F34395A','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'HO5','HO5','Contents Open Perils');												
insert into etl.coverage_mapping values ( 'H070ST0','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'BOLCC','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'F30655','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'CovC','CovC','Boat Trailer');												
insert into etl.coverage_mapping values ( 'CovA-EC','CovA','Dwelling (Extended Coverage)');												
insert into etl.coverage_mapping values ( 'UTLDB','UTLDB','Service Line');												
insert into etl.coverage_mapping values ( 'SRORP','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'PP','CovC','Personal Property (Extended Coverage)');												
insert into etl.coverage_mapping values ( 'OccupationCredit','OccupationDiscount','Occupation Discount');												
insert into etl.coverage_mapping values ( 'F.34415A','OLT','Landlord Eviction Expense Reimbursement');												
insert into etl.coverage_mapping values ( 'IncreasedOtherStructures','INCB','Other Structures Increased Limit');												
insert into etl.coverage_mapping values ( 'DAUPI','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'F.34355A','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'BEDBUG','BEDBUG','Bed Bug Coverage');												
insert into etl.coverage_mapping values ( 'G.30980','SPP','Scheduled Personal Property');												
insert into etl.coverage_mapping values ( 'G30980','SPP','Scheduled Personal Property');												
insert into etl.coverage_mapping values ( 'FRAUD','FRAUD','Identity Recovery Coverage');												
insert into etl.coverage_mapping values ( 'F.32830','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'DAU0463','LAC','Loss Assessment');												
insert into etl.coverage_mapping values ( 'EQPBK','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'F34355A','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'H082ST0','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'H048ST0','INCB','Other Structures Increased Limit');												
insert into etl.coverage_mapping values ( 'SPP','SPP','Scheduled Personal Property');												
insert into etl.coverage_mapping values ( 'SEWER','SEWER','Backup of Sewers and Drains');												
insert into etl.coverage_mapping values ( 'H051ST0','H051ST0','Building Additions and Alterations Increased Limit');												
insert into etl.coverage_mapping values ( 'F.31890','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'Senior','SeniorDiscount','Senior Discount');												
insert into etl.coverage_mapping values ( 'PRTDVC','PRTDVC','Protective Devices (Security/Fire/Other)');												
insert into etl.coverage_mapping values ( 'H065ST0','INCC','Personal Property Increased Limit');												
insert into etl.coverage_mapping values ( 'OS','CovB','Other Structures');												
insert into etl.coverage_mapping values ( 'MBEBU','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'PL','CovE','Personal Liability');												
insert into etl.coverage_mapping values ( 'F32815','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'WCINC','WCINC','Workers Compensation');												
insert into etl.coverage_mapping values ( 'BuildingOrdinance','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'THEFA','THEFA','Theft');												
insert into etl.coverage_mapping values ( 'MedPay','MEDPAY','Medical Payments/Expense');												
insert into etl.coverage_mapping values ( 'F.32815','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'H500ST0','PPREP','Personal Property Replacement Cost Option');												
insert into etl.coverage_mapping values ( 'CovC-SF','CovC','Personal Property (Fire and Lightning - Special Form)');												
insert into etl.coverage_mapping values ( 'F.34395A','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'F34390A','UTLDB','Service Line');												
insert into etl.coverage_mapping values ( 'CovA','CovA','Dwelling (Fire and Lightning)');												
insert into etl.coverage_mapping values ( 'LOU','CovD','Loss of Use/Fair Rental Value');												
insert into etl.coverage_mapping values ( 'ALARM','PRTDVC','Protective Devices (Security/Fire/Other)');												
insert into etl.coverage_mapping values ( 'MEDPM','MEDPAY','Medical Payments/Expense');												
insert into etl.coverage_mapping values ( 'LAC','LAC','Loss Assessment');												
insert into etl.coverage_mapping values ( 'INCC','INCC','Personal Property Increased Limit');												
insert into etl.coverage_mapping values ( 'F.34420A','PPREP','Personal Property Replacement Cost Option');												
insert into etl.coverage_mapping values ( 'F.32465','FRAUD','Identity Recovery Coverage');												
insert into etl.coverage_mapping values ( 'ML0090','WCINC','Workers Compensation');												
insert into etl.coverage_mapping values ( 'AddCovC','INCC','Personal Property Increased Limit');												
insert into etl.coverage_mapping values ( 'FireProtection','PRTDVC','Protective Devices (Security/Fire/Other)');												
insert into etl.coverage_mapping values ( 'F34415A','OLT','Landlord Eviction Expense Reimbursement');												
insert into etl.coverage_mapping values ( 'H033ST0','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'F.34410A','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'SeniorDiscount','SeniorDiscount','Senior Discount');												
insert into etl.coverage_mapping values ( 'ML0090Occasional','WCINC','Workers Compensation - Occasional Employee');												
insert into etl.coverage_mapping values ( 'OLT','OLT','Landlord Eviction Expense Reimbursement');												
insert into etl.coverage_mapping values ( 'H090CA0','WCINC','Workers Compensation');												
insert into etl.coverage_mapping values ( 'F32830','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'CovD','CovD','Unattached Boat Equipment');												
insert into etl.coverage_mapping values ( 'F.34390A','UTLDB','Service Line');												
insert into etl.coverage_mapping values ( 'ProtectiveDevices','PRTDVC','Protective Devices (Security/Fire/Other)');												
insert into etl.coverage_mapping values ( 'CovC-EC','CovC','Personal Property (Extended Coverage)');												
insert into etl.coverage_mapping values ( 'H061ST0','SPP','Scheduled Personal Property');												
insert into etl.coverage_mapping values ( 'F.32820','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'CovC-FL','CovC','Personal Property (Fire and Lightning)');												
insert into etl.coverage_mapping values ( 'MEDPAY','MEDPAY','Medical Payments/Expense');												
insert into etl.coverage_mapping values ( 'DAU0472','THEFA','Theft');												
insert into etl.coverage_mapping values ( 'F.32825','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'F.34350A','INCB','Other Structures Increased Limit');												
insert into etl.coverage_mapping values ( 'DWELL','CovA','Dwelling');												
insert into etl.coverage_mapping values ( 'H037ST0','LAC','Loss Assessment');												
insert into etl.coverage_mapping values ( 'F.30630','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'H040ST0','SRORP','Structures Rented to Others Residence Premises');												
insert into etl.coverage_mapping values ( 'CovA-FL','CovA','Dwelling (Fire and Lightning)');												
insert into etl.coverage_mapping values ( 'F.32470','FRAUD','Identity Recovery Coverage');												
insert into etl.coverage_mapping values ( 'F.30655','BOLAW','Building Ordinance or Law');												
insert into etl.coverage_mapping values ( 'INCB','INCB','Other Structures Increased Limit');												
insert into etl.coverage_mapping values ( 'F32820','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'HO2490','WCINC','Workers Compensation');												
insert into etl.coverage_mapping values ( 'CovA-SF','CovA','Dwelling (Fire and Lightning - Special Form)');												
insert into etl.coverage_mapping values ( 'F34420A','PPREP','Personal Property Replacement Cost Option');												
insert into etl.coverage_mapping values ( 'H090CA0-Occasional','WCINC','Workers Compensation - Occasional Employee');												
insert into etl.coverage_mapping values ( 'F31890','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'ALEXP','CovE','Additional Living Expenses (Fire and Lightning)');												
insert into etl.coverage_mapping values ( 'PIHOM','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'CovF','MEDPAY','Medical Payments/Expense');												
insert into etl.coverage_mapping values ( 'H035ST0','LAC','Loss Assessment');												
insert into etl.coverage_mapping values ( 'F34350A','INCB','Other Structures Increased Limit');												
insert into etl.coverage_mapping values ( 'F32825','EQPBK','Equipment Breakdown');												
insert into etl.coverage_mapping values ( 'MEDEX','MEDPAY','Medical Payments/Expense');												
insert into etl.coverage_mapping values ( 'L9287','PIHOM','Personal Injury Liability');												
insert into etl.coverage_mapping values ( 'PPREP','PPREP','Personal Property Replacement Cost Option');												
insert into etl.coverage_mapping values ( 'H050ST0','INCC','Personal Property Increased Limit');												
insert into etl.coverage_mapping values ( 'CovE','CovE','Liability');												
insert into etl.coverage_mapping values ( 'FRV','CovD','Loss of Use/Fair Rental Value (Fire and Lightning)');												
insert into etl.coverage_mapping values ( 'H216ST0','PRTDVC','Protective Devices (Security/Fire/Other)');												
insert into etl.coverage_mapping values ( 'MATUR','SeniorDiscount','Senior Discount');												
insert into etl.coverage_mapping values ( 'H080ST0','THEFA','Theft');												
insert into etl.coverage_mapping values ( 'CovB','CovB','Other Structures (Extended Coverage)');												
insert into etl.coverage_mapping values ( 'COC','COC','Course of Construction');												
insert into etl.coverage_mapping values ( 'BOLAW','BOLAW','Building Ordinance or Law');												
