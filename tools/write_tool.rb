class WriteTool < LlmGateway::Tool
  name 'Write'
  description 'Create new files or completely overwrite existing files with content'
  input_schema({
    type: 'object',
    properties: {
      file_path: { type: 'string', description: 'Path to file to create or overwrite' },
      content: { type: 'string', description: 'Complete content to write to the file' }
    },
    required: [ 'file_path', 'content' ]
  })

  def execute(input)
    file_path = input[:file_path]
    content = input[:content]

    begin
      # Create parent directories if they don't exist
      dir = File.dirname(file_path)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

      # Write the file
      File.write(file_path, content)

      file_size = File.size(file_path)
      line_count = content.lines.count

      "Successfully wrote #{line_count} lines (#{file_size} bytes) to #{file_path}"
    rescue => e
      "Error writing file: #{e.message}"
    end
  end
end
