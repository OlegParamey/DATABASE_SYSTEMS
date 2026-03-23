-- POWER MANAGEMENT DATABASE - Oleh Paramei, Dawid Sikora, Wojciech Włoczek
DROP TABLE AlertsAndEvents;
DROP TABLE MaintenanceLogs;
DROP TABLE Components;
DROP TABLE EnergyReadings;
DROP TABLE EnergyPrioritySchedule;
DROP TABLE StorageHealthLogs;
DROP TABLE ThermalSystem;
DROP TABLE PowerDistributions;
DROP TABLE EnergyStorages;
DROP TABLE FuelSystem;
DROP TABLE EnergyConversions;
DROP TABLE Technicians;
DROP TABLE EnergyConsumers;
DROP TABLE MartianEnvironment;
DROP TABLE EnergySources;


CREATE TABLE MartianEnvironment(
    env_id NUMBER(6) PRIMARY KEY,
    sol_number NUMBER(6),
    recorded_at TIMESTAMP,
    atmospheric_optical_depth NUMBER(4,3),
    temperature_c NUMBER(5,2),
    solar_irradiance_wm2 NUMBER(6,2),
    wind_speed_ms NUMBER(4,2),
    dust_storm_active NUMBER(1) CHECK (dust_storm_active IN (0,1))
);

CREATE TABLE EnergyConsumers(
    consumer_id NUMBER(5) PRIMARY KEY,
    consumer_name VARCHAR2(50),
    system_category VARCHAR2(20) CHECK (system_category IN ('life_support','communication','science','habitat','propulsion','navigation','thermal_control')),
    priority_level VARCHAR2(10) CHECK (priority_level IN ('critical','high','medium','low')),
    nominal_consumption_kw NUMBER(6,3),
    peak_consumption_kw NUMBER(6,3),
    operational_state VARCHAR2(10) CHECK (operational_state IN ('active','standby','offline','emergency')),
    thermal_output_kw NUMBER(6,3),
    location VARCHAR2(40),
    CONSTRAINT consumer_power_check CHECK (peak_consumption_kw >= nominal_consumption_kw)
);

CREATE TABLE Technicians(
    technician_id NUMBER(5) PRIMARY KEY,
    first_name VARCHAR2(20),
    last_name VARCHAR2(20),
    specialization VARCHAR2(30),
    clearance_level VARCHAR2(10) CHECK (clearance_level IN ('L1','L2','L3','chief')),
    contact_info VARCHAR2(100)
);

CREATE TABLE EnergySources(
    source_id NUMBER(5) PRIMARY KEY,
    source_name VARCHAR2(30),
    source_type VARCHAR2(12) CHECK (source_type IN ('solar','fission','RTG','fuel-based','hybrid')),
    max_output_kw NUMBER(6,3),
    efficiency_pct NUMBER(5,2) CHECK (efficiency_pct BETWEEN 0 AND 100),
    operational_status VARCHAR2(15) CHECK (operational_status IN ('active','standby','offline','failure','maintenance')),
    installation_date DATE,
    location VARCHAR2(40)
);

CREATE TABLE EnergyConversions(
    conversion_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    conversion_name VARCHAR2(40),
    conversion_type VARCHAR2(30),
    efficiency_pct NUMBER(5,2) CHECK (efficiency_pct BETWEEN 0 AND 100),
    max_input_kw NUMBER(6,3),
    max_output_kw NUMBER(6,3),
    thermal_output_kw NUMBER(6,3),
    operational_status VARCHAR2(20) CHECK (operational_status IN ('active','standby','offline','failure','maintenance')),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id)
);

CREATE TABLE FuelSystem(
    fuel_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    fuel_type VARCHAR2(20),
    tank_capacity_liters NUMBER(6,2),
    fuel_level_liters NUMBER(6,2),
    fuel_level_pct NUMBER(5,2) CHECK (fuel_level_pct BETWEEN 0 AND 100),
    pressure_kpa NUMBER(6,2),
    last_refueled DATE,
    CONSTRAINT fuel_level_check CHECK (fuel_level_liters <= tank_capacity_liters),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id)
);

CREATE TABLE EnergyStorages(
    storage_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    storage_name VARCHAR2(30),
    storage_type VARCHAR2(20) CHECK (storage_type IN ('battery','fuel_tank','thermal','flywheel','supercapacitor')),
    total_capacity_kwh NUMBER(7,3),
    current_level_kwh NUMBER(7,3),
    health_status VARCHAR2(10) CHECK (health_status IN ('excellent','good','degraded','critical','failed')),
    cycle_count NUMBER(7),
    degradation_pct NUMBER(5,2) CHECK (degradation_pct BETWEEN 0 AND 100),
    installation_date DATE,
    CONSTRAINT storage_capacity_check CHECK (current_level_kwh <= total_capacity_kwh),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id)
);

CREATE TABLE PowerDistributions(
    distribution_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    consumer_id NUMBER(5),
    allocated_power_kw NUMBER(6,3),
    actual_power_kw NUMBER(6,3),
    distribution_time TIMESTAMP,
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id)
);

CREATE TABLE ThermalSystem(
    thermal_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    consumer_id NUMBER(5),
    system_name VARCHAR2(30),
    system_type VARCHAR2(20),
    thermal_output_kwh NUMBER(6,3),
    thermal_storage_kwh NUMBER(7,3),
    current_thermal_level_kwh NUMBER(7,3),
    operational_status VARCHAR2(10) CHECK (operational_status IN ('active','standby','offline','failure')),
    installation_date DATE,
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id)
);

CREATE TABLE StorageHealthLogs(
    health_log_id NUMBER(7) PRIMARY KEY,
    storage_id NUMBER(6),
    recorded_at TIMESTAMP,
    health_status VARCHAR2(10) CHECK (health_status IN ('excellent','good','degraded','critical','failed')),
    cycle_count NUMBER(7),
    capacity_remaining_pct NUMBER(5,2) CHECK (capacity_remaining_pct BETWEEN 0 AND 100),
    temperature_c NUMBER(5,2),
    voltage_v NUMBER(6,3),
    notes VARCHAR2(200),
    FOREIGN KEY (storage_id) REFERENCES EnergyStorages(storage_id)
);

CREATE TABLE EnergyPrioritySchedule(
    schedule_id NUMBER(7) PRIMARY KEY,
    consumer_id NUMBER(5),
    env_id NUMBER(6),
    priority_level VARCHAR2(10) CHECK (priority_level IN ('critical','high','medium','low')),
    allocated_power_kw NUMBER(6,3),
    schedule_start TIMESTAMP,
    schedule_end TIMESTAMP,
    override_reason VARCHAR2(200),
    CONSTRAINT schedule_time_check CHECK (schedule_end > schedule_start),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id),
    FOREIGN KEY (env_id) REFERENCES MartianEnvironment(env_id)
);

CREATE TABLE EnergyReadings(
    reading_id NUMBER(7) PRIMARY KEY,
    source_id NUMBER(5),
    storage_id NUMBER(6),
    consumer_id NUMBER(5),
    env_id NUMBER(6),
    reading_time TIMESTAMP,
    generated_kw NUMBER(6,3),
    consumed_kw NUMBER(6,3),
    net_balance_kw NUMBER(6,3),
    stored_kwh NUMBER(7,3),
    CONSTRAINT energy_balance_check CHECK (net_balance_kw = generated_kw - consumed_kw),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id),
    FOREIGN KEY (storage_id) REFERENCES EnergyStorages(storage_id),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id),
    FOREIGN KEY (env_id) REFERENCES MartianEnvironment(env_id)
);

CREATE TABLE Components(
    component_id NUMBER(6) PRIMARY KEY,
    component_name VARCHAR2(40),
    component_type VARCHAR2(15) CHECK (component_type IN ('solar panel','battery cell','pump')),
    source_id NUMBER(5),
    consumer_id NUMBER(5),
    serial_number VARCHAR2(50),
    installation_date DATE,
    manufacturer VARCHAR2(50),
    expected_lifespan_days NUMBER(6),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id)
);

CREATE TABLE MaintenanceLogs(
    log_id NUMBER(6) PRIMARY KEY,
    component_id NUMBER(6),
    technician_id NUMBER(5),
    task_description VARCHAR2(200),
    repair_date DATE,
    next_inspection_date DATE,
    status VARCHAR2(15) CHECK (status IN ('completed','in_progress','scheduled','cancelled')),
    notes VARCHAR2(200),
    FOREIGN KEY (component_id) REFERENCES Components(component_id),
    FOREIGN KEY (technician_id) REFERENCES Technicians(technician_id)
);

CREATE TABLE AlertsAndEvents(
    alert_id NUMBER(6) PRIMARY KEY,
    source_id NUMBER(5),
    consumer_id NUMBER(5),
    technician_id NUMBER(5),
    alert_type VARCHAR2(30),
    severity VARCHAR2(10) CHECK (severity IN ('critical','warning','info')),
    description VARCHAR2(200),
    triggered_at TIMESTAMP,
    resolved_at TIMESTAMP,
    is_resolved NUMBER(1) DEFAULT 0 CHECK (is_resolved IN (0,1)),
    FOREIGN KEY (source_id) REFERENCES EnergySources(source_id),
    FOREIGN KEY (consumer_id) REFERENCES EnergyConsumers(consumer_id),
    FOREIGN KEY (technician_id) REFERENCES Technicians(technician_id)
);

-- DANE

INSERT INTO MartianEnvironment VALUES (1, 1201, TIMESTAMP '2037-01-05 06:15:00', 0.523, -63.25, 421.50, 7.80, 0);
INSERT INTO MartianEnvironment VALUES (2, 1202, TIMESTAMP '2037-01-06 13:22:00', 0.610, -61.10, 430.25, 8.15, 0);
INSERT INTO MartianEnvironment VALUES (3, 1203, TIMESTAMP '2037-01-07 19:40:00', 0.732, -65.42, 415.90, 9.70, 1);
INSERT INTO MartianEnvironment VALUES (4, 1204, TIMESTAMP '2037-01-08 04:05:00', 0.455, -60.11, 438.40, 6.90, 0);
INSERT INTO MartianEnvironment VALUES (5, 1205, TIMESTAMP '2037-01-09 11:30:00', 0.380, -58.90, 445.60, 5.60, 0);
INSERT INTO MartianEnvironment VALUES (6, 1206, TIMESTAMP '2037-01-10 17:55:00', 0.890, -70.10, 390.15, 11.40, 1);
INSERT INTO MartianEnvironment VALUES (7, 1207, TIMESTAMP '2037-01-11 09:12:00', 0.510, -62.70, 428.75, 7.25, 0);
INSERT INTO MartianEnvironment VALUES (8, 1208, TIMESTAMP '2037-01-12 15:48:00', 0.460, -59.88, 440.12, 6.45, 0);
INSERT INTO MartianEnvironment VALUES (9, 1209, TIMESTAMP '2037-01-13 21:03:00', 0.705, -66.35, 410.55, 10.10, 1);
INSERT INTO MartianEnvironment VALUES (10, 1210, TIMESTAMP '2037-01-14 07:29:00', 0.395, -57.60, 450.30, 5.20, 0);

INSERT INTO EnergyConsumers VALUES (1,'Life Support Core','life_support','critical',25.500,30.200,'active',10.500,'habitat A');
INSERT INTO EnergyConsumers VALUES (2,'Communication Array','communication','high',15.300,20.100,'active',6.200,'antenna field');
INSERT INTO EnergyConsumers VALUES (3,'Science Lab Alpha','science','high',18.750,25.000,'active',8.300,'lab sector');
INSERT INTO EnergyConsumers VALUES (4,'Habitat Heating','thermal_control','critical',22.100,28.500,'active',12.400,'habitat B');
INSERT INTO EnergyConsumers VALUES (5,'Navigation Systems','navigation','medium',8.200,12.000,'active',3.200,'control room');
INSERT INTO EnergyConsumers VALUES (6,'Rover Charging','science','medium',10.500,18.000,'standby',4.500,'garage');
INSERT INTO EnergyConsumers VALUES (7,'Greenhouse Lights','habitat','high',12.600,16.300,'active',5.000,'greenhouse');
INSERT INTO EnergyConsumers VALUES (8,'Water Processing','life_support','critical',20.000,26.000,'active',9.000,'water plant');
INSERT INTO EnergyConsumers VALUES (9,'Data Servers','communication','medium',9.800,14.200,'active',4.200,'data center');
INSERT INTO EnergyConsumers VALUES (10,'Emergency Systems','life_support','critical',5.200,8.500,'standby',2.100,'core systems');

INSERT INTO Technicians VALUES (1,'Elena','Morales','power systems','L3','elena.morales@marsbase.org');
INSERT INTO Technicians VALUES (2,'David','Kim','reactor specialist','chief','david.kim@marsbase.org');
INSERT INTO Technicians VALUES (3,'Luca','Rossi','thermal systems','L2','luca.rossi@marsbase.org');
INSERT INTO Technicians VALUES (4,'Aisha','Khan','battery systems','L2','aisha.khan@marsbase.org');
INSERT INTO Technicians VALUES (5,'Jonas','Weber','solar arrays','L1','jonas.weber@marsbase.org');
INSERT INTO Technicians VALUES (6,'Sofia','Petrov','mechanical','L2','sofia.petrov@marsbase.org');
INSERT INTO Technicians VALUES (7,'Carlos','Diaz','life support','L3','carlos.diaz@marsbase.org');
INSERT INTO Technicians VALUES (8,'Mei','Lin','communications','L1','mei.lin@marsbase.org');
INSERT INTO Technicians VALUES (9,'Oliver','Smith','diagnostics','L2','oliver.smith@marsbase.org');
INSERT INTO Technicians VALUES (10,'Hiro','Tanaka','robotics','L3','hiro.tanaka@marsbase.org');

INSERT INTO EnergySources VALUES (1,'Solar Array A','solar',250.500,22.50,'active',DATE '2035-06-10','sector A');
INSERT INTO EnergySources VALUES (2,'Solar Array B','solar',240.200,22.10,'active',DATE '2035-06-15','sector B');
INSERT INTO EnergySources VALUES (3,'Kilopower Reactor 1','fission',40.000,30.00,'active',DATE '2036-02-01','reactor bay');
INSERT INTO EnergySources VALUES (4,'Kilopower Reactor 2','fission',40.000,30.00,'standby',DATE '2036-02-05','reactor bay');
INSERT INTO EnergySources VALUES (5,'RTG Unit 1','RTG',0.110,6.50,'active',DATE '2034-03-10','science lab');
INSERT INTO EnergySources VALUES (6,'Methane Generator','fuel-based',60.000,35.20,'active',DATE '2036-07-20','fuel plant');
INSERT INTO EnergySources VALUES (7,'Hybrid Grid Node','hybrid',120.000,28.70,'active',DATE '2036-09-01','grid hub');
INSERT INTO EnergySources VALUES (8,'Solar Array C','solar',230.800,22.40,'active',DATE '2035-07-01','sector C');
INSERT INTO EnergySources VALUES (9,'Solar Array D','solar',210.600,21.90,'maintenance',DATE '2035-08-12','sector D');
INSERT INTO EnergySources VALUES (10,'Backup Generator','fuel-based',55.000,33.50,'standby',DATE '2036-11-18','utility bay');

INSERT INTO EnergyConversions VALUES (1,1,'Solar Inverter A','DC-AC inverter',96.50,250.000,241.250,8.500,'active');
INSERT INTO EnergyConversions VALUES (2,2,'Solar Inverter B','DC-AC inverter',96.20,240.000,231.000,8.200,'active');
INSERT INTO EnergyConversions VALUES (3,3,'Reactor Turbine Alpha','thermal-electric',32.50,40.000,13.000,20.500,'active');
INSERT INTO EnergyConversions VALUES (4,4,'Reactor Turbine Beta','thermal-electric',32.10,40.000,12.840,21.000,'standby');
INSERT INTO EnergyConversions VALUES (5,6,'Methane Generator Converter','combustion-electric',35.20,60.000,21.120,30.000,'active');
INSERT INTO EnergyConversions VALUES (6,7,'Hybrid Grid Converter','multi-source regulator',94.10,120.000,112.920,10.000,'active');
INSERT INTO EnergyConversions VALUES (7,8,'Solar Inverter C','DC-AC inverter',96.40,230.000,221.720,8.300,'active');
INSERT INTO EnergyConversions VALUES (8,9,'Solar Inverter D','DC-AC inverter',95.90,210.000,201.390,8.700,'maintenance');
INSERT INTO EnergyConversions VALUES (9,10,'Backup Generator Converter','combustion-electric',33.50,55.000,18.425,25.000,'standby');
INSERT INTO EnergyConversions VALUES (10,3,'Reactor Heat Recovery','thermal recovery',40.50,20.000,8.100,11.000,'active');

INSERT INTO FuelSystem VALUES (1,6,'methane',5000.00,3200.00,64.00,520.00,DATE '2037-01-02');
INSERT INTO FuelSystem VALUES (2,10,'methane',4000.00,2800.00,70.00,505.00,DATE '2037-01-03');
INSERT INTO FuelSystem VALUES (3,6,'oxygen-mix',3000.00,1900.00,63.33,480.00,DATE '2036-12-28');
INSERT INTO FuelSystem VALUES (4,10,'hydrogen',3500.00,2400.00,68.57,495.00,DATE '2037-01-07');
INSERT INTO FuelSystem VALUES (5,6,'methane',4500.00,3100.00,68.89,530.00,DATE '2037-01-11');
INSERT INTO FuelSystem VALUES (6,10,'methane',4200.00,3000.00,71.43,510.00,DATE '2037-02-01');
INSERT INTO FuelSystem VALUES (7,6,'propellant mix',3800.00,2100.00,55.26,470.00,DATE '2036-11-19');
INSERT INTO FuelSystem VALUES (8,10,'hydrogen',3600.00,2000.00,55.56,450.00,DATE '2037-01-18');
INSERT INTO FuelSystem VALUES (9,6,'methane',4100.00,2900.00,70.73,515.00,DATE '2037-02-05');
INSERT INTO FuelSystem VALUES (10,10,'methane',3900.00,2500.00,64.10,498.00,DATE '2037-02-12');

INSERT INTO EnergyStorages VALUES (1,1,'Battery Bank A','battery',5000.000,3100.250,'good',320,4.20,DATE '2035-06-11');
INSERT INTO EnergyStorages VALUES (2,2,'Battery Bank B','battery',4800.000,2900.100,'good',290,4.10,DATE '2035-06-16');
INSERT INTO EnergyStorages VALUES (3,3,'Thermal Tank 1','thermal',2000.000,1500.000,'excellent',150,1.10,DATE '2036-02-03');
INSERT INTO EnergyStorages VALUES (4,6,'Fuel Tank Main','fuel_tank',3000.000,2100.550,'good',80,0.50,DATE '2036-07-22');
INSERT INTO EnergyStorages VALUES (5,7,'Flywheel A','flywheel',600.000,420.000,'good',540,3.00,DATE '2036-09-03');
INSERT INTO EnergyStorages VALUES (6,8,'Battery Bank C','battery',4500.000,2800.750,'good',260,4.80,DATE '2035-07-03');
INSERT INTO EnergyStorages VALUES (7,3,'Thermal Tank 2','thermal',2100.000,1600.200,'excellent',120,1.00,DATE '2036-02-06');
INSERT INTO EnergyStorages VALUES (8,10,'Fuel Tank Backup','fuel_tank',2500.000,2000.000,'good',60,0.70,DATE '2036-11-19');
INSERT INTO EnergyStorages VALUES (9,7,'SuperCap Node','supercapacitor',300.000,220.100,'excellent',900,2.00,DATE '2036-09-05');
INSERT INTO EnergyStorages VALUES (10,1,'Battery Bank D','battery',4700.000,3000.450,'good',300,4.50,DATE '2035-06-20');

INSERT INTO PowerDistributions VALUES (1,1,1,30.000,25.400,TIMESTAMP '2037-01-05 06:30:00');
INSERT INTO PowerDistributions VALUES (2,2,2,20.000,15.300,TIMESTAMP '2037-01-06 13:40:00');
INSERT INTO PowerDistributions VALUES (3,3,3,25.000,18.750,TIMESTAMP '2037-01-07 20:05:00');
INSERT INTO PowerDistributions VALUES (4,1,4,28.000,22.100,TIMESTAMP '2037-01-08 04:20:00');
INSERT INTO PowerDistributions VALUES (5,8,7,16.000,12.600,TIMESTAMP '2037-01-09 11:50:00');
INSERT INTO PowerDistributions VALUES (6,6,6,18.000,10.500,TIMESTAMP '2037-01-10 18:10:00');
INSERT INTO PowerDistributions VALUES (7,7,8,24.000,20.000,TIMESTAMP '2037-01-11 09:40:00');
INSERT INTO PowerDistributions VALUES (8,1,9,14.000,9.800,TIMESTAMP '2037-01-12 16:10:00');
INSERT INTO PowerDistributions VALUES (9,3,5,12.000,8.200,TIMESTAMP '2037-01-13 21:30:00');
INSERT INTO PowerDistributions VALUES (10,10,10,9.000,5.200,TIMESTAMP '2037-01-14 07:50:00');

INSERT INTO ThermalSystem VALUES (1,3,4,'Habitat Thermal Loop','heat exchange',15.200,500.000,310.500,'active',DATE '2036-02-10');
INSERT INTO ThermalSystem VALUES (2,3,1,'Life Support Heater','resistive heating',8.200,200.000,150.200,'active',DATE '2036-02-12');
INSERT INTO ThermalSystem VALUES (3,6,7,'Greenhouse Heat Control','fluid loop',6.800,180.000,110.000,'active',DATE '2036-07-24');
INSERT INTO ThermalSystem VALUES (4,7,8,'Water Plant Thermal','heat recovery',9.400,250.000,190.000,'active',DATE '2036-09-06');
INSERT INTO ThermalSystem VALUES (5,3,3,'Lab Heat Stabilizer','precision heating',5.500,120.000,80.500,'active',DATE '2036-02-14');
INSERT INTO ThermalSystem VALUES (6,6,6,'Rover Bay Heater','air heating',4.100,100.000,60.200,'standby',DATE '2036-07-28');
INSERT INTO ThermalSystem VALUES (7,7,9,'Server Cooling Recovery','thermal exchange',7.300,150.000,95.000,'active',DATE '2036-09-10');
INSERT INTO ThermalSystem VALUES (8,3,5,'Navigation Thermal','micro heater',2.800,60.000,35.000,'active',DATE '2036-02-16');
INSERT INTO ThermalSystem VALUES (9,7,2,'Antenna De-Icer','surface heater',3.200,75.000,50.000,'active',DATE '2036-09-12');
INSERT INTO ThermalSystem VALUES (10,10,10,'Emergency Heater','backup heating',4.500,110.000,70.000,'standby',DATE '2036-11-25');

INSERT INTO StorageHealthLogs VALUES (1,1,TIMESTAMP '2037-01-05 09:00:00','good',320,95.50,-5.20,48.125,'stable');
INSERT INTO StorageHealthLogs VALUES (2,2,TIMESTAMP '2037-01-06 11:15:00','good',290,94.80,-4.80,48.110,'normal');
INSERT INTO StorageHealthLogs VALUES (3,3,TIMESTAMP '2037-01-07 13:40:00','excellent',150,98.20,35.50,12.500,'thermal stable');
INSERT INTO StorageHealthLogs VALUES (4,4,TIMESTAMP '2037-01-08 15:30:00','good',80,96.10,18.20,5.100,'fuel stable');
INSERT INTO StorageHealthLogs VALUES (5,5,TIMESTAMP '2037-01-09 17:50:00','good',540,93.60,20.00,15.400,'flywheel ok');
INSERT INTO StorageHealthLogs VALUES (6,6,TIMESTAMP '2037-01-10 08:25:00','good',260,92.30,-6.10,48.000,'normal');
INSERT INTO StorageHealthLogs VALUES (7,7,TIMESTAMP '2037-01-11 10:45:00','excellent',120,98.70,33.90,12.430,'stable');
INSERT INTO StorageHealthLogs VALUES (8,8,TIMESTAMP '2037-01-12 14:20:00','good',60,95.20,17.80,5.020,'ok');
INSERT INTO StorageHealthLogs VALUES (9,9,TIMESTAMP '2037-01-13 18:10:00','excellent',900,97.90,19.40,2.500,'supercap good');
INSERT INTO StorageHealthLogs VALUES (10,10,TIMESTAMP '2037-01-14 07:35:00','good',300,94.60,-5.90,48.050,'stable');

INSERT INTO EnergyPrioritySchedule VALUES (1,1,1,'critical',30.000,TIMESTAMP '2037-01-05 06:00:00',TIMESTAMP '2037-01-05 12:00:00','life support priority');
INSERT INTO EnergyPrioritySchedule VALUES (2,2,2,'high',20.000,TIMESTAMP '2037-01-06 12:30:00',TIMESTAMP '2037-01-06 18:30:00','communication window');
INSERT INTO EnergyPrioritySchedule VALUES (3,3,3,'high',24.000,TIMESTAMP '2037-01-07 18:00:00',TIMESTAMP '2037-01-07 23:00:00','experiment run');
INSERT INTO EnergyPrioritySchedule VALUES (4,4,4,'critical',28.000,TIMESTAMP '2037-01-08 03:30:00',TIMESTAMP '2037-01-08 10:00:00','habitat heating');
INSERT INTO EnergyPrioritySchedule VALUES (5,7,5,'high',16.000,TIMESTAMP '2037-01-09 10:30:00',TIMESTAMP '2037-01-09 15:30:00','crop growth cycle');
INSERT INTO EnergyPrioritySchedule VALUES (6,6,6,'medium',15.000,TIMESTAMP '2037-01-10 17:30:00',TIMESTAMP '2037-01-10 22:00:00','rover charging');
INSERT INTO EnergyPrioritySchedule VALUES (7,8,7,'critical',22.000,TIMESTAMP '2037-01-11 09:00:00',TIMESTAMP '2037-01-11 14:00:00','water processing');
INSERT INTO EnergyPrioritySchedule VALUES (8,9,8,'medium',12.000,TIMESTAMP '2037-01-12 15:00:00',TIMESTAMP '2037-01-12 20:00:00','data sync');
INSERT INTO EnergyPrioritySchedule VALUES (9,5,9,'medium',10.000,TIMESTAMP '2037-01-13 21:00:00',TIMESTAMP '2037-01-14 02:00:00','navigation recalibration');
INSERT INTO EnergyPrioritySchedule VALUES (10,10,10,'critical',8.000,TIMESTAMP '2037-01-14 07:00:00',TIMESTAMP '2037-01-14 12:00:00','emergency readiness');

INSERT INTO EnergyReadings VALUES (1,1,1,1,1,TIMESTAMP '2037-01-05 06:20:00',120.250,25.100,95.150,3100.200);
INSERT INTO EnergyReadings VALUES (2,2,2,2,2,TIMESTAMP '2037-01-06 13:25:00',118.450,15.300,103.150,2895.100);
INSERT INTO EnergyReadings VALUES (3,3,3,3,3,TIMESTAMP '2037-01-07 19:45:00',39.500,18.700,20.800,1500.000);
INSERT INTO EnergyReadings VALUES (4,1,1,4,4,TIMESTAMP '2037-01-08 04:10:00',110.000,22.100,87.900,3090.000);
INSERT INTO EnergyReadings VALUES (5,8,6,7,5,TIMESTAMP '2037-01-09 11:35:00',105.200,12.600,92.600,2800.700);
INSERT INTO EnergyReadings VALUES (6,6,4,6,6,TIMESTAMP '2037-01-10 18:00:00',55.000,10.500,44.500,2100.550);
INSERT INTO EnergyReadings VALUES (7,7,5,8,7,TIMESTAMP '2037-01-11 09:20:00',90.000,20.000,70.000,420.000);
INSERT INTO EnergyReadings VALUES (8,1,10,9,8,TIMESTAMP '2037-01-12 15:50:00',130.400,9.800,120.600,3000.450);
INSERT INTO EnergyReadings VALUES (9,3,7,5,9,TIMESTAMP '2037-01-13 21:05:00',38.900,8.200,30.700,1600.200);
INSERT INTO EnergyReadings VALUES (10,10,8,10,10,TIMESTAMP '2037-01-14 07:40:00',50.000,5.200,44.800,2000.000);

INSERT INTO Components VALUES (1,'Panel A1','solar panel',1,NULL,'SP-A1-2035',DATE '2035-06-11','Spectrolab',10950);
INSERT INTO Components VALUES (2,'Panel B1','solar panel',2,NULL,'SP-B1-2035',DATE '2035-06-16','Spectrolab',10950);
INSERT INTO Components VALUES (3,'Reactor Pump','pump',3,NULL,'RP-2036-01',DATE '2036-02-03','BWXTech',7300);
INSERT INTO Components VALUES (4,'Battery Cell A','battery cell',1,NULL,'BC-A-5532',DATE '2035-06-12','Panasonic',3650);
INSERT INTO Components VALUES (5,'Battery Cell B','battery cell',2,NULL,'BC-B-7731',DATE '2035-06-17','LG Energy',3650);
INSERT INTO Components VALUES (6,'Fuel Pump','pump',6,NULL,'FP-6621',DATE '2036-07-23','Bosch',5400);
INSERT INTO Components VALUES (7,'Panel C1','solar panel',8,NULL,'SP-C1-2035',DATE '2035-07-02','Spectrolab',10950);
INSERT INTO Components VALUES (8,'Panel D1','solar panel',9,NULL,'SP-D1-2035',DATE '2035-08-13','Spectrolab',10950);
INSERT INTO Components VALUES (9,'Cooling Pump','pump',3,NULL,'CP-8821',DATE '2036-02-07','Honeywell',6000);
INSERT INTO Components VALUES (10,'Battery Cell C','battery cell',8,NULL,'BC-C-9021',DATE '2035-07-04','Panasonic',3650);

INSERT INTO MaintenanceLogs VALUES (1,1,5,'cleaning solar panel array',DATE '2037-01-04',DATE '2037-02-04','completed','dust removed');
INSERT INTO MaintenanceLogs VALUES (2,2,5,'solar panel efficiency check',DATE '2037-01-07',DATE '2037-03-01','completed','normal output');
INSERT INTO MaintenanceLogs VALUES (3,3,2,'reactor coolant pump inspection',DATE '2037-01-10',DATE '2037-04-10','completed','no anomalies');
INSERT INTO MaintenanceLogs VALUES (4,4,4,'battery cell voltage balancing',DATE '2037-01-11',DATE '2037-02-11','completed','balanced');
INSERT INTO MaintenanceLogs VALUES (5,5,4,'battery diagnostics',DATE '2037-01-13',DATE '2037-03-15','completed','minor wear');
INSERT INTO MaintenanceLogs VALUES (6,6,6,'fuel pump calibration',DATE '2037-01-16',DATE '2037-04-16','completed','calibrated');
INSERT INTO MaintenanceLogs VALUES (7,7,5,'solar panel alignment',DATE '2037-01-18',DATE '2037-03-18','completed','adjusted');
INSERT INTO MaintenanceLogs VALUES (8,8,5,'panel dust removal',DATE '2037-01-21',DATE '2037-02-21','completed','clean');
INSERT INTO MaintenanceLogs VALUES (9,9,3,'cooling pump pressure test',DATE '2037-01-24',DATE '2037-04-01','completed','stable');
INSERT INTO MaintenanceLogs VALUES (10,10,4,'battery cell capacity test',DATE '2037-01-27',DATE '2037-03-27','completed','within limits');

INSERT INTO AlertsAndEvents VALUES (1,1,1,9,'power fluctuation','warning','minor solar fluctuation detected',TIMESTAMP '2037-01-05 06:45:00',TIMESTAMP '2037-01-05 07:10:00',1);
INSERT INTO AlertsAndEvents VALUES (2,9,2,5,'solar efficiency drop','warning','dust accumulation detected',TIMESTAMP '2037-01-06 14:10:00',TIMESTAMP '2037-01-06 16:00:00',1);
INSERT INTO AlertsAndEvents VALUES (3,3,3,2,'reactor temperature spike','critical','reactor core temp spike',TIMESTAMP '2037-01-07 20:20:00',TIMESTAMP '2037-01-07 21:00:00',1);
INSERT INTO AlertsAndEvents VALUES (4,6,6,6,'fuel pressure anomaly','warning','pressure deviation detected',TIMESTAMP '2037-01-10 18:25:00',NULL,0);
INSERT INTO AlertsAndEvents VALUES (5,1,7,5,'panel shading','info','temporary shadow from dust cloud',TIMESTAMP '2037-01-09 11:55:00',TIMESTAMP '2037-01-09 12:30:00',1);
INSERT INTO AlertsAndEvents VALUES (6,3,4,3,'thermal overload','warning','thermal loop approaching limit',TIMESTAMP '2037-01-11 09:50:00',TIMESTAMP '2037-01-11 10:40:00',1);
INSERT INTO AlertsAndEvents VALUES (7,7,8,9,'grid imbalance','warning','temporary load imbalance',TIMESTAMP '2037-01-11 10:20:00',TIMESTAMP '2037-01-11 11:00:00',1);
INSERT INTO AlertsAndEvents VALUES (8,8,9,8,'network lag','info','data server latency spike',TIMESTAMP '2037-01-12 16:30:00',TIMESTAMP '2037-01-12 16:50:00',1);
INSERT INTO AlertsAndEvents VALUES (9,10,10,1,'backup generator test','info','scheduled generator startup test',TIMESTAMP '2037-01-13 07:10:00',TIMESTAMP '2037-01-13 07:40:00',1);
INSERT INTO AlertsAndEvents VALUES (10,6,5,6,'fuel mixture deviation','warning','combustion efficiency reduced',TIMESTAMP '2037-01-14 08:20:00',NULL,0);

-- PRZYKŁADOWE WIDOKI
-- aktualny bilans energii

CREATE VIEW EnergySystemBalance AS
SELECT 
    er.reading_time,
    es.source_name,
    ec.consumer_name,
    er.generated_kw,
    er.consumed_kw,
    er.net_balance_kw,
    er.stored_kwh
FROM EnergyReadings er
JOIN EnergySources es ON er.source_id = es.source_id
JOIN EnergyConsumers ec ON er.consumer_id = ec.consumer_id;

-- aktywne alerty i zdarzenia

CREATE VIEW ActiveAlertsAndEvents AS
SELECT
    a.alert_id,
    es.source_name,
    ec.consumer_name,
    t.first_name || ' ' || t.last_name AS technician,
    a.alert_type,
    a.severity,
    a.description,
    a.triggered_at
FROM AlertsAndEvents a
LEFT JOIN EnergySources es ON a.source_id = es.source_id
LEFT JOIN EnergyConsumers ec ON a.consumer_id = ec.consumer_id
LEFT JOIN Technicians t ON a.technician_id = t.technician_id
WHERE a.is_resolved = 0;

-- produkcja energii wedlug zrodla

CREATE VIEW EnergyProductionSummary AS
SELECT
    es.source_type,
    SUM(er.generated_kw) AS total_generated_kw,
    AVG(er.generated_kw) AS avg_generated_kw
FROM EnergyReadings er
JOIN EnergySources es ON er.source_id = es.source_id
GROUP BY es.source_type;

-- przykladowe indeksy 
-- kolumny z czasem

CREATE INDEX idx_environment_time 
ON MartianEnvironment(recorded_at);

CREATE INDEX idx_readings_time 
ON EnergyReadings(reading_time);

CREATE INDEX idx_storage_health_time 
ON StorageHealthLogs(recorded_at);

CREATE INDEX idx_alert_time 
ON AlertsAndEvents(triggered_at);

-- status alertow/zdarzen i zrodel energii

CREATE INDEX idx_alert_resolved 
ON AlertsAndEvents(is_resolved);

CREATE INDEX idx_source_status 
ON EnergySources(operational_status);