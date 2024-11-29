require_relative 'service'

class Comiru < Service
  LOGIN_URL =  'https://comiru.jp/IM_09/login'

  def self.identifier
    :comiru
  end

  def initialize(kid)
    @name = kid['name']
    @page = login(kid['username'], kid['password'])
  end

  def login(username, password)
    mechanize = Mechanize.new
    page = mechanize.get(LOGIN_URL)
    form = page.form(:action => LOGIN_URL)
    form.field_with(:name => 'student_no').value = username
    form.field_with(:name => 'password').value = password
    form.submit
  end

  def get_lessons
    @page.at("h2:contains('最近の授業スケジュール')").next.search('tbody tr').map do |row|
      date = row.search('td')[0].text
      year, month, day = date.scan(/(\d{4})-(\d{2})-(\d{2})/).first.map(&:to_i)

      time = row.search('td')[1].text
      start_hour, start_min, end_hour, end_min = time.scan(/(\d\d):(\d\d) - (\d\d):(\d\d)/).first.map(&:to_i)

      {
        description: "#{@name} Lego School",
        start_time:  DateTime.new(year, month, day, start_hour, start_min),
        end_time:    DateTime.new(year, month, day, end_hour, end_min)
      }
    end
  end
end
