# Hospital Management System — SQL Project #3

A complete hospital analytics project with **15 solved SQL questions** ranging from beginner to intermediate level. This is my **third portfolio project** demonstrating practical SQL skills for healthcare data analysis.

## 📁 Project Structure

| File | Description |
|------|-------------|
| `hospital_management.sql` | Complete schema + 15 solved queries with explanations |
| `province.csv` | 13 Canadian provinces |
| `doctors.csv` | 45 doctors with specialties |
| `patients.csv` | 1,000 patient records |
| `admissions.csv` | ~1,656 admission records (1–3 per patient) |

## 🏗️ Database Schema

![Hospital ERD](https://github.com/abhidutta-analyst/Hospital_database/blob/main/hospital_ERD.png)

```sql
province(province_id PK, province_name)
patients(patient_id PK, first_name, last_name, gender, birth_date, city, province_id FK, allergies, height, weight)
doctors(doctor_id PK, first_name, last_name, specialty)
admissions(patient_id FK, admission_date, discharge_date, diagnosis, attending_doctor_id FK)
```

**Foreign Keys:** `patients.province_id → province`, `admissions.patient_id → patients`, `admissions.attending_doctor_id → doctors`

---

## 📋 15 Solved Questions

### 🟢 Beginner Questions

#### **Q1. Female patients in Toronto with Penicillin or Shellfish allergies**
```sql
SELECT * FROM (
    SELECT * FROM patients
    WHERE allergies = 'Penicillin' OR allergies = 'Shellfish'
) WHERE gender = 'F' AND city = 'Toronto';
```
*Filters patients by gender, city, and specific allergies using a subquery.*

---

#### **Q2. Patient count per province**
```sql
SELECT p.province_name, COUNT(pa.patient_id) 
FROM province p
JOIN patients pa ON p.province_id = pa.province_id
GROUP BY p.province_name
ORDER BY COUNT(pa.patient_id) DESC;
```
*Joins province with patients, groups by province name, orders by count descending.*

---

### 🟡 Intermediate JOIN Questions

#### **Q3. Admissions with patient name + doctor name + diagnosis**
```sql
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name, 
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name, 
    a.diagnosis 
FROM admissions a 
JOIN doctors d ON d.doctor_id = a.attending_doctor_id 
JOIN patients p ON p.patient_id = a.patient_id;
```
*Three-table join showing complete admission context.*

---

#### **Q4. Patients with last name starting with 'M' (with city & province)**
```sql
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.city, 
    pro.province_name 
FROM patients p
JOIN province pro ON pro.province_id = p.province_id
WHERE p.last_name LIKE 'M%';
```
*Uses LIKE pattern matching with two-table join.*

---

#### **Q5. Admissions handled per doctor (busiest first)**
```sql
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name, 
    COUNT(a.admission_date) AS number_of_patients 
FROM doctors d
JOIN admissions a ON a.attending_doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY number_of_patients DESC;
```
*Aggregates admissions per doctor, ordered by workload.*

---

#### **Q6. Patient stays sorted by longest duration**
```sql
SELECT CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    a.admission_date AS date_of_admission,
    a.discharge_date AS date_of_discharge,
    a.discharge_date - a.admission_date AS time_period 
FROM patients p
LEFT JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.first_name, p.last_name, a.admission_date, a.discharge_date
ORDER BY time_period DESC;
```
*Calculates length of stay using date subtraction; LEFT JOIN includes patients without admissions.*

---

#### **Q7. Average height & weight per province**
```sql
SELECT pro.province_name,
       ROUND(AVG(p.height), 2) AS avg_height, 
       ROUND(AVG(p.weight), 2) AS avg_weight 
FROM province pro
JOIN patients p ON pro.province_id = p.province_id
GROUP BY pro.province_name;
```
*Aggregates biometric data by province with rounding.*

---

### 🟠 Advanced Aggregation & Filtering

#### **Q9. Patients admitted multiple times for the same diagnosis**
```sql
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    COUNT(a.admission_date) AS no_of_times_admitted,
    a.diagnosis 
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, a.diagnosis
HAVING COUNT(a.admission_date) > 1;
```
*Groups by patient + diagnosis, filters with HAVING for repeat admissions.*

---

#### **Q10. Doctor(s) with the most admissions**
```sql
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS doctors_name,
    d.specialty,
    COUNT(a.patient_id) 
FROM doctors d
JOIN admissions a ON d.doctor_id = a.attending_doctor_id
GROUP BY d.first_name, d.last_name, d.specialty
ORDER BY COUNT(a.patient_id) DESC;
```
*Identifies highest-volume doctors with their specialties.*

---

#### **Q11. Patients treated by doctor_id = 7**
```sql
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    a.diagnosis,
    CONCAT(d.first_name, ' ', d.last_name) AS doctors_name
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.attending_doctor_id = 7;
```
*Three-table join filtered to a specific doctor.*

---

#### **Q12. Patients treated by more than one doctor**
```sql
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    COUNT(DISTINCT a.attending_doctor_id) AS unique_doctors_count
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(DISTINCT a.attending_doctor_id) > 1;
```
*Uses COUNT(DISTINCT) to find patients with multiple attending physicians.*

---

#### **Q13. First and last admission per patient**
```sql
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patients_name,
    MIN(a.admission_date) AS first_admission,
    MAX(a.admission_date) AS last_admission
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name;
```
*MIN/MAX aggregation to find admission date range per patient.*

---

#### **Q14. Patient count per province per gender (pivot-style)**
```sql
SELECT 
    pro.province_name, 
    SUM(CASE WHEN p.gender = 'M' THEN 1 ELSE 0 END) AS male_patients,
    SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END) AS female_patients
FROM patients p
JOIN province pro ON p.province_id = pro.province_id
GROUP BY pro.province_name;
```
*Conditional aggregation creates a pivot table without PIVOT syntax.*

---

### ⭐ **Q15. Most Common Attending Doctor per Diagnosis** — *Highlight Question*

```sql
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
```

**Why this matters for hospitals:**
- Identifies the **go-to specialist** for each diagnosis
- Enables data-driven referral pathways
- Helps with resource allocation and staffing decisions
- Reveals clinical patterns and doctor expertise areas

**Query breakdown:**
1. **Step 1** — Count treatments per (diagnosis, doctor) pair
2. **Step 2** — Find the maximum count per diagnosis
3. **Step 3** — Join to get doctors at that max, break ties with MIN(doctor_id)
4. **Final** — Join to doctors table for readable names

---

## 🚀 How to Run

### Option 1: pgAdmin / PostgreSQL
```bash
# 1. Create tables
\i hospital_management.sql

# 2. Import CSVs in order (FK dependencies):
#    province.csv → doctors.csv → patients.csv → admissions.csv
```

### Option 2: Any SQL Engine
The queries use standard SQL (PostgreSQL syntax for date subtraction). Adjust `discharge_date - admission_date` for your dialect:
- **MySQL:** `DATEDIFF(discharge_date, admission_date)`
- **SQL Server:** `DATEDIFF(DAY, admission_date, discharge_date)`
- **SQLite:** `julianday(discharge_date) - julianday(admission_date)`

---

## 📚 Skills Demonstrated

| Category | Techniques Used |
|----------|----------------|
| **Joins** | INNER, LEFT, 3+ table joins |
| **Aggregation** | COUNT, SUM, AVG, MIN, MAX |
| **Grouping** | GROUP BY with multiple columns |
| **Filtering** | WHERE, HAVING, LIKE, IN |
| **Conditional Logic** | CASE WHEN for pivot tables |
| **Subqueries** | Nested subqueries, derived tables |
| **Advanced** | Tie-breaking logic, multi-step CTE-style composition |

---

## 🎯 Project Highlights

- **15 real-world healthcare analytics questions** solved
- **Progressive difficulty** from basic filters to complex multi-step queries
- **Production-ready SQL** with proper formatting and comments
- **Question 15** demonstrates advanced analytical thinking valuable for hospital operations
- **Clean schema design** with proper FK constraints

---

## 🔮 Next Steps

Future enhancements with window functions & CTEs:
- `ROW_NUMBER()` for nth admission per patient
- `LAG()`/`LEAD()` for readmission gaps
- Running totals of daily admissions
- Cohort analysis (first admission per month/year)
- Recursive CTEs for doctor referral chains

---

*Built as Project #3 in my Data Analytics portfolio. Questions 1–14 cover foundational to intermediate SQL; Question 15 showcases the analytical depth needed for real healthcare decision-making.*
