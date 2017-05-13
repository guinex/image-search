class FileManagersController < ApplicationController

  def split
    if request.post?
      if (params[:csv_file]).present?
        file = params[:csv_file].read.force_encoding("ASCII-8BIT").encode('UTF-8', undef: :replace, replace: '')
        filename = 'original_big_file.csv'
        original_name = params[:csv_file].original_filename.split('.')[0]
        File.open(File.join('/tmp/', filename), 'w+') { |f| f.write file }
        HelperMethod.split_file(original_name, params[:split_into].to_i)
      end
      render json: {success: 'File have been processed please check'}
    else
      render json: {success: 'didnt process anything'}
    end
  end

  def file_actions
  end
end
