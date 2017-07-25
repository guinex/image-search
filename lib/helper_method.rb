module HelperMethod
###################
# 1. vertical
# 2. adjacent
# 3. no_upper
# 4. background
###################
  RELATION = {
              '1' => {
                vertical_all: [1,4,7,10].freeze,
                vertical_no_head: [4,7,10].freeze,
                vertical_no_bottom: [1,4,7].freeze
              }.freeze,
              '2' =>{
                left_side: [3,4,6,7,9,10].freeze,
                right_side: [5,4,8,7,11,10].freeze
              }.freeze,
              '3' => [4,6,7,8,9,10,11].freeze,
              '4' => [0,2,9,11].freeze
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

  def calculate_relation(matrix1, matrix2)
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

  def get_relation(metric, index)
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
    else
      get_relation(metric, index+1)
    end
    return false
  end

  def calculate_array(block, metric)
    (block == metric)
  end
end