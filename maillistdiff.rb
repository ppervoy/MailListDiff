require 'active_support/inflector'
require "mail"
require "vpim/vcard"
require "mbox"

src1 = []
src2 = []

DEBUG = false

if DEBUG
  puts "*** " + ARGV.length.to_s + " args recieved"
end

def help
  puts "USAGE:\n\truby maillistdiff.rb <src1> <src2> [<output>]\n"
  puts "WHERE:\n\t<srcX> if \".\" is given - *.eml files in current folder will be used\n\tas a source\n\tOR"
  puts "\t<srcX> name of .mbox export from Apple Mail\n\tOR"
  puts "\t<srcX> name of .vcf export from Apple Contacts\n\tOR"
  puts "\t<srcX> name of .txt file - result of previously ran subtraction\n"
  puts "RESULT:\n\tOptional <output> file with new-line-separated email addresses from\n\t<src1> excluding ones in <src2>\n\n"
end

def dedub(arr)
  dub = []

  while dub[0]=arr.detect { |e| arr.count(e) > 1}
    arr = arr - dub
    arr << dub[0]

    if DEBUG
      puts "*** Removed: " + dub[0]
    end  
  end

  return arr
end

def load_txt(path)
   if File.exist?(path)
    res = []

    if DEBUG
      puts "*** Loading from txt #{path} file"
    end

    f = File.new(path, "r")
    while (l = f.gets)
      if l.chomp.downcase.match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
        res << l.chomp.downcase
      end
    end
    f.close

  else
    puts "ERROR\n\t.txt file \'#{path}\' do not exist. Exiting...\n\n"
    help
    exit
  end

  if DEBUG
    puts "*** Loaded #{res.length} address"
  end

  return res
end

def load_eml
  res = []

  if DEBUG
    puts "*** Loading from local folder"
  end

  Dir.foreach(".") do |f|
    if f == "." or f == ".."
      next
    else
      if f.end_with? '.eml'
        m = Mail.read(f)
        res << m.to[0].downcase
      end
    end
  end

  if DEBUG
    puts "*** Loaded #{res.length} address"
  end

  return res
end

def load_vcf(path)
  if File.exist?(path)
    res = []

    if DEBUG
      puts "*** Loading from vcf #{path} file"
    end

    cards = Vpim::Vcard.decode(open(path))

    cards.each do |card|
      card.each do |field|
        if field.name.downcase == "email"
          res << field.value.downcase
        end
      end
    end

    if DEBUG
      puts "*** Loaded #{res.length} address"
    end

    return res
  else
    puts "ERROR\n\t.vcf file \'#{path}\' do not exist. Exiting...\n\n"
    help
    exit
  end
end

def load_mbox(path)
  if File.exist?(path)
    res = []
    str = ""

    if DEBUG
      puts "*** Loading from mbox #{path} file"
    end

    user_input = 0
      until [1,2].include? user_input do
        puts "Which field to import 1)FROM or 2)TO from #{path}> " 
            user_input = STDIN.gets.chomp.to_i
        end
        if user_input == 1    
            mboxfield = :from
        else   
            mboxfield = :to 
        end

    Mbox.open(path+"/mbox").each { |m|
      str = m.headers[mboxfield]

      if DEBUG
        puts "*** Got line '#{str}'"
      end

      if str
        if str.include? "," #line with several addresses
          str = str.split(",")

          str.each do |substr|
            if substr.include? ">"
              addr = substr.split("<")[1].split(">")[0].downcase.strip
            else
              addr = substr.downcase.strip
            end

            if addr.include? "@"
              res << addr
            end
          end

        else #line with one address
          if str.include? ">"
            addr = str.split("<")[1].split(">")[0].downcase.strip
          else
            addr = str.downcase.strip
          end

          if addr.include? "@"
            res << addr
          end
        end
      end
    }

    if DEBUG
      puts "*** Loaded #{res.length} address"
    end

    return res

  else
    puts "ERROR\n\t.mbox file \'#{path}\' do not exist. Exiting...\n\n"
    help
    exit
  end
end

if ARGV.length < 2
  help
  exit
end


if ARGV[0] == "."
  src1 = load_eml
else
  if ARGV[0][-4,4] == ".vcf"
    src1 = load_vcf(ARGV[0])
  elsif ARGV[0][-4,4] == ".txt"
    src1 = load_txt(ARGV[0])
  else
    src1 = load_mbox(ARGV[0])
  end
end
src1 = dedub(src1.sort)

if ARGV[1] == "."
  src2 = load_eml
else
  if ARGV[1][-4,4] == ".vcf"
    src2 = load_vcf(ARGV[1])
  elsif ARGV[1][-4,4] == ".txt"
    src2 = load_txt(ARGV[1])
  else
    src2 = load_mbox(ARGV[1])
  end
end
src2 = dedub(src2.sort)

d = src1 - src2

if DEBUG
  puts "*** Difference is #{d.length} addresses."
end

if not(ARGV[2])
  puts d.join(", ").to_s
else
  if not(File.exist?(ARGV[2]))
    File.open(ARGV[2], "w") do |f|
      d.each {|el| f.puts(el) }
    end

    if DEBUG
      puts "*** Saved #{ARGV[2]} #{d.length} addresses."
    end

  else
    puts "ERROR\n\tOutput file \'#{ARGV[2]}\' already exists. Exisitng...\n\n"
    help
    exit
  end
end