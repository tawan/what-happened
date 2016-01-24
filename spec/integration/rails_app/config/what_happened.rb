WhatHappened.define do
  a_new :message do
    notifies message.recipient, of: :new_message_in_inbox
  end
end
