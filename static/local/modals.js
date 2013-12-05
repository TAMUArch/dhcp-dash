$(document).ready(function(){
  $(".delete").click(function(){
    $("#hostname").val($(this).data('hostname'));
    $("#ip").val($(this).data('ip'));
    $("#mac").val($(this).data('mac'));
    $('#deleteModal').modal('show');
  });
});
