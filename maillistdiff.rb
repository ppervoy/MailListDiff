require 'active_support/inflector'
require "mail"
require "vpim/vcard"
require "mbox"

src1 = []
src2 = []

DEBUG = true

if DEBUG
  puts "*** " + ARGV.length.to_s + " args recieved"
end

def help
  puts "USAGE:\n\truby maillistdiff.rb <src1> <src2> [<output>]\n"
  puts "WHERE:\n\t<srcX> if \".\" is given - *.eml files in current folder will be used\n\tas a source\n\tOR"
  puts "\t<srcX> name of .mbox export from Apple Mail\n\tOR"
  puts "\t<srcX> name of .vcf export from Apple Contacts\n"
  puts "RESULT:\n\tOptional <output> file with coma-separated email addresses from\n\t<src1> excluding ones in <src2>\n\n"
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

    if DEBUG
      puts "*** Loading from mbox #{path} file"
    end

    Mbox.open(path+"/mbox").each {|m|
      if m.headers[:to][-1] == ">"
        res << m.headers[:to].split("<")[1].split(">")[0].downcase
      else
        res << m.headers[:to].downcase
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
  else
    src1 = load_mbox(ARGV[0])
  end
end
src1.sort!

#src1.detect { |e| src1.count(e) > 1}

if ARGV[1] == "."
  src2 = load_eml
else
  if ARGV[1][-4,4] == ".vcf"
    src2 = load_vcf(ARGV[1])
  else
    src2 = load_mbox(ARGV[1])
  end
end
src2.sort!

d = src1 - src2

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