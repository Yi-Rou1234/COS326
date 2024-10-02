INSERT INTO DegreeProgram (degree_code, degree_name, number_of_years, faculty)
VALUES 
    ('BSC', 'Bachelor of Science', 3, 'EBIT'),
    ('BIT', 'Bachelor of IT', 4, 'EBIT'),
    ('PHD', 'Philosophiae Doctor', 5, 'EBIT');

INSERT INTO Course (course_code, course_name, department, credits)
VALUES 
    ('COS301', 'Software Engineering', 'Computer Science', 40),
    ('COS326', 'Database Systems', 'Computer Science', 20),
    ('MTH301', 'Discrete Mathematics', 'Mathematics', 15),
    ('PHL301', 'Logical Reasoning', 'Philosophy', 15);

INSERT INTO Undergraduate (student_number, title, first_name, surname, date_of_birth, degree_code, year_of_study, courseRegistration)
VALUES 
    ('140010', 'Ms', 'Monica', 'Hung', '1996-01-10', 'BSC', 3, ARRAY['COS301', 'COS326', 'MTH301']),
    ('140015', 'Mr', 'Tim', 'Blake', '1995-05-25', 'BSC', 3, ARRAY['COS301', 'PHL301', 'MTH301']),
    ('131120', 'Ms', 'Jame', 'White', '1995-01-30', 'BIT', 3, ARRAY['COS301', 'COS326', 'PHL301']),
    ('131140', 'Mr', 'Brown', 'Cook', '1996-02-20', 'BIT', 4, ARRAY['COS301', 'COS326', 'MTH301']);

INSERT INTO Postgraduate (student_number, title, first_name, surname, date_of_birth, degree_code, year_of_study, category, supervisor_name)
VALUES 
    ('101122', 'Mrs', 'Bakey', 'Lively', '1987-06-15', 'PHD', 2, 'full-time', 'Mr. Jakey Chen'),
    ('121101', 'Mrs', 'Kim', 'Kourteney', '1985-04-27', 'PHD', 3, 'part-time', 'Mr. Kung Fu');
