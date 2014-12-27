require 'active_support/inflector'
require "mail"
require "vpim/vcard"
require "mbox"

from_emls = []
from_vcf = []
from_mbox = []

START = "."
GROUP = "./Group.vcf"
#GROUP = "./test.vcf"
MBOX = "./HH2014.mbox/mbox"
#MBOX = "./test.mbox/mbox"

Dir.foreach(START) do |x|
  if x == "." or x == ".."
    next
  else
    if x.end_with? '.eml'
      m = Mail.read(x)
      from_emls << m.to[0].downcase
    end
  end
end
puts from_emls.count.to_s + ' address'.pluralize(from_emls.count) + " from .eml files loaded"


cards = Vpim::Vcard.decode(open(GROUP))

cards.each do |card|
  card.each do |field|
    if field.name.downcase == "email"
      from_vcf << field.value.downcase
    end
  end
end
puts from_vcf.count.to_s + ' address'.pluralize(from_vcf.count) + " from #{GROUP} file loaded"


Mbox.open(MBOX).each {|m|
  if m.headers[:to][-1] == ">"
    from_mbox << m.headers[:to].split("<")[1].split(">")[0].downcase
  else
    from_mbox << m.headers[:to]
  end
}
puts from_mbox.count.to_s + ' address'.pluralize(from_mbox.length) + " from #{MBOX} loaded"


d = from_vcf - from_mbox


puts d.count.to_s + " unique address".pluralize(d.count) + " found in #{GROUP}:"
puts d.join(", ")