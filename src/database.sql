\c postgres

DROP DATABASE workflow_db;

CREATE DATABASE workflow_db;

\c workflow_db

CREATE EXTENSION pgcrypto;

/* ################################################################################################# */

/* read only */

/* All the users of the system are stored in the users table, a user can be employee or system-admin/admin/supervisor */
/* All the usernames should be unique whether it is deleted or not */



/* update is not allowed, only insert and delete */
CREATE TABLE users(
    username VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    doj_company DATE NOT NULL DEFAULT CURRENT_DATE 
);


CREATE TABLE deleted_users(
    username VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    doj_company DATE NOT NULL ,
    end_date_in_company DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE is_user_deleted(
    username VARCHAR(255) NOT NULL PRIMARY KEY,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);


/* ************************************************************************************************************ */

CREATE OR REPLACE FUNCTION populate_is_user_deleted() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO is_user_deleted(username) VALUES (NEW.username);
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER populate_is_user_deleted_trigger
BEFORE INSERT
ON users
FOR EACH ROW
EXECUTE PROCEDURE populate_is_user_deleted();

/* ************************************************************************************************************ */

CREATE OR REPLACE FUNCTION log_deleted_users() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO deleted_users(username, name, doj_company) VALUES (OLD.username, OLD.name, OLD.doj_company);
    UPDATE is_user_deleted SET is_deleted = TRUE WHERE username = OLD.username;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER log_deleted_users_trigger
AFTER DELETE
ON users
FOR EACH ROW
EXECUTE PROCEDURE log_deleted_users();

/* ############################################################################################ */

/* read only */


/* cannot create new department with the same name of the deleted department */
/* on deleting the department all the employees, roles, workflows and pending applications associated with it gets deleted */
/* Check it again:- DON'T UPDATE OR DELETE DEPARTMENT */

/* ***************************************************************************************************** */

/* update, insert and delete is allowed */
CREATE TABLE departments(
    department_name VARCHAR(100) NOT NULL PRIMARY KEY, 
    start_date DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE deleted_departments(
    department_name VARCHAR(100) NOT NULL PRIMARY KEY, 
    start_date DATE NOT NULL ,
    end_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE is_department_deleted(
    department_name VARCHAR(100) NOT NULL PRIMARY KEY,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

/* ***************************************************************************************************** */


CREATE OR REPLACE FUNCTION update_dep_name() RETURNS TRIGGER AS
$$
BEGIN
	UPDATE is_department_deleted SET department_name = NEW.department_name WHERE department_name = OLD.department_name;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_dep_name_trigger
BEFORE UPDATE
ON departments
FOR EACH ROW
EXECUTE PROCEDURE update_dep_name();


/********************************************************************************************************/

CREATE OR REPLACE FUNCTION populate_is_department_deleted_on_insertion_in_departments() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO is_department_deleted(department_name) VALUES (NEW.department_name);
    RETURN NEW;
END;
$$    
LANGUAGE plpgsql;

CREATE TRIGGER populate_is_department_deleted_on_insertion_in_departments_trig
BEFORE INSERT 
ON departments
FOR EACH ROW
EXECUTE PROCEDURE populate_is_department_deleted_on_insertion_in_departments();

/********************************************************************************************************/

CREATE OR REPLACE FUNCTION populate_deleted_departments() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO deleted_departments(department_name, start_date) VALUES (OLD.department_name, OLD.start_date);
    UPDATE is_department_deleted SET is_deleted = TRUE WHERE department_name = OLD.department_name; 
    /* delete workflow also */
    RETURN OLD;
END;
$$    
LANGUAGE plpgsql;

CREATE TRIGGER populate_deleted_departments_trigger
AFTER DELETE
ON departments
FOR EACH ROW
EXECUTE PROCEDURE populate_deleted_departments();


/* ######################################################################################################## */


/* read only */
/* here the employee is designated to the person who has no decision taking power  */
/* delete employee using its username only */



/***********************************************************************************************/

/* update not allowed , only insert and delete allowed */
CREATE TABLE employees(
    employee_email_id VARCHAR NOT NULL PRIMARY KEY,
    password text NOT NULL,
    username VARCHAR(255) REFERENCES users(username) ON DELETE CASCADE NOT NULL UNIQUE,
    department VARCHAR(100) REFERENCES departments(department_name) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    notification BOOLEAN NOT NULL DEFAULT TRUE
);

/* read only */
CREATE TABLE is_employee_deleted(
    employee_email_id VARCHAR NOT NULL PRIMARY KEY,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    department_name VARCHAR(100) REFERENCES is_department_deleted(department_name) ON UPDATE CASCADE NOT NULL,
    username VARCHAR(255) REFERENCES is_user_deleted(username) NOT NULL
);

/***********************************************************************************************/


CREATE OR REPLACE FUNCTION log_deleted_employee() RETURNS TRIGGER AS
$$
BEGIN 
    UPDATE is_employee_deleted SET is_deleted = TRUE where employee_email_id = OLD.employee_email_id;
    DELETE FROM users where username = OLD.username;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER log_deleted_employee_trigger
AFTER DELETE
ON employees
FOR EACH ROW
EXECUTE PROCEDURE log_deleted_employee();


/***********************************************************************************************/

CREATE OR REPLACE FUNCTION populate_is_employee_deleted() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO is_employee_deleted(employee_email_id,is_deleted, department_name, username) VALUES (NEW.employee_email_id,FALSE,NEW.department,NEW.username);
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER populate_is_employee_deleted_trigger
BEFORE INSERT
ON employees
FOR EACH ROW
EXECUTE PROCEDURE populate_is_employee_deleted();

/* ######################################################################################################## */

/* read only */
/* roles_associated_with_department contains all the roles that exists only if the department exists */
/* roles_not_associated with department contains the roles like dean, supervisor,admin etc who are not associated with any department*/


/*****************************************************************************************************/


/* role= "employee" is already inserted into the table */
/* delete, update and insert is allowed */
CREATE TABLE roles_associated_with_department(
    role_name VARCHAR(100) NOT NULL PRIMARY KEY
);


/****************************************************************************************************/


/* delete not allowed , insert and update allowed */ 
CREATE TABLE roles_not_associated_with_department(
    role_name VARCHAR(100) NOT NULL PRIMARY KEY
);

/* ######################################################################################################## */


/* read only */
/* An employee holding a post can be temporarily reassigned */
/* It is possible that no person is there on a role  for some duration*/



/*********************************************************************************************************/

/* update,delete,insert allowed */
CREATE  TABLE employees_holding_post_associated_with_department(
    role_email_id VARCHAR NOT NULL PRIMARY KEY,
    password TEXT NOT NULL,
    employee_email_id VARCHAR REFERENCES employees(employee_email_id)  ON DELETE RESTRICT UNIQUE,
    department VARCHAR(100) REFERENCES departments(department_name) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    role_created_on_date DATE DEFAULT CURRENT_DATE NOT NULL,
    /*reassigned_email_id VARCHAR REFERENCES employees(employee_email_id) ON DELETE RESTRICT DEFAULT NULL,*/
    /* duration INTERVAL DEFAULT NULL,
    date_of_reassignment DATE DEFAULT NULL, */
    role_name VARCHAR(100) REFERENCES roles_associated_with_department(role_name) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
    employee_assigned_post_date DATE DEFAULT NULL,
    notification BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE is_role_deleted(
    role_email_id VARCHAR NOT NULL PRIMARY KEY,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE deleted_roles(
    role_email_id VARCHAR NOT NULL PRIMARY KEY,
    department_name VARCHAR(100) REFERENCES is_department_deleted(department_name) ON UPDATE CASCADE NOT NULL,
    role_created_on_date DATE NOT NULL,
    role_ended_on_date DATE NOT NULL DEFAULT CURRENT_DATE,
    role_name VARCHAR(100) NOT NULL
);

CREATE TABLE changed_employees_on_role(
    role_email_id VARCHAR REFERENCES is_role_deleted(role_email_id) NOT NULL,
    employee_email_id VARCHAR REFERENCES is_employee_deleted(employee_email_id) ON UPDATE CASCADE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL DEFAULT CURRENT_DATE
);

/*
CREATE TABLE reassignment_history_on_role(
    role_email_id VARCHAR REFERENCES is_role_deleted(role_email_id) NOT NULL,
    employee_email_id VARCHAR REFERENCES is_employee_deleted(employee_email_id) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL DEFAULT CURRENT_DATE    
);
*/

/********************************************************************************************************************/


CREATE OR REPLACE FUNCTION populate_is_role_deleted() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO is_role_deleted(role_email_id) VALUES (NEW.role_email_id);
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER populate_is_role_deleted_trigger
BEFORE INSERT
ON employees_holding_post_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE populate_is_role_deleted();

/********************************************************************************************************************/


CREATE OR REPLACE FUNCTION log_deleted_roles() RETURNS TRIGGER AS
$$
    DECLARE is_null BOOLEAN;
BEGIN
    INSERT INTO deleted_roles(role_email_id, department_name, role_created_on_date, role_name) VALUES (OLD.role_email_id, OLD.department, OLD.role_created_on_date,OLD.role_name);
    UPDATE is_role_deleted SET is_deleted = TRUE WHERE role_email_id = OLD.role_email_id;
    IF OLD.employee_email_id is not null then
        INSERT INTO changed_employees_on_role(role_email_id,employee_email_id,start_date) VALUES (OLD.role_email_id, OLD.employee_email_id, OLD.employee_assigned_post_date);
    end if;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER log_deleted_users_trigger
AFTER DELETE
ON employees_holding_post_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE log_deleted_roles();

/********************************************************************************************************************/


/* create before delete TRIGGER later*/

/********************************************************************************************************************/


CREATE OR REPLACE FUNCTION populate_changed_employees_on_role() RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.employee_email_id <> NEW.employee_email_id THEN
        INSERT INTO changed_employees_on_role(role_email_id,employee_email_id,start_date) VALUES (OLD.role_email_id, OLD.employee_email_id, OLD.employee_assigned_post_date);
    END IF;

    /* IF OLD.reassigned_email_id <> NEW.reassigned_email_id THEN
        INSERT INTO reassignment_history_on_role(role_email_id,employee_email_id,start_date) VALUES (OLD.role_email_id, OLD.reassigned_email_id,OLD.date_of_reassignment);
    END IF;*/

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER populate_changed_employees_on_role_trigger
BEFORE UPDATE 
ON employees_holding_post_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE populate_changed_employees_on_role();


/* ######################################################################################################## */


/* read only */
/* before registering the employee of this type first add him as a user in users table */
/* no user is assigned a role */
/* if a user is assigned a role then set its start_date */

/***************************************************************************************************/

/* delete not allowed, insert and update allowed */
CREATE TABLE employees_holding_post_not_associated_with_department(
    post_email_id VARCHAR NOT NULL PRIMARY KEY,
    password TEXT NOT NULL,
    username VARCHAR(255) REFERENCES users(username) ON DELETE RESTRICT,
    created_on DATE DEFAULT CURRENT_DATE NOT NULL,
    start_date DATE DEFAULT NULL,
    role_name VARCHAR(100) REFERENCES roles_not_associated_with_department(role_name) ON DELETE CASCADE  ON UPDATE CASCADE NOT NULL
);

CREATE TABLE changed_employees_on_post_not_associated_with_department(
    post_email_id VARCHAR REFERENCES employees_holding_post_not_associated_with_department(post_email_id) NOT NULL,
    username VARCHAR(255) REFERENCES is_user_deleted(username),
    start_date DATE NOT NULL,
    end_date DATE DEFAULT CURRENT_DATE NOT NULL,
    role_name VARCHAR(100) NOT NULL
);

/***************************************************************************************************/

CREATE OR REPLACE FUNCTION populate_changed_employees() RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.username <> NEW.username THEN
        INSERT INTO changed_employees_on_post_not_associated_with_department(post_email_id,username,start_date,role_name) VALUES (OLD.post_email_id, OLD.username, OLD.start_date,OLD.role_name);
    END IF;
    RETURN NEW;   
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER populate_changed_employees_trigger
BEFORE UPDATE 
ON employees_holding_post_not_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE populate_changed_employees();


/* ######################################################################################################## */

/* read only */


/******************************************************************************************************/

CREATE TYPE which_table_choices AS ENUM(
    'emp',
    'role_dept',
    'role'
);


/* if employee or roles_associated_with_department gets deleted then corresponding entery in all_email also get deleted */
CREATE TABLE all_email(
    email VARCHAR PRIMARY KEY NOT NULL,
    which_table which_table_choices NOT NULL
);


/******************************************************************************************************/

CREATE OR REPLACE FUNCTION add_emp_email_to_all_email() RETURNS TRIGGER AS
$$
BEGIN
	INSERT INTO all_email (email, which_table) VALUES (NEW.employee_email_id, 'emp');
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER add_emp_email_to_all_email_trigger
BEFORE INSERT
ON employees
FOR EACH ROW
EXECUTE PROCEDURE add_emp_email_to_all_email();


/******************************************************************************************************/


CREATE OR REPLACE FUNCTION add_role_dept_email_to_all_email() RETURNS TRIGGER AS
$$
BEGIN
	INSERT INTO all_email (email, which_table) VALUES (NEW.role_email_id, 'role_dept');
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER add_role_dept_email_to_all_email_trigger
BEFORE INSERT
ON employees_holding_post_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE add_role_dept_email_to_all_email();


/******************************************************************************************************/



CREATE OR REPLACE FUNCTION add_role_email_to_all_email() RETURNS TRIGGER AS
$$
BEGIN
	INSERT INTO all_email (email, which_table) VALUES (NEW.post_email_id, 'role');
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER add_role_email_to_all_email_trigger
BEFORE INSERT
ON employees_holding_post_not_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE add_role_email_to_all_email();

/******************************************************************************************************/



CREATE OR REPLACE FUNCTION delete_role_dept_email_to_all_email() RETURNS TRIGGER AS
$$
BEGIN
	DELETE FROM all_email WHERE email = OLD.role_email_id;
	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delete_role_dept_email_to_all_email_trigger
AFTER DELETE
ON employees_holding_post_associated_with_department
FOR EACH ROW
EXECUTE PROCEDURE delete_role_dept_email_to_all_email();


/******************************************************************************************************/


CREATE OR REPLACE FUNCTION delete_employee_email_to_all_email() RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM all_email WHERE email = OLD.employee_email_id;
	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delete_employee_email_to_all_email_trigger
AFTER DELETE
ON employees
FOR EACH ROW
EXECUTE PROCEDURE delete_employee_email_to_all_email();

/* ######################################################################################################## */


/* read only */
/* if admin deletes a workflow a warning will be shown to him that the pending applications of the workflow gets deleted permanently */


/************************************************************************************************************/

/* update,insert,delete is allowed */
CREATE TABLE workflow_details(
    workflow_id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(100) NOT NULL,
    workflow_description TEXT NOT NULL,
    created_by_email VARCHAR REFERENCES employees_holding_post_not_associated_with_department(post_email_id) NOT NULL,
    created_by_username VARCHAR(100) REFERENCES is_user_deleted(username) NOT NULL ,
    created_on_date DATE DEFAULT CURRENT_DATE NOT NULL,
    application_form_ui json NOT NULL
);

/* admin and sys-admin both can insert in this table */
CREATE TABLE workflow_editors(
    workflow_id INTEGER REFERENCES workflow_details(workflow_id)  ON DELETE CASCADE NOT NULL,
    post_email_id VARCHAR REFERENCES employees_holding_post_not_associated_with_department(post_email_id) NOT NULL 
);

/* put role_name = 'employee' and department for the employees */
CREATE TABLE workflow_accessed_by_emp_and_role_dept(
    workflow_id INTEGER REFERENCES workflow_details(workflow_id)  ON DELETE CASCADE NOT NULL,
    role_name  VARCHAR(100) REFERENCES roles_associated_with_department(role_name) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL ,
    department_name VARCHAR(100) REFERENCES departments(department_name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE workflow_accessed_by_role(
    workflow_id INTEGER REFERENCES workflow_details(workflow_id) ON DELETE CASCADE NOT NULL ,
    role_name  VARCHAR(100) REFERENCES roles_not_associated_with_department(role_name)  ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE is_workflow_deleted(
    workflow_id INTEGER NOT NULL PRIMARY KEY,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

/* can't delete a role which is involved in a workflow */
/*  BUT when we delete a dep than all its workflows and roles gets deleted */
/* update,insert,delete allowed */
CREATE TABLE workflow_node(
    workflow_id INTEGER REFERENCES workflow_details(workflow_id) ON DELETE CASCADE NOT NULL, 
    stage INTEGER NOT NULL ,
    role_email_id VARCHAR REFERENCES all_email(email) ON DELETE RESTRICT NOT NULL,
    notification BOOLEAN DEFAULT TRUE NOT NULL,
    duration INTERVAL DEFAULT NULL,
    reassign_role_email_id VARCHAR REFERENCES all_email(email) ON DELETE RESTRICT DEFAULT NULL,
    can_take_decision BOOLEAN DEFAULT FALSE NOT NULL,
    reassigned_on DATE DEFAULT NULL,
    PRIMARY KEY(workflow_id, stage)
);

/************************************************************************************************************/


CREATE OR REPLACE FUNCTION populate_is_workflow_deleted() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO is_workflow_deleted(workflow_id) VALUES (NEW.workflow_id);
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER populate_is_workflow_deleted_trigger
BEFORE INSERT
ON workflow_details
FOR EACH ROW
EXECUTE PROCEDURE populate_is_workflow_deleted();

/************************************************************************************************************/


CREATE OR REPLACE FUNCTION update_is_workflow_deleted() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE is_workflow_deleted SET is_deleted = TRUE WHERE workflow_id = OLD.workflow_id;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER update_is_workflow_deleted_trigger
AFTER DELETE
ON workflow_details
FOR EACH ROW
EXECUTE PROCEDURE update_is_workflow_deleted();

/* ######################################################################################################## */

/* read only */
/* on deleting a department all the workflows and applications related to it gets deleted */
/* on deleting a pending application its corresponding rows in action_on_application table and all_applications gets deleted */


/**************************************************************************************************/

CREATE TYPE action_type AS ENUM(
    'pending',
    'approve',
    'reject',
    'forward',
    'revert'
);


CREATE TABLE pending_applications(
    application_id SERIAL PRIMARY KEY ,
    workflow_id INTEGER REFERENCES workflow_details(workflow_id)  ON DELETE CASCADE NOT NULL,
    initiated_by_email VARCHAR REFERENCES all_email(email) ON DELETE CASCADE NOT NULL,
    username VARCHAR(100) REFERENCES is_user_deleted(username) NOT NULL,
    current_stage INTEGER UNIQUE,          /* what happem on deleting*/
    time_stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    redirect_stage INTEGER DEFAULT NULL,        /*what happen on deleting */
    status action_type NOT NULL,
    application_form_data json NOT NULL   ,                  /*for the time being consider we are storing it as a json object */
    date_of_assignment DATE DEFAULT CURRENT_DATE
);

/* includes all the pending and closed applications */
CREATE TABLE all_applications(
    application_id INTEGER PRIMARY KEY,
    approved_or_rejected action_type NOT NULL           /* change this */
);

/* document attachment can be done later */
CREATE TABLE action_on_application(
    application_id INTEGER REFERENCES all_applications(application_id)  ON DELETE CASCADE NOT NULL,
    stage INTEGER NOT NULL,
    action_by_email VARCHAR NOT NULL,     
    action_by_username  VARCHAR(100) REFERENCES is_user_deleted(username) NOT NULL,
    date_of_action DATE DEFAULT CURRENT_DATE NOT NULL,
    date_of_assignment DATE NOT NULL,
    comments TEXT DEFAULT NULL,
    action action_type NOT NULL,
    document BYTEA,
    PRIMARY KEY(stage, application_id)
);

CREATE TABLE closed_applications(
    application_id INTEGER REFERENCES all_applications(application_id)  ON DELETE CASCADE NOT NULL,
    workflow_id INTEGER REFERENCES is_workflow_deleted(workflow_id) NOT NULL,
    initiated_by_email VARCHAR NOT NULL,
    username VARCHAR(100) REFERENCES is_user_deleted(username) NOT NULL,
    time_stamp TIMESTAMP NOT NULL,
    closed_application_on_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status action_type NOT NULL,
    application_form_data json NOT NULL
    /* put application form in json format */
);



/*********************************************************************************************************************************************************************/


CREATE OR REPLACE FUNCTION populate_all_applications() RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO all_applications VALUES (NEW.application_id, approved_or_rejected = 'pending');
    RETURN NEW;

END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER populate_all_applications_trigger
BEFORE INSERT
ON pending_applications
FOR EACH ROW
EXECUTE PROCEDURE populate_all_applications();



/*********************************************************************************************************************************************************************/


CREATE OR REPLACE FUNCTION delete_from_all_applications() RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.status = 'pending' THEN
        DELETE FROM all_applications WHERE application_id = OLD.application_id;
    END IF;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER delete_from_all_applications_trigger
AFTER DELETE
ON pending_applications
FOR EACH ROW
EXECUTE PROCEDURE delete_from_all_applications();



/***************************************************************************************************************************************************************/

/* later store document in the table */
/* only one application can be launched by a  person of a particular workflow at a time*/
/* Assumption: Atleast one node should be there on path other than owner */
CREATE OR REPLACE PROCEDURE launch_new_application(workflow_id INTEGER, la_email_id VARCHAR, application_form_data json, comments TEXT, doc BYTEA)
LANGUAGE plpgsql
AS $$
DECLARE
    la_username VARCHAR(100);
    la_which_table which_table_choices;
    la_emp_email_id VARCHAR;
    la_app_id INTEGER;
BEGIN
    SELECT which_table INTO la_which_table FROM all_email WHERE email = la_email_id;

    IF la_which_table = 'emp' THEN
        SELECT username INTO la_username FROM employees WHERE employee_email_id = la_email_id;
    ELSIF la_which_table = 'role_dept' THEN
        SELECT employee_email_id INTO la_emp_email_id  FROM employees_holding_post_associated_with_department WHERE role_email_id = la_email_id;
        SELECT username INTO la_username FROM employees WHERE employee_email_id = la_emp_email_id;
    ELSE    
        SELECT username INTO la_username FROM employees_holding_post_not_associated_with_department WHERE post_email_id = la_email_id;
    END IF;

    INSERT INTO pending_applications VALUES (DEFAULT, workflow_id, la_email_id, la_username, 1, now(), DEFAULT, 'pending', application_form_data, DEFAULT );
    SELECT application_id INTO la_app_id FROM pending_applications WHERE pending_applications.workflow_id = workflow_id AND initiated_by_email = la_email_id;
    INSERT INTO action_on_application VALUES (la_app_id, 0, la_email_id, la_username, DEFAULT, comments,doc);
	COMMIT;
END;
$$;    

/*********************************************************************************************************************************************************************/

/* call this function every time to check whether the current stage is last or not */
CREATE OR REPLACE FUNCTION can_approve_or_reject(la_current_stage INTEGER, la_workflow_id INTEGER) RETURNS BOOLEAN AS $$
DECLARE 
    final_stage INTEGER;
    val BOOLEAN;

BEGIN
    SELECT can_take_decision INTO val FROM workflow_node WHERE workflow_id = la_workflow_id AND stage = la_current_stage;
    IF val = TRUE THEN
        RETURN TRUE;
    ELSE    
        SELECT MAX(stage) INTO final_stage FROM workflow_node GROUP BY workflow_id HAVING workflow_id = la_workflow_id; 

        IF final_stage = la_current_stage THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;   
    END IF;         
END; $$
LANGUAGE PLPGSQL;

/*********************************************************************************************************************************************************************/

/* call this function only when can_approve_or_reject returns false */
/* later add duration constraint in it */
CREATE OR REPLACE PROCEDURE forward (la_app_id INTEGER, comments TEXT, la_email_id VARCHAR, la_username VARCHAR(255),doc BYTEA)
LANGUAGE plpgsql
AS $$
DECLARE
    la_current_stage INTEGER;
    la_redirect_stage INTEGER;

BEGIN
    SELECT current_stage, redirect_stage INTO la_current_stage, la_redirect_stage FROM pending_applications WHERE application_id = la_app_id;
    INSERT INTO action_on_application VALUES (la_app_id, la_current_stage, la_email_id, la_username, DEFAULT, comments,doc );
    
    IF la_redirect_stage IS NOT NULL  THEN
        UPDATE pending_applications SET redirect_stage = NULL , current_stage = la_redirect_stage WHERE application_id = la_app_id;
    ELSE
        UPDATE pending_applications SET current_stage = la_current_stage + 1, date_of_assignment = CURRENT_DATE WHERE application_id = la_app_id;
    END IF;
    COMMIT;
END;
$$;

/* ******************************************************************************************************************************************************************* */


/* call this procedure only when application is on the last stage or when the person has the right to take decision and check if it is working correctly or not */
CREATE OR REPLACE PROCEDURE approve_or_reject(la_app_id INTEGER , comments TEXT, la_email_id VARCHAR, la_username VARCHAR(255), action action_type,doc BYTEA)
LANGUAGE plpgsql
AS $$
DECLARE 
    la_current_stage INTEGER;
    la_row record;
    final_stage INTEGER;
    wrk_id INTEGER;

BEGIN
    SELECT current_stage,workflow_id INTO la_current_stage,wrk_id FROM pending_applications WHERE application_id = la_app_id;
    SELECT MAX(stage) INTO final_stage FROM workflow_node GROUP BY workflow_id HAVING workflow_id = wrk_id; 
    IF final_stage = la_current_stage OR action = 'reject' THEN 
        UPDATE pending_applications SET status = action WHERE application_id = la_app_id;
        UPDATE all_applications SET approved_or_rejected = action WHERE application_id = la_app_id;
        INSERT INTO action_on_application VALUES (la_app_id, la_current_stage, la_email_id, la_username, DEFAULT, comments,doc);
        SELECT * INTO la_row FROM pending_applications WHERE application_id = la_app_id;
        INSERT INTO closed_applications VALUES (la_row.application_id, la_row.workflow_id, la_row.initiated_by_email, la_row.username, la_row.time_stamp, DEFAULT, la_row.status, la_row.application_form_data);
        DELETE FROM pending_applications WHERE application_id = la_app_id;
    ELSE
        CALL forward(la_app_id,comments,la_email_id,la_username);

    END IF;    
    COMMIT;
END;
$$;    

/* ******************************************************************************************************************************************************************* */


CREATE OR REPLACE PROCEDURE redirect(la_app_id INTEGER, comments TEXT, la_email_id VARCHAR, la_username VARCHAR(255), la_redirect_stage INTEGER,doc BYTEA) 
LANGUAGE plpgsql
AS $$
DECLARE
    la_current_stage INTEGER;

BEGIN
    SELECT current_stage INTO la_current_stage FROM pending_applications WHERE application_id = la_app_id;
    UPDATE pending_applications SET redirect_stage = la_current_stage ,current_stage = la_redirect_stage, date_of_assignment = CURRENT_DATE WHERE application_id = la_app_id;
    INSERT INTO action_on_application VALUES (la_app_id, la_current_stage, la_email_id, la_username, DEFAULT, comments,doc);
    COMMIT;
END;
$$;

/* ******************************************************************************************************************************************************************* */


/* ######################################################################################################## */



CREATE TABLE temp_data_storage_table(
    emp_email_id VARCHAR PRIMARY KEY,
    password TEXT NOT NULL,
    username VARCHAR(255) UNIQUE,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL
);





















