# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class ScrapeConf < Mechanize
  def process
    get('http://railsconf.com/schedule')
    page.search('div.rc-schedule-day').each_with_index do |day_detail, index|
      process_day(day_detail)
    end
  end

  private

  def conf
    @conf ||= Conference.where(
      name: 'RailsConf',
      year: '2018',
      starts_at: Time.parse('2018-04-17 09:30:00'),
      ends_at: Time.parse('2018-04-19 18:00'),
    ).first_or_create!
  end

  def process_day(day_detail)
    day_of_week = day_detail.attr('id')
    day_name = page.search("a.rc-schedule-nav__link[href='##{day_of_week}']").text.strip.split("\n").last.strip.gsub('April ', '4/')
    puts day_name
    day_detail.search('li.rc-schedule-list-item').each_with_index do |slot_detail, index|
      puts "processing day: #{day_name}"
      process_slot(slot_detail, day_name)
    end
  end

  def process_slot(slot_detail, day_name)
    time_range = slot_detail.search('.rc-schedule-list-item__time').text.strip
    puts "processing slot: #{time_range}"
    slot = conf.slots.where(name: [day_name, time_range].join(' ')).first_or_create
    slot_detail.search('.rc-schedule-talk').each_with_index do |talk_detail, index|
      process_talk(talk_detail, slot)
    end
  end

  def process_talk(talk_detail, slot)
    title = speaker = link = synopsis = speaker_detail = talk = location = nil
    title = talk_detail.search('.rc-schedule-talk__title').text.strip
    speaker = talk_detail.search('.rc-schedule-talk__speaker').text.strip
    location = talk_detail.search('.rc-schedule-talk__room').text.strip
    link = talk_detail.search('.rc-schedule-talk__title a').first
    if title && location
      transact do
        click link if link.present?
        href = link.attributes['href'].value if link.respond_to?(:attributes)
        if page && href
          talk = page.search(".session").select{|t| t.search("a[href='##{href.split('#').last}']").present? }.last
          if talk
            synopsis = talk.search('.markdown-content--session').first.text.strip
            speaker_detail = talk.search('.session__speaker .markdown-content--session').text.strip
          else
            # probably a keynote or break
            keynote_detail = page.search('article.keynote').detect{|s|
              speakers = s.search('h1.speaker__name')
              speakers.present? && speakers.last.text.strip == speaker
            }
            if keynote_detail
              speaker_detail = keynote_detail.search('.keynote__content p').text.strip
            end
          end
        end
      end
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
end
# ScrapeConf.new.process
