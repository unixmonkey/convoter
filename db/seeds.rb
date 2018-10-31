# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class ScrapeConf < Mechanize
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
      year: '2018',
      starts_at: Time.parse('2018-11-13 09:30:00'),
      ends_at: Time.parse('2018-11-15 18:00'),
    ).first_or_create!
  end

  def process_day(day_detail)
    day_of_week = day_detail.attr('id')
    day_name = page.search("a.rc-schedule-nav__link[href='##{day_of_week}']").text.strip.split("\n").last.strip
    puts day_name
    day_detail.search('div.schedule-cell, div.schedule-cell-special').each_with_index do |slot_detail, index|
      puts "processing day: #{day_name}"
      process_slot(slot_detail, day_name)
    end
  end

  def process_slot(slot_detail, day_name)
    slot_start = slot_detail.search('.schedule-time strong').text.strip
    slot_end = slot_detail.search('.schedule-time small').text.strip
    time_range = "#{slot_start}#{slot_end}"
    puts "processing slot: #{time_range}"
    slot = conf.slots.where(name: [day_name, time_range].join(' ')).first_or_create
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
            synopsis = talk.search('p').first.text.strip
            speaker_detail = talk.search('.session-speaker p').text.strip
          end
        end
      end
    else
      puts "\n", "SPECIAL SPECIAL SPECIAL", "\n"
      speaker = talk_detail.search('.schedule-special-container.keynote span.special-speaker').text.strip
      if speaker.present? # a keynote
        title = talk_detail.search('a.special-label').text.strip
        location = talk_detail.search('.schedule-special-container.keynote span.special-location').text.strip
        link = talk_detail.search('a.special-label')
      else # a break
        title = talk_detail.search('span.special-label').text.strip
        location = talk_detail.search('.schedule-special-container span.special-location').text.strip
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
