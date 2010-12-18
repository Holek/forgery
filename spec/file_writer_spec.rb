require 'spec_helper'

describe Forgery::FileWriter do
  before :each do
    Forgery::FileWriter.write_to! 'spec/data/dictionaries'
    @lines = ['one', 'two', 'three']
    @file = Forgery::FileWriter.create_file 'test_file', @lines
  end

  it "should create a dictionary file when given an array" do
    File.exist?(File.expand_path(@file)).should be_true
  end

  it "should have one line for each item in the array" do
    IO.readlines(@file)[0].chomp.should == "one"
    IO.readlines(@file)[2].chomp.should == "three"
  end

  it "should create a dictionary file an html page" do
    html_doc = get_sample 'mock_web_page.html'
    Forgery::FileWriter.stub!(:open_page).and_return(html_doc)
    dictionary = Forgery::FileWriter.create_dictionary('numbers', 'http://www.fakeurl.com', '#list li')
    File.exist?(File.expand_path(dictionary)).should be_true
    IO.readlines(dictionary)[1].chomp.should == 'dos'
    File.delete(dictionary)
  end

  it "should create a dictionary file from xml content" do
    xml_doc = get_sample 'mock_xml_doc.xml'
    Forgery::FileWriter.stub!(:open_page).and_return(xml_doc)
    dictionary = Forgery::FileWriter.create_dictionary('dogs', 'http://www.fakeurl.com', '//dog')
    File.exist?(File.expand_path(dictionary)).should be_true
    IO.readlines(dictionary)[0].chomp.should == 'Labrador Retriever'
    File.delete(dictionary)
  end

  it "should accept multiple selectors for html/xml content" do
    html_doc = get_sample('mock_web_page.html')
    Forgery::FileWriter.stub!(:open_page).and_return(html_doc)
    dictionary = Forgery::FileWriter.create_dictionary('multiple_selectors_sample', 'http://www.fakeurl.com', 'h1', 'h2', 'p')
    File.exist?(File.expand_path(dictionary)).should be_true
    IO.readlines(dictionary)[0].chomp.should == 'Title'
    IO.readlines(dictionary)[2].chomp.should == 'Paragraph.'
    File.delete(dictionary)
  end

  after :each do
    File.delete @file if File.exist? @file
  end

  def get_sample(file_name)
    file = File.open("spec/data/documents/#{file_name}")
    doc = Nokogiri.parse(file)
    file.close
    doc
  end
end