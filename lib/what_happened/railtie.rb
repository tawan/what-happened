module WhatHappened
  class Railtie < Rails::Railtie
    config.what_happened = ActiveSupport::OrderedOptions.new
    config.what_happened.disabled = false
    config.after_commit = true
    initializer "what_happened.create_config" do |app|
      WhatHappened.config = Config.new

      app.config.after_initialize do
        ActiveRecord::Base.send(:include, WhatHappened::Model)
        unless app.config.what_happened.fetch(:disabled, true)
          [ :create, :update, :destroy ].each do |action|
            callback, *args = if app.config.what_happened.after_commit
              [:after_commit, { on: action }]
            else
              ["after_#{action}".to_sym ]
            end
            PaperTrail::Version.send(callback, *args) do |version|
              BroadcastJob.perform_later(version)
            end
          end


          path = File.join(app.root, "config", "notification_routing.rb")
          if File.exist?(path)
            specification = <<-SPEC
              specify do
                #{File.read(path)}
              end
            SPEC
            WhatHappened.config.instance_eval(specification)
          end
        end
      end
    end
  end
end
