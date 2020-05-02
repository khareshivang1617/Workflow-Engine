from flask import Flask, flash, redirect, render_template, request, session, abort, url_for,Blueprint
from bwms_app import cursor

common_views_bp = Blueprint('common_views',__name__)


@common_views_bp.route('/workflows')
def workflows():
    employee_typ = session['employee_typ']
    login_employee = session['login_employee']
    if employee_typ == 'role_dept':
        role_name = login_employee[8]
        department = login_employee[3]
        cursor.execute("select * from workflow_details where workflow_id in (select workflow_id from workflow_accessed_by_emp_and_role_dept where role_name = %s and department_name = %s)",(role_name,department,))
    elif employee_typ == 'emp':
        role_name = 'employee'
        department = login_employee[3]
        cursor.execute("select * from workflow_details where workflow_id in (select workflow_id from workflow_accessed_by_emp_and_role_dept where role_name = %s and department_name = %s)",(role_name,department,))
    else:
        role_name = login_employee[4]
        cursor.execute("select * from workflow_details where workflow_id in (select workflow_id from workflow_accessed_by_role where role_name = %s)",(role_name,))
    temp = cursor.fetchall()
    return render_template()
    