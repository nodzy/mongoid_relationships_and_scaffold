class BikeResult < LegResult
  field :mph, as: :mph, type: Float
  def calc_ave
    self[:mph] = event.miles * 3600 / secs if event && secs
  end
end
