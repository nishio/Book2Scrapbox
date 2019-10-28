# pdfstojson *.pdf > new.json
require 'fileutils'
require 'digest/md5'
require 'json'

jsondata = {}
pages = []

ARGV.each { |pdf|
  data = nil
  begin
    data = File.read(pdf)
  rescue
  end

  if data
    STDERR.puts pdf
  
    md5 = Digest::MD5.new.update(data).to_s
    md5 =~ /^(.{12})/
    pdfhash = $1

    if(!File.exist?("tmp/#{pdfhash}"))
      FileUtils.mkdir_p("tmp/#{pdfhash}")
      cmd = "pdftocairo -r 200 -f 0 -jpeg #{pdf} tmp/#{pdfhash}/page"
      STDERR.puts cmd
      system cmd
    end

    if(!File.exists?("tmp/#{pdfhash}.json"))
      cmd = "ruby makejson.rb #{pdfhash} tmp/#{pdfhash}/*.jpg > tmp/#{pdfhash}.json"
      STDERR.puts cmd
      system cmd
    end

    begin
      data = File.read("tmp/#{pdfhash}.json")
      x = JSON.load(data)
      pages += x['pages']
    rescue
      # 例えばmakejsonがネットワークエラーで死んだ場合に出力ファイルが空なので undefined method `[]' for nil:NilClass になる
      # 削除して再実行すれば良い
    end
  end
}

jsondata['pages'] = pages
puts jsondata.to_json
