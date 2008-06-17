= cinder - Export Campfire transcripts into CSVs
 
  http://github.com/eastmedia/cinder
 
* mailto:matt@eastmedia.com
 
== DESCRIPTION:

Cinder is a Ruby library for exporting transcripts from Campfire into CSV files.

== REQUIREMENTS:
 
* Ruby >= 1.8.6
 
== INSTALL:

  $ gem sources -a http://gems.github.com/ (you only need to do this once)
  $ gem install eastmedia-cinder

== SOURCE:

Cinders's git repo is available on GitHub, which can be browsed at:

  http://github.com/eastmedia/cinder

and cloned from:

  git://github.com/eastmedia/cinder.git


From IRB or any script you write:
  
  require "cinder"

  campfire = Cinder::Campfire.new 'mysubdomain', :ssl => true
  campfire.login 'myemail@example.com', 'mypassword'
  campfire.set_room 'Room Name'
  campfire.retrieve_transcript <date>  
  campfire.retrieve_transcripts_since <date>  
  campfire.retrieve_transcripts_between <start_date> <end_date>
  
== CREDITS:

Thanks to the folks behind the tinder gem.
Initial code by Mike Bueti at Eastmedia.
 
== HISTORY:
 
See CHANGELOG in this directory.

== LICENSE:
 
Copyright (c) 2008 Eastmedia (http://eastmedia.com)
See MIT-LICENSE in this directory.
