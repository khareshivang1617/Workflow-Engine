jQuery(function($) {
  var fbEditor = document.getElementById('build-wrap');
  var formBuilder = $(fbEditor).formBuilder();

  document.getElementById('getJSON').addEventListener('click', function() {
    var jsonData = JSON.stringify(formBuilder.actions.getData('json'));
    console.log(jsonData);
    localStorage.setItem("formData", jsonData);
    // alert(jsonData);
    //jsonData contains the json string that needs to be stored into the database. Send it to server however needed    
    window.close();
  });  
});
