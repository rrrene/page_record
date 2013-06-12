module PageRecord
	class PageRecord

	  class << self
	    attr_accessor :page, :type
	  end


		def self.all(selector = "", filter = "")
			records = []
			context = context_for_selector(selector)				
			context.all("[data-#{@type}-id]#{filter}").each do | record|
				id = record["data-#{@type}-id"]
				records << self.new(id, selector)
			end
			records
		end

		def self.find(id="", selector = "", filter= "")
			self.new(id, selector, filter)
		end

		def self.find_by_attribute(attribute, value, selector, filter)
			begin
				context = self.context_for_selector(selector)
				record = context.find("[data-#{@type}-id]#{filter} > [data-attribute-for='#{attribute}']", :text => value)
				parent = record.find(:xpath, "..")
				id = parent["data-#{@type}-id"]
				self.new(id, selector)
				rescue Capybara::Ambiguous
					raise MultipleRecords, "Found multiple #{@type} record with #{attribute} #{value} on page"				
				rescue Capybara::ElementNotFound
					raise RecordNotFound, "#{@type} record with #{attribute} #{value} not found on page"
			end
		end

		# def self.method_missing(action)
		# 	raw_action = /(.*)\?/.match(action)
		# 	begin
		# 		if raw_action
		# 			raw_action_for(raw_action[0])
		# 		else
		# 			action_for(action)
		# 		end
		# 	rescue Capybara::Ambiguous
		# 		raise MultipleRecords, "Found multiple #{action} tags for #{@type} on page"				
		# 	rescue Capybara::ElementNotFound
		# 		super
		# 	end
		# end


		def self.inherited(base)
			base.class_eval do
				@base_name =  base.to_s.gsub('Page', '')
				@type = @base_name.downcase
				@host_class = @base_name.constantize
				@attributes = @host_class.attribute_names.clone
				@attributes.delete('id') # id is a special case attribute
			end
			define_class_methods(base)
			define_instance_methods(base)
		end

private


		def self.action_for(action)
			element = raw_action_for(action)
			element.native.click
		end

		def self.raw_action_for(action)
			@page.find("[data-action-for='#{action}']")
		end


		def self.define_accessor_methods(base)
			base.instance_eval do
				@attributes.each do | attribute |
					define_method("#{attribute}_raw") do
						read_attribute_raw(attribute)
					end
					define_method(attribute) do
						read_attribute(attribute)
					end
					define_method("#{attribute}=") do | value|
						write_attribute(attribute, value)
					end
				end
			end
		end


		def self.define_instance_methods(base)
			define_accessor_methods(base)		
		end


		def self.define_class_methods(base)
			eigenclass = class << base; self; end
			attributes = base.instance_variable_get('@attributes')
 			eigenclass.instance_eval do
				attributes.each do | attribute|
					define_method "find_by_#{attribute}" do | value, selector = "", filter = ""|
						debugger
						find_by_attribute( attribute, value, selector, filter)
					end
				end
			end
		end


		def self.context_for_selector(selector)
			if selector.blank?
				@page
			else
				begin
					@page.find(selector)
					rescue Capybara::Ambiguous
						raise MultipleRecords, "Found multiple HTML segments with selector #{selector} on page"				
					rescue Capybara::ElementNotFound
						raise RecordNotFound, "#{selector} not found on page"						
				end
			end				
		end

	end
end