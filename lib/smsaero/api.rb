require "net/http"
require "digest/md5"
require "json"

class Smsaero::API
    API_URL = "https://gate.smsaero.ru/"
    attr_reader :user, :password
    attr_writer :user

    def initialize(user="", password="")
        @user     = user
        @password = Digest::MD5.hexdigest(password)
    end

    def password=(pass)
        @password = Digest::MD5.hexdigest(pass)
    end

    def balance
        result = request("balance", {})
        result[:balance]
    end

    def send(to, from, text, type=2, date=-1)
        params = {
            "to"    => to,
            "from"  => from,
            "text"  => text,
            "type"  => type,
        }
        params["date"] = date if date > 0

        result = request("send", params)
        result[:id]
    end

    def senders
        result = request("senders", {})
    end

    def sign(sign)
        result = request("sign", {"sign" => sign})
        result[:accepted]
    end

    def status(id)
        result = request("status", {'id' => id})
        result[:result]
    end

    private
    def request(endpoint, params)
        endpoint = endpoint.gsub(/^\/|\/$/, "")

        params['user']     = @user
        params['password'] = @password
        params['answer']   = 'json'

        response = Net::HTTP.post_form(URI.parse(API_URL + endpoint + "/"), params)
        if response.code != '200'
            raise "Server respond with #{response.code}"
        end

        result   = JSON.parse(response.body, symbolize_names: true)
        if result.is_a?(Hash) and result.has_key?(:result) and result[:result] == 'reject'
            raise "#{result[:reason]}"
        else
            result
        end
    end
end
