# typed: strict

require 'mechanize'

class Service
  extend T::Sig

  @@services = T.let([], T::Array[Service])

  sig { void }
  def self.identifier
    raise NotImplementedError
  end

  sig { params(subclass: T::Class[T.anything]).returns(T.untyped) }
  def self.inherited(subclass)
    @@services << subclass
  end

  sig { returns(T::Array[Service]) }
  def self.services
    @@services
  end

  sig { params(kid: T::Hash[String, String]).void }
  def initialize(kid)
    raise NotImplementedError
  end

  # Lesson should be:
  #  {
  #    String   description
  #    DateTime start_time
  #    DateTime end_time
  #  }
  sig {returns(T::Array[T::Hash[Symbol, T.any(String, DateTime)]])}
  def get_lessons
    raise NotImplementedError
  end
end
