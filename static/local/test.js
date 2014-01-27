
(function() {
  $('form > input').change(function() {
    var validForm = true;
    $('form > input').each(function() {
      if ($(":input").hasClass('LV_invalid_field') {
        validForm = false; 
      });
      if (validForm) {
        $('#submit').removeAttribute("disabled");
      } else {
        $('#submit').setAttribute("disabled, disabled");
      };
      })
  })
}()
