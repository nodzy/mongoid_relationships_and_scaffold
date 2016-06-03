class Entrant
  include Mongoid::Document
  include Mongoid::Timestamps
  field :bib, as: :bib, type: Integer
  field :secs, as: :secs, type: Float
  field :o, as: :overall, type: Placing
  field :gender, as: :gender, type: Placing
  field :group, as: :group, type: Placing
  store_in collection: 'results'
  embeds_many :results, class_name: 'LegResult', order: [:"event.o".asc], after_add: :update_total, after_remove: :update_total
  embeds_one :race, class_name: 'RaceRef', autobuild: true
  embeds_one :racer, class_name: 'RacerInfo', as: :parent, autobuild: true
  delegate :first_name, :first_name=, to: :racer
  delegate :last_name, :last_name=, to: :racer
  delegate :gender, :gender=, to: :racer, prefix: 'racer'
  delegate :birth_year, :birth_year=, to: :racer
  delegate :city, :city=, to: :racer
  delegate :state, :state=, to: :racer
  delegate :name, :name=, to: :race, prefix: 'race'
  delegate :date, :date=, to: :race, prefix: 'race'
  scope :upcoming, -> { where(:"race.date" => { :$gte => Time.current }) }
  scope :past, -> { where(:"race.date" => { :$lt => Time.current }) }

  def overall_place
    overall.place if overall
end

  def gender_place
    gender.place if gender
  end

  def group_name
    group.name if group
  end

  def group_place
    group.place if group
  end

  def update_total(_result)
    self.secs = 0.0

    self.secs = results.map(&:secs).select { |r| r }.inject(0, :+)
  end

  def the_race
    race.race
  end

  RESULTS = { 'swim' => SwimResult,
              't1' => LegResult,
              'bike' => BikeResult,
              't2' => LegResult,
              'run' => RunResult }.freeze

  RESULTS.keys.each do |name|
    define_method(name.to_s) do
      result = results.select { |result| name == result.event.name if result.event }.first
      unless result
        result = RESULTS[name.to_s].new(event: { name: name })
        results << result
      end
      result
    end
    define_method("#{name}=") do |event|
      event = send(name.to_s).build_event(event.attributes)
    end
    RESULTS[name.to_s].attribute_names.reject { |r| /^_/ === r }.each do |prop|
      define_method("#{name}_#{prop}") do
        event = send(name).send(prop)
      end
      define_method("#{name}_#{prop}=") do |value|
        event = send(name).send("#{prop}=", value)
        update_total nil if /secs/ === prop
      end
    end
  end
end
