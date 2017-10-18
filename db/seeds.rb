# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# rubyconf = Conference.where(
#   name: 'RubyConf',
#   year: '2016',
#   starts_at: Time.parse('2016-11-10 09:30:00'),
#   ends_at: Time.parse('2016-11-12 17:30'),
# ).first_or_create!

class ScrapeRubyConf < Mechanize
  def process
    get('http://rubyconf.org/schedule')
    page.search('div.rc-schedule-day').each do |day_detail|
      process_day(day_detail)
    end
  end

  private

  def rubyconf
    @rubyconf ||= Conference.where(
      name: 'RubyConf',
      year: '2017',
      starts_at: Time.parse('2017-11-15 09:30:00'),
      ends_at: Time.parse('2017-11-17 17:30'),
    ).first_or_create!
  end

  def process_day(day_detail)
    day_of_week = day_detail.attr('id')
    day_name = page.search("a.rc-schedule-nav__link[href='##{day_of_week}']").text.strip.gsub('Nov ', '11/')
    puts day_name
    day_detail.search('li.rc-schedule-list-item').each do |slot_detail|
      puts 'processing day'
      process_slot(slot_detail, day_name)
    end
  end

  def process_slot(slot_detail, day_name)
    time_range = slot_detail.search('.rc-schedule-list-item__time').text.strip
    puts time_range
    slot = rubyconf.slots.where(name: [day_name, time_range].join(' ')).first_or_create
    slot_detail.search('.rc-schedule-talk').each do |talk_detail|
      process_talk(talk_detail, slot)
    end
  end

  def process_talk(talk_detail, slot)
    title = speaker = link = synopsis = speaker_detail = talk = nil
    title = talk_detail.search('.rc-schedule-talk__title').text.strip
    speaker = talk_detail.search('.rc-schedule-talk__speaker').text.strip
    link = talk_detail.search('.rc-schedule-talk__title a').first
    if title && speaker && link
      transact do
        click link if link.present?
        href = link.attributes['href'].value
        if page
          talk = page.search(".session").select{|t| t.search("header h1 a[href='##{href.split('#').last}']").present? }.last
          if talk
            paragraphs = talk.search('p')
            if paragraphs.present?
              if paragraphs[0].present?
                synopsis = paragraphs[0].text
              end
              if paragraphs[1].present?
                speaker_detail = paragraphs[1].text
              end
            end
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
      puts title, speaker, synopsis, speaker_detail, "\n\n"
      slot.talks.where(
        title: title,
        speaker: speaker,
        speaker_detail: speaker_detail,
        synopsis: synopsis,
      ).first_or_create
    end
  end
end
ScrapeRubyConf.new.process
