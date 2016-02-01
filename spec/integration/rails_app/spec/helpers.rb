module Helpers
  def mount_new_what_happened_config
    WhatHappened.config = WhatHappened::Config.new
    WhatHappened.config
  end
end
