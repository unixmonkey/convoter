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
    page.search('div.schedule-day').each do |day_detail|
      process_day(day_detail)
    end
  end

  private

  def rubyconf
    @rubyconf ||= Conference.where(
      name: 'RubyConf',
      year: '2016',
      starts_at: Time.parse('2016-11-10 09:30:00'),
      ends_at: Time.parse('2016-11-12 17:30'),
    ).first_or_create!
  end

  def process_day(day_detail)
    day_name = day_detail.search('.schedule-day-title').text
    puts day_name
    day_detail.search('li.schedule-day-list-item').each do |slot_detail|
      process_slot(slot_detail, day_name)
    end
  end

  def process_slot(slot_detail, day_name)
    time_range = slot_detail.search('.schedule-day-list-item-time').text
    puts time_range
    slot = rubyconf.slots.where(name: [day_name, time_range].join(' ')).first_or_create
    slot_detail.search('.schedule-day-talk').each do |talk_detail|
      process_talk(talk_detail, slot)
    end
  end

  def process_talk(talk_detail, slot)
    title = speaker = link = synopsis = speaker_detail = talk = nil
    title = talk_detail.search('.schedule-day-talk-title').text
    speaker = talk_detail.search('.schedule-day-talk-speaker').text
    link = talk_detail.search('.schedule-day-talk-title a').first
    if title && speaker && link
      transact do
        click link if link.present?
        href = link.attributes['href'].value
        talk = page.search('.session').select{|t| t.search(".session-talk a[href='#{href}']").present? }.last
        paragraphs = talk.search('p')
        if paragraphs.present? && paragraphs[1].present?
          synopsis = paragraphs[1].text
        end
        speaker_info = talk.search('.session-speaker p')
        if speaker_info.present? && speaker_info[1].present?
          speaker_detail = speaker_info[1].text
        end
      end
      puts title, speaker, synopsis, speaker_detail, "\n\n"
    end
    slot.talks.where(
      title: title,
      speaker: speaker,
      speaker_detail: speaker_detail,
      synopsis: synopsis,
    ).first_or_create
  end
end
ScrapeRubyConf.new.process
