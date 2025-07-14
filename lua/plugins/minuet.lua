-- ============================================================================
-- Minuet AI - AI-powered code completion
-- ============================================================================

return {
  'milanglacier/minuet-ai.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp', -- optional but recommended for better integration
  },
  config = function()
    require('minuet').setup {
      provider = 'openai',
      provider_options = {
        openai_compatible = {
          model = 'gpt-4.1-mini',
          stream = true,
          system = "You are a helpful coding assistant.",
          few_shots = "hello",
          chat_input = "hello",
          api_key = 'OPENAI_API_KEY',
          -- end_point = 'http://localhost:11434/v1/chat/completions' -- to use ollama
          -- see https://github.com/milanglacier/minuet-ai.nvim?tab=readme-ov-file#quick-start to handle more models or setups
          optional = {
            max_tokens = 256,
          },
        },
      },
    }
  end,
}
