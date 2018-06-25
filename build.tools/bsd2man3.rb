#!/bin/env ruby -w

#require 'json'

#
# * mandoc -Tman 
# * convert .TP to .IP (GNO nroff doesn't support .TP )
# * preformat .TS / .TE tables
#

class TableParser < Object
	def initialize(args = {})
		@st = 0;
		@lines = []
		@sizes = []
		@chunk = ""
		@padding = 3
		@width = 71 # + 7 tab = 78
	end
	
	def process(line)

		if @st == 0 then
			@st = 1 if line =~ /\.$/
			return
		end

		line.gsub!(/^\s+|\s+$/, '')

		if line =~ /^\.PP/ then
			add_one_chunk() unless @chunk.empty?
			return
		end
		@chunk = @chunk.empty? ? line : @chunk + " " + line

	end

	def finish(io = $stdout)
		add_one_chunk() unless @chunk.empty?

		io.puts ".sp 1"
		io.puts ".nf"
		# in the future, this should generate a .ta command.

		# puts JSON.generate(@lines)
		# puts JSON.generate(@sizes)

		# if last column exceeds width, split it...

		@lines.each {|lines|


			tmp = justify(lines)
			tmp.each {|x|
				x.sub!(/[\t ]+$/ , '')
				io.puts x
			}

		}


		io.puts ".fi"

		@lines = []

	end

	def is_sentence(word)
		return word =~ /[.?!]["')]*$/
	end

	def split_last(line, width)
		rv = []
		words = line.split(/((?:[^\\ ]|\\.)+)/)
		words = words.reject {|x| x == "" || x == " " }

		work = ''
		words.reduce('') {|m, word|
			pt = strip_fmt(word)
			sp = is_sentence(pt) ? "  " : " "
			if pt.length + m.length > width then
				rv.push work unless work.empty?
				work = ""
				m = ""
			end
			work = work + word + sp
			m = m + pt + sp
			m
		}
		rv.push work unless work.empty?
		rv
	end

	def justify(lines)

		plain = lines.map {|x| strip_fmt(x) }
		tmp = ''
		extra = []

		last = @sizes.length - 1
		lines.each_with_index {|line, ix|

			if ix == last then
				ts = tmp.length
				avail = @width - ts
				if plain[ix].length > avail then
					extra = split_last(line, avail)
					line = extra.shift
					extra.map! {|x| (" " * ts) + x }
				end
			end

			tmp += line;
			tmp += " " * (@sizes[ix] - plain[ix].length + @padding)
		}
		tmp.sub!(/[\t ]+$/ , '')
		rv = [tmp]
		rv.push(*extra)
		return rv
	end


	def add_one_chunk()

		tmp = @chunk.split("\t")
		@lines.push(tmp)
		@chunk = ""


		tmp = tmp.map {|x| strip_fmt(x).size }
		tmp.each_index{|i|
			a = @sizes[i] || 0
			b = tmp[i]
			@sizes[i] = a > b ? a : b
		}

	end

	def strip_fmt(x)
		x = x.gsub(/\\f[BIRP]/, '')
		x = x.gsub(/\\~/, '') # non-breaking space.
		x = x.gsub(/\\./, 'x')

		return x
	end
	
end



def quote(x)

	x = x.gsub(/"/, '""')
	return '"' + x + '"'
end



ARGV.each do |file|

	IO.popen(["mandoc", "-Ios=GNO", "-Tman", file]) {|io|
		tp = nil
		tbl = nil

		File.open(file + "G", "w") {|out|

			io.each_line {|x|
				x.chomp!
				next if x == '.nh'
				next if x == '.if n .ad l';

				if tbl then
					if x =~ /^\.TE/
						puts tbl.finish(out)
						tbl = nil
					else
						tbl.process(x)
					end
					next
				end


				# convert .TP [nnn] / data -> .IP data [nnn]
				# since GNO's nroff -man can't handle .TP
				if x =~ /^\.TP/ then
					tp = x
					next
				end

				if x =~ /^\.TS/ then
					tbl = TableParser.new
					next
				end

				if tp then
					arg = tp[4..-1]
					out.puts ".IP #{quote(x)} #{arg}"
					tp = nil
					next
				end

				out.puts x 
			}
			if tbl then
				puts tbl.finish(out)
				$stderr.puts "warning: incomplete table"
			end
		}
	}
end