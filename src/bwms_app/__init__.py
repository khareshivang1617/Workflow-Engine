from flask import Flask
import psycopg2
from flask import Blueprint, render_template, redirect,url_for, request, flash

app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config')
app.config.from_pyfile('config.py')
try:
    db_url = app.config['DATABASE_URI']
    conn = psycopg2.connect(db_url)
    cursor = conn.cursor()

    # uncomment this for checking the connection
    # print('PostgreSQL database version:')
    # cur.execute('SELECT version()')
 
    # # display the PostgreSQL database server version
    # db_version = cur.fetchone()
    # print(db_version)
       
    # # close the communication with the PostgreSQL
    # cur.close()
except Exception as error:
    print(error)


# @app.route("/")
# def hello():
#     return render_template('index.html')

from .views.system_admin import system_admin_bp
app.register_blueprint(system_admin_bp)