module CalendarsHelper
  include CalendarHelper

  def make_calendar(this_month, rjs = false)
    next_month = this_month + 1.month
    last_month = this_month - 1.month

    div_id = 'events-calendar'

    # The JS script to run to construct the tooltips varies depending on whether the
    # response is for HTML or RJS. When responding to HTML, the JS func has to be
    # run after the DOM is loaded (at least on IE6 and IE7, but not IE8, Firefox, or
    # Safari). But when responding to RJS, the JS func has to be invoked directly.
    # tooltip_func = 'makeToolTips'.freeze
    # tooltip_script = rjs ? "#{tooltip_func}();" : "document.observe('dom:loaded', #{tooltip_func});"

    calendar_options = {
      :year => this_month.year,
      :month => this_month.month,
      :month_name_class => 'title',
      :first_day_of_week => 1,
      :show_today => true,
      :previous_month_text => %Q{
<a class="calendar-control" href="#{calendar_path(:year => last_month.year, :month => last_month.month)}">
  <span class="previous-month">
  	<span class="image-replacement">#{Date::ABBR_MONTHNAMES[last_month.month]}</span>
  </span>
</a>
      }.squish,
      :next_month_text => %Q{
<a class="calendar-control" href="#{calendar_path(:year => next_month.year, :month => next_month.month)}">
  <span class="next-month">
    <span class="image-replacement">#{Date::ABBR_MONTHNAMES[next_month.month]}</span>
  </span>
</a>
      }.squish,
      :abbrev => (0..0)
    }

    days_with_events = Event.for_month(this_month.month, this_month.year).group_by(&:date)

    returning String.new do |block|
      events = []

      block << %Q{<div id="#{div_id}">}
      block << calendar(calendar_options) do |d|
        if days_with_events.has_key?(d)
          d.inspect
          eod = d + 1.day - 1.second
          events = ActionView::Base.new(ActionController::Base.view_paths).render(:partial => 'calendars/events', :locals => { :id => d.jd, :events => days_with_events[d], :end_of_day => eod })
          event = %Q{
            <span class="tooltip-wrapper">
              <a href="#{events_path(:year => this_month.year, :month => this_month.month, :day => d.mday)}" class="event tooltip-trigger">#{d.mday}</a>
              #{events}
            </span>            
          }        
          [ event, { :class => 'eventDay', :id => "day-#{d.jd}" } ]
        end
        # HACK around a bug in RedCloth that inserts spurious p tags (the extra newlines seem to avoid the problem)
      end.gsub(/(<\/?(table|thead|tbody|tfoot|tr|th|td)[^>]*?>)/, "\n"+'\1')
      block << "\n"
      # block << events.join
      # block << %Q{<script type="text/javascript">#{tooltip_script}</script>\n}
      block << '</div>'
    end
  end

end
