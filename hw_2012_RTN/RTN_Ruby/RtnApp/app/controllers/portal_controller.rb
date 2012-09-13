class PortalController < ApplicationController
  def index
  end
  
  def execute
    load "#{Dir.pwd}/rtncode/rtnm.rb"
    load "#{Dir.pwd}/rtncode/dm.rb"
    load "#{Dir.pwd}/rtncode/sm.rb"
    load "#{Dir.pwd}/rtncode/lib.rb"
    load "#{Dir.pwd}/rtncode/rule.rb"
    load "#{Dir.pwd}/rtncode/rule_tuple.rb"
    
    sentence = params[:sentence]
    dictTxt = params[:dict]
    rtnmTxt = params[:rtnm]
    
    rtnm = Rtnm.flogic rtnmTxt
    dict = Dm.sfactory dictTxt
    
    Lib.setRuleTypes dict, rtnm
    
    returnSentence = "PROCESSING SENTENCE: #{sentence}\r"
    
    result = Lib.vs sentence, dict, rtnm
    sm = Sm.new
    sm.sentence = sentence
    result.each do |tr|
			returnSentence = returnSentence + tr.prettyprinttos(sm)
		end
    
    render :text => "#{returnSentence}"
  end
end