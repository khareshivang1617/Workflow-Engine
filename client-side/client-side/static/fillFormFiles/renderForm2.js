/*
This has been updated to use the new userData method available in formRender
*/
const getUserDataBtn = document.getElementById("get-user-data");
const fbRender = document.getElementById("fb-render");
const responseInput = document.getElementById("response");
const responseForm = document.getElementById("responseSubmit");
const extractForm = document.getElementById("extractForm").getAttribute("value");
console.log(extractForm);
const originalFormData = extractForm;
jQuery(function($) {
//   const formData = JSON.stringify(originalFormData);
const formData = originalFormData;

  $(fbRender).formRender({ formData });
  getUserDataBtn.addEventListener(
    "click",
    () => {
      let formResponse = window.JSON.stringify($(fbRender).formRender("userData"))
      responseInput.setAttribute("value", formResponse);
      responseForm.submit();
    //   window.close();
    },
    false
  );
});


// jQuery($ => {
//     const escapeEl = document.createElement("textarea");
//     const code = document.getElementById("markup");
//     const formData =
//       '[{"type":"textarea","label":"Text Area","className":"form-control","name":"textarea-1492616908223","subtype":"textarea"},{"type":"select","label":"Select","className":"form-control","name":"select-1492616913781","values":[{"label":"Option 1","value":"option-1","selected":true},{"label":"Option 2","value":"option-2"},{"label":"Option 3","value":"option-3"}]},{"type":"checkbox-group","label":"Checkbox Group","name":"checkbox-group-1492616915392","values":[{"label":"Option 1","value":"option-1","selected":true}]}]';
//     const addLineBreaks = html => html.replace(new RegExp("><", "g"), ">\n<");
  
//     // Grab markup and escape it
//     const $markup = $("<div/>");
//     $markup.formRender({ formData });
  
//     // set < code > innerText with escaped markup
//     code.innerText = addLineBreaks($markup.formRender("html"));
  
//     hljs.highlightBlock(code);
//   });



