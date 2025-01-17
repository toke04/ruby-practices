#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_COUNT = 4
DISPLAYED_WIDTH = 8.5
WC_OPTIONS = ARGV.getopts('l', 'w', 'c')

def main
  if ARGV.any?
    exec_file_process
  else
    exec_stdin_process
  end
end

def exec_file_process
  loaded_files = ARGV.map do
    File.read(_1)
  end
  displayed_data = create_display_file_data(loaded_files)
  displayed_data_by_condition = if loaded_files.count >= 2 # 本物のwcは、ファイルの数が2以上じゃないと合計値を出さない
                                  calculate_total_data(displayed_data)
                                else
                                  file_name = File.path(ARGV[0])
                                  displayed_data << [" #{file_name}"]
                                end
  display_file_data(displayed_data_by_condition)
end

def exec_stdin_process
  stdin_data = $stdin.readlines
  divided_stdin_data = stdin_data.map do
    [_1]
  end
  displayed_data = create_display_stdin_data(divided_stdin_data)
  displayed_data.each do
    print _1.to_s.rjust(DISPLAYED_WIDTH)
  end
end

def create_display_file_data(file)
  display_data = []
  if WC_OPTIONS.values.none?
    display_data.push(count_file_lines(file), count_file_words(file), count_file_characters(file))
  else
    display_data << count_file_lines(file) if WC_OPTIONS['l']
    display_data << count_file_words(file) if WC_OPTIONS['w']
    display_data << count_file_characters(file) if WC_OPTIONS['c']
  end
  display_data
end

def display_file_data(file_data)
  received_wc_option_count = WC_OPTIONS.values.count(true)
  column_count = received_wc_option_count.zero? ? MAX_COLUMN_COUNT : received_wc_option_count + 1 # wcのオプションの数 + 渡されたパスが表示されるので
  file_data.transpose.each do |rows|
    rows.each.with_index(1) do |cell, index|
      print cell.to_s.rjust(DISPLAYED_WIDTH) if index % column_count != 0
      print "#{cell}\n" if (index % column_count).zero?
    end
  end
end

def calculate_total_data(displayed_data)
  column_total_count = displayed_data.map(&:sum)
  added_total_count_data = displayed_data.each_with_index do |column, index|
    column << column_total_count[index]
  end
  file_name = ARGV.map do
    " #{File.path(_1)}"
  end
  last_columns = file_name
  last_columns << ' total'
  added_total_count_data << last_columns
end

def count_file_lines(files)
  new_lines = files.map do |file|
    file.lines.map do |line|
      line.scan(/\n$/)
    end
  end
  new_lines.map do |line|
    line.flatten.count("\n")
  end
end

def count_file_words(files)
  files.map do
    _1.split(/\s+/).size
  end
end

def count_file_characters(files)
  files.map(&:size)
end

def create_display_stdin_data(stdin_data)
  display_data = []
  if WC_OPTIONS.values.none?
    display_data.push(count_stdin_line(stdin_data), count_stdin_word(stdin_data), count_stdin_character(stdin_data))
  else
    display_data << count_stdin_line(stdin_data) if WC_OPTIONS['l']
    display_data << count_stdin_word(stdin_data) if WC_OPTIONS['w']
    display_data << count_stdin_character(stdin_data) if WC_OPTIONS['c']
  end
  display_data
end

def count_stdin_line(divided_stdin)
  divided_stdin.count
end

def count_stdin_word(divided_stdin)
  word_counts = divided_stdin.map do |line|
    line.join.scan(/\S+/).count
  end
  word_counts.sum
end

def count_stdin_character(divided_stdin)
  divided_stdin.flatten.join.size
end

main
