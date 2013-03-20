require '../sitecompare'

describe LinkCrawler do
  before :each do
    @linkCrawler = LinkCrawler.new('example.jp', Queue.new)
  end
  describe '#target?' do
    context 'when passed link to PDF' do
      it 'returns false' do
        @linkCrawler.target?('example.pdf').should be_false
        @linkCrawler.target?('example.PDF').should be_false
      end
    end
    context 'when passed link to JPEG' do
      it 'returns false' do
        @linkCrawler.target?('example.jpeg').should be_false
        @linkCrawler.target?('example.jpg').should be_false
        @linkCrawler.target?('example.JPEG').should be_false
        @linkCrawler.target?('example.JPG').should be_false
      end
    end
    context 'when passed link to GIF' do
      it 'returns false' do
        @linkCrawler.target?('example.gif').should be_false
        @linkCrawler.target?('example.GIF').should be_false
      end
    end
    context 'when passed link to PNG' do
      it 'returns false' do
        @linkCrawler.target?('example.png').should be_false
        @linkCrawler.target?('example.PNG').should be_false
      end
    end
    context 'when passed link to SWF' do
      it 'returns false' do
        @linkCrawler.target?('example.swf').should be_false
        @linkCrawler.target?('example.SWF').should be_false
      end
    end
    context 'when passed link to external URL' do
      it 'returns false' do
        @linkCrawler.target?('http://www.example.jp').should be_false
      end
    end
    context 'when passed link to HTML' do
      it 'returns true' do
        @linkCrawler.target?('/example.html').should be_true
      end
    end
  end

  describe '#valid_href?' do
    context 'when passed link to Javscript' do
      it 'returns false' do
        @linkCrawler.valid_href?('javascript:hoge();').should be_false
      end
    end
    context 'when passed link to MAILTO' do
      it 'returns false' do
        @linkCrawler.valid_href?('mailto:ex@example.jp').should be_false
      end
    end
    context 'when passed link to HTML' do
      it 'returns true' do
        @linkCrawler.valid_href?('/example.html').should be_true
      end
    end
  end

  describe '#url_filter' do
    context 'when passed relative path' do
      it 'convert to absolute path and return it' do
        @linkCrawler.url_filter('example.html', '/').should == '/example.html'
        @linkCrawler.url_filter('ex/example.html', '/').should == '/ex/example.html'
      end
    end
    context 'when passed absolute path' do
      it 'returns it' do
        @linkCrawler.url_filter('/example.html', '/').should == '/example.html'
      end
    end
    context 'when passed the path ends with directory name' do
      it 'add a slash and return it' do
        @linkCrawler.url_filter('/ex/directory_name', '/').should == '/ex/directory_name/'
      end
    end
    context 'when passed the path with url fragment' do
      it 'returns it' do
        @linkCrawler.url_filter('/example.html#ex', '/').should == '/example.html#ex'
      end
    end
  end
end
