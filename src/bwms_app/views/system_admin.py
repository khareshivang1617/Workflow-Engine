from flask import Flask, flash, redirect, render_template, request, session, abort, url_for, Blueprint
import os
from dotenv import load_dotenv
import psycopg2
import json
import datetime
from bwms_app import cursor


system_admin_bp = Blueprint('system_admin',__name__)


#  define the functions here and routes for system admin


@system_admin_bp.route("/system_admin")
def 