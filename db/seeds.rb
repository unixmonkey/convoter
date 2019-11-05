# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class ScrapeConf < Mechanize
  RUBYCONF_2019_DATES = {
    "tuesday" => "2019-11-18",
    "wednesday" => "2019-11-19",
    "thursday" => "2019-11-20",
  }

  def process
    get('http://rubyconf.org/schedule')
    page.search('div.js-schedule-day').each_with_index do |day_detail, index|
      puts "here"
      process_day(day_detail)
    end
  end

  private

  def conf
    @conf ||= Conference.where(
      name: 'RubyConf',
      year: '2019',
      starts_at: Time.parse('2019-11-18 09:30:00'),
      ends_at: Time.parse('2019-11-20 18:00'),
    ).first_or_create!
  end

  def process_day(day_detail)
    day_of_week = day_detail.attr('id')
    day_name = page.search("a.rc-schedule-nav__link[href='##{day_of_week}']").text.strip.split("\n").last.strip
    puts day_name
    day_detail.search('div.schedule-cell').each_with_index do |slot_detail, index|
      puts "processing day: #{day_name}"
      process_slot(slot_detail, day_name)
    end
    day_detail.search('div.schedule-cell-special').each_with_index do |slot_detail, index|
      puts "processing day: #{day_name}"
      process_special_slot(slot_detail, day_name)
    end
  end

  def process_special_slot(slot_detail, day_name)
    slot_start = slot_detail.search('.schedule-time strong').text.strip
    slot_end = slot_detail.search('.schedule-time small').text.strip
    time_range = "#{slot_start}#{slot_end}"
    date = RUBYCONF_2019_DATES[day_name.downcase]
    puts "processing slot: #{time_range}"
    puts "starts #{date} #{slot_start}"
    slot = conf.slots.where(name: [day_name, time_range].join(' ')).first_or_create(starts_at: "#{date} #{slot_start}", ends_at: "#{date} #{slot_end}")
    speaker = slot_detail.search('.schedule-special-container.keynote span.special-speaker').text.strip
    if speaker.present? # a keynote
      title = slot_detail.search('a.special-label').text.strip
      puts "process special slot (keynote): #{time_range} #{title}"
      location = slot_detail.search('.schedule-special-container.keynote span.special-location').text.strip
      slot.talks.where(
        title: title,
        speaker: speaker,
        location: location,
        keynote: true
      ).first_or_create
    else # a break
      title = slot_detail.search('span.special-label').text.strip
      puts "process special slot (break): #{time_range} #{title}"
      location = slot_detail.search('.schedule-special-container span.special-location').text.strip
      slot.talks.where(
        title: title,
        speaker: speaker,
        location: location,
        break: true
      ).first_or_create
    end
  end

  def process_slot(slot_detail, day_name)
    slot_start = slot_detail.search('.schedule-time strong').text.strip
    slot_end = slot_detail.search('.schedule-time small').text.strip
    time_range = "#{slot_start}#{slot_end}"
    date = RUBYCONF_2019_DATES[day_name.downcase]
    puts "processing slot: #{time_range}"
    puts "starts #{date} #{slot_start}"
    slot = conf.slots.where(name: [day_name, time_range].join(' ')).first_or_create(starts_at: "#{date} #{slot_start}", ends_at: "#{date} #{slot_end}")
    slot_detail.search('div').each_with_index do |talk_detail, index|
      process_talk(talk_detail, slot)
    end
  end

  def process_talk(talk_detail, slot)
    title = speaker = link = synopsis = speaker_detail = talk = location = nil
    title = talk_detail.search('a.schedule-title').text.strip
    speaker = talk_detail.search('h4.schedule-speaker').text.strip
    location = talk_detail.search('span.schedule-location').text.strip
    link = talk_detail.search('a.schedule-title').first
    if title.present? && location.present?
      transact do
        click link if link.present?
        href = link.attributes['href'].value if link.respond_to?(:attributes)
        if page && href
          talk = page.search(".session").select{|t| t.search("a[href='##{href.split('#').last}']").present? }.last
          if talk
            synopsis = talk.search('p')[1].text.strip
            speaker_detail = talk.search('.session-speaker p').text.strip
          end
        end
      end
    end
    return if [title, speaker, speaker_detail, synopsis, location].all?(&:blank?)
    puts 'processing talk:', "title: #{title}", "speaker: #{speaker}", "location: #{location}", "synopsis: #{synopsis}", "speaker_detail: #{speaker_detail}", "****"
    slot.talks.where(
      title: title,
      speaker: speaker,
      speaker_detail: speaker_detail,
      synopsis: synopsis,
      location: location,
    ).first_or_create
  end
end
ScrapeConf.new.process
