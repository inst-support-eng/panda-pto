class DocsController < ApplicationController

    def index
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,:autolink => true, :space_after_headers => true, :fenced_code_blocks => true, :tables => true, :with_toc_data => true, :images => true)
        @page = markdown.render(File.open("documentation/index.md").read)
        @files = Dir.entries("documentation/doc_files").select {|f| !File.directory? f}
    end

    def show
       begin
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,:autolink => true, :space_after_headers => true, :fenced_code_blocks => true, :tables => true, :with_toc_data => true)
   
        @page = markdown.render(File.open("documentation/doc_files/#{params[:file]}.#{params[:format]}").read)
     
        @files = Dir.entries("documentation/doc_files").select {|f| !File.directory? f}

       rescue Errno::ENOENT
        redirect_to :action => "index"

       end
        
    end
end