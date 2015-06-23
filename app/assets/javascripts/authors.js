$(function() {
  window.total_book_count = 0;
  window.female_book_count = 0;
  
  $('ul.authors li').each(function(index, li) {
    $.ajax('/authors/show', {
      data: { author_id: $(li).data('id') },
      success: function(data, status, request) {
        if (typeof data['gender'] !== 'undefined' && typeof data['author_id'] !== 'undefined') {
          var count = $('ul.authors li[data-id=' + data['author_id'] + ']').data('count');
          var gender = '?';
          var genderClass = 'unknown';
          if (data['gender'] == 'male') {
            gender = 'M';
            genderClass = 'male';
          }
          if (data['gender'] == 'female') {
            gender = 'F';
            genderClass = 'female';
            window.female_book_count = window.female_book_count + count;
          }
          $('ul.authors li[data-id=' + data['author_id'] + '] span.gender').text(gender).addClass(genderClass);
          
          if (gender == 'M' || gender == 'F') {
            window.total_book_count = window.total_book_count + count;
          }
        }
        update_ratio();
      },
      error: function(request, status, error) {
        console.log('Error fetching author info (' + error + ')');
      }
    });
  })
})

function update_ratio() {
  var ratio = Math.round(window.female_book_count/window.total_book_count * 100);
  $('h1#ratio').text(ratio + '%');
}