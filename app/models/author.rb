class Author < ActiveRecord::Base
  def self.get_list_from_user_with_shelf(user_id, shelf, page = 1, authors = {})
    per_page = 100
    api_call_uri = "https://www.goodreads.com/review/list.xml?v=2&id=#{user_id}&shelf=#{shelf}&per_page=#{per_page}&page=#{page}&sort=author&key=#{ENV['GOODREADS_API_KEY']}"
    uri = URI.parse api_call_uri
    xml = Timeout::timeout(20) { Net::HTTP.get(uri) }
    tree = Nokogiri::XML(xml)
    total_reviews = tree.xpath('//reviews').attribute('total').value
    total_pages = (total_reviews.to_f / per_page).ceil

    tree.css('review').each do |review_node|
      year = review_node.css('read_at').text.split.last || '0'
      authors[year] ||= {}
      review_node.css('authors > author').each do |author_node|
        id = author_node.css('id').text
        name = author_node.css('name').text
        previous_count = authors[year][id].nil? ? 0 : authors[year][id].count
        authors[year][id] = { name: name, count: previous_count + 1 }
      end
    end
    
    authors = Hash[authors.sort.reverse]
    
    if page >= total_pages
      authors
    else
      sleep 1
      get_list_from_user_with_shelf(user_id, shelf, page + 1, authors)
    end
  end
  
  def self.get_gender(author_id, year)
    author = Author.find_or_create_by(id: author_id)
    if author.gender.blank? || author.updated_at < 30.days.ago
      sleep 1
      uri = URI.parse "https://www.goodreads.com/author/show.xml?id=#{author_id}&key=#{ENV['GOODREADS_API_KEY']}"
      xml = Timeout::timeout(10) { Net::HTTP.get(uri) }
      tree = Nokogiri::XML(xml)
      if gender = tree.css('author > gender').text
        author.update(gender: gender)
        author.touch
      else
        return { 
          status: 'error', 
          error: "Couldn't fetch author info." 
        }
      end
    end
    {
      author_id: author_id,
      year: year,
      gender: author.gender,
    }
  end
end
