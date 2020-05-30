require 'net/http'
require 'json'
require 'uri'

class TimetrapHarvest::NetworkClient
  attr_reader :token, :account_id

  def initialize(config)
    @token     = config.token
    @account_id = config.account_id
  end

  def fetch(payload)
    uri = harvest_entries_uri
    params = { external_reference_id: payload[:external_reference][:id] }
    uri.query = URI.encode_www_form(params)

    req = Net::HTTP::Get.new(uri)
    res = request(uri, req)

    return if !res.is_a?(Net::HTTPSuccess)

    json = JSON.parse(res.body)
    return if json['total_entries'] == 0
    json['time_entries'][0]['id']
  end

  def create_or_update(id, payload)
    uri = harvest_entries_uri
    req = id.nil? ?
      Net::HTTP::Post.new(uri) :
      Net::HTTP::Patch.new(URI.join(uri, id.to_s))
    req.body            = payload.to_json
    req['Content-Type'] = 'application/json'
    req['Accept']       = 'application/json'

    request(uri, req)
  end

  def harvest_entries_uri
    URI("https://api.harvestapp.com/v2/time_entries/")
  end

  def request(uri, req)
    req["Authorization"] = "Bearer #{token}"
    req['Harvest-Account-ID'] = account_id

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.request(req)
  end
end
