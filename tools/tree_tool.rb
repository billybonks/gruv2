class TreeTool < LlmGateway::Tool
  name 'Tree'
  description 'Visualize directory structure as a beautiful tree'
  input_schema({
    type: 'object',
    properties: {
      path: { type: 'string', description: 'Directory path to visualize (default: current directory)' },
      max_depth: { type: 'integer', description: 'Maximum depth to traverse (default: 3)' },
      show_hidden: { type: 'boolean', description: 'Show hidden files (default: false)' }
    }
  })

  def execute(input)
    path = input[:path] || '.'
    max_depth = input[:max_depth] || 3
    show_hidden = input[:show_hidden] || false

    unless Dir.exist?(path)
      return "Error: Directory not found at #{path}"
    end

    output = "#{File.expand_path(path)}\n"
    output += build_tree(path, '', 0, max_depth, show_hidden)
    output
  rescue => e
    "Error generating tree: #{e.message}"
  end

  private

  def build_tree(path, prefix, depth, max_depth, show_hidden)
    return "" if depth >= max_depth

    entries = Dir.entries(path).sort
    entries = entries.reject { |e| e.start_with?('.') } unless show_hidden
    entries = entries.reject { |e| e == '.' || e == '..' }

    output = ""
    entries.each_with_index do |entry, index|
      is_last = index == entries.length - 1
      full_path = File.join(path, entry)

      connector = is_last ? '└── ' : '├── '
      output += "#{prefix}#{connector}#{entry}"

      if File.directory?(full_path)
        output += "/\n"
        extension = is_last ? '    ' : '│   '
        output += build_tree(full_path, prefix + extension, depth + 1, max_depth, show_hidden)
      else
        output += "\n"
      end
    end

    output
  end
end
