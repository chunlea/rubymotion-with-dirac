class Home2Screen < PM::Screen
  title "Dirac Example"
  stylesheet HomeStylesheet

  def on_load
    initAudioMonitor
    initAudioRecorder
    @gExecTimeTotal = 0.0

    # DIRAC parameters
    @time      = 1
    @pitch     = 0.75
    @formant   = 2**(0.0/12.0)

    # self.schedule("monitorAudioController:")
    # set_nav_bar_button :left, system_item: :camera, action: :nav_left_button
    # set_nav_bar_button :right, title: "Right", action: :nav_right_button

    append(UIButton, :start_btn).on(:tap) do |sender|
      p "startRecording"
      @isRecording = true
      @recorder.record
    end
    append(UIButton, :stop_btn).on(:tap) do |sender|
      p "stopRecording Record time: #{@recorder.currentTime}"

      @isRecording = false
      @recorder.stop

      @isPlaying = true
      initDiracPlayer
    end
    append(UIButton, :save_btn).on(:tap) do |sender|

    end
    # @duration_slider = append(UISlider, :duration_slider).on(:change) do |sender|
    #   @mDiracAudioPlayer.changeDuration(sender.value)
    #   if @mUseVarispeed
    #     val = 1.0/sender.value
    #     @pitch_slider.get.value = 12.0 * Math.log2(val)
    #     @mDiracAudioPlayer.changePitch(val)
    #   end
    # end
    # @pitch_slider = append(UISlider, :pitch_slider).on(:change) do |sender|
    #   @mDiracAudioPlayer.changePitch(2.0 ** sender.value / 12.0)
    # end
    # append(UISwitch, :varispeed_switch).on(:change) do |sender|
    #   @mUseVarispeed = sender.on?
    # end

    # @inputSound  = NSBundle.mainBundle.pathForResource("voice", ofType:"aif")
    # @inUrl = NSURL.fileURLWithPath(@inputSound)

    # @error = Pointer.new(:object)
    # @mDiracAudioPlayer = DiracFxAudioPlayer.alloc.initWithContentsOfURL(@inUrl, channels:1, error:@error)
    # @mDiracAudioPlayer.setDelegate(self)
    # @mDiracAudioPlayer.setNumberOfLoops(1)

    # @mUseVarispeed = false
  end

  def initAudioMonitor
    recordSetting = NSMutableDictionary.alloc.init
    recordSetting.setValue (NSNumber.numberWithInt(KAudioFormatAppleIMA4), forKey:AVFormatIDKey)
    recordSetting.setValue(NSNumber.numberWithFloat(44100.0), forKey:AVSampleRateKey)
    recordSetting.setValue(NSNumber.numberWithInt(1), forKey:AVNumberOfChannelsKey)

    documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)
    fullFilePath = documentPaths.objectAtIndex(0).stringByAppendingPathComponent("monitor.caf")
    monitorTmpFile = NSURL.fileURLWithPath(fullFilePath)
    p fullFilePath

    error = Pointer.new(:object)

    @audioMonitor =  AVAudioRecorder.alloc.initWithURL(monitorTmpFile, settings:recordSetting, error:error)
    @audioMonitor.setMeteringEnabled(true)
    @audioMonitor.setDelegate(self)
    @audioMonitor.record
  end
  def initAudioRecorder
    recordSetting = NSMutableDictionary.alloc.init
    recordSetting.setValue (NSNumber.numberWithInt(KAudioFormatAppleIMA4), forKey:AVFormatIDKey)
    recordSetting.setValue(NSNumber.numberWithFloat(44100.0), forKey:AVSampleRateKey)
    recordSetting.setValue(NSNumber.numberWithInt(1), forKey:AVNumberOfChannelsKey)

    documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)
    fullFilePath = documentPaths.objectAtIndex(0).stringByAppendingPathComponent("in.caf")
    inUrl = NSURL.fileURLWithPath(fullFilePath)
    p fullFilePath

    error = Pointer.new(:object)

    @recorder =  AVAudioRecorder.alloc.initWithURL(inUrl, settings:recordSetting, error:error)
    @recorder.setMeteringEnabled(true)
    @recorder.setDelegate(self)
    @recorder.prepareToRecord
  end
  def initDiracPlayer
    @outputSound = NSHomeDirectory().stringByAppendingString("/Documents/").stringByAppendingString("out.aif").retain
    @outUrl = NSURL.fileURLWithPath(@outputSound).retain
    @reader = EAFRead.alloc.init
    @writer = EAFWrite.alloc.init

    NSThread.detachNewThreadSelector(:processThread, toTarget:self, withObject:nil)
  end
  def processThread
    p "processThread"
    numChannels = 1
    sampleRate  = 44100.0

    # open input file
    @reader.openFileForRead(@inUrl, sr:sampleRate, channels:numChannels)

    # create output file (overwrite if exists)
    @writer.openFileForWrite(@outUrl, sr:sampleRate, channels:numChannels, wordLength:16, type:KAudioFileAIFFType)

    # First we set up DIRAC to process numChannels of audio at 44.1kHz
    # N.b.: The fastest option is kDiracLambdaPreview / kDiracQualityPreview, best is kDiracLambda3, kDiracQualityBest
    # The probably best *default* option for general purpose signals is kDiracLambda3 / kDiracQualityGood
    dirac = DiracCreate(KDiracLambdaPreview, KDiracQualityPreview, numChannels, sampleRate, ->(chdata, numFrames, userData) {
      # // The userData parameter can be used to pass information about the caller (for example, "self") to
      # // the callback so it can manage its audio streams.
      return false if !chdata
      return false if !userData

      # // we want to exclude the time it takes to read in the data from disk or memory, so we stop the clock until
      # // we've read in the requested amount of data
      @gExecTimeTotal += DiracClockTimeSeconds() #  stop timer

      err = userData.reader.readFloatsConsecutive(numFrames, intoArray:chdata)

      DiracStartClock() # start timer

      return err
    }, self)
    p dirac
    # //  void *dirac = DiracCreate(kDiracLambda3, kDiracQualityBest, numChannels, sampleRate, &myReadData);
    if !dirac
      p "!! ERROR !!\n\n\tCould not create DIRAC instance\n\tCheck number of channels and sample rate!\n"
      p "\n\tNote that the free DIRAC LE library supports only\n\tone channel per instance\n\n\n"
      return false
    end
  end

  # def monitorAudioController(dt)
  #   if !isPlaying
  #     audioMonitor.updateMeters
  #   end
  #         // a convenience, it’s converted to a 0-1 scale, where zero is complete quiet and one is full volume
  #         const double ALPHA = 0.05
  #         double peakPowerForChannel = pow(10, (0.05 * audioMonitor.peakPowerForChannel(0)))
  #         double audioMonitorResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * audioMonitorResults

  #         //NSLog(@"audioMonitorResults: %f", audioMonitorResults);

  #         if (audioMonitorResults > AUDIOMONITOR_THRESHOLD)
  #         {   //NSLog(@"Sound detected");

  #             if(!isRecording)
  #             {   [audioMonitor stop];
  #                 [self startRecording];
  #             }
  #         }   else
  #         {   //NSLog(@"Silence detected");
  #             if(isRecording)
  #             {   if(silenceTime > MAX_SILENCETIME)
  #                 {
  #                     NSLog(@"Next silence detected");
  #                     [audioMonitor stop];
  #                     [self stopRecordingAndPlay];
  #                     silenceTime = 0;
  #                 }   else
  #                 {   silenceTime += dt;
  #                 }
  #             }
  #         }
  #     }
  # end

  def diracPlayerDidFinishPlaying(player, successfully:flag)
    NSLog("Dirac player instance (0x%lx) is done playing", player);
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

