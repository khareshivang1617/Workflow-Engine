from flask import Flask, flash, redirect, render_template, request, session, abort, url_for,Blueprint
from bwms_app import cursor
from bwms_app.forms import Registration_Form
import bcrypt

register_bp = Blueprint('register', __name__)

@register_bp.route('/register',methods = ['GET','POST'])
def register():
    form = Registration_Form()
    if form.validate_on_submit():
        depart_name = str(request.form.get('department'))
        print(depart_name)
        cursor.execute("Insert into temp_data_storage_table values ('"+form.email.data+"',crypt('"+ form.password.data+"',gen_salt('bf')),'" + form.username.data+"','"+ form.name.data+"','"+ depart_name+"')")
        flash("You will be notified through email regarding the registration request.")
        return redirect(url_for('login.login'))
    cursor.execute("SELECT department_name FROM departments ")
    temp = cursor.fetchall()    
    return render_template('Authentication/register.html', form= form, items = temp)
