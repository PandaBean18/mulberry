require 'open-uri'
require 'nokogiri'
require 'json'
require 'net/http'

class MediaParserService
    HEADERS = {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
    }.freeze

    def self.call(url)
        new(url).parse
    end

    def initialize(url)
        @url = url
    end

    def parse
        if @url.include?("instagram.com")
            parse_instagram
        elsif @url.include?("youtube.com") || @url.include?("youtu.be")
            parse_youtube
        else
            parse_generic_webpage
        end
    end

    private

    def parse_youtube
        video_id = extract_youtube_id(@url)
        
        return parse_generic_webpage unless video_id 

        yt_data = fetch_youtube_data(video_id)
        
        return parse_generic_webpage if yt_data.empty?

        {
            external_url: @url,
            title: yt_data[:title],
            description: yt_data[:description],
            
            thumbnail_url: yt_data[:thumbnail_url] || "https://img.youtube.com/vi/#{video_id}/maxresdefault.jpg",
            media_url: "https://www.youtube.com/embed/#{video_id}",
            
            metrics: {
                views: yt_data[:views].to_i,
                likes: yt_data[:likes].to_i,
                comments: yt_data[:comments].to_i
            }.delete_if { |_, v| v.zero? }
        }
    end

    def extract_youtube_id(url)
        match = url.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|shorts)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i)
        match ? match[1] : nil
    end

    def fetch_youtube_data(video_id)
        api_key = ENV['YOUTUBE_API_KEY']
        
        if api_key.blank?
            Rails.logger.warn("[MediaParserService] Missing YOUTUBE_API_KEY")
            return {} 
        end

        uri = URI("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=#{video_id}&key=#{api_key}")
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)
            return {} if data['items'].blank?
            
            item = data['items'].first 
            snippet = item['snippet']
            stats = item['statistics']
        
            {
                title: snippet['title'],
                description: snippet['description'],
                thumbnail_url: snippet.dig('thumbnails', 'maxres', 'url') || snippet.dig('thumbnails', 'high', 'url'),
                views: stats['viewCount'],
                likes: stats['likeCount'],
                comments: stats['commentCount']
            }
        else
            Rails.logger.error("[MediaParserService] YouTube API Error: HTTP #{response.code} - #{response.body}")
            {}
        end
    rescue StandardError => e
        Rails.logger.error("[MediaParserService] Failed to fetch YouTube metrics: #{e.message}")
        {}
    end
    
    def parse_instagram
        shortcode = extract_instagram_shortcode(@url)
        return nil unless shortcode

        apify_data = fetch_metrics_from_apify(shortcode)
        return nil if apify_data.empty?

        {
            external_url: @url,
            title: apify_data[:caption].to_s.truncate(80, separator: ' ') || "Instagram Post",
            description: apify_data[:caption],
            
            temporary_thumbnail_url: apify_data[:display_url],
            temporary_media_url: apify_data[:video_url],
            
            metrics: {
                views: apify_data[:views].to_i,
                likes: apify_data[:likes].to_i,
                comments: apify_data[:comments].to_i
            }.delete_if { |_, v| v.zero? }
        }
    end

    def extract_instagram_shortcode(url)
        match = url.match(/instagram\.com\/(?:p|reel|tv)\/([A-Za-z0-9_\-]+)/i)
        match ? match[1] : nil
    end

    def fetch_metrics_from_apify(shortcode)
        api_token = ENV['APIFY_API_TOKEN']
        
        if api_token.blank?
        Rails.logger.warn("[MediaParserService] Missing APIFY_API_TOKEN")
        return {} 
        end

        actor_url = URI("https://api.apify.com/v2/acts/apify~instagram-scraper/run-sync-get-dataset-items?token=#{api_token}")
        payload = { "directUrls": ["https://www.instagram.com/p/#{shortcode}/"] }.to_json

        response = Net::HTTP.post(
            actor_url, 
            payload, 
            { "Content-Type" => "application/json" }
        )

        if response.code == "200" || response.code == "201"
            items = JSON.parse(response.body)
            return {} if items.blank?
            
            item = items.first 
        
            {
                caption: item["caption"],
                likes: item["likesCount"],
                comments: item["commentsCount"],
                views: item["videoPlayCount"],
                display_url: item["displayUrl"],
                video_url: item["videoUrl"]
            }
        else
            Rails.logger.error("[MediaParserService] Apify Error: HTTP #{response.code} - #{response.body}")
            {}
        end
    rescue StandardError => e
        Rails.logger.error("[MediaParserService] Failed to fetch Apify metrics: #{e.message}")
        {}
    end

    def parse_generic_webpage
        doc = fetch_document
        return nil unless doc

        {
            external_url: @url,
            title: extract_meta(doc, ['og:title', 'twitter:title']) || doc.at_css('title')&.text,
            description: extract_meta(doc, ['og:description', 'twitter:description', 'description']),
            temporary_thumbnail_url: extract_meta(doc, ['og:image', 'twitter:image:src']),
            temporary_media_url: extract_meta(doc, ['og:video:secure_url', 'og:video', 'twitter:player']),
            metrics: extract_json_ld_metrics(doc)
        }.compact
    end

    def fetch_document
        html = URI.open(@url, HEADERS).read
        Nokogiri::HTML(html)
    rescue OpenURI::HTTPError, SocketError, Net::OpenTimeout => e
        Rails.logger.error("[MediaParserService] Failed to fetch #{@url}: #{e.message}")
        nil
    end

    def extract_meta(doc, properties)
        properties.each do |prop|
            node = doc.at_css("meta[property='#{prop}'], meta[name='#{prop}']")
            return node['content'] if node && node['content'].present?
        end
        nil
    end

    def extract_json_ld_metrics(doc)
        metrics = { views: 0, likes: 0, comments: 0 }
        
        doc.css('script[type="application/ld+json"]').each do |script|
            begin
                data = JSON.parse(script.text)
                raw_json_string = data.to_json 
                
                if data.is_a?(Hash) || data.is_a?(Array)
                    metrics[:views] = extract_interaction_count(raw_json_string, 'WatchAction')
                    metrics[:likes] = extract_interaction_count(raw_json_string, 'LikeAction')
                    metrics[:comments] = extract_interaction_count(raw_json_string, 'CommentAction')
                end
            rescue JSON::ParserError
                next
            end
        end

        metrics.delete_if { |_, v| v.zero? }
        metrics
    end

    def extract_interaction_count(json_string, action_type)
        match = json_string.match(/#{action_type}".*?"userInteractionCount":\s*(\d+)/i)
        match ? match[1].to_i : 0
    end
end