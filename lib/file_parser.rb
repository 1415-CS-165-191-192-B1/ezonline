module FileParser
	def self.parse result, file_id, filename, user_id
		
		begin
			doc = Doc.new
			doc.doc_id = file_id
			doc.docname = filename
			doc.save!
		rescue ActiveRecord::RecordNotUnique
			return 'YOU ALREADY ADDED THIS FILE'
		end

		#array = result.body.split(/(\n)/)
		array = result.body.lines
		length = array.length

		for i in 0...length
			text = array[i].force_encoding('UTF-8')
			text.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

			if text.start_with?("#") # using '#' as snippet title starting character -- NOT WORKING FOR FIRST ENTRY!!!
				text.slice! "#"

				snippet = Snippet.new
				snippet.doc_id = file_id
				snippet.title = text.chomp!
				snippet.save!

				commit = Commit.new	# not being executed at some point
				commit.user_id = user_id
				commit.snippet_id = snippet.id

				string = ""
				for j in i+1...length	
					content = array[j].force_encoding('UTF-8')
					content.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') # remove the damn BOMs

					if content.start_with?("#")
						commit.commit_text = string
						commit.save!

						i = j

						break
					elsif j == length-1
						string << content
						commit.commit_text = string
						commit.save!

						i = j

						break
					else
						string << content
					end # end condition unless content.starts_with?("#")
				end # end inner for loop

			end # end condition text.starts_with?("#")
		end # end for loop 

		return 'SUCCESSFULLY ADDED FILE IN DATABASE'
	end

end