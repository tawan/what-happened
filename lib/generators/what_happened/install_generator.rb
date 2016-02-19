require 'rails/generators'
require 'rails/generators/active_record'

module WhatHappened
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)

    class_option :skip_helper, type: :boolean, desc: "Don't add view helper."

    def create_notifications_migration
      migration_template("create_notifications.rb", "db/migrate/create_notifications.rb", {})
    end

    def create_helper_files
      unless options[:skip_helper]
        template 'helper.rb', File.join('app/helpers', "what_happened_helper.rb")
      end
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
