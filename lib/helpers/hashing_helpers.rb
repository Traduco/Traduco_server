require 'digest/md5'

module HashingHelpers
	def md5 (src)
		Digest::MD5.hexdigest src
	end
end