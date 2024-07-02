ALTER PROCEDURE [dbo].[SP_DIM_RESERVESTATUS] (@SOURCE_SYSTEM VARCHAR(100), @LoadDate DATETIME)	
AS	
	
	
 IF OBJECT_ID('TEMPDB..#tmp_deltas') IS NOT NULL 	
  DROP TABLE #tmp_deltas;	
 WITH CTE_MAX AS	
 (	
 SELECT 	
 claim_uniqueid, 	
 ReserveCd, 	
 BookDt,	
 MAX(TransactionNumber) LTran,	
 COUNT(DISTINCT ReserveStatus) RSC	
 FROM STG_MGA.dbo.STG_RESERVESTATUS	
 WHERE SOURCE_SYSTEM=@SOURCE_SYSTEM	
 GROUP BY 	
 claim_uniqueid, 	
 ReserveCd, 	
 BookDt	
 )	
 SELECT DISTINCT 	
 CCFR.claim_uniqueid,	
 CCFR.BookDt, 	
 CCFR.TransactionNumber,	
 CCFR.ReserveCd,	
 CCFR.ReserveStatus 'ReserveStatusCd',	
 CASE WHEN CTE.RSC >= 1 THEN 1 ELSE 0 END 'RSChng'	
 INTO #tmp_deltas	
 FROM CTE_MAX CTE	
 INNER JOIN STG_MGA.dbo.STG_RESERVESTATUS CCFR	
  ON CCFR.claim_uniqueid = CTE.claim_uniqueid	
  AND CCFR.ReserveCd = CTE.ReserveCd	
  AND CCFR.BookDt = CTE.BookDt	
  AND CCFR.TransactionNumber = CTE.LTran	
 WHERE SOURCE_SYSTEM=@SOURCE_SYSTEM	
;	
	
IF OBJECT_ID('TEMPDB..#DIM_CCFR_Status') IS NOT NULL 	
 DROP TABLE #DIM_CCFR_Status;	
	
  SELECT 	
    claim_uniqueid, 	
	BookDt, 
	TransactionNumber, 
	CAST(0 AS smallint) Current_Flag
  , MAX(Adjustment) Adjustment	
  , MAX(Indemnity) Indemnity	
  , MAX(Defense) Defense	
  , MAX(Subrogation) Subrogation	
  , MAX(Salvage) Salvage	
  , MAX(RSCAdjustment) ARSC	
  , MAX(RSCIndemnity) IRSC	
  , MAX(RSCDefense) DRSC	
  , MAX(RSCSubrogation) SubRSC	
  , MAX(RSCSalvage) SalRSC	
  , CAST(NULL AS BIT) Adjustment_Status_Chng	
  , CAST(NULL AS BIT) Indemnity_Status_Chng	
  , CAST(NULL AS BIT) Defense_Status_Chng	
  , CAST(NULL AS BIT) Subrogation_Status_Chng	
  , CAST(NULL AS BIT) Salvage_Status_Chng	
  INTO #DIM_CCFR_Status	
  FROM	
  (	
   SELECT 	
     claim_uniqueid, 	
     BookDt	
   , LAST_VALUE(TransactionNumber) OVER (PARTITION BY claim_uniqueid ORDER BY TransactionNumber RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) TransactionNumber	
   , CAST(0 AS smallint) Current_Flag	
   , Adjustment	
   , Indemnity	
   , Defense	
   , Subrogation	
   , Salvage	
   , RSCAdjustment	
   , RSCIndemnity	
   , RSCDefense	
   , RSCSubrogation	
   , RSCSalvage	
   FROM	
   (	
    SELECT claim_uniqueid, BookDt, ReserveCd, 'RSC' + ReserveCd R2, ReserveStatusCd, TransactionNumber, RSChng	
    FROM #tmp_deltas	
   )SQ	
   PIVOT	
   (	
    MAX(ReserveStatusCd) FOR ReserveCd IN([Adjustment], [Indemnity], [Defense], [Subrogation], [Salvage])	
   )SQ_PIVOT	
   PIVOT	
   (	
    MAX(RSChng) FOR R2 IN([RSCAdjustment], [RSCIndemnity], [RSCDefense], [RSCSubrogation], [RSCSalvage])	
   )SQ_CHNG	
  )SQ	
  GROUP BY claim_uniqueid, BookDt, TransactionNumber;	
	
 WITH CTE AS	
  (	
   SELECT CCFR.claim_uniqueid, MAX(CCFR.BookDt)BookDt	
   FROM DW_MGA.dbo.DIM_RESERVESTATUS CCFR	
   INNER JOIN #DIM_CCFR_Status TMP	
   ON CCFR.claim_uniqueid = TMP.claim_uniqueid	
   AND CCFR.BookDt < TMP.BookDt	
   WHERE SOURCE_SYSTEM=@SOURCE_SYSTEM	
   GROUP BY CCFR.claim_uniqueid	
  )	
  UPDATE T 	
  SET	
   Adjustment = CASE WHEN T.Adjustment IS NULL THEN CCFR.Adjustment WHEN T.Adjustment = 'Open' AND CCFR.Adjustment <> 'Open' THEN 'Reopen' ELSE T.Adjustment END	
   , Defense = CASE WHEN T.Defense IS NULL THEN CCFR.Defense WHEN T.Defense = 'Open' AND CCFR.Defense <> 'Open' THEN 'Reopen' ELSE T.Defense END	
   , Indemnity = CASE WHEN T.Indemnity IS NULL THEN CCFR.Indemnity WHEN T.Indemnity = 'Open' AND CCFR.Indemnity <> 'Open' THEN 'Reopen' ELSE T.Indemnity END	
   , Subrogation = CASE WHEN T.Subrogation IS NULL THEN CCFR.Subrogation WHEN T.Subrogation = 'Open' AND CCFR.Subrogation <> 'Open' THEN 'Reopen' ELSE T.Subrogation END	
   , Salvage = CASE WHEN T.Salvage IS NULL THEN CCFR.Salvage WHEN T.Salvage = 'Open' AND CCFR.Salvage <> 'Open' THEN 'Reopen' ELSE T.Salvage END	
   , Adjustment_Status_Chng = CASE WHEN CCFR.Adjustment IS NULL AND T.Adjustment IS NOT NULL THEN 1 WHEN T.Adjustment IS NOT NULL AND (T.Adjustment = 'Closed' OR (T.Adjustment <> CCFR.Adjustment) OR T.ARSC = 1) THEN 1 ELSE 0 END	
   , Indemnity_Status_Chng = CASE WHEN CCFR.Indemnity IS NULL AND T.Indemnity IS NOT NULL THEN 1 WHEN T.Indemnity IS NOT NULL AND (T.Indemnity = 'Closed' OR (T.Indemnity <> CCFR.Indemnity OR T.IRSC = 1)) THEN 1 ELSE 0 END	
   , Defense_Status_Chng = CASE WHEN CCFR.Defense IS NULL AND T.Defense IS NOT NULL THEN 1 WHEN T.Defense IS NOT NULL AND (T.Defense = 'Closed' OR (T.Defense <> CCFR.Defense) OR T.DRSC = 1) THEN 1 ELSE 0 END	
   , Subrogation_Status_Chng = CASE WHEN CCFR.Subrogation IS NULL AND T.Subrogation IS NOT NULL THEN 1 WHEN T.Subrogation IS NOT NULL AND (T.Subrogation = 'Closed' OR (T.Subrogation <> CCFR.Subrogation) OR T.SubRSC = 1) THEN 1 ELSE 0 END	
   , Salvage_Status_Chng = CASE WHEN CCFR.Salvage IS NULL AND T.Salvage IS NOT NULL THEN 1 WHEN T.Salvage IS NOT NULL AND (T.Salvage = 'Closed' OR (T.Salvage <> CCFR.Salvage) OR T.SalRSC = 1) THEN 1 ELSE 0 END	
  FROM #DIM_CCFR_Status T	
  LEFT JOIN CTE	
   ON CTE.claim_uniqueid = T.claim_uniqueid	
  LEFT JOIN DW_MGA.dbo.DIM_RESERVESTATUS CCFR	
   ON CCFR.claim_uniqueid = CTE.claim_uniqueid	
   AND CCFR.BookDt = CTE.BookDt	
   AND CCFR.SOURCE_SYSTEM=@SOURCE_SYSTEM	
  ;	
	
  UPDATE T SET	
  Current_Flag = CASE	
   WHEN OA_Leads.cnt <= 1 THEN 1 --This will be the latest row	
   WHEN OA_Leads.cnt > 1 THEN 0 --This will not be the lastest row	
    END	
  FROM #DIM_CCFR_Status T	
  OUTER APPLY	
  (	
   SELECT COUNT(1) cnt	
   FROM DW_MGA.dbo.DIM_RESERVESTATUS CCFR	
   WHERE CCFR.claim_uniqueid = T.claim_uniqueid	
    AND CCFR.BookDt > T.BookDt	
	AND SOURCE_SYSTEM=@SOURCE_SYSTEM
  )OA_Leads;	
	
	
  IF(SELECT COUNT(1)FROM #DIM_CCFR_Status) > 0	
  BEGIN	
	
   DELETE CCFR	
   FROM DW_MGA.dbo.DIM_RESERVESTATUS CCFR	
   INNER JOIN #DIM_CCFR_Status T	
   ON CCFR.claim_uniqueid = T.claim_uniqueid	
   AND CCFR.BookDt = T.BookDt	
   WHERE SOURCE_SYSTEM=@SOURCE_SYSTEM	
   ;	
	
	
   UPDATE CCFR	
    SET Current_Flag = 0	
   FROM DW_MGA.dbo.DIM_RESERVESTATUS CCFR	
   INNER JOIN #DIM_CCFR_Status T	
   ON CCFR.claim_uniqueid = T.claim_uniqueid	
   AND CCFR.Current_Flag = 1	
   WHERE SOURCE_SYSTEM=@SOURCE_SYSTEM	
   ;	
	
   INSERT INTO DW_MGA.dbo.DIM_RESERVESTATUS	
   (	
	   SOURCE_SYSTEM
      ,LOADDATE	
      ,CLAIM_ID	
	  ,POLICY_ID
	  ,POLICY_UNIQUEID
	  ,PolicySystemId
      ,BookDt	
      ,TransactionNumber	
      ,CLAIM_UNIQUEID	
      ,ClaimNumber	
      ,Adjustment	
      ,Indemnity	
      ,Defense	
      ,Subrogation	
      ,Salvage	
      ,Adjustment_Status_Chng	
      ,Indemnity_Status_Chng	
      ,Defense_Status_Chng	
      ,Subrogation_Status_Chng	
      ,Salvage_Status_Chng	
      ,Current_Flag	
   )	
   SELECT	
       @SOURCE_SYSTEM SOURCE_SYSTEM	
      ,@LoadDate LOADDATE	
      ,isnull(c.CLAIM_ID, 0) CLAIM_ID	
	  ,isnull(c.POLICY_ID, 0) POLICY_ID
	  ,isnull(c.POLICY_UNIQUEID, 0) POLICY_UNIQUEID
	  ,isnull(c.PolicySystemId, 0) PolicySystemId
      ,BookDt	
      ,TransactionNumber	
      ,t.CLAIM_UNIQUEID	
      ,isnull(c.ClaimNumber,'Unknown') ClaimNumber	
      ,isnull(Adjustment, '~') Adjustment	
      ,isnull(Indemnity, '~') Indemnity	
      ,isnull(Defense, '~') Defense	
      ,isnull(Subrogation, '~') Subrogation	
      ,isnull(Salvage, '~') Salvage	
      ,isnull(Adjustment_Status_Chng, 0) Adjustment_Status_Chng	
      ,isnull(Indemnity_Status_Chng, 0) Indemnity_Status_Chng	
      ,isnull(Defense_Status_Chng, 0) Defense_Status_Chng	
      ,isnull(Subrogation_Status_Chng, 0) Subrogation_Status_Chng	
      ,isnull(Salvage_Status_Chng, 0) Salvage_Status_Chng	
      ,isnull(Current_Flag,0) Salvage_Status_Chng	
   FROM #DIM_CCFR_Status t	
   join DW_MGA.dbo.DIM_CLAIM c	
   on t.claim_uniqueid=c.claim_uniqueid;	
	
 END	

