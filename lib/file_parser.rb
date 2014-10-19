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

		array = result.body.split(/(\n)/)
		for i in 0..array.length-1
			text = array[i]
			if text.starts_with?("#") # using '#' as snippet title starting character
				text.slice! "#"

				snippet = Snippet.new
				snippet.doc_id = file_id
				snippet.title = text.chomp!
				snippet.save!

				commit = Commit.new	# not being executed in last run
				commit.user_id = user_id
				commit.snippet_id = snippet.id

				string = ''
				for j in i+1..array.length-1	
					content = array[j]
					unless content.starts_with?("#")
						string << content
					else
						commit.commit_text = string
						commit.save!
						break
					end # end condition unless content.starts_with?("#")
				end # end inner for loop
			end # end condition text.starts_with?("#")
		end # end for loop 

		return 'SUCCESSFULLY ADDED FILE IN DATABASE'
	end

end