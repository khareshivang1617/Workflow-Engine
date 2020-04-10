from flask import Flask, flash, redirect, render_template, request, session, abort, url_for, Blueprint
import os
from dotenv import load_dotenv
import psycopg2
import json
import datetime
from bwms_app import cursor
from bwms_app import conn


system_admin_bp = Blueprint('system_admin',__name__)


#  define the functions here and routes for system admin


@system_admin_bp.route('/system_admin/home_page')
def home_page():
    return render_template('system_admin/home_page.html')


@system_admin_bp.route('/system_admin/add_roles',  methods=["POST", "GET"])
def add_roles():
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
    return render_template('system_admin/add_roles.html')    

@system_admin_bp.route('/system_admin/add_department_roles',  methods=["POST", "GET"])
def add_department_roles():
    if request.method == "POST":
        department_role_name = request.form['department_role_name']
        print(department_role_name)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO roles_associated_with_department (role_name) VALUES (%s);", (department_role_name,))
            conn.commit()
            
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            cur.execute('rollback')
        cur.close()
    return render_template('system_admin/add_roles.html')    

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


@system_admin_bp.route('/system_admin/add_departments',  methods=["POST", "GET"])
def add_departments():
    
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
    return render_template('system_admin/add_departments.html')            

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

@system_admin_bp.route('/system_admin/assign_emp_on_role',  methods=["POST", "GET"])
def assign_emp_on_role():
    
    if request.method == "POST":
        role_name = request.form['role_name']
        post_email_id = request.form['post_email_id']
        password = request.form['password']
        username = request.form['username']
        print(password)
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO employees_holding_post_not_associated_with_department (post_email_id, password, username, start_date, role_name) VALUES (%s, %s, %s, CURRENT_DATE, %s);", (post_email_id, password, username,role_name,))
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
    return render_template('system_admin/assign_emp_on_role.html', role_data = role_data)            
