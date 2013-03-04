# -*- encoding: utf-8 -*-
require 'net/http'
require 'thread'
require 'nokogiri'


module HttpAccess
  def get(domain, path)
    begin
      url = URI.parse("http://#{domain}#{path}")
    rescue URI::InvalidURIError => e
      p e.backtrace
    end
    return '' if url == nil
    res = Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Get.new(path)
      req.basic_auth '', ''
      http.request(req).body
    end
  end
end

class LinkCrawler
  attr_reader :domain, :enqued
  include HttpAccess

  def initialize(domain, compare_path_queue)
    @domain = domain
    @compare_path_queue = compare_path_queue
    @enqued = []
  end

  def target?(path)
    return false if path =~ /http.*$/
    return false if @enqued.include?(path)
    return false if path =~ /.*\.(pdf|jpg|jpeg|png|gif|swf)$/
    return false if path =~ /^\/switch.php.*$/
    return false if path =~ /^\..*$/
    return true  if path =~ /^\/.*/
  end

  def url_filter(path, base_path)
    expanded = File.expand_path(path, File.dirname(base_path))
    expanded += "/" if File.extname(expanded) == "" && expanded != "/" && expanded !~ /.*#.*/
    expanded
  end

  def valid_href?(href)
    return false if href == nil
    return false if href =~ /^javascript.*$/i
    return false if href =~ /.*mailto.*/
    true
  end

  def crawl path
    begin
      doc = Nokogiri::HTML(get(self.domain, path), nil, "utf-8")
      doc.css("a").each do |a|
        next unless valid_href? a["href"]
        url = URI.parse(a["href"])
        filtered_path = url_filter(url.to_s, path)
        if target?(filtered_path)
          @compare_path_queue.push filtered_path
          @enqued << filtered_path
          crawl(filtered_path)
        end
      end
    rescue URI::InvalidURIError => e
      p "! exception occured"
      p path
    end
  end
end

class Comparer
  attr_reader :domain1, :domain2
  include HttpAccess

  def initialize(domain1, domain2)
    @domain1 = domain1
    @domain2 = domain2
  end

  def compare path
    get(@domain1, path) == get(@domain2, path)
  end
end



domain1 = ""
domain2 = ""

compare_path_queue = Queue.new
search_link_finished = false
enqued_count = 0
compared_count = 0
ok_count = 0
ng_count = 0

search_link_thread = Thread.new do
  crawler = LinkCrawler.new(domain1, compare_path_queue)
  crawler.crawl "/"
  search_link_finished = true
  enqued_count = crawler.enqued.count
end

compare_site_thread = Thread.new do
  comparer = Comparer.new(domain1, domain2)
  loop do
    target_path = compare_path_queue.pop
    result = comparer.compare(target_path)
    p target_path
    if result
      p "OK"
      ok_count += 1
    else
      p "NG"
      ng_count += 1
    end
    compared_count += 1
    break if search_link_finished && compare_path_queue.empty?
  end
end

search_link_thread.join
compare_site_thread.join
p "target pages: #{enqued_count}"
p "compared_count: #{compared_count}"
p "OK: #{ok_count}"
p "NG: #{ng_count}"
