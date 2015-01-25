class FilerParse
	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform result, id, title, link, user_id
		Filer::parse result, id, title, link, user_id
	end
end