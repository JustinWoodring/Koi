require 'socket'
require 'openssl'
require_relative './gemini'
require_relative './ssl'
require_relative './file'

class Koi::Server
  @config = {}
  @file_server = nil
  
  def initialize(config)
    @config = config
    @file_server = FileServer.new(@config[:file_root_dir], @config[:erb_enabled])
  end

  def run
    # Spawn TCP listener.
    server = TCPServer.new(@config[:bind_addr], @config[:bind_port])

    puts "                                                                      
                                                                      
                                  :.                                  
                                  :xx                                 
                                 .;+x  +;+:                           
                        .x   +&;;;;;;;+;;;+;:;;X        :.:.          
                          ::::+&&;::::::::::::::$+     ..:..;         
                      ;xx::::::::::;;::::::...::+      :;:.;;         
                    ;;::::::::;+xxxxx;::.:..         x+;+Xxx          
                   +$::..:;        .::                &$$$X;x         
                  ++;:                                &&&$$x          
                 :x:               +.                 &$$$x           
                 +                ;;.                $$XX             
                ;;      XXx$$&X;;&+X$&       ;:    :X&$               
               ++;    ++x::::::::x+&&&$$$Xxxx::::::;                  
              +;+;;   ++;:X:::::;$:;:XXXx:::xxX+xxxx;                 
              :;;;:;.     .::+X$;:$$$X+::::::x                        
             :;;:;;:           :.     x.+                             
             .:..:.            .       X:;                            
             .  .                       +++                           
                                          ::                          
                                                                      
          
                                                                      "
    puts "Koi Gemini Server - #{Koi::VERSION} - Listening on #{@config[:bind_addr]}:#{@config[:bind_port]}."
    
    # Define SSL context
    
    ctx = if @config[:key_file_path] == nil or
            @config[:cert_file_path] == nil then
            Koi::SSL.generate_debug_ctx
          else
            Koi::SSL.generate_ctx_from_files(@config[:key_file_path], @config[:cert_file_path])
          end
      
    # Loop TCP connections with Thread pool.
    loop do
      Thread.start(server.accept) do |socket|
        begin
          # Begin client upgrade
          client = OpenSSL::SSL::SSLSocket.new(socket, ctx)
          client.accept

          # Client stable begin server request handling
          handle(client)
            
        rescue OpenSSL::SSL::SSLError
          puts "Failed to upgrade client connection to SSL."
        ensure
          ssl_socket.close rescue nil
          socket.close rescue nil
        end
      end
    end
  end

  def handle(client)
    request = Koi::Gemini::Request.parse(client.gets)

    if not request.is_valid? then
      resp = Koi::Gemini::Response.new(Koi::Gemini::Status::BadRequest)

      puts "#{resp.status}: #{request.protocol}#{request.domain}#{request.path}" + (request.query != "" ? "?#{request.query}" : "")
      client.send(resp.to_s)
    else
      resp = @file_server.route(request)

      puts "#{resp.status}: #{request.protocol}#{request.domain}#{request.path}" + (request.query != "" ? "?#{request.query}" : "")
      client.write(resp.to_s)
    end
  end
end
