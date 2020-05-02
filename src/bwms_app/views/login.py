from flask import Flask, flash, redirect, render_template, request, session, abort, url_for,Blueprint
from bwms_app import cursor



login_bp = Blueprint('login',__name__)

@login_bp.route('/',methods= ['GET','POST'])
def login():
    error = ''
    try:

        if request.method == "POST":
            cursor.execute("SELECT * from all_email WHERE '"+request.form.get('email_id')+"' = email")
            email = request.form['email_id']
            password = request.form['pass']
            temp = cursor.fetchone()
            print(temp)
            if temp == None:
                return render_template('index.html',msg = 'Email Id not registered')
            employee_type = temp[1]

            if employee_type == 'emp':
                cursor.execute("SELECT * FROM employees WHERE '"+email +"'= employee_email_id AND password = crypt('"+ password+"',password) ")

            elif employee_type == 'role_dept':
                cursor.execute("SELECT * FROM employees_holding_post_associated_with_department WHERE '"+ email+"'=role_email_id and password=crypt('"+ password+"',password)")
            else:
                cursor.execute("SELECT * FROM employees_holding_post_not_associated_with_department WHERE '"+ email+"'=post_email_id and password= crypt('"+ password+"',password)") 

            temp = cursor.fetchone()   
            print(temp)

            if temp == None:
                return render_template('index.html', msg = 'Invalid credentials')
            # store the login position details in session as session['login_employee']
            session['login_employee'] = temp
            session['emailid'] = email
            session['employee_typ'] = employee_type

            if employee_type == 'role_dept':
                cursor.execute("SELECT username FROM employees WHERE employee_email_id = '"+ temp[2]+"'")
                username_row = cursor.fetchone()
                username = username_row[0]

            else :
                username = temp[2]

            cursor.execute("SELECT * FROM users WHERE username = '"+ username +"'")
            temp = cursor.fetchone()
            #  store the users informations in session as session[login_user]
            session['login_user'] = temp

            if employee_type == 'emp':
                return render_template('Employee/home_page.html')
            elif employee_type == 'role_dept':
                return render_template('Role_dept/home_page.html')
            else:
                if session['login_employee'][4] == 'System Admin':
                    return render_template('system_admin/home_page.html')
                elif session['login_employee'][4] == 'Admin':
                    return render_template('Role/Admin/home_page.html')
                elif session['login_employee'][4] == 'Supervisor':
                    return render_template('Role/Supervisor/home_page.html')
                else:
                    return render_template('Role/Employee/home_page.html')        

                

        return render_template("Authentication/index.html", error = error)

    except Exception as e:
        flash(e)
        return render_template("Authentication/index.html", error = error)







