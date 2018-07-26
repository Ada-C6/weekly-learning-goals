#! /usr/bin/env ruby
require 'date'

MASTER_SYLLABUS = "syllabus.md"
SPRING_SYLLABUS = "syllabus-winter-spring.md"
FALL_SYLLABUS = "syllabus-summer-fall.md"

WEEK_REGEX = /\| Week \d\d \| /

def get_cohort_start
  valid_date = false
  until valid_date
    puts "When does the cohort start? (e.g. 'Aug 6')"
    input = gets.strip
    date = nil
    begin
      date = Date.parse(input)
    rescue ArgumentError => e
      puts "Invalid date: #{input}"
      next
    end

    if date < Date.today
      puts "Date must be in the future! Got #{date}, today is #{Date.today}"
      next
    end

    unless date.monday?
      guess_monday = date - date.wday + 1
      if date.wday == 6
        guess_monday += 7
      end
      puts "#{date} is a #{date.strftime("%A")}, did you mean Monday #{guess_monday}? [y/n]"
      if gets.strip.downcase == 'y'
        date = guess_monday
      else
        next
      end
    end

    unless date.month == 2 || date.month == 8
      puts "#{date} is in #{date.strftime("%B")}, but cohorts usually start in August or February. Continue with this date? [y/n]"
      unless gets.strip.downcase == 'y'
        next
      end
    end

    return date
  end
end

def write_autogen_message(file)
  file.write("<!--\n")
  file.write("THIS FILE WAS AUTOMATICALLY GENERATED\n")
  file.write("by the script #{__FILE__} in the same directory.\n")
  file.write("Please adjust that script rather than hand-editing this file\n")
  file.write("-->\n")
end

def write_fall_intro(file, year)
  file.write("# Ada Developers Academy Summer/Fall Cohort Schedule\n")
  file.write("(Dates for #{year}-#{year + 1})\n\n")
end

def write_spring_intro(file, year)
  file.write("# Ada Developers Academy Winter/Spring Cohort Schedule\n")
  file.write("(Dates for #{year})\n\n")
end

def write_table_head(file)
  file.write("Date | Week | Unit | Topics\n")
  file.write("---  | ---  | ---  | ---   \n")
end

def write_table_body(file, start_date, lines)
  lines.each_with_index do |line, i|
    date = start_date + i * 7
    line = date.strftime("%b %d ") + line
    file.write(line)
  end
end

def load_master_syllabus
  weeks = []
  File.open(MASTER_SYLLABUS) do |file|
    lines = file.readlines
    weeks = lines.select do |line|
      line =~ WEEK_REGEX
    end
  end
  return weeks
end

def main
  start_date = get_cohort_start
  puts "Cohort starts #{start_date}"

  lines = load_master_syllabus
  puts "Loaded #{lines.length} lines from the master syllabus"

  filename = "generated_syllabus.md"
  if start_date.month == 8
    filename = FALL_SYLLABUS
  elsif start_date.month == 2
    filename = SPRING_SYLLABUS
  end
  puts "Writing dated syllabus to #{filename}"

  File.open(filename, 'w') do |file|
    write_autogen_message(file)
    if start_date.month == 8
      write_fall_intro(file, start_date.year)
    elsif start_date.month == 2
      write_spring_intro(file, start_date.year)
    end
    write_table_head(file)
    write_table_body(file, start_date, lines)
  end
end

if __FILE__ == $0
  main
end
