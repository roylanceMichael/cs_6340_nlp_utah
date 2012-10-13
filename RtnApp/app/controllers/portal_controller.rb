class PortalController < ApplicationController
  def index
  end
  
  def home
  end
  
  def executener
    load "#{Dir.pwd}/ner/ner.rb"
    load "#{Dir.pwd}/ner/rule.rb"
    load "#{Dir.pwd}/ner/instance.rb"
    
    seeds = params[:nerSeeds]
    training = params[:nerTraining]
    test = params[:nerTest]
    
    if seeds == nil || training == nil || test == nil
      render :text => "Please input all variables"
      return
    end
    
    seedT = Rule.factory seeds
    nerT = Instance.factory training
    testT = Instance.factory test
    
    ner = Ner.new seedT, nerT, testT
    
    render :text => ner.execute
  end
  
  def executelanguagegen
    load "#{Dir.pwd}/ngram/sentence.rb"
    load "#{Dir.pwd}/ngram/ngram.rb"
    
    training = params[:training]
    seeds = params[:seeds]
    
    if seeds == nil || training == nil
      render :text => "Please input all the variables"
      return
    end
    
    trainingSentences = Sentence.factory training
    ngram = Ngram.new trainingSentences
    
    returnSentence = ""
    results = ngram.languagegen seeds
    
    puts results
    results.each do |result|
      returnSentence = returnSentence + result + "\n"
    end
    
    render :text => returnSentence
  end
  
  def executengram
    load "#{Dir.pwd}/ngram/sentence.rb"
    load "#{Dir.pwd}/ngram/ngram.rb"
    
    sentence = params[:sentence]
    training = params[:training]
    
    if sentence == nil || training == nil
      render :text => "Please input all the variables"
      return
    end
    
    trainingSentences = Sentence.factory training
    ngram = Ngram.new trainingSentences 
    
    render :text => (ngram.prob sentence)
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
    
    if sentence == nil || sentence.length == 0 || dictTxt == nil || dictTxt.length == 0 || rtnmTxt == nil || rtnmTxt.length == 0
      render :text => "Please input all the variables"
      return
    end
    
    rtnm = Rtnm.flogic rtnmTxt
    dict = Dm.sfactory dictTxt
    
    Lib.setRuleTypes dict, rtnm
    
    returnSentence = "PROCESSING SENTENCE: #{sentence}\r\r"
    
    result = Lib.vs sentence, dict, rtnm
    sm = Sm.new
    sm.sentence = sentence
    result.each do |tr|
			returnSentence = "#{returnSentence}#{tr.prettyprinttos(sm)}\r\r"
		end
		
		returnSentence = "#{returnSentence}Done! Found #{result.length} parse(s)."
    
    render :text => "#{returnSentence}"
  end
end