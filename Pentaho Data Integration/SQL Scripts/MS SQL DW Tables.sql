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



USE [DW_MGA]						
GO						
						
						
CREATE VIEW [dbo].[VDIM_COMPANY]  AS  						
SELECT  						
   COMPANY_ID AS COMPANY_ID,   						
   COMPANY_UNIQUEID AS COMP_UNIQUEID,  						
   SOURCE_SYSTEM AS SOURCE_SYSTEM  						
FROM  						
   DIM_COMPANY  						
						
						
GO						
						
						
CREATE VIEW [dbo].[LKUP_COMPANY] AS						
SELECT						
 COMP_UNIQUEID						
,COMPANY_ID						
FROM VDIM_COMPANY						
						
						
GO						
						
						
CREATE VIEW [dbo].[VDIM_ADJUSTER] AS						
SELECT						
   ADJUSTER_ID,				  		
   ADJUSTER_UNIQUEID AS ADJ_UNIQUEID,						
   SOURCE_SYSTEM AS SOURCE_SYSTEM						
FROM						
   DIM_ADJUSTER						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_CLAIM](						
	[CLAIM_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
	[POLICY_ID] [int] NULL,					
	[PolicySystemId] [int] DEFAULT 0 NULL,					
	[CLAIMNUMBER] [varchar](50) NOT NULL,					
	[FEATURENUMBER] [varchar](50) NULL,					
	[DATEOFLOSS] [datetime] NULL,					
	[LOSSREPORTEDDATE] [datetime] NULL,					
	[RiskCd] [varchar](255) NULL,					
	[AnnualStatementLineCd] [varchar](255) NULL,					
	[SublineCd] [varchar](255) NULL,					
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
	[CATCODE] [varchar](100) NULL,					
	[CATDESCRIPTION] [varchar](255) NULL,					
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
	[ForRecordOnlyInd] [varchar](255) NULL,					
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL,					
 CONSTRAINT [PK_DIM_CLAIM] PRIMARY KEY CLUSTERED 						
(						
	[CLAIM_ID] ASC					
)						
) 						
GO						
						
						
						
						
						
						
						
CREATE VIEW [dbo].[LKUP_CLAIM] AS						
SELECT						
 CLAIM_UNIQUEID CLM_UNIQUEID						
,CLAIM_ID						
,CLAIMNUMBER CLM_CLAIMNUMBER						
FROM DIM_CLAIM						
						
						
						
						
GO						
						
						
CREATE TABLE [dbo].[FACT_CLAIMTRANSACTION](						
	[CLAIMTRANSACTION_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[TRANSACTIONDATE_ID] [int] NOT NULL,					
	[ACCOUNTINGDATE_ID] [int] NOT NULL,					
	[CLAIMTRANSACTIONTYPE_ID] [int] NOT NULL,					
	[ADJUSTER_ID] [int] NOT NULL,					
	[CLAIMANT_ID] [int] NOT NULL,					
	[PRODUCER_ID] [int] NOT NULL,					
	[PRODUCT_ID] [int] NOT NULL,					
	[COMPANY_ID] [int] NOT NULL,					
	[FIRSTINSURED_ID] [int] NOT NULL,					
	[CLAIM_ID] [int] NOT NULL,					
	[CLAIMSTATUS_ID] [int] NOT NULL,					
	[CLAIMLOSSADDRESS_ID] [int] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[PolicySystemId] [int] DEFAULT 0 NOT NULL,					
	[COVERAGE_ID] [int] NOT NULL,					
	[LIMIT_ID] [int] NOT NULL,					
	[DEDUCTIBLE_ID] [int] NOT NULL,					
	[COVERAGEEFFECTIVEDATE_ID] [int] NOT NULL,					
	[COVERAGEEXPIRATIONDATE_ID] [int] NOT NULL,					
	[OPENEDDATE_ID] [int] NOT NULL,					
	[CLOSEDDATE_ID] [int] NOT NULL,					
	[DATEREPORTED_ID] [int] NOT NULL,					
	[DATEOFLOSS_ID] [int] NOT NULL,					
	[PRIMARYRISK_ID] [int] NOT NULL,					
	[Building_Id] [int] DEFAULT 0 NOT NULL,					
	[Vehicle_Id] [int] DEFAULT 0 NOT NULL,					
	[Driver_Id] [int] DEFAULT 0 NOT NULL,					
	[PRIMARYRISKADDRESS_ID] [int] NOT NULL,					
	[CLASS_ID] [int] NOT NULL,					
	[CATASTROPHE_ID] [int] NOT NULL,					
	[RESERVESTATUS_ID] [int] NOT NULL,					
	[CLAIMNUMBER] [varchar](50) NOT NULL,					
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[COVERAGE_UNIQUEID] [varchar](100) NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,					
	[CLAIMTRANSACTION_UNIQUEID] [varchar](100) NOT NULL,					
	[TRANSACTIONSEQUENCE] [bigint] NOT NULL,					
	[AMOUNT] [decimal](13, 2) NOT NULL,					
	[AUDIT_ID] [int] DEFAULT 0 NOT NULL,					
 CONSTRAINT [PK_FACT_CLAIMTRANS] PRIMARY KEY CLUSTERED 						
(						
	[CLAIMTRANSACTION_ID] ASC					
)						
) 						
GO						
						
						
						
						
						
CREATE VIEW [dbo].[VDIM_CLAIMANT] AS						
SELECT						
  CLAIMANT_ID,						
   VALID_FROMDATE AS CLMNT_VALID_FROMDATE,						
   VALID_TODATE AS CLMNT_VALID_TODATE,						
   CLAIMANT_UNIQUEID AS CLMNT_UNIQUEID,						
   SOURCE_SYSTEM AS SOURCE_SYSTEM						
FROM						
   DIM_CLAIMANT						
						
GO						
						
						
						
						
						
CREATE TABLE [dbo].[DIM_INSURED]						
(						
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
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
	[fax] [VARCHAR](20) NULL,					
	[mobile] [VARCHAR](20) NULL,					
	[email] [VARCHAR](100) NULL,					
	[jobtitle] [VARCHAR](100) NULL,					
	[insurancescore] [VARCHAR](255) NULL,					
	[overriddeninsurancescore] [VARCHAR](255) NULL,					
	[applieddt] [DATE] NULL,					
	[insurancescorevalue] [VARCHAR](5) NULL,					
	[ratepageeffectivedt] [date] NULL,					
	[insscoretiervalueband] [VARCHAR](20) NULL,					
	[financialstabilitytier] [VARCHAR](20) NULL,					
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL,					
 CONSTRAINT [PK_DIM_INSURED] PRIMARY KEY CLUSTERED 						
(						
	[POLICY_ID],[SystemId] ASC					
)						
)						
GO						
						
CREATE VIEW [dbo].[VDIM_FIRSTINSURED] AS						
SELECT						
   SystemId AS FIRSTINSURED_ID,						
   INSURED_UNIQUEID,						
   VALID_FROMDATE AS FINSD_VALID_FROMDATE,						
   VALID_TODATE AS FINSD_VALID_TODATE,						
   SOURCE_SYSTEM AS SOURCE_SYSTEM						
FROM						
   DIM_INSURED						
						
GO						
						
						
CREATE TABLE [dbo].[DIM_CLAIMTRANSACTIONTYPE](						
	[CLAIMTRANSACTIONTYPE_ID] [int] NOT NULL,					
	[CTRANS_CODE] [varchar](50) NULL,					
	[CTRANS_NAME] [varchar](100) NULL,					
	[CTRANS_DESCRIPTION] [varchar](256) NULL,					
	[CTRANS_SUBCODE] [varchar](50) NULL,					
	[CTRANS_SUBNAME] [varchar](100) NULL,					
	[CTRANS_SUBDESCRIPTION] [varchar](256) NULL,					
	[CTRANS_LOSSPAID] [varchar](1) NULL,					
	[CTRANS_LOSSRESERVE] [varchar](1) NULL,					
	[CTRANS_INITLOSSRESERVE] [varchar](1) NULL,					
	[CTRANS_ALAEPAID] [varchar](1) NULL,					
	[CTRANS_ALAERESERVE] [varchar](1) NULL,					
	[CTRANS_ULAEPAID] [varchar](1) NULL,					
	[CTRANS_ULAERESERVE] [varchar](1) NULL,					
	[CTRANS_SUBRORECEIVED] [varchar](1) NULL,					
	[CTRANS_SUBROPAID] [varchar](1) NULL,					
	[CTRANS_SUBRORESERVE] [varchar](1) NULL,					
	[CTRANS_SALVAGERECEIVED] [varchar](1) NULL,					
	[CTRANS_SALVAGERESERVE] [varchar](1) NULL,					
	[CTRANS_DEDUCTRECOVERYRECVD] [varchar](1) NULL,					
	[CTRANS_DEDUCTRECOVERYRSRV] [varchar](1) NULL,					
	[CTRANS_LOSSPAID_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_LOSSRESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_ALAEPAID_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_ALAERESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_ULAEPAID_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_ULAERESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_SUBRORECEIVED_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_SUBRORESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_DCCPAID] [varchar](1) NULL,					
	[CTRANS_DCCRESERVE] [varchar](1) NULL,					
	[CTRANS_DCCPAID_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_DCCRESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_AAOPAID] [varchar](1) NULL,					
	[CTRANS_AAORESERVE] [varchar](1) NULL,					
	[CTRANS_AAOPAID_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_AAORESERVE_HISTORICAL] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY17] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY18] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY19] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY20] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY21] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY22] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY23] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY24] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY25] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY26] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY27] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY28] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY29] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY30] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY31] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY32] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY33] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY34] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY35] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY36] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY37] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY38] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY39] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY40] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY41] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY42] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY43] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY44] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY45] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY46] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY47] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY48] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY49] [varchar](1) NULL,					
	[CTRANS_USERDEFINEDSUMMARY50] [varchar](1) NULL,					
	[LOADDATE] [datetime] NULL,					
 CONSTRAINT [PK_DIM_CLAIMTRANSACTIONTYPE] PRIMARY KEY NONCLUSTERED 						
(						
	[CLAIMTRANSACTIONTYPE_ID] ASC					
)						
) 						
GO						
						
						
						
CREATE TABLE [dbo].[FACT_POLICY](						
	[FACTPOLICY_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[MONTH_ID] [int] NOT NULL,					
	[PRODUCER_ID] [int] NOT NULL,					
	[PRODUCT_ID] [int] NOT NULL,					
	[COMPANY_ID] [int] NOT NULL,					
	[FIRSTINSURED_ID] [int] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] Default 0 NOT NULL,					
	[POLICYSTATUS_ID] [int] NOT NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,					
	[POLICYNEWISSUEDIND] [int] NOT NULL,					
	[POLICYCANCELLEDISSUEDIND] [int] NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[COMM_AMT] [decimal](13, 2) NOT NULL,					
	[COMM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[COMM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[UNEARNED_PREM] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[FEES_AMT] [decimal](13, 2) NOT NULL,					
	[FEES_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[FEES_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[AUDIT_ID] [int] DEFAULT 0 NOT NULL,					
 CONSTRAINT [PK_FACT_POLICY] PRIMARY KEY CLUSTERED 						
(						
	[FACTPOLICY_ID] ASC					
)						
) 						
GO						
						
						
						
CREATE TABLE [dbo].[DIM_COVEREDRISK](						
	[COVEREDRISK_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[RISK_UNIQUEID] [varchar](100) NOT NULL,					
	[deleted_indicator] [int] NOT NULL,					
	[risk_number] [varchar](10) NOT NULL,					
	[risk_type] [varchar](255) NOT NULL,					
	[COVEREDRISK_UNIQUEID] [varchar](255) NOT NULL,					
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL,					
 CONSTRAINT [PK_DIM_RISK] PRIMARY KEY CLUSTERED 						
(						
	[COVEREDRISK_ID] ASC					
)						
) 						
						
						
CREATE TABLE [dbo].[FACT_POLICYCOVERAGE](						
	[FACTPOLICYCOVERAGE_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[MONTH_ID] [int] NOT NULL,					
	[PRODUCER_ID] [int] NOT NULL,					
	[PRODUCT_ID] [int] NOT NULL,					
	[COMPANY_ID] [int] NOT NULL,					
	[FIRSTINSURED_ID] [int] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[POLICYSTATUS_ID] [int] NOT NULL,					
	[COVERAGE_ID] [int] NOT NULL,					
	[COVERAGEEFFECTIVEDATE_ID] [int] NOT NULL,					
	[COVERAGEEXPIRATIONDATE_ID] [int] NOT NULL,					
	[LIMIT_ID] [int] NOT NULL,					
	[DEDUCTIBLE_ID] [int] NOT NULL,					
	[CLASS_ID] [int] NOT NULL,					
	[PRIMARYRISK_ID] [int] NOT NULL,					
	[Building_Id] [int] DEFAULT 0 NOT NULL,					
	[Vehicle_Id] [int] DEFAULT 0 NOT NULL,					
	[Driver_Id] [int] DEFAULT 0 NOT NULL,					
	[PRIMARYRISKADDRESS_ID] [int] NOT NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,					
	[POLICYNEWISSUEDIND] [int] NOT NULL,					
	[POLICYCANCELLEDISSUEDIND] [int] NOT NULL,					
	[POLICYCANCELLEDEFFECTIVEIND] [int] NOT NULL,					
	[POLICYEXPIREDEFFECTIVEIND] [int] NOT NULL,					
	[RISK_DELETEDINDICATOR] [varchar](1) NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[COVERAGE_UNIQUEID] [varchar](100) NULL,					
	[COMM_AMT] [decimal](13, 2) NOT NULL,					
	[COMM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[COMM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[GROSS_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[MAN_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ORIG_WRTN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[TERM_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[EARNED_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[UNEARNED_PREM] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[GROSS_EARNED_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[COMM_EARNED_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ENDORSE_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[AUDIT_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[CNCL_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[REIN_PREM_AMT] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[TAXES_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[FEES_AMT] [decimal](13, 2) NOT NULL,					
	[FEES_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[FEES_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[AUDIT_ID] [int] DEFAULT 0 NOT NULL,					
 CONSTRAINT [PK_FACT_POLICYCOVERAGE] PRIMARY KEY CLUSTERED 						
(						
	[FACTPOLICYCOVERAGE_ID] ASC					
)						
)						
GO						
						
						
						
						
CREATE TABLE [dbo].[FACT_POLICYTRANSACTION](						
	[POLICYTRANSACTION_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[TRANSACTIONDATE_ID] [int] NOT NULL,					
	[ACCOUNTINGDATE_ID] [int] NOT NULL,					
	[EFFECTIVEDATE_ID] [int] NOT NULL,					
	[FIRSTINSURED_ID] [int] NOT NULL,					
	[PRODUCT_ID] [int] NOT NULL,					
	[COMPANY_ID] [int] NOT NULL,					
	[POLICYTRANSACTIONTYPE_ID] [int] NOT NULL,					
	[PRODUCER_ID] [int] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[COVERAGE_ID] [int] NOT NULL,					
	[COVERAGEEFFECTIVEDATE_ID] [int] NOT NULL,					
	[COVERAGEEXPIRATIONDATE_ID] [int] NOT NULL,					
	[LIMIT_ID] [int] NOT NULL,					
	[DEDUCTIBLE_ID] [int] NOT NULL,					
	[POLICYTRANSACTIONEXTENSION_ID] [int] NOT NULL,					
	[EARNFROMDATE_ID] [int] NOT NULL,					
	[PRIMARYRISK_ID] [int] NOT NULL,					
	[Building_Id] [int] DEFAULT 0 NOT NULL,					
	[Vehicle_Id] [int] DEFAULT 0 NOT NULL,					
	[Driver_Id] [int] DEFAULT 0 NOT NULL,					
	[PRIMARYRISKADDRESS_ID] [int] NOT NULL,					
	[EARNTODATE_ID] [int] NOT NULL,					
	[CLASS_ID] [int] NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[COVERAGE_UNIQUEID] [varchar](100) NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,					
	[EARNINGSTYPE] [varchar](1) NOT NULL,					
	[POLICYTRANSACTION_UNIQUEID] [varchar](100) NOT NULL,					
	[TRANSACTIONSEQUENCE] [bigint] NOT NULL,					
	[PERCENTEARNEDINCEPTION] [decimal](6, 3) NOT NULL,					
	[AMOUNT] [decimal](13, 2) NOT NULL,					
	[TERM_AMOUNT] [decimal](13, 2) NOT NULL,					
	[COMMISSION_AMOUNT] [decimal](13, 2) NOT NULL,					
	[AUDIT_ID] [int] DEFAULT 0 NOT NULL,					
 CONSTRAINT [PK_FACT_POLICYTRANSACTION] PRIMARY KEY CLUSTERED 						
(						
	[POLICYTRANSACTION_ID] ASC					
)						
) 						
GO						
						
						
						
						
						
						
CREATE VIEW [dbo].[VDIM_PRODUCER] AS						
SELECT						
   PRODUCER_ID,						
   producer_uniqueid AS PRDR_UNIQUEID,						
SOURCE_SYSTEM						
FROM						
   DW_MGA.dbo.DIM_PRODUCER						
WHERE Valid_ToDate='2200-01-01 00:00:00.000'						
						
GO						
						
						
CREATE TABLE [dbo].[FACT_CLAIM](						
	[CLAIMSUMMARY_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[MONTH_ID] [int] NOT NULL,					
	[COVERAGE_ID] [int] NOT NULL,					
	[COVERAGEEFFECTIVEDATE_ID] [int] NOT NULL,					
	[COVERAGEEXPIRATIONDATE_ID] [int] NOT NULL,					
	[ADJUSTER_ID] [int] NOT NULL,					
	[CLAIMANT_ID] [int] NOT NULL,					
	[PRODUCT_ID] [int] NOT NULL,					
	[COMPANY_ID] [int] NOT NULL,					
	[POLICY_ID] [int] NOT NULL,					
	[PolicySystemId] [int] NOT NULL,					
	[PRODUCER_ID] [int] NOT NULL,					
	[CLAIM_ID] [int] NOT NULL,					
	[CLAIMSTATUS_ID] [int] NOT NULL,					
	[CLAIMLOSSADDRESS_ID] [int] NOT NULL,					
	[DATEREPORTED_ID] [int] NOT NULL,					
	[DATEOFLOSS_ID] [int] NOT NULL,					
	[OPENEDDATE_ID] [int] NOT NULL,					
	[CLOSEDDATE_ID] [int] NOT NULL,					
	[FIRSTINSURED_ID] [int] NOT NULL,					
	[LIMIT_ID] [int] NOT NULL,					
	[DEDUCTIBLE_ID] [int] NOT NULL,					
	[PRIMARYRISK_ID] [int] NOT NULL,					
	[Building_Id] [int] NOT NULL,					
	[Vehicle_Id] [int] NOT NULL,					
	[Driver_Id] [int] NOT NULL,					
	[PRIMARYRISKADDRESS_ID] [int] NOT NULL,					
	[CLASS_ID] [int] NOT NULL,					
	[CATASTROPHE_ID] [int] NOT NULL,					
	[RESERVESTATUS_ID] [int] NOT NULL,					
	[CLAIMNUMBER] [varchar](50) NOT NULL,					
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[COVERAGE_UNIQUEID] [varchar](100) NOT NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NOT NULL,					
	[LOSS_PD_AMT] [decimal](13, 2) NOT NULL,					
	[LOSS_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[INIT_LOSS_RSRV_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_PD_AMT] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_PD_AMT] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[SUBRO_RECV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[SUBRO_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[SUBRO_PAID_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RECV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RECV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RSRV_CHNG_AMT] [decimal](13, 2) NOT NULL,					
	[LOSS_PD_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[LOSS_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_PD_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_PD_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[SUBRO_RECV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[SUBRO_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[SUBRO_PAID_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RECV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RECV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RSRV_CHNG_AMT_YTD] [decimal](13, 2) NOT NULL,					
	[LOSS_PD_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[LOSS_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_PD_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[ALC_EXP_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_PD_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[UALC_EXP_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[SUBRO_RECV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[SUBRO_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[SUBRO_PAID_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RECV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[SALVAGE_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RECV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[DEDRECOV_RSRV_CHNG_AMT_ITD] [decimal](13, 2) NOT NULL,					
	[FEAT_DAYS_OPEN] [int] NOT NULL,					
	[FEAT_DAYS_OPEN_ITD] [int] NOT NULL,					
	[FEAT_OPENED_IN_MONTH] [int] NOT NULL,					
	[FEAT_CLOSED_IN_MONTH] [int] NOT NULL,					
	[FEAT_CLOSED_WITHOUT_PAY] [int] NOT NULL,					
	[FEAT_CLOSED_WITH_PAY] [int] NOT NULL,					
	[CLM_DAYS_OPEN] [int] NOT NULL,					
	[CLM_DAYS_OPEN_ITD] [int] NOT NULL,					
	[CLM_OPENED_IN_MONTH] [int] NOT NULL,					
	[CLM_CLOSED_IN_MONTH] [int] NOT NULL,					
	[CLM_CLOSED_WITHOUT_PAY] [int] NOT NULL,					
	[CLM_CLOSED_WITH_PAY] [int] NOT NULL,					
	[MASTERCLAIM] [int] NOT NULL,					
	[CLM_REOPENED_IN_MONTH] [int] NULL,					
	[FEAT_REOPENED_IN_MONTH] [int] NULL,					
	[CLM_CLOSED_IN_MONTH_COUNTER] [int] NULL,					
	[CLM_CLOSED_WITHOUT_PAY_COUNTER] [int] NULL,					
	[CLM_CLOSED_WITH_PAY_COUNTER] [int] NULL,					
	[CLM_REOPENED_IN_MONTH_COUNTER] [int] NULL,					
	[AUDIT_ID] [int] NOT NULL,					
 CONSTRAINT [PK_FACT_CLAIM] PRIMARY KEY CLUSTERED 						
(						
	[CLAIMSUMMARY_ID] ASC					
)						
) 						
GO						
						
						
						
						
						
CREATE TABLE [dbo].[DIM_STATUS](						
	[STATUS_ID] [int] NOT NULL,					
	[STAT_4SIGHTBISTATUSCD] [varchar](50) NOT NULL,					
	[STAT_STATUSCD] [varchar](50) NOT NULL,					
	[STAT_STATUS] [varchar](100) NOT NULL,					
	[STAT_SUBSTATUSCD] [varchar](50) NOT NULL,					
	[STAT_SUBSTATUS] [varchar](100) NOT NULL,					
	[STAT_CATEGORY] [varchar](50) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
 CONSTRAINT [PK_DIM_STATUS] PRIMARY KEY CLUSTERED 						
(						
	[STATUS_ID] ASC					
)						
) 						
GO						
						
						
CREATE VIEW [dbo].[VDIM_POLICYSTATUS] AS						
SELECT						
   STATUS_ID AS POLICYSTATUS_ID,						
   STAT_4SIGHTBISTATUSCD AS POLST_4SIGHTBISTATUSCD,						
   STAT_STATUSCD AS POLST_STATUSCD,						
   STAT_STATUS AS POLST_STATUS,						
   STAT_SUBSTATUSCD AS POLST_SUBSTATUSCD,						
   STAT_SUBSTATUS AS POLST_SUBSTATUS						
FROM						
   DIM_STATUS						
WHERE						
   STAT_CATEGORY = 'policy'						
						
GO						
						
						
CREATE TABLE [dbo].[DIM_ADDRESS](						
	[ADDRESS_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[ADDRESS1] [varchar](150) NULL,					
	[ADDRESS2] [varchar](150) NULL,					
	[COUNTY] [varchar](50) NULL,					
	[CITY] [varchar](50) NULL,					
	[STATE] [varchar](50) NULL,					
	[POSTALCODE] [varchar](20) NULL,					
 CONSTRAINT [PK_DIM_ADDRESS] PRIMARY KEY CLUSTERED 						
(						
	[ADDRESS_ID] ASC					
)						
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_COVERAGE](						
	[COVERAGE_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[COV_CODE] [varchar](50) NULL,					
	[COV_SUBCODE] [varchar](50) NULL,					
	[COV_ASL] [varchar](5) NULL,					
	[COV_SUBLINE] [varchar](5) NULL,					
 CONSTRAINT [PK_DIM_COVERAGE] PRIMARY KEY CLUSTERED 						
(						
	[COVERAGE_ID] ASC					
)						
)						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_DEDUCTIBLE](						
	[DEDUCTIBLE_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[COV_DEDUCTIBLE1] [decimal](13, 2) NULL,					
	[COV_DEDUCTIBLE2] [decimal](13, 2) NULL,					
 CONSTRAINT [PK_DIM_DEDUCTIBLE] PRIMARY KEY CLUSTERED 						
(						
	[DEDUCTIBLE_ID] ASC					
)						
) 						
GO						
						
						
						
CREATE TABLE [dbo].[DIM_CLASSIFICATION](						
	[CLASS_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[CLASS_CODE] [varchar](50) NULL,					
	[CLASS_CODENAME] [varchar](50) NULL,					
	[CLASS_CODEDESCRIPTION] [varchar](256) NULL,					
 CONSTRAINT [PK_DIM_CLASS] PRIMARY KEY NONCLUSTERED 						
(						
	[CLASS_ID] ASC					
)						
) 						
GO						
						
						
CREATE VIEW [dbo].[VDIM_CLAIMSTATUS] AS						
SELECT						
   STATUS_ID AS CLAIMSTATUS_ID,						
   STAT_4SIGHTBISTATUSCD AS CLMST_4SIGHTBISTATUSCD,						
   STAT_STATUSCD AS CLMST_STATUSCD,						
   STAT_STATUS AS CLMST_STATUS,						
   STAT_SUBSTATUSCD AS CLMST_SUBSTATUSCD,						
   STAT_SUBSTATUS AS CLMST_SUBSTATUS						
FROM						
   DIM_STATUS						
WHERE						
   STAT_CATEGORY = 'claim'						
						
GO						
						
						
						
CREATE TABLE [dbo].[DIM_LIMIT](						
	[LIMIT_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[COV_LIMIT1] [varchar](255) NULL,					
	[COV_LIMIT1TYPE] [varchar](50) NULL,					
	[COV_LIMIT2] [varchar](255) NULL,					
	[COV_LIMIT2TYPE] [varchar](50) NULL,					
	[COV_LIMIT1_VALUE] [numeric](13, 2) NULL,					
	[COV_LIMIT2_VALUE] [numeric](13, 2) NULL,					
 CONSTRAINT [PK_DIM_LIMIT] PRIMARY KEY CLUSTERED 						
(						
	[LIMIT_ID] ASC					
)						
) 						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_POLICYTRANSACTIONTYPE](						
	[POLICYTRANSACTIONTYPE_ID] [int] NOT NULL,					
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
) ON [PRIMARY]						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_PRODUCT](						
	[PRODUCT_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[PRODUCT_UNIQUEID] [varchar](100) NULL,					
	[CarrierGroupCd] [varchar](100) NULL,					
	[Description] [varchar](2000) NULL,					
	[SubTypeCd] [varchar](100) NULL,					
	[ProductVersion] [varchar](24) NULL,					
	[Name] [varchar](64) NULL,					
	[ProductTypeCd] [varchar](32) NULL,					
	[CarrierCd] [varchar](8) NULL,					
	[isSelect] [int] NULL,					
	[LineCd] [varchar](32) NULL,					
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
	[TPAFeePlanCd] [varchar](24) NULL,					
	[Valid_Fromdate] [datetime] NULL,					
	[Valid_Todate] [datetime] NULL,					
	[Record_Version] [int] NULL,					
 CONSTRAINT [PK_DIM_PRODUCT] PRIMARY KEY CLUSTERED 						
(						
	[PRODUCT_ID] ASC					
)						
) 						
GO						
						
CREATE TABLE [dbo].[DIM_POLICY](						
	[POLICY_ID] [int] NOT NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NOT NULL,					
	[TransactionCd] [varchar](255) NULL,					
	[POLICYNUMBER] [varchar](50) NOT NULL,					
	[TERM] [varchar](10) NULL,					
	[EFFECTIVEDATE] [date] NULL,					
	[EXPIRATIONDATE] [date] NULL,					
	[CarrierCd] [varchar](255) NULL,					
	[CompanyCd] [varchar](255) NULL,					
	[TermDays] [int] NULL,					
	[CarrierGroupCd] [varchar](255) NULL,					
	[StateCD] [varchar](255) NULL,					
	[BusinessSourceCd] [varchar](255) NULL,					
	[PreviouscarrierCd] [varchar](255) NULL,					
	[PolicyFormCode] [varchar](255) NULL,					
	[SubTypeCd] [varchar](255) NULL,					
	[payPlanCd] [varchar](255) NULL,					
	[InceptionDt] [date] NULL,					
	[PriorPolicyNumber] [varchar](255) NULL,					
	[PreviousPolicyNumber] [varchar](255) NULL,					
	[AffinityGroupCd] [varchar](255) NULL,					
	[ProgramInd] [varchar](255) NULL,					
	[RelatedPolicyNumber] [varchar](255) NULL,					
	[TwoPayDiscountInd] [varchar](255) NULL,					
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
	[PrimaryPolicyNumber] [varchar](255) NULL,					
	[LandLordInd] [varchar](255) NULL,					
	[PersonalInjuryInd] [varchar](255) NULL,					
	[VehicleListConfirmedInd] [varchar](4) NULL,					
	[AltSubTypeCd] [varchar](32) NULL,					
	[FirstPayment] [date] NULL,					
	[LastPayment] [date] NULL,					
	[BalanceAmt] [decimal](38, 6) NULL,					
	[PaidAmt] [decimal](38, 6) NULL,					
	[PRODUCT_UNIQUEID] [varchar](100) NULL,					
	[COMPANY_UNIQUEID] [varchar](100) NULL,					
	[PRODUCER_UNIQUEID] [varchar](100) NULL,					
	[FIRSTINSURED_UNIQUEID] [varchar](100) NULL,					
	[AccountRef] [int] NULL,					
	[CUSTOMER_UNIQUEID] [int] NULL,					
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
	[CommissionAmt] [decimal](38, 6) NULL,					
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL,					
 CONSTRAINT [PK_DIM_POLICY] PRIMARY KEY CLUSTERED 						
(						
	[POLICY_ID],[SystemId] ASC					
)						
)						
GO						
						
						
						
						
						
						
						
						
CREATE TABLE [dbo].[DIM_BUILDING](						
	[BUILDING_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[POLICY_ID] [int] NULL,					
	[SystemId] [int] DEFAULT 0 NOT NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
	[Risk_UniqueId] [varchar](255) NULL,					
	[BldgNumber] [int] NULL,					
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
	[LineCD] [varchar](255) NULL,					
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
	[RoofCondition] [varchar](20) NULL,					
	[VALID_FROMDATE] [datetime] NOT NULL,					
	[VALID_TODATE] [datetime] NOT NULL,					
	[RECORD_VERSION] [int] NOT NULL					
 CONSTRAINT [PK_DIM_PROPERTY] PRIMARY KEY NONCLUSTERED 						
(						
	[BUILDING_ID] ASC					
)						
) 						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_MONTH](						
	[MONTH_ID] [int] NOT NULL,					
	[MON_MONTHNAME] [varchar](25) NULL,					
	[MON_MONTHABBR] [varchar](4) NULL,					
	[MON_REPORTPERIOD] [varchar](6) NULL,					
	[MON_MONTHINQUARTER] [int] NULL,					
	[MON_MONTHINYEAR] [int] NULL,					
	[MON_YEAR] [int] NULL,					
	[MON_QUARTER] [int] NULL,					
	[MON_STARTDATE] [datetime] NULL,					
	[MON_ENDDATE] [datetime] NULL,					
	[LOADDATE] [datetime] NULL,					
	[MON_SEQUENCE] [int] NULL,					
 CONSTRAINT [PK_DIM_MONTH] PRIMARY KEY CLUSTERED 						
(						
	[MONTH_ID] ASC					
)						
) 						
GO						
						
CREATE TABLE [dbo].[DIM_TIME](						
	[TIME_ID] [int] NOT NULL,					
	[MONTH_ID] [int] NULL,					
	[TM_DATE] [datetime] NULL,					
	[TM_DAYNAME] [varchar](25) NULL,					
	[TM_DAYABBR] [varchar](4) NULL,					
	[TM_REPORTPERIOD] [varchar](6) NULL,					
	[TM_ISODATE] [varchar](8) NULL,					
	[TM_DAYINWEEK] [int] NULL,					
	[TM_DAYINMONTH] [int] NULL,					
	[TM_DAYINQUARTER] [int] NULL,					
	[TM_DAYINYEAR] [int] NULL,					
	[TM_WEEKINMONTH] [int] NULL,					
	[TM_WEEKINQUARTER] [int] NULL,					
	[TM_WEEKINYEAR] [int] NULL,					
	[TM_MONTHNAME] [varchar](25) NULL,					
	[TM_MONTHABBR] [varchar](4) NULL,					
	[TM_MONTHINQUARTER] [int] NULL,					
	[TM_MONTHINYEAR] [int] NULL,					
	[TM_QUARTER] [int] NULL,					
	[TM_YEAR] [int] NULL,					
	[LOADDATE] [datetime] NULL,					
 CONSTRAINT [PK_DIM_TIME] PRIMARY KEY CLUSTERED 						
(						
	[TIME_ID] ASC					
)						
)						
GO						
						
CREATE TABLE [dbo].[DIM_TRANSACTIONTYPE](						
	[TRANSACTIONTYPE_ID] [int] NOT NULL,					
	[TRANS_CODE] [varchar](5) NOT NULL,					
	[TRANS_NAME] [varchar](100) NOT NULL,					
	[TRANS_DESCRIPTION] [varchar](256) NOT NULL,					
	[TRANS_SUBCODE] [varchar](5) NOT NULL,					
	[TRANS_SUBNAME] [varchar](100) NOT NULL,					
	[TRANS_SUBDESCRIPTION] [varchar](256) NOT NULL,					
	[TRANS_GROUP] [varchar](50) NULL,					
	[TRANS_RULE1] [varchar](50) NULL,					
	[TRANS_RULE2] [varchar](50) NULL,					
	[TRANS_RULE3] [varchar](50) NULL,					
	[TRANS_CATEGORY] [varchar](50) NULL,					
	[LOADDATE] [datetime] NOT NULL,					
 CONSTRAINT [PK_DIM_TRANSACTIONTYPE] PRIMARY KEY CLUSTERED 						
(						
	[TRANSACTIONTYPE_ID] ASC					
)						
) 						
GO						
						
CREATE TABLE [dbo].[LKUP_CLAIMTRANSACTIONSTATUS](						
	[CLAIMTRANSACTIONSTATUS_ID] [int] NOT NULL,					
	[CTS_TRANSACTIONSTATUS] [varchar](50) NOT NULL,					
	[CTS_TRANSACTIONROLLUP] [varchar](1) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
 CONSTRAINT [PK_CLMTRNSSTAT] PRIMARY KEY CLUSTERED 						
(						
	[CLAIMTRANSACTIONSTATUS_ID] ASC					
)						
)						
GO						
						
						
						
						
CREATE TABLE [dbo].[TMP_FACT_POLICYTRANSACTION](						
    [POLICY_ID] [int] NULL,						
	[SystemId] [int] NULL,					
	[Building_Id] [int] NULL,					
	[Vehicle_Id] [int] NULL,					
	[Driver_Id] [int] NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
	[COVERAGE_UNIQUEID] [varchar](100) NULL,					
	[COVERAGE_ID] [int] NULL,					
	[CLASS_ID] [int] NULL,					
	[DEDUCTIBLE_ID] [int] NULL,					
	[LIMIT_ID] [int] NULL,					
	[PRODUCT_ID] [int] NULL,					
	[COMPANY_ID] [int] NULL,					
	[PRODUCER_ID] [int] NULL,					
	[FIRSTINSURED_ID] [int] NULL,					
	[PRIMARYRISK_ID] [int] NULL,					
	[LKUP_RSK_DELETED_INDICATOR] [int] NULL,					
	[PRIMARYRISKADDRESS_ID] [int] NULL,					
	[POLICYNEWORRENEWAL] [varchar](10) NULL,					
	[POLICYTRANSACTIONTYPE_ID] [int] NULL,					
	[PTRANS_4SIGHTBICODE] [varchar](50) NULL,					
	[TRANS_DATE] [datetime] NULL,					
	[ACCT_DATE] [datetime] NULL,					
	[EFF_DATE] [datetime] NULL,					
	[POL_EFFECTIVEDATE] [datetime] NULL,					
	[POL_EXPIRATIONDATE] [datetime] NULL,					
	[COV_EFFECTIVEDATE] [datetime] NULL,					
	[COV_EXPIRATIONDATE] [datetime] NULL,					
	[COV_LIMIT1] [varchar](255) NULL,					
	[COV_LIMIT2] [varchar](255) NULL,					
	[AMOUNT] [decimal](13, 2) NULL,					
	[COMMISSION_AMOUNT] [decimal](13, 2) NULL,					
	[TERM_AMOUNT] [decimal](13, 2) NULL,					
	[TRANSACTIONDATE_ID] [int] NULL,					
	[TRANSACTIONSEQUENCE] [int] NULL					
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_POLICYTRANSACTIONEXTENSION](						
	[POLICYTRANSACTIONEXTENSION_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NULL,					
	[LOADDATE] [datetime] NULL,					
	[POLICY_ID] [int] NULL,					
	[SystemId] [int] NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
	[POLICYTRANSACTION_UNIQUEID] [varchar](100) NOT NULL,					
	[TransactionNumber] [int] NULL,					
	[TransactionCd] [varchar](255) NULL,					
	[TransactionLongDescription] [varchar](255) NULL,					
	[TransactionShortDescription] [varchar](255) NULL,					
	[CancelTypeCd] [varchar](255) NULL,					
	[CancelRequestedByCd] [varchar](255) NULL,					
	[CancelReason] [varchar](255) NULL,					
	[PolicyProgramCode] [varchar](255) NULL,					
 CONSTRAINT [PK_DIM_POLICYTRANSACTIONEXTENSION] PRIMARY KEY CLUSTERED 						
(						
	[POLICYTRANSACTIONEXTENSION_ID] ASC					
)						
)						
GO						
						
CREATE TABLE [dbo].[DIM_CATASTROPHE](						
	[catastrophe_id] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](5) NULL,					
	[LOADDATE] [datetime] NULL,					
	[cat_lossyear] [smallint] NULL,					
	[cat_startdate] [date] NULL,					
	[cat_enddate] [date] NULL,					
	[cat_name] [varchar](100) NULL,					
	[cat_isoserial] [varchar](5) NULL,					
	[cat_description] [varchar](150) NULL,					
	[cat_code] [varchar](100) NULL,					
	[cat_manuallyadded] [bit] NOT NULL,					
	[cat_actuarialtype] [varchar](20) NULL,					
	[cat_claimstype] [varchar](20) NULL,					
	[cat_financetype] [varchar](20) NULL,					
	[cat_adddate] [date] NULL,					
	[cat_updatedby] [varchar](50) NULL,					
	[cat_changedate] [date] NULL,					
	[cat_totalclaims] [int] NULL,					
	[cat_totalincurred] [decimal](38, 2) NULL,					
 CONSTRAINT [PK_DIM_CATASTROPHE] PRIMARY KEY CLUSTERED 						
(						
	[catastrophe_id] ASC					
						
))						
						
						
						
 CREATE NONCLUSTERED INDEX IFPYTRN_ETL2 ON dbo.FACT_POLICYTRANSACTION (  ACCOUNTINGDATE_ID ASC  , COVERAGEEXPIRATIONDATE_ID ASC  , TRANSACTIONDATE_ID ASC  )   INCLUDE ( COVERAGE_UNIQUEID , TRANSACTIONSEQUENCE )   ;  					;	
 CREATE NONCLUSTERED INDEX IDX_ETL1 ON dbo.DIM_CLAIMRISK (  ClaimNumber ASC  )   INCLUDE ( CLAIMRISK_ID )    ;  						
 CREATE NONCLUSTERED INDEX IDX_ETL1 ON dbo.TMP_FACT_POLICYTRANSACTION (  POLICY_UNIQUEID ASC  , COVERAGE_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDX_ETL2 ON dbo.TMP_FACT_POLICYTRANSACTION (  COVERAGE_UNIQUEID ASC  , TRANS_DATE ASC  , TRANSACTIONSEQUENCE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDX_ETL3 ON dbo.TMP_FACT_POLICYTRANSACTION (  POLICY_UNIQUEID ASC  , TRANS_DATE ASC  , TRANSACTIONSEQUENCE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDSTATUS_ETL ON dbo.DIM_STATUS (  STAT_STATUSCD ASC  , STAT_SUBSTATUSCD ASC  , STAT_CATEGORY ASC  )   INCLUDE ( STATUS_ID ) ;						
 CREATE NONCLUSTERED INDEX IDTIME_TM_DATE_ETL ON dbo.DIM_TIME (  TM_DATE ASC  )   INCLUDE ( TIME_ID )  ;						
 CREATE NONCLUSTERED INDEX IDTIME_MONTHNAME ON dbo.DIM_TIME (  TM_MONTHNAME ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDTIME_MONTHINYEAR ON dbo.DIM_TIME (  TM_MONTHINYEAR ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDTIME_QUARTER ON dbo.DIM_TIME (  TM_QUARTER ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDTIME_YEAR ON dbo.DIM_TIME (  TM_YEAR ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLKUPCLMTRNS_ETL ON dbo.LKUP_CLAIMTRANSACTIONSTATUS (  CTS_TRANSACTIONSTATUS ASC  )   INCLUDE ( CLAIMTRANSACTIONSTATUS_ID , CTS_TRANSACTIONROLLUP )  ;						
 CREATE NONCLUSTERED INDEX IFP_COMPANY_ID ON dbo.FACT_POLICY (  COMPANY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_FIRSTIID ON dbo.FACT_POLICY (  FIRSTINSURED_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_MONTH_ID ON dbo.FACT_POLICY (  MONTH_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_POLICY_ID ON dbo.FACT_POLICY (  POLICY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_POLSTATUSID ON dbo.FACT_POLICY (  POLICYSTATUS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_PRODUCER_ID ON dbo.FACT_POLICY (  PRODUCER_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_PRODUCT_ID ON dbo.FACT_POLICY (  PRODUCT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFP_POLICY_UID ON dbo.FACT_POLICY (  POLICY_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDMONTH_ETL ON dbo.DIM_MONTH (  MON_STARTDATE ASC  )   INCLUDE ( MONTH_ID )  ;						
 CREATE NONCLUSTERED INDEX IDMONTH_MONTHNAME ON dbo.DIM_MONTH (  MON_MONTHNAME ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDMNTH_MNTHINYR ON dbo.DIM_MONTH (  MON_MONTHINYEAR ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDMONTH_QUARTER ON dbo.DIM_MONTH (  MON_MONTHINQUARTER ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDMONTH_YEAR ON dbo.DIM_MONTH (  MON_YEAR ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_ETL ON dbo.DIM_ADDRESS (  ADDR_CITY ASC  , ADDR_STATE ASC  , ADDR_COUNTY ASC  , ADDR_POSTALCODE ASC  , ADDR_COUNTRY ASC  , ADDR_LATITUDE ASC  , ADDR_LONGITUDE ASC  )   INCLUDE ( ADDR_ADDRESS1 , ADDR_ADDRESS2 , ADDR_ADDRESS3 , ADDRESS_ID )  ;						
 CREATE NONCLUSTERED INDEX IDADDR_COUNTRY ON dbo.DIM_ADDRESS (  ADDR_COUNTRY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_STATE ON dbo.DIM_ADDRESS (  ADDR_STATE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_COUNTY ON dbo.DIM_ADDRESS (  ADDR_COUNTY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_POSTALCODE ON dbo.DIM_ADDRESS (  ADDR_POSTALCODE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_CITY ON dbo.DIM_ADDRESS (  ADDR_CITY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_ADDRESS1 ON dbo.DIM_ADDRESS (  ADDR_ADDRESS1 ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_ADDRESS2 ON dbo.DIM_ADDRESS (  ADDR_ADDRESS2 ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDADDR_ADDRESS3 ON dbo.DIM_ADDRESS (  ADDR_ADDRESS3 ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCLMTRANSTYPE_ETL ON dbo.DIM_CLAIMTRANSACTIONTYPE (  CTRANS_CODE ASC  , CTRANS_SUBCODE ASC  )   INCLUDE ( CLAIMTRANSACTIONTYPE_ID )  ;						
 CREATE NONCLUSTERED INDEX IDCLMTRNTYP_TRNNM ON dbo.DIM_CLAIMTRANSACTIONTYPE (  CTRANS_NAME ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCOV_ETL ON dbo.DIM_COVERAGE (  COV_TYPE ASC  , COV_CODE ASC  , COV_NAME ASC  , COV_SUBCODE ASC  , COV_SUBCODENAME ASC  , COV_ASL ASC  , COV_SUBLINE ASC  )   INCLUDE ( COVERAGE_ID );						
 CREATE NONCLUSTERED INDEX IDCOVERAGE_TYPE ON dbo.DIM_COVERAGE (  COV_TYPE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCOVERAGE_CODE ON dbo.DIM_COVERAGE (  COV_CODE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCOVERAGE_NAME ON dbo.DIM_COVERAGE (  COV_NAME ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCOVERAGE_SUBCODE ON dbo.DIM_COVERAGE (  COV_SUBCODE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDCOV_SUBCDNAM ON dbo.DIM_COVERAGE (  COV_SUBCODENAME ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDDEDUCTIBLE_ETL ON dbo.DIM_DEDUCTIBLE (  COV_DEDUCTIBLE1 ASC  , COV_DEDUCTIBLE1TYPE ASC  , COV_DEDUCTIBLE2 ASC  , COV_DEDUCTIBLE2TYPE ASC  , COV_DEDUCTIBLE3 ASC  , COV_DEDUCTIBLE3TYPE ASC  )   INCLUDE ( DEDUCTIBLE_ID )  ;						
 CREATE NONCLUSTERED INDEX IDLIMIT_ETL ON dbo.DIM_LIMIT (  COV_LIMIT1 ASC  , COV_LIMIT1TYPE ASC  , COV_LIMIT2 ASC  , COV_LIMIT2TYPE ASC  , COV_LIMIT3 ASC  , COV_LIMIT3TYPE ASC  , COV_LIMIT4 ASC  , COV_LIMIT4TYPE ASC  , COV_LIMIT5 ASC  , COV_LIMIT5TYPE ASC  )   INCLUDE ( LIMIT_ID )  ;						
 CREATE NONCLUSTERED INDEX IDTRANSYPE_ETL ON dbo.DIM_TRANSACTIONTYPE (  TRANS_CODE ASC  , TRANS_SUBCODE ASC  , TRANS_CATEGORY ASC  )   INCLUDE ( TRANSACTIONTYPE_ID )  ;						
						
 CREATE NONCLUSTERED INDEX IDX_ETL2 ON dbo.DIM_COVEREDRISK (  CVRSK_ITEM_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IPTRNTYP_ETL ON dbo.DIM_POLICYTRANSACTIONTYPE (  PTRANS_CODE ASC  , PTRANS_SUBCODE ASC  )   INCLUDE ( POLICYTRANSACTIONTYPE_ID ) ;						
 CREATE NONCLUSTERED INDEX IDPRODUCT_ETL ON dbo.DIM_PRODUCT (  PRODUCT_UNIQUEID ASC  )   INCLUDE ( PRODUCT_ID ) ;						
 CREATE NONCLUSTERED INDEX IFC_MONTH_ID ON dbo.FACT_CLAIM (  MONTH_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COVERAGE_ID ON dbo.FACT_CLAIM (  COVERAGE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COVERAGEXT_ID ON dbo.FACT_CLAIM (  COVERAGEEXTENSION_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COVEEFFDT_ID ON dbo.FACT_CLAIM (  COVERAGEEFFECTIVEDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COVEEXPDT_ID ON dbo.FACT_CLAIM (  COVERAGEEXPIRATIONDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_ADJUSTER_ID ON dbo.FACT_CLAIM (  ADJUSTER_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_CLAIMANT_ID ON dbo.FACT_CLAIM (  CLAIMANT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_PRODUCT_ID ON dbo.FACT_CLAIM (  PRODUCT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COMPANY_ID ON dbo.FACT_CLAIM (  COMPANY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_POLICY_ID ON dbo.FACT_CLAIM (  POLICY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_PRODUCER_ID ON dbo.FACT_CLAIM (  PRODUCER_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_CLAIM_ID ON dbo.FACT_CLAIM (  CLAIM_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_CLAIMSTATUS_ID ON dbo.FACT_CLAIM (  CLAIMSTATUS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_LOSSADDR_ID ON dbo.FACT_CLAIM (  CLAIMLOSSADDRESS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_DATERPTD_ID ON dbo.FACT_CLAIM (  DATEREPORTED_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_DATELOSS_ID ON dbo.FACT_CLAIM (  DATEOFLOSS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_DATECLOSED_ID ON dbo.FACT_CLAIM (  CLOSEDDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_FIRSTINSD_ID ON dbo.FACT_CLAIM (  FIRSTINSURED_ID ASC  ) ; 					 	
 CREATE NONCLUSTERED INDEX IFC_LIMIT_ID ON dbo.FACT_CLAIM (  LIMIT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_DEDUCTIBLE_ID ON dbo.FACT_CLAIM (  DEDUCTIBLE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_CLASS_ID ON dbo.FACT_CLAIM (  CLASS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_PRIMARYRSK_ID ON dbo.FACT_CLAIM (  PRIMARYRISK_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_PRSKADDR_ID ON dbo.FACT_CLAIM (  PRIMARYRISKADDRESS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_POLUID ON dbo.FACT_CLAIM (  POLICY_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFC_COVUID ON dbo.FACT_CLAIM (  COVERAGE_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLMTRNT ON dbo.FACT_CLAIMTRANSACTION (  CLAIMTRANSACTIONTYPE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_COVERAGE_ID ON dbo.FACT_CLAIMTRANSACTION (  COVERAGE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_COVEF ON dbo.FACT_CLAIMTRANSACTION (  COVERAGEEFFECTIVEDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_COVEXP ON dbo.FACT_CLAIMTRANSACTION (  COVERAGEEXPIRATIONDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_ADJUSTER_ID ON dbo.FACT_CLAIMTRANSACTION (  ADJUSTER_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLAIMANT_ID ON dbo.FACT_CLAIMTRANSACTION (  CLAIMANT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_PRODUCT_ID ON dbo.FACT_CLAIMTRANSACTION (  PRODUCT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_COMPANY_ID ON dbo.FACT_CLAIMTRANSACTION (  COMPANY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_POLICY_ID ON dbo.FACT_CLAIMTRANSACTION (  POLICY_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_PRODUCER_ID ON dbo.FACT_CLAIMTRANSACTION (  PRODUCER_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLAIM_ID ON dbo.FACT_CLAIMTRANSACTION (  CLAIM_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_DATERPTD_ID ON dbo.FACT_CLAIMTRANSACTION (  DATEREPORTED_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_DATELOSS_ID ON dbo.FACT_CLAIMTRANSACTION (  DATEOFLOSS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_DATECLOSED ON dbo.FACT_CLAIMTRANSACTION (  CLOSEDDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_FIRSTID ON dbo.FACT_CLAIMTRANSACTION (  FIRSTINSURED_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_LIMIT_ID ON dbo.FACT_CLAIMTRANSACTION (  LIMIT_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_DEDID ON dbo.FACT_CLAIMTRANSACTION (  DEDUCTIBLE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLASS_ID ON dbo.FACT_CLAIMTRANSACTION (  CLASS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_PRSKID ON dbo.FACT_CLAIMTRANSACTION (  PRIMARYRISK_ID ASC  ) ; 					 	
 CREATE NONCLUSTERED INDEX IFCTRN_PRSKADDR ON dbo.FACT_CLAIMTRANSACTION (  PRIMARYRISKADDRESS_ID ASC  ) ; 					 	
 CREATE NONCLUSTERED INDEX IFCTRN_TRANSDT_ID ON dbo.FACT_CLAIMTRANSACTION (  TRANSACTIONDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_ACCTDT_ID ON dbo.FACT_CLAIMTRANSACTION (  ACCOUNTINGDATE_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLMSTATUS ON dbo.FACT_CLAIMTRANSACTION (  CLAIMSTATUS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_CLMTRNUNIQ ON dbo.FACT_CLAIMTRANSACTION (  CLAIMTRANSACTION_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_TRANSFLAG ON dbo.FACT_CLAIMTRANSACTION (  TRANSACTIONFLAG ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_STATUS ON dbo.FACT_CLAIMTRANSACTION (  TRANSACTIONSTATUS ASC  ) ; 					 	
 CREATE NONCLUSTERED INDEX IFCTRN_LOSSADDR ON dbo.FACT_CLAIMTRANSACTION (  CLAIMLOSSADDRESS_ID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTRN_NEWRNW ON dbo.FACT_CLAIMTRANSACTION (  POLICYNEWORRENEWAL ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTAN_POLUID ON dbo.FACT_CLAIMTRANSACTION (  POLICY_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IFCTAN_COVUID ON dbo.FACT_CLAIMTRANSACTION (  COVERAGE_UNIQUEID ASC  ) ; 						
 CREATE NONCLUSTERED INDEX NCI_LOADDATE ON dbo.FACT_POLICYCOVERAGE (  LOADDATE ASC  ) ;						
 CREATE NONCLUSTERED INDEX NCI_MONTH_ID ON dbo.FACT_POLICYCOVERAGE (  MONTH_ID ASC  ) ;						
 CREATE NONCLUSTERED INDEX IDLEGALENTITY_ROLE ON dbo.DIM_LEGALENTITY (  LENTY_ROLE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLE_NAME1 ON dbo.DIM_LEGALENTITY (  LENTY_NAME1 ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLEGALENTITY_ETL ON dbo.DIM_LEGALENTITY (  LENTY_UNIQUEID ASC  , LENTY_ROLE ASC  , VALID_FROMDATE ASC  , VALID_TODATE ASC  )   INCLUDE ( LEGALENTITY_ID );						
 CREATE NONCLUSTERED INDEX IDLE_NUMBER ON dbo.DIM_LEGALENTITY (  LENTY_NUMBER ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLE_COUNTRY ON dbo.DIM_LEGALENTITY (  LENTY_COUNTRY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLE_STATE ON dbo.DIM_LEGALENTITY (  LENTY_STATE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLE_COUNTY ON dbo.DIM_LEGALENTITY (  LENTY_COUNTY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLEGALENTITY_CITY ON dbo.DIM_LEGALENTITY (  LENTY_CITY ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLE_POSTALCODE ON dbo.DIM_LEGALENTITY (  LENTY_POSTALCODE ASC  ) ; 						
 CREATE NONCLUSTERED INDEX IDLEGALENTITY_TYPE ON dbo.DIM_LEGALENTITY (  LENTY_TYPE ASC  ) ; 						
						
						
CREATE VIEW [dbo].[VDIM_OPENEDDATE] AS						
SELECT						
   TIME_ID AS OPENEDDATE_ID,						
   TM_DATE AS OPNDT_DATE,						
   TM_DAYNAME AS OPNDT_DAYNAME,						
   TM_DAYABBR AS OPNDT_DAYABBR,						
   TM_DAYINWEEK AS OPNDT_DAYINWEEK,						
   TM_DAYINMONTH AS OPNDT_DAYINMONTH,						
   TM_DAYINQUARTER AS OPNDT_DAYINQUARTER,						
   TM_DAYINYEAR AS OPNDT_DAYINYEAR,						
   TM_WEEKINMONTH AS OPNDT_WEEKINMONTH,						
   TM_WEEKINQUARTER AS OPNDT_WEEKINQUARTER,						
   TM_WEEKINYEAR AS OPNDT_WEEKINYEAR,						
   TM_MONTHNAME AS OPNDT_MONTHNAME,						
   TM_MONTHABBR AS OPNDT_MONTHABBR,						
   TM_MONTHINQUARTER AS OPNDT_MONTHINQUARTER,						
   TM_MONTHINYEAR AS OPNDT_MONTHINYEAR,						
   TM_QUARTER AS OPNDT_QUARTER,						
   TM_YEAR AS OPNDT_YEAR						
FROM						
   DIM_TIME						
						
						
						
						
						
GO						
						
						
CREATE VIEW [dbo].[VDIM_ACCOUNTINGDATE] AS						
SELECT						
   TIME_ID AS ACCOUNTINGDATE_ID,						
   TM_DATE AS ACCT_DATE,						
   TM_DAYNAME AS ACCT_DAYNAME,						
   TM_DAYABBR AS ACCT_DAYABBR,						
   TM_DAYINWEEK AS ACCT_DAYINWEEK,						
   TM_DAYINMONTH AS ACCT_DAYINMONTH,						
   TM_DAYINQUARTER AS ACCT_DAYINQUARTER,						
   TM_DAYINYEAR AS ACCT_DAYINYEAR,						
   TM_WEEKINMONTH AS ACCT_WEEKINMONTH,						
   TM_WEEKINQUARTER AS ACCT_WEEKINQUARTER,						
   TM_WEEKINYEAR AS ACCT_WEEKINYEAR,						
   TM_MONTHNAME AS ACCT_MONTHNAME,						
   TM_MONTHABBR AS ACCT_MONTHABBR,						
   TM_MONTHINQUARTER AS ACCT_MONTHINQUARTER,						
   TM_MONTHINYEAR AS ACCT_MONTHINYEAR,						
   TM_QUARTER AS ACCT_QUARTER,						
   TM_YEAR AS ACCT_YEAR						
FROM						
   DIM_TIME						
						
						
						
						
						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_VEHICLE](						
	[VEHICLE_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[POLICY_ID] [int] NOT  NULL,					
	[SystemId] [int] NOT  NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[Policy_Uniqueid] [int] NOT  NULL,					
	[Risk_UniqueId] [varchar](255) NOT  NULL,					
	[VehNumber] [int] NOT NULL,					
	[Vehicle_uniqueid] [varchar](525) NOT NULL,					
	[SPInnVehicle_Id] [varchar](255) NULL,					
	[Status] [varchar](255) NOT NULL,					
	[StateProvCd] [varchar](255) NOT NULL,					
	[County] [varchar](255) NOT NULL,					
	[PostalCode] [varchar](255) NOT NULL,					
	[City] [varchar](255) NOT NULL,					
	[Addr1] [varchar](1023) NOT NULL,					
	[Addr2] [varchar](255) NOT NULL,					
	[GaragAddrFlg] [varchar](3) NOT NULL,					
	[Latitude] [decimal](18, 12) NULL,					
	[Longitude] [decimal](18, 12) NULL,					
	[GaragPostalCode] [varchar](255) NULL,					
	[GaragPostalCodeFlg] [varchar](3) NULL,					
	[Manufacturer] [varchar](255) NOT NULL,					
	[Model] [varchar](255) NOT NULL,					
	[ModelYr] [varchar](10) NOT NULL,					
	[VehIdentificationNumber] [varchar](255) NOT NULL,					
	[ValidVinInd] [varchar](255) NOT NULL,					
	[VehLicenseNumber] [varchar](255) NOT NULL,					
	[RegistrationStateProvCd] [varchar](255) NOT NULL,					
	[VehBodyTypeCd] [varchar](255) NOT NULL,					
	[PerformanceCd] [varchar](255) NOT NULL,					
	[RestraintCd] [varchar](255) NOT NULL,					
	[AntiBrakingSystemCd] [varchar](255) NOT NULL,					
	[AntiTheftCd] [varchar](255) NOT NULL,					
	[EngineSize] [varchar](255) NOT NULL,					
	[EngineCylinders] [varchar](255) NOT NULL,					
	[EngineHorsePower] [varchar](255) NOT NULL,					
	[EngineType] [varchar](255) NOT NULL,					
	[VehUseCd] [varchar](255) NOT NULL,					
	[GarageTerritory] [int] NOT NULL,					
	[CollisionDed] [varchar](255) NOT NULL,					
	[ComprehensiveDed] [varchar](255) NOT NULL,					
	[StatedAmt] [numeric](28, 6) NOT NULL,					
	[ClassCd] [varchar](255) NOT NULL,					
	[RatingValue] [varchar](255) NOT NULL,					
	[CostNewAmt] [numeric](28, 6) NOT NULL,					
	[EstimatedAnnualDistance] [int] NOT NULL,					
	[EstimatedWorkDistance] [int] NOT NULL,					
	[LeasedVehInd] [varchar](255) NOT NULL,					
	[PurchaseDt] [date] NOT NULL,					
	[StatedAmtInd] [varchar](255) NOT NULL,					
	[NewOrUsedInd] [varchar](255) NOT NULL,					
	[CarPoolInd] [varchar](255) NOT NULL,					
	[OdometerReading] [varchar](10) NOT NULL,					
	[WeeksPerMonthDriven] [varchar](255) NOT NULL,					
	[DaylightRunningLightsInd] [varchar](255) NOT NULL,					
	[PassiveSeatBeltInd] [varchar](255) NOT NULL,					
	[DaysPerWeekDriven] [varchar](255) NOT NULL,					
	[UMPDLimit] [varchar](255) NOT NULL,					
	[TowingAndLaborInd] [varchar](255) NOT NULL,					
	[RentalReimbursementInd] [varchar](255) NOT NULL,					
	[LiabilityWaiveInd] [varchar](255) NOT NULL,					
	[RateFeesInd] [varchar](255) NOT NULL,					
	[OptionalEquipmentValue] [int] NOT NULL,					
	[CustomizingEquipmentInd] [varchar](255) NOT NULL,					
	[CustomizingEquipmentDesc] [varchar](255) NOT NULL,					
	[InvalidVinAcknowledgementInd] [varchar](255) NOT NULL,					
	[IgnoreUMPDWCDInd] [varchar](255) NOT NULL,					
	[RecalculateRatingSymbolInd] [varchar](255) NOT NULL,					
	[ProgramTypeCd] [varchar](255) NOT NULL,					
	[CMPRatingValue] [varchar](255) NOT NULL,					
	[COLRatingValue] [varchar](255) NOT NULL,					
	[LiabilityRatingValue] [varchar](255) NOT NULL,					
	[MedPayRatingValue] [varchar](255) NOT NULL,					
	[RACMPRatingValue] [varchar](255) NOT NULL,					
	[RACOLRatingValue] [varchar](255) NOT NULL,					
	[RABIRatingSymbol] [varchar](255) NOT NULL,					
	[RAPDRatingSymbol] [varchar](255) NOT NULL,					
	[RAMedPayRatingSymbol] [varchar](255) NOT NULL,					
	[EstimatedAnnualDistanceOverride] [varchar](5) NOT NULL,					
	[OriginalEstimatedAnnualMiles] [varchar](12) NOT NULL,					
	[ReportedMileageNonSave] [varchar](12) NOT NULL,					
	[Mileage] [varchar](12) NOT NULL,					
	[EstimatedNonCommuteMiles] [varchar](12) NOT NULL,					
	[TitleHistoryIssue] [varchar](3) NOT NULL,					
	[OdometerProblems] [varchar](3) NOT NULL,					
	[Bundle] [varchar](15) NOT NULL,					
	[LoanLeaseGap] [varchar](3) NOT NULL,					
	[EquivalentReplacementCost] [varchar](3) NOT NULL,					
	[OriginalEquipmentManufacturer] [varchar](3) NOT NULL,					
	[OptionalRideshare] [varchar](3) NOT NULL,					
	[MedicalPartsAccessibility] [varchar](4) NOT NULL,					
	[OdometerReadingPrior] [varchar](10) NOT NULL,					
	[ReportedMileageNonSaveDtPrior] [date] NOT NULL,					
	[FullGlassCovInd] [varchar](3) NOT NULL,					
	[BoatLengthFeet] [varchar](255) NOT  NULL,					
	[MotorHorsePower] [varchar](255) NOT  NULL,					
	[Replacementof] [int]  NOT NULL,					
	[ReportedMileageNonSaveDt] [date] NOT  NULL,					
	[ManufacturerSymbol] [varchar](4) NOT  NULL,					
	[ModelSymbol] [varchar](4) NOT  NULL,					
	[BodyStyleSymbol] [varchar](4) NOT  NULL,					
	[SymbolCode] [varchar](12) NOT NULL,					
	[VerifiedMileageOverride] [varchar](4) NOT NULL,					
	[VALID_FROMDATE] [datetime] NOT NULL,					
	[VALID_TODATE] [datetime] NOT NULL,					
	[RECORD_VERSION] [int] NOT NULL					
	 CONSTRAINT [PK_DIM_VEHICLE] PRIMARY KEY NONCLUSTERED 					
	(					
	[VEHICLE_ID] ASC					
	)					
	) 					
	GO					
						
						
	CREATE TABLE [dbo].[DIM_DRIVER](					
	[DRIVER_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[POLICY_ID] [int] NOT  NULL,					
	[SystemId] [int] NOT NULL,					
	[BookDt] [date]  NOT NULL,					
	[TransactionEffectiveDt] [date] NOT NULL,					
	[Policy_Uniqueid] [int] NOT NULL,					
	[Driver_UniqueId] [varchar](255) NOT NULL,					
	[SPINNDriver_Id] [varchar](255) NOT NULL,					
	[DriverNumber] [int] NOT NULL,					
	[Status] [varchar](255) NOT NULL,					
	[FirstName] [varchar](255) NULL,					
	[LastName] [varchar](255) NULL,					
	[LicenseNumber] [varchar](255) NOT NULL,					
	[LicenseDt] [datetime] NOT NULL,					
	[DriverInfoCd] [varchar](255) NOT NULL,					
	[DriverTypeCd] [varchar](255) NOT NULL,					
	[DriverStatusCd] [varchar](255) NOT NULL,					
	[LicensedStateProvCd] [varchar](255) NOT NULL,					
	[RelationshipToInsuredCd] [varchar](255) NOT NULL,					
	[ScholasticDiscountInd] [varchar](255) NOT NULL,					
	[MVRRequestInd] [varchar](255) NOT NULL,					
	[MVRStatus] [varchar](255) NOT NULL,					
	[MVRStatusDt] [datetime] NOT NULL,					
	[MatureDriverInd] [varchar](255) NOT NULL,					
	[DriverTrainingInd] [varchar](255) NOT NULL,					
	[GoodDriverInd] [varchar](255) NOT NULL,					
	[AccidentPreventionCourseCompletionDt] [datetime] NOT NULL,					
	[DriverTrainingCompletionDt] [datetime] NOT NULL,					
	[AccidentPreventionCourseInd] [varchar](255) NOT NULL,					
	[ScholasticCertificationDt] [datetime] NOT NULL,					
	[ActiveMilitaryInd] [varchar](255) NOT NULL,					
	[PermanentLicenseInd] [varchar](255) NOT NULL,					
	[NewToStateInd] [varchar](255) NOT NULL,					
	[PersonTypeCd] [varchar](255) NOT NULL,					
	[GenderCd] [varchar](255) NOT NULL,					
	[BirthDt] [datetime] NOT NULL,					
	[MaritalStatusCd] [varchar](255) NOT NULL,					
	[OccupationClassCd] [varchar](255) NOT NULL,					
	[PositionTitle] [varchar](255) NOT NULL,					
	[CurrentResidenceCd] [varchar](255) NOT NULL,					
	[CivilServantInd] [varchar](255) NOT NULL,					
	[RetiredInd] [varchar](255) NOT NULL,					
	[NewTeenExpirationDt] [date] NOT NULL,					
	[AttachedVehicleRef] [varchar](255) NOT NULL,					
	[VIOL_PointsChargedTerm] [int] NOT NULL,					
	[ACCI_PointsChargedTerm] [int] NOT NULL,					
	[SUSP_PointsChargedTerm] [int] NOT NULL,					
	[Other_PointsChargedTerm] [int] NOT NULL,					
	[GoodDriverPoints_chargedterm] [int] NOT  NULL,					
	[SR22FeeInd] [varchar](4) NOT  NULL,					
	[MatureCertificationDt] [datetime]  NOT  NULL,					
	[AgeFirstLicensed] [int]  NOT  NULL,					
	[VALID_FROMDATE] [datetime] NOT NULL,					
	[VALID_TODATE] [datetime] NOT NULL,					
	[RECORD_VERSION] [int] NOT NULL					
	 CONSTRAINT [PK_DIM_DRIVER] PRIMARY KEY NONCLUSTERED 					
	(					
	[DRIVER_ID] ASC					
	)					
	) 					
	GO					
						
						
						
CREATE TABLE [dbo].[DIM_RESERVESTATUS](						
	[ReserveStatus_Id] [int] IDENTITY(0,1) NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[CLAIM_ID] [int] NOT NULL,					
	[CLAIM_UNIQUEID] [varchar](100) NOT NULL,					
	[BookDt] [date] NOT NULL,					
	[POLICY_UNIQUEID] [int] NULL,					
	[POLICY_ID] [int] NULL,					
	[PolicySystemId] [int] DEFAULT 0 NULL,					
	[TransactionNumber] [int] NOT NULL,					
	[ClaimNumber] [varchar](50) NOT NULL,					
	[Adjustment] [varchar](10) NOT  NULL,					
	[Indemnity] [varchar](10) NOT  NULL,					
	[Defense] [varchar](10) NOT  NULL,					
	[Subrogation] [varchar](10) NOT  NULL,					
	[Salvage] [varchar](10) NOT  NULL,					
	[Adjustment_Status_Chng] [smallint] NOT  NULL,					
	[Indemnity_Status_Chng] [smallint] NOT  NULL,					
	[Defense_Status_Chng] [smallint] NOT  NULL,					
	[Subrogation_Status_Chng] [smallint] NOT  NULL,					
	[Salvage_Status_Chng] [smallint] NOT  NULL,					
	[Current_Flag] [smallint] NULL					
PRIMARY KEY CLUSTERED 						
(						
	[ReserveStatus_Id] ASC					
)						
)						
GO						
						
CREATE TABLE [dbo].[DIM_CLAIMANT](						
	[CLAIMANT_ID] [int] NOT NULL,					
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
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL					
 CONSTRAINT [PK_DIM_CLAIMANT] PRIMARY KEY CLUSTERED 						
(						
	[CLAIMANT_ID] ASC					
)						
) 						
GO						
						
						
						
						
CREATE TABLE [dbo].[DIM_ADJUSTER](						
	[ADJUSTER_ID] [int] NOT NULL,					
	[source_system] [varchar](100) NOT NULL,					
	[loaddate] [datetime] NOT NULL,					
	[ADJUSTER_uniqueID] [varchar](100) NOT NULL,					
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
	[Supervisor] [varchar](255) NULL,					
	[VALID_FROMDATE] [datetime] NULL,					
	[VALID_TODATE] [datetime] NULL,					
	[RECORD_VERSION] [int] NULL					
 CONSTRAINT [PK_DIM_ADJUSTER] PRIMARY KEY CLUSTERED 						
(						
	[ADJUSTER_ID] ASC					
)						
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_COMPANY](						
	[company_id] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NOT NULL,					
	[company_uniqueid] [varchar](100) NOT NULL,					
	[CarrierCd] [varchar](10) NOT NULL,					
	[CompanyCd] [varchar](10) NOT NULL					
)						
GO						
						
						
CREATE TABLE [dbo].[DIM_PRODUCER](						
	[producer_id] [int] NOT NULL,					
	[Source_System] [varchar](100) NULL,					
	[LoadDate] [datetime] NULL,					
	[producer_uniqueid] [varchar](20) NULL,					
	[Valid_FromDate] [datetime] NULL,					
	[Valid_ToDate] [datetime] NULL,					
	[Record_Version] [int] NULL,					
	[producer_number] [varchar](20) NULL,					
	[producer_name] [varchar](255) NULL,					
	[LicenseNo] [varchar](255) NULL,					
	[agency_type] [varchar](11) NULL,					
	[address] [varchar](510) NULL,					
	[city] [varchar](80) NULL,					
	[state_cd] [varchar](5) NULL,					
	[zip] [varchar](10) NULL,					
	[phone] [varchar](20) NULL,					
	[fax] [varchar](15) NULL,					
	[email] [varchar](255) NULL,					
	[agency_group] [varchar](255) NULL,					
	[national_name] [varchar](255) NULL,					
	[national_code] [varchar](20) NULL,					
	[territory] [varchar](50) NULL,					
	[territory_manager] [varchar](50) NULL,					
	[DBA] [varchar](255) NULL,					
	[producer_status] [varchar](10) NULL,					
	[commission_master] [varchar](20) NULL,					
	[reporting_master] [varchar](20) NULL,					
	[pn_appointment_date] [date] NULL,					
	[Profit_sharing_master] [varchar](20) NULL,					
	[producer_master] [varchar](20) NULL,					
	[Recognition_tier] [varchar](100) NULL,					
	[RMAddress] [varchar](100) NULL,					
	[RMCity] [varchar](50) NULL,					
	[RMState] [varchar](25) NULL,					
	[RMZip] [varchar](25) NULL,					
	[new_business_term_date] [date] NULL					
 CONSTRAINT [PK_REFERENCE_PR] PRIMARY KEY CLUSTERED 						
(						
	[producer_id] ASC					
)						
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_USER](						
	[USER_ID] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[USER_UNIQUEID] [varchar](255) NOT NULL,					
	[LoginId] [varchar](255) NOT NULL,					
	[TypeCd] [varchar](255) NOT NULL,					
	[Supervisor] [varchar](255) NOT NULL,					
	[LastName] [varchar](255) NOT NULL,					
	[FirstName] [varchar](255) NOT NULL,					
	[TerminatedDt] [datetime] NOT NULL,					
	[DepartmentCd] [varchar](255) NOT NULL,					
	[UserManagementGroupCd] [varchar](250) NOT NULL,					
	[VALID_FROMDATE] [datetime] NOT NULL,					
	[VALID_TODATE] [datetime] NOT NULL,					
	[RECORD_VERSION] [int] NOT NULL					
PRIMARY KEY CLUSTERED 						
(						
	[USER_ID] ASC					
)						
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_CUSTOMER](						
	[Customer_Id] [int] NOT NULL,					
	[SOURCE_SYSTEM] [varchar](100) NOT NULL,					
	[LOADDATE] [datetime] NULL,					
	[Customer_UniqueId] int NOT NULL,					
	[Status] [varchar](10) NOT NULL,					
	[EntityTypeCd] [varchar](30) NOT NULL,					
	[First_Name] [varchar](255) NOT NULL,					
	[Last_Name] [varchar](255) NOT NULL,					
	[CommercialName] [varchar](255) NOT NULL,					
	[DOB] [datetime] NOT NULL,					
	[gender] [varchar](5) NOT NULL,					
	[maritalStatus] [varchar](20) NOT NULL,					
	[address1] [varchar](255) NOT NULL,					
	[address2] [varchar](255) NOT NULL,					
	[county] [varchar](255) NOT NULL,					
	[city] [varchar](255) NOT NULL,					
	[state] [varchar](255) NOT NULL,					
	[PostalCode] [varchar](5) NOT NULL,					
	[phone] [varchar](255) NOT NULL,					
	[mobile] [varchar](255) NOT NULL,					
	[email] [varchar](255) NOT NULL,					
	[PreferredDeliveryMethod] [varchar](10) NOT NULL,					
	[PortalInvitationSentDt] [datetime] NOT NULL,					
	[PaymentReminderInd] [varchar](10) NOT NULL,					
	[VALID_FROMDATE] [datetime] NOT NULL,					
	[VALID_TODATE] [datetime] NOT NULL,					
	[Record_Version] [int] NOT NULL					
 CONSTRAINT [PK_DIM_CUSTOMER] PRIMARY KEY CLUSTERED 						
(						
	[Customer_Id] ASC					
)						
) 						
GO						
						
						
CREATE TABLE dbo.DIM_RISK_COVERAGE(						
COVEREDRISK_ID int NOT NULL,						
POLICY_ID int NOT NULL,						
SystemId int NULL,						
SOURCE_SYSTEM varchar(100) NOT NULL,						
LOADDATE datetime NULL,						
[BookDt] [date]  NOT NULL,						
[TransactionEffectiveDt] [date] NOT NULL,						
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
WCINC_FullTermAmt_o	[decimal](13, 2) NULL,					
[VALID_FROMDATE] [datetime] NOT NULL,						
[VALID_TODATE] [datetime] NOT NULL,						
[RECORD_VERSION] [int] NOT NULL						
 CONSTRAINT [PK_DIM_RISK_COVERAGE] PRIMARY KEY NONCLUSTERED 						
(						
	[COVEREDRISK_ID] ASC					
)						
) 						
GO						
						
						
CREATE TABLE [dbo].[DIM_CLAIMANT_ASSOCIATE](						
	CLAIMANT_ASSOCIATE_ID int NOT NULL,					
	source_system varchar(100) NOT NULL,					
	loaddate datetime NOT NULL,					
	CLAIMANT_ID int NOT NULL,					
	claimant_uniqueID varchar(100) NOT NULL,					
	AssociateTypeCd varchar(255) NULL,					
	AssociateProviderRef [int] NULL					
PRIMARY KEY CLUSTERED 						
(						
	CLAIMANT_ASSOCIATE_ID ASC					
)						
);						


