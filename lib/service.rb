class Service

	def self.string(*attrs)
		add_to_schema :string, attrs
	end

	def self.boolean(*attrs)
		add_to_schema :boolean, attrs
	end
	
	def self.schema
		@schema ||= {}
	end

	attr_accessor :settings, :payload

	def self.add_to_schema(type, *attrs)
		fields = attrs.first
		if fields.last.is_a?(Hash)
			options = fields.pop
		else
			options = {}
		end
		fields.each do |field|
			schema[field] = {:type => type}.merge!(options)
		end
	end

	def settings(setting)
		payload['settings'][setting.to_s]
	end

	def simple(attr)
		payload['simple'][attr.to_s]
	end

	def url
		payload['url']
	end

end
