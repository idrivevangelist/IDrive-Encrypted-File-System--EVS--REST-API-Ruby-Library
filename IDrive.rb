require "net/https"
require 'uri'
require 'rexml/document'

module IDrive
        class IDriveAPI
                def initialize(uid,pwd)
                        @uid, @pwd = uid, pwd

                        uri = URI.parse("https://evs.idrive.com/")
                        http = Net::HTTP.new(uri.host, uri.port)
                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

                        request = Net::HTTP::Post.new("/evs/getServerAddress")
                        request.set_form_data({"uid" => @uid,"pwd" => @pwd})
                        response = http.request(request)

                        document = REXML::Document.new(response.body)
                        @base_url = document.root.attributes['webApiServer']
                        puts @base_url
                end
                def execute(page, parameters)
                        uri = URI.parse("https://"+@base_url)

                        http = Net::HTTP.new(uri.host, uri.port)

                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

                        request = Net::HTTP::Post.new("/evs/"+page)
                        if page == 'uploadFile' or page == 'downloadFile'
                                request['content-type'] = "multipart/form-data"
                        else
                                request['content-type'] = "application/x-www-form-urlencoded"
                        end

                        parameters['uid'] = @uid
                        parameters['pwd'] = @pwd
                        request.set_form_data(parameters)
                        response = http.request(request)

                        document = REXML::Document.new(response.body)
                        return document.root
                end
        end
end
