CREATE DATABASE HIMS;
USE HIMS;

SELECT * FROM appointments LIMIT 5;
SELECT * FROM billing LIMIT 5;
SELECT * FROM doctors LIMIT 5;
SELECT * FROM patients LIMIT 5;
SELECT * FROM treatments LIMIT 5;

-- 1. List all patients with their full name and email.
SELECT CONCAT(first_name,' ',last_name) as Full_Name, email
FROM patients;

-- 2. Show all doctors who specialize in "Dermatology".
SELECT CONCAT(first_name,' ',last_name) AS full_name
FROM doctors
WHERE LOWER(specialization)= "dermatology";

-- 3. Count how many patients are male and female.
SELECT COUNT(LOWER(gender)="male") AS Male, COUNT(LOWER(gender)="female") AS Female
FROM patients;

-- 4. Show all appointments scheduled for today.
SELECT appointment_id,appointment_time
FROM appointments
WHERE appointment_date= CURDATE();

-- 5. List the top 5 most experienced doctors.
SELECT CONCAT(first_name,' ',last_name) as Full_Name, years_experience
FROM doctors
ORDER BY years_experience DESC
LIMIT 5;

-- 6. Display all unique treatment types.
SELECT DISTINCT(treatment_type)
FROM treatments;

-- 7. Find all patients who have insurance from "MedCare Plus."
SELECT CONCAT(first_name,' ',last_name) as Full_Name, insurance_provider
FROM patients
WHERE insurance_provider="MedCare Plus";

-- 8. List all pennding bills from the billing table.
SELECT bill_id, patient_id
FROM billing
WHERE LOWER(payment_status)="pending";

-- 9. Show treatments that cost more than 3,000.
SELECT treatment_type, cost
FROM treatments
WHERE cost>3000;

-- 10. Count how many appointments each doctor has.
SELECT doctor_id, COUNT(appointment_id)
FROM appointments
GROUP BY doctor_id;

-- intermediate level
-- 11. Find the total revenue generated from each treatment type.
SELECT t.treatment_type, ROUND(SUM(b.amount),2) AS total_revenue
FROM treatments t
JOIN billing b ON t.treatment_id=b.treatment_id
GROUP BY t.treatment_type
ORDER BY total_revenue DESC;

-- 12. List patients along with their assigned doctor and appointment date.
SELECT 
	CONCAT (p.first_name,' ',p.last_name) AS Patient_name,
	CONCAT (d.first_name,' ',d.last_name) AS Doctor_name,
    a.appointment_date
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id= p.patient_id;
    
-- 13. Show how many treatments each patient has received.
SELECT 
	CONCAT(p.first_name,' ',p.last_name) AS Patient_name,
    COUNT(t.treatment_type) AS Treatments
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
JOIN Treatments t ON b.treatment_id = t.treatment_id
GROUP BY p.first_name, p.last_name;

-- 14. Calculate the average treatment cost per doctor.
SELECT 
	CONCAT(d.first_name,' ',d.last_name) AS Doctor_name,
    ROUND(AVG(t.cost),2) AS Average_cost
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY d.first_name, d.last_name;

-- 15. Identify doctors who haven’t had any appointments yet.
SELECT 
	CONCAT(d.first_name,' ',d.last_name) AS Doctor_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.first_name, d.last_name
HAVING total_appointments = 0;

-- 16. List all appointments that are "Cancelled" or "No-Show".
SELECT a.appointment_id,
	CONCAT(p.first_name,' ',p.last_name) AS Patient_name,
    a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE LOWER(a.status) = 'cancelled' or LOWER(a.status) = 'no-show';

-- 17. Show the monthly revenue trend for the last 6 months.
SELECT 
    DATE_FORMAT(STR_TO_DATE(bill_date, '%m/%d/%Y'), '%Y-%m') AS month,
    ROUND(SUM(amount), 2) AS total_revenue
FROM billing
GROUP BY month
ORDER BY month;

-- 18. Find which hospital branch has the highest number of doctors.
SELECT d.hospital_branch, COUNT(*) AS Doctor_count
FROM doctors d
GROUP BY d.hospital_branch
ORDER BY Doctor_count DESC
LIMIT 1;

-- 19. Identify patients with more than 3 appointments.
SELECT 
	CONCAT(p.first_name,' ',p.last_name) AS Patient_name,
    COUNT(a.appointment_id) AS appointment
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.first_name, p.last_name
HAVING appointment >3
ORDER BY appointment DESC;

-- 20. Display each patient’s age based on their date of birth.
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_name,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(p.date_of_birth, '%d/%m/%Y'),CURDATE()) AS Age
FROM patients p
WHERE p.date_of_birth IS NOT NULL
ORDER BY age DESC;

-- Advance Questions
-- 21. List the top 3 patients who have generated the most revenue.
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_name,
    ROUND(SUM(b.amount),2) AS Revenue
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
GROUP BY p.first_name, p.last_name
ORDER BY revenue DESC
LIMIT 3;

-- 22. Find the doctor who treated the highest number of unique patients.
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS Doctor_name,
    COUNT(DISTINCT a.patient_id) AS patient_no
FROM doctors d
JOIN appointments a ON d.doctor_id=a.doctor_id
GROUP BY d.first_name, d.last_name
ORDER BY patient_no DESC
LIMIT 1;

-- 24. Flag potential duplicate patients (same name and DOB).
SELECT 
    first_name, 
    last_name, 
    date_of_birth, 
    COUNT(*) AS duplicate_count
FROM patients
GROUP BY first_name, last_name, date_of_birth
HAVING COUNT(*) > 1;

-- 25. Create a report that shows:• patient name • doctor name • treatment name • bill amount • payment status — all in one row. 
SELECT
	CONCAT(p.first_name, ' ', p.last_name) AS Patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS Doctor_name,
    t.treatment_type,b.amount,b.payment_status
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id 
JOIN treatments t ON b.treatment_id = t.treatment_id
JOIN appointments a ON t.appointment_id = a.appointment_id
JOIN doctors d ON a.doctor_id = d.doctor_id
