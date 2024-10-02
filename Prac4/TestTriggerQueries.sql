-- Test inserting with an invalid degree code
INSERT INTO Undergraduate (student_number, title, first_name, surname, date_of_birth, degree_code, year_of_study, courseRegistration)
VALUES 
('150001', 'Mr', 'Invalid', 'Degree', '1999-01-01', 'XYZ', 3, ARRAY['COS301']);

-- Test inserting with an invalid course code
INSERT INTO Undergraduate (student_number, title, first_name, surname, date_of_birth, degree_code, year_of_study, courseRegistration)
VALUES 
('150002', 'Ms', 'Invalid', 'Course', '1999-01-01', 'BSC', 3, ARRAY['INVALID']);

-- Test inserting with an invalid degree code 
INSERT INTO Postgraduate (student_number, title, first_name, surname, date_of_birth, degree_code, year_of_study, category, supervisor_name)
VALUES 
('150003', 'Mr', 'Invalid', 'Degree', '1988-01-01', 'XYZ', 2, 'Full_Time', 'Dr. Supervisor');

UPDATE Undergraduate
SET degree_code = 'XYZ'
WHERE student_number = '140010';

UPDATE Undergraduate
SET courseRegistration = ARRAY['COS301', 'INVALID']
WHERE student_number = '140010';

UPDATE Postgraduate
SET degree_code = 'XYZ'
WHERE student_number = '121101';

DELETE FROM Undergraduate
WHERE student_number = '140010';

DELETE FROM Postgraduate
WHERE student_number = '121101';