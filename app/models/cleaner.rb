class Cleaner
  REPLACEMENTS = [
    # HTML Entities
    [%r{&nbsp;},    " "],
    [%r{&#8230;},   "..."],
    [%r{&#8211;},   "-"],
    [%r{&#215;},    "x"],

    # HTML Tags
    [%r{<br\s*/*>}, "\n"],
    [%r{</\w+.*?>}, "\n"],
    [%r{<\w+.*?>},  ""],

    # Extra Spaces
    [%r{ +},        " "],
    [%r{\n\s+\n},       "\n"],
    [%r{\n\n+},       "\n"],
  ].freeze

  def self.clean(input)
    buffer = input.dup

    REPLACEMENTS.each do |regexp, replacement|
      buffer.gsub! regexp, replacement
    end

    buffer
  end
end
