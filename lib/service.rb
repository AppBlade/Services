class String
  def blank?
    self == nil || self == ""
  end
end

class Service

	def self.string(*attrs)
		add_to_schema :string, attrs
	end

	def self.boolean(*attrs)
		add_to_schema :boolean, attrs
	end

  def self.password(*attrs)
    add_to_schema :password, attrs
  end

  def self.oauth(service)
    add_to_schema :oauth, [:access_token, {:service => service}]
  end

  def self.schema
    @schema ||= {}
  end

  def self.subclasses
    @subclasses ||= ObjectSpace.each_object.map do |klass|
      klass if Module === klass && self > klass
    end.compact
  end

	def self.subclass_description
		self.subclasses.inject({}) do |response, subclass|
			response[subclass.to_s] = {
				:name          => subclass::Title,
				:short         => subclass::Description,
				:schema        => subclass.schema,
				:documentation => File.read(File.expand_path("../../docs/#{subclass.name.split('::').last.downcase}.md", __FILE__))
			}
			response
		end
	end

  def self.crash_report_listeners
    @crash_report_listeners ||= subclasses.select{|k| k.method_defined?(:receive_crash_report) }
  end

  def self.new_version_listeners
    @new_version_listeners ||= subclasses.select{|k| k.method_defined?(:receive_new_version) }
  end

  def self.feedback_listeners
    @feedback_listeners ||= subclasses.select{|k| k.method_defined?(:receive_feedback) }
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
		payload['settings'][self.class.name][setting.to_s]
	end

	def simple(attr)
		payload['simple'][attr.to_s]
	end

	def url
		payload['url']
	end

end

Dir["#{File.dirname(__FILE__)}/../services/**/*.rb"].each { |service| load service }
