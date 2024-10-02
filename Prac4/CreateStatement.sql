CREATE TYPE title_under_enum AS ENUM ('Ms', 'Mev', 'Miss', 'Mrs', 'Mr', 'Mnr', 'Dr', 'Prof');
CREATE TYPE title_post_enum AS ENUM ('Dr', 'Prof');
CREATE TYPE title_enum AS ENUM ('Ms', 'Mev', 'Miss', 'Mrs', 'Mr', 'Mnr', 'Dr', 'Prof');

CREATE TYPE category_enum AS ENUM ('part-time', 'full-time');

CREATE DOMAIN course_code_domain AS VARCHAR(6) CHECK (VALUE ~ '^[A-Z]{3}[0-9]{3}$');

CREATE DOMAIN degree_code_domain AS VARCHAR(4) CHECK (VALUE ~ '^[A-Z]{2,4}$');

CREATE SEQUENCE student_id_seq START 1;

CREATE SEQUENCE course_id_seq START 100;

CREATE SEQUENCE degree_program_id_seq START 10;

-- TABLES
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

CREATE TABLE Undergraduate (
    courseRegistration course_code_domain[] DEFAULT '{}'
) INHERITS (Student);

CREATE TABLE Postgraduate (
    category category_enum NOT NULL,
    supervisor_name VARCHAR(150) NOT NULL
) INHERITS (Student);

CREATE TABLE DegreeProgram (
    degree_id INTEGER PRIMARY KEY DEFAULT nextval('degree_program_id_seq'),
    degree_code degree_code_domain NOT NULL,
    degree_name VARCHAR(100) NOT NULL,
    number_of_years INTEGER CHECK (number_of_years BETWEEN 1 AND 6),
    faculty VARCHAR(100) NOT NULL
);

CREATE TABLE Course (
    course_id INTEGER PRIMARY KEY DEFAULT nextval('course_id_seq'),
    course_code course_code_domain NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER CHECK (credits > 0),
    department VARCHAR(100) NOT NULL
);

-- New Tables
CREATE TABLE DeletedUndergrad (
    deletionTimestamp TIMESTAMP NOT NULL,
    deletedByUserId VARCHAR(50) NOT NULL,
    PRIMARY KEY (student_id)
) INHERITS (Undergraduate);

CREATE TABLE DeletedPostgrad (
    deletionTimestamp TIMESTAMP NOT NULL,
    deletedByUserId VARCHAR(50) NOT NULL,
    PRIMARY KEY (student_id)
) INHERITS (Postgraduate);

-- FUNCSTIONS in plpgsql
CREATE OR REPLACE FUNCTION personFullNames(title title_enum, first_name VARCHAR, surname VARCHAR) RETURNS TEXT AS $$
BEGIN
    RETURN title || ' ' || first_name || ' ' || surname;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ageInYears(date_of_birth DATE) RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(date_of_birth));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isRegisteredFor(p_student_id INTEGER, p_course_code TEXT) 
RETURNS BOOLEAN AS $$
DECLARE
    is_registered BOOLEAN;
BEGIN
    SELECT p_course_code = ANY(courseRegistration) INTO is_registered
    FROM Undergraduate WHERE student_number = p_student_id::TEXT;
    RETURN is_registered;
END;
$$ LANGUAGE plpgsql;

-- New Functions

CREATE OR REPLACE FUNCTION isValidCourseCode(p_course_code course_code_domain)
RETURNS BOOLEAN AS $$
DECLARE
    exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM Course WHERE course_code = p_course_code) INTO exists;
    RETURN exists;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hasValidCourseCodes(p_courseRegistration course_code_domain[])
RETURNS BOOLEAN AS $$
DECLARE
    p_course_code course_code_domain;
BEGIN
    FOREACH p_course_code IN ARRAY p_courseRegistration
    LOOP
        IF NOT isValidCourseCode(p_course_code) THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION courseCodeFrequency(course_codes course_code_domain[], course_code course_code_domain) RETURNS INTEGER AS $$
DECLARE
    count INTEGER := 0;
    code course_code_domain;
BEGIN
    FOREACH code IN ARRAY course_codes LOOP
        IF code = course_code THEN
            count := count + 1;
        END IF;
    END LOOP;
    RETURN count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hasDuplicateCourseCodes(course_codes course_code_domain[]) RETURNS BOOLEAN AS $$
DECLARE
    course_code course_code_domain;
BEGIN
    FOREACH course_code IN ARRAY course_codes LOOP
        IF courseCodeFrequency(course_codes, course_code) > 1 THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isValidDegreeCode(p_degree_code degree_code_domain) RETURNS BOOLEAN AS $$
DECLARE
    exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM DegreeProgram WHERE degree_code = p_degree_code) INTO exists;
    RETURN exists;
END;
$$ LANGUAGE plpgsql;

-- Trigger Functions
CREATE OR REPLACE FUNCTION check_valid_degree_code() RETURNS TRIGGER AS $$
BEGIN
    IF NOT isValidDegreeCode(NEW.degree_code) THEN
        RAISE EXCEPTION 'Invalid degree code: %', NEW.degree_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_valid_course_codes()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT hasValidCourseCodes(NEW.courseRegistration) THEN
        RAISE EXCEPTION 'Invalid course codes';
    END IF;
    IF hasDuplicateCourseCodes(NEW.courseRegistration) THEN
        RAISE EXCEPTION 'Duplicate course codes';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION record_delete_undergrad() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO DeletedUndergrad
    SELECT OLD.*, CURRENT_TIMESTAMP, SESSION_USER;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION record_delete_postgrad() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO DeletedPostgrad
    SELECT OLD.*, CURRENT_TIMESTAMP, SESSION_USER;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER check_valid_degree
BEFORE INSERT OR UPDATE ON Student
FOR EACH ROW EXECUTE FUNCTION check_valid_degree_code();

CREATE TRIGGER under_check_valid_degree
BEFORE INSERT OR UPDATE ON Undergraduate
FOR EACH ROW EXECUTE FUNCTION check_valid_degree_code();

CREATE TRIGGER post_check_valid_degree
BEFORE INSERT OR UPDATE ON Postgraduate
FOR EACH ROW EXECUTE FUNCTION check_valid_degree_code();

CREATE TRIGGER check_valid_course_registration
BEFORE INSERT OR UPDATE ON Undergraduate
FOR EACH ROW EXECUTE FUNCTION check_valid_course_codes();

CREATE TRIGGER audit_delete_undergrad
AFTER DELETE ON Undergraduate
FOR EACH ROW EXECUTE FUNCTION record_delete_undergrad();

CREATE TRIGGER audit_delete_postgrad
AFTER DELETE ON Postgraduate
FOR EACH ROW EXECUTE FUNCTION record_delete_postgrad();