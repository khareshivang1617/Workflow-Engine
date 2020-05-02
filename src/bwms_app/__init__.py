from flask import Flask
import psycopg2
from flask import Blueprint, render_template, redirect,url_for, request, flash
from flask_mail import Mail

app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config')
app.config.from_pyfile('config.py')
mail = Mail(app)
try:
    db_url = app.config['DATABASE_URI']
    print(db_url)
    conn = psycopg2.connect(db_url)
    conn.autocommit = True
    cursor = conn.cursor()

    ## uncomment these for checking the connection
    # print('PostgreSQL database version:')
    # cursor.execute('SELECT version()')
 
    # display the PostgreSQL database server version
    # db_version = cursor.fetchone()
    # print(db_version)
       
    # close the communication with the PostgreSQL
    # cursor.close()
except Exception as error:
    print(error)


from .views.system_admin import system_admin_bp
from .views.login import login_bp
from .views.register import register_bp
from .views.employee import employee_bp
from .views.common_views import common_views_bp
app.register_blueprint(system_admin_bp)
app.register_blueprint(login_bp)
app.register_blueprint(register_bp)
app.register_blueprint(common_views_bp)
app.register_blueprint(employee_bp)
