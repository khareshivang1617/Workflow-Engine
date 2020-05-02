from flask import Flask, flash, redirect, render_template, request, session, abort, url_for,Blueprint
from bwms_app import cursor

employee_bp = Blueprint('employee',__name__)

@employee_bp.route('/employee/home_page')
def home_page():
    return render_template('Employee/home_page.html')