from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import ValidationError, DataRequired, Email, EqualTo, InputRequired,Required
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from bwms_app import cursor


def get_department_list():
    cursor.execute("SELECT department_name FROM departments ")
    temp = cursor.fetchall()
    return temp

class Registration_Form(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    password2 = PasswordField(
        'Retype Password', validators=[DataRequired(), EqualTo('password')])
    name = StringField('Name', validators=[DataRequired()])
    submit = SubmitField('Send Confirmation Mail')

    def validate_username(self, username):
        cursor.execute("SELECT * FROM is_user_deleted where username = '"+ username.data+"'")
        temp = cursor.fetchone()
        if temp is not None:
            raise ValidationError('Please use a different username.') 
        cursor.execute("SELECT * from temp_data_storage_table where username = %s)",(username,))
        temp = cursor.fetchone()
        if temp is not None:
            raise ValidationError('Username already exists!')

    def validate_email(self, email):
        cursor.execute("SELECT * from is_employee_deleted where employee_email_id = '"+ email.data+ "'")
        temp = cursor.fetchone()
        if temp is not None:
            raise ValidationError('Please use a different email address.')
        cursor.execute("SELECT * from temp_data_storage_table where emp_email_id = %s)",(email,))
        temp = cursor.fetchone()
        if temp is not None:
            raise ValidationError('Email-ID already exists!')
