require 'net/ssh'

def ssh_shell(socket)
  Net::SSH.start("localhost", "root", :password => "foobar" ) do |ssh|
    channel = ssh.open_channel do |ch|
      ch.exec("bash") do |ch, success|
        raise "could not execute command" unless success

        socket.extend(Net::SSH::BufferedIo)
        ssh.listen_to(socket)

        ch.on_process do
          print("P", socket.available, " ", socket.closed?, "\n");
          if socket.available > 0
            ch.send_data(socket.read_available)
          end
          if socket.closed?
            ch.close
          end
        end

        ch.on_data do |ch2, data|
          print("0: ", data, "\n")
          socket.enqueue(data)
        end

        ch.on_extended_data do |ch2, type, data|
          print("extended\n")
          print(type, ": ", data, "\n")
        end

      end

    end

    channel.wait
    socket.close
    print("EXIT\n")
  end
end

listen_socket = TCPServer.open(1234)
socket = listen_socket.accept
ssh_shell(socket)
