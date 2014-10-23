$(function() {
  var list = $('menu ul');
  $("content h3").each(function() {
    $(this).prepend('<a name="' + $(this).text() + '"></a>');
    $(list).append('<li class="list-group-item"><a href="#' + $(this).text() + '">' +  $(this).text() + '</a></li>');
  });
});

$('menu.help').affix({
  offset: {
    top: 100, 
    bottom: 100
  }
})