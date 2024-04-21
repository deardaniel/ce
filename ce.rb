# typed: strict

require 'icalendar'
require 'yaml'
require 'sorbet-runtime'

require_relative 'lib/challenge_english'
require_relative 'lib/comiru'

config = YAML.load_file('ce.yaml')

cal = Icalendar::Calendar.new
# cal.x_wr_calname = 'Calendar Engine'

# Looks like:
#  {
#    challenge_english: ChallengEnglish,
#    comiru: Comiru
#  }
services = Hash[
  Service.services
    .map { |klass| [klass.identifier, klass] }
  ]

config.each do |service_name, kids|
  service_class = services[service_name.to_sym]
  if service_class.nil?
    raise "Unknown service name in config: #{service_name}"
  end

  kids.each do |kid|
    lessons = service_class.new(kid).get_lessons
    lessons.each do |lesson|
      cal.event do |e|
        e.summary = lesson[:description]
        e.dtstart = lesson[:start_time]
        e.dtend   = lesson[:end_time]
      end
    end
  end
end

cal.publish

cal_string = cal.to_ical
puts cal_string
