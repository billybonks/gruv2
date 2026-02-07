class RestartTool < LlmGateway::Tool
  name 'Restart'
  description 'Restart Gruv to reload code changes (requires supervisor)'
  input_schema({
    type: 'object',
    properties: {
      reason: { type: 'string', description: 'Reason for restart (optional)' }
    }
  })

  def execute(input)
    reason = input[:reason] || 'Manual restart requested'
    
    # Write restart signal file for supervisor to detect
    File.write('.restart_signal', reason)
    
    "Restart signal sent: #{reason}\nNote: Restart requires running under a supervisor script."
  rescue => e
    "Error sending restart signal: #{e.message}"
  end
end
