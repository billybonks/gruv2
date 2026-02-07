class WatchTool < LlmGateway::Tool
  name 'Watch'
  description 'Monitor files/directories for changes and detect modifications proactively'
  input_schema({
    type: 'object',
    properties: {
      operation: {
        type: 'string',
        enum: ['start', 'stop', 'status', 'check'],
        description: 'Watch operation'
      },
      path: { type: 'string', description: 'File or directory path to watch' },
      interval: { type: 'integer', description: 'Check interval in seconds (default: 1)' }
    },
    required: ['operation']
  })

  @@watches = {}

  def execute(input)
    operation = input[:operation]
    path = input[:path]
    interval = input[:interval] || 1

    case operation
    when 'start'
      start_watch(path, interval)
    when 'stop'
      stop_watch(path)
    when 'status'
      watch_status
    when 'check'
      check_changes(path)
    else
      "Error: Unknown watch operation '#{operation}'"
    end
  rescue => e
    "Error in watch operation: #{e.message}"
  end

  private

  def start_watch(path, interval)
    return "Error: path required for start operation" unless path
    return "Error: path does not exist: #{path}" unless File.exist?(path)

    @@watches[path] = {
      interval: interval,
      last_modified: get_modification_time(path),
      started_at: Time.now
    }

    "Started watching #{path} (interval: #{interval}s)"
  end

  def stop_watch(path)
    return "Error: path required for stop operation" unless path

    if @@watches.delete(path)
      "Stopped watching #{path}"
    else
      "#{path} is not being watched"
    end
  end

  def watch_status
    if @@watches.empty?
      "No active watches"
    else
      output = "Active watches (#{@@watches.length}):\n"
      @@watches.each do |path, data|
        output += "  #{path} (started: #{data[:started_at]}, interval: #{data[:interval]}s)\n"
      end
      output
    end
  end

  def check_changes(path)
    return "Error: path required for check operation" unless path
    return "Error: #{path} is not being watched" unless @@watches[path]

    current_mtime = get_modification_time(path)
    last_mtime = @@watches[path][:last_modified]

    if current_mtime > last_mtime
      @@watches[path][:last_modified] = current_mtime
      "Changes detected in #{path} (modified: #{current_mtime})"
    else
      "No changes detected in #{path}"
    end
  end

  def get_modification_time(path)
    File.mtime(path)
  end
end
