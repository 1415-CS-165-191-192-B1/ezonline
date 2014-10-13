class FileController < ApplicationController
	def get_file
		search_result = GoogleClient::fetch_file
		if search_result.status == 200
			file = search_result.data['items'].first
			download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl'	
			if download_url
				result = @@client.execute(uri: download_url)
				if result.status == 200
					#@array = result.body.lines.map(&:chomp)
					@array = result.body.split(/(\n)/)
					for i in 0..@array.length-1
						text = @array[i]
						if text.starts_with?("#") # using '#' as snippet title starting character
							text.slice! "#"
							filename = text + ".txt"
							f = File.open(filename, "w+")

							for j in i+1..@array.length-1	
								content = @array[j]
								unless content.starts_with?("#")
									f.write("#{content}")
								else
									f.close unless f == nil
									break
								end # end condition !content.starts_with?("#")
							end # end inner for loop

						end # end condition ext.starts_with?("#")
						f.close unless f == nil or f.closed?
					end # end for loop
				else # result.status != 200
					puts "An error occurred: #{result.data['error']['message']}"
				end
			end
		end
	end



end
