DROP TABLE if exists kdlab.dim_producer;
CREATE TABLE kdlab.dim_producer
(
producer_id INTEGER NOT NULL identity(0,1) ENCODE RAW
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
,producer_uniqueid VARCHAR(20) NOT NULL ENCODE lzo
,valid_fromdate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
,valid_todate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
,record_version INTEGER NOT NULL ENCODE az64
,isCurrent INTEGER NOT NULL ENCODE az64
,producer_number VARCHAR(20) NOT NULL ENCODE lzo
,producer_name VARCHAR(255) NOT NULL ENCODE lzo
,licenseno VARCHAR(255) NOT NULL ENCODE lzo
,agency_type VARCHAR(11) NOT NULL ENCODE lzo
,address VARCHAR(510) NOT NULL ENCODE lzo
,city VARCHAR(80) NOT NULL ENCODE lzo
,state_cd VARCHAR(5) NOT NULL ENCODE lzo
,zip VARCHAR(10) NOT NULL ENCODE lzo
,phone VARCHAR(20) NOT NULL ENCODE lzo
,fax VARCHAR(15) NOT NULL ENCODE lzo
,email VARCHAR(255) NOT NULL ENCODE lzo
,agency_group VARCHAR(255) NOT NULL ENCODE lzo
,national_name VARCHAR(255) NOT NULL ENCODE lzo
,national_code VARCHAR(20) NOT NULL ENCODE lzo
,territory VARCHAR(50) NOT NULL ENCODE lzo
,territory_manager VARCHAR(50) NOT NULL ENCODE lzo
,dba VARCHAR(255) NOT NULL ENCODE lzo
,producer_status VARCHAR(10) NOT NULL ENCODE lzo
,commission_master VARCHAR(20) NOT NULL ENCODE lzo
,reporting_master VARCHAR(20) NOT NULL ENCODE lzo
,pn_appointment_date DATE NOT NULL ENCODE az64
,profit_sharing_master VARCHAR(20) NOT NULL ENCODE lzo
,producer_master VARCHAR(20) NOT NULL ENCODE lzo
,recognition_tier VARCHAR(100) NOT NULL ENCODE lzo
,rmaddress VARCHAR(100) NOT NULL ENCODE lzo
,rmcity VARCHAR(50) NOT NULL ENCODE lzo
,rmstate VARCHAR(25) NOT NULL ENCODE lzo
,rmzip VARCHAR(25) NOT NULL ENCODE lzo
,new_business_term_date DATE NOT NULL ENCODE az64
,PRIMARY KEY (producer_id)
)
DISTSTYLE KEY
DISTKEY (producer_uniqueid)
SORTKEY (
producer_uniqueid
)
;
