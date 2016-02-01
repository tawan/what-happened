require 'rails/generators'
require 'rails/generators/active_record'

module WhatHappened
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)

    def create_notifications_migration
      migration_template("create_notifications.rb", "db/migrate/create_notifications.rb", {})
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
