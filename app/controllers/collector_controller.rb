class CollectorController < ApplicationController
    
    def collect
        
    end

    def result
        
        #찾으려는 책 리스트 넘어옴; 일체형 / nil클래스(delete시에) 빈문자열
        if params[:bookname].nil?
            params[:bookname] = ""
        end
        @findresult = CGI.escape(params[:bookname])

                
            
                    #개행으로 절단
                    @findresultarray = @findresult.split("%0D%0A")
                    
                    @findresultarray.each do |x|
                        #하나씩 네이버에 검색하기 / 받은결과 html-doc 삽입 / 첫째검색순위 저장
                        uri = URI("http://book.naver.com/search/search.nhn?sm=sta_hty.book&sug=&where=nexearch&query=#{x}")
                        html_doc = Nokogiri::HTML(Net::HTTP.get(uri))
                        #최종 저자 (역자) 출판사 날짜
                        @printresult = html_doc.css("dd.txt_block")[0].inner_text
                        
                        @printresultarray = @printresult.split("|")
                        
                        #저자 출판 날짜 디비입력
                        eachbook = Bookshelf.new
                        eachbook.authorname = @printresultarray[0]
                        eachbook.publisher = @printresultarray[@printresultarray.length - 2]
                        eachbook.releasedate = @printresultarray[@printresultarray.length - 1]
                        
                        #확인을 위한 제대로된 제목입력
                        @tempstrforsub = html_doc.css("#searchBiblioList//li")[0].css("dt//a")[0].inner_text
                        eachbook.bookname = @tempstrforsub
                        #그에따른 부제목입력
                        @tempstrforsub = html_doc.css("#searchBiblioList//li")[0].css("dt//span").inner_text
                        
                        if @tempstrforsub.empty?
                            eachbook.booksubname = "cannot find subtitle"    
                        else
                            eachbook.booksubname = @tempstrforsub    
                        end
                        
                        
                        #첫째검색순위 타고들어가기위한 링크 저장
                        #@firstlink = html_doc.css("#searchBiblioList//li")[0].css("dl//dt//a").map {|link| link ['href']}.to_s[2..-3]
                        @firstlink = html_doc.css("#searchBiblioList//li")[0].css("div//div//a").map {|link| link ['href']}.to_s[2..-3]
                        eachbook.booklink = @firstlink
                        
                        #링크접속 / isbn 저장
                        uri = URI(@firstlink)
                        html_doc = Nokogiri::HTML(Net::HTTP.get(uri))
                        @printresult2 = html_doc.css(".book_info_inner//div").inner_text
                        
                        #텍스트섬을 isbn 문자열로 분할하고 두번째문자열의 첫13자리
                        
                        if @printresult2.include? "|ISBN"
                            @resisbn = @printresult2.split("|ISBN ")[1][1..13]    
                        else
                            @resisbn = "cannot find ISBN"
                        end
                        #@resisbn = @printresult2
                        eachbook.isbnnumber = @resisbn
                        
                        #카테고리저장
                        html_doc = Nokogiri::HTML(Net::HTTP.get(uri))
                        @printresult3 = html_doc.css("#category_location1_depth").inner_text 
                        if @printresult3.empty?
                            @printresult3="cannot find category"
                        end
                        eachbook.categorize = @printresult3
                        
                        eachbook.save
                    end

        @outputbooksum = Bookshelf.all
        # uri = URI(@firstlink)
        # html_doc = Nokogiri::HTML(Net::HTTP.get(uri))
        # @printresult2 = html_doc.css("div.book_info//h2").inner_text
        
        
        
        
        
        
        
        
        
        # @cutlink = @getlink[2..-3]
        # uri = URI("#{@firstlink}")
        # html_doc = Nokogiri::HTML(Net::HTTP.get(uri))
        # @lastresult = html_doc.css("")
        
        
        def delpost
            
            one_post = Bookshelf.find(params[:id])
            one_post.destroy
            
            redirect_to "/collector/result"
        end
    end
    
end