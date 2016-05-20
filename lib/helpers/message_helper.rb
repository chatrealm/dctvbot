# file: lib/helpers/message_helper.rb

class MessageHelper

	def self.replace_first_message_section(current_message, new_data, delimiter='|')
		message_parts_array = current_message.split(delimiter)
		message_parts_array.shift
		new_message = new_data + " #{delimiter}" + message_parts_array.join(delimiter)
		return new_message
	end
	
end
