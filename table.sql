-- excute in postgresql
-- this code creates the database --
-- members : Krish Weragalaarachchi, Douglas Baker

---------------------------------------------------
-- create departments table 

DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments(
    department_name varchar(256) not null,
    department_code varchar(10) not null PRIMARY KEY,
    address varchar(256) not null,
    phone varchar(20) not null
);

----------------------------------------------------
-- create positions table 

DROP TABLE IF EXISTS positions CASCADE;
CREATE TABLE positions(
    position_code varchar(10) not null PRIMARY KEY,
    position_name varchar(256) not null
);

-----------------------------------------------------
-- create employees table 

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees(
    employee_id int not null PRIMARY KEY,
    last_name varchar(256) not null,
    first_name varchar(256) not null,
    position_code varchar(10) not null ,
    department_code varchar(10) not null ,
    salary float not null,
    start_year int not null,
    salary_category varchar(10),
    projects int ,
    promotions int ,
    CONSTRAINT employees_departments_fk FOREIGN KEY(department_code) REFERENCES departments(department_code),
    CONSTRAINT employees_positions_fk FOREIGN KEY(position_code) REFERENCES positions(position_code)
);

-------------------------------------------------------
-- create accidents table (this contains accidentTypes)

DROP TABLE IF EXISTS accidents CASCADE;
CREATE TABLE accidents(
    accident_type varchar(10) not null PRIMARY KEY
);

---------------------------------------------------------
-- create involved_in table 

DROP TABLE IF EXISTS involved_in CASCADE;
CREATE TABLE involved_in(
    employee_id int not null ,
    accident_type varchar(10) not null,
    accident_date date not null, 
    accident_id int not null PRIMARY KEY,
    CONSTRAINT involvedin_employees_fk FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    CONSTRAINT involvedin_accidents_fk FOREIGN KEY(accident_type) REFERENCES accidents(accident_type)
);

----------------------------------------------------------
-- create c_codes table 

DROP TABLE IF EXISTS c_codes CASCADE;
CREATE TABLE c_codes(
    complaint_code varchar(10) not null PRIMARY KEY,
    complaint_description varchar(256) not null,
    complaint_class varchar(256) not null
);

------------------------------------------------------------
-- create receivedtest table 

DROP TABLE IF EXISTS receivedtest CASCADE;
CREATE TABLE receivedtest(
    complaint_id int not null,
    employee_id int not null ,
    complaint_code varchar(10) not null ,
    c_date date not null,
    resolution_status varchar(10) not null,
    resolution_code int not null,
    CONSTRAINT receivedtest_pk PRIMARY KEY(complaint_id,employee_id,complaint_code),
    CONSTRAINT receivedtest_employees_fk FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
    CONSTRAINT receivedtest_ccodes_fk FOREIGN KEY(complaint_code) REFERENCES c_codes(complaint_code)
    
);
























