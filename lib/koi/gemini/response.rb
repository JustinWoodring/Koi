require_relative './status'

class Koi::Gemini::Response
  attr_accessor :status, :metadata, :content
  
  def initialize(status, metadata, content)
    @status = status
    @metadata = metadata
    @content = content
  end

  def to_s
    return "#{@status} #{metadata}\r\n#{@content}".b
  end
end
