module ApplicationHelper
	
	def get_percentage(percent, total)
		return total != 0 ? (percent*100/total).floor : 0
	end
end
