function fetchAndSendData(){
    let defaultFormData = '"[{\"type\":\"textarea\",\"required\":false,\"label\":\"Subject\",\"className\":\"form-control\",\"name\":\"textarea-1586517925776\",\"access\":false,\"subtype\":\"textarea\"},{\"type\":\"textarea\",\"required\":false,\"label\":\"Body\",\"className\":\"form-control\",\"name\":\"textarea-1586517959538\",\"access\":false,\"subtype\":\"textarea\"}]"';

    try {
        defaultFormData = localStorage.getItem("formData");
        console.log('Form dAta set');
        
        
       
    } catch (error) {
        console.log("formData not set yet. Sending default form data");
        
    }   
    finally{
        console.log(defaultFormData);
    }

}