require 'erb'
require 'open3'

require_relative '../gemini'

class Koi::ERB::Handler
  def initialize
    # We might put properties that can defined here in the future.
  end

  def handler_internal(filename, request)
    ruby_code = <<~RUBY
           require 'erb'

           class Koi
           end

           class Koi::ERB
           end

           class Koi::ERB::Context
                 @request = nil
                 @response_status = nil
                 @response_metadata = nil
                 @response_content = nil
  
                 attr_accessor :request, :response_status, :response_metadata, :response_content

                 def initialize(request)
                     @request = request
                     @response_status = nil
                     @response_metadata = nil
                     @response_content = nil
                 end
    
                 def get_binding
                     return binding
                 end
           end

           class Koi::Gemini
           end

           class Koi::Gemini::Request
                 attr_accessor :is_valid, :protocol, :domain, :path, :query

                 def initialize(is_valid, protocol, domain, path, query)
                     @is_valid = is_valid
                     @protocol = protocol
                     @domain = domain
                     @path = path
                     @query = query
                 end
           end

           request = Koi::Gemini::Request.new(
                   "#{request.is_valid}",
                   '#{request.protocol.to_s.dump}'.undump,
                   '#{request.domain.to_s.dump}'.undump,
                   '#{request.path.to_s.dump}'.undump,
                   '#{request.query.to_s.dump}'.undump)

           template_content = File.binread('#{filename.dump}'.undump)
           context = Koi::ERB::Context.new(request)
           erb = ERB.new(template_content)

           output = erb.result(context.get_binding)

           status = if context.response_status != nil
                  context.response_status else 20 end
           metadata = if context.response_metadata != nil
                  context.response_metadata else
                   "text/gemini; charset=utf-8" end
           content = if context.response_content != nil
                  context.response_content else
                  output.b end

           puts status
           puts metadata
           puts content
RUBY

    return ruby_code
  end  
  
  def handle(valid_path, request)
    begin
      # Initialize ERB
      filename = valid_path[valid_path.rindex('/')+1..-1]
      path_prefix = valid_path[0..valid_path.rindex('/')]
      
      stdout, stderr, code = Open3.capture3("ruby",
                                              chdir: valid_path[0..valid_path.rindex('/')],
                                              stdin_data: handler_internal(filename, request))
      
      output = stdout.split("\n",3)

      puts "---\n#{stdout}\n---"
      puts "---\n#{stderr}\n---"
      
      status = output[0]
      metadata = output[1]
      content = output[2]
    
      return Koi::Gemini::Response.new(status, metadata, content)
    rescue Exception => e 
      status = Koi::Gemini::Status::PermanentGenericError
      metadata = "CGI backend experienced an error."
      content = nil

      puts e

      return Koi::Gemini::Response.new(status, metadata, content)
    end
  end
end

  
