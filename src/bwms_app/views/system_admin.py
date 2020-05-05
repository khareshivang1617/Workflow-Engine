from flask import Flask, flash, redirect, render_template, request, session, abort, url_for, Blueprint
import os
from dotenv import load_dotenv
import psycopg2
import json
import datetime
from bwms_app import cursor
from bwms_app import conn
from datetime import datetime
from datetime import date

system_admin_bp = Blueprint('system_admin',__name__)


#  define the functions here and routes for system admin

@system_admin_bp.route('/system_admin/home_page')
def home_page():
    return render_template('system_admin/home_page.html')


@system_admin_bp.route('/system_admin/add_non_dept_roles',  methods=["POST", "GET"])
def add_non_dept_roles():
    if request.method == "POST":
        role_name = request.form['role_name']
        print(role_name)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO roles_not_associated_with_department (role_name) VALUES (%s);", (role_name,))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_not_associated_with_department")
        role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/non_dept_roles.html', role_data=role_data)    

@system_admin_bp.route('/system_admin/delete_role/<role_name>', methods=["POST", "GET"])
def delete_non_dept_role(role_name):
    print(role_name)
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM roles_not_associated_with_department WHERE role_name = %s", [role_name])
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return redirect(url_for('system_admin.add_non_dept_roles'))


@system_admin_bp.route('/system_admin/add_dept_roles',  methods=["POST", "GET"])
def add_dept_roles():
    if request.method == "POST":
        role_name = request.form['role_name']
        print(role_name)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO roles_associated_with_department (role_name) VALUES (%s);", (role_name,))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_associated_with_department")
        role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/dept_roles.html', role_data=role_data)

@system_admin_bp.route('/system_admin/delete_non_dept_role/<role_name>', methods=["POST", "GET"])
def delete_dept_role(role_name):
    print(role_name)
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM roles_associated_with_department WHERE role_name = %s", [role_name])
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return redirect(url_for('system_admin.add_dept_roles'))


@system_admin_bp.route('/system_admin/show_roles',  methods=["POST", "GET"])
def show_all_roles():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_not_associated_with_department")
        role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_associated_with_department")
        department_role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()    
    return render_template('/system_admin/show_roles.html', role_data=role_data, department_role_data = department_role_data)        


@system_admin_bp.route('/system_admin/department_actions',  methods=["POST", "GET"])
def CRD_departments():
    
    if request.method == "POST":
        department = request.form['department']
        print(department)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO departments (department_name, start_date) VALUES (%s, CURRENT_DATE);", (department,))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM departments")
        data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/CRD_departments.html', data=data)            

# @system_admin_bp.route('/system_admin/edit_departments',  methods=["POST", "GET"])
# def edit_departments()
@system_admin_bp.route('/system_admin/delete_department/<department_name>', methods=["POST", "GET"])
def delete_department(department_name):
    print(department_name)
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM departments WHERE department_name = %s", [department_name])
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return redirect(url_for('system_admin.CRD_departments'))

@system_admin_bp.route('/system_admin/show_departments',  methods=["POST", "GET"])
def show_departments():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM departments")
        data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('/system_admin/show_departments.html', data=data)        

@system_admin_bp.route('/system_admin/delete_employee/<username>', methods=["POST", "GET"])
def delete_employee(username):
    print(username)
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM employees WHERE username = %s", [username])
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return redirect(url_for('system_admin.RD_employees'))

@system_admin_bp.route('/system_admin/employees',  methods=["POST", "GET"])
def RD_employees():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM employees")
        data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/RD_employees.html', data=data)            


@system_admin_bp.route('/system_admin/assign_emp_non_dept_role',  methods=["POST", "GET"])
def assign_emp_non_dept_role():
    
    if request.method == "POST":
        role_name = request.form['role_name']
        post_email_id = request.form['post_email_id']
        password = request.form['password']
        username = request.form['username']
        start_date = request.form['start_date']
        
        print(username)
        print(password)
        print(post_email_id)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO employees_holding_post_not_associated_with_department (post_email_id, password, username, start_date, role_name) VALUES (%s, %s, %s, %s ,%s);", (post_email_id, password, username, start_date, role_name,))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_not_associated_with_department")
        role_data = cur.fetchall()
        cur.execute("SELECT * FROM users")
        user_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/assign_emp_non_dept_role.html', role_data = role_data, user_data = user_data)            

@system_admin_bp.route('/system_admin/show_assigned_role',  methods=["POST", "GET"])
def show_assigned_role():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM employees_holding_post_not_associated_with_department")
        assigned_role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/show_assigned_role.html', assigned_role_data = assigned_role_data)            

@system_admin_bp.route('/system_admin/edit_assigned_role/<post_email_id>',  methods=["POST", "GET"])
def edit_assigned_role(post_email_id):
    
    if request.method == "POST":
        password = request.form['password']
        username = request.form['username']
        start_date = request.form['start_date']
        print(username)
        print(password)
        print(post_email_id)
        print(start_date)
        print(type(start_date))
        start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
        print(start_date)
        print(type(start_date))        
        try:
            cur = conn.cursor()
            cur.execute("Update employees_holding_post_not_associated_with_department set password = %s ,  username = %s , start_date = %s where post_email_id = %s", ( password, username, start_date , post_email_id))
            conn.commit()

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
        return redirect(url_for('system_admin.show_assigned_role'))
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM users")
        user_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/edit_assigned_role.html', post_email_id = post_email_id, user_data = user_data)

@system_admin_bp.route('/system_admin/assign_emp_dept_role',  methods=["POST", "GET"])
def assign_emp_dept_role():
    
    if request.method == "POST":
        role_email_id = request.form['role_email_id']
        employee_email_id = request.form['employee_email_id']
        password = request.form['password']
        department = request.form['department']
        role_name = request.form['role_name']
        employee_assigned_post_date = request.form['employee_assigned_post_date']
        print(employee_assigned_post_date)
        print(role_name)
        print(role_email_id)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO employees_holding_post_associated_with_department (role_email_id, password, employee_email_id, department, role_name, employee_assigned_post_date) VALUES (%s, %s, %s, %s, %s, %s);", (role_email_id, password, employee_email_id, department, role_name, employee_assigned_post_date))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM roles_associated_with_department")
        role_data = cur.fetchall()
        cur.execute("SELECT * FROM employees")
        employees_data = cur.fetchall()
        cur.execute("SELECT * FROM departments")
        departments_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/assign_emp_dept_role.html', role_data = role_data, employees_data = employees_data, departments_data = departments_data)            

@system_admin_bp.route('/system_admin/show_assigned_dept_role',  methods=["POST", "GET"])
def show_assigned_dept_role():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM employees_holding_post_associated_with_department")
        assigned_role_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/show_assigned_dept_role.html', assigned_role_data = assigned_role_data)            

@system_admin_bp.route('/system_admin/edit_assigned_dept_role/<role_email_id>',  methods=["POST", "GET"])
def edit_assigned_dept_role(role_email_id):
    
    if request.method == "POST":
        password = request.form['password']
        employee_email_id = request.form['employee_email_id']
        employee_assigned_post_date = request.form['employee_assigned_post_date']
        try:
            cur = conn.cursor()
            cur.execute("Update employees_holding_post_associated_with_department set password = %s ,  employee_email_id = %s , employee_assigned_post_date = %s where role_email_id = %s", ( password, employee_email_id , employee_assigned_post_date, role_email_id ))
            conn.commit()

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
        return redirect(url_for('system_admin.show_assigned_dept_role'))
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM employees")
        employees_data = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        cur.execute('rollback')
    cur.close()
    return render_template('system_admin/edit_assigned_dept_role.html', role_email_id = role_email_id, employees_data = employees_data)


@system_admin_bp.route('/system_admin/registration_requests/<email>/<action>')
def action_on_request(email,action):
    if action=='Approve':
        cursor.execute("SELECT * FROM temp_data_storage_table where emp_email_id = %s",(email,))
        temp = cursor.fetchone()
        cursor.execute("insert into users(username,name) values (%s,%s)",(temp[2],temp[3],))
        cursor.execute("insert into employees(employee_email_id,password,username,department) values (%s,%s,%s,%s)",(temp[0],temp[1],temp[2],temp[4],))

    cursor.execute("delete from temp_data_storage_table where emp_email_id = %s",(email,))
    return redirect(url_for('system_admin.registration_requests'))

@system_admin_bp.route('/system_admin/registration_requests')
def registration_requests():
    cursor.execute("select * from temp_data_storage_table")
    temp = cursor.fetchall()
    return render_template('system_admin/registration_requests.html',requests = temp)    