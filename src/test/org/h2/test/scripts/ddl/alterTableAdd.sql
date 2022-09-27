-- Copyright 2004-2021 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(B INT);
> ok

ALTER TABLE TEST ADD C INT;
> ok

ALTER TABLE TEST ADD COLUMN D INT;
> ok

ALTER TABLE TEST ADD IF NOT EXISTS B INT;
> ok

ALTER TABLE TEST ADD IF NOT EXISTS E INT;
> ok

ALTER TABLE IF EXISTS TEST2 ADD COLUMN B INT;
> ok

ALTER TABLE TEST ADD B1 INT AFTER B;
> ok

ALTER TABLE TEST ADD B2 INT BEFORE C;
> ok

ALTER TABLE TEST ADD (C1 INT, C2 INT) AFTER C;
> ok

ALTER TABLE TEST ADD (C3 INT, C4 INT) BEFORE D;
> ok

ALTER TABLE TEST ADD A2 INT FIRST;
> ok

ALTER TABLE TEST ADD (A INT, A1 INT) FIRST;
> ok

SELECT * FROM TEST;
> A A1 A2 B B1 B2 C C1 C2 C3 C4 D E
> - -- -- - -- -- - -- -- -- -- - -
> rows: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT NOT NULL, B INT);
> ok

-- column B may be null
ALTER TABLE TEST ADD (CONSTRAINT PK_B PRIMARY KEY (B));
> exception COLUMN_MUST_NOT_BE_NULLABLE_1

ALTER TABLE TEST ADD (CONSTRAINT PK_A PRIMARY KEY (A));
> ok

ALTER TABLE TEST ADD (C INT AUTO_INCREMENT UNIQUE, CONSTRAINT U_B UNIQUE (B), D INT UNIQUE);
> ok

INSERT INTO TEST(A, B, D) VALUES (11, 12, 14);
> update count: 1

SELECT * FROM TEST;
> A  B  C D
> -- -- - --
> 11 12 1 14
> rows: 1

INSERT INTO TEST VALUES (11, 20, 30, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 12, 30, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 1, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 30, 14);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 30, 40);
> update count: 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST();
> ok

ALTER TABLE TEST ADD A INT CONSTRAINT PK_1 PRIMARY KEY;
> ok

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;
> CONSTRAINT_NAME CONSTRAINT_TYPE
> --------------- ---------------
> PK_1            PRIMARY KEY
> rows: 1

DROP TABLE TEST;
> ok

CREATE TABLE PARENT(ID INT);
> ok

CREATE INDEX PARENT_ID_IDX ON PARENT(ID);
> ok

CREATE TABLE CHILD(ID INT PRIMARY KEY, P INT);
> ok

ALTER TABLE CHILD ADD CONSTRAINT CHILD_P_FK FOREIGN KEY (P) REFERENCES PARENT(ID);
> exception CONSTRAINT_NOT_FOUND_1

SET MODE MySQL;
> ok

ALTER TABLE CHILD ADD CONSTRAINT CHILD_P_FK FOREIGN KEY (P) REFERENCES PARENT(ID);
> ok

SET MODE Regular;
> ok

INSERT INTO PARENT VALUES 1, 1;
> exception DUPLICATE_KEY_1

DROP TABLE CHILD, PARENT;
> ok

CREATE TABLE PARENT(ID INT CONSTRAINT P1 PRIMARY KEY);
> ok

CREATE TABLE CHILD(ID INT CONSTRAINT P2 PRIMARY KEY, CHILD INT CONSTRAINT C REFERENCES PARENT);
> ok

ALTER TABLE PARENT DROP CONSTRAINT P1 RESTRICT;
> exception CONSTRAINT_IS_USED_BY_CONSTRAINT_2

ALTER TABLE PARENT DROP CONSTRAINT P1 RESTRICT;
> exception CONSTRAINT_IS_USED_BY_CONSTRAINT_2

ALTER TABLE PARENT DROP CONSTRAINT P1 CASCADE;
> ok

DROP TABLE PARENT, CHILD;
> ok

CREATE TABLE A(A TIMESTAMP PRIMARY KEY, B INT ARRAY UNIQUE, C TIME ARRAY UNIQUE);
> ok

CREATE TABLE B(A TIMESTAMP WITH TIME ZONE, B DATE, C INT ARRAY, D TIME ARRAY, E TIME WITH TIME ZONE ARRAY);
> ok

ALTER TABLE B ADD FOREIGN KEY(A) REFERENCES A(A);
> exception UNCOMPARABLE_REFERENCED_COLUMN_2

ALTER TABLE B ADD FOREIGN KEY(B) REFERENCES A(A);
> ok

ALTER TABLE B ADD FOREIGN KEY(C) REFERENCES A(B);
> ok

ALTER TABLE B ADD FOREIGN KEY(C) REFERENCES A(C);
> exception TYPES_ARE_NOT_COMPARABLE_2

ALTER TABLE B ADD FOREIGN KEY(D) REFERENCES A(B);
> exception UNCOMPARABLE_REFERENCED_COLUMN_2

ALTER TABLE B ADD FOREIGN KEY(D) REFERENCES A(C);
> ok

ALTER TABLE B ADD FOREIGN KEY(E) REFERENCES A(B);
> exception UNCOMPARABLE_REFERENCED_COLUMN_2

ALTER TABLE B ADD FOREIGN KEY(E) REFERENCES A(C);
> exception UNCOMPARABLE_REFERENCED_COLUMN_2

DROP TABLE B, A;
> ok

CREATE TABLE PARENT(ID INT PRIMARY KEY, K INT UNIQUE);
> ok

CREATE TABLE CHILD(ID INT PRIMARY KEY, P INT GENERATED ALWAYS AS (ID));
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON DELETE CASCADE;
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON DELETE RESTRICT;
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON DELETE NO ACTION;
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON DELETE SET DEFAULT;
> exception GENERATED_COLUMN_CANNOT_BE_UPDATABLE_BY_CONSTRAINT_2

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON DELETE SET NULL;
> exception GENERATED_COLUMN_CANNOT_BE_UPDATABLE_BY_CONSTRAINT_2

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON UPDATE CASCADE;
> exception GENERATED_COLUMN_CANNOT_BE_UPDATABLE_BY_CONSTRAINT_2

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON UPDATE RESTRICT;
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON UPDATE NO ACTION;
> ok

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON UPDATE SET DEFAULT;
> exception GENERATED_COLUMN_CANNOT_BE_UPDATABLE_BY_CONSTRAINT_2

ALTER TABLE CHILD ADD FOREIGN KEY(P) REFERENCES PARENT(K) ON UPDATE SET NULL;
> exception GENERATED_COLUMN_CANNOT_BE_UPDATABLE_BY_CONSTRAINT_2

DROP TABLE CHILD, PARENT;
> ok

CREATE TABLE T1(B INT, G INT GENERATED ALWAYS AS (B + 1) UNIQUE);
> ok

CREATE TABLE T2(A INT, G INT REFERENCES T1(G) ON UPDATE CASCADE);
> ok

INSERT INTO T1(B) VALUES 1;
> update count: 1

INSERT INTO T2 VALUES (1, 2);
> update count: 1

TABLE T2;
> A G
> - -
> 1 2
> rows: 1

UPDATE T1 SET B = 2;
> update count: 1

TABLE T2;
> A G
> - -
> 1 3
> rows: 1

DROP TABLE T2, T1;
> ok

CREATE SCHEMA S1;
> ok

CREATE TABLE S1.T1(ID INT PRIMARY KEY);
> ok

CREATE SCHEMA S2;
> ok

CREATE TABLE S2.T2(ID INT, FK INT REFERENCES S1.T1(ID));
> ok

SELECT CONSTRAINT_SCHEMA, CONSTRAINT_TYPE, TABLE_SCHEMA, TABLE_NAME, INDEX_SCHEMA
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA LIKE 'S%';
> CONSTRAINT_SCHEMA CONSTRAINT_TYPE TABLE_SCHEMA TABLE_NAME INDEX_SCHEMA
> ----------------- --------------- ------------ ---------- ------------
> S1                PRIMARY KEY     S1           T1         S1
> S2                FOREIGN KEY     S2           T2         S2
> rows: 2

SELECT INDEX_SCHEMA, TABLE_SCHEMA, TABLE_NAME, INDEX_TYPE_NAME, IS_GENERATED FROM INFORMATION_SCHEMA.INDEXES
    WHERE TABLE_SCHEMA LIKE 'S%';
> INDEX_SCHEMA TABLE_SCHEMA TABLE_NAME INDEX_TYPE_NAME IS_GENERATED
> ------------ ------------ ---------- --------------- ------------
> S1           S1           T1         PRIMARY KEY     TRUE
> S2           S2           T2         INDEX           TRUE
> rows: 2

SELECT INDEX_SCHEMA, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.INDEX_COLUMNS
    WHERE TABLE_SCHEMA LIKE 'S%';
> INDEX_SCHEMA TABLE_SCHEMA TABLE_NAME COLUMN_NAME
> ------------ ------------ ---------- -----------
> S1           S1           T1         ID
> S2           S2           T2         FK
> rows: 2

@reconnect

DROP SCHEMA S2 CASCADE;
> ok

DROP SCHEMA S1 CASCADE;
> ok

EXECUTE IMMEDIATE 'CREATE TABLE TEST(' || (SELECT LISTAGG('C' || X || ' INT') FROM SYSTEM_RANGE(1, 16384)) || ')';
> ok

ALTER TABLE TEST ADD COLUMN(X INTEGER);
> exception TOO_MANY_COLUMNS_1

DROP TABLE TEST;
> ok

CREATE MEMORY TABLE TEST(ID BIGINT NOT NULL);
> ok

ALTER TABLE TEST ADD PRIMARY KEY(ID);
> ok

SELECT INDEX_TYPE_NAME, IS_GENERATED FROM INFORMATION_SCHEMA.INDEXES WHERE TABLE_NAME = 'TEST';
> INDEX_TYPE_NAME IS_GENERATED
> --------------- ------------
> PRIMARY KEY     TRUE
> rows: 1

CALL DB_OBJECT_SQL('INDEX', 'PUBLIC', 'PRIMARY_KEY_2');
>> CREATE PRIMARY KEY "PUBLIC"."PRIMARY_KEY_2" ON "PUBLIC"."TEST"("ID")

SCRIPT NODATA NOPASSWORDS NOSETTINGS NOVERSION;
> SCRIPT
> -------------------------------------------------------------------------------------
> CREATE USER IF NOT EXISTS "SA" PASSWORD '' ADMIN;
> CREATE MEMORY TABLE "PUBLIC"."TEST"( "ID" BIGINT NOT NULL );
> ALTER TABLE "PUBLIC"."TEST" ADD CONSTRAINT "PUBLIC"."CONSTRAINT_2" PRIMARY KEY("ID");
> -- 0 +/- SELECT COUNT(*) FROM PUBLIC.TEST;
> rows (ordered): 4

@reconnect

SELECT INDEX_TYPE_NAME, IS_GENERATED FROM INFORMATION_SCHEMA.INDEXES WHERE TABLE_NAME = 'TEST';
> INDEX_TYPE_NAME IS_GENERATED
> --------------- ------------
> PRIMARY KEY     TRUE
> rows: 1

DROP TABLE TEST;
> ok
