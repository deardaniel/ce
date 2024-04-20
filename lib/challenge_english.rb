require_relative 'service'

class ChallengeEnglish < Service
  LOGIN_URL = 'https://loginc.benesse.ne.jp/ce/login'

  def self.identifier
    :challenge_english
  end

  def initialize(kid)
    @name = kid['name']
    @page = login(kid['username'], kid['password'])
  end

  def login(username, password)
    mechanize = Mechanize.new
    page = mechanize.get(LOGIN_URL)
    form = page.form(:name => 'login')
    form.field_with(:name => 'usr_name').value = username
    form.field_with(:name => 'usr_password').value = password
    form.submit
  end

  def get_lessons
    dates = @page.search('.dataList dt')
    times = @page.search('.dataList dd')
    dates.map.with_index do |date, i|
      month, day = date.text.scan(/(\d\d)\/(\d\d)/).first
      start_hour, start_min, end_hour, end_min = times[i].text.scan(/(\d\d):(\d\d)～(\d\d):(\d\d)/).first

      {
        description: "#{@name} Challenge English",
        start_time:  DateTime.new(Date.today.year, month.to_i, day.to_i, start_hour.to_i, start_min.to_i),
        end_time:    DateTime.new(Date.today.year, month.to_i, day.to_i, end_hour.to_i, end_min.to_i)
      }
    end
  end
end
