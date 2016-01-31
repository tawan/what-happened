module WhatHappened
  class Railtie < Rails::Railtie
    initializer "what_happened.create_config" do |app|
      app.config.x.what_happened = Config.new

      app.config.after_initialize do
        ActiveSupport.on_load(:active_record) do
          PaperTrail::Version.after_create do |version|
            BroadcastJob.perform_later(version)
          end
          PaperTrail::Version.after_update do |version|
            BroadcastJob.perform_later(version)
          end
          PaperTrail::Version.after_destroy do |version|
            BroadcastJob.perform_later(version)
          end

          ActiveRecord::Base.send(:include, WhatHappened::Model)

          path = File.join(app.root, "config", "notification_routing.rb")
          if File.exist?(path)
            app.config.x.what_happened.instance_eval(File.read(path))
          end
        end
      end
    end
  end
end
