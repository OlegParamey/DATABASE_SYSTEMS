--1. Implement an anonymous block in which you execute queries returning one row, multiple rows, and zero rows. 
--Handle the appropriate exceptions.

-- SELECT salary FROM employees ORDER BY 1;

DECLARE 
  v_astronaut_id employees.EMPLOYEE_ID%TYPE;
  v_lname employees.LAST_NAME%TYPE;
  v_salary employees.SALARY%TYPE:=2100; --one row
  -- v_salary employees.SALARY%TYPE:=2500; --many rows 
  -- v_salary employees.SALARY%TYPE:=25000; --no rows

begin 
  select employee_id, last_name into v_astronaut_id, v_lname from employees where salary = v_salary;
  DBMS_OUTPUT.PUT_LINE('Astronauts whom earns '||v_salary||': '||v_astronaut_id||'.'||v_lname);
EXCEPTION
  when no_data_found then
    DBMS_OUTPUT.PUT_LINE('No data found');
  when too_many_rows then
    DBMS_OUTPUT.PUT_LINE('Too many rows');
  when OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Other error: '||sqlcode||'-'||sqlerrm);
end;
/


--2. Implement a cursor for any query retrieving a group of rows. Handle the cursor in the full form (using the OPEN, FETCH, and CLOSE statements) and display the query results. Remember to handle exceptions related to cursors.

DECLARE 
  CURSOR c_mission_participants (p_id NUMBER) IS 
    SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = p_id;
  vr_miss_part employees%ROWTYPE;
BEGIN 
  -- CLOSE c_mission_participants; -- error
  OPEN c_mission_participants(50);
  DBMS_OUTPUT.PUT_LINE(q'!We've opened the cursor!');
  -- OPEN c_mission_participants(50); --error
  -- CLOSE  c_mission_participants;
  LOOP 
    FETCH c_mission_participants INTO vr_miss_part;
    EXIT WHEN c_mission_participants%NOTFOUND OR c_mission_participants%NOTFOUND IS NULL;
    DBMS_OUTPUT.PUT_LINE(c_mission_participants%ROWCOUnT||'. '||vr_miss_part.last_name);
    END LOOP;
  DBMS_OUTPUT.PUT_LINE('There are '||c_mission_participants%ROWCOUNT||' astronauts');
  CLOSE c_mission_participants;
    EXCEPTION 
      WHEN cursor_already_open THEN 
        DBMS_OUTPUT.PUT_LINE(q'!Cursor already open!');
        IF(c_mission_participants%ISOPEN) THEN
        CLOSE c_mission_participants;
        DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
        END IF;
      WHEN invalid_cursor THEN  
        DBMS_OUTPUT.PUT_LINE(q'!Invalid cursor!');
        IF(c_mission_participants%ISOPEN) THEN 
          CLOSE c_mission_participants;
          DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
        END IF;
        WHEN OTHERS THEN 
          DBMS_OUTPUT.PUT_LINE('Other error: '||SQLCODE||' '||SQLERRM);
          IF (c_mission_participants%ISOPEN) THEN 
            CLOSE c_mission_participants;
            DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
          END IF;
END;
/

--3. Implement a parameterized cursor for any query retrieving a group of rows. Handle the cursor using a FOR loop and display the query results. Remember to handle exceptions related to cursors.

DECLARE
  CURSOR c_mission_participants (p_id NUMBER := 50) IS 
    SELECT * FROM employees WHERE department_id = p_id;
    -- vr_miss_part employees%ROWTYPE;
    v_count NUMBER (4,0) := 0;
    BEGIN
      FOR vr_miss_part IN c_mission_participants LOOP
        DBMS_OUTPUT.PUT_LINE(c_mission_participants%ROWCOUNT||'.'||vr_miss_part.last_name);
        v_count := v_count + 1;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE(v_count||' astronauts');  
        EXCEPTION
          WHEN cursor_already_open THEN 
            DBMS_OUTPUT.PUT_LINE(q'!Cursor is already open!');
            IF(c_mission_participants%ISOPEN) THEN
              CLOSE c_mission_participants;
              DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
            END IF;
          WHEN invalid_cursor THEN
            DBMS_OUTPUT.PUT_LINE('Invalid cursor');
            IF(c_mission_participants%ISOPEN) THEN
              CLOSE c_mission_participants;
              DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
            END IF;
END;
/

DECLARE 
  CURSOR c_mission_jobs (p_salary NUMBER := 8000) IS  
    SELECT DISTINCT job_id FROM employees WHERE salary > p_salary;
  v_count NUMBER(4,0) := 0;
BEGIN
  FOR vr_miss_j IN c_mission_jobs LOOP
    DBMS_OUTPUT.PUT_LINE(c_mission_jobs%ROWCOUNT||'.'||vr_miss_j.job_id);
    v_count := v_count + 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(v_count||' well paid jobs');
    EXCEPTION 
      WHEN cursor_already_open THEN
        DBMS_OUTPUT.PUT_LINE(q'!Cursor already open!');
        IF(c_mission_jobs%ISOPEN) THEN
          CLOSE c_mission_jobs;
          DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
        END IF;
      WHEN invalid_cursor THEN
        DBMS_OUTPUT.PUT_LINE(q'!Invalid cursor!');
        IF(c_mission_jobs%ISOPEN) THEN
          CLOSE c_mission_jobs;
          DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
        END IF;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Other error: '||SQLCODE||' '||SQLERRM);
        IF(c_mission_jobs%ISOPEN) THEN
          CLOSE c_mission_jobs;
          DBMS_OUTPUT.PUT_LINE(q'!Let's close the cursor!');
        END IF;
END;
/

--4. Implement an anonymous block with handling of a user-defined exception.

DECLARE
e_salary_error EXCEPTION;
v_job_id jobs.job_id%TYPE := 'ST_DAS';
v_job_title jobs.JOB_TITLE%TYPE := 'Data Scientist';
v_min jobs.min_salary%TYPE := 4000;
v_max jobs.MAX_SALARY%TYPE := 10000;
v_min_country NUMBER(6,2) := 4242;
BEGIN
  IF (v_min_country > v_min) THEN
    RAISE e_salary_error;
  ELSE 
    INSERT INTO jobs VALUES(v_job_id, v_job_title, v_min, v_max);
    COMMIT;
  END IF;
  EXCEPTION
    WHEN e_salary_error THEN
      DBMS_OUTPUT.PUT_LINE('Salary is too small.');
    WHEN others THEN
      DBMS_OUTPUT.PUT_LINE('Other error: '||SQLCODE||' '||SQLERRM);
END;
/ 

--raise_application_error
DECLARE
  v_job_id jobs.job_id%TYPE := 'ST_DAS';
  v_job_title jobs.job_title%TYPE := 'Data Scientist';
  v_min jobs.min_salary%TYPE := 4000;
  v_max jobs.max_salary%TYPE := 10000;
  v_min_country NUMBER(6,2) := 4242;
BEGIN
  IF (v_min_country > v_min) THEN
   Raise_application_error(-20001,'Salary is too small');    
  ELSE
    INSERT INTO jobs VALUES(v_job_id, v_job_title, v_min, v_max) ;
    COMMIT;
  END IF;  
  EXCEPTION
    WHEN others THEN
      DBMS_OUTPUT.PUT_LINE('Other error:'||SQLCODE||' '||SQLERRM);  
END;
/


--5. Display the result of a query returning multiple rows using a FOR loop (implicit cursor). Handle exceptions.

DECLARE
  v_count NUMBER(4,0) := 0;
BEGIN 
  FOR vr_miss_part IN (SELECT * FROM employees WHERE department_id = 50) LOOP
    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE(v_count||'.'||vr_miss_part.last_name);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(v_count||' - astronauts');
    EXCEPTION
      WHEN invalid_cursor THEN
        DBMS_OUTPUT.PUT_LINE(q'!Invalid cursor!');
      WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Other error: '||SQLCODE||'.'||SQLERRM);
END;
/

--6. Create two cursors, where the second one is parameterized. The parameter should be a value returned by the first cursor. Handle them using nested loops. Remember to handle errors.

DECLARE 
  CURSOR c_managers IS
    SELECT * FROM employees WHERE EMPLOYEE_ID IN 
      (SELECT manager_id FROM employees);
    vr_manager employees%ROWTYPE;
    CURSOR c_mission_participants (p_man employees.manager_id%TYPE) IS 
        SELECT * FROM employees WHERE manager_id = p_man;
      vr_mission_participants employees%ROWTYPE;
BEGIN
  FOR vr_mission_manager IN c_managers LOOP
    DBMS_OUTPUT.PUT_LINE(c_managers%ROWCOUNT||' - Mission manager: '||vr_mission_manager.last_name);
    DBMS_OUTPUT.PUT_LINE(' and mission participants: ');
    FOR vr_mission_participants IN c_mission_participants(vr_mission_manager.employee_id) LOOP
      DBMS_OUTPUT.PUT_LINE(' '||c_mission_participants%ROWCOUNT||'. '||vr_mission_participants.last_name);
    END LOOP;
  END LOOP;
EXCEPTION
  WHEN cursor_already_open THEN 
    DBMS_OUTPUT.PUT_LINE('Cursor is already open');
    IF (c_mission_participants%ISOPEN) THEN 
      CLOSE c_mission_participants;
      DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
    END IF;
    IF (c_managers%ISOPEN) THEN
      CLOSE c_managers;
      DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
    END IF;
    WHEN invalid_cursor THEN
      DBMS_OUTPUT.PUT_LINE('Invalid cursor');
      IF (c_mission_participants%ISOPEN) THEN 
        CLOSE c_mission_participants;
        DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
      END IF;
      IF (c_managers%ISOPEN) THEN
        CLOSE c_managers;
        DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
      END IF;
    WHEN OTHERS THEN 
      DBMS_OUTPUT.PUT_LINE('Other error: '||SQLCODE||'.'||SQLERRM);
      IF (c_mission_participants%ISOPEN) THEN 
        CLOSE c_mission_participants;
        DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
      END IF;
      IF (c_managers%ISOPEN) THEN
        CLOSE c_managers;
        DBMS_OUTPUT.PUT_LINE('Let"s close the cursor');
      END IF;
    END;
    /





