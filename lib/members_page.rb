# frozen_string_literal: true

require 'scraped'

class MembersPage < CdepPage
  field :members do
    noko.css('.grup-parlamentar-list').xpath('.//table//tr[td]').map do |tr|
      fragment tr => MemberRow
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    source[/idm=(\d+)/, 1]
  end

  field :sort_name do
    tds[1].text.tidy
  end

  field :faction do
    tds[3].text.tidy
  end

  field :area do
    area_data.last
  end

  field :area_id do
    area_data.first
  end

  field :term do
    url[/leg=(\d+)/, 1]
  end

  field :source do
    tds[1].css('a/@href').text
  end

  field :start_date do
    date if current?
  end

  field :end_date do
    date if ex?
  end

  private

  def area_data
    tds[2].text.split(%r{\s*/\s*}, 2).map(&:tidy)
  end

  def tds
    noko.css('td')
  end

  def date
    tds[4]&.text.to_s.to_date
  end

  def section
    noko.xpath('preceding::h1').text
  end

  def current?
    !ex?
  end

  def ex?
    section.include? 'finished'
  end
end
