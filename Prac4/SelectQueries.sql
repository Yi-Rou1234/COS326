-- 1. List details of all students registered for COS326
SELECT 
    student_number, 
    personFullNames(title, first_name, surname) AS full_names, 
    ageInYears(date_of_birth) AS age, 
    degree_code
FROM Undergraduate
WHERE isRegisteredFor(student_number::INTEGER, 'COS326');

-- Valid course codes
SELECT 
    student_number, 
    hasValidCourseCodes(courseRegistration) AS valid_courses
FROM Undergraduate
WHERE student_number = '140010';

-- Invalid course codes
SELECT 
    student_number, 
    hasValidCourseCodes(ARRAY['COS301', 'INVALID']) AS valid_courses
FROM Undergraduate
WHERE student_number = '140010';

-- No duplicate course codes
SELECT 
    student_number, 
    hasDuplicateCourseCodes(courseRegistration) AS duplicate_courses
FROM Undergraduate
WHERE student_number = '140010';

-- Duplicate course codes
SELECT 
    student_number, 
    hasDuplicateCourseCodes(ARRAY['COS301', 'COS301', 'COS326']) AS duplicate_courses
FROM Undergraduate
WHERE student_number = '140010';