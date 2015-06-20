class Author < ActiveRecord::Base
  def self.get_list_from_user_with_shelf(user_id, shelf)
    uri = URI.parse "https://www.goodreads.com/review/list.xml?v=2&id=#{user_id}&shelf=#{shelf}&per_page=200&sort=author&key=#{ENV['GOODREADS_API_KEY']}"
    xml = Timeout::timeout(10) { Net::HTTP.get(uri) }
    tree = Nokogiri::XML(xml)
    authors = {}
    tree.css('book > authors > author').each do |node|
      id = node.css('id').text
      name = node.css('name').text
      previous_count = authors[id].nil? ? 0 : authors[id].count
      authors[id] = { name: name, count: previous_count + 1 }
    end
    authors
  end
  
  def self.get_gender(author_id)
    begin
      author = Author.find(author_id)
      {
        author_id: author_id,
        gender: author.gender,
        cached: true
      }
    rescue ActiveRecord::RecordNotFound
      if Author.count > 0
        retry if Author.order(updated_at: :desc).limit(1).first.updated_at > (Time.now - 1.second)
      end
      uri = URI.parse "https://www.goodreads.com/author/show.xml?id=#{author_id}&key=#{ENV['GOODREADS_API_KEY']}"
      xml = Timeout::timeout(10) { Net::HTTP.get(uri) }
      tree = Nokogiri::XML(xml)
      if gender = tree.css('author > gender').text
        Author.create(id: author_id, gender: gender)
        {
          author_id: author_id,
          gender: gender,
          cached: false
        }
      else
        {
          status: 'error',
          error: "Couldn't fetch author info."
        }
      end
    end
  end
end
