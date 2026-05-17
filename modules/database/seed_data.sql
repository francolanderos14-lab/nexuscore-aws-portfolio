CREATE DATABASE IF NOT EXISTS employees_demo;
USE employees_demo;

CREATE TABLE departments (
  dept_id   INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL,
  location  VARCHAR(100)
);

INSERT INTO departments (dept_name, location) VALUES
  ('Ingenieria',   'Nueva York'),
  ('Marketing',    'San Francisco'),
  ('Finanzas',     'Chicago'),
  ('Recursos Humanos', 'Austin'),
  ('Operaciones',  'Seattle');

CREATE TABLE employees (
  emp_id     INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50)  NOT NULL,
  last_name  VARCHAR(50)  NOT NULL,
  email      VARCHAR(100) UNIQUE NOT NULL,
  dept_id    INT,
  salary     DECIMAL(10,2),
  hire_date  DATE,
  is_active  BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

DELIMITER $$
CREATE PROCEDURE generate_employees()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE names_first VARCHAR(500) DEFAULT 'James,Maria,John,Patricia,Robert,Jennifer,Michael,Linda,William,Barbara,David,Susan,Richard,Jessica,Joseph,Sarah,Thomas,Karen,Charles,Lisa';
  DECLARE names_last  VARCHAR(500) DEFAULT 'Smith,Johnson,Williams,Brown,Jones,Garcia,Miller,Davis,Martinez,Hernandez,Lopez,Gonzalez,Wilson,Anderson,Thomas,Taylor,Moore,Jackson,Martin,Lee';
  WHILE i <= 10000 DO
    INSERT INTO employees (first_name, last_name, email, dept_id, salary, hire_date)
    VALUES (
      TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(names_first, ',', 1 + FLOOR(RAND() * 20)), ',', -1)),
      TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(names_last,  ',', 1 + FLOOR(RAND() * 20)), ',', -1)),
      CONCAT('empleado_', i, '@nexuscore.com'),
      1 + FLOOR(RAND() * 5),
      30000 + FLOOR(RAND() * 120000),
      DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 3650) DAY)
    );
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL generate_employees();
DROP PROCEDURE generate_employees;

SELECT COUNT(*) AS total_empleados FROM employees;
SELECT dept_name, COUNT(*) AS empleados, AVG(salary) AS salario_promedio
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY dept_name
ORDER BY empleados DESC;