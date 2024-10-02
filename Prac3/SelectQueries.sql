--1
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    ageInYears(date_of_birth) AS ageInYears
FROM 
    Student;

--2
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    courseRegistration
FROM 
    Undergraduate;

--3
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    category AS postgraduateCategory,
    supervisor_name AS personFullName
FROM 
    Postgraduate;

--4 Assuming 3 years to finish degree
SELECT 
    student_id,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    courseRegistration
FROM 
    Undergraduate
WHERE 
    isFinalYear(year_of_study, degree_code); 

--5 
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    courseRegistration
FROM 
    Undergraduate
WHERE 
    isRegisteredFor(student_id, 'COS326');

--6
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    category AS postgraduateCategory,
    supervisor_name AS personFullName
FROM 
    Postgraduate
WHERE 
    isFullTime(category);

--7
SELECT 
    student_id,
    student_number,
    personFullNames(title, first_name, surname) AS personFullName,
    degree_code AS studentDegreeCode,
    year_of_study AS studentYearOfStudy,
    category AS postgraduateCategory,
    supervisor_name AS personFullName
FROM 
    Postgraduate
WHERE 
    isPartTime(category); 
