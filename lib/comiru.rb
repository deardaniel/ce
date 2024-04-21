# typed: strict
require_relative 'service'

class Comiru < Service
  extend T::Sig
  LOGIN_URL =  'https://comiru.jp/IM_09/login'

  sig { returns(Symbol) }
  def self.identifier
    :comiru
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
    form = page.form(:action => LOGIN_URL)
    form.field_with(:name => 'student_no').value = username
    form.field_with(:name => 'password').value = password
    form.submit
  end

  sig {returns(T::Array[T::Hash[Symbol, T.any(String, DateTime)]])}
  def get_lessons
    @page.search('table')[1].search('tbody tr').map do |row|
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
