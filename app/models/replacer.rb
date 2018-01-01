class Replacer
  def replace(text)
    REPLACEMENTS.each do |replacement, regexp|
      text = text.gsub(regexp, replacement)
    end
    text
  end

  REPLACEMENTS = [
    ['DL', /dead(lifts|s|lift)/i],
    ['\1RM', /(\d*) rep max/i],
    ['\1in', /(m)inutes?/i],
    ['\1min', /(\d+)[\s-]*min/i],
    ['MU', /muscle[\s-]?ups?/i],
    ['DU', /double[\s-]?unders?/i],
    ['PU', /pull[\s-]?ups?/i],
  ]
end
