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
        document.getElementById("serverSubmit").submit();
        
    }

}
