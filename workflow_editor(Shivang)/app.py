from flask import Flask, render_template, request, redirect, g, url_for
import json
#from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://scott:shiwang@localhost:5432/my_db    '
#db = SQLAlchemy(app)
#l = [["Node1",200,10,248,271,50,50], ["Node2",270,10,318,341,50,50], ["Node3",340,10,368,368,69,98]]#A particular worflow's description..... #finded by using the database...

workflow_details=[["Node1",200,10,248,271,50,50], ["Node2",270,10,318,341,50,50], ["Node3",340,10,368,368,69,98]]
workflow_basic_details=["WOrkflowName","workflowDescription",["admin_1", "admin_2", "admin_3"],[["role_1,dept_1"],["role_2","dept_2"],["role_3","dept_3"]],["role_1","role_2","role_3"]]
node_index_editing=-1

@app.route("/")
def workflow_editor():
    #when this page is opened everything is fetched from databases and put into the list...
    #here we will fetch the json object fromt the database... convert it back to the list (for now atleast) and split apart workflow_details and workflow_basic_details lists...

    print(workflow_details)

    return render_template("basicui2.html", list=workflow_details) #end_x=247,end_y=65)
#render_template("basicui2.html")

@app.route("/node_configure",  methods=["GET", "POST"])
def node_configure():
    node_name="garbageNode"

    node_name=request.form["node_name"]

    for i in range(len(workflow_details)):####needs to be changed... must be started from 1, currently starting from 0

        if workflow_details[i][0]==node_name:
            print("setting the node index editing var")
            node_index_editing=i
            print(node_index_editing)



    return render_template("node_configuration.html", node_index=node_index_editing,node_details=workflow_details[node_index_editing])

@app.route("/node_data_save", methods=["GET","POST"])
def node_data_save():

    print("Saving the node...")

    name=request.form["node_name"]
    description=request.form["description"]
    role_mail_id=request.form["role_mail_id"]
    duration=request.form["duration"]
    node_index_editing=int(request.form["node_index"])

    #node_index_editing...

    print("workflow before editing...")    
    print(workflow_details)

    if name!="":
        workflow_details[node_index_editing][0]=name

    workflow_details[node_index_editing][1]=description

    if role_mail_id!="":
        workflow_details[node_index_editing][2]=role_mail_id
    
    if duration!="":
        workflow_details[node_index_editing][3]=duration

    print("workflow after editing...")
    print(workflow_details)

    #from the list pick up the node with the given node_id_editing and change the stuff accordingly

    return redirect(url_for("workflow_editor"))


@app.route("/new_node")
def new_node():
    
    #making and inserting a new node in the list...
    node_details=["newNode","Description","role-mail-id","duration"]
    workflow_details.append(node_details)
    node_index_editing=len(workflow_details)-1#correct it once the rest of the stuff is done...

    #storing the 
    return render_template("node_configuration.html", node_index=node_index_editing, node_details=workflow_details[node_index_editing])


@app.route("/node_remove",methods=["GET","POST"])
def remove_node():

    node_name=request.form["node_name"]
    
    for i in range(len(workflow_details)):####needs to be changed... must be started from 1, currently starting from 0

        if workflow_details[i][0]==node_name:
            print("setting the node index editing var")
            node_index_removing=i
            
    del workflow_details[node_index_removing]

    return redirect(url_for("workflow_editor"))



@app.route("/save_workflow")
def save_workflow():
    #Here we'll concatenate the workflow_details and workflow_basic_details list and convert it to json and store in the database

    workflow=[workflow_basic_details]+workflow_details
    print(workflow)
    #converting workflow to json file....

    my_json_string = json.dumps(workflow)
    print(my_json_string)

    return "<h2>successfully saved workflow!</h2>"

#@app.route("/workflow_basic_detail_save")###for its name and description saving...

#@app.route("/give_privilage")###give the privilage to be the admin OR to access the workflow....(still need to think about this a lot!)


if __name__ == "__main__":
    app.run(debug=True)

    