USE [master]
GO


CREATE DATABASE [FSBI_DW_MGA]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FSBI_DW_MGA', FILENAME = N'D:\SQL\DB\FSBI_DW_MGA.mdf' , SIZE = 320375808KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'FSBI_DW_MGA_log', FILENAME = N'E:\SQL\Log\FSBI_DW_MGA_log.ldf' , SIZE = 44456384KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO


USE [STG_MGA]			
GO			
			
CREATE TABLE [dbo].[ETL_CLAIM_CLOSEDDATE](			
	[ClaimNumber] [varchar](255) NULL,		
	[BookDt] [varchar](27) NULL,		
	[ReserveStatusCd] [varchar](255) NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[ETL_CLAIM_HISTORY](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[CLM_SEQUENCE] [bigint] NOT NULL,		
	[CLM_CHANGEDATE] [datetime] NOT NULL,		
	[POLICY_UNIQUEID] [varchar](100) NULL,		
	[PolicySystemId] [int] NULL,		
	[CLAIMANT_UNIQUEID] [varchar](100) NULL,		
	[CLM_DATEOFLOSS] [datetime] NULL,		
	[CLM_CLOSEDDATE] [datetime] NULL,		
	[CLM_OPENEDDATE] [datetime] NULL,		
	[CLM_LOSSREPORTEDDATE] [datetime] NULL,		
	[CLM_CLAIMSTATUSCD] [varchar](50) NULL,		
	[CLM_SUBSTATUSCD] [varchar](50) NULL,		
	[PRIMARYRISK_UNIQUEID] [varchar](100) NULL,		
	[SECONDARYRISK_UNIQUEID] [varchar](100) NULL,		
	[COVERAGE_UNIQUEID] [varchar](100) NULL,		
	[ADJUSTER_UNIQUEID] [varchar](100) NULL,		
	[CLM_ADDRESS1] [varchar](150) NULL,		
	[CLM_ADDRESS2] [varchar](150) NULL,		
	[CLM_COUNTY] [varchar](50) NULL,		
	[CLM_CITY] [varchar](50) NULL,		
	[CLM_STATE] [varchar](50) NULL,		
	[CLM_POSTALCODE] [varchar](20) NULL,		
	[CLM_CLAIMNUMBER] [varchar](50) NULL,		
	[CLM_FEATURENUMBER] [varchar](50) NULL,		
	[CLM_CATCODE] [varchar](100) NULL		
) 			
GO			
			
CREATE TABLE [dbo].[ETL_COVERAGE_HISTORY](			
[SOURCE_SYSTEM] [varchar](100) NOT NULL,			
[LOADDATE] [datetime] NULL,			
[COVERAGE_UNIQUEID] [varchar](100) NOT NULL,			
[COV_SEQUENCE] [int] NOT NULL,			
[COV_TRANSACTIONTYPE] [varchar](5) NOT NULL,			
[COV_TRANSACTIONDATE] [datetime] NOT NULL,			
[COV_CODE] [varchar](50) NOT NULL,			
[COV_SUBCODE] [varchar](50) NULL,			
[COV_EFFECTIVEDATE] [datetime] NOT NULL,			
[COV_EXPIRATIONDATE] [datetime] NOT NULL,			
[COV_ASL] [varchar](5) NULL,			
[COV_SUBLINE] [varchar](5) NULL,			
[COV_CLASSCODE] [varchar](50) NULL,			
[COV_DEDUCTIBLE1] [decimal](13, 2) NULL,			
[COV_DEDUCTIBLE2] [decimal](13, 2) NULL,			
[COV_LIMIT1]  [varchar](255) NULL,			
[COV_LIMIT1TYPE] [varchar](50) NULL,			
[COV_LIMIT2]  [varchar](255) NULL,			
[COV_LIMIT2TYPE] [varchar](50) NULL,			
[COV_LIMIT1_VALUE] [numeric](13, 2) NULL,			
[COV_LIMIT2_VALUE] [numeric](13, 2) NULL			
) 			
GO			
			
			
			
CREATE TABLE [dbo].[ETL_LOG](			
	[loadDate] [datetime] NOT NULL,		
	[bookDate] [date] NOT NULL,		
	[loadStartTime] [datetime] NOT NULL,		
	[loadEndTime] [datetime] NULL,		
	[loadComments] [varchar](256) NULL		
) 			
GO			
			
CREATE TABLE [dbo].[ETL_LOG_DETAILS](			
	[Stage] [varchar](250) NOT NULL,		
	[Operation] [varchar](250) NOT NULL,		
	[OperationTimeStamp] [datetime] NOT NULL,		
	[Comments] [varchar](256) NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[ETL_POLICY_HISTORY](			
[SOURCE_SYSTEM] [varchar](100) NOT NULL,			
[LOADDATE] [datetime] NULL,			
[SystemId] [int] NULL,			
[POLICY_UNIQUEID] [int] NOT NULL,			
[PRODUCT_UNIQUEID] [varchar](100) NULL,			
[COMPANY_UNIQUEID] [varchar](100) NULL,			
[PRODUCER_UNIQUEID] [varchar](100) NULL,			
[FIRSTINSURED_UNIQUEID] [int] NULL,			
[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,			
) 			
GO			
			
			
CREATE TABLE [dbo].[ETL_POLICYTRANSACTIONTYPE](			
	[PTRANS_4SIGHTBICODE] [varchar](50) NULL,		
	[PTRANS_CODE] [varchar](50) NOT NULL,		
	[PTRANS_NAME] [varchar](100) NOT NULL,		
	[PTRANS_DESCRIPTION] [varchar](256) NOT NULL,		
	[PTRANS_SUBCODE] [varchar](50) NOT NULL,		
	[PTRANS_SUBNAME] [varchar](100) NOT NULL,		
	[PTRANS_SUBDESCRIPTION] [varchar](256) NOT NULL,		
	[PTRANS_WRITTENPREM] [varchar](1) NOT NULL,		
	[PTRANS_COMMISSION] [varchar](1) NOT NULL,		
	[PTRANS_GROSSWRITTENPREM] [varchar](1) NOT NULL,		
	[PTRANS_ORIGINALWRITTENPREM] [varchar](1) NOT NULL,		
	[PTRANS_EARNEDPREM] [varchar](1) NOT NULL,		
	[PTRANS_GROSSEARNEDPREM] [varchar](1) NOT NULL,		
	[PTRANS_EARNEDCOMMISSION] [varchar](1) NOT NULL,		
	[PTRANS_MANUALWRITTENPREM] [varchar](1) NOT NULL,		
	[PTRANS_ENDORSEMENTPREM] [varchar](1) NOT NULL,		
	[PTRANS_AUDITPREM] [varchar](1) NOT NULL,		
	[PTRANS_CANCELLATIONPREM] [varchar](1) NOT NULL,		
	[PTRANS_REINSTATEMENTPREM] [varchar](1) NOT NULL,		
	[PTRANS_TAXES] [varchar](1) NOT NULL,		
	[PTRANS_FEES] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY1] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY2] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY3] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY4] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY5] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY6] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY7] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY8] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY9] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY10] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY11] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY12] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY13] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY14] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY15] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY16] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY17] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY18] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY19] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY20] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY21] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY22] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY23] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY24] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY25] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY26] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY27] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY28] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY29] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY30] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY31] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY32] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY33] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY34] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY35] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY36] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY37] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY38] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY39] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY40] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY41] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY42] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY43] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY44] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY45] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY46] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY47] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY48] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY49] [varchar](1) NOT NULL,		
	[PTRANS_USERDEFINEDSUMMARY50] [varchar](1) NOT NULL,		
	[LOADDATE] [datetime] NOT NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[ETL_RISK_HISTORY](			
	[SOURCE_SYSTEM] [varchar](100) NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[POLICY_UNIQUEID] [int] NULL,		
	[RISK_UNIQUEID] [varchar](100) NOT NULL,		
	[RSK_NUMBER] [varchar](50) NULL,		
	[RSK_ADDRESS1] [varchar](150) NULL,		
	[RSK_ADDRESS2] [varchar](150) NULL,		
	[RSK_COUNTY] [varchar](50) NULL,		
	[RSK_CITY] [varchar](50) NULL,		
	[RSK_STATE] [varchar](50) NULL,		
	[RSK_POSTALCODE] [varchar](20) NULL,		
	[RSK_LATITUDE] [decimal](18, 12) NULL,		
	[RSK_LONGITUDE] [decimal](18, 12) NULL,		
) 			
GO			
			
			
CREATE TABLE [dbo].[STG_CLAIM](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[CLM_SEQUENCE] [bigint] NOT NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[POLICY_UNIQUEID] [int] NULL,		
	[PolicySystemId] [int] NULL,		
	[PRIMARYRISK_UNIQUEID] [varchar](100) NULL,		
	[SECONDARYRISK_UNIQUEID] [varchar](100) NULL,		
	[LineCD] [varchar](255) NULL,		
	[CoverageCd] [varchar](255) NULL,		
	[CoverageItemCd] [varchar](255) NULL,		
	[RiskCd] [varchar](255) NULL,		
	[CLAIMANT_UNIQUEID] [varchar](100) NULL,		
	[ADJUSTER_UNIQUEID] [varchar](100) NULL,		
	[CLM_CLAIMNUMBER] [varchar](50) NOT NULL,		
	[CLM_FEATURENUMBER] [varchar](50) NULL,		
	[CLM_DATEOFLOSS] [datetime] NULL,		
	[CLM_LOSSREPORTEDDATE] [datetime] NULL,		
	[CLM_CLOSEDDATE] [datetime] NULL,		
	[CLM_CLAIMSTATUSCD] [varchar](50) NULL,		
	[CLM_SUBSTATUSCD] [varchar](50) NULL,		
	[CLM_COUNTY] [varchar](50) NULL,		
	[CLM_CITY] [varchar](50) NULL,		
	[CLM_STATE] [varchar](50) NULL,		
	[CLM_POSTALCODE] [varchar](20) NULL,		
	[CLM_CHANGEDATE] [datetime] NOT NULL,		
	[CLM_ADDRESS1] [varchar](150) NULL,		
	[CLM_ADDRESS2] [varchar](150) NULL,		
	[AnnualStatementLineCd] [varchar](255) NULL,		
	[SublineCd] [varchar](255) NULL,		
	[COVERAGE_UNIQUEID] [varchar](100) NULL,		
	[CarrierCd] [varchar](255) NULL,		
	[CompanyCd] [varchar](255) NULL,		
	[CarrierGroupCd] [varchar](255) NULL,		
	[ClaimantCd] [varchar](255) NULL,		
	[FeatureCd] [varchar](255) NULL,		
	[FeatureSubCd] [varchar](255) NULL,		
	[FeatureTypeCd] [varchar](255) NULL,		
	[ReserveCd] [varchar](255) NULL,		
	[ReserveTypeCd] [varchar](255) NULL,		
	[AtFaultCd] [varchar](255) NULL,		
	[SourceCd] [varchar](255) NULL,		
	[CategoryCd] [varchar](255) NULL,		
	[LossCauseCd] [varchar](255) NULL,		
	[ReportedTo] [varchar](255) NULL,		
	[ReportedBy] [varchar](255) NULL,		
	[DamageDesc] [varchar](255) NULL,		
	[ShortDesc] [varchar](255) NULL,		
	[Description] [varchar](255) NULL,		
	[Comment] [varchar](255) NULL,		
	[CLM_CATCODE] [varchar](100) NULL,		
	[CLM_CATDESCRIPTION] [varchar](255) NULL,		
	[TotalLossInd] [varchar](255) NULL,		
	[SalvageOwnerRetainedInd] [varchar](255) NULL,		
	[SuitFiledInd] [varchar](10) NULL,		
	[InSIUInd] [varchar](3) NULL,		
	[SubLossCauseCd] [varchar](50) NULL,		
	[LossCauseSeverity] [varchar](10) NULL,		
	[NegligencePct] [int] NULL,		
	[EmergencyService] [varchar](20) NULL,		
	[EmergencyServiceVendor] [varchar](20) NULL,		
	[OccurSite] [varchar](50) NULL,		
	[CLM_OPENEDDATE] [datetime] NULL	,	
	[ForRecordOnlyInd] [varchar](255) NULL		
	) 		
GO			
			
			
			
			
			
CREATE TABLE [dbo].[STG_CLAIMTRANSACTION](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[CLAIMTRANSACTION_UNIQUEID] [varchar](150) NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[PAYEE_UNIQUEID] [varchar](100) NULL,		
	[CT_SEQUENCE] [bigint] NOT NULL,		
	[CT_TRANSACTIONFLAG] [varchar](1) NULL,		
	[CT_TRANSACTIONSTATUS] [varchar](50) NULL,		
	[CT_TRANSACTIONDATE] [datetime] NULL,		
	[CT_ACCOUNTINGDATE] [datetime] NOT NULL,		
	[CT_CHANGEDATE] [datetime] NULL,		
	[CT_TYPECODE] [varchar](50) NOT NULL,		
	[CT_SUBTYPECODE] [varchar](50) NULL,		
	[CT_AMOUNT] [decimal](13, 2) NOT NULL,		
	[CT_ORIGCURRENCYCODE] [varchar](5) NULL,		
	[CT_ORIGCURRENCYAMOUNT] [decimal](13, 3) NULL,		
	[ReserveCd] [varchar](255) NULL,		
	[ReserveTypeCd] [varchar](255) NULL,		
	[BookDt] [datetime] NULL,		
	[SystemId] [int] NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_COVERAGE](			
[SOURCE_SYSTEM] [varchar](100) NOT NULL,			
[LOADDATE] [datetime] NULL,			
[COVERAGE_UNIQUEID] [varchar](100) NOT NULL,			
[COV_SEQUENCE] [int] NOT NULL,			
[COV_TRANSACTIONTYPE] [varchar](5) NOT NULL,			
[COV_TRANSACTIONDATE] [datetime] NOT NULL,			
[COV_CODE] [varchar](50) NOT NULL,			
[COV_SUBCODE] [varchar](50) NULL,			
[COV_EFFECTIVEDATE] [datetime] NOT NULL,			
[COV_EXPIRATIONDATE] [datetime] NOT NULL,			
[COV_ASL] [varchar](5) NULL,			
[COV_SUBLINE] [varchar](5) NULL,			
[COV_CLASSCODE] [varchar](50) NULL,			
[COV_DEDUCTIBLE1] [decimal](13, 2) NULL,			
[COV_DEDUCTIBLE2] [decimal](13, 2) NULL,			
[COV_LIMIT1]  [varchar](255) NULL,			
[COV_LIMIT1TYPE] [varchar](50) NULL,			
[COV_LIMIT2]  [varchar](255) NULL,			
[COV_LIMIT2TYPE] [varchar](50) NULL,			
[COV_LIMIT1_VALUE] [numeric](13, 2) NULL,			
[COV_LIMIT2_VALUE] [numeric](13, 2) NULL			
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_POLICY](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[POLICY_UNIQUEID] [int] NOT NULL,		
	[TransactionCd] [varchar](255) NULL,		
	[PRODUCT_UNIQUEID] [varchar](100) NULL,		
	[COMPANY_UNIQUEID] [varchar](100) NULL,		
	[PRODUCER_UNIQUEID] [varchar](100) NULL,		
	[FIRSTINSURED_UNIQUEID] [int] NULL,		
	[POL_POLICYNUMBER] [varchar](50) NOT NULL,		
	[TERM] [varchar](10) NULL,		
	[POL_EFFECTIVEDATE] [datetime] NULL,		
	[POL_EXPIRATIONDATE] [datetime] NULL,		
	[CarrierCd] [varchar](255) NULL,		
	[CompanyCd] [varchar](255) NULL,		
	[TermDays] [int] NULL,		
	[CarrierGroupCd] [varchar](255) NULL,		
	[StateCD] [varchar](255) NULL,		
	[BusinessSourceCd] [varchar](255) NULL,		
	[PreviouscarrierCd] [varchar](255) NULL,		
	[PolicyFormCode] [varchar](255) NULL,		
	[SubTypeCd] [varchar](255) NULL,		
	[AltSubTypeCd] [varchar](32) NULL,		
	[payPlanCd] [varchar](255) NULL,		
	[InceptionDt] [datetime] NULL,		
	[PriorPolicyNumber] [varchar](255) NULL,		
	[PreviousPolicyNumber] [varchar](255) NULL,		
	[AffinityGroupCd] [varchar](255) NULL,		
	[ProgramInd] [varchar](255) NULL,		
	[RelatedPolicyNumber] [varchar](255) NULL,		
	[QuoteNumber] [varchar](255) NULL,		
	[RenewalTermCd] [varchar](255) NULL,		
	[RewritePolicyRef] [varchar](255) NULL,		
	[RewriteFromPolicyRef] [varchar](255) NULL,		
	[CancelDt] [date] NULL,		
	[ReinstateDt] [date] NULL,		
	[PersistencyDiscountDt] [date] NULL,		
	[PaperLessDelivery] [varchar](10) NULL,		
	[MultiCarDiscountInd] [varchar](255) NULL,		
	[LateFee] [varchar](255) NULL,		
	[NSFFee] [varchar](255) NULL,		
	[InstallmentFee] [varchar](255) NULL,		
	[batchquotesourcecd] [varchar](255) NULL,		
	[WaivePolicyFeeInd] [varchar](255) NULL,		
	[LiabilityLimitCPL] [varchar](255) NULL,		
	[LiabilityReductionInd] [varchar](255) NULL,		
	[LiabilityLimitOLT] [varchar](255) NULL,		
	[PersonalLiabilityLimit] [varchar](255) NULL,		
	[GLOccurrenceLimit] [varchar](255) NULL,		
	[GLAggregateLimit] [varchar](255) NULL,		
	[Policy_SPINN_Status] [varchar](255) NULL,		
	[BILimit] [varchar](255) NULL,		
	[PDLimit] [varchar](255) NULL,		
	[UMBILimit] [varchar](255) NULL,		
	[MedPayLimit] [varchar](255) NULL,		
	[MultiPolicyDiscount] [varchar](3) NULL,		
	[MultiPolicyAutoDiscount] [varchar](255) NULL,		
	[MultiPolicyAutoNumber] [varchar](255) NULL,		
	[MultiPolicyHomeDiscount] [varchar](255) NULL,		
	[HomeRelatedPolicyNumber] [varchar](255) NULL,		
	[MultiPolicyUmbrellaDiscount] [varchar](255) NULL,		
	[UmbrellaRelatedPolicyNumber] [varchar](255) NULL,		
	[CSEEmployeeDiscountInd] [varchar](255) NULL,		
	[FullPayDiscountInd] [varchar](255) NULL,		
	[TwoPayDiscountInd] [varchar](255) NULL,		
	[PrimaryPolicyNumber] [varchar](255) NULL,		
	[LandLordInd] [varchar](255) NULL,		
	[PersonalInjuryInd] [varchar](255) NULL,		
	[VehicleListConfirmedInd] [varchar](4) NULL,		
	[FirstPayment] [date] NULL,		
	[LastPayment] [date] NULL,		
	[BalanceAmt] [decimal](38, 6) NULL,		
	[PaidAmt] [decimal](38, 6) NULL,		
	[AccountRef] int NULL,		
	[customer_uniqueid] [int] NULL,		
	[MGAFeePlanCd] [varchar](24) NULL,		
	[MGAFeePct] [decimal](28,6) NULL,		
	[TPAFeePlanCd] [varchar](24) NULL,		
	[TPAFeePct] [decimal](28,6)  NULL,		
	[ApplicationNumber] [varchar](255) NULL,		
	[Application_UpdateTimestamp] [datetime] NULL,		
	[QuoteInfo_UpdateDt] [date] NULL,		
	[QuoteInfo_adduser_uniqueid] [varchar](255) NULL,		
	[original_policy_uniqueid] [int] NULL,		
	[Application_Type] [varchar](255) NULL,		
	[QuoteInfo_Type] [varchar](255) NULL,		
	[Application_Status] [varchar](255) NULL,		
	[QuoteInfo_Status] [varchar](255) NULL,		
	[QuoteInfo_CloseReasonCd] [varchar](255) NULL,		
	[QuoteInfo_CloseSubReasonCd] [varchar](255) NULL,		
	[QuoteInfo_CloseComment] [varchar](255) NULL,		
	[WrittenPremiumAmt] [decimal](38, 6) NULL,		
	[FullTermAmt] [decimal](38, 6) NULL,		
	[CommissionAmt] [decimal](38, 6) NULL		
	) 		
	GO		
			
			
			
			
			
			
CREATE TABLE [dbo].[STG_POLICYTRANSACTION](			
[SOURCE_SYSTEM] [varchar](100) NOT NULL,			
[LOADDATE] [datetime] NULL,			
[SystemId] [int] NULL,			
[POLICY_UNIQUEID] [varchar](100) NOT NULL,			
[POLICYTRANSACTION_UNIQUEID] [varchar](100) NOT NULL,			
[PRIMARYRISK_UNIQUEID] [varchar](100) NOT NULL,			
[SECONDARYRISK_UNIQUEID] [varchar](100) NOT NULL,			
[COVERAGE_UNIQUEID] [varchar](100) NOT NULL,			
[PT_TRANSACTIONDATE] [datetime] NULL,			
[PT_SEQUENCE] [bigint] NOT NULL,			
[PT_ACCOUNTINGDATE] [datetime] NOT NULL,			
[PT_EFFECTIVEDATE] [datetime] NOT NULL,			
[PT_TYPECODE] [varchar](50) NOT NULL,			
[PT_TYPESUBCODE] [varchar](50) NOT NULL,			
[PT_AMOUNT] [decimal](13, 2) NOT NULL,			
[PT_COMMISSIONAMOUNT] [decimal](13, 2) NULL,			
[PT_TERMAMOUNT] [decimal](13, 2) NULL,			
[TRANSACTIONCD] [varchar](255) NULL,			
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_POLICYTRANSACTIONEXTENSION](			
	[SOURCE_SYSTEM] [varchar](5) NULL,		
	[LOADDATE] [datetime] NULL,		
	[POLICYTRANSACTION_UNIQUEID] [varchar](317) NOT NULL,		
	[TRANSACTIONNUMBER] [int] NOT NULL,		
	[POLICY_UNIQUEID] [int]  NOT NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[TRANSACTIONCD] [varchar](255) NOT NULL,		
	[TRANSACTIONLONGDESCRIPTION] [varchar](255) NULL,		
	[TRANSACTIONSHORTDESCRIPTION] [varchar](255) NULL,		
	[CANCELTYPECD] [varchar](255) NULL,		
	[CANCELREQUESTEDBYCD] [varchar](255) NULL,		
	[CancelReason] [varchar](255) NULL,		
	[PolicyProgramCode] [varchar](255) NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_RISK](			
	[SOURCE_SYSTEM] [varchar](100) NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[POLICY_UNIQUEID] [int] NULL,		
	[RISK_UNIQUEID] [varchar](100) NOT NULL,		
	[RSK_NUMBER] [varchar](50) NULL,		
	[RSK_ADDRESS1] [varchar](150) NULL,		
	[RSK_ADDRESS2] [varchar](150) NULL,		
	[RSK_COUNTY] [varchar](50) NULL,		
	[RSK_CITY] [varchar](50) NULL,		
	[RSK_STATE] [varchar](50) NULL,		
	[RSK_POSTALCODE] [varchar](20) NULL,		
	[RSK_LATITUDE] [decimal](18, 12) NULL,		
	[RSK_LONGITUDE] [decimal](18, 12) NULL,		
) 			
GO			
			
			
			
			
CREATE TABLE [dbo].[STG_PRODUCT](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[ProductVersionIdRef] [varchar](64) NOT NULL,		
	[ProductVersion] [varchar](24) NULL,		
	[Name] [varchar](64) NULL,		
	[Description] [varchar](88) NULL,		
	[ProductTypeCd] [varchar](32) NULL,		
	[CarrierGroupCd] [varchar](16) NULL,		
	[CarrierCd] [varchar](8) NULL,		
	[isSelect] [int] NULL,		
	[LineCd] [varchar](32) NULL,		
	[SubTypeCd] [varchar](24) NULL,		
	[AltSubTypeCd] [varchar](32) NULL,		
	[SubTypeShortDesc] [varchar](64) NULL,		
	[SubTypeFullDesc] [varchar](64) NULL,		
	[PolicyNumberPrefix] [varchar](3) NULL,		
	[StartDt] [date] NULL,		
	[StopDt] [date] NULL,		
	[RenewalStartDt] [date] NULL,		
	[RenewalStopDt] [date] NULL,		
	[StateCd] [varchar](2) NULL,		
	[Contract] [varchar](8) NULL,		
	[LOB] [varchar](8) NULL,		
	[PropertyForm] [varchar](8) NULL,		
	[PreRenewalDays] [int] NULL,		
	[AutoRenewalDays] [int] NULL,		
	[MGAFeePlanCd] [varchar](24) NULL,		
	[TPAFeePlanCd] [varchar](24) NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_BUILDING](			
	[LineCD] [varchar](255) NULL,		
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[Policy_Uniqueid] [int] NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[Risk_UniqueId] [varchar](255) NULL,		
	[BldgNumber] [int] NULL,		
	[Risk_Type][varchar](255) NULL,		
	[Building_uniqueid] [varchar](525) NOT NULL,		
	[SPInnBuilding_Id] [varchar](255) NULL,		
	[Status] [varchar](255) NULL,		
	[StateProvCd] [varchar](255) NULL,		
	[County] [varchar](255) NULL,		
	[PostalCode] [varchar](255) NULL,		
	[City] [varchar](255) NULL,		
	[Addr1] [varchar](255) NULL,		
	[Addr2] [varchar](255) NULL,		
	[BusinessCategory] [varchar](255) NULL,		
	[BusinessClass] [varchar](255) NULL,		
	[ConstructionCd] [varchar](255) NULL,		
	[RoofCd] [varchar](255) NULL,		
	[YearBuilt] [int] NULL,		
	[SqFt] [int] NULL,		
	[Stories] [int] NULL,		
	[Units] [int] NULL,		
	[OccupancyCd] [varchar](255) NULL,		
	[ProtectionClass] [varchar](255) NULL,		
	[TerritoryCd] [varchar](255) NULL,		
	[BuildingLimit] [int] NULL,		
	[ContentsLimit] [int] NULL,		
	[ValuationMethod] [varchar](255) NULL,		
	[InflationGuardPct] [int] NULL,		
	[OrdinanceOrLawInd] [varchar](255) NULL,		
	[ScheduledPremiumMod] [int] NULL,		
	[WindHailExclusion] [varchar](255) NULL,		
	[CovALimit] [int] NULL,		
	[CovBLimit] [int] NULL,		
	[CovCLimit] [int] NULL,		
	[CovDLimit] [int] NULL,		
	[CovELimit] [int] NULL,		
	[CovFLimit] [int] NULL,		
	[AllPerilDed] [varchar](255) NULL,		
	[BurglaryAlarmType] [varchar](255) NULL,		
	[FireAlarmType] [varchar](255) NULL,		
	[CovBLimitIncluded] [int] NULL,		
	[CovBLimitIncrease] [int] NULL,		
	[CovCLimitIncluded] [int] NULL,		
	[CovCLimitIncrease] [int] NULL,		
	[CovDLimitIncluded] [int] NULL,		
	[CovDLimitIncrease] [int] NULL,		
	[OrdinanceOrLawPct] [int] NULL,		
	[NeighborhoodCrimeWatchInd] [varchar](255) NULL,		
	[EmployeeCreditInd] [varchar](255) NULL,		
	[MultiPolicyInd] [varchar](255) NULL,		
	[HomeWarrantyCreditInd] [varchar](255) NULL,		
	[YearOccupied] [int] NULL,		
	[YearPurchased] [int] NULL,		
	[TypeOfStructure] [varchar](255) NULL,		
	[FeetToFireHydrant] [int] NULL,		
	[NumberOfFamilies] [int] NULL,		
	[MilesFromFireStation] [int] NULL,		
	[Rooms] [int] NULL,		
	[RoofPitch] [varchar](255) NULL,		
	[FireDistrict] [varchar](255) NULL,		
	[SprinklerSystem] [varchar](255) NULL,		
	[FireExtinguisherInd] [varchar](255) NULL,		
	[KitchenFireExtinguisherInd] [varchar](255) NULL,		
	[DeadboltInd] [varchar](255) NULL,		
	[GatedCommunityInd] [varchar](255) NULL,		
	[CentralHeatingInd] [varchar](255) NULL,		
	[Foundation] [varchar](255) NULL,		
	[WiringRenovation] [varchar](255) NULL,		
	[WiringRenovationCompleteYear] [varchar](255) NULL,		
	[PlumbingRenovation] [varchar](255) NULL,		
	[HeatingRenovation] [varchar](255) NULL,		
	[PlumbingRenovationCompleteYear] [varchar](255) NULL,		
	[ExteriorPaintRenovation] [varchar](255) NULL,		
	[HeatingRenovationCompleteYear] [varchar](255) NULL,		
	[CircuitBreakersInd] [varchar](255) NULL,		
	[CopperWiringInd] [varchar](255) NULL,		
	[ExteriorPaintRenovationCompleteYear] [varchar](255) NULL,		
	[CopperPipesInd] [varchar](255) NULL,		
	[EarthquakeRetrofitInd] [varchar](255) NULL,		
	[PrimaryFuelSource] [varchar](255) NULL,		
	[SecondaryFuelSource] [varchar](255) NULL,		
	[UsageType] [varchar](255) NULL,		
	[HomegardCreditInd] [varchar](255) NULL,		
	[MultiPolicyNumber] [varchar](255) NULL,		
	[LocalFireAlarmInd] [varchar](255) NULL,		
	[NumLosses] [int] NULL,		
	[CovALimitIncrease] [int] NULL,		
	[CovALimitIncluded] [int] NULL,		
	[MonthsRentedOut] [int] NULL,		
	[RoofReplacement] [varchar](255) NULL,		
	[SafeguardPlusInd] [varchar](255) NULL,		
	[CovELimitIncluded] [int] NULL,		
	[RoofReplacementCompleteYear] [varchar](255) NULL,		
	[CovELimitIncrease] [int] NULL,		
	[OwnerOccupiedUnits] [int] NULL,		
	[TenantOccupiedUnits] [int] NULL,		
	[ReplacementCostDwellingInd] [varchar](255) NULL,		
	[FeetToPropertyLine] [varchar](255) NULL,		
	[GalvanizedPipeInd] [varchar](255) NULL,		
	[WorkersCompInservant] [int] NULL,		
	[WorkersCompOutservant] [int] NULL,		
	[LiabilityTerritoryCd] [varchar](255) NULL,		
	[PremisesLiabilityMedPayInd] [varchar](255) NULL,		
	[RelatedPrivateStructureExclusion] [varchar](255) NULL,		
	[VandalismExclusion] [varchar](255) NULL,		
	[VandalismInd] [varchar](255) NULL,		
	[RoofExclusion] [varchar](255) NULL,		
	[ExpandedReplacementCostInd] [varchar](255) NULL,		
	[ReplacementValueInd] [varchar](255) NULL,		
	[OtherPolicyNumber1] [varchar](255) NULL,		
	[OtherPolicyNumber2] [varchar](255) NULL,		
	[OtherPolicyNumber3] [varchar](255) NULL,		
	[PrimaryPolicyNumber] [varchar](255) NULL,		
	[OtherPolicyNumbers] [varchar](255) NULL,		
	[ReportedFireHazardScore] [varchar](255) NULL,		
	[FireHazardScore] [varchar](255) NULL,		
	[ReportedSteepSlopeInd] [varchar](255) NULL,		
	[SteepSlopeInd] [varchar](255) NULL,		
	[ReportedHomeReplacementCost] [int] NULL,		
	[ReportedProtectionClass] [varchar](255) NULL,		
	[EarthquakeZone] [varchar](255) NULL,		
	[MMIScore] [varchar](255) NULL,		
	[HomeInspectionDiscountInd] [varchar](255) NULL,		
	[RatingTier] [varchar](255) NULL,		
	[SoilTypeCd] [varchar](255) NULL,		
	[ReportedFireLineAssessment] [varchar](255) NULL,		
	[AAISFireProtectionClass] [varchar](255) NULL,		
	[InspectionScore] [varchar](255) NULL,		
	[AnnualRents] [int] NULL,		
	[PitchOfRoof] [varchar](255) NULL,		
	[TotalLivingSqFt] [int] NULL,		
	[ParkingSqFt] [int] NULL,		
	[ParkingType] [varchar](255) NULL,		
	[RetrofitCompleted] [varchar](255) NULL,		
	[NumPools] [varchar](255) NULL,		
	[FullyFenced] [varchar](255) NULL,		
	[DivingBoard] [varchar](255) NULL,		
	[Gym] [varchar](255) NULL,		
	[FreeWeights] [varchar](255) NULL,		
	[WireFencing] [varchar](255) NULL,		
	[OtherRecreational] [varchar](255) NULL,		
	[OtherRecreationalDesc] [varchar](255) NULL,		
	[HealthInspection] [varchar](255) NULL,		
	[HealthInspectionDt] [datetime] NULL,		
	[HealthInspectionCited] [varchar](255) NULL,		
	[PriorDefectRepairs] [varchar](255) NULL,		
	[MSBReconstructionEstimate] [varchar](255) NULL,		
	[BIIndemnityPeriod] [varchar](255) NULL,		
	[EquipmentBreakdown] [varchar](255) NULL,		
	[MoneySecurityOnPremises] [varchar](255) NULL,		
	[MoneySecurityOffPremises] [varchar](255) NULL,		
	[WaterBackupSump] [varchar](255) NULL,		
	[SprinkleredBuildings] [varchar](255) NULL,		
	[SurveillanceCams] [varchar](255) NULL,		
	[GatedComplexKeyAccess] [varchar](255) NULL,		
	[EQRetrofit] [varchar](255) NULL,		
	[UnitsPerBuilding] [varchar](255) NULL,		
	[NumStories] [varchar](255) NULL,		
	[ConstructionQuality] [varchar](255) NULL,		
	[BurglaryRobbery] [varchar](255) NULL,		
	[NFPAClassification] [varchar](255) NULL,		
	[AreasOfCoverage] [varchar](255) NULL,		
	[CODetector] [varchar](255) NULL,		
	[SmokeDetector] [varchar](255) NULL,		
	[SmokeDetectorInspectInd] [varchar](255) NULL,		
	[WaterHeaterSecured] [varchar](255) NULL,		
	[BoltedOrSecured] [varchar](255) NULL,		
	[SoftStoryCripple] [varchar](255) NULL,		
	[SeniorHousingPct] [varchar](255) NULL,		
	[DesignatedSeniorHousing] [varchar](255) NULL,		
	[StudentHousingPct] [varchar](255) NULL,		
	[DesignatedStudentHousing] [varchar](255) NULL,		
	[PriorLosses] [int] NULL,		
	[TenantEvictions] [varchar](255) NULL,		
	[VacancyRateExceed] [varchar](255) NULL,		
	[SeasonalRentals] [varchar](255) NULL,		
	[CondoInsuingAgmt] [varchar](255) NULL,		
	[GasValve] [varchar](255) NULL,		
	[OwnerOccupiedPct] [varchar](255) NULL,		
	[RestaurantName] [varchar](255) NULL,		
	[HoursOfOperation] [varchar](255) NULL,		
	[RestaurantSqFt] [int] NULL,		
	[SeatingCapacity] [int] NULL,		
	[AnnualGrossSales] [int] NULL,		
	[SeasonalOrClosed] [varchar](255) NULL,		
	[BarCocktailLounge] [varchar](255) NULL,		
	[LiveEntertainment] [varchar](255) NULL,		
	[BeerWineGrossSales] [varchar](255) NULL,		
	[DistilledSpiritsServed] [varchar](255) NULL,		
	[KitchenDeepFryer] [varchar](255) NULL,		
	[SolidFuelCooking] [varchar](255) NULL,		
	[ANSULSystem] [varchar](255) NULL,		
	[ANSULAnnualInspection] [varchar](255) NULL,		
	[TenantNamesList] [varchar](255) NULL,		
	[TenantBusinessType] [varchar](255) NULL,		
	[TenantGLLiability] [varchar](255) NULL,		
	[InsuredOccupiedPortion] [varchar](255) NULL,		
	[ValetParking] [varchar](255) NULL,		
	[LessorSqFt] [int] NULL,		
	[BuildingRiskNumber] [int] NULL,		
	[MultiPolicyIndUmbrella] [varchar](255) NULL,		
	[PoolInd] [varchar](255) NULL,		
	[StudsUpRenovation] [varchar](255) NULL,		
	[StudsUpRenovationCompleteYear] [varchar](255) NULL,		
	[MultiPolicyNumberUmbrella] [varchar](255) NULL,		
	[RCTMSBAmt] [varchar](255) NULL,		
	[RCTMSBHomeStyle] [varchar](255) NULL,		
	[WINSOverrideNonSmokerDiscount] [varchar](255) NULL,		
	[WINSOverrideSeniorDiscount] [varchar](255) NULL,		
	[ITV] [int] NULL,		
	[ITVDate] [datetime] NULL,		
	[MSBReportType] [varchar](255) NULL,		
	[VandalismDesiredInd] [varchar](255) NULL,		
	[WoodShakeSiding] [varchar](255) NULL,		
	[CSEAgent] [varchar](3) NULL,		
	[PropertyManager] [varchar](3) NULL,		
	[RentersInsurance] [varchar](3) NULL,		
	[WaterDetectionDevice] [varchar](3) NULL,		
	[AutoHomeInd] [varchar](3) NULL,		
	[EarthquakeUmbrellaInd] [varchar](3) NULL,		
	[LandlordInd] [varchar](3) NULL,		
	[LossAssessment] [varchar](16) NULL,		
	[GasShutOffInd] [varchar](4) NULL,		
	[WaterDed] [varchar](16) NULL,		
	[ServiceLine] [varchar](4) NULL,		
	[FunctionalReplacementCost] [varchar](4) NULL,		
	[MilesOfStreet] [varchar](32) NULL,		
	[HOAExteriorStructure] [varchar](3) NULL,		
	[RetailPortionDevelopment] [varchar](32) NULL,		
	[LightIndustrialType] [varchar](128) NULL,		
	[LightIndustrialDescription] [varchar](128) NULL,		
	[PoolCoverageLimit] [int] NULL,		
	[MultifamilyResidentialBuildings] [int] NULL,		
	[SinglefamilyDwellings] [int] NULL,		
	[AnnualPayroll] [int] NULL,		
	[AnnualRevenue] [int] NULL,		
	[BedsOccupied] [varchar](16) NULL,		
	[EmergencyLighting] [varchar](4) NULL,		
	[ExitSignsPosted] [varchar](4) NULL,		
	[FullTimeStaff] [varchar](4) NULL,		
	[LicensedBeds] [varchar](10) NULL,		
	[NumberofFireExtinguishers] [int] NULL,		
	[OtherFireExtinguishers] [varchar](16) NULL,		
	[OxygenTanks] [varchar](4) NULL,		
	[PartTimeStaff] [varchar](4) NULL,		
	[SmokingPermitted] [varchar](4) NULL,		
	[StaffOnDuty] [varchar](4) NULL,		
	[TypeofFireExtinguishers] [varchar](32) NULL,		
	[CovADDRR_SecondaryResidence] [varchar](3) NULL,		
	[CovADDRRPrem_SecondaryResidence] [numeric](13, 2) NULL,		
	[HODeluxe] [varchar](3) NULL,		
	[Latitude] [decimal](18, 12) NULL,		
	[Longitude] [decimal](18, 12) NULL,		
	[WUIClass] [varchar](30) NULL,		
	[CensusBlock] [varchar](30) NULL,		
	[WaterRiskScore] [int] NULL,		
	[LandlordLossPreventionServices] [varchar](5) NULL,		
	[EnhancedWaterCoverage] [varchar](5) NULL,		
	[LandlordProperty] [varchar](5) NULL,		
	[LiabilityExtendedToOthers] [varchar](5) NULL,		
	[LossOfUseExtendedTime] [varchar](5) NULL,		
	[OnPremisesTheft] [int] NULL,		
	[BedBugMitigation] [varchar](5) NULL,		
	[HabitabilityExclusion] [varchar](5) NULL,		
	[WildfireHazardPotential] [varchar](20) NULL,		
	[BackupOfSewersAndDrains] [int] NULL,		
	[VegetationSetbackFt] [int] NULL,		
	[YardDebrisCoverageArea] [int] NULL,		
	[YardDebrisCoveragePercentage] [varchar](5) NULL,		
	[CapeTrampoline] [varchar](16) NULL,		
	[CapePool] [varchar](16) NULL,		
	[RoofConditionRating] [varchar](16) NULL,		
	[TrampolineInd] [varchar](16) NULL,		
	[PlumbingMaterial] [varchar](16) NULL,		
	[CentralizedHeating] [varchar](16) NULL,		
	[FireDistrictSubscriptionCode] [varchar](8) NULL,		
	[RoofCondition] [varchar](20) NULL		
) 			
GO			
			
			
 CREATE NONCLUSTERED INDEX IDX_COV_HIST_ETL ON dbo.ETL_COVERAGE_HISTORY (  COVERAGE_UNIQUEID ASC  , COV_TRANSACTIONDATE DESC  )   INCLUDE ( COV_ASL , COV_CLASSCODE , COV_CLASSCODEDESCRIPTION , COV_CLASSSUBCODE , COV_CODE , COV_DEDUCTIBLE1 , COV_DEDUCTIBLE1TYPE , COV_DEDUCTIBLE2 , COV_DEDUCTIBLE2TYPE , COV_DEDUCTIBLE3 , COV_DEDUCTIBLE3TYPE , COV_DESCRIPTION , COV_EFFECTIVEDATE , COV_EXPIRATIONDATE , COV_LIMIT1 , COV_LIMIT1TYPE , COV_LIMIT2 , COV_LIMIT2TYPE , COV_LIMIT3 , COV_LIMIT3TYPE , COV_LIMIT4 , COV_LIMIT4TYPE , COV_LIMIT5 , COV_LIMIT5TYPE , COV_NAME , COV_SEQUENCE , COV_SUBCODE , COV_SUBCODEDESCRIPTION , COV_SUBCODENAME , COV_SUBLINE , COV_TRANSACTIONTYPE , COV_TYPE )  ;			
 CREATE NONCLUSTERED INDEX IDX_POL_HIST_ETL ON dbo.ETL_POLICY_HISTORY (  POLICY_UNIQUEID ASC  , POL_CHANGEDATE DESC  )   INCLUDE ( COMPANY_UNIQUEID , FIFTHINSURED_UNIQUEID , FIRSTINSURED_UNIQUEID , FOURTHINSURED_UNIQUEID , POL_ASL , POL_CONVERSIONINDICATORCODE , POL_EFFECTIVEDATE , POL_EXPIRATIONDATE , POL_MASTERTERRITORYCODE , POL_MASTERTERRITORYNAME , POL_POLICYNUMBER , POL_POLICYNUMBERPREFIX , POL_POLICYNUMBERSUFFIX , POL_SEQUENCE , POLICYNEWORRENEWAL , PRODUCER_UNIQUEID , PRODUCT_UNIQUEID , SECONDINSURED_UNIQUEID , SUBPRODUCER_UNIQUEID , THIRDINSURED_UNIQUEID , UNDERWRITER_UNIQUEID )  ;			
 CREATE NONCLUSTERED INDEX IDX_POL_HIST_ETL2 ON dbo.ETL_POLICY_HISTORY (  POLICY_UNIQUEID ASC  )   INCLUDE ( COMPANY_UNIQUEID , FIFTHINSURED_UNIQUEID , FIRSTINSURED_UNIQUEID , FOURTHINSURED_UNIQUEID , POL_ASL , POL_CHANGEDATE , POL_CONVERSIONINDICATORCODE , POL_EFFECTIVEDATE , POL_EXPIRATIONDATE , POL_MASTERTERRITORYCODE , POL_MASTERTERRITORYNAME , POL_POLICYNUMBER , POL_POLICYNUMBERPREFIX , POL_POLICYNUMBERSUFFIX , POL_SEQUENCE , POLICYNEWORRENEWAL , PRODUCER_UNIQUEID , PRODUCT_UNIQUEID , SECONDINSURED_UNIQUEID , SUBPRODUCER_UNIQUEID , THIRDINSURED_UNIQUEID , UNDERWRITER_UNIQUEID )  ;			
 CREATE NONCLUSTERED INDEX IPTRNTYPETL ON dbo.ETL_POLICYTRANSACTIONTYPE (  PTRANS_CODE ASC  , PTRANS_SUBCODE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_RSKLOCHIST_ETL ON dbo.ETL_RISK_HISTORY (  RISK_UNIQUEID ASC  , RSK_TRANSACTIONDATE DESC  , RSK_SEQUENCE DESC  )   INCLUDE ( FOTHRINT_UNIQUEID , RSK_ADDRESS1 , RSK_ADDRESS2 , RSK_ADDRESS3 , RSK_CITY , RSK_COUNTRY , RSK_COUNTY , RSK_LATITUDE , RSK_LONGITUDE , RSK_POSTALCODE , RSK_STATE , RSK_TERRITORYCODE , RSK_TERRITORYNAME , SOTHRINT_UNIQUEID )  ;			
 CREATE CLUSTERED INDEX IDX_STG_PROP_LDATE ON dbo.STG_BUILDING (  loaddate ASC  , BUILDING_UNIQUEID ASC  , CHANGEDATE ASC  );			
 CREATE NONCLUSTERED INDEX IDX_STG_CLMTRN_ETL ON dbo.STG_CLAIMTRANSACTION (  LOADDATE ASC  , CLAIM_UNIQUEID ASC  )   INCLUDE ( CLAIMTRANSACTION_UNIQUEID , CT_AMOUNT , CT_CHANGEDATE , CT_ORIGCURRENCYAMOUNT , CT_ORIGCURRENCYCODE , CT_SEQUENCE , CT_SUBTYPECODE , CT_TRANSACTIONFLAG , CT_TYPECODE , PAYEE_UNIQUEID )  ;			
 CREATE NONCLUSTERED INDEX IDX_STG_CLMTRN_LDATE ON dbo.STG_CLAIMTRANSACTION (  LOADDATE ASC  , CLAIM_UNIQUEID ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_COV_LDATE ON dbo.STG_COVERAGE (  LOADDATE ASC  , COV_TRANSACTIONDATE DESC  , COV_SEQUENCE DESC  )   INCLUDE ( COV_ASL , COV_CLASSCODE , COV_CLASSCODEDESCRIPTION , COV_CLASSCODENAME , COV_CLASSSUBCODE , COV_CLASSSUBCODENAME , COV_CODE , COV_DEDUCTIBLE1 , COV_DEDUCTIBLE1TYPE , COV_DEDUCTIBLE2 , COV_DEDUCTIBLE2TYPE , COV_DEDUCTIBLE3 , COV_DEDUCTIBLE3TYPE , COV_DESCRIPTION , COV_EFFECTIVEDATE , COV_EXPIRATIONDATE , COV_LIMIT1 , COV_LIMIT1TYPE , COV_LIMIT2 , COV_LIMIT2TYPE , COV_LIMIT3 , COV_LIMIT3TYPE , COV_LIMIT4 , COV_LIMIT4TYPE , COV_LIMIT5 , COV_LIMIT5TYPE , COV_NAME , COV_SUBCODE , COV_SUBCODEDESCRIPTION , COV_SUBCODENAME , COV_SUBLINE , COV_TRANSACTIONTYPE , COV_TYPE , COVERAGE_UNIQUEID );			
 CREATE NONCLUSTERED INDEX IDX_STG_COVUID_ETL ON dbo.STG_COVERAGE (  COVERAGE_UNIQUEID ASC  , COV_TRANSACTIONDATE ASC  , COV_SEQUENCE ASC  );			
 CREATE NONCLUSTERED INDEX IDX_STG_LENTYLDATE ON dbo.STG_LEGALENTITY (  LOADDATE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_POL_LDATE ON dbo.STG_POLICY (LOADDATE ASC) ;			
 CREATE NONCLUSTERED INDEX IDX_STG_PTRN_ETL ON dbo.STG_POLICYTRANSACTION (  POLICY_UNIQUEID ASC  , PT_TYPECODE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_PTRN_LDATE ON dbo.STG_POLICYTRANSACTION (  LOADDATE ASC  , PT_ACCOUNTINGDATE ASC  , PT_SEQUENCE ASC  , POLICY_UNIQUEID ASC  , PRIMARYRISK_UNIQUEID ASC  , SECONDARYRISK_UNIQUEID ASC  , COVERAGE_UNIQUEID ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_PRDT_LDATE ON dbo.STG_PRODUCT (  LOADDATE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_RSK_LDATE ON dbo.STG_RISK (  LOADDATE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_STG_RSKUID_ETL ON dbo.STG_RISK (  RISK_UNIQUEID ASC  , RSK_SEQUENCE ASC  , RSK_TRANSACTIONDATE ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_ETL_CLAIM_CLOSEDDATE_ETL ON dbo.ETL_CLAIM_CLOSEDDATE (  ClaimNumber ASC  , BookDt DESC  )   ;			
 CREATE CLUSTERED INDEX IDX_CLM_HIST_ETL2 ON dbo.ETL_CLAIM_HISTORY (  CLM_CHANGEDATE ASC  , CLM_CLAIMSTATUSCD ASC  , CLM_SUBSTATUSCD ASC  , CLM_CLAIMNUMBER ASC  )   ;			
 CREATE NONCLUSTERED INDEX IDX_CLM_HIST_ETL ON dbo.ETL_CLAIM_HISTORY (  CLAIM_UNIQUEID ASC  , CLM_CHANGEDATE DESC  )   INCLUDE ( ADJUSTER_UNIQUEID , CLAIMANT_UNIQUEID , CLM_ADDRESS1 , CLM_ADDRESS2 , CLM_ADDRESS3 , CLM_CITY , CLM_CLAIMSTATUSCD , CLM_CLOSEDDATE , CLM_COUNTRY , CLM_COUNTY , CLM_DATEOFLOSS , CLM_LATITUDE , CLM_LONGITUDE , CLM_LOSSREPORTEDDATE , CLM_POSTALCODE , CLM_SEQUENCE , CLM_STATE , CLM_SUBSTATUSCD , CONTACT_UNIQUEID , COVERAGE_UNIQUEID , POLICY_UNIQUEID , PRIMARYRISK_UNIQUEID , RISKRELATIONSHIP_UNIQUEID , SECONDARYRISK_UNIQUEID )  ;			
			
			
			
CREATE TABLE [dbo].[STG_CLAIMTRANSACTION](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[CLAIMTRANSACTION_UNIQUEID] [varchar](150) NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[CT_SEQUENCE] [bigint] NOT NULL,		
	[CT_TRANSACTIONFLAG] [varchar](1) NULL,		
	[CT_TRANSACTIONSTATUS] [varchar](50) NULL,		
	[CT_TRANSACTIONDATE] [datetime] NULL,		
	[CT_ACCOUNTINGDATE] [datetime] NOT NULL,		
	[CT_CHANGEDATE] [datetime] NULL,		
	[CT_TYPECODE] [varchar](50) NOT NULL,		
	[CT_SUBTYPECODE] [varchar](50) NULL,		
	[CT_AMOUNT] [decimal](13, 2) NOT NULL,		
	[CT_ORIGCURRENCYCODE] [varchar](5) NULL,		
	[CT_ORIGCURRENCYAMOUNT] [decimal](13, 3) NULL,		
	[ReserveCd] [varchar](255) NULL,		
	[ReserveTypeCd] [varchar](255) NULL,		
	[BookDt] [datetime] NULL,		
	[coverage_uniqueid] [varchar](100) NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[STG_COVERAGE](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[COV_SEQUENCE] [int] NOT NULL,		
	[COVERAGE_UNIQUEID] [varchar](100) NOT NULL,		
	[COV_TRANSACTIONTYPE] [varchar](5) NOT NULL,		
	[COV_TRANSACTIONDATE] [datetime] NOT NULL,		
	[COV_TYPE] [varchar](100) NULL,		
	[COV_CODE] [varchar](50) NOT NULL,		
	[COV_NAME] [varchar](256) NULL,		
	[COV_DESCRIPTION] [varchar](256) NULL,		
	[COV_SUBCODE] [varchar](50) NULL,		
	[COV_SUBCODENAME] [varchar](256) NULL,		
	[COV_SUBCODEDESCRIPTION] [varchar](256) NULL,		
	[COV_EFFECTIVEDATE] [datetime] NOT NULL,		
	[COV_EXPIRATIONDATE] [datetime] NOT NULL,		
	[COV_ASL] [varchar](5) NULL,		
	[COV_SUBLINE] [varchar](5) NULL,		
	[COV_CLASSCODE] [varchar](50) NULL,		
	[COV_CLASSCODENAME] [varchar](50) NULL,		
	[COV_CLASSCODEDESCRIPTION] [varchar](256) NULL,		
	[COV_CLASSSUBCODE] [varchar](50) NULL,		
	[COV_CLASSSUBCODENAME] [varchar](50) NULL,		
	[COV_CLASSSUBCODEDESCRIPTION] [varchar](256) NULL,		
	[COV_DEDUCTIBLE1] [decimal](13, 2) NULL,		
	[COV_DEDUCTIBLE1TYPE] [varchar](50) NULL,		
	[COV_DEDUCTIBLE2] [decimal](13, 2) NULL,		
	[COV_DEDUCTIBLE2TYPE] [varchar](50) NULL,		
	[COV_DEDUCTIBLE3] [decimal](13, 2) NULL,		
	[COV_DEDUCTIBLE3TYPE] [varchar](50) NULL,		
	[COV_LIMIT1] [decimal](13, 2) NULL,		
	[COV_LIMIT1TYPE] [varchar](50) NULL,		
	[COV_LIMIT2] [decimal](13, 2) NULL,		
	[COV_LIMIT2TYPE] [varchar](50) NULL,		
	[COV_LIMIT3] [decimal](13, 2) NULL,		
	[COV_LIMIT3TYPE] [varchar](50) NULL,		
	[COV_LIMIT4] [decimal](13, 2) NULL,		
	[COV_LIMIT4TYPE] [varchar](50) NULL,		
	[COV_LIMIT5] [decimal](13, 2) NULL,		
	[COV_LIMIT5TYPE] [varchar](50) NULL		
) 			
GO			
			
			
			
			
			
			
			
			
			
			
CREATE TABLE [dbo].[TMP_CLAIMENDINRESERVE](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[ClaimNumber] [varchar](8) NULL,		
	[clm_sequence] [bigint] NULL,		
	[BookDt] [datetime] NULL,		
	[currentReserve] [decimal](38, 6) NULL,		
	[priorReserve] [decimal](38, 6) NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[TMP_CLAIMRESERVECLOSEDATES](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[ClaimNumber] [varchar](8) NULL,		
	[ReserveCd] [varchar](15) NULL,		
	[BookDt] [datetime] NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[TMP_CLAIM](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[CLM_SEQUENCE] [bigint] NOT NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[POLICY_UNIQUEID] [int] NULL,		
	[PolicySystemId] [int] NULL,		
	[PRIMARYRISK_UNIQUEID] [varchar](100) NULL,		
	[SECONDARYRISK_UNIQUEID] [varchar](100) NULL,		
	[LineCD] [varchar](255) NULL,		
	[CoverageCd] [varchar](255) NULL,		
	[CoverageItemCd] [varchar](255) NULL,		
	[RiskCd] [varchar](255) NULL,		
	[CLAIMANT_UNIQUEID] [varchar](100) NULL,		
	[ADJUSTER_UNIQUEID] [varchar](100) NULL,		
	[CLM_CLAIMNUMBER] [varchar](50) NOT NULL,		
	[CLM_FEATURENUMBER] [varchar](50) NULL,		
	[CLM_DATEOFLOSS] [datetime] NULL,		
	[CLM_LOSSREPORTEDDATE] [datetime] NULL,		
	[CLM_CLOSEDDATE] [datetime] NULL,		
	[CLM_CLAIMSTATUSCD] [varchar](50) NULL,		
	[CLM_SUBSTATUSCD] [varchar](50) NULL,		
	[ReserveChangeAmt] [decimal](28, 6) NULL,		
	[CLM_COUNTY] [varchar](50) NULL,		
	[CLM_CITY] [varchar](50) NULL,		
	[CLM_STATE] [varchar](50) NULL,		
	[CLM_POSTALCODE] [varchar](20) NULL,		
	[CLM_CHANGEDATE] [datetime] NOT NULL,		
	[CLM_ADDRESS1] [varchar](150) NULL,		
	[CLM_ADDRESS2] [varchar](150) NULL,		
	[AnnualStatementLineCd] [varchar](255) NULL,		
	[SublineCd] [varchar](255) NULL,		
	[COVERAGE_UNIQUEID] [varchar](100) NULL,		
	[CarrierCd] [varchar](255) NULL,		
	[CompanyCd] [varchar](255) NULL,		
	[CarrierGroupCd] [varchar](255) NULL,		
	[ClaimantCd] [varchar](255) NULL,		
	[FeatureCd] [varchar](255) NULL,		
	[FeatureSubCd] [varchar](255) NULL,		
	[FeatureTypeCd] [varchar](255) NULL,		
	[ReserveCd] [varchar](255) NULL,		
	[ReserveTypeCd] [varchar](255) NULL,		
	[AtFaultCd] [varchar](255) NULL,		
	[SourceCd] [varchar](255) NULL,		
	[CategoryCd] [varchar](255) NULL,		
	[LossCauseCd] [varchar](255) NULL,		
	[ReportedTo] [varchar](255) NULL,		
	[ReportedBy] [varchar](255) NULL,		
	[DamageDesc] [varchar](255) NULL,		
	[ShortDesc] [varchar](255) NULL,		
	[Description] [varchar](255) NULL,		
	[Comment] [varchar](255) NULL,		
	[CLM_CATCODE] [varchar](100) NULL,		
	[CLM_CATDESCRIPTION] [varchar](255) NULL,		
	[TotalLossInd] [varchar](255) NULL,		
	[SalvageOwnerRetainedInd] [varchar](255) NULL,		
	[SuitFiledInd] [varchar](10) NULL,		
	[InSIUInd] [varchar](3) NULL,		
	[SubLossCauseCd] [varchar](50) NULL,		
	[LossCauseSeverity] [varchar](10) NULL,		
	[NegligencePct] [int] NULL,		
	[EmergencyService] [varchar](20) NULL,		
	[EmergencyServiceVendor] [varchar](20) NULL,		
	[OccurSite] [varchar](50) NULL,		
	[CLM_OPENEDDATE] [datetime] NULL,		
	[ForRecordOnlyInd] [varchar](255) NULL		
	) 		
GO			
			
CREATE TABLE [dbo].[STG_INSURED]			
(			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[POLICY_UNIQUEID] [int] NOT NULL,		
	[insured_uniqueid] [VARCHAR](100) NOT NULL,		
	[first_name] [VARCHAR](200) NULL,		
	[last_name] [VARCHAR](200) NULL,		
	[commercialname] [VARCHAR](200) NULL,		
	[dob] [date] NULL,		
	[occupation] [VARCHAR](256) NULL,		
	[gender] [VARCHAR](10) NULL,		
	[maritalstatus] [VARCHAR](256) NULL,		
	[address1] [VARCHAR](150) NULL,		
	[address2] [VARCHAR](150) NULL,		
	[county] [VARCHAR](50) NULL,		
	[city] [VARCHAR](50) NULL,		
	[state] [VARCHAR](50) NULL,		
	[postalcode] [VARCHAR](20) NULL,		
	[country] [VARCHAR](50) NULL,		
	[telephone] [VARCHAR](20) NULL,		
	[mobile] [VARCHAR](20) NULL,		
	[email] [VARCHAR](100) NULL,		
	[jobtitle] [VARCHAR](100) NULL,		
	[insurancescore] [VARCHAR](255) NULL,		
	[overriddeninsurancescore] [VARCHAR](255) NULL,		
	[applieddt] [DATE] NULL,		
	[insurancescorevalue] [VARCHAR](5) NULL,		
	[ratepageeffectivedt] [date] NULL,		
	[insscoretiervalueband] [VARCHAR](20) NULL,		
	[financialstabilitytier] [VARCHAR](20) NULL		
)			
GO			
			
			
CREATE TABLE [dbo].[STG_CATASTROPHE](			
	[SOURCE_SYSTEM] [varchar](5) NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[cat_states] [varchar](25) NULL,		
	[cat_lossyear] [smallint] NULL,		
	[cat_startdate] [date] NULL,		
	[cat_enddate] [date] NULL,		
	[cat_name] [varchar](100) NULL,		
	[cat_isoserial] [varchar](5) NULL,		
	[cat_description] [varchar](150) NULL,		
	[cat_code] [varchar](100) NULL,		
	[cat_manuallyadded] [bit]  NULL,		
	[cat_actuarialtype] [varchar](20) NULL,		
	[cat_claimstype] [varchar](20) NULL,		
	[cat_financetype] [varchar](20) NULL,		
	[cat_adddate] [date] NULL,		
	[cat_updatedby] [varchar](50) NULL,		
	[cat_changedate] [date] NULL		
) ;			
			
			
			
			
CREATE TABLE [dbo].[STG_VEHICLE](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[Policy_Uniqueid] [int] NULL,		
	[Risk_UniqueId] [varchar](255) NULL,		
	[VehNumber] [int] NULL,		
	[Risk_Type][varchar](255) NULL,		
	[Vehicle_uniqueid] [varchar](525) NOT NULL,		
	[SPInnVehicle_Id] [varchar](255) NULL,		
	[Status] [varchar](255) NULL,		
	[StateProvCd] [varchar](255) NULL,		
	[County] [varchar](255) NULL,		
	[PostalCode] [varchar](255) NULL,		
	[City] [varchar](255) NULL,		
	[Addr1] [varchar](1023) NULL,		
	[Addr2] [varchar](255) NULL,		
	[GaragAddrFlg] [varchar](3) NULL,		
	[Manufacturer] [varchar](255) NULL,		
	[Model] [varchar](255) NULL,		
	[ModelYr] [varchar](10) NULL,		
	[VehIdentificationNumber] [varchar](255) NULL,		
	[ValidVinInd] [varchar](255) NULL,		
	[VehLicenseNumber] [varchar](255) NULL,		
	[RegistrationStateProvCd] [varchar](255) NULL,		
	[VehBodyTypeCd] [varchar](255) NULL,		
	[PerformanceCd] [varchar](255) NULL,		
	[RestraintCd] [varchar](255) NULL,		
	[AntiBrakingSystemCd] [varchar](255) NULL,		
	[AntiTheftCd] [varchar](255) NULL,		
	[EngineSize] [varchar](255) NULL,		
	[EngineCylinders] [varchar](255) NULL,		
	[EngineHorsePower] [varchar](255) NULL,		
	[EngineType] [varchar](255) NULL,		
	[VehUseCd] [varchar](255) NULL,		
	[GarageTerritory] [int] NULL,		
	[CollisionDed] [varchar](255) NULL,		
	[ComprehensiveDed] [varchar](255) NULL,		
	[StatedAmt] [numeric](28, 6) NULL,		
	[ClassCd] [varchar](255) NULL,		
	[RatingValue] [varchar](255) NULL,		
	[CostNewAmt] [numeric](28, 6) NULL,		
	[EstimatedAnnualDistance] [int] NULL,		
	[EstimatedWorkDistance] [int] NULL,		
	[LeasedVehInd] [varchar](255) NULL,		
	[PurchaseDt] [datetime] NULL,		
	[StatedAmtInd] [varchar](255) NULL,		
	[NewOrUsedInd] [varchar](255) NULL,		
	[CarPoolInd] [varchar](255) NULL,		
	[OdometerReading] [varchar](10) NULL,		
	[WeeksPerMonthDriven] [varchar](255) NULL,		
	[DaylightRunningLightsInd] [varchar](255) NULL,		
	[PassiveSeatBeltInd] [varchar](255) NULL,		
	[DaysPerWeekDriven] [varchar](255) NULL,		
	[UMPDLimit] [varchar](255) NULL,		
	[TowingAndLaborInd] [varchar](255) NULL,		
	[RentalReimbursementInd] [varchar](255) NULL,		
	[LiabilityWaiveInd] [varchar](255) NULL,		
	[RateFeesInd] [varchar](255) NULL,		
	[OptionalEquipmentValue] [int] NULL,		
	[CustomizingEquipmentInd] [varchar](255) NULL,		
	[CustomizingEquipmentDesc] [varchar](255) NULL,		
	[InvalidVinAcknowledgementInd] [varchar](255) NULL,		
	[IgnoreUMPDWCDInd] [varchar](255) NULL,		
	[RecalculateRatingSymbolInd] [varchar](255) NULL,		
	[ProgramTypeCd] [varchar](255) NULL,		
	[CMPRatingValue] [varchar](255) NULL,		
	[COLRatingValue] [varchar](255) NULL,		
	[LiabilityRatingValue] [varchar](255) NULL,		
	[MedPayRatingValue] [varchar](255) NULL,		
	[RACMPRatingValue] [varchar](255) NULL,		
	[RACOLRatingValue] [varchar](255) NULL,		
	[RABIRatingSymbol] [varchar](255) NULL,		
	[RAPDRatingSymbol] [varchar](255) NULL,		
	[RAMedPayRatingSymbol] [varchar](255) NULL,		
	[EstimatedAnnualDistanceOverride] [varchar](5) NULL,		
	[OriginalEstimatedAnnualMiles] [varchar](12) NULL,		
	[ReportedMileageNonSave] [varchar](12) NULL,		
	[Mileage] [varchar](12) NULL,		
	[EstimatedNonCommuteMiles] [varchar](12) NULL,		
	[TitleHistoryIssue] [varchar](3) NULL,		
	[OdometerProblems] [varchar](3) NULL,		
	[Bundle] [varchar](15) NULL,		
	[LoanLeaseGap] [varchar](3) NULL,		
	[EquivalentReplacementCost] [varchar](3) NULL,		
	[OriginalEquipmentManufacturer] [varchar](3) NULL,		
	[OptionalRideshare] [varchar](3) NULL,		
	[MedicalPartsAccessibility] [varchar](4) NULL,		
	[OdometerReadingPrior] [varchar](10) NULL,		
	[ReportedMileageNonSaveDtPrior] [date] NULL,		
	[FullGlassCovInd] [varchar](3) NULL,		
	[Latitude] [decimal](18, 12) NULL,		
	[Longitude] [decimal](18, 12) NULL,		
	[GaragPostalCode] [varchar](255) NULL,		
	[GaragPostalCodeFlg] [varchar](3) NULL,		
	[BoatLengthFeet] [varchar](255) NULL,		
	[MotorHorsePower] [varchar](255) NULL,		
	[Replacementof] [int] NULL,		
	[ReportedMileageNonSaveDt] [date] NULL,		
	[ManufacturerSymbol] [varchar](4) NULL,		
	[ModelSymbol] [varchar](4) NULL,		
	[BodyStyleSymbol] [varchar](4) NULL,		
	[SymbolCode] [varchar](12) NULL,		
	[VerifiedMileageOverride] [varchar](4) NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[STG_DRIVER](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NOT NULL,		
	[SystemId] [int] NOT NULL,		
	[BookDt] [date] NULL,		
	[TransactionEffectiveDt] [date] NULL,		
	[Policy_Uniqueid] [int] NOT NULL,		
	[Driver_UniqueId] [varchar](255) NOT NULL,		
	[SPINNDriver_Id] [varchar](255) NOT NULL,		
	[DriverNumber] [int] NOT NULL,		
	[Status] [varchar](255) NOT NULL,		
	[FirstName] [varchar](255) NULL,		
	[LastName] [varchar](255) NULL,		
	[LicenseNumber] [varchar](255)  NULL,		
	[LicenseDt] [datetime]  NULL,		
	[DriverInfoCd] [varchar](255)  NULL,		
	[DriverTypeCd] [varchar](255)  NULL,		
	[DriverStatusCd] [varchar](255)  NULL,		
	[LicensedStateProvCd] [varchar](255)  NULL,		
	[RelationshipToInsuredCd] [varchar](255)  NULL,		
	[ScholasticDiscountInd] [varchar](255)  NULL,		
	[MVRRequestInd] [varchar](255)  NULL,		
	[MVRStatus] [varchar](255)  NULL,		
	[MVRStatusDt] [datetime]  NULL,		
	[MatureDriverInd] [varchar](255)  NULL,		
	[DriverTrainingInd] [varchar](255)  NULL,		
	[GoodDriverInd] [varchar](255)  NULL,		
	[AccidentPreventionCourseCompletionDt] [datetime]  NULL,		
	[DriverTrainingCompletionDt] [datetime]  NULL,		
	[AccidentPreventionCourseInd] [varchar](255)  NULL,		
	[ScholasticCertificationDt] [datetime]  NULL,		
	[ActiveMilitaryInd] [varchar](255)  NULL,		
	[PermanentLicenseInd] [varchar](255)  NULL,		
	[NewToStateInd] [varchar](255)  NULL,		
	[PersonTypeCd] [varchar](255)  NULL,		
	[GenderCd] [varchar](255)  NULL,		
	[BirthDt] [datetime]  NULL,		
	[MaritalStatusCd] [varchar](255)  NULL,		
	[OccupationClassCd] [varchar](255)  NULL,		
	[PositionTitle] [varchar](255)  NULL,		
	[CurrentResidenceCd] [varchar](255)  NULL,		
	[CivilServantInd] [varchar](255)  NULL,		
	[RetiredInd] [varchar](255)  NULL,		
	[NewTeenExpirationDt] [date]  NULL,		
	[AttachedVehicleRef] [varchar](255)  NULL,		
	[VIOL_PointsChargedTerm] [int]  NULL,		
	[ACCI_PointsChargedTerm] [int]  NULL,		
	[SUSP_PointsChargedTerm] [int]  NULL,		
	[Other_PointsChargedTerm] [int]  NULL,		
	[SR22FeeInd] [varchar](4) NULL,		
	[MatureCertificationDt] [datetime] NULL,		
	[GoodDriverPoints_chargedterm] [int] NULL,		
	[AgeFirstLicensed] [varchar](3) NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[STG_RESERVESTATUS](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NOT NULL,		
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,		
	[ReserveCd] [varchar](255) NULL,		
	[ReserveStatus] [varchar](255) NULL,		
	[TransactionNumber] [int] NULL,		
	[BookDt] [date] NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[STG_CLAIMANT](			
	[source_system] [varchar](100) NOT NULL,		
	[loaddate] [datetime] NOT NULL,		
	[claimant_uniqueID] [varchar](100) NOT NULL,		
	[claimant_type] [varchar](50) NULL,		
	[claimant_number] [varchar](50) NULL,		
	[name] [varchar](200) NULL,		
	[DOB] [date] NULL,		
	[gender] [varchar](10) NULL,		
	[maritalStatus] [varchar](256) NULL,		
	[address1] [varchar](150) NULL,		
	[address2] [varchar](150) NULL,		
	[city] [varchar](50) NULL,		
	[state] [varchar](50) NULL,		
	[postalCode] [varchar](20) NULL,		
	[telephone] [varchar](20) NULL,		
	[fax] [varchar](20) NULL,		
	[email] [varchar](100) NULL,		
	[WaterMitigationInd] [varchar](3) NULL,		
	[PublicAdjusterInd] [varchar](3) NULL,		
	[attorneyrepind] [varchar](3) NULL,		
	[injuryinvolvedind] [varchar](3) NULL,		
	[injuredpartyrelationshipcd] [varchar](255) NULL,		
	[injurydesc] [varchar](255) NULL,		
	[majortraumacd] [varchar](256) NULL,		
	[fatalityind] [varchar](256) NULL,		
	[suitfiledind] [varchar](256) NULL,		
	[suitdt] [date] NULL,		
	[suitstatuscd]  [varchar](256) NULL,		
	[suitcloseddt] [date] NULL,		
	[suitsettlementcd] [varchar](256) NULL,		
	[docketnumber] [varchar](256) NULL,		
	[claimsettleddt] [date] NULL,		
	[litigationcaption] [varchar](256) NULL,		
	[phoneappind] [varchar](3) NULL,		
	[phoneapplanguage] [varchar](15) NULL,		
	[phoneappphoneinfoid] [varchar](29) NULL,		
	[casefacts] [varchar](256) NULL,		
	[caseanalysis] [varchar](256) NULL,		
	[suitreasoncd] [varchar](32) NULL,		
	[courttype] [varchar](15) NULL,		
	[courtstate] [varchar](2) NULL,		
	[courtcounty] [varchar](75) NULL,		
	[suitserveddate] [date] NULL,		
	[suitmediationdate] [date] NULL,		
	[suitarbitrationdate] [date] NULL,		
	[suitconferencedate] [date] NULL,		
	[suitmotionjudgedate] [date] NULL,		
	[suitdismissaldate] [date] NULL,		
	[suittrialdate] [date] NULL,		
	[suitservedind] [varchar](3) NULL,		
	[suitmediationind] [varchar](3) NULL,		
	[suitarbitrationind] [varchar](3) NULL,		
	[suitconferenceind] [varchar](3) NULL,		
	[suitmotionjudgeind] [varchar](3) NULL,		
	[suitdismissalind] [varchar](3) NULL,		
	[suittrialind] [varchar](3) NULL,		
	[healthinsuranceclaimnumber] [varchar](50) NULL,		
	[injurycausecd] [varchar](10) NULL,		
	[exhaustdt] [date] NULL,		
	[nofaultinsurancelimit] [int] NULL,		
	[injurycausetypecd] [varchar](10) NULL,		
	[productliabilitycd] [varchar](20) NULL,		
	[notsendcovcms] [varchar](3) NULL,		
	[representativetypecd] [varchar](20) NULL,		
	[ongoingresponsibilitymedicalsind] [varchar](3) NULL,		
	[deletefromcms] [varchar](3) NULL,		
	[stateofvenue] [varchar](2) NULL,		
	[ormind] [varchar](3) NULL,		
	[ongoingresponsibilitymedicalsterminationdt] [date] NULL,		
	[medicarebeneficiarycd] [varchar](20) NULL,		
	[AssociateTypeCd] [varchar](255) NULL,		
	[AssociateProviderRef] [int] NULL		
) 			
			
GO			
			
			
CREATE TABLE [dbo].[STG_ADJUSTER](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[ADJUSTER_UNIQUEID] [varchar](100) NULL,		
	[ADJUSTER_TYPE] [varchar](50) NULL,		
	[ADJUSTER_NUMBER] [varchar](50) NULL,		
	[NAME] [varchar](200) NOT NULL,		
	[ADDRESS1] [varchar](150) NULL,		
	[ADDRESS2] [varchar](150) NULL,		
	[CITY] [varchar](50) NULL,		
	[STATE] [varchar](50) NULL,		
	[POSTALCODE] [varchar](20) NULL,		
	[TELEPHONE] [varchar](20) NULL,		
	[FAX] [varchar](20) NULL,		
	[EMAIL] [varchar](100) NULL,		
	[DEPARTMENT] [varchar](100) NULL,		
	[UserManagementGroupCd] [varchar](25) NULL,		
	[Supervisor] [varchar](255) NULL		
) 			
GO			
			
			
CREATE TABLE [dbo].[STG_PRODUCER](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[producer_uniqueid] [varchar](20) NULL,		
	[producer_number] [varchar](255) NULL,		
	[producer_name] [varchar](255) NULL,		
	[LicenseNo] [varchar](255) NULL,		
	[agency_type] [varchar](255) NULL,		
	[address] [varchar](510) NULL,		
	[city] [varchar](255) NULL,		
	[state_cd] [varchar](255) NULL,		
	[zip] [varchar](255) NULL,		
	[phone] [varchar](255) NULL,		
	[fax] [varchar](255) NULL,		
	[email] [varchar](255) NULL,		
	[agency_group] [varchar](255) NULL,		
	[national_name] [varchar](128) NULL,		
	[national_code] [varchar](20) NULL,		
	[territory] [varchar](255) NULL,		
	[territory_manager] [varchar](20) NULL,		
	[DBA] [varchar](255) NULL,		
	[producer_status] [varchar](255) NULL,		
	[commission_master] [varchar](20) NULL,		
	[reporting_master] [varchar](20) NULL,		
	[pn_appointment_date] [date] NULL,		
	[Profit_sharing_master] [varchar](20) NULL,		
	[producer_master] [varchar](20) NULL,		
	[Recognition_tier] [varchar](255) NULL,		
	[RMAddress] [varchar](510) NULL,		
	[RMCity] [varchar](255) NULL,		
	[RMState] [varchar](255) NULL,		
	[RMZip] [varchar](255) NULL,		
	[new_business_term_date] [date] NULL,		
	[ChangeDate] [datetime] NULL		
)			
GO			
			
CREATE TABLE [dbo].[STG_CUSTOMER](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[Customer_UniqueId] int  NOT NULL,		
	[Status] [varchar](255) NULL,		
	[EntityTypeCd] [varchar](255) NULL,		
	[First_Name] [varchar](255) NULL,		
	[Last_Name] [varchar](255) NULL,		
	[CommercialName] [varchar](255) NULL,		
	[DOB] [datetime] NULL,		
	[gender] [varchar](255) NULL,		
	[maritalStatus] [varchar](255) NULL,		
	[address1] [varchar](255) NULL,		
	[address2] [varchar](255) NULL,		
	[county] [varchar](255) NULL,		
	[city] [varchar](255) NULL,		
	[state] [varchar](255) NULL,		
	[PostalCode] [varchar](255) NULL,		
	[phone] [varchar](255) NULL,		
	[mobile] [varchar](255) NULL,		
	[email] [varchar](255) NULL,		
	[PreferredDeliveryMethod] [varchar](255) NULL,		
	[PortalInvitationSentDt] [datetime] NULL,		
	[PaymentReminderInd] [varchar](128) NULL,		
	[ChangeDate] [datetime] NULL		
) 			
GO			
			
			
			
CREATE TABLE [dbo].[stg_user](			
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,		
	[LOADDATE] [datetime] NULL,		
	[SystemId] [int] NULL,		
	[USER_UNIQUEID] [varchar](255) NULL,		
	[LoginId] [varchar](255) NULL,		
	[TypeCd] [varchar](255) NULL,		
	[Supervisor] [varchar](255) NULL,		
	[LastName] [varchar](255) NULL,		
	[FirstName] [varchar](255) NULL,		
	[TerminatedDt] [datetime2](0) NULL,		
	[DepartmentCd] [varchar](255) NULL,		
	[UserManagementGroupCd] [varchar](250) NULL		
) 			
GO			
			
			
CREATE TABLE dbo.STG_RISK_COVERAGE(			
SOURCE_SYSTEM varchar(100) NOT NULL,			
LOADDATE datetime NULL,			
SystemId int NULL,			
[BookDt] [date] NULL,			
[TransactionEffectiveDt] [date] NULL,			
POLICY_UNIQUEID int NOT NULL,			
RISK_UNIQUEID varchar(100) NOT NULL,			
CovA_Limit1	[varchar](255) NULL,		
CovA_Limit2	[varchar](255) NULL,		
CovA_Deductible1	[decimal](13, 2) NULL,		
CovA_Deductible2	[decimal](13, 2) NULL,		
CovA_FullTermAmt	[decimal](13, 2) NULL,		
CovB_Limit1	[varchar](255) NULL,		
CovB_Limit2	[varchar](255) NULL,		
CovB_Deductible1	[decimal](13, 2) NULL,		
CovB_Deductible2	[decimal](13, 2) NULL,		
CovB_FullTermAmt	[decimal](13, 2) NULL,		
CovC_Limit1	[varchar](255) NULL,		
CovC_Limit2	[varchar](255) NULL,		
CovC_Deductible1	[decimal](13, 2) NULL,		
CovC_Deductible2	[decimal](13, 2) NULL,		
CovC_FullTermAmt	[decimal](13, 2) NULL,		
CovD_Limit1	[varchar](255) NULL,		
CovD_Limit2	[varchar](255) NULL,		
CovD_Deductible1	[decimal](13, 2) NULL,		
CovD_Deductible2	[decimal](13, 2) NULL,		
CovD_FullTermAmt	[decimal](13, 2) NULL,		
CovE_Limit1	[varchar](255) NULL,		
CovE_Limit2	[varchar](255) NULL,		
CovE_Deductible1	[decimal](13, 2) NULL,		
CovE_Deductible2	[decimal](13, 2) NULL,		
CovE_FullTermAmt	[decimal](13, 2) NULL,		
BEDBUG_Limit1	[varchar](255) NULL,		
BEDBUG_Limit2	[varchar](255) NULL,		
BEDBUG_Deductible1	[decimal](13, 2) NULL,		
BEDBUG_Deductible2	[decimal](13, 2) NULL,		
BEDBUG_FullTermAmt	[decimal](13, 2) NULL,		
BOLAW_Limit1	[varchar](255) NULL,		
BOLAW_Limit2	[varchar](255) NULL,		
BOLAW_Deductible1	[decimal](13, 2) NULL,		
BOLAW_Deductible2	[decimal](13, 2) NULL,		
BOLAW_FullTermAmt	[decimal](13, 2) NULL,		
COC_Limit1	[varchar](255) NULL,		
COC_Limit2	[varchar](255) NULL,		
COC_Deductible1	[decimal](13, 2) NULL,		
COC_Deductible2	[decimal](13, 2) NULL,		
COC_FullTermAmt	[decimal](13, 2) NULL,		
EQPBK_Limit1	[varchar](255) NULL,		
EQPBK_Limit2	[varchar](255) NULL,		
EQPBK_Deductible1	[decimal](13, 2) NULL,		
EQPBK_Deductible2	[decimal](13, 2) NULL,		
EQPBK_FullTermAmt	[decimal](13, 2) NULL,		
FRAUD_Limit1	[varchar](255) NULL,		
FRAUD_Limit2	[varchar](255) NULL,		
FRAUD_Deductible1	[decimal](13, 2) NULL,		
FRAUD_Deductible2	[decimal](13, 2) NULL,		
FRAUD_FullTermAmt	[decimal](13, 2) NULL,		
H051ST0_Limit1	[varchar](255) NULL,		
H051ST0_Limit2	[varchar](255) NULL,		
H051ST0_Deductible1	[decimal](13, 2) NULL,		
H051ST0_Deductible2	[decimal](13, 2) NULL,		
H051ST0_FullTermAmt	[decimal](13, 2) NULL,		
HO5_Limit1	[varchar](255) NULL,		
HO5_Limit2	[varchar](255) NULL,		
HO5_Deductible1	[decimal](13, 2) NULL,		
HO5_Deductible2	[decimal](13, 2) NULL,		
HO5_FullTermAmt	[decimal](13, 2) NULL,		
INCB_Limit1	[varchar](255) NULL,		
INCB_Limit2	[varchar](255) NULL,		
INCB_Deductible1	[decimal](13, 2) NULL,		
INCB_Deductible2	[decimal](13, 2) NULL,		
INCB_FullTermAmt	[decimal](13, 2) NULL,		
INCC_Limit1	[varchar](255) NULL,		
INCC_Limit2	[varchar](255) NULL,		
INCC_Deductible1	[decimal](13, 2) NULL,		
INCC_Deductible2	[decimal](13, 2) NULL,		
INCC_FullTermAmt	[decimal](13, 2) NULL,		
LAC_Limit1	[varchar](255) NULL,		
LAC_Limit2	[varchar](255) NULL,		
LAC_Deductible1	[decimal](13, 2) NULL,		
LAC_Deductible2	[decimal](13, 2) NULL,		
LAC_FullTermAmt	[decimal](13, 2) NULL,		
MEDPAY_Limit1	[varchar](255) NULL,		
MEDPAY_Limit2	[varchar](255) NULL,		
MEDPAY_Deductible1	[decimal](13, 2) NULL,		
MEDPAY_Deductible2	[decimal](13, 2) NULL,		
MEDPAY_FullTermAmt	[decimal](13, 2) NULL,		
OccupationDiscount_Limit1	[varchar](255) NULL,		
OccupationDiscount_Limit2	[varchar](255) NULL,		
OccupationDiscount_Deductible1	[decimal](13, 2) NULL,		
OccupationDiscount_Deductible2	[decimal](13, 2) NULL,		
OccupationDiscount_FullTermAmt	[decimal](13, 2) NULL,		
OLT_Limit1	[varchar](255) NULL,		
OLT_Limit2	[varchar](255) NULL,		
OLT_Deductible1	[decimal](13, 2) NULL,		
OLT_Deductible2	[decimal](13, 2) NULL,		
OLT_FullTermAmt	[decimal](13, 2) NULL,		
PIHOM_Limit1	[varchar](255) NULL,		
PIHOM_Limit2	[varchar](255) NULL,		
PIHOM_Deductible1	[decimal](13, 2) NULL,		
PIHOM_Deductible2	[decimal](13, 2) NULL,		
PIHOM_FullTermAmt	[decimal](13, 2) NULL,		
PPREP_Limit1	[varchar](255) NULL,		
PPREP_Limit2	[varchar](255) NULL,		
PPREP_Deductible1	[decimal](13, 2) NULL,		
PPREP_Deductible2	[decimal](13, 2) NULL,		
PPREP_FullTermAmt	[decimal](13, 2) NULL,		
PRTDVC_Limit1	[varchar](255) NULL,		
PRTDVC_Limit2	[varchar](255) NULL,		
PRTDVC_Deductible1	[decimal](13, 2) NULL,		
PRTDVC_Deductible2	[decimal](13, 2) NULL,		
PRTDVC_FullTermAmt	[decimal](13, 2) NULL,		
SeniorDiscount_Limit1	[varchar](255) NULL,		
SeniorDiscount_Limit2	[varchar](255) NULL,		
SeniorDiscount_Deductible1	[decimal](13, 2) NULL,		
SeniorDiscount_Deductible2	[decimal](13, 2) NULL,		
SeniorDiscount_FullTermAmt	[decimal](13, 2) NULL,		
SEWER_Limit1	[varchar](255) NULL,		
SEWER_Limit2	[varchar](255) NULL,		
SEWER_Deductible1	[decimal](13, 2) NULL,		
SEWER_Deductible2	[decimal](13, 2) NULL,		
SEWER_FullTermAmt	[decimal](13, 2) NULL,		
SPP_Limit1	[varchar](255) NULL,		
SPP_Limit2	[varchar](255) NULL,		
SPP_Deductible1	[decimal](13, 2) NULL,		
SPP_Deductible2	[decimal](13, 2) NULL,		
SPP_FullTermAmt	[decimal](13, 2) NULL,		
SRORP_Limit1	[varchar](255) NULL,		
SRORP_Limit2	[varchar](255) NULL,		
SRORP_Deductible1	[decimal](13, 2) NULL,		
SRORP_Deductible2	[decimal](13, 2) NULL,		
SRORP_FullTermAmt	[decimal](13, 2) NULL,		
THEFA_Limit1	[varchar](255) NULL,		
THEFA_Limit2	[varchar](255) NULL,		
THEFA_Deductible1	[decimal](13, 2) NULL,		
THEFA_Deductible2	[decimal](13, 2) NULL,		
THEFA_FullTermAmt	[decimal](13, 2) NULL,		
UTLDB_Limit1	[varchar](255) NULL,		
UTLDB_Limit2	[varchar](255) NULL,		
UTLDB_Deductible1	[decimal](13, 2) NULL,		
UTLDB_Deductible2	[decimal](13, 2) NULL,		
UTLDB_FullTermAmt	[decimal](13, 2) NULL,		
WCINC_Limit1	[varchar](255) NULL,		
WCINC_Limit2	[varchar](255) NULL,		
WCINC_Deductible1	[decimal](13, 2) NULL,		
WCINC_Deductible2	[decimal](13, 2) NULL,		
WCINC_FullTermAmt	[decimal](13, 2) NULL,		
WCINC_Limit1_o	[varchar](255) NULL,		
WCINC_Limit2_o	[varchar](255) NULL,		
WCINC_Deductible1_o	[decimal](13, 2) NULL,		
WCINC_Deductible2_o	[decimal](13, 2) NULL,		
WCINC_FullTermAmt_o	[decimal](13, 2) NULL		
) 			
GO			

CREATE CLUSTERED INDEX [ETL_IDX_STG_VEHICLE] ON [dbo].[STG_VEHICLE]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_USER] ON [dbo].[STG_USER]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_RISK_COVERAGE] ON [dbo].[STG_RISK_COVERAGE]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_RISK] ON [dbo].[STG_RISK]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_RESERVESTATUS] ON [dbo].[STG_RESERVESTATUS]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_PRODUCT] ON [dbo].[STG_PRODUCT]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_PRODUCER] ON [dbo].[STG_PRODUCER]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_POLICYTRANSACTIONEXTENSION] ON [dbo].[STG_POLICYTRANSACTIONEXTENSION]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_POLICYTRANSACTION] ON [dbo].[STG_POLICYTRANSACTION]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_POLICY] ON [dbo].[STG_POLICY]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_INSURED] ON [dbo].[STG_INSURED]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_DRIVER] ON [dbo].[STG_DRIVER]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_CUSTOMER] ON [dbo].[STG_CUSTOMER]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_COVERAGE] ON [dbo].[STG_COVERAGE]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_CLAIMTRANSACTION] ON [dbo].[STG_CLAIMTRANSACTION]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_CLAIMANT] ON [dbo].[STG_CLAIMANT]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_CLAIM] ON [dbo].[STG_CLAIM]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_CATASTROPHE] ON [dbo].[STG_CATASTROPHE]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_BUILDING] ON [dbo].[STG_BUILDING]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
CREATE CLUSTERED INDEX [ETL_IDX_STG_ADJUSTER] ON [dbo].[STG_ADJUSTER]	
(	
	[LOADDATE] ASC,
	[SOURCE_SYSTEM] ASC
)	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE NONCLUSTERED INDEX [IDX_ETL_CLAIM_CLOSEDDATE_ETL] ON [dbo].[ETL_CLAIM_CLOSEDDATE]	
(	
	[ClaimNumber] ASC,
	[BookDt] DESC
)	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE NONCLUSTERED INDEX [IDX_CLM_HIST_ETL] ON [dbo].[ETL_CLAIM_HISTORY]	
(	
	[CLAIM_UNIQUEID] ASC,
	[CLM_CHANGEDATE] DESC
)	
INCLUDE([CLM_SEQUENCE],[POLICY_UNIQUEID],[CLAIMANT_UNIQUEID],[CLM_DATEOFLOSS],[CLM_CLOSEDDATE],[CLM_LOSSREPORTEDDATE],[CLM_CLAIMSTATUSCD],[CLM_SUBSTATUSCD],[PRIMARYRISK_UNIQUEID],[SECONDARYRISK_UNIQUEID],[COVERAGE_UNIQUEID],[ADJUSTER_UNIQUEID],[CLM_ADDRESS1],[CLM_ADDRESS2],[CLM_COUNTY],[CLM_CITY],[CLM_STATE],[CLM_POSTALCODE]) 	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE CLUSTERED INDEX [IDX_CLM_HIST_ETL2] ON [dbo].[ETL_CLAIM_HISTORY]	
(	
	[CLM_CLAIMNUMBER] ASC,
	[CLM_CLAIMSTATUSCD] ASC,
	[CLM_SUBSTATUSCD] ASC,
	[CLM_CHANGEDATE] ASC
)	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE NONCLUSTERED INDEX [IDX_COV_HIST_ETL] ON [dbo].[ETL_COVERAGE_HISTORY]	
(	
	[COVERAGE_UNIQUEID] ASC,
	[COV_TRANSACTIONDATE] DESC,
	[COV_TRANSACTIONTYPE] ASC
)	
INCLUDE([COV_SEQUENCE],[COV_CODE],[COV_SUBCODE],[COV_EFFECTIVEDATE],[COV_EXPIRATIONDATE],[COV_ASL],[COV_SUBLINE],[COV_CLASSCODE],[COV_DEDUCTIBLE1],[COV_DEDUCTIBLE2],[COV_LIMIT1],[COV_LIMIT1TYPE],[COV_LIMIT2],[COV_LIMIT2TYPE])	
GO	
	
CREATE CLUSTERED INDEX [IDX_BOOKDATE] ON [dbo].[ETL_LOG]	
(	
	[bookDate] ASC
)	
GO	
	
	
CREATE INDEX [IDX_LOADDATE] ON [dbo].[ETL_LOG]	
(	
	[loadDate] ASC
)	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE NONCLUSTERED INDEX [IDX_POL_HIST_ETL2] ON [dbo].[ETL_POLICY_HISTORY]	
(	
	[POLICY_UNIQUEID] ASC
)	
INCLUDE([PRODUCT_UNIQUEID],[COMPANY_UNIQUEID],[PRODUCER_UNIQUEID],[FIRSTINSURED_UNIQUEID],[POLICYNEWORRENEWAL])	
GO	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
/*CREATE NONCLUSTERED INDEX [IPTRNTYPETL] ON [dbo].[ETL_POLICYTRANSACTIONTYPE]	
(	
	[PTRANS_CODE] ASC,
	[PTRANS_SUBCODE] ASC
)	
GO*/	
	
USE [FSBI_STG_SPINN]	
GO	
	
SET ANSI_PADDING ON	
GO	
	
	
CREATE NONCLUSTERED INDEX [IDX_RSKLOCHIST_ETL] ON [dbo].[ETL_RISK_HISTORY]	
(	
	[RISK_UNIQUEID] ASC
)	
INCLUDE([RSK_ADDRESS1],[RSK_ADDRESS2],[RSK_CITY],[RSK_COUNTY],[RSK_LATITUDE],[RSK_LONGITUDE],[RSK_POSTALCODE],[RSK_STATE])	
GO	
