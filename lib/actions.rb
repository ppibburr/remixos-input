def play_click
  Thread.new do
    #system("aplay ../data/click.wav") == 1 || system("aplay -D hw:0,3 ../data/click.wav") == 1 || system("aplay -D hw:1,0 ../data/click.wav") == 1  || nil
    system("beep -l 2")
  end
end
