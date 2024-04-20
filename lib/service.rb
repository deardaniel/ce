class Service
  def self.identifier
    raise NotImplementedError
  end

  def initialize(kid)
    raise NotImplementedError
  end

  # Lesson should be:
  #  {
  #    String   description
  #    DateTime start_time
  #    DateTime end_time
  #  }
  def get_lessons
    raise NotImplementedError
  end
end
