-- Enum for student title
CREATE TYPE title_enum AS ENUM ('Ms', 'Mev', 'Miss', 'Mrs', 'Mr', 'Mnr', 'Dr', 'Prof');

-- Enum for postgraduate category
CREATE TYPE category_enum AS ENUM ('part-time', 'full-time');

-- Domain for course code
CREATE DOMAIN course_code_domain AS VARCHAR(6) CHECK (VALUE ~ '^[A-Z]{3}[0-9]{3}$');

-- Domain for degree code
CREATE DOMAIN degree_code_domain AS VARCHAR(4) CHECK (VALUE ~ '^[A-Z]{2,4}$');

-- Sequence for student primary key
CREATE SEQUENCE student_id_seq START 1;

-- Sequence for course primary key
CREATE SEQUENCE course_id_seq START 100;

-- Sequence for degree program primary key
CREATE SEQUENCE degree_program_id_seq START 10;

-- Base table for Student
CREATE TABLE Student (
    student_id INTEGER PRIMARY KEY DEFAULT nextval('student_id_seq'),
    student_number CHAR(6) NOT NULL,
    title title_enum NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    degree_code degree_code_domain NOT NULL,
    year_of_study INTEGER CHECK (year_of_study BETWEEN 1 AND 6)
);

-- Table for Undergraduate students inheriting from Student
CREATE TABLE Undergraduate (
    courseRegistration course_code_domain[] DEFAULT '{}'
) INHERITS (Student);

-- Table for Postgraduate students inheriting from Student
CREATE TABLE Postgraduate (
    category category_enum NOT NULL,
    supervisor_name VARCHAR(150) NOT NULL
) INHERITS (Student);

-- Degree Program table
CREATE TABLE DegreeProgram (
    degree_id INTEGER PRIMARY KEY DEFAULT nextval('degree_program_id_seq'),
    degree_code degree_code_domain NOT NULL,
    degree_name VARCHAR(100) NOT NULL,
    number_of_years INTEGER CHECK (number_of_years BETWEEN 1 AND 6),
    faculty VARCHAR(100) NOT NULL
);

-- Course table
CREATE TABLE Course (
    course_id INTEGER PRIMARY KEY DEFAULT nextval('course_id_seq'),
    course_code course_code_domain NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER CHECK (credits > 0),
    department VARCHAR(100) NOT NULL
);

-- Function to return full name of a person
CREATE FUNCTION personFullNames(title title_enum, first_name VARCHAR, surname VARCHAR) RETURNS TEXT AS $$
    SELECT title || ' ' || first_name || ' ' || surname;
$$ LANGUAGE SQL;

-- Function to return age in years
CREATE FUNCTION ageInYears(date_of_birth DATE) RETURNS INTEGER AS $$
    SELECT EXTRACT(YEAR FROM AGE(date_of_birth));
$$ LANGUAGE SQL;

-- Function to check if an undergraduate student is registered for a course
CREATE FUNCTION isRegisteredFor(student_id INTEGER, course_code course_code_domain) RETURNS BOOLEAN AS $$
    SELECT course_code = ANY(courseRegistration) FROM Undergraduate WHERE student_id = $1;
$$ LANGUAGE SQL;

-- Function to check if an undergraduate student is in their final year
CREATE FUNCTION isFinalYear(year_of_study INTEGER, degree_code degree_code_domain) RETURNS BOOLEAN AS $$
    SELECT year_of_study = (
        SELECT number_of_years
        FROM DegreeProgram
        WHERE degree_code = $2
    );
$$ LANGUAGE SQL;

-- Function to check if a postgraduate student is full-time
CREATE FUNCTION isFullTime(category category_enum) RETURNS BOOLEAN AS $$
    SELECT category = 'full-time';
$$ LANGUAGE SQL;

-- Function to check if a postgraduate student is part-time
CREATE FUNCTION isPartTime(category category_enum) RETURNS BOOLEAN AS $$
    SELECT category = 'part-time';
$$ LANGUAGE SQL;
