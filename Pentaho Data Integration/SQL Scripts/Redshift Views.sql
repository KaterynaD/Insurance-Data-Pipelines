CREATE OR REPLACE VIEW dw_mga.vdim_claimstatus
AS SELECT dim_status.status_id AS claimstatus_id, dim_status.stat_4sightbistatuscd AS clmst_4sightbistatuscd, dim_status.stat_statuscd AS clmst_statuscd, dim_status.stat_status AS clmst_status, dim_status.stat_substatuscd AS clmst_substatuscd, dim_status.stat_substatus AS clmst_substatus
FROM dw_mga.dim_status
WHERE dim_status.STAT_CATEGORY = 'claim':;


CREATE OR REPLACE VIEW dw_mga.vdim_primaryriskaddress
AS SELECT dim_address.address_id AS primaryriskaddress_id, dim_address.address1 AS prskadd_address1, dim_address.address2 AS prskadd_address2, dim_address.county AS prskadd_county, dim_address.city AS prskadd_city, dim_address.state AS prskadd_state, dim_address.postalcode AS prskadd_postalcode, dim_address.source_system, dim_address.loaddate
FROM dw_mga.dim_address;



CREATE OR REPLACE VIEW dw_mga_finance.vw_claim_bordereau
AS SELECT dpr.producttypecd AS "program code", fc.month_id AS "bordereau month", dcom.carriercd AS "writing company", dp.policynumber AS "policy number",
CASE
WHEN ((di.first_name::text || ' '::text) || di.last_name::text) = '~'::text THEN di.commercialname::text
ELSE (di.first_name::text || ' '::text) || di.last_name::text
END AS "insured name", di.address1 AS "insured address", di.city AS "insured city", di.state AS "insured state", di.postalcode AS "insured zip", dp.expirationdate AS "policy expiration date", dp.effectivedate AS "policy effective date", 'Occurence' AS "policy type", fc.claimnumber AS "claim number", dcl.claimant_number AS "claimant number", dcov.cov_code AS feature, dcl.name AS "claimant name", to_date(fc.dateofloss_id::text, 'yyyymmdd'::text) AS "date of loss", to_date(fc.datereported_id::text, 'yyyymmdd'::text) AS "date reported", cl.closeddt AS "date closed", re.reopendt AS "date reopened", dce.coveragetype AS coverage, dc.losscausecd AS peril,
CASE
WHEN db.typeofstructure::text = 'DW'::text THEN 'Dwelling'::character varying
WHEN db.typeofstructure::text = 'AP'::text THEN 'Apartment'::character varying
WHEN db.typeofstructure::text = 'CD'::text THEN 'Condo'::character varying
WHEN db.typeofstructure::text = 'CO'::text THEN 'Co-op'::character varying
WHEN db.typeofstructure::text = 'MH'::text THEN 'Mobile Home'::character varying
WHEN db.typeofstructure::text = 'RH'::text THEN 'Row House'::character varying
WHEN db.typeofstructure::text = 'TH'::text THEN 'Townhouse'::character varying
ELSE db.typeofstructure
END AS "property type", dv.vehbodytypecd AS "vehicle type", dd.cov_deductible1 AS deductible, dlim.cov_limit1 AS "limit", 'N/A' AS "location name", db.addr1 AS "location address", db.city AS "location city", db.stateprovcd AS "location zip", vpa.prskadd_state AS "risk state", dc.shortdesc AS "loss summary", dc.description AS "description of loss", dcat.cat_name AS "cat name", dcat.cat_isoserial AS "cat isicode", dcl.attorneyrepind AS "attorney rep", dcl.suitfiledind AS "suit filed", dcl.litigationcaption AS "litigation caption", 'N/A' AS "notice only", 'N/A' AS "refer to carrier", vcs.clmst_status AS "claim open/closed", 'N/A' AS denial, dcl.medicarebeneficiarycd AS "medicare/cms", 'N/A' AS "e&o / bad faith", sum(fc.loss_pd_amt_itd) AS "itd paid total loss", sum(
CASE
WHEN dcov.cov_code::text = 'MEDPAY'::text THEN fc.loss_pd_amt_itd
ELSE 0::numeric
END) AS "itd paid loss medical only", sum(fc.alc_exp_pd_amt_itd + fc.ualc_exp_pd_amt_itd) AS "itd paid total alae", sum(fc.ualc_exp_pd_amt_itd) AS "itd paid alae legal fees only", sum(fc.loss_rsrv_chng_amt_itd) AS "case reserve loss", sum(fc.alc_exp_rsrv_chng_amt_itd) AS "case reserve alae", sum(fc.salvage_recv_chng_amt_itd) AS "itd paid salvage", sum(fc.subro_paid_chng_amt_itd) AS "itd paid subrogation", sum(fc.dedrecov_recv_chng_amt_itd) AS "itd paid other recovery", sum(fc.loss_pd_amt_itd) + sum(fc.alc_exp_pd_amt_itd + fc.ualc_exp_pd_amt_itd) + sum(fc.loss_rsrv_chng_amt_itd) + sum(fc.alc_exp_rsrv_chng_amt_itd) - sum(fc.salvage_recv_chng_amt_itd) - sum(fc.subro_paid_chng_amt_itd) - sum(fc.dedrecov_recv_chng_amt_itd) AS "total incurred loss & alae", sum(fc.salvage_rsrv_chng_amt_itd) AS "salvage reserve", sum(fc.subro_rsrv_chng_amt_itd) AS "subrogation reserve", sum(fc.dedrecov_rsrv_chng_amt_itd) AS "other recovery reserve"
FROM dw_mga.fact_claim fc
JOIN dw_mga.dim_insured di ON fc.firstinsured_id = di.insured_id
LEFT JOIN dw_mga.dim_policy dp ON fc.policy_id = dp.policy_id
JOIN dw_mga.dim_claim dc ON fc.claim_id = dc.claim_id
JOIN dw_mga.dim_claimant dcl ON fc.claimant_id = dcl.claimant_id
JOIN dw_mga.vdim_claimstatus vcs ON fc.claimstatus_id = vcs.claimstatus_id
JOIN dw_mga.dim_coverage dcov ON fc.coverage_id = dcov.coverage_id
LEFT JOIN dw_mga.dim_coverageextension dce ON dcov.coverage_id = dce.coverage_id
JOIN dw_mga.dim_catastrophe dcat ON fc.catastrophe_id = dcat.catastrophe_id
JOIN dw_mga.dim_building db ON fc.building_id = db.building_id
JOIN dw_mga.dim_vehicle dv ON fc.vehicle_id = dv.vehicle_id
JOIN dw_mga.dim_deductible dd ON fc.deductible_id = dd.deductible_id
JOIN dw_mga.dim_limit dlim ON fc.limit_id = dlim.limit_id
JOIN dw_mga.dim_product dpr ON fc.product_id = dpr.product_id
JOIN dw_mga.dim_company dcom ON fc.company_id = dcom.company_id
JOIN dw_mga.vdim_primaryriskaddress vpa ON fc.primaryriskaddress_id = vpa.primaryriskaddress_id
LEFT JOIN ( SELECT dim_reservestatus.reservestatus_id, dim_reservestatus.systemid, dim_reservestatus.claim_uniqueid, dim_reservestatus.bookdt AS reopendt
FROM dw_mga.dim_reservestatus
WHERE dim_reservestatus.current_flag = 1::boolean AND dim_reservestatus.indemnity::text = 'Reopen'::text) re ON fc.reservestatus_id = re.reservestatus_id
LEFT JOIN ( SELECT dim_reservestatus.reservestatus_id, dim_reservestatus.systemid, dim_reservestatus.claim_uniqueid, dim_reservestatus.bookdt AS closeddt
FROM dw_mga.dim_reservestatus
WHERE dim_reservestatus.current_flag = 1::boolean AND dim_reservestatus.indemnity::text = 'Closed'::text) cl ON fc.reservestatus_id = cl.reservestatus_id
GROUP BY dpr.producttypecd, fc.month_id, dcom.carriercd, dp.policynumber,
CASE
WHEN ((di.first_name::text || ' '::text) || di.last_name::text) = '~'::text THEN di.commercialname::text
ELSE (di.first_name::text || ' '::text) || di.last_name::text
END, di.address1, di.city, di.state, di.postalcode, dp.expirationdate, dp.effectivedate, fc.claimnumber, dcl.claimant_number, dcov.cov_code, dcl.name, to_date(fc.dateofloss_id::text, 'yyyymmdd'::text), to_date(fc.datereported_id::text, 'yyyymmdd'::text), cl.closeddt, re.reopendt, dce.coveragetype, dc.losscausecd,
CASE
WHEN db.typeofstructure::text = 'DW'::text THEN 'Dwelling'::character varying
WHEN db.typeofstructure::text = 'AP'::text THEN 'Apartment'::character varying
WHEN db.typeofstructure::text = 'CD'::text THEN 'Condo'::character varying
WHEN db.typeofstructure::text = 'CO'::text THEN 'Co-op'::character varying
WHEN db.typeofstructure::text = 'MH'::text THEN 'Mobile Home'::character varying
WHEN db.typeofstructure::text = 'RH'::text THEN 'Row House'::character varying
WHEN db.typeofstructure::text = 'TH'::text THEN 'Townhouse'::character varying
ELSE db.typeofstructure
END, dv.vehbodytypecd, dd.cov_deductible1, dlim.cov_limit1, db.addr1, db.city, db.stateprovcd, vpa.prskadd_state, dc.shortdesc, dc.description, dcat.cat_name, dcat.cat_isoserial, dcl.attorneyrepind, dcl.suitfiledind, dcl.litigationcaption, vcs.clmst_status, dcl.medicarebeneficiarycd;

CREATE OR REPLACE VIEW dw_mga_finance.vw_policy_bordereau
AS SELECT prd.name AS "program code", dt.month_id AS "bordereau month", dc.carriercd AS "writing company", sum(
CASE
WHEN covx.feetype IS NULL THEN f.amount
ELSE 0::numeric
END) AS "written premium", sum(
CASE
WHEN covx.feetype IS NOT NULL AND covx.feetype::text = 'PolicyFee'::text THEN f.amount
ELSE 0::numeric
END) AS "policy fee", sum(
CASE
WHEN covx.feetype IS NOT NULL AND covx.feetype::text = 'OtherFee'::text THEN f.amount
ELSE 0::numeric
END) AS "other fee", sum(f.commission_amount) AS "retail commission", round(sum(
CASE
WHEN covx.feetype IS NULL THEN f.amount
ELSE 0::numeric
END) * 0.15, 2) AS "mga commission", round(sum(f.commission_amount) + sum(
CASE
WHEN covx.feetype IS NULL THEN f.amount
ELSE 0::numeric
END) * 0.15, 2) AS "mga and retail commissions", p.effectivedate AS "policy effective date", p.expirationdate AS "expiration date", to_date(f.transactiondate_id::text, 'yyyymmdd'::text) AS "transaction date",
CASE
WHEN dpt.ptrans_name::text = 'Cancellation'::text OR dpt.ptrans_name::text = 'Endorsement'::text THEN to_date(f.transactiondate_id::text, 'yyyymmdd'::text)
ELSE NULL::date
END AS "endorsement/cancellation change date", p.canceldt AS "cancel date", dpt.ptrans_name AS "transaction type",
CASE
WHEN p.payplancd::text !~~ '%full%'::text THEN 'Yes'::text
ELSE 'No'::text
END AS "installment plan", p.payplancd AS "pay plan",
CASE
WHEN covx.covx_asl::text = '~'::character varying::text THEN '0'::character varying
ELSE covx.covx_asl
END AS "annual statement line", prd.lob AS "line of business", covx.coveragetype AS "coverage type", covx.covx_code AS "detailed coverage", covx.feetype, 'Occurence' AS "claims made / occurrence", round((sum(
CASE
WHEN covx.feetype IS NULL THEN f.amount
ELSE 0::numeric
END) + sum(
CASE
WHEN covx.feetype IS NOT NULL AND covx.feetype::text = 'PolicyFee'::text THEN f.amount
ELSE 0.00
END)) * 2.35 / 100::numeric, 2) AS "premium tax", sum(
CASE
WHEN covx.codetype::text = 'Surcharge'::text THEN f.amount
ELSE 0::numeric
END) AS "assessments / surcharges",
CASE
WHEN covx.codetype::text = 'Surcharge'::text THEN covx.covx_code
ELSE NULL::character varying
END AS "assessments / surcharges description", sum(
CASE
WHEN covx.covx_code::text = 'InspectionFee'::text THEN f.amount
ELSE 0.00
END) AS inspection, dlim.cov_limit1 AS "limit 1", dlim.cov_limit2 AS "limit 2", db.bldgnumber AS locations, p.statecd AS "risk state", p.policynumber AS "policy number", p.term AS "policy term", (di.first_name::text || ' '::text) || di.last_name::text AS "insured name", (di.address1::text || ' '::text) ||
CASE
WHEN di.address2::text = '~'::text THEN ''::character varying
ELSE di.address2
END::text AS "insured address", di.city AS "insured city", di.state AS "insured state", di.postalcode AS "insured zip code", 'N/A' AS "location name", db.addr1 AS "location address", db.city AS "location city", db.stateprovcd AS "location state", db.postalcode AS "location zip code", dd.cov_deductible1 AS "policy occurrence deductible", p.priorpolicynumber AS "expiring policy number", dp.address AS "producer broker address", dp.city AS "producer broker city", dp.state_cd AS "producer broker state", dp.zip AS "producer broker zip code"
FROM dw_mga.fact_policytransaction f
JOIN dw_mga.dim_coverage c ON f.coverage_id = c.coverage_id
JOIN dw_mga.dim_coverageextension covx ON c.coverage_id = covx.coverage_id
JOIN dw_mga.dim_policy p ON f.policy_id = p.policy_id
JOIN dw_mga.dim_policytransactiontype dpt ON f.policytransactiontype_id = dpt.policytransactiontype_id
JOIN dw_mga.dim_product prd ON f.product_id = prd.product_id
JOIN dw_mga.dim_limit dlim ON f.limit_id = dlim.limit_id
JOIN dw_mga.dim_deductible dd ON f.deductible_id = dd.deductible_id
JOIN dw_mga.dim_insured di ON f.firstinsured_id = di.insured_id
JOIN dw_mga.dim_building db ON f.building_id = db.building_id
LEFT JOIN dw_mga.dim_producer dp ON f.producer_id = dp.producer_id
JOIN dw_mga.dim_time dt ON f.accountingdate_id = dt.time_id
JOIN dw_mga.dim_company dc ON f.company_id = dc.company_id
GROUP BY prd.name, dt.month_id, dc.carriercd, p.effectivedate, p.expirationdate, to_date(f.transactiondate_id::text, 'yyyymmdd'::text),
CASE
WHEN dpt.ptrans_name::text = 'Cancellation'::text OR dpt.ptrans_name::text = 'Endorsement'::text THEN to_date(f.transactiondate_id::text, 'yyyymmdd'::text)
ELSE NULL::date
END, p.canceldt, dpt.ptrans_name,
CASE
WHEN p.payplancd::text !~~ '%full%'::text THEN 'Yes'::text
ELSE 'No'::text
END, p.payplancd,
CASE
WHEN covx.covx_asl::text = '~'::character varying::text THEN '0'::character varying
ELSE covx.covx_asl
END, prd.lob, covx.coveragetype, covx.covx_code, covx.feetype,
CASE
WHEN covx.codetype::text = 'Surcharge'::text THEN covx.covx_code
ELSE NULL::character varying
END, dlim.cov_limit1, dlim.cov_limit2, db.bldgnumber, p.statecd, p.policynumber, p.term, (di.first_name::text || ' '::text) || di.last_name::text, (di.address1::text || ' '::text) ||
CASE
WHEN di.address2::text = '~'::text THEN ''::character varying
ELSE di.address2
END::text, di.city, di.state, di.postalcode, db.addr1, db.city, db.stateprovcd, db.postalcode, dd.cov_deductible1, p.priorpolicynumber, dp.address, dp.city, dp.state_cd, dp.zip
HAVING sum(f.amount) <> 0::numeric OR sum(f.commission_amount) <> 0::numeric;


CREATE OR REPLACE VIEW dw_mga.dim_ccfr_status
AS SELECT drs.reservestatus_id AS ccfr_stat_key, drs.claimnumber, dc.claimantcd, dc.featurecd,
CASE
WHEN drs.adjustment::text = '~'::text THEN NULL::character varying
ELSE drs.adjustment
END AS adjustment,
CASE
WHEN drs.indemnity::text = '~'::text THEN NULL::character varying
ELSE drs.indemnity
END AS indemnity,
CASE
WHEN drs.defense::text = '~'::text THEN NULL::character varying
ELSE drs.defense
END AS defense,
CASE
WHEN drs.subrogation::text = '~'::text THEN NULL::character varying
ELSE drs.subrogation
END AS subrogation,
CASE
WHEN drs.salvage::text = '~'::text THEN NULL::character varying
ELSE drs.salvage
END AS salvage, drs.adjustment_status_chng, drs.indemnity_status_chng, drs.defense_status_chng, drs.subrogation_status_chng, drs.salvage_status_chng, drs.bookdt, drs.transactionnumber, drs.current_flag, drs.source_system
FROM dw_mga.dim_reservestatus drs
JOIN dw_mga.dim_claim dc ON drs.claim_uniqueid::text = dc.claim_uniqueid::text;
