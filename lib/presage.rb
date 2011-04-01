class Presage
  
  def initialize
  end
  
  # input: text from wich words will be extracted
  def build(text)
    # parse words and then builds weighted links
    arr = []
    i = 0
    while word = parse_string
      arr << word
      if i == 0
        add_first_word()
      else
        add_word()
      end
      i = 0 if trim_space == true
    end
  
  end
  
  def clean_all
    # remove all data
    PresageWord.destroy_all
    PresageLink.destroy_all
  end

end