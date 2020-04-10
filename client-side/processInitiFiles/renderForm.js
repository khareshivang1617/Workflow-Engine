jQuery(function($) {
    var fbRender = document.getElementById('fb-render'),
      formData = '<form-template><fields><field class="form-control" label="Full Name" name="text-input-1459436848806" type="text" subtype="text"></field><field class="form-control" label="Select" name="select-1459436851691" type="select"><option value="option-1">Option 1</option><option value="option-2">Option 2</option></field><field class="form-control" label="Your Message" name="textarea-1459436854560" type="textarea"></field></fields></form-template>';
  
    var formRenderOpts = {
      formData,
      dataType: 'xml'
    };
  
    $(fbRender).formRender(formRenderOpts);
  });
  
  