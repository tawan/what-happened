# config/what_happened.rb
specify do
  creating_message do
    notifies { |message| message.recipient }
  end
end
