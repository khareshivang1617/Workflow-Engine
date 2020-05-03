from flask import Flask, flash, redirect, render_template, request, session, abort, url_for, Blueprint
from bwms_app import cursor
from flask_bootstrap import Bootstrap


admin_bp = Blueprint('admin',__name__)


@admin_bp.route('/admin')
def index():
    return render_template('admin/genericHomePage.html')

@admin_bp.route('/workflowEditor', methods=['POST', 'GET'])
def workflowEditor():
    if request.method == 'POST':
        JSONformLayout = request.form['custId']
        session['formdata'] = JSONformLayout
        print(JSONformLayout)

        JSONworkflowNodes = request.form['workflow_nodes']
        print(JSONworkflowNodes)

        JSONworkflowDetails = request.form['workflow_details']
        print(JSONworkflowDetails)

    admins = cursor.execute('SELECT post_email_id FROM employees_holding_post_not_associated_with_department WHERE role_name = 'admin')  
    # admins = ["admin1", "admin2", "admin3", "admin4", "admin5"]#this thing will be fetched from database
    role_dept = [["role_1","dept_1"],["role_2","dept_2"],["role_3","dept_3"],["role_4","dept_4"],["role_5","dept_5"]]#also fetched from the database
    roles = ["role_1","role_2","role_3","role_4","role_5"]#roles without any dept also fetched from the database
    return render_template('admin/workflowEditor.html', admins = admins, role_dept = role_dept, roles = roles)#the list of all ppl at all roles will be passed from here...

@admin_bp.route('/formBuilder')
def formBuilder():
    return render_template('admin/formbuilder.html')






