class HomeScreen < PM::Screen
  title "Dirac Example"
  stylesheet HomeStylesheet

  def on_load
    # set_nav_bar_button :left, system_item: :camera, action: :nav_left_button
    # set_nav_bar_button :right, title: "Right", action: :nav_right_button

    # @hello_world_label = append!(UILabel, :hello_world)
    append(UIButton, :start_btn).on(:tap) do |sender|
      @mDiracAudioPlayer.play
    end
    append(UIButton, :stop_btn).on(:tap) do |sender|
      @mDiracAudioPlayer.stop
    end
    append(UIButton, :save_btn).on(:tap) do |sender|
      save_audio
    end
    @duration_slider = append(UISlider, :duration_slider).on(:change) do |sender|
      @mDiracAudioPlayer.changeDuration(sender.value)
      if @mUseVarispeed
        val = 1.0/sender.value
        @pitch_slider.get.value = 12.0 * Math.log2(val)
        @mDiracAudioPlayer.changePitch(val)
      end
    end
    @pitch_slider = append(UISlider, :pitch_slider).on(:change) do |sender|
      @mDiracAudioPlayer.changePitch(2.0 ** sender.value / 12.0)
    end
    append(UISwitch, :varispeed_switch).on(:change) do |sender|
      @mUseVarispeed = sender.on?
    end

    @inputSound  = NSBundle.mainBundle.pathForResource("voice", ofType:"aif")
    @inUrl = NSURL.fileURLWithPath(@inputSound)

    @error = Pointer.new(:object)
    @mDiracAudioPlayer = DiracFxAudioPlayer.alloc.initWithContentsOfURL(@inUrl, channels:1, error:@error)
    @mDiracAudioPlayer.setDelegate(self)
    @mDiracAudioPlayer.setNumberOfLoops(1)

    @mUseVarispeed = false
  end

  def diracPlayerDidFinishPlaying(player, successfully:flag)
    NSLog("Dirac player instance (0x%lx) is done playing", player);
  end

  # def save_audio
  #   Dispatch::Queue.new("com.mydomain.myapp.mybackgroundthreadname").async do
  #     # do something on the main thread, but asynchronously
  #     save_audio_async
  #   end
  # end
  # def save_audio_async
  #   p "TODO::Save audio file and then send it to users."
  #   outputSound = NSHomeDirectory().stringByAppendingString("/Documents/out.aif").retain
  #   p outputSound
  #   outUrl = NSURL.fileURLWithPath(outputSound).retain
  #   reader = EAFRead.alloc.init
  #   writer = EAFWrite.alloc.init

  #   # this thread does the processing
  #   # NSThread.detachNewThreadSelector(@selector(processThread:), toTarget:self, withObject:nil)

  #   # pool = NSAutoreleasePool.alloc.init
  #   # pool = NSAutoreleasePool.new
  #   p "Processing..."
  #   p "TimeStretching Example\nDIRAC Version: #{DiracVersion()}"

  #   numChannels = 1 # DIRAC LE allows mono only
  #   sampleRate = 44100.0

  #   # open input file
  #   reader.openFileForRead(@inUrl, sr:sampleRate, channels:numChannels)

  #   # create output file (overwrite if exists)
  #   writer.openFileForWrite(outUrl, sr:sampleRate, channels:numChannels, wordLength:16, type:KAudioFileAIFFType)

  #   # DIRAC parameters
  #   # Here we set our time an pitch manipulation values
  #   time = @duration_slider.get.value
  #   if @mUseVarispeed
  #     pitch = 1.0/@duration_slider.get.value
  #     formant = pitch
  #   else
  #     pitch = 2.0 ** @pitch_slider.get.value / 12.0
  #     formant = pitch
  #   end
  #   p time, pitch, formant


  #   # First we set up DIRAC to process numChannels of audio at 44.1kHz
  #   # N.b.: The fastest option is kDiracLambdaPreview / kDiracQualityPreview, best is kDiracLambda3, kDiracQualityBest
  #   # The probably best *default* option for general purpose signals is kDiracLambda3 / kDiracQualityGood
  #   dirac = DiracCreate(KDiracLambdaPreview, KDiracQualityPreview, numChannels, sampleRate, ->(chdata, numFrames, userData){
  #     # return false unless chdata
  #     # return false unless userData

  #     # # we want to exclude the time it takes to read in the data from disk or memory, so we stop the clock until
  #     # # we've read in the requested amount of data
  #     # gExecTimeTotal += DiracClockTimeSeconds()

  #     # OSStatus err = userData.reader.readFloatsConsecutive(numFrames, intoArray:chdata)

  #     # DiracStartClock()

  #     # return err
  #   }, self)
  #   # #  void *dirac = DiracCreate(KDiracLambda3, kDiracQualityBest, numChannels, sampleRate, &myReadData);
  #   # unless dirac
  #   #   p "!! ERROR !!\n\n\tCould not create DIRAC instance\n\tCheck number of channels and sample rate!\n"
  #   #   p "\n\tNote that the free DIRAC LE library supports only\n\tone channel per instance\n\n\n"
  #   #   return false
  #   # end

  #   # # # # Pass the values to our DIRAC instance
  #   # DiracSetProperty(KDiracPropertyTimeFactor, time, dirac);
  #   # DiracSetProperty(KDiracPropertyPitchFactor, pitch, dirac);
  #   # DiracSetProperty(KDiracPropertyFormantFactor, formant, dirac);

  #   # # upshifting pitch will be slower, so in this case we'll enable constant CPU pitch shifting
  #   # if pitch > 1.0
  #   #   DiracSetProperty(KDiracPropertyUseConstantCpuPitchShift, 1, dirac)
  #   # end

  #   # # # # Print our settings to the console
  #   # DiracPrintSettings(dirac)

  #   # p "Running DIRAC version #{DiracVersion()} \n Starting processing"

  #   # # Get the number of frames from the file to display our simplistic progress bar
  #   # numf = reader.fileNumFrames
  #   # outframes = 0
  #   # newOutframe = numf*time
  #   # lastPercent = -1
  #   # percent = 0

  #   # # This is an arbitrary number of frames per call. Change as you see fit
  #   # numFrames = 8192

  #   # # Allocate buffer for output
  #   # # audio = AllocateAudioBuffer(numChannels, numFrames)
  #   # audio = Pointer.new(:char)

  #   # p "Hello"

  #   # bavg = 0

  #   # while true
  #   #   # Display ASCII style "progress bar"
  #   #   percent = 100.0 * outframes / newOutframe
  #   #   ipercent = percent
  #   #   if lastPercent != percent
  #   #     p "\rProgress: %3i%% [%-40s] #{ipercent}, #{40 - ((ipercent>100)?40:(2*ipercent/5))}"
  #   #     # printf("", ipercent, &"||||||||||||||||||||||||||||||||||||||||"[40 - ((ipercent>100)?40:(2*ipercent/5))] );
  #   #     lastPercent = ipercent
  #   #     # fflush(stdout)
  #   #   end
  #   #   DiracStartClock()

  #   #   # Call the DIRAC process function with current time and pitch settings
  #   #   # Returns: the number of frames in audio
  #   #   ret = DiracProcess(audio, numFrames, dirac)
  #   #   bavg += (numFrames/sampleRate)
  #   #   gExecTimeTotal += DiracClockTimeSeconds()

  #   #   p "x realtime = #{bavg/gExecTimeTotal} : 1 (DSP only), CPU load (peak, DSP+disk): #{iracPeakCpuUsagePercent(dirac)}\n"
  #   #   #   printf("x realtime = %3.3f : 1 (DSP only), CPU load (peak, DSP+disk): %3.2f%%\n", bavg/gExecTimeTotal, DiracPeakCpuUsagePercent(dirac));

  #   #   # Process only as many frames as needed
  #   #   framesToWrite = numFrames
  #   #   nextWrite = outframes + numFrames
  #   #   framesToWrite = numFrames - nextWrite + newOutframe if nextWrite > newOutframe
  #   #   framesToWrite = 0 if framesToWrite < 0

  #   #   # Write the data to the output file
  #   #   writer.writeFloats(framesToWrite, fromArray:audio)

  #   #   # Increase our counter for the progress bar
  #   #   outframes += numFrames;

  #   #   # As soon as we've written enough frames we exit the main loop
  #   #   break if ret <= 0
  #   # end


  #   # # Free buffer for output
  #   # # DeallocateAudioBuffer(audio, numChannels)

  #   # # destroy DIRAC instance
  #   # DiracDestroy(dirac)

  #   p "\nDone!"
  #   # reader.release
  #   # writer.release
  #   # pool.drain
  # end

  def nav_left_button
    mp 'Left button'
  end

  def nav_right_button
    mp 'Right button'
  end

  # You don't have to reapply styles to all UIViews, if you want to optimize,
  # another way to do it is tag the views you need to restyle in your stylesheet,
  # then only reapply the tagged views, like so:
  # def logo(st)
  #   st.frame = {t: 10, w: 200, h: 96}
  #   st.centered = :horizontal
  #   st.image = image.resource('logo')
  #   st.tag(:reapply_style)
  # end
  #
  # # Then in willAnimateRotationToInterfaceOrientation
  # find(:reapply_style).reapply_styles
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    find.all.reapply_styles
  end
end

