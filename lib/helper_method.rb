module HelperMethod
###################
# 1. vertical
# 2. adjacent
# 3. no_upper
# 4. background
###################
  RELATION = {
              '1' => {
                alike: [1,4,7,10].freeze
              }.freeze,
              '2' =>{
                side_alike: [3,4,6,7,9,10].freeze
              }.freeze,
              '3' =>{
                base_alike: [4,6,7,8,9,10,11].freeze
                },
              '4' => {
                background_alike: [0,2,9,11].freeze
                },
              '5'=> {
                color_variant: [-1].freeze
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

  def self.calculate_relation(matrix1, matrix2, threshold = 1000)
    result_set = []
    matrix1.each_with_index do |element, index|
      result_set << index if (element - matrix2[index]).abs < threshold
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
    puts '__________________________least alike____________________________'
    return metric.size > 5 ? metric.size : false
  end


  # def self.sort_file_with_similar_designs(data)
  #   # result = []
  #   # data.each do |design_data|
  #   #   if design_data[:similar_designs].present?
  #   #     design_data[:similar_designs].split(',').each do |similar_id|
  #   #       get_position(data, similar_id, design_data[:design_id], design_data[:position])
  #   #     end
  #   #   elsif position_swap.nil?
  #   #     result[design_data[:design_id].to_i] = design_data[:position]
  #   #   end
  #   # end
  #   result = {}
  #   data.each do |design_data|
  #     result[design_data[:design_id]] = {similar_designs: design_data[:similar_designs], position: design_data[:position]}
  #   end
  #   result.each do |res, value|
  #     unless value[:similar_designs].nil?
  #       value[:similar_designs].split(',').each do |id|
  #         if result[id][:position].to_i < value[:position]
  #           result.delete(res)
  #         end
  #       end
  #     end
  #   end
  # end


  def self.calculate_array(block, metric)
    if block.first == -1
      block = [0,1,2,3,4,5,6,7,8,9,10,11]
    end
    matches = (block & metric).size
    (matches/block.size.to_f) > 0.7
  end
end