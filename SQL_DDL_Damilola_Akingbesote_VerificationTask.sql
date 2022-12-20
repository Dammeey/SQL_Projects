CREATE DATABASE health_institution;
CREATE SCHEMA IF NOT EXISTS health AUTHORIZATION postgres;

    CREATE TABLE IF NOT EXISTS health.service 
    
    (
        service_id BIGSERIAL PRIMARY KEY,
        category VARCHAR(255)
    );
    
    CREATE TABLE IF NOT EXISTS health.staffs
    
    (
        staff_id BIGSERIAL PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        category VARCHAR(255) NOT NULL
    );
    
    CREATE TABLE IF NOT EXISTS health.facility 
    
    (
        facility_id SERIAL PRIMARY KEY,
        facility_name VARCHAR(255) NOT NULL
    );

    CREATE TABLE IF NOT EXISTS health.hospital
    
    (
        hosp_id BIGSERIAL PRIMARY KEY,
        hospital_name TEXT NOT NULL,
        capacity BIGINT NOT NULL,
        servicies BIGINT NOT NULL REFERENCES health.service CHECK (servicies > 0),
        pharmacy BOOLEAN DEFAULT TRUE,
        facility BIGINT NOT NULL REFERENCES health.facility CHECK (facility > 0)
    );

    CREATE TABLE IF NOT EXISTS health.health_inst 
    (
        id BIGSERIAL PRIMARY KEY,
        hospital_id BIGINT NOT NULL REFERENCES health.hospital,
        address VARCHAR(255) NOT NULL,
        total_staff BIGINT NOT NULL,
        patients BIGINT NOT NULL,
        doctors BIGINT NOT NULL
    );
    
    
    CREATE TABLE IF NOT EXISTS health.patient
    (
        patient_id BIGSERIAL PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        address VARCHAR(255),
        phone_number BIGINT,
        doctor BIGINT REFERENCES health.staffs,
        visitation_date TIMESTAMP NOT NULL DEFAULT CURRENT_DATE 
    );
    
    
    INSERT INTO health.service (category)
    SELECT category FROM 
    (
    	SELECT 'outpatient department' AS category
    	UNION ALL 
    	SELECT 'nursing' AS category
    	UNION ALL 
    	SELECT 'ward facilities' AS category
    	UNION ALL 
    	SELECT 'Intensive Care Unit' AS category
    	UNION ALL 
    	SELECT 'Pharmacy and Diagnosis' AS category
    	UNION ALL 
    	SELECT 'All services' AS category
    ) t1
    WHERE category NOT IN (
    	SELECT category
    	FROM health.service
    );
            
    INSERT INTO health.staffs (first_name, last_name, category)
    SELECT first_name, last_name, category FROM
    (
    	SELECT 'Ignotas' AS first_name,
    			'Uknevicius' AS last_name,
    			'doctor' AS category
    			
    	UNION ALL 
    	
    	SELECT 'Leopoldas' AS first_name,
    			'Orlauskas' AS last_name,
    			'nurse' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Vincas' AS first_name,
    			'Kivilius' AS last_name,
    			'doctor' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Rapolas' AS first_name,
    			'Kvaselis' AS last_name,
    			'doctor' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Celestinas' AS first_name,
    			'Cincilevicius' AS last_name,
    			'nurse' AS category
    			
    	UNION ALL 
    	
    	SELECT 'Oskaras' AS first_name,
    			'Danila' AS last_name,
    			'doctor' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Titas' AS first_name,
    			'Olbergas' AS last_name,
    			'doctor' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Vytaras' AS first_name,
    			'Petronis' AS last_name,
    			'doctor' AS category
    	
    	UNION ALL 
    	
    	SELECT 'Edgaras' AS first_name,
    			'Kantautas' AS last_name,
    			'nurse' AS category
    			
    	UNION ALL 
    	
    	SELECT 'Simonas' AS first_name,
    			'Bajoraitis' AS last_name,
    			'nurse' AS category
    ) t2
    WHERE (first_name, last_name) NOT IN (
    	SELECT first_name, last_name
    	FROM health.staffs
    );
    
    

            
    INSERT INTO health.facility (facility_name)
    SELECT facility_name FROM
    (
    	SELECT 'ambulance' AS facility_name
    	UNION ALL 
    	SELECT 'X-ray' AS facility_name
    	UNION ALL 
    	SELECT 'ECG services' AS facility_name
    	UNION ALL 
    	SELECT 'Laboratory' AS facility_name
    	UNION ALL 
    	SELECT 'blood bank' AS facility_name
    	UNION ALL 
    	SELECT 'diabetes center' AS facility_name
    	UNION ALL 
    	SELECT 'dialysis center' AS facility_name
    	UNION ALL 
    	SELECT 'radiology center' AS facility_name
    	UNION ALL 
    	SELECT 'mental health care' AS facility_name
    	UNION ALL 
    	SELECT 'all services' AS facility_name
    ) t3
    WHERE facility_name NOT IN (
    	SELECT facility_name
    	FROM health.facility
    );
    	
        
    INSERT INTO health.hospital (hospital_name, capacity, servicies, pharmacy, facility)
    
    SELECT hospital_name, capacity, servicies, pharmacy, facility FROM
    
    (
    	SELECT 'Kedainiai Hospital' AS hospital_name,
    			50 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'outpatient department') AS servicies,
    			FALSE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'all services') AS facility
    			
    	UNION ALL 
    	
    	SELECT 'Vilnius University Hospital' AS hospital_name,
    			500 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'All services') AS servicies,
    			TRUE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'mental health care') AS facility
    			
    	UNION ALL 
    	
    	SELECT 'Centrinis Korpusas' AS hospital_name,
    			100 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'Intensive Care Unit') AS servicies,
    			TRUE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'blood bank') AS facility
    	
    	UNION ALL 
    	
    	SELECT 'LSMU Hospital' AS hospital_name,
    			700 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'Intensive Care Unit') AS servicies,
    			TRUE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'blood bank') AS facility
    			
    	UNION ALL 
    	
    	SELECT 'Kardiolita Hospital' AS hospital_name,
    			50 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'nursing') AS servicies,
    			FALSE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'dialysis center') AS facility
    			
    	UNION ALL 
    	
    	SELECT 'Kaunas Red Cross Hospital' AS hospital_name,
    			100 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'ward facilities') AS servicies,
    			TRUE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'radiology center') AS facility
    	
    	UNION ALL 
    	
    	SELECT 'Vilkpedes Hospital' AS hospital_name,
    			300 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'All services') AS servicies,
    			TRUE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'ambulance') AS facility
    			
    	UNION ALL 
    	
    	SELECT 'Jonava Hospital' AS hospital_name,
    			200 AS capacity,
    			(SELECT service_id 
    			FROM health.service
    			WHERE category = 'nursing') AS servicies,
    			FALSE AS pharmacy,
    			(SELECT facility_id
    			FROM health.facility
    			WHERE facility_name = 'dialysis center') AS facility
    			
    ) t4
    WHERE hospital_name NOT IN (
    	SELECT hospital_name
    	FROM health.hospital
    );
   

        
    INSERT INTO health.patient (first_name, last_name, address, phone_number, doctor)
    
    SELECT first_name, last_name, address, phone_number, doctor FROM
    (
    	SELECT 'Romualdas' AS first_name,
    			'Gavelis' AS last_name,
    			'Vilniaus g. 33, Vilnius' AS address,
    			 868641091 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Domas' AS first_name,
    			'Kasperunas' AS last_name,
    			'Pramones g. 8, Kaunas' AS address,
    			 861637229 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Domas' AS first_name,
    			'Judickas' AS last_name,
    			'Laisves al. 84-4, Kaunas' AS address,
    			 852404391 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Faustas' AS first_name,
    			'Kemezys' AS last_name,
    			'Savanorių pr. 284, Kaunas' AS address,
    			 852385090 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Ulijonas' AS first_name,
    			'Nainys' AS last_name,
    			'Tilzes g. 13, Vilnius' AS address,
    			 844661185 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    	
    	UNION ALL 
    	
    	SELECT 'Teodoras' AS first_name,
    			'Brazaitiss' AS last_name,
    			'Santariskiu g. 2, Vilnius' AS address,
    			852365148 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Edgaras' AS first_name,
    			'Serapinas' AS last_name,
    			'Stoties g. 11, Kedaina' AS address,
    			842244529 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Rimantas' AS first_name,
    			'Milinavicius' AS last_name,
    			'Zolyno g. 10-4, Jonava' AS address,
    			 852449686 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Vytaras Petronis') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Vidmantas' AS first_name,
    			'Kukutis' AS last_name,
    			'Lyros g. 13, Kedaina' AS address,
    			 865010093 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Ignotas Uknevicius') AS doctor
    			
    	UNION ALL 
    	
    	SELECT 'Mykolas' AS first_name,
    			'Zvirbly' AS last_name,
    			'Zasliu g. 16, Jonava' AS address,
    			 834960282 AS phone_number,
    			(SELECT staff_id 
    			FROM health.staffs
    			WHERE category = 'doctor'
    			AND CONCAT(first_name, ' ', last_name) = 'Rapolas Kvaselis') AS doctor
    	
    ) t5
    
    WHERE (first_name, last_name) NOT IN (
    	SELECT first_name, last_name
    	FROM health.patient
    );
    
   
    
    INSERT INTO health.health_inst (hospital_id, address, total_staff, patients, doctors)
    
    SELECT hospital_id, address, total_staff, patients, doctors FROM (
    
    	SELECT (SELECT hosp_id
    			FROM health.hospital
    			WHERE hospital_name = 'Kedainiai Hospital') AS hospital_id,
    			'Laisves Al. 23, Kedaina' AS address,
    			78 AS total_staff,
    			33 AS patients,
    			53 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Vilnius University Hospital') AS hospital_id,
    			'asava pl. 5, Vilnius' AS address,
    			225 AS total_staff,
    			443 AS patients,
    			104 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Centrinis Korpusas') AS hospital_id,
    			'Baltupio g. 103, Kaunas' AS address,
    			44 AS total_staff,
    			78 AS patients,
    			22 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'LSMU Hospital') AS hospital_id,
    			'Vyduno g. 4, Kaunas' AS address,
    			433 AS total_staff,
    			690 AS patients,
    			220 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Kardiolita Hospital') AS hospital_id,
    			'Savanoriu pr. 423, Kaunas' AS address,
    			88 AS total_staff,
    			173 AS patients,
    			69 AS doctors
    			
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Kaunas Red Cross Hospital') AS hospital_id,
    			'Laisves al. 17, Kaunas' AS address,
    			36 AS total_staff,
    			82 AS patients,
    			12 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Vilkpedes Hospital') AS hospital_id,
    			'Vilkpedes g. 3, Vilnius' AS address,
    			53 AS total_staff,
    			103 AS patients,
    			20 AS doctors
    			
    	UNION ALL 
    	
    	SELECT (SELECT hosp_id 
    			FROM health.hospital
    			WHERE hospital_name = 'Jonava Hospital') AS hospital_id,
    			'Zeimiu g., Jonava' AS address,
    			98 AS total_staff,
    			400 AS patients,
    			39 AS doctors
    
    
    
    ) t6
    WHERE hospital_id NOT IN (
    	SELECT hospital_id 
    	FROM health.health_inst
    	
    );
        
    

-- Write a query to identify doctors with insufficient workload 
-- (less than 5 patients a month for the past few months)

SELECT s2.first_name || ' ' || s2.last_name AS doctors
FROM (SELECT s.staff_id, s.first_name, s.last_name
        FROM health.staffs s
        WHERE category = 'doctor') s2
LEFT JOIN health.patient p 
ON p.doctor  = s2.staff_id
WHERE visitation_date >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY doctors
HAVING count(p.patient_id) < 5;

    
        

