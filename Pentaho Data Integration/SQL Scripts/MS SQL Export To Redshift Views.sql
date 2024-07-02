CREATE SCHEMA [ExportToRedshift];	
	
GO	
	
CREATE view [ExportToRedshift].[dim_status] as select * from [dbo].[dim_status] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[dim_policytransactiontype] as select * from [dbo].[dim_policytransactiontype] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[dim_claimtransactiontype] as select * from [dbo].[dim_claimtransactiontype] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[dim_time] as select * from [dbo].[dim_time] with (NOLOCK)	
	
GO	
	
CREATE view [ExportToRedshift].[dim_month] as select * from [dbo].[dim_month] with (NOLOCK)	
	
GO	
	
	
create view [ExportToRedshift].[dim_address] as select * from [dbo].[dim_address] with (NOLOCK)	
	
GO	
	
create view [ExportToRedshift].[dim_coverage] as select * from [dbo].[dim_coverage] with (NOLOCK)	
	
GO	
	
create view [ExportToRedshift].[dim_deductible] as select * from [dbo].[dim_deductible] with (NOLOCK)	
	
GO	
	
create view [ExportToRedshift].[dim_limit] as select * from [dbo].[dim_limit] with (NOLOCK)	
	
GO	
	
create view [ExportToRedshift].[dim_classification] as select * from [dbo].[dim_classification] with (NOLOCK)	
	
GO	
	
	
	
alter view [ExportToRedshift].[dim_policytransactionextension] as 	
select 	
       POLICYTRANSACTIONEXTENSION_ID	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
      ,POLICY_ID	
      ,SystemId	
      ,0 CurrentFlg	
      ,BookDt	
      ,TransactionEffectiveDt	
      ,POLICY_UNIQUEID	
      ,POLICYTRANSACTION_UNIQUEID	
      ,TransactionNumber	
      ,TransactionCd	
      ,TransactionLongDescription	
      ,TransactionShortDescription	
      ,CancelTypeCd	
      ,CancelRequestedByCd	
      ,CancelReason	
      ,PolicyProgramCode	
from [dbo].[dim_policytransactionextension] with (NOLOCK);	
	
GO	
	
	
	
/*SystemId dist key - both approved and not approved*/	
create view [ExportToRedshift].[dim_application] as 	
select	
       SOURCE_SYSTEM	
      ,LOADDATE	
       ,p.POLICY_ID	
      ,p.SystemId	
      ,0 CurrentFlg	
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
      ,ApplicationNumber	
      ,Application_UpdateTimestamp	
      ,QuoteInfo_UpdateDt	
      ,QuoteInfo_adduser_uniqueid	
      ,original_policy_uniqueid	
      ,Application_Type	
      ,QuoteInfo_Type	
      ,Application_Status	
      ,QuoteInfo_Status	
      ,QuoteInfo_CloseReasonCd	
      ,QuoteInfo_CloseSubReasonCd	
      ,QuoteInfo_CloseComment	
     ,WrittenPremiumAmt	
     ,FullTermAmt	
    ,CommissionAmt	
FROM dbo.DIM_POLICY p;	
	
GO	
	
	
	
/*SystemId dist key - both approved and not approved*/	
create view [ExportToRedshift].[dim_insured] as 	
select 	
       i.SystemId INSURED_ID	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
     ,i.POLICY_ID	
     ,i.SystemId	
    ,0 CurrentFlg	
      ,BookDt	
      ,TransactionEffectiveDt	
      ,POLICY_UNIQUEID	
      ,insured_uniqueid	
      ,first_name	
      ,last_name	
      ,commercialname	
      ,dob	
      ,occupation	
      ,gender	
      ,maritalstatus	
      ,address1	
      ,address2	
      ,county	
      ,city	
      ,state	
      ,postalcode	
      ,country	
      ,telephone	
      ,mobile	
      ,email	
      ,jobtitle	
      ,insurancescore	
      ,overriddeninsurancescore	
      ,applieddt	
      ,insurancescorevalue	
      ,ratepageeffectivedt	
      ,insscoretiervalueband	
      ,financialstabilitytier	
from dbo.DIM_INSURED i;	
	
  	
GO	
	
	
	
	
/*SystemId dist key - both approved and not approved*/	
create view [ExportToRedshift].[dim_coveredrisk] as 	
SELECT COVEREDRISK_ID COVEREDRISK_ID	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
      ,POLICY_ID	
      ,SystemId	
     ,0 CurrentFlg	
      ,BookDt	
      ,TransactionEffectiveDt	
      ,POLICY_UNIQUEID	
      ,deleted_indicator	
      ,risk_number	
      ,risk_type	
      ,RISK_UNIQUEID	
      ,COVEREDRISK_UNIQUEID	
  FROM dbo.DIM_COVEREDRISK dc;	
	
GO	
	
	
	
	
	
/*SystemId dist key - both approved and not approved*/	
create view [ExportToRedshift].[dim_building] as 	
SELECT 	
       BUILDING_ID 	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
      ,b.POLICY_ID	
      ,b.SystemId	
       ,0 CurrentFlg	
      ,BookDt	
      ,TransactionEffectiveDt	
      ,POLICY_UNIQUEID	
      ,Risk_UniqueId	
      ,BldgNumber	
      ,Building_uniqueid	
      ,SPInnBuilding_Id	
      ,Status	
      ,StateProvCd	
      ,County	
      ,PostalCode	
      ,City	
      ,Addr1	
      ,Addr2	
      ,BusinessCategory	
      ,BusinessClass	
      ,ConstructionCd	
      ,RoofCd	
      ,YearBuilt	
      ,SqFt	
      ,Stories	
      ,Units	
      ,OccupancyCd	
      ,ProtectionClass	
      ,TerritoryCd	
      ,BuildingLimit	
      ,ContentsLimit	
      ,ValuationMethod	
      ,InflationGuardPct	
      ,OrdinanceOrLawInd	
      ,ScheduledPremiumMod	
      ,WindHailExclusion	
      ,CovALimit	
      ,CovBLimit	
      ,CovCLimit	
      ,CovDLimit	
      ,CovELimit	
      ,CovFLimit	
      ,AllPerilDed	
      ,BurglaryAlarmType	
      ,FireAlarmType	
      ,CovBLimitIncluded	
      ,CovBLimitIncrease	
      ,CovCLimitIncluded	
      ,CovCLimitIncrease	
      ,CovDLimitIncluded	
      ,CovDLimitIncrease	
      ,OrdinanceOrLawPct	
      ,NeighborhoodCrimeWatchInd	
      ,EmployeeCreditInd	
      ,MultiPolicyInd	
      ,HomeWarrantyCreditInd	
      ,YearOccupied	
      ,YearPurchased	
      ,TypeOfStructure	
      ,FeetToFireHydrant	
      ,NumberOfFamilies	
      ,MilesFromFireStation	
      ,Rooms	
      ,RoofPitch	
      ,FireDistrict	
      ,SprinklerSystem	
      ,FireExtinguisherInd	
      ,KitchenFireExtinguisherInd	
      ,DeadboltInd	
      ,GatedCommunityInd	
      ,CentralHeatingInd	
      ,Foundation	
      ,WiringRenovation	
      ,WiringRenovationCompleteYear	
      ,PlumbingRenovation	
      ,HeatingRenovation	
      ,PlumbingRenovationCompleteYear	
      ,ExteriorPaintRenovation	
      ,HeatingRenovationCompleteYear	
      ,CircuitBreakersInd	
      ,CopperWiringInd	
      ,ExteriorPaintRenovationCompleteYear	
      ,CopperPipesInd	
      ,EarthquakeRetrofitInd	
      ,PrimaryFuelSource	
      ,SecondaryFuelSource	
      ,UsageType	
      ,HomegardCreditInd	
      ,MultiPolicyNumber	
      ,LocalFireAlarmInd	
      ,NumLosses	
      ,CovALimitIncrease	
      ,CovALimitIncluded	
      ,MonthsRentedOut	
      ,RoofReplacement	
      ,SafeguardPlusInd	
      ,CovELimitIncluded	
      ,RoofReplacementCompleteYear	
      ,CovELimitIncrease	
      ,OwnerOccupiedUnits	
      ,TenantOccupiedUnits	
      ,ReplacementCostDwellingInd	
      ,FeetToPropertyLine	
      ,GalvanizedPipeInd	
      ,WorkersCompInservant	
      ,WorkersCompOutservant	
      ,LiabilityTerritoryCd	
      ,PremisesLiabilityMedPayInd	
      ,RelatedPrivateStructureExclusion	
      ,VandalismExclusion	
      ,VandalismInd	
      ,RoofExclusion	
      ,ExpandedReplacementCostInd	
      ,ReplacementValueInd	
      ,OtherPolicyNumber1	
      ,OtherPolicyNumber2	
      ,OtherPolicyNumber3	
      ,PrimaryPolicyNumber	
      ,OtherPolicyNumbers	
      ,ReportedFireHazardScore	
      ,FireHazardScore	
      ,ReportedSteepSlopeInd	
      ,SteepSlopeInd	
      ,ReportedHomeReplacementCost	
      ,ReportedProtectionClass	
      ,EarthquakeZone	
      ,MMIScore	
      ,HomeInspectionDiscountInd	
      ,RatingTier	
      ,SoilTypeCd	
      ,ReportedFireLineAssessment	
      ,AAISFireProtectionClass	
      ,InspectionScore	
      ,AnnualRents	
      ,PitchOfRoof	
      ,TotalLivingSqFt	
      ,ParkingSqFt	
      ,ParkingType	
      ,RetrofitCompleted	
      ,NumPools	
      ,FullyFenced	
      ,DivingBoard	
      ,Gym	
      ,FreeWeights	
      ,WireFencing	
      ,OtherRecreational	
      ,OtherRecreationalDesc	
      ,HealthInspection	
      ,HealthInspectionDt	
      ,HealthInspectionCited	
      ,PriorDefectRepairs	
      ,MSBReconstructionEstimate	
      ,BIIndemnityPeriod	
      ,EquipmentBreakdown	
      ,MoneySecurityOnPremises	
      ,MoneySecurityOffPremises	
      ,WaterBackupSump	
      ,SprinkleredBuildings	
      ,SurveillanceCams	
      ,GatedComplexKeyAccess	
      ,EQRetrofit	
      ,UnitsPerBuilding	
      ,NumStories	
      ,ConstructionQuality	
      ,BurglaryRobbery	
      ,NFPAClassification	
      ,AreasOfCoverage	
      ,CODetector	
      ,SmokeDetector	
      ,SmokeDetectorInspectInd	
      ,WaterHeaterSecured	
      ,BoltedOrSecured	
      ,SoftStoryCripple	
      ,SeniorHousingPct	
      ,DesignatedSeniorHousing	
      ,StudentHousingPct	
      ,DesignatedStudentHousing	
      ,PriorLosses	
      ,TenantEvictions	
      ,VacancyRateExceed	
      ,SeasonalRentals	
      ,CondoInsuingAgmt	
      ,GasValve	
      ,OwnerOccupiedPct	
      ,RestaurantName	
      ,HoursOfOperation	
      ,RestaurantSqFt	
      ,SeatingCapacity	
      ,AnnualGrossSales	
      ,SeasonalOrClosed	
      ,BarCocktailLounge	
      ,LiveEntertainment	
      ,BeerWineGrossSales	
      ,DistilledSpiritsServed	
      ,KitchenDeepFryer	
      ,SolidFuelCooking	
      ,ANSULSystem	
      ,ANSULAnnualInspection	
      ,TenantNamesList	
      ,TenantBusinessType	
      ,TenantGLLiability	
      ,InsuredOccupiedPortion	
      ,ValetParking	
      ,LessorSqFt	
      ,BuildingRiskNumber	
      ,MultiPolicyIndUmbrella	
      ,PoolInd	
      ,StudsUpRenovation	
      ,StudsUpRenovationCompleteYear	
      ,MultiPolicyNumberUmbrella	
      ,RCTMSBAmt	
      ,RCTMSBHomeStyle	
      ,WINSOverrideNonSmokerDiscount	
      ,WINSOverrideSeniorDiscount	
      ,ITV	
      ,ITVDate	
      ,MSBReportType	
      ,VandalismDesiredInd	
      ,WoodShakeSiding	
      ,CSEAgent	
      ,PropertyManager	
      ,RentersInsurance	
      ,WaterDetectionDevice	
      ,AutoHomeInd	
      ,EarthquakeUmbrellaInd	
      ,LandlordInd	
      ,LossAssessment	
      ,GasShutOffInd	
      ,WaterDed	
      ,ServiceLine	
      ,FunctionalReplacementCost	
      ,MilesOfStreet	
      ,HOAExteriorStructure	
      ,RetailPortionDevelopment	
      ,LightIndustrialType	
      ,LightIndustrialDescription	
      ,PoolCoverageLimit	
      ,MultifamilyResidentialBuildings	
      ,SinglefamilyDwellings	
      ,AnnualPayroll	
      ,AnnualRevenue	
      ,BedsOccupied	
      ,EmergencyLighting	
      ,ExitSignsPosted	
      ,FullTimeStaff	
      ,LicensedBeds	
      ,NumberofFireExtinguishers	
      ,OtherFireExtinguishers	
      ,OxygenTanks	
      ,PartTimeStaff	
      ,SmokingPermitted	
      ,StaffOnDuty	
      ,TypeofFireExtinguishers	
      ,CovADDRR_SecondaryResidence	
      ,CovADDRRPrem_SecondaryResidence	
      ,HODeluxe	
      ,Latitude	
      ,Longitude	
      ,LineCD	
      ,WUIClass	
      ,CensusBlock	
      ,WaterRiskScore	
      ,LandlordLossPreventionServices	
      ,EnhancedWaterCoverage	
      ,LandlordProperty	
      ,LiabilityExtendedToOthers	
      ,LossOfUseExtendedTime	
      ,OnPremisesTheft	
      ,BedBugMitigation	
      ,HabitabilityExclusion	
      ,WildfireHazardPotential	
      ,BackupOfSewersAndDrains	
      ,VegetationSetbackFt	
      ,YardDebrisCoverageArea	
      ,YardDebrisCoveragePercentage	
      ,CapeTrampoline	
      ,CapePool	
      ,RoofConditionRating	
      ,TrampolineInd	
      ,PlumbingMaterial	
      ,CentralizedHeating	
      ,FireDistrictSubscriptionCode	
      ,RoofCondition	
FROM dbo.DIM_BUILDING b with (NOLOCK);	
	
GO	
	
	
	
alter view [ExportToRedshift].[DIM_CLAIM] as	
SELECT	
CLAIM_ID	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
      ,CLAIM_UNIQUEID	
      ,POLICY_UNIQUEID	
      ,POLICY_ID	
      ,PolicySystemId	
      ,CLAIMNUMBER	
      ,FEATURENUMBER	
      ,DATEOFLOSS	
      ,LOSSREPORTEDDATE	
      ,RiskCd	
      ,AnnualStatementLineCd	
      ,SublineCd	
      ,CarrierCd	
      ,CompanyCd	
      ,CarrierGroupCd	
      ,ClaimantCd	
      ,FeatureCd	
      ,FeatureSubCd	
      ,FeatureTypeCd	
      ,ReserveCd	
      ,ReserveTypeCd	
      ,AtFaultCd	
      ,SourceCd	
      ,CategoryCd	
      ,LossCauseCd	
      ,ReportedTo	
      ,ReportedBy	
      ,replace(replace(replace(DamageDesc,char(13)+char(10),' '),char(13),' '),char(10),' ') DamageDesc	
      ,replace(replace(replace(ShortDesc,char(13)+char(10),' '),char(13),' '),char(10),' ') ShortDesc	
      ,replace(replace(replace(Description,char(13)+char(10),' '),char(13),' '),char(10),' ') Description	
      ,replace(replace(replace(Comment,char(13)+char(10),' '),char(13),' '),char(10),' ') Comment	
      ,CATCODE	
      ,CATDESCRIPTION	
      ,TotalLossInd	
      ,SalvageOwnerRetainedInd	
      ,SuitFiledInd	
      ,InSIUInd	
      ,SubLossCauseCd	
      ,LossCauseSeverity	
      ,NegligencePct	
      ,EmergencyService	
      ,EmergencyServiceVendor	
      ,OccurSite	
     ,ForRecordOnlyInd	
FROM dbo.DIM_CLAIM c with (NOLOCK);	
	
GO	
	
	
	
	
CREATE view [ExportToRedshift].[fact_policytransaction] as select * from [dbo].[fact_policytransaction] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[dim_catastrophe] as select * from [dbo].[dim_catastrophe] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[fact_claimtransaction] as select * from [dbo].[fact_claimtransaction] with (NOLOCK)	
	
GO	
	
CREATE view [ExportToRedshift].[fact_claim] as select * from [dbo].[fact_claim] with (NOLOCK)	
	
GO	
	
	
CREATE view [ExportToRedshift].[FACT_POLICYCOVERAGE] as 	
select 	
       [FACTPOLICYCOVERAGE_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[MONTH_ID]	
      ,[PRODUCER_ID]	
      ,[PRODUCT_ID]	
      ,[COMPANY_ID]	
      ,[FIRSTINSURED_ID]	
      ,[POLICY_ID]	
      ,[SystemId]	
      ,[POLICYSTATUS_ID]	
      ,[COVERAGE_ID]	
      ,[COVERAGEEFFECTIVEDATE_ID]	
      ,[COVERAGEEXPIRATIONDATE_ID]	
      ,[LIMIT_ID]	
      ,[DEDUCTIBLE_ID]	
      ,[CLASS_ID]	
      ,[PRIMARYRISK_ID]	
      ,[Building_Id]	
      ,[Vehicle_Id]	
      ,[Driver_Id]	
      ,[PRIMARYRISKADDRESS_ID]	
      ,[POLICYNEWORRENEWAL]	
      ,[POLICYNEWISSUEDIND]	
      ,[POLICYCANCELLEDISSUEDIND]	
      ,[POLICYCANCELLEDEFFECTIVEIND]	
      ,[POLICYEXPIREDEFFECTIVEIND]	
      ,[RISK_DELETEDINDICATOR]	
      ,[POLICY_UNIQUEID]	
      ,[COVERAGE_UNIQUEID]	
      ,[COMM_AMT]	
      ,[COMM_AMT_YTD]	
      ,[COMM_AMT_ITD]	
      ,[WRTN_PREM_AMT]	
      ,[WRTN_PREM_AMT_YTD]	
      ,[WRTN_PREM_AMT_ITD]	
      ,[TERM_PREM_AMT]	
      ,[TERM_PREM_AMT_YTD]	
      ,[TERM_PREM_AMT_ITD]	
      ,[EARNED_PREM_AMT]	
      ,[EARNED_PREM_AMT_YTD]	
      ,[EARNED_PREM_AMT_ITD]	
      ,[UNEARNED_PREM]	
      ,[COMM_EARNED_AMT]	
      ,[COMM_EARNED_AMT_YTD]	
      ,[COMM_EARNED_AMT_ITD]	
      ,[CNCL_PREM_AMT]	
      ,[CNCL_PREM_AMT_YTD]	
      ,[CNCL_PREM_AMT_ITD]	
      ,[FEES_AMT]	
      ,[FEES_AMT_YTD]	
      ,[FEES_AMT_ITD]	
      ,0 we	
      ,0 ee	
      ,0 we_ytd	
      ,0 ee_ytd	
      ,0 we_itd	
      ,0 ee_itd	
      ,0 we_rm	
      ,0 ee_rm	
      ,0 we_rm_ytd	
      ,0 ee_rm_ytd	
      ,0 we_rm_itd	
      ,0 ee_rm_itd	
      ,[AUDIT_ID]	
from [dbo].[fact_policycoverage]  with (NOLOCK);	
	
	
CREATE view [ExportToRedshift].[FACT_POLICY] as 	
select 	
       [FACTPOLICY_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[MONTH_ID]	
      ,[PRODUCER_ID]	
      ,[PRODUCT_ID]	
      ,[COMPANY_ID]	
      ,[FIRSTINSURED_ID]	
      ,[POLICY_ID]	
      ,[SystemId]	
      ,[POLICYSTATUS_ID]	
      ,[POLICYNEWORRENEWAL]	
      ,[POLICYNEWISSUEDIND]	
      ,[POLICYCANCELLEDISSUEDIND]	
      ,[POLICY_UNIQUEID]	
      ,[COMM_AMT]	
      ,[COMM_AMT_YTD]	
      ,[COMM_AMT_ITD]	
      ,[WRTN_PREM_AMT]	
      ,[WRTN_PREM_AMT_YTD]	
      ,[WRTN_PREM_AMT_ITD]	
      ,[TERM_PREM_AMT]	
      ,[TERM_PREM_AMT_YTD]	
      ,[TERM_PREM_AMT_ITD]	
      ,[EARNED_PREM_AMT]	
      ,[EARNED_PREM_AMT_YTD]	
      ,[EARNED_PREM_AMT_ITD]	
      ,[UNEARNED_PREM]	
      ,[CNCL_PREM_AMT]	
      ,[CNCL_PREM_AMT_YTD]	
      ,[CNCL_PREM_AMT_ITD]	
      ,[FEES_AMT]	
      ,[FEES_AMT_YTD]	
      ,[FEES_AMT_ITD]	
      ,[AUDIT_ID]	
from [dbo].[fact_policy]  with (NOLOCK);	
	
	
create view [ExportToRedshift].[dim_vehicle] as 	
SELECT 	
       [VEHICLE_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[POLICY_ID]	
      ,[SystemId]	
       ,0 [CurrentFlg]	
      ,[BookDt]	
      ,[TransactionEffectiveDt]	
      ,[Policy_Uniqueid]	
      ,[Risk_UniqueId]	
      ,[VehNumber]	
      ,[Vehicle_uniqueid]	
      ,[SPInnVehicle_Id]	
      ,[Status]	
      ,[StateProvCd]	
      ,[County]	
      ,[PostalCode]	
      ,[City]	
      ,[Addr1]	
      ,[Addr2]	
      ,[GaragAddrFlg]	
      ,[Latitude]	
      ,[Longitude]	
      ,[GaragPostalCode]	
      ,[GaragPostalCodeFlg]	
      ,[Manufacturer]	
      ,[Model]	
      ,[ModelYr]	
      ,[VehIdentificationNumber]	
      ,[ValidVinInd]	
      ,[VehLicenseNumber]	
      ,[RegistrationStateProvCd]	
      ,[VehBodyTypeCd]	
      ,[PerformanceCd]	
      ,[RestraintCd]	
      ,[AntiBrakingSystemCd]	
      ,[AntiTheftCd]	
      ,[EngineSize]	
      ,[EngineCylinders]	
      ,[EngineHorsePower]	
      ,[EngineType]	
      ,[VehUseCd]	
      ,[GarageTerritory]	
      ,[CollisionDed]	
      ,[ComprehensiveDed]	
      ,[StatedAmt]	
      ,[ClassCd]	
      ,[RatingValue]	
      ,[CostNewAmt]	
      ,[EstimatedAnnualDistance]	
      ,[EstimatedWorkDistance]	
      ,[LeasedVehInd]	
      ,[PurchaseDt]	
      ,[StatedAmtInd]	
      ,[NewOrUsedInd]	
      ,[CarPoolInd]	
      ,[OdometerReading]	
      ,[WeeksPerMonthDriven]	
      ,[DaylightRunningLightsInd]	
      ,[PassiveSeatBeltInd]	
      ,[DaysPerWeekDriven]	
      ,[UMPDLimit]	
      ,[TowingAndLaborInd]	
      ,[RentalReimbursementInd]	
      ,[LiabilityWaiveInd]	
      ,[RateFeesInd]	
      ,[OptionalEquipmentValue]	
      ,[CustomizingEquipmentInd]	
      ,[CustomizingEquipmentDesc]	
      ,[InvalidVinAcknowledgementInd]	
      ,[IgnoreUMPDWCDInd]	
      ,[RecalculateRatingSymbolInd]	
      ,[ProgramTypeCd]	
      ,[CMPRatingValue]	
      ,[COLRatingValue]	
      ,[LiabilityRatingValue]	
      ,[MedPayRatingValue]	
      ,[RACMPRatingValue]	
      ,[RACOLRatingValue]	
      ,[RABIRatingSymbol]	
      ,[RAPDRatingSymbol]	
      ,[RAMedPayRatingSymbol]	
      ,[EstimatedAnnualDistanceOverride]	
      ,[OriginalEstimatedAnnualMiles]	
      ,[ReportedMileageNonSave]	
      ,[Mileage]	
      ,[EstimatedNonCommuteMiles]	
      ,[TitleHistoryIssue]	
      ,[OdometerProblems]	
      ,[Bundle]	
      ,[LoanLeaseGap]	
      ,[EquivalentReplacementCost]	
      ,[OriginalEquipmentManufacturer]	
      ,[OptionalRideshare]	
      ,[MedicalPartsAccessibility]	
      ,[OdometerReadingPrior]	
      ,[ReportedMileageNonSaveDtPrior]	
      ,[FullGlassCovInd]	
      ,[BoatLengthFeet]	
      ,[MotorHorsePower]	
      ,[Replacementof]	
      ,[ReportedMileageNonSaveDt]	
      ,[ManufacturerSymbol]	
      ,[ModelSymbol]	
      ,[BodyStyleSymbol]	
      ,[SymbolCode]	
      ,[VerifiedMileageOverride]	
FROM dbo.DIM_VEHICLE v with (NOLOCK);	
	
GO	
	
	
create view [ExportToRedshift].[dim_driver] as 	
SELECT 	
       [DRIVER_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[POLICY_ID]	
      ,[SystemId]	
       ,0 [CurrentFlg]	
      ,[BookDt]	
      ,[TransactionEffectiveDt]	
      ,[Policy_Uniqueid]	
      ,[DriverNumber]	
      ,[Driver_UniqueId]	
      ,[SPINNDriver_Id]	
      ,[Status]	
      ,[FirstName]	
      ,[LastName]	
      ,[LicenseNumber]	
      ,[LicenseDt]	
      ,[DriverInfoCd]	
      ,[DriverTypeCd]	
      ,[DriverStatusCd]	
      ,[LicensedStateProvCd]	
      ,[RelationshipToInsuredCd]	
      ,[ScholasticDiscountInd]	
      ,[MVRRequestInd]	
      ,[MVRStatus]	
      ,[MVRStatusDt]	
      ,[MatureDriverInd]	
      ,[DriverTrainingInd]	
      ,[GoodDriverInd]	
      ,[AccidentPreventionCourseCompletionDt]	
      ,[DriverTrainingCompletionDt]	
      ,[AccidentPreventionCourseInd]	
      ,[ScholasticCertificationDt]	
      ,[ActiveMilitaryInd]	
      ,[PermanentLicenseInd]	
      ,[NewToStateInd]	
      ,[PersonTypeCd]	
      ,[GenderCd]	
      ,[BirthDt]	
      ,[MaritalStatusCd]	
      ,[OccupationClassCd]	
      ,[PositionTitle]	
      ,[CurrentResidenceCd]	
      ,[CivilServantInd]	
      ,[RetiredInd]	
      ,[NewTeenExpirationDt]	
      ,[AttachedVehicleRef]	
      ,[VIOL_PointsChargedTerm]	
      ,[ACCI_PointsChargedTerm]	
      ,[SUSP_PointsChargedTerm]	
      ,[Other_PointsChargedTerm]	
      ,[GoodDriverPoints_chargedterm]	
      ,[SR22FeeInd]	
      ,[MatureCertificationDt]	
      ,[AgeFirstLicensed]       	
FROM dbo.DIM_DRIVER d with (NOLOCK);	
	
GO	
	
CREATE view [ExportToRedshift].[dim_reservestatus] as select * from [dbo].[dim_reservestatus] with (NOLOCK)	
	
GO	
	
	
	
create view [ExportToRedshift].[DIM_ADJUSTER] as 	
select	
   ADJUSTER_ID	
      ,source_system	
      ,loaddate	
      ,ADJUSTER_uniqueID	
      ,ADJUSTER_TYPE	
      ,ADJUSTER_NUMBER	
      ,NAME	
      ,ADDRESS1	
      ,ADDRESS2	
      ,CITY	
      ,STATE	
      ,POSTALCODE	
      ,TELEPHONE	
      ,FAX	
      ,EMAIL	
      ,DEPARTMENT	
      ,UserManagementGroupCd	
      ,Supervisor	
from dbo.DIM_ADJUSTER with (NOLOCK)	;
	
GO	
	
create view [ExportToRedshift].[DIM_COMPANY] as select	* from dbo.DIM_COMPANY with (NOLOCK);
GO	
	
	
create view [ExportToRedshift].[DIM_CLAIMANT] as 	
select	
   CLAIMANT_ID	
      ,source_system	
      ,loaddate	
      ,claimant_uniqueID	
      ,claimant_type	
      ,claimant_number	
      ,name	
      ,DOB	
      ,gender	
      ,maritalStatus	
      ,address1	
      ,address2	
      ,city	
      ,state	
      ,postalCode	
      ,telephone	
      ,fax	
      ,email	
      ,WaterMitigationInd	
      ,PublicAdjusterInd	
      ,attorneyrepind	
      ,injuryinvolvedind	
      ,injuredpartyrelationshipcd	
      ,injurydesc	
      ,majortraumacd	
      ,fatalityind	
      ,suitfiledind	
      ,suitdt	
      ,suitstatuscd	
      ,suitcloseddt	
      ,suitsettlementcd	
      ,docketnumber	
      ,claimsettleddt	
      ,litigationcaption	
      ,phoneappind	
      ,phoneapplanguage	
      ,phoneappphoneinfoid	
      ,casefacts	
      ,caseanalysis	
      ,suitreasoncd	
      ,courttype	
      ,courtstate	
      ,courtcounty	
      ,suitserveddate	
      ,suitmediationdate	
      ,suitarbitrationdate	
      ,suitconferencedate	
      ,suitmotionjudgedate	
      ,suitdismissaldate	
      ,suittrialdate	
      ,suitservedind	
      ,suitmediationind	
      ,suitarbitrationind	
      ,suitconferenceind	
      ,suitmotionjudgeind	
      ,suitdismissalind	
      ,suittrialind	
      ,healthinsuranceclaimnumber	
      ,injurycausecd	
      ,exhaustdt	
      ,nofaultinsurancelimit	
      ,injurycausetypecd	
      ,productliabilitycd	
      ,notsendcovcms	
      ,representativetypecd	
      ,ongoingresponsibilitymedicalsind	
      ,deletefromcms	
      ,stateofvenue	
      ,ormind	
      ,ongoingresponsibilitymedicalsterminationdt	
      ,medicarebeneficiarycd	
from dbo.DIM_CLAIMANT with (NOLOCK)	
	
GO	
	
create view [ExportToRedshift].[DIM_PRODUCER] as select	* from dbo.DIM_PRODUCER with (NOLOCK);
GO	
	
	
create view [ExportToRedshift].[dim_product] as 	
select 	
   [PRODUCT_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[PRODUCT_UNIQUEID]	
      ,[CarrierGroupCd]	
      ,[Description]	
      ,[SubTypeCd]	
      ,[ProductVersion]	
      ,[Name]	
      ,[ProductTypeCd]	
      ,[CarrierCd]	
      ,[isSelect]	
      ,[LineCd]	
      ,[AltSubTypeCd]	
      ,[SubTypeShortDesc]	
      ,[SubTypeFullDesc]	
      ,[PolicyNumberPrefix]	
      ,[StartDt]	
      ,[StopDt]	
      ,[RenewalStartDt]	
      ,[RenewalStopDt]	
      ,[StateCd]	
      ,[Contract]	
      ,[LOB]	
      ,[PropertyForm]	
      ,[PreRenewalDays]	
      ,[AutoRenewalDays]	
      ,[MGAFeePlanCd]	
      ,[TPAFeePlanCd]	
from [dbo].[dim_product] with (NOLOCK)	
	
GO	
	
	
create view [ExportToRedshift].[dim_user] as 	
SELECT [USER_ID]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[USER_UNIQUEID]	
      ,[LoginId]	
      ,[TypeCd]	
      ,[Supervisor]	
      ,[LastName]	
      ,[FirstName]	
      ,[TerminatedDt]	
      ,[DepartmentCd]	
      ,[UserManagementGroupCd]	
  FROM [dbo].[DIM_USER] with (NOLOCK)	
	
GO	
	
	
create view [ExportToRedshift].[dim_customer] as 	
SELECT [Customer_Id]	
      ,[SOURCE_SYSTEM]	
      ,[LOADDATE]	
      ,[Customer_UniqueId]	
      ,[Status]	
      ,[EntityTypeCd]	
      ,[First_Name]	
      ,[Last_Name]	
      ,[CommercialName]	
      ,[DOB]	
      ,[gender]	
      ,[maritalStatus]	
      ,[address1]	
      ,[address2]	
      ,[county]	
      ,[city]	
      ,[state]	
      ,[PostalCode]	
      ,[phone]	
      ,[mobile]	
      ,[email]	
      ,[PreferredDeliveryMethod]	
      ,[PortalInvitationSentDt]	
      ,[PaymentReminderInd]	
  FROM [DW_MGA].[dbo].[DIM_CUSTOMER]  with (NOLOCK)	
	
	
create view [ExportToRedshift].[dim_risk_coverage] as 	
SELECT 	
       COVEREDRISK_ID	
      ,SOURCE_SYSTEM	
      ,LOADDATE	
      ,POLICY_ID	
      ,SystemId	
      ,0 CurrentFlg	
      ,BookDt	
      ,TransactionEffectiveDt	
      ,POLICY_UNIQUEID	
      ,RISK_UNIQUEID	
      ,CovA_Limit1	
      ,CovA_Limit2	
      ,CovA_Deductible1	
      ,CovA_Deductible2	
      ,CovA_FullTermAmt	
      ,CovB_Limit1	
      ,CovB_Limit2	
      ,CovB_Deductible1	
      ,CovB_Deductible2	
      ,CovB_FullTermAmt	
      ,CovC_Limit1	
      ,CovC_Limit2	
      ,CovC_Deductible1	
      ,CovC_Deductible2	
      ,CovC_FullTermAmt	
      ,CovD_Limit1	
      ,CovD_Limit2	
      ,CovD_Deductible1	
      ,CovD_Deductible2	
      ,CovD_FullTermAmt	
      ,CovE_Limit1	
      ,CovE_Limit2	
      ,CovE_Deductible1	
      ,CovE_Deductible2	
      ,CovE_FullTermAmt	
      ,BEDBUG_Limit1	
      ,BEDBUG_Limit2	
      ,BEDBUG_Deductible1	
      ,BEDBUG_Deductible2	
      ,BEDBUG_FullTermAmt	
      ,BOLAW_Limit1	
      ,BOLAW_Limit2	
      ,BOLAW_Deductible1	
      ,BOLAW_Deductible2	
      ,BOLAW_FullTermAmt	
      ,COC_Limit1	
      ,COC_Limit2	
      ,COC_Deductible1	
      ,COC_Deductible2	
      ,COC_FullTermAmt	
      ,EQPBK_Limit1	
      ,EQPBK_Limit2	
      ,EQPBK_Deductible1	
      ,EQPBK_Deductible2	
      ,EQPBK_FullTermAmt	
      ,FRAUD_Limit1	
      ,FRAUD_Limit2	
      ,FRAUD_Deductible1	
      ,FRAUD_Deductible2	
      ,FRAUD_FullTermAmt	
      ,H051ST0_Limit1	
      ,H051ST0_Limit2	
      ,H051ST0_Deductible1	
      ,H051ST0_Deductible2	
      ,H051ST0_FullTermAmt	
      ,HO5_Limit1	
      ,HO5_Limit2	
      ,HO5_Deductible1	
      ,HO5_Deductible2	
      ,HO5_FullTermAmt	
      ,INCB_Limit1	
      ,INCB_Limit2	
      ,INCB_Deductible1	
      ,INCB_Deductible2	
      ,INCB_FullTermAmt	
      ,INCC_Limit1	
      ,INCC_Limit2	
      ,INCC_Deductible1	
      ,INCC_Deductible2	
      ,INCC_FullTermAmt	
      ,LAC_Limit1	
      ,LAC_Limit2	
      ,LAC_Deductible1	
      ,LAC_Deductible2	
      ,LAC_FullTermAmt	
      ,MEDPAY_Limit1	
      ,MEDPAY_Limit2	
      ,MEDPAY_Deductible1	
      ,MEDPAY_Deductible2	
      ,MEDPAY_FullTermAmt	
      ,OccupationDiscount_Limit1	
      ,OccupationDiscount_Limit2	
      ,OccupationDiscount_Deductible1	
      ,OccupationDiscount_Deductible2	
      ,OccupationDiscount_FullTermAmt	
      ,OLT_Limit1	
      ,OLT_Limit2	
      ,OLT_Deductible1	
      ,OLT_Deductible2	
      ,OLT_FullTermAmt	
      ,PIHOM_Limit1	
      ,PIHOM_Limit2	
      ,PIHOM_Deductible1	
      ,PIHOM_Deductible2	
      ,PIHOM_FullTermAmt	
      ,PPREP_Limit1	
      ,PPREP_Limit2	
      ,PPREP_Deductible1	
      ,PPREP_Deductible2	
      ,PPREP_FullTermAmt	
      ,PRTDVC_Limit1	
      ,PRTDVC_Limit2	
      ,PRTDVC_Deductible1	
      ,PRTDVC_Deductible2	
      ,PRTDVC_FullTermAmt	
      ,SeniorDiscount_Limit1	
      ,SeniorDiscount_Limit2	
      ,SeniorDiscount_Deductible1	
      ,SeniorDiscount_Deductible2	
      ,SeniorDiscount_FullTermAmt	
      ,SEWER_Limit1	
      ,SEWER_Limit2	
      ,SEWER_Deductible1	
      ,SEWER_Deductible2	
      ,SEWER_FullTermAmt	
      ,SPP_Limit1	
      ,SPP_Limit2	
      ,SPP_Deductible1	
      ,SPP_Deductible2	
      ,SPP_FullTermAmt	
      ,SRORP_Limit1	
      ,SRORP_Limit2	
      ,SRORP_Deductible1	
      ,SRORP_Deductible2	
      ,SRORP_FullTermAmt	
      ,THEFA_Limit1	
      ,THEFA_Limit2	
      ,THEFA_Deductible1	
      ,THEFA_Deductible2	
      ,THEFA_FullTermAmt	
      ,UTLDB_Limit1	
      ,UTLDB_Limit2	
      ,UTLDB_Deductible1	
      ,UTLDB_Deductible2	
      ,UTLDB_FullTermAmt	
      ,WCINC_Limit1	
      ,WCINC_Limit2	
      ,WCINC_Deductible1	
      ,WCINC_Deductible2	
      ,WCINC_FullTermAmt	
      ,WCINC_Limit1_o	
      ,WCINC_Limit2_o	
      ,WCINC_Deductible1_o	
      ,WCINC_Deductible2_o	
      ,WCINC_FullTermAmt_o	
FROM dbo.DIM_RISK_COVERAGE with (NOLOCK);	
	
GO	
	
	
	
create view [ExportToRedshift].[DIM_CLAIMANT_ASSOCIATE] as 	
select * 	
from dbo.DIM_CLAIMANT_ASSOCIATE;	
