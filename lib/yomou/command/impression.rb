# coding: utf-8
module Yomou
  module Command
    class Impression < Thor
      namespace :impression

      include Yomou::Helper

      BASE_URL = 'http://novelcom.syosetu.com/impression/list/ncode/'

      desc "download", ""
      def download(*ncodes)
        @conf = Yomou::Config.new

        ncodes.each do |ncode|
          info = fetch_info_from_ncode(ncode)
          p info
          (info[:impression_count] / 10 + 1).times do |index|
            url = "#{BASE_URL}#{info[:impression_id]}/"
            unless index == 0
              url += sprintf("index.php?p=%d", index + 1)
            end
            p url
            open(url) do |context|
              doc = Nokogiri::HTML.parse(context.read)
              doc.xpath("//div[@class='waku']").each do |div|
                div.xpath('div').each do |child|
                  case child.attribute('class').text
                  when "comment_h2"
                    label = child.text
                  when "comment"
                    body = child.text
                    case label
                    when "良い点"
                    when "悪い点"
                    when "一言"
                    end
                  when "res"
                  end
                end
              end
            end
          end
        end
      end

      private

      INFO_URL = 'http://ncode.syosetu.com/novelview/infotop/ncode/'

      def fetch_info_from_ncode(ncode)
        hash = {}
        path = pathname_expanded([@conf.directory,
                                  'info',
                                  ncode.slice(1,2),
                                  "#{ncode.downcase}.html.xz"])
        info_url = INFO_URL + ncode + '/'
        p info_url
        save_as(info_url, path, {:compress => true})
        html_xz(path.to_s) do |doc|
          doc.xpath("//ul[@id='head_nav']/li/a").each do |a|
            case a.text
            when '感想'
              hash[:impression_url] = a.attribute('href').value
              hash[:impression_url] =~ /.+\/(\d+)\/$/
              hash[:impression_id] = $1
            when 'レビュー'
              hash[:review_url] = a.attribute('href').value
            end
          end
          doc.xpath("//table[@id='noveltable2']/tr").each_with_index do |tr,i|
            label = ""
            text = ""
            tr.xpath('th').each do |th|
              label = th.text
            end
            tr.xpath('td').each do |td|
              text = td.text
            end
            case label
            when '感想'
              hash[:impression_count] = text.gsub(/\n|件/, "").to_i
            when 'レビュー'
              hash[:review_count] = text.gsub(/,|件/, "").to_i
            when 'ポイント評価'
              hash[:writing_point] = text.split[0].gsub(/,|pt/, "").to_i
              hash[:story_point] = text.split[2].gsub(/,|pt/, "").to_i
            when 'ブックマーク登録'
              hash[:bookmark_count] = text.gsub(/,|件/, "").to_i
            end
          end
        end
        hash
      end
    end

  end
end