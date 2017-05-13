module HelperMethod
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
end