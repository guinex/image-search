module HelperMethod
###################
# 1. vertical
# 2. adjacent
# 3. no_upper
# 4. background
###################
  RELATION = {
              '1' => {
                alike: [1,4,7,10].freeze,
                bottom_alike: [4,7,10].freeze,
                top_alike: [1,4,7].freeze
              }.freeze,
              '2' =>{
                left_alike: [3,4,6,7,9,10].freeze,
                right_alike: [5,4,8,7,11,10].freeze
              }.freeze,
              '3' =>{
                base_alike: [4,6,7,8,9,10,11].freeze
                },
              '4' => {
                background_alike: [0,2,9,11].freeze
              }
            }.freeze
  def self.split_file(file_path, into)
    file = '/tmp/original_big_file.csv'
    csv_file = SmarterCSV.process(file)
    counter = 0
    csv_file.in_groups_of(into) do |batch|
      header =false
      CSV.open("tmp/#{counter}_#{file_path}.csv", "w", {col_sep: ","}) do |f|
        f << %w(design_id country_id  scale country_code) unless header
        header =true
        batch.compact.each do |row|
          f << [row[:design_id], row[:country_id], row[:scale],  row[:country_code]]
        end
      end
      counter = counter + 1
    end
  end

  def self.calculate_distance(d_hash, average)
    (Math.sqrt(d_hash.values.collect{|rgb| rgb*rgb}.inject(:+)) / average)
  end

  def self.calculate_relation(matrix1, matrix2)
    result_set = []
    matrix1.each_with_index do |element, index|
      result_set << index if (element - matrix2[index]).abs < 10000
    end
    get_relation(result_set,1)
  end

  # def matrix_relation(metric)
  #   min_indices = []
  #   metric.each_with_index{|i, index| min_indices << index if i < 10000}
  #   get_relation(min_indices,1)
  # end

  def self.get_relation(metric, index)
    if RELATION[index.to_s].is_a?(Hash)
      RELATION[index.to_s].each do |key, value|
        if calculate_array(value, metric)
          return key
        else
          next
        end
      end
      get_relation(metric, index+1)
    elsif RELATION[index.to_s].is_a?(Array) && calculate_array(RELATION[index.to_s], metric)
        return index
    elsif RELATION[index.to_s].present?
      get_relation(metric, index+1)
    end
    puts '__________________________relation_rejected____________________________'
    return metric.size > 5 ? metric.size : false
  end

  def self.calculate_array(block, metric)
    (block == metric)
  end
end