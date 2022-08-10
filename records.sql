-- this code is to populate the database
-- Members : Krish Weragalaarachchi, Douglas Baker

-- we have done it in two steps

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- step 1: make tables to store csv files and these tbales can be later use to populate the database
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

-- making tables for csv files and populate them
-- for deparment.csv file
DROP TABLE IF EXISTS department;
CREATE TABLE department(
    department_name varchar(256),
    department_code varchar(10),
    address varchar(256),
    phone varchar(20)
);
-- execute the following in commandline 
\copy department from 'departments.csv' DELIMITER ',' CSV HEADER;

-- for PositionCodes.csv file
DROP TABLE IF EXISTS positions1;
CREATE TABLE positions1(
    position_name varchar(256),
    position_code varchar(10) 
);
-- execute the following in commandline 
\copy positions1 from 'PositionCodes.csv' DELIMITER ',' CSV HEADER;

-- for WindyCityEmployees.csv file
DROP TABLE IF EXISTS employee1;
CREATE TABLE employee1(
    employee_id int,
    last_name varchar(256),
    first_name varchar(256),
    position_code varchar(10),
    department_code varchar(10),
    salary float,
    start_year int
);
-- execute the following in commandline 
\copy employee1 from 'WindyCityEmployees.csv' DELIMITER ',' CSV HEADER;

-- for more data of employees from HR_Data_and_AccidentCodes.csv file
DROP TABLE IF EXISTS employee2;
CREATE TABLE employee2(
    employee_id int,
    projects int,
    average_hours int,
    work_accidents int,
    promotions int,
    salary_category varchar(10)
);
-- execute the following in commandline 
\copy employee2 from 'HR_Data_and_AccidentCodes.csv' DELIMITER ',' CSV HEADER;

-- for accidents.csv file
DROP TABLE IF EXISTS accident_data;
CREATE TABLE accident_data(
    employee_id int,
    accident_type varchar(10),
    accident_date date,
    accident_id int
);
-- execute the following in commandline 
\copy accident_data from 'accidents.csv' DELIMITER ',' CSV HEADER;

-- complaint.csv file. complaint_code column has spces and have to remove them
DROP TABLE IF EXISTS complaint_data;
CREATE TABLE complaint_data(
    complaint_id float,
    complaint_code varchar(10),
    employee_id float,
    resolution_status varchar(10),
    resolution_code float,
    compliant_date date
);
-- execute the following in commandline 
\copy complaint_data from 'Complaint.csv' DELIMITER ',' CSV HEADER;

-- trimiing trailing spaces from complaint_code column--
UPDATE complaint_data SET complaint_code = TRIM (BOTH FROM complaint_code);

-- for ComplaintCode.csv file
DROP TABLE IF EXISTS complaint_codes;
CREATE TABLE complaint_codes(
    complaint_code varchar(10),
    complaint_description varchar(256),
    complaint_class varchar(256)
);
-- execute the following in commandline 
\copy complaint_codes from 'ComplaintCodes.csv' DELIMITER ',' CSV HEADER;


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- step 2: populate the database using above created tables
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

-- insert data to departments table from department ( departmnets.csv)

INSERT INTO departments(department_name,department_code,address,phone) 
SELECT DISTINCT department_name::varchar,department_code::varchar,
address::varchar,phone::varchar FROM department;

----------------------------------------------------------------------------------------
-- insert data to positions table from positions1  (PositionCodes.csv)

INSERT INTO positions(position_code,position_name) 
SELECT DISTINCT position_code::varchar,position_name::varchar FROM  positions1;

----------------------------------------------------------------------------------------
-- insert data to employees table from employee1(WindyCityEmployees.csv) and employee2(HR_Data_and_AccidentCodes.csv)

INSERT INTO employees(employee_id,last_name,first_name,position_code,
department_code,salary,start_year) 
SELECT DISTINCT employee_id::int,last_name::varchar,first_name::varchar,
position_code::varchar,department_code::varchar,salary::float,start_year::int FROM employee1;

UPDATE employees SET salary_category = employee2.salary_category 
FROM employee2 WHERE employees.employee_id = employee2.employee_id;
UPDATE employees SET projects = employee2.projects
FROM employee2 WHERE employees.employee_id = employee2.employee_id;
UPDATE employees SET promotions = employee2.promotions
FROM employee2 WHERE employees.employee_id = employee2.employee_id;

----------------------------------------------------------------------------------------
-- insert data to accidents table from accident_data  (accidents.csv)
-- this table is no use for quering as it only has one attribute --

INSERT INTO accidents(accident_type)
SELECT DISTINCT accident_type::varchar from accident_data;

-----------------------------------------------------------------------------------------
-- insert data to involved_in table from accident_data (accidents.csv)

INSERT INTO involved_in(employee_id,accident_type,accident_date,accident_id)
SELECT DISTINCT employee_id::int,accident_type::varchar,accident_date::date,accident_id::int FROM accident_data;

-----------------------------------------------------------------------------------------
-- insert data to c_codes table from complaint_codes (ComplaintCodes.csv)

INSERT INTO c_codes(complaint_code,complaint_description,complaint_class)
SELECT DISTINCT complaint_code::varchar, complaint_description::varchar, complaint_class::varchar FROM complaint_codes;
UPDATE c_codes SET complaint_code = TRIM (BOTH FROM complaint_code);

-----------------------------------------------------------------------------------------
-- insert data to receivedtest table from complaint_data (Complaint.csv)

INSERT INTO receivedtest(complaint_id,employee_id,complaint_code,c_date,resolution_status,resolution_code)
SELECT DISTINCT complaint_id::int,employee_id::int,complaint_code::varchar,compliant_date::date,
resolution_status::varchar,resolution_code::int FROM complaint_data;


































