
// Get the modal
var modal1 = document.getElementById('id01');
var modal2 = document.getElementById('id02');
var modal3 = document.getElementById('id03');


// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
    if (event.target == modal1) {
        this.modal1.style.display = "none";
    }
    if (event.target == modal2) {
        this.modal2.style.display = "none";
    }
    if (event.target == modal3) {
        this.modal3.style.display = "none";
    }
}
