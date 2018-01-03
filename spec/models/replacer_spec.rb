require 'rails_helper'

RSpec.describe Replacer do
  subject(:replacer) { described_class.new }

  data = File.read(__FILE__).split("__END__").last
  tests = {}

  current_to = nil
  data.each_line do |line|
    case line
    when "\n"
      current_to = nil
    when /\A\w/
      current_to = line.strip
      tests[current_to] ||= []
    when /\A\s{2}\w/
      tests[current_to] << line.strip
    end
  end

  tests.each do |expected, inputs|
    inputs.each do |input|
      it "replaces #{input.inspect} with #{expected.inspect}" do
        output = replacer.replace(input)
        expect(output).to eq(expected)
      end
    end
  end
end

__END__

DL
  deadlift
  deadlifts
  deads
  DEADLIFT

3RM
  3 rep max
  3 Rep Max
  3 RM
  3rm

10RM
  10 rep max

Min
  Minute

min
  minute
  minutes

7min
  7minute
  7 minute
  7 minutes
  7-minute

MU
  Muscle Ups
  muscle ups
  muscle-up
  muscle-ups
  muscleup

DU
  Double Under
  double-unders

PU
  Pull Up
  pull-ups

BS
  Back Squat
  backsquat
