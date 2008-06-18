module Cinder


  # == Usage
  #
  #   campfire = Cinder::Campfire.new 'mysubdomain', :ssl => true
  #   campfire.login 'myemail@example.com', 'mypassword'
  #   campfire.set_room 'Room Name'
  #   campfire.retrieve_transcript date
  class Campfire
    attr_reader :subdomain, :uri, :room, :directory
    
    # Create a new connection to a campfire account with the given +subdomain+.
    # There's an +:ssl+ option to use SSL for the connection.
    #
    # campfire = Cinder::Campfire.new("my_subdomain", :ssl => true)
    def initialize(subdomain, options = {})
      options = { :ssl => false }.merge(options)
      @subdomain = subdomain
      @uri = URI.parse("#{options[:ssl] ? "https" : "http"}://#{subdomain}.campfirenow.com")
      @room = nil
      @directory = "."
      @agent = WWW::Mechanize.new
      @logged_in = false
    end

    # Log in to campfire using your +email+ and +password+
    def login(email, password)
      unless @agent.post("#{@uri.to_s}/login", "email_address" => email, "password" => password).uri == @uri
        raise Error, "Campfire login failed"
      end
      @lobby = @agent.page
      @rooms = get_rooms(@lobby)
      @logged_in = true
    end

    # Returns true if currently logged in
    def logged_in?
      @logged_in == true
    end

    # Logs out of the campfire account
    def logout 
      if @agent.get("#{@uri}/logout").uri == URI.parse("#{@uri.to_s}/login")
        @logged_in = false
      end
    end

    # Selects the room with name +room_name+ to retrieve transcripts from
    def set_room(room_name)
      @room = find_room_by_name(room_name)
    end

    # Set the directory where Cinder saves transcripts to +path+, 
    def set_directory(path)
      if File.exists? path and File.directory? path
        @directory = path.reverse.index("/") == 0 ? path.chop : path
      else
        raise Error, "Invalid path name"
      end 
    end

    # Retrieve the transcript for the current room and +date+, passed in as a Time object, and store it locally as a csv file in the preselected directory, or the current location if no directory was set
    def retrieve_transcript(date = Time.now)
      transcript_uri = URI.parse("#{@room[:uri].to_s}/transcript/#{date.strftime("%Y/%m/%d")}")
      transcript = get_transcript(transcript_uri)
      write_transcript(transcript, "#{@directory}/#{@room[:name].gsub(" ", "_")}_#{date.strftime("%m_%d_%Y")}", date)
      puts "Transcript retrieved from room '#{@room[:name]}' for #{date.strftime("%m/%d/%Y")}".green
    rescue WWW::Mechanize::ResponseCodeError
      puts "No transcript found in room '#{@room[:name]}' for #{date.strftime("%m/%d/%Y")}".red
    end

    # Retrieve all of the transcripts for the current room
    def retrieve_all_transcripts
      puts "Retrieving all transcripts from '#{@room[:name]}'. This could take some time.".yellow
      retrieve_transcripts_since find_start_date(@room)
    end

    # Retrieve the transcripts for the current room from the +date+ passed in as a Time object, up until and including the current date
    def retrieve_transcripts_since(date)
      puts "Retrieving transcripts from '#{@room[:name]}' since #{date.strftime("%m/%d/%Y")}.".blue
      retrieve_transcripts_between(date, Time.now)
    end
    
    # Retrieve the transcripts for the current room created between the +start_date+ and +end_date+ passed in as a Time objects
    def retrieve_transcripts_between(start_date, end_date)
      puts "Retrieving transcripts from '#{@room[:name]}' between #{start_date.strftime("%m/%d/%Y")} and #{end_date.strftime("%m/%d/%Y")}.".blue
      while start_date <= end_date
        retrieve_transcript(start_date)
        start_date = start_date + 24*60*60
      end
    end

    # Retrieve the transcripts from all rooms in this Campfire account for the +date+ passed in as a Time object
    def retrieve_transcripts_from_all_rooms(date = Time.now)
      preset_room = @room
      @rooms.each do |room|
        @room = room
        retrieve_transcript date
      end
      @room = preset_room
    end

    # Retrieve the transcripts from all rooms in this Campfire account created since the +date+ passed in as a Time object
    def retrieve_transcripts_from_all_rooms_since(date)
      puts "Retrieving transcripts from all rooms in #{@uri.to_s} since #{date.strftime("%m/%d/%Y")}.".yellow
      retrieve_transcripts_from_all_rooms_between date, Time.now
    end

    # Retrieve the transcripts from all rooms in this Campfire account created between the +start_date+ and the +end_date+ passed in as a Time objects
    def retrieve_transcripts_from_all_rooms_between(start_date, end_date)
      puts "Retrieving transcripts from all rooms in #{@uri.to_s} between #{start_date.strftime("%m/%d/%Y")} and #{end_date.strftime("%m/%d/%Y")}.".yellow
      preset_room = @room
      @rooms.each do |room|
        @room = room
        retrieve_transcripts_between start_date, end_date
      end
      @room = preset_room
    end

    # Retrieve all of the transcripts created in all of the rooms in this Campfire account
    def retrieve_all_transcripts_from_all_rooms
      puts "Retrieving all transcripts from #{@uri.to_s}. This could take some time.".yellow 
      preset_room = @room
      @rooms.each do |room|
        @room = room
        retrieve_all_transcripts
      end
      @room = preset_room
    end

    private

    # Find all of the room names and associated urls on the provided +page+
    def get_rooms(page)
      page.links.collect { |link| { :name => link.to_s, :uri => link.uri } if link.uri.to_s["#{uri.to_s}/room"] }.reject { |room| room.nil? }
    end

    # Find the room name and uri hash that matches the provided +room_name+
    def find_room_by_name(room_name)
      @rooms.collect { |room| room if room[:name] == room_name }.reject { |room| room.nil? }.first
    end

    def get_transcript(uri)
      @agent.get(transcript_uri.to_s).parser
    end

    def find_start_date(room)
      list_page = @agent.get("#{@uri}/files+transcripts?room_id=#{room[:uri].to_s.split("/").last}")
      while list_page.links.detect { |link| link.text == "Older" }
        list_page.links.detect { |link| link.text == "Older" }.click
        list_page = @agent.page
      end
      links = list_page.links
      links.pop
      earliest = links.pop.uri.to_s.split("/")
      day = earliest.pop
      month = earliest.pop
      year = earliest.pop
      Time.mktime(year.to_i, month.to_i, day.to_i)
    end
    
    # Parse the provided +transcript+ hpricot document and write the contents to the .csv file +file_name+
    def write_transcript(transcript, file_name, date)
      writer = CSV.open("#{file_name}.csv", 'w')
      writer << ["Date", "Time", "User", "Message"]
      date = date.strftime("%m/%d/%Y")
      time = nil
      user = nil
      (transcript%"tbody[@id='chat']").each_child do |row|
        if row.class == Hpricot::Elem
          row.each_child do |cell|
            if cell.class == Hpricot::Elem
              if cell.classes.include? "time"
                if cell.containers.any?
                  time = cell.containers.first.html
                else
                  time = cell.html
                end
              elsif cell.classes.include? "person"
                if cell.containers.any?
                  user = cell.containers.first.html
                else
                  user = cell.html
                end
              elsif cell.classes.include? "body"
                writer << [date, time, user, cell.containers.first.html]
              end
            end
          end
        end
      end
      writer.close
    end

  end
end
