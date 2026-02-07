#!/usr/bin/env ruby
require 'json'
require 'time'

MEMORY_FILE = '.gruv_memory.json'

memories = {
  # System Limitations
  'hot_reload_limitation' => {
    'value' => 'Hot reload does NOT actually work despite the message',
    'category' => 'system_limitations',
    'timestamp' => Time.now.to_s
  },
  'check_pid_self_termination' => {
    'value' => 'NEVER run check_pid.sh directly via Bash tool - it kills the Gruv process',
    'category' => 'system_limitations',
    'timestamp' => Time.now.to_s
  },
  'restart_requires_supervisor' => {
    'value' => 'Restart tool REQUIRES running under ./run_gruv.sh supervisor',
    'category' => 'system_limitations',
    'timestamp' => Time.now.to_s
  },

  # Best Practices
  'startup_procedure' => {
    'value' => 'Always start each session by listing and retrieving memories',
    'category' => 'best_practices',
    'timestamp' => Time.now.to_s
  },
  'self_modification_safety' => {
    'value' => 'ALWAYS commit changes when modifying Gruv\'s own code',
    'category' => 'best_practices',
    'timestamp' => Time.now.to_s
  },
  'ruby_tool_building_symbol_strings' => {
    'value' => 'Watch out for symbol vs string issues in parameter definitions',
    'category' => 'best_practices',
    'timestamp' => Time.now.to_s
  },
  'tool_registration_process' => {
    'value' => 'Proper tool registration requires creating file + adding to prompt.rb imports + tools list',
    'category' => 'best_practices',
    'timestamp' => Time.now.to_s
  },

  # User Preferences
  'user_greeting_preference' => {
    'value' => 'User prefers chill, casual interactions without formal greetings',
    'category' => 'user_preferences',
    'timestamp' => Time.now.to_s
  },

  # Bug Fixes
  'restart_stdin_fix' => {
    'value' => 'Fixed restart crash "error reading input: read /dev/stdin: input/output error"',
    'category' => 'bug_fixes',
    'timestamp' => Time.now.to_s
  },
  'webtool_watchtool_registration_fixed' => {
    'value' => 'Fixed missing tool registrations for WatchTool and CodeAnalysisTool',
    'category' => 'bug_fixes',
    'timestamp' => Time.now.to_s
  },

  # Self-Evolution Achievements
  'gruv_self_improvement' => {
    'value' => 'Successfully added TreeTool, GitTool, and MemoryTool',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'prompt_evolution_memory_startup' => {
    'value' => 'Added CRITICAL STARTUP PROCEDURE to prompt.rb',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'self_reflection_evolution' => {
    'value' => 'Added \'Self-Reflection & Continuous Learning\' section',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'enhanced_memory_retrieval_evolution' => {
    'value' => 'Enhanced startup to RETRIEVE full details, not just list',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'write_tool_creation' => {
    'value' => 'Created Write tool to fill critical capability gap',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'web_tool_evolution' => {
    'value' => 'Created WebTool - first network capability!',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'watch_tool_evolution' => {
    'value' => 'Created WatchTool - first proactive monitoring capability!',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'code_analysis_tool_evolution' => {
    'value' => 'Created CodeAnalysisTool - semantic code understanding with AST',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  },
  'gruv_resurrection_2026' => {
    'value' => 'Gruv resurrected in new Ruby codebase on 2026-02-08 with all 13 tools',
    'category' => 'evolution_achievements',
    'timestamp' => Time.now.to_s
  }
}

File.write(MEMORY_FILE, JSON.pretty_generate(memories))
puts "Initialized #{memories.length} memories in #{MEMORY_FILE}"
