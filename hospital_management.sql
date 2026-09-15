-- Hospital Management System Project

-- Creating Province Table
CREATE TABLE province(
   province_id CHAR(2) PRIMARY KEY,
   province_name VARCHAR(30)
);

-- Creating Patients Table
CREATE TABLE patients(
   patient_id INT PRIMARY KEY,
   first_name VARCHAR(30),
   last_name VARCHAR(30),
   gender CHAR(1),
   birth_date DATE,
   city VARCHAR(30),
   province_id CHAR(2),
   allergies VARCHAR(80),
   height DECIMAL(3,0),
   weight DECIMAL(4,0)
);

--Creating Doctors Table
CREATE TABLE doctors (
   doctor_id INT PRIMARY KEY,
   first_name VARCHAR(30),
   last_name VARCHAR(30),
   specialty VARCHAR(25)
);

-- Creating Admissions Table
CREATE TABLE admissions(
  patient_id INT,
  admission_date DATE,
  discharge_date DATE,
  diagnosis VARCHAR(50),
  attending_doctor_id INT
);

-- Foreign Key
ALTER TABLE patients
ADD CONSTRAINT fk_province
FOREIGN KEY (province_id)
REFERENCES province(province_id);

ALTER TABLE admissions
ADD CONSTRAINT fk_patients
FOREIGN KEY (patient_id)
REFERENCES patients(patient_id);

ALTER TABLE admissions
ADD CONSTRAINT fk_doctors
FOREIGN KEY (attending_doctor_id)
REFERENCES doctors(doctor_id);
--

/* Question 1: Show all female patients from the city 
of Toronto with pencilin or shellfish allergies.*/
SELECT * FROM (SELECT * FROM patients
WHERE allergies='Penicillin' or allergies='Shellfish')
WHERE gender='F' and city='Toronto';

/* Question 2: Count how many patients are in each province.*/
SELECT p.province_name, 
       COUNT(pa.patient_id) FROM province p
JOIN patients pa 
ON p.province_id=pa.province_id
GROUP BY p.province_name
ORDER BY COUNT(pa.patient_id) DESC;

/* Question 3: Show each admission with patient name + doctor name + diagnosis. */
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name, 
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name, 
    a.diagnosis 
FROM admissions a 
JOIN doctors d ON d.doctor_id = a.attending_doctor_id 
JOIN patients p ON p.patient_id = a.patient_id;

/* Question 4: Show patient name, city, and province name for patients whose last name starts with 'M'.*/
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.city, 
    pro.province_name 
FROM patients p
JOIN province pro ON pro.province_id = p.province_id
WHERE p.last_name LIKE 'M%';

/* Question 5: Show how many admissions each doctor handled, ordered by busiest first.*/
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name, 
    COUNT(a.admission_date) AS number_of_patients 
FROM doctors d
JOIN admissions a ON a.attending_doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY number_of_patients DESC;

/* Question 6: Show patient name + admission date + discharge date, sorted by longest stay first. */
SELECT CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
a.admission_date AS date_of_admission,
a.discharge_date AS date_of_discharge ,
a.discharge_date - a.admission_date AS time_period FROM patients p
LEFT JOIN admissions a
ON p.patient_id=a.patient_id
GROUP BY p.first_name, p.last_name, a.admission_date, a.discharge_date
ORDER BY time_period DESC;

/* Question 7: For each province, show the average patient height and weight. */
SELECT pro.province_name,
       ROUND(AVG(p.height),2) AS avg_height, 
	   ROUND(AVG(p.weight),2) AS avg_weight FROM province pro
JOIN patients p
ON pro.province_id=p.province_id
GROUP BY pro.province_name;

/* Question 9: Find patients who have been admitted more than once for the same diagnosis.*/
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    COUNT(a.admission_date) AS no_of_times_admitted,
    a.diagnosis 
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, a.diagnosis
HAVING COUNT(a.admission_date) > 1;

/* Question 10: Find the doctor(s) who have handled the most admissions.*/
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS doctors_name,
	d.specialty,
	COUNT(a.patient_id) FROM doctors d
JOIN admissions a
ON d.doctor_id=a.attending_doctor_id
GROUP BY d.first_name, d.last_name, d.specialty
ORDER BY COUNT(a.patient_id) DESC;

/* Question 11: List patients treated by doctor_id = 7 and their diagnoses.*/
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    a.diagnosis,
    CONCAT(d.first_name, ' ', d.last_name) AS doctors_name
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.attending_doctor_id = 7;

/* Question 12: Show patients who were treated by more than one doctor across their admissions.*/
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    COUNT(DISTINCT a.attending_doctor_id) AS unique_doctors_count
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(DISTINCT a.attending_doctor_id) > 1;

/* Question 13: Show the first and last admission of each patient.*/
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
	MIN(a.admission_date) AS first_admission,
	MAX(a.admission_date) AS last_admission
FROM patients p
JOIN admissions a ON p.patient_id=a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name;

/* Question 14:  Show the count of patients per province per gender.*/
SELECT 
    pro.province_name, 
    SUM(CASE WHEN p.gender = 'M' THEN 1 ELSE 0 END) AS male_patients,
    SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END) AS female_patients
FROM patients p
JOIN province pro ON p.province_id = pro.province_id
GROUP BY pro.province_name;

/* Question 15: For each diagnosis, show the most common attending doctor. */
SELECT 
    final_grouped.diagnosis,
    CONCAT(d.first_name, ' ', d.last_name) AS doctors_name,
    final_grouped.treatment_count
FROM (
    -- Step 3: Break ties by picking the lowest doctor_id for each max count
    SELECT 
        grouped.diagnosis,
        MIN(grouped.attending_doctor_id) AS tie_breaker_doctor_id,
        grouped.treatment_count
    FROM (
        -- Step 1: Get treatment counts for every doctor-diagnosis pair
        SELECT diagnosis, attending_doctor_id, COUNT(*) AS treatment_count
        FROM admissions
        GROUP BY diagnosis, attending_doctor_id
    ) grouped
    JOIN (
        -- Step 2: Get the absolute maximum treatment count for each diagnosis
        SELECT diagnosis, MAX(treatment_count) AS max_count
        FROM (
            SELECT diagnosis, attending_doctor_id, COUNT(*) AS treatment_count
            FROM admissions
            GROUP BY diagnosis, attending_doctor_id
        ) sub
        GROUP BY diagnosis
    ) max_counts 
      ON grouped.diagnosis = max_counts.diagnosis 
     AND grouped.treatment_count = max_counts.max_count
    GROUP BY grouped.diagnosis, grouped.treatment_count
) final_grouped
JOIN doctors d ON final_grouped.tie_breaker_doctor_id = d.doctor_id;
