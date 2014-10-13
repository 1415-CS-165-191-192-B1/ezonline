module GoogleModel
	def self.id
		'1000040334636-uohs489t2ndrgiv742tt0l3u2cafv0q2.apps.googleusercontent.com'
	end

	def self.secret
		'NtYbyXc-1XZNbPyOQKfh-yiu'
	end

	def self.uri
		'http://localhost:3000/authentication'
	end

	def self.scope
		['https://www.googleapis.com/auth/drive',
		 'https://www.googleapis.com/auth/userinfo.profile',
		 'https://www.googleapis.com/auth/userinfo.email']
	end
end