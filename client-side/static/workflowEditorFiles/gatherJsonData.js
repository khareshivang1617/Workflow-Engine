// const submitBtn = document.getElementById("01");

// submitBtn.addEventListener('click', ()=>{
//     let defaultFormData = '"[{\"type\":\"textarea\",\"required\":false,\"label\":\"Subject\",\"className\":\"form-control\",\"name\":\"textarea-1586517925776\",\"access\":false,\"subtype\":\"textarea\"},{\"type\":\"textarea\",\"required\":false,\"label\":\"Body\",\"className\":\"form-control\",\"name\":\"textarea-1586517959538\",\"access\":false,\"subtype\":\"textarea\"}]"';

//     try {
//         defaultFormData = localStorage.getItem("formData");
//         console.log('Form data set');        
        
       
//     } catch (error) {
//         console.log("formData not set yet. Sending default form data");
        
//     }   
//     finally{
//     document.getElementById("custId").value = defaultFormData;
//     document.getElementById("serverSubmit").submit();
//     console.log('sent')
//     }

// });



// function sendData(){
//     let defaultFormData = '"[{\"type\":\"textarea\",\"required\":false,\"label\":\"Subject\",\"className\":\"form-control\",\"name\":\"textarea-1586517925776\",\"access\":false,\"subtype\":\"textarea\"},{\"type\":\"textarea\",\"required\":false,\"label\":\"Body\",\"className\":\"form-control\",\"name\":\"textarea-1586517959538\",\"access\":false,\"subtype\":\"textarea\"}]"';

//     try {
//         defaultFormData = localStorage.getItem("formData");
//         console.log('Form data set');        
        
       
//     } catch (error) {
//         console.log("formData not set yet. Sending default form data");
        
//     }   
//     finally{
//     document.getElementById('custId').value = defaultFormData;
//     document.getElementById("serverSubmit").submit();
//     }
// }
function fetchAndSendData(){

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

// $(document).ready( function() {
//     $('#final-submit-btn').click(function() {
//         let defaultFormData = '"[{\"type\":\"textarea\",\"required\":false,\"label\":\"Subject\",\"className\":\"form-control\",\"name\":\"textarea-1586517925776\",\"access\":false,\"subtype\":\"textarea\"},{\"type\":\"textarea\",\"required\":false,\"label\":\"Body\",\"className\":\"form-control\",\"name\":\"textarea-1586517959538\",\"access\":false,\"subtype\":\"textarea\"}]"';

//         console.log("button clicked");
//         try {
//             defaultFormData = localStorage.getItem("formData");
//             console.log('Form data set');        
            
           
//         } catch (error) {
//             console.log("formData not set yet. Sending default form data");
            
//         }   
//         finally{
//     //    var formdata = serialize();
//     var formdata = defaultFormData;
//        $.ajax({
//             type: 'POST',
//             contentType: 'application/json',
//             // data: JSON.stringify(formdata),
//             data: formdata,
//             dataType: 'json',
//             url: 'http://localhost:5000/workfloweditor',
//             success: function (e) {
//                 console.log(e);
//                 window.location = "http://192.168.57.223:5000/";
//             },
//             error: function(error) {
//                 console.log('error occured');
//             console.log(error);
//         }
//         });
//     }
// });
// });