require 'rails_helper'

RSpec.describe Cleaner do
  it "does not modify input" do
    input = "&nbsp;"
    described_class.clean input
    expect(input).to eq("&nbsp;")
  end

  it "is idempotent" do
    input = "\n&nbsp;\n<div>\n</div>\n&nbsp; &nbsp;"
    first = described_class.clean(input)
    second = described_class.clean(first)
    expect(second).to eq(first)
  end

  [
    ["", ""],
    ["&nbsp;", " "],
    ["&#8230;", "..."],
    ["&#8211;", "-"],
    ["&#215;", "x"],

    ["<br>", "\n"],
    ["<br/>", "\n"],
    ["<br />", "\n"],
    ["<div>", ""],
    ["</div>", "\n"],

    ["  ", " "],
    ["   ", " "],
    ["\n\n", "\n"],
    ["\n \n", "\n"],
  ].each do |input, expected|
    it "changes #{input.inspect} to #{expected.inspect}" do
      expect(described_class.clean(input)).to eq(expected)
    end
  end
end
