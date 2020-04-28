const radioBtns = document.querySelectorAll("input");


document.getElementById("taskExecute-btn").addEventListener('click', (e)=>{
    let checkButtonCount = 0;
    let checkButtonIndex = 0;
    e.preventDefault();
    for(i=0;i<radioBtns.length; i++){
        if(radioBtns[i].checked){
            checkButtonCount++;
            checkButtonIndex = i;
        }
    }
    if(checkButtonCount != 0){
        document.getElementById("taskId").setAttribute("value",checkButtonIndex);
        document.getElementById("taskIdSubmit").submit();
        console.log(checkButtonIndex);
    }
});