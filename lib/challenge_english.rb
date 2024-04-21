# typed: strict

require_relative 'service'

class ChallengeEnglish < Service
  LOGIN_URL = 'https://loginc.benesse.ne.jp/ce/login'

  sig { returns(Symbol) }
  def self.identifier
    :challenge_english
  end

  sig { params(kid: T::Hash[String, String]).void }
  def initialize(kid)
    raise 'Expected `name`' if kid['name'].nil?
    raise 'Expected `username`' if kid['username'].nil?
    raise 'Expected `password`' if kid['password'].nil?

    @name = T.let(T.must(kid['name']), String)
    @page = T.let(login(T.must(kid['username']), T.must(kid['password'])), Mechanize::Page)
  end

  sig {params(username: String, password: String).returns(Mechanize::Page)}
  def login(username, password)
    mechanize = Mechanize.new
    page = mechanize.get(LOGIN_URL)
    form = page.form(:name => 'login')
    form.field_with(:name => 'usr_name').value = username
    form.field_with(:name => 'usr_password').value = password
    form.submit
  end

  sig {returns(T::Array[T::Hash[Symbol, T.any(String, DateTime)]])}
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
