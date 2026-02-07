class GitTool < LlmGateway::Tool
  name 'Git'
  description 'Perform git operations (status, diff, log, commit, etc.)'
  input_schema({
    type: 'object',
    properties: {
      operation: {
        type: 'string',
        enum: ['status', 'diff', 'log', 'add', 'commit', 'branch', 'show'],
        description: 'Git operation to perform'
      },
      args: { type: 'array', items: { type: 'string' }, description: 'Arguments for the operation' },
      message: { type: 'string', description: 'Commit message (for commit operation)' }
    },
    required: ['operation']
  })

  def execute(input)
    operation = input[:operation]
    args = input[:args] || []
    message = input[:message]

    case operation
    when 'status'
      run_git('status', args)
    when 'diff'
      run_git('diff', args)
    when 'log'
      log_args = args.empty? ? ['--oneline', '-10'] : args
      run_git('log', log_args)
    when 'add'
      return "Error: files to add must be specified in args" if args.empty?
      run_git('add', args)
    when 'commit'
      return "Error: commit message required" unless message
      run_git('commit', ['-m', message])
    when 'branch'
      run_git('branch', args)
    when 'show'
      run_git('show', args)
    else
      "Error: Unknown git operation '#{operation}'"
    end
  rescue => e
    "Error executing git command: #{e.message}"
  end

  private

  def run_git(command, args)
    cmd = ['git', command] + args
    result = `#{cmd.join(' ')} 2>&1`
    status = $?.success?

    if status
      result.empty? ? "Command completed successfully (no output)" : result
    else
      "Git command failed:\n#{result}"
    end
  end
end
