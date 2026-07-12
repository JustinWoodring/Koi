class Koi::Gemini::Request
  @is_valid = true
  
  attr_accessor :is_valid, :protocol, :domain, :path, :query 

  def self.parse(input)
    if self.is_a?(Class)
     req = Koi::Gemini::Request.allocate

     if input[0...9] == "gemini://" then
       req.protocol = "gemini://"
     end

     domain_path_query = input[9..-1].gsub('\r\n','').strip
     split = domain_path_query.split("/",2)

     if split[0] != nil
       and not split[0].include?("/")
       and not split[0].include?('"')
       and not split[0].include?("'")
       and not split[0].include?(" ") then

       req.domain = split[0]
       req.path = "/index"
       req.query = ""
       req.is_valid = true
       else
       req.is_valid = false
     end

     if split[1] != nil
       if not split[1].include?("..")
         and not split[1].include?(" ")
         and not split[1].include?("'")
         and not split[1].include?('"') then
         if split[1].include?("?") then
           path_query = split[1].split("?")
           req.path = "/"+path_query[0]
           req.query = path_query[1]
         else
           req.path = "/"+split[1]
         end
       else 
         req.is_valid = false
       end
     end

     return req
    end
    raise "This method should be called from the class, not an instance!"
  end

  def is_valid?
    if self.is_a?(Class)
      raise "This method must be called on an instance, not the class!"
    end

    return @is_valid
  end
end
