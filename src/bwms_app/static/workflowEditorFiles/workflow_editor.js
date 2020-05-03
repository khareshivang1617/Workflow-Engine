const loopContainer = document.getElementById("loopContainer");
const nodeAddBtn = document.getElementById("nodeAdd");
const newNodeForm = document.getElementById("node_add_form");
const saveNodeConfig = document.getElementById("save_node_config");
const nodeConfigBtn = document.getElementById("node_config_form");
const generalConfig = document.getElementById("general_config");
const saveGenConfig = document.getElementById("save_general_config");
const finalSubmitBtn= document.getElementById("final-submit-btn");

var nodes_data_array=[

    {
        'name' : 'Node 1',
        'description' : 'description 1',
        'role_assigned' : 'role 1',
        'duration' : '',
        'x0' : 200,
        'y0' : 10,
        'x1' : 248,
        'x2' : 271,
        'y1' : 50,
        'y2' : 50

    },

    {
        'name' : 'Node 2',
        'description' : 'description 2',
        'role_assigned' : 'role 2',
        'duration' : '',
        'x0' : 270,
        'y0' : 10,
        'x1' : 318,
        'x2' : 341,
        'y1' : 50,
        'y2' : 50

    },

    {
        'name' : 'Node 3',
        'description' : 'description 3',
        'role_assigned' : 'role 3',
        'duration' : '',
        'x0' : 340,
        'y0' : 10,
        'x1' : 368,
        'x2' : 368,
        'y1' : 69,
        'y2' : 98

    }
];

//[workflow_name,workflow_description,workflow_admins_list,workflow_accesses_by_emp_and_role_dept, workflow_accessed_by_role]
//workflow_basic_details=["WOrkflowName","workflowDescription",["admin_1", "admin_2", "admin_3"],[["role_1,dept_1"],["role_2","dept_2"],["role_3","dept_3"]],["role_1","role_2","role_3"]]

var workflow_details= {

    'id' : 'workflow_id0000',
    'name' : 'Test_workflow',
    'description' : 'Some description',
    'workflow_admins' : ['admin1','admin2','admin3'],
    
    'workflow_accesses_by_emp_and_role_dept' : [
        {
            'role' : 'role_1',
            'dept' : 'dept_1'
        },
        {
            'role' : 'role_2',
            'dept' : 'dept_2'
        },
        {
            'role' : 'role_3',
            'dept' : 'dept_3'
        }
    ],

    'workflow_accesses_by_role' : ['role_1','role_2','role_3']

};
document.getElementById("workflow_id").setAttribute("value",workflow_details.id)//document.getElementById("workflow_id"),innerHTML=workflow_details.id;
document.getElementById("workflow_name").setAttribute("value",workflow_details.name);//document.getElementById("workflow_name").innerHTML=workflow_details.name;
document.getElementById("workflow_description").innerHTML=workflow_details.description;

var workflow_admins = workflow_details.workflow_admins;
var workflow_accesses_role_dept = workflow_details.workflow_accesses_by_emp_and_role_dept;
var workflow_accesses_role = workflow_details.workflow_accesses_by_role;


const checkBoxList = document.querySelectorAll(".checks");

for(var i=0;i < checkBoxList.length; i++){
    console.log(i);
    if(workflow_admins.includes(checkBoxList[i].value))
        checkBoxList[i].checked = true;

    if(workflow_accesses_role_dept.includes(checkBoxList[i].value))
        checkBoxList[i].checked = true;
    
    if(workflow_accesses_role.includes(checkBoxList[i].value))
        checkBoxList[i].checked = true;
            
}


function fetchAndSendData(){

    try {
        defaultFormData = localStorage.getItem("formData");
        console.log('Form dAta set');


        
        
       
    } catch (error) {
        console.log("formData not set yet. Sending default form data");
        
    }   
    finally{
        console.log('sent');
        document.getElementById("custId").setAttribute("value",defaultFormData);

        const nodes_data_array_serialized=JSON.stringify(nodes_data_array);
        const workflow_details_serialized=JSON.stringify(workflow_details);
        document.getElementById("workflow_nodes").setAttribute("value",nodes_data_array_serialized);
        document.getElementById("workflow_details").setAttribute("value",workflow_details_serialized);
        
        document.getElementById("serverSubmit").submit();
        
    }

}











function sendLoopContainer(){

    //make and call the function over here to set the coordinate attributs for UI display...

    setDisplayCoordinates();

    loopContainer.innerHTML+= `
    <g transform="translate(100)">
    <circle fill="#000" cx="55" cy="50" r="15" opacity="1" />
    <text x="42" y="53" font-family="Open Sans Condensed" font-size="7" stroke="none" fill="#f5f3e7" font-weight="100" style="text-transform:uppercase; letter-spacing: 1px">    Start</text>
    <line x1="90" x2="130" y1="50" y2="50" stroke-width="2" stroke="#443c3d" stroke-dasharray="2,1" />
    </g>

    <line x1="172" x2="195" y1="50" y2="50" stroke-width="2" stroke="#443c3d" stroke-dasharray="2,1" />
    `;

    for(var i = 0; i < nodes_data_array.length; i++ ){

        const x0 = nodes_data_array[i].x0;
        const y0= nodes_data_array[i].y0;
        const x1= nodes_data_array[i].x1;
        const y1= nodes_data_array[i].y1;
        const x2= nodes_data_array[i].x2;
        const y2 = nodes_data_array[i].y2;
        const name = nodes_data_array[i].name;
        console.log(x0, y0);
        const html = 
        `<g transform="transsubmitlate(${x0},${y0})">
            <rect fill="#66cc00" x="2" y="25" rx="3" ry="3" width="45" height="30" />
            
            <text x="8" y="33" font-family="Open Sans Condensed" font-size="7" stroke="none" fill="#f5f3e7" font-weight="900" style="text-transform:uppercase; letter-spacing: 1px onclick="document.getElementById('id05').style.display='block'">${name}
            </text>

            <text id="${i}" class = "remove" x="8" y="52" font-family="Open Sans Condensed" font-size="4" stroke="none" fill="#f5f3e7" font-weight="900" style="text-transform:uppercase; letter-spacing: 1px">
            Rem
            </text>

            <text id = "${i}" class = "config" x="25" y="52" font-family="Open Sans Condensed" font-size="4" stroke="none" fill="#f5f3e7" font-weight="900" style="text-transform:uppercase; letter-spacing: 1px">
            Config
            </text>
        </g>
        <!--###########################################WORKFLOW#################################################-->
        <line x1=${x1} x2=${x2} y1=${y1} y2=${y2} stroke-width="2" stroke="#443c3d" stroke-dasharray="2,1" />`;

        loopContainer.innerHTML+=html;
        
        //$( loopContainer ).load(window.location.href + loopContainer );
    }

    var x_end = nodes_data_array[nodes_data_array.length-1].x0+32
    var y_end = nodes_data_array[nodes_data_array.length-1].y0

    loopContainer.innerHTML+= `
    <g transform="translate(${x_end},${y_end})">
    <circle fill="#000" cx="55" cy="50" r="15" opacity="1" />
    <text x="47" y="52" font-family="Open Sans Condensed" font-size="7" stroke="none" fill="#f5f3e7" font-weight="100" style="text-transform:uppercase; letter-spacing: 1px">End</text>
    </g>
    `;

    document.getElementById("new_node_index").setAttribute("value", nodes_data_array.length+1);
}

sendLoopContainer();

loopContainer.addEventListener('click', e=>{
    if(e.target.getAttribute("class") == 'remove'){
        var nodeIndex = e.target.getAttribute("id");
        console.log(nodeIndex);
        //remove node with this index
        nodes_data_array.splice(nodeIndex,1);
        console.log(nodes_data_array);

        //Code to again reload the UI display of workflow..
        sendLoopContainer();
        
        
    }
    else if(e.target.getAttribute("class") == 'config'){
        var nodeIndex = e.target.getAttribute("id");
        console.log(nodeIndex);

        document.getElementById("node_name").setAttribute("value",innerHTML=nodes_data_array[nodeIndex].name);//not working yet
        //set the placeholders in the corresponding forms...


        document.getElementById('id02').style.display='block';
    }
});




nodeAddBtn.addEventListener('click', (e)=>{
    e.preventDefault();
    //const nodeIndex = document.getElementById("node_index").value;
    const nodeName = document.getElementById("node_name").value;
    const description = document.getElementById("description").value;

    const roleMailIdSelector = document.getElementById("role_mail_id");
    const roleMailId = roleMailIdSelector.options[roleMailIdSelector.selectedIndex].text;
    
    const duration = document.getElementById("duration").value;
    
    document.getElementById('id01').style.display='none';

    const new_node = {
        'name' : nodeName,
        'description' : description,
        'role_assigned' : roleMailId,
        'duration' : duration,
        'x0' : 0,
        'y0' : 0,
        'x1' : 0,
        'x2' : 0,
        'y1' : 0,
        'y2' : 0

    };
    
    nodes_data_array.push(new_node);
    ///Make a new node and append it to the list...
    console.log(nodes_data_array);

    //Code to again reload the UI display of workflow..
});

saveNodeConfig.addEventListener('click', (e)=>{
    e.preventDefault();
    //extract the variables here and make changes in the nodes data respectively...


    document.getElementById('id02').style.display='none';

});

saveGenConfig.addEventListener('click', (e)=>{
    e.preventDefault();
    //extract the updated general configurations here and make changes in the object accordingly...


    document.getElementById('id03').style.display='none';
});


