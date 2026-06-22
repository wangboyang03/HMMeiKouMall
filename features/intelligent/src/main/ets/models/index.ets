export interface Message {
  role: 'system' | 'user' | 'assistant',
  content: string
}

export interface Delta {
  content: string
}

export interface Choice {
  finish_reason?: string | null
  delta: Delta
}

export interface Response {
  id: string
  object: string
  created: number
  model: string
  choices: Choice[]
}

export interface _RequestParams {
  model: string;
  max_tokens: number;
  messages: Message[];
  stream: boolean;
  stream_options?: StreamOptions;
  temperature: number;
}

interface StreamOptions {
  include_usage: boolean;
}