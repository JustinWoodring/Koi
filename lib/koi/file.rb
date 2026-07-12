require_relative "./gemini"
require_relative "./erb"

class FileServer
  @base_directory = nil
  @erb_enabled = false
  @erb_handler = nil

  def initialize(base_directory, erb_enabled)
    @base_directory = base_directory
    @erb_enabled = erb_enabled
    if erb_enabled then
      @erb_handler = Koi::ERB::Handler.new
    end
  end

  def search_path(path)
    files = Dir.glob("#{@base_directory}/**/*").each do |f|
      f.sub!("#{@base_directory}", "")
    end.append("/")

    f_trimmed = files.find { |file| path == file }

    if f_trimmed != nil then
      if File.directory?(File.join("#{@base_directory}", f_trimmed)) then
        # If we are in a directory lets test for an index.erb and then index.gmi

        if @erb_enabled then
          i = File.join("#{@base_directory}", f_trimmed, "index.erb")

          if File.exist?(i) then
            return i
          end
        end

        i = File.join("#{@base_directory}", f_trimmed, "index.gmi")
        if File.exist?(i) then
          return i
        end 
      else
        i = File.join("#{@base_directory}", f_trimmed)
        return i
      end
    end

    return nil
  end

  def route(request)
    valid_path = search_path(request.path)

    if valid_path != nil then
      if valid_path.end_with?(".erb") and not @erb_enabled then
        # Filter a file ending in .erb if .erb is not enabled. If the path ends with this return Not Found.
        return Koi::Gemini::Response.new(Koi::Gemini::Status::NotFound, "Resource Not Found", nil)
      elsif valid_path.split("/")[-1].start_with?(".") then
        # Check for files beginning with . and ignore them.

        # If the file begins with . as in .env then return Not Found.
        return Koi::Gemini::Response.new(Koi::Gemini::Status::NotFound, "Resource Not Found", nil)
      else
        # Consider the route safe, figure out how to pack the response.
        if valid_path.end_with?(".erb")
          response = @erb_handler.handle(valid_path, request)
          return response
        else
          status = Koi::Gemini::Status::Success
          metadata = if valid_path.end_with?(".gmi")
                       "text/gemini; charset=utf-8"
                     elsif valid_path.end_with?(".txt")
                       "text/plain; charset=utf-8"
                     elsif valid_path.end_with?(".zip")
                       "application/zip"
                     elsif valid_path.end_with?(".pdf")
                       "application/pdf"
                     elsif valid_path.end_with?(".gif")
                       "image/gif"
                     elsif valid_path.end_with?(".jpeg", ".jpg")
                       "image/jpeg"
                     elsif valid_path.end_with?(".png")
                       "image/png"
                     else
                       "application/octet-stream"
                     end
                       
          content = File.binread(valid_path)
          return response = Koi::Gemini::Response.new(status, metadata, content)
        end
      end
    else
      # No File Found
      return Koi::Gemini::Response.new(Koi::Gemini::Status::NotFound, "Resource Not Found", nil)
    end
  end
end
