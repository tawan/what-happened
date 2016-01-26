specify do
  creating_message do
    notifies { |message| message.recipient }
  end
end
