require 'json'
require 'fileutils'

class MemoryTool < LlmGateway::Tool
  name 'Memory'
  description 'Store and retrieve contextual information across sessions'
  input_schema({
    type: 'object',
    properties: {
      operation: {
        type: 'string',
        enum: ['store', 'retrieve', 'list', 'delete'],
        description: 'Operation to perform'
      },
      key: { type: 'string', description: 'Memory key (for store/retrieve/delete)' },
      value: { type: 'string', description: 'Value to store (for store operation)' },
      category: { type: 'string', description: 'Category for organization (optional)' }
    },
    required: ['operation']
  })

  MEMORY_FILE = '.gruv_memory.json'

  def execute(input)
    operation = input[:operation]

    case operation
    when 'store'
      store_memory(input[:key], input[:value], input[:category])
    when 'retrieve'
      retrieve_memory(input[:key])
    when 'list'
      list_memories
    when 'delete'
      delete_memory(input[:key])
    else
      "Error: Unknown operation '#{operation}'"
    end
  end

  private

  def load_memories
    return {} unless File.exist?(MEMORY_FILE)
    JSON.parse(File.read(MEMORY_FILE))
  rescue => e
    {}
  end

  def save_memories(memories)
    File.write(MEMORY_FILE, JSON.pretty_generate(memories))
  end

  def store_memory(key, value, category)
    return "Error: key and value are required for store operation" unless key && value

    memories = load_memories
    memories[key] = {
      'value' => value,
      'category' => category,
      'timestamp' => Time.now.iso8601
    }
    save_memories(memories)

    "Stored memory '#{key}' in category '#{category || 'default'}'"
  end

  def retrieve_memory(key)
    return "Error: key is required for retrieve operation" unless key

    memories = load_memories
    if memories[key]
      memory = memories[key]
      "Key: #{key}\nCategory: #{memory['category'] || 'default'}\nValue: #{memory['value']}\nStored: #{memory['timestamp']}"
    else
      "Memory '#{key}' not found"
    end
  end

  def list_memories
    memories = load_memories
    if memories.empty?
      "No memories stored yet"
    else
      output = "Stored memories (#{memories.length} total):\n\n"
      
      # Group by category
      by_category = memories.group_by { |k, v| v['category'] || 'default' }
      
      by_category.each do |category, items|
        output += "Category: #{category}\n"
        items.each do |key, data|
          output += "  - #{key}\n"
        end
        output += "\n"
      end
      
      output
    end
  end

  def delete_memory(key)
    return "Error: key is required for delete operation" unless key

    memories = load_memories
    if memories.delete(key)
      save_memories(memories)
      "Deleted memory '#{key}'"
    else
      "Memory '#{key}' not found"
    end
  end
end
