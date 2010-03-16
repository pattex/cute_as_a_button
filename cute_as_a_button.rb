HOURS_TO_WORK = 8

class Workday

  attr_reader :started_at

  def initialize(started_at, worktime)
    @started_at  = started_at
    @paused      = 0
    @working     = true
    @duration = @worktime = worktime
  end

  def work
    @working = true
  end

  def pause
    @working = false
  end

  def working?
    @working
  end

  def duration
    @duration = end_of_work - Time.now unless @duration.to_i == 0
  end

  def idle
    @paused += 1 unless @duration.to_i == 0
  end

  def end_of_work
    Time.at(@started_at + @worktime + @paused)
  end

end

class Shoes::App

  def time_as_string(time)
    if time.is_a?(Time)
      time.strftime("%H:%M")
    else
      "%02d:%02d" % [
        time / (60 * 60),
        time / 60 % 60
      ]
    end
  end

  def start
    @workday = Workday.new(Time.now, HOURS_TO_WORK * 3600)
    draw_button_stack('pause')
  end

  def pause
    @workday.pause
    draw_button_stack('work')
  end

  def work
    @workday.work
    draw_button_stack('pause')
  end

  def draw_button(action)
    button(action.capitalize,  :width => 70) do
      send(action)
    end
  end

  def draw_button_stack(action)
    if @button
      @button.clear stack do
        draw_button(action)
      end
    else
      @button = stack do
        draw_button(action)
      end
    end
  end

end

Shoes.app :title => 'Cute As A Button', :width => 150, :height => 110 do
  working_since = para "#{ws  = 'Started at:'}\n"
  go_home_at    = para "#{gha = 'Go home at:'}\n"
  time_to_go    = para "#{ttg = 'Time to go:'}\n"

  animate(1) do
    if @workday
      if @workday.working?
        working_since.replace "#{ws}\t#{time_as_string(@workday.started_at)}\n"
        time_to_go.replace "#{ttg}\t#{time_as_string(@workday.duration)}\n"
      else
        @workday.idle
      end
      go_home_at.replace "#{gha}\t#{time_as_string(@workday.end_of_work)}\n"
    end
  end

  draw_button_stack('start')
end
