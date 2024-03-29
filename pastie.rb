#!/usr/bin/env ruby

# Derived from https://gist.github.com/1976443
require 'net/http'
require 'optparse'
require 'timeout'
require 'cgi'

class Hash
  def to_query_string
    map { |k, v| 
      if v.instance_of?(Hash)
        v.map { |sk, sv|
          "#{k}[#{sk}]=#{sv}"
        }.join('&')
      else
        "#{k}=#{v}"
      end
    }.join('&')
  end
end

module Pastie
  AVAILABLE_PARSERS = %w(
    c diff html javascript
    nitro_xhtml pascal plaintext
    rhtml ruby sql
  )
  
  class API
    PASTIE_URI = 'pastie.org'
    
    def paste(body, format='plaintext', is_private=false)
      if body.size > 64000
        $stderr.puts "Input over 64k limit, use Dropbox instead?"
        return body
      end
      raise InvalidParser unless valid_parser?(format)
      http = Net::HTTP.new(PASTIE_URI)
      query_string = { :paste => {
        :body => CGI.escape(body),
        :parser => format,
        :restricted => is_private,
        :authorization => 'burger'
      }}.to_query_string
      resp, body = http.start { |http|
        http.post('/pastes', query_string)
      }
      if resp.code == '302'
        return resp['location']
      else
        raise Pastie::Error
      end
    end
    
    private
      def valid_parser?(format)
        Pastie::AVAILABLE_PARSERS.include?(format)
      end
  end
  
  class Error < StandardError; end
  class InvalidParser < StandardError; end
  
  class ConsoleOptions
    attr_reader :parser, :options
    
    def initialize
      @options = {
        :format => 'plaintext',
        :private => false
      }
      
      @parser = OptionParser.new do |cmd|
        cmd.banner = "Ruby Pastie CLI - takes paste input from STDIN"
        
        cmd.separator ''
        
        cmd.on('-h', '--help', 'Displays this help message') do
          puts @parser
          exit
        end
        
        cmd.on('-f', '--format FORMAT',
          %(The format of the text being pasted. Available parsers: #{Pastie::AVAILABLE_PARSERS.join('|')})
            ) do |format|
          @options[:format] = format
        end
        
        cmd.on('-p', '--private', 'Create a private paste') do
          @options[:private] = true
        end
      end
    end
    
    def run(args)
      @parser.parse!(args)
      body = ''
      Timeout.timeout(1) do
        body += STDIN.read
      end
      if body.strip.empty?
        puts "Please pipe in some content to paste on STDIN."
        exit 1
      end

      pastie = API.new
      puts pastie.paste(body, @options[:format], @options[:private])
      exit 0
    rescue InvalidParser
      puts "Please specify a valid format parser."
      exit 1
    rescue Error
      puts "An unknown error occurred"
      exit 1
    rescue Timeout::Error
      puts "Could not read from STDIN."
      exit 1
    end
  end
end

if ($0 == __FILE__)
  app = Pastie::ConsoleOptions.new
  app.run(ARGV)
end
