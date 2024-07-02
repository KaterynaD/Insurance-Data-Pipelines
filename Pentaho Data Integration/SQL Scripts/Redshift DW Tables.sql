CREATE TABLE DW_MGA.Dim_address(									
ADDRESS_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
ADDRESS1 varchar(150) NOT NULL,									
ADDRESS2 varchar(150) NOT NULL,									
COUNTY varchar(50) NOT NULL,									
CITY varchar(50) NOT NULL,									
STATE varchar(50) NOT NULL,									
POSTALCODE varchar(20) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
address_id									
);									
ALTER TABLE DW_MGA.Dim_address ADD CONSTRAINT Dim_address_pkey PRIMARY KEY (ADDRESS_ID);									
									
									
									
CREATE TABLE DW_MGA.Dim_policy(									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
TransactionCd varchar(255) NOT NULL,									
POLICYNUMBER varchar(50) NOT NULL,									
TERM varchar(10) NOT NULL,									
EFFECTIVEDATE date NOT NULL,									
EXPIRATIONDATE date NOT NULL,									
CarrierCd varchar(255) NOT NULL,									
CompanyCd varchar(255) NOT NULL,									
TermDays integer NOT NULL,									
CarrierGroupCd varchar(255) NOT NULL,									
StateCD varchar(255) NOT NULL,									
BusinessSourceCd varchar(255) NOT NULL,									
PreviouscarrierCd varchar(255) NOT NULL,									
PolicyFormCode varchar(255) NOT NULL,									
SubTypeCd varchar(255) NOT NULL,									
payPlanCd varchar(255) NOT NULL,									
InceptionDt date NOT NULL,									
PriorPolicyNumber varchar(255) NOT NULL,									
PreviousPolicyNumber varchar(255) NOT NULL,									
AffinityGroupCd varchar(255) NOT NULL,									
ProgramInd varchar(255) NOT NULL,									
RelatedPolicyNumber varchar(255) NOT NULL,									
TwoPayDiscountInd varchar(255) NOT NULL,									
QuoteNumber varchar(255) NOT NULL,									
RenewalTermCd varchar(255) NOT NULL,									
RewritePolicyRef varchar(255) NOT NULL,									
RewriteFromPolicyRef varchar(255) NOT NULL,									
CancelDt date NOT NULL,									
ReinstateDt date NOT NULL,									
PersistencyDiscountDt date NOT NULL,									
PaperLessDelivery varchar(10) NOT NULL,									
MultiCarDiscountInd varchar(255) NOT NULL,									
LateFee varchar(255) NOT NULL,									
NSFFee varchar(255) NOT NULL,									
InstallmentFee varchar(255) NOT NULL,									
batchquotesourcecd varchar(255) NOT NULL,									
WaivePolicyFeeInd varchar(255) NOT NULL,									
LiabilityLimitCPL varchar(255) NOT NULL,									
LiabilityReductionInd varchar(255) NOT NULL,									
LiabilityLimitOLT varchar(255) NOT NULL,									
PersonalLiabilityLimit varchar(255) NOT NULL,									
GLOccurrenceLimit varchar(255) NOT NULL,									
GLAggregateLimit varchar(255) NOT NULL,									
Policy_SPINN_Status varchar(255) NOT NULL,									
BILimit varchar(255) NOT NULL,									
PDLimit varchar(255) NOT NULL,									
UMBILimit varchar(255) NOT NULL,									
MedPayLimit varchar(255) NOT NULL,									
MultiPolicyDiscount varchar(3) NOT NULL,									
MultiPolicyAutoDiscount varchar(255) NOT NULL,									
MultiPolicyAutoNumber varchar(255) NOT NULL,									
MultiPolicyHomeDiscount varchar(255) NOT NULL,									
HomeRelatedPolicyNumber varchar(255) NOT NULL,									
MultiPolicyUmbrellaDiscount varchar(255) NOT NULL,									
UmbrellaRelatedPolicyNumber varchar(255) NOT NULL,									
CSEEmployeeDiscountInd varchar(255) NOT NULL,									
FullPayDiscountInd varchar(255) NOT NULL,									
PrimaryPolicyNumber varchar(255) NOT NULL,									
LandLordInd varchar(255) NOT NULL,									
PersonalInjuryInd varchar(255) NOT NULL,									
VehicleListConfirmedInd varchar(4) NOT NULL,									
AltSubTypeCd varchar(32) NOT NULL,									
FirstPayment date NOT NULL,									
LastPayment date NOT NULL,									
BalanceAmt numeric(13,2) NOT NULL,									
PaidAmt numeric(13,2) NOT NULL,									
PRODUCT_UNIQUEID varchar(100) NOT NULL,									
COMPANY_UNIQUEID varchar(100) NOT NULL,									
PRODUCER_UNIQUEID varchar(100) NOT NULL,									
FIRSTINSURED_UNIQUEID varchar(100) NOT NULL,									
AccountRef integer NOT NULL,									
CUSTOMER_UNIQUEID integer NOT NULL,									
MGAFeePlanCd varchar(24) NOT NULL,									
MGAFeePct numeric(28,6) NOT NULL,									
TPAFeePlanCd varchar(24) NOT NULL,									
TPAFeePct numeric(28,6)  NOT NULL									
)									
SORTKEY									
(									
POLICY_ID									
);									
ALTER TABLE DW_MGA.DIM_POLICY ADD CONSTRAINT DIM_POLICY_pkey PRIMARY KEY (POLICY_ID);									
									
CREATE TABLE DW_MGA.Dim_application(									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
TransactionCd varchar(255) NOT NULL,									
POLICYNUMBER varchar(50) NOT NULL,									
TERM varchar(10) NOT NULL,									
EFFECTIVEDATE date NOT NULL,									
EXPIRATIONDATE date NOT NULL,									
CarrierCd varchar(255) NOT NULL,									
CompanyCd varchar(255) NOT NULL,									
TermDays integer NOT NULL,									
CarrierGroupCd varchar(255) NOT NULL,									
StateCD varchar(255) NOT NULL,									
BusinessSourceCd varchar(255) NOT NULL,									
PreviouscarrierCd varchar(255) NOT NULL,									
PolicyFormCode varchar(255) NOT NULL,									
SubTypeCd varchar(255) NOT NULL,									
payPlanCd varchar(255) NOT NULL,									
InceptionDt date NOT NULL,									
PriorPolicyNumber varchar(255) NOT NULL,									
PreviousPolicyNumber varchar(255) NOT NULL,									
AffinityGroupCd varchar(255) NOT NULL,									
ProgramInd varchar(255) NOT NULL,									
RelatedPolicyNumber varchar(255) NOT NULL,									
TwoPayDiscountInd varchar(255) NOT NULL,									
QuoteNumber varchar(255) NOT NULL,									
RenewalTermCd varchar(255) NOT NULL,									
RewritePolicyRef varchar(255) NOT NULL,									
RewriteFromPolicyRef varchar(255) NOT NULL,									
CancelDt date NOT NULL,									
ReinstateDt date NOT NULL,									
PersistencyDiscountDt date NOT NULL,									
PaperLessDelivery varchar(10) NOT NULL,									
MultiCarDiscountInd varchar(255) NOT NULL,									
LateFee varchar(255) NOT NULL,									
NSFFee varchar(255) NOT NULL,									
InstallmentFee varchar(255) NOT NULL,									
batchquotesourcecd varchar(255) NOT NULL,									
WaivePolicyFeeInd varchar(255) NOT NULL,									
LiabilityLimitCPL varchar(255) NOT NULL,									
LiabilityReductionInd varchar(255) NOT NULL,									
LiabilityLimitOLT varchar(255) NOT NULL,									
PersonalLiabilityLimit varchar(255) NOT NULL,									
GLOccurrenceLimit varchar(255) NOT NULL,									
GLAggregateLimit varchar(255) NOT NULL,									
Policy_SPINN_Status varchar(255) NOT NULL,									
BILimit varchar(255) NOT NULL,									
PDLimit varchar(255) NOT NULL,									
UMBILimit varchar(255) NOT NULL,									
MedPayLimit varchar(255) NOT NULL,									
MultiPolicyDiscount varchar(3) NOT NULL,									
MultiPolicyAutoDiscount varchar(255) NOT NULL,									
MultiPolicyAutoNumber varchar(255) NOT NULL,									
MultiPolicyHomeDiscount varchar(255) NOT NULL,									
HomeRelatedPolicyNumber varchar(255) NOT NULL,									
MultiPolicyUmbrellaDiscount varchar(255) NOT NULL,									
UmbrellaRelatedPolicyNumber varchar(255) NOT NULL,									
CSEEmployeeDiscountInd varchar(255) NOT NULL,									
FullPayDiscountInd varchar(255) NOT NULL,									
PrimaryPolicyNumber varchar(255) NOT NULL,									
LandLordInd varchar(255) NOT NULL,									
PersonalInjuryInd varchar(255) NOT NULL,									
VehicleListConfirmedInd varchar(4) NOT NULL,									
AltSubTypeCd varchar(32) NOT NULL,									
FirstPayment date NOT NULL,									
LastPayment date NOT NULL,									
BalanceAmt numeric(13,2) NOT NULL,									
PaidAmt numeric(13,2) NOT NULL,									
PRODUCT_UNIQUEID varchar(100) NOT NULL,									
COMPANY_UNIQUEID varchar(100) NOT NULL,									
PRODUCER_UNIQUEID varchar(100) NOT NULL,									
FIRSTINSURED_UNIQUEID varchar(100) NOT NULL,									
AccountRef integer NOT NULL,									
CUSTOMER_UNIQUEID integer NOT NULL,									
MGAFeePlanCd varchar(24) NOT NULL,									
MGAFeePct numeric(28,6) NOT NULL,									
TPAFeePlanCd varchar(24) NOT NULL,									
TPAFeePct numeric(28,6)  NOT NULL,									
ApplicationNumber varchar(255)Not  NULL,									
Application_UpdateTimestamp datetime NOT NULL,									
QuoteInfo_UpdateDt   date NOT  NULL,									
QuoteInfo_adduser_uniqueid varchar(255) NOT NULL,									
original_policy_uniqueid int NOT NULL,									
Application_Type varchar(255) NOT NULL,									
QuoteInfo_Type varchar(255) NOT NULL,									
Application_Status varchar(255) NOT NULL,									
QuoteInfo_Status varchar(255) NOT NULL,									
QuoteInfo_CloseReasonCd varchar(255) NOT NULL,									
QuoteInfo_CloseSubReasonCd varchar(255) NOT NULL,									
QuoteInfo_CloseComment varchar(255) NOT NULL,									
WrittenPremiumAmt decimal(38, 6) NOT NULL,									
FullTermAmt decimal(38, 6) NOT NULL,									
CommissionAmt decimal(38, 6) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_application ADD CONSTRAINT DIM_application_pkey PRIMARY KEY (SystemId);									
CREATE TABLE DW_MGA.Dim_building(									
BUILDING_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
Risk_UniqueId varchar(255) NOT NULL,									
BldgNumber integer NOT NULL,									
Building_uniqueid varchar(525) NOT NULL,									
SPInnBuilding_Id varchar(255) NOT NULL,									
Status varchar(255) NOT NULL,									
StateProvCd varchar(255) NOT NULL,									
County varchar(255) NOT NULL,									
PostalCode varchar(255) NOT NULL,									
City varchar(255) NOT NULL,									
Addr1 varchar(255) NOT NULL,									
Addr2 varchar(255) NOT NULL,									
BusinessCategory varchar(255) NOT NULL,									
BusinessClass varchar(255) NOT NULL,									
ConstructionCd varchar(255) NOT NULL,									
RoofCd varchar(255) NOT NULL,									
YearBuilt integer NOT NULL,									
SqFt integer NOT NULL,									
Stories integer NOT NULL,									
Units integer NOT NULL,									
OccupancyCd varchar(255) NOT NULL,									
ProtectionClass varchar(255) NOT NULL,									
TerritoryCd varchar(255) NOT NULL,									
BuildingLimit integer NOT NULL,									
ContentsLimit integer NOT NULL,									
ValuationMethod varchar(255) NOT NULL,									
InflationGuardPct integer NOT NULL,									
OrdinanceOrLawInd varchar(255) NOT NULL,									
ScheduledPremiumMod integer NOT NULL,									
WindHailExclusion varchar(255) NOT NULL,									
CovALimit integer NOT NULL,									
CovBLimit integer NOT NULL,									
CovCLimit integer NOT NULL,									
CovDLimit integer NOT NULL,									
CovELimit integer NOT NULL,									
CovFLimit integer NOT NULL,									
AllPerilDed varchar(255) NOT NULL,									
BurglaryAlarmType varchar(255) NOT NULL,									
FireAlarmType varchar(255) NOT NULL,									
CovBLimitIncluded integer NOT NULL,									
CovBLimitIncrease integer NOT NULL,									
CovCLimitIncluded integer NOT NULL,									
CovCLimitIncrease integer NOT NULL,									
CovDLimitIncluded integer NOT NULL,									
CovDLimitIncrease integer NOT NULL,									
OrdinanceOrLawPct integer NOT NULL,									
NeighborhoodCrimeWatchInd varchar(255) NOT NULL,									
EmployeeCreditInd varchar(255) NOT NULL,									
MultiPolicyInd varchar(255) NOT NULL,									
HomeWarrantyCreditInd varchar(255) NOT NULL,									
YearOccupied integer NOT NULL,									
YearPurchased integer NOT NULL,									
TypeOfStructure varchar(255) NOT NULL,									
FeetToFireHydrant integer NOT NULL,									
NumberOfFamilies integer NOT NULL,									
MilesFromFireStation integer NOT NULL,									
Rooms integer NOT NULL,									
RoofPitch varchar(255) NOT NULL,									
FireDistrict varchar(255) NOT NULL,									
SprinklerSystem varchar(255) NOT NULL,									
FireExtinguisherInd varchar(255) NOT NULL,									
KitchenFireExtinguisherInd varchar(255) NOT NULL,									
DeadboltInd varchar(255) NOT NULL,									
GatedCommunityInd varchar(255) NOT NULL,									
CentralHeatingInd varchar(255) NOT NULL,									
Foundation varchar(255) NOT NULL,									
WiringRenovation varchar(255) NOT NULL,									
WiringRenovationCompleteYear varchar(255) NOT NULL,									
PlumbingRenovation varchar(255) NOT NULL,									
HeatingRenovation varchar(255) NOT NULL,									
PlumbingRenovationCompleteYear varchar(255) NOT NULL,									
exteriorpaintrenovation varchar(255) NOT NULL,									
HeatingRenovationCompleteYear varchar(255) NOT NULL,									
CircuitBreakersInd varchar(255) NOT NULL,									
CopperWiringInd varchar(255) NOT NULL,									
exteriorpaintrenovationcompleteyear varchar(255) NOT NULL,									
CopperPipesInd varchar(255) NOT NULL,									
EarthquakeRetrofitInd varchar(255) NOT NULL,									
PrimaryFuelSource varchar(255) NOT NULL,									
SecondaryFuelSource varchar(255) NOT NULL,									
UsageType varchar(255) NOT NULL,									
HomegardCreditInd varchar(255) NOT NULL,									
MultiPolicyNumber varchar(255) NOT NULL,									
LocalFireAlarmInd varchar(255) NOT NULL,									
NumLosses integer NOT NULL,									
CovALimitIncrease integer NOT NULL,									
CovALimitIncluded integer NOT NULL,									
MonthsRentedOut integer NOT NULL,									
RoofReplacement varchar(255) NOT NULL,									
SafeguardPlusInd varchar(255) NOT NULL,									
CovELimitIncluded integer NOT NULL,									
RoofReplacementCompleteYear varchar(255) NOT NULL,									
CovELimitIncrease integer NOT NULL,									
OwnerOccupiedUnits integer NOT NULL,									
TenantOccupiedUnits integer NOT NULL,									
ReplacementCostDwellingInd varchar(255) NOT NULL,									
FeetToPropertyLine varchar(255) NOT NULL,									
GalvanizedPipeInd varchar(255) NOT NULL,									
WorkersCompInservant integer NOT NULL,									
WorkersCompOutservant integer NOT NULL,									
LiabilityTerritoryCd varchar(255) NOT NULL,									
PremisesLiabilityMedPayInd varchar(255) NOT NULL,									
RelatedPrivateStructureExclusion varchar(255) NOT NULL,									
VandalismExclusion varchar(255) NOT NULL,									
VandalismInd varchar(255) NOT NULL,									
RoofExclusion varchar(255) NOT NULL,									
ExpandedReplacementCostInd varchar(255) NOT NULL,									
ReplacementValueInd varchar(255) NOT NULL,									
OtherPolicyNumber1 varchar(255) NOT NULL,									
OtherPolicyNumber2 varchar(255) NOT NULL,									
OtherPolicyNumber3 varchar(255) NOT NULL,									
PrimaryPolicyNumber varchar(255) NOT NULL,									
OtherPolicyNumbers varchar(255) NOT NULL,									
ReportedFireHazardScore varchar(255) NOT NULL,									
FireHazardScore varchar(255) NOT NULL,									
ReportedSteepSlopeInd varchar(255) NOT NULL,									
SteepSlopeInd varchar(255) NOT NULL,									
ReportedHomeReplacementCost integer NOT NULL,									
ReportedProtectionClass varchar(255) NOT NULL,									
EarthquakeZone varchar(255) NOT NULL,									
MMIScore varchar(255) NOT NULL,									
HomeInspectionDiscountInd varchar(255) NOT NULL,									
RatingTier varchar(255) NOT NULL,									
SoilTypeCd varchar(255) NOT NULL,									
ReportedFireLineAssessment varchar(255) NOT NULL,									
AAISFireProtectionClass varchar(255) NOT NULL,									
InspectionScore varchar(255) NOT NULL,									
AnnualRents integer NOT NULL,									
PitchOfRoof varchar(255) NOT NULL,									
TotalLivingSqFt integer NOT NULL,									
ParkingSqFt integer NOT NULL,									
ParkingType varchar(255) NOT NULL,									
RetrofitCompleted varchar(255) NOT NULL,									
NumPools varchar(255) NOT NULL,									
FullyFenced varchar(255) NOT NULL,									
DivingBoard varchar(255) NOT NULL,									
Gym varchar(255) NOT NULL,									
FreeWeights varchar(255) NOT NULL,									
WireFencing varchar(255) NOT NULL,									
OtherRecreational varchar(255) NOT NULL,									
OtherRecreationalDesc varchar(255) NOT NULL,									
HealthInspection varchar(255) NOT NULL,									
HealthInspectionDt timestamp NOT NULL,									
HealthInspectionCited varchar(255) NOT NULL,									
PriorDefectRepairs varchar(255) NOT NULL,									
MSBReconstructionEstimate varchar(255) NOT NULL,									
BIIndemnityPeriod varchar(255) NOT NULL,									
EquipmentBreakdown varchar(255) NOT NULL,									
MoneySecurityOnPremises varchar(255) NOT NULL,									
MoneySecurityOffPremises varchar(255) NOT NULL,									
WaterBackupSump varchar(255) NOT NULL,									
SprinkleredBuildings varchar(255) NOT NULL,									
SurveillanceCams varchar(255) NOT NULL,									
GatedComplexKeyAccess varchar(255) NOT NULL,									
EQRetrofit varchar(255) NOT NULL,									
UnitsPerBuilding varchar(255) NOT NULL,									
NumStories varchar(255) NOT NULL,									
ConstructionQuality varchar(255) NOT NULL,									
BurglaryRobbery varchar(255) NOT NULL,									
NFPAClassification varchar(255) NOT NULL,									
AreasOfCoverage varchar(255) NOT NULL,									
CODetector varchar(255) NOT NULL,									
SmokeDetector varchar(255) NOT NULL,									
SmokeDetectorInspectInd varchar(255) NOT NULL,									
WaterHeaterSecured varchar(255) NOT NULL,									
BoltedOrSecured varchar(255) NOT NULL,									
SoftStoryCripple varchar(255) NOT NULL,									
SeniorHousingPct varchar(255) NOT NULL,									
DesignatedSeniorHousing varchar(255) NOT NULL,									
StudentHousingPct varchar(255) NOT NULL,									
DesignatedStudentHousing varchar(255) NOT NULL,									
PriorLosses integer NOT NULL,									
TenantEvictions varchar(255) NOT NULL,									
VacancyRateExceed varchar(255) NOT NULL,									
SeasonalRentals varchar(255) NOT NULL,									
CondoInsuingAgmt varchar(255) NOT NULL,									
GasValve varchar(255) NOT NULL,									
OwnerOccupiedPct varchar(255) NOT NULL,									
RestaurantName varchar(255) NOT NULL,									
HoursOfOperation varchar(255) NOT NULL,									
RestaurantSqFt integer NOT NULL,									
SeatingCapacity integer NOT NULL,									
AnnualGrossSales integer NOT NULL,									
SeasonalOrClosed varchar(255) NOT NULL,									
BarCocktailLounge varchar(255) NOT NULL,									
LiveEntertainment varchar(255) NOT NULL,									
BeerWineGrossSales varchar(255) NOT NULL,									
DistilledSpiritsServed varchar(255) NOT NULL,									
KitchenDeepFryer varchar(255) NOT NULL,									
SolidFuelCooking varchar(255) NOT NULL,									
ANSULSystem varchar(255) NOT NULL,									
ANSULAnnualInspection varchar(255) NOT NULL,									
TenantNamesList varchar(255) NOT NULL,									
TenantBusinessType varchar(255) NOT NULL,									
TenantGLLiability varchar(255) NOT NULL,									
InsuredOccupiedPortion varchar(255) NOT NULL,									
ValetParking varchar(255) NOT NULL,									
LessorSqFt integer NOT NULL,									
BuildingRiskNumber integer NOT NULL,									
MultiPolicyIndUmbrella varchar(255) NOT NULL,									
PoolInd varchar(255) NOT NULL,									
StudsUpRenovation varchar(255) NOT NULL,									
StudsUpRenovationCompleteYear varchar(255) NOT NULL,									
MultiPolicyNumberUmbrella varchar(255) NOT NULL,									
RCTMSBAmt varchar(255) NOT NULL,									
RCTMSBHomeStyle varchar(255) NOT NULL,									
WINSOverrideNonSmokerDiscount varchar(255) NOT NULL,									
WINSOverrideSeniorDiscount varchar(255) NOT NULL,									
ITV integer NOT NULL,									
ITVDate timestamp NOT NULL,									
MSBReportType varchar(255) NOT NULL,									
VandalismDesiredInd varchar(255) NOT NULL,									
WoodShakeSiding varchar(255) NOT NULL,									
CSEAgent varchar(3) NOT NULL,									
PropertyManager varchar(3) NOT NULL,									
RentersInsurance varchar(3) NOT NULL,									
WaterDetectionDevice varchar(3) NOT NULL,									
AutoHomeInd varchar(3) NOT NULL,									
EarthquakeUmbrellaInd varchar(3) NOT NULL,									
LandlordInd varchar(3) NOT NULL,									
LossAssessment varchar(16) NOT NULL,									
GasShutOffInd varchar(4) NOT NULL,									
WaterDed varchar(16) NOT NULL,									
ServiceLine varchar(4) NOT NULL,									
FunctionalReplacementCost varchar(4) NOT NULL,									
MilesOfStreet varchar(32) NOT NULL,									
HOAExteriorStructure varchar(3) NOT NULL,									
RetailPortionDevelopment varchar(32) NOT NULL,									
LightIndustrialType varchar(128) NOT NULL,									
LightIndustrialDescription varchar(128) NOT NULL,									
PoolCoverageLimit integer NOT NULL,									
MultifamilyResidentialBuildings integer NOT NULL,									
SinglefamilyDwellings integer NOT NULL,									
AnnualPayroll integer NOT NULL,									
AnnualRevenue integer NOT NULL,									
BedsOccupied varchar(16) NOT NULL,									
EmergencyLighting varchar(4) NOT NULL,									
ExitSignsPosted varchar(4) NOT NULL,									
FullTimeStaff varchar(4) NOT NULL,									
LicensedBeds varchar(10) NOT NULL,									
NumberofFireExtinguishers integer NOT NULL,									
OtherFireExtinguishers varchar(16) NOT NULL,									
OxygenTanks varchar(4) NOT NULL,									
PartTimeStaff varchar(4) NOT NULL,									
SmokingPermitted varchar(4) NOT NULL,									
StaffOnDuty varchar(4) NOT NULL,									
TypeofFireExtinguishers varchar(32) NOT NULL,									
CovADDRR_SecondaryResidence varchar(3) NOT NULL,									
CovADDRRPrem_SecondaryResidence numeric(13, 2) NOT NULL,									
HODeluxe varchar(3) NOT NULL,									
Latitude decimal(18, 12) NOT NULL,									
Longitude decimal(18, 12) NOT NULL,									
LineCD varchar(255) NOT NULL,									
WUIClass varchar(30) NOT NULL,									
CensusBlock varchar(30) NOT NULL,									
WaterRiskScore integer NOT NULL,									
LandlordLossPreventionServices varchar(5) NOT NULL,									
EnhancedWaterCoverage varchar(5) NOT NULL,									
LandlordProperty varchar(5) NOT NULL,									
LiabilityExtendedToOthers varchar(5) NOT NULL,									
LossOfUseExtendedTime varchar(5) NOT NULL,									
OnPremisesTheft integer NOT NULL,									
BedBugMitigation varchar(5) NOT NULL,									
HabitabilityExclusion varchar(5) NOT NULL,									
WildfireHazardPotential varchar(20) NOT NULL,									
BackupOfSewersAndDrains integer NOT NULL,									
VegetationSetbackFt integer NOT NULL,									
YardDebrisCoverageArea integer NOT NULL,									
YardDebrisCoveragePercentage varchar(5) NOT NULL,									
CapeTrampoline varchar(16) NOT NULL,									
CapePool varchar(16) NOT NULL,									
RoofConditionRating varchar(16) NOT NULL,									
TrampolineInd varchar(16) NOT NULL,									
PlumbingMaterial varchar(16) NOT NULL,									
CentralizedHeating varchar(16) NOT NULL,									
FireDistrictSubscriptionCode varchar(8) NOT NULL,									
RoofCondition varchar(20) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_BUILDING ADD CONSTRAINT DIM_BUILDING_pkey PRIMARY KEY (BUILDING_ID);									
CREATE TABLE DW_MGA.DIM_CLAIM(									
CLAIM_ID integer NOT NULL,	CLAIM_ID								
SOURCE_SYSTEM varchar(100) NOT NULL,	SOURCE_SYSTEM								
LOADDATE timestamp NOT NULL,	LOADDATE								
CLAIM_UNIQUEID varchar(100) NOT NULL,	CLAIM_UNIQUEID								
POLICY_UNIQUEID integer NOT NULL,	POLICY_UNIQUEID								
POLICY_ID integer NOT NULL,	POLICY_ID								
SystemId integer NOT NULL DISTKEY,	PolicySystemId								
CLAIMNUMBER varchar(50) NOT NULL,	CLAIMNUMBER								
FEATURENUMBER varchar(50) NOT NULL,	FEATURENUMBER								
DATEOFLOSS timestamp NOT NULL,	DATEOFLOSS								
LOSSREPORTEDDATE timestamp NOT NULL,	LOSSREPORTEDDATE								
RiskCd varchar(255) NOT NULL,	RiskCd								
AnnualStatementLineCd varchar(255) NOT NULL,	AnnualStatementLineCd								
SublineCd varchar(255) NOT NULL,	SublineCd								
CarrierCd varchar(255) NOT NULL,	CarrierCd								
CompanyCd varchar(255) NOT NULL,	CompanyCd								
CarrierGroupCd varchar(255) NOT NULL,	CarrierGroupCd								
ClaimantCd varchar(255) NOT NULL,	ClaimantCd								
FeatureCd varchar(255) NOT NULL,	FeatureCd								
FeatureSubCd varchar(255) NOT NULL,	FeatureSubCd								
FeatureTypeCd varchar(255) NOT NULL,	FeatureTypeCd								
ReserveCd varchar(255) NOT NULL,	ReserveCd								
ReserveTypeCd varchar(255) NOT NULL,	ReserveTypeCd								
AtFaultCd varchar(255) NOT NULL,	AtFaultCd								
SourceCd varchar(255) NOT NULL,	SourceCd								
CateryCd varchar(255) NOT NULL,	CategoryCd								
LossCauseCd varchar(255) NOT NULL,	LossCauseCd								
ReportedTo varchar(255) NOT NULL,	ReportedTo								
ReportedBy varchar(255) NOT NULL,	ReportedBy								
DamageDesc varchar(255) NOT NULL,	DamageDesc								
ShortDesc varchar(255) NOT NULL,	ShortDesc								
Description varchar(255) NOT NULL,	Description								
Comment varchar(255) NOT NULL,	Comment								
CATCODE varchar(100) NOT NULL,	CATCODE								
CATDESCRIPTION varchar(255) NOT NULL,	CATDESCRIPTION								
TotalLossInd varchar(255) NOT NULL,	TotalLossInd								
SalvageOwnerRetainedInd varchar(255) NOT NULL,	SalvageOwnerRetainedInd								
SuitFiledInd varchar(10) NOT NULL,	SuitFiledInd								
InSIUInd varchar(3) NOT NULL,	InSIUInd								
SubLossCauseCd varchar(50) NOT NULL,	SubLossCauseCd								
LossCauseSeverity varchar(10) NOT NULL,	LossCauseSeverity								
NegligencePct integer NOT NULL,	NegligencePct								
mergencyService varchar(20) NOT NULL,	EmergencyService								
mergencyServiceVendor varchar(20) NOT NULL,	EmergencyServiceVendor								
OccurSite varchar(50) NOT NULL,	OccurSite								
ForRecordOnlyInd varchar(255) NOT NULL	ForRecordOnlyInd								
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_CLAIM ADD CONSTRAINT DIM_CLAIM_pkey PRIMARY KEY (CLAIM_ID);									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
CREATE TABLE DW_MGA.Dim_claimtransactiontype(									
CLAIMTRANSACTIONTYPE_ID integer NOT NULL,									
CTRANS_CODE varchar(50) NOT NULL,									
CTRANS_NAME varchar(100) NOT NULL,									
CTRANS_DESCRIPTION varchar(256) NOT NULL,									
CTRANS_SUBCODE varchar(50) NOT NULL,									
CTRANS_SUBNAME varchar(100) NOT NULL,									
CTRANS_SUBDESCRIPTION varchar(256) NOT NULL,									
CTRANS_LOSSPAID varchar(1) NOT NULL,									
CTRANS_LOSSRESERVE varchar(1) NOT NULL,									
CTRANS_INITLOSSRESERVE varchar(1) NOT NULL,									
CTRANS_ALAEPAID varchar(1) NOT NULL,									
CTRANS_ALAERESERVE varchar(1) NOT NULL,									
CTRANS_ULAEPAID varchar(1) NOT NULL,									
CTRANS_ULAERESERVE varchar(1) NOT NULL,									
CTRANS_SUBRORECEIVED varchar(1) NOT NULL,									
CTRANS_SUBROPAID varchar(1) NOT NULL,									
CTRANS_SUBRORESERVE varchar(1) NOT NULL,									
CTRANS_SALVAGERECEIVED varchar(1) NOT NULL,									
CTRANS_SALVAGERESERVE varchar(1) NOT NULL,									
CTRANS_DEDUCTRECOVERYRECVD varchar(1) NOT NULL,									
CTRANS_DEDUCTRECOVERYRSRV varchar(1) NOT NULL,									
CTRANS_LOSSPAID_HISTORICAL varchar(1) NOT NULL,									
CTRANS_LOSSRESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_ALAEPAID_HISTORICAL varchar(1) NOT NULL,									
CTRANS_ALAERESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_ULAEPAID_HISTORICAL varchar(1) NOT NULL,									
CTRANS_ULAERESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_SUBRORECEIVED_HISTORICAL varchar(1) NOT NULL,									
CTRANS_SUBRORESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_DCCPAID varchar(1) NOT NULL,									
CTRANS_DCCRESERVE varchar(1) NOT NULL,									
CTRANS_DCCPAID_HISTORICAL varchar(1) NOT NULL,									
CTRANS_DCCRESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_AAOPAID varchar(1) NOT NULL,									
CTRANS_AAORESERVE varchar(1) NOT NULL,									
CTRANS_AAOPAID_HISTORICAL varchar(1) NOT NULL,									
CTRANS_AAORESERVE_HISTORICAL varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY17 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY18 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY19 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY20 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY21 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY22 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY23 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY24 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY25 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY26 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY27 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY28 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY29 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY30 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY31 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY32 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY33 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY34 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY35 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY36 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY37 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY38 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY39 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY40 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY41 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY42 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY43 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY44 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY45 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY46 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY47 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY48 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY49 varchar(1) NOT NULL,									
CTRANS_USERDEFINEDSUMMARY50 varchar(1) NOT NULL,									
LOADDATE timestamp NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
CLAIMTRANSACTIONTYPE_ID									
);									
ALTER TABLE DW_MGA.DIM_CLAIMTRANSACTIONTYPE ADD CONSTRAINT DIM_CLAIMTRANSACTIONTYPE_pkey PRIMARY KEY (CLAIMTRANSACTIONTYPE_ID);									
CREATE TABLE DW_MGA.Dim_classification(									
CLASS_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
CLASS_CODE varchar(50) NOT NULL,									
CLASS_CODENAME varchar(50) NOT NULL,									
CLASS_CODEDESCRIPTION varchar(256) NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
CLASS_ID									
);									
ALTER TABLE DW_MGA.DIM_classification ADD CONSTRAINT DIM_classification_pkey PRIMARY KEY (CLASS_ID);									
CREATE TABLE DW_MGA.Dim_coverage(									
COVERAGE_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
COV_CODE varchar(50) NOT NULL,									
COV_SUBCODE varchar(50) NOT NULL,									
COV_ASL varchar(5) NOT NULL,									
COV_SUBLINE varchar(5) NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
COVERAGE_ID									
);									
ALTER TABLE DW_MGA.DIM_coverage ADD CONSTRAINT DIM_coverage_pkey PRIMARY KEY (coverage_ID);									
CREATE TABLE DW_MGA.Dim_coveredrisk(									
COVEREDRISK_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
deleted_indicator integer NOT NULL,									
risk_number varchar(10) NOT NULL,									
risk_type varchar(255) NOT NULL,									
RISK_UNIQUEID varchar(100) NOT NULL,									
COVEREDRISK_UNIQUEID varchar(500) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_coveredrisk ADD CONSTRAINT DIM_coveredrisk_pkey PRIMARY KEY (COVEREDRISK_ID);									
CREATE TABLE DW_MGA.Dim_deductible(									
DEDUCTIBLE_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
COV_DEDUCTIBLE1 decimal(13, 2) NOT NULL,									
COV_DEDUCTIBLE2 decimal(13, 2) NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
DEDUCTIBLE_ID									
);									
ALTER TABLE DW_MGA.DIM_deductible ADD CONSTRAINT DIM_deductible_pkey PRIMARY KEY (deductible_ID);									
CREATE TABLE DW_MGA.Dim_insured(									
INSURED_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
insured_uniqueid varchar(100) NOT NULL,									
first_name varchar(200) NOT NULL,									
last_name varchar(200) NOT NULL,									
commercialname varchar(200) NOT NULL,									
dob date NULL,									
occupation varchar(256) NOT NULL,									
gender varchar(10) NOT NULL,									
maritalstatus varchar(256) NOT NULL,									
address1 varchar(150) NOT NULL,									
address2 varchar(150) NOT NULL,									
county varchar(50) NOT NULL,									
city varchar(50) NOT NULL,									
state varchar(50) NOT NULL,									
postalcode varchar(20) NOT NULL,									
country varchar(50) NOT NULL,									
telephone varchar(20) NOT NULL,									
mobile varchar(20) NOT NULL,									
email varchar(100) NOT NULL,									
jobtitle varchar(100) NOT NULL,									
insurancescore varchar(255) NOT NULL,									
overriddeninsurancescore varchar(255) NOT NULL,									
applieddt date NULL,									
insurancescorevalue varchar(5) NOT NULL,									
ratepageeffectivedt date NULL,									
insscoretiervalueband varchar(20) NOT NULL,									
financialstabilitytier varchar(20) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_insured ADD CONSTRAINT DIM_insured_pkey PRIMARY KEY (insured_ID);									
CREATE TABLE DW_MGA.Dim_limit(									
LIMIT_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
COV_LIMIT1 varchar(255) NOT NULL,									
COV_LIMIT1TYPE varchar(50) NOT NULL,									
COV_LIMIT2 varchar(255) NOT NULL,									
COV_LIMIT2TYPE varchar(50) NOT NULL,									
COV_LIMIT1_VALUE numeric(13, 2) NOT NULL,									
COV_LIMIT2_VALUE numeric(13, 2) NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
LIMIT_ID									
);									
ALTER TABLE DW_MGA.DIM_limit ADD CONSTRAINT DIM_limit_pkey PRIMARY KEY (limit_ID);									
CREATE TABLE DW_MGA.Dim_month(									
MONTH_ID integer NOT NULL,									
MON_MONTHNAME varchar(25) NOT NULL,									
MON_MONTHABBR varchar(4) NOT NULL,									
MON_REPORTPERIOD varchar(6) NOT NULL,									
MON_MONTHINQUARTER integer NOT NULL,									
MON_MONTHINYEAR integer NOT NULL,									
MON_YEAR integer NOT NULL,									
MON_QUARTER integer NOT NULL,									
MON_STARTDATE timestamp NOT NULL,									
MON_ENDDATE timestamp NOT NULL,									
LOADDATE timestamp NOT NULL,									
MON_SEQUENCE integer NOT null									
)									
DISTSTYLE ALL									
SORTKEY									
(									
MONTH_ID									
);									
ALTER TABLE DW_MGA.DIM_month ADD CONSTRAINT DIM_month_pkey PRIMARY KEY (month_ID);									
CREATE TABLE DW_MGA.Dim_policytransactionextension(									
POLICYTRANSACTIONEXTENSION_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
POLICYTRANSACTION_UNIQUEID varchar(100) NOT NULL,									
TransactionNumber integer NOT NULL,									
TransactionCd varchar(255) NOT NULL,									
TransactionLongDescription varchar(255) NOT NULL,									
TransactionShortDescription varchar(255) NOT NULL,									
CancelTypeCd varchar(255) NOT NULL,									
CancelRequestedByCd varchar(255) NOT NULL,									
CancelReason varchar(255) NOT NULL,									
PolicyProgramCode varchar(255) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_policytransactionextension ADD CONSTRAINT DIM_policytransactionextension_pkey PRIMARY KEY (policytransactionextension_ID);									
CREATE TABLE DW_MGA.Dim_policytransactiontype(									
POLICYTRANSACTIONTYPE_ID integer NOT NULL,									
PTRANS_4SIGHTBICODE varchar(50) NOT NULL,									
PTRANS_CODE varchar(50) NOT NULL,									
PTRANS_NAME varchar(100) NOT NULL,									
PTRANS_DESCRIPTION varchar(256) NOT NULL,									
PTRANS_SUBCODE varchar(50) NOT NULL,									
PTRANS_SUBNAME varchar(100) NOT NULL,									
PTRANS_SUBDESCRIPTION varchar(256) NOT NULL,									
PTRANS_WRITTENPREM varchar(1) NOT NULL,									
PTRANS_COMMISSION varchar(1) NOT NULL,									
PTRANS_GROSSWRITTENPREM varchar(1) NOT NULL,									
PTRANS_ORIGINALWRITTENPREM varchar(1) NOT NULL,									
PTRANS_EARNEDPREM varchar(1) NOT NULL,									
PTRANS_GROSSEARNEDPREM varchar(1) NOT NULL,									
PTRANS_EARNEDCOMMISSION varchar(1) NOT NULL,									
PTRANS_MANUALWRITTENPREM varchar(1) NOT NULL,									
PTRANS_ENDORSEMENTPREM varchar(1) NOT NULL,									
PTRANS_AUDITPREM varchar(1) NOT NULL,									
PTRANS_CANCELLATIONPREM varchar(1) NOT NULL,									
PTRANS_REINSTATEMENTPREM varchar(1) NOT NULL,									
PTRANS_TAXES varchar(1) NOT NULL,									
PTRANS_FEES varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY1 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY2 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY3 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY4 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY5 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY6 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY7 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY8 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY9 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY10 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY11 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY12 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY13 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY14 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY15 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY16 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY17 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY18 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY19 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY20 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY21 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY22 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY23 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY24 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY25 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY26 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY27 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY28 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY29 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY30 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY31 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY32 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY33 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY34 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY35 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY36 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY37 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY38 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY39 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY40 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY41 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY42 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY43 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY44 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY45 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY46 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY47 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY48 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY49 varchar(1) NOT NULL,									
PTRANS_USERDEFINEDSUMMARY50 varchar(1) NOT NULL,									
LOADDATE timestamp NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
POLICYTRANSACTIONTYPE_ID									
);									
ALTER TABLE DW_MGA.DIM_POLICYTRANSACTIONTYPE ADD CONSTRAINT DIM_POLICYTRANSACTIONTYPE_pkey PRIMARY KEY (POLICYTRANSACTIONTYPE_ID);									
CREATE TABLE DW_MGA.Dim_product(									
PRODUCT_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp NOT NULL,									
PRODUCT_UNIQUEID varchar(100) NOT NULL,									
CarrierGroupCd varchar(100) NOT NULL,									
Description varchar(2000) NOT NULL,									
SubTypeCd varchar(100) NOT NULL,									
ProductVersion varchar(24) NOT NULL,									
Name varchar(64) NOT NULL,									
ProductTypeCd varchar(32) NOT NULL,									
CarrierCd varchar(8) NOT NULL,									
isSelect integer NOT NULL,									
LineCd varchar(32) NOT NULL,									
AltSubTypeCd varchar(32) NOT NULL,									
SubTypeShortDesc varchar(64) NOT NULL,									
SubTypeFullDesc varchar(64) NOT NULL,									
PolicyNumberPrefix varchar(3) NOT NULL,									
StartDt date NULL,									
StopDt date NULL,									
RenewalStartDt date NULL,									
RenewalStopDt date NULL,									
StateCd varchar(2) NOT NULL,									
Contract varchar(8) NOT NULL,									
LOB varchar(8) NOT NULL,									
PropertyForm varchar(8) NOT NULL,									
PreRenewalDays integer NOT NULL,									
AutoRenewalDays integer NOT NULL,									
MGAFeePlanCd varchar(24) NOT NULL,									
TPAFeePlanCd varchar(24) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
PRODUCT_ID									
);									
ALTER TABLE DW_MGA.DIM_PRODUCT ADD CONSTRAINT DIM_PRODUCT_pkey PRIMARY KEY (PRODUCT_ID);									
CREATE TABLE DW_MGA.Dim_status(									
STATUS_ID integer NOT NULL,									
STAT_4SIGHTBISTATUSCD varchar(50) NOT NULL,									
STAT_STATUSCD varchar(50) NOT NULL,									
STAT_STATUS varchar(100) NOT NULL,									
STAT_SUBSTATUSCD varchar(50) NOT NULL,									
STAT_SUBSTATUS varchar(100) NOT NULL,									
STAT_CATEGORY varchar(50) NOT NULL,									
LOADDATE timestamp NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
STATUS_ID									
);									
ALTER TABLE DW_MGA.DIM_status ADD CONSTRAINT DIM_status_pkey PRIMARY KEY (status_ID);									
CREATE TABLE DW_MGA.Dim_time(									
TIME_ID integer NOT NULL,									
MONTH_ID integer NOT NULL,									
TM_DATE timestamp NOT NULL,									
TM_DAYNAME varchar(25) NOT NULL,									
TM_DAYABBR varchar(4) NOT NULL,									
TM_REPORTPERIOD varchar(6) NOT NULL,									
TM_ISODATE varchar(8) NOT NULL,									
TM_DAYINWEEK integer NOT NULL,									
TM_DAYINMONTH integer NOT NULL,									
TM_DAYINQUARTER integer NOT NULL,									
TM_DAYINYEAR integer NOT NULL,									
TM_WEEKINMONTH integer NOT NULL,									
TM_WEEKINQUARTER integer NOT NULL,									
TM_WEEKINYEAR integer NOT NULL,									
TM_MONTHNAME varchar(25) NOT NULL,									
TM_MONTHABBR varchar(4) NOT NULL,									
TM_MONTHINQUARTER integer NOT NULL,									
TM_MONTHINYEAR integer NOT NULL,									
TM_QUARTER integer NOT NULL,									
TM_YEAR integer NOT NULL,									
LOADDATE timestamp NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
TIME_ID									
);									
ALTER TABLE DW_MGA.DIM_TIME ADD CONSTRAINT DIM_TIME_pkey PRIMARY KEY (TIME_ID);									
									
									
									
CREATE TABLE DW_MGA.Dim_catastrophe(									
catastrophe_id int NOT NULL,									
SOURCE_SYSTEM varchar(5) NULL,									
LOADDATE datetime NULL,									
cat_lossyear smallint NULL,									
cat_startdate date NULL,									
cat_enddate date NULL,									
cat_name varchar(100) NULL,									
cat_isoserial varchar(5) NULL,									
cat_description varchar(150) NULL,									
cat_code varchar(100) NULL,									
cat_manuallyadded bool NOT NULL,									
cat_actuarialtype varchar(20) NULL,									
cat_claimstype varchar(20) NULL,									
cat_financetype varchar(20) NULL,									
cat_adddate date NULL,									
cat_updatedby varchar(50) NULL,									
cat_changedate date NULL,									
cat_totalclaims int NULL,									
cat_totalincurred decimal(38, 2) NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
catastrophe_id									
);									
ALTER TABLE DW_MGA.Dim_catastrophe ADD CONSTRAINT Dim_catastrophe_pkey PRIMARY KEY (catastrophe_ID);									
									
									
CREATE TABLE DW_MGA.FACT_POLICYTRANSACTION(									
POLICYTRANSACTION_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
TRANSACTIONDATE_ID int NOT NULL,									
ACCOUNTINGDATE_ID int NOT NULL,									
EFFECTIVEDATE_ID int NOT NULL,									
FIRSTINSURED_ID int NOT NULL,									
PRODUCT_ID int NOT NULL,									
COMPANY_ID int NOT NULL,									
POLICYTRANSACTIONTYPE_ID int NOT NULL,									
PRODUCER_ID int NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
COVERAGE_ID int NOT NULL,									
COVERAGEEFFECTIVEDATE_ID int NOT NULL,									
COVERAGEEXPIRATIONDATE_ID int NOT NULL,									
LIMIT_ID int NOT NULL,									
DEDUCTIBLE_ID int NOT NULL,									
POLICYTRANSACTIONEXTENSION_ID int NOT NULL,									
PRIMARYRISK_ID int NOT NULL,									
Building_Id int NOT NULL,									
Vehicle_Id int NOT NULL,									
Driver_Id int NOT NULL,									
PRIMARYRISKADDRESS_ID int NOT NULL,									
CLASS_ID int NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
COVERAGE_UNIQUEID varchar(100) NULL,									
POLICYNEWORRENEWAL varchar(10) NOT NULL,									
POLICYTRANSACTION_UNIQUEID varchar(100) NOT NULL,									
TRANSACTIONSEQUENCE bigint NOT NULL,									
AMOUNT decimal(13, 2) NOT NULL,									
TERM_AMOUNT decimal(13, 2) NOT NULL,									
COMMISSION_AMOUNT decimal(13, 2) NOT NULL,									
AUDIT_ID int NOT NULL									
)									
SORTKEY (									
policytransaction_uniqueid									
)									
;									
									
									
									
									
									
									
CREATE TABLE DW_MGA.FACT_CLAIMTRANSACTION(									
CLAIMTRANSACTION_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
TRANSACTIONDATE_ID int NOT NULL,									
ACCOUNTINGDATE_ID int NOT NULL,									
CLAIMTRANSACTIONTYPE_ID int NOT NULL,									
ADJUSTER_ID int NOT NULL,									
CLAIMANT_ID int NOT NULL,									
PRODUCER_ID int NOT NULL,									
PRODUCT_ID int NOT NULL,									
COMPANY_ID int NOT NULL,									
FIRSTINSURED_ID int NOT NULL,									
CLAIM_ID int NOT NULL,									
CLAIMSTATUS_ID int NOT NULL,									
CLAIMLOSSADDRESS_ID int NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
COVERAGE_ID int NOT NULL,									
LIMIT_ID int NOT NULL,									
DEDUCTIBLE_ID int NOT NULL,									
COVERAGEEFFECTIVEDATE_ID int NOT NULL,									
COVERAGEEXPIRATIONDATE_ID int NOT NULL,									
OPENEDDATE_ID int NOT NULL,									
CLOSEDDATE_ID int NOT NULL,									
DATEREPORTED_ID int NOT NULL,									
DATEOFLOSS_ID int NOT NULL,									
PRIMARYRISK_ID int NOT NULL,									
Building_Id int NOT NULL,									
Vehicle_Id int NOT NULL,									
Driver_Id int NOT NULL,									
PRIMARYRISKADDRESS_ID int NOT NULL,									
CLASS_ID int NOT NULL,									
CATASTROPHE_ID int NOT NULL,									
RESERVESTATUS_ID int NOT NULL,									
CLAIMNUMBER varchar(50) NOT NULL,									
CLAIM_UNIQUEID varchar(100) NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
COVERAGE_UNIQUEID varchar(100) NULL,									
POLICYNEWORRENEWAL varchar(10) NOT NULL,									
CLAIMTRANSACTION_UNIQUEID varchar(100) NOT NULL,									
TRANSACTIONSEQUENCE bigint NOT NULL,									
AMOUNT decimal(13, 2) NOT NULL,									
AUDIT_ID int NOT NULL									
)									
SORTKEY (									
CLAIMTRANSACTION_UNIQUEID									
)									
;									
									
CREATE TABLE DW_MGA.FACT_CLAIM(									
CLAIMSUMMARY_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
MONTH_ID int NOT NULL,									
COVERAGE_ID int NOT NULL,									
COVERAGEEFFECTIVEDATE_ID int NOT NULL,									
COVERAGEEXPIRATIONDATE_ID int NOT NULL,									
ADJUSTER_ID int NOT NULL,									
CLAIMANT_ID int NOT NULL,									
PRODUCT_ID int NOT NULL,									
COMPANY_ID int NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
PRODUCER_ID int NOT NULL,									
CLAIM_ID int NOT NULL,									
CLAIMSTATUS_ID int NOT NULL,									
CLAIMLOSSADDRESS_ID int NOT NULL,									
DATEREPORTED_ID int NOT NULL,									
DATEOFLOSS_ID int NOT NULL,									
OPENEDDATE_ID int NOT NULL,									
CLOSEDDATE_ID int NOT NULL,									
FIRSTINSURED_ID int NOT NULL,									
LIMIT_ID int NOT NULL,									
DEDUCTIBLE_ID int NOT NULL,									
PRIMARYRISK_ID int NOT NULL,									
Building_Id int NOT NULL,									
Vehicle_Id int NOT NULL,									
Driver_Id int NOT NULL,									
PRIMARYRISKADDRESS_ID int NOT NULL,									
CLASS_ID int NOT NULL,									
CATASTROPHE_ID int NOT NULL,									
RESERVESTATUS_ID int NOT NULL,									
CLAIMNUMBER varchar(50) NOT NULL,									
CLAIM_UNIQUEID varchar(100) NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
COVERAGE_UNIQUEID varchar(100) NOT NULL,									
POLICYNEWORRENEWAL varchar(10) NOT NULL,									
LOSS_PD_AMT decimal(13, 2) NOT NULL,									
LOSS_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
INIT_LOSS_RSRV_AMT_ITD decimal(13, 2) NOT NULL,									
ALC_EXP_PD_AMT decimal(13, 2) NOT NULL,									
ALC_EXP_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
UALC_EXP_PD_AMT decimal(13, 2) NOT NULL,									
UALC_EXP_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
SUBRO_RECV_CHNG_AMT decimal(13, 2) NOT NULL,									
SUBRO_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
SUBRO_PAID_CHNG_AMT decimal(13, 2) NOT NULL,									
SALVAGE_RECV_CHNG_AMT decimal(13, 2) NOT NULL,									
SALVAGE_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
DEDRECOV_RECV_CHNG_AMT decimal(13, 2) NOT NULL,									
DEDRECOV_RSRV_CHNG_AMT decimal(13, 2) NOT NULL,									
LOSS_PD_AMT_YTD decimal(13, 2) NOT NULL,									
LOSS_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
ALC_EXP_PD_AMT_YTD decimal(13, 2) NOT NULL,									
ALC_EXP_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
UALC_EXP_PD_AMT_YTD decimal(13, 2) NOT NULL,									
UALC_EXP_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
SUBRO_RECV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
SUBRO_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
SUBRO_PAID_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
SALVAGE_RECV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
SALVAGE_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
DEDRECOV_RECV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
DEDRECOV_RSRV_CHNG_AMT_YTD decimal(13, 2) NOT NULL,									
LOSS_PD_AMT_ITD decimal(13, 2) NOT NULL,									
LOSS_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
ALC_EXP_PD_AMT_ITD decimal(13, 2) NOT NULL,									
ALC_EXP_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
UALC_EXP_PD_AMT_ITD decimal(13, 2) NOT NULL,									
UALC_EXP_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
SUBRO_RECV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
SUBRO_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
SUBRO_PAID_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
SALVAGE_RECV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
SALVAGE_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
DEDRECOV_RECV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
DEDRECOV_RSRV_CHNG_AMT_ITD decimal(13, 2) NOT NULL,									
FEAT_DAYS_OPEN int NOT NULL,									
FEAT_DAYS_OPEN_ITD int NOT NULL,									
FEAT_OPENED_IN_MONTH int NOT NULL,									
FEAT_CLOSED_IN_MONTH int NOT NULL,									
FEAT_CLOSED_WITHOUT_PAY int NOT NULL,									
FEAT_CLOSED_WITH_PAY int NOT NULL,									
CLM_DAYS_OPEN int NOT NULL,									
CLM_DAYS_OPEN_ITD int NOT NULL,									
CLM_OPENED_IN_MONTH int NOT NULL,									
CLM_CLOSED_IN_MONTH int NOT NULL,									
CLM_CLOSED_WITHOUT_PAY int NOT NULL,									
CLM_CLOSED_WITH_PAY int NOT NULL,									
MASTERCLAIM int NOT NULL,									
CLM_REOPENED_IN_MONTH int NULL,									
FEAT_REOPENED_IN_MONTH int NULL,									
CLM_CLOSED_IN_MONTH_COUNTER int NULL,									
CLM_CLOSED_WITHOUT_PAY_COUNTER int NULL,									
CLM_CLOSED_WITH_PAY_COUNTER int NULL,									
CLM_REOPENED_IN_MONTH_COUNTER int NULL,									
AUDIT_ID int NOT NULL									
)									
SORTKEY (									
MONTH_ID									
)									
;									
									
CREATE TABLE DW_MGA.FACT_POLICY(									
FACTPOLICY_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
MONTH_ID int NOT NULL,									
PRODUCER_ID int NOT NULL,									
PRODUCT_ID int NOT NULL,									
COMPANY_ID int NOT NULL,									
FIRSTINSURED_ID int NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
POLICYSTATUS_ID int NOT NULL,									
POLICYNEWORRENEWAL varchar(10) NOT NULL,									
POLICYNEWISSUEDIND int NOT NULL,									
POLICYCANCELLEDISSUEDIND int NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
COMM_AMT decimal(13, 2) NOT NULL,									
COMM_AMT_YTD decimal(13, 2) NOT NULL,									
COMM_AMT_ITD decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
TERM_PREM_AMT decimal(13, 2) NOT NULL,									
TERM_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
TERM_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
UNEARNED_PREM decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
FEES_AMT decimal(13, 2) NOT NULL,									
FEES_AMT_YTD decimal(13, 2) NOT NULL,									
FEES_AMT_ITD decimal(13, 2) NOT NULL,									
AUDIT_ID int NOT NULL									
)									
SORTKEY (									
MONTH_ID									
)									
;									
									
CREATE TABLE DW_MGA.FACT_POLICYCOVERAGE(									
FACTPOLICYCOVERAGE_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
MONTH_ID int NOT NULL,									
PRODUCER_ID int NOT NULL,									
PRODUCT_ID int NOT NULL,									
COMPANY_ID int NOT NULL,									
FIRSTINSURED_ID int NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
POLICYSTATUS_ID int NOT NULL,									
COVERAGE_ID int NOT NULL,									
COVERAGEEFFECTIVEDATE_ID int NOT NULL,									
COVERAGEEXPIRATIONDATE_ID int NOT NULL,									
LIMIT_ID int NOT NULL,									
DEDUCTIBLE_ID int NOT NULL,									
CLASS_ID int NOT NULL,									
PRIMARYRISK_ID int NOT NULL,									
Building_Id int NOT NULL,									
Vehicle_Id int NOT NULL,									
Driver_Id int NOT NULL,									
PRIMARYRISKADDRESS_ID int NOT NULL,									
POLICYNEWORRENEWAL varchar(10) NOT NULL,									
POLICYNEWISSUEDIND int NOT NULL,									
POLICYCANCELLEDISSUEDIND int NOT NULL,									
POLICYCANCELLEDEFFECTIVEIND int NOT NULL,									
POLICYEXPIREDEFFECTIVEIND int NOT NULL,									
RISK_DELETEDINDICATOR varchar(1) NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
COVERAGE_UNIQUEID varchar(100) NULL,									
COMM_AMT decimal(13, 2) NOT NULL,									
COMM_AMT_YTD decimal(13, 2) NOT NULL,									
COMM_AMT_ITD decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
WRTN_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
TERM_PREM_AMT decimal(13, 2) NOT NULL,									
TERM_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
TERM_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
EARNED_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
UNEARNED_PREM decimal(13, 2) NOT NULL,									
COMM_EARNED_AMT decimal(13, 2) NOT NULL,									
COMM_EARNED_AMT_YTD decimal(13, 2) NOT NULL,									
COMM_EARNED_AMT_ITD decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT_YTD decimal(13, 2) NOT NULL,									
CNCL_PREM_AMT_ITD decimal(13, 2) NOT NULL,									
FEES_AMT decimal(13, 2) NOT NULL,									
FEES_AMT_YTD decimal(13, 2) NOT NULL,									
FEES_AMT_ITD decimal(13, 2) NOT NULL,									
WE INTEGER ,									
EE INTEGER ,									
WE_YTD INTEGER ,									
EE_YTD INTEGER ,									
WE_ITD INTEGER ,									
EE_ITD INTEGER ,									
WE_RM NUMERIC(13, 2),									
EE_RM NUMERIC(13, 2),									
WE_RM_YTD NUMERIC(13, 2),									
EE_RM_YTD NUMERIC(13, 2),									
WE_RM_ITD NUMERIC(13, 2),									
EE_RM_ITD NUMERIC(13, 2),									
AUDIT_ID int NOT NULL									
)									
SORTKEY (									
MONTH_ID									
)									
;									
									
CREATE TABLE DW_MGA.DIM_VEHICLE(									
VEHICLE_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
Policy_Uniqueid int NOT NULL,									
Risk_UniqueId varchar(255) NOT NULL,									
VehNumber int NOT NULL,									
Vehicle_uniqueid varchar(525) NOT NULL,									
SPInnVehicle_Id varchar(255) NULL,									
Status varchar(255) NOT NULL,									
StateProvCd varchar(255) NOT NULL,									
County varchar(255) NOT NULL,									
PostalCode varchar(255) NOT NULL,									
City varchar(255) NOT NULL,									
Addr1 varchar(1023) NOT NULL,									
Addr2 varchar(255) NOT NULL,									
GaragAddrFlg varchar(3) NOT NULL,									
Latitude decimal(18, 12) NOT NULL,									
Longitude decimal(18, 12) NOT NULL,									
GaragPostalCode varchar(255) NOT NULL,									
GaragPostalCodeFlg varchar(3) NOT NULL,									
Manufacturer varchar(255) NOT NULL,									
Model varchar(255) NOT NULL,									
ModelYr varchar(10) NOT NULL,									
VehIdentificationNumber varchar(255) NOT NULL,									
ValidVinInd varchar(255) NOT NULL,									
VehLicenseNumber varchar(255) NOT NULL,									
RegistrationStateProvCd varchar(255) NOT NULL,									
VehBodyTypeCd varchar(255) NOT NULL,									
PerformanceCd varchar(255) NOT NULL,									
RestraintCd varchar(255) NOT NULL,									
AntiBrakingSystemCd varchar(255) NOT NULL,									
AntiTheftCd varchar(255) NOT NULL,									
EngineSize varchar(255) NOT NULL,									
EngineCylinders varchar(255) NOT NULL,									
EngineHorsePower varchar(255) NOT NULL,									
EngineType varchar(255) NOT NULL,									
VehUseCd varchar(255) NOT NULL,									
GarageTerritory int NOT NULL,									
CollisionDed varchar(255) NOT NULL,									
ComprehensiveDed varchar(255) NOT NULL,									
StatedAmt numeric(28, 6) NOT NULL,									
ClassCd varchar(255) NOT NULL,									
RatingValue varchar(255) NOT NULL,									
CostNewAmt numeric(28, 6) NOT NULL,									
EstimatedAnnualDistance int NOT NULL,									
EstimatedWorkDistance int NOT NULL,									
LeasedVehInd varchar(255) NOT NULL,									
PurchaseDt date NOT NULL,									
StatedAmtInd varchar(255) NOT NULL,									
NewOrUsedInd varchar(255) NOT NULL,									
CarPoolInd varchar(255) NOT NULL,									
OdometerReading varchar(10) NOT NULL,									
WeeksPerMonthDriven varchar(255) NOT NULL,									
DaylightRunningLightsInd varchar(255) NOT NULL,									
PassiveSeatBeltInd varchar(255) NOT NULL,									
DaysPerWeekDriven varchar(255) NOT NULL,									
UMPDLimit varchar(255) NOT NULL,									
TowingAndLaborInd varchar(255) NOT NULL,									
RentalReimbursementInd varchar(255) NOT NULL,									
LiabilityWaiveInd varchar(255) NOT NULL,									
RateFeesInd varchar(255) NOT NULL,									
OptionalEquipmentValue int NOT NULL,									
CustomizingEquipmentInd varchar(255) NOT NULL,									
CustomizingEquipmentDesc varchar(255) NOT NULL,									
InvalidVinAcknowledgementInd varchar(255) NOT NULL,									
IgnoreUMPDWCDInd varchar(255) NOT NULL,									
RecalculateRatingSymbolInd varchar(255) NOT NULL,									
ProgramTypeCd varchar(255) NOT NULL,									
CMPRatingValue varchar(255) NOT NULL,									
COLRatingValue varchar(255) NOT NULL,									
LiabilityRatingValue varchar(255) NOT NULL,									
MedPayRatingValue varchar(255) NOT NULL,									
RACMPRatingValue varchar(255) NOT NULL,									
RACOLRatingValue varchar(255) NOT NULL,									
RABIRatingSymbol varchar(255) NOT NULL,									
RAPDRatingSymbol varchar(255) NOT NULL,									
RAMedPayRatingSymbol varchar(255) NOT NULL,									
EstimatedAnnualDistanceOverride varchar(5) NOT NULL,									
OriginalEstimatedAnnualMiles varchar(12) NOT NULL,									
ReportedMileageNonSave varchar(12) NOT NULL,									
Mileage varchar(12) NOT NULL,									
EstimatedNonCommuteMiles varchar(12) NOT NULL,									
TitleHistoryIssue varchar(3) NOT NULL,									
OdometerProblems varchar(3) NOT NULL,									
Bundle varchar(15) NOT NULL,									
LoanLeaseGap varchar(3) NOT NULL,									
EquivalentReplacementCost varchar(3) NOT NULL,									
OriginalEquipmentManufacturer varchar(3) NOT NULL,									
OptionalRideshare varchar(3) NOT NULL,									
MedicalPartsAccessibility varchar(4) NOT NULL,									
OdometerReadingPrior varchar(10) NOT NULL,									
ReportedMileageNonSaveDtPrior date NOT NULL,									
FullGlassCovInd varchar(3) NOT NULL,									
BoatLengthFeet varchar(255) NOT NULL,									
MotorHorsePower varchar(255) NOT NULL,									
Replacementof int NOT NULL,									
ReportedMileageNonSaveDt date NOT NULL,									
ManufacturerSymbol varchar(4) NOT NULL,									
ModelSymbol varchar(4) NOT NULL,									
BodyStyleSymbol varchar(4) NOT NULL,									
SymbolCode varchar(12) NOT NULL,									
VerifiedMileageOverride varchar(4) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_VEHICLE ADD CONSTRAINT DIM_VEHICLE_pkey PRIMARY KEY (VEHICLE_ID);									
									
									
CREATE TABLE DW_MGA.DIM_DRIVER(									
DRIVER_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL Distkey,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
Policy_Uniqueid int NOT NULL,									
DriverNumber int NOT NULL,									
Driver_UniqueId varchar(255) NOT NULL,									
SPINNDriver_Id varchar(255) NOT NULL,									
Status varchar(255) NOT NULL,									
FirstName varchar(255) NOT NULL,									
LastName varchar(255) NOT NULL,									
LicenseNumber varchar(255) NOT NULL,									
LicenseDt datetime NOT NULL,									
DriverInfoCd varchar(255) NOT NULL,									
DriverTypeCd varchar(255) NOT NULL,									
DriverStatusCd varchar(255) NOT NULL,									
LicensedStateProvCd varchar(255) NOT NULL,									
RelationshipToInsuredCd varchar(255) NOT NULL,									
ScholasticDiscountInd varchar(255) NOT NULL,									
MVRRequestInd varchar(255) NOT NULL,									
MVRStatus varchar(255) NOT NULL,									
MVRStatusDt datetime NOT NULL,									
MatureDriverInd varchar(255) NOT NULL,									
DriverTrainingInd varchar(255) NOT NULL,									
GoodDriverInd varchar(255) NOT NULL,									
AccidentPreventionCourseCompletionDt datetime NOT NULL,									
DriverTrainingCompletionDt datetime NOT NULL,									
AccidentPreventionCourseInd varchar(255) NOT NULL,									
ScholasticCertificationDt datetime NOT NULL,									
ActiveMilitaryInd varchar(255) NOT NULL,									
PermanentLicenseInd varchar(255) NOT NULL,									
NewToStateInd varchar(255) NOT NULL,									
PersonTypeCd varchar(255) NOT NULL,									
GenderCd varchar(255) NOT NULL,									
BirthDt datetime NOT NULL,									
MaritalStatusCd varchar(255) NOT NULL,									
OccupationClassCd varchar(255) NOT NULL,									
PositionTitle varchar(255) NOT NULL,									
CurrentResidenceCd varchar(255) NOT NULL,									
CivilServantInd varchar(255) NOT NULL,									
RetiredInd varchar(255) NOT NULL,									
NewTeenExpirationDt date NOT NULL,									
AttachedVehicleRef varchar(255) NOT NULL,									
VIOL_PointsChargedTerm int NOT NULL,									
ACCI_PointsChargedTerm int NOT NULL,									
SUSP_PointsChargedTerm int NOT NULL,									
Other_PointsChargedTerm int NOT NULL,									
GoodDriverPoints_chargedterm int NOT NULL,									
SR22FeeInd varchar(4) NOT NULL,									
MatureCertificationDt datetime NOT NULL,									
AgeFirstLicensed int NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_DRIVER ADD CONSTRAINT DIM_DRIVER_pkey PRIMARY KEY (DRIVER_ID);									
									
									
CREATE TABLE DW_MGA.DIM_RESERVESTATUS(									
ReserveStatus_Id integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
CLAIM_ID integer NOT NULL,									
CLAIM_UNIQUEID varchar(100) NOT NULL,									
BookDt date NOT NULL,									
POLICY_UNIQUEID integer NOT NULL,									
POLICY_ID integer NOT NULL,									
SystemId integer NOT NULL DISTKEY,									
TransactionNumber integer NOT NULL,									
ClaimNumber varchar(50) NOT NULL,									
Adjustment varchar(10) NOT NULL,									
Indemnity varchar(10) NOT NULL,									
Defense varchar(10) NOT NULL,									
Subrogation varchar(10) NOT NULL,									
Salvage varchar(10) NOT NULL,									
Adjustment_Status_Chng boolean NOT NULL,									
Indemnity_Status_Chng boolean NOT NULL,									
Defense_Status_Chng boolean NOT NULL,									
Subrogation_Status_Chng boolean NOT NULL,									
Salvage_Status_Chng boolean NOT NULL,									
Current_Flag boolean NOT NULL									
)									
SORTKEY									
(									
CLAIM_ID,									
BookDt									
);									
ALTER TABLE DW_MGA.DIM_RESERVESTATUS ADD CONSTRAINT DIM_RESERVESTATUS_pkey PRIMARY KEY (ReserveStatus_Id);									
									
									
									
									
CREATE TABLE DW_MGA.DIM_CLAIMANT(									
CLAIMANT_ID int NOT NULL,									
source_system varchar(100) NOT NULL,									
loaddate datetime NOT NULL,									
claimant_uniqueID varchar(100) NOT NULL,									
claimant_type varchar(50) NOT NULL,									
claimant_number varchar(50) NOT NULL,									
name varchar(200) NOT NULL,									
DOB date NOT NULL,									
gender varchar(10) NOT NULL,									
maritalStatus varchar(256) NOT NULL,									
address1 varchar(150) NOT NULL,									
address2 varchar(150) NOT NULL,									
city varchar(50) NOT NULL,									
state varchar(50) NOT NULL,									
postalCode varchar(20) NOT NULL,									
telephone varchar(20) NOT NULL,									
fax varchar(20) NOT NULL,									
email varchar(100) NOT NULL,									
WaterMitigationInd varchar(3) NOT NULL,									
PublicAdjusterInd varchar(3) NOT NULL,									
attorneyrepind varchar(3) NOT NULL,									
injuryinvolvedind varchar(3) NOT NULL,									
injuredpartyrelationshipcd varchar(3) NOT NULL,									
injurydesc varchar(255) NOT NULL,									
majortraumacd varchar(256) NOT NULL,									
fatalityind varchar(256) NOT NULL,									
suitfiledind varchar(256) NOT NULL,									
suitdt date NOT NULL,									
suitstatuscd varchar(256) NOT NULL,									
suitcloseddt date NOT NULL,									
suitsettlementcd varchar(256) NOT NULL,									
docketnumber varchar(256) NOT NULL,									
claimsettleddt date NOT NULL,									
litigationcaption varchar(256) NOT NULL,									
phoneappind varchar(3) NOT NULL,									
phoneapplanguage varchar(15) NOT NULL,									
phoneappphoneinfoid varchar(29) NOT NULL,									
casefacts varchar(256) NOT NULL,									
caseanalysis varchar(256) NOT NULL,									
suitreasoncd varchar(32) NOT NULL,									
courttype varchar(15) NOT NULL,									
courtstate varchar(2) NOT NULL,									
courtcounty varchar(75) NOT NULL,									
suitserveddate date NOT NULL,									
suitmediationdate date NOT NULL,									
suitarbitrationdate date NOT NULL,									
suitconferencedate date NOT NULL,									
suitmotionjudgedate date NOT NULL,									
suitdismissaldate date NOT NULL,									
suittrialdate date NOT NULL,									
suitservedind varchar(3) NOT NULL,									
suitmediationind varchar(3) NOT NULL,									
suitarbitrationind varchar(3) NOT NULL,									
suitconferenceind varchar(3) NOT NULL,									
suitmotionjudgeind varchar(3) NOT NULL,									
suitdismissalind varchar(3) NOT NULL,									
suittrialind varchar(3) NOT NULL,									
healthinsuranceclaimnumber varchar(50) NOT NULL,									
injurycausecd varchar(10) NOT NULL,									
exhaustdt date NOT NULL,									
nofaultinsurancelimit integer NOT NULL,									
injurycausetypecd varchar(10) NOT NULL,									
productliabilitycd varchar(20) NOT NULL,									
notsendcovcms varchar(3) NOT NULL,									
representativetypecd varchar(20) NOT NULL,									
ongoingresponsibilitymedicalsind varchar(3) NOT NULL,									
deletefromcms varchar(3) NOT NULL,									
stateofvenue varchar(2) NOT NULL,									
ormind varchar(3) NOT NULL,									
ongoingresponsibilitymedicalsterminationdt date NOT NULL,									
medicarebeneficiarycd varchar(20) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
claimant_id									
);									
ALTER TABLE DW_MGA.DIM_claimant ADD CONSTRAINT DIM_claimant_pkey PRIMARY KEY (claimant_ID);									
									
CREATE TABLE DW_MGA.DIM_ADJUSTER(									
ADJUSTER_ID int NOT NULL,									
source_system varchar(100) NOT NULL,									
loaddate datetime NOT NULL,									
ADJUSTER_uniqueID varchar(100) NOT NULL,									
ADJUSTER_TYPE varchar(50) NOT NULL,									
ADJUSTER_NUMBER varchar(50) NOT NULL,									
NAME varchar(200) NOT NULL,									
ADDRESS1 varchar(150) NOT NULL,									
ADDRESS2 varchar(150) NOT NULL,									
CITY varchar(50) NOT NULL,									
STATE varchar(50) NOT NULL,									
POSTALCODE varchar(20) NOT NULL,									
TELEPHONE varchar(20) NOT NULL,									
FAX varchar(20) NOT NULL,									
EMAIL varchar(100) NOT NULL,									
DEPARTMENT varchar(100) NOT NULL,									
UserManagementGroupCd varchar(25) NOT NULL,									
Supervisor varchar(255) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
adjuster_id									
);									
ALTER TABLE DW_MGA.DIM_ADJUSTER ADD CONSTRAINT DIM_ADJUSTER_pkey PRIMARY KEY (ADJUSTER_ID);									
									
									
CREATE TABLE DW_MGA.DIM_COMPANY(									
company_id int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NOT NULL,									
company_uniqueid varchar(100) NOT NULL,									
CarrierCd varchar(10) NOT NULL,									
CompanyCd varchar(10) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
company_id									
);									
ALTER TABLE DW_MGA.DIM_COMPANY ADD CONSTRAINT DIM_COMPANY_pkey PRIMARY KEY (COMPANY_ID);									
									
									
CREATE TABLE DW_MGA.dim_producer									
(									
producer_id INTEGER NOT NULL									
,source_system VARCHAR(100) NOT NULL									
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL									
,producer_uniqueid VARCHAR(20) NOT NULL									
,valid_fromdate TIMESTAMP WITHOUT TIME ZONE NOT NULL									
,valid_todate TIMESTAMP WITHOUT TIME ZONE NOT NULL									
,record_version INTEGER NOT NULL									
,producer_number VARCHAR(20) NOT NULL									
,producer_name VARCHAR(255) NOT NULL									
,LicenseNo VARCHAR(255) NOT NULL									
,agency_type VARCHAR(11) NOT NULL									
,address VARCHAR(510) NOT NULL									
,city VARCHAR(80) NOT NULL									
,state_cd VARCHAR(5) NOT NULL									
,zip VARCHAR(10) NOT NULL									
,phone VARCHAR(20) NOT NULL									
,fax VARCHAR(15) NOT NULL									
,email VARCHAR(255) NOT NULL									
,agency_group VARCHAR(255) NOT NULL									
,national_name VARCHAR(255) NOT NULL									
,national_code VARCHAR(20) NOT NULL									
,territory VARCHAR(50) NOT NULL									
,territory_manager VARCHAR(50) NOT NULL									
,dba VARCHAR(255) NOT NULL									
,producer_status VARCHAR(10) NOT NULL									
,commission_master VARCHAR(20) NOT NULL									
,reporting_master VARCHAR(20) NOT NULL									
,pn_appointment_date DATE NOT NULL									
,profit_sharing_master VARCHAR(20) NOT NULL									
,producer_master VARCHAR(20) NOT NULL									
,recognition_tier VARCHAR(100) NOT NULL									
,rmaddress VARCHAR(100) NOT NULL									
,rmcity VARCHAR(50) NOT NULL									
,rmstate VARCHAR(25) NOT NULL									
,rmzip VARCHAR(25) NOT NULL									
,new_business_term_date DATE NOT NULL									
,PRIMARY KEY (producer_id)									
)									
DISTSTYLE ALL									
SORTKEY (									
producer_id									
)									
;									
									
									
CREATE TABLE DW_MGA.DIM_USER(									
USER_ID integer NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime not NULL,									
USER_UNIQUEID varchar(255) NOT NULL,									
LoginId varchar(255) NOT NULL,									
TypeCd varchar(255) NOT NULL,									
Supervisor varchar(255) NOT NULL,									
LastName varchar(255) NOT NULL,									
FirstName varchar(255) NOT NULL,									
TerminatedDt datetime NOT NULL,									
DepartmentCd varchar(255) NOT NULL,									
UserManagementGroupCd varchar(250) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
user_id									
);									
ALTER TABLE DW_MGA.DIM_USER ADD CONSTRAINT DIM_USER_pkey PRIMARY KEY (USER_ID);									
									
									
CREATE TABLE DW_MGA.DIM_CUSTOMER(									
Customer_Id int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE timestamp not NULL,									
Customer_UniqueId integer NOT NULL,									
Status varchar(10) NOT NULL,									
EntityTypeCd varchar(30) NOT NULL,									
First_Name varchar(255) NOT NULL,									
Last_Name varchar(255) NOT NULL,									
CommercialName varchar(255) NOT NULL,									
DOB datetime NOT NULL,									
gender varchar(5) NOT NULL,									
maritalStatus varchar(20) NOT NULL,									
address1 varchar(255) NOT NULL,									
address2 varchar(255) NOT NULL,									
county varchar(255) NOT NULL,									
city varchar(255) NOT NULL,									
state varchar(255) NOT NULL,									
PostalCode varchar(5) NOT NULL,									
phone varchar(255) NOT NULL,									
mobile varchar(255) NOT NULL,									
email varchar(255) NOT NULL,									
PreferredDeliveryMethod varchar(10) NOT NULL,									
PortalInvitationSentDt datetime NOT NULL,									
PaymentReminderInd varchar(10) NOT NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
CUSTOMER_id									
);									
ALTER TABLE DW_MGA.DIM_CUSTOMER ADD CONSTRAINT DIM_CUSTOMER_pkey PRIMARY KEY (CUSTOMER_ID);									
									
 /*Need to create STG_MGA later*/									
CREATE TABLE IF NOT EXISTS DW_MGA.stg_exposures									
(									
factpolicycoverage_id INTEGER									
,month_id INTEGER									
,policy_id INTEGER									
,policy_uniqueid VARCHAR(100)									
,coverage_id INTEGER									
,coverage_uniqueid VARCHAR(100)									
,we INTEGER									
,ee INTEGER									
,we_ytd INTEGER									
,ee_ytd INTEGER									
,we_itd INTEGER									
,ee_itd INTEGER									
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
									
									
CREATE TABLE DW_MGA.Dim_risk_coverage(									
COVEREDRISK_ID int NOT NULL,									
SOURCE_SYSTEM varchar(100) NOT NULL,									
LOADDATE datetime NULL,									
POLICY_ID int NOT NULL,									
SystemId int NOT NULL DISTKEY,									
CurrentFlg integer NOT NULL,									
BookDt date NOT NULL,									
TransactionEffectiveDt date NOT NULL,									
POLICY_UNIQUEID int NOT NULL,									
RISK_UNIQUEID varchar(100) NOT NULL,									
CovA_Limit1 varchar(255) NOT NULL,									
CovA_Limit2 varchar(255) NOT NULL,									
CovA_Deductible1 decimal(13, 2) NOT NULL,									
CovA_Deductible2 decimal(13, 2) NOT NULL,									
CovA_FullTermAmt decimal(13, 2) NOT NULL,									
CovB_Limit1 varchar(255) NOT NULL,									
CovB_Limit2 varchar(255) NOT NULL,									
CovB_Deductible1 decimal(13, 2) NOT NULL,									
CovB_Deductible2 decimal(13, 2) NOT NULL,									
CovB_FullTermAmt decimal(13, 2) NOT NULL,									
CovC_Limit1 varchar(255) NOT NULL,									
CovC_Limit2 varchar(255) NOT NULL,									
CovC_Deductible1 decimal(13, 2) NOT NULL,									
CovC_Deductible2 decimal(13, 2) NOT NULL,									
CovC_FullTermAmt decimal(13, 2) NOT NULL,									
CovD_Limit1 varchar(255) NOT NULL,									
CovD_Limit2 varchar(255) NOT NULL,									
CovD_Deductible1 decimal(13, 2) NOT NULL,									
CovD_Deductible2 decimal(13, 2) NOT NULL,									
CovD_FullTermAmt decimal(13, 2) NOT NULL,									
CovE_Limit1 varchar(255) NOT NULL,									
CovE_Limit2 varchar(255) NOT NULL,									
CovE_Deductible1 decimal(13, 2) NOT NULL,									
CovE_Deductible2 decimal(13, 2) NOT NULL,									
CovE_FullTermAmt decimal(13, 2) NOT NULL,									
BEDBUG_Limit1 varchar(255) NOT NULL,									
BEDBUG_Limit2 varchar(255) NOT NULL,									
BEDBUG_Deductible1 decimal(13, 2) NOT NULL,									
BEDBUG_Deductible2 decimal(13, 2) NOT NULL,									
BEDBUG_FullTermAmt decimal(13, 2) NOT NULL,									
BOLAW_Limit1 varchar(255) NOT NULL,									
BOLAW_Limit2 varchar(255) NOT NULL,									
BOLAW_Deductible1 decimal(13, 2) NOT NULL,									
BOLAW_Deductible2 decimal(13, 2) NOT NULL,									
BOLAW_FullTermAmt decimal(13, 2) NOT NULL,									
COC_Limit1 varchar(255) NOT NULL,									
COC_Limit2 varchar(255) NOT NULL,									
COC_Deductible1 decimal(13, 2) NOT NULL,									
COC_Deductible2 decimal(13, 2) NOT NULL,									
COC_FullTermAmt decimal(13, 2) NOT NULL,									
EQPBK_Limit1 varchar(255) NOT NULL,									
EQPBK_Limit2 varchar(255) NOT NULL,									
EQPBK_Deductible1 decimal(13, 2) NOT NULL,									
EQPBK_Deductible2 decimal(13, 2) NOT NULL,									
EQPBK_FullTermAmt decimal(13, 2) NOT NULL,									
FRAUD_Limit1 varchar(255) NOT NULL,									
FRAUD_Limit2 varchar(255) NOT NULL,									
FRAUD_Deductible1 decimal(13, 2) NOT NULL,									
FRAUD_Deductible2 decimal(13, 2) NOT NULL,									
FRAUD_FullTermAmt decimal(13, 2) NOT NULL,									
H051ST0_Limit1 varchar(255) NOT NULL,									
H051ST0_Limit2 varchar(255) NOT NULL,									
H051ST0_Deductible1 decimal(13, 2) NOT NULL,									
H051ST0_Deductible2 decimal(13, 2) NOT NULL,									
H051ST0_FullTermAmt decimal(13, 2) NOT NULL,									
HO5_Limit1 varchar(255) NOT NULL,									
HO5_Limit2 varchar(255) NOT NULL,									
HO5_Deductible1 decimal(13, 2) NOT NULL,									
HO5_Deductible2 decimal(13, 2) NOT NULL,									
HO5_FullTermAmt decimal(13, 2) NOT NULL,									
INCB_Limit1 varchar(255) NOT NULL,									
INCB_Limit2 varchar(255) NOT NULL,									
INCB_Deductible1 decimal(13, 2) NOT NULL,									
INCB_Deductible2 decimal(13, 2) NOT NULL,									
INCB_FullTermAmt decimal(13, 2) NOT NULL,									
INCC_Limit1 varchar(255) NOT NULL,									
INCC_Limit2 varchar(255) NOT NULL,									
INCC_Deductible1 decimal(13, 2) NOT NULL,									
INCC_Deductible2 decimal(13, 2) NOT NULL,									
INCC_FullTermAmt decimal(13, 2) NOT NULL,									
LAC_Limit1 varchar(255) NOT NULL,									
LAC_Limit2 varchar(255) NOT NULL,									
LAC_Deductible1 decimal(13, 2) NOT NULL,									
LAC_Deductible2 decimal(13, 2) NOT NULL,									
LAC_FullTermAmt decimal(13, 2) NOT NULL,									
MEDPAY_Limit1 varchar(255) NOT NULL,									
MEDPAY_Limit2 varchar(255) NOT NULL,									
MEDPAY_Deductible1 decimal(13, 2) NOT NULL,									
MEDPAY_Deductible2 decimal(13, 2) NOT NULL,									
MEDPAY_FullTermAmt decimal(13, 2) NOT NULL,									
OccupationDiscount_Limit1 varchar(255) NOT NULL,									
OccupationDiscount_Limit2 varchar(255) NOT NULL,									
OccupationDiscount_Deductible1 decimal(13, 2) NOT NULL,									
OccupationDiscount_Deductible2 decimal(13, 2) NOT NULL,									
OccupationDiscount_FullTermAmt decimal(13, 2) NOT NULL,									
OLT_Limit1 varchar(255) NOT NULL,									
OLT_Limit2 varchar(255) NOT NULL,									
OLT_Deductible1 decimal(13, 2) NOT NULL,									
OLT_Deductible2 decimal(13, 2) NOT NULL,									
OLT_FullTermAmt decimal(13, 2) NOT NULL,									
PIHOM_Limit1 varchar(255) NOT NULL,									
PIHOM_Limit2 varchar(255) NOT NULL,									
PIHOM_Deductible1 decimal(13, 2) NOT NULL,									
PIHOM_Deductible2 decimal(13, 2) NOT NULL,									
PIHOM_FullTermAmt decimal(13, 2) NOT NULL,									
PPREP_Limit1 varchar(255) NOT NULL,									
PPREP_Limit2 varchar(255) NOT NULL,									
PPREP_Deductible1 decimal(13, 2) NOT NULL,									
PPREP_Deductible2 decimal(13, 2) NOT NULL,									
PPREP_FullTermAmt decimal(13, 2) NOT NULL,									
PRTDVC_Limit1 varchar(255) NOT NULL,									
PRTDVC_Limit2 varchar(255) NOT NULL,									
PRTDVC_Deductible1 decimal(13, 2) NOT NULL,									
PRTDVC_Deductible2 decimal(13, 2) NOT NULL,									
PRTDVC_FullTermAmt decimal(13, 2) NOT NULL,									
SeniorDiscount_Limit1 varchar(255) NOT NULL,									
SeniorDiscount_Limit2 varchar(255) NOT NULL,									
SeniorDiscount_Deductible1 decimal(13, 2) NOT NULL,									
SeniorDiscount_Deductible2 decimal(13, 2) NOT NULL,									
SeniorDiscount_FullTermAmt decimal(13, 2) NOT NULL,									
SEWER_Limit1 varchar(255) NOT NULL,									
SEWER_Limit2 varchar(255) NOT NULL,									
SEWER_Deductible1 decimal(13, 2) NOT NULL,									
SEWER_Deductible2 decimal(13, 2) NOT NULL,									
SEWER_FullTermAmt decimal(13, 2) NOT NULL,									
SPP_Limit1 varchar(255) NOT NULL,									
SPP_Limit2 varchar(255) NOT NULL,									
SPP_Deductible1 decimal(13, 2) NOT NULL,									
SPP_Deductible2 decimal(13, 2) NOT NULL,									
SPP_FullTermAmt decimal(13, 2) NOT NULL,									
SRORP_Limit1 varchar(255) NOT NULL,									
SRORP_Limit2 varchar(255) NOT NULL,									
SRORP_Deductible1 decimal(13, 2) NOT NULL,									
SRORP_Deductible2 decimal(13, 2) NOT NULL,									
SRORP_FullTermAmt decimal(13, 2) NOT NULL,									
THEFA_Limit1 varchar(255) NOT NULL,									
THEFA_Limit2 varchar(255) NOT NULL,									
THEFA_Deductible1 decimal(13, 2) NOT NULL,									
THEFA_Deductible2 decimal(13, 2) NOT NULL,									
THEFA_FullTermAmt decimal(13, 2) NOT NULL,									
UTLDB_Limit1 varchar(255) NOT NULL,									
UTLDB_Limit2 varchar(255) NOT NULL,									
UTLDB_Deductible1 decimal(13, 2) NOT NULL,									
UTLDB_Deductible2 decimal(13, 2) NOT NULL,									
UTLDB_FullTermAmt decimal(13, 2) NOT NULL,									
WCINC_Limit1 varchar(255) NOT NULL,									
WCINC_Limit2 varchar(255) NOT NULL,									
WCINC_Deductible1 decimal(13, 2) NOT NULL,									
WCINC_Deductible2 decimal(13, 2) NOT NULL,									
WCINC_FullTermAmt decimal(13, 2) NOT NULL,									
WCINC_Limit1_o varchar(255) NOT NULL,									
WCINC_Limit2_o varchar(255) NOT NULL,									
WCINC_Deductible1_o decimal(13, 2) NOT NULL,									
WCINC_Deductible2_o decimal(13, 2) NOT NULL,									
WCINC_FullTermAmt_o decimal(13, 2) NOT NULL									
)									
SORTKEY									
(									
SystemId									
);									
ALTER TABLE DW_MGA.DIM_RISK_COVERAGE ADD CONSTRAINT DIM_RISK_COVERAGE_pkey PRIMARY KEY (COVEREDRISK_ID);									
									
									
									
									
CREATE TABLE DW_MGA.DIM_CLAIMANT_ASSOCIATE(									
CLAIMANT_ASSOCIATE_ID int NOT NULL,									
source_system varchar(100) NOT NULL,									
loaddate datetime NOT NULL,									
CLAIMANT_ID int NOT NULL,									
claimant_uniqueID varchar(100) NOT NULL,									
AssociateTypeCd varchar(255) not NULL,									
AssociateProviderRef int not NULL									
)									
DISTSTYLE ALL									
SORTKEY									
(									
claimant_id									
);									
ALTER TABLE DW_MGA.DIM_CLAIMANT_ASSOCIATE ADD CONSTRAINT DIM_CLAIMANT_ASSOCIATE_pkey PRIMARY KEY (CLAIMANT_ASSOCIATE_ID);									