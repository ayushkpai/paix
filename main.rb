require "io/console"

class PaiX
  RESET  = "\e[0m"
  CYAN   = "\e[36m"
  BLUE   = "\e[34m"
  GRAY   = "\e[90m"
  PURPLE = "\e[95m"
  INVERT = "\e[7m"

  def initialize
    @root = File.expand_path("~")
    @cwd = @root

    @stack = []
    @index = 0

    load_files
  end

  def load_files
    @files = Dir.entries(@cwd)
      .reject { |f| f == "." || f == ".." }
      .sort
  end

  def clear
    print "\e[2J\e[H"
  end

  def draw
    clear

    puts "#{BLUE}PaiX#{RESET}"
    puts "#{PURPLE}Root: #{@root}#{RESET}"
    puts "#{PURPLE}Path: #{@cwd}#{RESET}"
    puts "-" * 60

    if @files.empty?
      puts "#{GRAY}No files here#{RESET}"
      return
    end

    preview = preview_text

    @files.each_with_index do |f, i|
      path = File.join(@cwd, f)

      icon = File.directory?(path) ? "🗂️" : "📄"

      line = "  #{icon} #{f}"

      if i == @index
        puts "#{INVERT}➤ #{line}#{RESET} #{GRAY}| #{preview}#{RESET}"
      else
        puts line
      end
    end

    puts "-" * 60
    puts "#{GRAY}↑↓ move | Enter open | b back | r home | q quit#{RESET}"
  end

  def preview_text
    return "" if @files.empty?

    path = File.join(@cwd, @files[@index])

    if File.directory?(path)
      return "DIR"
    end

    begin
      File.readlines(path)[0..2].map(&:strip).join(" | ")
    rescue
      "binary"
    end
  end

  def enter
    return if @files.empty?

    path = File.join(@cwd, @files[@index])

    if File.directory?(path)
      @stack.push(@cwd)
      @cwd = path
      @index = 0
      load_files
    else
      view_file(path)
    end
  end

  def view_file(path)
    content = File.readlines(path) rescue ["[cannot read file]"]

    loop do
      clear
      puts "#{BLUE}FILE VIEW#{RESET}"
      puts "#{PURPLE}#{path}#{RESET}"
      puts "-" * 60
      puts content
      puts "-" * 60
      puts "#{GRAY}ESC = back#{RESET}"

      break if STDIN.getch == "\e"
    end
  end

  def back
    return if @stack.empty?

    @cwd = @stack.pop
    load_files
    @index = 0
  end

  def home
    @cwd = @root
    @stack = []
    load_files
    @index = 0
  end

  def up
    return if @files.empty?
    @index = (@index - 1) % @files.size
  end

  def down
    return if @files.empty?
    @index = (@index + 1) % @files.size
  end

  def run
    loop do
      draw
      input = STDIN.getch

      if input == "\e"
        seq = STDIN.getch rescue nil
        if seq == "["
          arrow = STDIN.getch rescue nil
          up if arrow == "A"
          down if arrow == "B"
        end
        next
      end

      case input
      when "\r" then enter
      when "b"  then back
      when "r"  then home
      when "q"  then break
      end
    end
  end
end

PaiX.new.run
