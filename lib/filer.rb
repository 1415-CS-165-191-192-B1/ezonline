module Filer
  def self.parse result, doc_id, docname, doclink, user_id
    begin
      doc = Doc.new(doc_id: doc_id, docname: docname, link: doclink)
      doc.valid? ? doc.save : (return :notice, "The file has already been added before.")

      array = result.lines

      for i in 0 ...array.length
        text = array[i].force_encoding('UTF-8')
        text.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') #remove the damn BOMs

        if text.start_with?("#")
          text.slice! "#"

          snippet = Snippet.new(doc_id: doc_id, title: text.chomp!)
          doc.snippets << snippet if snippet.valid?
          Snippet.update_video_id(snippet.title);

          commit = Commit.new(user_id: user_id, snippet_id: snippet.id)

          string = ""
          for j in i+1...array.length  
            content = array[j].force_encoding('UTF-8')
            content.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') #remove the damn BOMs

            if content.start_with?("#") #reached next snippet
              commit.commit_text = string
              snippet.commits << commit if commit.valid?
              i = j
              break
            elsif j == array.length-1  #reached end of file
              string << content
              commit.commit_text = string
              snippet.commits << commit if commit.valid?
              i = j
              break
            else  # continue to read snippet contents
              string << content
            end # end condition if content.start_with?("#")

          end # end inner for loop

        end # end condition text.start_with?("#")
      end # end for loop 

      return :success, 'The file was successfully added to the database.'

    rescue Exception => ex
      return :error, 'An error occurred while parsing the Google Doc.'
    end

  end

  def self.write doc_id
      doc = Doc.find_by doc_id: doc_id
      #snippets = Snippet.where(doc_id: doc_id)
      snippets = doc.snippets

      result = Hash.new
      snippets.each do |snippet|
        #result[s.title] = Commit.where(snippet_id: s.id).order(created_at: :desc).first.commit_text
        result[snippet.title] = snippet.commits.first
      end

      tmp = Tempfile.new(doc.docname, Rails.root.join('tmp'))
      begin
        result.each do |title, text|
          tmp.write(title.upcase)
          tmp.write("\n")
          tmp.write(text)
          tmp.write("\n\n")
        end

        result = GoogleClient::upload tmp, doc.docname

        tmp.close
        tmp.unlink
        
        if !result.nil? and result.status == 200
          doc.update_attribute :link, result.data.alternateLink
          return :success, "Successfully compiled snippets."
        else
          return :error, "An error occurred: #{result.data['error']['message']}"
        end

      end
  end
  
end