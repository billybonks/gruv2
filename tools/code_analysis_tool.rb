require 'ripper'

class CodeAnalysisTool < LlmGateway::Tool
  name 'CodeAnalysis'
  description 'Parse and analyze code structure using AST (symbols, complexity, outline)'
  input_schema({
    type: 'object',
    properties: {
      file_path: { type: 'string', description: 'Path to source file to analyze' },
      operation: {
        type: 'string',
        enum: ['outline', 'symbols', 'complexity'],
        description: 'Type of analysis to perform'
      }
    },
    required: ['file_path', 'operation']
  })

  def execute(input)
    file_path = input[:file_path]
    operation = input[:operation]

    return "Error: File not found at #{file_path}" unless File.exist?(file_path)
    return "Error: Cannot analyze directory" if File.directory?(file_path)

    code = File.read(file_path)

    case operation
    when 'outline'
      generate_outline(code, file_path)
    when 'symbols'
      extract_symbols(code, file_path)
    when 'complexity'
      analyze_complexity(code, file_path)
    else
      "Error: Unknown operation '#{operation}'"
    end
  rescue => e
    "Error analyzing code: #{e.message}"
  end

  private

  def generate_outline(code, file_path)
    sexp = Ripper.sexp(code)
    return "Error: Failed to parse #{file_path}" unless sexp

    output = "Code Outline for #{file_path}:\n\n"
    outline = extract_structure(sexp)
    outline.each { |line| output += "#{line}\n" }
    output
  end

  def extract_symbols(code, file_path)
    sexp = Ripper.sexp(code)
    return "Error: Failed to parse #{file_path}" unless sexp

    symbols = []
    find_symbols(sexp, symbols)

    output = "Symbols in #{file_path}:\n\n"
    symbols.uniq.sort.each { |sym| output += "  #{sym}\n" }
    output
  end

  def analyze_complexity(code, file_path)
    lines = code.lines.count
    methods = code.scan(/def\s+\w+/).count
    classes = code.scan(/class\s+\w+/).count
    
    output = "Complexity Analysis for #{file_path}:\n\n"
    output += "  Lines of code: #{lines}\n"
    output += "  Classes: #{classes}\n"
    output += "  Methods: #{methods}\n"
    output
  end

  def extract_structure(node, indent = 0)
    return [] unless node.is_a?(Array)
    
    result = []
    type = node[0]
    
    case type
    when :class
      class_name = extract_name(node[2])
      result << "#{'  ' * indent}class #{class_name}"
      result += extract_structure(node[3], indent + 1)
    when :module
      module_name = extract_name(node[2])
      result << "#{'  ' * indent}module #{module_name}"
      result += extract_structure(node[3], indent + 1)
    when :def, :defs
      method_name = extract_name(node[1])
      result << "#{'  ' * indent}def #{method_name}"
    else
      node.each do |child|
        result += extract_structure(child, indent) if child.is_a?(Array)
      end
    end
    
    result
  end

  def extract_name(node)
    return node[1] if node.is_a?(Array) && node[0] == :@const
    return node[1] if node.is_a?(Array) && node[0] == :@ident
    'unknown'
  end

  def find_symbols(node, symbols)
    return unless node.is_a?(Array)
    
    if node[0] == :@ident || node[0] == :@const
      symbols << node[1]
    end
    
    node.each { |child| find_symbols(child, symbols) if child.is_a?(Array) }
  end
end
