require 'net/ssh'

Net::SSH.start("localhost", "root", :password => "foobar" ) do |ssh|
  channel = ssh.open_channel do |ch|
    ch.exec("/bin/bash") do |ch, success|
      raise "could not execute command" unless success

      ch.on_data do |ch2, data|
        print("0: ", data, "\n")
      end

      ch.on_extended_data do |ch2, type, data|
        print(type, ": ", data, "\n")
      end

      ch.send_data("ls \n")
    end

  end

  channel.wait
end
