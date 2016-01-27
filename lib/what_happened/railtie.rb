module WhatHappened
  class Railtie < Rails::Railtie
    initializer "what_happened.create_config" do |app|
      app.config.x.what_happened = Config.new

      app.config.after_initialize do
        ActiveSupport.on_load(:active_record) do
          PaperTrail::Version.after_create do |version|
            app.config.x.what_happened.broadcast(version)
          end
          PaperTrail::Version.after_update do |version|
            app.config.x.what_happened.broadcast(version)
          end
          PaperTrail::Version.after_destroy do |version|
            app.config.x.what_happened.broadcast(version)
          end

          ActiveRecord::Base.include(WhatHappened::Model)

          path = File.join(app.root, "config", "what_happened.rb")
          if File.exist?(path)
            app.config.x.what_happened.instance_eval(File.read(path))
          end
        end
      end
    end
  end
end
