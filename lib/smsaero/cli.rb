require 'smsaero'
require 'thor'
require 'yaml'

class Smsaero::CLI < Thor
    include Thor::Actions

    def initialize(*args)
        super
        settings = {"login" => "", "password" => ""}
        settings = YAML.load_file("#{ENV['HOME']}/.smsaerorc") if File.exist?("#{ENV['HOME']}/.smsaerorc")
        @sms = Smsaero::API.new(settings["login"], settings["password"])
    end

    desc "auth", "Save auth data to $HOME/.smsaerorc"
    method_option :login,    :aliases => "-l", :type => :string, :required => true
    method_option :password, :aliases => "-p", :type => :string, :required => true
    def auth
        settings = {"login" => options[:login], "password" => options[:password]}
        File.open("#{ENV['HOME']}/.smsaerorc", 'w') {|f| f.write settings.to_yaml }
    end

    desc "balance", "Get current balance"
    def balance
        say @sms.balance
    end

    desc "senders", "Get available senders"
    def senders
        say @sms.senders.join("\n")
    end

    desc "status", "Get SMS status by id"
    method_option :id,  :aliases => "-i", :type => :string, :required => true
    def status
        say @sms.status(options[:id])
    end

    desc "sign", "Request new sender or check it's status"
    method_option :sign, :aliases => "-s", :type => :string, :required => true
    def sign
        say @sms.sign(options[:sign])
    end

    desc "message", "Send a short message to a number, returns message id"
    method_option :to,   :aliases => "-t", :type => :numeric, :required => true
    method_option :from, :aliases => "-f", :type => :string, :required => true
    method_option :text, :aliases => "-m", :type => :string, :required => true
    method_option :type, :aliases => "-b", :type => :numeric, :default => 2
    method_option :date, :aliases => "-d", :type => :numeric, :banner => "unix time"
    def message
        if options.has_key?(:date)
            say @sms.send(options[:to], options[:from], options[:text], options[:type] options[:date])
        else
            say @sms.send(options[:to], options[:from], options[:text], options[:type])
        end
    end
end
