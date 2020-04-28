var node_index  = document.getElementById('node_index').value;
document.getElementById("node_name_temp").innerHTML = node_index;

for (var i = 0; i < localStorage.length; i++){

  console.log(JSON.parse(localStorage.getItem(localStorage.key(i))));
}

//code to extract the exact node details from the workflow json files and supply them to display in the HTML file...

node_name = "Some random Name";

function addNode(){
    var node_index  = document.getElementById('node_index').value;
    node_name = document.getElementById('node_name').value;
    var description = document.getElementById('dscription').value;
    var role_email_id = document.getElementById('role_email_id').value;
    var durattion = document.getElementById('duration').value;

    // code to update the workflow list in the corr node and re save it as json file...

    

    
    
  }

  document.getElementById("node_name_temp").innerHTML = node_name;