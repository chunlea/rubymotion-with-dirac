class HomeStylesheet < ApplicationStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end

  def hello_world(st)
    st.frame = {top: 100, width: 200, height: 18, centered: :horizontal}
    st.text_alignment = :center
    st.color = color.battleship_gray
    st.font = font.medium
    st.text = 'Hello World'
  end

  def start_btn(st)
    standard_button st
    st.text = "start"
    st.frame = {t: 100, w: 300, h: 30, centered: :horizontal}
  end
  def stop_btn(st)
    standard_button st
    st.text = "stop"
    st.frame = {t: 150, w: 300, h: 30, centered: :horizontal}
  end
  def save_btn(st)
    standard_button st
    st.text = "save"
    st.frame = {t: 200, w: 300, h: 30, centered: :horizontal}
  end
  def duration_slider(st)
    st.frame = {t: 300, w: 300, h: 30, centered: :horizontal}
    st.view.minimumValue = 0.5
    st.view.maximumValue = 2
  end
  def pitch_slider(st)
    st.frame = {t: 400, w: 300, h: 30, centered: :horizontal}
    st.view.minimumValue = -12
    st.view.maximumValue = 12
  end
  def varispeed_switch(st)
    st.frame = {t: 500, w: 300, h: 30, centered: :horizontal}
  end

end
