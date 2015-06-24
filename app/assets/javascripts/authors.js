$(function() {
  window.total_book_count = 0;
  window.female_book_count = 0;
  window.book_count_by_year = {};
  window.female_book_count_by_year = {};
  
  $('ul.authors li').each(function(index, element) {
    $.ajax('/authors/show', {
      data: { 
        author_id: $(element).data('id'),
        year: $(element).parents('div.year').data('year')
      },
      success: function(data, status, request) {
        if (typeof data['gender'] !== 'undefined' && typeof data['author_id'] !== 'undefined') {
          var li = $('div.year[data-year="' + data['year'] + '"] ul.authors li[data-id=' + data['author_id'] + ']');
          var count = li.data('count');
          if (typeof window.female_book_count_by_year[data['year']] == 'undefined') {
            window.female_book_count_by_year[data['year']] = 0;
          }
          if (typeof window.book_count_by_year[data['year']] == 'undefined') {
            window.book_count_by_year[data['year']] = 0;
          }
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
            window.female_book_count_by_year[data['year']] = window.female_book_count_by_year[data['year']] + count;
          }
          li.find('span.gender').text(gender).addClass(genderClass);
          
          if (gender == 'M' || gender == 'F') {
            window.total_book_count = window.total_book_count + count;
            window.book_count_by_year[data['year']] = window.book_count_by_year[data['year']] + count;
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
  // Global count
  var ratio = Math.round(window.female_book_count/window.total_book_count * 100);
  $('h1#ratio').text(ratio + '%');
  
  // Yearly count
  $('div.year').each(function(index, element) {
    var year = $(element).data('year');
    var ratio = Math.round(window.female_book_count_by_year[year]/window.book_count_by_year[year] * 100);
    $(element).find('h2 span.percentage').text(' – ' + ratio + '%');
  });
}