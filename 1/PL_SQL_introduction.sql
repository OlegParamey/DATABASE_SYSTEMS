--1. Write an anonymous block that displays the message "Hello mission!".

BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello mission');
END;
/

--2. Create an anonymous block containing declarations of four variables and one
-- constant of different data types. Initialize some of the variables and the
-- constant with values. In the executable section, display the values of the variables.
DECLARE
  v_station_name VARCHAR2(50);
  v_station_no NUMBER(3,0) DEFAULT 1;
  v_inspection_date DATE := Sysdate;
  v_inspection_interval INTERVAL YEAR TO MONTH;
  cn_main_hub CONSTANT NUMBER(3,0) := 331;
BEGIN
  v_station_name := 'Alpha';
  v_inspection_interval := interval '1-6' YEAR TO MONTH;
  DBMS_OUTPUT.PUT_LINE(v_station_name||' station number: '||v_station_no||' was inspected on '||To_char(v_inspection_date,'DD/MM/YYYY')||
  '. Next inspection expected in '||v_inspection_interval||' (years and months). Starting with hub: '||cn_main_hub );
END;
/

--3. Within an anonymous block, declare a record type copying column types
-- from any table and a variable of that record type. In the executable section,
-- assign values to the fields of the record variable and display them.

DECLARE
  TYPE r_astronaut IS RECORD(
    f_f_name employees.FIRST_NAME%TYPE,
    f_l_name employees.LAST_NAME%TYPE,
    f_salary employees.SALARY%TYPE
  );
  vr_astronaut r_astronaut;
BEGIN
  vr_astronaut.f_f_name := 'Buzz';
  vr_astronaut.f_l_name := 'Lighter';
  vr_astronaut.f_salary := 10000;

  DBMS_OUTPUT.PUT_LINE('Did '||vr_astronaut.f_f_name||' '||vr_astronaut.f_l_name||' get $'||vr_astronaut.f_salary||' a month?');

END;
/  

--4. Create a record type based on a row of a selected table. Assign values to
-- the record variable and display them.

DESC employees;

DECLARE
  vr_astronaut employees%ROWTYPE;
BEGIN
  vr_astronaut.first_name := 'Buzz';
  vr_astronaut.last_name := 'Lighter';
  vr_astronaut.salary := 10000;
  DBMS_OUTPUT.PUT_LINE('Did '||vr_astronaut.first_name||' '||vr_astronaut.last_name||' get $'||vr_astronaut.salary||' a month?');
END;
/

--5. Create a record type based on a row of a selected table. Retrieve values
-- into it using a query (only one row!) and display them.

SELECT * FROM employees WHERE EMPLOYEE_ID = 200;

DECLARE
  vr_astronaut employees%ROWTYPE;
BEGIN
  SELECT * INTO vr_astronaut FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;
  DBMS_OUTPUT.PUT_LINE('Was '||vr_astronaut.first_name||' '||vr_astronaut.last_name||' an astronaut?');
END;
/  

--6. Create a record type based on a row of a selected table and a regular variable
-- with a type copied from one attribute of the same table. In the executable
-- section assign values to the record variable. Modify any row of the table
-- using UPDATE and the values from the record variable. At the same time return
-- a value (RETURNING INTO clause) into the additional variable.

DECLARE
  vr_astronaut employees%ROWTYPE;
  v_salary employees.salary%TYPE;
BEGIN

  SELECT * INTO vr_astronaut FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;
    vr_astronaut.commission_pct := 0.3;
    vr_astronaut.last_name := 'Grace';
    vr_astronaut.salary := 12500;

    UPDATE EMPLOYEES SET ROW = vr_astronaut WHERE EMPLOYEE_ID = 200
      RETURNING salary INTO v_salary; 

    DBMS_OUTPUT.PUT_LINE('Astronaut '||vr_astronaut.first_name||' '||vr_astronaut.last_name||' got a $'||v_salary||' raise?');
END;
/  

-- SELECT * from EMPLOYEES WHERE EMPLOYEE_ID = 200;

--7. Use the IF conditional statement to display information based on
-- a row from a selected table. Declare appropriate variables.

DECLARE 
  vr_astronaut employees%ROWTYPE;

BEGIN

  SELECT * INTO vr_astronaut FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;

  IF vr_astronaut.salary < 10000 THEN
    DBMS_OUTPUT.PUT_LINE('The pay of '||vr_astronaut.first_name||' is too low.');

  ELSIF vr_astronaut.salary BETWEEN 10000 AND 15000 THEN 
    DBMS_OUTPUT.PUT_LINE('This is the average pay for '||vr_astronaut.first_name||'.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('That''s good pay for '||vr_astronaut.first_name||'.');
  END IF;
END;
/  

DECLARE 
  vr_astronaut employees%ROWTYPE;

BEGIN

  SELECT * INTO vr_astronaut FROM EMPLOYEES WHERE EMPLOYEE_ID = 100;

  IF vr_astronaut.salary < 10000 THEN
    DBMS_OUTPUT.PUT_LINE('The pay of '||vr_astronaut.first_name||' is too low.');

  ELSIF vr_astronaut.salary BETWEEN 10000 AND 15000 THEN 
    DBMS_OUTPUT.PUT_LINE('This is the average pay for '||vr_astronaut.first_name||'.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('That''s good pay for '||vr_astronaut.first_name||'.');
  END IF;
END;
/  

--8. Retrieve any string from the database. Display it vertically,
-- letter by letter, using three different types of loops.

-- LOOP
DECLARE
  v_name employees.LAST_NAME%TYPE;
  v_name_length NUMBER(3,0);
  v_i NUMBER(3,0) := 1;
BEGIN
  SELECT last_name INTO v_name FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;
  DBMS_OUTPUT.PUT_LINE(v_name);
  v_name_length := Length(v_name);

  LOOP
    DBMS_OUTPUT.PUT_LINE(Substr(v_name, v_i, 1));
    v_i := v_i + 1;
    EXIT WHEN v_i > v_name_length;
  END LOOP;

END;
/

-- WHILE LOOP
DECLARE
  v_name employees.LAST_NAME%TYPE;
  v_name_length NUMBER(3,0);
  v_i NUMBER(3,0) := 1;
BEGIN
  SELECT last_name INTO v_name FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;
  DBMS_OUTPUT.PUT_LINE(v_name);
  v_name_length := Length(v_name);

  WHILE v_i <= v_name_length LOOP
    DBMS_OUTPUT.PUT_LINE(Substr(v_name, v_i, 1));
    v_i := v_i + 1;
  END LOOP;
END;
/

-- FOR LOOP
DECLARE
  v_name employees.LAST_NAME%TYPE;
  v_name_length NUMBER(3,0);
  v_i NUMBER(3,0) := 1;
BEGIN
  SELECT last_name INTO v_name FROM EMPLOYEES WHERE EMPLOYEE_ID = 200;
  DBMS_OUTPUT.PUT_LINE(v_name);
  v_name_length := Length(v_name);

  FOR v_i IN 1..v_name_length LOOP
    DBMS_OUTPUT.PUT_LINE(Substr(v_name, v_i, 1));
  END LOOP;
END;
/

