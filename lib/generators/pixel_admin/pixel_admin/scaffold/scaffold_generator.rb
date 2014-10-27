require 'rails/generators'
require 'rails/generators/generated_attribute'

module PixelAdmin
  module Generators
    class ScaffoldGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :controller_path,    :type => :string
      argument :model_name,         :type => :string, :required => false
      argument :layout,             :type => :string, :default => "application",
                                    :banner => "Specify application layout"

      def initialize(args, *options)
        super(args, *options)
        initialize_views_variables
      end

      def copy_views
        generate_views
      end

      protected

      def initialize_views_variables
        @base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(controller_path)
        @controller_routing_path = @controller_file_path.gsub(/\//, '_')
        @model_name = @controller_class_nesting + "::#{@base_name.singularize.camelize}" unless @model_name
        @model_name = @model_name.camelize
      end

      def controller_routing_path
        @controller_routing_path
      end

      def singular_controller_routing_path
        @controller_routing_path.singularize
      end

      def model_name
        @model_name
      end

      def plural_model_name
        @model_name.pluralize
      end

      def resource_name
        @model_name.demodulize.underscore
      end

      def plural_resource_name
        resource_name.pluralize
      end

      def columns
        excluded_column_names = %w[id created_at updated_at]
        if defined?(ActiveRecord)
          rescue_block ActiveRecord::StatementInvalid do
            @model_name.constantize.columns.reject{|c| excluded_column_names.include?(c.name) }.collect{|c| ::Rails::Generators::GeneratedAttribute.new(c.name, c.type)}
          end
        else
          rescue_block do
            @model_name.constantize.fields.collect{|c| c[1]}.reject{|c| excluded_column_names.include?(c.name) }.collect{|c| ::Rails::Generators::GeneratedAttribute.new(c.name, c.type.to_s)}
          end
        end
      end

      def rescue_block(exception=Exception)
        yield if block_given?
      rescue exception => e
        say e.message, :red
        exit
      end

      def extract_modules(name)
        modules = name.include?('/') ? name.split('/') : name.split('::')
        name    = modules.pop
        path    = modules.map { |m| m.underscore }
        file_path = (path + [name.underscore]).join('/')
        nesting = modules.map { |m| m.camelize }.join('::')
        [name, path, file_path, nesting, modules.size]
      end

      def generate_views
        puts "Controller path: #{@controller_file_path}"
        views = {
          "index.html.#{ext}"                 => File.join('app/views/admin', plural_resource_name, "index.html.#{ext}"),
          "new.html.#{ext}"                   => File.join('app/views/admin', plural_resource_name, "new.html.#{ext}"),
          "edit.html.#{ext}"                  => File.join('app/views/admin', plural_resource_name, "edit.html.#{ext}"),
          "_form.html.#{ext}"                 => File.join('app/views/admin', plural_resource_name, "_form.html.#{ext}"),
          "controller.rb.erb"                    => File.join('app/controllers/admin/', "#{plural_resource_name}_controller.rb")}
          selected_views = views
          options.engine == generate_erb(selected_views)
      end

      def generate_erb(views)
        views.each do |template_name, output_path|
          template template_name, output_path
        end
      end

      def ext
        ::Rails.application.config.generators.options[:rails][:template_engine] || :erb
      end



    end
  end
end
