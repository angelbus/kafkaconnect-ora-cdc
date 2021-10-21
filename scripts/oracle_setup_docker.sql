prompt Starting Setup

prompt Check if the ORACLE database is in archive log mode
select log_mode from v$database;

prompt Turn on ARCHIVELOG mode
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

prompt Check if the ORACLE database is in archive log mode
select log_mode from v$database;

prompt Enable supplemental logging for all columns
ALTER SESSION SET CONTAINER=cdb$root;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

-- to be run in the CDB
-- credit : https://docs.confluent.io/kafka-connect-oracle-cdc/current
CREATE ROLE C##CDC_PRIVS;
GRANT CREATE SESSION,
EXECUTE_CATALOG_ROLE,
SELECT ANY TRANSACTION,
SELECT ANY DICTIONARY TO C##CDC_PRIVS;
GRANT SELECT ON SYSTEM.LOGMNR_COL$ TO C##CDC_PRIVS;
GRANT SELECT ON SYSTEM.LOGMNR_OBJ$ TO C##CDC_PRIVS;
GRANT SELECT ON SYSTEM.LOGMNR_USER$ TO C##CDC_PRIVS;
GRANT SELECT ON SYSTEM.LOGMNR_UID$ TO C##CDC_PRIVS;

CREATE USER C##myuser IDENTIFIED BY password CONTAINER=ALL;
GRANT C##CDC_PRIVS TO C##myuser CONTAINER=ALL;
ALTER USER C##myuser QUOTA UNLIMITED ON sysaux;
ALTER USER C##myuser SET CONTAINER_DATA = (CDB$ROOT, ORCLPDB1) CONTAINER=CURRENT;

ALTER SESSION SET CONTAINER=CDB$ROOT;
GRANT CREATE SESSION, ALTER SESSION, SET CONTAINER, LOGMINING, EXECUTE_CATALOG_ROLE TO C##myuser CONTAINER=ALL;
GRANT SELECT ON GV_$DATABASE TO C##myuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO C##myuser CONTAINER=ALL;
GRANT SELECT ON GV_$ARCHIVED_LOG TO C##myuser CONTAINER=ALL;
GRANT CONNECT TO C##myuser CONTAINER=ALL;
GRANT CREATE TABLE TO C##myuser CONTAINER=ALL;
GRANT CREATE SEQUENCE TO C##myuser CONTAINER=ALL;
GRANT CREATE TRIGGER TO C##myuser CONTAINER=ALL;

ALTER SESSION SET CONTAINER=cdb$root;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

GRANT FLASHBACK ANY TABLE TO C##myuser;
GRANT FLASHBACK ANY TABLE TO C##myuser container=all;


prompt Create some objects
CREATE TABLE C##MYUSER.emp
(
    i INTEGER GENERATED BY DEFAULT AS IDENTITY,
    name VARCHAR2(100),
    PRIMARY KEY (i)
) tablespace sysaux;
    
insert into C##MYUSER.emp (name) values ('Bob');
insert into C##MYUSER.emp (name) values ('Jane');
insert into C##MYUSER.emp (name) values ('Mary');
insert into C##MYUSER.emp (name) values ('Alice');

prompt All Done

exit;

